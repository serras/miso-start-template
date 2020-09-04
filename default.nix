let
  # Pin the Miso repository to a particular commit.
  #
  # Last updated: 4 September 2020
  misoSrc = builtins.fetchTarball {
    url = "https://github.com/dmjio/miso/archive/bb230192164f0532660aadb4175460740abfa2a2.tar.gz";
    sha256 = "0q44lxzz8pp89ccaiw3iwczha8x2rxjwmgzkxj8cxm97ymsm0diy";
  };

  # Import the Miso expression and retrieve the pinned Nixpkgs set from it.
  miso = import misoSrc {};
  inherit (miso) pkgs;

  # Ensure that we have an up-to-date Hackage snapshot.
  #
  # This will act as our "base" Haskell package set, on top of which we can
  # overlay additional packages from Hackage, GitHub, et al.
  #
  # Last updated: 4 September 2020.
  hackageSnapshot = pkgs.haskell.packages.ghcjs.override {
    all-cabal-hashes = pkgs.fetchurl {
      url = "https://github.com/commercialhaskell/all-cabal-hashes/archive/117622c10bf41f70548af023366ad82eab9835e3.tar.gz";
      sha256 = "15zpi7x1iqkjk4dscm0z9xxshl58nmdi3sxgn8w3x86wbz03k1wv";
    };
  };

  # Skip running the test suite for a Haskell project.
  inherit (pkgs.haskell.lib) dontCheck;

  # An overlay that overrides/augments a Haskell package set with additional
  # Hackage packages.
  #
  # NOTE: 'callHackage' depends on 'all-cabal-hashes', and therefore cannot be
  # used to retrieve Hackage packages that have been added _after_ that
  # snapshot was taken.
  #
  # To depend on Hackage packages that were added after this snapshot was
  # taken, use 'callHackageDirect' instead.
  extraHackagePackages = hself: hsuper: {
    servant = dontCheck (
      hself.callHackage "servant" "0.16" {}
    );
    servant-client-core = dontCheck (
      hself.callHackage "servant-client-core" "0.16" {}
    );
  };

  # Skip version bounds checks for a Haskell project.
  inherit (pkgs.haskell.lib) doJailbreak;

  # An overlay that overrides/augments a Haskell package set with additional
  # additional Haskell packages from external source repositories.
  extraSourcePackages = hself: hsuper: {
    servant-client-ghcjs =
      let
        src =
          pkgs.fetchFromGitHub {
            owner = "haskell-servant";
            repo = "servant";
            rev = "v0.16";
            sha256 = "0dyn50gidzbgyq9yvqijnysai9hwd3srqvk8f8rykh09l375xb9j";
          }
          # NOTE: 'servant-client-ghcjs' resides in a subdirectory of the
          # 'haskell-servant' repository.
          + "/servant-client-ghcjs";
      in
        doJailbreak (hself.callCabal2nix "servant-client-ghcjs" src {});
  };

  # Construct a complete Haskell package set by overlaying the package set
  # provided by 'hackageSnapshot' with the extensions from
  # 'extraHackagePackages' and 'extraSourcePackages'.
  #
  # NOTE: The list of package set overrides is applied in-order; if there are
  # conflicting packages across two or more package sets, the last set of
  # overrides to be applied "wins".
  haskellPackages = hackageSnapshot.override (
    old: {
      overrides = builtins.foldl' pkgs.lib.composeExtensions
        (old.overrides or (_: _: {})) [
        extraHackagePackages
        extraSourcePackages
      ];
    }
  );
in

haskellPackages.callCabal2nix "miso-app" ./. {}
