let
  # The preview package version and its dependencies vary across different nixpkgs versions.
  # To ensure consistent behavior, we pin nixpkgs to a specific version.
  # Here we pin to the latest nixpkgs 25.11 release.
  pkgs = import ((import <nixpkgs> {}).fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "2c3e5ec5df46d3aeee2a1da0bfedd74e21f4bf3a";
    hash = "sha256-yBXJLE6WCtrGo7LKiB6NOt6nisBEEkguC/lq/rP3zRQ=";
  }) {};
  utils = pkgs.callPackage ../utils.nix {};
in pkgs.lib.runTests {
  # First, we check their approach (current typst.withPackages) only includes direct dependencies.
  test-their = let
    typst = pkgs.typst.withPackages (p: [p.academic-conf-pre]);
    packages = utils.get-typst-packages typst "lib/typst/packages/preview";
  in {
    expr = utils.lists-eq packages [
      "academic-conf-pre/0.1.0"
        "cuti/0.2.1"
        "touying/0.4.2"
        "unify/0.6.0"
    ];
    expected = true;
  };

  # The, we check our approach includes all direct and indirect dependencies
  test-our = let
    buildTypstEnv = pkgs.callPackage ../.. {};
    only-preview-env = buildTypstEnv {
      typstPkgs = [ pkgs.typstPackages.academic-conf-pre ];
    };
    typst-packages = utils.get-typst-packages only-preview-env "preview";
  in {
    expr = utils.lists-eq typst-packages [
      "academic-conf-pre/0.1.0"
        "cuti/0.2.1"
          "sourcerer/0.2.1"
        "touying/0.4.2"
          "cetz/0.2.2"
            "oxifmt/0.2.0"
          "ctheorems/1.1.2"
          "fletcher/0.4.4"
            "cetz/0.2.2"
              "oxifmt/0.2.0"
            "tidy/0.2.0"
            "touying/0.2.1"
              "cetz/0.2.0"
                "oxifmt/0.2.0"
              "fletcher/0.4.1"
                "cetz/0.2.0"
                  "oxifmt/0.2.0"
                "tidy/0.1.0"
        "unify/0.6.0"
    ];
    expected = true;
  };
}
