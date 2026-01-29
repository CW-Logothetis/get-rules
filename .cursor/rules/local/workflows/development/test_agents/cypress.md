# Cypress Component Testing Best Practices Review

## Feature files

1. Verify feature files use Gherkin syntax: `Feature:`, `Background:`, `Scenario:`
2. Check scenarios are tagged with JIRA tickets: `@mav-XXXXX`
3. Verify step definitions are declarative (what), not imperative (how)
4. Check `Given`, `When`, `Then` order is correct
5. Check scenarios test ONE behavior each
6. Check for happy path AND error state coverage

## Step definitions

7. Verify Page Object Model is used:
   - Import from `@pages/...`
   - No direct `cy.get()` selectors in step definitions
8. Check GraphQL mocking uses `api.graphql.mock()`:
   - Pattern: `api.graphql.mock('OperationName', (req) => { req.reply({...}); })`
9. Verify fixtures are loaded before use:
   - Pattern: `cy.fixture('path/to/fixture.json').then((data) => {...})`
10. Check permission mocking uses `api.auth.setPermissionAllowed()`
11. Verify shared steps in `cypress/support/step_definitions/`are used where possible
12. Check scoped steps are sibling `.js` files to `.feature` files

## Page objects

13. Verify page objects encapsulate selectors and actions
14. Check methods are named descriptively:
    - `visit()` - navigation
    - `assertXxxVisible()` - assertions
    - `clickXxx()`, `fillInXxx()` - interactions
15. Verify selectors prefer text content over attributes:
    - Good: `cy.contains(/create new/i).click()`
16. Verify use of shared config and that constructor accepts configuration where needed
    - e.g. constructor({ projectId } = {}) for shared project IDs
