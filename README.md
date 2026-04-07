# GetScan

The Programming language Luau is highly capable, but structurally fragmented. Modifying an Instance typically requires managing a chaotic mix of property assignments, method calls, and attribute injections—each demanding a different syntax. 

**GetScan** makes all syntax that goes through it a **Single-Entry-Point (SEP)**. By routing all engine interactions through a custom proxy environment (`.Scan`), it replaces traditional syntax with a high-performance **Hexidecimal Dictionary**. It is designed for Developers who need to execute mass-modification logic with absolute precision and fault-safe measures.

Features & Uses:

###1. The Unified Logic Gateway (Hex-ID Mapping)
Instead of juggling disparate syntaxes to change colors, run methods, or set attributes, GetScan funnels everything through a singular index mapping. Attributes, Properties, and custom data are all injected via the same underlying logic structure.
> `local Part = GetScan.Scan(workspace.Part)`
> `Part = "Name_Example"`

###2. Atomic Batching
GetScan eliminates the need to write multi-line sequential property updates. Using the `.State` index, developers can pass a table of values that the engine instantly parses and applies simultaneously. It translates complex visual and physics updates into a single, easily readable line of code.
> `Part.State = { "Neon", 0.5, true } -- Applies Material, Transparency, and Anchored = true`

###3. Fault-Tolerant Execution (Safe-Sets)
In native Luau, attempting to index or modify a non-existent property throws a fatal error, halting the script. GetScan intercepts these failures at the metatable level. If an invalid property is called, the proxy acts as a shock absorber, it logs a subtle warning to the console and allows the script to continue running safely.

###4. Deep Hierarchy Scanning
GetScan utilizes a high-speed traversal mechanism. The `ScanDeep` function maps the entire family tree of an object and caches it into a readily accessible dictionary. Because the discovery loop is cached upfront, subsequent direct-access calls or mass-iterations are lightning-fast.
> `local CharRig = GetScan.ScanDeep(workspace.Rig)`

###5. The Metatable Bridge (Unwrapping)
A common flaw in proxy wrappers is the loss of compatibility with native Roblox services (like `TweenService`). GetScan solves this elegantly using the `__call` metamethod. By simply appending `()` to your proxy variable, it instantly "unwraps" the object, returning the raw Roblox Instance for seamless integration with external APIs.
> `local myProxy = GetScan.Scan(workspace.Part)`
> `local info = TweenInfo.new(2, Enum.EasingStyle.Sine)`
> `local goals = {Size = Vector3.new(20, 20, 20), Transparency = 1}`
> `local tween = TweenService:Create(myProxy(), info, goals)`

###6. Hex-Serialization & Memory Control
GetScan provides deep system-level control over how data is processed. Objects can be entirely serialized into an address-mapped table using `:Serialize()`, converting all live properties into their respective Hex-IDs—perfect for debugging, UI population, or saving states. Furthermore, the engine allows for live memory flushing (`GetScan.FlushCache()`) to support hot-reloading module updates without restarting the server.
