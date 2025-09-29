# macOS-specific configuration
{
  config,
  pkgs,
  ...
}: {
  # macOS-specific packages
  home.packages = with pkgs; [
    # Terminal emulators
    # ghostty # Has build issues on macOS due to Wayland dependencies
    # You can install Ghostty directly from https://ghostty.org for macOS
    alacritty # Fast, cross-platform terminal (works great on macOS)

    # Development tools that are particularly useful on macOS
    cocoapods # iOS development
    xcbuild # Xcode build tool

    # System utilities
    coreutils # GNU coreutils (gls, gcp, etc.)
    findutils # GNU find, xargs
    gnused # GNU sed
    gawk # GNU awk

    # macOS-specific productivity tools
    mas # Mac App Store CLI

    # Additional development tools
    docker # Docker CLI (requires Docker Desktop)
  ];

  # macOS-specific shell configuration
  programs.zsh = {
    shellAliases = {
      # Config editing shortcuts (from your current setup)
      zshconfig = "nvim ~/.zshrc";
      ohmyzsh = "nvim ~/.oh-my-zsh";

      # macOS-specific aliases
      brewup = "brew update && brew upgrade && brew cleanup";

      # Quick Look from terminal
      ql = "qlmanage -p";

      # Show/hide hidden files in Finder
      showfiles = "defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder";
      hidefiles = "defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder";

      # Flush DNS cache
      flushdns = "sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder";

      # Home Manager rebuild for macOS
      rebuild = "home-manager switch --flake ~/dev/dotfiles#jacob@macos";
    };

    initContent = ''
      # macOS-specific PATH additions
      export PATH="/opt/homebrew/bin:$PATH"
      export PATH="/opt/homebrew/sbin:$PATH"

      # Python from Homebrew
      export PATH="/opt/homebrew/opt/python@3.11/libexec/bin:$PATH"

      # Ruby from Homebrew
      export PATH="/opt/homebrew/opt/ruby/bin:$PATH"

      # Cargo/Rust
      if [ -f "$HOME/.cargo/env" ]; then
        source "$HOME/.cargo/env"
      fi

      # Phylax
      export PATH="$PATH:$HOME/.phylax/bin"

      # Foundry (for Ethereum development)
      export PATH="$PATH:$HOME/.foundry/bin"

      # Mise (development environment manager)
      if command -v mise &> /dev/null; then
        eval "$(mise activate zsh)"
      fi

      # Nix profile (if not already handled by Home Manager)
      if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
        . "$HOME/.nix-profile/etc/profile.d/nix.sh"
      fi

      # Setting for using GPG with git on macOS
      export GPG_TTY=$(tty)

      # Better performance for macOS
      export HOMEBREW_NO_ANALYTICS=1
      export HOMEBREW_NO_AUTO_UPDATE=1
    '';
  };

  # macOS-specific Git configuration
  programs.git = {
    extraConfig = {
      # Use macOS keychain for credentials
      credential.helper = "osxkeychain";
    };
  };

  # SSH configuration for macOS
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false; # Fix the warning about default values
    matchBlocks = {
      "*" = {
        extraOptions = {
          AddKeysToAgent = "yes";
          UseKeychain = "yes";
          IdentityFile = "~/.ssh/id_ed25519";
        };
      };
    };
  };
}
