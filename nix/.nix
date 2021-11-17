##bash ~/.nix/build.sh

# my NIX config

inputs: with inputs; let
# aliases {
# flake.nix: u1,u2,etc
ifNix = package: lib.mkIf nixos package;
#}
# custom packages {
custom = map (x: import x {inherit u1; inherit s1;}) [
  ./programs/nvim.nix
  ./programs/quickemu.nix
];
#}
# package groups {
# libre-kernel {
kernel = with u1.linuxPackages-libre; [

# wireguard                 # VPN method - included in latter kernels


# -}
# unfree {
]; unfree = with inputs.unfree.unstable1; [

##games:
# lutris                    # integrates with steam - proprietary...
  steam                     # games, proprietary, yep
  multimc                   # better minecrft launcher, except minecraft is unfree...


#}
# core {
]; core = with u1; [

  coreutils                 # don't piss GNU+Stallman off!
  libtool                   # more gnu tools
  lsof strace               # identify open files
  usbutils                  # lsusb+
  fish dash bash            # main shell & sh + bash, for compatability
  u1.vim                    # editor le supreme
  xterm                     # basic terminal, as a backup only
  bitwarden                 # Password manager, it's that simple :)
  gnome.gnome-keyring       # Keyring, manages DBs other than pw-managers

  auto-cpufreq              # dynamic CPU frequency scaler
  earlyoom                  # oomKiller sucks! But this doesn't.

  nitrogen                  # wallpaper manager
#?picom                     # compositor

#Bcmake                     # for source builds
#Bbinutils                  # for source builds
#Bgcc                       # compiler
  xsecurelock               # secure lockscreen
  xss-lock                  # lockscreen as screensaver
  nix-bundle                # https://github.com/matthewbauer/nix-bundle
  manix nixdoc nix-doc      # nix documentation
#HDD freefall                 # anti HDD death


#}
# etc {
]; etc = with u1; [

#+ghacks-user.js
#+yacy.drv
#+auto-cpufreq.drv
#+onlyoffice.drv
#+feral/gamemode.drv
#Bgolly                     # Game of Life
  nur.repos.onny.librewolf-bin  # TODO
 #(ifNix librewolf)         # TODO
  firefox                   # FF meh, librewolf tho
  brave                     # backup browser -- somehow works w/ nvidia acceleration despite lack of nixGL
  browsh                    # TUI browser
  thunderbird               # Mozillas mail client
  libreoffice               # office suite
#Bgodot                     # game engine
  legendary-gl              # "epic" game yoinking
  pidgin                    # chat client
  tut                       # TUI mastodon client
  element-desktop           # matrix client


#}
# code {
]; code = with u1; [

# lang cores
# ghc                       # haskell compiler | INCLUDED IN packages.haskell
  rustc                     # rust compiler
  nim                       # nim compiler
  jdk                       # java runtime
  (ifNix python27)          # python interpreter 2.7
  (ifNix python38)          # python interpreter 3.8

# package managers
  cargo                     # rust package manager
  poetry                    # python package-manager
  cabal-install             # haskell package-manager
  stack                     # haskell package-manager
  yarn                      # JS dep-manager | coc.vim needs it


#}
# editors {
]; editors = with s2; [

  arduino                   # arduino programming
  nvimpager                 # why not?
##nvim                      # my custom nvim
  amp kakoune               # similar to vim
  micro                     # similar to nano
  notepadqq                 # GUI text editor


#}
# fonts {
]; fonts = with u1; [

  (nerdfonts.override {
	fonts = [
		"Mononoki"
		"Meslo"
		"FiraCode"
		"Terminus"
  ];
  })

  noto-fonts
  noto-fonts-cjk
  noto-fonts-emoji
  liberation_ttf
  mplus-outline-fonts
  dina-font
  (lib.hiPrio proggyfonts)
  uw-ttyp0
  tamzen
  powerline-fonts


#}
# extras {
]; extras = with u1; [

  sl                        # to fix ls typos, of course
  bsod pipes                # wine but better XD
  vitetris                  # epic terminal-based tetris game
#Belectricsheep             # A p2p artwork creating screensaver
  breeze-icons              # icon theme
  libsForQt5.qtstyleplugins # let QT themes apply properly
  qt5ct                     # theming for stuff inside xorg
  xsettingsd                # application settings, alternative to gsettingsd
  lxappearance              # theming
  touchegg                  # touch gestures


#}
# vm {
]; vm = with u1; [

  dolphinEmu                # wii/gamecube emulator
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
  edk2
  OVMF
# OVMFFull
  libvirt
  virtlyst
# swtpm
# swtpm-tpm2


#}
# xorg {
]; xorg = with u1.xorg; [

  u1.autorandr              # display manager
  u1.xdotool                # virtual keypress util
  libXrandr                 # res change lib
  xrandr                    # change your resolution
  u1.wmctrl                 # window manager functions
  xprop                     # x properties
  xwininfo                  # like xprop
  xev                       # input tester
  u1.greetd.greetd          # greeter!
  u1.greetd.tuigreet        # greeter!
  u1.greetd.dlm             # greeter!
  u1.greetd.gtkgreet        # greeter!


#}
# hacking {
]; hacking = with u1; [

  keybase kbfs keybase-gui  # less secure, but screw it
  torbrowser                # heck yeah
  cutter                    # cut TCP/IP connections
  wireshark                 # monitor network packages


#}
# flossGames {
]; flossGames = with s2; [

  superTuxKart              # super-tux-kart!
  _2048-in-terminal
  _0verkill
  cuyo


#}
];
# experimental things {
experimental = with u1; [
  dpkg                      # debian
  apt                       # ubuntu
  pacman                    # arch
  libdnf                    # redhat (rpm)
  ];
