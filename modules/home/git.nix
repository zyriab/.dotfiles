{ pkgs, ... }:
let
  secrets = import ../../secrets.nix;
in
{
  home.packages = [
    pkgs.delta
  ];

  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "Arthur Wallendorff";
        email = secrets.personalEmail;
      };
      core.editor = "nvim";
      init.defaultBranch = "master";

      # Delta config
      core.pager = "delta";
      interactive.diffFilter = "delta --color-only";
      delta = {
        navigate = true;
        side-by-side = true;
        dark = true;
        syntax-theme = "base16";

        # File headers
        file-style = "#79c0ff bold";
        file-decoration-style = "#79c0ff ul";

        # Line numbers
        line-numbers = true;
        line-numbers-left-style = "#6e7681";
        line-numbers-right-style = "#6e7681";
        line-numbers-minus-style = "#ec8e2c bold";
        line-numbers-plus-style = "#58a6ff bold";
        line-numbers-zero-style = "#6e7681";

        # Added lines (blue)
        plus-style = "#c9d1d9 #132339";
        plus-emph-style = "#ffffff bold #214d87";

        # Removed lines (orange)
        minus-style = "#c9d1d9 #2c1e19";
        minus-emph-style = "#ffffff bold #723e1f";

        # Unchanged lines
        zero-style = "syntax";

        # Hunk headers
        hunk-header-style = "#c9d1d9 bold";
        hunk-header-decoration-style = "#58a6ff box";
        hunk-header-file-style = "#79c0ff";
        hunk-header-line-number-style = "#d29922";

        # Commit info
        commit-style = "#79c0ff bold";
        commit-decoration-style = "#58a6ff box";

        # Merge conflicts
        merge-conflict-begin-symbol = "▼";
        merge-conflict-end-symbol = "▲";
        merge-conflict-ours-diff-header-style = "#d29922 bold";
        merge-conflict-theirs-diff-header-style = "#58a6ff bold";
      };
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
    };

    includes = [
      {
        condition = "gitdir:/mnt/data/dev/freelance/sponsor-cx/";
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
        theme.selectedRangeBgColor = [ "#1e4273" ];
        theme.selectedLineBgColor = [ "#1e4273" ];
        showNumstatInFilesView = true;
        commandLogSize = 4;
        statusPanelView = "allBranchesLog";
        switchTabsWithPanelJumpKeys = true;

      };

      git.pagers = [
        {
          colorArg = "always";
          pager = "delta --paging=never --line-numbers";
        }
      ];

      notARepository = "skip";
    };
  };
}
