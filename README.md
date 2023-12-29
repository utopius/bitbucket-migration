# Bitbucket Server to Github Migration

Migrate from Bitbucket server to Github with all refs, with the ability to respect author e-mail privacy by transforming commit authors in the history preserving the commit dates using [git-filter-repo](https://github.com/newren/git-filter-repo) & [Github CLI](https://cli.github.com/).

Usage:
clone, then `cd` into the working copy and...
```sh
./01-get-projects.sh [USER] [ACCESS_TOKEN] [BASE_URL]
```
If you want, edit `work/projects.txt` to remove unwanted projects`.`
```sh
./02-mirror-repos.sh [USER] [ACCESS_TOKEN] [BASE_URL]
./03-generate-authors.sh
```
Edit the generated `work/mailmap.txt` which contains the distinct authors from all cloned repositories and apply the [git-mailmap format](https://git-scm.com/docs/gitmailmap).
Then run
```sh
./04-transform-authors.sh
```
Throroughly review the output to find authors `03-generate-authors.sh` missed and add them to the `work/mailmap.txt`. If some were missing, run 04 again ;) (too lazy to search for this edge case).

Be sure to install the [Github CLI](https://cli.github.com/): <https://github.com/cli/cli/blob/trunk/docs/install_linux.md>.

**ATTENTION:** `05-push-to-github.sh` first deletes the repositories from Github if they already exist!

If satisfied with the results (be sure that the [Github CLI](https://cli.github.com/) is authenticated):
```sh
./05-push-to-github.sh
```
which pushes all transformed repositories to your github account using [Github CLI](https://cli.github.com/). Additionally it generates a `remove_from_github.sh` file in every project that's pushed to be able to remove the repos if some additional corrections have to be made.