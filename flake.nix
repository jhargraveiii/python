{
  description = "A NixOS shell for using Latest Pixi";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          allowBroken = true;
          nvidiaSupport = true;
        };
      };

      latest_pixi = pkgs.callPackage ./pixi.nix {
        inherit (pkgs) stdenv rustPlatform fetchFromGitHub pkg-config libgit2 openssl installShellFiles;
      };
      fhs = pkgs.buildFHSUserEnv {
        name = "cuda";
        targetPkgs = pkgs: with pkgs; [
          latest_pixi
          linuxPackages.nvidia_x11
          git
          gcc
          gnumake
          cmake
        ];
        profile = ''
          export UV_HTTP_TIMEOUT=900
          export CUDA_PATH=/home/jimh/DATA2/python/.pixi/envs/default
          export LD_LIBRARY_PATH=${pkgs.linuxPackages.nvidia_x11}/lib
          export EXTRA_LDFLAGS="-L/lib -L${pkgs.linuxPackages.nvidia_x11}/lib"
          export EXTRA_CCFLAGS="-I/usr/include"
          export KERAS_BACKEND="jax"
          export JAX_PLATFORM_NAME="cuda"
        '';
      };
    in
    {
      devShells.${system}.default = fhs.env;
    };
}
