# Home Manager configuration for dev user
{ config, lib, pkgs, inputs, ... }:

let
  # Define the dotfiles directory for cleaner path references
  dotfilesDir = "${config.home.homeDirectory}/dotfiles";
in

{
  # Home Manager needs a bit of information about you and the paths it should manage
  home = {
    username = "dev";
    homeDirectory = "/home/dev";
    stateVersion = "24.05"; # Please read the comment before changing

    # Environment variables
    sessionVariables = {
      EDITOR = "zed";
      BROWSER = "firefox";
      TERMINAL = "warp";

      # Development
      NIXOS_CONFIG = "$HOME/dotfiles";
      FLAKE = "$HOME/dotfiles";

      # Path additions
      PATH = "$PATH:$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.npm/bin";
    };

    # User-specific packages
    packages = with pkgs; [
      # Development tools
      rustc
      cargo
      rust-analyzer
      nodejs_20
      npm
      yarn
      bun
      python3
      python3Packages.pip
      go

      # Version control
      git
      git-lfs
      gh # GitHub CLI

      # File management
      fd
      ripgrep
      eza
      bat
      fzf
      tree
      unzip
      zip

      # System monitoring
      htop
      btop
      neofetch
      du-dust
      procs

      # Network tools
      wget
      curl
      httpie

      # Media
      mpv
      imv

      # Communication
      discord
      slack

      # Productivity
      obsidian

      # AppImage support
      appimage-run

      # Custom packages (from our overlay)
      cursor-appimage
      warp-terminal
    ];
  };

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # Git configuration
  programs.git = {
    enable = true;
    userName = "Your Name"; # TODO: Replace with actual name
    userEmail = "your.email@example.com"; # TODO: Replace with actual email

    extraConfig = {
      init.defaultBranch = "main";
      core = {
        editor = "zed --wait";
        autocrlf = false;
      };
      pull.rebase = true;
      push.autoSetupRemote = true;
      rerere.enabled = true;

      # Better diffs
      diff = {
        algorithm = "patience";
        compactionHeuristic = true;
      };
    };

    aliases = {
      st = "status";
      co = "checkout";
      br = "branch";
      ci = "commit";
      ca = "commit -a";
      cam = "commit -am";
      unstage = "reset HEAD --";
      last = "log -1 HEAD";
      visual = "!gitk";

      # Pretty logs
      lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      lga = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --all";
    };
  };

  # Zsh configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [
        "git"
        "docker"
        "rust"
        "node"
        "npm"
        "python"
        "sudo"
        "history"
        "colored-man-pages"
        "command-not-found"
        "zsh-autosuggestions"
      ];
    };

    shellAliases = {
      # System
      ll = "eza -la";
      ls = "eza";
      la = "eza -la";
      tree = "eza --tree";
      cat = "bat";
      grep = "rg";
      find = "fd";
      ps = "procs";

      # Git
      g = "git";
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git pull";

      # NixOS
      rebuild = "sudo nixos-rebuild switch --flake ~/dotfiles";
      home-rebuild = "home-manager switch --flake ~/dotfiles";
      nix-gc = "sudo nix-collect-garbage -d && nix-collect-garbage -d";

      # Development
      v = "zed";
      vim = "nvim";

      # Quick navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
    };

    initExtra = ''
      # Custom functions
      mkcd() { mkdir -p "$1" && cd "$1"; }

      # Better history
      setopt HIST_IGNORE_DUPS
      setopt HIST_IGNORE_ALL_DUPS
      setopt HIST_SAVE_NO_DUPS
      setopt HIST_IGNORE_SPACE
      setopt HIST_VERIFY
      setopt EXTENDED_HISTORY

      # Auto-suggestions
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

      # FZF integration
      if command -v fzf >/dev/null 2>&1; then
        source <(fzf --zsh)
      fi

      # Load custom configurations
      [ -f ~/.config/zsh/local.zsh ] && source ~/.config/zsh/local.zsh
    '';
  };

  # Neovim with LazyVim (for quick edits)
  programs.neovim = {
    enable = true;
    defaultEditor = false; # Zed is primary
    viAlias = true;
    vimAlias = true;
  };

  # Firefox configuration
  programs.firefox = {
    enable = true;

    profiles.dev = {
      isDefault = true;

      settings = {
        # Privacy settings
        "privacy.trackingprotection.enabled" = true;
        "privacy.donottrackheader.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;

        # Performance
        "gfx.webrender.all" = true;
        "media.ffmpeg.vaapi.enabled" = true;

        # UI
        "browser.tabs.warnOnClose" = false;
        "browser.startup.homepage" = "about:home";

        # Developer tools
        "devtools.theme" = "dark";
      };

      extensions = with inputs.firefox-addons.packages.${pkgs.system}; [
        ublock-origin
        bitwarden
        privacy-badger
        decentraleyes
        clearurls
        darkreader
      ];
    };
  };

  # GPG
  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };

  # Direnv for project environments
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  # Starship prompt
  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      add_newline = false;

      format = lib.concatStrings [
        "$directory"
        "$git_branch"
        "$git_state"
        "$git_status"
        "$cmd_duration"
        "$line_break"
        "$character"
      ];

      directory = {
        style = "blue bold";
        truncation_length = 3;
        truncate_to_repo = true;
      };

      character = {
        success_symbol = "[❯](purple)";
        error_symbol = "[❯](red)";
        vimcmd_symbol = "[❮](green)";
      };

      git_branch = {
        format = "[$branch]($style)";
        style = "bright-black";
      };

      git_status = {
        format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](218) ($ahead_behind$stashed)]($style)";
        style = "cyan";
        conflicted = "​";
        untracked = "​";
        modified = "​";
        staged = "​";
        renamed = "​";
        deleted = "​";
        stashed = "≡";
      };

      git_state = {
        format = "\([$state( $progress_current/$progress_total)]($style)\) ";
        style = "bright-black";
      };

      cmd_duration = {
        format = "[$duration]($style) ";
        style = "yellow";
      };
    };
  };

  # XDG directories
  xdg = {
    enable = true;

    configFile = {
      # Zed configuration
      "zed/settings.json".source = "${dotfilesDir}/config/zed/settings.json";

      # LazyVim configuration
      "nvim" = {
        source = "${dotfilesDir}/config/nvim";
        recursive = true;
      };
    };

    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "x-scheme-handler/about" = "firefox.desktop";
        "x-scheme-handler/unknown" = "firefox.desktop";

        "text/plain" = "zed.desktop";
        "application/json" = "zed.desktop";

        "image/jpeg" = "imv.desktop";
        "image/png" = "imv.desktop";
        "image/gif" = "imv.desktop";

        "video/mp4" = "mpv.desktop";
        "video/x-matroska" = "mpv.desktop";

        "inode/directory" = "dolphin.desktop";
      };
    };
  };

  # Services
  services = {
    # GPG agent
    gpg-agent.enable = true;

    # Syncthing for file sync
    syncthing.enable = true;
  };

  # Font configuration
  fonts.fontconfig.enable = true;
}
