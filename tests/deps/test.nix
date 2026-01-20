let
  pkgs = import <nixpkgs> {};
  buildLocalTypstEnv = pkgs.callPackage ../.. {};
  submodule = buildLocalTypstEnv { src = ./submodule; };
  module = buildLocalTypstEnv {
    src = ./module;
    propagatedBuildInputs = [ submodule pkgs.typstPackages.academic-conf-pre ];
  };
in pkgs.lib.runTests {
  test-deps = {
    expr = module.propagatedBuildInputs;
    expected = [ submodule pkgs.typstPackages.academic-conf-pre ];
  };
}
