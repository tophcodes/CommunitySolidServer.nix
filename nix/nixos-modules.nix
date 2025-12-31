{ inputs, self, ... }: {
  flake.nixosModules.default = { config, lib, pkgs, ... }: {
    options.services.solid-server = {
      enable = lib.mkEnableOption "Solid server";

      package = lib.mkOption {
        type = lib.types.package;
        default = self.packages.${pkgs.system}.default;
        defaultText = "pkgs.solid-server";
        description = "The Solid server package to use.";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 3000;
        description = "The TCP port on which the server should listen.";
      };

      baseUrl = lib.mkOption {
        type = lib.types.str;
        default = "http://localhost:${toString config.services.solid-server.port}/";
        description = "The base URL used internally to generate URLs. Change this if your server does not run on `http://localhost:$PORT/`.";
      };

      socket = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "The Unix Domain Socket on which the server should listen. `--baseUrl` must be set if this option is provided";
      };

      loggingLevel = lib.mkOption {
        type = lib.types.enum [ "error" "warn" "info" "verbose" "debug" "silly" ];
        default = "info";
        description = "The detail level of logging; useful for debugging problems. Use `debug` for full information.";
      };

      configFile = lib.mkOption {
        type = lib.types.path;
        default = "${self.packages.${pkgs.system}.default}/config/default.json";
        description = "The configuration(s) for the server. The default only stores data in memory; to persist to your filesystem, use `@css:config/file.json`";
      };

      rootFilePath = lib.mkOption {
        type = lib.types.path;
        default = "./";
        description = "Root folder where the server stores data, when using a file-based configuration.";
      };

      sparqlEndpoint = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "URL of the SPARQL endpoint, when using a quadstore-based configuration.";
      };

      showStackTrace = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enables detailed logging on error output.";
      };

      podConfigJson = lib.mkOption {
        type = lib.types.path;
        default = "${self.packages.${pkgs.system}.default}/pod-config.json";
        description = "Path to the file that keeps track of dynamic Pod configurations. Only relevant when using `@css:config/dynamic.json`.";
      };

      seededPodConfigJson = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Path to the file that keeps track of seeded Pod configurations.";
      };

      mainModulePath = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Path from where Components.js will start its lookup when initializing configurations.";
      };

      workers = lib.mkOption {
        type = lib.types.nullOr lib.types.ints.unsigned;
        default = 1;
        description = "Run in multithreaded mode using workers. Special values are `-1` (scale to `num_cores-1`), `0` (scale to `num_cores`) and 1 (singlethreaded).";
      };
    };

    config = lib.mkIf config.services.solid-server.enable {
      systemd.services.solid-server =
        let
          cfg = config.services.solid-server;
        in
        {
          description = "Solid server";
          wantedBy = [ "multi-user.target" ];
          after = [ "network.target" ];

          serviceConfig = {
            ExecStart = ''
              ${cfg.package}/bin/server \
                --port ${toString cfg.port} \
                --baseUrl ${cfg.baseUrl} \
                ${lib.optionalString (cfg.socket != null) "--socket ${cfg.socket}"} \
                --loggingLevel ${cfg.loggingLevel} \
                --config ${cfg.configFile} \
                ${lib.optionalString (cfg.rootFilePath != null) "--rootFilePath ${cfg.rootFilePath}"} \
                ${lib.optionalString (cfg.sparqlEndpoint != null) "--sparqlEndpoint ${cfg.sparqlEndpoint}"} \
                ${lib.optionalString cfg.showStackTrace "--showStackTrace"} \
                ${lib.optionalString (cfg.podConfigJson != null) "--podConfigJson ${cfg.podConfigJson}"} \
                ${lib.optionalString (cfg.seededPodConfigJson != null) "--seededPodConfigJson ${cfg.seededPodConfigJson}"} \
                ${lib.optionalString (cfg.mainModulePath != null) "--mainModulePath ${cfg.mainModulePath}"}
            '';
            Restart = "on-failure";
          };
        };
    };
  };
}
