#!/bin/bash

# Usage: ./mr-subagents.sh "Paste JIRA Acceptance Criteria here"

JIRA_AC="$1"
DIFF_FILE=".cursor/temp_diff.txt"
OUTPUT_DIR=".cursor/reviews"

# 1. Setup: Create temp directories and get the diff
mkdir -p $OUTPUT_DIR
echo "📝 Generating git diff..."
git diff origin/develop...HEAD > $DIFF_FILE

if [ ! -s $DIFF_FILE ]; then
    echo "No diff found. Exiting."
    exit 0
fi

# Generate list of changed files for scoping
FILES_LIST=".cursor/temp_changed_files.txt"
git diff --name-only origin/develop...HEAD > $FILES_LIST
echo "📄 Changed files:"
cat $FILES_LIST

# Strict scope: AC agent only looks at the diff, nothing else
STRICT_SCOPE="IMPORTANT: You must ONLY analyze the code changes shown in the diff file, like a human doing a code review with the diffs. \
Do NOT search the codebase for additional files. Do NOT reference or review any files that are not listed in $FILES_LIST. \
The changed files are: $(cat $FILES_LIST | tr '\n' ', ')"

# Diff scope: sub-agents may read surrounding files for context but only report on diff changes
DIFF_SCOPE="SCOPE RULES: Your review MUST only report issues in the code changes shown in the diff. \
You SHOULD read parent components, sibling files, or hook/utility files - WHEN RELEVANT - to understand how the changed code fits into the broader architecture. \
Do NOT report issues in unchanged files. If context from a surrounding file reveals that a change in the diff is incorrect, report it against the diff code. \
The changed files are: $(cat $FILES_LIST | tr '\n' ', ')"

echo "🚀 Starting The Main Agent: JIRA Acceptance Criteria Review..."

# 2. Main Agent (Blocking) - Checks JIRA AC
cursor-agent -p --force "$STRICT_SCOPE Read the code changes in the diff file at $DIFF_FILE. \
Compare them strictly against the JIRA Acceptance Criteria: \"$JIRA_AC\" - IF PROVIDED. \
Determine if the code satisfies the requirements. Give a bullet point breakdown of what passes \
and what fails. Write this to $OUTPUT_DIR/00_ac_check.md"

echo "✅ Main Agent finished. Spawning Sub-Agents..."

# 3. Sub-Agents (Parallel) - The "&" puts them in background

# React Best Practices
cursor-agent -p --force "$DIFF_SCOPE Read .cursor/rules/project-constraints.mdc for project conventions. \
If there are React files (.tsx) in the diff, review the Added Code in $DIFF_FILE for React Best Practices. \
Check for: hooks rules, component decomposition, \
prop drilling, effect dependencies (empty [] for mount-only, useCallback for function deps), \
is state in best place (could performance be improved if state lifted, for example), memoization \ 
(try composition first per Dan Abramov - Move State Down or Lift Content Up), key props in lists. \
Write findings in bullet points and with short sentences to $OUTPUT_DIR/01_react.md" &
echo "✅ Spawned React..."
sleep 0.5

# Unit Test Best Practices
cursor-agent -p --force "$DIFF_SCOPE Read .cursor/rules/project-constraints.mdc and docs/testing/apollo-graphql/README.md for project conventions. \
If there are Unit Test files (.test.tsx, .test.ts) in the diff, review the Added Code in $DIFF_FILE for Unit Testing Best Practices. \
Check for: test isolation, meaningful assertions, use generateFakeData/fakeOperation/AutoFakeApollo for mocking (not manual mocks), \
no implementation-detail testing, coverage of logic branches. \
Read the logic of all the tests in a file against any new additions and ensure the test file as a whole \
makes sense and does not have duplication. \
Ensure there are no duplicate tests for the same logic in parents or siblings. \
Write findings in bullet points and with short sentences to $OUTPUT_DIR/03_unit_tests.md" &
echo "✅ Spawned Unit Tests..."
sleep 0.5

# Cypress Component Test Best Practices
cursor-agent -p --force "$DIFF_SCOPE Read .cursor/rules/project-constraints.mdc and docs/testing/component-testing/README.md for project conventions. \
If there are Cypress files (.feature, cypress/**/*.js) in the diff, review $DIFF_FILE for Cypress Component Testing Best Practices. \
Check for: Gherkin feature structure, scoped vs shared step definitions, api.graphql.mock() usage, declarative language. \
Write findings in bullet points and with short sentences to $OUTPUT_DIR/04_cypress.md" &
echo "✅ Spawned Cypress..."
sleep 0.5

