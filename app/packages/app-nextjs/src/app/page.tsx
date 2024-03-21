import {Card, Text} from "@radix-ui/themes";
import React from "react";

export default function Home2() {
    return (
        <main className="flex flex-row min-h-screen  justify-between">
            <Card variant={"surface"} asChild style={{maxWidth: 350}}>
                <a href="#">
                    <Text as="div" size="2" weight="bold">
                        Quick start
                    </Text>
                    <Text as="div" color="gray" size="2">
                        Start building your next project in minutes
                    </Text>
                </a>
            </Card>
        </main>
    );
}

