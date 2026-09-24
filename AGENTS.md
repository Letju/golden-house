# AGENTS.md

Guidelines for every contributor (human or AI agent) working on this repository.
This project is evaluated on its **DevOps practices**: the Git history, the pull requests
and the CI/CD pipelines are part of the deliverable. Follow these rules strictly.

---

## 1. Golden rules

1. **Never push directly to `main`.** Every change goes through a branch and a pull request.
2. **Never force-push** to `main` or `develop`, and never rewrite history that has been shared.
3. **Everything in English**: code, identifiers, comments, commit messages, branch names, PR titles and descriptions, issues, documentation.
4. **One branch = one purpose.** Keep branches small, focused and short-lived.
5. **CI must be green before merging.** A failing pipeline blocks the merge, no exceptions.
6. **Never commit secrets** (passwords, tokens, API keys, `.env` files, private keys).
7. **Small, atomic commits** with meaningful messages. The history must tell the story of the project.

---

## 2. Branching strategy

We use a simplified **Git Flow**:

| Branch | Purpose | Protected |
|---|---|---|
| `main` | Production-ready code. Only receives merges from `develop` (releases) or `hotfix/*`. | Yes |
| `develop` | Integration branch. Receives merges from feature branches. | Yes |
| `feature/<issue-id>-<short-description>` | New feature | No |
| `fix/<issue-id>-<short-description>` | Bug fix | No |
| `hotfix/<short-description>` | Urgent fix on `main` | No |
| `chore/<short-description>` | Tooling, dependencies, config | No |
| `docs/<short-description>` | Documentation only | No |
| `ci/<short-description>` | CI/CD pipeline changes | No |
| `refactor/<short-description>` | Code restructuring without behavior change | No |
| `test/<short-description>` | Adding or fixing tests | No |

Rules:
- Branch names are **lowercase**, words separated by **hyphens**, in English.
  - ✅ `feature/12-user-authentication`
  - ❌ `Feature/Authentification_Utilisateur`
- Always branch from an **up-to-date** `develop` (or `main` for hotfixes).
- Delete the branch after it is merged.

### Standard workflow

```bash
# 1. Start from an up-to-date develop
git checkout develop
git pull origin develop

# 2. Create a dedicated branch
git checkout -b feature/12-user-authentication

# 3. Work, commit often with meaningful messages
git add <files>
git commit -m "feat(auth): add login endpoint"

# 4. Keep the branch up to date with develop
git fetch origin
git rebase origin/develop   # or: git merge origin/develop

# 5. Push the branch and open a pull request
git push -u origin feature/12-user-authentication
```

---

## 3. Commit messages — Conventional Commits

All commits follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>(<optional scope>): <short description>

<optional body: what and why, not how>

<optional footer: Closes #12, BREAKING CHANGE: ...>
```

### Allowed types

| Type | When to use it |
|---|---|
| `feat` | A new feature |
| `fix` | A bug fix |
| `docs` | Documentation only |
| `style` | Formatting, whitespace, no code logic change |
| `refactor` | Code change that neither fixes a bug nor adds a feature |
| `perf` | Performance improvement |
| `test` | Adding or updating tests |
| `build` | Build system or dependencies (Dockerfile, package manager…) |
| `ci` | CI/CD configuration (GitHub Actions, GitLab CI…) |
| `chore` | Maintenance tasks that do not touch source or tests |
| `revert` | Reverts a previous commit |

### Rules

- Description in **English**, **imperative mood**, **lowercase**, **no trailing period**, max ~72 characters.
  - ✅ `feat(api): add pagination to users endpoint`
  - ✅ `fix(db): handle null values in migration script`
  - ✅ `ci: add docker image build job`
  - ❌ `update`, `fix bug`, `wip`, `ajout de la fonction`, `Fixed stuff.`
- One logical change per commit. Do not mix a feature, a refactor and a formatting pass in one commit.
- Reference the related issue in the footer: `Closes #12` / `Refs #12`.
- Breaking changes: add `!` after the type (`feat(api)!: ...`) and a `BREAKING CHANGE:` footer.
- Never commit commented-out code, debug prints, or generated/build artifacts.

---

## 4. Pull requests

### Before opening a PR
- [ ] The branch is up to date with its target branch.
- [ ] The code builds and runs locally.
- [ ] Linter and formatter pass.
- [ ] Tests pass locally and new code is covered by tests.
- [ ] No secrets, no debug code, no unrelated changes.
- [ ] Documentation (README, comments) is updated if needed.

