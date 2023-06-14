#!/bin/bash

# Exit on any error
set -e

# Project root
proj="$(realpath "$(dirname "$0")")"

# Navigate to the project root
cd "$proj"

# Clean
# =============================================================================
# Delete all cloned submodules (if any)
git submodule deinit -f .

# Delete gitignored files/folders
git clean -f -X

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
# Create python venv and activate it
python3 -m venv venv
source venv/bin/activate

# Install requirements.txt
pip install -r requirements.txt

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

# Exit
# =============================================================================
echo -e "\033[0;32mSetup finished\033[0m"
exit 0