#}

# gpu wrappers {
	gpu = with nixGL; [
	nixGLIntel
	auto.nixGLDefault
	auto.nixGLNvidia
];
#}


 packages = with u1; {

# haskell {
# use ghcWithHoogle rather than ghcWithPackages, this way you get nice haddock
# pages, and a localhost hoogle instance!
haskell = haskellPackages.ghcWithHoogle (p: with p; [
# s1.wayland s1.wayland-scanner
# inputs.waymonad           # experimental WM
  xmonad                    # wm
  xmonad-contrib            # xmonad stuff
# xmonad-extras             # xmonad-contrib++ # needs transition to flakes
  xmonad-utils              # xmonad more more stuff stuff
# DescriptiveKeys           # xmonad stuff more in the more of the stuff
  haskell.lib.appendConfigureFlag xmobar ("-f all_extensions")                    # xmobar addition for xmonad

  random-fu                 # functions for use in xmonad
#?text                      # useful functions for working w/ json
]);
#}
# vim {
vim = with u1.vimPlugins; [
  (lib.hiPrio haskell-vim)  # vim.hs
  vim-fish                  # vim.fish
];
#}

};
media = {

# managing {
managing = with u1; [
  alsa-firmware             # firmware for soundcards
  pulseaudio                # I really hate typing that, but alsa just doesn't work
  pavucontrol               # pulseaudio manager
  playerctl                 # manage media easier
  easyeffects            # apply effects to audio in pw
];
#}
# capturing {
capturing = with u1; [
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
creation = with u1; [
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
viewing = with u1; [
#+lbry.drv
  celluloid mpv vlc         # multimedia players
  minitube yt-dlp           # view youtube videos
#Bnewsflash                 # RSS reader
  gpodder                   # podcast client
];
#}


};
utils = {

# terminals {
terminals = with u1; [
  st                        # my terminals
#Balacritty                 # my terminals
#Btermite                   # my terminals
];
#}
# debuggers {
debuggers = with u1; [
  cgdb gdb pwndbg edb       # general debuggers suite :)
  bench                     # CLI benchmarking tool
  pydb                      # python debugger
  bashdb                    # bash debugger
  delve                     # golang debugger
];
#}
# security {
security = with u1; [
  # open VPN solutions
  openvpn gnome3.networkmanager-openvpn
  # proton vpn solution
  protonvpn-cli #protonvpn-gui
  # wireguard vpn stuff
  boringtun wg-bond wireguard-tools
  firejail                  # sandbox applications, particularly useful with web browsers
  usbguard                  # anti badusb
  tor torsocks              # online protection
  macchanger                # randomize your mac address
  vulnix                    # vuln scanner
  sshguard                  # anti ssh attacks
  ferm                      # complex firewall management
  firehol                   # "a firewall for humans"
  opensnitch
  opensnitch-ui             # another firewall??
];
#}
# shells {
shells = with u1; [
  any-nix-shell             # connect nix-shell with yours
  zsh                       # Zsh because it's useful I guess...
  bash bashInteractive      # Bash shell for easier scripting
];
#}
# cli {
cli = with u1; [
  cointop                   # crypto tracker
  bottom htop               # system monitors
  ftop                      # file-top

  hostname                  # the ability to modify your hostname | un-nix?
  bat exa fd                # better coreutils in rust
  lzip gzip bzip2 xz        # zippers
  curl wget                 # downloaders
  more less                 # pagers
#Bdoas                      # BSD.sudo (Linux port)
  git                       # If you don't git git you git nothin' and therefore don't git it
#~ckb-next                  # manage corsair products
  wally-cli                 # flash your epic keyboard
  qmk                       # qmk firmware management
  archivemount              # mount archives (via FUSE)
  flootty                   # collab TTY
  xclip                     # clipboard util
  rsync                     # powerful file copy/share
  ffsend                    # file share for use with FF
  fzf                       # fuzzy finder tool
  snapper snapper-gui       # btrfs snapshot management utility
  btrfs-progs               # betterfs tools
  screen                    # multiplex/session manager
  neofetch pfetch           # show off your system
  remake                    # better verson of GNU make
];
#}
# gui {
gui = with u1; [
  dragon-drop               # drag-n-drop utility
  czkawka                   # file duplicate management tool
  transmission-gtk          # torrent tool! also has cli
  sxiv                      # simple x image viewer
  clipit                    # clipboard manager
# parcellite                # clipboard manager
  xzoom                     # screen magnifier   : These work well
  colorpicker               # hex value of pixel : together.
  brightnessctl             # manage brightness
  remmina                   # remote connection client
  cinnamon.warpinator       # LAN file sharer
  xfce.thunar gvfs          # file manager + trash support
  conky                     # snazzy
  deadd-notification-center # notification system
  caffeine-ng               # stop screen-locking
  blueman                   # bluetooth tray
# (lib.hiPrio blueman)      # bluetooth tray
  gnome3.networkmanagerapplet # network tray
  stalonetray               # better system tray
# trayer                    # system tray
  mate.engrampa             # Archive tool GUI
# ark                       # Archive tool GUI
  qalculate-gtk             # nice calculator
  kmplot                    # plotting software (graphing calc)
  tilem                     # TI# calculator emulator (needs ROM file)
  usermount                 # automatically mount drives as they appear
  gnome.dconf-editor        # dconf editor, duh
  drawing                   # basic drawing tool - like G-drawings
  drawio                    # flowcharts!!!!
];
#}


};
#}
# selections {
selections = builtins.concatLists [
  # things that need high package priority to work:
  (map lib.hiPrio [
#  packages.haskell
  ])

  # NixOS only:
  (map ifNix [
  kernel
  packages.python
# experimental  # other distro's package managers
  ])

  custom

  [packages.haskell]

  # Essentials
  unfree
  core # source compiles won't work without it
  etc
  xorg
  fonts

  # Likely desired
  extras
  code
  editors
  hacking
  vm
  gpu

  flossGames


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
		xsession.windowManager.command = "$HOME/scripts/wm";
		xsession.enable = true;
		xsession.numlock.enable = true;
		# cursor theme
		xsession.pointerCursor.package          = u1.vanilla-dmz;
		xsession.pointerCursor.defaultCursor    = "Vanilla-DMZ";
		xsession.pointerCursor.name             = "Vanilla-DMZ";
		xsession.pointerCursor.size             = 16;
		# gtk
		gtk.enable = true;
		gtk.theme.name = "Equilux"; #"Sweet-mars"; # "Equilux";
		gtk.theme.package = u1.equilux-theme; #.sweet; #.equilux-theme;
		gtk.iconTheme.package = u1.gnome3.gnome_themes_standard;
		gtk.iconTheme.name = "Adwaita";
		# qt
		#qt.enable = true;
		#qt.platformTheme = "gtk";
		#}
		# dconf {
		
		# }
		fonts.fontconfig.enable = true;
		systemd.user.services = {
			opensnitch = {
				Unit = {
					Description = "Opensnitch Application Firewall Daemon";
					After = ["network.target"]; 
					PartOf = ["multi-user.target"];
				};
				Service = {
					Type = "simple";
					PermissionsStartOnly = true;
					ExecStartPre = "${u1.coreutils}/bin/mkdir -p /etc/opensnitch/rules"; 
					ExecStart = "${u1.opensnitch}/bin/opensnitchd -rules-path /etc/opensnitch/rules"; 
					Restart = "always";
					RestartSec = 30;
				};
			};
		};
		services = {
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
			#	enable = true;
			#	lockCmd = "${u1.xsecurelock}/bin/xsecurelock";
			#	inactiveInterval = 1;
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
				EDITOR = "nvim"; # custom script pointing to nvim
				BROWSER = "librewolf";
				PAGER = "nvimpager";
				XDG_DATA_DIRS = lib.concatStringsSep ":" (map (profile: "${profile}/share") [ "/nix/var/nix/profiles/default" config.home.profileDirectory "/usr"]);
				QT_QPA_PLATFORMTHEME = "qt5ct";
			};
			sessionPath = [
			"~/.local/bin"
			"~/scripts"
			"~/appimages"
			];
			#}
			# install manpages for packages too
			extraOutputsToInstall = ["doc" "info" "devdoc"];
			# apply selections | selections
			packages = (map lib.hiPrio [ u1.nixUnstable u1.home-manager ]  ) ++ selections;
		};
	};
}


# things to look into {
# # generate emulator config
#androidenv.emulateApp {
#  name = "emulate-MyAndroidApp";
#  platformVersion = "28";
#  abiVersion = "x86"; # armeabi-v7a, mips, x86_64
#  systemImageType = "google_apis_playstore";
#}
#`environment.etc.nixpkgs.source = inputs.nixpkgs;` to link the flake's nixpkgs to `/etc/nixpkgs`, and add `nixpkgs=/etc/nixpkgs` to `nix.nixPath`
#
#if you want something approximating environment.etc.<name>.source under Home Manager, you could use xdg.dataFile.<name>.source
#then you could use ~/.local/share/nixpkgs
#services.printing.drivers = with pkgs; [ gutenprint gutenprintBin epson-201106w epson-alc1100 epson-escpr epson-escpr2 epson-workforce-635-nx625-series epson_201207w ]
#}
