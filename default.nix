{ lib, buildGoModule, installShellFiles, name, version, ldFlags }:

buildGoModule {
  pname = name;
  version = version;
  src = lib.cleanSource ./.;
  vendorHash = "sha256-G4ar+9ARBwR77t/6NswUDXpUw38rYnLy9lIep302mNI=";

  nativeBuildInputs = [ installShellFiles ];

  ldflags = ldFlags;

  postInstall = ''
    mv $out/bin/{src,${name}}

    installShellCompletion --cmd ${name} \
      --bash <($out/bin/${name} completion bash) \
      --zsh <($out/bin/${name} completion zsh) \
      --fish <($out/bin/${name} completion fish)
  '';

  meta = {
    description = "A simple and flexible scheduler and orchestrator to manage non-containerized applications";
    homepage = "https://github.com/F1bonacc1/process-compose";
    changelog = "https://github.com/F1bonacc1/process-compose/releases/tag/v${version}";
    license = lib.licenses.asl20;
    mainProgram = name;
  };

  doCheck = false; # it takes ages to run the tests
}
