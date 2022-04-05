# GitHub Workflows

## Secrets

GitHub Action runners need access to restricted resources like repositories or cloud storage.
They get access via
[GitHub Actions secrets](https://github.com/organizations/reboot-dev/settings/secrets/actions)
for the organization. The secret values are exposed to GitHub Action Runners as environment variables.

When adding or editing secrets, add or update the relevant row in a table below.
These tables help to answer questions like:
"looking at the list of keys for service account X, what are all these keys used for?
Can I delete some of them?
Which of these have been compromised by [some oopsie] and where do I need to go to replace them?"


### GitHub (repo) access secrets

To create a secret that contains a GitHub Personal Access Token (PAT) for the `reboot-dev-bot` account which can be used to grant access to a repo:

1. Go to [go/passwords](http://go/passwords) to get the password for the `reboot-dev-bot` GitHub account.
2. Log in to GitHub.com as `reboot-dev-bot`.
3. Go to https://github.com/settings/tokens
4. Create a PAT with a useful name (e.g. `PRIVATE_REPO_ACCESS_AS_REBOT_TOKEN on GitHub Actions`) and the following scopes: `repo`, `admin:org`.
5. Copy the resulting token and use it verbatim to set `PRIVATE_REPO_ACCESS_AS_REBOT_TOKEN` (note: `REBOT` not `REBOOT`, because we're hilarious like that).
6. Make an entry for the PAT in the table below:

| Secret name                                                                                                  | Point of contact | Access                                      |
| ------------------------------------------------------------------------------------------------------------ | ---------------- | ------------------------------------------- |
| [`PRIVATE_REPO_ACCESS_AS_REBOT_TOKEN`](https://github.com/organizations/reboot-dev/settings/secrets/actions) | rjh@             | Repositories in the reboot-dev organization |


### Google Cloud service account credentials secrets

These secrets contain a one-line JSON object representing Google Cloud service account credentials.
They grant access to a Google Cloud Storage bucket used as our remote build cache.

To create such credentials:

1. Identify the correct service account to use to access your Google Cloud
   Storage bucket. For example, the
   [`reboot-workstations-buildcache` bucket](https://console.cloud.google.com/storage/browser/reboot-workstations-buildcache)
   is accessed via the
   [`remote-build-cache-acccess@reboot-workstations.iam.gserviceaccount.com`](https://console.cloud.google.com/iam-admin/serviceaccounts/details/108850164519701382905?project=reboot-workstations)
   service account in the same `reboot-workstations` project.
2. In the [Google Cloud Console page for that service account](https://console.cloud.google.com/iam-admin/serviceaccounts?project=reboot-workstations),
   go to the `KEYS` tab.
3. Click `ADD KEY` -> `Create new key`. Select `JSON` as the key type. Click `CREATE`.
4. Encode the downloaded `.json` file in base64. This ensures that it won't contain characters like `\n` that break various parsers. [On OS X](https://superuser.com/questions/120796/how-to-encode-base64-via-command-line), run: `openssl base64 -in <infile> -out <outfile>`
4. Create your desired type of secret (e.g. organization-level, repo-level, codespace-restricted, etc.) and set its value to the contents of the base64 encoded `.json` file.
6. Delete the `.json` file after saving the secret to avoid accidentally leaking credentials.
7. Code that reads the secret must [base64 decode the value](https://stackoverflow.com/a/65351316/204009), e.g.: `"echo \"$MY_SECRET\" | base64 -d > my_secret.json`.
8. Make an entry for the key in the table below:

| Secret name                                                                                                       | Service account name                                                   | Key ID                                   | Point of contact | Access to which bucket?                                      | Used where?                                            |
| ----------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------- | ---------------------------------------- | ---------------- | ------------------------------------------------------------ | ------------------------------------------------------ |
| ?? maybe [`GCP_REMOTE_CACHE_CREDENTIALS`](https://github.com/organizations/reboot-dev/settings/secrets/actions)   | remote-build-cache-acccess@reboot-workstations.iam.gserviceaccount.com | 354eaa1d0083e743ee838f1a7934955b892eec71 | rjh@             | `reboot-workstations-buildcache` in `reboot-workstations`    | GitHub Actions (reboot-dev org, duplicate with below?) |
| ?? maybe [`GCP_REMOTE_CACHE_CREDENTIALS`](https://github.com/organizations/reboot-dev/settings/secrets/actions)   | remote-build-cache-acccess@reboot-workstations.iam.gserviceaccount.com | 07c6dc8d8dede334e85a57289dd45613e248873a | rjh@             | `reboot-workstations-buildcache` in `reboot-workstations`    | GitHub Actions (reboot-dev org, duplicate with above?) |
| [`GCP_REMOTE_CACHE_CREDENTIALS`](https://github.com/reboot-dev/respect/settings/secrets/codespaces)               | remote-build-cache-acccess@reboot-workstations.iam.gserviceaccount.com | 72a65a01e4cc7a976510f1b4ccfc7c3149bffccb | alexmc@          | `reboot-workstations-buildcache` in `reboot-workstations`    | GitHub Codespaces (specifically Codespace Prebuilds    |
| [`GCP_GITHUB_INFRA_REMOTE_CACHE_CREDENTIALS`](https://github.com/organizations/3rdparty/settings/secrets/actions) | reboot-dev-remote-cache@reboot-github-infra.iam.gserviceaccount.com    | 91c420b58ae966c421eac8480459c5c03ef66595 | rjh@             | `reboot-dev-eventuals-remote-cache` in `reboot-github-infra` | GitHub Actions (3rdparty org, eventuals repo)          |
