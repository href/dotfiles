fn clear-pane {|pane|
  tmux send-keys -t $pane "projects:clear" Enter
  tmux send-keys -t $pane "cd" Enter
  tmux send-keys -t $pane "clear" Enter
  tmux send-keys -t $pane C-u
}

fn reset {
  tmux split-window -h -p 72 -t 0
  tmux split-window -h -p 39 -t 1
  clear-pane 0
  clear-pane 1
  clear-pane 2
  sleep 0.25
  clear-pane 1
  tmux select-pane -t 1
}

fn new-window {
  tmux new-window
  tmux rename-window Shell
  tmux send-keys 'tmux:reset' Enter
}