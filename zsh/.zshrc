# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# =============================================================================
#                          Pre-Plugin Configuration
# =============================================================================

# Automagically quote URLs. This obviates the need to quote them manually when
# pasting or typing URLs.
autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic

# zsh-syntax-highlighting
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)
ZSH_HIGHLIGHT_PATTERNS+=('rm -rf *' 'fg=white,bold,bg=red')
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[path]='fg=blue'
ZSH_HIGHLIGHT_STYLES[path_pathseparator]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[alias]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[function]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[redirection]='fg=magenta'
ZSH_HIGHLIGHT_STYLES[bracket-level-1]='fg=cyan,bold'
ZSH_HIGHLIGHT_STYLES[bracket-level-2]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[bracket-level-3]='fg=magenta,bold'
ZSH_HIGHLIGHT_STYLES[bracket-level-4]='fg=yellow,bold'

if [[ ! -d "${ZPLUG_HOME}" ]]; then
  if [[ ! -d ~/.zplug ]]; then
    git clone https://github.com/zplug/zplug ~/.zplug
    # If we can't get zplug, it'll be a very sobering shell experience. To at
    # least complete the sourcing of this file, we'll define an always-false
    # returning zplug function.
    if [[ $? != 0 ]]; then
      function zplug() {
        return 1
      }
    fi
  fi
  export ZPLUG_HOME=~/.zplug
fi
if [[ -d "${ZPLUG_HOME}" ]]; then
  source "${ZPLUG_HOME}/init.zsh"
fi

zplug 'plugins/bundler', from:oh-my-zsh, if:'which bundle'
zplug 'plugins/colored-man-pages', from:oh-my-zsh
zplug 'plugins/completion', from:oh-my-zsh
zplug 'plugins/extract', from:oh-my-zsh
zplug 'plugins/fancy-ctrl-z', from:oh-my-zsh
zplug 'plugins/git', from:oh-my-zsh, if:'which git'
#zplug 'plugins/gpg-agent', from:oh-my-zsh, if:'which gpg-agent'
#zplug 'plugins/httpie', from:oh-my-zsh, if:'which httpie'
zplug 'plugins/gpg-agent', from:oh-my-zsh, if:'which gpg-agent'
zplug 'plugins/nanoc', from:oh-my-zsh, if:'which nanoc'
zplug 'plugins/nmap', from:oh-my-zsh, if:'which nmap'
# zplug 'plugins/tmux', from:oh-my-zsh, if:'which tmux'

#zplug 'b4b4r07/enhancd', use:init.sh
zplug 'b4b4r07/zsh-vimode-visual', defer:3
zplug 'jeffreytse/zsh-vi-mode'
zplug "junegunn/fzf-bin", as:command, from:gh-r, rename-to:"fzf", frozen:1
zplug "junegunn/fzf", use:"shell/key-bindings.zsh"
zplug 'knu/zsh-manydots-magic', use:manydots-magic, defer:3
#zplug 'romkatv/powerlevel10k', use:powerlevel10k.zsh-theme
zplug 'romkatv/powerlevel10k', as:theme, depth:1
zplug 'seebi/dircolors-solarized', ignore:"*", as:plugin
zplug 'Tarrasch/zsh-bd'
zplug 'zsh-users/zsh-autosuggestions'
zplug 'zsh-users/zsh-completions', defer:2
zplug 'zsh-users/zsh-history-substring-search'
zplug 'zsh-users/zsh-syntax-highlighting', defer:2

if ! zplug check; then
  zplug install
fi

zplug load

if zplug check 'seebi/dircolors-solarized'; then
  if which gdircolors > /dev/null 2>&1; then
    alias dircolors='gdircolors'
  fi
  if which dircolors > /dev/null 2>&1; then
    scheme='dircolors.256dark'
    eval $(dircolors $ZPLUG_HOME/repos/seebi/dircolors-solarized/$scheme)
  fi
fi

if zplug check 'zsh-users/zsh-autosuggestions'; then
  # Enable asynchronous fetching of suggestions.
  ZSH_AUTOSUGGEST_USE_ASYNC=1
  # For some reason, the offered completion winds up having the same color as
  # the terminal background color (when using a dark profile). Therefore, we
  # switch to gray.
  # See https://github.com/zsh-users/zsh-autosuggestions/issues/182.
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=gray'
fi

