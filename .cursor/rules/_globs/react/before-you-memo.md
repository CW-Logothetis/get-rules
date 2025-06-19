# Before you memo

There are many articles written about React performance optimizations. In general, if some state update is slow, you need to:

- Verify that you didn’t put the state higher in the tree than necessary. (For example, putting input state in a centralized store might not be the best idea.)
- Run React DevTools Profiler to see what gets re-rendered, and wrap the most expensive subtrees with memo(). (And add useMemo() where needed.)

This last step is annoying, especially for components in between.

Here are two different techniques. They’re surprisingly basic, which is why people rarely realize they improve rendering performance.

These solutions are often goot to try first, but they do not replace memoization, they are complementary to memo or useMemo.

## An (Artificially) Slow Component
Here’s a component with a severe rendering performance problem:
```
import { useState } from 'react';
 
export default function App() {
  let [color, setColor] = useState('red');
  return (
    <div>
      <input value={color} onChange={(e) => setColor(e.target.value)} />
      <p style={{ color }}>Hello, world!</p>
      <ExpensiveTree />
    </div>
  );
}
 
function ExpensiveTree() {
  let now = performance.now();
  while (performance.now() - now < 100) {
    // Artificial delay -- do nothing for 100ms
  }
  return <p>I am a very slow component tree.</p>;
}
```

The problem is that whenever color changes inside `App`, we will re-render `<ExpensiveTree />` which we’ve artificially delayed to be very slow.

I could put `memo()` on it and call it a day, but there are many existing articles about it so I won’t spend time on it. I want to show two different solutions.

## Solution 1: Move State Down
If you look at the rendering code closer, you’ll notice only a part of the returned tree actually cares about the current color:

```
export default function App() {
  let [color, setColor] = useState('red');
  return (
    <div>
      <input value={color} onChange={(e) => setColor(e.target.value)} />
      <p style={{ color }}>Hello, world!</p>
      <ExpensiveTree />
    </div>
  );
}
```
So let’s extract that part into a Form component and move state down into it:
```
export default function App() {
  return (
    <>
      <Form />
      <ExpensiveTree />
    </>
  );
}
 
function Form() {
  let [color, setColor] = useState('red');
  return (
    <>
      <input value={color} onChange={(e) => setColor(e.target.value)} />
      <p style={{ color }}>Hello, world!</p>
    </>
  );
}
```

Now if the color changes, only the Form re-renders. Problem solved.

## Solution 2: Lift Content Up
The above solution doesn’t work if the piece of state is used somewhere above the expensive tree. For example, let’s say we put the color on the parent <div>:
```
export default function App() {
  let [color, setColor] = useState('red');
  return (
    <div style={{ color }}>
      <input value={color} onChange={(e) => setColor(e.target.value)} />
      <p>Hello, world!</p>
      <ExpensiveTree />
    </div>
  );
}
```


Now it seems like we can’t just “extract” the parts that don’t use color into another component, since that would include the parent `<div>`, which would then include `<ExpensiveTree />`. Can’t avoid memo this time, right?

Or can we?

The answer is remarkably plain:
```
export default function App() {
  return (
    <ColorPicker>
      <p>Hello, world!</p>
      <ExpensiveTree />
    </ColorPicker>
  );
}
 
function ColorPicker({ children }) {
  let [color, setColor] = useState("red");
  return (
    <div style={{ color }}>
      <input value={color} onChange={(e) => setColor(e.target.value)} />
      {children}
    </div>
  );
}
```

We split the App component in two. The parts that depend on the color, together with the color state variable itself, have moved into `ColorPicker`.

The parts that don’t care about the color stayed in the `App` component and are passed to `ColorPicker` as JSX content, also known as the children prop.

When the color changes, `ColorPicker` re-renders. But it still has the same children prop it got from the `App` last time, so React doesn’t visit that subtree.

And as a result, `<ExpensiveTree />` doesn’t re-render.

## What’s the moral?
Before you apply optimizations like memo or useMemo, it might make sense to look if you can split the parts that change from the parts that don’t change.

The interesting part about these approaches is that they don’t really have anything to do with performance, per se. Using the children prop to split up components usually makes the data flow of your application easier to follow and reduces the number of props plumbed down through the tree. Improved performance in cases like this is a cherry on top, not the end goal.

Curiously, this pattern also unlocks more performance benefits in the future.

Again, all approaches are complementary. Don’t neglect moving state down (and lifting content up!)

Then, where it’s not enough, use the React Profiler and sprinkle those memo’s.
