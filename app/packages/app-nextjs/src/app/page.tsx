import * as React from 'react';
import Link from 'next/link';

export default function ButtonUsage() {
    return <div className="">
        <Link href={"/workspace"}>/workspace</Link>
        <br/>
        <Link href={"/"}>/</Link>
        <br/>
        <button className="btn btn-primary">Buttosssssssssssssssssssssn</button>

        <button className="btn btn-primary">One</button>
        <button className="btn btn-secondary">Two</button>
        <button className="btn btn-accent btn-outline">Three</button>
    </div>
        ;
}