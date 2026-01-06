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

      # See https://hyprdynamicmonitors.filipmikina.com/docs/quickstart/nix#using-the-tui-with-declarative-configuration
      hdm = ''
        HDM_CONFIG_DIR=~/.dotfiles/modules/home/hyprdynamicmonitors
        mkdir -p $HDM_CONFIG_DIR/tmp
        cp $HDM_CONFIG_DIR/config.toml $HDM_CONFIG_DIR/tmp/config.toml
        cp -r $HDM_CONFIG_DIR/hyprconfigs $HDM_CONFIG_DIR/tmp

        hyprdynamicmonitors tui --config $HDM_CONFIG_DIR/tmp/config.toml

        cp $HDM_CONFIG_DIR/tmp/config.toml $HDM_CONFIG_DIR
        cp -r $HDM_CONFIG_DIR/tmp/hyprconfigs $HDM_CONFIG_DIR

        # Fix paths: TUI writes absolute paths to tmp/, replace with actual paths
        sed -i "s|$HDM_CONFIG_DIR/tmp/|$HDM_CONFIG_DIR/|g" $HDM_CONFIG_DIR/config.toml
      '';
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
