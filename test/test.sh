#!/usr/bin/env bash
# ==============================================================================
# test.sh — Run nano configuration validation across multiple nano versions
# ==============================================================================
# Usage:
#   ./test/test.sh                  # Test all templates and keymaps
#   ./test/test.sh development      # Test only the development template
#   ./test/test.sh gui-keymap       # Test only the gui keymap
#   ./test/test.sh development 7.2  # Test development template on nano 7.2 only
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATES_DIR="$PROJECT_DIR/templates"
KEYMAPS_DIR="$PROJECT_DIR/keymaps"
TEST_DIR="$SCRIPT_DIR"

# Nano versions and their corresponding Docker base images
# Format: "version:base_image"
VERSION_MAP="5.9:alpine:3.15
6.2:ubuntu:22.04
7.2:alpine:3.18
8.0:alpine:3.20"

ALL_TEMPLATES="minimal development writing beginner advanced"
ALL_KEYMAPS="default gui emacs"
ALL_VERSIONS="5.9 6.2 7.2 8.0"

TOTAL_PASS=0
TOTAL_FAIL=0

# Parse arguments
FILTER_TARGET="${1:-}"
FILTER_VERSION="${2:-}"

# --------------------------------------------------------------------------
# Lookup base image for a nano version
# --------------------------------------------------------------------------
get_base_image() {
    local version="$1"
    echo "$VERSION_MAP" | while IFS=: read -r ver img; do
        if [ "$ver" = "$version" ]; then
            echo "$img"
            return
        fi
    done
}

# --------------------------------------------------------------------------
# Build test image
# --------------------------------------------------------------------------
build_image() {
    local version="$1"
    local base_image
    base_image=$(get_base_image "$version")
    local image_tag="nanorc-test:nano-${version}"

    if [ -z "$base_image" ]; then
        printf "\033[31mUnknown nano version: %s\033[0m\n" "$version"
        printf "Available versions: %s\n" "$ALL_VERSIONS"
        exit 1
    fi

    printf "\033[1mBuilding test image for nano %s (%s)...\033[0m\n" "$version" "$base_image"
    if ! docker build -q \
        --build-arg "BASE_IMAGE=$base_image" \
        -t "$image_tag" \
        -f "$TEST_DIR/Dockerfile" \
        "$TEST_DIR" > /dev/null 2>&1; then
        printf "\033[31mFailed to build image for nano %s\033[0m\n" "$version"
        return 1
    fi
}

# --------------------------------------------------------------------------
# Run validation for a config file against a nano version
# --------------------------------------------------------------------------
run_test() {
    local config_file="$1"
    local version="$2"
    local image_tag="nanorc-test:nano-${version}"

    if [ ! -f "$config_file" ]; then
        printf "\033[31mConfig not found: %s\033[0m\n" "$config_file"
        TOTAL_FAIL=$((TOTAL_FAIL + 1))
        return 1
    fi

    if docker run --rm \
        -v "$config_file:/tmp/test.nanorc:ro" \
        "$image_tag" \
        /tmp/test.nanorc; then
        TOTAL_PASS=$((TOTAL_PASS + 1))
    else
        TOTAL_FAIL=$((TOTAL_FAIL + 1))
    fi
}

# --------------------------------------------------------------------------
# Run validation for a keymap by combining it with the minimal template
# --------------------------------------------------------------------------
run_keymap_test() {
    local keymap="$1"
    local version="$2"
    local image_tag="nanorc-test:nano-${version}"
    local keymap_file="$KEYMAPS_DIR/${keymap}.keymaprc"
    local base_file="$TEMPLATES_DIR/minimal.nanorc"

    if [ ! -f "$keymap_file" ]; then
        printf "\033[31mKeymap not found: %s\033[0m\n" "$keymap_file"
        TOTAL_FAIL=$((TOTAL_FAIL + 1))
        return 1
    fi

    # Create a temporary combined config: minimal template + keymap
    local combined
    combined=$(mktemp)
    cat "$base_file" > "$combined"
    printf "\n# --- Keymap: %s ---\n" "$keymap" >> "$combined"
    cat "$keymap_file" >> "$combined"

    if docker run --rm \
        -v "$combined:/tmp/test.nanorc:ro" \
        "$image_tag" \
        /tmp/test.nanorc; then
        TOTAL_PASS=$((TOTAL_PASS + 1))
    else
        TOTAL_FAIL=$((TOTAL_FAIL + 1))
    fi

    rm -f "$combined"
}

