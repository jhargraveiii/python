{
  description = "An FHS shell for CUDA and Pixi.";

  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; };

  outputs = { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        config.allowBroken = true;
        config.cudaSupport = true;
        config.cudannSupport = true;
        config.nvidiaSupport = true;
      };
      fhs = pkgs.buildFHSUserEnv {
        name = "cuda";
        targetPkgs = pkgs: with pkgs; [
          cudaPackages_12_3.cudatoolkit
          cudaPackages_12_3.libcublas
          cudaPackages_12_3.cudnn
          cudaPackages_12_3.cuda_nvcc
          cudaPackages_12_3.cutensor
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
          pixi
          bazel
        ];
        profile = ''
          # CUDA
          export CUDA_PATH=${pkgs.cudaPackages_12_3.cudatoolkit}
          export LD_LIBRARY_PATH=${pkgs.linuxPackages.nvidia_x11_stable_open}/lib
          export EXTRA_LDFLAGS="-L/lib -L${pkgs.linuxPackages.nvidia_x11_stable_open}/lib"
          export EXTRA_CCFLAGS="-I/usr/include"
          export KERAS_BACKEND="jax"
          export JAX_PLATFORM_NAME="cuda"
        '';

        runScript = ''
          #!/bin/sh

          pixi install
          pixi shell
        ''; 
      };
    in
    {
      devShells.${system}.default = fhs.env;
    };
}
