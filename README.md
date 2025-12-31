CommunitySolidServer Nix Flake
==============================

This Nix Flake provides a package and a NixOS module for the [CommunitySolidServer](https://solidcommunity.be/community-solid-server/) (v7.1.7), a Node.js-based server that implements the Solid specification. The Solid specification is a framework for decentralized social networking, allowing users to own and control their own data.

The project describes itself as "open software that provides you with a [Solid](https://solidproject.org/) Pod and identity. That Pod acts as your own personal storage space so you can share data with people and Solid applications."

This flake uses a modern **flake-parts** architecture with modular organization for better maintainability and extensibility.

## Requirements

To use this Nix Flake, you will need:
- [Nix](https://nixos.org/nix/) with flakes enabled
- Optionally, [NixOS](https://nixos.org/) to use the system module

## Architecture

This flake is organized using `flake-parts` with the following structure:

```
/
├── flake.nix              # Main entry point
├── nix/
│   ├── packages.nix       # Package and app definitions
│   ├── nixos-modules.nix  # NixOS service module
│   └── devshell.nix       # Development environment
```

**What's included:**
- Uses nixpkgs 24.11 (latest stable)
- Community Solid Server v7.1.7
- Node.js 18.x LTS
- Modular flake-parts structure for easy customization

Installation
------------

To install the CommunitySolidServer package and NixOS module, you can add the following lines to your `flake.nix` file:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    community-solid-server = {
      url = "github:gravio-la/CommunitySolidServer.nix#main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, community-solid-server }:
  let
    system = "x86_64-linux";
    pkgs =  import nixpkgs {
      inherit system;
    };
  in
  {
    nixosConfigurations = {
      sampleHost = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          community-solid-server.nixosModules.default
          {
            services.solid-server = {
              enable = true;
            };
          }
        ];
      };
    };
  };
}
```

## Development

Enter the development environment:

```bash
nix develop
```

Build the package:

```bash
nix build
```

Run the server:

```bash
nix run
```

Configuration
-------------

The CommunitySolidServer NixOS module provides a number of options for configuring the server. These options can be set in the `services.solid-server` attribute in your `configuration.nix` file.

Here is a description of each option:

-   `enable`: A boolean option that enables or disables the CommunitySolidServer service.
-   `package`: The Solid server package to use.
-   `port`: The TCP port on which the server should listen.
-   `baseUrl`: The base URL used internally to generate URLs.
-   `socket`: The Unix Domain Socket on which the server should listen.
-   `loggingLevel`: The detail level of logging.
-   `configFile`: The configuration file for the server.
-   `rootFilePath`: The root folder where the server stores data when using a file-based configuration.
-   `sparqlEndpoint`: The URL of the SPARQL endpoint when using a quadstore-based configuration.
-   `showStackTrace`: A boolean option that enables or disables detailed logging on error output.
-   `podConfigJson`: The path to the file that keeps track of dynamic Pod configurations.
-   `seededPodConfigJson`: The path to the file that keeps track of seeded Pod configurations.
-   `mainModulePath`: The path from which Components.js will start its lookup when initializing configurations.
-   `workers`: An integer option that sets the number of workers to use in multithreaded mode.

For example, to change the port that the server listens on, you can set the `port` option in your `configuration.nix` file:

```nix
{
  services.solid-server = {
    enable = true;
    package = pkgs.solid-server;
    port = 4000;
  };
}
```

Running the CommunitySolidServer
--------------------------------

Once the CommunitySolidServer package and NixOS module are installed and configured, you can start the server by running the following command:

```bash
systemctl start solid-server
```

To stop the server, use the `stop` command instead:

```bash
systemctl stop solid-server
```

Contributing
------------

If you would like to contribute to this Nix Flake, please feel free to submit a pull request on GitHub.
