import 'common.just'

# Print the version used by the image build and release workflow.
version:
    bun {{ quote(_alpine_cli) }} version

# Print the release metadata used by GitHub Actions.
release-info version='':
    bun {{ quote(_alpine_cli) }} release-info --version {{ quote(version) }}

# Build one image through the existing privileged Docker builder.
[script('bash')]
build arch='x86_64' flavor='lts' version='':
    set -euo pipefail
    cd {{ quote(_repo_root) }}
    version={{ quote(version) }}
    if [ -z "$version" ]; then version="$(bun {{ quote(_alpine_cli) }} version)"; fi
    ALPINE_RELEASE="$version" ARCH={{ quote(arch) }} FLAVOR={{ quote(flavor) }} ./docker-build.sh

# Build the four standard release targets locally or in a runner.
[script('bash')]
build-all version='':
    set -euo pipefail
    version={{ quote(version) }}
    if [ -z "$version" ]; then version="$(bun {{ quote(_alpine_cli) }} version)"; fi
    just --jobs 4 build x86_64 lts "$version"
    just --jobs 4 build x86_64 virt "$version"
    just --jobs 4 build aarch64 lts "$version"
    just --jobs 4 build aarch64 virt "$version"

# Build an optional Raspberry Pi image.
[script('bash')]
build-rpi arch='aarch64' version='':
    set -euo pipefail
    cd {{ quote(_repo_root) }}
    version={{ quote(version) }}
    if [ -z "$version" ]; then version="$(bun {{ quote(_alpine_cli) }} version)"; fi
    ALPINE_RELEASE="$version" ARCH={{ quote(arch) }} FLAVOR=rpi ./docker-build.sh

# Run the cheap repository checks without building an image.
check:
    cd {{ quote(_repo_root) }}
    bun run typecheck
    just --fmt --check
