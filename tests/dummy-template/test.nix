let
  pkgs = import <nixpkgs> {};
  buildLocalTypstEnv = pkgs.callPackage ../.. {};
  dummy = buildLocalTypstEnv { src = ./.; };
in pkgs.lib.runTests {
  test-outputs = {
    expr = dummy.outputs;
    expected = ["out" "template"];
  };
  test-template = {
    expr = builtins.readDir dummy.template;
    expected = {"wang.pdf" = "regular";};
  };
}
