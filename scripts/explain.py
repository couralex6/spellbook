import json
import os
from fnmatch import fnmatch

import boto3 as boto3
from trino import dbapi
from trino.auth import BasicAuthentication
from trino.exceptions import TrinoUserError

compiled_models_dir = "/Users/couralex/src/spellbook/target/compiled/spellbook/models/"


def get_models(compiled_models_dir):
    """
    Function that returns a list of paths to all the compiled models in the compiled_models_dir.
    """
    pattern = "*.sql"
    model_paths = []
    # Walking the directory to find all spells
    for path, subdirs, files in os.walk(compiled_models_dir):
        for name in files:
            if fnmatch(name, pattern):
                model_paths.append(os.path.join(path, name))

    return model_paths

def get_models_from_manifest(manifest_path):
    """
    Function that reads manifest.json
    """
    models = []
    with open(manifest_path, 'r') as f:
        manifest = json.load(f)

    for node in manifest["nodes"]:
        if manifest["nodes"][node]["resource_type"] == "model":
            deps = manifest["nodes"][node]["depends_on"]["nodes"]
            # if deps contains no elements that start with "model.", then add node to models
            if not any(dep.startswith("model.") for dep in deps):
                print(manifest["nodes"][node]["compiled_path"])
                print(manifest["nodes"][node].keys())
                # print(deps)
                # print(node)
                models.append(manifest["nodes"][node]["compiled_path"])

    return models

def execute_query(query):
    """
    Function that executes a query passed as a string against the trino server. We would like to use aws secrets
    manager to authenticate.
    """
    username = os.environ.get('TRINO_USERNAME')
    password = os.environ.get('TRINO_PASSWORD')

    # Creating a connection to the trino server
    trino_host = os.environ.get('TRINO_URL')
    conn = dbapi.connect(
        host=trino_host,
        port=443,
        auth=BasicAuthentication(username, password),
        http_scheme="https",
        client_tags=["routingGroup=sandbox"],
    )
    # try executing the query and returning the response. return error if it fails.
    try:
        cursor = conn.cursor()
        cursor.execute(query)
        return cursor.fetchall()
    except TrinoUserError as e:
        return f"error: {e.message}"
    except Exception as e:
        return f"NON_TRINO_ERROR : {e}"


def get_sql(model_path):
    """
    Function that returns the SQL query from a model path.
    """
    with open(model_path, 'r') as f:
        sql = f.read()
    return sql.replace("`", "").replace(".from", '."from"')


def get_secret():
    """
    Function that fetches a secret from AWS Secrets Manager given a secret ARN.
    Note: may not be needed if we can use the user/pass to authenticate.
    """
    secret_arn = os.environ.get('TRINO_SECRET_ARN')
    session = boto3.session.Session()
    client = session.client(service_name='secretsmanager')
    get_secret_value_response = client.get_secret_value(SecretId=secret_arn)
    secret = get_secret_value_response['SecretString']
    return secret


def explain_query(query):
    """
    Function that explains a query and returns the response.
    """
    sql_query = get_sql(query)
    resp = execute_query("EXPLAIN (TYPE LOGICAL, FORMAT JSON) " + sql_query)
    if type(resp) == str:
        return resp
    return json.loads(resp[0][0])

def parse_results(path):
    errors = {}

    known_errors = ["not registered", "Cannot apply operator:"]

    with open(path, 'r') as f:
        lines = f.readlines()
        print(f"Total number of errors: {len(lines)}")
        for line in lines:
            split = line.split(": error: ")
            if len(split) > 1:
                error = split[1]
                for known_error in known_errors:
                    if known_error in error:
                        errors[known_error] = errors.get(known_error, 0) + 1



    # print(f"Unique errors: {len(errors)}")
    print(errors)

def run_all_spells():
    """
    Function that runs all the spells in the compiled_models_dir and returns the success rate.
    """

    # to run all spells
    queries = get_models(compiled_models_dir)

    # to run all spells with no dependencies
    # queries = get_models_from_manifest("/Users/couralex/src/spellbook/target/manifest.json")
    table_no_exist = []
    success_count = 0
    total_count = 0
    for query in queries:
        # resp = explain_query(compiled_models_dir + query.replace(".sql", ".translated.sql"))
        resp = explain_query(query)
        if type(resp) == str:
            if "Table 'iceberg.dbt_alex_" in resp:
                table_no_exist.append(query)
            elif resp.startswith("error"):
                total_count += 1
                print(query + ": " + resp)
        else:
            total_count += 1
            success_count += 1

    print(f"Total number of tables that don't exist: {len(table_no_exist)}")
    print(f"Success rate: {success_count}/{total_count}. Total explains: {total_count}. Total queries: {len(queries)}")


run_all_spells()

# get_models_from_manifest("/Users/couralex/src/spellbook/target/manifest.json")

# parse_results("/Users/couralex/src/spellbook/scripts/explain.txt")

# executed_query = execute_query("/Users/couralex/src/spellbook/target/compiled/spellbook/models/looksrare/ethereum/looksrare_ethereum_burns.translated.sql")
# resp = executed_query[0][0]
# print(json.loads(resp))


# models = get_models(compiled_models_dir)
# for model in models:
#     print(model)
