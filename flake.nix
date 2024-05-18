{
  description = "A NixOS shell for using Latest Pixi";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      overlays = [
        import
        ./overlay
        {
          inherit inputs;
        }
      ];
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowBroken = true;
          nvidiaSupport = true;
          allowUnfree = true;
          cudaSupport = true;
          cuda = true;
          cuBlas = true;
          cudVersion = "12.4";
          cudnnSupport = true;
          tensorrtSupport = true;
          cudaCapabilities = [ "8.9" ];
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
          cudaPackages.cudatoolkit
          cudaPackages.cudnn
          cudaPackages.tensorrt
          cudaPackages.cuda_nvcc
          pixi
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
          export CFLAGS="-O3 -march=native -mtune=native -ffast-math -funroll-loops"
          export CXXFLAGS="-O3 -march=native -mtune=native -ffast-math -funroll-loops"
          export NVCCFLAGS="-arch=sm_89 -O3"
          export UV_HTTP_TIMEOUT=900
          export CUDA_PATH=${pkgs.cudatoolkit}
          export LD_LIBRARY_PATH=${pkgs.amd-blis}/lib:${pkgs.amd-libflame}/lib:${pkgs.linuxPackages.nvidia_x11}/lib:$LD_LIBRARY_PATH
          export EXTRA_LDFLAGS="-L/lib -L${pkgs.linuxPackages.nvidia_x11}/lib"
          export EXTRA_CCFLAGS="-I/usr/include"
          export KERAS_BACKEND="jax"
          export JAX_PLATFORM_NAME="cuda"
        '';
      };
    in
    {
      nixpkgs =
        {
          overlays = [
            overlays.cuda
          ];
        };

      devShells.${system}.default = fhs.env;
    };
}
