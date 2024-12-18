use str

fn context {|site access_key secret_key|
    var env zone = (str:split "-" $site)

    put [
        &site=$site
        &access_key=$access_key
        &secret_key=$secret_key
        &env=$env
        &zone=$zone
        &region=(str:trim-right $zone "123456789")
    ]
}

fn endpoint {|context|
    str:join "." [({
        if (eq $context[env] "exp") {
            put "exp-objects"
        } elif (eq $context[env] "lab") {
            put "lab-objects"
        } else {
            put "objects"
        }

        put $context[region]
        put "cloudscale"

        if (eq $context[env] "prod") {
            put "ch"
        } else {
            put "zone"
        }
    })]
}

fn api {|context @args|
    with [E:AWS_ACCESS_KEY_ID = $context[access_key]] ^
         [E:AWS_SECRET_ACCESS_KEY = $context[secret_key]] {
        aws s3api --endpoint "https://"(endpoint $context) $@args
    }
}

fn cmd {|context @args|
    s3cmd ^
    --access_key $context[access_key] ^
    --secret_key $context[secret_key] ^
    --host (endpoint $context) ^
    --host-bucket "%(bucket)s."(endpoint $context) $@args
}
