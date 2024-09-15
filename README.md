# gh-actions-git-secret-protector

[![GitHub Action](https://img.shields.io/badge/action-git--secret--protector-blue?logo=github)](https://github.com/c0x12c/gh-actions-git-secret-protector)
[![License: Apache 2.0](https://img.shields.io/badge/license-Apache%202.0-green)](https://opensource.org/licenses/Apache-2.0)

A GitHub Action that uses [git-secret-protector](https://pypi.org/project/git-secret-protector/) to decrypt secrets in a `git-secret-protector` protected repository during a workflow run. The action cleans up the decrypted secrets after the job completes to maintain security.

## Table of Contents


## Features

- **Automated Decryption**: Seamlessly decrypts encrypted files using `git-secret-protector`.
- **Cleanup**: Securely removes decrypted secrets after the workflow execution.

## Usage

Include this action as a step in your workflow. Provide the required inputs for your environment and AES key.

### Inputs

- **`environment`** (required): The environment name associated with the AES key (e.g., `dev`, `prod`).
- **`aes-key`** (required): The AES key used for decryption. Store this securely, such as in GitHub Secrets.

### Example Workflow

```yaml
name: 'Build and Deploy'

on:
  push:
    branches:
      - main
      - develop

jobs:
  build-deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Decrypt Secrets
        uses: c0x12c/git-secret-protector@v1
        with:
          filter: 'app-dev'

      # Add steps that require the decrypted secrets here
      - name: Your Build Step
        run: |
          echo "Building application..."
          # Your build commands here
          
      # The action will automatically clean up the secrets after this point
```

## License

This project is licensed under the Apache License 2.0.

## Contributing
Contributions are welcome! Please:

- Fork the repository.
- Create a new branch.
- Commit your changes.
- Submit a pull request.

- For major changes, please open an issue first to discuss them.
