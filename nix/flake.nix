##cd ~/.nix && nix build .#home.v0id.activationPackage && ./result/activate #
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
	outputs = {self, homeManager, flake-utils,
		stable1, stable2,
		unstable1, unstable2, nixGL, nur
	}: {
		home = {
			#https://github.com/nix-community/home-manager/blob/4320399a3e5f3afb8a867324901a559f23be8178/flake.nix#L35
			v0id = homeManager.lib.homeManagerConfiguration {
				homeDirectory = "/home/v0id";
				username = "v0id";
				# later on: flake-utils
				extraSpecialArgs = {
					stable1  =stable1  .legacyPackages.x86_64-linux;
					stable2  =stable2  .legacyPackages.x86_64-linux;
					unstable1=unstable1.legacyPackages.x86_64-linux;
					unstable2=unstable2.legacyPackages.x86_64-linux;
					nur      =nur      .legacyPackages.x86_64-linux;
					inherit nixGL;
#				nixGL = (import nixGL { pkgs=stable1; });
#					nixGL    =nixGL    .legacyPackages.x86_64-linux; # missing flake, also's very impure
				};
				configuration = { pkgs, lib, ... }: {
					home.packages = [
					] ++ (with (import nixGL { inherit pkgs; }); [
						nixGLIntel
						auto.nixGLDefault
						auto.nixGLNvidia
					]);
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
	};
#}
}
