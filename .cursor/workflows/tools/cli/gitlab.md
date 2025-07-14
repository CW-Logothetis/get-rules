# Core GitLab CLI Commands

Run `glab --help` to view a list of core commands in your terminal.

- `glab alias`
- `glab api`
- `glab auth`
- `glab changelog`
- `glab check-update`
- `glab ci`
- `glab cluster`
- `glab completion`
- `glab config`
- `glab duo`
- `glab incident`
- `glab issue`
- `glab label`
- `glab mr`
- `glab release`
- `glab repo`
- `glab schedule`
- `glab securefile`
- `glab snippet`
- `glab ssh-key`
- `glab stack`
- `glab user`
- `glab variable`

---

Commands follow this pattern:

`glab <command> <subcommand> [flags]`

Many core commands also have sub-commands. Some examples:

* List merge requests assigned to you: `glab mr list --assignee=@me`
* List review requests for you: `glab mr list --reviewer=@me`
* Approve a merge request: `glab mr approve 235`
* Create an issue, and add milestone, title, and label: `glab issue create -m release-2.0.0 -t "My title here" --label important`

---

## GitLab Duo for the CLI

The GitLab CLI also provides support for GitLab Duo AI/ML powered features. These include:

* `glab duo ask`

Use `glab duo ask` to ask questions about Git commands. It can help you remember a command you forgot, or provide suggestions on how to run commands to perform other tasks.
