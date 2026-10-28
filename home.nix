{
  config,
  lib,
  pkgs,
  ...
}: let
  dotFiles = builtins.attrNames (builtins.readDir ./configs);
  cmdAliases = {
    # Replace the default ls command with lsd for better output
    ls = "lsd";

    # Show the full listing with lsd command
    ll = "lsd -lah";

    # Show the current directory tree with lsd
    lt = "ls --tree";

    # Configure micro editor to disable the bottom status line for more space
    micro = "micro -statusline off";

    # Show the full directory listing with tree view
    tree = "ls --tree";

    # Use fzf for previewing files with bat for syntax highlighting
    preview = "fzf --preview 'bat --color \"always\" {}'";
  };

  # Installs the apps listed in apps.txt by Homebrew cask name, without Homebrew.
  installApps = pkgs.writeShellApplication {
    name = "install-apps";
    runtimeInputs = with pkgs; [
      curl
      jq
      coreutils
      gnugrep
      gnused
    ];
    text =
      ''
        DOTFILES=${lib.escapeShellArg config.dotfiles}
      ''
      + builtins.readFile ./install-apps.sh;
  };

  # Weekly Nix garbage collection that reports how much space it reclaimed.
  # Nix prints "<n> MiB freed"; the notification shows that figure in GB.
  nixGcNotify = pkgs.writeShellScript "nix-gc-notify" ''
    log=/tmp/nix-gc.log
    if /nix/var/nix/profiles/default/bin/nix-collect-garbage -d > "$log" 2>&1; then
      mib=$(/usr/bin/sed -n 's/.* \([0-9.]*\) MiB freed.*/\1/p' "$log" | /usr/bin/tail -1)
      gb=$(/usr/bin/awk -v m="''${mib:-0}" 'BEGIN { printf "%.1f", m / 1024 }')
      msg="Nix store pruned: $gb GB reclaimed"
    else
      msg="Nix prune failed, see /tmp/nix-gc.log"
    fi
    ${pkgs.terminal-notifier}/bin/terminal-notifier \
      -title "Weekly cleanup" \
      -message "$msg" \
      -sound default
  '';
in {
  options = {
    dotfiles = lib.mkOption {
      type = lib.types.path;
      apply = toString;
      default = "${config.home.homeDirectory}/dotfiles";
      example = "/Users/jane/dotfiles";
      description = "Location of the dotfiles working copy";
    };
  };

  config = {
    home = {
      username = builtins.getEnv "USER";
      homeDirectory = builtins.getEnv "HOME";
      stateVersion = "22.05";

      packages = with pkgs; [
        home-manager
        jq
        lsd
        delta
        bat
        awscli
        google-cloud-sdk
        cloudflared
        coreutils
        curl
        fd
        findutils
        git
        micro
        moreutils
        nodejs
        peco
        pay-respects
        tree
        wget
        openssl
        stow
        font-awesome
        powerline-fonts
        powerline-symbols
        devbox
        installApps
      ];

      file = lib.mkMerge (
        (map (fileName: {
            "${fileName}" = {
              source = config.lib.file.mkOutOfStoreSymlink "${config.dotfiles}/configs/${fileName}";
            };
          })
          dotFiles)
        ++ [
          {
            # The global Devbox packages live in this repo so a new machine gets the same tools.
            ".local/share/devbox/global/default/devbox.json".source =
              config.lib.file.mkOutOfStoreSymlink "${config.dotfiles}/devbox-global.json";
          }
        ]
      );

      # The skills repo is edited and pushed by hand, so Home Manager only clones it once.
      # It is skipped quietly when GitHub access is not set up yet; re-run after authenticating.
      activation.agentSkills = lib.hm.dag.entryAfter ["linkGeneration"] ''
        if [ ! -d "$HOME/.agents/skills/.git" ]; then
          run mkdir -p "$HOME/.agents"
          GIT_SSH_COMMAND="ssh -o BatchMode=yes" \
            run ${pkgs.git}/bin/git clone git@github.com:mridang/skills.git "$HOME/.agents/skills" \
            || echo "Skipped cloning the skills repo; authenticate with GitHub and re-run make apply."
        fi
      '';

      sessionVariables = {
        # Let's use Nano as the default editor. I'm not very good with VIM.
        EDITOR = "nano";

        # Don’t clear the screen after quitting a manual page
        MANPAGER = "less -X";

        # Prefer US English and use UTF-8
        LC_ALL = "en_US.UTF-8";
        LANG = "en_US";

        HOMEBREW_CASK_OPTS = "--appdir=/Applications";

        # Disable the Mac coloured listing so that instead of the LSCOLOURS, the commands
        # (including tree) use the LS_COLOURS variable
        # https://unix.stackexchange.com/q/2897/56262

        CLICOLOR = "1";
        CLICOLOR_FORCE = "1";
      };
    };

    xdg.enable = true;

    launchd.agents.nix-gc = {
      enable = true;
      config = {
        ProgramArguments = ["${nixGcNotify}"];
        StartCalendarInterval = [
          {
            Weekday = 0;
            Hour = 10;
            Minute = 0;
          }
        ];
        StandardOutPath = "/tmp/nix-gc-agent.log";
        StandardErrorPath = "/tmp/nix-gc-agent.log";
      };
    };

    programs = {
      starship = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
      };

      atuin = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
      };

      fzf = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
      };

      zoxide = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
      };

      direnv = {
        enable = true;
        nix-direnv.enable = true;
      };

      bash = {
        enable = true;
        shellAliases = cmdAliases;
      };

      zsh = {
        enable = true;
        shellAliases = cmdAliases;
        initContent = ''
          eval "$(devbox global shellenv)"

          # ~/.npmrc reads the GitHub Packages token from this variable.
          if command -v gh >/dev/null 2>&1; then
            export GITHUB_TOKEN="$(gh auth token 2>/dev/null)"
          fi
        '';
      };
    };
  };
}
