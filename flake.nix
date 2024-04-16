{
  description = "An FHS shell for CUDA and Pixi.";

  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        config.allowBroken = true;
        config.nvidiaSupport = true;
      };

      latest_pixi = pkgs.callPackage ./pixi.nix {
        inherit (pkgs) stdenv rustPlatform fetchFromGitHub pkg-config libgit2 openssl installShellFiles;
      };

      fhs = pkgs.buildFHSUserEnv {
        name = "cuda";
        targetPkgs = pkgs: with pkgs; [
          latest_pixi
          linuxPackages.nvidia_x11_stable_open
          libGLU
          libGL
          xorg.libICE
          xorg.libSM
          xorg.libX11
          xorg.libXext
          xorg.libXi
          xorg.libXmu
          xorg.libXrandr
          xorg.libXrender
          xorg.libXv
          freeglut
          zlib
          ncurses5
          stdenv.cc
          binutils
          ffmpeg
          autoconf
          curl
          freeglut
          gcc
          git
          gitRepo
          gnumake
          cmake
          gnupg
          gperf
          libselinux
          m4
          procps
          unzip
          util-linux
          wget
        ];
        profile = ''
          export CUDA_PATH=/home/jimh/DATA2/python/.pixi/envs/default
          export LD_LIBRARY_PATH=${pkgs.linuxPackages.nvidia_x11_stable_open}/lib
          export EXTRA_LDFLAGS="-L/lib -L${pkgs.linuxPackages.nvidia_x11_stable_open}/lib"
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
