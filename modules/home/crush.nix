{ pkgs, lib, inputs, ... }:
let
  anthropic-api-key = pkgs.callPackage ../../pkgs/anthropic-api-key.nix { };

  # Build crush from source using our pkgs (inherits allowUnfree)
  # with postPatch to prefix tool names (avoids Claude API conflicts)
  crushPkg = pkgs.buildGoModule {
    pname = "crush";
    version = "nightly-${inputs.crush.shortRev or "dev"}";

    src = inputs.crush;

    proxyVendor = true;
    vendorHash = "sha256-DgAEvl0zVDEpwo6R2nHlVkC9YU2MAdQKt2MavEx1dcs=";

    env = {
      CGO_ENABLED = "0";
      GOEXPERIMENT = "greenteagc";
    };

    ldflags = [
      "-s"
      "-w"
      "-X github.com/charmbracelet/crush/internal/version.Version=nightly-${inputs.crush.shortRev or "dev"}"
    ];

    buildFlags = [ "-trimpath" ];
    doCheck = false;

    nativeBuildInputs = [ pkgs.installShellFiles ];

    postPatch = ''
      substituteInPlace internal/agent/tools/bash.go \
        --replace 'BashToolName = "bash"' 'BashToolName = "crush_bash"'
      substituteInPlace internal/agent/tools/edit.go \
        --replace 'EditToolName = "edit"' 'EditToolName = "crush_edit"'
      substituteInPlace internal/agent/tools/view.go \
        --replace 'ViewToolName     = "view"' 'ViewToolName     = "crush_view"'
      substituteInPlace internal/agent/tools/write.go \
        --replace 'WriteToolName = "write"' 'WriteToolName = "crush_write"'
      substituteInPlace internal/agent/tools/ls.go \
        --replace 'LSToolName = "ls"' 'LSToolName = "crush_ls"'
      substituteInPlace internal/agent/tools/glob.go \
        --replace 'GlobToolName = "glob"' 'GlobToolName = "crush_glob"'
      substituteInPlace internal/agent/tools/grep.go \
        --replace 'GrepToolName        = "grep"' 'GrepToolName        = "crush_grep"'
      substituteInPlace internal/agent/tools/fetch.go \
        --replace 'FetchToolName = "fetch"' 'FetchToolName = "crush_fetch"'
      substituteInPlace internal/agent/tools/fetch_types.go \
        --replace 'AgenticFetchToolName = "agentic_fetch"' 'AgenticFetchToolName = "crush_agentic_fetch"' \
        --replace 'WebFetchToolName = "web_fetch"' 'WebFetchToolName = "crush_web_fetch"' \
        --replace 'WebSearchToolName = "web_search"' 'WebSearchToolName = "crush_web_search"'
      substituteInPlace internal/agent/tools/download.go \
        --replace 'DownloadToolName = "download"' 'DownloadToolName = "crush_download"'
      substituteInPlace internal/agent/tools/todos.go \
        --replace 'TodosToolName = "todos"' 'TodosToolName = "crush_todos"'
      substituteInPlace internal/agent/tools/multiedit.go \
        --replace 'MultiEditToolName = "multiedit"' 'MultiEditToolName = "crush_multiedit"'
      substituteInPlace internal/agent/tools/job_kill.go \
        --replace 'JobKillToolName = "job_kill"' 'JobKillToolName = "crush_job_kill"'
      substituteInPlace internal/agent/tools/job_output.go \
        --replace 'JobOutputToolName = "job_output"' 'JobOutputToolName = "crush_job_output"'
      substituteInPlace internal/agent/tools/diagnostics.go \
        --replace 'DiagnosticsToolName = "lsp_diagnostics"' 'DiagnosticsToolName = "crush_lsp_diagnostics"'
      substituteInPlace internal/agent/tools/references.go \
        --replace 'ReferencesToolName = "lsp_references"' 'ReferencesToolName = "crush_lsp_references"'
      substituteInPlace internal/agent/tools/sourcegraph.go \
        --replace 'SourcegraphToolName = "sourcegraph"' 'SourcegraphToolName = "crush_sourcegraph"'
      substituteInPlace internal/agent/agent_tool.go \
        --replace 'AgentToolName = "agent"' 'AgentToolName = "crush_agent"'
    '';

    postInstall = ''
      installShellCompletion --cmd crush \
        --bash <($out/bin/crush completion bash) \
        --zsh <($out/bin/crush completion zsh) \
        --fish <($out/bin/crush completion fish)
      mkdir -p $out/share/man/man1
      $out/bin/crush man | gzip -c > $out/share/man/man1/crush.1.gz
    '';

    meta = with pkgs.lib; {
      description = "The glamourous AI coding agent for your favourite terminal";
      homepage = "https://github.com/charmbracelet/crush";
      license = licenses.fsl11Mit;
      mainProgram = "crush";
      platforms = platforms.unix;
    };
  };
in
{
  home.packages = [ anthropic-api-key ];

  programs.crush = {
    enable = true;
    package = lib.mkForce crushPkg;
    settings = {
      providers = {
        anthropic = {
          type = "anthropic";
          api_key = "Bearer $(anthropic-api-key)";
          extra_headers = {
            "anthropic-version" = "2023-06-01";
            "anthropic-beta" = "oauth-2025-04-20";
          };
          system_prompt_prefix = "You are Claude Code, Anthropic's official CLI for Claude.";
        };
      };
      lsp = {
        go = {
          enabled = true;
          command = "gopls";
          args = [ "--remote=auto" ];
        };
        nix = {
          enabled = true;
          command = "nixd";
        };
        typescript = {
          enabled = true;
          command = "typescript-language-server";
          args = [ "--stdio" ];
        };
      };
      options = {
        context_paths = [ "/etc/nixos/configuration.nix" ];
        tui.compact_mode = true;
        debug = false;
      };
    };
  };
}
