# python script that adds `database: delta_prod` to source in each source file under "models/" directory

import os
import ruamel.yaml

def add_database_to_source(source_file):
    yaml = ruamel.yaml.YAML()
    yaml.indent(mapping=2, sequence=4, offset=2)
    yaml.preserve_quotes = True

    with open(source_file, 'r') as f:
        data = yaml.load(f)

    for item in data["sources"]:
        item.insert(1, 'database', 'delta_prod')

    with open(source_file, 'w') as f:
        yaml.dump(data, f)

def main():
    """
    Function that finds all files ending with "sources.yml" in the "models/" directory and its subdirectories. Models/ is in the current directory.
    """
    for root, dirs, files in os.walk('./models'):
        for file in files:
            if file.endswith('sources.yml'):
                add_database_to_source(os.path.join(root, file))

if __name__ == '__main__':
    main()