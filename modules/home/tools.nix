{ pkgs, ... }:
{
  programs.bat.enable = true;
  programs.btop.enable = true;
  programs.fzf.enable = true;
  programs.ripgrep.enable = true;
  programs.jq.enable = true;
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "https";
      prompt = "enabled";
      aliases = {
        co = "pr checkout";
      };
    };
  };
  programs.tmux.enable = true;

  home.packages = with pkgs; [
    curl
    wget
    fd
    duf
    lsof
    fastfetch
    dos2unix
    zip
    unzip
    usbutils
    imagemagick
    bluetuith
    xclip
    lazydocker
  ];
}
