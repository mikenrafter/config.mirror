##bash ~/.nix/build.sh #
{
# `nix flake lock` to lock dependency versions
# `nix flake update` to update dependency versions
inputs = {
	# split nix inputs for groups with large packages
	unstable1.url = "github:NixOS/nixpkgs/nixos-unstable";
	unstable2.url = "github:NixOS/nixpkgs/nixos-unstable";
	stable1.url = "github:NixOS/nixpkgs/nixos-21.05";
	stable2.url = "github:NixOS/nixpkgs/nixos-21.05";

	nur.url = "github:nix-community/NUR";
	nixGL = {
		flake = false;
		url = "github:guibou/nixGL?rev=bdb42cffe567466dc041ba351d33cb8aa46f234a";
	};

	flake-utils.url = "github:numtide/flake-utils";
	homeManager = {
		url = "github:nix-community/home-manager";
		inputs.nixpkgs.follows = "unstable1";
	};

};
#{ outputs
	outputs = inputs: with inputs; let
		system = "x86_64-linux";
		# channels that use flakes, or otherwise don't offer .legacyPackages
		otherChannels = {
			inherit nixGL;
			unfree=unstable1;
		};
		channels = stable1.lib.mapAttrs (_:
			set: builtins.getAttr system set.legacyPackages
		) inputs // otherChannels;
	in {
		#https://github.com/nix-community/home-manager/blob/4320399a3e5f3afb8a867324901a559f23be8178/flake.nix#L35
		home = homeManager.lib.homeManagerConfiguration {
			homeDirectory = "/home/v0id";
			username = "v0id";
			extraSpecialArgs = channels;
			configuration = { pkgs, lib, ... }: {
				imports = [ ./.nix ];
				nixpkgs = {
					#source = unstable1;
					#overlays = [ emacs.overlay ];
					# only applies to `pkgs`, therefore, only use within unfree
					# group, to prevent accidents (pkgs follows unstable1)
					config = { allowUnfree = true; };
				};
			};
			system = "x86_64-linux";
		};
	};
#}
}
