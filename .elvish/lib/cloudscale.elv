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
    http GET (api $path) (auth-header)
}

fn create [path args]{
    put $args | to-json | http POST (api $path) (auth-header)
}

fn update [path args]{
    put $args | to-json | http PATCH (api $path) (auth-header)
}

fn delete [path]{
    http DELETE (api $path) (auth-header)
}

#
#   Server Functions
#
fn servers {
    show /servers | jq -r '.[] | [.name, .uuid, .flavor.slug, .zone.slug] | @tsv'
}

fn server-uuid [name]{
    servers | grep -E "^"$name"\t" | awk '{print $2}'
}

fn server [name]{
    show /servers/(server-uuid $name) 
}

fn create-server [@params]{
    create /servers (with-defaults $@params [
        &image=ubuntu-18.04
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