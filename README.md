# Git Sync

A GitHub Action for syncing between two independent repositories using **force push**.

## Features

- Sync branches between two GitHub repositories
- Sync branches to/from a remote repository
- GitHub action can be triggered on a timer or on push
- To sync with current repository, please checkout [Github Repo Sync](https://github.com/marketplace/actions/github-repo-sync)

## Usage

> Always make a full backup of your repo (`git clone --mirror`) before using this action.

### GitHub Actions

```yml
# .github/workflows/git-sync.yml

on: push
jobs:
  git-sync:
    runs-on: ubuntu-latest
    steps:
      - name: git-sync
        uses: wei/git-sync@v3
        with:
          source_repo: "source_org/repository"
          source_branch: "main"
          destination_repo: "destination_org/repository"
          destination_branch: "main"
          ssh_private_key: ${{ secrets.SSH_PRIVATE_KEY }} # optional
          source_ssh_private_key: ${{ secrets.SOURCE_SSH_PRIVATE_KEY }} # optional, will override `SSH_PRIVATE_KEY`
          destination_ssh_private_key: ${{ secrets.DESTINATION_SSH_PRIVATE_KEY }} # optional, will override `SSH_PRIVATE_KEY`
```

##### Using shorthand

You can use GitHub repo shorthand like `username/repository`.

##### Using ssh

> The `ssh_private_key`, or `source_ssh_private_key` and `destination_ssh_private_key` must be supplied if using ssh clone urls.

```yml
source_repo: "git@github.com:username/repository.git"
```
or
```yml
source_repo: "git@gitlab.com:username/repository.git"
```

##### Using https

> The `ssh_private_key`, `source_ssh_private_key` and `destination_ssh_private_key` can be omitted if using authenticated https urls.

```yml
source_repo: "https://username:personal_access_token@github.com/username/repository.git"
```

#### Set up deploy keys

> You only need to set up deploy keys if repository is private and ssh clone url is used.

- Either generate different ssh keys for both source and destination repositories or use the same one for both, leave passphrase empty (note that GitHub deploy keys must be unique for each repository)

```sh
$ ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

- In GitHub, either:

  - add the unique public keys (`key_name.pub`) to _Repo Settings > Deploy keys_ for each repository respectively and allow write access for the destination repository

  or

  - add the single public key (`key_name.pub`) to _Personal Settings > SSH keys_

- Add the private key(s) to _Repo > Settings > Secrets_ for the repository containing the action (`SSH_PRIVATE_KEY`, or `SOURCE_SSH_PRIVATE_KEY` and `DESTINATION_SSH_PRIVATE_KEY`)

#### Advanced: Sync all branches

To Sync all branches from source to destination, use `source_branch: "refs/remotes/source/*"` and `destination_branch: "refs/heads/*"`. But be careful, branches with the same name including `master` will be overwritten.

```yml
source_branch: "refs/remotes/source/*"
destination_branch: "refs/heads/*"
```

#### Advanced: Sync all tags

To Sync all tags from source to destination, use `source_branch: "refs/tags/*"` and `destination_branch: "refs/tags/*"`. But be careful, tags with the same name will be overwritten.

```yml
source_branch: "refs/tags/*"
destination_branch: "refs/tags/*"
```

### Docker

```sh
$ docker run --rm -e "SSH_PRIVATE_KEY=$(cat ~/.ssh/id_rsa)" $(docker build -q .) \
  $SOURCE_REPO $SOURCE_BRANCH $DESTINATION_REPO $DESTINATION_BRANCH
```

## Author

[Wei He](https://github.com/wei) _github@weispot.com_

## License

[MIT](https://wei.mit-license.org)
