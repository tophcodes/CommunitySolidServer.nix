{
  description = "An open and modular implementation of the Solid specifications";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];

      imports = [
        ./nix/packages.nix
        ./nix/nixos-modules.nix
        ./nix/devshell.nix
        ./nix/checks.nix
        ./nix/vm-test.nix
      ];
    };
}
