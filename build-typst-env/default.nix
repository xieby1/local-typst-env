# Typst community does not want to change TYPST_PACKAGE_PATH into a list of paths.
#   For more details, see this: https://github.com/typst/typst/pull/6190
# If they would, we could then write a setup hook to generate TYPST_PACKAGE_PATH from pkgsHostTarget.
#
# Currently, we
# 1. (This file) generates a symlink directory to contain all typst modules in pkgsHostTarget,
# 2. (Project file) generates TYPST_PACKAGE_PATH which pointed to symlink directory .
{ runCommand }:
{ typstPkgs }: runCommand "build-typst-env" { buildInputs = typstPkgs; } ''
  symlink_typst_packages() {
    src="$1"
    dst="$2"
    if [[ -d $src ]]; then
      #                      mod ver
      #                        | |
      for path_mod_ver in $src/*/*; do
        mod=$(basename $(dirname $path_mod_ver))
        # Why mkdir .../mod?
        # Because the dependencies may have same mod but different vers.
        # If only ln -s mod, we will lose dependencies.
        mkdir -p $dst/$mod
        ln -s $path_mod_ver $dst/$mod/
      done
    fi
  }
  for p in "''${pkgsHostTarget[@]}"; do
    symlink_typst_packages $p/lib/typst-packages/       $out/preview/
    symlink_typst_packages $p/lib/typst-local-packages/ $out/local/
  done
''
