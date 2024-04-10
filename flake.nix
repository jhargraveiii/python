{
  description = "An FHS shell with Python and CUDA.";

  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; };

  outputs = { self, nixpkgs, ... }:
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
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs;
          [
            cudaPackages_12_3.cudatoolkit
            cudaPackages_12_3.libcublas
            cudaPackages_12_3.cudnn
            linuxPackages.nvidia_x11_stable_open
            libGLU
            libGL
            xorg.libXi
            xorg.libXmu
            freeglut
            xorg.libXext
            xorg.libX11
            xorg.libXv
            xorg.libXrandr
            zlib
            ncurses5
            stdenv.cc
            binutils
            ffmpeg
            pixi
            python311
            python311Packages.pip
            python311Packages.virtualenv
          ];
        shellHook = ''
          # cuda
          export CUDA_PATH=${pkgs.cudaPackages_12_3.cudatoolkit}
          export LD_LIBRARY_PATH=${pkgs.linuxPackages.nvidia_x11_stable_open}/lib
          export EXTRA_LDFLAGS="-L/lib -L${pkgs.linuxPackages.nvidia_x11_stable_open}/lib"
          export EXTRA_CCFLAGS="-I/usr/include"
        '';
      };
    };
}
