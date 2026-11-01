<img src="https://raw.githubusercontent.com/denzyldick/phanalist/main/docs/branding/banner-cropped.png"/>

[![CI](https://github.com/denzyldick/phanalist-action/actions/workflows/ci.yml/badge.svg)](https://github.com/denzyldick/phanalist-action/actions)

> GitHub Action for [Phanalist](https://github.com/denzyldick/phanalist) — a performant static analyzer for PHP, written in Rust. Catches common mistakes and enforces best practices with zero configuration required.

---

### Installation

Paste this step into your existing workflow:

```yaml
      - uses: denzyldick/phanalist-action@v1
        with:
          src: .
```

---

### Usage

```yaml
name: Phanalist
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
jobs:
  analyze:
    runs-on: ubuntu-latest
    permissions:
      security-events: write
      contents: read
    steps:
      - uses: actions/checkout@v4
      - uses: denzyldick/phanalist-action@v1
        with:
          src: .
```

The action does not check out your repository. Run `actions/checkout` before it.

### Inputs

| Input | Default | Description |
| :--- | :--- | :--- |
| `src` | `.` | Path to project sources, relative to the workspace root or absolute. |
| `version` | `latest` | Phanalist release to install, for example `1.2.0` or `v1.2.0`. |
| `include_rule_descriptions` | `true` | Append each rule's full documentation to inline pull request annotations. Set to `false` for shorter messages. |

By default, the action appends each rule's full documentation to the SARIF result message, so inline pull request annotations show the same explanation as the rule page.

### What it does

1. Downloads the requested `phanalist` release
2. Runs `phanalist` with SARIF output
3. Optionally appends full rule documentation to the SARIF messages
4. Uploads the results for GitHub code scanning

Results appear under the **Security** tab → **Code scanning** in your repository.

### Rules

Phanalist ships with built-in rules covering architecture, runtime risk, security, and code quality. See the [Phanalist rules documentation](https://github.com/denzyldick/phanalist#rules) for the complete list and configuration options.
