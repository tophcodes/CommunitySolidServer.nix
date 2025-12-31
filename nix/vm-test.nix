{
  inputs,
  self,
  ...
}: {
  perSystem = {
    pkgs,
    system,
    ...
  }: {
    checks.nixos-module = pkgs.testers.runNixOSTest {
      name = "solid-server-nixos-module";

      nodes.machine = {
        config,
        pkgs,
        ...
      }: {
        imports = [self.nixosModules.default];

        services.solid-server = {
          enable = true;
          port = 3000;
          baseUrl = "http://localhost:3000/";
          loggingLevel = "info";
          rootFilePath = "/var/lib/solid";
        };

        # Ensure the data directory exists
        systemd.tmpfiles.rules = [
          "d /var/lib/solid 0755 root root -"
        ];
      };

      testScript = ''
        start_all()

        # Wait for the service to start
        machine.wait_for_unit("solid-server.service")

        # Wait for the server to be ready (max 30 seconds)
        machine.wait_for_open_port(3000, timeout=30)

        # Test that the server responds
        machine.succeed("curl -f http://localhost:3000/")

        # Check service status
        machine.succeed("systemctl is-active solid-server.service")

        # Verify the service is using the correct binary
        output = machine.succeed("systemctl show solid-server.service -p ExecStart")
        assert "solid-server" in output, f"Expected 'solid-server' in ExecStart, got: {output}"

        print("✓ Community Solid Server NixOS module test passed!")
      '';
    };
  };
}
