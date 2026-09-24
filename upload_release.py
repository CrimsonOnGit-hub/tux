#!/usr/bin/env python3
import urllib.request
import urllib.error
import json
import os
import sys
import ssl

TOKEN = os.environ.get("GH_TOKEN")
if not TOKEN and len(sys.argv) > 1:
    TOKEN = sys.argv[1]
if not TOKEN:
    print("[-] Error: Provide GH_TOKEN environment variable or pass token as first argument.")
    sys.exit(1)
REPO = "CrimsonOnGit-hub/tux"
TAG = "v1.0.0"
DEB_PATH = os.path.join("dist", "tux_1.0.0_all.deb")

def get_ssl_context():
    return ssl._create_unverified_context()

def api_request(url, method="GET", data=None, headers=None):
    if headers is None:
        headers = {}
    headers["Authorization"] = f"token {TOKEN}"
    headers["User-Agent"] = "Antigravity-Release-Uploader"
    headers["Accept"] = "application/vnd.github.v3+json"
    
    req_data = None
    if data is not None:
        if isinstance(data, (dict, list)):
            req_data = json.dumps(data).encode("utf-8")
            headers["Content-Type"] = "application/json"
        else:
            req_data = data
            
    req = urllib.request.Request(url, data=req_data, headers=headers, method=method)
    ctx = get_ssl_context()
    with urllib.request.urlopen(req, context=ctx) as res:
        return json.loads(res.read().decode("utf-8"))

def upload_asset(upload_url_template, file_path):
    upload_url = upload_url_template.split("{")[0] + "?name=" + os.path.basename(file_path)
    print(f"[+] Uploading {file_path} to {upload_url}...")
    with open(file_path, "rb") as f:
        file_bytes = f.read()

    headers = {
        "Authorization": f"token {TOKEN}",
        "User-Agent": "Antigravity-Release-Uploader",
        "Content-Type": "application/vnd.debian.binary-package",
        "Content-Length": str(len(file_bytes))
    }
    req = urllib.request.Request(upload_url, data=file_bytes, headers=headers, method="POST")
    ctx = get_ssl_context()
    with urllib.request.urlopen(req, context=ctx) as res:
        return json.loads(res.read().decode("utf-8"))

def main():
    print(f"[*] Checking existing releases for {REPO}...")
    try:
        releases = api_request(f"https://api.github.com/repos/{REPO}/releases")
    except Exception as e:
        releases = []

    target_release = None
    for r in releases:
        if r.get("tag_name") == TAG:
            target_release = r
            break

    if target_release is None:
        print(f"[+] Creating release {TAG} on {REPO}...")
        payload = {
            "tag_name": TAG,
            "target_commitish": "main",
            "name": f"Tux {TAG}",
            "body": "Official release of Tux Universal Package Manager (.deb package for APT on Linux / Debian / WSL).\n\n### Install with APT:\n```bash\nsudo apt install ./tux_1.0.0_all.deb\n```",
            "draft": False,
            "prerelease": False
        }
        target_release = api_request(f"https://api.github.com/repos/{REPO}/releases", method="POST", data=payload)
        print(f"[+] Created release: {target_release.get('html_url')}")
    else:
        print(f"[+] Found existing release: {target_release.get('html_url')}")

    # Check if asset already exists
    existing_assets = target_release.get("assets", [])
    for a in existing_assets:
        if a.get("name") == os.path.basename(DEB_PATH):
            print(f"[*] Deleting older asset {a.get('name')} (id: {a.get('id')})...")
            del_req = urllib.request.Request(
                f"https://api.github.com/repos/{REPO}/releases/assets/{a.get('id')}",
                headers={"Authorization": f"token {TOKEN}", "User-Agent": "Antigravity"},
                method="DELETE"
            )
            with urllib.request.urlopen(del_req, context=get_ssl_context()):
                pass

    upload_url_template = target_release.get("upload_url")
    result = upload_asset(upload_url_template, DEB_PATH)
    print(f"[SUCCESS] Asset uploaded successfully!")
    print(f"Direct Download URL: {result.get('browser_download_url')}")

if __name__ == "__main__":
    main()
