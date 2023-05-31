import json

TRINO_TABLES = []
SPARK_TABLES = []
def load_manifest(manifest_path):
    with open(manifest_path, "r") as f:
        manifest = json.load(f)
    for manifest