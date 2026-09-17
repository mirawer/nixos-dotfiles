# NixOS module. Two separate programs from noctalia-dev:
#   noctalia         — desktop shell, launched by spawn-at-startup in niri's KDL
#   noctalia-greeter — login screen, its own repo and versioning
{
  pkgs,
  inputs,
  self,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  imports = [
    inputs.noctalia-greeter.nixosModules.default
  ];

  # --- Desktop shell ---
  environment.systemPackages = [
    inputs.noctalia.packages.${system}.default
  ];

  # Binary cache for Noctalia v5 (needed because this input has no inputs.nixpkgs.follows)
  nix.settings = {
    extra-substituters = [ "https://noctalia.cachix.org" ];
    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };

  # --- Greeter ---
  programs.noctalia-greeter = {
    enable = true;
    settings = {
      keyboard = {
        layout = "pl";
      };
    };
  };

  # Registers niri.desktop with the greeter
  services.displayManager.sessionPackages = [ self.packages.${system}.niri ];
}
