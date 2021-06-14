{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = inputs@{ self, nixpkgs, flake-utils, ... }: let
    inherit (flake-utils.lib) simpleFlake;
  in
    simpleFlake {
      inherit self nixpkgs;
      name = "devdo.xyz";
      shell = _: with _.pkgs; mkShell {
        packages = let
          langtools = [ proselint hunspell link-grammar ];
          ssg = [ zola ];
        in
          ssg ++ langtools;
      };
    };
}
