#!/bin/sh
# Simple installer script for noble
# Supports Linux x86_64 and arm64 architectures

set -e

main() {
    os=$(uname -s)
    arch=$(uname -m)
    version=${1:-latest}

    # Determine the correct binary based on architecture
    if [ "$os" = "Linux" ]; then
        case $arch in
            x86_64)
                noble_uri="https://github.com/bick/noble-cli/archive/refs/tags/test.zip"
                ;;
            arm64)
                noble_uri="https://github.com/bick/noble-cli/archive/refs/tags/test.zip"
                ;;
            *)
                echo "Error: Unsupported architecture $arch" 1>&2
                exit 1
                ;;
        esac
    else
        echo "Error: Unsupported OS $os" 1>&2
        exit 1
    fi

    noble_install="${NOBLE_INSTALL:-$HOME/.noble}"

    bin_dir="$noble_install/bin"
    tmp_dir="$noble_install/tmp"
    exe="$bin_dir/noble"

    mkdir -p "$bin_dir"
    mkdir -p "$tmp_dir"

    echo "Downloading noble from $noble_uri..."
    curl -q --fail --location --progress-bar --output "$tmp_dir/noble.tar.gz" "$noble_uri"

    # Extract to tmp dir so we don't open the existing executable file for writing:
    tar -C "$tmp_dir" -xzf "$tmp_dir/noble.tar.gz"
    chmod +x "$tmp_dir/noble"

    # Atomically rename into place:
    mv "$tmp_dir/noble" "$exe"
    rm "$tmp_dir/noble.tar.gz"

    echo "noble was installed successfully to $exe"
    if command -v noble >/dev/null; then
        echo "Run 'noble --help' to get started"
    else
        case $SHELL in
        /bin/zsh) shell_profile=".zshrc" ;;
        *) shell_profile=".bash_profile" ;;
        esac
        echo "Manually add the directory to your \$HOME/$shell_profile (or similar):"
        echo "  export NOBLE_INSTALL=\"$noble_install\""
        echo "  export PATH=\"\$NOBLE_INSTALL/bin:\$PATH\""
        echo "Run '$exe --help' to get started"
    fi
}

main "$1"
