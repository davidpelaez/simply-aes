# Contributing

`SimplyAES` is [Apache-2-liennsed](LICENSE.md) and community contributions are welcome.

## Git-Flow

`SimplyAES` follows the [git-flow][] branching model, which means that every commit on `master` is a release.
The default working branch is `develop`, so in general please keep feature pull-requests based against the current `develop`.
Hotfixes -- fixes to already-released builds -- should be based on `master` or the appropriate major version's maintenance branch.

 - ensure your issue is not already addressed in an issue or pull-request
 - fork simply-aes
 - use the git-flow model to start your feature or hotfix
 - make some commits (please include specs)
 - submit a pull-request

## Bug Reporting

Please include clear steps-to-reproduce.
Spec files are especially welcome; a failing spec can be contributed as a pull-request against `develop`.

## Ruby Appraiser

`SimplyAES` uses the [ruby-appraiser][] gem via [pre-commit][] hook, which can be activated by installing [icefox/git-hooks][] and running `git-hooks --install` while in the repo.
Rubocop supplies strong guidelines;
use them to reduce defects as much as you can, but if you believe clarity will be sacrificed they can be bypassed with the `--no-verify` flag.

[git-flow]: http://nvie.com/posts/a-successful-git-branching-model/
[pre-commit]: .githooks/pre-commit/run-ruby-appraiser
[ruby-appraiser]: https://github.com/simplymeasured/ruby-appraiser
[icefox/git-hooks]: https://github.com/icefox/git-hooks
