{
  description = "cargo wasm-pack";

  inputs = {
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-unstable"; };
    rust-overlay = { url = "github:oxalica/rust-overlay"; };
  };

  outputs = { nixpkgs, rust-overlay, ... }:
    let system = "x86_64-linux";
    in {
      devShell.${system} = let
        pkgs = import nixpkgs {        
          inherit system;
          overlays = [ rust-overlay.overlays.default ];
        };
      in (({ pkgs, ... }:
        pkgs.mkShell {          
          nativeBuildInputs = with pkgs; [ 
            pkg-config alsa-lib udev python3 wasm-bindgen-cli
          ];
          buildInputs = with pkgs; [            
            cargo rustc rustfmt pre-commit rustPackages.clippy rust-analyzer
            cargo-watch
            nodejs
            wasm-pack
            (rust-bin.stable.latest.default.override {
              extensions = [ "rust-src" ];
              targets = [ "wasm32-unknown-unknown" ];
            })
            # wasm-opt -Os --output output.wasm input.wasm
            binaryen
            # better linker
            clang
          ];

          shellHook = "";
          RUST_SRC_PATH = pkgs.rustPlatform.rustLibSrc;
        }) { pkgs = pkgs; });
    };
}
