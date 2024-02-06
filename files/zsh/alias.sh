#!/bin/bash
alias vim="nvim"

# Python
# -----------------------------
# Updates the python and pip aliases when using virtualenv 
alias python='eval $(which python3)'
alias pip='eval $(which pip3)'
alias activate='source ./venv/bin/activate'

# Git Commands
# -----------------------------
# git add -u : updates existing files that are tracked and does not add new ones
alias gat="ga -u"

# Delete a local branch
function gbdl() {
  branch_name="$(git symbolic-ref HEAD 2>/dev/null)" ||
  branch_name="(unnamed branch)"     # detached HEAD
  branch_name=${branch_name##refs/heads/}
    
  gcm
  gb -D "${branch_name}"
}

# Delete a remote branch
function gbdr() {
  branch_name="$(git symbolic-ref HEAD 2>/dev/null)" ||
  branch_name="(unnamed branch)"     # detached HEAD
  branch_name=${branch_name##refs/heads/}

  gcm
  gp origin --delete "${branch_name}"
}

# Delete a local and remote branch
function gbdrl() {
  branch_name="$(git symbolic-ref HEAD 2>/dev/null)" ||
  branch_name="(unnamed branch)"     # detached HEAD
  branch_name=${branch_name##refs/heads/}

  gcm
  gp origin --delete "${branch_name}"
  gb -D "${branch_name}"
}

# Sevenrooms
# -----------------------------
# Search and find in logs
# saf $filename $startline $text
alias saf="search_and_filter"
function search_and_filter() {
    FILENAME=$1
    START_LINE=$2
    SEARCH_TEXT=$3
    sed -n "${START_LINE},\$p" ${FILENAME} | grep ${SEARCH_TEXT}
}
alias sr-tunnel='(
    cd ~/sevenrooms
    workon env3
    gcloud auth login
    gcloud compute ssh --ssh-key-file=~/.ssh/sevenrooms_gcp vault-1 -- -N -L 8200:127.0.0.1:8200
)'
alias sr-serve='(
    cd ~/sevenrooms
    workon env3
    pip install -r requirements.txt -r requirements_test.txt
    yarn install
    gulp secrets:pull
    gulp build
    gulp serve
)'
alias sr-docker='(
    cd ~/sevenrooms
    workon env3
    gulp docker:dev
)'
alias sr-main-serve='(
    cd ~/sevenroom
    gco main
    git pull
    workon env3
    pip install -r requirements.txt -r requirements_test.txt
    yarn install
    gulp secrets:pull
    gulp build
    gulp serve
)'
alias sr-main-docker='(
    cd ~/sevenrooms
    gco main
    workon env3
    gulp docker:dev
)'
