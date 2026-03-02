#!/bin/bash

REPO_URL="https://github.com/carl0xs/anyvim.git"
TARGET_DIR="$HOME/.config/anyvim"
FISH_CONF="$HOME/.config/fish/config.fish"

# Clone repo if not present
if [ ! -d "$TARGET_DIR" ]; then
    echo "Cloning into $TARGET_DIR..."
    git clone "$REPO_URL" "$TARGET_DIR"
else
    echo "Directory $TARGET_DIR already exists."
fi

# Append nv function to fish config
cat << 'EOF' >> "$FISH_CONF"

# Select and apply a Neovim configuration
function nv
    set -l base_dir "$HOME/.config/anyvim"
    set -l nvim_dir "$HOME/.config/nvim"
    set -l nvim_backup "$HOME/.config/nvim.backup"

    set -l choice (ls -d $base_dir/*/ | xargs -n 1 basename | fzf --prompt="Choose configuration: " --height=20% --reverse)

    if test -z "$choice"
        echo "No configuration selected."
        return 1
    end

    set -l choice_dir "$base_dir/$choice"
    echo "Selected: $choice"

    if test -d "$nvim_dir"
        echo "Creating backup at $nvim_backup"
        rm -rf "$nvim_backup"
        mkdir -p "$nvim_backup"
        rsync -a --delete "$nvim_dir"/ "$nvim_backup"/
    end

    echo "Applying new configuration..."
    rm -rf "$nvim_dir"
    mkdir -p "$nvim_dir"
    rsync -a "$choice_dir"/ "$nvim_dir"/

    echo "Now using: $choice"
end
# -----------------------------------------
EOF

echo "Installation complete. Restart your shell."

