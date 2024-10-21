{ lib, writeShellScriptBin, name, ldFlags, ... }:

let
  ldFlagStr = lib.concatStringsSep " " ldFlags;
in
{
  bumpVersionCmd = writeShellScriptBin "pc-bump-version" ''
    version=$(git describe --abbrev=0 | cut -d"v" -f 2)
    sed -i 's/version = ".*"/version = "'$version'"/' flake.nix
  '';

  buildCmd = writeShellScriptBin "pc-build" ''
    go build -o bin/${name} -ldflags "${ldFlagStr}" ./src
  '';

  buildPiCmd = writeShellScriptBin "pc-build-pi" ''
    GOOS=linux GOARCH=arm go build -ldflags "${ldFlagStr}" -o bin/${name}-linux-arm ./src
  '';

  compileCmd = writeShellScriptBin "pc-compile" ''
    for arch in amd64 386 arm64 arm; do
      GOOS=linux GOARCH=$arch go build -ldflags "${ldFlagStr}" -o bin/${name}-linux-$arch ./src
    done
    for arch in amd64 arm64; do
      GOOS=darwin GOARCH=$arch go build -ldflags "${ldFlagStr}" -o bin/${name}-darwin-$arch ./src
    done
    for arch in amd64 arm64; do
      GOOS=windows GOARCH=$arch go build -ldflags "${ldFlagStr}" -o bin/${name}-windows-$arch.exe ./src
    done
  '';

  testCmd = writeShellScriptBin "pc-test" ''
    go test -cover ./src/...
  '';

  testRaceCmd = writeShellScriptBin "pc-test-race" ''
    go test -race ./src/...
  '';

  coverHtmlCmd = writeShellScriptBin "pc-cover-html" ''
    go test -coverprofile=coverage.out ./src/...
    go tool cover -html=coverage.out
  '';

  runCmd = writeShellScriptBin "pc-run" ''
    PC_DEBUG_MODE=1 ./bin/${name}
  '';

  docsCmd = writeShellScriptBin "pc-docs" ''
    ./bin/${name} docs www/docs/cli
    for f in www/docs/cli/*.md; do
      sed -i 's/''${USER}/<user>/g' $f
      sed -i 's/${name}-[0-9]\+.sock/${name}-<pid>.sock/g' $f
    done
  '';

  lintCmd = writeShellScriptBin "pc-lint" ''
    golangci-lint run --show-stats -c .golangci.yaml
  '';
}
