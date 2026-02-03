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
  # `shellHook` should not be run in nix-build, `shellHook` shall only be run during nix-shell
  # Therefore, there is no miao and TYPST_ROOT in `builtins.readDir dummy`.
  test-dir = {
    expr = builtins.readDir dummy;
    expected = {lib = "directory";};
  };
}
