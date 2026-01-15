# oxlint-annotation-repro

Minimal reproduction for oxlint warnings piped to GitHub Actions annotations and PR review comments.

This repo has two PRs:
- A "no-fix" PR that triggers a max-lines warning but fails to create a PR inline comment.
- A "fix" PR that changes one line in the script to make the inline comment work.