# Our custom version of oh-my-zsh's globalias plugin. Unlike the OMZ version,
# we do not use the `expand-word' widget and only expand a few whitelisted
# aliases.
# See https://github.com/robbyrussell/oh-my-zsh/issues/6123 for discussion.
globalias() {
  # FIXME: the whitelist pattern should technically only be computed once, but
  # since it's cheap, we keep it local for now.
  local -a whitelist candidates
  whitelist=(ls git tmux)
  local pattern="^(${(j:|:)whitelist})"
  for k v in ${(kv)aliases}; do
    # We have a candidate unless the alias is an alias that begins with itself,
    # e.g., ls='ls --some-option'.
    if [[ $v =~ $pattern && ! $v =~ ^$k ]]; then
      candidates+=($k)
    fi
  done
  if [[ $LBUFFER =~ "(^|[;|&])\s*(${(j:|:)candidates})\s*($|[;|&])" ]]; then
    zle _expand_alias
  fi
  zle self-insert
}
zle -N globalias
bindkey -M emacs ' ' globalias
bindkey -M viins ' ' globalias
bindkey -M isearch ' ' magic-space # normal space during searches


# =============================================================================
#                                   Options
# =============================================================================

# Watching other users
WATCHFMT='%n %a %l from %m at %t.'
watch=(notme)         # Report login/logout events for everybody except ourself.
LOGCHECK=60           # Time (seconds) between checks for login/logout activity.
REPORTTIME=5          # Display usage statistics for commands running > 5 sec.
WORDCHARS="\'*?_-.[]~=/&;!#$%^(){}<>\'"

# History
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt autocd                   # Allow changing directories without `cd`
setopt append_history           # Do not overwrite history
setopt extended_history         # Also record time and duration of commands.
setopt share_history            # Share history between multiple shells
setopt hist_expire_dups_first   # Clear duplicates when trimming internal hist.
setopt hist_find_no_dups        # Do not display duplicates during searches.
setopt hist_ignore_dups         # Ignore consecutive duplicates.
setopt hist_ignore_all_dups     # Remember only one unique copy of the command.
setopt hist_reduce_blanks       # Remove superfluous blanks.
setopt hist_save_no_dups        # Omit older commands in favor of newer ones.

# Changing directories
setopt pushd_ignore_dups        # Do not push copies of the same dir on stack.
setopt pushd_minus              # Reference stack entries with '-'.

setopt extended_glob

# =============================================================================
#                                   Aliases
# =============================================================================

# Swift editing and file display.
alias e="$EDITOR"
alias v="$VISUAL"

# Directory coloring
if which gls > /dev/null 2>&1; then
  # Prefer GNU version, since it respects dircolors.
  alias ls='gls --group-directories-first --color=auto'
elif [[ $OSTYPE = (darwin|freebsd)* ]]; then
  export CLICOLOR="YES" # Equivalent to passing -G to ls.
  export LSCOLORS="exgxdHdHcxaHaHhBhDeaec"
else
  alias ls='ls --group-directories-first --color=auto'
fi

# Directory management
alias la='ls -a'
alias ll='ls -l'
alias lal='ls -al'
alias dirs='dirs -v'
push() { pushd $1 > /dev/null 2>&1; dirs -v; }
pop() { popd > /dev/null 2>&1; dirs -v }

