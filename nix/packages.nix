{ inputs, ... }: {
  perSystem = { config, self', inputs', pkgs, system, ... }:
    let
      bp = pkgs.callPackage inputs.nix-npm-buildPackage { nodejs = pkgs.nodejs-18_x; };

      src = pkgs.fetchFromGitHub {
        owner = "CommunitySolidServer";
        repo = "CommunitySolidServer";
        rev = "v7.1.7";
        sha256 = "sha256-tR1dUWJFKmsg1zLXU6DyOyTTFp9r7ndhAEIUWW27n9Q=";
      };
    in
    {
      packages.default = bp.buildNpmPackage {
        name = "solid-server";
        inherit src;
        packageJSON = "${src}/package.json";
        packageLockJSON = "${src}/package-lock.json";
        buildInputs = with pkgs; [ nodejs-18_x nodePackages.typescript ];
      };

      apps.default = {
        type = "app";
        program = "${config.packages.default}/bin/server";
      };
    };
}
