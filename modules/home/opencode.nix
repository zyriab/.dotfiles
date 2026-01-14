{ pkgs, inputs, ... }:
{
  home.packages = [
    inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  xdg.configFile."opencode/opencode.json".text = builtins.toJSON {
    "$schema" = "https://opencode.ai/config.json";
    permission = {
      read = "allow";
      edit = "ask";
      write = "ask";
      glob = "allow";
      grep = "allow";
      list = "allow";
      bash = "ask";
      task = "allow";
      skill = "allow";
      lsp = "allow";
      todoread = "allow";
      todowrite = "allow";
      webfetch = "allow";
      websearch = "allow";
      codesearch = "allow";
      fetch = "ask";
      notebook = "ask";
      mcp = "ask";
      external_directory = "ask";
      doom_loop = "ask";
    };
    mcp = {
      linear-findleads = {
        enabled = true;
        type = "remote";
        url = "https://mcp.linear.app/sse";
      };
      linear-scx = {
        enabled = true;
        type = "remote";
        url = "https://mcp.linear.app/sse";
      };
    };
  };
}
