{-# LANGUAGE LambdaCase, BlockArguments, TupleSections, RecordWildCards #-}
module Custom.Vars where
--{- imports
--{- standards
--port qualified XMonad.Core
import XMonad hiding (terminal, Color(..))
import XMonad.Prelude hiding (for)
import qualified XMonad.StackSet as W
import System.IO.Unsafe (unsafePerformIO)
import System.Environment (getEnv)
import System.Random.Stateful (uniformRM, globalStdGen)
--}
--{- data
import Data.List
import Data.List.Split (wordsBy, splitOn)
import Data.Char
import Data.Traversable hiding (for)
import qualified Data.Map as M
import Data.Bifunctor (first, second)
--}
--{- util
import XMonad.Util.Run (safeSpawn, spawnPipe)
import GHC.IO.Handle (Handle)
--}
import XMonad.Layout.Decoration
import System.Directory
import Control.Monad
import XMonad.Hooks.ManageHelpers
--}
--{- type aliases
type AXXX a = a -> X () -> X () -> X ()
type XXXA a =      X () -> X () -> X () -> a
type XXX    =      X () -> X () -> X ()
--}
--{- keys
super = mod4Mask :: KeyMask
alt   = mod1Mask :: KeyMask

-- keys for switching windows
-- left, right
windowKeys =
 -- down
 [ ["s","n"]
 -- up
 , ["t","e"]]
-- keys for switching workspaces
-- left, right
workspaceKeys =
 -- down
 [ ["<L>","<KP_Page_Up>",    "<Page_Up>"]
 -- up
 , ["<R>","<KP_Page_Down>","<Page_Down>"]]
-- keys for managing fullscreen
-- fullscreen, windowed
fullscreenKeys =
 -- down
 [ ["<U>"]
 -- up
 , ["<D>"]]
--}
--{- customization
open :: String -> String -> X ()
open c = spawn . with c
start = spawn :: String -> X ()
-- specify monad instance for constraint
--spawn :: String -> X ()
--spawn = XMonad.Core.spawn
with' = (<>)
with  = with' . (<>" ")
plus s f = f<>" "<>s
simply f _ _ = f
--{- settings
mononoki t s = "xft:Mononoki Nerd Font:"<>t<>":size="<>show s
font    = mononoki "bold"    10
font'   = mononoki "regular" 16
name    = "V0ID|BRING3R"
home    = unsafePerformIO $ getEnv "HOME"
maxStep, minStep, timeout :: Int
maxStep = 5
minStep = 2
timeout = 5 -- in minutes
border  = 2 :: Dimension
--}
--{- actions & apps
browse  = open browser
view    = open files
prompt  = open term . with shell
edit    = open term . with editor
-- simply strings
browse''= browser
view''  = files
prompt''= with term shell
edit''  = with term editor

-- string versions that accept names
browse' = const browser
view'   = const files
prompt' = scratch shell
edit'   = scratch editor


term    = with terminal "--command"
named   = with terminal . with "--title" . wraps "\""
scratch c n = named n `with` "--command" `with` c


browser  = "librewolf"
files    = "thunar"
terminal = "alacritty"
shell    = "fish"
editor   = "nvim"

browserc  = caps browser
filesc    = caps files
terminalc = terminal
shellc    = terminal
editorc   = terminal
--}
--{- util
panel :: IO Handle
panel  = spawnPipe $ "bar "<>home<>" "<>home<>"/.xmonad/xmobar.hs"
notifs = start  "notif-center"
tray   = open "stalonetray" . joins " " . args where
 --{- tray args
 args x =
  [ "-bg '" <> x <> "'"
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
  ]
 --}
--}
--{- actions
-- e.g. notify $ message "Compilation failed" errormessage
message title = with (show title) . show
notify   = open "notify-send -i emblem-system"
-- system state
louder   = tweak vol "+"
quieter  = tweak vol "-"
louder'  = tweak vol "+ unmute"
quieter' = tweak vol "- unmute"
toggleV  = open  vol "toggle"
brighter = tweak bri "+"
dimmer   = tweak bri "-"

lock     = start locker
locker   = "slock"

-- screenshot
full     = open  "maim |" $ clip <> img
screen   = start "flameshot gui"
box      = open  "maim -sku |" $ clip <> img
vol  = "amixer set Master"
bri  = "brightnessctl set"
tweak :: String -> String -> Int -> X ()
tweak cmd d n = open cmd $ show n <> "%" <> d
clip = "xclip -selection clipboard"
img = " -t image/png"
--}
--{- configs
configs = map (second edit)
  [ ("Bashrc", home<>"/.bashrc")
  , ("Xmonad", home<>"/.xmonad/xmonad.hs")
  , ("Xmobar", home<>"/.xmonad/xmobar.conf")
  , ("Fishrc", home<>"/.config/fish/config.fish")
  ]
--}
--{- apps
apps = map (first caps)
  [ (terminal, prompt)
  , (browser , browse)
  , (editor  , edit  )
  , (files   , view  )
  ]
--}
--{- colors
foregrounds = map hex6
  [ "#59c"  -- blue    old: "#8bf"
  , "#c95"  -- orange     : "#fb8"
  , "#c55"  -- red        : "#f88"
  , "#5c9"  -- green      : "#8fb"
  , "#95c"  -- purple     : "#b8f"
  ]
backgrounds = map hex6
  [ "#222"
  , "#334"
  , "#445"
  , "#556"
  ]
-- how much you prefer the top items
gravity = (3,2) -- (*,/)

fc = ofList foregrounds
bc = ofList backgrounds

fc' = prioritize foregrounds
bc' = prioritize backgrounds

bfc = ofList foregrounds
bbc = ofList backgrounds
bkc = (bbc,bfc)
--}
--{- session startup
-- run once
msession =
 [ -- moved to .wmrc
 ]  -- mtray && mbar

script = open . with "dash"
-- run on every restart as well
mrestart =
 [ script (home<>"/.wmrc") ""
-- , "udiskie --appindicator"
 --, "parcellite"
 ]
--}
--}
--{- utility functions
--{- type definitions
-- types that use ambiguous letters are intentionally generalized
cons, scon :: [a] -> [a]
wraps :: [a] -> [a] -> [a]
joins :: [a] -> [[a]] -> [a]
withTiled' :: (Window -> WindowSet -> WindowSet) -> X ()
windowCount :: X (Maybe String)
(!) :: [a] -> Int -> a
(~~?), (~?){-, (~/?)-} :: Eq a => Query [a] -> [a] -> Query Bool
unspawn :: String -> X ()
type WindowBoxes = M.Map Window W.RationalRect
nonMembers,members  :: [Window] -> WindowBoxes -> [Window]
isn't,is            ::  Window  -> WindowBoxes -> Bool
aren't,are          :: [Window] -> WindowBoxes -> Bool
--}
--{- colors

-- random fg/bg
-- usage: aXG shades/colors
aXG :: Color -> IO String
aXG  = uncurry fmap . second rand
aBG, aFG :: Colors -> IO String
aBG  = aXG . fst
aFG  = aXG . snd

-- usage: color the tabs == tabs back fore
colored :: (String, String) -> (String -> String -> a) -> a
colored = flip uncurry


readColors = map hex6 . grabs ' ' '-'
ofList ls = (,len) $ (ls!!) . (`mod` len) where len = length ls

prioritize = prioritize' gravity
prioritize' :: (Int,Int) -> [String] -> Color
prioritize' (0,_) _ = error "zero gravity"
prioritize' (_,0) _ = error "zero gravity"
prioritize' _ [] = error "empty color list"
prioritize' (s,w) l@(_:_) = (,total) $ (l!!) . locate . (`mod` total) where
  -- group them into  ↑↑↑↑↑↑↑↑ standard color format
  total = head factors
  -- get the index for a given choice
  locate n = fromMaybe (len-1) $ findIndex (n>=) factors
  -- generate priority sequence
  factors = reverse $ factor 0 len
  factor x limit | x < limit = x*(x+s) `div` w : factor (x+1) limit
                 | otherwise = []
  len = length l
  --{- old
  -- approximation of:
  -- 10 -> 66 (=6.6), 11 -> 78 (~7.1), 12 -> 91 (~7.6) ... this pattern continues
  -- factor increases by approx ½ (offset = 3), 
  -- idx = flip2 foldl [(0,1)] [2..length l] \s x -> (x-1,fst (head s)+x):s
  --}

-- when seq < 4 chars, double e.g #123 -> #112233
hex6 :: String -> String
hex6 (c:cs) = take 7 $ '#' : duplicate cs where
 len = if 4 > length cs then 1 else 2
 duplicate (x:xs) = replicate len x <> duplicate xs
 duplicate [    ] = []
hex6 [    ] = []
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
    | [c,'\\'] `isPrefixOf` s2 = (s1 <> [c] <> s1', s2')
    | otherwise = (s1, s2)
      where (s1, s2 ) = break (== c) s
            (s1',s2') = breakOn c $ tail s2

tail' (x:xs) = xs
tail' [    ] = []

-- NOTE: parsec?
grabSep :: Char -> String -> [String]
grabLine :: Char -> String -> [String]
grabs :: Char -> Char -> String -> [String]

grabSep sep = map (prune $ child valid) . wordsBy (==sep)
grabLine comment = map (takeWhile (/= comment)) . wordsBy (=='\n')
grabs sep comment = concat . map (grabSep sep) . grabLine comment
--grabS comment nx = (\(x,xs) -> (dropWhile seps x) : grabS comment (tail' xs)) $ break seps nx

for = flip map
prune :: (Char -> Bool) -> String -> String
prune p = takeWhile p . dropWhile (not . p)
trim = prune $ child " \t"

tuple (a:b:_) = (a,b)
tuple [     ] = error "invalid tupling"
{-wordsWhen pred fn str =
 case dropWhile pred str of
  "" -> []
  str' -> fn w : wordsWhen pred fn tr
   where (w, tr) = break pred str'
--}
--}
--{- strings
caps (x:xs) = toUpper x : xs
--joins a (b:bs) = concat $ b : map (a<>) bs
joins = intercalate
wraps a b = a <> b <> a
--}
--{- xmonad
withTiled' f =
  windows \ws -> foldr f ws
  $ filter (not . flip M.member (W.floating ws)) . W.integrate' . W.stack . W.workspace . W.current $ ws
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset
groupBy fn = shiftToSame $ fmap Just fn
--}
--{- IO
getFile n = readFile $ with' (home<>"/") n

--parseIn :: a -> [String] -> IO (IO a -> IO a)
parseIn backup files parse =
 foldl1 (<|>) (for files getFile) <|> pure ""
 >>= return . \case
  "" -> backup
  x  -> parse x
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
(!) l n = l!!(n-1)
-- query operator for pythonic 'in'
-- q ~/? x = (not $ isInfixOf x <$> q)
(~~?) q x = isInfixOf x <$> q
-- same as above, ignore first char for capitalization ruling
(~?) q x = q ~~? (tail x)

-- query management functions, each explained in xmonad.hs
or', and' :: [Query Bool] -> Query Bool
or'  = foldr1 (<||>)
and' = foldr1 (<&&>)

infixl 5 ?&
infixl 5 ?|
(?|) a b = or'   a -?> b
(?&) a b = and'  a -?> b

infixl 5 >|
infixl 5 >&
(>|) a b = or'   a --> b
(>&) a b = and'  a --> b

infixl 7 <<
(<<) a b = a <> b

--}
--{- shell
-- valid chars
valid = ['!' .. 'z'] \\ "!$&;*/<=>"

--ndProcess p = "pgrep -i -d ' ' " <> reverse (takeWhile (`elem` valid) $ reverse (takeWhile (/= ' ') p))
findProcess = with "pgrep -i -d ' '" . takeWhile (`elem` valid)

-- based on: https://gist.github.com/altercation/fdd2dff789b4aa9287476bf33ba6167c#file-xmonad-hs-L229
unspawn = open "kill" . wraps "`" . findProcess
--}
--}
--{- settings
type Colors = (Color,Color)
type Color  = (Box, Int)
type Box    = Int -> String
type Settings = Z
data Z = Z
  { faves      :: [(String,X ())]
  , workspaces :: [String]
  -- primary bg/fg
  , tints      :: (String,String)
  , back       :: String -- ^
  , fore       :: String -- ^
  , colors     :: Colors
  , bg         :: Box
  , fg         :: Box
  , colors'    :: ([String],[String])
  , bgs        :: [String]
  , fgs        :: [String]
  -- prioritized colors:
  , shades     :: Colors
  , bg'        :: Box
  , fg'        :: Box
  , settings   :: Z
  }
--}


rand :: Int -> IO Int
rand = flip uniformRM globalStdGen . (0,)
child = flip elem

{- references
--}

