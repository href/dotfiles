use str

#
#   Utility Functions
#
fn auth-header {
    put 'Authorization: Bearer '$E:CLOUDSCALE_API_TOKEN
}

fn api [path]{
    if (not (eq $E:CLOUDSCALE_API_URL "")) {
        put $E:CLOUDSCALE_API_URL''$path
    } else {
        put 'https://api.cloudscale.ch/v1'$path
    }
}

fn with-defaults [params defaults]{
    keys $defaults | each [key]{
        if (not (has-key $params $key)) {
            params[$key] = $defaults[$key]
        }
    }

    put $params
}

#
#   HTTP Functions
#
fn show [path]{
    http --check-status GET (api $path) (auth-header)
}

fn create [path args]{
    server = (put $args | to-json | http --check-status POST (api $path) (auth-header) | slurp)

    echo "Created "(echo $server | from-json)[href]
    echo $server | jq -r '.interfaces[].addresses[].address' | each [address]{

        # Announce address
        echo $address

        # Clear existing host fingerprints
        ssh-keygen -R $address stderr>/dev/null stdout>/dev/null
    }
}

fn update [path args]{
    put $args | to-json | http PATCH (api $path) (auth-header)
}

fn delete [path]{
    if (str:has-prefix $path "https://") {
        http --check-status DELETE $path (auth-header) > /dev/null
    } else {
        http --check-status DELETE (api $path) (auth-header) > /dev/null
    }
}

#
#   Server Functions
#
fn servers {
    show /servers | jq -r '.[] | [.name, .uuid, .flavor.slug, .zone.slug] | @tsv'
}

fn server-uuid [name]{
    show /servers | jq -r '.[] | select(.name | contains("'$name'")) | .uuid'
}

fn server [name]{
    show /servers/(server-uuid $name)
}

fn create-server [@params]{
    create /servers (with-defaults $@params [
        &image=ubuntu-20.04
        &ssh_keys=[(cat ~/.ssh/cloudscale.pub)]
        &use_ipv6=$true
        &flavor=flex-2
        &user_data=(cat ~/Inits/generic.yml | slurp)
    ])
}

fn delete-server [name]{
    delete /servers/(server-uuid $name)
}

fn delete-server-fuzzy [name]{
    servers | grep $name | awk '{print $2}' | each [uuid]{
        delete /servers/$uuid
    }
}

fn a [name]{
    server $name | jq -r '.interfaces[].addresses[] | select( .version | contains(4)) | .address'
}

fn aaaa [name]{
    server $name | jq -r '.interfaces[].addresses[] | select( .version | contains(6)) | .address'
}