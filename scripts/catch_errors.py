import re
import sys

def extract_info(error_messages):
    error_message_separator = r"\n{2,}"
    model_name_pattern = r"model (\S+)"
    model_path_pattern = r"\(([^)]+)\)"
    error_message_pattern = r"TrinoUserError\([^)]+\)"

    error_messages = re.split(error_message_separator, error_messages)

    for error_message in error_messages:
        model_name_match = re.search(model_name_pattern, error_message)
        model_path_match = re.search(model_path_pattern, error_message)
        error_message_match = re.search(error_message_pattern, error_message)

        if model_name_match and model_path_match and error_message_match:
            model_name = model_name_match.group(1)
            model_path = model_path_match.group(1)
            error_message = error_message_match.group(0)

            yield model_name, model_path, error_message

if __name__ == "__main__":
    input_error_messages = sys.stdin.read()
    extracted_info = extract_info(input_error_messages)

    for model_name, model_path, error_message in extracted_info:
        print(f"Model name: {model_name}")
        print(f"Model path: {model_path}")
        print(f"Error message: {error_message}")
        print()
