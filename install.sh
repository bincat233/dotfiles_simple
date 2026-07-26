#!/bin/bash

REPO_OWNER="bincat233"
REPO_NAME="dotfiles_simple"
REPO_BRANCH="main"
PULL_BASE="https://raw.githubusercontent.com/$REPO_OWNER/$REPO_NAME/$REPO_BRANCH"

DOTFILES_ROOT="$(cd "$(dirname "$0")" && pwd)"

API_BASE="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME"

RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Discover component directories from local filesystem
discover_local_components() {
    for d in "$DOTFILES_ROOT"/*/; do
        [ -d "$d" ] && basename "$d"
    done
}

# Discover top-level component directories from GitHub API (curl fallback only)
discover_remote_components() {
    curl -fsSL "$API_BASE/git/trees/$REPO_BRANCH" \
        | tr '{}' '\n' \
        | grep '"type"[[:space:]]*:[[:space:]]*"tree"' \
        | sed 's/.*"path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/'
}

# List all files under a component from GitHub API (curl fallback only)
get_remote_files() {
    local comp=$1
    local response
    response=$(curl -fsSL "$API_BASE/git/trees/$REPO_BRANCH?recursive=1") || return 1
    echo "$response" \
        | tr '{}' '\n' \
        | grep '"type"[[:space:]]*:[[:space:]]*"blob"' \
        | grep '"path"[[:space:]]*:[[:space:]]*"'"$comp"'/' \
        | sed 's/.*"path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/'
}

show_help() {
    echo "Usage: $(basename "$0") [OPTIONS] [COMPONENTS...]"
    echo ""
    echo "Options:"
    echo "  --stow       Use GNU Stow to symlink (error if stow not found)"
    echo "  --link       Use ln -sf to symlink"
    echo "  --pull       Download files via curl; if git is available, also clone submodules"
    echo "  --all        Install all components (auto-discovered)"
    echo "  --help       Show this help message"
    echo ""
    echo "  If no mode flag is given, auto-detects: curl pipe → pull, stow available → stow, else → link"
    echo ""
    echo "Examples:"
    echo "  $0 zsh vim"
    echo "  $0 --all"
    echo "  $0 --pull --all"
    echo "  $0 --link zsh tmux"
    echo "  curl -fsSL .../install.sh | bash -s -- --all"
}

# Parse .gitmodules from remote and clone submodules under a component
clone_submodules() {
    local comp=$1
    local gitmodules
    gitmodules=$(curl -fsSL "$PULL_BASE/.gitmodules") || return

    local path="" url=""
    while IFS= read -r line; do
        line="${line#"${line%%[! ]*}"}"  # trim leading whitespace
        if [[ "$line" == path* ]]; then
            path="${line#*= }"
        elif [[ "$line" == url* ]]; then
            url="${line#*= }"
        fi
        if [ -n "$path" ] && [ -n "$url" ]; then
            if [[ "$path" == "$comp/"* ]]; then
                local target="$HOME/${path#"$comp"/}"
                echo "  submodule $path -> $target"
                git clone --depth=1 "$url" "$target" \
                    || { echo -e "  ${RED}ERROR: failed to clone submodule $url${NC}" >&2; return 1; }
            fi
            path="" url=""
        fi
    done <<< "$gitmodules"
}

pull_with_curl() {
    local comp=$1
    local files
    if ! files=$(get_remote_files "$comp"); then
        echo -e "  ${RED}ERROR: failed to fetch file list (network or API error)${NC}" >&2
        return 1
    fi
    if [ -z "$files" ]; then
        echo -e "  ${RED}ERROR: component '$comp' not found in repository${NC}" >&2
        return 1
    fi

    while IFS= read -r file; do
        local target="$HOME/${file#"$comp"/}"
        mkdir -p "$(dirname "$target")"
        echo "  $file -> $target"
        curl -fsSL "$PULL_BASE/$file" -o "$target" \
            || { echo -e "  ${RED}ERROR: failed to download $file${NC}" >&2; return 1; }
    done <<< "$files"

    if command -v git >/dev/null 2>&1; then
        clone_submodules "$comp"
    fi
}

install_component() {
    local comp=$1
    echo "==> Installing $comp..."

    if [ "$MODE" = "stow" ]; then
        stow --target="$HOME" --dir="$DOTFILES_ROOT" -R "$comp" \
            || { echo -e "  ${RED}ERROR: stow failed for $comp${NC}" >&2; return 1; }
    else
        while IFS= read -r file; do
            local rel="${file#"$DOTFILES_ROOT/$comp"/}"
            local target="$HOME/$rel"
            mkdir -p "$(dirname "$target")"
            ln -sfv "$file" "$target" \
                || { echo -e "  ${RED}ERROR: failed to link $file${NC}" >&2; return 1; }
        done < <(find "$DOTFILES_ROOT/$comp" -type f)
    fi
}

# No arguments
if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

# First pass: parse mode flags and validate options
MODE=""
for arg in "$@"; do
    case $arg in
        --help) show_help; exit 0 ;;
        --stow|--link|--pull)
            if [ -n "$MODE" ]; then
                echo "Error: --stow, --link, --pull are mutually exclusive"
                exit 1
            fi
            MODE="${arg#--}"
            ;;
        --all) ;;
        -*)
            echo "Unknown option: $arg"
            show_help
            exit 1
            ;;
        *) ;;
    esac
done

# Auto-detect mode if not specified
if [ -z "$MODE" ]; then
    if [ ! -f "$0" ]; then
        MODE="pull"
        echo "Auto-detected: curl pipe execution, using pull mode"
    elif command -v stow >/dev/null 2>&1; then
        MODE="stow"
    else
        echo -e "${RED}Note: GNU Stow not found, falling back to ln -sf.${NC}" >&2
        MODE="link"
    fi
fi

# Validate stow availability
if [ "$MODE" = "stow" ] && ! command -v stow >/dev/null 2>&1; then
    echo "Error: --stow specified but GNU Stow is not installed"
    exit 1
fi

USE_CURL_FALLBACK=false
if [ "$MODE" = "pull" ]; then
    USE_CURL_FALLBACK=true
fi

# Discover available components
AVAILABLE=$(discover_local_components)

# Second pass: build component list
COMPONENTS=()
for arg in "$@"; do
    case $arg in
        --all)
            if [ "$USE_CURL_FALLBACK" = true ]; then
                while IFS= read -r comp; do
                    COMPONENTS+=("$comp")
                done <<< "$(discover_remote_components)"
            else
                while IFS= read -r comp; do
                    COMPONENTS+=("$comp")
                done <<< "$AVAILABLE"
            fi
            break
            ;;
        --stow|--link|--pull) ;;
        -*) ;;
        *)
            if [ "$USE_CURL_FALLBACK" = true ]; then
                COMPONENTS+=("$arg")
            elif echo "$AVAILABLE" | grep -qx "$arg"; then
                COMPONENTS+=("$arg")
            else
                echo "Unknown component: $arg"
                echo "Available: $(echo "$AVAILABLE" | tr '\n' ' ')"
                exit 1
            fi
            ;;
    esac
done

if [ ${#COMPONENTS[@]} -eq 0 ]; then
    echo "No components specified."
    show_help
    exit 1
fi

# Update submodules for local stow/link modes
if [ "$MODE" != "pull" ]; then
    echo "Updating git submodules..."
    git -C "$DOTFILES_ROOT" submodule update --init --recursive
fi

# Run
FAILED=0
for comp in "${COMPONENTS[@]}"; do
    if [ "$USE_CURL_FALLBACK" = true ]; then
        echo "==> Pulling $comp (curl)..."
        pull_with_curl "$comp" || FAILED=1
    else
        install_component "$comp" || FAILED=1
    fi
done

if [ "$FAILED" -ne 0 ]; then
    echo -e "${RED}ERROR: one or more components failed to install${NC}" >&2
    exit 1
fi
echo "Done!"
