#!/bin/sh
# Simple installer script for clutch
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
                clutch_uri="https://owenbick.com/releases/Linux_x86_64.tar.gz"
                ;;
            arm64)
                clutch_uri="https://owenbick.com/releases/Linux_arm64.tar.gz"
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

    clutch_install="${CLUTCH_INSTALL:-$HOME/.clutch}"

    bin_dir="$clutch_install/bin"
    tmp_dir="$clutch_install/tmp"
    exe="$bin_dir/clutch"

    mkdir -p "$bin_dir"
    mkdir -p "$tmp_dir"

    echo "Downloading clutch from $clutch_uri..."
    curl -q --fail --location --progress-bar --output "$tmp_dir/clutch.tar.gz" "$clutch_uri"

    # Extract to tmp dir so we don't open the existing executable file for writing:
    tar -C "$tmp_dir" -xzf "$tmp_dir/clutch.tar.gz"
    chmod +x "$tmp_dir/clutch"

    # Atomically rename into place:
    mv "$tmp_dir/clutch" "$exe"
    rm "$tmp_dir/clutch.tar.gz"

    echo "clutch was installed successfully to $exe"
    if command -v clutch >/dev/null; then
        echo "Run 'clutch --help' to get started"
    else
        case $SHELL in
        /bin/zsh) shell_profile=".zshrc" ;;
        *) shell_profile=".bash_profile" ;;
        esac
        echo "Manually add the directory to your \$HOME/$shell_profile (or similar):"
        echo "  export CLUTCH_INSTALL=\"$clutch_install\""
        echo "  export PATH=\"\$CLUTCH_INSTALL/bin:\$PATH\""
        echo "Run '$exe --help' to get started"
    fi
}

main "$1"
