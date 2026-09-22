{
  description = "SubDomainizer";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      python = pkgs.python3;
      py = python.withPackages (
        ps: with ps; [
          termcolor
          beautifulsoup4
          requests
          htmlmin
          tldextract
          colorama
          cffi
        ]
      );
    in
    {
      packages.${system}.default = pkgs.stdenv.mkDerivation rec {
        pname = "subdomainizer";
        version = "unstable-2026-03-14";

        src = pkgs.fetchFromGitHub {
          owner = "nsonaniya2010";
          repo = "SubDomainizer";
          rev = "master";
          hash = "sha256-IxaHIJ+UG6j4ce9+9y0OREBifG+zWlwPE86V2oJuzyQ=";
        };

        nativeBuildInputs = [ pkgs.makeWrapper ];

        installPhase = ''
          runHook preInstall

          mkdir -p $out/share/${pname} $out/bin
          cp -r . $out/share/${pname}

          makeWrapper ${py}/bin/python3 $out/bin/SubDomainizer.py \
            --add-flags "$out/share/${pname}/SubDomainizer.py"

          runHook postInstall
        '';

        meta = with pkgs.lib; {
          description = "Find hidden subdomains and secrets in webpages, JS files, folders, and GitHub";
          homepage = "https://github.com/nsonaniya2010/SubDomainizer";
          license = licenses.mit;
          mainProgram = "SubDomainizer.py";
          platforms = platforms.all;
        };
      };

      apps.${system}.default = {
        type = "app";
        program = "${self.packages.${system}.default}/bin/SubDomainizer.py";
      };
    };
}
