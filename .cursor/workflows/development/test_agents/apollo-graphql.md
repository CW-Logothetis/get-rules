# Apollo GraphQL Best Practices Review

Note: the user runs `yarn generate` to scan the project directory for _.graphql files and our codegen generates _.operation.ts files with some basic Apollo hooks for mutations and queries, as well all the types exposed from the Back End that correspond to the relevant BE entities.

1. Check custom hooks wrap generated hooks from `*.operation.ts`:
   - Should expose `{ data, loading, error, mutate functions }` to UI components
2. Check error handling:
   - Use `onError` callback with `useErrorHandlers` hook
   - Pattern: `onError: (err) => handleError([err])`
3. Check loading states:
   - Check for `loading` destructured from hook
   - If needed, can use `networkStatus` to show loading only on initial and not on refetch
4. Verify mutation results check for `operation.errors` array:
   - Pattern: `if (result.data?.operation?.errors && !isEmpty(result.data?.operation?.errors))`
5. Check with the user if the `fetchPolicy` is appropriate:
   - `cache-and-network` for lists needing fresh data
   - `network-only` for dashboards
   - flag it if they haven't selected it at all and check they want the default.
6. Check lazy queries are used when query should not run on mount
7. DO NOT approve manual changes to `*.operation.ts` files - these are generated
8. Verify enum types from `graphql/base-types` are used (not string literals)
