---
alwaysApply: true
---

## **Clean Code Heuristics for JavaScript/TypeScript**

This document outlines key principles from Robert C. Martin's "Clean Code," with JavaScript/TypeScript examples, to guide code review and generation. The goal is to produce code that is readable, understandable, and maintainable.

### **Names**

-   **N1 - Choose Descriptive Names:** A name must be descriptive. This includes describing any side effects (**N7**).
    -   *Bad:* `getO(thing)`
    -   *Good:* `createAndSaveThing(thing)`
-   **N2 - Choose Names at the Appropriate Level of Abstraction:** Names should reflect the abstraction, not the implementation.
    -   *Bad:* `modem.dialString("5551212")` (Exposes implementation detail of a "dial string")
    -   *Good:* `modem.connectToNumber("5551212")` (Abstracts the action)
-   **N3 - Use Standard Nomenclature:** Leverage existing conventions (e.g., design patterns like `Factory`, `Observer`).
    -   *Bad:* `makeNewAccount()`
    -   *Good:* `AccountFactory.create()`
-   **N4 - Unambiguous Names:** Choose names that leave no doubt about their purpose.
    -   *Bad:* `doTask(list)` (What task?)
    -   *Good:* `filterActiveUsers(users)`
-   **N5 - Use Long Names for Long Scopes:** The longer a variable exists, the more descriptive its name should be.
    -   *Bad:* (in a long function) `for (let i = 0; i < r.length; i++)`
    -   *Good:* (in a long function) `for (const registration of registrations)`
-   **N6 - Avoid Encodings:** Don't add type or scope prefixes.
    -   *Bad:* `const strName = '';`, `this.m_customer;`
    -   *Good:* `const name = '';`, `this.customer;`

### **Functions**

-   **G30 - Functions Should Do One Thing:** Each function should have a single, focused responsibility.
    -   *Bad:* A function that validates user input, saves the user to the database, and sends a welcome email.
    -   *Good:* Three separate functions: `validateInput(input)`, `saveUser(user)`, `sendWelcomeEmail(user)`.
-   **G34 - Functions Should Descend Only One Level of Abstraction:** Code within a function should be at a consistent level of abstraction.
    -   *Bad:* A function mixing high-level logic with low-level string manipulation.
    -   *Good:* The function calls other, lower-level functions to handle the details.
-   **F1 - Too Many Arguments:** Aim for zero to three arguments.
    -   *Bad:* `createUser(username, password, email, age, address, phone)`
    -   *Good:* `createUser(userDetails)` where `userDetails` is an object.
-   **F2 - Output Arguments:** Avoid them. A function should change its own object's state or return a new value.
    -   *Bad:* `appendFooter(report)` (Modifies the passed-in object, which is counterintuitive).
    -   *Good:* `report.appendFooter()` (Method on the object itself) or `const newReport = appendFooter(report)` (Returns new instance).
-   **F3 - Flag Arguments:** Boolean arguments indicate a function does more than one thing.
    -   *Bad:* `render(isTestMode)`
    -   *Good:* Two functions: `renderForProduction()` and `renderForTest()`.
-   **G20 - Function Names Should Say What They Do:** The name should be self-explanatory.
    -   *Bad:* `process()`
    -   *Good:* `calculateMonthlyRevenue()`
-   **F4 - Dead Function:** Remove any method that is never called.

**REMEMBER: All examples should reflect JavaScript/TypeScript and React best practices.**

### **Comments**

-   **C3 - Redundant Comment:** A comment that explains something the code already says is clutter.
    -   *Bad:* `i++; // Increment i`
    -   *Good:* No comment needed.
-   **C1 - Inappropriate Information:** Use your version control system for history.
    -   *Bad:* `// 2024-01-10: Added by Bob to fix bug #123`
    -   *Good:* No comment. This info is in `git blame`.
