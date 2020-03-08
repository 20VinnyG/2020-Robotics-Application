# ScoutMobile 2020

## Build app:

1. run: __flutter build apk --release__
2. run: __adb install [-r] /path/to/apk__
3. alternatively, put the apk on google drive for distribution

## Helpful git commands:

* __git clone *<url>*__ -- clone's a git repo
* __git checkout -b *<branch_name>*__ -- creates a new local branch copying on the current local branch
* __git checkout *<branch_name>*__ -- switches branches
* __git pull origin *<branch_name>*__ -- pulls changes from the specified branch (like master) into the current branch for merging
* __git reset --hard HEAD__ -- throws away all uncommitted local changes
* __git add --all__ -- stage all files for commit
* __git commit [-m "commit message"]__ -- opens vi to enter commit message; using -m flag lets you specify a commit message inline
* __git push__ -- pushes the current branch to remote (github)
* __git stash__ -- stashes the current changes for later recovery
* __git stash save *stash-label*__ -- stashes the current changes with a specific label
* __git stash list__ -- lists all stashed changes
* __git stash pop__ -- pops the top entry of the stash stack and applies it to the active branch
* __git stash apply stash@{*index*}__ -- applies the specified stash stack entry to the active branch (doesn't remove from stash)

## Flutter Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
