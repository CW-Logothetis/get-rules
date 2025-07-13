# Dynamic Merge Request Description Generator

This rule automates the drafting of a Merge Request description for a bug fix. It uses the current git diff to understand the changes and can optionally incorporate information from Jira tickets to provide context.

## Instructions for AI

When the user invokes this rule, follow these steps:

1.  **Get Git Context**
    Run `git diff develop...HEAD` to get the diff between the `develop` branch and the user's current local branch. This is your primary source for understanding the code changes.

2.  **Check for Jira Tickets (Optional)**
    Ask the user: "Please provide any relevant Jira tickets associated with this MR. If not, type 'no' and I'll continue without them." If they provide tickets, you will run the Jira CLI commands (see tools/cli/jira.md) and use this information to describe the bug. Otherwise, you will infer the bug's behavior from the git diff.

3.  **Analyze and Draft**
    -   Analyze the output from the `git diff`. Identify the core problem that was fixed and how the new code solves it.
    -   If Jira tickets were provided, use their titles, descriptions and comments for the "Bug Behavior" section.
    -   Fill out the template below. Prefer bullet points instead of sentences. Be concise and clear.

    **Template to Fill:**
    ````markdown
    ## Technical Description of Bug Behavior

    <!-- Analyze the "before" state from the git diff or use the Jira ticket description to explain what was happening. -->
    <!-- What actually happens -->
    <!-- Provide any relevant technical details, such as error messages or stack traces. -->

    ## Solution Provided

    <!-- Analyze the "after" state from the git diff to describe the fix. Explain the new logic or changes. -->
    ````

4.  **Create Architecture Diagram**
    -   Based on the file paths in the `git diff`, identify the key components that were changed and their relationships. Put the names on one line, then in parenthesis on a new line, describe the file in very few words.
    -   Create a Mermaid `graph TD` diagram to visualize these components.
    -   **Important Styling Rules:** Use the following styles for the diagram to ensure clarity and consistency in both light and dark modes:
        -   **All Nodes:** Use black backgrounds (`fill:#000000`), a `1px` border (`stroke-width:1px`), and rounded corners (`rx:5,ry:5`).
        -   **Unchanged Components:** Use white text (`color:#ffffff`) and a gray border (`stroke:#666666`).
        -   **Changed Components (from git diff):** Use light green text (`color:#90EE90`) and a light green border (`stroke:#90EE90`) to highlight them.
    -   Add the complete diagram markdown to the MR description under a `## Component Architecture Diagram` section.

5. **Add Mandatory sections**
    ```
    ## Screenshots

    <!-- Paste any relevant screenshots that demonstrate the bug behavior and/or the fixed behavior. -->

    ## Checklist:

    - [ ] I have performed a self-review of my code
    - [ ] I have provided JSDoc comments for all components to explain their purpose and usage
    - [ ] My changes generate no new warnings or errors in the console
    - [ ] New and existing unit tests written in Jest and end-to-end tests written in Cypress pass locally with my changes
    ```    

6.  **Present to User**
    Combine the filled-out template and the Mermaid diagram into a single markdown block and present it to the user.

Example:

## Technical Description of Bug Behavior

<!-- What actually happens -->
If Formers fail, the user is prevented from opening Customers when they click on the Customers tab.

- The fail is in the `expertFinderSearch` query, called in `ResultsArea`, and used for the company info in the Header. 
- The query only returned status information for Formers (pending, error, completed) but not for Customers. 
- The status determines if the `ResultsArea` routes to the Formers or Customers Lists. 
- When Formers failed, there was no independent status for Customers, so the routing logic couldn't determine if Customers were available, blocking access to the Customers tab.

## Solution Provided
- Updated the `expertFinderSearch.graphql` query to include a customers field that mirrors the existing formers field.
- Modified the `ResultsArea.tsx` component to:
  - Extract both `formersStatus` and `customersStatus` from the query response
  - Create a unified `ExpertFinderSearchStatus` object containing both statuses
  - Pass this to `ExpertsPanel` which uses `useExpertFinderQuerySelector` to determine the appropriate status based on the selected tab

