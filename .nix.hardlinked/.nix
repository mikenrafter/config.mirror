##home-manager switch #
# ^ pseudo shebang, see .vimrc

# my NIX config

# imports {
{ config, lib, pkgs,
	stable1, stable2,
	unstable1, unstable2,
	...
}:
#}
let
# config {
nixos = false;
#}
# aliases {
s1 =   stable1; s2 =   stable2;
u1 = unstable1; u2 = unstable2;
user = "v0id";
#inherit (n) haskellPackages;
#nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {pkgs = n;};
#}
# package groups {
# libre-kernel {
kernel = with s1.linuxPackages-libre; [

  wireguard                 # VPN method


# -}
# unfree {
]; unfree = with pkgs; [

# lutris                    # games, but uses steam, so proprietary...
# discord                   # friends - nope, too creepy, I'll use it over my
# browser now, if at all
  steam                     # games, proprietary, yep
  multimc                   # better minecrft launcher, except minecraft is unfree...
# intelliJ stuff here later, maybe...


#}
# core {
]; core = with s1; [

  coreutils                 # don't piss GNU+Stallman off!
  fish dash                 # main shell & sh
  u1.vim                       # editor le supreme
  xterm                     # basic terminal, as a backup only
  bitwarden                 # Password manager, it's that simple :)

  earlyoom                  # oomKiller sucks! But this doesn't.

  nitrogen                  # wallpaper manager
#?  picom                     # compositor

#Bcmake                     # for source builds
#Bbinutils                  # for source builds
#Bgcc                       # compiler
  xss-lock                  # lockscreen as screensaver
  nix-bundle                # https://github.com/matthewbauer/nix-bundle


#}
# etc {
]; etc = with s1; [

#+ghacks-user.js
#+yacy.drv
#+auto-cpufreq.drv
#+onlyoffice.drv
#+feral/gamemode.drv
#Bgolly                     # Game of Life
  (lib.mkIf nixos firefox)  #-84-0-1 <- pin | FF meh, librewolf tho
  brave                     # backup browser -- somehow works w/ nvidia acceleration despite lack of nixGL
  thunderbird               # Mozillas mail client
  libreoffice               # office suite
#Bgodot                     # game engine
  legendary-gl              # "epic" game yoinking
  pidgin                    # chat client
  element-desktop           # matrix client


#}
# code {
]; code = with s1; [

# lang cores
# ghc                       # haskell compiler | INCLUDED IN packages.haskell
  rustc                     # rust compiler
  nim                       # nim compiler
  jdk                       # java runtime
(lib.mkIf nixos python27)   # python interpreter 2.7
(lib.mkIf nixos python38)   # python interpreter 3.8

# package managers
  cargo                     # rust package manager
  poetry                    # python package-manager
  cabal-install             # haskell package-manager
  stack                     # haskell package-manager


#}
# editors {
]; editors = with s2; [

  arduino                   # arduino programming
  (neovim.override {        # vim+++
	configure = {
		packages.myPlugins = with s1.vimPlugins; {
			start = [ nvim-compe ];
			opt = [
				nvim-web-devicons
				nvim-tree-lua

				nvim-lspconfig

				nvim-treesitter
				nvim-colorizer-lua
			];
		};
	};
  }
  )
  amp kakoune               # similar to vim
  micro                     # similar to nano
  notepadqq                 # GUI text editor


#}
# fonts {
]; fonts = with s1; [

  mononoki                  # my favorite
  meslo-lgs-nf
  noto-fonts
  noto-fonts-cjk
  noto-fonts-emoji
  liberation_ttf
  fira-code
  fira-code-symbols
  mplus-outline-fonts
  dina-font
  (lib.hiPrio proggyfonts)
  uw-ttyp0
  terminus_font
  terminus_font_ttf
  tamzen
  powerline-fonts


#}
# extras {
]; extras = with s1; [

  sl                        # to fix ls typos, of course
  bsod                      # wine but better XD
#Belectricsheep             # A p2p artwork creating screensaver
  breeze-icons              # icon theme
  libsForQt5.qtstyleplugins # let QT themes apply properly
  qt5ct                     # theming for stuff inside xorg
  lxappearance              # theming
  touchegg                  # touch gestures


#}
# vm {
]; vm = with s1; [

# dolphinEmu                # wii/gamecube emulator
  rpcs3                     # ps3 emulator
#Banbox                     # Android APK runner
  virt-manager              # VM manager
  virtualbox                # VM host
  qemu-utils                # qemu tools
  (lib.hiPrio qemu)         # VM method
# qemu_kvm                  # VM qumu bridge
  kvm                       # VM method
#Blibguestfs                # for accessing guest fs's
  # IDK, kvm stuff...
  bridge-utils
  virt-viewer
  dnsmasq
  vde2
  netcat


#}
# xorg {
]; xorg = with s1.xorg; [

  libXrandr                 # res change lib
  xrandr                    # change your resolution


#}
# hacking {
]; hacking = with s1; [

  keybase kbfs keybase-gui  # less secure, but screw it
  torbrowser                # heck yeah
  cutter                    # cut TCP/IP connections
  wireshark                 # monitor network packages


#}
];

