module Custom.Vars where
--{- imports
--{- standards
import XMonad
import qualified XMonad.StackSet as W
import System.IO.Unsafe (unsafePerformIO)
import System.Environment (getEnv)
--}
--{- data
import Data.List
import Data.Char
import Data.Traversable
import qualified Data.Map as M
--}
--{- util
import XMonad.Util.Run (safeSpawn)
--}
--}
--{- type aliases
type AXXX a = a -> X () -> X () -> X ()
type XXXA a =      X () -> X () -> X () -> a
type XXX    =      X () -> X () -> X ()
--}
--{- keys
--{- type definitions
super, alt :: KeyMask
mwinKeys, mwsKeys, mfsKeys :: [[String]]
--}
super = mod4Mask
alt = mod1Mask

-- keys for switching windows
-- left, right
mwinKeys = [["a","n"],["r","e"]]
-- keys for switching workspaces
-- left, right
mwsKeys = [["<L>","<KP_Page_Up>","<Page_Up>"],["<R>","<KP_Page_Down>","<Page_Down>"]]
-- keys for managing fullscreen
-- fullscreen, windowed
mfsKeys = [["<U>"],["<D>"]]
--}
--{- customization
--{- type definitions
mfont, mhome,
 mbrowser, mfiles, mterminal, mshell, meditor',
 mnotify', mlocker, mtoClip,
 mscreenshotFull, mscreenshotBox :: String
meditor :: String -> String
mnotify'', msession, mrestart, bg, fg, bg', fg' :: [String]
mtimeout :: Int
mapps, mconfigs :: [(String, String)]
borderW :: Dimension
--}
--{- font
mfont = "xft:Mononoki Nerd Font:bold:size=10"
--}
--{- wm name
mwm = "V0ID|BRING3R"
--}
--{- home directory
-- automatic
mhome = unsafePerformIO $ getEnv "HOME"
-- manual
-- mhome = "/home/example"
--}
--{- programs
mbrowser = "librewolf"

mfiles = "thunar" -- pcmanfm

mterminal = "alacritty"
mshell = "fish"  -- "bash"

-- gridselect...
meditor' = "nVim"  -- assumeS CLI in scratch.hs
meditor f = mconsole' $ meditor' <> " " <> f
--}
--{- environment programs
-- the cabal,stack/nix installs of xmobar don't work (on arch anyway)
mbar = "/bin/xmobar " <> mhome <> "/.xmonad/xmobar.conf"
mtray mBG = "stalonetray " <> joins " " args
-- mtray = "trayer " <> joins " " args
 --{- args
 where
 args =
  [ "-bg '" <> mBG <> "'"
  , "--slot-size 24"
  , "--icon-size 8"
--, "--no-shrink"
  , "--sticky"
  , "--xsync"
  , "--window-layer top"
  , "--max-geometry 0x24"
  , "--kludges=force_icons_size"
--[ "--edge top"
--, "--align center"
--, "--expand false"
--, "--widthtype request"
--, "--padding 6"
--, "--height 18"
--, "--distance 3"
--, "--iconspacing 8"
--, "--SetDockType true"
--, "--SetPartialStrut true"
--, "--transparent false" -- transparency doesn't work well
--, "--alpha 0"
--, "--tint 0x22222200"
  ] --}

--{- volume
-- the amount to go up/down in volume based on regular, or shifted keystrokes
mvoln  = 5
mvoln' = 2
--{- command that changes the volume, takes two arguments:
-- - num is the number that is applied
-- - op is operation, usually +/-
--}
mvol num op = concat ["amixer set Master ", show num, "%", op]
-- similar to above, but static, merely toggles the mute state
--{- programmer ramble
-- I would simplify these strings using some more programmatic magic, but
-- this is the part of the config that's meant to be plug & play, so that's
-- beyond the scope of this code section
--}
mmute = "amixer set Master toggle"
--}
--{- brightness
-- the amount to go up/down in brightness based on regular, or shifted keystrokes
mbrightn  = 5
mbrightn' = 2
--{- command that changes the brightness, takes two arguments:
-- - num is the number that is applied
-- - op is operation, usually +/-
--}
mbright num op = concat ["brightnessctl set ", show num, "%", op]
--}

mnotify' = "notify-send"
mnotify'' = ["-i", "info"]

mlocker = "slock"
mtimeout = 5  -- in minutes

mtoClip = "xclip -selection clipboard"

mscreenshotFull = "maim | "      <> mtoClip <> " -t image/png"
mscreenshotBox  = "flameshot gui"
mscreenshotBox' = "maim -sku | " <> mtoClip <> " -t image/png"
--}
--{- favorite programs
mapps =
 [ (caps mterminal, mterminal)
-- , (caps mterminal', mterminal')
 , (caps mbrowser, mbrowser)
 , (caps meditor', meditor "")
 , (caps mfiles,   mfiles)
 , ("Firefox",     "firefox") -- temporary, while you make the transition
 , ("Gravit",      "brave --app=https://designer.gravit.io") -- sandboxed variant, no noticable difference
 , ("Discord",     "brave --app=https://discord.com/channels/@me") -- sandboxed variant, no noticable difference
 , ("0 Element",   "element 0")
 , ("1 Element",   "element 1")
 , ("2 Element",   "element 2")
 , ("ThBird",      "thunderbird")
 , ("Gimp",        "gimp")
 , ("OBS",         "obs")
 , ("wiicube",     "dolphin-emu")
 , ("ps3",         "rpcs3")
 , ("Steam",       "Steam") -- script
 , ("Engrampa",    "engrampa")
 , ("Blender",     "blender")
 , ("MultiMC",     "Multimc")
 ]
--}
--{- my configs
mconfigs =
 [(a, meditor b) | (a, b) <-
  [ ("Bashrc", mhome <> "/.bashrc")
  , ("Xmonad", mhome <> "/.xmonad/xmonad.hs")
  , ("Xmobar", mhome <> "/.xmonad/xmobar.conf")
  , ("Fishrc", mhome <> "/.config/fish/config.fish")
  ]
 ]
--}
--{- session startup
-- run once
msession =
 [ "/usr/lib/xfce-polkit/xfce-polkit" -- TODO: create nix derivation for
 , mhome <> "/.nix-profile/lib/xfce4/notifyd/xfce4-notifyd"
 , "appimagelauncherd"
 , "usermount"
 ]  -- mtray && mbar

-- run on every restart as well
mrestart =
 [ "dash " <> mhome <> "/.wmrc " <> mhome
-- , "udiskie --appindicator"
 --, "parcellite"
 ]
--}
--{- colors
-- make prioritized color lists
fg' = prioritize fg  -- apply favorite levels
bg' = prioritize bg  -- apply favorite levels

-- minimum of 4 colors each
bg =
 map hex6
 [ "#222"
 , "#334"
 , "#445"
 , "#556"
 ]

-- access via fg!n
fg =
 map hex6
 [ "#59c"  -- blue    old: "#8bf"
 , "#c95"  -- orange     : "#fb8"
 , "#c55"  -- red        : "#f88"
 , "#5c9"  -- green      : "#8fb"
 , "#95c"  -- purple     : "#b8f"
 ]
---}
--{- borders
borderW = 2
--}
--{- workspace settings
-- characters to be appended to workspace names to apply rulesets
-- regular workspaces
mreg = ""
-- fullscreen workspaces
mfull = "+"
-- floating workspaces
mfloat = "~"
--}
--}
--{- utility functions
--{- type definitions
-- types that use ambiguous letters are intentionally generalized
prioritize :: [[a]] -> [[a]]
hex6, caps, findProcess, mconsole' :: String -> String
cons, scon :: [a] -> [a]
wraps :: [a] -> [a] -> [a]
joins :: [a] -> [[a]] -> [a]
withTiled' :: (Window -> WindowSet -> WindowSet) -> X ()
windowCount :: X (Maybe String)
(!) :: [a] -> Int -> a
(~~?), (~?) :: Eq a => Query [a] -> [a] -> Query Bool
valid :: String
unspawn :: String -> X ()
mconsole :: String -> String -> String
mnotify :: String -> String -> X ()
--}
--{- colors
-- requires a non-empty list
-- factorial $ length - idx <- explanation of how prioritize works
prioritize l =
 -- this factorially effects those that're favorited, int
 let favoriteOffset = 2 in
 concat $
  -- zipwith - run b with each of a
  -- replicate - 2 "a" -> "aa"
  zipWith replicate
   -- get factorial of index, but cap at 30, factorial is of unreasonable time
   (map (\x -> min 30 $ sum [0..x*favoriteOffset])
   -- get each index, in reverse order
   [length l, length l-1 .. 1])
   l
hex6 h =
 head h : concat (
  -- if string is longer than 4 characters, then double e.g #123 -> #112233
  -- exclude first character, ofc
  map (\x -> replicate (if (length h') > 4 then 1 else 2) x) h'
  ) where h' = tail h
--}
--{- lists,arrays,strings
cons arr = tail arr <> [head arr]
scon arr = last arr : init arr -- init is inverse tail
lFilter :: [(String,X ())] -> String -> [X ()]
lFilter pairs str = [ b | (a,b) <- pairs, a == str]
--}
--{- strings
caps str = (toUpper $ head str) : tail str
joins a b = concat $ head b : [ a <> x | x <- tail b ]
wraps a b = a <> b <> a
--}
--{- xmonad
withTiled' f =
 windows $ \ws ->
  let all' = filter (not . flip M.member (W.floating ws)) . W.integrate' . W.stack . W.workspace . W.current $ ws
  in foldr f ws all'
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset
--}
--{- operators
-- user-friendly length fn
l ! n = l!!(n-1)
-- query operator for pythonic 'in'
q ~~? x = isInfixOf x <$> q
-- same as above, ignore first char for capitalization ruling
q ~? x = q ~~? (tail x)
--}
--{- shell
-- valid chars
valid = ['!' .. 'z'] \\ "!$&;*/<=>"

findProcess p = "pgrep -i -d ' ' " <> reverse (takeWhile (`elem` valid) $ reverse (takeWhile (/= ' ') p))

-- based on: https://gist.github.com/altercation/fdd2dff789b4aa9287476bf33ba6167c#file-xmonad-hs-L229
unspawn p = spawn $ "kill `" <> findProcess p <> "` &"
--}
{- https://github.com/pjones/xmonadrc/blob/master/src/XMonad/Local/Action.hs
focusFollowsTiledOnly :: Event -> X All
focusFollowsTiledOnly e@CrossingEvent {ev_window = w, ev_event_type = t}
  | isNormalEnter = whenX bothTiled (focus w) <+> mempty
  where
    isNormalEnter = t == enterNotify && ev_mode e == notifyNormal
    bothTiled = notFloating w <&&> currentIsTiled
    currentIsTiled = currentWindow <+>= maybe (return True) notFloating
    currentWindow = gets $ W.peek . windowset
    notFloating w' = gets $ not . M.member w' . W.floating . windowset
focusFollowsTiledOnly _ = mempty
--}
--{- console
-- turn shell and terminal settings into functions
mconsole name exec =
 concat [mterminal, " -t ", name, " -e ", exec, ""]
mconsole' exec =
 concat [mterminal, " -e ", exec, ""]
--}
--{- notify
-- turn notification settings into function
mnotify s c = do
 spawn $ joins " "               -- join with spaces
  [mnotify',                     -- command
  (joins " " mnotify''),         -- arguments
  (wraps "\"" s), (wraps "\"" c) -- encased notification content
  ]
--}
--}

{- references
{- -- this tricks vim, enabling syntax highlighting
-}
-- ($ a) == (\f -> f a)
map (+ 5) [5..10]
map ($ 5) [(5 +), (10 +)]
--}

