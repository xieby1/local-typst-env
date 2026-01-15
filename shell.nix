let
  pkgs = import <nixpkgs> {};
in pkgs.mkShell {
  name = "local-typst-env";
  packages = [
    pkgs.nix-unit
  ];
}