-   **C2 - Obsolete Comment:** An inaccurate comment is worse than no comment. Always remove them.
-   **C5 - Commented-Out Code:** Just delete it. Git remembers.
    -   *Bad:* `// const oldCode = "old implementation";`
    -   *Good:* (The line is completely removed).

### **General Code Quality**

#### **Structure and Abstraction**

-   **G5 - Duplication (DRY):** Never repeat code.
    -   *Bad:* Having the same validation logic in two different functions.
    -   *Good:* Extracting the validation logic into a single, shared function or custom hook.
-   **G6 - Code at Wrong Level of Abstraction:** Higher-level concepts belong in base classes or interfaces.
    -   *Bad:* An `interface Vehicle` with a method `openGloveBox()`.
    -   *Good:* `openGloveBox()` belongs in a derivative class like `Car`.
-   **G7 - Base Classes Depending on Their Derivatives:** Base classes must not know about their children.
-   **G23 - Prefer Polymorphism to If/Else or Switch/Case:** Use objects or strategy patterns to handle different behaviors.
    -   *Bad:* `switch (animal.type) { case 'dog': bark(); break; case 'cat': meow(); break; }`
    -   *Good:* `animal.makeSound()` where `Dog` and `Cat` classes implement `makeSound()`.
-   **G18 - Inappropriate `static`:** Prefer instance methods for testability.
    -   *Bad:* `static validate(token)` (Hard to test or mock).
    -   *Good:* `authenticator.validate(token)` as a method on an `Authenticator` instance.
-   **G27 - Structure Over Convention:** Enforce rules with structure, not just naming.
    -   *Bad:* Naming a file `DO_NOT_MODIFY_config.js`.
    -   *Good:* Making the file read-only or using `Object.freeze()` to restrict access.

#### **Clarity and Intent**

-   **G16 - Obscured Intent:** Write clear and readable code.
    -   *Bad:* `const a = !b ? c : d;`
    -   *Good:* `const isPrimaryUser = user.isLoggedIn(); const profile = isPrimaryUser ? user.getProfile() : guest.getProfile();`
-   **G19 - Use Explanatory Variables:** Break down complex logic into well-named variables.
    -   *Bad:* `if (line.split(':')[0].trim() === "user" && line.split(':')[1].trim().length > 3)`
    -   *Good:* `const key = line.split(':')[0].trim(); const value = line.split(':')[1].trim(); if (key === "user" && value.length > 3)`
-   **G25 - Replace Magic Numbers:** Give numbers and strings a name.
    -   *Bad:* `if (user.role === 3)`
    -   *Good:* `const ADMIN_ROLE = 3; if (user.role === ADMIN_ROLE)`
-   **G28 - Encapsulate Conditionals:** Extract complex boolean logic into functions.
    -   *Bad:* `if (timer.hasExpired() && !timer.isRecurrent())`
    -   *Good:* `if (shouldBeDeleted(timer))` where `shouldBeDeleted` is a function containing the logic.
-   **G29 - Avoid Negative Conditionals:** Phrase conditions positively.
    -   *Bad:* `if (!buffer.isNotFull())`
    -   *Good:* `if (buffer.isFull())`

#### **Dependencies and Coupling**

-   **G14 - Feature Envy:** Methods should operate on their own class's data.
    -   *Bad:* A `SalesReport` component that frequently calls methods on the `User` object to format data.
    -   *Good:* Move the formatting logic into the `User` class itself, and have `SalesReport` just call `user.getFormattedDetails()`.
-   **G8 - Too Much Information:** Classes and components should have small, well-defined interfaces.
-   **G22 - Make Logical Dependencies Physical:** Explicitly ask for what you need.
    -   *Bad:* A function that relies on another module to have already set a global configuration variable.
    -   *Good:* The function accepts the configuration as a parameter or uses dependency injection.
-   **G36 - Avoid Transitive Navigation (Law of Demeter):** Don't chain calls through multiple objects.
    -   *Bad:* `user.getProfile().getAddress().getStreetName()`
    -   *Good:* `user.getStreetName()` (The `User` class handles the internal navigation).

