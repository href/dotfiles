#
#   Utility Functions
#
fn auth-header {
    put 'Authorization: Bearer '$E:CLOUDSCALE_API_TOKEN
}

fn api [path]{
    put 'https://api.cloudscale.ch/v1'$path
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
    delete /servers/(servers | grep $name | awk '{print $2}')
}
