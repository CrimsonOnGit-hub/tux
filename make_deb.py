#!/usr/bin/env python3
import io
import os
import tarfile
import time

VERSION = "1.0.0"
PACKAGE_NAME = "tux"
ARCH = "all"
OUTPUT_DEB = os.path.join("dist", f"{PACKAGE_NAME}_{VERSION}_{ARCH}.deb")

os.makedirs("dist", exist_ok=True)

mtime = int(time.time())

# 1. debian-binary
debian_binary_data = b"2.0\n"

# 2. control.tar.gz
control_content = f"""Package: {PACKAGE_NAME}
Version: {VERSION}
Section: utils
Priority: optional
Architecture: {ARCH}
Depends: python3
Maintainer: Crimson <allaboutgames2268@gmail.com>
Homepage: https://github.com/CrimsonOnGit-hub/tux
Description: Tux Universal Package Manager
 A fast, lightweight, and colored package manager built for Linux and WSL.
 Pulls packages directly from remote repository catalogs and installs them
 seamlessly.
""".encode("utf-8")

postinst_content = b"""#!/bin/sh
set -e
mkdir -p /var/lib/tux
if [ ! -f /var/lib/tux/lock.json ]; then
    echo '{"installed": {}}' > /var/lib/tux/lock.json
fi
chmod 755 /var/lib/tux
chmod 644 /var/lib/tux/lock.json 2>/dev/null || true
ln -sf /usr/local/bin/tux /usr/local/bin/Tux
chmod 755 /usr/local/bin/tux
exit 0
"""

prerm_content = b"""#!/bin/sh
set -e
rm -f /usr/local/bin/Tux
exit 0
"""

control_buf = io.BytesIO()
with tarfile.open(fileobj=control_buf, mode="w:gz", format=tarfile.GNU_FORMAT) as tar:
    # ./
    ti = tarfile.TarInfo("./")
    ti.type = tarfile.DIRTYPE
    ti.mode = 0o755
    ti.mtime = mtime
    tar.addfile(ti)

    # ./control
    ti = tarfile.TarInfo("./control")
    ti.size = len(control_content)
    ti.mode = 0o644
    ti.mtime = mtime
    tar.addfile(ti, io.BytesIO(control_content))

    # ./postinst
    ti = tarfile.TarInfo("./postinst")
    ti.size = len(postinst_content)
    ti.mode = 0o755
    ti.mtime = mtime
    tar.addfile(ti, io.BytesIO(postinst_content))

    # ./prerm
    ti = tarfile.TarInfo("./prerm")
    ti.size = len(prerm_content)
    ti.mode = 0o755
    ti.mtime = mtime
    tar.addfile(ti, io.BytesIO(prerm_content))

control_tar_gz = control_buf.getvalue()

# 3. data.tar.gz
with open("tux.py", "rb") as f:
    tux_script = f.read()

data_buf = io.BytesIO()
with tarfile.open(fileobj=data_buf, mode="w:gz", format=tarfile.GNU_FORMAT) as tar:
    # Directories
    for dpath in ["./", "./usr/", "./usr/local/", "./usr/local/bin/", "./var/", "./var/lib/", "./var/lib/tux/"]:
        ti = tarfile.TarInfo(dpath)
        ti.type = tarfile.DIRTYPE
        ti.mode = 0o755
        ti.mtime = mtime
        tar.addfile(ti)

    # ./usr/local/bin/tux
    ti = tarfile.TarInfo("./usr/local/bin/tux")
    ti.size = len(tux_script)
    ti.mode = 0o755
    ti.mtime = mtime
    tar.addfile(ti, io.BytesIO(tux_script))

data_tar_gz = data_buf.getvalue()

def build_ar_header(name, size, mode=0o100644):
    name_str = name.ljust(16)
    mtime_str = str(mtime).ljust(12)
    uid_str = "0".ljust(6)
    gid_str = "0".ljust(6)
    mode_str = oct(mode)[2:].ljust(8)
    size_str = str(size).ljust(10)
    fmag = b"`\n"
    return (name_str + mtime_str + uid_str + gid_str + mode_str + size_str).encode("ascii") + fmag

with open(OUTPUT_DEB, "wb") as deb:
    deb.write(b"!<arch>\n")

    # Member 1: debian-binary
    deb.write(build_ar_header("debian-binary", len(debian_binary_data)))
    deb.write(debian_binary_data)
    if len(debian_binary_data) % 2 != 0:
        deb.write(b"\n")

    # Member 2: control.tar.gz
    deb.write(build_ar_header("control.tar.gz", len(control_tar_gz)))
    deb.write(control_tar_gz)
    if len(control_tar_gz) % 2 != 0:
        deb.write(b"\n")

    # Member 3: data.tar.gz
    deb.write(build_ar_header("data.tar.gz", len(data_tar_gz)))
    deb.write(data_tar_gz)
    if len(data_tar_gz) % 2 != 0:
        deb.write(b"\n")

print(f"[SUCCESS] Built {OUTPUT_DEB} ({os.path.getsize(OUTPUT_DEB)} bytes)")
