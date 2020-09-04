# [Miso](https://haskell-miso.org/) Start Template

Copy the files and start hacking your Miso app!

## Prepare the build

1. [Install Nix](https://nixos.org/download.html)
    * If you are using macOS 10.15 or newer, check the [specific instructions](https://nixos.org/manual/nix/stable/#sect-macos-installation)
2. Optionally set up a binary cache:
    1. [Install Cachix](https://docs.cachix.org/installation.html#installation): `nix-env -iA cachix -f https://cachix.org/api/v1/install`
    2. Use the Miso cache: `cachix use miso-haskell`

## Build and run the project

```sh
nix-build
open ./result/bin/app.jsexe/index.html
```

## Update dependencies

The `default.nix` file has a couple of lines which indicate the "state of the world" for the build system:
- The version of Miso you are going to use, usually from Git;
- A Hackage snapshot, which can be updated by taking the latest version from [`all-cabal-hashes`](https://github.com/commercialhaskell/all-cabal-hashes).

The example also shows how you can re-wire the Hackage information to make some packages use a different version from the latest (`servant` in our case), and how to bring a package from a GitHub repository.