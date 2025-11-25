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

echo "🚀 Starting The Main Agent: JIRA Acceptance Criteria Review..."

# 2. Main Agent (Blocking) - Checks JIRA AC
cursor-agent -p --force "Read the code changes in $DIFF_FILE. Compare them strictly against these JIRA Acceptance Criteria: \"$JIRA_AC\". Determine if the code satisfies the requirements. Write a detailed breakdown of what passes and what fails. Write this to $OUTPUT_DIR/00_ac_check.md"

echo "✅ Main Agent finished. Spawning Sub-Agent Swarm..."

# 3. Sub-Agents (Parallel) - The "&" puts them in background
# React Best Practices
cursor-agent -p --force "If there are React files in the diff, review the Added Code in $DIFF_FILE solely for React Best Practices (e.g. Hooks rules, composition, re-renders, state management). Write findings to $OUTPUT_DIR/01_react.md" &
echo "✅ Spawned React..."

# TypeScript Best Practices
cursor-agent -p --force "Review $DIFF_FILE solely for TypeScript Best Practices (e.g Strict typing, avoidance of any, interface segregation). Write findings to $OUTPUT_DIR/02_ts.md" &
echo "✅ Spawned TypeScript..."

# Unit Test Best Practices
cursor-agent -p --force "If there are Unit Test files in the diff, review the Added Code in $DIFF_FILE solely for Unit Testing Best Practices (Jest, React Testing Library, Kent C. Dodds philosophy for testing, coverage, mocking logic, assertions). Write findings to $OUTPUT_DIR/03_unit_tests.md" &
echo "✅ Spawned Unit Tests..."

# Cypress Component Test Best Practices
cursor-agent -p --force "If there are Cypress files in the diff, review $DIFF_FILE solely for Cypress Component Testing Best Practices (Selectors, interception, mounting). Write findings to $OUTPUT_DIR/04_cypress.md" &
echo "✅ Spawned Cypress..."

# Uncle Bob's Clean Code
cursor-agent -p --force "Review the Added Code in $DIFF_FILE solely for 'Clean Code' principles by Uncle Bob (e.g Function size, naming conventions, structure and abstraction, clarity and intent, dependencies and coupling, SOLID principles, comments). Write findings to $OUTPUT_DIR/05_clean_code.md" &
echo "✅ Spawned Clean Code..."

# Accessibility Best Practices - A11y
cursor-agent -p --force "Review the Added Code in $DIFF_FILE solely for 'a11y' principles (e.g. accessibility attributes, data-gtm-id, aria-label, role, etc.). Write findings to $OUTPUT_DIR/06_a11y.md" &
echo "✅ Spawned Accessibility..."

# Security Best Practices
cursor-agent -p --force "Review the Added Code in $DIFF_FILE solely for 'security' principles (e.g. data sanitization, input validation, error handling, tabnabbing, injection attacks, etc.). Remember that we work on an internal app for 1,500 internal users. Write findings to $OUTPUT_DIR/07_security.md" &
echo "✅ Spawned Security..."

# Performance Best Practices
cursor-agent -p --force "Review the Added Code in $DIFF_FILE solely for 'performance' principles (e.g. lazy loading, code splitting, image optimization, debouncing, throttling, etc.). Write findings to $OUTPUT_DIR/08_performance.md" &
echo "✅ Spawned Performance..."

# 4. Synchronization
echo "⏳ Waiting for all sub-agents to report back..."
wait
echo "📦 All sub-agents finished. Aggregating reports..."

# 5. Final Agent (Summarizer)
cursor-agent -p --force "You are the Lead Reviewer. Read all markdown files located in directory $OUTPUT_DIR. Summarize the findings into a single, prioritized list of action items. Group them by 'Critical', 'Major', and 'Minor'. Ignore files that say 'No issues found'. Highlight if any of the issues could be solved by es lint rules and fixes. If yes, suggest the lint rule and fix. Output the final report to FINAL_CODE_REVIEW.md"

echo "🎉 Done! Check FINAL_CODE_REVIEW.md for your report."
