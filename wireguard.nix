{ ... }:

{
  # Klient tunelu do serwera domowego.
  # Tunel dzielony — przez wg0 idzie tylko 10.100.0.0/24, reszta internetu
  # normalnie swoją drogą.
  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.100.0.2/24" ];

    # Klucz prywatny nigdy nie trafia do repo — tylko ścieżka do niego.
    privateKeyFile = "/var/lib/secrets/wg-laptop-private";

    peers = [
      {
        # serwer domowy
        publicKey = "vaWpDuPHsQtGDMPC3SyqGaDPISriLzc8QVSJL3EmqXM=";
        allowedIPs = [ "10.100.0.0/24" ];

        # Na razie adres w LAN-ie, żeby sprawdzić sam tunel w oderwaniu od
        # routera. Przy dostępie z zewnątrz wejdzie tu adres publiczny.
        endpoint = "192.168.1.24:51820";

        # Laptop siedzi za NAT-em, więc to on musi podtrzymywać połączenie.
        persistentKeepalive = 25;
      }
    ];
  };
}
