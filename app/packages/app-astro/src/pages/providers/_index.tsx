import {useState} from 'react'

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
