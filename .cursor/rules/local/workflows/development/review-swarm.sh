#!/bin/bash

# Usage: ./review_swarm.sh "Paste JIRA Acceptance Criteria here"

JIRA_AC="$1"
DIFF_FILE=".cursor/temp_diff.txt"
OUTPUT_DIR=".cursor/reviews"

# 1. Setup: Create temp directories and get the diff
mkdir -p $OUTPUT_DIR
echo "📝 Generating git diff..."
git diff origin/develop > $DIFF_FILE

if [ ! -s $DIFF_FILE ]; then
    echo "No diff found. Exiting."
    exit 0
fi

# Generate list of changed files for strict scoping
FILES_LIST=".cursor/temp_changed_files.txt"
git diff --name-only origin/develop > $FILES_LIST
echo "📄 Changed files:"
cat $FILES_LIST

# Instruction to restrict agents to diff only
STRICT_SCOPE="IMPORTANT: You must ONLY analyze the code changes shown in the diff file, like a human doing a code review with the diffs. \ 
Do NOT search the codebase for additional files. Do NOT reference or review any files that are not listed in $FILES_LIST. \ 
The changed files are: $(cat $FILES_LIST | tr '\n' ', ')"

echo "🚀 Starting The Main Agent: JIRA Acceptance Criteria Review..."

# 2. Main Agent (Blocking) - Checks JIRA AC
cursor-agent -p --force "$STRICT_SCOPE Read the code changes in the diff file at $DIFF_FILE. \
Compare them strictly against the JIRA Acceptance Criteria: \"$JIRA_AC\" - IF PROVIDED. \
Determine if the code satisfies the requirements. Give a bullet point breakdown of what passes \
and what fails. Write this to $OUTPUT_DIR/00_ac_check.md"

echo "✅ Main Agent finished. Spawning Sub-Agent Swarm..."

# 3. Sub-Agents (Parallel) - The "&" puts them in background
# Instruction files
REACT_INSTRUCTIONS=".cursor/workflows/development/test_agents/react.md"
UNIT_TEST_INSTRUCTIONS=".cursor/workflows/development/test_agents/unit-testing.md"
CYPRESS_INSTRUCTIONS=".cursor/workflows/development/test_agents/cypress.md"
APOLLO_INSTRUCTIONS=".cursor/workflows/development/test_agents/apollo-graphql.md"
CLEAN_CODE_INSTRUCTIONS=".cursor/workflows/development/test_agents/clean-code.md"

# React Best Practices
cursor-agent -p --force "$STRICT_SCOPE If there are React files (.tsx) in the diff, \
review the Added Code in $DIFF_FILE for React Best Practices. \
Use the review guide at $REACT_INSTRUCTIONS. \
Write findings in bullet points and with short sentences to $OUTPUT_DIR/01_react.md" &
echo "✅ Spawned React..."
sleep 0.5

# TypeScript Best Practices
cursor-agent -p --force "$STRICT_SCOPE Review the Added Code in the diff file $DIFF_FILE \
solely for TypeScript Best Practices (e.g Strict typing, avoidance of any, interface segregation). \
Write findings in bullet points and with short sentences to $OUTPUT_DIR/02_ts.md" &
echo "✅ Spawned TypeScript..."
sleep 0.5

# Unit Test Best Practices
cursor-agent -p --force "$STRICT_SCOPE If there are Unit Test files (.test.tsx, .test.ts) in the diff, \
review the Added Code in $DIFF_FILE for Unit Testing Best Practices. \
Use the review guide at $UNIT_TEST_INSTRUCTIONS. \
Read the logic of all the tests in a file against any new additions and ensure the test file as a whole \
makes sense and does not have duplication. \
Write findings in bullet points and with short sentences to $OUTPUT_DIR/03_unit_tests.md" &
echo "✅ Spawned Unit Tests..."
sleep 0.5

# Cypress Component Test Best Practices
cursor-agent -p --force "$STRICT_SCOPE If there are Cypress files (.feature, cypress/**/*.js) in the diff, \
review $DIFF_FILE for Cypress Component Testing Best Practices. \
Use the review guide at $CYPRESS_INSTRUCTIONS. \
Write findings in bullet points and with short sentences to $OUTPUT_DIR/04_cypress.md" &
echo "✅ Spawned Cypress..."
sleep 0.5

