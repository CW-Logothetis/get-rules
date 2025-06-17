# Jira CLI – Cursor Rules & Usage

## Main Commands

### Issue
- List:
  ```sh
  jira issue list
  jira issue list --created -7d
  jira issue list -s"To Do"
  jira issue list --plain
  jira issue list --raw
  jira issue list --csv
  jira issue list -q "summary ~ cli"
  ```
- Create:
  ```sh
  jira issue create
  jira issue create -tBug -s"New Bug" --no-input
  jira issue create --template /path/to/template.tmpl
  ```
- Edit:
  ```sh
  jira issue edit ISSUE-1 -s"New summary" --no-input
  ```
- Assign:
  ```sh
  jira issue assign ISSUE-1 "Jon Doe"
  jira issue assign ISSUE-1 $(jira me)
  jira issue assign ISSUE-1 x  # Unassign
  ```
- Move/Transition:
  ```sh
  jira issue move ISSUE-1 "In Progress"
  jira issue move ISSUE-1 Done -RFixed -a$(jira me)
  ```
- View:
  ```sh
  jira issue view ISSUE-1
  jira issue view ISSUE-1 --comments 5
  ```
- Link/Unlink:
  ```sh
  jira issue link ISSUE-1 ISSUE-2 Blocks
  jira issue unlink ISSUE-1 ISSUE-2
  ```
- Clone:
  ```sh
  jira issue clone ISSUE-1 -s"Modified summary"
  jira issue clone ISSUE-1 -H"find:replace"
  ```
- Delete:
  ```sh
  jira issue delete ISSUE-1
  jira issue delete ISSUE-1 --cascade
  ```
- Comment:
  ```sh
  jira issue comment add ISSUE-1 "My comment"
  jira issue comment add ISSUE-1 --internal
  jira issue comment add ISSUE-1 --template /path/to/template.tmpl
  ```
- Worklog:
  ```sh
  jira issue worklog add ISSUE-1 "2d 3h 30m" --no-input
  jira issue worklog add ISSUE-1 "10m" --comment "This is a comment"
  ```

### Epic
- List:
  ```sh
  jira epic list
  jira epic list --table
  jira epic list KEY-1
  ```
- Create:
  ```sh
  jira epic create -n"Epic name" -s"Summary"
  ```
- Add/Remove Issues:
  ```sh
  jira epic add EPIC-KEY ISSUE-1 ISSUE-2
  jira epic remove ISSUE-1 ISSUE-2
  ```

### Sprint
- List:
  ```sh
  jira sprint list
  jira sprint list --table
  jira sprint list --current
  jira sprint list SPRINT_ID
  ```
- Add Issues:
  ```sh
  jira sprint add SPRINT_ID ISSUE-1 ISSUE-2
  ```

### Releases
- List:
  ```sh
  jira release list
  jira release list --project KEY
  ```

### Other
- Open project/issue in browser:
  ```sh
  jira open
  jira open KEY-1
  ```
- List projects/boards:
  ```sh
  jira project list
  jira board list
  ```

## Flags & Options
- `--plain` – plain output
- `--raw` – JSON output
- `--csv` – CSV output
- `--order-by` – sort order
- `--reverse` – reverse order
- `-a` – assignee
- `-r` – reporter
- `-s` – status
- `-y` – priority
- `-l` – label
- `-q` – JQL query
- `--created`, `--updated` – time filters

## Scripting Example
Count tickets per day this month:
```sh
jira issue list --created month --plain --columns created --no-headers | awk '{print $2}' | awk -F'-' '{print $3}' | sort -n | uniq -c
```

## Tips
- Use `jira completion --help` for shell completion.
- Use `jira --help` or `jira <command> --help` for more info.

---
For full docs: [ankitpokhrel/jira-cli](https://github.com/ankitpokhrel/jira-cli) 