# xmonad {

# git {
# xmonad {
#monadg = pkgs: with pkgs;
#(callPackage
# ({ mkDerivation, base, containers, data-default, directory
#  , extensible-exceptions, filepath, mtl, process, QuickCheck
#  , setlocale, unix, utf8-string, X11
#  }:
# mkDerivation {
#  pname = "xmonad-git";
#  version = "0.17";
#  sha256 = "16wxp2k918c3c0lnalg5x8ag0v4wcij9bajpf0bq81lr51q6qx3q";
#  src = fetchGit {
#    url = "https://github.com/xmonad/xmonad";
#    ref = "master";
#    rev = "4a0b166998a838d91f002991da82507a2d04d3bb";
#  };
#  isLibrary = true;
#  isExecutable = true;
#  libraryHaskellDepends = [
#    base containers data-default directory extensible-exceptions
#    filepath mtl process setlocale unix utf8-string X11
#  ];
#  executableHaskellDepends = [ base mtl unix X11 ];
#  testHaskellDepends = [
#    base containers extensible-exceptions QuickCheck X11
#  ];
#  postInstall = ''
#   install -D man/xmonad.1 ''${!outputDoc}/share/man/man1/xmonad.1
#   install -D man/xmonad.hs ''${!outputDoc}/share/doc/$name/sample-xmonad.hs
#  '';
#  description = "A tiling window manager";
#  license = lib.licenses.bsd3;
#  maintainers = with lib.maintainers; [ peti ];
# })
#}); {
#}
# xmonad-contrib {
#monad-contribg = pkgs: with pkgs;
# let xmonada = (xmonadg pkgs); in
#(callPackage
# ({ mkDerivation, alsa-mixer, base, bytestring, containers, hint
#  , libmpd, mtl, network, regex-posix, X11, xmonad-git
#  }:
# mkDerivation {
#  pname = "xmonad-contrib";
#  version = "0.17";
#  sha256 = "0vzi9cfgbdk0hsapb3skh2la2aic1lmbs0rfr6xli6l5wsbr8xl9";
#  src = fetchGit {
#   url = "https://github.com/xmonad/xmonad-contrib";
#   ref = "master";
#   rev = "902c2bb17d1a1ee4a56944dbf952d6f95d5700c6";
#  };
#  configureFlags = [
#    "-f-with_hlist" "-fwith_parsec" "-fwith_split"
#  ];
#  libraryHaskellDepends = [
#    alsa-mixer base bytestring containers hint libmpd mtl network
#    regex-posix X11 xmonad xmonad-contrib
#    QuickCheck hspec
#  ];
#  description = "Third party extensions for xmonad with wacky dependencies";
#  license = lib.licenses.bsd3;
# })
#}); {
#}
# xmonad-extras {
#monad-extrasg = pkgs: with pkgs;
#let xmonada = xmonadg pkgs; xmonad-contriba = xmonad-contribg pkgs; in
#(callPackage
# ({ mkDerivation, alsa-mixer, base, bytestring, containers, hint
#  , libmpd, mtl, network, regex-posix, X11, xmonada, xmonad-contriba
#  }:
# mkDerivation {
#  pname = "xmonad-extras";
#  version = "0.17";
#  src = fetchGit {
#    url = "https://github.com/xmonad/xmonad-extras";
#    ref = "master";
#    rev = "d45b4cbfadbd8a6c2f0c062e5027a1c800b0e959";
#  };
#  sha256 = "1r4wgs1r7grh14kjsplcjy14wm799pq7zgsl7v2z7sjii63hicab";
#  configureFlags = [
#    "-f-with_hlist" "-fwith_parsec" "-fwith_split"
#  ];
#  libraryHaskellDepends = [
#    alsa-mixer base bytestring containers hint libmpd mtl network
#    regex-posix X11 xmonad xmonad-contrib
#  ];
#  description = "Third party extensions for xmonad with wacky dependencies";
#  license = lib.licenses.bsd3;
# })
#}); {
#}
#}
# non-git {
#xmonadg = pkgs: with pkgs; xmonad;
#xmonad-contribg = pkgs: with pkgs; xmonad-contrib;
#xmonad-extrasg = pkgs: with pkgs; xmonad-extras;
#}


