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
        upstreamRepo = "git@git.sr.ht:~drsensor/site";
        shellHook = ''
          git config push.gpgsign if-asked
          git config commit.gpgsign true
          git config tag.gpgsign true
          if ! git remote show | grep -q upstream && [ $(git remote get-url origin) != $upstreamRepo ]; then
            git config checkout.defaultRemote upstream
            git config remote.pushDefault upstream

            defaultBranch=$(git remote show origin | awk '/HEAD branch/ {print $NF}')
            git config branch.$defaultBranch.remote upstream
            git config branch.$defaultBranch.merge refs/heads/$defaultBranch

            git remote add upstream $upstreamRepo
            git remote add all $(git remote get-url upstream)
            for remote in origin upstream; do
              git remote set-url --add --push all $(git remote get-url $remote)
            done
          fi
        '';
      };
    };
}
