#!/usr/bin/env bash
#
# check-updates.sh - Check for new releases of eic/epic and eic/EICrecon,
# update flake.nix and pkgs/*/default.nix, and open PRs for each update.
#
# Requirements: curl, jq, sed, git, gh (GitHub CLI)
# Designed to be called from a GitHub Actions workflow.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

# -- Package definitions -------------------------------------------------------
# Each entry: "input_name|github_owner_repo|tag_prefix|pkg_dir"
#   input_name      : flake input name (without the -src suffix)
#   github_owner_repo: owner/repo on GitHub
#   tag_prefix       : prefix used in git tags ("v" or "")
#   pkg_dir          : directory under pkgs/
PACKAGES=(
  "epic|eic/epic||epic"
  "eicrecon|eic/EICrecon|v|eicrecon"
)

# -- Fetch the latest tag from GitHub ------------------------------------------
get_latest_tag() {
  local repo="$1"
  curl -sf "https://api.github.com/repos/${repo}/tags?per_page=1" \
    | jq -r '.[0].name'
}

# -- Extract the current tag from flake.nix for a given input ------------------
get_current_flake_tag() {
  local input_name="$1"
  local github_owner_repo="$2"
  # The flake input URL is on its own line:  url = "github:<owner>/<repo>/<tag>";
  sed -n 's|.*url = "github:'"${github_owner_repo}"'/\([^"]*\)";.*|\1|p' flake.nix
}

# -- Main loop -----------------------------------------------------------------
for entry in "${PACKAGES[@]}"; do
  IFS='|' read -r input_name github_owner_repo tag_prefix pkg_dir <<< "$entry"

  echo "::group::Checking $github_owner_repo"

  latest_tag=$(get_latest_tag "$github_owner_repo")
  current_tag=$(get_current_flake_tag "$input_name" "$github_owner_repo")

  echo "  Current tag in flake.nix: $current_tag"
  echo "  Latest  tag on GitHub:    $latest_tag"

  if [ "$latest_tag" = "$current_tag" ]; then
    echo "  Already up-to-date."
    echo "::endgroup::"
    continue
  fi

  # Strip the tag prefix to get bare version numbers
  latest_version="${latest_tag#$tag_prefix}"
  current_version="${current_tag#$tag_prefix}"

  branch_name="update/${pkg_dir}-${latest_version}"

  echo "  Update available: $current_version -> $latest_version"

  # Skip if a branch (and presumably a PR) already exists
  if git ls-remote --exit-code origin "refs/heads/$branch_name" >/dev/null 2>&1; then
    echo "  Branch $branch_name already exists. Skipping."
    echo "::endgroup::"
    continue
  fi

  # -- Apply changes -----------------------------------------------------------

  # 1) Update the flake input URL  (url line: url = "github:<owner>/<repo>/<tag>";)
  sed -i "s|url = \"github:${github_owner_repo}/${current_tag}\"|url = \"github:${github_owner_repo}/${latest_tag}\"|" flake.nix

  # 2) Update version string in pkgs/<pkg_dir>/default.nix
  pkg_nix="pkgs/$pkg_dir/default.nix"
  if [ -f "$pkg_nix" ]; then
    sed -i "s|version = \"${current_version}|version = \"${latest_version}|" "$pkg_nix"
  fi

  # -- Commit, push, and open a PR ---------------------------------------------
  git checkout -b "$branch_name"
  git add flake.nix "$pkg_nix"
  git commit -m "$pkg_dir: $current_version -> $latest_version"
  git push origin "$branch_name"

  pr_body="Automated update of **$github_owner_repo** from $current_tag to $latest_tag.

This PR was created automatically by the check-updates workflow.

Release: https://github.com/$github_owner_repo/releases/tag/$latest_tag"

  gh pr create \
    --title "$pkg_dir: update $current_version -> $latest_version" \
    --body "$pr_body" \
    --base master \
    --head "$branch_name"

  # Return to master for the next package
  git checkout master

  echo "  PR created for $branch_name"
  echo "::endgroup::"
done

echo "All checks complete."
