{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

# keybr-tui — adaptacyjny trener pisania w terminalu (port algorytmu keybr.com).
# Nie ma go w nixpkgs, wiec budujemy ze zrodel. Gotowe binarki z releasow
# odpadaja: linkuja do /lib64/ld-linux, ktorego na NixOS nie ma.
rustPlatform.buildRustPackage rec {
  pname = "keybr-tui";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "y0sif";
    repo = "keybr-tui";
    rev = "v${version}";
    hash = "sha256-3aQVQgwL5CayyLMi/x0o64PdEZc6Obplbtnsf7I08TU=";
  };

  cargoHash = "sha256-6b+htOhQC4RH4TN5Puy7e6qyIR5SCKgbP71iOScLCQc=";

  meta = {
    description = "Adaptacyjny trener pisania w TUI, port algorytmu keybr.com";
    homepage = "https://github.com/y0sif/keybr-tui";
    license = lib.licenses.mit;
    mainProgram = "keybr-tui";
    platforms = lib.platforms.unix;
  };
}
