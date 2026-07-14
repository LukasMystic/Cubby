# Cubby

## Requirements

- Xcode 15+
- iOS 17+ / macOS 14+

## Getting started

Open `Cubby.xcodeproj` in Xcode and run (⌘R).

## Contributing

### Commit convention

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <what changed>
```

The header is mandatory; the scope is optional.

**Types:** `build`, `ci`, `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, `style`

**Examples:**

```
feat(game): add game screen
fix: add navigation to game page
docs: update setup instructions
```

### Branching

- Branch off `main` for every change.
- Name branches `<type>/<page-or-feature>`, using the same types as commits (e.g. `feat/storybook-page`, `fix/game-page`).
- Never force push; never skip hooks.
- Open a PR — don't commit directly to `main`.
