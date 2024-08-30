#!/bin/sh
# Simple installer script for noble
# Supports Linux x86_64 and arm64 architectures

set -e

main() {
    os=$(uname -s)
    arch=$(uname -m)
    version=${1:-latest}

    # Determine the correct binary based on architecture
    case $arch in
        x86_64)
            noble_uri="https://github.com/bick/noble-cli/releases/download/test/noble-x86_64.tar.gz"
            binary_name="noble-x86_64"
            ;;
        arm64)
            noble_uri="https://github.com/bick/noble-cli/releases/download/test/noble-arm64.tar.gz"
            binary_name="noble-arm64"
            ;;
        *)
            echo "Error: Unsupported architecture $arch" 1>&2
            exit 1
            ;;
    esac

    noble_install="${NOBLE_INSTALL:-$HOME/.noble}"

    bin_dir="$noble_install/bin"
    tmp_dir="$noble_install/tmp"
    exe="$bin_dir/noble"

    mkdir -p "$bin_dir"
    mkdir -p "$tmp_dir"

    echo "Downloading noble from $noble_uri..."
    curl -q --fail --location --progress-bar --output "$tmp_dir/noble.tar.gz" "$noble_uri"

    # Extract to tmp dir so we don't open the existing executable file for writing
    tar -C "$tmp_dir" -xzf "$tmp_dir/noble.tar.gz"

    # Check if the expected binary is there
    if [ ! -f "$tmp_dir/$binary_name" ]; then
        echo "Error: $binary_name not found in the extracted tarball." 1>&2
        exit 1
    fi

    # Set executable permissions and move the binary to the bin directory
    chmod +x "$tmp_dir/$binary_name"
    mv "$tmp_dir/$binary_name" "$exe"
    rm -rf "$tmp_dir"

    echo "noble was installed successfully to $exe"

    # Determine the shell profile file
    case $SHELL in
    /bin/zsh) shell_profile="$HOME/.zshrc" ;;
    *) shell_profile="$HOME/.bashrc" ;;
    esac

    # Add to PATH if not already present
    if ! grep -q 'NOBLE_INSTALL' "$shell_profile"; then
        echo "Adding Noble to your PATH in $shell_profile..."
        echo "export NOBLE_INSTALL=\"$noble_install\"" >> "$shell_profile"
        echo "export PATH=\"\$NOBLE_INSTALL/bin:\$PATH\"" >> "$shell_profile"
        echo "Noble has been added to your PATH. Please restart your terminal or run 'source $shell_profile' to apply the changes."
    else
        echo "Noble is already in your PATH."
    fi
}

main "$1"
