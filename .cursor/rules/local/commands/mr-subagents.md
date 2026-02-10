---
alwaysApply: false
description: pre-MR review from sub-agents
---

## Agent Swarm Review Rule

When I ask to "run a review before opening MR" or "deep review this MR":

1.  **Context Gathering**: If I give you the JIRA ticket number, check if the the JIRA CLI is available (check for cli/jira.md) to fetch the description and acceptance criteria (AC). If Jira CLI isn't installed or I don't give you a ticket number, then ask me to either copy/paste the JIRA ticket description and AC, or say that you can continue without it should I not have the info to hand.
2.  **Execution**: Execute the shell script `.cursor/commands/mr-subagents.sh` passing the Jira description and/or AC as the first argument (if Jira info is available from step 1).
3.  **Observation**: Monitor the terminal output.
4.  **Presentation**: Once the script creates `FINAL_CODE_REVIEW.md`, open that file automatically in the editor and ask if I want to apply the "Critical" fixes immediately.
---
alwaysApply: false
description: pre-MR review from sub-agents
---

## Agent Swarm Review Rule

When I ask to "run a review before opening MR" or "deep review this MR":

1.  **Context Gathering**: If I give you the JIRA ticket number, check if the the JIRA CLI is available (check for cli/jira.md) to fetch the description and acceptance criteria (AC). If Jira CLI isn't installed or I don't give you a ticket number, then ask me to either copy/paste the JIRA ticket description and AC, or say that you can continue without it should I not have the info to hand.
2.  **Execution**: Execute the shell script `.cursor/commands/mr-subagents.sh` passing the Jira description and/or AC as the first argument (if Jira info is available from step 1).
3.  **Observation**: Monitor the terminal output.
4.  **Presentation**: Once the script creates `FINAL_CODE_REVIEW.md`, open that file automatically in the editor and ask if I want to apply the "Critical" fixes immediately.
