{
  description = "tlater's host configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-20.09";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    flake-utils.url = "github:numtide/flake-utils";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-20.09";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dotfiles = {
      url = "github:tlater/dotfiles";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-unstable.follows = "nixpkgs-unstable";
      inputs.home-manager.follows = "home-manager";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { nixpkgs, nixpkgs-unstable, nixos-hardware, flake-utils, sops-nix
    , home-manager, dotfiles, ... }:
    let
      # A helper function that removes the duplication of things that
      # will be common across all hosts.
      make-nixos-system = { nixpkgs, system, modules ? [ ] }:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          # Set allowed unfree packages on unstable; this can't be
          # done where they are used sadly because it's used as an
          # overlay.
          allow-nvidia = pkg:
            builtins.elem (pkgs.lib.getName pkg) [
              "nvidia-x11"
              "nvidia-settings"
              "nvidia-persistenced"
            ];

          # Overlays to be added to the system
          overlays = [
            (final: prev: {
              tlater = (import ./pkgs { pkgs = prev; });
              unstable = import nixpkgs-unstable {
                inherit system;
                config.allowUnfreePredicate = allow-nvidia;
              };
            })
          ];
        in nixpkgs.lib.nixosSystem {
          inherit system;

          # The configuration modules
          modules = [
            (import ./configurations)
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager

            ({ ... }: { nixpkgs.overlays = overlays; })
          ] ++ modules;

          # Additional modules with custom configuration options
          extraModules = [ (import ./modules) ];
        };

    in {
      nixosConfigurations = {
        yui = make-nixos-system {
          nixpkgs = nixpkgs;
          system = "x86_64-linux";
          modules = [
            (import ./configurations/yui)
            (dotfiles.lib.nixosConfigurationFromProfile
              dotfiles.profiles.pcs.personal "tlater")
          ];
        };

        ct-lt-02052 = make-nixos-system {
          nixpkgs = nixpkgs;
          system = "x86_64-linux";
          modules = [
            (import ./configurations/ct-lt-02052)
            (dotfiles.lib.nixosConfigurationFromProfile
              dotfiles.profiles.pcs.work "tlater")

            nixos-hardware.nixosModules.lenovo-thinkpad-t490
          ];
        };
      };
    }
    # Set up a "dev shell" that will work on all architectures.
    // (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        sops-pkgs = sops-nix.packages.${system};
      in {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; with sops-pkgs; [ nixfmt sops-init-gpg-key ];
          nativeBuildInputs = with sops-pkgs; [ sops-pgp-hook ];
          sopsPGPKeyDirs = [ "./keys/hosts/" "./keys/users/" ];
        };
      }));
}
