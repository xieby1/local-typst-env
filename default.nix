{ lib, stdenvNoCC, buildEnv, typst }: lib.extendMkDerivation {
  constructDrv = stdenvNoCC.mkDerivation;
  extendDrvArgs = finalAttrs: prevAttrs: let
    typst_toml = lib.importTOML (finalAttrs.src + /typst.toml);
    set-TYPST_ROOT = "export TYPST_ROOT=$(realpath .)";
  in {
    pname = typst_toml.package.name;
    version = typst_toml.package.version;
    name = "typst-local-package-${finalAttrs.pname}-${finalAttrs.version}";
    dontBuild = true;

    installPhase = let
      outDir = "$out/lib/typst-local-packages/${finalAttrs.pname}/${finalAttrs.version}";
    in ''
      ${set-TYPST_ROOT}
      runHook preInstall
      mkdir -p ${outDir}
      cp -r . ${outDir}
      runHook postInstall
    '';

    # Why use `shellHook = "export TYPST_ROOT=$(realpath .)"` instead of `TYPST_ROOT=finalAttrs.src`?
    # For better development experience in nix-shell.
    # When developing in nix-shell, you frequently edit *.typ files in $TYPST_ROOT.
    # If we use `finalAttrs.src` (TYPST_ROOT=/nix/store/...), you would need to refresh nix-shell after every edit to *.typ files.
    # With `shellHook` (TYPST_ROOT=/home/...), you can edit files freely without worrying about nix-shell refreshes.
    shellHook = ''
      ${set-TYPST_ROOT}
    '' + (prevAttrs.shellHook or ""); # Make sure the user provided `shellHook` also works

    TYPST_PACKAGE_PATH = buildEnv {
      name = "TYPST_PACKAGE_PATH";
      paths = finalAttrs.propagatedBuildInputs or [] ++ finalAttrs.buildInputs or [];
      includeClosures = true;
      pathsToLink  = [ "/lib/typst-packages" "/lib/typst-local-packages" ];
      postBuild = ''
        mv $out/lib/typst-packages $out/preview
        mv $out/lib/typst-local-packages $out/local
        rmdir $out/lib
      '';
    };

    TYPST_IGNORE_SYSTEM_FONTS="true";
    TYPST_FONT_PATHS = buildEnv {
      name = "TYPST_FONT_PATHS";
      paths = finalAttrs.propagatedBuildInputs or [] ++ finalAttrs.buildInputs or [];
      includeClosures = true;
      pathsToLink  = [ "/share/fonts" ];
    };

    # If typst_toml contains "[template]" section,
    # then add the `template` in passthru.
    # As a result, user can access template by `<this-drv>.template`.
    passthru = lib.optionalAttrs (typst_toml?template) {
      # `template` is a standalone derivation rather than
      # an output in <this-drv> because: `template` may have a build phase.
      # For example, `template` may contain draw.io diagrams
      # that need to be converted to SVG before Typst compile.
      template = stdenvNoCC.mkDerivation ({
        name = "${finalAttrs.name}-template";
        inherit (finalAttrs)
          src
          shellHook
          TYPST_PACKAGE_PATH
          TYPST_IGNORE_SYSTEM_FONTS
          TYPST_FONT_PATHS
        ;
        installPhase = ''
          ${set-TYPST_ROOT}
          runHook preInstall
          mkdir -p $out
          ${typst}/bin/typst compile \
          ${typst_toml.template.path}/${typst_toml.template.entrypoint} \
          $out/${lib.removeSuffix ".typ" (baseNameOf typst_toml.template.entrypoint)}.pdf
          runHook postInstall
        '';
      } // lib.attrByPath ["passthru" "template"] {} prevAttrs);
    };
  };
}
