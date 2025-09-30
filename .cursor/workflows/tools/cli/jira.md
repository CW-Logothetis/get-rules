# Jira CLI – Cursor Rules & Usage

Your Task: When you need to view or edit anything in Jira, use the Jira command-line tool. Adhere strictly to the default behaviors specified below unless explicitly overridden by the user or task requirements.

## Jira API notice (2024-10-31) – JQL Search deprecation and migration

Atlassian has deprecated legacy JQL search and expression evaluate endpoints with removal after 2025-05-01. Affected endpoints include:

- `GET/POST /rest/api/{2|3|latest}/search`
- `POST /rest/api/{2|3|latest}/search/id`
- `POST /rest/api/{2|3|latest}/expression/eval`

Key changes in the new APIs:

- Default responses may return only issue IDs; request specific fields via `fields`.
- Pagination uses continuation tokens (`nextPageToken`) instead of random page access (`startAt`).
- Unbounded JQL is rejected (400). Always bound your queries (for example: `updated > -5m`).
- No `validateQuery` parameter; use the Parse endpoint instead.
- Comment and changelog limits are capped (20 and 40 respectively) via search; use dedicated endpoints to fetch more.

Recommended replacements and helpers:

- Search: `POST /rest/api/3/search/jql` (continuation token based)
- Bulk fetch fields: `POST /rest/api/{2|3|latest}/issue/bulkfetch`
- Approximate count: `POST /rest/api/3/search/approximate-count`
- Parse JQL: `POST /rest/api/3/jql/parse`
- Evaluate expression: `POST /rest/api/3/expression/evaluate`

Notes for CLI usage:

- `jira issue list -q "..."` continues to work, but you must provide bounded JQL. For very large result sets or advanced pagination needs, prefer the curl-based recipes below that call the new endpoints directly.
- Use `--raw` to get JSON and pipe to `jq` for scripting.
- Avoid assumptions about `startAt` or parallel page fetching; use `nextPageToken` sequentially.

### Migration recipes (curl)

Set these environment variables once per shell (or your dotfiles):

```sh
export JIRA_BASE_URL="https://your-domain.atlassian.net"
export JIRA_TOKEN="your_api_token"   # Use a PAT or basic auth token
export JIRA_EMAIL="you@example.com"  # If using basic auth
AUTH_HEADER="Authorization: Basic $(printf "%s:%s" "$JIRA_EMAIL" "$JIRA_TOKEN" | base64)"
CT_HEADER='Content-Type: application/json'
AC_HEADER='Accept: application/json'
```

#### Approximate count

```sh
curl --location "$JIRA_BASE_URL/rest/api/3/search/approximate-count" \
  --header "$AUTH_HEADER" \
  --header $CT_HEADER \
  --header $AC_HEADER \
  --data '{"jql":"project in (FOO, BAR) AND updated > -5m"}' | jq .
```

#### Parse JQL

```sh
curl --location "$JIRA_BASE_URL/rest/api/3/jql/parse" \
  --header "$AUTH_HEADER" \
  --header $CT_HEADER \
  --header $AC_HEADER \
  --data '{"queries":["project in (FOO, BAR) AND updated > -5m"]}' | jq .
```

#### Token-based paginated search (get IDs first)

```sh
BODY='{ "jql": "project in (FOO, BAR) AND updated > -5m", "maxResults": 100 }'
RESP=$(curl --location "$JIRA_BASE_URL/rest/api/3/search/jql" \
  --header "$AUTH_HEADER" --header $CT_HEADER --header $AC_HEADER \
  --data "$BODY")
echo "$RESP" | jq -r '.issues[].id'
NEXT=$(echo "$RESP" | jq -r '.nextPageToken // empty')
while [ -n "$NEXT" ]; do
  BODY_NEXT=$(jq -n --arg jql "project in (FOO, BAR) AND updated > -5m" --arg t "$NEXT" '{jql: $jql, maxResults:100, nextPageToken:$t}')
  RESP=$(curl --location "$JIRA_BASE_URL/rest/api/3/search/jql" \
    --header "$AUTH_HEADER" --header $CT_HEADER --header $AC_HEADER \
    --data "$BODY_NEXT")
  echo "$RESP" | jq -r '.issues[].id'
  NEXT=$(echo "$RESP" | jq -r '.nextPageToken // empty')
done
```

#### Bulk fetch fields for known IDs or keys

```sh
curl --location "$JIRA_BASE_URL/rest/api/latest/issue/bulkfetch" \
  --header "$AUTH_HEADER" --header $CT_HEADER --header $AC_HEADER \
  --data '{
    "issueIdsOrKeys": ["FOO-1", "10067", "BAR-1"],
    "fields": ["priority", "status", "summary"]
  }' | jq .
```

#### Evaluate expression with JQL context and paginate via nextPageToken

```sh
FIRST='{
  "context": {"issues": {"jql": {"maxResults": 5, "query": "summary ~ \"task\" AND updated > -5m"}}},
  "expression": "issues.map(i => i.summary)"
}'
RESP=$(curl --request POST "$JIRA_BASE_URL/rest/api/3/expression/evaluate" \
  --header "$AUTH_HEADER" --header $CT_HEADER --header $AC_HEADER \
  --data "$FIRST")
echo "$RESP" | jq -r '.value[]'
NEXT=$(echo "$RESP" | jq -r '.meta.issues.jql.nextPageToken // empty')
while [ -n "$NEXT" ]; do
  BODY=$(jq -n --arg t "$NEXT" '{
    context: { issues: { jql: { maxResults: 5, query: "summary ~ \"task\" AND updated > -5m", nextPageToken: $t } } },
    expression: "issues.map(i => i.summary)"
  }')
  RESP=$(curl --request POST "$JIRA_BASE_URL/rest/api/3/expression/evaluate" \
    --header "$AUTH_HEADER" --header $CT_HEADER --header $AC_HEADER \
    --data "$BODY")
  echo "$RESP" | jq -r '.value[]'
  NEXT=$(echo "$RESP" | jq -r '.meta.issues.jql.nextPageToken // empty')
done
```

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
- `-q` – JQL query (bound queries only; avoid unbounded searches)
- `--created`, `--updated` – time filters

## Scripting Example

Count tickets per day this month (bounded):

```sh
jira issue list --plain --columns created --no-headers -q "project = FOO AND created >= startOfMonth()" | \
  awk '{print $2}' | awk -F'-' '{print $3}' | sort -n | uniq -c
```

For large result sets, prefer the two-step API pattern (IDs via `/search/jql` then fields via `/issue/bulkfetch`).

## Tips

- Use `jira completion --help` for shell completion.
- Use `jira --help` or `jira <command> --help` for more info.

Migration references:

- Atlassian deprecation announcement and migration guide (search JQL and expression evaluate). See Atlassian public docs.
- Jira CLI: ankitpokhrel/jira-cli – keep the tool updated to the latest release for best compatibility.

---
For full docs: [ankitpokhrel/jira-cli](https://github.com/ankitpokhrel/jira-cli)
