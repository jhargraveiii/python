{
  description = "An FHS shell with Python and CUDA using Pixi.";

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
        name = "python-pixi-cuda";
        targetPkgs = pkgs: with pkgs; [
          cudaPackages_12.cudatoolkit
          cudaPackages_12.libcublas
          cudaPackages_12.cudnn
          cudaPackages_12.cuda_nvcc
          #cudaPackages_12.tensorrt
          cudaPackages_12.cutensor
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
          gnupg
          gperf
          libselinux
          m4
          procps
          unzip
          util-linux
          wget
          pixi
          python39
          python39Packages.pip
          python39Packages.virtualenv
        ];
        profile = ''
          # CUDA
          export CUDA_PATH=${pkgs.cudaPackages_12.cudatoolkit}
          export LD_LIBRARY_PATH=${pkgs.linuxPackages.nvidia_x11_stable_open}/lib
          export EXTRA_LDFLAGS="-L/lib -L${pkgs.linuxPackages.nvidia_x11_stable_open}/lib"
          export EXTRA_CCFLAGS="-I/usr/include"
        '';
        runScript = ''
          echo 'eval "$(pixi completion --shell bash)"' >> ~/.bashrc
          pixi shell
        '';
      };
    in
    {
      devShells.${system}.default = fhs.env;
    };
}
