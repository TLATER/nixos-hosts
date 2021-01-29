{
  description = "tlater's host configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-20.09";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: {
    nixosConfigurations = {
      yui = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          (import ./configurations)
          (import ./configurations/yui)
          (import ./configurations/bluetooth.nix)
          (import ./configurations/wifi.nix)
        ];
        specialArgs = { inherit inputs; };
      };
    };
  };
}
