--xmonad #
{-# OPTIONS_GHC -Wno-missing-signatures -Wno-orphans #-}
{- LANGUAGE FlexibleContexts, LambdaCase, BlockArguments, ViewPatterns #-} -- ?
{- LANGUAGE ParallelListComp, NoMonomorphismRestriction, NamedFieldPuns #-} -- ?
{-# LANGUAGE NamedFieldPuns, RecordWildCards, LambdaCase, BlockArguments, TupleSections #-}
{-# LANGUAGE FlexibleContexts #-}

import XMonad.Hooks.FadeWindows
-- my xmonad config, see ../.vimrc for navigation
--{- imports
--{- global
import Custom.Grid
import Custom.Keys
import Custom.Prompts
import Custom.Scratch
import Custom.Vars hiding (workspaces, terminal, workspaces)
import qualified Custom.Vars as V
import qualified Modules.Fullscreen as FS
import Tweaks.EwmhDesktops
import Tweaks.WindowSwallowing
import Tweaks.Magnifier
--}
--{- standards
import XMonad hiding (workspaces, manage, keys)
import qualified XMonad as XM
import XMonad.Prelude
import Prelude hiding (log)
import qualified XMonad.StackSet as W
import System.IO (hPutStrLn, Handle)
import System.Directory
import Control.Monad
--}
--{- data
import Control.Monad
import Data.Monoid
import Data.List.Split (wordsBy, splitOn)
import Data.Bifunctor
import Data.List (isInfixOf)
import Data.Char (isSpace, toLower)
import qualified Data.Map as M
import Data.Maybe (fromJust)
--}
--{- actions
import XMonad.Actions.SpawnOn
import XMonad.Actions.UpdatePointer
import XMonad.Actions.TagWindows
--port XMonad.Actions.EasyMotion
--}
--{- hooks
import XMonad.Hooks.DynamicLog  --(dynamicLogWithPP, pad, xmobarPP, xmobarColor, xmobarBorder, PP(..), shorten, xmobarStrip, filterOutWsPP)
-- for some fullscreen events, also for xcomposite in obs.
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.ManageDocks -- (avoidStruts, docksEventHook, checkDock, manageDocks, ToggleStruts(..))
import XMonad.Hooks.ManageHelpers hiding ((~?))
import XMonad.Hooks.SetWMName
import XMonad.Hooks.WorkspaceHistory
import XMonad.Hooks.RefocusLast
import XMonad.Hooks.Place
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
import XMonad.Util.EZConfig
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
--port XMonad.Util.Run
--}
import XMonad.Actions.ShowText
--}
--{- autostart
startup (Z{..}) = do
-- setDefaultCursor xC_left_ptr
 FS.setTheme (tabConfig settings)
--setWMName mwm
 mapM_
  ( \x -> spawnOnce $ x <> " &" )
  $ mlock <> msession
 mapM_ id
--( \x -> unspawn x <+> spawn ("sleep 1;" ++ x) )
  $ tray (bg 0) : mrestart
 where
  mlock =
   [ "xset s " <> show (60 * timeout)
   , "xss-lock " <> locker
   ]
--}
--{- workspaces
--tagWS = first . (<>)
mWSIndices :: M.Map String Int
mWSIndices = M.fromList $ zip (map fst workspaces') [1..]

-- number of dynamic workspaces
projectSpace = 6
(workspaces', workflows) = (
 [ ("basic", [prompt, prompt]) -- 1
 , ("multi", [browse]        ) -- 2
 , ("full" , [open "Steam"]  ) -- 3
 ,    w "a",  w "b",   w "c"   -- 4,5,6
-- ("chat" , [spawn "chats"] ) -- 7
-- ("NSP"  , []              ) -- 8
 ]
 ,
-- TODO: implement workflows in some way (gridselect?)
 [ ("dev", [prompt, edit]         )
 , ("web", [browse]               )
 , ("2D" , s ["gimp","krita"]     )
 , ("vec", s ["gravit","inkscape"])
 , ("3D" , s ["blender"]          )
 ]
 ) where
 s = map open
 w = (,[])
--}
--{- hooks
--{- type definitions
manage   :: Z -> XMonad.Query (Data.Monoid.Endo WindowSet)
events   :: Z -> Event -> X All
log, bar :: Z -> Handle -> X ()
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
--Just ws <- W.findTag w <+> gets windowset
  Just ws <- fmap (W.findTag w) $ gets windowset
  notify $ message ws (show name)

--safeSpawn mnotify' $ mnotify'' <> [ws, show name]

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
manage (Z{..}) =
 let up = updatePointer (0.5, 0.5) (1, 1)
 in
 -- manage floating, and fullscreen
 retainFS
 -- manage scratchpads, done after WS shifting, before, stack
 -- rearrangement, and before composeOne - monoids read backward
 <+> namedScratchpadManageHook scratchpads
 -- supposed to reunite child windows from an application with the parent,
 -- isn't very reliable
 <+> transience'
 <+> composeOne [collage [c] (browsers<>gaming<>art) >| V.groupBy c]
 --{- basic
 <+> composeOne
  [ collage [c,t] ["xmonad_conky"]        ?| doLower <+> doIgnore
  , [ isDialog{-, ws ~~? mfloat-}]        <>
    collage [c,t] (popup <> floaters)     ?| doCenterFloat
  , collage [c,t] annoyances              ?| s 0
  , [ isFullscreen{-, ws ~~? mfull-}]     <>
    collage [c,t] gaming                  ?| FS.start
  ] --}
 --{- workspaces
 <+> composeAll( reverse
--[ checkDock --> doLower
  [
    collage [c  ] ["obs"]   >| s 0
--, collage [c  ] []        >| s 1
  , collage [c  ] browsers' >| s 2
  , collage [c  ] art       >| s 3
  , collage [c,t] chat      >| s 4

--, collage [c,t] []        >| s 0
--, collage [c,t] media     >| s 1
  , collage [c  ] virt      >| s 2

  , collage [c  ] gaming    >| s 0
--, collage [c,t] []        >| s 1
--, collage [c,t] []        >| s 2
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
--  s''@s'@s n = doShift $ (workspaces !!)
  s = doShift . (workspaces !!)
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
activate :: Z -> ManageHook
activate (Z{..}) = composeOne
  [ className ~? "Element" -?> doFocus
  , pure True -?> doAskUrgent
  ]
--}
--{- handleEventHook
events (Z{..}) =
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
-- <+> swallowEventHook
 <+> swallowHook
     (\c p -> hideWindow p)
     storeConfig
     (restoreDeleted
       (windows . insertIntoStack)
--       (\_ _ _ -> windows . insertIntoStack)
--       (\_ _ _ -> sendMessage . PopSpecificHiddenWindow)
--     supplantSwallower

       \oldStack oldFloating childWindow parent -> do
       supplantSwallower oldStack oldFloating childWindow parent
       -- X.L.hidden ignores irrelevant pop requests
       hideWindow parent
       sendMessage $ PopSpecificHiddenWindow parent
     )
     -- my check
     swallow (return True)
 <+> handleTimerEvent
--}
--{- swallowHook
swallow = className =? caps terminalc
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
log settings pipe =
 -- counterpart to handleEventHook for refocusLast
 refocusLastLogHook
 -- change opacity of unfocused windows, 1 is opaque, 0 transparent
-- <+> fadeWindowsLogHook mfadeHook
 -- for changing to/from the last focused workspace
 <+> workspaceHistoryHook
 -- pass pipe in, for status bar
 <+> bar settings pipe
 -- handle mag-fullscreen events
 <+> FS.logHook
--}
--{- barHook
bar (Z{..}) pipe = do
 -- for copied windows, e.g media player
 wsContainingCopies >>= \copies ->
  let hasExtras x | x `elem` copies = c (fg 2) (bg 1) $ " + "
                        | otherwise = c (fg 0) (bg 2) $ act x
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
    , ppOrder  = \(ws:lay:title:extra) -> [shorten 30 lay, ws] <> extra <> [title]
    , ppSort   = mkWsSort getWsCompare
 
    }
--}
--}

--{- layout
--{- type definitions
nameDisplay :: Z -> SWNConfig
--}
--{- global settings
-- theming for tabs
tabConfig (Z{..}) = def
 { fontName            = font'
 , activeColor         = fore
 , activeBorderColor   = back
 , activeTextColor     = back

 , inactiveColor       = back
 , inactiveBorderColor = back
 , inactiveTextColor   = fore
 }
-- i --> inner x*, inner y*, outer x*, outer y*
lay name count space = id
-- windowArrange $
 . renamed [Replace name]
 . limitWindows (if count > 0 then count else 100)
 . (if space > 0 then smartSpacingWithEdge else spacing) space
 --fullscreen
--}
--{- layoutHook
layout (Z{..}) = id
   . renamed [KeepWordsRight 1]
   . showWName' (nameDisplay settings)
   . hiddenWindows
   . trackFloating
   . fullscreen
   . avoidStruts
   . smartBorders
     -- keep floating grouped above last focused tiled
   $   dishes
   ||| accordion
   ||| spiral
   ||| golden
   ||| tall1
   ||| tabs settings
   ||| tall2
--}
--{- selected layouts
--              lay name  # ' ' $ layout
--tabPlus = lay "+tb" 0 2 $ layoutN 3 (relBox 0 0 0.5 1) (Just $ relBox 0 0 1 1) t
--                        $ layoutN 3 (relBox 0.5 0 1 1)  Nothing                t
--                        $ layoutAll (relBox 0 0.4 1 1)                         t
--                        where t = colored tabs
dishes        = lay "dis" 6  0 $ magnifier $ MultiDishes 2 4 (3/7)
accordion     = lay "acc" 0  2 $ Accordion
spiral        = lay "spi" 8  2 $ LS.spiral (3/5)
golden        = lay "gld" 8  2 $ magnifier $ LS.spiral (3/5)
tall1         = lay "tal" 10 2 $ Tall 1 (3/100) (1/2)
tall2         = lay "tll" 20 3 $ Tall 2 (3/100) (1/2)
tabs settings = lay "tab" 50 0 $ tabbed shrinkText $ tabConfig settings
--}
--{- showWorkspaceTheme
nameDisplay (Z{..}) =
 def
 { swn_font    = "xft:Mononoki Nerd Font:regular:pixelsize=32"
 , swn_fade    = 0.5
 , swn_bgcolor = back
 , swn_color   = fore
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
 mfaves <- parseIn [         ] [".faves"] $ map (second open . tuple . splitOn "\t") . grabLine '#'
 bgs    <- parseIn backgrounds [".cache/wal/wmbc-DISABLED", ".wmbc"] $ readColors
 fgs    <- parseIn foregrounds [".cache/wal/wmfc-DISABLED", ".wmfc"] $ readColors
 let
   faves = map (second $ ($"")) $ apps <> mfaves
   -- colors
   bc = ofList     bgs
   fc = ofList     fgs
   -- shades
   bp = prioritize bgs
   fp = prioritize fgs
 --}
 -- choose colors randomly
 back' <- aXG bp
 fore' <- aXG fp
 --{- settings
 let
  s@(Z{..}) = Z
   { faves      = faves
   , workspaces = map fst workspaces'
   , tints      = (back' ,fore')
   , colors     = (bc   ,fc  )
   , colors'    = (bgs  ,fgs )
   , shades     = (bp   ,fp  )
   -- expanded
   , back = back', fore = fore'
   , bg         = fst bc
   , fg         = fst fc
   , bgs , fgs
   , bg'        = fst bp
   , fg'        = fst fp
   , settings   = s
   }
 --}
  mk = keys settings
  allKeys c = c `addKeys` overrides `addKeys` mk
  keyz = ("M-h", checkKeymap (allKeys $ ewmh def) mk) : mk
  urgentOnActivate = setEwmhActivateHook (activate settings)
  in xmonad
  --}
  --{- hooks
  -- manage docks
  . ewmh
  . Hacks.javaHack
  -- apply urgency hook
  . withUrgencyHook Notify
  -- apply urgency hook w/ borders
  . withUrgencyHookC BorderUrgencyHook { urgencyBorderColor = fore } def { suppressWhen = Never }
 -- dynamicProjects mprojects
  . urgentOnActivate
  . ewmhFullscreen' FS.on FS.off
  . docks
  $ def
   { manageHook      = manage  settings
   , handleEventHook = events  settings
   , logHook         = log     settings pipe
   , startupHook     = startup settings
   , layoutHook      = layout  settings
   --}
  --}
   --{- settings
   , XM.workspaces      = workspaces
   , focusFollowsMouse  = False
   , clickJustFocuses   = True
   , modMask            = super
   , terminal           = V.terminal
   --}
   --{- colors
   , borderWidth        = V.border
   , normalBorderColor  = back
   , focusedBorderColor = fore
   --}
   } --}
   --{- apply keys
   `addKeys` overrides
   `addKeys` keyz
   `addMouse` mmouseBindings
  --}

-- remove conflicts before adding
addKeys  c k = c `removeKeysP` (map fst k) `additionalKeysP` k
addMouse c k = c `removeMouseBindings` (map fst k) `additionalMouseBindings` k

{- TODOs
IfMax instead of layoutBuilder
X.L.Stoppable -- save CPU with bg processes! Use with caution.
--}
{- references
--}
