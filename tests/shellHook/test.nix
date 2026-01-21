let
  pkgs = import <nixpkgs> {};
  buildLocalTypstEnv = pkgs.callPackage ../.. {};
  dummy = buildLocalTypstEnv {
    src = ./src;
    shellHook = ''
      mkdir -p $out
      echo miao miao > $out/miao
      echo $TYPST_ROOT > $out/TYPST_ROOT
    '';
  };
in pkgs.lib.runTests {
  test-miao = {
    expr = builtins.readFile (dummy + "/miao");
    expected = ''
      miao miao
    '';
  };
  test-TYPST_ROOT = {
    # The value is "/build/src/\n", but may be different is different platform.
    # So only check whether it is empty.
    expr = builtins.readFile (dummy + "/TYPST_ROOT") != "";
    expected= true;
  };
}
