##bash ~/.nix/build.sh #
{
# `nix flake lock` to lock dependency versions
# `nix flake update` to update dependency versions
#	limited ver: `nix flake lock --update-input name`
inputs = {
	# split nix inputs for groups with large packages
	unstable1.url = github:NixOS/nixpkgs/nixos-unstable;
	unstable2.url = github:NixOS/nixpkgs/nixos-unstable;
	stable1.url = github:NixOS/nixpkgs/nixos-21.05;
	stable2.url = github:NixOS/nixpkgs/nixos-21.05;

	nur.url = github:nix-community/NUR;
	nixGL = {
		flake = false;
		# unpin when not broken OR suggest stable branch + use
		url = github:guibou/nixGL?rev=bdb42cffe567466dc041ba351d33cb8aa46f234a;
	};

	flake-utils.url = github:numtide/flake-utils;
	homeManager = {
		url = github:nix-community/home-manager;
		inputs.nixpkgs.follows = "unstable1";
	};

	waymonad = {
		url = github:L-as/waymonad;
		flake = false;
		inputs.nixpkgs.follows = "stable1";
	};

	xm = {
		url  = path:./xm-test;
		inputs.nixpkgs.follows = "unstable1";
	};
	xmc = {
		url = path:./xm-test-contrib;
		inputs.nixpkgs.follows = "unstable1";
	};

};
#{ outputs
	outputs = inputs: with inputs; let
		system = "x86_64-linux";
		username = "v0id";
		# is user on nixos?
		nixos = false;
		passthrough = { inherit username nixos system; };

		unfree = utils.enslave { # usage: unfree.name
			inherit unstable1 stable1;
		};
		otherChannels = { # channels w/ flakes only or no legacyPackages
			nixGL = import nixGL {pkgs=unfree.unstable1;};
			waymonad = import waymonad { pkgs=(import stable1 {}); };
		};
		overlays = utils.overlay [
			xm
			xmc
		];

		# legacy: names like u1, s1
		shorthand  = with utils; attrMapFn inputs firstLast;
		# flake: names like _unstable1, _stable1
		flaky      = with utils; attrMapFn inputs (n: "_"+n);
		# flake: names like _u1, _s1
		_fy        = with utils; attrMapFn shorthand (n: "_"+n);

		libs = stable1;

		# mini-utils {
		# keep overlays, for weird scenarios (hopefully not!)
		extraSpecialArgs = with utils; channels // otherChannels // flaky // _fy // passthrough // { inherit unfree overlays;};
		# with utils; - allow self-references
		utils = with builtins; with libs.lib; rec {
			enslave = mapAttrs (_: set: 
				import set {config.allowUnfree=true;}
			);
			channels = mapAttrs (_: set:
				import set {inherit overlays;}
			) ( inputs // shorthand );

			overlay = map (p: p.overlay);

			attrMapFn = set: op: attrsets.mapAttrs'
				(n: v:
					attrsets.nameValuePair
					(op n) v
				) set;
			firstLast = s: let l = stringLength s - 1; in elm s 0 + elm s l;
			elm = s: x: substring x 1 s;
		};
		#}
	in {
		#https://github.com/nix-community/home-manager/blob/4320399a3e5f3afb8a867324901a559f23be8178/flake.nix#L35
		home = homeManager.lib.homeManagerConfiguration {
			inherit username system extraSpecialArgs;
			configuration = { pkgs, lib, ... }: {
				imports = [ ./.nix ];
				nixpkgs = {
					#source = unstable1;
					inherit overlays;
				};
			};
			homeDirectory = "/home/" + username;
		};
	};
#}
}
