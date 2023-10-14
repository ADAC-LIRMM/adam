#!/bin/bash

use_venv=true

# Exit on any error
set -e

while [[ $# -gt 0 ]]; do
  case $1 in
    --no-venv)
      use_venv=false
      shift
      ;;
  esac
done

# Navigate to the project root
cd "$(dirname "$0")"/..
proj=$(pwd)

# Clean
# =============================================================================
# Delete all cloned submodules (if any)
git submodule deinit -f .

# Delete gitignored files/folders
git clean -Xdf

# Setup submodules
# =============================================================================
# Clone all submodules recursively
git submodule update --init --recursive

# Apply patches to submodules
for submodule in $(git submodule status | awk '{print $2}'); do
    patches="patches/$submodule"
    if [ -d "$patches" ]; then
        for patch in "$patches"/*; do
            patch=$(realpath $patch)
            (cd "$submodule" && git apply "$patch")
        done
    fi
done

# Setup Python
# =============================================================================
if $use_venv; then
  # Create python venv and activate it
  python3 -m venv venv
  source ./venv/bin/activate
else
  echo "Skipping virtual environment as --no-venv was specified"
fi

# Install requirements.txt
pip3 install -r requirements.txt

# Setup IBEX
# =============================================================================
# Goes to IBEX submodule
cd libs/ibex

# Install python-requirements.txt
pip3 install -U -r python-requirements.txt

# Run fusesoc
fusesoc --cores-root . run --target=lint --setup --build-root \
./build/ibex_out lowrisc:ibex:ibex_top

# Return to project root
cd $proj

# Build bootloader
# =============================================================================
# Goes into the bootloader directory
cd bootloader 

# Build bootloader
make all

# Return to project root
cd $proj

# Build docs
# =============================================================================
# Goes into the docs directory
cd docs

# Build docs
make html

# Return to project root
cd $proj

# Exit
# =============================================================================
# Print exit message
echo -e "\033[0;32mSetup finished\033[0m"

# Exits from script
exit 0