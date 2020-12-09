# Git Sync

A GitHub Action for syncing between two independent repositories using **force push**.

## Features

- Sync branches between two GitHub repositories
- Sync branches to/from a remote repository
- GitHub action can be triggered on a timer or on push
- To sync with current repository, please checkout [Github Repo Sync](https://github.com/marketplace/actions/github-repo-sync)
- Optional _git-sync_ commit with a specific user

## Usage

> Always make a full backup of your repo (`git clone --mirror`) before using this action.

- Either generate different ssh keys for both source and destination repositories or use the same one for both, leave passphrase empty (note that GitHub deploy keys must be unique)

```sh
$ ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

- In GitHub, either:

  - add the unique public keys (`key_name.pub`) to _Repo Settings > Deploy keys_ for each repository respectively and allow write access for the destination repository

  or

  - add the single public key (`key_name.pub`) to _Personal Settings > SSH keys_

- Add the private key(s) to _Repo > Settings > Secrets_ for the repository containing the action (`SSH_PRIVATE_KEY` or `SOURCE_SSH_PRIVATE_KEY` and `DESTINATION_SSH_PRIVATE_KEY`)

### GitHub Actions

```yml
# .github/workflows/repo-sync.yml

on: push
jobs:
  repo-sync:
    runs-on: ubuntu-latest
    steps:
      - name: repo-sync
        uses: wei/git-sync@v2
        with:
          source_repo: "username/repository"
          destination_repo: "git@github.com:org/repository.git"
          source_branch: "main" # [regexp] optional, will sync all by default
          destination_branch: "main" # [string] optional, will sync all by default
          ssh_private_key: ${{ secrets.SSH_PRIVATE_KEY }} # optional
          source_ssh_private_key: ${{ secrets.SOURCE_SSH_PRIVATE_KEY }} # optional, will override `SSH_PRIVATE_KEY`
          destination_ssh_private_key: ${{ secrets.DESTINATION_SSH_PRIVATE_KEY }} # optional, will override `SSH_PRIVATE_KEY`
          commit_user_email: ${{ secrets.COMMIT_USER_EMAIL }} # optional, will trigger 'git-sync' commit
          commit_user_name: ${{ secrets.COMMIT_USER_NAME }} # optional, will trigger 'git-sync' commit
          sync_tags: ${{ secrets.SYNC_TAGS }} # optional, will sync all tags
```

##### Alternative using https

The `ssh_private_key`, `source_ssh_private_key` and `destination_ssh_private_key` can be omitted if using authenticated https urls.

```yml
source_repo: "https://username:personal_access_token@github.com/username/repository.git"
```

### Docker

```sh
$ docker run --rm -e "SSH_PRIVATE_KEY=$(cat ~/.ssh/id_rsa)" $(docker build -q .) \
  $SOURCE_REPO $DESTINATION_REPO $SOURCE_BRANCH $DESTINATION_BRANCH
```

## Author

[Wei He](https://github.com/wei) _github@weispot.com_

## License

[MIT](https://wei.mit-license.org)
