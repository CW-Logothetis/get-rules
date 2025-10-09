# Before you memo

Core Principle: Isolate State Changes

When a component's state updates, React re-renders the component and its entire subtree. If a part of that subtree is computationally expensive but does not depend on the changing state, this leads to performance issues. The solution is to refactor components to separate the parts that depend on state from the parts that don't.

Strategy 1: Move State Down

This technique is applicable when state is held higher up in the component tree than necessary.

    Problem: A parent component App holds state (e.g., color) that is only used by a few elements within it, but its state updates cause an unrelated <ExpensiveTree /> component to re-render.
    JavaScript

// Problematic Structure
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

Solution: Extract the state and the elements that depend on it into a new, self-contained component (Form). The parent component (App) then renders this new component alongside the expensive one.
JavaScript

    // Optimized Structure
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

    Result: Now, when the color state changes, only the Form component re-renders. <ExpensiveTree /> is unaffected because its parent (App) does not re-render.

Strategy 2: Lift Content Up

This technique is useful when a parent component must hold the state because it affects the parent's own rendering (e.g., styling a container div), but its children don't need to re-render.

    Problem: The state (color) is used in the parent component's top-level element, so we can't simply move the state down. The state change still triggers a re-render of <ExpensiveTree />.
    JavaScript

// Problematic Structure
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

Solution: Split the component. Create a new component (ColorPicker) that manages the state and renders the elements dependent on it. The expensive, non-dependent components (<p> and <ExpensiveTree />) are passed from the parent as the children prop.
JavaScript

// Optimized Structure
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

Result: When the color changes, ColorPicker re-renders. However, from React's perspective, the children prop it receives from App is the same object as before. Therefore, React does not need to visit and re-render the children subtree, and <ExpensiveTree /> is skipped.
