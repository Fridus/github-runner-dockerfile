# github-runner-dockerfile
Dockerfile for the creation of a GitHub Actions runner image to be deployed dynamically. [Find the full explanation and tutorial here](https://baccini-al.medium.com/creating-a-dockerfile-for-dynamically-creating-github-actions-self-hosted-runners-5994cc08b9fb).

When running the docker image, or when executing docker compose, environment variables for repo-owner/repo-name and github-token must be included. 

Credit to [testdriven.io](https://testdriven.io/blog/github-actions-docker/) for the original start.sh script, which I slightly modified to make it work with a regular repository rather than with an enterprise. 

Whene generating your GitHub PAT you will need to include `repo`, `workflow`, and `admin:org` permissions.

------

## Pull image

```sh
docker pull fridus/github-runner
```

## Usage

```sh
docker run -d --name github-runner \
    -e REPO=your-org/your-repo \
    -e TOKEN=your-token \
    -e NAME=your-runner-name \
    fridus/github-runner:latest
```

- `REPO` is the repository to register the runner to. Required.
- `TOKEN` is the personal access token to use to register the runner. Required.
- `NAME` is the name of the runner (used as a prefix for the runner name). Optional.

## Create access token

To create an access token, go to [Personal access tokens](https://github.com/settings/personal-access-tokens/new) and create a new token.

Permission `Self-hosted runners` is required to create a runner on a organization.

## Docker compose

```bash
docker compose up -d
```

Example of `.env` file:

```bash
REPO=fridus/my-repo
TOKEN=your-token
NAME=my-runner
```

## Build image

```bash
docker buildx build --platform linux/amd64,linux/arm64/v8 -t fridus/github-runner:latest --push .
```
