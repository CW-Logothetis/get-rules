# Create a High-Quality Merge Request

**Your Task: Follow this comprehensive checklist to prepare and create a well-documented, clean, and accurate Merge Request (mR) using Gitlab's `glab` CLI.**

You can find `glab` commands here @.cursor/workflows/tools/cli/gitlab.md - refer to these if you get any errors in the terminal for commans that you read here or try off your own back.

## File Existence Check

Confirm the presence of `.gitignore` and the MR body file location:

```bash
ls . docs
```

Use this information before running the remaining steps.

0.  **Pre-check: Unstaged Changes**
    - **Action:** Execute `git status`.
    - **Review:** Identify any modified or new files relevant to this MR that are not yet staged.
    - **Stage if Necessary:** If relevant changes are unstaged, use `git add <file>...` or `git add .`.
    - **Confirm:** Re-run `git status` to ensure all intended changes for this MR are now staged.

1.  **Audit Staged Files (Critical Check)**
    - **Verify `.gitignore`**:** Ensure your project's `.gitignore` file is up-to-date and correctly excludes all unwanted files (e.g., local environment files, build artifacts, logs, secrets).
    - **Review Staged List:** Execute `git status` again. Meticulously review the final list of files staged for commit.
    - **Identify Unwanted Files:** Look for any files that should *not* be part of the repository or this specific MR (e.g., secrets, large binaries, temporary files). Standard configuration files like `.vscode/`, `.cursor/`, `.editorconfig` are generally acceptable if intended for the project.
    - **Remediate if Unwanted Files Found:**
        - Add/update patterns in `.gitignore` for these files.
        - Unstage them: `git reset HEAD <file>...`.
        - If already tracked, remove from Git history: `git rm --cached <file>...`.
        - For untracked files, ensure they are now ignored or delete them if they are genuinely extraneous.
    - **Final Confirmation:** Run `git status` one last time. Verify that *only* the intended and appropriate files remain staged.

2.  **Draft Merge Request Body**
    - **Create/Update MR Body File:** Prepare the MR description in a file named `docs/mr/mr-body-file-<branch-name>.md` (replace `<branch-name>` with your current Git branch name).
    - **Structure for Clarity:** Use Markdown with clear headings from the appropriate template (see next point below).
    - **Follow the appropriate template:**
      - *for new features:* read @.gitlab/merge_request_templates/Feature.md
      - *for bugs:* read @.gitlab/merge_request_templates/Bug.md
    - **Short bullet points:** only add a maximum of three bullet points to each item in the templates. Each bullet point should have a maximum of two sentences.
  - **Save:** Ensure the MR body file is saved.

3.  **Create Merge Request with `glab` CLI**
    - **Push Branch (if not already done):** Ensure your local branch is pushed to the remote: `git push -u origin <branch-name>`.
    - **Construct Gitlab create MR Command:**
        - Use a conventional commit title with Jira Ticket: `--title "type(TICKET NUMBER): Short description of main change"` (e.g., `feat(MAV-21000: Implement user authentication flow`). Follow conventional commit message standards.
        - Specify the drafted body file: `--body-file docs/mr/mr-body-file-<branch-name>.md`.
    - **Execute:** Run the Gitlab command to create the MR with your prepared options.
    - **Review `glab` Output:** Carefully check the preview of the title and body provided by `glab` before final submission. Ensure it is accurate, clear, and complete.

**Example `gh pr create` command:**

```bash
# Ensure branch is pushed first: git push -u origin fix-label-sanitization
glab mr create --title "fix(MAV-12546): Enforce normalized, dash-separated, lowercase labels" --description-file docs/mr/mr-body-file-fix-label-sanitization.md
```

After creating the merge request, give a concise executive summary of the key changes and tests so reviewers know what to expect. Keep this summary separate from the MR body file.

**REMEMBER: The objective is to create a meticulously prepared Merge Request. This includes clean commits, a descriptive title, a comprehensive body, and adherence to any project-specific pre-MR checks. A high-quality MR facilitates easier review and smoother integration.**
