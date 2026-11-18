# Research

The facts step of design. The job is to answer questions about the change's
area with evidence, not to form a solution and then look for support. What you
learn goes into the spec's research appendix, so a reader can check it.

## Ask neutral questions

Write the questions down before reading. A question that contains its answer
("where should this helper live?") closes the search too early.

Questions that stay open:

- What happens today, for each caller and each input class?
- Where does this value come from, who writes it, and who reads it?
- Which invariant holds here, and where is it enforced?
- What happens when this is missing, empty, duplicated, or late?
- Which test or check would fail if this behaviour changed?
- What outside constraint binds it: a schema, a partner, a migration, a
  retention rule?
- Has this been tried before, and what did that change say?

Ask about behaviour and data first, code second. A name or a comment is a
claim; the executing path is the evidence.

## Where to look

Work outward from the change's entry point. Stop when the next read cannot
change a decision.

1. **Entry points**: routes, commands, handlers, jobs, event consumers.
2. **Callers and callees**: who reaches this, and what it reaches.
3. **Data**: schema, migrations, stored formats, fixtures, retention jobs.
4. **Tests**: what they pin, what they assume, what they skip.
5. **Config and environment**: flags, defaults, deployed values.
6. **The vocabulary of the area**: `GLOSSARY.md`, ADRs, runbooks.
7. **The record**: the commits that introduced the area and every later change,
   their PR/MR discussions, issues, and release notes.

Search by concept as well as by name: a copied rule can appear under three
names, and the name in the ticket may exist nowhere in the code.

## Cite `file:line`

Every fact gets a location. Ranges are fine; one line is usually enough.

- Read the file at the cite before writing it. A cite from memory is a guess.
- Cite the line that carries the fact, not the top of the file.
- For a claim about counts or history, write the command you ran and its
  result, for example `git log --oneline -- src/import | wc -l` giving 34.
- For a claim about behaviour, name the observation: the test that pins it, the
  fixture that shows it, the run whose output showed it.
- Use the project's names, not synonyms you invented. If the code and the
  glossary disagree, say so; that disagreement is a finding.

## Mark the gaps

Three kinds, and each is written down rather than absorbed:

- **Evidence gap**: you did not read the file, service, or data that would
  settle it. Say what to read and who can.
- **Record gap**: the why is not written anywhere. Say which sources are
  missing. Do not reconstruct intent from the code as if the authors said it.
- **Decision gap**: the fact is known and the choice is the user's. That is a
  judgment question, asked with options, not a gap to research.

A gap is a finding. It belongs in the appendix with its owner, and in open
risks if it can invalidate the shape.

Keep your own inferences separate: mark them `(inference)` and give what would
confirm them. A reconstruction is not a citation.

## Use the record, do not mine it

The record is the authority for why; the code is the authority for what. Read
the commit that introduced the behaviour, the discussion that shaped it, the
ADR that settled it, and the release note that announced it.

- Quote the decision, with its SHA, PR/MR number, or ADR path.
- Treat an earlier decision as settled unless new evidence overturns it. Do not
  re-ask what an ADR answers.
- When record and code disagree, report both. The gap is often the useful part.
- Recent commits and issues show drift: behaviour that was right for an intent
  that has since moved.

## When to hand off to `why`

`design` reads the record for facts it needs. Ask the user to run `why` when
the question becomes a research task of its own:

- the change depends on why an earlier design was chosen, and no ADR states it;
- the trailing discussion is long, contested, or spread across many changes;
- you need a cited account of the history for the spec, not a fact or two;
- the record may answer the question and code cannot.

State the question and the target, then resume design with `why`'s answer and
its named gaps. Do not spend the design session reconstructing history that a
dedicated pass would cite properly.
