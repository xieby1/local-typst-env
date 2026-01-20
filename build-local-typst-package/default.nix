{ lib, stdenvNoCC, runCommand }: lib.extendMkDerivation {
  constructDrv = stdenvNoCC.mkDerivation;
  extendDrvArgs = finalAttrs: prevAttrs: let
    typst_toml = lib.importTOML (finalAttrs.src + /typst.toml);
  in {
    pname = typst_toml.package.name;
    version = typst_toml.package.version;
    name = "typst-local-package-${finalAttrs.pname}-${finalAttrs.version}";
    dontBuild = true;
    installPhase = let
      outDir = "$out/lib/typst-local-packages/${finalAttrs.pname}/${finalAttrs.version}";
    in ''
      runHook preInstall
      mkdir -p ${outDir}
      cp -r . ${outDir}
      runHook postInstall
    '';

    TYPST_PACKAGE_PATH = toString (runCommand "TYPST_PACKAGE_PATH" {
      buildInputs = finalAttrs.propagatedBuildPints or [];
    } ''
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
      # Is this `mkdir -p $out` redundant?
      # No. Because: pkgsHostTarget may be empty, so the for loop below may not be executed.
      mkdir -p $out
      for p in "''${pkgsHostTarget[@]}"; do
        symlink_typst_packages $p/lib/typst-packages/       $out/preview/
        symlink_typst_packages $p/lib/typst-local-packages/ $out/local/
      done
    '');
  };
}
