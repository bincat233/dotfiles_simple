#!/bin/bash

# Base directory
DOTFILES_ROOT="$(cd "$(dirname "$0")" && pwd)"
USE_STOW=false

# Colors
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if stow is available
if command -v stow >/dev/null 2>&1; then
    USE_STOW=true
fi

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

    if [ "$USE_STOW" = false ]; then
        echo -e "\n${RED}Note: GNU Stow not found, falling back to manual ln -sf.${NC}" >&2
    fi
}

install_component() {
    local comp=$1
    echo "==> Installing $comp configuration..."

    if [ "$USE_STOW" = true ]; then
        # Use stow: target is $HOME, directory is $DOTFILES_ROOT
        stow --target="$HOME" --dir="$DOTFILES_ROOT" -R "$comp"
    else
        # Manual fallback
        case $comp in
            zsh)
                ln -sfv "$DOTFILES_ROOT/zsh/.zshrc" "$HOME/.zshrc"
                ;;
            vim)
                ln -sfv "$DOTFILES_ROOT/vim/.vimrc" "$HOME/.vimrc"
                ln -sfv "$DOTFILES_ROOT/vim/.vim" "$HOME/.vim"
                ;;
            tmux)
                ln -sfv "$DOTFILES_ROOT/tmux/.tmux.conf" "$HOME/.tmux.conf"
                ;;
        esac
    fi
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
    install_component "$comp"
done

echo "Done!"
