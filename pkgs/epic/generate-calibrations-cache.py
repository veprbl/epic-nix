#!/usr/bin/env python3
import os
import re
import subprocess
import sys
import xml.etree.ElementTree as ET


FNV1A_64_OFFSET = 0xcbf29ce484222325
FNV1A_64_PRIME = 0x100000001b3


def fnv1a_64(s):
    h = FNV1A_64_OFFSET
    for b in s.encode():
        h ^= b
        h = (h * FNV1A_64_PRIME) & 0xFFFFFFFFFFFFFFFF
    return f"{h:016x}"


FALLBACK_URLS = {
    # 26.07.2 uses a root:// URL that is not accessible from all environments;
    # fall back to the same file in the epic-data GitHub repository.
    "root://dtn-eic.jlab.org//volatile/eic/EPIC/xrdtest/CALIB/2025/5a202b05d865214e3c399883ee13859318044678f87d7b3d9fa8ff526b4909b6/Low-Q2_Steering_Reconstruction.onnx":
        "https://github.com/eic/epic-data/raw/1882ccb5ddf13d7e5838c5eec85eaa29bca6c83a/onnx/Low-Q2_Steering_Reconstruction.onnx",
}


def download(url, dest, xrootd_available):
    if url.startswith("root://"):
        fallback_url = FALLBACK_URLS.get(url)
        if fallback_url:
            cmd = ["curl", "--retry", "5", "--location", "--fail", "--output", dest, fallback_url]
        elif xrootd_available:
            cmd = ["xrdcp", "--retry", "5", url, dest]
        else:
            raise RuntimeError(f"no xrootd available and no fallback for {url}")
    else:
        cmd = ["curl", "--retry", "5", "--location", "--fail", "--output", dest, url]
    subprocess.run(cmd, check=True)


def collect_urls_from_xml(path):
    urls = []
    try:
        tree = ET.parse(path)
    except ET.ParseError as e:
        print(f"warning: failed to parse {path}: {e}")
        return urls
    root = tree.getroot()

    for plugin in root.findall(".//plugin[@name='epic_FileLoader']"):
        args = [arg.get("value") for arg in plugin.findall("arg")]
        url_arg = None
        for arg in args:
            if arg.startswith("url:"):
                url_arg = arg[4:]
        if url_arg:
            urls.append(url_arg)

    for elem in root.iter():
        url = elem.get("url")
        if url and (elem.tag == "field" or elem.tag.endswith("_gdmlfile")):
            urls.append(url)

    return urls


def main():
    if len(sys.argv) < 3:
        print(f"Usage: {sys.argv[0]} <source-path> <cache-dir>")
        sys.exit(1)

    source_path = sys.argv[1]
    cache_dir = sys.argv[2]

    os.makedirs(cache_dir, exist_ok=True)

    xrootd_available = os.path.exists("xrdcp") or any(
        os.path.exists(os.path.join(p, "xrdcp"))
        for p in os.environ.get("PATH", "").split(os.pathsep)
    )

    urls = set()
    if os.path.isdir(source_path):
        for dirpath, _dirnames, filenames in os.walk(source_path):
            for filename in filenames:
                if filename.endswith(".xml"):
                    urls.update(collect_urls_from_xml(os.path.join(dirpath, filename)))
    else:
        urls.update(collect_urls_from_xml(source_path))

    for url in urls:
        h = fnv1a_64(url)
        dest = os.path.join(cache_dir, h)
        print(f"downloading {url} as {h}")
        download(url, dest, xrootd_available)


if __name__ == "__main__":
    main()
