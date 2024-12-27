#!/bin/bash

dotfiles_dir=~/dotfiles
dotfiles_config_dir=$dotfiles_dir/files
cd $dotfiles_dir || { echo "dotfiles directory not found"; exit 1; }

dependency() {
    local package=$1
    local install_type=${2:-} # Default to empty if not provided

    # Lowercase conversion for cross-shell compatibility
    install_type=$(echo "$install_type" | awk '{print tolower($0)}')

    if brew list --formula "$package" &> /dev/null; then
        echo "'$package' formula is already installed."
    elif brew list --cask "$package" &> /dev/null; then
        echo "'$package' cask is already installed."
    else
        if [ "$install_type" = "f" ]; then
            echo "Installing '$package' as a formula."
            brew install "$package"
        elif [ "$install_type" = "c" ]; then
            echo "Installing '$package' as a cask."
            brew install --cask "$package"
        else
            echo "Package '$package' is not installed. Install as a formula (F) or as a cask (C)? [F/C/n] "
            read -r choice
            # Lowercase conversion for cross-shell compatibility
            choice=$(echo "$choice" | awk '{print tolower($0)}')
            
            case "$choice" in
                f)
                    brew install "$package"
                    ;;
                c)
                    brew install --cask "$package"
                    ;;
                n)
                    echo "Installation canceled."
                    ;;
                *)
                    echo "Invalid option. Installation canceled."
                    ;;
            esac
        fi
    fi
}

function setup_homebrew ()
{
    cd "$dotfiles_dir"
    echo "Installing Homebrew..."
    # Check if Homebrew is installed
    if command -v brew &> /dev/null; then
        echo "Homebrew is already installed."
    else
        echo "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
        echo "Homebrew installation complete."
    fi

    echo "Installing up RipGrep…"
    # Handle skipping .gitignore files on search
    dependency ripgrep f

    echo "Installing up n…"
    # Node version manager .nvmrc files
    dependency n f

    echo "Installing up fd…"
    # Fast program to search filesystem 
    dependency fd f


    echo "Installing up pipx…"
    # Python module manager 
    dependency pipx 

    echo "Installing up Jetbrains font…"
    brew tap homebrew/cask-fonts
    dependency font-jetbrains-mono-nerd-font c

    echo "Installing up Alacritty…"
    dependency alacritty c
    mkdir -p ~/.config/alacritty
    ln -sf $dotfiles_config_dir/alacritty/alacritty.toml ~/.config/alacritty/alacritty.toml

    echo "Installing up Aerospace…"
    dependency nikitabobko/tap/aerospace c
    mkdir -p ~/.config/aerospace
    ln -sf $dotfiles_config_dir/aerospace/aerospace.toml ~/.config/aerospace/aerospace.toml
}


function setup_tmux ()
{
    cd "$dotfiles_dir"
    echo "Installing up Tmux…"
    dependency tmux f
    TPM_DIR="$HOME/.tmux/plugins/tpm"
    if [ ! -d "$TPM_DIR" ]; then
        git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
        echo "Tmux Plugin Manager (TPM) directory cloned successfully."
    else
        echo "TPM directory already exists. Skipping clone operation."
    fi
    target_tmux_dir=~/.config/tmux
    rm -rf $target_tmux_dir
    mkdir -p $target_tmux_dir
    ln -sf $dotfiles_config_dir/tmux/tmux.conf $target_tmux_dir/tmux.conf
}

function setup_nvim ()
{
    cd "$dotfiles_dir"
    echo "Installing NeoVim…"
    dependency neovim f
    source_nvim_dir=$dotfiles_config_dir/nvim
    target_nvim_dir=~/.config/nvim
    rm -rf $target_nvim_dir
    mkdir -p $target_nvim_dir/.backup
    mkdir -p $target_nvim_dir/lua/config
    mkdir -p $target_nvim_dir/lua/plugins
    ln -sf ~/dotfiles/files/nvim/init.lua $target_nvim_dir/init.lua
    ln -sf ~/dotfiles/files/nvim/lazy-lock.json $target_nvim_dir/lazy-lock.json
    cd $source_nvim_dir
    find . -type f | while read -r file; do
      file="${file#./}"
      mkdir -p "$target_nvim_dir/$(dirname "$file")"
      ln -sf "$source_nvim_dir/$file" "$target_nvim_dir/$file"
    done
    cd $dotfiles_dir


    echo "Installing NeoVim LSP dependency…"
    dependency n 
    n auto 
    npm install -g typescript typescript-language-server # ts_ls

    dependency pipx 
    pipx install python-lsp-server
    cd ~/.local/share/pipx/venvs/python-lsp-server
    source base/activate
    python3 -m pip install pylsp-mypy
    python3 -m pip install python-lsp-ruff --no-deps
}

function setup_shell ()
{
    cd "$dotfiles_dir"
    echo "Installing Zsh…"
    dependency zsh f
    OH_MY_ZSH=$HOME/.oh-my-zsh
    OH_MY_ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
    if [ -d $OH_MY_ZSH ]; then
      echo "Oh My Zsh is already installed."
    else
        echo "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

        # Change default shell to Zsh
        chsh -s $(which zsh)
        echo "Oh My Zsh installed successfully."
    fi
    DRACULA_THEME_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/dracula"
    if [ ! -d "$DRACULA_THEME_DIR" ]; then
        echo "Dracula theme not found. Installing..."
        git clone https://github.com/dracula/zsh.git "$DRACULA_THEME_DIR"
        # Create a symlink for the theme to be recognized by Oh My Zsh
        ln -s "${DRACULA_THEME_DIR}/dracula.zsh-theme" "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/dracula.zsh-theme"
        echo "Dracula theme installed and set successfully."
    else
        echo "Dracula theme is already installed."
    fi
    ZSH_AUTOSUGGESTIONS_DIR="$OH_MY_ZSH_CUSTOM/plugins/zsh-autosuggestions"
    if [ ! -d "$OH_MY_ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
        echo "Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_AUTOSUGGESTIONS_DIR"
    else
        echo "zsh-autosuggestions is already installed."
    fi

    echo "Loading zsh profile and scripts..."
    mkdir -p ~/.config/zsh
    ln -sf $dotfiles_config_dir/zsh/* ~/.config/zsh
    ln -sf $dotfiles_config_dir/zshrc ~/.zshrc
    ln -sf $dotfiles_config_dir/zprofile ~/.zprofile
    echo "Loaded zsh profile and scripts."
}

case "$1" in
    homebrew) setup_homebrew;;
    tmux) setup_tmux;;
    nvim) setup_nvim;;
    shell) setup_shell;;
    all)
        setup_homebrew
        setup_shell
        setup_nvim
        setup_tmux
        ;;
    *)
      echo -e "\nUsage: $(basename "$0") {homebrew|tmux|nvim|shell|all}\n"
      return 0
      ;;
esac
echo -e "success Done."
