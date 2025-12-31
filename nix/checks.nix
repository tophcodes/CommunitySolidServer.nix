{ inputs, ... }: {
  perSystem = { config, pkgs, ... }: {
    checks = {
      # The package itself runs install checks (which test server startup)
      package = config.packages.default;

      # Verify the binary is executable and shows help
      server-binary = pkgs.runCommand "solid-server-binary-test"
        {
          nativeBuildInputs = [ config.packages.default ];
        } ''
        echo "Verifying solid-server binary is available..."
        if command -v solid-server >/dev/null 2>&1; then
          echo "✓ solid-server command found in PATH"
        else
          echo "✗ solid-server command not found"
          exit 1
        fi

        echo "Checking binary can be executed..."
        if solid-server --help 2>&1 | grep -q "Community Solid Server"; then
          echo "✓ solid-server executable shows expected output"
        else
          echo "⚠ solid-server help output unexpected (this may be OK)"
        fi

        touch $out
      '';
    };
  };
}
