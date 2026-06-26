# ~/.zshrc

# Histórico
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt INTERACTIVE_COMMENTS

# Autocomplete básico
autoload -Uz compinit
compinit

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Modo de edição estilo bash/emacs
bindkey -e

# Aliases básicos
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'

# Aliases modernos
if command -v eza >/dev/null 2>&1; then
  alias ls='eza'
  alias ll='eza -lah --git'
  alias tree='eza --tree'
fi

if command -v batcat >/dev/null 2>&1; then
  alias bat='batcat'
fi

if command -v fdfind >/dev/null 2>&1; then
  alias fd='fdfind'
fi

# Git
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate --all'

# Navegação
alias ..='cd ..'
alias ...='cd ../..'

# Editor padrão
export EDITOR=nano

# zoxide
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# direnv
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

# Starship
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
