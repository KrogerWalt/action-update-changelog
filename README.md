# Action Update Changelog

[![actions-workflow-lint][actions-workflow-lint-badge]][actions-workflow-lint]
[![release][release-badge]][release]
[![license][license-badge]][license]


This is a GitHub Action to update a changelog file based on git commits. If one is not found, a blank one will be
created based on this [template](https://keepachangelog.com/en/1.0.0/) and updated going forward. 
The action will NOT attempt to create a complete changelog based on previous commits.

The action assumes you use semver and a ticketing system, and that you format branch names according to 
`TICKET-ID/ChangeType/Description_of_change`.

For example, if a pull request being merged has the branch `PROJ-1234/Added/Update_profile_picture`, this action
will update the changelog to have a new entry like:

## [v1.7.2] - 2021-05-27
### Added
- Update profile picture

### Referenced Issues
- [PROJ-1234](https://jira.yourcompany.com/jira/browse/PROJ-1234)


## Inputs

|         NAME        |                                                                         DESCRIPTION                                                                      |   TYPE   | REQUIRED |     DEFAULT      |
| ------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | -------- | ---------------- |
| `branch_name`       | Overrides the branch name to parse for the message. Default is name of current branch.                                                                   | `string` | `false`  | `current branch` |
| `changelog_file`    | Overrides the path to the changelog. Default is ./CHANGELOG.md                                                                                           | `string` | `false`  | CHANGELOG.md     |
| `ticket_url_prefix` | If provided, will be used to create a link for referenced issues. (Make sure to include ending slash if needed. This allows ticket to be param as well.) | `string` | `false`  | `N/A`            |
| `version`           | The version of the release will be added above this and the other unreleased changes. If not supplied this change will be added to unreleased changes.   | `string` | `false`  | `N/A`            |


## Outputs

|    NAME     |                  DESCRIPTION                     |   TYPE   |
|-------------|--------------------------------------------------|----------|
| `change_md` | The Markdown that was generated for this change. | `string` |

## Example

### Simple

```yaml
name: Update Changelog

on:
  pull_request:
    types: [closed]

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
        with: 
          fetch-depth: 0

      - uses: KrogerWalt/action-get-latest-tag@v2
        id: get-latest-tag

      - uses: actions-ecosystem/action-bump-semver@v1
        id: bump-semver
        if: ${{ steps.release-label.outputs.level != null }}
        with:
          current_version: ${{ steps.get-latest-tag.outputs.tag }}
          level: ${{ steps.release-label.outputs.level || 'patch' }}
        
      - uses: KrogerWalt/action-update-changelog@v1
        id: changelog-update
        if: ${{ github.event.pull_request.merged == true }}
        with:
          ticket_url_prefix: https://jira.yourcompany.com/jira/browse/
          version: ${{ steps.bump-semver.outputs.new_version }}

      - name: Push Changelog to git
      ...
```

## License

Copyright 2021 KrogerWalt.

Action Release Label is released under the [Apache License 2.0](./LICENSE).

<!-- badge links -->

[actions-workflow-lint]: https://github.com/KrogerWalt/action-update-changelog/actions?query=workflow%3ALint
[actions-workflow-lint-badge]: https://img.shields.io/github/workflow/status/KrogerWalt/action-update-changelog/Lint?label=Lint&style=for-the-badge&logo=github

[release]: https://github.com/KrogerWalt/action-update-changelog/releases
[release-badge]: https://img.shields.io/github/v/release/KrogerWalt/action-update-changelog?style=for-the-badge&logo=github

[license]: LICENSE
[license-badge]: https://img.shields.io/github/license/KrogerWalt/action-update-changelog?style=for-the-badge
