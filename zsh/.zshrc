#{{{ 命令提示符、标题栏、任务栏样式、颜色
precmd() {
    # %{%F{cyan}%}
    # %n -- username
    # %{%F{green}%}
    # %M -- hostname
    # :
    # %{%F{red}%}
    # %(?..[%?]:) -- error code
    # %{%F{white}%}
    # %~ -- dir
    # $'\n' -- new line
    # %% -- %
    PROMPT="%{%F{cyan}%}%n@%{%F{green}%}%M:%{%F{red}%}%(?..[%?]:)%{%F{white}%}%~"$'\n'"%% "
}

preexec() {
    # \e]0;内容\a
    print -Pn "\e]0;%~$ ${1/[\\\%]*/@@@}\a"
}
# 加载算数模块
#zmodload zsh/mathfunc

#{{{ 关于历史纪录的配置
# 只显示以当前命令开头的历史记录

autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey -- "^[OA" up-line-or-beginning-search
bindkey -- "^[OB" down-line-or-beginning-search
bindkey -- "^[[A" up-line-or-beginning-search
bindkey -- "^[[B" down-line-or-beginning-search
# 历史纪录条目数量
export HISTSIZE=500
# 注销后保存的历史纪录条目数量
export SAVEHIST=500
# 历史纪录文件
export HISTFILE=~/.zsh_history
# 修改 esc 超时时间为 0.01s
export KEYTIMEOUT=1
# 如果连续输入的命令相同，历史纪录中只保留一个
setopt HIST_IGNORE_DUPS
# 为历史纪录中的命令添加时间戳
#setopt EXTENDED_HISTORY
# 启用 cd 命令的历史纪录，cd -[TAB]进入历史路径
setopt AUTO_PUSHD
# 相同的历史路径只保留一个
setopt PUSHD_IGNORE_DUPS
# 在命令前添加空格，不将此命令添加到纪录文件中
setopt HIST_IGNORE_SPACE
# 加强版通配符
setopt EXTENDED_GLOB
# 在后台运行命令时不调整优先级
setopt NO_BG_NICE
# 禁用终端响铃
unsetopt BEEP
#}}}

#{{{ 自动补全
# 扩展路径
# /v/c/p/p => /var/cache/pacman/pkg
setopt complete_in_word

#以下字符视为单词的一部分
WORDCHARS='*?_-[]~=&;!#$%^(){}<>'

setopt AUTO_LIST
setopt AUTO_MENU
# 开启此选项，补全时会直接选中菜单项
# setopt MENU_COMPLETE
#
fpath+=(~/.bin/comp)
autoload -U compinit
compinit

_force_rehash() {
    ((CURRENT == 1)) && rehash
    return 1    # Because we didn't really complete anything
}
zstyle ':completion:::::' completer _force_rehash _complete _approximate

# 自动补全选项
#bindkey -e #emacs
#bindkey -v #vi
zstyle ':completion:*' verbose yes
zstyle ':completion:*' menu select
zstyle ':completion:*:*:default' force-list always
zstyle ':completion:*' select-prompt '%SSelect:  lines: %L  matches: %M  [%p]'
zstyle ':completion:*:match:*' original only
zstyle ':completion::prefix-1:*' completer _complete
zstyle ':completion:predict:*' completer _complete
zstyle ':completion:incremental:*' completer _complete _correct
zstyle ':completion:*' completer _complete _prefix _correct _prefix _match _approximate

# 路径补全
zstyle ':completion:*' expand 'yes'
zstyle ':completion:*' squeeze-slashes 'yes'
zstyle ':completion::complete:*' '\\'

# 彩色补全菜单
export ZLSCOLORS=$LS_COLORS
zmodload zsh/complist
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# 修正大小写
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'

# 错误校正
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# 补全类型提示分组
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:descriptions' format $'\e[01;33m -- %d --\e[0m'
zstyle ':completion:*:messages' format $'\e[01;35m -- %d --\e[0m'
zstyle ':completion:*:warnings' format $'\e[01;31m -- No Matches Found --\e[0m'
zstyle ':completion:*:corrections' format $'\e[01;32m -- %d (errors: %e) --\e[0m'

# kill 补全
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:*:*:*:processes' force-list always
zstyle ':completion:*:processes' command 'ps -au$USER'

# cd ~ 补全顺序
zstyle ':completion:*:-tilde-:*' group-order 'named-directories' 'path-directories' 'users' 'expand'

# 空行(光标在行首)补全 "cd "
user-complete() {
    case $BUFFER {
        "" )
            # 空行填入 "cd "
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
##}}}

#{{{ 杂项
# 进入相应的路径时只要 cd ~xxx
# hash -d mine='/mnt/c/mine'

# 加载函数
autoload -U zmv

# 按照对应命令补全
zstyle ':completion:*:ping:*' hosts g.cn www.baidu.com www.google.com
zstyle ':completion:*:my-accounts' users-hosts goreliu@192.168.1.{2,3,6,7,9}
#}}}

#{{{ 和 zsh 无关的配置

path+=(~/.bin)
# 开启后 exec zsh 后 ctrl + a 异常
export EDITOR=vim
export PAGER='less -irf'
export GREP_COLOR='40;33;01'

# man 颜色
export LESS_TERMCAP_mb=$'\E[01;31m'
# 标题和命令主体
export LESS_TERMCAP_md=$'\E[01;32m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
# 命令参数
export LESS_TERMCAP_us=$'\E[04;36;4m'

export PATH=$PATH:$HOME/bin
#}}}
#

#自定义函数
#alias
alias ls="ls --group-directories-first --color=auto"
alias ll="ls -l"
alias la="ls -lAFh"
alias l='ls -CF'
alias suv="sudo vim"
alias kernel="uname -r | sed 's/[1-9]\+[0-9]*\.[0-9]\+\.[0-9]\+-//' | sed 's/[1-9]\+[0-9]*\.[0-9]*\-rc[0-9]\+-//'"
alias showip='ip -4 addr show scope global | grep inet | awk "{print $2}" | cut -d"/" -f1 | sed "s/    inet //g" | paste -s -d, -'
