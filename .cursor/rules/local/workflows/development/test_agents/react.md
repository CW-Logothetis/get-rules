# React Best Practices Review

1. Verify functional components use `React.FC<Props>` pattern with typed props
2. Check that Props interfaces are:
   - Defined in separate `.types.tsx` files for complex components (preferred)
   - Use descriptive names: `ComponentNameProps`
   - Include JSDoc comments for non-obvious props
3. New components should use Smoothie (`@dev-team/smoothie-core`). Flag if they use direct MUI imports
4. Verify file structure: `ComponentName.tsx`, `.styles.tsx`, `.types.tsx`, `.test.tsx`
5. Check hooks are extracted to `hooks/` subfolders IF reusable
6. Verify imports use absolute paths from `src/` (no `src/` prefix, no `../../../`)
7. Ensure no default exports - use named exports only
8. Check component does one thing (Single Responsibility)
9. Presentational components shall be designed as pure functions of their props. They must not perform data fetching, manage global state (via Redux, Context, or complex local state/effects), or contain application-specific business logic. All such logic must reside within their parent Container components or encapsulated Custom Hooks.
10. Verify event handlers are typed: `React.MouseEvent<HTMLElement>`, etc.

## React Hooks

11. Verify `React.useEffect` dependency arrays are correct:

- Empty `[]` for mount-only effects
- Functions in deps must be wrapped in `useCallback`
- No object/array literals in deps

12. Check `useMemo`/`useCallback` are used only when necessary (not for simple calculations)
13. Verify custom hooks follow naming convention: `useCamelCase`
14. Ensure state is colocated - kept close to where it's used
15. Verify no prop drilling - use Context when passing props 3+ levels

## Styling React

16. Generally styles are applied through the `sx` prop. We have a custom helper function to create such style objects src/utils/makeSxStyles.ts
17. Margin padding: Use theme.spacing(0.25, 0.5,1,2,3,4,5,6…) (base size being 8px\*) for laying out components.18. Color: Use theme.palette for coloring elements.
18. All buttons should use sentence casing e.g. “Add new something“, “Submit“.
