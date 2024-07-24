#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p "python3.withPackages(ps: with ps; [ requests ])" common-updater-scripts

"""
Binary Ninja update script

This script requests a license for channel CHANNEL, fetches mail with isync, finds the license email from Vector35, and computes the hashes of the installer for PLATFORMS (or all supported platforms if -a is specified), along with writing the license to the user's Downloads directory.
To prevent abuse, all URLs must be prefixed with FQDN.
(CURRENTLY BROKEN) Only the installers for SYSTEMS will be left in the store in order to consume less disk space.
It is the caller's responsibility to set $HOME sensibly.

This is highly tailored to the setup of the author; instead of contorting this to your needs, I suggest using this as inspiration to write your own script. (You can also just fetch the URL manually)

Example:
./update.py aarch64-darwin dev -a
"""

import email, os, pathlib, re, requests, subprocess, shlex, sys, time, traceback

def log(arg):
    print(arg, file=sys.stderr)
def run(cmd, **kwargs):
    return subprocess.check_output(shlex.split(cmd), **kwargs).decode().strip()

FQDN = "https://binaryninja.s3.amazonaws.com/"
binja_platforms = {
    # "x86_64-darwin": "macOS",  # same as aarch64-darwin
    "macOS": "aarch64-darwin",
    "Linux (x86_64)": "aarch64-linux",
    "Linux (aarch64)": "x86_64-linux"
}

# this update script gets copied to the store, so __file__ isn't what you want; update.nix ensures $CWD is fyshpkgs.
# fyshpkgs = pathlib.Path(__file__).parent.parent.parent

if (l:=len(sys.argv)) < 3 or l > 4: sys.exit("Incorrect number of arguments, see usage below:\n" + __doc__)
platforms = sys.argv[1].split(','); assert (t:=next((p for p in platforms if p and p not in binja_platforms.values()), None)) is None, f"Unsupported platform {t}"
channel = sys.argv[2]; assert channel in ("dev", "stable"), f"Unknown channel {channel}"
email_address = os.environ.get("EMAIL") or subprocess.check_output(shlex.split("git config user.email")).decode().strip(); assert '@' in email_address, f"Invalid email address {email_address}"
update_all = len(sys.argv) == 4 and ((a:=sys.argv[3]) == "-a" or a == "--all")

version_re = re.compile(r"VERSION: '([\d.]*(-dev)?)")
api_info = requests.get(f"https://{'dev-' if channel == 'dev' else ''}api.binary.ninja/_static/documentation_options.js"); api_info.raise_for_status()
version = version_re.search(api_info.text).group(1)
log(f"Found version {version}...")

log(f"Requesting Binary Ninja download for user {email_address}...")
_ = requests.get("https://master.binary.ninja/recover/", params = {"email": email_address, "dev": channel == "dev"}).raise_for_status()

RETRY = 3 # be sure to tweak the query date range if you change this
for _ in range(RETRY):
    time.sleep(60)
    _ = run("mbsync -a")
    try:
        mail_file = run('mu find date:5M.. and from:licenses@vector35.com and subject:"Binary Ninja License" -n 1 --sortfield=date --reverse --fields=l')
    except: pass
    else:
        break
else:
    raise Exception(f"Couldn't find license email in {RETRY} attempts")

with open(mail_file) as f:
    mail = email.message_from_file(f)

# More. MORE!
urls = {binja_platforms[p]: (l[l.index(FQDN):]).replace("&amp;", '&') for l in next((p for p in mail.walk() if p.get_content_type() == "text/plain")).get_payload().split('\n') if (p:=next(filter(lambda x: l.startswith(x), binja_platforms.keys()), None))}

license = next((p for p in mail.walk() if p.get_content_type() == "application/json"))
with open(pathlib.Path.home() / "Downloads" / license.get_filename(), 'wb') as f:
    f.write(license.get_payload(decode=True))
    log(f"Wrote binja license to {f.name}")

urls = urls if update_all else {k: v for k, v in urls.items() if k in platforms}
gc_paths = []
try:
    for platform, url in urls.items():
        sha256, store_path = run(f"nix-prefetch-url --type sha256 {url} --name {url[url.rfind('/')+1:url.index('?')]} --print-path").split()
        gc_paths.append(store_path)
        sha256 = run(f"nix hash to-sri --type sha256 {sha256}")
        _ = run(f"update-source-version binary-ninja{'-dev' if channel == 'dev' else ''} {version} {sha256} --system={platform} --version-key={platform}.{channel}.version")
# BROKEN: unconditionally GC on failure, only GC unwanted installers otherwise
# fails because the paths are "alive"; likely due to issues with gc roots on macOS, maybe it works on Linux
# except:
#     traceback.print_exc()
#     if gc_paths:
#         log(f"Deleting {gc_paths}")
#         _ = run(f"nix-store --delete {' '.join(gc_paths)}")
# else:
#     if (gc:=[p for p in gc_paths if not ((p in platforms) or (p == "aarch64-darwin" and "x86_64-darwin" in platforms))]):
#         log(f"Deleting {gc}")
#         _ = run(f"nix-store --delete {' '.join(gc)}")
#     log("All done!")
except: pass
else: log("All done!")
