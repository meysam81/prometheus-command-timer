# Changelog

## [1.1.0](https://github.com/meysam81/prometheus-command-timer/compare/v1.0.13...v1.1.0) (2025-03-03)


### Features

* add more precision to duration metric ([1499576](https://github.com/meysam81/prometheus-command-timer/commit/1499576ceb2bda23c0a5b94cb80d973bd6abc929))

## [1.0.13](https://github.com/meysam81/prometheus-command-timer/compare/v1.0.12...v1.0.13) (2025-03-03)


### Bug Fixes

* **CI:** rename downloadable asset name in docker image ([a044d44](https://github.com/meysam81/prometheus-command-timer/commit/a044d444903be227c0c77f00dc2641dc5100a55a))

## [1.0.12](https://github.com/meysam81/prometheus-command-timer/compare/v1.0.11...v1.0.12) (2025-03-03)


### Miscellaneous Chores

* **CI:** use amd64 as arch in release assets ([86fab42](https://github.com/meysam81/prometheus-command-timer/commit/86fab42f10303e5ae95c509061a165a3ff410d6f))

## [1.0.11](https://github.com/meysam81/prometheus-command-timer/compare/v1.0.10...v1.0.11) (2025-03-03)


### Miscellaneous Chores

* **CI:** checkout the ref explicilty when building stable docker ([9d5d803](https://github.com/meysam81/prometheus-command-timer/commit/9d5d803a3f52fe8a562de207afd09086f4ea3f49))
* **CI:** create build assets with dash instead ([a66663c](https://github.com/meysam81/prometheus-command-timer/commit/a66663cd2a2c5c96e427373b347048fd5727385e))

## [1.0.10](https://github.com/meysam81/prometheus-command-timer/compare/v1.0.9...v1.0.10) (2025-02-27)


### Bug Fixes

* **docs:** syntax error ([c8ee7a5](https://github.com/meysam81/prometheus-command-timer/commit/c8ee7a5ca910571bda5af4fee61811f2675ae6ad))


### Miscellaneous Chores

* **CI:** manually extract major version from semver ([52e884d](https://github.com/meysam81/prometheus-command-timer/commit/52e884dbde8c28f048f28516ccfd27aacf42f04f))

## [1.0.9](https://github.com/meysam81/prometheus-command-timer/compare/v1.0.8...v1.0.9) (2025-02-27)


### Miscellaneous Chores

* **CI:** build major version docker images ([0d04363](https://github.com/meysam81/prometheus-command-timer/commit/0d04363346a46bb5749098a187cfff530b8968d6))

## [1.0.8](https://github.com/meysam81/prometheus-command-timer/compare/v1.0.7...v1.0.8) (2025-02-27)


### Bug Fixes

* **CI:** template the certificate and signature for cosign ([85c8291](https://github.com/meysam81/prometheus-command-timer/commit/85c82915cf093045e2fbd04663018c803663e218))

## [1.0.7](https://github.com/meysam81/prometheus-command-timer/compare/v1.0.6...v1.0.7) (2025-02-25)


### Bug Fixes

* **CI:** remove checksum artifact ([3b40932](https://github.com/meysam81/prometheus-command-timer/commit/3b4093227b55a9771be65d5c408beabb9a40ca8c))

## [1.0.6](https://github.com/meysam81/prometheus-command-timer/compare/v1.0.5...v1.0.6) (2025-02-25)


### Miscellaneous Chores

* release 1.0.6 ([4a59665](https://github.com/meysam81/prometheus-command-timer/commit/4a59665eeea19c9d99cfc90b8ce40469b74761be))

## [1.0.5](https://github.com/meysam81/prometheus-command-timer/compare/v1.0.4...v1.0.5) (2025-02-25)


### Bug Fixes

* **CI:** remove duplicate certificate name ([a9d57b1](https://github.com/meysam81/prometheus-command-timer/commit/a9d57b134afd00144959297212817a322d57d847))


### Miscellaneous Chores

* install version from the release ([2c250ca](https://github.com/meysam81/prometheus-command-timer/commit/2c250ca3d1192197a37347cb00b30c5eac63aff4))

## [1.0.4](https://github.com/meysam81/prometheus-command-timer/compare/v1.0.3...v1.0.4) (2025-02-25)


### Features

* add -version flag ([c7a0999](https://github.com/meysam81/prometheus-command-timer/commit/c7a0999c916039c67ca87806a6374ca2d590edbc))

## [1.0.3](https://github.com/meysam81/prometheus-command-timer/compare/v1.0.2...v1.0.3) (2025-02-25)


### Bug Fixes

* **CI:** remove redundant dashes from args ([ccb4e8a](https://github.com/meysam81/prometheus-command-timer/commit/ccb4e8a8ca95e334d97e731897b97fea1f407c3c))


### Miscellaneous Chores

* lowercase the OS in release assets ([e35519b](https://github.com/meysam81/prometheus-command-timer/commit/e35519b342cf9964ffaece25034049332b501d39))

## [1.0.2](https://github.com/meysam81/prometheus-command-timer/compare/v1.0.1...v1.0.2) (2025-02-25)


### Miscellaneous Chores

* customize signature and output certificate ([75f3458](https://github.com/meysam81/prometheus-command-timer/commit/75f3458ba8c04645fc7854fe0bd88ba1dac60e73))
* remove cosign args from goreleaser ([29d6fd1](https://github.com/meysam81/prometheus-command-timer/commit/29d6fd1b480bec0e2bffbffe9277ad5f84b7fe90))

## [1.0.1](https://github.com/meysam81/prometheus-command-timer/compare/v1.0.0...v1.0.1) (2025-02-25)


### Bug Fixes

* **CI:** allow write access to release assets ([901ca8f](https://github.com/meysam81/prometheus-command-timer/commit/901ca8fc241e22dd19ec85fc6198a033dfbdc556))

## 1.0.0 (2025-02-25)


### Features

* create dockerfile to allow usage in initContainers ([5f367de](https://github.com/meysam81/prometheus-command-timer/commit/5f367de2e357232ca2bc66d9789fbedb9a9a6dd7))
* rewrite it in go to get one final binary artifact ([fc62175](https://github.com/meysam81/prometheus-command-timer/commit/fc621753ce62d5f16e69441d74d1c34376492ce2))


### Bug Fixes

* install curl in the same install script ([4aaf4b6](https://github.com/meysam81/prometheus-command-timer/commit/4aaf4b69ab8013afd37fe5dd51151820b45956b1))
* modify image name ([2513f65](https://github.com/meysam81/prometheus-command-timer/commit/2513f65daec51f4b5195c042b7ef5078bb3034b8))
