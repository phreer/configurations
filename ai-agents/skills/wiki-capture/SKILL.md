---
name: wiki-capture
description: 'Capture a valuable discussion from ANY repo/session into the LLM Wiki inbox as a self-contained raw source, for later ingest. Use when the user says capture / 记到 wiki / 存到 wiki / 这个有价值记一下 / file this for the wiki / 加入 wiki inbox — typically while working in a DIFFERENT repo than the Notes vault. This skill ONLY writes a raw file + queues it; it does NOT touch wiki entity/concept/index pages (that happens later via wiki-ingest in the Notes repo).'
argument-hint: '[optional slug or topic]'
---

# Wiki Capture

Capture a valuable discussion — usually happening in **a different repo** than the
Notes vault — into the wiki's **inbox** as a self-contained raw source, so it can be
ingested properly later. This is the **Capture** half of a deliberate two-stage flow:

```
Capture  (any repo, this skill)   →  raw/inbox/<date>-<slug>.md   +  queue row
Ingest   (Notes repo, /wiki-ingest) →  entity/concept/index/log pages
```

## Why two stages (do not collapse them)

The wiki's whole schema rests on every claim tracing back to an **immutable raw
source**. A chat is volatile — it gets compacted and lost. And when you're in another
repo, the wiki's `index.md` and existing pages are **not loaded**, so you don't know
which `[[entities]]`/`[[concepts]]` already exist. Doing a full ingest here would
duplicate pages, miss cross-links, and corrupt index/log with no way to lint.

So this skill does the ONE thing that must happen while context is still rich:
**freeze the discussion into a self-contained, sourced raw file.** Everything that
needs wiki context is deferred to `wiki-ingest` back in the Notes repo.

## Hard rules

- **Write ONLY** into the vault inbox. Do **NOT** create or edit any `wiki/entities/`,
  `wiki/concepts/`, `wiki/sources/`, `wiki/syntheses/`, `index.md`, `overview.md`, or
  `log.md`. No `[[wikilinks]]` to wiki pages from the captured file body — you can't
  verify they resolve. Plain prose + real source paths only.
- **Never modify the source repo** you're discussing in. Read-only.
- The captured file MUST be **self-contained**: a future reader (and the ingest agent)
  has none of this conversation. Write the conclusions/code/decisions, not "we discussed X".
- **Don't fabricate**. If you didn't actually verify a path/commit, say so inline.

## Vault path

The Notes vault lives at `$HOME/workspace/Notes` (resolve `$HOME` at runtime — the
username is NOT fixed, never hardcode an absolute `/home/<user>/...` path). The inbox is:

```
$HOME/workspace/Notes/wiki/raw/inbox/
├── inbox.md            # the queue table (append a row)
├── _README.md          # conventions
└── <YYYY-MM-DD>-<slug>.md   # one file per capture
```

First **resolve and verify** the inbox dir, e.g.:
`ls "$HOME/workspace/Notes/wiki/raw/inbox" 2>/dev/null`.
If it does **not** exist, the vault may have moved or this machine differs — **ask the
user where the Notes vault is** (use the question tool) instead of guessing or creating
it. Do not scaffold the vault structure from another repo.

## Procedure

1. **Confirm scope with the user.** What exactly is worth keeping — the conclusion, a
   code snippet, an architecture insight, a decision? Capture that, not the whole chat.
2. **Gather source provenance** from the current repo (this is the file's "URL"):
   - repo name + local path (`git rev-parse --show-toplevel`)
   - remote URL (`git remote get-url origin`, if any)
   - commit (`git rev-parse HEAD`) and branch
   - the specific file paths / functions the discussion touched
   - today's date (ask the user or use the known current date; do NOT invent one)
3. **Pick a slug** (kebab-case, from the topic or the user's argument).
4. **Write** `$HOME/workspace/Notes/wiki/raw/inbox/<YYYY-MM-DD>-<slug>.md` (resolve
   `$HOME`) using the template below.
5. **Append a row** to `inbox.md`'s queue table: `TODO` status, date, link to the file,
   one-line summary, source repo. Update its `updated:` frontmatter.
   (Queue statuses: `TODO` = not yet ingested, `DONE` = ingested, `STALE` = a `DONE`
   source was later edited and needs re-ingesting. Capture always writes `TODO`.)
6. **Tell the user** it's queued, and that ingest happens later via `/wiki-ingest` in the
   Notes repo. Do NOT attempt ingest from here.

## Captured file template

```markdown
# <标题>（raw / inbox）

> 跨 repo 讨论的捕获快照（只读归档，待 ingest）。
> - **来源 repo**：`<repo 名>`
> - **本地路径**：`<绝对路径>`
> - **remote**：<URL 或 "无">
> - **commit**：`<full sha>`（<分支>）
> - **相关文件**：`path/a.cpp`, `path/b.h:120`
> - **捕获日期**：<YYYY-MM-DD>
> - **置信度/边界**：<哪些是亲自核实的；哪些是推断、待 ingest 时核对>

---

## 结论 / 要点
<自包含地写清结论。代码片段用 fenced block。决策写明理由。>

## 待 ingest 时处理
- <可能涉及的实体/概念，留给 ingest 时去 wiki 里搜索/建页 —— 这里只提名字，不建链接>
```

## Completion check
- [ ] File written under `wiki/raw/inbox/`, self-contained, with full provenance header.
- [ ] A `TODO` row appended to `inbox.md`; its `updated:` bumped.
- [ ] NO wiki entity/concept/index/log page was touched.
- [ ] NO `[[wikilink]]` in the captured body (deferred to ingest).
- [ ] NO file in the source repo was modified.
- [ ] User told that ingest is a separate later step (`/wiki-ingest` in Notes repo).
