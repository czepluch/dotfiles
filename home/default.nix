# Base Home Manager Configuration
# Essential user-level settings and packages
{
  config,
  pkgs,
  userConfig,
  ...
}: {
  # Home Manager basics
  home = {
    username = userConfig.username;
    homeDirectory = "/home/${userConfig.username}";
    stateVersion = "24.05";

    # Essential user packages
    packages = with pkgs; [
      # Terminal and shell utilities
      alacritty # Backup terminal
      eza # Better ls
      ripgrep # Better grep
      fd # Better find
      bat # Better cat
      fzf # Fuzzy finder
      zoxide # Smart cd
      starship # Shell prompt
      tmux # Terminal multiplexer

      # File management
      ranger # TUI file manager
      file # File type detection
      tree # Directory tree view
      du-dust # Better du
      duf # Better df

      # System monitoring
      btop # Better htop
      bandwhich # Network usage monitor
      hyperfine # Benchmarking tool
      fastfetch # System info display (for flex/rice screenshots)

      # Text processing
      jq # JSON processor
      yq-go # YAML processor

      # Network tools
      wget
      curl
      rsync
      httpie # Better curl for APIs
      gping # Ping with a graph

      # Git workflow
      lazygit # TUI for git
      delta # Better git diff viewer
      gh # GitHub CLI

      # Productivity
      tealdeer # Quick command references (tldr)

      # Programming languages
      rustup # Rust toolchain manager
      gleam # Gleam language
      nixd # Nix language server
      alejandra # Nix formatter

      # Neovim/LazyVim dependencies
      gcc # Required for treesitter
      lua-language-server
      stylua # Lua formatter
    ];
  };

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # Git configuration
  programs.git = {
    enable = true;
    userName = userConfig.name;
    userEmail = userConfig.email;

    delta = {
      enable = true;
      options = {
        navigate = true;
        light = false;
        line-numbers = true;
        side-by-side = false;
        syntax-theme = "Catppuccin-mocha";
      };
    };

    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
      core.editor = "zed --wait"; # Use Zed as editor

      # Better diffs with delta
      diff.algorithm = "histogram";
      diff.colorMoved = "default";
      merge.conflictstyle = "diff3";

      # Useful aliases
      alias = {
        st = "status";
        co = "checkout";
        br = "branch";
        ci = "commit";
        lg = "log --oneline --graph --decorate --all";
        unstage = "reset HEAD --";
        last = "log -1 HEAD";
      };
    };
  };

  # Shell configuration - Zsh with Oh My Zsh features
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Shell aliases
    shellAliases = {
      # File operations
      ll = "eza -la --git";
      ls = "eza --icons";
      la = "eza -la --icons";
      lt = "eza --tree --icons";

      # Better alternatives
      cat = "bat";
      grep = "rg";
      find = "fd";

      # System shortcuts
      rebuild = "sudo nixos-rebuild switch --flake ~/nixos-config";
      home-rebuild = "home-manager switch --flake ~/nixos-config";

      # Quick navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";

      # Git shortcuts
      g = "git";
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git pull";
    };

    # Oh My Zsh configuration
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "docker"
        "docker-compose"
        "node"
        "npm"
        "rust"
        "python"
        "sudo"
        "history"
        "fzf"
      ];
      theme = "robbyrussell"; # Will be overridden by Starship
    };

    # Additional shell configuration
    initContent = ''
      # Initialize zoxide
      eval "$(zoxide init zsh)"

      # FZF configuration
      export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix'
      export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
      export FZF_ALT_C_COMMAND='fd --type d . --strip-cwd-prefix'

      # Use bat for FZF preview
      export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :50 {}'"
      export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -50'"

      # History configuration
      HISTSIZE=10000
      SAVEHIST=10000
      setopt share_history
      setopt hist_expire_dups_first
      setopt hist_ignore_dups
      setopt hist_verify
    '';
  };

  # Starship prompt
  programs.starship = {
    enable = true;
    settings = {
      format = "$all$character";

      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };

      git_branch = {
        format = "[$symbol$branch(:$remote_branch)]($style) ";
        symbol = " ";
      };

      git_status = {
        format = "([\\[$all_status$ahead_behind\\]]($style) )";
      };

      cmd_duration = {
        format = "[$duration]($style) ";
        style = "yellow";
      };

      directory = {
        truncation_length = 3;
        format = "[$path]($style)[$read_only]($read_only_style) ";
      };

      # Language support
      rust = {
        disabled = false;
        format = "[$symbol($version )]($style)";
      };

      gleam = {
        disabled = false;
        format = "[$symbol($version )]($style)";
      };

      solidity = {
        disabled = false;
        format = "[$symbol($version )]($style)";
      };

      nodejs = {
        disabled = false;
        format = "[$symbol($version )]($style)";
      };

      python = {
        disabled = false;
        format = "[$symbol($version )]($style)";
      };

      nix_shell = {
        disabled = false;
        format = "[$symbol$state( \\($name\\))]($style) ";
      };

      package = {
        disabled = false;
        format = "[$symbol$version]($style) ";
      };

      docker_context = {
        disabled = false;
        format = "[$symbol$context]($style) ";
      };
    };
  };

  # Tmux configuration
  programs.tmux = {
    enable = true;
    clock24 = true;
    keyMode = "vi";
    prefix = "C-a";

    extraConfig = ''
      # Better colors
      set -g default-terminal "screen-256color"

      # Mouse support
      set -g mouse on

      # Vim-like pane switching
      bind -r ^ last-window
      bind -r k select-pane -U
      bind -r j select-pane -D
      bind -r h select-pane -L
      bind -r l select-pane -R

      # Start windows and panes at 1
      set -g base-index 1
      set -g pane-base-index 1
      set-window-option -g pane-base-index 1
      set-option -g renumber-windows on
    '';
  };

  # Neovim with LazyVim
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # LazyVim configuration files
  xdg.configFile."nvim/init.lua".text = ''
    -- Bootstrap lazy.nvim
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not vim.loop.fs_stat(lazypath) then
      vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
      })
    end
    vim.opt.rtp:prepend(lazypath)

    -- Load LazyVim
    require("lazy").setup({
      spec = {
        { "LazyVim/LazyVim", import = "lazyvim.plugins" },
        { import = "plugins" },
      },
      defaults = {
        lazy = false,
        version = false,
      },
      checker = { enabled = false },
      performance = {
        rtp = {
          disabled_plugins = {
            "gzip",
            "tarPlugin",
            "tohtml",
            "tutor",
            "zipPlugin",
          },
        },
      },
    })
  '';

  xdg.configFile."nvim/lua/config/lazy.lua".text = ''
    return {}
  '';

  xdg.configFile."nvim/lua/config/options.lua".text = ''
    -- Options are automatically loaded before lazy.nvim startup
    vim.g.mapleader = " "
    vim.g.maplocalleader = "\\"
  '';

  xdg.configFile."nvim/lua/config/keymaps.lua".text = ''
    -- Keymaps are automatically loaded
  '';

  xdg.configFile."nvim/lua/config/autocmds.lua".text = ''
    -- Autocmds are automatically loaded
  '';

  xdg.configFile."nvim/lua/plugins/init.lua".text = ''
    -- Custom plugins can be added here
    return {}
  '';

  # Alacritty terminal configuration
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        opacity = 0.9;
        padding = {
          x = 10;
          y = 10;
        };
      };

      font = {
        normal = {
          family = "JetBrainsMono Nerd Font";
          style = "Regular";
        };
        bold = {
          family = "JetBrainsMono Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "JetBrainsMono Nerd Font";
          style = "Italic";
        };
        size = 11.0;
      };

      colors = {
        primary = {
          background = "#1e1e2e";
          foreground = "#cdd6f4";
        };
      };
    };
  };

  # XDG directories
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
      desktop = "${config.home.homeDirectory}/desktop";
      documents = "${config.home.homeDirectory}/documents";
      download = "${config.home.homeDirectory}/downloads";
      music = "${config.home.homeDirectory}/music";
      pictures = "${config.home.homeDirectory}/pictures";
      videos = "${config.home.homeDirectory}/videos";
      templates = "${config.home.homeDirectory}/templates";
      publicShare = "${config.home.homeDirectory}/public";
    };
  };
}
