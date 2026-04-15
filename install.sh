#!/bin/bash

# Base directory
DOTFILES_ROOT="$(cd "$(dirname "$0")" && pwd)"

show_help() {
    echo "Usage: $(basename "$0") [OPTIONS] [COMPONENTS...]"
    echo ""
    echo "Options:"
    echo "  --all        Install all components (zsh, vim, tmux)"
    echo "  --help       Show this help message"
    echo ""
    echo "Components:"
    echo "  zsh          Install .zshrc"
    echo "  vim          Install .vimrc and .vim directory"
    echo "  tmux         Install .tmux.conf"
    echo ""
    echo "Example:"
    echo "  $0 zsh vim"
    echo "  $0 --all"
}

install_zsh() {
    echo "==> Installing zsh configuration..."
    ln -sfv "$DOTFILES_ROOT/zsh/.zshrc" "$HOME/.zshrc"
}

install_vim() {
    echo "==> Installing vim configuration..."
    ln -sfv "$DOTFILES_ROOT/vim/.vimrc" "$HOME/.vimrc"
    ln -sfv "$DOTFILES_ROOT/vim/.vim" "$HOME/.vim"
}

install_tmux() {
    echo "==> Installing tmux configuration..."
    ln -sfv "$DOTFILES_ROOT/tmux/.tmux.conf" "$HOME/.tmux.conf"
}

# No arguments
if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

# Update submodules
echo "Updating git submodules..."
git -C "$DOTFILES_ROOT" submodule update --init --recursive

# Parse arguments
COMPONENTS=()
for arg in "$@"; do
    case $arg in
        --help)
            show_help
            exit 0
            ;;
        --all)
            COMPONENTS=("zsh" "vim" "tmux")
            break
            ;;
        zsh|vim|tmux)
            COMPONENTS+=("$arg")
            ;;
        *)
            echo "Unknown option/component: $arg"
            show_help
            exit 1
            ;;
    esac
done

# Run installation
for comp in "${COMPONENTS[@]}"; do
    case $comp in
        zsh)  install_zsh ;;
        vim)  install_vim ;;
        tmux) install_tmux ;;
    esac
done

echo "Done!"
