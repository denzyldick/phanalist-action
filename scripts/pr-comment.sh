#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo="${GITHUB_REPOSITORY:?GITHUB_REPOSITORY is required}"
pr="${PR_NUMBER:?PR_NUMBER is required}"
sarif="${SARIF_FILE:?SARIF_FILE is required}"
head_sha="${PR_HEAD_SHA:-${GITHUB_SHA:-}}"
server="${SERVER_URL:-https://github.com}"

if [ -z "${GH_TOKEN:-}" ]; then
  echo "::warning::GH_TOKEN is not set; skipping Phanalist PR comment."
  exit 0
fi

if [ ! -s "${sarif}" ]; then
  echo "::warning::SARIF file not found at ${sarif}; skipping Phanalist PR comment."
  exit 0
fi

tool_name="$(jq -r '.runs[0].tool.driver.name // "Phanalist"' "${sarif}")"
tool_name_enc="$(jq -rn --arg v "${tool_name}" '$v | @uri')"
tmp="$(mktemp -d)"
trap 'rm -rf "${tmp}"' EXIT

check_id=""
for _ in $(seq 1 10); do
  for sha in "${head_sha}" "${GITHUB_SHA:-}"; do
    [ -n "${sha}" ] || continue
    check_id="$(gh api --method GET \
      "repos/${repo}/commits/${sha}/check-runs?check_name=${tool_name_enc}&filter=latest" \
      --jq '.check_runs[0].id // empty' 2>/dev/null || true)"
    if [ -n "${check_id}" ]; then
      break 2
    fi
  done
  sleep 3
done

if [ -z "${check_id}" ]; then
  echo "::warning::Could not find the ${tool_name} check run; skipping Phanalist PR comment."
  exit 0
fi

annotations_raw="${tmp}/annotations.raw"
for _ in $(seq 1 10); do
  if ! gh api --paginate "repos/${repo}/check-runs/${check_id}/annotations?per_page=100" > "${annotations_raw}" 2>/dev/null; then
    echo "::warning::Could not read ${tool_name} check-run annotations; skipping Phanalist PR comment."
    exit 0
  fi
  if [ -s "${annotations_raw}" ] && [ "$(jq -s 'add // [] | length' "${annotations_raw}")" -gt 0 ]; then
    break
  fi
  sleep 3
done

jq -s 'add // []' "${annotations_raw}" > "${tmp}/annotations.json"

alerts_url="${server}/${repo}/security/code-scanning?query=pr%3A${pr}+tool%3A${tool_name_enc}+is%3Aopen"
jq -r -n \
  --slurpfile sarif "${sarif}" \
  --slurpfile annotations "${tmp}/annotations.json" \
  --arg alerts_url "${alerts_url}" \
  -f "${script_dir}/build-comment.jq" > "${tmp}/body.md"

if [ ! -s "${tmp}/body.md" ]; then
  echo "::warning::Phanalist PR comment body was empty; skipping."
  exit 0
fi

existing="$(gh api --paginate "repos/${repo}/issues/${pr}/comments?per_page=100" \
  | jq -s 'add // []' \
  | jq -r '.[] | select(.body | contains("<!-- phanalist-action -->")) | .id' \
  | head -n 1)"

jq -n --rawfile body "${tmp}/body.md" '{body: $body}' > "${tmp}/payload.json"

if [ -n "${existing}" ]; then
  gh api --method PATCH "repos/${repo}/issues/comments/${existing}" --input "${tmp}/payload.json" >/dev/null
  echo "Updated Phanalist PR comment: ${existing}"
else
  gh api --method POST "repos/${repo}/issues/${pr}/comments" --input "${tmp}/payload.json" >/dev/null
  echo "Created Phanalist PR comment."
fi
