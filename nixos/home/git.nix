{ ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "thosvarley";
        email = "contact@thosvarley.me";
      };
      # Matches what `gh auth setup-git` installs, but calls `gh` off PATH
      # instead of pinning a nix store path that goes stale on updates.
      credential."https://github.com".helper = [ "" "!gh auth git-credential" ];
      credential."https://gist.github.com".helper = [ "" "!gh auth git-credential" ];
    };
  };
}
