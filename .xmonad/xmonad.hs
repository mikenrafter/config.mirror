--xmonad #
{-# OPTIONS_GHC -Wno-missing-signatures -Wno-orphans #-}
{-# LANGUAGE FlexibleContexts #-} -- for L.Hidden
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE BlockArguments #-}

{- LANGUAGE ViewPatterns #-} -- ?
{- LANGUAGE ParallelListComp #-} -- ?
{- LANGUAGE NoMonomorphismRestriction #-} -- ?
{- LANGUAGE NamedFieldPuns #-} -- ?

import XMonad.Hooks.FadeWindows
-- my xmonad config, see ../.vimrc for navigation
--{- imports
--{- global
import Custom.Grid
import Custom.Keys
import Custom.Prompts
import Custom.Scratch
import Custom.Vars as V
import qualified Custom.Fullscreen as FS
--}
--{- standards
import XMonad
import XMonad.Prelude
import qualified XMonad.StackSet as W
import System.IO (hPutStrLn, Handle)
import System.Directory
import Control.Monad
import XMonad.Config.Prime (Query(..))
--}
--{- data
import Control.Monad
import Data.Monoid
import Data.List (isInfixOf)
import Data.Char (isSpace, toLower)
import qualified Data.Map as M
import Data.Maybe (fromJust)
--}
--{- actions
import XMonad.Actions.SpawnOn
import XMonad.Actions.UpdatePointer
import XMonad.Actions.TagWindows
--}
--{- hooks
import XMonad.Hooks.DynamicLog  --(dynamicLogWithPP, pad, xmobarPP, xmobarColor, xmobarBorder, PP(..), shorten, xmobarStrip, filterOutWsPP)
-- for some fullscreen events, also for xcomposite in obs.
import Custom.EwmhDesktops
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.ManageDocks -- (avoidStruts, docksEventHook, checkDock, manageDocks, ToggleStruts(..))
import XMonad.Hooks.ManageHelpers hiding ((~?))
import XMonad.Hooks.SetWMName
import XMonad.Hooks.WorkspaceHistory
import XMonad.Hooks.RefocusLast
import XMonad.Hooks.Place
import XMonad.Hooks.WindowSwallowing
import XMonad.Hooks.DynamicProperty
--}
--{- layouts
--{- variants
import qualified XMonad.Layout.Spiral as LS
import XMonad.Layout.GridVariants (Grid(Grid))
import XMonad.Layout.ResizableTile
import XMonad.Layout.Tabbed
import XMonad.Layout.MultiDishes
import XMonad.Layout.Accordion
import XMonad.Layout.SubLayouts
import XMonad.Layout.LayoutBuilder
--}
--{- effects
--{- testing
import Custom.Magnifier
--import XMonad.Layout.Magnifier -- of use
import XMonad.Layout.CenteredMaster -- of use
import qualified XMonad.Layout.HintedTile as HT
--}
import XMonad.Layout.TrackFloating
import XMonad.Layout.LayoutModifier
import XMonad.Layout.LimitWindows (limitWindows)
import XMonad.Layout.NoBorders (smartBorders, noBorders)
import XMonad.Layout.Spacing
import XMonad.Layout.ShowWName
--}
--{- modifiers
import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS))
import XMonad.Layout.Renamed (renamed, Rename(..))
import XMonad.Layout.WindowArranger (windowArrange, WindowArrangerMsg(..))
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))
import XMonad.Layout.Hidden
import XMonad.Layout.Minimize
import XMonad.Layout.BoringWindows (boringWindows, boringAuto)
--}
--{- actions
import XMonad.Actions.MouseResize
import XMonad.Actions.DynamicProjects
import XMonad.Actions.CopyWindow
import XMonad.Layout.WindowNavigation
--}
--}
--{- utils
import qualified XMonad.Util.ExtensibleState as XS
import XMonad.Util.EZConfig (additionalKeysP, removeKeysP, checkKeymap)
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run (runProcessWithInput, safeSpawn, spawnPipe)
import XMonad.Util.SpawnOnce
import XMonad.Util.Cursor
import XMonad.Util.WorkspaceCompare
import XMonad.Util.Hacks as Hacks
import XMonad.Util.WindowProperties
--}
--{- urgencyhook
import XMonad.Hooks.UrgencyHook
import XMonad.Util.NamedWindows
import XMonad.Util.Run
--}
--}
--{- autostart
--{- type definitions
mstartupHook :: [String] -> [String] -> String -> String -> X ()
--}
mstartupHook bcs fcs mBG mFG = do
-- setDefaultCursor xC_left_ptr
 FS.setTheme $ mtabConfig mBG mFG
 setWMName mwm
 mapM_
  ( \x -> spawnOnce $ x <> " &" )
  $ mlock <> msession
 mapM_
  ( \x -> unspawn x <+> spawn ("sleep 1;" ++ x) )
  $ mtray (bcs!1) : mrestart
 where
  mlock =
   [ "xset s " <> show (60 * mtimeout)
   , "xss-lock " <> mlocker
   ]
--}
--{- workspaces
--{- type definitions
tagWS :: String -> [(String, (String, X ()))] -> [(String, (String, X ()))]
chop  ::[(String, (String, X ()))] -> [String]
mWS   :: String -> String -> X () -> (String, (String, X ()))
mregular', mfloats', mfulls' :: [(String, (String, X ()))]
mregular , mfloats , mfulls , mworkspaces :: [String]
mprojects :: [Project]
mWSIndices :: M.Map String Int
--}
--{- fn
tagWS tag l = [(a ++ tag, b) | (a, b) <- l ]
chop l = [a | (a, b) <- l]
mWS name directory startup = ( name, (directory, startup) )
mWSIndices = M.fromList $ zipWith (,) mworkspaces [1..]
act ws = (xmobarAction ("xdotool key super+"<>show i) "12345" . pad) ws
 where i = fromJust $ M.lookup ws mWSIndices
--}

--{- regular
mregular' =
 tagWS mreg
 [ mWS "work" "~/"
   $ mapM_ spawnHere [mterminal, mfiles]
 , mWS "dev" "~/"
   $ mapM_ spawnHere [mterminal, meditor ""]
 , mWS "web" "~/"
   $ mapM_ spawnHere [mbrowser]
 , mWS "art" "~/"
   $ mapM_ spawnHere ["gravit-designer", "gimp"]
 , mWS "chat" "~/"
   $ mapM_ spawnHere ["thunderbird", "element-desktop"]
 ]
--}
--{- floats
mfloats' =
 tagWS mfloat
 [ mWS "A1" "~/"
   $ mapM_ spawnHere []
 , mWS "A2" "~/"
   $ mapM_ spawnHere []
 , mWS "A3" "~/"
   $ mapM_ spawnHere []
 ]
--}
--{- fulls
mfulls' =
 tagWS mfull
 [ mWS "B1" "~/"
   $ mapM_ spawnHere ["lutris"]
 , mWS "B2" "~/"
   $ mapM_ spawnHere []
 , mWS "B3" "~/"
   $ mapM_ spawnHere []
 ]
--}

--{- lists
mregular = chop mregular'
mfloats = chop mfloats'
mfulls = chop mfulls'
mworkspaces =
 concat
 [ mregular, mfloats, mfulls
 , ["NSP"]
 ]

mprojects =
 [
 Project
  { projectName = a
  , projectDirectory = b
  , projectStartHook = Just $ do c
  } | (a, (b, c)) <- concat [ mregular', mfloats', mfulls' ]
 ]
--}
--}
--{- hooks
--{- type definitions
mmanageHook :: XMonad.Query (Data.Monoid.Endo WindowSet)
mhandleEventHook :: Event -> X All
mlogHook, mbarHook :: Handle -> [String] -> [String] -> X ()
--mlayoutHook :: String -> String -> l0 Window
--mlayoutHook :: ()
--}
--{- urgencyHook
-- let windows mark themselves as urgent, add a border, and send a
-- notification
data LibNotifyUrgencyHook = LibNotifyUrgencyHook deriving (Read, Show)

instance UrgencyHook LibNotifyUrgencyHook where
 urgencyHook LibNotifyUrgencyHook w = do
  name    <- getName w
  Just ws <- fmap (W.findTag w) $ gets windowset
  safeSpawn mnotify' $ mnotify'' <> [ws, show name]

--}
--{- manageHook
{- documentation
tail "abc" -> "bc"
 "Abc123"  ~? "abc" == True   -- tailed infix
 "ABc"     ~? "Abc" == False
 "123abc" ~~? "abc" == True   -- infix
 "abc"    ~~? "Abc" == False
 "abc"     =? "abc" == True   -- exact
 "abc1"    =? "abc" == False

 | operator | false-positivity | verbosity |
 -------------------------------------------
 | ~?       | high             | low       |
 | ~~?      | medium           | medium    |
 | =?       | low              | high      |

usage:
 identifier :: Query String
 condition  :: Query Bool
 action     :: (maybe)manageHook
 
 conditions >| action    -- if any condition  is  satisfied
 conditions >& action    -- if all conditions are satisfied
 c ?| a {- and -} c ?& a -- ^ MaybeManageHook variants ^
 
 collage [identifiers] [strings]            -- returns [identifier ~? string]s
 [otherConditions] << collage ... >| action -- standard + collage
 collage ... << [otherConditions] >| action -- also works as expected
--}
mmanageHook =
 let up = updatePointer (0.5, 0.5) (1, 1)
 in
 -- manage floating, and fullscreen
 retainFS
 -- manage scratchpads, done after WS shifting, before, stack
 -- rearrangement, and before composeOne - monoids read backward
 <+> namedScratchpadManageHook mscratch
 -- supposed to reunite child windows from an application with the parent,
 -- isn't very reliable
 <+> transience'
 <+> composeOne [collage [c] (browsers<>gaming<>art) >| V.groupBy c]
 --{- basic
 <+> composeOne
  [ collage [c,t] ["xmonad_conky"]        ?| doLower <+> doIgnore
  , [ isDialog, currentWs ~~? mfloat ]    <<
    collage [c,t] (popup <> floaters)     ?| doCenterFloat
  , collage [c,t] annoyances              ?| s'' 2
  , [ isFullscreen, currentWs ~~? mfull ] <<
    collage [c,t] gaming                  ?| FS.start
  ] --}
 --{- workspaces
 <+> composeAll( reverse
--[ checkDock --> doLower
  [
    collage [c  ] ["obs"]   >| s 1
--, collage [c  ] []        >| s 2
  , collage [c  ] browsers' >| s 3
  , collage [c  ] art       >| s 4
  , collage [c,t] chat      >| s 5

--, collage [c,t] []    >| s' 1
--, collage [c,t] media >| s' 2
  , collage [c  ] virt  >| s' 3

  , collage [c  ] gaming >| s'' 1
--, collage [c,t] []     >| s'' 2
--, collage [c,t] []     >| s'' 3
  ]) --}
 -- hook for spawnOn calls
 <+> manageSpawn
 --{- where
 where
  --{- groups
  browsers' =
   [ "firefox", "libreWolf"
   , "tor Browser", "tor-", "torbrowser"
   , "qute"
   ]
  browsers = browsers' <> [ "brave", "chrom" ]
  gaming =
   [ "steam", "lutris", "heroic"
   , "dolphin-emu"
   , "multiMC"
   ]
  media =
   [ "music", "video"
   , "mpv", "vlc"
   ]
  virt =
   [ " xephyr", "weston"
   , " virt"
   ]
  art =
   [ "krita", "gimp"
   , "design"
   ]
  chat =
   [ "thunderbird", "discord", "brave", "element"
   , "messeng", "convers", "irc", "chat"
   ]
  popup = map (' ':)
   [ "pop-up", "overlay", "toolkit", "tool"
   , "dialog", "message", "notif", "zenity"
   , "file", "open", "inspect"
   , "flameshot", "xzoom"
   , "man"
   ]
  floaters = map (' ':)
    [ "picture"
    , "connection"
    , "volume", "pulseaudio", "alsa", "jack", "pipewire", "easyeffects"
    , "junction", "re.sonny.Junction"
    ]
  annoyances = map (' ':)
    [ "crash report"
    , "Sharing Indicator"
    ]
  --}

  -- Use with group ? Doesn't work at the moment...
  isNotOn t = ask >>= \w -> pure (maybe True (const False) (W.findTag w t))

  c = className
  t = title
--  never = return False
  s n = doShift $ mregular!n
  s' n = doShift $ mfloats!n
  s'' n = doShift $ mfulls!n
  collage f v = [x ~? y | y <- v, x <- f]
--  anyOfIs fns compare list = 
  -- see above, https://github.com/TheMC47/dotfiles/blob/master/.xmonad/src/Config.hs
  retainFS =
   composeOne
   [ FS.query    -?> doF ignore
   , return True -?> doF avoid
   ]
  --{- ignore
  -- n: new, u: up, upstack, c: current, d: downstack
  ignore ws = flip W.modify' ws \case
   -- move the new windows downward
   W.Stack n u (c:d) -> W.Stack c u $ n:d
   W.Stack n u d     -> W.Stack n u   d
  --}
  --{- avoid
  avoid ws =
   let floating = W.floating ws; s = flip W.Stack
   -- ^ s: [top..above] focus [below..bottom]
   in flip W.modify' ws \case
   -- n: new, u: up, c: current, d: downstack
    --{- master
    W.Stack n [] (c : d) ->
     -- new: tiled -> focus
     if n `isn't`   floating then s [] n $ c:d
     -- else -> focus
     else s [] n $ c:d
    --}
    --{- other
    W.Stack n u (c : d) ->
     -- current: float, new: tile -> avoid
     if n `isn't`   floating
     && c `is`      floating then s u c $ n:d
     else
     -- new & current: float -> focus
     if [n,c] `are` floating then s u n $ c:d
     -- else -> above
     else s (c:u) n d
    --}
    -- empty -> focus
    W.Stack n u d -> W.Stack n u d
  --}

--}
--}
--{- activateHook
-- focus element, let all others die
mActivateHook :: ManageHook
mActivateHook = composeOne
  [ className ~? "Element" -?> doFocus
  , pure True -?> doAskUrgent
  ]
--}
--{- handleEventHook
mhandleEventHook =
 -- when a focused, fullscreen window is closed, refocus last window
--     fadeWindowsEventHook
     refocusLastWhen
     (    FS.query
     <||> fmap not isFloating
     <||> return True
     )
 <+> blend dynamicPropertyChange propertyHooks
 <+> trayerAboveXmobarEventHook
 <+> Hacks.windowedFullscreenFixEventHook
 <+> uncurry swallowEventHook swallowHook
--}
--{- swallowHook
swallowHook = (className =? mterminal <&&> fmap not ( title ~~? "S:"), return True)
--}
--{- propertyHooks
propertyHooks =
 [ ("WM_CLASS", composeOne
   [ className ~? "re.sonny.Junction" -?> doCenterFloat
   --className ~? "element" -?> doCenterFloat
   ])
 ]

--}
--{- fadeHook
mfadeHook = composeAll
 [    opaque
 ,    isUnfocused
 <&&> isFloating  --> transparency 0.05
 ,    FS.query    --> opaque
--    opaque
 ]
--}

--{- logHook
mlogHook pipe bcs fcs =
 -- counterpart to handleEventHook for refocusLast
 refocusLastLogHook
 -- change opacity of unfocused windows, 1 is opaque, 0 transparent
-- <+> fadeWindowsLogHook mfadeHook
 -- for changing to/from the last focused workspace
 <+> workspaceHistoryHook
 -- pass pipe in, for status bar
 <+> mbarHook pipe fcs bcs
 -- handle mag-fullscreen events
 <+> FS.logHook
--}
--{- barHook
mbarHook pipe fg bg = do
 -- for copied windows, e.g media player
 copies <- wsContainingCopies
 let check x | x `elem` copies = xc (fg!3) (bg!2) $ " + "
                   | otherwise = xc (fg!1) (bg!3) $ act x
 -- boilerplate + xmobar + scratchpads
 dynamicLogWithPP . filterOutWsPP ["NSP"] $ xmobarPP
   { ppOutput = hPutStrLn pipe

   , ppSep             = " "
   -- mark urgent WS's
   , ppUrgent          = xc(fg!3) (bg!3) . act
   , ppCurrent         = xc(fg!2) (bg!1) . xmobarBorder "Bottom" (fg!1) 4 . act
   , ppHidden          = check
   , ppHiddenNoWindows = xc(bg!4) (bg!2) . pad . take 2
   , ppTitle           = \x -> xc(fg!5) (bg!2) . pad . shorten 40 $ if null x then "?" else x
   , ppTitleSanitize   = xmobarStrip

   -- other items
   , ppExtras = [windowCount]
   , ppOrder  = \(ws:lay:title:extra) -> [take 10 lay, ws] <> extra <> [title]
   , ppSort = mkWsSort getWsCompare

   }
  where xc = xmobarColor
--}
--}

--{- layout
--{- type definitions
mshowWNameTheme :: [Char] -> [Char] -> SWNConfig
--}
--{- global settings
-- theming for tabs
mtabConfig mFG mBG =
 def
 { fontName            = "xft:Mononoki Nerd Font:regular:pixelsize=16"
 , activeColor         = mFG
 , activeBorderColor   = mBG
 , activeTextColor     = mBG

 , inactiveColor       = mBG
 , inactiveBorderColor = mBG
 , inactiveTextColor   = mFG
 }
-- i --> inner x*, inner y*, outer x*, outer y*
mspacing i = smartSpacingWithEdge i
nospace    = spacing 0
lay name count space layout =
-- windowArrange $
   renamed [Replace name]
 $ (if space > 0 then mspacing space else nospace)
 $ limitWindows (if count > 0 then count else 100)
 $ hiddenWindows
 $ fullscreen
 $ layout
--}
--{- layoutHook
mlayoutHook mBG mFG =
   mods
   -- windowNavigation .
   -- subLayout [0] (tabs mBG mFG)
   $   dishess mBG mFG
-- ||| tabPlus mBG mFG
   ||| accordion
   ||| spiral
   ||| spiral'
   ||| tall1
   ||| tabs mBG mFG
   ||| tall2
 where
  -- modifications for all
  mods =
     smartBorders .
     showWName' (mshowWNameTheme mBG mFG) .
     avoidStruts .
   --boringAuto . boringWindows .
     -- keep floating grouped above last focused tiled
     trackFloating .
     mouseResize
--}
--{- selected layouts
--             lay name  # ' ' $ layout
--tabPlus mBG mFG =  lay "+tb" 0 2 $ (layoutN 3 (relBox 0 0 0.5 1) (Just $ relBox 0 0 1 1)   $ tabs mBG mFG)
--                                 $ (layoutN 3 (relBox 0.5 0 1 1) Nothing                   $ tabs mBG mFG)
--                                 $  layoutAll (relBox 0 0.4 1 1)                           $ tabs mBG mFG
dishess mBG mFG = lay "dis" 6 0 $ magnifier $ MultiDishes 2 4 (3/7)
--dishess mBG mFG = ( layoutN 6 (relBox 0 0 1 (4/7)) (Just $ relBox 0 0 1 1) $ magnifier $ MultiDishes 2 4 (3/7))
--                  $ layoutAll (relBox 0 (4/7) 1 1)                         $ full
--dishess mBG mFG = lay "dis" 0  2 $ (layoutN 6 (relBox 0 0 1 (4/7)) (Just $ relBox 0 0 1 1) $ magnifier $ MultiDishes 2 4 (3/7))
--                                 $  layoutAll (relBox 0 (4/7) 1 1)                         $ tabs mBG mFG
accordion =    lay "acc" 0  2 $ Accordion
spiral =       lay "spi" 8  2 $ LS.spiral (3/5)
spiral' =      lay "+sp" 8  2 $ magnifier $ LS.spiral (3/5)
tall1 =        lay "tl1" 10 2 $ Tall 1 (3/100) (1/2)
tall2 =        lay "tl2" 20 3 $ Tall 2 (3/100) (1/2)
tabs mBG mFG = lay "tab" 50 0 $ tabbed shrinkText $ mtabConfig mFG mBG
--}
--{- showWorkspaceTheme
mshowWNameTheme mBG mFG =
 def
 { swn_font    = "xft:Mononoki Nerd Font:regular:pixelsize=32"
 , swn_fade    = 0.5
 , swn_bgcolor = mBG
 , swn_color   = mFG
 }
--}
--}
--{- xmonad
--{- type definitions
main :: IO ()
--}
--{- definitions
main = do
 pipe <- spawnPipe mbar
 --{- dynamic colors
 let getColors = tryReadFile . (mhome <>)
 let stringify colors = foldr1 (\a b -> a <> "\n" <> b) colors

 faves' <- getColors "/.faves" <|> pure ("")
 let faves = mapps <> (map (breakOn '\t') $ grabColors '\n' '#' faves')

 wmbc <- getColors "/.cache/wal/wmbc-DISABLED"
     <|> getColors "/.wmbc"
     <|> pure (stringify bg)
 wmfc <- getColors "/.cache/wal/wmfc-DISABLED"
     <|> getColors "/.wmfc"
     <|> pure (stringify fg)
 let fcs = map hex6 $ grabColors '\n' ' ' wmfc
     bcs = map hex6 $ grabColors '\n' ' ' wmbc
 fc   <- rand $ prioritize fcs
 bc   <- rand $ prioritize bcs

 let
  mFG = fc
  mBG = bc
 --}
  mk = mkeys mworkspaces bcs fcs faves
  keys = ("M-h", checkKeymap (ewmh def `additionalKeysP` mk) mk) : mk
  in
  xmonad
  --}
  --{- hooks  {
  -- manage docks
  . Hacks.javaHack
  -- apply urgency hook
  . withUrgencyHook LibNotifyUrgencyHook
  -- apply urgency hook w/ borders
  $ withUrgencyHookC BorderUrgencyHook { urgencyBorderColor = mFG } urgencyConfig { suppressWhen = Never }
 -- $ dynamicProjects mprojects
  . setEwmhActivateHook doAskUrgent
  . ewmhFullscreen
  . docks
  . ewmh
  $ def
   { manageHook      = mmanageHook
   , handleEventHook = mhandleEventHook
   , logHook         = mlogHook pipe    bcs fcs
   , startupHook     = mstartupHook     bcs fcs mBG mFG
   , layoutHook      = mlayoutHook      mBG mFG
   --}
   --{- settings
   , workspaces         = mworkspaces
   , focusFollowsMouse  = False
   , clickJustFocuses   = True
   , modMask     = super
   , terminal    = mterminal
   --}
   --{- colors
   , borderWidth        = borderW
   , normalBorderColor  = mBG
   , focusedBorderColor = mFG
   --}
   } --}
   --{- apply keys
   -- remove defaults listed in overrides
   `removeKeysP` (map fst moverrides)
   -- add overrides
   `additionalKeysP` moverrides
   -- remove conflicts with your config
   `removeKeysP` (map fst moverrides)
   -- apply your config
   `additionalKeysP` keys
  --}

{- TODOs
IfMax instead of layoutBuilder
X.L.Stoppable -- save CPU with bg processes! Use with caution.
--}
{- references
--}
