#!/bin/bash
alias vim="nvim"

# Bash
log_terminal_session() {
    local session_date
    session_date=$(date +"%Y-%m-%d_%H-%M-%S")
    script ~/sessions/zsh_$session_date.log
}

# Git 
# -----------------------------
# git add -u : updates existing files that are tracked and does not add new ones
alias gat="ga -u"

# Delete a local branch
alias gbdl='(
  branch_name="$(git symbolic-ref HEAD 2>/dev/null)" ||
  branch_name="(unnamed branch)"     # detached HEAD
  branch_name=${branch_name##refs/heads/}
    
  gcm
  gb -D "${branch_name}"
)'

# Delete a remote branch
alias gbdr='(
  branch_name="$(git symbolic-ref HEAD 2>/dev/null)" ||
  branch_name="(unnamed branch)"     # detached HEAD
  branch_name=${branch_name##refs/heads/}

  gcm
  gp origin --delete "${branch_name}"
)'

# Delete a local and remote branch
alias gbdrl='(
  branch_name="$(git symbolic-ref HEAD 2>/dev/null)" ||
  branch_name="(unnamed branch)"     # detached HEAD
  branch_name=${branch_name##refs/heads/}

  gcm
  gp origin --delete "${branch_name}"
  gb -D "${branch_name}"
)'

# Sevenrooms
# -----------------------------
search_log() {
    filename=$1
    text=$2
    start_line=$3
    end_line=$4  # Optional end line

    if [ -z "$end_line" ]; then
        echo "Searching $filename for $text starting at line number $start_line to EOF"
        nl -ba "$filename" | sed -n "${start_line},\$p" | grep "$text"
    else
        echo "Searching $filename for $text starting at line number $start_line to $end_line"
        nl -ba "$filename" | sed -n "${start_line},${end_line}p" | grep "$text"
    fi
}
alias sr_run='(
    echo "Starting sevenrooms app locally..."
    cd ~/sevenrooms
    current_branch=$(git branch --show-current)
    echo "Starting sevenrooms app on branch $current_branch"

    workon env3

    # echo "Deleting Root Node Modules"
    # rm -r node_modules
    # echo "Deleting Frontend/Packages/ Node Modules"
    # find frontend -name node_modules | xargs rm -rf
    # echo "Finished Cleaning Node Modules"
    
    gcloud auth application-default login
    pip-sync requirements.txt requirements_test.txt
    yarn install
    gulp secrets:pull
    gulp build
    gulp serve
)'
sr_start_tunnel() {
        TUNNEL_PID=$(lsof -ti :8200)
        if [ -z "$TUNNEL_PID" ]
        then
                echo "Tunnel is starting..."
                gcloud auth login
                gcloud compute ssh --ssh-key-file=~/.ssh/sevenrooms_gcp vault-1 -- -N -L 8200:127.0.0.1:8200
        else
                echo "Tunnel is already running with PID: $TUNNEL_PID"
        fi
}

sr_stop_tunnel() {
        TUNNEL_PID=$(lsof -ti :8200)
        if [ -z "$TUNNEL_PID" ]
        then
                echo "Tunnel is not running"
        else
                kill $TUNNEL_PID
        fi
}
