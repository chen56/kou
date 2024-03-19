import {useState} from 'react'

function App() {
    const [count, setCount] = useState(0)

    return (
        <>
            <h1>Vite + React</h1>
            <div className="card">
                <button type="button" className="btn" onClick={() => setCount(count + 1)}> +</button>
                count is {count}
                <button type="button" className="btn" onClick={() => setCount(count + 1)}> +</button>
                count is {count}
            </div>
        </>
    )
}

export default App;

export function App3() {
    const [count, setCount] = useState("xyzabc")

    return (
        <>
            <div className="card">
                <button type="button" className="btn" onClick={() => setCount(count + 1)}> +</button>
                count is {count}
            </div>
        </>
    )
}

