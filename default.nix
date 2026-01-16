{ pkgs ? import <nixpkgs> {} }: {
  buildLocalTypstPackage = pkgs.callPackage ./build-local-typst-package {};
  buildTypstEnv = pkgs.callPackage ./build-typst-env {};
}
