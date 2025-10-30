# Developer Profile
# Additional packages and configurations for software development
{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Programming Languages and Runtimes
    nodejs_20
    python3
    python3Packages.pip
    rustc
    cargo
    go
    # java  # Uncomment if needed
    # dotnet-sdk  # Uncomment if needed

    # Development Tools
    docker
    docker-compose
    kubectl
    # terraform  # Uncomment if needed
    # ansible    # Uncomment if needed

    # Databases
    sqlite
    postgresql
    redis
    # mongodb    # Uncomment if needed

    # API Testing
    insomnia
    # postman    # Uncomment if needed

    # Version Control
    gh                    # GitHub CLI
    git-lfs
    lazygit               # Terminal UI for git
    tig                   # Text-mode interface for git

    # Build Tools
    cmake
    gnumake
    ninja
    pkg-config

    # Network Tools
    wireshark
    nmap
    netcat-gnu
    tcpdump

    # Containers and Virtualization
    podman                # Alternative to Docker
    distrobox             # Run other Linux distros

    # Cloud Tools
    # awscli2             # Uncomment if using AWS
    # google-cloud-sdk    # Uncomment if using GCP
    # azure-cli           # Uncomment if using Azure

    # Monitoring and Performance
    htop
    btop
    iotop
    strace
    ltrace

    # Text Editors (CLI)
    neovim
    helix                 # Modern modal editor

    # Language Servers (for editor support)
    rust-analyzer
    gopls
    nodePackages.typescript-language-server
    nodePackages.vscode-langservers-extracted
    python3Packages.python-lsp-server
    # nil                 # Nix language server (already in dev shell)

    # Formatters
    nixpkgs-fmt          # Nix
    rustfmt              # Rust
    nodePackages.prettier # Web technologies
    black                # Python
    gofmt                # Go (comes with go)

    # Terminal Applications
    lazydocker           # Docker TUI
    k9s                  # Kubernetes TUI
    bottom               # System monitor
    bandwhich            # Network monitor

    # Documentation
    tldr                 # Simplified man pages
    cheat                # Cheatsheets

    # File Transfer
    rsync
    scp
    sftp
  ];

  # Git configuration for development
  programs.git = {
    extraConfig = {
      # Signing commits (uncomment and configure if you use GPG)
      # commit.gpgsign = true;
      # user.signingkey = "YOUR_GPG_KEY";

      # Better merge conflict resolution
      merge.conflictstyle = "diff3";

      # Useful for rebasing
      rebase.autosquash = true;
      rebase.autostash = true;

      # Performance for large repos
      core.preloadindex = true;
      core.fscache = true;
      gc.auto = 256;

      # Additional aliases for development
      alias = {
        # Workflow
        wip = "commit -am 'WIP'";
        unwip = "reset HEAD~1";
        amend = "commit --amend --no-edit";
        force = "push --force-with-lease";

        # Information
        contributors = "shortlog --summary --numbered";
        files = "diff-tree --no-commit-id --name-only -r";

        # Cleanup
        cleanup = "!git branch --merged | grep -v '\\*\\|master\\|main\\|develop' | xargs -n 1 git branch -d";
      };
    };
  };

  # Enhanced Zsh configuration for development
  programs.zsh = {
    shellAliases = {
      # Docker
      d = "docker";
      dc = "docker-compose";
      dps = "docker ps";
      dimg = "docker images";
      dlog = "docker logs";

      # Kubernetes
      k = "kubectl";
      kgp = "kubectl get pods";
      kgs = "kubectl get services";
      kdp = "kubectl describe pod";
      kaf = "kubectl apply -f";

      # Git (additional)
      gaa = "git add .";
      gcm = "git commit -m";
      gco = "git checkout";
      gcb = "git checkout -b";
      gbd = "git branch -d";
      gpo = "git push origin";
      gpl = "git pull";
      gf = "git fetch";
      gm = "git merge";
      gr = "git rebase";

      # Development servers
      serve = "python3 -m http.server 8000";
      pyserve = "python3 -m http.server";

      # Process management
      ports = "netstat -tulanp";
      listening = "lsof -i -P -n | grep LISTEN";
    };

    initExtra = ''
      # Development environment variables
      export EDITOR="code --wait"
      export BROWSER="firefox"
      export TERM="xterm-256color"

      # Go
      export GOPATH="$HOME/go"
      export PATH="$PATH:$GOPATH/bin"

      # Rust
      export PATH="$PATH:$HOME/.cargo/bin"

      # Node.js
      export PATH="$PATH:$HOME/.local/bin"

      # Python
      export PATH="$PATH:$HOME/.local/bin"

      # Docker buildkit
      export DOCKER_BUILDKIT=1

      # Development functions

      # Create and enter directory
      mkcd() {
        mkdir -p "$1" && cd "$1"
      }

      # Find and kill process by port
      killport() {
        lsof -ti:$1 | xargs kill -9
      }

      # Quick git commit with message
      gc() {
        git add .
        git commit -m "$1"
      }

      # Quick git commit and push
      gcp() {
        git add .
        git commit -m "$1"
        git push
      }

      # Switch to git branch or create if doesn't exist
      gcob() {
        git checkout -b $1 2>/dev/null || git checkout $1
      }
    '';
  };

  # Neovim configuration for development
  programs.neovim = {
    enable = true;
    defaultEditor = false;  # VS Code is primary
    viAlias = true;
    vimAlias = true;

    extraConfig = ''
      " Basic settings
      set number
      set relativenumber
      set tabstop=2
      set shiftwidth=2
      set expandtab
      set smartindent
      set wrap
      set smartcase
      set noswapfile
      set nobackup
      set undodir=~/.vim/undodir
      set undofile
      set incsearch
      set hlsearch
      set hidden
      set scrolloff=8
      set colorcolumn=80
      set signcolumn=yes

      " Key mappings
      let mapleader = " "

      " Better navigation
      nnoremap <C-h> <C-w>h
      nnoremap <C-j> <C-w>j
      nnoremap <C-k> <C-w>k
      nnoremap <C-l> <C-w>l

      " Clear search highlighting
      nnoremap <leader>h :nohl<CR>

      " Quick save
      nnoremap <leader>w :w<CR>

      " Quit
      nnoremap <leader>q :q<CR>

      " File explorer
      nnoremap <leader>e :Ex<CR>
    '';
  };

  # Development directories
  home.file = {
    # Create common development directories
    "Development/.keep".text = "";
    "Development/projects/.keep".text = "";
    "Development/learning/.keep".text = "";
    "Development/tools/.keep".text = "";

    # Git templates
    ".git-templates/hooks/pre-commit" = {
      text = ''
        #!/bin/sh
        # Run code formatting before commit
        if command -v nixpkgs-fmt > /dev/null; then
          nixpkgs-fmt $(find . -name "*.nix")
        fi
      '';
      executable = true;
    };
  };

  # XDG directories for development
  xdg.userDirs = {
    # Override default directories for development workflow
    desktop = "${config.home.homeDirectory}/Desktop";
    documents = "${config.home.homeDirectory}/Documents";
    download = "${config.home.homeDirectory}/Downloads";

    # Development-specific
    templates = "${config.home.homeDirectory}/Development/templates";
    publicShare = "${config.home.homeDirectory}/Development/shared";
  };
}