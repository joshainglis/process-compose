{
  description = "Process Compose is like docker-compose, but for orchestrating a suite of processes, not containers.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          name = "process-compose";
          version = "1.34.0";
          pkg = "github.com/f1bonacc1/${name}/src/config";
          ldFlags = [
            "-X ${pkg}.Version=v${version}"
            "-X ${pkg}.CheckForUpdates=true"
            "-X ${pkg}.Commit=${self.shortRev or "dirty"}"
            "-X ${pkg}.Date=${self.lastModifiedDate or "19700101"}"
            "-X '${pkg}.ProjectName=Process Compose 🔥'"
            "-X '${pkg}.RemoteProjectName=Process Compose ⚡'"
            "-s"
            "-w"
          ];

          process-compose = pkgs.callPackage ./default.nix { inherit name ldFlags; };
          swag2op = pkgs.callPackage ./nix/swag2op.nix { };
          cmds = pkgs.callPackage ./nix/cmds.nix { inherit name ldFlags; };
        in

        {
          packages = {
            default = process-compose;
            ${name} = process-compose;
          };

          apps.default = flake-utils.lib.mkApp { drv = process-compose; };

          devShells.default = pkgs.mkShell {
            buildInputs = builtins.attrValues
              {
                inherit (pkgs)
                  go
                  golangci-lint
                  goreleaser
                  act;

                inherit swag2op;

                inherit (cmds)
                  bumpVersionCmd
                  buildCmd
                  buildPiCmd
                  compileCmd
                  testCmd
                  testRaceCmd
                  coverHtmlCmd
                  runCmd
                  docsCmd
                  lintCmd;
              };

            shellHook = ''
              echo "Welcome to the Process Compose development environment!"
              just -l
            '';
          };

          checks.default = process-compose.overrideAttrs (prev: {
            doCheck = true;
            nativeBuildInputs = prev.nativeBuildInputs ++ [ pkgs.python3 ];
          });
        }
      ) // {
      overlays.default = final: prev: {
        process-compose = self.packages.${prev.system}.process-compose;
      };
    };
}