# --------------------------------------------------------------------------
# Main
# --------------------------------------------------------------------------
printf "\n\033[1m============================================\033[0m\n"
printf "\033[1m  Nano Configuration Test Suite\033[0m\n"
printf "\033[1m============================================\033[0m\n\n"

# Determine which versions to test
if [ -n "$FILTER_VERSION" ]; then
    VERSIONS="$FILTER_VERSION"
else
    VERSIONS="$ALL_VERSIONS"
fi

# Determine what to test based on filter
TEMPLATES=""
KEYMAPS=""

if [ -n "$FILTER_TARGET" ]; then
    # Check if it's a keymap (ends with -keymap) or a template
    case "$FILTER_TARGET" in
        *-keymap)
            KEYMAPS="${FILTER_TARGET%-keymap}"
            ;;
        *)
            # Check if it matches a template name
            if echo "$ALL_TEMPLATES" | grep -qw "$FILTER_TARGET"; then
                TEMPLATES="$FILTER_TARGET"
            # Check if it matches a keymap name
            elif echo "$ALL_KEYMAPS" | grep -qw "$FILTER_TARGET"; then
                KEYMAPS="$FILTER_TARGET"
            else
                printf "\033[31mUnknown target: %s\033[0m\n" "$FILTER_TARGET"
                printf "Templates: %s\n" "$ALL_TEMPLATES"
                printf "Keymaps:   %s (or use <name>-keymap)\n" "$ALL_KEYMAPS"
                exit 1
            fi
            ;;
    esac
else
    TEMPLATES="$ALL_TEMPLATES"
    KEYMAPS="$ALL_KEYMAPS"
fi

# Build all required images
for version in $VERSIONS; do
    build_image "$version"
done

printf "\n"

# Run template tests
if [ -n "$TEMPLATES" ]; then
    for version in $VERSIONS; do
        for template in $TEMPLATES; do
            run_test "$TEMPLATES_DIR/${template}.nanorc" "$version"
        done
    done
fi

# Run keymap tests
if [ -n "$KEYMAPS" ]; then
    for version in $VERSIONS; do
        for keymap in $KEYMAPS; do
            run_keymap_test "$keymap" "$version"
        done
    done
fi

# --------------------------------------------------------------------------
# Final Summary
# --------------------------------------------------------------------------
TOTAL=$((TOTAL_PASS + TOTAL_FAIL))
printf "\033[1m============================================\033[0m\n"
printf "\033[1m  Final Summary\033[0m\n"
printf "\033[1m============================================\033[0m\n"
[ -n "$TEMPLATES" ] && printf "  Templates: %s\n" "$TEMPLATES"
[ -n "$KEYMAPS" ]   && printf "  Keymaps:   %s\n" "$KEYMAPS"
printf "  Nano versions: %s\n" "$VERSIONS"
printf "  Total runs:    %d\n" "$TOTAL"

if [ "$TOTAL_FAIL" -eq 0 ]; then
    printf "  Result:        \033[32mALL %d PASSED\033[0m\n" "$TOTAL"
else
    printf "  Result:        \033[31m%d FAILED\033[0m, %d passed\n" "$TOTAL_FAIL" "$TOTAL_PASS"
fi

printf "\033[1m============================================\033[0m\n\n"

[ "$TOTAL_FAIL" -eq 0 ]
