{
  description = "A NixOS shell for using Latest Pixi";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowBroken = true;
          nvidiaSupport = true;
          allowUnfree = true;
          nvidia.acceptLicense = true;
        };
        hostPlatform = {
          gcc = {
            arch = "znver3";
            tune = "znver3";
          };
          system = "x86_64-linux";

        };
        buildPlatform = {
          gcc = {
            arch = "znver3";
            tune = "znver3";
          };
          system = "x86_64-linux";

        };
      };

      latest_pixi = pkgs.callPackage ./pixi.nix {
        inherit (pkgs) stdenv rustPlatform fetchFromGitHub pkg-config libgit2 openssl installShellFiles;
      };

      nix = {
        settings = {
          experimental-features = [ "nix-command" "flakes" ];
          system-features = [ "benchmark" "big-parallel" "kvm" "nixos-test" "gccarch-znver3" ];
        };
      };

      fhs = pkgs.buildFHSUserEnv {
        name = "cuda";
        targetPkgs = pkgs: with pkgs; [
          latest_pixi
          linuxPackages_latest.nvidia_x11
          git
          gcc
          gfortran
          gnumake
          cmake
          amd-blis
          amd-libflame
        ];
        profile = ''
          export KITTY_PUBLIC_KEY=""
          export UV_HTTP_TIMEOUT=900
          export KERAS_BACKEND="jax"
          export JAX_PLATFORM_NAME="cuda"
        '';
      };
    in
    {
      devShells.${system}.default = fhs.env;
    };
}
