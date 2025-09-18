# Shared configuration for both macOS and NixOS
{
  config,
  pkgs,
  gitName,
  gitEmail,
  ...
}: {
  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # Common packages that work on both platforms
  home.packages = with pkgs; [
    # Modern CLI tools
    eza # Better ls
    ripgrep # Better grep
    fd # Better find
    bat # Better cat
    fzf # Fuzzy finder
    tree # Directory tree
    htop # Process monitor
    jq # JSON processor
    yq # YAML processor
    tldr # Simplified man pages

    # Archive tools
    unzip
    zip

    # Development tools
    git
    gh # GitHub CLI
    delta # Better git diff
    lazygit # Terminal git UI

    # Network tools
    curl
    wget
    httpie

    # Text processing
    sd # Better sed
    tokei # Code statistics

    # Terminal multiplexer
    tmux

    # File management
    ranger # Terminal file manager
  ];

  # Git configuration
  programs.git = {
    enable = true;
    userName = gitName;
    userEmail = gitEmail;

    delta = {
      enable = true;
      options = {
        navigate = true;
        light = false;
        side-by-side = true;
      };
    };

    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = false;

      # Better diffs
      diff.algorithm = "histogram";
      merge.conflictstyle = "zdiff3";

      # Reuse recorded resolution of conflicted merges
      rerere.enabled = true;

      # Better performance
      core.fsmonitor = true;
      feature.manyFiles = true;
    };

    aliases = {
      st = "status -sb";
      co = "checkout";
      br = "branch";
      ci = "commit";
      unstage = "reset HEAD --";
      last = "log -1 HEAD";
      lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
    };
  };

  # Zsh configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 100000;
      save = 100000;
      share = true;
      extended = true;
      ignoreDups = true;
      ignoreSpace = true;
    };

    shellAliases = {
      # Modern replacements
      ll = "eza -la --icons";
      ls = "eza --icons";
      la = "eza -a --icons";
      lt = "eza --tree --icons";
      cat = "bat";
      grep = "rg";
      find = "fd";

      # Git shortcuts
      g = "git";
      gs = "git status";
      gd = "git diff";
      gc = "git commit";
      gp = "git push";
      gl = "git pull";

      # Navigation
      up = "cd ..";
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";

      # Safety nets
      rm = "rm -i";
      cp = "cp -i";
      mv = "mv -i";

      # Home Manager shortcuts
      hm = "home-manager";
      hms = "home-manager switch --flake ~/dev/dotfiles#$(whoami)@macos";
      hme = "nvim ~/dev/dotfiles/home/common.nix";
    };

    initContent = ''
      # Better history searching
      bindkey '^R' history-incremental-search-backward
      bindkey '^S' history-incremental-search-forward
      bindkey '^P' history-search-backward
      bindkey '^N' history-search-forward

      # Navigate words with option+arrow
      bindkey '^[[1;5C' forward-word
      bindkey '^[[1;5D' backward-word

      # FZF integration
      if command -v fzf &> /dev/null; then
        source <(fzf --zsh)
      fi

      # Set default editor
      export EDITOR="nvim"
      export VISUAL="nvim"

      # Better ls colors
      export EZA_COLORS="uu=36:gu=37:sn=32:sb=32:da=34:ur=34:uw=35:ux=36:ue=36:gr=34:gw=35:gx=36:tr=34:tw=35:tx=36:"
    '';
  };

  # Neovim configuration - LazyVim will handle its own setup on first run
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;

    # Only essential language servers
    extraPackages = with pkgs; [
      # Lua for neovim config
      lua-language-server

      # Solidity
      vscode-solidity-server

      # Python basics
      pyright

      # Rust
      rust-analyzer
    ];
  };

  # Tmux configuration
  programs.tmux = {
    enable = true;
    clock24 = true;
    keyMode = "vi";
    terminal = "screen-256color";
    historyLimit = 10000;

    extraConfig = ''
      # Better prefix
      set -g prefix C-a
      unbind C-b
      bind C-a send-prefix

      # Fast escape
      set -sg escape-time 0

      # Start windows and panes at 1
      set -g base-index 1
      setw -g pane-base-index 1

      # Renumber windows on close
      set -g renumber-windows on

      # Split with | and -
      bind | split-window -h
      bind - split-window -v

      # Vim-like pane navigation
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Enable mouse
      set -g mouse on

      # Better colors
      set -g default-terminal "screen-256color"
      set -ga terminal-overrides ",*256col*:Tc"
    '';
  };

  # Starship prompt
  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      format = "$all$character";

      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };

      directory = {
        style = "blue bold";
        truncate_to_repo = false;
        truncation_length = 3;
      };

      git_branch = {
        style = "green bold";
        symbol = " ";
      };

      git_status = {
        style = "red bold";
        ahead = "⇡$count";
        diverged = "⇕⇡$ahead_count⇣$behind_count";
        behind = "⇣$count";
      };

      cmd_duration = {
        min_time = 500;
        format = "took [$duration](bold yellow)";
      };
    };
  };

  # Direnv for automatic environment loading
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  # FZF configuration
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
      "--info=inline"
    ];
  };

  # Config files that are directly symlinked from our dotfiles repo
  home.file = {
    # Zed editor settings - you can edit this file directly!
    ".config/zed/settings.json".source = ../config/zed/settings.json;
  };
}
