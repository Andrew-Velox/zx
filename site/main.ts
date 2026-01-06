import React from "react";
import { createRoot } from "react-dom/client";
import { hydrateAll } from "../packages/ziex/src/react";
import { init, jsz } from "../packages/ziex/src/wasm";
import { components } from "@ziex/components";

// Build registry from generated components
const registry = Object.fromEntries(components.map(c => [c.name, c.import]));

// Hydrate React islands
hydrateAll(registry, (el, C, props) => createRoot(el).render(React.createElement(C, props)));

const importObject: WebAssembly.Imports = {
    env: {
        zxFetch: (urlPtr: number, urlLen: number) => {
            const memory = new Uint8Array(jsz.memory!.buffer);
            const url = new TextDecoder().decode(memory.slice(urlPtr, urlPtr + urlLen));

            fetch(url)
                .then(response => response.text())
                .then(text => {
                    const encoder = new TextEncoder();
                    const bytes = encoder.encode(text);

                    // Allocate memory in WASM
                    const wasmAlloc = window._zx?.exports?.wasmAlloc as ((len: number) => number) | undefined;
                    const onFetchComplete = window._zx?.exports?.onFetchComplete as ((ptr: number, len: number) => void) | undefined;
                    const wasmFree = window._zx?.exports?.wasmFree as ((ptr: number, len: number) => void) | undefined;

                    if (!wasmAlloc || !onFetchComplete) {
                        console.error('WASM exports not available');
                        return;
                    }

                    const ptr = wasmAlloc(bytes.length);
                    if (ptr === 0) {
                        console.error('Failed to allocate WASM memory');
                        return;
                    }

                    const mem = new Uint8Array(jsz.memory!.buffer);
                    mem.set(bytes, ptr);

                    onFetchComplete(ptr, bytes.length);

                    wasmFree?.(ptr, bytes.length);
                })
                .catch(error => {
                    console.error('Fetch error:', error);
                    const onFetchError = window._zx?.exports?.onFetchError as (() => void) | undefined;
                    onFetchError?.();
                });
        },
    }
};

// Initialize WASM
init({
    importObject,
});

