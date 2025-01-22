#~/bin/bash
cd "$(dirname "$0")"

git submodule update --init --recursive
stow --target=$HOME vim
