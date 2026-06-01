{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withRuby = false;
    withPython3 = false;
  };

  # Lua config managed separately
  xdg.configFile."nvim".source = ../../nvim;

  # Neovim plugin dependencies
  home.packages = with pkgs; [
    sword # bible verse plugin
  ];
}
