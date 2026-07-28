# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

**Note**: Ensure to keep this changelog updated with every new release or change made to the project.

## [v1.1.7] - 2026-07-28

### Changed
- Upgrade `git-secret-protector` to `v1.8.0` (fail-closed decrypt on unsupported format + `doctor` supported-schemes).

## [v1.1.6] - 2026-07-27

### Changed
- Upgrade `git-secret-protector` to `v1.7.1` (from v1.2.4), rebuilding the `:1` image.

### Fixed
- Restore GHCR publishing, which had been broken since v1.1.2 (`installation not allowed to Write organization package`). The workflow now authenticates with the built-in `GITHUB_TOKEN` (`packages: write`) after granting this repository the Write role under the package's *Manage Actions access*, replacing the expired user PAT (a third-party GitHub App installation token is not permitted to write org-owned packages).

## [v1.1.2] - 2025-03-30

### Changed
- Upgrade `git-secret-protector` to v1.2.4

## [v1.1.1] - 2024-10-21

### Changed
- Upgrade `git-secret-protector` to v1.0

## [v1.1.0] - 2024-10-20

### Changed
- Upgrade `git-secret-protector` to v0.8.0

## [v1.0.6] - 2024-09-17

### Added
- Support stripped tags.

## [v1.0.5] - 2024-09-17

### Added
- Install GCloud CLI in the Docker image.

## [v1.0.3] - 2024-09-15

### Changed
- Use image v1.0.

## [v1.0.2] - 2024-09-15

### Fixed
- Enhance the publish workflow to use PAT for authentication to GHCR.

## [v1.0.1] - 2024-09-15

### Fixed
- Fixed release workflow scripts.

## [v1.0.0] - 2024-09-15

### Added
- Initial release of the GitHub Actions plugin to support decrypting secrets in repositories using `git-secret-protector`.
- Configured post-job cleanup to re-encrypt the secrets and remove the working folder.
- Integrated a Docker-based action that runs `git-secret-protector` to decrypt and encrypt files based on a provided filter.
- Created unit tests to verify the decryption and re-encryption process within the action.
