{ pkgs, ... }:

{
  # Klient Tora — wyłącznie jako lokalne proxy SOCKS5 na 127.0.0.1:9050,
  # żeby dobić się do serwera domowego po adresie .onion. Operator trzyma
  # serwer za CGNAT, więc nie ma jak połączyć się do niego wprost.
  services.tor = {
    enable = true;
    client.enable = true;
  };

  # ssh gada z proxy SOCKS5 przez `nc -X 5`. Tę opcję ma tylko wersja
  # OpenBSD — GNU netcat jej nie zna.
  environment.systemPackages = [ pkgs.netcat-openbsd ];
}
