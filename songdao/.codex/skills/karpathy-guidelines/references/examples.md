# Karpathy Guidelines Examples

These examples describe the project-wide anti-patterns this skill is meant to prevent.

## Hidden Assumptions

Weak response: implement a broad export or sync feature without checking scope, data ownership, privacy, or verification.

Better response: identify the smallest useful path, state assumptions, and ask only when a wrong assumption would cause rework or data risk.

## Over-Abstraction

Weak response: build factories, strategy layers, registries, or config frameworks for one caller.

Better response: write one clear function or local module first. Extract only when repeated real cases exist.

## Drive-By Refactoring

Weak response: fix one bug while renaming files, reformatting unrelated code, and changing neighboring behavior.

Better response: change the failing branch, add a focused test, and leave adjacent code intact.

## Verifiable Goals

Weak response: "Improve onboarding" or "make detection better" without a measurable path.

Better response: define the observable result, run the closest check, and stop when the success criteria are met.
