let
  pkgs = import <nixpkgs> {};
  buildLocalTypstPackage = pkgs.callPackage ../.. {};
  submodule = buildLocalTypstPackage { src = ./submodule; };
  module = buildLocalTypstPackage {
    src = ./module;
    propagatedBuildInputs = [ submodule pkgs.typstPackages.academic-conf-pre ];
  };
in pkgs.lib.runTests {
  test-deps = {
    expr = module.propagatedBuildInputs;
    expected = [ submodule pkgs.typstPackages.academic-conf-pre ];
  };
}
