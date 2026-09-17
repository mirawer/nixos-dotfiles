# Home Manager module. The Lua config lives in ./config and is linked as-is.
{ ... }:
{
  # builtins.path only so the store path is named "nvim" rather than
  # "config" (the default is the directory's basename)
  xdg.configFile."nvim".source = builtins.path {
    path = ./config;
    name = "nvim";
  };
}
