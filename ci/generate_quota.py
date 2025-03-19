# import yaml
# from jinja2 import Environment, FileSystemLoader

# with open("config.yaml", "r") as file:
#     config_data = yaml.safe_load(file)

# env = Environment(loader=FileSystemLoader("."))  
# template = env.get_template("resource_quota_template.yaml")

# output_yaml = template.render(config_data)

# with open("resource_quota.yaml", "w") as output_file:
#     output_file.write(output_yaml)

# print("Arquivo resource_quota.yaml gerado com sucesso!")
import yaml
import argparse
from jinja2 import Environment, FileSystemLoader
import os

# Configurar argumentos da linha de comando
parser = argparse.ArgumentParser(description="Generate Kubernetes ResourceQuota YAML")
parser.add_argument("--config", required=True, help="Path to the config.yaml file")
parser.add_argument("--template", required=True, help="Path to the resource_quota_template.yaml file")
args = parser.parse_args()

config_path = args.config
template_path = args.template
template_dir = os.path.dirname(template_path)

if not os.path.isfile(config_path):
    raise FileNotFoundError(f"Config file '{config_path}' not found.")

if not os.path.isfile(template_path):
    raise FileNotFoundError(f"Template file '{template_path}' not found.")

with open(config_path, "r") as file:
    config_data = yaml.safe_load(file)

env = Environment(loader=FileSystemLoader(template_dir))
template = env.get_template(os.path.basename(template_path))

output_yaml = template.render(config_data)

output_file_path = os.path.join(os.path.dirname(config_path), "resource_quota.yaml")
with open(output_file_path, "w") as output_file:
    output_file.write(output_yaml)

print(f"Arquivo {output_file_path} gerado com sucesso!")