# Apollo GraphQL Best Practices
cursor-agent -p --force "$DIFF_SCOPE Read .cursor/rules/project-constraints.mdc for project conventions. \
If there are files using Apollo hooks (useQuery, useMutation, useLazyQuery) or GraphQL files (.graphql) in the diff, \
review the Added Code in $DIFF_FILE for Apollo GraphQL Best Practices. \
Check for: error handling with useErrorHandlers, cache update patterns, query/mutation separation, \
proper loading/error state handling, use useNotify() for user-facing errors. \
Write findings in bullet points and with short sentences to $OUTPUT_DIR/05_apollo.md" &
echo "✅ Spawned Apollo GraphQL..."
sleep 0.5

# Refactor agent (broad scope - reads beyond the diff to understand architecture)
cursor-agent -p --force "make yourself a ToDo List:
1. Review the files in $FILES_LIST and then read any related files such as parents that render these files, shared components, shared utilities, hooks, etc. \
2. Give yourself all the context you need to understand how the files in $FILES_LIST work together. \
3. Draw a mermaid diagram of the architecture and how the files in $FILES_LIST fit into it and add to $OUTPUT_DIR/architecture.md. \
4. Review how the added Code in $DIFF_FILE could be refactored for \
a) any React files (.tsx); check the architecture for best system design patterns \
e.g. Design Patterns: HOC Pattern; Hooks Pattern; Compound Pattern; Container/Presentational Pattern; Render Props Pattern; AI UI Patterns; React Stack Patterns; and more... \
5. Check any test files similarly, e.g. do test files of parents duplicate the testing logic that is unit tested better lower down? \
Do parent files test logic that should be a component test in cypress? \
Write findings in bullet points and with short sentences to $OUTPUT_DIR/refactor_review.md" &
echo "✅ Spawned Refactor review..."
sleep 0.5

# 4. Synchronization
echo "⏳ Waiting for all sub-agents to report back..."
wait
echo "📦 All sub-agents finished."

# 5. Validator Agent (Blocking) - Filters noise before summarizing
echo "🔍 Running Validator to filter noise..."
cursor-agent -p --force "You are a Validator. Read all .md files in $OUTPUT_DIR \
(except 00_ac_check.md and architecture.md). Compare each finding against the $DIFF_FILE. For each finding, classify it as: \
- ACTIONABLE: Specific to the actual code changes, with a clear fix or improvement. \
- NOISE: Generic advice that could apply to any codebase, stylistic preference, or a finding without a specific code reference. \
Write only ACTIONABLE findings to $OUTPUT_DIR/validated_findings.md, \
preserving which agent raised each finding. Write NOISE findings to $OUTPUT_DIR/noisy_findings.md."
echo "✅ Validator finished."

# 6. Final Agent (Summarizer)
echo "📝 Summarizing validated findings..."
cursor-agent -p --force "You are the Lead Reviewer. Read these files: \
$OUTPUT_DIR/validated_findings.md and $OUTPUT_DIR/00_ac_check.md \
Summarize the validated findings into a single, prioritized list of action items. \
Group them by 'Critical', 'Major', and 'Minor'. \
Each finding must have a numbered ID with agent prefix: [R-01] for React, [UT-01] for Unit Tests, \
[CY-01] for Cypress, [AP-01] for Apollo, [RF-01] for Refactor. \
Each finding must have a [ ] checkbox for resolution tracking. \
Every finding must reference a specific file and code pattern from the diff. Discard any that don't. \
Highlight if any issues could be solved by ESLint rules and fixes. If yes, suggest the lint rule and fix. \
Output the final report to FINAL_CODE_REVIEW.md in $OUTPUT_DIR and output a list of the eslint rules that could \
be added to the .eslintrc.js file to prevent similar issues in future code reviews to SUGGESTED_ESLINT_RULES.md \
in $OUTPUT_DIR."

# 7. Delete temp files
rm -rf $DIFF_FILE $FILES_LIST
echo "✅ Deleted temp files."

echo "🎉 Done! Check FINAL_CODE_REVIEW.md for your report."