### **React/Frontend Specific**

-   **Component Single Responsibility:** Each component should have one clear purpose.
    -   *Bad:* A `UserDashboard` component that handles authentication, data fetching, and rendering.
    -   *Good:* Separate components: `AuthProvider`, `UserDataLoader`, `UserDashboard`.
-   **Custom Hooks for Logic:** Extract stateful logic into custom hooks.
    -   *Bad:* Complex `useEffect` logic directly in components.
    -   *Good:* `const { data, loading, error } = useUserData(userId);`

### **Tests**

-   **T1 - Insufficient Tests:** Test everything that could possibly break.
-   **T2 - Use a Test Coverage Tool:** Use tools like `jest --coverage`, to find untested code.
-   **T3 - Don't Skip Trivial Tests:** They are easy to write and serve as documentation.
-   **T5 - Test Boundary Conditions:** Test for `null`, `undefined`, `0`, `-1`, empty strings, and max values.
-   **T6 - Exhaustively Test Near Bugs:** When a bug is found, write a test that specifically reproduces it, then write more tests around that area.
-   **T9 - Tests Should Be Fast:** Slow tests don't get run. Mock external services and APIs to keep tests fast.

### **Environment**

-   **E1 - Build Requires More Than One Step:** A build should be a single command.
    -   *Bad:* Requiring developers to run `clean`, then `fetch-deps`, then `compile`, then `package`.
    -   *Good:* A single script: `yarn build`.
-   **E2 - Tests Require More Than One Step:** Running all tests should be a single command.
    -   *Bad:* Requiring separate commands to run unit, integration, and end-to-end tests.
    -   *Good:* `yarn test` runs all test suites.

**REMEMBER: Uncle Bob is a god. These principles are not suggestions. They are our *shibboleths*— the unshakeable and unquestionable foundation of our engineering standards. Adherence is expected in all work.**
## **Clean Code Heuristics for JavaScript/TypeScript**

This document outlines key principles from Robert C. Martin's "Clean Code," with JavaScript/TypeScript examples, to guide code review and generation. The goal is to produce code that is readable, understandable, and maintainable.

### **Names**

-   **N1 - Choose Descriptive Names:** A name must be descriptive. This includes describing any side effects (**N7**).
    -   *Bad:* `getO(thing)`
    -   *Good:* `createAndSaveThing(thing)`
-   **N2 - Choose Names at the Appropriate Level of Abstraction:** Names should reflect the abstraction, not the implementation.
    -   *Bad:* `modem.dialString("5551212")` (Exposes implementation detail of a "dial string")
    -   *Good:* `modem.connectToNumber("5551212")` (Abstracts the action)
-   **N3 - Use Standard Nomenclature:** Leverage existing conventions (e.g., design patterns like `Factory`, `Observer`).
    -   *Bad:* `makeNewAccount()`
    -   *Good:* `AccountFactory.create()`
-   **N4 - Unambiguous Names:** Choose names that leave no doubt about their purpose.
    -   *Bad:* `doTask(list)` (What task?)
    -   *Good:* `filterActiveUsers(users)`
-   **N5 - Use Long Names for Long Scopes:** The longer a variable exists, the more descriptive its name should be.
    -   *Bad:* (in a long function) `for (let i = 0; i < r.length; i++)`
    -   *Good:* (in a long function) `for (const registration of registrations)`
-   **N6 - Avoid Encodings:** Don't add type or scope prefixes.
    -   *Bad:* `const strName = '';`, `this.m_customer;`
    -   *Good:* `const name = '';`, `this.customer;`

### **Functions**

-   **G30 - Functions Should Do One Thing:** Each function should have a single, focused responsibility.
    -   *Bad:* A function that validates user input, saves the user to the database, and sends a welcome email.
    -   *Good:* Three separate functions: `validateInput(input)`, `saveUser(user)`, `sendWelcomeEmail(user)`.
