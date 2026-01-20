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

  buildLocalTypstPackage = pkgs.callPackage ../../.. {};
  subsubmodule = buildLocalTypstPackage { src = ./subsubmodule; };
  submodule = buildLocalTypstPackage { src = ./submodule; propagatedBuildInputs = [subsubmodule]; };
  module = buildLocalTypstPackage { src = ./module; propagatedBuildInputs = [submodule]; };

  buildTypstEnv = pkgs.callPackage ../.. {};
  typst-env = buildTypstEnv {
    typstPkgs = [
      module
      pkgs.typstPackages.academic-conf-pre
    ];
  };
in pkgs.lib.runTests {
  test = pkgs.lib.testAllTrue [
    (utils.lists-eq (utils.get-typst-packages typst-env "local") [
      "module/0.1.0"
        "submodule/0.0.3"
          "subsubmodule/0.0.99"
    ])
    (utils.lists-eq (utils.get-typst-packages typst-env "preview") [
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
    ])
  ];
}
