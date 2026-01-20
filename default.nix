{ lib, stdenvNoCC, runCommand, buildEnv }: lib.extendMkDerivation {
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
  };
}
