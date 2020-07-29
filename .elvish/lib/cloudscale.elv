use re
use str
use utils

# Returns the auth header for all cloudscale.ch API requests
fn auth-header {
    put 'Authorization: Bearer '$E:CLOUDSCALE_API_TOKEN
}

# Returns the API URL base
fn url {
    utils:default $E:CLOUDSCALE_API_URL 'https://api.cloudscale.ch/v1'
}

# Takes a path or URL and ensures that it is a full API URL
fn full-url [path]{

    if (str:has-prefix $path 'https://') {
        put $path; return
    }

    if (str:has-prefix $path '/') {
        path = (str:trim-prefix $path '/')
    }

    put (url)"/"$path
}

# Runs an authenticated HTTP request against the given path
fn request [method path &body=$nil]{

    # If the path is a map, we will try to get the href out of it
    if (has-key $path href) {
        path = $path[href]
    }

    # Turn the path into a full URL (or leave if it is one already)
    url = (full-url $path)

    # Make sure the token is not sent to the wrong address
    utils:assert "Invalid API call: "$url {
        re:match 'https://[a-z]+.cloudscale.ch/.*' $url
    }

    curl ({

        # Authenticate the request
        put "--header" (auth-header)

        # Declare the body to be JSON
        put "--header" "Content-Type: application/json"

        # Include the body if given
        if (not-eq $body $nil) {
            put "--data" (to-json [$body])
        }

        # # Do not show progress
        put "--silent"

        # Cause curl to fail if the request fails
        put "--fail"

        # Show an error in this case
        put "--show-error"

        # Specify the actual request
        put "--request" $method $url

    }) | from-json
}

# Request shortcuts
fn delete [path]{ request 'DELETE' $path }
fn get [path]{ request 'GET' $path }
fn patch [path body]{ request 'PATCH' $path &body=$body }
fn post [path body]{ request 'POST' $path &body=$body }
fn put [path body]{ request 'GET' $path &body=$body }

# Return all known addresses of the server
fn server-addresses [server &types=[public private] &versions=[4 6]]{

    for interface $server[interfaces] {

        # Skip unwanted types
        if (not (has-value $types $interface[type])) {
            continue
        }

        for address $interface[addresses] {

            # Skip unwanted versions
            if (not (has-value $versions (to-string $address[version]))) {
                continue
            }

            put $address
        }
    }
}

# Condense the full server JSON to a readable summary
fn server-summary [server]{

    # Print the summary as table
    utils:table [({

        # General info
        put ['Name:' (styled $server[name] bold)]
        put ['Zone:' $server[zone][slug]]
        put ['UUID': (styled $server[uuid] dim)]

        # Runtime info
        put ['Status:' ({
            if (eq $server[status] 'running') {
                put (styled 'running' green)
            } elif (eq $server[status] 'stopped') {
                put (styled 'stopped' red)
            } else {
                put (styled $server[status] blue)
            }
        })]

        # Server type
        put ['Flavor:' $server[flavor][slug]]
        put ['Image:' $server[image][slug]]

        # Addresses
        for a [(server-addresses $server)] {
            put ['IPv'$a[version]':' $a[address]]
        }

    })]
}

# Launch a new server
fn server-launch [@options]{
    server = (post '/servers' (utils:with-defaults $@options [
        &name=test-(str:to-lower (uuidgen | cut -d '-' -f 1))
        &image=ubuntu-20.04
        &ssh_keys=[(cat ~/.ssh/cloudscale.pub)]
        &use_ipv6=$true
        &flavor=flex-2
        &user_data=(cat ~/Inits/generic.yml | slurp)
    ]))

    # Clear existing host fingerprints
    server-addresses $server | each [address]{
        ssh-keygen -R $address stderr>/dev/null stdout>/dev/null
    }

    server-summary $server
}

# Returns the UUID(s) of the servers that match the given name.
fn server-uuid [name]{
    get /servers | to-json | jq -r '.[] | select(.name | contains("'$name'")) | .uuid'
}

# Returns the server data of the servers that match the given name.
fn server [name]{
    get /servers/(server-uuid $name)
}

# Delete a server (or a number of them)
fn server-delete [name &fuzzy=$false]{
    uuids = [(server-uuid $name)]

    if (eq (count $uuids) 0) {
        fail "No such server"
    }

    if (eq (count $uuids) 1) {
        delete /servers/$uuids[0]
    } else {
        if (not-eq $fuzzy $true) {
            fail "More than one server matched, use &fuzzy=$true to delete"
        }

        for uuid $uuids {
            delete /servers/$uuid
        }
    }
}

# Get the public IPv4 address of a server
fn server-a [name]{
    servers = [(server $name)]

    if (eq (count $servers) 0) {
        fail "No such server"
    }

    if (eq (count $servers) 1) {
        put (server-addresses $servers[0] &types=[public] &versions=[4])[address]
    } else {
        fail "Matched more than one server"
    }
}

# Get the public IPv6 address of a server
fn server-aaaa [name]{
    servers = [(server $name)]

    if (eq (count $servers) 0) {
        fail "No such server"
    }

    if (eq (count $servers) 1) {
        put (server-addresses $servers[0] &types=[public] &versions=[6])[address]
    }

    fail "Matched more than one server"
}

# Styles server status output
fn server-status-icon [status]{
    if (eq (to-string $status) 'running') {
        styled-segment '•' &fg-color=green; return
    }

    if (eq (to-string $status) 'stopped') {
        styled-segment '•' &fg-color=red; return
    }

    styled-segment '•' &fg-color=blue
}

# Render a table of all servers as table
fn server-list {
    utils:table [({
        for server (get '/servers') {
            put [
                (styled $server[status] $server-status-icon~)
                (styled $server[name] bold)
                $server[zone][slug]
                $server[image][slug]
                (styled $server[uuid] dim)
            ]
        }
    })]
}
