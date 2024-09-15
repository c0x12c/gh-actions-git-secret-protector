# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

**Note**: Ensure to keep this changelog updated with every new release or change made to the project.

## [v1.0.0] - 2024-09-15

### Added
- Initial release of the GitHub Actions plugin to support decrypting secrets in repositories using `git-secret-protector`.
- Configured post-job cleanup to re-encrypt the secrets and remove the working folder.
- Integrated a Docker-based action that runs `git-secret-protector` to decrypt and encrypt files based on a provided filter.
- Created unit tests to verify the decryption and re-encryption process within the action.
