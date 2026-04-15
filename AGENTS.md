# AGENTS.md

Guidelines for AI agents working on this repository.

## Design philosophy

This repo targets **non-development environments**: servers, routers (e.g. OpenWrt), temporary machines. The primary constraint is **minimal dependencies**.

Dependency ladder — the installer adapts to what's available:

```
bash + curl only  →  pull mode, curl fallback (GitHub API for file discovery)
+ git             →  pull mode, shallow clone
+ ln              →  link mode
+ stow            →  stow mode  (preferred when available)
```

When evaluating changes to `install.sh`: prefer solutions that work at a lower rung of this ladder. Do not introduce new runtime dependencies without strong justification.

## Structure

```
dotfiles_simple/
├── install.sh          # Single installer script
├── zsh/.zshrc
├── vim/.vimrc
├── vim/.vim/           # Git submodules (plugins)
├── tmux/.tmux.conf
└── kitty-terminfo/.terminfo/x/xterm-kitty
```

**Every top-level directory is a component.** There are no exceptions and this convention will not change. Do not hardcode component names anywhere — `install.sh` auto-discovers them via filesystem scan or GitHub API.

## install.sh design

### Modes

| Mode | Trigger | Behavior |
|------|---------|----------|
| `stow` | `--stow` or auto-detected | `stow --target=$HOME -R $comp` |
| `link` | `--link` or stow not found | `ln -sfv` for each file under component dir |
| `pull` | `--pull` or curl-pipe auto-detect | See below |

Modes are mutually exclusive. A single `MODE` variable controls the flow.

### Pull mode detail

```
pull
 ├── git available  → shallow clone to ~/.dotfiles_simple
 │                    submodule update --init --recursive
 │                    switch MODE to stow or link
 │                    install normally
 └── no git         → USE_CURL_FALLBACK=true
                       discover components via GitHub API (git trees, non-recursive)
                       list files per component via GitHub API (git trees, recursive=1)
                       curl each file to $HOME, preserving relative path
```

GitHub API is used **only** in the curl fallback path. Submodule content (`type:commit` in git tree) is naturally excluded by the `type:blob` filter — this is intentional, not a gap.

### Argument parsing

Two-pass design to avoid `--all` breaking early before flags are processed:

1. **First pass**: mode flags (`--stow`, `--link`, `--pull`) and unknown-option validation
2. **Second pass**: component list (`--all` or named components)

Auto-detection of curl-pipe execution: `[ ! -f "$0" ]` — when piped via `curl | bash`, `$0` is `bash` rather than a file path.

### Submodule update

Only triggered when running from a local repo (not after a pull-mode clone, which already ran it).

Condition: `MODE != pull && USE_CURL_FALLBACK == false && DOTFILES_ROOT != CLONE_DEST`

## Adding a new component

1. Create `<name>/` directory at repo root
2. Place files inside following stow convention: `<name>/path/to/file` maps to `$HOME/path/to/file`
3. No changes to `install.sh` needed

## What not to do

- Do not add component names to any list or `case` statement in `install.sh`
- Do not add file mappings — the stow convention handles all path resolution
- Do not add a GitHub Actions workflow just to maintain a file manifest — the GitHub API already provides this dynamically
