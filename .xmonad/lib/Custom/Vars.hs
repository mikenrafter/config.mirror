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
import XMonad.Layout.Decoration
import System.Directory
import XMonad.Prelude
import Control.Monad
import XMonad
import XMonad.Hooks.ManageHelpers
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
meditor' = "nvim"  -- assumeS CLI in scratch.hs
meditor f = mconsole' $ meditor' <> " " <> f
--}
--{- environment programs
-- the cabal,stack/nix installs of xmobar don't work (on arch anyway)
mbar = "bar " <> mhome <> " " <> mhome <> "/.xmonad/xmobar.conf"
--mbar = mhome <> "/.nix-profile/bin/xmobar " <> mhome <> "/.xmonad/xmobar.conf"
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
mnotify'' = ["-i", "emblem-system"]

mlocker = "slock"
mtimeout = 5  -- in minutes

mtoClip = "xclip -selection clipboard"

mscreenshotFull = "maim | "      <> mtoClip <> " -t image/png"
mscreenshotBox  = "flameshot gui"
mscreenshotBox' = "maim -sku | " <> mtoClip <> " -t image/png"

mnotifTray = "notif-center" -- ~/scripts/notif-center
--}
--{- favorite programs
mapps =
 [ (caps mterminal, mterminal)
-- (caps mterminal', mterminal')
 , (caps mbrowser, mbrowser)
 , (caps meditor', meditor "")
 , (caps mfiles,   mfiles)
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
 [ -- moved to .wmrc
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
grabColors :: Char -> Char -> String -> [String]
wordsWhen :: (Char -> Bool) -> (String -> String) -> String -> [String]
cons, scon :: [a] -> [a]
wraps :: [a] -> [a] -> [a]
joins :: [a] -> [[a]] -> [a]
withTiled' :: (Window -> WindowSet -> WindowSet) -> X ()
windowCount :: X (Maybe String)
(!) :: [a] -> Int -> a
(~~?), (~?){-, (~/?)-} :: Eq a => Query [a] -> [a] -> Query Bool
valid :: String
unspawn :: String -> X ()
mconsole :: String -> String -> String
mnotify :: String -> String -> X ()
nonMembers,members  :: [Window] -> M.Map Window W.RationalRect -> [Window]
isn't,is            ::  Window  -> M.Map Window W.RationalRect -> Bool
aren't,are          :: [Window] -> M.Map Window W.RationalRect -> Bool
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
 let h' = tail h in
 head h : (take 6 $ concat (
  -- if string is longer than 4 characters, then double e.g #123 -> #112233
  -- exclude first character, ofc
  map (\x -> flip replicate x $ if (length h') > 4 then 1 else 2) h'
  ))
grabColors sep comment = wordsWhen (== sep) $ takeWhile (/= comment)
-- split-on function grabbed from stackOverflow
wordsWhen pred fn str =
 case dropWhile pred str of
  "" -> []
  str' -> fn w : wordsWhen pred fn tr
   where (w, tr) = break pred str'
--}
--{- lists,arrays,strings
cons arr = tail arr <> [head arr]
scon arr = last arr : init arr -- init is inverse tail
lFilter :: [(String,X ())] -> String -> [X ()]
lFilter pairs str = [ b | (a,b) <- pairs, a == str]

-- blends [(monoid functor arguments,),] into multiple monoids
blend f l = foldr1 (<+>) $ map (uncurry f) l


breakOn :: Char -> String -> (String, String)
breakOn c s
    | [c,'\\'] `isPrefixOf` s2 = (s1 ++ [c] ++ s1', s2')
    | otherwise = (s1, s2)
      where (s1, s2 ) = break (== c) s
            (s1',s2') = breakOn c $ tail s2

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
groupBy fn = shiftToSame $ fmap Just fn
--}
--{- IO
tryReadFile :: FilePath -> IO String
tryReadFile f = do
 guard =<< doesFileExist f
 readFile f
--}

--{- if item in stack, filter amongst stacks
nonMembers  items set = filter (not . flip M.member set) items
members     items set = filter (      flip M.member set) items
isn't       i     s   = []/=nonMembers [i] s
is          i     s   = []/=members    [i] s
aren't      i     s   = []==members     i  s
are         i     s   = i ==members     i  s
--}
--{- operators
-- user-friendly length fn
l ! n = l!!(n-1)
-- query operator for pythonic 'in'
-- q ~/? x = (not $ isInfixOf x <$> q)
q ~~? x = isInfixOf x <$> q
-- same as above, ignore first char for capitalization ruling
q ~? x = q ~~? (tail x)

-- query management functions, each explained in xmonad.hs
or', and' :: [Query Bool] -> Query Bool
or'  = foldr1 (<||>)
and' = foldr1 (<&&>)

infixl 5 ?&
infixl 5 ?|
(?|) a b = or' a -?> b
(?&) a b = and'  a -?> b

infixl 5 >|
infixl 5 >&
(>|) a b = or' a --> b
(>&) a b = and'  a --> b

infixl 7 <<
(<<) a b = a <> b

--}
--{- shell
-- valid chars
valid = ['!' .. 'z'] \\ "!$&;*/<=>"

findProcess p = "pgrep -i -d ' ' " <> reverse (takeWhile (`elem` valid) $ reverse (takeWhile (/= ' ') p))

-- based on: https://gist.github.com/altercation/fdd2dff789b4aa9287476bf33ba6167c#file-xmonad-hs-L229
unspawn p = spawn $ "kill `" <> findProcess p <> "` &"
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
 spawn $ joins " "           -- join with spaces
  [mnotify',                 -- command
  joins " " mnotify'',       -- arguments
  wraps "\"" s, wraps "\"" c -- encased notification content
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

