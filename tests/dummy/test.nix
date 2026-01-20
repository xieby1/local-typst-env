let
  pkgs = import <nixpkgs> {};
  buildLocalTypstPackage = pkgs.callPackage ../.. {};
  dummy = buildLocalTypstPackage { src = ./src; };
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
