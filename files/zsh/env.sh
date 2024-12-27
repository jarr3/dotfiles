#!/bin/bash
# Executables
export PATH="/usr/local/bin/brew:$PATH"
export PATH="/usr/local/bin:$PATH"
export PATH="/usr/bin:$PATH"
export PATH="/usr/sbin:$PATH"
export PATH="/bin:$PATH"
export PATH="/sbin:$PATH"
export PATH="/usr/local/opt:$PATH"
export PATH="/System/Cryptexes/App/usr/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/Library/Application Support/JetBrains/Toolbox/scripts:$PATH"
export PATH="$HOME/Library/Python/3.9/bin:$PATH" # Add python path for nvim pylsp
export PATH="/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:$PATH"
export PATH="/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:$PATH"
export PATH="/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:$PATH"


# Quick access files and directories
export PROJECTS=$HOME/Projects
export SESSIONS=$HOME/sessions
export DOTFILES=$HOME/dotfiles
export CONFIG=$DOTFILES/files
export ZSHRC=$CONFIG/zshrc
export ZSHPROFILE=$CONFIG/zprofile
export ZSHALIAS=$CONFIG/zsh/alias.sh
export ZSHENV=$CONFIG/zsh/env.sh
export ZSH7R=$CONFIG/zsh/sevenrooms.sh
export ALACRITTYCONFIG=$CONFIG/alacritty/alacritty.toml
export NVIMINIT=$CONFIG/nvim/init.lua
export NVIMLOCK=$CONFIG/nvim/lazy-lock.json

# Node version manager directory
export N_PREFIX=$HOME/n

alias projects="cd $PROJECTS"
alias sessions="cd $SESSIONS"
alias dotfiles="cd $DOTFILES"
alias zshrc="nvim $ZSHRC"
alias zshalias="nvim $ZSHALIAS"
alias zshenv="nvim $ZSHENV"
alias zsh7r="nvim $ZSH7R"
alias alacrittyconfig="nvim $ALACRITTYCONFIG"
alias nviminit="nvim $NVIMINIT"
