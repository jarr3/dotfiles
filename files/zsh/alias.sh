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
  gp origin --delete "${branch_name}" --no-verify
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

create_log_file() {
  if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    current_branch=$(git rev-parse --abbrev-ref HEAD)
    today=$(date +"%Y-%m-%d")
    safe_branch=$(echo "$current_branch" | sed 's|/|_|g')
    log_dir="$HOME/sessions/log/$safe_branch"
    mkdir -p "$log_dir"
    filename="$log_dir/${today}.txt"

    echo "Redirecting output to log file: $filename"
    exec > >(tee -a "$filename") 2>&1
  else
    echo "Current directory is not a Git repository. Exiting."
  fi
}

alias sr_lint_ruff='gulp lint:ruff:fix'
alias sr_lint_es='gulp lint:es:fix'
alias sr_lint='(
    gulp lint:es:fix
    gulp lint:ruff:fix
)'
alias sr_serve='(
    echo "[ ] Starting sevenrooms app locally..."
    cd ~/sevenrooms-web
    current_branch=$(git branch --show-current)
    create_log_file
    echo "[√] Starting sevenrooms app on branch $current_branch"

    echo "[ ] Loading up venv and node ..."
    source .venv/bin/activate
    n auto
    echo "[√] Loading up venv and node"

    echo "[ ] Installing dependencies..."
    gcloud auth application-default login
    uv pip sync requirements.txt requirements_test.txt
    yarn install
    gulp secrets:pull
    echo "[√] Installing dependencies"

    echo "[ ] Building webpack..."
    gulp build
    gulp serve
    echo "[√] Building webpack"
)'
alias sr_cypress_open='(
    echo "[ ] Starting sevenrooms cypress locally..."
    cd ~/sevenrooms-web/automation/
    current_branch=$(git branch --show-current)
    echo "[√] Starting sevenrooms app on branch $current_branch"

    echo "[ ] Loading up node ..."
    n auto
    echo "[√] Loading up node"

    echo "[ ] Starting up cypress..."
    yarn cypress-open
    echo "[√] Starting up cypress"
)'

sr_web_kill() {
        pkill -5 -f appengine
        WEBPACK_PROCS="${"$(ps aux | grep '[w]ebpack' | awk '{print $2}')"//$'\n'/ }"
        if [[ ! -z $WEBPACK_PROCS ]]
        then
                echo "Killing Webpack Proccesses $WEBPACK_PROCS"
                /bin/bash -c "kill -9 $WEBPACK_PROCS"
        else
                echo "No webpack proccesses running"
        fi
        SSO_CONTAINERS="${"$(docker container ls --filter ancestor=sso_app -q -a)"//$'\n'/ }"
        if [[ ! -z $SSO_CONTAINERS ]] 
        then
                echo "Killing containers $SSO_CONTAINERS"
                /bin/bash -c "docker container rm -f $SSO_CONTAINERS"
        else
                echo "No Running SSO Containers"
        fi
        GUNICORN_PROCS="${"$(ps aux | grep '[g]unicorn -b' | awk '{print $2}')"//$'\n'/ }"
        if [[ ! -z $GUNICORN_PROCS ]]
        then
                echo "Killing Gunicorn Processes $GUNICORN_PROCS"
                /bin/bash -c "kill -9 $GUNICORN_PROCS"
        else
                echo "No Gunicorn Processes"
        fi
}
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
