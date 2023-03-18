use str

fn GET {|path|
  curl -s ^
    -H "X-Auth-Token: "$E:ROCKETCHAT_PASS ^
    -H "X-User-Id: "$E:ROCKETCHAT_USER ^
    -H "Content-Type: application/json" ^
    https://$E:ROCKETCHAT_HOST/$path
}

# Returns a map of unread counts, as follows:
#
# [
#   &general=[&count=1, &type="channel" &alert=1]
#   &john=[&count=0 &type="direct" &alert=0]
# ]
#
# Note that it looks like the 'count' is always zero, unless no client has
# fetched these messages yet. Therefore it is best to use the 'alert' as
# indicator if something is actually unread.
#
fn unread-count {
  GET '/api/v1/subscriptions.get' ^
    | jq '.update | 
      map({
        (.name): {
          count: .unread,
          user_mentions: .userMentions,
          group_mentions: .groupMentions,
          type: (if .c == "c" then "channel" else "direct" end),
          alert: .alert
        }
      }) | add' ^
    | from-json
}

# Returns true if the given channel is deemed important
fn is-important-channel {|channel|
  if (eq $channel "prod-alerts") {
    put $true
    return
  }

  if (str:has-prefix $channel "sys") {
    put $true
    return
  }

  put $false
}

# Shows a colored output if there are alerts in rocketchat:
#
# - If there are no alerts, there's no output.
# - If there is an alert, the first channel with an alert is shown.
# - If the channel is important, the background is red.
# - If the channel is not important, the background is green.
#
fn chat-status {
  var unread = (unread-count)

  for name [(keys $unread)] {
    var alert = (bool $unread[$name][alert])

    if (and $alert (is-important-channel $name)) {
      print (styled "#"$name red)" | ansi=true"
      return
    }
  }

  for name [(keys $unread)] {
    var alert = (bool $unread[$name][alert])

    if (eq $alert $true) {
      print (styled "#"$name green)" | ansi=true"
      return
    }
  }
} 