{ lib, ... }:

with lib;
let
  # Recursively constructs an attrset mirroring a folder tree, recursing on
  # directories; the value of each leaf is its filetype.
  getDir = dir: mapAttrs
    (file: type:
      if type == "directory" then getDir "${dir}/${file}" else type
    )
    (builtins.readDir dir);

  # Collects every file under a directory as a list of relative path strings.
  files = dir: collect isString (mapAttrsRecursive (path: type: concatStringsSep "/" path) (getDir dir));

  # Keeps only importable modules (`.nix` files other than this one) and makes
  # their paths absolute to this directory.
  importAll = dir: map
    (file: ./. + "/${file}")
    (filter
      (file: hasSuffix ".nix" file && file != "default.nix")
      (files dir));

in
{
  imports = importAll ./.;
}
