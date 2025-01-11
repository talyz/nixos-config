{
  description = "Talyz's NixOS configs";

  inputs = {
    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs.url = "path:./modules/nixpkgs";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    home-manager.url = "path:./modules/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    home-manager-stable.url = "github:nix-community/home-manager/release-24.11";
    home-manager-stable.inputs.nixpkgs.follows = "nixpkgs-stable";
    impermanence.url = "path:./modules/impermanence";
    # impermanence.url = "github:nix-community/impermanence";
    # emacs-overlay.url = "path:./modules/emacs-overlay";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    emacs-overlay.inputs.nixpkgs.follows = "nixpkgs";
    dotfiles.url = "path:./modules/dotfiles";
    dotfiles.flake = false;
    dracula-emacs.url = "path:./modules/dracula-emacs";
    dracula-emacs.flake = false;
    anyrun.url = "github:anyrun-org/anyrun";
    anyrun.inputs.nixpkgs.follows = "nixpkgs";
    ags.url = "github:aylur/ags/v1";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-stable,
    impermanence,
    sops-nix,
    deploy-rs,
    ...
  }@args:
    let
      modules' = postfix: [
        args."home-manager${postfix}".nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
        }
        impermanence.nixosModules.impermanence
        sops-nix.nixosModules.sops
        {
          sops.defaultSopsFile = ./secrets.yaml;
          sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        }
      ];
      modules = modules' "";
      modules-stable = modules' "-stable";
    in
      {
        passthru = args;

        nixosConfigurations.zen = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = modules ++ [
            ./machines/zen/configuration.nix
          ];
          specialArgs = args // {
            isStable = false;
          };
        };

        deploy.nodes.zen = {
          hostname = "zen.local";
          profiles.system = {
            user = "root";
            sshUser = "root";
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.zen;
          };
        };

        nixosConfigurations.sythe = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = modules ++ [
            ./machines/sythe/configuration.nix
          ];
          specialArgs = args // {
            isStable = false;
          };
        };

        deploy.nodes.sythe = {
          hostname = "sythe";
          profiles.system = {
            user = "root";
            sshUser = "root";
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.sythe;
          };
        };

        nixosConfigurations.raine = nixpkgs-stable.lib.nixosSystem {
          system = "x86_64-linux";
          modules = modules-stable ++ [
            ./machines/raine/configuration.nix
          ];
          specialArgs = args // {
            isStable = true;
          };
        };

        deploy.nodes.raine = {
          hostname = "raine";
          profiles.system = {
            user = "root";
            sshUser = "root";
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.raine;
          };
        };

        isoImage = (nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = modules ++ [
            ./machines/cd/configuration.nix
          ];
          specialArgs = args // {
            isStable = false;
          };
        }).config.system.build.isoImage;

        devShells.x86_64-linux.default =
          let
            pkgs = nixpkgs.legacyPackages.x86_64-linux;
          in
            pkgs.mkShell {
              packages = [
                pkgs.sops
              ];
            };

        # checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
      };
}
