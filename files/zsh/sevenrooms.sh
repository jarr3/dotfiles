# SevenRooms configuration
export PATH="/usr/local/sbin:$PATH"
export LIBRARY_PATH=$LIBRARY_PATH:/usr/local/opt/openssl/lib/

# Node
export N_PREFIX=${XDG_DATA_HOME:-~/.local/share}/n
export PATH=$N_PREFIX/bin:$PATH

# uv
export PATH="~/.local/bin:$PATH"

# Gulp
alias gulp='yarn gulp'

# Java
export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)

# MySQL
export PATH="/usr/local/opt/mysql-client@5.7/bin:$PATH"
export LDFLAGS="-L/usr/local/opt/mysql-client@5.7/lib"
export CPPFLAGS="-I/usr/local/opt/mysql-client@5.7/include"
export PKG_CONFIG_PATH="/usr/local/opt/mysql-client@5.7/lib/pkgconfig"

# Python
# pyenv
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
# virtualenv
export PATH="/usr/local/share/python:$PATH"
export PYENV_VERSION="$(pyenv version-name)"
export PIP_REQUIRE_VIRTUALENV=true
# source ~/.pyenv/versions/$PYENV_VERSION/bin/virtualenvwrapper.sh

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/jngandjui/google-cloud-sdk/path.zsh.inc' ]; then
  . '/Users/jngandjui/google-cloud-sdk/path.zsh.inc'
fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/jngandjui/google-cloud-sdk/completion.zsh.inc' ]; then
  . '/Users/jngandjui/google-cloud-sdk/completion.zsh.inc'
fi

