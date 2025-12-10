#!/bin/bash

# Usage: ./review_swarm.sh "Paste JIRA Acceptance Criteria here"

JIRA_AC="$1"
DIFF_FILE=".cursor/temp_diff.txt"
OUTPUT_DIR=".cursor/reviews"

# 1. Setup: Create temp directories and get the diff
mkdir -p $OUTPUT_DIR
echo "📝 Generating git diff..."
git diff develop > $DIFF_FILE

if [ ! -s $DIFF_FILE ]; then
    echo "No diff found. Exiting."
    exit 0
fi

# Generate list of changed files for strict scoping
FILES_LIST=".cursor/temp_changed_files.txt"
git diff --name-only develop > $FILES_LIST
echo "📄 Changed files:"
cat $FILES_LIST

# Instruction to restrict agents to diff only
STRICT_SCOPE="IMPORTANT: You must ONLY analyze the code changes shown in the diff file. Do NOT search the codebase for additional files. Do NOT reference or review any files that are not listed in $FILES_LIST. The changed files are: $(cat $FILES_LIST | tr '\n' ', ')"

echo "🚀 Starting The Main Agent: JIRA Acceptance Criteria Review..."

# 2. Main Agent (Blocking) - Checks JIRA AC
cursor-agent -p --force "$STRICT_SCOPE Read the code changes in the diff file at $DIFF_FILE. Compare them strictly against the JIRA Acceptance Criteria: \"$JIRA_AC\" - IF PROVIDED. Determine if the code satisfies the requirements. Give a bullet point breakdown of what passes and what fails. Write this to $OUTPUT_DIR/00_ac_check.md"

echo "✅ Main Agent finished. Spawning Sub-Agent Swarm..."

# 3. Sub-Agents (Parallel) - The "&" puts them in background
# React Best Practices
cursor-agent -p --force "$STRICT_SCOPE If there are React files in the diff, review the Added Code in $DIFF_FILE solely for React Best Practices (e.g. Hooks rules, composition, re-renders, state management). Write findings in bullet points and with short sentences to $OUTPUT_DIR/01_react.md" &
echo "✅ Spawned React..."
sleep 0.5


# TypeScript Best Practices
cursor-agent -p --force "$STRICT_SCOPE Review the Added Code in the diff file $DIFF_FILE solely for TypeScript Best Practices (e.g Strict typing, avoidance of any, interface segregation). Write findings in bullet points and with short sentences to $OUTPUT_DIR/02_ts.md" &
echo "✅ Spawned TypeScript..."
sleep 0.5

# Unit Test Best Practices
cursor-agent -p --force "$STRICT_SCOPE If there are Unit Test files in the diff, review the Added Code in $DIFF_FILE solely for Unit Testing Best Practices (Jest, React Testing Library, Kent C. Dodds philosophy for testing, coverage, mocking logic, assertions). Read the logic of all the tests in a file against any new additions and ensure the test file as a whole makes sense and does not have duplication, which is a common occurance when engineers add new tests without reading the existing ones. Write findings in bullet points and with short sentences to $OUTPUT_DIR/03_unit_tests.md" &
echo "✅ Spawned Unit Tests..."
sleep 0.5

# Cypress Component Test Best Practices
cursor-agent -p --force "$STRICT_SCOPE If there are Cypress files in the diff, review $DIFF_FILE solely for Cypress Component Testing Best Practices (Selectors, interception, mounting). If there are no suitable selectors by role, name or label for a new element, check we added data-cy or data-testid. Write findings in bullet points and with short sentences to $OUTPUT_DIR/04_cypress.md" &
echo "✅ Spawned Cypress..."
sleep 0.5

# Uncle Bob's Clean Code
cursor-agent -p --force "$STRICT_SCOPE Review the Added Code in $DIFF_FILE solely for 'Clean Code' principles by Uncle Bob (e.g Function size, naming conventions, structure and abstraction, clarity and intent, dependencies and coupling, SOLID principles, comments). Flag any TODO comments - existing or added. Write findings in bullet points and with short sentences to $OUTPUT_DIR/05_clean_code.md" &
echo "✅ Spawned Clean Code..."
sleep 0.5

# Accessibility Best Practices - A11y
cursor-agent -p --force "$STRICT_SCOPE Review the Added Code in $DIFF_FILE solely for 'a11y' principles (e.g. accessibility attributes, data-gtm-id, aria-label, role, etc.). Write findings in bullet points and with short sentences to $OUTPUT_DIR/06_a11y.md" &
echo "✅ Spawned Accessibility..."
sleep 0.5

# Security Best Practices
cursor-agent -p --force "$STRICT_SCOPE Review the Added Code in $DIFF_FILE solely for 'security' principles (e.g. data sanitization, input validation, error handling, tabnabbing, injection attacks, etc.). Remember that we work on an internal app for 1,500 internal users. Write findings in bullet points and with short sentences to $OUTPUT_DIR/07_security.md" &
echo "✅ Spawned Security..."
sleep 0.5

# Performance Best Practices
cursor-agent -p --force "$STRICT_SCOPE Review the Added Code in $DIFF_FILE solely for 'performance' principles (e.g. lazy loading, code splitting, image optimization, debouncing, throttling, etc.). Write findings in bullet points and with short sentences to $OUTPUT_DIR/08_performance.md" &
echo "✅ Spawned Performance..."
sleep 0.5

# 4. Synchronization
echo "⏳ Waiting for all sub-agents to report back..."
wait
echo "📦 All sub-agents finished. Aggregating reports..."

# 5. Final Agent (Summarizer)
cursor-agent -p --force "You are the Lead Reviewer. Read all markdown files located in directory $OUTPUT_DIR. Summarize the findings into a single, prioritized list of action items. Group them by 'Critical', 'Major', and 'Minor'. Ignore files that say 'No issues found'. Highlight if any of the issues could be solved by es lint rules and fixes. If yes, suggest the lint rule and fix. Output the final report to FINAL_CODE_REVIEW.md in $OUTPUT_DIR and output a list of the eslint rules that could be added to the .eslintrc.js file to prevent similar issues in future code reviews to SUGGESTED_ESLINT_RULES.md in $OUTPUT_DIR."

# 6. Delete temp files
rm -rf $DIFF_FILE $FILES_LIST
echo "✅ Deleted temp files."

echo "🎉 Done! Check FINAL_CODE_REVIEW.md for your report."
