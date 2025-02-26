{
  description = "Lorenzo's nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = { pkgs, ... }: {
      nixpkgs.config.allowUnfree = true;
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [
            pkgs.atuin
            pkgs.direnv
            pkgs.google-chrome
            pkgs.neovim
            pkgs.nil
            pkgs.raycast
            pkgs.starship
            pkgs.stow
            pkgs.zellij
            pkgs.zoxide
        ];
      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      programs.fish.enable = true;
      users.users.lorenzo = {
          shell = pkgs.fish;
      };

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      # Git configuration using activation script
      system.activationScripts.postActivation.text = ''
        echo "Configuring git..."
        ${pkgs.git}/bin/git config --global user.signingKey "/home/lorenzo/.ssh/id_rsa.pub"
        ${pkgs.git}/bin/git config --global user.email "maturanolorenzo@gmail.com"
        ${pkgs.git}/bin/git config --global user.name "Lorenzo"
        ${pkgs.git}/bin/git config --global gpg.format "ssh"
        ${pkgs.git}/bin/git config --global gpg.ssh.allowedSignersFile "/home/lorenzo/.ssh/allowed-signers"
        ${pkgs.git}/bin/git config --global commit.gpgSign true
      '';
  };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Lorenzos-MacBook-Pro
    darwinConfigurations."Lorenzos-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };
  };
}
