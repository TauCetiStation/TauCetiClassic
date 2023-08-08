#!/usr/bin/env python3

# Fetches titles of test merged PRs from GitHub and saves them to cache
# Args:
# * PR IDs
# * GitHub token (optional)
# * Repository owner and name (optional e.g. 'TauCetiStation/TauCetiClassic'
# * * If not set will try to get names from cache (in case you want to use something else to fetch and store test merges)
# Returns:
# * JSON-encoded object of test merges and their titles

import argparse
from dataclasses import dataclass
import json
import sys
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor
import requests


@dataclass
class FetchArgs:
    pr_id: str
    repo: str
    headers: dict


def read_arguments():
    parser = argparse.ArgumentParser(description="get wrapper")

    parser.add_argument("prs", nargs="+")

    parser.add_argument("-t", "--token", default=None)

    parser.add_argument("-r", "--repo_owner_and_name", default=None, dest="repo")

    return parser.parse_args()


def fetch_merge(args: FetchArgs):
    try:
        resp = requests.get(
            f"https://api.github.com/repos/{args.repo}/pulls/{args.pr_id}",
            timeout=30,
        )
        if resp.status_code == 429:
            # you look at your anonymous access and sigh
            return args.pr_id, "GITHUB API ERROR: RATE LIMITED"
        if resp.status_code == 404:
            # you look at your shithub and sigh
            return args.pr_id, "GITHUB API ERROR: PR NOT FOUND"
        if resp.status_code == 401:
            # you look at your token and sigh
            return args.pr_id, "GITHUB API ERROR: BAD CREDENTIALS"
        if resp.status_code != 200:
            error_msg = json.loads(resp.text)["message"]
            print(error_msg, file=sys.stderr)
            return args.pr_id, "GITHUB API ERROR"
        json_object = json.loads(resp.text)
        return args.pr_id, f'{json_object["title"]} by {json_object["user"]["login"]}'
    except (requests.exceptions.RequestException, json.JSONDecodeError) as exc:
        print(exc, file=sys.stderr)
        return args.pr_id, "FAILED TO GET PR TITLE"


def main(options):
    cache_path = Path("data/testMergeCache.txt")

    test_merges = {}
    if cache_path.exists():
        with open(cache_path, "r", encoding="utf-8") as file:
            for line in file:
                merge_id, title = line.strip().split(" ", 1)
                test_merges[merge_id] = title

    to_fetch = set(options.prs) - set(test_merges.keys())
    headers = {
        "Accept": "application/vnd.github+json",
        "X-GitHub-Api-Version": "2022-11-28",
    }
    if options.token:
        headers["Authorization"] = f"Bearer {options.token}"

    with ThreadPoolExecutor(max_workers=10) as pool:
        for merge_id, title in pool.map(
            fetch_merge,
            (FetchArgs(merge_id, options.repo, headers) for merge_id in to_fetch),
        ):
            test_merges[merge_id] = title.strip()

    sys.stdout.buffer.write(json.dumps(test_merges).encode("utf-8"))

    cache_path.parent.mkdir(parents=True, exist_ok=True)
    with open(cache_path, "w", encoding="utf-8") as file:
        for merge_id, title in test_merges.items():
            file.write(f"{merge_id} {title}\n")

    return 0


if __name__ == "__main__":
    sys.exit(main(read_arguments()))
