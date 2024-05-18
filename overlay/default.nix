# This file defines overlays
{ inputs, lib, ... }: {
  cuda = final: prev: {
    # Override attributes of packages inside cudaPackages
    cudaPackages = prev.cudaPackages_12_3;
  };
}
