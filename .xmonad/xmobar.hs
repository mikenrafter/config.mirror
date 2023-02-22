import Xmobar
import Data.List

  --{- colors
fore =
  (["#59c" -- blue   old: "#8bf"
  , "#c95" -- orange    : "#fb8"
  , "#c55" -- red       : "#f88"
  , "#5c9" -- green     : "#8fb"
  , "#95c" -- purple    : "#b8f"
  ]!!) . subtract 1
back =
  (["#222"
  , "#334"
  , "#556"
  ]!!) . subtract 1
--}

config :: Config
config = defaultConfig
 {
 --{- dock info
   position = Static { xpos = 0, ypos = 0, width = 1920, height = 24 } -- Top { height = 50 }
 , overrideRedirect = True
 , lowerOnStart = True, persistent = True
 , hideOnStart = False, allDesktops = True
 --}
 --{- fonts
 , font = "Mononoki Nerd Font 12"
 , additionalFonts = ["FontAwesome 13"]
 --}
 --{- main colors
 , bgColor = "#222", fgColor = "#5c9" --"#8fb"
 --}
 --{- commands
 , commands = [
  --{- date
    Run $ Date "%d %a"    "date" 36000  -- 1h
  , Run $ Date "%l:%M %p" "time" 600  -- 1m
  --}
  --{- trayer width
  , Run $ Com "tray-width" [] "tray" 10  -- 1s
  --}
  --{- keyboard status'
  , Run $ Locks
  , Run $ Kbd [("us(colemak)", "<box type=Bottom width=4 color=orange>colemak</box>"), ("us", "qwerty")]
  --}
  --{- network speed
  , Run $ DynNetwork ["-t", "<rx>kb <tx>kb"] 20  -- 2s
  --}
  --{- CPU, temp
  , Run $ Cpu [ "-t", "<total>%"] 20  -- 2s
--  , Run $ TopProc ["-t", "<name1>"] 20  -- 2s
  , Run $ MultiCoreTemp ["-t", "<avg>C"] 50 -- 5s
  --}
  --{- mem, swap %
  , Run $ Memory ["-t", "<usedratio>%"] 20  -- 2s
  , Run $ Swap   ["-t", "<usedratio>%"] 20  -- 2s
  --}
  --{- disk free
  , Run $ DiskU [("/home", "<free>")] [] 18000  -- 30m
  --}
  --{- GPU
  , Run $ Com "check-nvidia" [] "gpu" 20 -- 2s
  --}
  --{- uptime
  , Run $ Com "tray-uptime" [] "uptime" 600  -- 1m
  --}
  --{- check for updates
  , Run $ Com "updates" [] "updates" 18000  -- 30m
  --}
  --{- brightness
  , Run $ Brightness [ "-t", "<percent>%" -- <bar>
   , "-b", " "
   , "-f", ":"
   , "-m", "2"
   , "-W", "4"

   , "--"
   , "-D", "intel_backlight"
  ] 10 -- 1s
  --}
  --{- volume
  , Run $ Com "get-vol" [] "vol" 5
  , Run $ Alsa "default" "Master"
   [ "-t", "<status><volume>"
   , "-m", "3"

   , "--"
   , "--offc", "#59c,#222", "--off", " "
   , "--onc",  "#59c,#222", "--on",  "|"
-- , "--offc", "#000,#c55", "--off", "\xf026 "
-- , "--onc",  "#000,#c55", "--on",  "\xf027 "
   ] -- 10  -- 1s
   --}
  --{- battery
  , Run $ Battery
   [ "-t", f (3,1) ["<acstatus>  "]<>"<left>" -- <leftbar>
   , "-b", " "
   , "-f", ":"
   , "-m", "2"
   , "-W", "4"

   , "--"

   , "--off",  "\xf242"
   , "--idle", "\xf240"
   , "--on",   "\xf1e6"
-- , "--off", "-<left>" -- "\xf242"
-- , "--idle", " <left>" -- "\xf240"
-- , "--on", "+<left>" -- "\xf1e6"
   ,"-A", "15"
   , "-a", "notify-send -i battery-low 'Low battery!'"
   ] 40  -- 4s
   --}
  --{- xmonad pipe
  , Run $ UnsafeStdinReader
  --}
  ] --}
  --{- template
  , template = template'
  --}
 }

template' = concat
  [ tray
  , pipe
  , "}{"
  , f (2,1) [gpu]
  , " "
  , f (2,2) $ sp [kbdi,kbd,wrap locks]
  , " - "
  , b (1,1)
    [ box 1
      [ f (1,1)
        [ act netm [f (2,1) [neti]," ", net]
        , act cpum $ sp
          [ f (2,1) [cpui],cpu,temp
          , f (2,1) [memi],mem,swap
          ]
        ]
      ]
    ]
  , f (2,1)
    [ box 2
      [ uptime
      , act pkgm $ sp
        [ f (3,1) [updi],update
        , "?"]
      ]
    ]
  , f (3,1)
    [ box 3
      [ f (1,1) [ brii ]
      , bright
      , act volm
        [ " | " -- volbar
        , f (1,1) [volume]
        ]
      , f (1,1) [battery]
      ]
--      <fc=%fg1%>%battery%</fc> - <fc=%fg4%,%bg2%> %itime% %date% %time% </fc>
    ]
  , " "
  ]
--{- helpers
f (fc,bc) xs = concat ["<fc=",fore fc,",",back bc,">",concat xs,"</fc>"]
b (fc,bc) xs = concat ["<fc=",back fc,",",fore bc,">",concat xs,"</fc>"]
p x = [intercalate " " x]
sp x = [s $ intercalate " " x]
wrap x = '[':x<>"]"
w x = '%':x<>"%"
s x = ' ':x<>" "
box n xs = "<box width=4 type=Bottom color="<>fore n<>">"<>concat xs<>"</box>"
act :: String -> [String] -> String
act x xs = "<action="<>x<>">"<>concat xs<>"</action>"
--}
--{- stuff
tray    = w "tray"
pipe    = w "UnsafeStdinReader"
gpu     = w "gpu"
kbd     = w "kbd"
locks   = w "locks"
net     = w "dynnetwork"
cpu     = w "cpu"
temp    = w "multicoretemp"
mem     = w "memory"
swap    = w "swap"
uptime  = w "uptime"
update  = "" -- TODO
bright  = w "bright"
volume  = w "default:Master" -- TODO
battery = w "battery"
--}
--{- applications
files = "thunar"
volm  = "pavucontrol"
cpum  = "alacritty -e btm"
pkgm  = "alacritty"
netm  = "alacritty -e nmtui"
--}
--{- icons
kbdi  = "\xf11c " -- "K"
neti  = "\xf1eb " -- "N"
cpui  = "\xf2db " -- "C"
memi  = "\xf0ae " -- "M"
diski = "\xf07c"  -- "D"
updi  = "\xf1b2"  -- "U"
brii  = "\xf0eb " -- "B"
timei = "\xf017"  -- "T"
--}

main = xmobar config
