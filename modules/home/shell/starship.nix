{ ... }:

{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      add_newline = false;
      git_branch.style = "bold blue";
      character.success_symbol = "[➜](bold green)";
    };
  };
}
