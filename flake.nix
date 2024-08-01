{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/24.05";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      # I don't know if I need an FHS, but just to be on the safe side
      fhs = pkgs.buildFHSUserEnv {
        name = "codeql";
        targetPkgs = pkgs: with pkgs; [
          clang-analyzer
          codeql
          gcc
          gnumake
        ];
      };

    in
    {
      devShells.${system}.default = fhs.env;
    };
}
