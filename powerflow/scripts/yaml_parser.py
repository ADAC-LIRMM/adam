# Copyright 2025 LIRMM
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import yaml
from pathlib import Path
import argparse

def get_all_required_files(yaml_file, fset):
    with open(yaml_file, 'r') as file:
        yaml_data = yaml.safe_load(file)

    base_dir = Path(yaml_file).parent.resolve()
    home_dir = Path.home()
    relative_dir = base_dir.relative_to(home_dir)
    full_dir = home_dir / relative_dir
    required_files, include_dirs = get_required_files_recursive(yaml_data, fset, full_dir)
    return required_files, include_dirs

def get_required_files_recursive(yaml_data, fset, base_dir):
    required_files = set()
    include_dirs = set()

    root_path = yaml_data['fsets'][fset].get('root', '')
    dir_path = yaml_data['fsets'][fset].get('dir', '')

    if 'sources' in yaml_data['fsets'][fset]:
        for source in yaml_data['fsets'][fset]['sources']:
            full_path = base_dir / root_path / dir_path / source
            required_files.add(str(full_path))

    if 'includes' in yaml_data['fsets'][fset]:
        for include_dir in yaml_data['fsets'][fset]['includes']:
            include_path = base_dir / root_path / include_dir
            include_dirs.add(str(include_path))

    if 'requires' in yaml_data['fsets'][fset]:
        for require in yaml_data['fsets'][fset]['requires']:
            required_files_from_require, include_dirs_from_require = get_required_files_recursive(yaml_data, require, base_dir)
            required_files.update(required_files_from_require)
            include_dirs.update(include_dirs_from_require)

    return list(required_files), list(include_dirs)

def main():
    parser = argparse.ArgumentParser(description='Process some integers.')
    parser.add_argument('fsets', type=str, help='File set for which to get the required files')

    args = parser.parse_args()

    # Path to the YAML file
    yaml_file = '../../adam.yml'

    # File set for which to get the required files
    fset = args.fsets

    # Get all required files for the file set
    required_files, include_dirs = get_all_required_files(yaml_file, fset)

    # Print the paths of the required files
    print(' '.join(required_files))
    print(' '.join(include_dirs))


if __name__ == "__main__":
    main()