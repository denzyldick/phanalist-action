<img src="https://raw.githubusercontent.com/denzyldick/phanalist/main/docs/branding/banner-cropped.png"/>

[![CI](https://github.com/denzyldick/phanalist-action/actions/workflows/ci.yml/badge.svg)](https://github.com/denzyldick/phanalist-action/actions)

> GitHub Action for [Phanalist](https://github.com/denzyldick/phanalist) — a performant static analyzer for PHP, written in Rust. Catches common mistakes and enforces best practices with zero configuration required.

---

### Installation

Paste this step into your existing workflow:

```yaml
      - uses: denzyldick/phanalist-action@v0.1.22
        with:
          src: /app
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
      - uses: denzyldick/phanalist-action@v0.1.22
        with:
          src: /app
```

The `src` input is the path to your project sources (relative to workspace root).

By default, the action appends each rule's full documentation to the SARIF result message, so inline pull request annotations show the same explanation as the rule page. Set `include_rule_descriptions: false` to keep the shorter violation message.

### What it does

1. Downloads the latest `phanalist` binary
2. Runs `phanalist` with SARIF output
3. Uploads results as a SARIF file for GitHub code scanning

Results appear under the **Security** tab → **Code scanning** in your repository.

### Rules

| Code | Name | Options |
| :--: | :--- | :------ |
| E0000 | Example rule | |
| E0001 | Opening tag position | |
| E0002 | Empty catch | |
| E0003 | Method modifiers | |
| E0004 | Uppercase constants | |
| E0005 | Capitalized class name | |
| E0006 | Property modifiers | |
| E0007 | Method parameters count | `check_constructor: true`, `max_parameters: 5` |
| E0008 | Return type signature | |
| E0009 | Cyclomatic complexity | `max_complexity: 10` |
| E0010 | Npath complexity | `max_paths: 200` |
| E0011 | Detect error suppression symbol (`@`) | |
| E0012 | Service compatibility with Shared Memory Model | `include_namespaces`, `exclude_namespaces`, `reset_interfaces` |
| E0013 | Private method not being used | |
| E0014 | Law of Demeter | |
| E0015 | Lack of Cohesion of Methods (LCOM4) | `threshold: 1` |
| E0016 | Cognitive complexity | `max_complexity: 15` |
| E0017 | Coupling Between Objects (CBO) | `max_coupling: 10` |
| E0018 | Weighted Methods per Class (WMC) | `max_wmc: 50` |
| E0019 | Response For a Class (RFC) | `max_rfc: 50` |
| E0020 | Depth of Inheritance Tree (DIT) | `max_depth: 4` |
| E0021 | Number of Children (NOC) | `max_children: 15` |
| E0022 | Afferent and Efferent Coupling (Ca/Ce) | `max_ca: 20`, `max_ce: 20` |
| E0023 | Instability, Abstractness, Distance (I/A/D) | `max_instability: 0.8`, `max_abstractness: 0.8`, `max_distance: 0.5` |
| E0024 | Lines of Code per Method | `max_loc: 30` |
| E0025 | Lines of Code per File | `max_loc: 500` |
| E0026 | Comment Ratio | `min_ratio: 0.1`, `max_ratio: 0.5` |
| E0027 | God Class (Brain Class) | `max_methods: 15`, `max_fields: 10` |
| E0028 | Data Class | `max_getter_setter_ratio: 0.7`, `min_methods: 3` |
| E0029 | Fan-in / Fan-out | `max_fan_out: 10`, `max_fan_in: 20` |
| E0030 | Cyclomatic Complexity Density | `max_density: 0.3` |
