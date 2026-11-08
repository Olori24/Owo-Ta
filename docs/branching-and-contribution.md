# Branching and contribution rules

## Ownership and control

- All original source code is maintained in the Olori24/owo-ta repository.
- The repository owner remains the source of truth for release, distribution, and commercial direction.
- No third-party paid build or game-generation service is required for the project core.

## Branching model

- `main`: protected release branch.
- `develop`: integration branch for active work.
- Feature branches: `feature/<short-name>`
- Fix branches: `fix/<short-name>`
- Hotfix branches: `hotfix/<short-name>`

## Contribution rules

1. All work must be merged into `develop` or a feature branch via pull request.
2. No direct pushes to `main` when pull requests are available.
3. Every pull request must include a brief technical rationale and validation evidence.
4. Larger design changes must include docs updates.
5. Asset usage must be reviewed against the licensing register before submission.
6. Secrets, credentials, and platform-generated files must never be committed.

## Validation gate

Before merge, a pull request should show:

- project validation passing in CI,
- no unresolved licensing issues,
- an explanation of the actual milestone being delivered, and
- proof of any required export or gameplay validation result.
