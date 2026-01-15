let
  pkgs = import <nixpkgs> {};
  lists-eq = l1: l2: let
    l2_l1 = pkgs.lib.subtractLists l1 l2;
    l1_l2 = pkgs.lib.subtractLists l2 l1;
    res = l2_l1 == [] && l1_l2 == [];
  in if res then res
  else builtins.trace (
    pkgs.lib.generators.toPretty {} {inherit l2_l1 l1_l2;}
  ) res;
  get-typst-packages = drv: relpath: let
    typst-packages-file = pkgs.runCommand "typst-packages" {} ''
      cd ${drv}/${relpath}; echo */* > $out
    '';
    typst-packages-str = builtins.readFile typst-packages-file;
    typst-packages-list-may-have-empty-str = pkgs.lib.splitStringBy (
      prev: curr: builtins.elem curr [ " " "\n" ]
    ) false typst-packages-str;
    typst-packages-list = builtins.filter (x: x!="") typst-packages-list-may-have-empty-str;
  in typst-packages-list;
in pkgs.lib.runTests {
  # First, we check their approach (current typst.withPackages) only includes direct dependencies.
  test-their = let
    typst = pkgs.typst.withPackages (p: [p.academic-conf-pre]);
    packages = get-typst-packages typst "lib/typst/packages/preview";
  in {
    expr = lists-eq packages [
      "academic-conf-pre/0.1.0"
        "cuti/0.2.1"
        "touying/0.4.2"
        "unify/0.6.0"
    ];
    expected = true;
  };

  # The, we check our approach includes all direct and indirect dependencies
  test-our = let
    buildTypstEnv = pkgs.callPackage ../.. {};
    only-preview-env = buildTypstEnv {
      typstPkgs = [ pkgs.typstPackages.academic-conf-pre ];
    };
    typst-packages = get-typst-packages only-preview-env "preview";
  in {
    expr = lists-eq typst-packages [
      "academic-conf-pre/0.1.0"
        "cuti/0.2.1"
          "sourcerer/0.2.1"
        "touying/0.4.2"
          "cetz/0.2.2"
            "oxifmt/0.2.0"
          "ctheorems/1.1.2"
          "fletcher/0.4.4"
            "cetz/0.2.2"
              "oxifmt/0.2.0"
            "tidy/0.2.0"
            "touying/0.2.1"
              "cetz/0.2.0"
                "oxifmt/0.2.0"
              "fletcher/0.4.1"
                "cetz/0.2.0"
                  "oxifmt/0.2.0"
                "tidy/0.1.0"
        "unify/0.6.0"
    ];
    expected = true;
  };
}
