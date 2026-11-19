# PR/MR body

The PR/MR body is the handover for a reviewer: why the change exists, what it
does, and how far to trust it. It is written here as text. The user pushes and
opens the PR/MR.

## Find the template first

Look for the project's PR/MR template before writing:
`.github/pull_request_template.md`, `.github/PULL_REQUEST_TEMPLATE/`,
`.gitlab/merge_request_templates/`, or a rule in `AGENTS.md`, `CLAUDE.md`, or
`CONTRIBUTING.md`. If one exists, follow
its sections and order, and put the content below into them. Leave no section
of the project's template empty; write "none" where nothing applies.

## Template

```markdown
<Title: what the change makes true, imperative, under ~70 characters>

## Why

<One paragraph: the goal and the problem it solves. Link the spec and the
ticket.>

## What changed

- <User-visible change first.>
- <Then internal changes a reviewer must know about.>

## How it was proved

- **Criterion 1** — <the criterion>: <the direct check> showed <result>.
- **Criterion 2** — <the criterion>: <the direct check> showed <result>.

## Not proved / known gaps

- <What remains unverified, and why.>
- <Not tested, and why. Declared P0/P1 findings, with who accepted them.>

## Change outline

<The `show-me` view of the change: a file tree with status, a `diff` of a
shape, or a Mermaid flow. Markdown format, so it renders in the PR/MR.>

## Found, not fixed

- `<file:line>` · P2 — <problem>.
```

## Rules

- **Plain language.** Write for a reviewer who did not see the work. No
  internal shorthand, no stage names as jargon.
- **Proof, not reassurance.** Each criterion names its check and what it showed.
  "Tests pass" is not a proof line.
- **No coverage percentage as evidence.** A number describes the suite, not this
  change.
- **Not proved is never empty by omission.** If everything is proven, say so.
- **Link the spec.** The body summarises; the spec is the contract.
- **The outline fits a PR/MR.** Use the `show-me` skill in Markdown format: one
  or two views, short enough to read in the PR/MR page, with their sources.
- **Do not push or open.** Return the body as text, or as a file if the user
  asks. Pushing, opening the PR/MR, and posting to the tracker stay with the
  user.
