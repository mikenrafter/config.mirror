{- language CPP -}
{-# LANGUAGE LambdaCase, BlockArguments, TupleSections, ParallelListComp, RecordWildCards #-}
module Custom.Keys where
--{- imports
--{- globals
import Custom.Grid
import Custom.Prompts as Prompt
import Custom.Scratch
import Custom.Vars
import Custom.Misc
import qualified Custom.Fullscreen as FS
import Utility.Map
--}
--{- standards
import XMonad hiding (workspaces)
import qualified XMonad as XM
import System.Exit (exitSuccess)
import qualified XMonad.Util.PureX as P
import qualified XMonad.Util.Stack as U
import qualified XMonad.StackSet as W
import qualified XMonad.Util.ExtensibleState as XS
--}
--{- actions
import XMonad.Actions.UpdatePointer

import XMonad.Actions.DynamicWorkspaces
import XMonad.Actions.DynamicWorkspaceOrder (getSortByOrder)

import XMonad.Actions.DynamicProjects
import XMonad.Actions.SpawnOn
import XMonad.Actions.FloatSnap
import XMonad.Actions.CopyWindow (kill1, killAllOtherCopies, copyToAll)
import XMonad.Actions.CycleWS (moveTo, shiftTo, WSType(..), nextScreen, prevScreen, nextWS, prevWS, toggleWS')
import XMonad.Actions.GridSelect (goToSelected, bringSelected)
import XMonad.Actions.RotSlaves (rotAllDown, rotAllUp)
import XMonad.Actions.WithAll
-- import XMonad.Actions.Sink (sink)
import qualified XMonad.Actions.Search as S
import XMonad.Actions.Minimize
import XMonad.Actions.TagWindows
import XMonad.Actions.EasyMotion (selectWindow)
--}
--{- layouts
import XMonad.Layout.LimitWindows (limitWindows)
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS))
import XMonad.Layout.ResizableTile
import XMonad.Layout.WindowArranger (windowArrange, WindowArrangerMsg(..))
import qualified XMonad.Layout.MultiToggle as MT (Toggle(..))
import XMonad.Layout.BoringWindows as B
import XMonad.Layout.SubLayouts
import XMonad.Layout.WindowNavigation
import XMonad.Layout.Spacing
import XMonad.Layout.Hidden
--}
--{- prompt
import XMonad.Prompt
import XMonad.Prompt.Shell hiding (prompt)
import XMonad.Prompt.RunOrRaise
--}
--{- utils
import XMonad.Util.NamedScratchpad
import XMonad.Util.SpawnOnce
--}
--{- misc
import XMonad.Hooks.ManageDocks (ToggleStruts(..), SetStruts(..))
import Data.List (isInfixOf)
import qualified Data.Map as M
import Data.Maybe (isJust, fromMaybe)
import Data.Monoid (Ap(..))
import Data.Bifunctor
--}
--}
--{- overrides
overrides :: [(String, X ())]
overrides =
 leader . map (second $ notify . message "usage") $
 [ ("S-/",        def)
 , ("S-<Return>", def)
 , ("p",          def)
 , ("S-p",        off)
 , ("S-c",        "M-backspace")
 -- q & S-q excluded as a safety precaution
 , ("<Space>",    def)
 , ("S-<Space>",  off)
 , ("n",          off)
 , ("<Tab>",      def)
 , ("S-<Tab>",    off)
 , ("j",          "M-r")
 , ("k",          "M-a")
 , ("m",          def)
 , ("<Return>",   def)
 , ("S-j",        "M-S-r")
 , ("S-k",        "M-S-a")
 , ("h",          def)
 , ("l",          off)
 , ("t",          "M-down")
 , (",",          off)
 , (".",          off)
 ]
 <> dupe (list  o'n ) off
 <> dope (list  o'n ) off
 <> dupe (list "wer") off
 <> dope (list "wer") off
 where
  dupe list msg = map (,msg) list
  list = map \x -> [x]
  dope = dupe . map (ms<>)
  o'n = ['1'..'9']
  off = "disabled"
  def = "???"
--}
--{- my keys
keys :: Settings -> [(String, X ())]
keys (Z{..}) =
 -- logHook.updatePointer causes unwanted triggers --> keepUp :: manual
 concat [[]
--{- multimedia
--{- play/pause/seek
 ,[("<XF86AudioPrev>"  , player    "previous")
 , ("<XF86AudioNext>"  , player    "next"    )
 , ("S-<XF86AudioPrev>", player "-a previous")
 , ("S-<XF86AudioNext>", player "-a next"    )
 ]
 , dupe             ["<XF86AudioPlay>", "<XF86AudioPause>", "<Pause>"]  (player    "play-pause")
 , dupe (map (ms<>) ["<XF86AudioPlay>", "<XF86AudioPause>", "<Pause>"]) (player "-a play-pause")
--}
--{- volume up/down/mute
 ,[("<XF86AudioLowerVolume>"  , quieter  maxStep)
 , ("<XF86AudioRaiseVolume>"  , louder   maxStep)
 , ("<XF86AudioMute>"         , toggleV         )
 , ("S-<XF86AudioLowerVolume>", quieter' minStep)
 , ("S-<XF86AudioRaiseVolume>", louder'  minStep)
 ]
--}
--{- brightness up/down
 , dupe ["<XF86MonBrightnessUp>"    ,"M--"]   (brighter maxStep)
 , dupe ["<XF86MonBrightnessDown>"  ,"M-="]   (dimmer   maxStep)
 , dupe ["S-<XF86MonBrightnessUp>"  ,"M-S--"] (brighter maxStep)
 , dupe ["S-<XF86MonBrightnessDown>","M-S-="] (dimmer   minStep)
--}
--{- screenshots
 ,[(  "<Print>",   full)
 , ("M-<Print>", screen)
 , ("S-<Print>",    box)
 ]
--}
--{- misc
 ,[("M-M1-<Space>", spawn "kbd")
 , ("M-."         , notifs)
 ]
--}
--}
 , leader $ keepUp $ concat [[]
 --{- static
 , [
--{- session management
   ("q"  , notify (message "xmonad" "restarting")  <+> spawn "xmonad --restart")
 , ("C-q", io exitSuccess)
 , ("S-q", io exitSuccess)
 , ("l"  , lock)
 -- TODO: make cleaner
 --("0"  , mapM_ (\x -> unspawn x <+> spawn ("sleep 1;" <> x)) $ tray (bg 0) : mrestart)  -- relaunch startup things
 , ("0"  , mapM_ id $ (tray (bg 0)) : mrestart)
--}
--{- general
 , ("<Return>"     , prompt "")
 , ("S-<Return>"   , prompt "")

 , ("<Backspace>"  , kill1)
 , ("S-<Backspace>", killAll)

 , ("`"            , windows copyToAll)
 , ("<Escape>"     , killAllOtherCopies)
--}
--{- window navigation
--  NOTE - dynamic keys, dynamically added based on values in Vars.hs
 -- , ("C-a", rotAllUp)                -- Rotate all up
 -- , ("C-r", rotAllDown)              -- Rotate all down
 
 , ("z"  , withFocused hideWindow)
 , ("S-z", popNewestHiddenWindow)
--}
--{- layouts
 , ("S-<Tab>", sendMessage FirstLayout)
 , ("<Tab>"  , sendMessage NextLayout)
 , ("S-<D>"  , FS.withTag  \tg -> withTaggedGlobal tg FS.off <+> sinkAll) -- sink all windows
 , ("<D>"    , withFocused \w  -> FS.off w >> windows (W.sink w))         -- sink current window
 , ("<U>"    , withFocused  FS.toggle)                                    -- fullscreen current window
--}
--{- workspaces
--  NOTE - dynamic keys, dynamically added based on values in Vars.hs
 , ("<Space>", toggleWS' ["NSP"])
-- TODO: setup projects properly
-- ("C-S-M1-s", renameWorkspaceByName "ay")
-- ("M1-C-S-<Return>", activateProject currentProject)
--}
{- sublayouts
 sublayouts options, tabbed sublayouts causes screen artifacts in my attempts.
 , ("u", sendMessage $ pullGroup U)  -- i j k l =  US, u n e i = US(COLEMAK)
 , ("n", sendMessage $ pullGroup L)
 , ("e", sendMessage $ pullGroup D)
 , ("i", sendMessage $ pullGroup R)

 , ("C-<D>", withFocused (sendMessage . MergeAll))
 , ("C-<U>", withFocused (sendMessage . UnMerge))

 , ("C-a", onGroup W.focusUp')
 , ("C-r", onGroup W.focusDown')

 , ("f <L>", withFocused $ \w -> W.float w $ W.RationalRect 0.1 0.1 0.5 1.0)
 , ("f <L>", windows $ \w -> W.float w $ W.RationalRect 0.1 0.1 0.5 1.0)
--}
 --{- gridselects
 , ("i"      , bare $ nest settings $ grids settings)
 , ("o"      , bare $ nest settings $ map (second item) faves)
 --}
 ] --}
--{- dynamic keybinds
 --{- scratchpads
 , hold mm "p" [(k, allNamedScratchpadAction scratchpads k )    |  k    <- scratchKeys   ]  -- scratchpads
 --}
 --{- prompts
 , hold mm "s" $ map (second ($ Prompt.config settings)) engineMap -- search prompts
 , subfix mm   $ map (second ($ Prompt.config settings)) promptMap -- other prompts
 --}
 --{- navigation
 --{- window movement
 , bind ""     windowKeys [fUp,fDown]
 , bind ms     windowKeys [windows W.swapUp, windows W.swapDown]
 ,[("r", selectWindow (emConfig settings) >>= (`whenJust` windows . W.focusWindow))]
 --}
 --{- workspace movement
 , bound $ map (boundSuffix (workspaceKeys!!0))
  [ (["M1-C-","C-S-"], aPrev  )                                   -- shift all prev
  , ([ma,ms], safeShift Prev  )                                   -- shift prev
  , ([mc],              prevWS)                                   -- prev
  , ([""],    safeMove  Prev  )                                   -- prev active
  ]
 , bound $ map (boundSuffix (workspaceKeys!!1))
  [ (["M1-C-","C-S-"], aNext  )                                   -- shift all Next
  , ([ma,ms], safeShift Next  )                                   -- shift Next
  , ([mc],              nextWS)                                   -- Next
  , ([""],    safeMove  Next  )                                   -- Next active
  ]

 , [ ( concat [m, show k], windows $ f i )
  | (i, k) <- zip (XM.workspaces $ def {XM.workspaces=workspaces}) [1..9]
  , (f, m) <- [(W.view, ""), (W.shift, "S-")]
  ]

 -- TODO, explain this gazelle
 , [ ( concat ["C-", show k] , mapM_ (flip withNthWorkspace i) [W.shift, W.view] )
  | (k, i) <- zip [0..9] $ scon [0..9] ]
 , [ ( concat ["C-S-", show k] , foldl (<+>) wreverse (take 10 $ repeat $ withNthWorkspace W.shift i) <+> withNthWorkspace W.view i)
  | (k, i) <- zip [0..9] $ scon [0..9] ]
 --}
 --{- monitor movement
 , [ ( concat ["M1-", m, [k]], screenWorkspace sc >>= flip whenJust (windows . f) )
  | (k, sc) <- zip "rst" [2,1,0]
  , (f, m) <- [(W.view, ""), (W.shift, "S-"), (W.greedyView, "C-S-")]
  ]
 --}
 --}
 --{- floatKeys
 , hold mm "f" $ bound $ [(k, withFocused $ windows . \w -> W.float w r)  | (k,r) <- moldMap]
 --}
 --}
 ]
 ]
 where --{-
  player = open "playerctl"
  -- TODO: execute raw stack actions, instead of this mess
  allSafe fwd bak = withAll (const $ safeShift fwd <+> safeMove bak) <+> safeMove fwd <+> wreverse <+> up -- leave `up` here, other up happens before
  aNext = allSafe Next Prev
  aPrev = allSafe Prev Next
  fullFloat :: Window -> WindowSet -> WindowSet
  fullFloat = flip W.float $ W.RationalRect 0 0 1 1
  up = updatePointer (0.5, 0.5) (0.75, 0.75)
  keepUp = map $ second (*> up)

  wrev2    =const    revWS
  wreverse = windows revWS
  revWS = W.modify' \(W.Stack f u d) ->
   -- completely reverse stack (kinda)
   W.Stack (last d) [] $ reverse (init d) <> u <> [f]
--{- experiments
  -- complex functions to replace *.focusUp/down
  -- adds support for tab layout to B.focusUp
  -- adds support for floating window visibility whilst switching (broken ATM)
  fUp =
   windows W.focusUp
   --B.focusUp
   --ifLay' "tab" (windows W.focusUp) B.focusUp
   -- <+> ifFloat W.shiftMaster)
   -- <+> up
  fDown =
   windows W.focusDown
   --B.focusDown
   --ifLay' "tab" (windows W.focusDown) B.focusDown
   -- <+> up
   -- <+> ifFloat' (mapM_ ifFloat [W.swapMaster, W.swapUp, W.focusMaster]) B.focusDown
   -- <+> ifFloat' (ifFloat (W.swapUp <+> W.focusMaster)) B.focusDown
   --}
--}
{- mouse bindings
mmouseBindings :: XConfig Layout -> M.Map (ButtonMask, Button) (Window -> X ())
mmouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList $
    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modMask, button1), (\w -> focus w <+> mouseMoveWindow w))
    -- mod-button2, Raise the window to the top of the stack
    , ((modMask, button2), (\w -> focus w <+> windows W.swapMaster))
    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modMask, button3), (\w -> focus w <+> Flex.mouseResizeWindow w))
    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]
mmouses (XConfig {XMonad.modMask = modMask}) = M.fromList
    -- mod-button1 %! Set the window to floating mode and move by dragging
    [ ((modMask, button1), \w -> focus w <+> mouseMoveWindow w
                                          <+> windows W.shiftMaster)
    -- mod-button2 %! Raise the window to the top of the stack
    , ((modMask, button2), windows . (W.shiftMaster .) . W.focusWindow)
    -- mod-button3 %! Set the window to floating mode and resize by dragging
    , ((modMask, button3), \w -> focus w <+> mouseResizeWindow w
                                         <+> windows W.shiftMaster
                                         <+> ifClick (snapMagicMove (Just 50) (Just 50) w))
)
    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]
 [ 
--}
--}
--{- utility functions
--{- type definitions
ifWS',    ifLay'    :: AXXX String
ifWS ,    ifLay     :: String -> (WindowSet -> WindowSet) -> X ()
ifFloat', ifTile'   :: XXX
ifFloat , ifTile    :: (WindowSet -> WindowSet) -> X ()
nNSP, usednNSP      :: WSType
safeShift', safeShift, safeMove :: Direction1D -> X ()
--}
--{- if workspace.name
ifWS' s fn bk  = withWindowSet $ \ws -> if s `isInfixOf` (W.currentTag) ws then fn else bk
ifWS  s fn     = ifWS' s (windows fn) $ pure ()
--}
--{- if layout.name
ifLay' s fn bk = withWindowSet $ \ws -> if s `isInfixOf` (description . W.layout . W.workspace . W.current) ws then fn else bk
ifLay  s fn    = ifLay' s (windows fn) $ pure ()
--}
--{- if floating
ifFloat' fn bk = withWindowSet $ \ws -> case W.peek ws of Just w | M.member w $ W.floating ws -> fn; _ -> bk
ifFloat  fn    = ifFloat' (windows fn) $ pure ()
--}
--{- if tiled
ifTile'   = flip ifFloat'
ifTile fn = ifTile' (windows fn) $ pure ()
--}
--{- WS movement
nNSP     = WSIs $ return \x -> W.tag x /= "NSP"
usednNSP = WSIs $ return \x -> isJust (W.stack x) && W.tag x /= "NSP"
safeMove   direction = moveTo     direction usednNSP
safeShift' direction = shiftTo    direction nNSP
safeShift  direction = safeShift' direction <+> safeMove direction
--}
{- custom withNthWorkspace
wNWS' :: ([WorkspaceId] -> [WorkspaceId]) -> [(String -> WindowSet -> WindowSet)] -> Int -> X ()
wNWS' tr jobs wnum = do
 sort <- getSortByOrder
 ws <- gets (tr . map W.tag . sort . W.workspaces . windowset)
 case drop wnum ws of
   (w:_) -> windows $ foldl (<+>) $ [head jobs w] <> tail jobs
   []    -> return ()

-- | Do something with the nth workspace in the dynamic order.  The
--   callback is given the workspace's tag as well as the 'WindowSet'
--   of the workspace itself.
wNWS :: [(String -> WindowSet -> WindowSet)] -> Int -> X ()
wNWS = wNWS' id
--}
--}

{- references
--{- organize: takes all other floats windows and places them below the focus
-- sort-of replaces trackFloating, but seems to be a more expensive operation,
-- tbh, just use that, but here's an amazing example on how to modify the
-- stack
organize = windows $ \ws ->
 let floating = W.floating ws
 in flip W.modify' ws $
 \(W.Stack f u d) -> W.Stack f
 -- self explanatory
    (u `isn't` floating)
 $  (reverse u) `is` floating
 <> d `is` floating
 <> d `isn't` floating
--}
--}
