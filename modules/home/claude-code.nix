{ pkgs, ... }:
{
  home.file.".claude/settings.json".text = builtins.toJSON {
    model = "sonnet";
    statusLine = {
      type = "command";
      command = "bash ~/.claude/statusline-command.sh";
    };
    alwaysThinkingEnabled = false;
  };

  home.file.".claude/statusline-command.sh" = {
    executable = true;
    text = ''
      #!/bin/bash

      # Read JSON input
      input=$(cat)

      # 1. Model name
      model=$(echo "$input" | jq -r '.model.display_name')

      # 2. Current directory name
      current_dir=$(echo "$input" | jq -r '.workspace.current_dir')
      dir_name=$(basename "$current_dir")

      # 3. Workspace location (last 2 directories only)
      workspace_full=$(echo "$input" | jq -r '.workspace.project_dir')
      workspace=$(echo "$workspace_full" | awk -F'/' '{if (NF >= 2) print $(NF-1)"/"$NF; else print $0}')

      # 4. Orthodox cross symbol
      cross="☦"

      # 5. Git branch name (skip optional locks)
      cd "$current_dir" 2>/dev/null
      git_branch=""
      if git rev-parse --git-dir > /dev/null 2>&1; then
          git_branch=$(git -c core.useBuiltinFSMonitor=false branch --show-current 2>/dev/null || echo "")
      fi

      # 6. Timeout/Usage Block Status
      # Check if there are rate limit fields in the input
      rate_limit_remaining=$(echo "$input" | jq -r '.rate_limit.remaining // empty')
      rate_limit_limit=$(echo "$input" | jq -r '.rate_limit.limit // empty')
      rate_limit_reset=$(echo "$input" | jq -r '.rate_limit.reset // empty')


      # 7. Claude Code version
      version=$(echo "$input" | jq -r '.version')

      # Build the status line
      printf "[%s] | %s [%s] | %s  %s | v%s" \
          "$model" \
          "$dir_name" \
          "$workspace" \
          "$cross" \
          "$git_branch" \
          "$version"
    '';
  };
}
