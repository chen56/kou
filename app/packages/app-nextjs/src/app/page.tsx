import * as React from 'react';
import Button from '@mui/material/Button';
import Link from 'next/link';

export default function ButtonUsage() {
    return <div>
        <Link href={"/workspace"}>/workspace</Link>
        <br/>
        <Link href={"/"}>/</Link>
        <br/>

        <Button variant="contained">Hello world </Button>
    </div>
        ;
}