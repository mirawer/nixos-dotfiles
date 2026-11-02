{ config, lib, pkgs, ... }:
let
  cfg = config.services.syncthing;
in
{
  # Folder/device pairing stays in the GUI; later rebuilds must not erase it.
  services.syncthing = {
    enable = true;
    user = "echo";
    group = "users";
    dataDir = "/home/echo";
    configDir = "/home/echo/.local/state/syncthing";
    guiAddress = "127.0.0.1:8384";
    openDefaultPorts = true;
    overrideDevices = false;
    overrideFolders = false;
    settings.options = {
      localAnnounceEnabled = true;
      globalAnnounceEnabled = true;
      relaysEnabled = true;
      natEnabled = false; # No UPnP/NAT-PMP changes to the router.
      urAccepted = -1;
    };
  };

  # Disable router mapping before serve starts, including the first boot.
  systemd.services.syncthing.serviceConfig.ExecStartPre =
    pkgs.writeShellScript "syncthing-prestart" ''
      umask 0077
      ${lib.getExe cfg.package} generate --config ${lib.escapeShellArg cfg.configDir} --data ${lib.escapeShellArg cfg.databaseDir} >/dev/null
      ${pkgs.xmlstarlet}/bin/xmlstarlet ed -L -u /configuration/options/natEnabled -v false ${lib.escapeShellArg "${cfg.configDir}/config.xml"}
    '';
}
