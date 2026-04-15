# ==============================================================================
#  ZSH CONFIGURATION (Single File)
# ==============================================================================

# {{{ 1. Environment Variables & Paths
# ------------------------------------------------------------------------------
export EDITOR='vim'
export PAGER='less -irf'
export GREP_COLOR='40;33;01'

# Manpages Colors
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;32m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[04;36;4m'

# System Paths
path=($HOME/bin $HOME/.local/bin $path)
export PATH
# }}}

# {{{ 2. Zsh Options
# ------------------------------------------------------------------------------
# History
export HISTSIZE=500
export SAVEHIST=500
export HISTFILE=~/.zsh_history
export KEYTIMEOUT=1

setopt HIST_IGNORE_DUPS       # Ignore duplicate commands in history
setopt AUTO_PUSHD             # Make cd push the old directory onto the directory stack
setopt PUSHD_IGNORE_DUPS      # Don't push multiple copies of the same directory onto the stack
setopt HIST_IGNORE_SPACE      # Don't record an entry starting with a space
setopt EXTENDED_GLOB          # Use extended globbing
setopt NO_BG_NICE             # Don't run background jobs at lower priority
unsetopt BEEP                 # No beep

# General Options
setopt complete_in_word       # Allow completion from within a word
setopt AUTO_LIST              # Automatically list choices on ambiguous completion
setopt AUTO_MENU              # Show completion menu on successive tab press
# }}}

# {{{ 3. Keybindings & Widgets
# ------------------------------------------------------------------------------
zmodload zsh/terminfo

# Standard keys mapping
typeset -g -A key
key=(
    Up         "${terminfo[kcuu1]}"
    Down       "${terminfo[kcud1]}"
    Left       "${terminfo[kcub1]}"
    Right      "${terminfo[kcuf1]}"
    Home       "${terminfo[khome]}"
    End        "${terminfo[kend]}"
    Insert     "${terminfo[kich1]}"
    Delete     "${terminfo[kdch1]}"
    PageUp     "${terminfo[kpp]}"
    PageDown   "${terminfo[knp]}"
    BackTab    "${terminfo[kcbt]}"
)

# Search history based on what's already typed
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

[[ -n "${key[Up]}"   ]] && bindkey "${key[Up]}"   up-line-or-beginning-search
[[ -n "${key[Down]}" ]] && bindkey "${key[Down]}" down-line-or-beginning-search

# Standard functional keys
[[ -n "${key[Delete]}" ]] && bindkey "${key[Delete]}" delete-char
[[ -n "${key[Home]}"   ]] && bindkey "${key[Home]}"   beginning-of-line
[[ -n "${key[End]}"    ]] && bindkey "${key[End]}"    end-of-line

# Tab behavior for empty lines
user-complete() {
    case $BUFFER {
        "" )
            BUFFER="cd "
            zle end-of-line
            zle expand-or-complete
            ;;
        " " )
            BUFFER="!?"
            zle end-of-line
            zle expand-or-complete
            ;;
        * )
            zle expand-or-complete
            ;;
    }
}
zle -N user-complete
bindkey "\t" user-complete
# }}}

# {{{ 4. Completion System
# ------------------------------------------------------------------------------
WORDCHARS='*?_-[]~=&;!#$%^(){}<>'
fpath=($HOME/.zfunc $fpath)

# Speed up compinit by using a cache file
autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.m-1) ]]; then
    compinit -C
else
    compinit
fi

_force_rehash() {
    ((CURRENT == 1)) && rehash
    return 1
}

# zstyle: general
zstyle ':completion:::::' completer _force_rehash _complete _approximate
zstyle ':completion:*' verbose yes
zstyle ':completion:*' menu select
zstyle ':completion:*:*:default' force-list always
zstyle ':completion:*' select-prompt '%SSelect:  lines: %L  matches: %M  [%p]'
zstyle ':completion:*:match:*' original only
zstyle ':completion::prefix-1:*' completer _complete
zstyle ':completion:predict:*' completer _complete
zstyle ':completion:incremental:*' completer _complete _correct
zstyle ':completion:*' completer _complete _prefix _correct _prefix _match _approximate

# zstyle: path & colors
zstyle ':completion:*' expand 'yes'
zstyle ':completion:*' squeeze-slashes 'yes'
zstyle ':completion::complete:*' '\\'
export ZLSCOLORS=$LS_COLORS
zmodload zsh/complist
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'

# zstyle: error correction & groups
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:approximate:*' max-errors 1 numeric
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:descriptions' format $'\e[01;33m -- %d --\e[0m'
zstyle ':completion:*:messages' format $'\e[01;35m -- %d --\e[0m'
zstyle ':completion:*:warnings' format $'\e[01;31m -- No Matches Found --\e[0m'
zstyle ':completion:*:corrections' format $'\e[01;32m -- %d (errors: %e) --\e[0m'

# zstyle: process completion
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:*:*:*:processes' force-list always
zstyle ':completion:*:processes' command 'ps -au$USER'

# zstyle: misc
zstyle ':completion:*:-tilde-:*' group-order 'named-directories' 'path-directories' 'users' 'expand'
zstyle ':completion:*:ping:*' hosts g.cn www.baidu.com www.google.com
zstyle ':completion:*:my-accounts' users-hosts goreliu@192.168.1.{2,3,6,7,9}
# }}}

# {{{ 5. Prompt & Visuals
# ------------------------------------------------------------------------------
precmd() {
    PROMPT="%{%F{cyan}%} %n@%{%F{green}%}%M:%{%F{red}%}%(?..[%?]:)%{%F{white}%}%~"$'\n'"%% "
}

preexec() {
    print -Pn "\e]0;%~$ ${1/[\\\%]*/@@@}\a"
}

autoload -U zmv
# }}}

# {{{ 6. Aliases & Custom Functions
# ------------------------------------------------------------------------------
alias ls="ls --group-directories-first --color=auto"
alias ll="ls -l"
alias la="ls -lAFh"
alias l='ls -CF'
alias suv="sudo vim"
alias kernel="uname -r | sed 's/[1-9]\+[0-9]*\.[0-9]\+\.[0-9]\+-//' | sed 's/[1-9]\+[0-9]*\.[0-9]*\-rc[0-9]\+-//'"
alias showip='ip -4 addr show scope global | grep inet | awk "{print $2}" | cut -d"/" -f1 | sed "s/    inet //g" | paste -s -d, -'
alias vim=nvim
# }}}

# {{{ 7. Local Overrides
# ------------------------------------------------------------------------------
# Load machine-specific configuration
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
# }}}
