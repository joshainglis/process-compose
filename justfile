# Default recipe (builds and runs)
default: build run

# Setup Go modules
setup:
    go mod download

# CI tasks
ci: setup build test-race

# Generate docs from swagger attributes
swag:
    swag2op init --dir src --output src/docs -g api/pc_api.go --openapiOutputDir src/docs --parseDependency --parseInternal

# Build the project
build:
    pc-build

# Build using Nix
build-nix:
    nix build .

# Update version in default.nix
nixver:
    pc-bump-version

# Build for Raspberry Pi
build-pi:
    pc-build-pi

# Compile for multiple platforms
compile:
    pc-compile

# Run tests
test:
    pc-test

# Run tests with race detection
test-race:
    pc-test-race

# Generate HTML coverage report
cover-html:
    pc-cover-html

# Run the application
run:
    pc-run

# Clean build artifacts
clean:
    rm -f bin/*

# Create a release
release:
    source exports
    goreleaser release --clean --skip-validate

# Create a snapshot release
snapshot:
    goreleaser release --snapshot --clean

# Run GitHub Actions locally
github-workflows:
    act -W ./.github/workflows/go.yml -j build
    act -W ./.github/workflows/nix.yml -j build

# Generate documentation
docs:
    pc-docs

# Run linter
lint:
    pc-lint

# Enter Nix development shell
dev:
    nix develop
