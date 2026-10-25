# Git & GitHub Workflow — 6 Members

This guide is written so that **each of the 6 members gets their own commits,
their own branch and their own pull request** in the same repository. That is
what makes GitHub show 6 contributors instead of 1.

Read [Part 0](#part-0-how-this-works) once as a group, then each person only
needs their own section.

---

## Part 0. How this works

### The problem

GitHub counts a contribution by **commit author email**, not by folder. If one
person commits the whole project and pushes it, GitHub shows **1 contributor**.
The other 5 members would have nothing in the history.

### The plan

```
main ──●─────────────────●────────●────────●────────●────────●────────●──►
        │ initial import  │        │        │        │        │        │
        │ (repo owner)    │        │        │        │        │        │
        └─ feature/1 ─────┘        │        │        │        │        │
           feature/2 ──────────────┘        │        │        │        │
           feature/3 ───────────────────────┘        │        │        │
           feature/4 ────────────────────────────────┘        │        │
           feature/5 ─────────────────────────────────────────┘        │
           feature/6 ──────────────────────────────────────────────────┘
```

1. **Repo owner** (Member 1) creates the GitHub repository and pushes the
   integrated codebase as the first commit on `main`.
2. **Each member** clones the repo, creates their own branch, adds their
   **task report** and takes ownership of their module's files, commits with
   their own name and email, pushes the branch, and opens a **pull request**.
3. **Repo owner** reviews and merges each pull request into `main`.

Result: 6 branches, 6 pull requests, 6 authors, a full audit trail — and `main`
stays working the whole time.

### Ownership map

| # | Member | Branch | Module | Task report |
| --- | --- | --- | --- | --- |
| 1 | Member 1 | `feature/1-core-auth` | Core, auth, security, audit | `docs/tasks/1-core-auth.md` |
| 2 | Member 2 | `feature/2-patients` | Patient management | `docs/tasks/2-patients.md` |
| 3 | Member 3 | `feature/3-doctors` | Doctor management | `docs/tasks/3-doctors.md` |
| 4 | Member 4 | `feature/4-appointments` | Appointments + conflict detection | `docs/tasks/4-appointments.md` |
| 5 | Member 5 | `feature/5-records` | Medical records, documents | `docs/tasks/5-records.md` |
| 6 | Member 6 | `feature/6-billing` | Billing, insurance, pharmacy | `docs/tasks/6-billing.md` |

Exact file lists per module: [`TEAM-TASKS.md`](TEAM-TASKS.md).

### Timeline

| Day | Who | Action |
| --- | --- | --- |
| 1 | Repo owner | Create repo, push, invite the other 5 |
| 1 | Everyone | Accept the email invitation |
| 2–3 | Everyone | Clone, branch, write task report, commit, push, open PR |
| 4 | Repo owner | Review and merge the 5 open PRs |
| 4 | Everyone | Pull `main` and confirm it still builds |
| 5 | Repo owner | Final check against the [submission checklist](#part-7-submission-checklist) |

---

## Part 1. Repo owner — one-time setup

Do this **once**. The other members start at [Part 2](#part-2-every-member).

### 1.1 Create the repository on GitHub

1. Go to <https://github.com/new>.
2. **Repository name:** `medicare-app`
3. **Visibility:** `Public` (free private repos cannot all be viewed by a
   lecturer without invites — public is simpler; make it private only if your
   university requires it).
4. **Do NOT** tick "Add a README", "Add .gitignore" or "Choose a license".
   The project already has those files.
5. Click **Create repository**.

### 1.2 Push the code

Open PowerShell **in the project folder** and run these one at a time.

```powershell
git add .
```

```powershell
git status
```

Check the list. You should see `src/`, `pom.xml`, `medicare_db.sql`,
`README.md`, `docs/` — and **no** `target/` and **no** `.idea/`. If you see
either, `.gitignore` was not applied; stop and fix that first.

```powershell
git commit -m "chore: initial import of integrated Medicare codebase"
```

```powershell
git branch -M main
```

```powershell
git remote add origin https://github.com/<YOUR-USERNAME>/medicare-app.git
```

```powershell
git push -u origin main
```

A browser window will open asking you to sign in to GitHub. **A GitHub password
will not work** — sign in through the browser window that appears. If no window
appears, install [Git Credential Manager](https://github.com/git-ecosystem/git-credential-manager)
or use a Personal Access Token as the password.

### 1.3 Invite the other 5 members

1. Repo → **Settings** → **Collaborators** (left sidebar).
2. **Add people** → type each member's GitHub username or email → **Add**.
3. Each person receives an email and must **accept** before they can push.

### 1.4 Protect `main` so nobody pushes directly

1. **Settings** → **Branches** → **Add branch protection rule**.
2. Branch name pattern: `main`
3. Tick **Require a pull request before merging**.
4. Leave everything else default and **Save**.

This guarantees every member's work arrives as a pull request, which is exactly
what you want to show in the report.

---

## Part 2. Every member

You need: Git installed, a GitHub account, and an accepted collaborator
invitation.

### 2.1 Install Git (skip if `git --version` already works)

<https://git-scm.com/download/win> → run the installer → accept the defaults.

Then close and reopen PowerShell and check:

```powershell
git --version
```

### 2.2 Set your identity — this is the most important step

Your commits carry a name and an email. **The email must be one linked to your
GitHub account**, otherwise GitHub shows a grey avatar and does not count you as
a contributor.

Find your GitHub email:

1. <https://github.com/settings/emails>
2. If **Keep my email addresses private** is ticked, GitHub shows something like
   `12345678+yourusername@users.noreply.github.com`.
   **Use that address.** It is the safest option — it is linked to your account
   and does not expose your real email.

Then, **inside the cloned project folder** (step 2.3), run:

```powershell
git config --local user.name "Your Full Name"
git config --local user.email "12345678+yourusername@users.noreply.github.com"
```

Verify:

```powershell
git config --get user.name
git config --get user.email
```

> `--local` means this applies only to this repository and will not overwrite
> settings for your other projects.

### 2.3 Clone the repository

Pick a short path with **no spaces and no brackets**. The current folder name
`medicare-app (3)` will cause trouble with Maven and Tomcat.

```powershell
cd C:\
mkdir dev -Force
cd C:\dev
git clone https://github.com/<OWNER-USERNAME>/medicare-app.git
cd medicare-app
```

### 2.4 Create your branch

Use the branch name from the table in [Part 0](#ownership-map). Never work
directly on `main`.

```powershell
git switch -c feature/2-patients
```

Confirm:

```powershell
git branch
```

Your branch should have a `*` next to it.

### 2.5 Create your task report

```powershell
Copy-Item docs\tasks\TEMPLATE.md docs\tasks\2-patients.md
```

Open the new file in your editor and fill in every section. Replace the
`&lt;...&gt;` placeholders and delete the sections that do not apply.

This report is the part of the project that is **unambiguously yours**, so give
it real content: what you built, how the flow works, what you tested, what broke
and how you fixed it.

### 2.6 Make your contribution to your module

Pick at least one real improvement inside your own module — do not edit other
people's files:

- Add a Javadoc header with `@author Your Name` to each file you own.
- Fix a bug you find while testing your module.
- Improve validation or an error message.
- Add a missing feature from your module's "Key deliverables" list in
  [`TEAM-TASKS.md`](TEAM-TASKS.md).

Example header, added to the top of a class you own:

```java
/**
 * Handles patient directory requests.
 *
 * @author Your Full Name
 */
public class PatientServlet extends HttpServlet {
```

Keep each commit focused. Three small commits are better than one giant one.

### 2.7 Commit

```powershell
git status
```

Review the list. You should only see files from **your** module plus your task
report. Then:

```powershell
git add .
```

```powershell
git commit -m "feat(patients): add patient directory and portal view"
```

Commit message convention — `<type>(<scope>): <what changed>`:

| Type | Use for |
| --- | --- |
| `feat` | a new feature |
| `fix` | a bug fix |
| `docs` | documentation only |
| `refactor` | code restructure, no behaviour change |
| `chore` | build, config, tooling |

### 2.8 Push

```powershell
git push -u origin feature/2-patients
```

Expected output ends with a link like
`https://github.com/OWNER/medicare-app/pull/new/feature/2-patients`.

### 2.9 Open the pull request

1. Open the repository on GitHub. A yellow **Compare & pull request** banner
   should appear — click it. Otherwise go to **Pull requests** → **New pull
   request** and choose your branch.
2. **Title:** `feat(patients): patient management module`
3. **Description:** 3–5 lines — what you did, which files changed, how to test.
   Reference your task report file.
4. **Create pull request.**

Do not merge your own PR — the owner merges (Part 3).

---

## Part 3. Repo owner — review and merge

For each of the 5 open pull requests:

1. Open the PR → **Files changed**. Confirm the author only touched their own
   module (compare against [`TEAM-TASKS.md`](TEAM-TASKS.md)).
2. Click **Add a comment** → leave a short review note. A review thread is good
   evidence of teamwork.
3. Click **Merge pull request** → choose **Create a merge commit**
   (not "Squash and merge" — a merge commit preserves the member as the commit
   author).
4. **Delete branch** afterwards.

Then tell everyone to update their local copy:

```powershell
git switch main
git pull
```

---

## Part 4. Rules for everyone

1. **Never commit to `main` directly.** Always branch.
2. **Never commit `target/`, `.idea/`, `*.iml`, `*.war` or `*.log`.** Already
   handled by `.gitignore` — do not bypass it with `git add -f`.
3. **Never commit real passwords.** `DBConnection.java` uses an empty local
   root password on purpose; keep it that way and put your own password in a
   local file that is ignored.
4. **Do not reformat files you do not own.** It creates huge diffs and merge
   conflicts.
5. **Pull before you start work** each day:
   ```powershell
   git switch main
   git pull
   git switch feature/2-patients
   git merge main
   ```
6. **Commit small, commit often**, with meaningful messages.

---

## Part 5. Troubleshooting

| Symptom | Cause | Fix |
| --- | --- | --- |
| `'git' is not recognized` | Git not installed / not on PATH | Install Git for Windows, reopen PowerShell |
| `remote: Permission to ... denied` | Invitation not accepted, or wrong account signed in | Accept the email invite; Windows → Credential Manager → remove `git:https://github.com` and sign in again |
| `Support for password authentication was removed` | Used a GitHub password | Use the browser sign-in or a Personal Access Token |
| `Updates were rejected because the remote contains work` | `main` moved since you branched | `git pull --rebase origin main` then push again |
| `error: failed to push some refs` | Branch protection is on | You are pushing to `main` — push your `feature/...` branch instead |
| Commits show the wrong name | Identity set after committing | `git commit --amend --reset-author --no-edit` for the last commit |
| Commits show a grey avatar, not counted | Email not linked to GitHub | Set the `users.noreply.github.com` email from §2.2, amend, force-push your own branch |
| `LF will be replaced by CRLF` warning | Windows line endings | Harmless; `.gitattributes` normalises it |
| Merge conflict in a file you do not own | Someone edited shared files | Ask in the group chat; resolve together, never delete the other person's work |
| Build fails before your changes | A dependency PR is not merged yet | `git merge main` into your branch |

### I committed to `main` by mistake

Do not force-push. Move the commit to a branch:

```powershell
git switch -c feature/2-patients
git switch main
git reset --hard origin/main
git switch feature/2-patients
```

---

## Part 6. No-terminal option (GitHub Desktop)

If a member is not comfortable with PowerShell:

1. Install [GitHub Desktop](https://desktop.github.com/) and sign in.
2. **File → Clone repository** → choose `medicare-app`.
3. **Branch → New branch** → `feature/2-patients`.
4. Edit files in VS Code or IntelliJ.
5. GitHub Desktop shows the changed files on the left → write a summary →
   **Commit to feature/2-patients**.
6. Click **Publish branch**.
7. Go to the GitHub website and open the pull request as in §2.9.

`git config` is not needed — GitHub Desktop uses your signed-in account.

---

## Part 7. Submission checklist

Run these in the repo folder and keep the output for your report.

```powershell
git log --oneline --graph --all
```

```powershell
git shortlog -sne --all
```

`git shortlog` must list **all 6 members** with a non-zero commit count.

| # | Check | Done |
| --- | --- | --- |
| 1 | `main` builds: `.\mvnw.cmd clean package` produces a `.war` | ☐ |
| 2 | The app runs on Tomcat 9 and login works for all 3 roles | ☐ |
| 3 | `git shortlog -sne --all` lists 6 contributors | ☐ |
| 4 | 6 branches exist, each merged via its own pull request | ☐ |
| 5 | `docs/tasks/` contains 6 filled-in reports | ☐ |
| 6 | `README.md` team table has real names and GitHub usernames | ☐ |
| 7 | `docs/TEAM-TASKS.md` has no remaining placeholder text | ☐ |
| 8 | No `target/`, `.idea/`, `*.war` or passwords in the repository | ☐ |
| 9 | Screenshots added to `docs/screenshots/` and referenced in the reports | ☐ |

---

## Part 8. If your lecturer requires per-line code authorship

The plan above gives each member a branch, a PR and their module's files, but the
first import commit was made by the repo owner, so GitHub's blame on the very
first version points at the owner.

If your lecturer explicitly checks who *originally wrote* each line, use this
variant instead of Part 1.2:

1. Repo owner commits **only** the shared scaffolding:
   `pom.xml`, `.gitignore`, `.gitattributes`, `mvnw*`, `.mvn/`, `medicare_db.sql`,
   `README.md`, `docs/`, `WEB-INF/web.xml`, `util/DBConnection.java`,
   `factory/DAOFactory.java`.
2. Each member's pull request then **adds their module's files** (they already
   have a copy of the project from the group folder) plus their task report.
3. Member 1's PR adds the core/auth files, and is merged **first** so the other
   branches have something to compile against.

Trade-off: `main` will not compile until the last PR is merged. That is normal
for parallel development, but do not use this variant if the deadline is close.
