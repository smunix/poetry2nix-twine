{
  description = "virtual environments";

  inputs.devshell.url = "github:numtide/devshell";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.poetry2nix-src.url = "github:nix-community/poetry2nix";

  outputs = { self, flake-utils, devshell, nixpkgs, poetry2nix-src }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ devshell.overlay poetry2nix-src.overlay ];
        };
      in {
        defaultPackage =
          pkgs.poetry2nix.mkPoetryApplication { projectDir = ./.; };
        devShell = pkgs.devshell.mkShell {
          imports = [ (pkgs.devshell.importTOML ./devshell.toml) ];
          packages = with pkgs; [
            # Additional dev packages list here.
            nixpkgs-fmt
            (pkgs.poetry2nix.mkPoetryEnv {
              projectDir = ./.;
              editablePackageSources = { my-app = ./poetry_demo; };
            })
          ];
        };
      });
}
