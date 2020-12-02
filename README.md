# Git Sync

A GitHub Action for syncing between two independent repositories using **force push**.

## Features

- Sync branches between two GitHub repositories
- Sync branches to/from a remote repository
- GitHub action can be triggered on a timer or on push
- To sync with current repository, please checkout [Github Repo Sync](https://github.com/marketplace/actions/github-repo-sync)

## Usage

> Always make a full backup of your repo (`git clone --mirror`) before using this action.

- Generate different ssh keys for both source and destination repositories, leave passphrase empty

```sh
$ ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

- In GitHub add the public keys (`key_name.pub`) to _Settings > Deploy keys_ for each repository respectively, allow write access for the destination repository

- Add both the private keys to _Settings > Secrets_ for the repository containing the action (`SOURCE_SSH_PRIVATE_KEY` and `DESTINATION_SSH_PRIVATE_KEY`)

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
          source_repo: "git@github.com:username/repository.git"
          source_branch: "main"
          destination_repo: "git@github.com:org/repository.git"
          destination_branch: "main"
          source_ssh_private_key: ${{ secrets.SOURCE_SSH_PRIVATE_KEY }}
          destination_ssh_private_key: ${{ secrets.DESTINATION_SSH_PRIVATE_KEY }}
```

##### Alternative using https

The `source_ssh_private_key` and `destination_ssh_private_key` can be omitted if using authenticated https urls.

```yml
source_repo: "https://username:personal_access_token@github.com/username/repository.git"
```

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
$ docker run --rm -e "SOURCE_SSH_PRIVATE_KEY=$(cat ~/.ssh/id_rsa)" $(docker build -q .) \
  $SOURCE_REPO $SOURCE_BRANCH $DESTINATION_REPO $DESTINATION_BRANCH
```

## Author

[Wei He](https://github.com/wei) _github@weispot.com_

## License

[MIT](https://wei.mit-license.org)
