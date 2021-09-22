--xmonad #
{-# LANGUAGE LambdaCase #-}
{-# OPTIONS_GHC -Wno-missing-signatures -Wno-orphans #-}
{- LANGUAGE ViewPatterns #-} -- ?
{- LANGUAGE ParallelListComp #-} -- ?
{- LANGUAGE NoMonomorphismRestriction #-} -- ?
{- LANGUAGE NamedFieldPuns #-} -- ?
{- LANGUAGE FlexibleContexts #-} -- ?

-- import XMonad.Hooks.FadeWindows (isFloating) -- for later
import Control.Monad
import Data.Monoid
import XMonad.Actions.UpdatePointer
-- my xmonad config, see ../.vimrc for navigation
--{- imports
--{- global
import Custom.Grid
import Custom.Keys
import Custom.Prompts
import Custom.Scratch
import Custom.Vars
--}
--{- standards
import XMonad
import qualified XMonad.StackSet as W
import System.IO (hPutStrLn, Handle)
import Control.Monad
--}
--{- data
import Data.Monoid
import Data.List (isInfixOf)
import Data.Char (isSpace, toLower)
import qualified Data.Map as M
import Data.Maybe (fromJust)
--}
--{- actions
import XMonad.Actions.SpawnOn
--}
--{- hooks
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, pad, xmobarPP, xmobarColor, PP(..), shorten, xmobarStrip)
-- for some fullscreen events, also for xcomposite in obs.
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.ManageDocks -- (avoidStruts, docksEventHook, checkDock, manageDocks, ToggleStruts(..))
import XMonad.Hooks.ManageHelpers
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
import XMonad.Layout.Accordion
import XMonad.Layout.SubLayouts
--}
--{- effects
--{- testing
import XMonad.Layout.Magnifier -- of use
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
--}
--{- urgencyhook
import XMonad.Hooks.UrgencyHook
import XMonad.Util.NamedWindows
import XMonad.Util.Run
--}
--}
--{- autostart
--{- type definitions
mstartupHook :: X ()
--}
mstartupHook = do
 setDefaultCursor xC_left_ptr
 setWMName mwm
 -- note: (spawnpipe mbar) is used in main()
 mapM_ (\x -> spawnOnce $ x ++ " &") $ mlock ++ msession
 mapM_ (\x -> unspawn x <+> spawn ("sleep 1;" ++ x)) $ mtray (bg!1) : mrestart
 where
  mlock =
   [ "xset s " ++ show (60 * mtimeout)
   , "xss-lock " ++ mlocker
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
clickable ws = "<action=xdotool key super+"++show i++">"++ws++"</action>"
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
mlogHook :: Handle -> X ()
mbarHook :: Handle -> X ()
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
 let up = updatePointer (0.5, 0.5) (0, 0)
 in
 -- manage floating, and fullscreen
 -- change the stack as new windows arrive
 doF avoids
 -- <+> liftX up
 --{- composeOne
 <+> composeOne
  [ doCenterFloat >?| [ isDialog, currentWs ~~? mfloat ]
  , act doCenterFloat (>?|) [className, title]
    [ "picture"
    , "connection"
    , "volume", "pulseaudio", "alsa", "jack"
 -- , "firefox", "libreWolf", "tor Browser", "brave", "chrom", "qute"
    ] []
  , doFullFloat >?| [ isFullscreen, currentWs ~~? mfull ]
  , act doFullFloat (>?|) [className, title] ["steam"] []
  ] --}
 -- manage scratchpads, done after WS shifting, before, stack
 -- rearrangement, and before composeOne, monoids read backward
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
  , act (s 1) (>>|) [className] ["obs"] []
  , act (s 2) (>>|) [className] ["geanie"] []
  , act (s 3) (>>|) [className] ["qute", "librewolf", "brave", "chrom", "tor-", "torb"] []
  , act (s 4) (>>|) [className] ["krita", "gimp", "design"] []
  , act (s 5) (>>|) [className] ["discord", "thunderbird", "messeng" , "convers", "brave-browser"] ["irc", "chat"]

  , act (s' 1) (>>|) [className] ["tor-browser"] []
  , act (s' 2) (>>|) [className, title] [] ["multiMC"]
--  , act (s' 2) (>>|) [className, title] ["music", "video"] ["mpv"{-, "vlc"-}]
  , act (s' 3) (>>|) [className] ["xephyr", "virt"] []

  , act (s'' 1) (>>|) [className] ["steam", "lutris"] []
--  , act (doF ignore)  (>?|) [className, title] ["sharing indicator"] []
  ]) --}
 -- hook for spawnOn calls
 <+> manageSpawn
 --{- where
 where
  never = ( stringProperty "_" =? "_" )
  s n = doShift $ mregular!n
  s' n = doShift $ mfloats!n
  s'' n = doShift $ mfulls!n
  act fn compare values n0 n1 =
   fn `compare`
   concat
   [  [never]
   ++ [x ~? y  | y <- n0]
   ++ [x ~~? y | y <- n1]
      | x <- values ]
  or' a = foldr1 (<||>) a
  and' a = foldr1 (<&&>) a
  (>>|) a b = or' b --> a
  (>>&) a b = and' b --> a
  (>?|) a b = or' b -?> a
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
 -- let applications fullscreen themselves, only some do reliably
 XMonad.Hooks.EwmhDesktops.fullscreenEventHook
 -- handle new docks dynamically
 <+> docksEventHook
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
mlogHook pipe =
 -- counterpart to handleEventHook for refocusLast
 refocusLastLogHook
 -- change opacity of unfocused windows, 1 is opaque, 0 transparent
 <+> fadeInactiveLogHook 0.98
 -- for changing to/from the last focused workspace
 <+> workspaceHistoryHook
 -- pass pipe in, for status bar
 <+> mbarHook pipe
--}
--{- barHook
mbarHook pipe = do
 -- for copied windows, e.g media player
 copies <- wsContainingCopies
 let check x | x `elem` copies = fc (fg!3) (bg!2) $ " + "
                   | otherwise = fc (fg!1) (bg!3) $ (pad . clickable) x
 -- boilerplate + xmobar + scratchpads
 dynamicLogWithPP . namedScratchpadFilterOutWorkspacePP $ xmobarPP
   { ppOutput = \x -> hPutStrLn pipe x

   , ppSep             = " "
   -- mark urgent WS's
   , ppUrgent          = fc(fg!3) (bg!3) . pad . clickable
   -- current WS -- TODO add bottom/top border instead of bg color
   , ppCurrent         = {-xmobarBorder-} fc(bg!1) (fg!2) . pad . clickable
   , ppHidden          = check
   , ppHiddenNoWindows = fc(bg!4) (bg!2) . pad . \x -> take 2 x
   , ppTitle           = fc(fg!5) (bg!2) . pad . shorten 40
   , ppTitleSanitize   = xmobarStrip

   -- other items
   , ppExtras = [windowCount]
   , ppOrder  = \(ws:lay:title:extra) -> [lay, ws] <> extra <> [title] -- use w/ statusBar: [(xmobarRaw . (\w -> if null w then "untitled" else w title]
   , ppSort = mkWsSort getWsCompare

   }
  where fc = xmobarColor
--}
--{- layoutHook
mlayoutHook mBG mFG =
   mods
   -- windowNavigation .
   -- subLayout [0] (tabs mBG mFG)
 $ accordion
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
-- i --> inner x*, innex y*, outer x*, outer y*
mspacing i = spacingRaw True (Border (i) (i) (i*2) (i*2)) True (Border i i i i) True
nospace = spacingRaw False bnull False bnull False where bnull = Border 0 0 0 0
lay name count space layout =
-- windowArrange $
   renamed [Replace name]
 $ (if space > 0 then mspacing space else nospace)
 $ limitWindows count
 $ minimize
 $ layout
--}
--{- selected layouts
accordion =    lay "acc" 8  2 $ Accordion
spiral =       lay "spi" 8  2 $ LS.spiral (3/5)
spiral' =      lay "+sp" 8  2 $ magnifier (LS.spiral (3/5) )
tall1 =        lay "tl1" 10 2 $ Tall 1 (3/100) (1/2)
tall2 =        lay "tl2" 20 3 $ Tall 2 (3/100) (1/2)
tabs mBG mFG = lay "tab" 50 0
 $ tabbed shrinkText mtabConfig
 where --{-
  mtabConfig =
   def
   { fontName            = "xft:Mononoki Nerd Font:regular:pixelsize=16"
   , activeColor         = mFG
   , activeBorderColor   = mBG
   , activeTextColor     = mBG

   , inactiveColor       = mBG
   , inactiveBorderColor = mBG
   , inactiveTextColor   = mFG
   } --}
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
 fgc <- rand fg'
 bgc <- rand bg'
--et mBG = bg!2; mFG = fg!1 in
 let mBG = bgc;  mFG = fgc  in
  xmonad
  --}
  --{- hooks  {
  -- manage docks
  $ docks
  -- apply urgency hook
  $ withUrgencyHook LibNotifyUrgencyHook
  -- apply urgency hook w/ borders
  $ withUrgencyHookC BorderUrgencyHook { urgencyBorderColor = mFG } urgencyConfig { suppressWhen = Never }
--  $ dynamicProjects mprojects
  $ ewmh def
   { manageHook = mmanageHook
   , handleEventHook = mhandleEventHook
   , logHook = mlogHook pipe
   , startupHook = mstartupHook
   , layoutHook  = mlayoutHook mBG mFG
   --}
   --{- settings
   , workspaces         = mworkspaces
   , focusFollowsMouse  = False
   , clickJustFocuses   = True
   , modMask     = super
   , terminal    = mterminal
   --}
   --{- colors }
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
  where --{-
   keys =
    ("M-h", checkKeymap (ewmh def `additionalKeysP` mkeys) mkeys) : mkeys
  --}
  --}

{- references
{- -- this tricks vim, enabling syntax highlighting
-}
--}
