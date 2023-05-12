import re

def remove_from_hex(input_str):
    """Remove from_hex() from a string"""

    # Define a regex pattern to match "from_hex(some_string)"
    pattern = r'from_hex\((.*?)\)'
    # Replace the matched pattern with "some_string"
    output_str = re.sub(pattern, r'\1', input_str)
    return output_str

# read every .sql file in the models directory and remove from_hex
# from every file
import os
import glob

# Get the current working directory
cwd = os.getcwd()

# Get the path to the models directory
models_dir = os.path.join(cwd, 'models')

# walk through the models directory and get all the .sql files
for root, dirs, files in os.walk(models_dir):
    for file in files:
        if file.endswith('.sql'):
            # Get the path to the file
            file_path = os.path.join(root, file)
            # Read the file
            with open(file_path, 'r') as f:
                file_contents = f.read()

            # Remove from_hex from the file
            changed_content = remove_from_hex(file_contents)
            if changed_content != file_contents:
                print(f"Changed {file_path}")
                # Write the file
                with open(file_path, 'w') as f:
                    f.write(changed_content)