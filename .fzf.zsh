# Setup fzf
# ---------
if [[ ! "$PATH" == */opt/boxen/homebrew/opt/fzf/bin* ]]; then
  export PATH="$PATH:/opt/boxen/homebrew/opt/fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/opt/boxen/homebrew/opt/fzf/shell/completion.zsh" 2> /dev/null
