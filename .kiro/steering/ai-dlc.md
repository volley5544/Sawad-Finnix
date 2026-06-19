---
inclusion: always
---

# AI-DLC (AI-Driven Development Lifecycle)

Apply this methodology to every task in this workspace automatically. Do not wait
for the user to type "Using AI-DLC" — it is always on.

## Core principle

AI does the bulk of the work (analysis, planning, code, tests); the human stays in
the loop as the decision-maker who clarifies intent and approves direction. Move in
short, verifiable cycles rather than one large unverified change.

## Three phases

1. **Inception** — Understand the intent.
   - Restate the goal in one or two sentences.
   - Surface assumptions and ask only the clarifying questions that would change the
     approach. If intent is clear, proceed without asking.
   - Produce a short plan (the work units / "bolts") before writing code.

2. **Construction** — Build in small bolts.
   - Implement one bolt at a time. A bolt is a small, independently verifiable slice.
   - After each bolt: run the build and relevant tests, report what was verified.
   - Keep the human able to approve or redirect between bolts.

3. **Operations** — Make it runnable and maintainable.
   - Ensure build/test/lint pass.
   - Note how to run it, and any follow-ups, risks, or blocked items.

## Working rules

- Always present the plan (bolts) before large or multi-file changes; act directly on
  small, well-scoped ones.
- Prefer the smallest change that fully satisfies the task; avoid unrequested scope.
- Verify every change (build + tests) before presenting it as done.
- Be explicit about what was verified vs. assumed.
- Match the project's existing style, libraries, and conventions.
