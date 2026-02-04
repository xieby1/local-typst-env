let
  pkgs = import <nixpkgs> {};
  buildLocalTypstEnv = pkgs.callPackage ../.. {};
  use-buildPhase = buildLocalTypstEnv {
    src = ./.;
    passthru.template.buildPhase = ''
      mkdir miao
      echo 'wang!!!' > miao/wang.typ
    '';
  };
in pkgs.lib.runTests {
  test-use-buildPhase = {
    expr = builtins.readDir use-buildPhase.template;
    expected = {"wang.pdf" = "regular";};
  };
}