#}

packages = with s1; {

# flakes {
flakes = [(pkgs.writeScriptBin "flakes" ''
	exec ${pkgs.nixUnstable}/bin/nix --experimental-features "nix-command flakes" "$@"
	'')];
#}
# haskell {
# use ghcWithHoogle rather than ghcWithPackages, this way you get nice haddock
# pages, and a localhost hoogle instance!
haskell = haskellPackages.ghcWithHoogle (pkgs: with pkgs; [
## xmonad {
#  (callPackage
#  ({ mkDerivation, base, containers, data-default, directory
#   , extensible-exceptions, filepath, mtl, process, QuickCheck
#   , setlocale, unix, utf8-string, X11
#   }:
#  mkDerivation {
#   pname = "xmonad-git";
#   version = "0.17";
#   sha256 = "16wxp2k918c3c0lnalg5x8ag0v4wcij9bajpf0bq81lr51q6qx3q";
#   src = fetchGit {
#     url = "https://github.com/xmonad/xmonad";
#     ref = "master";
#     rev = "4a0b166998a838d91f002991da82507a2d04d3bb";
#   };
#   isLibrary = true;
#   isExecutable = true;
#   libraryHaskellDepends = [
#     base containers data-default directory extensible-exceptions
#     filepath mtl process setlocale unix utf8-string X11
#   ];
#   executableHaskellDepends = [ base mtl unix X11 ];
#   testHaskellDepends = [
#     base containers extensible-exceptions QuickCheck X11
#   ];
#   postInstall = ''
#    install -D man/xmonad.1 ''${!outputDoc}/share/man/man1/xmonad.1
#    install -D man/xmonad.hs ''${!outputDoc}/share/doc/$name/sample-xmonad.hs
#   '';
#   description = "A tiling window manager";
#   license = lib.licenses.bsd3;
#   maintainers = with lib.maintainers; [ peti ];
#  })
#  {})
##}
## xmonad-contrib {
#  (callPackage
#  ({ mkDerivation, alsa-mixer, base, bytestring, containers, hint
#   , libmpd, mtl, network, regex-posix, X11 #, xmonad-git
#   }:
#  mkDerivation {
#   pname = "xmonad-contrib-git";
#   version = "0.17";
#   sha256 = "0vzi9cfgbdk0hsapb3skh2la2aic1lmbs0rfr6xli6l5wsbr8xl9";
#   src = fetchGit {
#    url = "https://github.com/xmonad/xmonad-contrib";
#    ref = "master";
#    rev = "902c2bb17d1a1ee4a56944dbf952d6f95d5700c6";
#   };
#   configureFlags = [
#     "-f-with_hlist" "-fwith_parsec" "-fwith_split"
#   ];
#   libraryHaskellDepends = [
#     alsa-mixer base bytestring containers hint libmpd mtl network
#     regex-posix X11 xmonad xmonad-contrib
#     QuickCheck hspec
#   ];
#   description = "Third party extensions for xmonad with wacky dependencies";
#   license = lib.licenses.bsd3;
#  })
#  {})
##}
## xmonad-extras {
#  (callPackage
#  ({ mkDerivation, alsa-mixer, base, bytestring, containers, hint
#   , libmpd, mtl, network, regex-posix, X11 #, xmonad-git, xmonad-contrib-git
#   }:
#  mkDerivation {
#   pname = "xmonad-extras-git";
#   version = "0.17";
#   src = fetchGit {
#     url = "https://github.com/xmonad/xmonad-extras";
#     ref = "master";
#     rev = "d45b4cbfadbd8a6c2f0c062e5027a1c800b0e959";
#   };
#   sha256 = "1r4wgs1r7grh14kjsplcjy14wm799pq7zgsl7v2z7sjii63hicab";
#   configureFlags = [
#     "-f-with_hlist" "-fwith_parsec" "-fwith_split"
#   ];
#   libraryHaskellDepends = [
#     alsa-mixer base bytestring containers hint libmpd mtl network
#     regex-posix X11 xmonad xmonad-contrib
#   ];
#   description = "Third party extensions for xmonad with wacky dependencies";
#   license = lib.licenses.bsd3;
#  })
#  {})
##}
  xmonad                    # wm
  xmonad-contrib            # xmonad stuff
  xmonad-extras             # xmonad-contrib++
  xmonad-utils              # xmonad more more stuff stuff
# DescriptiveKeys           # xmonad stuff more in the more of the stuff
  haskell.lib.appendConfigureFlag xmobar ("-f all_extensions")                    # xmobar addition for xmonad

  random-fu                 # functions for use in xmonad
#?text                      # useful functions for working w/ json
]);
#}
# vim {
vim = with s1.vimPlugins; [
  (lib.hiPrio haskell-vim)  # vim.hs
  vim-fish                  # vim.fish
];
#}

};
media = {

# managing {
managing = with s1; [
  alsa-firmware             # firmware for soundcards
  pulseaudio                # I really hate typing that, but alsa just doesn't work
# pavucontrol               # pulseaudio manager
  playerctl                 # manage media easier
# easyeffects               # apply effects to audio in pw
];
#}
# capturing {
capturing = with s1; [
  maim                      # screenshot tool
  scrot                     # super simple screenshot utility
  flameshot                 # screenshot utility
  capture                   # A "no BS" CLI simple screen capture utility
  obs-studio                # OBS itself
# obs-v4l2sink              # OBS virtual camera - merged into OBS
# obs-move-transition       # OBS move items upon transition
# obs-wlrobs                # OBS wayland screen captures
];
#}
# creation {
creation = with s1; [
#Bblender                   # 3d editor ftw
  avidemux                  # a very basic video editor
  olive-editor              # a more complex video editor
  kdenlive                  # a more complex video editor
#tardour                    # music.mp3
  audacity                  # modify.mp3
  gimp                      # modify.img
  krita                     # paint.img
  akira-unstable            # SVGs.img
];
#}
# viewing {
viewing = with s1; [
#+lbry.drv
  celluloid                 # multimedia player - based on MPV, simple
  vlc                       # multimedia player
  minitube youtube-dl       # view youtube videos
#Bnewsflash                 # RSS reader
  gpodder                   # podcast client
];
#}


};
utils = {

# terminals {
terminals = with s1; [
  st                        # my terminals
#Balacritty                 # my terminals
#Btermite                   # my terminals
];
#}
# debuggers {
debuggers = with s1; [
  cgdb gdb pwndbg edb       # general debuggers suite :)
  bench                     # CLI benchmarking tool
  pydb                      # python debugger
  bashdb                    # bash debugger
  delve                     # golang debugger
];
#}
# security {
security = with s1; [
  # open VPN solutions
  openvpn gnome3.networkmanager-openvpn
  # proton vpn solution
  protonvpn-cli protonvpn-gui
  # wireguard vpn stuff
  boringtun wg-bond wireguard-tools
  firejail                  # sandbox applications, particularly useful with web browsers
  usbguard                  # anti badusb
  tor torsocks              # online protection
  macchanger
# sshguard                  # anti ssh attacks
# ?ferm
# ?firehol
# ?shorewall
];
#}
# shells {
shells = with s1; [
  any-nix-shell             # connect nix-shell with yours
  zsh                       # Zsh because it's useful I guess...
  bash bashInteractive      # Bash shell for easier scripting
];
#}
# cli {
cli = with s1; [
  bat exa fd                # better coreutils in rust
  lzip gzip bzip2 xz        # zippers
  curl wget                 # downloaders
  more less                 # pagers
#Bdoas                      # BSD.sudo (Linux port)
  git                       # If you don't git git you git nothin' and therefore don't git it
#~ckb-next                  # manage corsair products
#?wally-cli                 # flash your epic keyboard
  archivemount              # mount archives (via FUSE)
  flootty                   # collab TTY
  xclip                     # clipboard util
  rsync                     # powerful file copy/share
  bottom htop               # system monitors
  ffsend                    # file share for use with FF
  fzf                       # fuzzy finder tool
  snapper snapper-gui       # btrfs snapshot management utility
  btrfs-progs               # betterfs tools
  screen                    # multiplex/session manager
  neofetch                  # show off your system
  remake                    # better verson of GNU make
];
#}
# gui {
gui = with s1; [
  dragon-drop               # drag-n-drop utility
  czkawka                   # file duplicate management tool
  transmission-gtk          # torrent tool! also has cli
  sxiv                      # simple x image viewer
  parcellite                # clipboard manager
  xzoom                     # screen magnifier   | These work well
  colorpicker               # hex value of pixel | together.
  brightnessctl             # manage brightness
  remmina                   # remote connection client
  cinnamon.warpinator       # LAN file sharer
  xfce.thunar               # file manager
  xfce.xfce4-notifyd        # notification system
  caffeine-ng               # stop screen-locking
  blueman                   # bluetooth tray
# (lib.hiPrio blueman)      # bluetooth tray
  gnome3.networkmanagerapplet # network tray
  stalonetray               # better system tray
# trayer                    # system tray
  mate.engrampa             # Archive tool GUI
# ark                       # Archive tool GUI
  qalculate-gtk             # nice calculator
  tilem                     # TI# calculator emulator (needs ROM file)
  usermount                 # automatically mount drives as they appear
];
#}


};
#}
# selections {
selections = builtins.concatLists [
  # things that need high package priority to work:
  (map lib.hiPrio [ packages.haskell ])

  # NixOS only:
  (map (lib.mkIf nixos) [ kernel packages.python ])

  # Essentials
  unfree
  core # source compiles won't work without it
  etc
  xorg
  packages.flakes
  fonts

  extras
  code
  editors
  hacking
  vm

  media.managing
  media.creation
  media.capturing
  media.viewing

  packages.vim

  utils.terminals
  utils.debuggers
  utils.security
  utils.shells
  utils.cli
  utils.gui
  # temporary orphans
  [
  #(nur.repos.mic92.hello-nur) # pkgs)
  ]
];
#}
in
{ # main
#	# enable NUR {
#	imports = lib.attrValues nur.repos.moredhel.hmModules.modules;
#	#}
	options.profiles.dev.enable =
		lib.mkOption {
			description = "enable profile";
			type = with lib.types; bool;
			default = true;
		};
	config = {
		# makes themes, and other things work better off of nixOS
		targets.genericLinux.enable = ! nixos;
		# theming {
		xsession.windowManager.command = "$HOME/.nix-profile/bin/xmonad";
		xsession.enable = true;
		xsession.numlock.enable = true;
		# cursor theme
		xsession.pointerCursor.package          = s1.vanilla-dmz;
		xsession.pointerCursor.defaultCursor    = "Vanilla-DMZ";
		xsession.pointerCursor.name             = "Vanilla-DMZ";
		xsession.pointerCursor.size             = 16;
		# gtk
		gtk.enable = true;
		gtk.theme.name = "Equilux"; #"Sweet-mars"; # "Equilux";
		gtk.theme.package = s1.equilux-theme; #.sweet; #.equilux-theme;
		gtk.iconTheme.package = s1.gnome3.gnome_themes_standard;
		gtk.iconTheme.name = "Adwaita";
		# qt
		#qt.enable = true;
		#qt.platformTheme = "gtk";
		#}
		services = {
#			# enable NUR #2 {
#				unison = {
#					enable = true;
#					profiles = {
#						org = {
#							src = "/home/moredhel/org";
#							dest = "/home/moredhel/org.backup";
#							extraArgs = "-batch -watch -ui text -repeat 60 -fat";
#						};
#					};
#				};
#			#}
			#udiskie = {
			#	enable = true;
			#	automount = true;
			#	notify = true;
			#	tray = "always";
			#};
			# caffeine-ng used instead
			#caffeine.enable = false;
			#pasystray.enable = true;
			#blueman.enable = true;
			#blueman-applet.enable = true;
			#screen-locker = {
			#	enable = false;
			#	lockCmd = "${pkgs.slock}/bin/slock";
			#	inactiveInterval = 10;
			#};
		};
#		programs = {
#			home-manager.enable = true;
#		};
		home = {
			# tracked files {
#			file = {
#				xresources = {
#					source = ./.Xresources;
#					target = "./.Xresources";
#				};
#			};
			#}
			# env vars {
			sessionVariables = {
				EDITOR = "nvim";
				BROWSER = "librewolf";
				XDG_DATA_DIRS = lib.concatStringsSep ":" (map (profile: "${profile}/share") [ "/nix/var/nix/profiles/default" config.home.profileDirectory "/usr"]);
				QT_QPA_PLATFORMTHEME = "qt5ct";
			};
			sessionPath = [
			"~/.local/bin"
			"~/scripts"
			"~/appimages"
			];
			#}
			# now inherited from flake.nix
			# username = user;
			# homeDirectory = "/home/" + user;
			# install manpages for packages too
			extraOutputsToInstall = ["doc" "info" "devdoc"];
			# apply selections | selections
			packages = (map lib.hiPrio [ u1.nixUnstable u1.home-manager ]  ) ++ selections;
		};
	};
}


# things to look into {
#with import <nixpkgs> {};
# # generate emulator config
#androidenv.emulateApp {
#  name = "emulate-MyAndroidApp";
#  platformVersion = "28";
#  abiVersion = "x86"; # armeabi-v7a, mips, x86_64
#  systemImageType = "google_apis_playstore";
#}
#
# TODO: topographical sort of dependencies, grouped into individual inputs,
# based on a threshold, for saving disk space, while maintaining nix-niceties
# (likely to be a waste of time)
#}
