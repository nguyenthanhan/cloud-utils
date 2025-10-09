# Aliases
alias ls='eza'
alias ll='ls -alF'
alias la='ls -A'
alias c='clear'
if ! command -v bat &> /dev/null; then
    alias bat="batcat"
fi
alias cat="bat --paging=never"
alias avd='~/Library/Android/sdk/tools/emulator -list-avds'
alias gpf='git push -f && git fetch'
alias gfda='git fetch origin develop:develop && git fetch --all --prune'
alias gfm='git fetch origin main:main'
alias xcls='xcrun simctl list devices'
alias python="python3"
alias ..='cd ..'
alias ...='cd ../..'
cd() {
    builtin cd "$@" && ls -a
}
