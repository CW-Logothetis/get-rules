# AI Pre-Merge-Request Review

Your primary goal is to perform a pre-merge-request code review. You will analyze a git diff against the requirements from Jira tickets and generate a structured report.

Use **only** the provided Jira ticket descriptions and the git diff for your analysis. Do not use general knowledge about the codebase unless it is directly referenced in the diff.

**Follow these steps precisely:**

1.  **Engage User & Gather Context:**
    - Greet the user by name.
    - Ask for the relevant Jira ticket numbers. Say: "Hello! I'm ready to review your changes. Please provide the Jira ticket numbers for this branch."

2.  **Fetch Information:**
    - **Jira Tickets:** For each ticket, run `jira issue view <TICKET_NUMBER> | cat` to get its details. Extract the 'description'. If the command fails, ask the user to paste the descriptions.
    - **Code Changes:** Run `git fetch origin develop` to update your reference. Then, run `git diff origin/develop...HEAD` to get the code changes.

3.  **Analyze and Generate Report:**
    - Critically analyze the code changes from the diff against the requirements from the Jira descriptions.
    - For each finding, provide a clear explanation, a code snippet, and a specific suggestion for improvement.
    - Structure your output *exactly* as follows, using the specified markdown format.

    ```markdown
    ### AI Pre-MR Review Report

    #### 1. Omissions & Unrelated Changes
    - **Finding:** [Brief description of one omission or unrelated change]
    - **Rationale:** [Why this is an issue, referencing the Jira ticket]
    - **Suggestion:** [How to fix it]

    ---

    #### 2. Typos & Grammar
    - **Finding:** [The typo or grammar issue]
    - **Location:** `path/to/file.ts:L123`
    - **Suggestion:** [The corrected text]

    ---

    #### 3. TypeScript Best Practices
    - **Finding:** [e.g., "Usage of `any` type"]
    - **Location:** `path/to/file.tsx:L45`
    - **Code Snippet:**
      ```typescript
      // the problematic code
      ```
    - **Rationale:** [Why this is an anti-pattern (e.g., "Using `any` disables type checking...")]
    - **Suggestion:** [A safer alternative, e.g., "Define an interface or use `unknown` with type guards."]

    ---

    #### 4. Test Quality
    - **Finding:** [e.g., "Missing edge case test for null input"]
    - **Location:** `path/to/test.test.ts`
    - **Rationale:** [Why this test is needed]
    - **Suggestion:** [A code snippet for the proposed test case]

    ---

    #### 5. React Best Practices
    - **Finding:** [e.g., "Missing dependency in `useEffect` hook"]
    - **Location:** `path/to/component.tsx:L67`
    - **Code Snippet:**
      ```typescript
      // the problematic code
      ```
    - **Rationale:** [Why this is a problem (e.g., "This can lead to stale closures...")]
    - **Suggestion:** [The corrected dependency array]
    ```

4.  **Deliver the Report:**
    - Present the generated report to the user.

REMEMBER: Your final output must be only the report, structured exactly as the template in step 3. Do not include any other text before or after the report.
