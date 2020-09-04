with (import (builtins.fetchTarball {
  # point to latest commit for miso
  # last updated: 4 september 2020
  url = "https://github.com/dmjio/miso/archive/bb230192164f0532660aadb4175460740abfa2a2.tar.gz";
  sha256 = "0q44lxzz8pp89ccaiw3iwczha8x2rxjwmgzkxj8cxm97ymsm0diy";
}) {});
let
  my-haskell-packages = (pkgs.haskell.packages.ghcjs.override {
    # this ensures we have an up-to-date view of Hackage
    # last updated: 4 september 2020
    all-cabal-hashes = pkgs.fetchurl {
      url = "https://github.com/commercialhaskell/all-cabal-hashes/archive/117622c10bf41f70548af023366ad82eab9835e3.tar.gz";
      sha256 = "15zpi7x1iqkjk4dscm0z9xxshl58nmdi3sxgn8w3x86wbz03k1wv";
    };
  }).extend (hself: hsuper: rec {
    # include here packages not in the snapshot
    # that you want to bring from Hackage
    # -- servant client --
    servant = pkgs.haskell.lib.dontCheck (hself.callHackage "servant" "0.16" {});
    servant-client-core = pkgs.haskell.lib.dontCheck (hself.callHackage "servant-client-core" "0.16" {});
  });
  # these are packages only available in GitHub
  servant-client-ghcjs-src = pkgs.fetchFromGitHub { 
     owner = "haskell-servant";
     repo = "servant";
     rev = "v0.16";
     sha256 = "0dyn50gidzbgyq9yvqijnysai9hwd3srqvk8f8rykh09l375xb9j";
  } + "/servant-client-ghcjs";
  servant-client-ghcjs = my-haskell-packages.callCabal2nixWithOptions "servant-client-ghcjs" servant-client-ghcjs-src "--jailbreak" {};  # jailbreak means 'do not check bounds'
in
  my-haskell-packages.callCabal2nix "miso-app" ./. { inherit servant-client-ghcjs; }