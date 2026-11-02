{
  description = "my Retro daily config for money not safety";

  # ==========================================================
  # INPUTS
  # ==========================================================
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";

    # Only for the coding agents (pi, codex) — the 26.05 versions are too old
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # No follows: keeps its own nixpkgs (unstable) so the Cachix cache hits
    noctalia = {
      url = "github:noctalia-dev/noctalia/cachix";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";

    areofyl-fetch = {
      url = "github:areofyl/fetch";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # ==========================================================
  # OUTPUTS
  # ==========================================================
  outputs =
    inputs:
    let
      lib = inputs.nixpkgs.lib;
    in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.wrapper-modules.flakeModules.wrappers
        inputs.flake-parts.flakeModules.modules

        # Builds packages.<system>.niri — the wrapper with a baked-in config.kdl
        ./niri

        (
          { self, ... }:
          {

            # ==================================================
            # HOST echo
            # ==================================================
            flake.nixosConfigurations.echo = inputs.nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              specialArgs = { inherit inputs self; };
              modules = [

                ./hardware.nix
                ./syncthing.nix
                ./wireguard.nix
                ./tor.nix
                ./noctalia

                # ------------------------------------------------
                # SYSTEM
                # ------------------------------------------------
                (
                  {
                    config,
                    lib,
                    pkgs,
                    inputs,
                    self,
                    ...
                  }:
                  {
                    nixpkgs.config.allowUnfree = true;

                    # Pull a few packages from unstable, leave the rest on 26.05
                    nixpkgs.overlays = [
                      (final: prev: {
                        inherit (inputs.nixpkgs-unstable.legacyPackages.${prev.stdenv.hostPlatform.system})
                          pi-coding-agent
                          codex
                          ;
                      })
                    ];

                    # --- Bootloader ---
                    boot.loader.systemd-boot.enable = true;
                    boot.loader.systemd-boot.configurationLimit = 5;
                    boot.loader.efi.canTouchEfiVariables = true;
                    boot.loader.timeout = 0;

                    # --- Network and time ---
                    networking.hostName = "echo";
                    networking.networkmanager.enable = true;
                    time.timeZone = "Europe/Warsaw";

                    # --- Firmware and power ---
                    services.fwupd.enable = true;
                    hardware.bluetooth.enable = true;
                    services.power-profiles-daemon.enable = true;
                    services.upower.enable = true;

                    # --- Environment variables ---
                    environment.variables = {
                      XKB_DEFAULT_LAYOUT = "pl";
                      DISABLE_TELEMETRY = "1";
                      DISABLE_ERROR_REPORTING = "1";
                      CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY = "1";
                    };

                    # --- Audio (PipeWire) ---
                    security.rtkit.enable = true;
                    services.pulseaudio.enable = false;
                    services.pipewire = {
                      enable = true;
                      alsa.enable = true;
                      alsa.support32Bit = true;
                      pulse.enable = true;
                    };

                    # --- GNOME Keyring ---
                    services.gnome.gnome-keyring.enable = true;
                    security.pam.services.login.enableGnomeKeyring = true;

                    # --- MariaDB ---
                    services.mysql = {
                      enable = true;
                      package = pkgs.mariadb;
                    };

                    # --- User echo ---
                    users.users.echo = {
                      isNormalUser = true;
                      extraGroups = [
                        "wheel"
                        "networkmanager"
                        "plugdev"
                      ];
                      packages = with pkgs; [ tree ];
                    };

                    # --- Fonts ---
                    fonts.packages = with pkgs; [
                      nerd-fonts.jetbrains-mono
                    ];

                    # --- Nix daemon ---
                    nix.settings = {
                      experimental-features = [
                        "nix-command"
                        "flakes"
                      ];
                    };

                    # --- System packages ---
                    environment.systemPackages =
                      with pkgs;
                      [
                        claude-code
                        obsidian
                        vim
                        neovim
                        wget
                        git
                        gh

                        # C++
                        clang
                        llvm
                        cmake
                        ninja

                        # Rust
                        cargo
                        rustc
                        rustfmt
                        clippy
                        rust-analyzer

                        # Zig
                        zig
                        zls

                        # Perl
                        perl

                        # OCaml
                        ocaml
                        ocamlPackages.ocaml-lsp

                        # Desktop and misc
                        foliate
                        fastfetch
                        cpufetch
                        ghostty

                        # Screenshots (niri)
                        grim
                        slurp
                        wl-clipboard
                        xwayland-satellite

                        # Text-mode VM: qemu-system-x86_64 -nographic
                        qemu_kvm

                        # Minecraft launcher
                        prismlauncher
                        

                      ]
                      # Packages coming from flake inputs, not from pkgs
                      ++ [
                        self.packages.${pkgs.stdenv.hostPlatform.system}.niri
                        inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
                        inputs.areofyl-fetch.packages.${pkgs.stdenv.hostPlatform.system}.default
                      ];

                    system.stateVersion = "26.05";
                  }
                )

                # ------------------------------------------------
                # HOME MANAGER — user echo
                # ------------------------------------------------
                inputs.home-manager.nixosModules.home-manager
                {
                  home-manager = {
                    useGlobalPkgs = true;
                    useUserPackages = true;
                    extraSpecialArgs = { inherit inputs self; };
                    backupFileExtension = "backup";

                    users.echo =
                      {
                        config,
                        pkgs,
                        inputs,
                        ...
                      }:
                      {
                        imports = [
                          ./nvim
                        ];

                        home.username = "echo";
                        home.homeDirectory = "/home/echo";
                        home.stateVersion = "26.05";

                        # --- Git ---
                        programs.git = {
                          enable = true;
                          userName = "mirawer";
                          userEmail = "michaljanwernik@gmail.com";

                          # University repos use the PW address instead
                          includes = [
                            {
                              condition = "gitdir:~/Szkoła/";
                              contents = {
                                user = {
                                  name = "mwernik";
                                  email = "michal.wernik.stud@pw.edu.pl";
                                };
                              };
                            }
                          ];
                        };

                        # --- User packages ---
                        home.packages = with pkgs; [
                          tor-browser
                          pavucontrol
                          jq
                          mysql-workbench

                          # pymupdf for the pdf-reader skill — the PyPI wheel does not link on NixOS
                          (python3.withPackages (ps: [ ps.pymupdf ]))

                          # Neovim tooling
                          ripgrep
                          fd
                          
                          # Vis ( leprzy vim ) 
                          vis


                          # pi
                          pi-coding-agent

                          # Codex CLI (OpenAI) — z unstable, patrz overlay wyzej
                          codex

                          nodejs_22
                          yt-dlp
                          ffmpeg
                          sox

                          # Trener pisania w terminalu — brak w nixpkgs, budowany ze zrodel
                          (callPackage ./keybr-tui.nix { })
                        ];

                        # --- Session variables ---
                        home.sessionVariables = {
                          # Playwright on NixOS cannot run a binary fetched by npx
                          PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
                          PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
                        };

                        # --- tmux ---
                        # extended-keys: bez tego tmux tlumi rozszerzone sekwencje
                        # klawiszy (CSI u), przez co pi nie odroznia Shift+Enter
                        # od zwyklego Entera.
                        programs.tmux = {
                          enable = true;
                          extraConfig = ''
                            set -g extended-keys on
                            set -g extended-keys-format csi-u
                          '';
                        };

                        # --- Starship prompt ---
                        # settings trafia do ~/.config/starship.toml (generowany,
                        # read-only) — nie edytowac tego pliku recznie, tylko tutaj.
                        # Integracja z bashem wlacza sie sama wraz z programs.bash.
                        programs.starship = {
                          enable = true;

                          # Ikony z Nerd Fonts — sa juz zainstalowane w systemie
                          presets = [ "nerd-font-symbols" ];

                          settings = {
                            add_newline = true;

                            # Kolor strzalki jako status ostatniej komendy
                            character = {
                              success_symbol = "[➜](bold green)";
                              error_symbol = "[➜](bold red)";
                            };

                            # Pelna sciezka gubi sie w waskim panelu tmuxa
                            directory.truncation_length = 3;

                            # Czas tylko dla komend, ktore faktycznie trwaly
                            cmd_duration.min_time = 2000;

                            # "is 󰏗 v0.1.0" z Cargo.toml/package.json — wersja
                            # projektu i tak jest w pliku, a zjada pol linii
                            package.disabled = true;
                          };
                        };

                        # --- Bash ---
                        programs.bash = {
                          enable = true;

                          shellAliases = {
                            btw = "echo I use nixos, btw";
                            pisanie = "keybr-tui --target-wpm 80";
                            cpp11 = "clang++ -std=c++11 -Wall -Weffc++ -Wextra -Wconversion -Wsign-conversion -Werror";
                            cpp14 = "clang++ -std=c++14 -Wall -Weffc++ -Wextra -Wconversion -Wsign-conversion -Werror";
                            cpp17 = "clang++ -std=c++17 -Wall -Weffc++ -Wextra -Wconversion -Wsign-conversion -Werror";
                            cpp20 = "clang++ -std=c++20 -Wall -Weffc++ -Wextra -Wconversion -Wsign-conversion -Werror";
                            cpp23 = "clang++ -std=c++23 -Wall -Weffc++ -Wextra -Wconversion -Wsign-conversion -Werror";
                            cpp26 = "clang++ -std=c++26 -Wall -Weffc++ -Wextra -Wconversion -Wsign-conversion -Werror";
                          };

                          # pi inside the Obsidian vault. Always under tmux, because
                          # interactive subagents split panes off $TMUX_PANE and
                          # without a session pi errors with "tmux is required for subagents".
                          initExtra = ''
                            piv() {
                              if [ -n "$TMUX" ]; then
                                cd "$HOME/Obsidian Vault/PI" && pi "$@"
                              else
                                tmux new-session -A -s vault -c "$HOME/Obsidian Vault/PI" pi "$@"
                              fi
                            }
                          '';
                        };
                      };
                  };
                }
              ];
            };
          }
        )
      ];

      # Extension point used by ./niri — holds deferred wrapper modules
      options.flake.wrappersModules = lib.mkOption {
        default = { };
        type = lib.types.attrsOf lib.types.deferredModule;
      };

      config.systems = [ "x86_64-linux" ];
    };
}
