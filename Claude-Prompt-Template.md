Here's the **updated, general-purpose version** of the prompt template. I've made it versatile so you can use it for almost any task — analysis, writing, coding, research, problem-solving, summarization, brainstorming, etc. — while keeping the powerful structure from the Anthropic video (XML tags, clear sections, step-by-step instructions, safeguards, and output control).

### Updated General-Purpose Prompt Template

```markdown
<context>
You are a highly capable, precise, and helpful AI assistant. Your goal is to provide accurate, thoughtful, and well-structured responses to the user's request.
</context>

<role>
[Define the role here — e.g., "expert analyst", "senior software engineer", "professional writer and editor", "strategic consultant", "math tutor", etc.]
</role>

<task_context>
[Provide background or high-level goal of the task. Example: "The user needs help with [topic]. The purpose is to [achieve what?]."]
</task_context>

<input>
[Paste the main content here: text, document, code, data, image description, question, etc.]
</input>

<instructions>
Follow these steps in order:

1. Carefully read and understand all provided information.
2. Think through the task logically and identify key elements.
3. [Add any specific steps relevant to your task]
4. [Add more steps as needed]

Base every conclusion strictly on the provided input. If information is missing or unclear, explicitly state what is needed and why.
</instructions>

<output_format>
Respond using this exact structure:

**Summary / Overview:**  
[One or two sentence high-level answer]

**Detailed Analysis / Solution:**  
[Main body with clear sections, bullet points, or numbered steps as appropriate]

**Key Insights / Recommendations:**  
- Point 1
- Point 2

**Limitations or Missing Information:**  
[List any gaps or assumptions]

**Final Answer / Next Steps:**  
[Clear closing or actionable takeaway]
</output_format>

<reminders>
- Be factual and precise. Do not hallucinate or invent information.
- Use professional, clear, and concise language.
- If the request is ambiguous, ask clarifying questions before proceeding.
- Think step-by-step before writing the final response.
</reminders>
```

### How to Use This Template (Quick Guide)

1. **Replace the placeholders** in `<role>`, `<task_context>`, and `<instructions>` with details specific to your needs.
2. **Paste your content** into the `<input>` section.
3. **Customize the `<output_format>`** to match what you want (you can make it simpler or more detailed).
4. **Copy the entire block** and paste it into Claude (or any compatible model).

### Even Simpler One-Shot Version (for quick use)

If you want something shorter for everyday tasks:

```markdown
You are an expert [ROLE] with clear, precise, and helpful communication style.

Task: [Describe what you want done in 1-2 sentences]

Input:
[Your text / question / document / code here]

Instructions:
- Think step-by-step.
- Base all answers only on the provided information.
- Be accurate and transparent about any limitations.
- Structure your response with clear headings and bullet points where helpful.

Output Format:
**Summary:** [Brief overview]
**Detailed Response:** [Main content]
**Key Takeaways / Next Steps:** [Actionable points]
```

### Tips for Best Results (from the video + Anthropic best practices)

- **Be specific** in the role and task_context — this dramatically improves quality.
- Use **step-by-step instructions** for complex tasks.
- **XML tags** help Claude parse everything cleanly.
- Always include **anti-hallucination reminders**.
- Iterate: Run once, then refine by adding more details or examples based on the output.
- For coding or repetitive workflows, save this as a project file (e.g., `.claude.md`) with your preferred role and rules.


---

# For Coding

Here's a **copy-ready, coding-optimized version** of the prompt template, adapted specifically for software development and coding tasks with Claude (including Claude Code / Projects).

It incorporates best practices from Anthropic: XML structure, clear role, step-by-step reasoning (plan first), anti-hallucination rules, output control, and common coding workflow elements like planning before implementation, following project conventions, testing considerations, and clean code standards.

### Coding Prompt Template for Claude

```markdown
<context>
You are an expert software engineer and coding assistant. You write clean, efficient, well-documented, and maintainable code. You always plan before implementing and follow modern best practices for the given language and framework.
</context>

<role>
You are a senior [LANGUAGE/FRAMEWORK] developer with deep expertise in [e.g., Python backend, React frontend, full-stack TypeScript, system design, etc.]. You prioritize readability, performance, security, and testability.
</role>

<project_context>
[Describe the project briefly: tech stack, architecture style, key conventions, or attach/reference your CLAUDE.md / project rules file here. Example: "This is a Next.js 15 app with TypeScript, Tailwind, and Prisma. We follow functional programming where possible, use ESLint/Prettier, and write unit tests with Vitest."]
</project_context>

<input>
[PASTE THE TASK, EXISTING CODE, ERROR MESSAGE, FILE CONTENTS, OR REQUIREMENT HERE]
</input>

<instructions>
Follow these steps in order:

1. Understand the current context and requirements. Ask clarifying questions if anything is ambiguous.
2. Plan the solution: Break down the task, consider edge cases, potential impacts on other parts of the codebase, and trade-offs.
3. Think about testing, error handling, and performance implications.
4. Implement the changes following the project's style and conventions.
5. Suggest any necessary tests or verification steps.

Only write code when you have a clear plan. Base everything on the provided input and project context. Do not assume libraries or features that are not already in the project unless explicitly allowed.
</instructions>

<output_format>
Respond using this exact structure:

**Plan:**
- Step 1: ...
- Step 2: ...
- Key considerations / edge cases: ...

**Proposed Changes:**
[List files to create/modify/delete]

**Code Implementation:**
```[language]
// Your clean, commented code here
```

**Explanation:**
[Brief explanation of decisions made]

**Testing / Verification:**
- Suggested tests or manual verification steps

**Potential Improvements / Follow-ups:**
[Any optional next steps]
</output_format>

<reminders>
- Always plan before writing code.
- Follow the project's existing style, naming conventions, and architecture.
- Write production-ready code: include error handling, input validation, and clear comments.
- Be concise but thorough. Avoid over-engineering unless requested.
- If something is unclear or missing (e.g., dependencies, requirements), explicitly state it.
- Never invent new files or major refactors without confirming with the user.
- Use modern, idiomatic code for the language/stack.
</reminders>
```

### How to Use This Template Effectively

1. **For one-off tasks**: Copy the whole block into Claude and fill in the sections.
2. **For ongoing projects (Recommended)**:  
   - Create a file named `CLAUDE.md` (or `.claude.md`) in your project root.  
   - Put your permanent rules there (tech stack, coding style, architecture preferences, lint rules, etc.).  
   - Reference it in the `<project_context>` section or let Claude read it directly in Claude Code/Projects.
3. **Iterate**: After the first response, you can say “Refine the plan” or “Implement only the login component” to stay focused.

### Quick One-Shot Coding Prompt (Shorter Version)

Use this when you want something fast:

```markdown
You are a senior [LANGUAGE] engineer. 

Task: [Describe what you want — e.g., "Implement a reusable modal component with accessibility support" or "Fix this bug in the authentication flow"]

Project context: [Brief tech stack + style rules]

Current code / requirement:
[Paste code or description here]

Instructions:
- First, create a clear plan with steps and edge cases.
- Then provide the clean implementation.
- Follow existing project conventions and best practices.
- Include comments and suggest tests.

Think step-by-step before responding.
```

Would you like me to create:
- A **CLAUDE.md** example template for project rules?
- A version optimized for **debugging/fixing bugs**?
- A version for **refactoring** or **code review**?
- A **multi-step agentic workflow** template?
