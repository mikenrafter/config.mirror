## cd ~/nix && nix build .#home.v0id.activationPackage && ./result/activate #
{
#{ inputs
	# split nix inputs for groups with large packages
	inputs.unstable1.url = "github:NixOS/nixpkgs/nixos-unstable";
	inputs.unstable2.url = "github:NixOS/nixpkgs/nixos-unstable";
	inputs.stable1.url = "github:NixOS/nixpkgs/nixos-21.05";
	inputs.stable2.url = "github:NixOS/nixpkgs/nixos-21.05";

	inputs.nur.url = "github:nix-community/NUR/master";

	inputs.homeManager.url = "github:nix-community/home-manager";
	inputs.homeManager.inputs.nixpkgs.follows = "unstable1";
#}
#{ outputs
	outputs = {self, homeManager,
		stable1, stable2,
		unstable1, unstable2,
		nur }: {
		home = {
			#https://github.com/nix-community/home-manager/blob/4320399a3e5f3afb8a867324901a559f23be8178/flake.nix#L35
			v0id = homeManager.lib.homeManagerConfiguration {
			# later on: flake-utils
			extraSpecialArgs = {
				stable1  =stable1  .legacyPackages.x86_64-linux;
				stable2  =stable2  .legacyPackages.x86_64-linux;
				unstable1=unstable1.legacyPackages.x86_64-linux;
				unstable2=unstable2.legacyPackages.x86_64-linux;
			};
			configuration = { pkgs, lib, ... }: {
				imports = [ ./.nix ];
				nixpkgs = {
					#overlays = [ emacs.overlay ];
					config = { allowUnfree = true; };
				};
			};
			system = "x86_64-linux";
			homeDirectory = "/home/v0id";
			username = "v0id";
			};
		};
	};
#}
}