The `ExpertList` component now checks `currentTabStatus` independently for each tab type:

```const currentTabStatus = isTypeFormers ? expertFinderSearchStatus?.formers : expertFinderSearchStatus?.customers;```

## Mermaid diagram
graph TD
    A["ExpertFinderTab<br/>(Main container)"] --> B["SearchTabs<br/>(Company accordion with Formers/Customers tabs)"]
    A --> C["ResultsArea<br/>(Main results display area)"]
    
    B --> B1["RoutableAccordion<br/>(Per company)"]
    B1 --> B2["Tab: Formers<br/>(Shows formers count/status)"]
    B1 --> B3["Tab: Customers<br/>(Shows customers count/status)"]
    
    C --> C1["ExpertFinderTabContext.Provider<br/>(Provides company context)"]
    C1 --> C2["SearchParamsProvider<br/>(URL search params)"]
    C2 --> C3["ExpertsPanel<br/>(Expert display logic)"]
    
    C3 --> D["HeaderWithLegend<br/>(Company info header)"]
    C3 --> E["ExpertList<br/>(Main expert list component)"]
    
    E --> F["Filters"]
    F --> F1["FormersFiltersContainer<br/>(When selectedTab = formers)"]
    F --> F2["CustomersFiltersContainer<br/>(When selectedTab = customers)"]
    
    E --> G["Expert Items"]
    G --> G1["FormersListItem<br/>(Individual former expert)"]
    G --> G2["CustomerListItem<br/>(Individual customer expert)"]
    
    E --> H["Messages"]
    H --> H1["ErrorMessage<br/>(When currentTabStatus = FAILED)"]
    H --> H2["NoExpertResultsMessage<br/>(When no results)"]
    H --> H3["Loading State<br/>(When currentTabStatus = PENDING)"]
    
    E --> I["Pagination<br/>(Results pagination)"]
    
    style A fill:#000000,stroke:#333333,color:#ffffff
    style B fill:#000000,stroke:#333333,color:#ffffff
    style C fill:#000000,stroke:#333333,color:#90EE90
    style D fill:#000000,stroke:#333333,color:#ffffff
    style E fill:#000000,stroke:#333333,color:#90EE90
    style F fill:#000000,stroke:#333333,color:#ffffff
    style G fill:#000000,stroke:#333333,color:#ffffff
    style H fill:#000000,stroke:#333333,color:#ffffff
    style I fill:#000000,stroke:#333333,color:#ffffff
    style B1 fill:#000000,stroke:#333333,color:#ffffff
    style B2 fill:#000000,stroke:#333333,color:#ffffff
    style B3 fill:#000000,stroke:#333333,color:#ffffff
    style C1 fill:#000000,stroke:#333333,color:#ffffff
    style C2 fill:#000000,stroke:#333333,color:#ffffff
    style C3 fill:#000000,stroke:#333333,color:#90EE90
    style F1 fill:#000000,stroke:#333333,color:#ffffff
    style F2 fill:#000000,stroke:#333333,color:#ffffff
    style G1 fill:#000000,stroke:#333333,color:#ffffff
    style G2 fill:#000000,stroke:#333333,color:#ffffff
    style H1 fill:#000000,stroke:#333333,color:#ffffff
    style H2 fill:#000000,stroke:#333333,color:#ffffff
    style H3 fill:#000000,stroke:#333333,color:#ffffff

## Screenshots

<!-- Paste any relevant screenshots that demonstrate the bug behavior and/or the fixed behavior. -->

## Checklist:

- [ ] I have performed a self-review of my code
- [ ] I have provided JSDoc comments for all components to explain their purpose and usage
- [ ] My changes generate no new warnings or errors in the console
- [ ] New and existing unit tests written in Jest and end-to-end tests written in Cypress pass locally with my changes
