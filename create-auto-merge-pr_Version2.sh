#!/usr/bin/env bash
set -euo pipefail

REPO="hacyber-global/hgt-multi-botgrabber"
BRANCH="chore/add-auto-merge"

TMP=$(mktemp -d)
git clone "git@github.com:${REPO}.git" "$TMP/repo"
cd "$TMP/repo"

git checkout -b "$BRANCH"

mkdir -p .github/workflows
cat > .github/workflows/auto-merge.yml <<'YAML'
name: Auto Merge when ready
on:
  pull_request:
    types: [opened, reopened, synchronized, ready_for_review]
  check_suite:
    types: [completed]

permissions:
  pull-requests: write
  contents: read

jobs:
  automerge:
    runs-on: ubuntu-latest
    steps:
      - name: Determine PR number and mergeable state
        uses: actions/github-script@v7
        id: check
        with:
          script: |
            const pr = context.payload.pull_request ?? null;
            let number = pr?.number;
            if (!number) {
              const prs = await github.rest.pulls.list({
                owner: context.repo.owner,
                repo: context.repo.repo,
                state: 'open',
                per_page: 100
              });
              if (prs && prs.data && prs.data.length > 0) {
                number = prs.data[0].number;
              }
            }
            if (!number) return core.setFailed('No PR context found.');
            const { data } = await github.rest.pulls.get({
              owner: context.repo.owner,
              repo: context.repo.repo,
              pull_number: number
            });
            core.setOutput('number', data.number);
            core.setOutput('mergeable', String(data.mergeable));
            core.setOutput('mergeable_state', String(data.mergeable_state));
      - name: Merge PR when mergeable
        if: steps.check.outputs.mergeable == 'true' || steps.check.outputs.mergeable_state == 'clean'
        uses: peter-evans/merge@v3
        with:
          pull-request-number: ${{ steps.check.outputs.number }}
          merge-method: squash
          delete-branch: true
          token: ${{ secrets.GITHUB_TOKEN }}
YAML

git add .github/workflows/auto-merge.yml
git commit -m "Add auto-merge workflow"
git push -u origin "$BRANCH"

DEFAULT_BRANCH=$(gh repo view "$REPO" --json defaultBranchRef --jq '.defaultBranchRef.name')
gh pr create --repo "$REPO" --title "Add auto-merge workflow" --body "Auto-merge PRs when mergeable (squash + delete branch)." --base "$DEFAULT_BRANCH" --head "$BRANCH"

echo "Created branch $BRANCH and opened PR against $DEFAULT_BRANCH."