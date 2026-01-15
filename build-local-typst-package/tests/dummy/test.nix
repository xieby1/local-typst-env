let
  pkgs = import <nixpkgs> {};
  buildLocalTypstPackage = pkgs.callPackages ../.. {};
  dummy = buildLocalTypstPackage { src = ./src; };
in {
  test-pname = {
    expr = dummy.pname;
    expected = "dummy";
  };
  test-version = {
    expr = dummy.version;
    expected= "1.2.3";
  };
}