# Generic command adaptations.
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# OS-specific aliases
if [[ $OSTYPE = darwin* ]]; then
  # Lock screen (e.g., when leaving computer).
  alias afk="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"
  # Hide/show all desktop icons (useful when presenting)
  alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false \
    && killall Finder"
  alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true \
    && killall Finder"
  # Combine PDFs on the command line.
  pdfcat() {
    if [[ $# -lt 2 ]]; then
      echo "usage: $0 merged.pdf input0.pdf [input1.pdf ...]" > /dev/stderr
      return 1
    fi
    local output="$1"
    shift
    # Try pdfunite first (from Homebrew package poppler), because it's much
    # faster and doesn't perform stupid page rotations.
    if which pdfunite > /dev/null 2>&1; then
      pdfunite "$@" "$output"
    else
      local join='/System/Library/Automator/Combine PDF Pages.action/Contents/Resources/join.py'
      "$join" -o "$output" "$@" && open "$output"
    fi
  }
fi

# =============================================================================
#                                Key Bindings
# =============================================================================

bindkey -v

# Common CTRL bindings.
bindkey '^a' beginning-of-line
bindkey '^e' end-of-line
bindkey '^f' forward-word
bindkey '^b' backward-word
bindkey '^k' kill-line
bindkey '^d' delete-char
bindkey '^y' accept-and-hold
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word
bindkey '^u' backward-kill-line

# More convenient acceptance of suggested command line.
if zplug check 'zsh-users/zsh-autosuggestions'; then
  bindkey '^ ' autosuggest-execute
fi

# History
if zplug check 'zsh-users/zsh-history-substring-search'; then
  zmodload zsh/terminfo
  bindkey "$terminfo[kcuu1]" history-substring-search-up
  bindkey "$terminfo[kcud1]" history-substring-search-down
  bindkey '^p' history-substring-search-up
  bindkey '^n' history-substring-search-down
  bindkey -M vicmd 'k' history-substring-search-up
  bindkey -M vicmd 'j' history-substring-search-down
fi

# Do not require a space when attempting to tab-complete.
bindkey '^i' expand-or-complete-prefix

# FZF
if zplug check 'junegunn/fzf'; then
  export FZF_DEFAULT_OPTS='--height 30%
      --color fg:223,bg:235,hl:208,fg+:229,bg+:237,hl+:167,border:237
      --color info:246,prompt:214,pointer:214,marker:142,spinner:246,header:214'
fi

# =============================================================================
#                                 Completions
# =============================================================================

# case-insensitive (all), partial-word and then substring completion
zstyle ':completion:*' matcher-list \
  'm:{a-zA-Z}={A-Za-z}' \
  'r:|[._-]=* r:|=*' \
  'l:|=* r:|=*'

zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# When doing `cd ../<TAB>`, don't offer the current directory as an option.
zstyle ':completion:*:cd:*' ignore-parents parent pwd

# Show a menu (with arrow keys) to select the process to kill.
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*'   force-list always

# =============================================================================
#                                    Other
# =============================================================================

# Utility that prints out lines that are common among $# files.
intersect() {
  local sort='sort -S 1G'
  case $# in
    (0) true;;
    (2) $sort -u "$1"; $sort -u "$2";;
    (*) $sort -u "$1"; shift; intersection "$@";;
  esac | $sort | uniq -d
}

# Changes an iTerm profile by sending a proprietary escape code that iTerm
# intercepts. This function additionally updates ITERM_PROFILE environment
# variable.
iterm-profile() {
  echo -ne "\033]50;SetProfile=$1\a"
  export ITERM_PROFILE="$1"
}

# Convenience function to update system applications and user packages.
update() {
  # sudoe once
  if ! sudo -n true 2> /dev/null; then
    sudo -v
    while true; do
      sudo -n true
      sleep 60
      kill -0 "$$" || exit
    done 2>/dev/null &
  fi
  # System
  sudo softwareupdate -i -a
  # Homebrew
  brew upgrade
  brew cleanup
  # Ruby
  gem update --system
  gem update
  gem cleanup
  # npm
  npm install npm -g
  npm update -g
  # Shell plugin management
  zplug update
  .tmux/plugins/tpm/bin/update_plugins all
  vim +PlugUpgrade +PlugUpdate +PlugCLean! +qa
}

# =============================================================================
#                                   Startup
# =============================================================================

# Source local customizations.
if [[ -f ~/.zshrc.local ]]; then
  source ~/.zshrc.local
fi

# Setup GPG for user accounts.
if [[ $UID != 0 ]]; then
  export GPG_TTY=$(tty);
  if which gpgconf > /dev/null 2>&1; then
    export GPG_AGENT_INFO=$(gpgconf --list-dirs agent-socket)
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
    gpg-connect-agent updatestartuptty /bye > /dev/null
  fi
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/omega.bavedila/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/omega.bavedila/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/omega.bavedila/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/omega.bavedila/Downloads/google-cloud-sdk/completion.zsh.inc'; fi
test -e /Users/omega.bavedila/.iterm2_shell_integration.zsh && source /Users/omega.bavedila/.iterm2_shell_integration.zsh || true

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/omega.bavedila/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)