# Apollo GraphQL Best Practices
cursor-agent -p --force "$STRICT_SCOPE If there are files using Apollo hooks (useQuery, useMutation, useLazyQuery) \
or GraphQL files (.graphql) in the diff, review the Added Code in $DIFF_FILE for Apollo GraphQL Best Practices. \
Use the review guide at $APOLLO_INSTRUCTIONS. \
Write findings in bullet points and with short sentences to $OUTPUT_DIR/05_apollo.md" &
echo "✅ Spawned Apollo GraphQL..."
sleep 0.5

# Uncle Bob's Clean Code
cursor-agent -p --force "$STRICT_SCOPE Review the Added Code in $DIFF_FILE for 'Clean Code' principles by Uncle Bob. \
Use the review guide at $CLEAN_CODE_INSTRUCTIONS. \
Flag any TODO comments - existing or added. \
Write findings in bullet points and with short sentences to $OUTPUT_DIR/06_clean_code.md" &
echo "✅ Spawned Clean Code..."
sleep 0.5

# Accessibility Best Practices - A11y
cursor-agent -p --force "$STRICT_SCOPE Review the Added Code in $DIFF_FILE solely for 'a11y' principles \
(e.g. accessibility attributes, data-gtm-id, aria-label, role, etc.). \
Write findings in bullet points and with short sentences to $OUTPUT_DIR/07_a11y.md" &
echo "✅ Spawned Accessibility..."
sleep 0.5

# Security Best Practices
cursor-agent -p --force "$STRICT_SCOPE Review the Added Code in $DIFF_FILE solely for 'security' principles \
(e.g. data sanitization, input validation, error handling, tabnabbing, injection attacks, etc.). \
Remember that we work on an internal app for 1,500 internal users. \
Write findings in bullet points and with short sentences to $OUTPUT_DIR/08_security.md" &
echo "✅ Spawned Security..."
sleep 0.5

# Performance Best Practices
cursor-agent -p --force "$STRICT_SCOPE Review the Added Code in $DIFF_FILE solely for 'performance' principles \
(e.g. lazy loading, code splitting, image optimization, debouncing, throttling, etc.). \
Write findings in bullet points and with short sentences to $OUTPUT_DIR/09_performance.md" &
echo "✅ Spawned Performance..."
sleep 0.5

# Refactor agent
cursor-agent -p --force "Review the files in $FILES_LIST and then read any related files such as parents that render these files. \
Give yourself all the context you need to understand how the files in $FILES_LIST work together.\
Then review how the added Code in $DIFF_FILE could be refactored for a) any React files (.tsx); check the architecture for best system design patterns. \
Then b) check any test files similarly e.g. do test files of parents duplicate the testing logic that is \
unit tested better lower down? Do parent files test logic that should be a component test in cypress? \
Write findings in bullet points and with short sentences to $OUTPUT_DIR/refactor_review.md" &
echo "✅ Spawned Refactor review..."
sleep 0.5

# 4. Synchronization
echo "⏳ Waiting for all sub-agents to report back..."
wait
echo "📦 All sub-agents finished. Aggregating reports..."

# 5. Final Agent (Summarizer)
cursor-agent -p --force "You are the Lead Reviewer. Read all markdown files located in directory $OUTPUT_DIR. \
Summarize the findings into a single, prioritized list of action items. Group them by 'Critical', 'Major', \
and 'Minor'. Ignore files that say 'No issues found'. \
Highlight if any of the issues could be solved by es lint rules and fixes. If yes, suggest the lint rule and fix. \
Output the final report to FINAL_CODE_REVIEW.md in $OUTPUT_DIR and output a list of the eslint rules that could \
be added to the .eslintrc.js file to prevent similar issues in future code reviews to SUGGESTED_ESLINT_RULES.md \
in $OUTPUT_DIR."

# 6. Delete temp files
rm -rf $DIFF_FILE $FILES_LIST
echo "✅ Deleted temp files."

echo "🎉 Done! Check FINAL_CODE_REVIEW.md for your report."
