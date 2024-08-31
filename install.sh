#!/bin/sh
# Simple installer script for Barrel
# Supports Linux x86_64 and arm64 architectures

set -e

main() {
    os=$(uname -s)
    arch=$(uname -m)
    version=${1:-latest}

    # Determine the correct binary based on architecture
    case $arch in
        x86_64)
            barrel_uri="https://github.com/bick/barrel-cli/releases/download/test/barrel-x86_64.tar.gz"
            binary_name="barrel-x86_64"
            ;;
        arm64)
            barrel_uri="https://github.com/bick/barrel-cli/releases/download/test/barrel-arm64.tar.gz"
            binary_name="barrel-arm64"
            ;;
        *)
            echo "Error: Unsupported architecture $arch" 1>&2
            exit 1
            ;;
    esac

    barrel_install="${BARREL_INSTALL:-$HOME/.barrel}"

    bin_dir="$barrel_install/bin"
    tmp_dir="$barrel_install/tmp"
    exe="$bin_dir/barrel"

    mkdir -p "$bin_dir"
    mkdir -p "$tmp_dir"

    echo "Downloading barrel from $barrel_uri..."
    curl -q --fail --location --progress-bar --output "$tmp_dir/barrel.tar.gz" "$barrel_uri"

    # Extract to tmp dir so we don't open the existing executable file for writing
    tar -C "$tmp_dir" -xzf "$tmp_dir/barrel.tar.gz"
    tar -C "$tmp_dir" -xzf "$tmp_dir/barrel.tar.gz"

    # Check if the expected binary is there
    if [ ! -f "$tmp_dir/$binary_name" ]; then
        echo "Error: $binary_name not found in the extracted tarball." 1>&2
        exit 1
    fi

    # Set executable permissions and move the binary to the bin directory
    chmod +x "$tmp_dir/$binary_name"
    mv "$tmp_dir/$binary_name" "$exe"
    rm -rf "$tmp_dir"

    echo "barrel was installed successfully to $exe"

    # Determine the shell profile file
    case $SHELL in
    /bin/zsh) shell_profile="$HOME/.zshrc" ;;
    *) shell_profile="$HOME/.bashrc" ;;
    esac

    # Add to PATH if not already present
    if ! grep -q 'BARREL_INSTALL' "$shell_profile"; then
        echo "Adding Barrel to your PATH in $shell_profile..."
        echo "export BARREL_INSTALL=\"$barrel_install\"" >> "$shell_profile"
        echo "export PATH=\"\$BARREL_INSTALL/bin:\$PATH\"" >> "$shell_profile"
        echo "Barrel has been added to your PATH. Please restart your terminal or run 'source $shell_profile' to apply the changes."
    else
        echo "Barrel is already in your PATH."
    fi
}

main "$1"
