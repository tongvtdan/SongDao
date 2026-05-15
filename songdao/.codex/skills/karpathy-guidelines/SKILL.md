---
name: karpathy-guidelines
description: Behavioral guardrails for AI coding work. Use when writing, reviewing, debugging, refactoring, or planning code changes where Codex should avoid wrong assumptions, overengineering, drive-by edits, or unverifiable completion.
---

# Karpathy Guidelines

Use this skill as a quality gate for non-trivial SongDao coding, debugging, refactoring, review, or architecture work. Bias toward explicit assumptions, simple code, surgical diffs, and verified outcomes.

## Operating Loop

1. Define the user outcome and success criteria.
2. Surface assumptions that affect scope, data, safety, privacy, performance, product claims, or architecture.
3. Choose the smallest implementation that satisfies the outcome.
4. Change only files and lines that trace to the request.
5. Verify with the narrowest meaningful test or command.
6. Report what changed, what passed, and any residual risk.

## Simplicity First

- Do not add speculative features, extension points, configuration systems, or new packages.
- Do not introduce an abstraction for a single caller unless it removes real local complexity.
- Prefer existing project patterns before new structure.
- Keep error handling grounded in realistic failure modes for this product.
- If the solution feels large relative to the request, reduce scope before editing.

## Surgical Changes

- Match surrounding style.
- Do not reformat, rename, or refactor adjacent code as a side effect.
- Remove unused code only when your change made it unused.
- Mention unrelated concerns in the final handoff instead of editing them.

## Project Fit

Prioritize work that improves:

- daily faith-practice activation
- return behavior and completion consistency
- content-pack trust and maintainability
- local parish usefulness
- local-first reliability

Challenge work that does not improve one of those outcomes.

## Examples

Read `references/examples.md` when a task involves ambiguous implementation, refactoring, review, or broad changes.
