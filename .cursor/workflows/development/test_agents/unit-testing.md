# Unit Testing Best Practices Review

1. Verify `createRender` utility is used for provider wrapping:
   - Pattern: `const render = createRender(['Theme', 'Redux', 'Apollo'])`
2. Check test descriptions start with verbs (NOT "should"):
   - Good: `it('renders the correct label')`
   - Bad: `it('should render the correct label')`
3. Verify accessible selectors are used (Kent C. Dodds priority):
   - Prefer: `getByRole`, `getByLabelText`, `getByText`
   - Use `data-testid` only as last resort
4. Check jest.mock pattern uses import, NOT require:
   - Pattern: `jest.mock('path', () => ({ hook: jest.fn() }))`
   - Then: `(hook as jest.Mock).mockReturnValue({...})`
5. Verify NO `require()` statements in test files
6. Check mock implementations are simple return values (no React hooks in mocks)
7. Ensure `waitFor` is used for async assertions
8. Verify regex patterns used for text matching: `toHaveTextContent(/text/i)`
9. Check `.not.toBeInTheDocument()` used over `.toBeNull()`
10. Verify tests import from `__test-utils__` (not direct RTL imports)
11. Check `AutoFakeApollo` mockResolvers are async and in `beforeAll`/`beforeEach`
12. Verify NOT using both `AutoFakeApollo` in createRender AND MockedProvider in test
