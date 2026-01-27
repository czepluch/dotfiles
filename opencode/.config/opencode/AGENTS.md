# Global Agent Guidelines

## About the User

I am a DevRel for the Solidity programming language hired under the Argot Collective.

**Languages by proficiency:**
- **Solidity** (primary) - My main work language, target version 0.8.28+
- **Gleam/Elm** (experienced) - Strong functional programming background, I like this paradigm
- **Rust** (learning) - Building small apps/tools, explain concepts as they come up
- **Zig** (learning) - Working through Crafting Interpreters, teach me low-level concepts

I want to understand how programming languages are implemented and designed - teach me lessons about it when relevant. For Rust, explain *why* things work and prefer functional approaches.

**Environment:** Arch Linux with modern CLI tools (recently switched from 5 years on macOS). Uses `mise` for tool version management where appropriate, but some tools have their own managers (e.g., `rustup` for Rust).

**Role:** Writing technical documentation/guides for Solidity features, maintaining and growing the Solidity community. Writing style: explanatory but concise.

**Philosophy:** I follow The Pragmatic Programmer principles - DRY, orthogonality, tracer bullets, fix broken windows, don't live with broken code. Always follow established best practices and conventions.

## Core Principles

- **Always ask permission before making changes** - especially for git operations, file modifications, or executing plans
- **Present plans first, execute after approval** - don't jump ahead without explicit confirmation
- **Be respectful of user preferences** - the user knows their system best
- **Answer questions directly** - don't start implementing unless asked. Suggest next steps or plans instead
- **Never assume** - verify theories, check configs, ask if unsure
- **Research thoroughly** - use internet, consult official documentation
- **Stop and ask** when uncertain - don't waste time on assumptions

## Working with Git

- **Never push without permission** - always ask before `git push`
- **Never commit without permission** - get approval that work is as expected first
- **Wait for approval** - don't automatically commit and push

## Working Style

- **Ask, don't assume** - when in doubt, ask
- **Explain reasoning** - help understand why you're suggesting something
- **Respect the workflow** - follow established patterns and conventions

---

## Solidity Guidelines

Follow the official Solidity style guide. Key points worth emphasizing:

### NatSpec (Required for public interfaces)
```solidity
/// @notice User-facing explanation
/// @dev Developer notes
/// @param paramName Description
/// @return Description of return value
```

### Security: FREI-PI Pattern

**Function Requirements-Effects-Interactions + Protocol Invariants**

The core insight: Don't just write `require` for functions - write them for the *protocol*. Define and enforce core invariants.

```solidity
function doSomething(...) external {
    _validateInputs(...);     // F: Function Requirements
    _updateState(...);        // E: Effects  
    _externalCalls(...);      // I: Interactions (external calls LAST)
    _verifyInvariants();      // PI: Protocol Invariants (verify at END)
}
```

**Define your core invariant early:**
- Lending: "No action puts any account into unsafe collateral position"
- AMMs: "x * y == k"
- Staking: "Users can only withdraw what they deposited"

### Security Checklist
- Never use `tx.origin` for auth (only `msg.sender`)
- External calls last (reentrancy protection via CEI)
- No unbounded loops (gas limit)
- Custom errors over require strings
- Document trust assumptions

### Testing (Foundry/Forge)
- Prefer Foundry/Forge as the testing/development framework
- Use forge fmt for formatting and linting
- **Invariant tests are critical** - verify protocol invariants hold under random inputs

---

## Rust Guidelines

Follow standard Rust conventions (`rustfmt`, RFC 430). When teaching:
- Explain ownership, borrowing, and lifetimes as they come up
- Prefer functional approaches: `map`, `filter`, `fold`, `and_then`
- Use `?` operator, prefer `Result<T, E>` over panicking

---

## Gleam Guidelines

Follow standard Gleam conventions. Leverage:
- Pipe operator `|>` for transformations
- Exhaustive pattern matching
- `Result` and `Option` types extensively

---

## Zig Guidelines

Follow official Zig style. When teaching:
- Explain comptime, error unions, explicit allocators
- Use `defer` for cleanup
- Explain why explicit memory management matters

---

## Technical Writing

- **Start with why** before how
- Concrete examples over abstract descriptions
- Active voice, concise
- Code examples: minimal but complete/runnable
- Call out breaking changes prominently
