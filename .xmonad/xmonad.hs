--xmonad #
{-# OPTIONS_GHC -Wno-missing-signatures -Wno-orphans #-}
{-# LANGUAGE FlexibleContexts #-} -- for L.Hidden
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE BlockArguments #-}

{- LANGUAGE ViewPatterns #-} -- ?
{- LANGUAGE ParallelListComp #-} -- ?
{- LANGUAGE NoMonomorphismRestriction #-} -- ?
{- LANGUAGE NamedFieldPuns #-} -- ?

import XMonad.Hooks.DynamicProperty
import XMonad.Util.WindowProperties
import qualified XMonad.Util.ExtensibleState as XS
-- import XMonad.Hooks.FadeWindows (isFloating) -- for later
-- my xmonad config, see ../.vimrc for navigation
--{- imports
--{- global
import Custom.Grid
import Custom.Keys
import Custom.Prompts
import Custom.Scratch
import Custom.Vars
import Custom.Fullscreen
--}
--{- standards
import XMonad
import XMonad.Prelude
import qualified XMonad.StackSet as W
import System.IO (hPutStrLn, Handle)
import System.Directory
import Control.Monad
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
import XMonad.Util.EZConfig (additionalKeysP, removeKeysP, checkKeymap)
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run (runProcessWithInput, safeSpawn, spawnPipe)
import XMonad.Util.SpawnOnce
import XMonad.Util.Cursor
import XMonad.Util.WorkspaceCompare
import XMonad.Util.Hacks as Hacks
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
 setFSTheme $ mtabConfig mBG mFG
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
act :: X () -> Functor -> [managehook-thing] -> [[Char]] -> [[Char]] -> ManageHook
act action joining_operator [identifier] [tailed] [exact], eg:
 act (shift 1) (>>|) [className] ["abc"] ["123"] = (never, className ~? "abc" <||> className ~~? "123") --> shift 1
 act (shift 1) (>>&) [className, title] ["urmom"] [] = (never, className ~? "urmom" <&&> title ~? "title") --> shift 1
 act (shift 1) (>>|) [className, title] [] [] = (never) --> shift 1
--}
mmanageHook =
 let up = updatePointer (0.5, 0.5) (1, 1)
 in
 -- manage floating, and fullscreen
 -- change the stack as new windows arrive
 doF avoids
 -- <+> liftX up
 --{- composeOne
 <+> composeOne
  [ act (doLower <+> doIgnore) (>?|) [className, title] ["xmonad_conky"] []
--  , act (doCenterFloat) (>?|) [className, title] ["junction", "re.sonny.Junction"] []
  , doCenterFloat >?| [ isDialog, currentWs ~~? mfloat ]
  , act doCenterFloat (>?|) [className, title]
    [ "picture"
    , "connection"
    , "volume", "pulseaudio", "alsa", "jack", "pipewire", "easyeffects"
--    , "junction"
--    , "re.sonny.Junction"
    ] []
  , groupBy className $ browsers <> ["steam", "dolphin"]
  , act (s'' 2) (>?|) [className, title] ["crash report"] []
  , doFullFloat >?| [ isFullscreen ]
  , act doFullFloat (>?|) [className, title] ["steam"] []
  ] --}
 -- manage scratchpads, done after WS shifting, before, stack
 -- rearrangement, and before composeOne - monoids read backward
 <+> namedScratchpadManageHook mscratch
 -- supposed to reunite child windows from an application with the parent,
 -- isn't very reliable
 <+> transience'
 -- Default WS for programs
 --{- composeAll
 <+> composeAll( reverse
  -- don't overtake the master window, helps keep focus
--[ checkDock --> doLower
  [ act doCenterFloat (>>|) [className, title]
    [ "pop-up", "overlay", "toolkit", "tool"
    , "dialog", "message", "notif", "zenity"
    , "file", "open", "inspect"
    , "flameshot", "xzoom"
    ] ["man"]
--  , className =? "Alacritty" -?> doCenterFloat
--, (className =? "Alacritty") --> shiftToSame' (fmap Just className)
  , act (s 1) (>>|) [className] ["obs"] []
--  , act (s 2) (>>|) [className] [] []
  , act (s 3) (>>|) [className] browsers' []
  , act (s 4) (>>|) [className] ["krita", "gimp", "design"] []
  , act (s 5) (>>|) [className, title] ["thunderbird", "messeng" , "convers"] ["irc", "chat", "discord", "brave", "element"]

--  , act (s' 1) (>>|) [className] [] []
  , act (s' 2) (>>|) [className, title] [] ["multiMC"]
--  , act (s' 2) (>>|) [className, title] ["music", "video"] ["mpv"{-, "vlc"-}]
  , act (s' 3) (>>|) [className] ["xephyr", "virt"] []

  , act (s'' 1) (>>|) [className] ["steam", "lutris"] []
  , act (s 1 <+> doLower <+> doIgnore)  (>>|) [className, title] ["sharing indicator"] []
  ]) --}
 -- hook for spawnOn calls
 <+> manageSpawn
 --{- where
 where
  isNotOn t = ask >>= \w -> pure (maybe True (const False) (W.findTag w t))
  groupBy fn names =
   (or' $ fmap (\x -> fn ~? x) names)
   --> shiftToSame (fmap Just fn)
   -- (fmap Just ( (isNotOn "NSP") -?> className ))
  browsers' =
   [ "firefox", "libreWolf"
   , "tor Browser", "tor-", "torbrowser"
   , "qute"
   ]
  browsers = browsers' <> [ "brave", "chrom" ]
  never = stringProperty "_" =? "_"
  s n = doShift $ mregular!n
  s' n = doShift $ mfloats!n
  s'' n = doShift $ mfulls!n
  act fn compare values n0 n1 =
   fn `compare`
   concat
   [  []
   <> [x ~? y  | y <- n0]
   <> [x ~~? y | y <- n1]
      | x <- values ]
  or' a = foldr1 (<||>) a
  and' a = foldr1 (<&&>) a
  (>>|) a b = or'  b --> a
  (>>&) a b = and' b --> a
  (>?|) a b = or'  b -?> a
  (>?&) a b = and' b -?> a
  -- see above, https://github.com/TheMC47/dotfiles/blob/master/.xmonad/src/Config.hs
  --{- ignore
  -- n: new, u: up, upstack, c: current, ds: downstack
  ignore = \ws ->
   let s = flip W.Stack
   in flip W.modify' ws $ \c -> case c of
   -- if none above
   W.Stack n [] (c : ds) -> s [] c ds
   -- if none below
   W.Stack n (u : us) [] -> s us u []
   -- otherwise, default behaviour
   _ -> c
  --}
  --{- avoids
  -- n: new, u: up, c: current, ds: downstack
  avoids = \ws ->
   let floating = W.floating ws; s = flip W.Stack
   -- ^ s: [top..above] focus [below..bottom]
   in flip W.modify' ws $ \c -> case c of
   --{- if master
   W.Stack n [] (c : ds) ->
    -- new: tiled -> avoid (commented)
    -- new: tiled -> focus
    if [n] `iff` floating == []
--  ultra aviodance mode
--  then s [] c $ ds <> [n]
    then s [] n $ c:ds
    -- else -> focus
    else s [] n $ c:ds
   --}
   --{- if not master, and at least one other window
   W.Stack n u (c : ds) ->
    -- current: float, new: tile -> avoid
    if [n] `iff`  floating == []
    && [c] `nott` floating == []
    then s u c $ n:ds
    -- new & current: float -> focus
    else
     if [n] `nott` floating == []
     && [c] `nott` floating == []
     then s u n $ c:ds
     -- else -> above
     else s (c:u) n ds
   --}
   -- when empty, default behaviour
   _ -> c
  --}

  -- pulled from latest manageHelpers, it hasn't been pushed to the nix version
  doLower :: ManageHook
  doLower = ask >>= \w -> liftX $ withDisplay $ \dpy -> io (lowerWindow dpy w) *> mempty
--}
--}
--{- activateHook
-- focus element, let all others die
mActivateHook :: ManageHook
mActivateHook = composeOne
  [ className ~~? "Element" -?> doFocus
  , pure True -?> doAskUrgent
  ]
--}
--{- handleEventHook
{- fconf
floatConfReqHook :: MaybeManageHook -> Event -> X All
floatConfReqHook mh ConfigureRequestEvent{ev_window = w} = do
   runQuery ((<$>) join $ (-?>) isFloat mh) w >>= \case
        Nothing -> mempty
        Just e -> windows (appEndo $ Endo (\_ -> e)) >> pure (All False)
floatConfReqHook _ _ = mempty


mfcfrhook :: MaybeManageHook
mfcfrhook = composeAll
    [ appName =? "alarm-clock-applet" -?> doFloat -- prevent alarm-clock-applet from moving its floats to remebered location
    , className =? "Steam" -?> doFloat -- prevent Steam from moving its floats to primary screen
    , className =? "Discord" -?> doFloat
    ]
--}


mhandleEventHook =
 -- on closing of focused float, if new focus is tiled, refocus last tiled
 -- viewed before focusing a float
 --  refocusLastWhen isFloat
     (dynamicPropertyChange "WM_NAME" ( className =? "re.sonny.Junction" --> doCenterFloat ))
 <+> trayerAboveXmobarEventHook
 <+> Hacks.windowedFullscreenFixEventHook
 -- <+> floatConfReqHook mfcfrhook
 -- <+> putBelow "xmobar" (=?) "trayer"
 {- where
 where
  putBelow :: String -> (Query String -> a1 -> Query Bool) -> String -> Event -> X All
  putBelow below compare above ConfigureEvent{ev_window = w, ev_above = a} | a == none = do
   -- when trayer is lowered to the bottom of stack, put all xmobars that
   -- are above it below
   whenX (runQuery (className `compare` above) w) $ do
    withDisplay $ \dpy -> do
     rootw <- asks theRoot
     (_, _, ws) <- io $ queryTree dpy rootw
     let aboveWs = dropWhile (w /=) ws
     belowWs <- filterM (runQuery (appName `compare` below)) aboveWs
     mapM_ (io . lowerWindow dpy) belowWs
   mempty
  putBelow _ _ _ _ = mempty
--}

--}
--{- logHook
mlogHook pipe bcs fcs =
 -- counterpart to handleEventHook for refocusLast
 refocusLastLogHook
 -- change opacity of unfocused windows, 1 is opaque, 0 transparent
 <+> fadeInactiveLogHook 0.98
 -- for changing to/from the last focused workspace
 <+> workspaceHistoryHook
 -- pass pipe in, for status bar
 <+> mbarHook pipe fcs bcs
 -- handle mag-fullscreen events
 <+> fsHook
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
     -- withUrgencyHookC BorderUrgencyHook { urgencyBorderColor = mFG } urgencyConfig { suppressWhen = Never } .
     showWName' (mshowWNameTheme mBG mFG) .
     avoidStruts .
--   minimize .
     boringAuto .
     -- boringWindows .
     -- keep floating grouped above last focused tiled
     trackFloating .
     mouseResize
--}
--}

--{- layout
--{- type definitions
mshowWNameTheme :: [Char] -> [Char] -> SWNConfig
--}
--{- global settings
-- i --> inner x*, inner y*, outer x*, outer y*
mspacing i = smartSpacingWithEdge i
nospace    = spacing 0
--mspacing i = spacingRaw True (Border (i) (i) (i*2) (i*2)) True (Border i i i i) True
--nospace = spacingRaw False bnull False bnull False where bnull = Border 0 0 0 0
lay name count space layout =
-- windowArrange $
   renamed [Replace name]
 $ (if space > 0 then mspacing space else nospace)
 $ limitWindows (if count > 0 then count else 100)
-- minimize
 $ hiddenWindows
 $ fullscreen
 $ layout
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

 wmbc <- getColors "/.cache/wal/wmbc-DISABLED"
     <|> getColors "/.wmbc"
     <|> (pure $ stringify bg)
 wmfc <- getColors "/.cache/wal/wmfc-DISABLED"
     <|> getColors "/.wmfc"
     <|> (pure $ stringify fg)
 let fcs = map hex6 $ grabColors '\n' ' ' wmfc
 let bcs = map hex6 $ grabColors '\n' ' ' wmbc
 fc   <- rand $ prioritize fcs
 bc   <- rand $ prioritize bcs

 let
  mFG = fc
  mBG = bc
  mk = mkeys mworkspaces bcs fcs
  keys = ("M-h", checkKeymap (ewmh def `additionalKeysP` mk) mk) : mk
  in
 --}
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
   `removeKeysP` [ a | (a,b) <- moverrides]
   -- add overrides
   `additionalKeysP` moverrides
   -- remove conflicts with your config
   `removeKeysP` [ a | (a,b) <- keys]
   -- apply your config
   `additionalKeysP` keys
  --}

tryReadFile :: FilePath -> IO String
tryReadFile f = do
 guard =<< doesFileExist f
 readFile f

{- TODOs
look into: X.L.Hidden instead of minimize
IfMax instead of layoutBuilder
StateFull instead of janky floating done now
X.L.Stoppable -- save CPU with bg processes! Use with caution.
--}
{- references
--}
