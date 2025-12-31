{inputs, ...}: {
  perSystem = {
    config,
    self',
    inputs',
    pkgs,
    system,
    ...
  }: {
    packages.default = pkgs.buildNpmPackage rec {
      pname = "solid-server";
      version = "unstable-2025-12-15";
      src = pkgs.fetchFromGitHub {
        owner = "CommunitySolidServer";
        repo = "CommunitySolidServer";
        rev = "5ff9424394f3c7125be8c121d9ba8c82a94edf60";
        sha256 = "sha256-TuJY/waVZ6aVr0TsjnqecQG1JGOVI/zi8uiGTgmRH8s=";
      };

      npmDepsHash = "sha256-cbb5vqVIDkr1ukYZYW6WYDVk1FXDODZbOTFTS8xo30Q=";
      npmBuildScript = "build";

      installPhase = ''
        runHook preInstall

        mkdir -p $out/bin $out/lib
        cp -rv dist $out/lib/
        cp -rv bin $out/lib/
        cp -rv node_modules $out/lib/
        cp -rv package.json $out/lib/
        cp -rv config $out/lib/
        cp -rv templates $out/lib/

        cat > $out/bin/${pname} << 'EOF'
        #!/bin/sh
        exec ${pkgs.lib.getExe pkgs.nodejs} $out/lib/bin/server.js "$@"
        EOF

        chmod +x $out/bin/${pname}

        runHook postInstall
      '';

      doInstallCheck = true;
      nativeInstallCheckInputs = [ pkgs.curl ];
      installCheckPhase = ''
        runHook preInstallCheck

        # Start server in background
        echo "Starting Community Solid Server for health check..."
        timeout 30 $out/bin/${pname} --port 3333 &
        SERVER_PID=$!

        # Wait for server to start (max 20 seconds)
        echo "Waiting for server to start..."
        for i in {1..20}; do
          if curl -sf http://localhost:3333/ > /dev/null 2>&1; then
            echo "✓ Server started successfully and responds to requests"
            kill $SERVER_PID 2>/dev/null || true
            wait $SERVER_PID 2>/dev/null || true
            runHook postInstallCheck
            exit 0
          fi
          sleep 1
        done

        # If we get here, server didn't start
        echo "✗ Server failed to start within 20 seconds"
        kill $SERVER_PID 2>/dev/null || true
        wait $SERVER_PID 2>/dev/null || true
        exit 1
      '';

      meta.mainProgram = "${pname}";
    };
  };
}
