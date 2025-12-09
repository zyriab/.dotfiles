{ ... }:
let
  secrets = import ../../secrets.nix;
in
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Arthur Wallendorff";
        email = secrets.personalEmail;
      };
      core.editor = "nvim";
      init.defaultBranch = "master";
    };
    includes = [
      {
        condition = "gitdir:~/dev/freelance/sponsor-cx/";
        contents = {
          user = {
            name = "Arthur Wallendorff";
            email = secrets.workEmail;
          };
        };
      }
    ];
  };

  programs.lazygit = {
    enable = true;
    settings = {
      os.editPreset = "nvim";
      gui = {
        nerdFontsVersion = "3";
        showFileTree = false;
        theme.selectedBgColor = "1e4273";
        showNumstatInFilesView = true;
        commandLogSize = 4;
        statusPanelView = "allBranchesLog";
        switchTabsWithPanelJumpKeys = true;

      };
    };
  };
}
