#!/usr/bin/env python3
"""
Fetch Claude Code usage from Anthropic's OAuth usage API.

Reads the OAuth access token from ~/.claude/.credentials.json (Linux/WSL),
calls GET https://api.anthropic.com/api/oauth/usage, and prints the JSON
response to stdout. Exits non-zero on failure so a caller using
stale-while-revalidate caching (e.g. statusline-command.sh) won't overwrite
a previously-good cache file with empty data.

Ported from ccstatusline (sirmalloc/ccstatusline, MIT) — specifically the
usage-fetch.ts module. We use only the Linux/WSL credential path; macOS
keychain handling is out of scope.

Endpoint / auth contract:
    GET https://api.anthropic.com/api/oauth/usage
    Authorization: Bearer <accessToken>
    anthropic-beta: oauth-2025-04-20

Response shape (relevant fields):
    {
      "five_hour":  { "utilization": <number>, "resets_at": "<iso8601>" },
      "seven_day":  { "utilization": <number>, "resets_at": "<iso8601>" },
      "seven_day_sonnet": { ... },
      "seven_day_opus":   { ... },
      "extra_usage":      { ... }
    }
"""

import json
import os
import sys
import urllib.error
import urllib.request

CRED_PATH = os.path.expanduser("~/.claude/.credentials.json")
URL = "https://api.anthropic.com/api/oauth/usage"
TIMEOUT_SEC = 5


def read_token() -> str:
    with open(CRED_PATH, encoding="utf-8") as f:
        cred = json.load(f)
    token = (cred.get("claudeAiOauth") or {}).get("accessToken")
    if not token:
        raise RuntimeError("claudeAiOauth.accessToken not found")
    return token


def main() -> int:
    try:
        token = read_token()
    except Exception as exc:
        print(f"usage-fetch: {exc}", file=sys.stderr)
        return 2

    req = urllib.request.Request(
        URL,
        headers={
            "Authorization": f"Bearer {token}",
            "anthropic-beta": "oauth-2025-04-20",
        },
    )
    try:
        with urllib.request.urlopen(req, timeout=TIMEOUT_SEC) as resp:
            body = resp.read().decode("utf-8")
    except urllib.error.HTTPError as exc:
        print(f"usage-fetch: HTTP {exc.code} {exc.reason}", file=sys.stderr)
        return 3
    except Exception as exc:
        print(f"usage-fetch: {type(exc).__name__}: {exc}", file=sys.stderr)
        return 4

    try:
        json.loads(body)
    except Exception as exc:
        print(f"usage-fetch: response not valid JSON: {exc}", file=sys.stderr)
        return 5

    sys.stdout.write(body)
    return 0


if __name__ == "__main__":
    sys.exit(main())
