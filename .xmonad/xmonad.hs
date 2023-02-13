--xmonad #
{-# OPTIONS_GHC -Wno-missing-signatures -Wno-orphans #-}
{- LANGUAGE FlexibleContexts, LambdaCase, BlockArguments, ViewPatterns #-} -- ?
{- LANGUAGE ParallelListComp, NoMonomorphismRestriction, NamedFieldPuns #-} -- ?

import XMonad.Hooks.FadeWindows
-- my xmonad config, see ../.vimrc for navigation
--{- imports
--{- global
import Custom.Grid
import Custom.Keys
import Custom.Prompts
import Custom.Scratch
import Custom.Vars hiding (workspaces)
import qualified Custom.Vars as V
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
import XMonad.Actions.EasyMotion
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
startup :: Settings -> X ()
--}
startup the = do
-- setDefaultCursor xC_left_ptr
 FS.setTheme $ color the tabConfig
--setWMName mwm
 mapM_
  ( \x -> spawnOnce $ x <> " &" )
  $ mlock <> msession
 mapM_
  ( \x -> unspawn x <+> spawn ("sleep 1;" ++ x) )
  $ mtray (the bg 0) : mrestart
 where
  mlock =
   [ "xset s " <> show (60 * mtimeout)
   , "xss-lock " <> mlocker
   ]
--}
--{- workspaces
tagWS = first . (<>)
mWSIndices :: M.Map String Int
mWSIndices = M.fromList $ zip workspaces [1..]

-- number of dynamic workspaces
projectSpace = 6
(workspaces, workflows) = (
 [ ("basic", [prompt, prompt]) -- 1
 , ("multi", [browse]        ) -- 2
 , ("full" , [spawn "Steam"] ) -- 3
 ,    w "a",  w "b",   w "c"   -- 4,5,6
-- ("chat" , [spawn "chats"] ) -- 7
-- ("NSP"  , []              ) -- 8
 ]
 ,
-- TODO: implement workflows in some way (gridselect?)
 [ ("dev", [prompt, editor]       )
 , ("web", [browse]               )
 , ("2D" , s ["gimp","krita"]     )
 , ("vec", s ["gravit","inkscape"])
 , ("3D" , s ["blender"]          )
 ]
 ) where
 s = map spawn
 w = (,[])
--}
--{- hooks
--{- type definitions
manage :: Settings -> XMonad.Query (Data.Monoid.Endo WindowSet)
events :: Settings -> Event -> X All
log, bar :: Settings -> Handle -> [String] -> [String] -> X ()
--mlayoutHook :: String -> String -> l0 Window
--mlayoutHook :: ()
--}
--{- urgencyHook
-- let windows mark themselves as urgent, add a border, and send a
-- notification
data Notify = Notify deriving (Read, Show)

instance UrgencyHook Notify where
 urgencyHook Notify w = do
  name    <- getName w
  Just ws <- W.findTag w <+> gets windowset
  notify $ message ws (show name)

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
manage the =
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
  , [ isDialog, {-ws ~~? mfloat-}]        <>
    collage [c,t] (popup <> floaters)     ?| doCenterFloat
  , collage [c,t] annoyances              ?| s'' 2
  , [ isFullscreen, {-ws ~~? mfull-}]     <>
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
  s''@s'@s n = doShift $ (the workspaces !!)
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
activate :: ManageHook
activate = composeOne
  [ className ~? "Element" -?> doFocus
  , pure True -?> doAskUrgent
  ]
--}
--{- handleEventHook
events =
 -- when a focused, fullscreen window is closed, refocus last window
--     fadeWindowsEventHook
     refocusLastWhen
     (    FS.query
     <||> fmap not isFloating
     <||> return True
     )
 <+> blend dynamicPropertyChange properties
 <+> trayerAboveXmobarEventHook
 <+> Hacks.windowedFullscreenFixEventHook
 <+> uncurry swallowEventHook swallow
--}
--{- swallowHook
swallow = (className =? terminalc <&&> fmap not ( title ~~? "S:"), return True)
--}
--{- propertyHook
properties =
 [ ("WM_CLASS", composeOne
   [ className ~? "re.sonny.Junction" -?> doCenterFloat
   --className ~? "element" -?> doCenterFloat
   ])
 ]

--}
--{- fadeHook
fade = composeAll
 [    opaque
 ,    isUnfocused
 <&&> isFloating  --> transparency 0.05
 ,    FS.query    --> opaque
--    opaque
 ]
--}

--{- logHook
log the pipe =
 -- counterpart to handleEventHook for refocusLast
 refocusLastLogHook
 -- change opacity of unfocused windows, 1 is opaque, 0 transparent
-- <+> fadeWindowsLogHook mfadeHook
 -- for changing to/from the last focused workspace
 <+> workspaceHistoryHook
 -- pass pipe in, for status bar
 <+> bar the pipe
 -- handle mag-fullscreen events
 <+> FS.logHook
--}
--{- barHook
bar the pipe = let
 fc = the fg
 bc = the bg
 in do
 -- for copied windows, e.g media player
wsContainingCopies >>= \copies ->
 let hasExtras x | x `elem` copies = xc (fg 2) (bg 1) $ " + "
                       | otherwise = xc (fg 0) (bg 2) $ act x
     c = xmobarColor
     b = xmobarBorder

     act ws = xmobarAction ("xdotool key super+"<>show (i ws)) "12345" $ pad ws
     i = fromJust . flip M.lookup mWSIndices

 -- boilerplate + xmobar + scratchpads
 in dynamicLogWithPP . filterOutWsPP ["NSP"] $ xmobarPP
   { ppOutput = hPutStrLn pipe

   , ppSep             = " "
   -- mark urgent WS's
   , ppUrgent          = c (fg 2) (bg 2) . act
   , ppCurrent         = c (fg 1) (bg 0) . b "Bottom" (fg 0) 4 . act
   , ppHidden          = hasExtras
   , ppHiddenNoWindows = c (bg 3) (bg 1) . pad . take 2
   , ppTitle     = \x -> c (fg 4) (bg 1) . pad . shorten 40 $ if null x then "?" else x
   , ppTitleSanitize   = xmobarStrip

   -- other items
   , ppExtras = [windowCount]
   , ppOrder  = \(ws:lay:title:extra) -> [shorten 10 lay, ws] <> extra <> [title]
   , ppSort   = mkWsSort getWsCompare

   }
--}
--}

--{- layout
--{- type definitions
nameDisplay :: [Char] -> [Char] -> SWNConfig
--}
--{- global settings
-- theming for tabs
tabConfig the =
 def
 { fontName            = "xft:Mononoki Nerd Font:regular:pixelsize=16"
 , activeColor         = fg
 , activeBorderColor   = bg
 , activeTextColor     = bg

 , inactiveColor       = bg
 , inactiveBorderColor = bg
 , inactiveTextColor   = fg
 } where
 bg = the back
 fg = the fore
-- i --> inner x*, inner y*, outer x*, outer y*
lay name count space = id
-- windowArrange $
 . renamed [Replace name]
 . limitWindows (if count > 0 then count else 100)
 . hiddenWindows
 . (if space > 0 then smartSpacingWithEdge else spacing) space
 --fullscreen
--}
--{- layoutHook
layout the@settings =
  mods
   -- windowNavigation .
   -- subLayout [0] (tabs mBG mFG)
   $   dishes settings
-- ||| tabPlus settings
   ||| accordion
   ||| spiral
   ||| golden
   ||| tall1
   ||| tabs settings
   ||| tall2
 where
  bg = the back
  fg = the fore
  -- modifications for all
  mods = id
   . smartBorders
   . showWName' (nameDisplay settings)
   . fullscreen
   . avoidStruts
   --boringAuto . boringWindows .
     -- keep floating grouped above last focused tiled
   . trackFloating
   --mouseResize
--}
--{- selected layouts
--              lay name  # ' ' $ layout
--tabPlus the = lay "+tb" 0 2 $ layoutN 3 (relBox 0 0 0.5 1) (Just $ relBox 0 0 1 1) t
--                            $ layoutN 3 (relBox 0.5 0 1 1)  Nothing                t
--                            $ layoutAll (relBox 0 0.4 1 1)                         t
--                            where t = color the tabs
dishes  the = lay "dis" 6  0 $ magnifier $ MultiDishes 2 4 (3/7)
accordion   = lay "acc" 0  2 $ Accordion
spiral      = lay "spi" 8  2 $ LS.spiral (3/5)
golden      = lay "gld" 8  2 $ magnifier $ LS.spiral (3/5)
tall1       = lay "tal" 10 2 $ Tall 1 (3/100) (1/2)
tall2       = lay "tll" 20 3 $ Tall 2 (3/100) (1/2)
tabs    the = lay "tab" 50 0 $ tabbed shrinkText $ color the tabConfig
--}
--{- showWorkspaceTheme
nameDisplay the =
 def
 { swn_font    = "xft:Mononoki Nerd Font:regular:pixelsize=32"
 , swn_fade    = 0.5
 , swn_bgcolor = the back
 , swn_color   = the fore
 }
--}
--}
--{- xmonad
--{- type definitions
main :: IO ()
--}
--{- definitions
main = do
 pipe <- panel
 --{- dynamic attributes
 -- IO
 faves <- (apps<>) <+> parseIn [] [".faves"]
        $ map (second open . tuple . splitOn '\t') . grabLines '#'
 -- ((Box,Int),[String])
 (bp,bs,bgs) <- parseIn (bc',bc,backgrounds) [".cache/wal/wmbc-DISABLED", ".wmbc"]
          $ readColors
 (fp,fs,fgs) <- parseIn (fc',fc,foregrounds) [".cache/wal/wmfc-DISABLED", ".wmfc"]
          $ readColors
 --}
 -- choose colors randomly
 bg <- aBG bp
 fg <- aFG fp
 --{- settings
 let
  the@settings = ($ Settings
    { faves      = faves
    , workspaces = workspaces
    , tints      = (bg,fg)
    , colors     = (bs,fs)
    , colors'    = (bgs,fgs)
    , shades     = (bp,fp)
    })
 --}
 let
  mk = keys settings
  allKeys = (`addKeys` overrides `addKeys` mk)
  keyz = ("M-h", checkKeymap (allKeys $ ewmh def) mk) : mk
  urgentOnActivate = setEwmhActivateHook activate
  in xmonad
  --}
  --{- hooks
  -- manage docks
  . ewmh
  . Hacks.javaHack
  -- apply urgency hook
  . withUrgencyHook Notify
  -- apply urgency hook w/ borders
  . withUrgencyHookC BorderUrgencyHook { urgencyBorderColor = mFG } urgencyConfig { suppressWhen = Never }
 -- dynamicProjects mprojects
  . urgentOnActivate
  . ewmhFullscreen
  . docks
  $ def
   { manageHook      = manage
   , handleEventHook = events
   , logHook         = log the pipe
   , startupHook     = startup settings
   , layoutHook      = layout  settings
   --}
  --}
   --{- settings
   , workspaces         = V.workspaces
   , focusFollowsMouse  = False
   , clickJustFocuses   = True
   , modMask            = super
   , terminal           = V.terminal
   --}
   --{- colors
   , borderWidth        = V.border
   , normalBorderColor  = the back
   , focusedBorderColor = the fore
   --}
   } --}
   --{- apply keys
   `addKeys` overrides
   `addKeys` keyz
  --}

-- remove conflicts before adding
addKeys k = `removeKeysP` (map fst k) `additionalKeysP` k

{- TODOs
IfMax instead of layoutBuilder
X.L.Stoppable -- save CPU with bg processes! Use with caution.
--}
{- references
--}
