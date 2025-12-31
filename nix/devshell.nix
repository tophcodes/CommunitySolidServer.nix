{ inputs, ... }: {
  perSystem = { pkgs, ... }: {
    devShells.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        gnumake
      ];

      shellHook = ''
        echo "Community Solid Server development environment"
      '';
    };
  };
}
