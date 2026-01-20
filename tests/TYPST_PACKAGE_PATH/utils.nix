{ lib, runCommand }: {
  lists-eq = l1: l2: let
    l2_l1 = lib.subtractLists l1 l2;
    l1_l2 = lib.subtractLists l2 l1;
    res = l2_l1 == [] && l1_l2 == [];
  in if res then res
  else builtins.trace (
    lib.generators.toPretty {} {inherit l2_l1 l1_l2;}
  ) res;

  get-typst-packages = drv: relpath: let
    typst-packages-file = runCommand "typst-packages" {} ''
      cd ${drv}/${relpath}; echo */* > $out
    '';
    typst-packages-str = builtins.readFile typst-packages-file;
    typst-packages-list-may-have-empty-str = lib.splitStringBy (
      prev: curr: builtins.elem curr [ " " "\n" ]
    ) false typst-packages-str;
    typst-packages-list = builtins.filter (x: x!="") typst-packages-list-may-have-empty-str;
  in typst-packages-list;
}
