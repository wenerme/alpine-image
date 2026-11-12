set minimum-version := '1.58.0'
set lazy
set default-list

# Resolve paths from the repository instead of the invocation directory.
_repo_root := parent_directory(source_directory())
_alpine_cli := _repo_root / 'scripts' / 'alpine.ts'