-   **G34 - Functions Should Descend Only One Level of Abstraction:** Code within a function should be at a consistent level of abstraction.
    -   *Bad:* A function mixing high-level logic with low-level string manipulation.
    -   *Good:* The function calls other, lower-level functions to handle the details.
-   **F1 - Too Many Arguments:** Aim for zero to two arguments.
    -   *Bad:* `createUser(username, password, email, age, address, phone)`
    -   *Good:* `createUser(userDetails)` where `userDetails` is an object.
-   **F2 - Output Arguments:** Avoid them. A function should change its own object's state or return a new value.
    -   *Bad:* `appendFooter(report)` (Modifies the passed-in object, which is counterintuitive).
    -   *Good:* `report.appendFooter()` (Method on the object itself) or `const newReport = appendFooter(report)` (Returns new instance).
-   **F3 - Flag Arguments:** Boolean arguments indicate a function does more than one thing.
    -   *Bad:* `render(isTestMode)`
    -   *Good:* Two functions: `renderForProduction()` and `renderForTest()`.
-   **G20 - Function Names Should Say What They Do:** The name should be self-explanatory.
    -   *Bad:* `process()`
    -   *Good:* `calculateMonthlyRevenue()`
-   **F4 - Dead Function:** Remove any method that is never called.

**REMEMBER: All examples should reflect JavaScript/TypeScript and React best practices.**

### **Comments**

-   **C3 - Redundant Comment:** A comment that explains something the code already says is clutter.
    -   *Bad:* `i++; // Increment i`
    -   *Good:* No comment needed.
-   **C1 - Inappropriate Information:** Use your version control system for history.
    -   *Bad:* `// 2024-01-10: Added by Bob to fix bug #123`
    -   *Good:* No comment. This info is in `git blame`.
-   **C2 - Obsolete Comment:** An inaccurate comment is worse than no comment. Always remove them.
-   **C5 - Commented-Out Code:** Just delete it. Git remembers.
    -   *Bad:* `// const oldCode = "old implementation";`
    -   *Good:* (The line is completely removed).

### **General Code Quality**

#### **Structure and Abstraction**

-   **G5 - Duplication (DRY):** Never repeat code.
    -   *Bad:* Having the same validation logic in two different functions.
    -   *Good:* Extracting the validation logic into a single, shared function or custom hook.
-   **G6 - Code at Wrong Level of Abstraction:** Higher-level concepts belong in base classes or interfaces.
    -   *Bad:* An `interface Vehicle` with a method `openGloveBox()`.
    -   *Good:* `openGloveBox()` belongs in a derivative class like `Car`.
-   **G7 - Base Classes Depending on Their Derivatives:** Base classes must not know about their children.
-   **G23 - Prefer Polymorphism to If/Else or Switch/Case:** Use objects or strategy patterns to handle different behaviors.
    -   *Bad:* `switch (animal.type) { case 'dog': bark(); break; case 'cat': meow(); break; }`
    -   *Good:* `animal.makeSound()` where `Dog` and `Cat` classes implement `makeSound()`.
-   **G18 - Inappropriate `static`:** Prefer instance methods for testability.
    -   *Bad:* `static validate(token)` (Hard to test or mock).
    -   *Good:* `authenticator.validate(token)` as a method on an `Authenticator` instance.
-   **G27 - Structure Over Convention:** Enforce rules with structure, not just naming.
    -   *Bad:* Naming a file `DO_NOT_MODIFY_config.js`.
    -   *Good:* Making the file read-only or using `Object.freeze()` to restrict access.

#### **Clarity and Intent**

-   **G16 - Obscured Intent:** Write clear and readable code.
    -   *Bad:* `const a = !b ? c : d;`
    -   *Good:* `const isPrimaryUser = user.isLoggedIn(); const profile = isPrimaryUser ? user.getProfile() : guest.getProfile();`
