{ ... }:
{
  programs.zsh = {
    enable = true;

    shellAliases = {
      ned = "nvim ~/.dotfiles/";
      nrb = "echo \":: Rebuilding NixOS configuration for $(hostname)...\" && sudo nixos-rebuild switch --flake ~/.dotfiles#$(hostname)";
      nrbu = "nix flake update nixpkgs && nrb";
      ll = "ls -l";
      lr = "lazydocker";
      cpwd = "pwd | wl-copy";
    };

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    initContent = ''
      # Set default gh account on shell start
      gh auth switch --user zyriab 2>/dev/null

      # Switch back to personal gh account when leaving sponsor-cx
      chpwd() {
        if [[ "$OLDPWD" == *"sponsor-cx"* && "$PWD" != *"sponsor-cx"* ]]; then
          gh auth switch --user zyriab 2>/dev/null
        fi
      }

      # Conditionally initialize zoxide (disabled in Claude Code)
      if [[ -z "$CLAUDECODE" ]]; then
        eval "$(zoxide init --cmd cd zsh)"
      fi
    '';

    oh-my-zsh = {
      enable = true;
      theme = "bira";
      plugins = [
        "gh"
        "direnv"
      ];
    };
  };

  programs.zoxide = {
    enable = true;
    # Disable automatic shell integration - we'll do it manually
    enableZshIntegration = false;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    MANPAGER = "nvim +Man!";
    MANWIDTH = "999";
  };
}
