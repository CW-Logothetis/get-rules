---
alwaysApply: false
description: agent swarm MR
---

## Agent Swarm Review Rule

When I ask to "run a swarm review" or "deep review this MR":

1.  **Context Gathering**: If I give you the JIRA ticket number, use the JIRA CLI (see cli/jira.md) to get the description and acceptance criteria (AC). If Jira CLI isn't installed or I don't give you a ticket number, then ask me to either copy/paste the JIRA ticket description and AC, or say that you can continue without it should I not have the info to hand.
2.  **Execution**: Execute the shell script `.cursor/workflows/development/review-swarm.sh` passing the Jira description and/or AC as the first argument (if Jira info is available from step 1).
3.  **Observation**: Monitor the terminal output.
4.  **Presentation**: Once the script creates `FINAL_CODE_REVIEW.md`, open that file automatically in the editor and ask if I want to apply the "Critical" fixes immediately.

**Command Reference:**
To run manually via terminal: `.cursor/workflows/development/review-swarm.sh "JIRA AC text"`