### PR title
Same format as a commit message: `feat(auth): add JWT-based login`.

### PR description template

```markdown
## Description
What does this PR do and why?

## Related issue
Closes #<issue-number>

## Type of change
- [ ] Feature
- [ ] Bug fix
- [ ] Refactor
- [ ] Documentation
- [ ] CI/CD

## How has this been tested?
Describe the tests run and how to reproduce them.

## Checklist
- [ ] CI is green
- [ ] Tests added or updated
- [ ] Documentation updated
- [ ] No secrets committed
```

### Review and merge rules
- At least **one approval** from another team member is required.
- All review comments must be **resolved** before merging.
- The author does not approve their own PR.
- All required CI checks must pass.
- Prefer **squash and merge** for feature branches (clean history on `develop`),
  and a **merge commit** for `develop` → `main` releases.
- Keep PRs small (ideally < 400 changed lines). Split large work into several PRs.

---

## 5. CI/CD

The pipeline is defined as code in the repository (e.g. `.github/workflows/` or `.gitlab-ci.yml`).

### Continuous Integration (on every push and every PR)
1. **Install** dependencies (with caching).
2. **Lint** and check formatting.
3. **Build** the project.
4. **Test**: unit tests, then integration tests; publish the coverage report.
5. **Security**: dependency vulnerability scan, secret scanning.
6. **Docker** (if applicable): build the image to make sure it builds.

### Continuous Delivery / Deployment
- On merge to `develop`: deploy to a **staging** environment.
- On merge to `main` or on a version tag (`vX.Y.Z`): build, tag and publish the release artifacts / Docker image, then deploy to **production**.
- Deployments must be **reproducible** and **automated**: no manual steps on servers.

### Rules
- Never disable, skip or comment out a failing check to get a PR merged: fix the cause.
- Pipeline secrets are stored in the CI platform's **secret store**, never in the YAML files.
- Pin versions of actions, base images and tools (no `latest` in production).
- Keep pipelines fast: use caching and run independent jobs in parallel.

---

## 6. Branch protection (repository settings)

Configure on `main` (and `develop`):
- Require a pull request before merging.
- Require at least 1 approval.
- Require status checks to pass before merging.
- Require branches to be up to date before merging.
- Require conversation resolution before merging.
- Block force pushes and branch deletion.

---

## 7. Code conventions

- **Language**: all code, identifiers, comments, logs and error messages are in **English**.
- **Naming**: descriptive names; follow the idiomatic convention of the language
  (e.g. `snake_case` in Python, `camelCase` in JavaScript/Java, `PascalCase` for classes).
- **Comments** explain *why*, not *what*. Keep them short and up to date.
- Public functions/classes have a docstring or doc comment.
- Follow the project's linter and formatter configuration; do not reformat unrelated files.
- No dead code, no commented-out code, no hard-coded credentials or environment-specific values:
  use environment variables and configuration files.

---

## 8. Testing

- Every feature or bug fix comes with tests.
- A bug fix should include a test that reproduces the bug.
- Tests must be deterministic and runnable locally with a single command.
- Do not merge code that lowers the test coverage without a justification in the PR.

---

## 9. Security and secrets

- `.env`, credentials, keys and certificates are listed in `.gitignore`.
- Provide a `.env.example` with placeholder values to document required variables.
- If a secret is committed by mistake: **revoke/rotate it immediately**, then remove it from the history.
- Keep dependencies up to date (e.g. Dependabot / Renovate) and review their PRs like any other.

---

## 10. Versioning and releases

- Follow [Semantic Versioning](https://semver.org/): `MAJOR.MINOR.PATCH`.
- Releases are created from `main` with an annotated tag: `git tag -a v1.2.0 -m "Release v1.2.0"`.
- Maintain a `CHANGELOG.md` (can be generated from Conventional Commits).

---

## 11. Issues and project tracking

- Every piece of work starts with an **issue** (title and description in English).
- Use labels (`feature`, `bug`, `documentation`, `ci`, …) and link issues to PRs.
- Track progress on a project board (To do → In progress → In review → Done).

---

## 12. Instructions specific to AI agents

- Never commit or push to `main` or `develop`. Always work on a dedicated branch following section 2.
- Never merge a pull request, force-push, rewrite history or change repository settings unless explicitly asked.
- Write commits following section 3; one logical change per commit.
- Run the linter and the test suite before proposing a commit.
- Do not add or modify CI secrets, and never write secrets in files.
- Keep all generated code, comments and messages in English.
- Do not make changes outside the scope of the current task; mention unrelated issues instead of fixing them silently.
