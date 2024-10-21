{ buildGoModule, fetchFromGitHub, ... }:

buildGoModule {
  pname = "swag2op";
  version = "1.0.1";
  src = fetchFromGitHub
    {
      owner = "zxmfke";
      repo = "swagger2openapi3";
      rev = "v1.0.1";
      sha256 = "sha256-0khXtJ2DB56RLMwPU61K/OQld0w16YxPj89AZ31U3yo=";
    };
  vendorHash = "sha256-y6evAKRDgUChEFwVjTIis1aaMJb8sbvRZwIyHyspy3c=";
  subPackages = [ "." "cmd/swag2op" ];
  doCheck = false;
}
