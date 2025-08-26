# Agent Contribution Guidelines

This repository welcomes contributions from both humans and automation agents. Follow these practices to keep the workflow reliable and consistent with the latest agent tooling.

## Workflow
- Work directly on the `main` branch. Avoid creating new branches.
- Keep commits focused; write present-tense, imperative commit messages.
- Reference this `AGENTS.md` file in your pull requests so future agents can find it.

## Code Style
- Python code uses [Black](https://black.readthedocs.io/) formatting with a line length of 88, [isort](https://pycqa.github.io/isort/), and [Flake8](https://flake8.pycqa.org/).
- Run formatting and linting via pre-commit on the files you modify:
  ```bash
  pre-commit run --files <file1> <file2>
  ```
- Detect secret leaks with `pre-commit`'s `detect-secrets` hook.

## Testing
- If your change impacts code behavior, run the test suite:
  ```bash
  pytest
  ```
- Document test outcomes in your pull request.

## Tooling
- Install and configure development tools:
  ```bash
  make install      # install pre-commit hooks
  make precommit    # run all hooks on the entire repo
  ```
- Use Python 3.11+ and virtual environments for isolation.

## Documentation
- Update or add documentation and examples alongside code changes.
- Keep lines under 120 characters and use Markdown headings for structure.

Adhering to these guidelines helps maintain automation-friendly workflows and keeps the project aligned with modern agent practices.
