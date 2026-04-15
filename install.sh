#~/bin/bash
cd "$(dirname "$0")"

#!/bin/bash
command -v stow && command -v git || exit 1
git submodule update --init --recursive
stow --target=$HOME vim
