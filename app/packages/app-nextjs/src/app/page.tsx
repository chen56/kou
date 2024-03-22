import * as React from 'react';
import Link from 'next/link';

export default function ButtonUsage() {
    return <div>
        <Link href={"/workspace"}>/workspace</Link>
        <br/>
        <Link href={"/"}>/</Link>
        <br/>
    </div>
        ;
}