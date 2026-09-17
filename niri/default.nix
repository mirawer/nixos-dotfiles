{ inputs, self, ... }:
{
  # Empty hook for extending the niri wrapper
  flake.wrappersModules.niri = { ... }: { };

  perSystem =
    { pkgs, system, ... }:
    let
      noctaliaExe = pkgs.lib.getExe inputs.noctalia.packages.${system}.default;
      xwaylandExe = "${pkgs.xwayland-satellite}/bin/xwayland-satellite";
    in
    {

      # `nix run .#niri` — niri with a baked-in config; Nix injects the dependency paths
      packages.niri = inputs.wrapper-modules.wrappers.niri.wrap {
        inherit pkgs;
        imports = [
          self.wrappersModules.niri
          {
            # Sessions belong in share/wayland-sessions/, not share/applications/ — without this the greeter cannot see niri
            config.filesToPatch = [ "share/wayland-sessions/*.desktop" ];

            config."config.kdl".content = ''
              prefer-no-csd

              output "eDP-1" {
                scale 1.25
              }

              input {
                keyboard {
                  xkb {
                    layout "pl"
                  }
                  repeat-rate 35
                  repeat-delay 200
                }
                touchpad {
                  natural-scroll
                  tap
                }
                focus-follows-mouse max-scroll-amount="0%"
                warp-mouse-to-focus
              }

              layout {
                gaps 8
                default-column-width { proportion 0.5; }

                focus-ring {
                  width 2
                  active-color "#9610EF"
                  inactive-color "#3d59a1"
                }
                border {
                  off
                }
                shadow {
                  on
                  softness 30
                  spread 5
                  draw-behind-window true
                  color "#0000007f"
                }
              }

              window-rule {
                geometry-corner-radius 9
                clip-to-geometry true
                draw-border-with-background false
              }

              spawn-at-startup "${noctaliaExe}"

              xwayland-satellite {
                path "${xwaylandExe}"
              }

              blur {
                passes 2
                offset 2
                noise 0.02
                saturation 1.5
              }

              hotkey-overlay {
                skip-at-startup
              }

              binds {
                Mod+Return { spawn "ghostty"; }
                Mod+Q { close-window; }
                Mod+G { maximize-column; }
                Mod+F { fullscreen-window; }
                Mod+Shift+F { toggle-window-floating; }
                Mod+C { center-column; }

                Mod+H { focus-column-left; }
                Mod+L { focus-column-right; }
                Mod+K { focus-window-up; }
                Mod+J { focus-window-down; }
                Mod+Left { focus-column-left; }
                Mod+Right { focus-column-right; }
                Mod+Up { focus-window-up; }
                Mod+Down { focus-window-down; }

                Mod+Shift+H { move-column-left; }
                Mod+Shift+L { move-column-right; }
                Mod+Shift+K { move-window-up; }
                Mod+Shift+J { move-window-down; }

                Mod+1 { focus-workspace 1; }
                Mod+2 { focus-workspace 2; }
                Mod+3 { focus-workspace 3; }
                Mod+4 { focus-workspace 4; }
                Mod+5 { focus-workspace 5; }
                Mod+Shift+1 { move-column-to-workspace 1; }
                Mod+Shift+2 { move-column-to-workspace 2; }
                Mod+Shift+3 { move-column-to-workspace 3; }
                Mod+Shift+4 { move-column-to-workspace 4; }
                Mod+Shift+5 { move-column-to-workspace 5; }

                XF86AudioRaiseVolume allow-when-locked=true { spawn "wpctl" "set-volume" "-l" "1.4" "@DEFAULT_AUDIO_SINK@" "5%+"; }
                XF86AudioLowerVolume allow-when-locked=true { spawn "wpctl" "set-volume" "-l" "1.4" "@DEFAULT_AUDIO_SINK@" "5%-"; }
                XF86AudioMute allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }

                Mod+Ctrl+S { spawn "sh" "-c" "grim -l 0 - | wl-copy"; }
                Mod+Shift+S { spawn "sh" "-c" "grim -g \"$(slurp -w 0)\" - | wl-copy"; }
                Print { spawn "sh" "-c" "grim -l 0 - | wl-copy"; }
                Shift+Print { spawn "sh" "-c" "grim -g \"$(slurp -w 0)\" - | wl-copy"; }
                Mod+D { spawn "${noctaliaExe}" "msg" "panel-toggle" "launcher"; }
                Mod+O { spawn "obsidian"; }
                Mod+B { spawn "zen"; }

                Mod+Shift+E { quit; }

                Mod+Ctrl+H { set-column-width "-5%"; }
                Mod+Ctrl+L { set-column-width "+5%"; }
                Mod+Ctrl+J { set-window-height "-5%"; }
                Mod+Ctrl+K { set-window-height "+5%"; }
              }
            '';
          }
        ];
      };
    };
}
