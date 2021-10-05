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
		otherChannels = { # channels w/ flakes only or no legacyPackages
		inherit
			nixGL
		;
		};
		overlayPackages = [xm xmc];

		# legacy: names like u1, s1
		shorthand  = attrMap inputs firstLast;
		# flake: names like _u1, _s1
		_fy        = attrMap shorthand (n: "_"+n);
		# flake: names like _unstable1, _stable1
		flaky      = attrMap inputs (n: "_"+n);

		libChannel = stable1;

		# mini-utils {
		extraSpecialArgs = channels // otherChannels // flaky // _fy // passthrough;
		channels = with lc; lib.mapAttrs (_:
			set: builtins.getAttr system set.legacyPackages
		) (overlay ( inputs // shorthand ));

		overlays = builtins.map (p: p.overlay) overlayPackages;
		overlay = with lc; lib.attrsets.mapAttrs (_: v: v // { inherit overlays; });

		attrMap = with lc; set: op: lib.attrsets.mapAttrs'
			(n: v:
				lib.attrsets.nameValuePair
				(op n) v
			) set;
		firstLast = with builtins; s: let l = stringLength s - 1; in elm s 0 + elm s l;
		elm = with builtins; s: x: substring x 1 s;
		lc = libChannel;
		#}
	in {
		#https://github.com/nix-community/home-manager/blob/4320399a3e5f3afb8a867324901a559f23be8178/flake.nix#L35
		home = homeManager.lib.homeManagerConfiguration {
			inherit username system extraSpecialArgs;
			configuration = { pkgs, lib, ... }: {
				imports = [ ./.nix ];
				nixpkgs = {
					#source = unstable1;
					overlays = [ xm.overlay xmc.overlay ];
				};
			};
			homeDirectory = "/home/" + username;
		};
	};
#}
}