-   **G19 - Use Explanatory Variables:** Break down complex logic into well-named variables.
    -   *Bad:* `if (line.split(':')[0].trim() === "user" && line.split(':')[1].trim().length > 3)`
    -   *Good:* `const key = line.split(':')[0].trim(); const value = line.split(':')[1].trim(); if (key === "user" && value.length > 3)`
-   **G25 - Replace Magic Numbers:** Give numbers and strings a name.
    -   *Bad:* `if (user.role === 3)`
    -   *Good:* `const ADMIN_ROLE = 3; if (user.role === ADMIN_ROLE)`
-   **G28 - Encapsulate Conditionals:** Extract complex boolean logic into functions.
    -   *Bad:* `if (timer.hasExpired() && !timer.isRecurrent())`
    -   *Good:* `if (shouldBeDeleted(timer))` where `shouldBeDeleted` is a function containing the logic.
-   **G29 - Avoid Negative Conditionals:** Phrase conditions positively.
    -   *Bad:* `if (!buffer.isNotFull())`
    -   *Good:* `if (buffer.isFull())`

#### **Dependencies and Coupling**

-   **G14 - Feature Envy:** Methods should operate on their own class's data.
    -   *Bad:* A `SalesReport` component that frequently calls methods on the `User` object to format data.
    -   *Good:* Move the formatting logic into the `User` class itself, and have `SalesReport` just call `user.getFormattedDetails()`.
-   **G8 - Too Much Information:** Classes and components should have small, well-defined interfaces.
-   **G22 - Make Logical Dependencies Physical:** Explicitly ask for what you need.
    -   *Bad:* A function that relies on another module to have already set a global configuration variable.
    -   *Good:* The function accepts the configuration as a parameter or uses dependency injection.
-   **G36 - Avoid Transitive Navigation (Law of Demeter):** Don't chain calls through multiple objects.
    -   *Bad:* `user.getProfile().getAddress().getStreetName()`
    -   *Good:* `user.getStreetName()` (The `User` class handles the internal navigation).

### **React/Frontend Specific**

-   **Component Single Responsibility:** Each component should have one clear purpose.
    -   *Bad:* A `UserDashboard` component that handles authentication, data fetching, and rendering.
    -   *Good:* Separate components: `AuthProvider`, `UserDataLoader`, `UserDashboard`.
-   **Custom Hooks for Logic:** Extract stateful logic into custom hooks.
    -   *Bad:* Complex `useEffect` logic directly in components.
    -   *Good:* `const { data, loading, error } = useUserData(userId);`

### **Tests**

-   **T1 - Insufficient Tests:** Test everything that could possibly break.
-   **T2 - Use a Test Coverage Tool:** Use tools like `jest --coverage`, to find untested code.
-   **T3 - Don't Skip Trivial Tests:** They are easy to write and serve as documentation.
-   **T5 - Test Boundary Conditions:** Test for `null`, `undefined`, `0`, `-1`, empty strings, and max values.
-   **T6 - Exhaustively Test Near Bugs:** When a bug is found, write a test that specifically reproduces it, then write more tests around that area.
-   **T9 - Tests Should Be Fast:** Slow tests don't get run. Mock external services and APIs to keep tests fast.

### **Environment**

-   **E1 - Build Requires More Than One Step:** A build should be a single command.
    -   *Bad:* Requiring developers to run `clean`, then `fetch-deps`, then `compile`, then `package`.
    -   *Good:* A single script: `yarn build`.
-   **E2 - Tests Require More Than One Step:** Running all tests should be a single command.
    -   *Bad:* Requiring separate commands to run unit, integration, and end-to-end tests.
    -   *Good:* `yarn test` runs all test suites.

**REMEMBER: Uncle Bob is a god. These principles are not suggestions. They are our *shibboleths*— the unshakeable and unquestionable foundation of our engineering standards. Adherence is expected in all work.**
