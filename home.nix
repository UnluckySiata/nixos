{ config, pkgs, userSettings, ... }:

let
  rosepine-fish = pkgs.fetchFromGitHub {
      owner = "rose-pine";
      repo = "fish";
      rev = "38aab5b";
      sha256 = "0bwsq9pz1nlhbr3kyz677prgyk973sgis72xamm1737zqa98c8bd";
  };
in 
{
  nixpkgs.config.allowUnfree = true;

  home.username = userSettings.userName;
  home.homeDirectory = "/home/${userSettings.userName}";

  home.stateVersion = "23.11";

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    firefox
    thunderbird
    tutanota-desktop

    discord
    spotify
    steam

    neovim
    neofetch
    ripgrep
    fd
    fzf
    htop
    eza
    tmux
    tmux-sessionizer

    direnv

    # lsp + more
    nodejs_21
    nixd
    lua-language-server
    # templ
    # htmx-lsp
    vscode-langservers-extracted

    cmake
    (lowPrio llvmPackages_17.clang-unwrapped)
    (hiPrio clang-tools.override { llvmPackages = llvmPackages_17; enableLibcxx = true; })

    cargo
    rustc
    rust-analyzer

    go
    gopls
    delve

    elixir
    elixir-ls

    python3
    pyright

    jdk21
    jdt-language-server

    (nerdfonts.override { fonts = [ "FiraCode" "Hermit" ]; })
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    GOPATH = "$HOME/.go";
    VCPKG_ROOT = "$HOME/source/vcpkg";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
    "$GOPATH/bin"
  ];

  programs.home-manager.enable = true;

  home.shellAliases = {
    v = "nvim";
    nf = "neofetch";
    l = "eza -aBlg";
  };

  programs.git = {
    enable = true;
    userName = userSettings.fullName;
    userEmail = userSettings.email;
    
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
      pull = {
        rebase = "false";
      };
      merge = {
        conflictStyle = "diff3";
      };
    };
  };

  programs.bash = {
    enable = true;
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      fish_vi_key_bindings
      fish_config theme choose "rosepine"

      bind -M insert \cn nextd-or-forward-word
      bind -M insert \cN nextd-or-forward-word
      bind -M insert \cy accept-autosuggestion
    '';
  };

  # bind fish theme to correct dir
  xdg.configFile."fish/themes/rosepine.theme".source = "${rosepine-fish}/themes/Rosé Pine.theme";

  programs.tmux = {
    enable = true;
    mouse = true;
    customPaneNavigationAndResize = true;

    baseIndex = 1;

    prefix = "C-a";
    keyMode = "vi";
    shell = "${pkgs.fish}/bin/fish";

    plugins = with pkgs; [
      tmuxPlugins.catppuccin
    ];

    extraConfig = ''
      set-window-option -g automatic-rename on
      set-option -g set-titles on

      bind-key v split-window -h
      bind-key b split-window -v

      bind-key C-f run-shell "tmux neww tms"
    '';
  };

  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        dimensions = {
          columns = 90;
          lines = 30;
        };
        padding = {
          x = 5;
          y = 5;
        };
        opacity = 0.5;

      };

      font = {
        size = 14.0;
        normal = {
          family = "Hurmit Nerd Font Mono";
          style = "Regular";
        };
        bold = {
          family = "Hurmit Nerd Font Mono";
          style = "Bold";
        };
      };

      shell = {
        program = "${pkgs.tmux}/bin/tmux";
        args = [
          "new-session"
          "-A"
          "-D"
          "-s"
          "main"
        ];
      };
    };
  };
}
