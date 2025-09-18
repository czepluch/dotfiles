# Minimal Home Manager Configuration
# This handles user-level packages and settings
{ config, pkgs, ... }:

{
  # Basic info
  home = {
    username = "jstcz";
    homeDirectory = "/home/jstcz";
    stateVersion = "24.05";

    # User packages
    packages = with pkgs; [
      # Editors
      zed-editor
      neovim

      # Terminal
      warp-terminal
      alacritty  # Backup terminal

      # CLI tools
      eza        # Better ls
      ripgrep    # Better grep
      fd         # Better find
      bat        # Better cat
      fzf        # Fuzzy finder
      tree       # Directory tree
      htop       # Process monitor
      unzip
      zip

      # Hyprland ecosystem
      waybar             # Status bar
      wofi               # App launcher
      mako               # Notifications
      grimblast          # Screenshots
      copyq              # Clipboard manager
      swww               # Wallpaper daemon

      # Apps
      firefox
      bitwarden

      # File management
      dolphin            # File manager
    ];
  };

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # Git configuration
  programs.git = {
    enable = true;
    userName = "czepluch";
    userEmail = "j.czepluch@proton.me";
    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };
  };

  # Zsh with basic setup
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "eza -la";
      ls = "eza";
      cat = "bat";
      grep = "rg";
      find = "fd";

      # NixOS shortcuts
      rebuild = "sudo nixos-rebuild switch --flake ~/dotfiles/minimal#anonfunc";
      home-rebuild = "home-manager switch --flake ~/dotfiles/minimal#jstcz@anonfunc";
    };
  };

  # Firefox with basic setup
  programs.firefox = {
    enable = true;
    profiles.dev = {
      isDefault = true;
      settings = {
        "privacy.trackingprotection.enabled" = true;
        "browser.startup.homepage" = "about:home";
      };
    };
  };

  # Neovim with LazyVim (auto-installs on first run)
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = false;  # Zed is primary
  };

  # Create config directories
  home.file = {
    # Empty Zed config directory
    ".config/zed/.keep".text = "";

    # Empty Hyprland config directory
    ".config/hypr/.keep".text = "";

    # Empty waybar config directory
    ".config/waybar/.keep".text = "";

    # LazyVim configuration (auto-installs on first nvim run)
    ".config/nvim/init.lua".text = ''
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

      -- Configure LazyVim
      require("lazy").setup({
        -- LazyVim
        {
          "LazyVim/LazyVim",
          import = "lazyvim.config",
        },
        -- Import LazyVim plugins
        { import = "lazyvim.plugins" },
        -- Language support
        { import = "lazyvim.plugins.extras.lang.json" },
        { import = "lazyvim.plugins.extras.lang.markdown" },
      }, {
        defaults = {
          lazy = false,
          version = false,
        },
        install = { colorscheme = { "tokyonight", "habamax" } },
        checker = { enabled = true },
      })
    '';
  };
}
