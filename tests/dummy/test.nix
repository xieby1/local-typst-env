let
  pkgs = import <nixpkgs> {};
  buildLocalTypstEnv = pkgs.callPackage ../.. {};
  dummy = buildLocalTypstEnv { src = ./src; };
in pkgs.lib.runTests {
  test-pname = {
    expr = dummy.pname;
    expected = "dummy";
  };
  test-version = {
    expr = dummy.version;
    expected= "1.2.3";
  };
}
