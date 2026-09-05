# flake.nix
{
  description = "something which describes something";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";

    # I dont really need this ngl
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    # Follows Unstable
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.1.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    driftwm = {
      url = "github:malbiruk/driftwm";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    # Follows Stable
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    home-manager-stable = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
  };

  outputs =
    { nixpkgs, nixpkgs-stable, ... }@inputs:
    {
      nixosConfigurations = {
        archongrid = nixpkgs-stable.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./hosts/archongrid ];
          specialArgs = { inherit inputs; };
        };

        thingamajig = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./hosts/thingamajig ];
          specialArgs = { inherit inputs; };
        };

        lapbottom = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./hosts/lapbottom ];
          specialArgs = { inherit inputs; };
        };
      };

      # Standalone HM for non NixOS Systems
      # Build with: home-manager switch --flake .#racc@thingamajig
      #     homeConfigurations = {
      #       "racc@thingamajig" = inputs.home-manager.lib.homeManagerConfiguration {
      #         pkgs = import nixpkgs {
      #           system = "x86_64-linux";
      #           config.allowUnfree = true;
      #         };
      #         extraSpecialArgs = { inherit inputs; };
      #         modules = [ ./home/racc/standalone.nix ];
      #       };
      #     };
    };
}
