{- language CPP -}
module Custom.Keys where
--{- imports
--{- globals
import Custom.Grid
import Custom.Prompts
import Custom.Scratch
import Custom.Vars
--}
--{- standards
import XMonad
import System.Exit (exitSuccess)
import qualified XMonad.Util.PureX as P
import qualified XMonad.Util.Stack as U
import qualified XMonad.StackSet as W
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
import XMonad.Layout.Hidden
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
--}
--{- prompt
import XMonad.Prompt
import XMonad.Prompt.Shell
import XMonad.Prompt.RunOrRaise
--}
--{- utils
import XMonad.Util.NamedScratchpad
import XMonad.Util.SpawnOnce
--}
--{- misc
import XMonad.Hooks.ManageDocks (ToggleStruts(..))
import Data.List (isInfixOf)
import qualified Data.Map as M
import Data.Maybe (isJust, fromMaybe)
--}
--}
--{- keys
--{- type definitions
moverrides :: [(String, X ())]
mkeys :: [String] -> [String] -> [(String, X ())]
--}
--{- overrides
moverrides =
 [ (a, mnotify "usage" b) | (a, b) <-
 [ ("M-S-/",        def)
 , ("M-S-<Return>", def)
 , ("M-p",          def)
 , ("M-S-p",        off)
 , ("M-S-c",        "M-backspace")
 -- M-q & M-S-q excluded as a safety precaution
 , ("M-<Space>",    def)
 , ("M-S-<Space>",  off)
 , ("M-n",          off)
 , ("M-<Tab>",      def)
 , ("M-S-<Tab>",    off)
 , ("M-j",          "M-r")
 , ("M-k",          "M-a")
 , ("M-m",          def)
 , ("M-<Return>",   def)
 , ("M-S-j",        "M-S-r")
 , ("M-S-k",        "M-S-a")
 , ("M-h",          def)
 , ("M-l",          off)
 , ("M-t",          "M-down")
 , ("M-,",          off)
 , ("M-.",          off)
 ]
--  <> [ dyn k  off | k <- ['1'..'9'] ]
--  <> [ dyn' k off | k <- ['1'..'9'] ]
 <> [ dyn  k  off | k <- "wer" ]
 <> [ dyn' k off | k <- "wer" ]
 ]
 --{- where
 where
  --{- type definitions
  off, def :: String
  dyn', dyn :: Char -> String -> (String, String)
  --}
  off = "disabled"
  def = "???"
  dyn  k a = ("M-" <> [k], a)
  dyn' k a = ("M-S-" <> [k], a)
  --}
--}
--{- my keys
mkeys bgs fgs =
 -- Instead of clumsy log hook version of updatePointer, activate after every
 -- hotkey. This way it doesn't activate upon notifications!
 map (\(k, a) -> (k, a *> up)) ([
--{-  session management
   ("M-q", mnotify "xmonad" "restarting"  <+> spawn "xmonad --restart")
 , ("M-C-q", io exitSuccess)
 , ("M-S-q", io exitSuccess)
 , ("M-l", spawn $ mlocker <> " &")
 -- couldn't figure out how TF to pipe mBG in here, so...
 , ("M-0", mapM_ (\x -> unspawn x <+> spawn ("sleep 1;" <> x)) $ mtray (bg!1) : mrestart)  -- relaunch startup things
--}
--{-  general
 , ("M-<Return>",      spawn $ mterminal <> " -e " <> mshell)
 , ("M-S-<Return>",    spawn $ mterminal <> " -e " <> mshell)

 , ("M-<Backspace>",   kill1)
 , ("M-S-<Backspace>", killAll)

 , ("M-`",             windows copyToAll)
 , ("M-<Escape>",      killAllOtherCopies)
--}
--{-  window navigation
--  NOTE - dynamic keys, dynamically added based on values in Vars.hs
 -- , ("M-C-a", rotAllUp)                -- Rotate all up
 -- , ("M-C-r", rotAllDown)              -- Rotate all down
 
 , ("M-z",   withFocused hideWindow)
 , ("M-S-z", popNewestHiddenWindow)
-- ("M-z",   withFocused minimizeWindow)
-- ("M-S-z", withLastMinimized maximizeWindowAndFocus)
--}
--{-  layouts
 , ("M-S-<Tab>", sendMessage FirstLayout)
 , ("M-<Tab>",   sendMessage NextLayout)
 , ("M-C-<D>",   sinkAll)                        -- sink all windows
 , ("M-S-<D>",   sinkAll)                        -- sink all windows
 , ("M-<D>",     withFocused $ windows . W.sink) -- sink current window

 , ("M-C-S-<U>", withAll'            fullFloat <+> windows W.shiftMaster) -- fullscreen all windows
 , ("M-C-<U>",   withAll'            fullFloat <+> windows W.shiftMaster) -- fullscreen all windows
 , ("M-S-<U>", withTiled'            fullFloat <+> windows W.shiftMaster) -- fullscreen all tiled windows
 , ("M-<U>", withFocused $ windows . fullFloat)                          -- fullscreen current window
--}
--{-  workspaces
--  NOTE - dynamic keys, dynamically added based on values in Vars.hs
 , ("M-<Space>" , toggleWS' ["NSP"])
 , ("M-C-S-M1-<Space>", appendWorkspace "oioi")
 , ("M-C-S-M1-1", setWorkspaceIndex 5)
 , ("M-C-S-M1-2", addWorkspacePrompt $ promptConf bgs fgs)
 , ("M-C-S-M1-3", renameWorkspace  $ promptConf bgs fgs)
 , ("M-C-S-M1-4", addWorkspace "test")
 , ("M-C-S-M1-5", selectWorkspace  $ promptConf bgs fgs)
 , ("M-C-S-M1-6", addHiddenWorkspace "wow")
 , ("M-C-S-M1-s", renameWorkspaceByName "ay")
 -- , ("M-M1-C-S-<Return>", activateProject currentProject)
--}
--{-  multimedia
--{- play/pause/seek
 , ("<XF86AudioPrev>" , spawn "playerctl previous")
 , ("<XF86AudioPlay>" , spawn "playerctl play-pause")
 , ("<XF86AudioPause>", spawn "playerctl play-pause")
 , ("<Pause>",          spawn "playerctl play-pause")
 , ("<XF86AudioNext>" , spawn "playerctl next")
 , ("S-<XF86AudioPrev>" , spawn "playerctl -a previous")
 , ("S-<XF86AudioPlay>" , spawn "playerctl -a play-pause")
 , ("S-<XF86AudioPause>", spawn "playerctl -a play-pause")
 , ("S-<Pause>",          spawn "playerctl -a play-pause")
 , ("S-<XF86AudioNext>" , spawn "playerctl -a next")
--}
--{- volume up/down/mute
 , ("<XF86AudioLowerVolume>",   spawn $ mvol mvoln  "-")
 , ("<XF86AudioRaiseVolume>",   spawn $ mvol mvoln  "+")
 , ("<XF86AudioMute>",          spawn $ mmute)
 , ("S-<XF86AudioLowerVolume>", spawn $ mvol mvoln' "- unmute")
 , ("S-<XF86AudioRaiseVolume>", spawn $ mvol mvoln' "+ unmute")
--}
--{- brightness up/down
 , ("<XF86MonBrightnessDown>",   spawn $ mbright mbrightn  "-")
 , ("<XF86MonBrightnessUp>"  ,   spawn $ mbright mbrightn  "+")
 , ("S-<XF86MonBrightnessDown>", spawn $ mbright mbrightn' "-")
 , ("S-<XF86MonBrightnessUp>"  , spawn $ mbright mbrightn' "+")
 , ("S-M--",                     spawn $ mbright mbrightn' "-")
 , ("S-M-=",                     spawn $ mbright mbrightn' "+")
 , ("M--",                       spawn $ mbright mbrightn  "-")
 , ("M-=",                       spawn $ mbright mbrightn  "+")
--}
--{- screenshooting
 , ("<Print>",   spawn mscreenshotFull)
 , ("M-<Print>", spawn mscreenshotBox')
 , ("S-<Print>", spawn mscreenshotBox )
--}
--{- multi-keyboard layout management
 , ("M-M1-<Space>", spawn "bash ~/.xmonad/kbd.sh")
--}
--{- notifications
 , ("M-.", spawn mnotifTray)
--}
--}
{- sublayouts
 sublayouts options, tabbed sublayouts causes screen artifacts in my attempts.
 , ("M-u", sendMessage $ pullGroup U)  -- i j k l =  US, u n e i = US(COLEMAK)
 , ("M-n", sendMessage $ pullGroup L)
 , ("M-e", sendMessage $ pullGroup D)
 , ("M-i", sendMessage $ pullGroup R)

 , ("M-C-<D>", withFocused (sendMessage . MergeAll))
 , ("M-C-<U>", withFocused (sendMessage . UnMerge))

 , ("M-C-a", onGroup W.focusUp')
 , ("M-C-r", onGroup W.focusDown')

 , ("M-f <L>", withFocused $ \w -> W.float w $ W.RationalRect 0.1 0.1 0.5 1.0)
 , ("M-f <L>", windows $ \w -> W.float w $ W.RationalRect 0.1 0.1 0.5 1.0)
--}
 ]
--{- dynamic keybinds
-- like DT's dynamic keys using list comprehension, but "M-a a" & "M-a M-a" are accepted
 --{- scratchpads
 <> twoK "M" "p" [(k, allNamedScratchpadAction mscratch k ) | k     <- mscratch'   ]  -- scratchpads
 --}
 --{- prompts
 <> twoK "M" "s" [(k, S.promptSearch (promptConf' bgs fgs) f )     | (k,f) <- msearches   ]  -- search prompts
 <>              [("M-" <> k, f (promptConf' bgs fgs))            | (k,f) <- mprompts    ]  -- other prompts
 --}
 --{- gridselects
 <> twoK "M" "\\" mgrids
 --}
 --{- navigation
 --{- window movement
 <> mapKs "M"   mwinKeys [fUp,fDown]
 <> mapKs "M-S" mwinKeys [windows W.swapUp, windows W.swapDown]
 --}
 --{- workspace movement
 <> mapKs "M" (modifs ["M1-C","C-S", "M1","S", "C"] $ mwsKeys!1)
  [ aPrev, aPrev                                                  -- shift all prev
  , safeShift Prev, safeShift Prev                                -- shift prev
  , prevWS                                                        -- prev
  , safeMove Prev                                                 -- prev active
  ]
 <> mapKs "M" (modifs ["M1-C","C-S", "M1","S", "C"] $ mwsKeys!2)
  [ aNext, aNext                                                  -- shift all
  , safeShift Next, safeShift Next                                -- shift next
  , nextWS                                                        -- next
  , safeMove Next                                                 -- next active
  ]
 -- TODO, explain this gazelle
 <> [ ( concat ["M-C-", show k] , mapM_ (flip withNthWorkspace i) [W.shift, W.view] )
  | (k, i) <- zip [0..9] $ scon [0..9] ]
 <> [ ( concat ["M-C-S-", show k] , foldl (<+>) wreverse (take 10 $ repeat $ withNthWorkspace W.shift i) <+> withNthWorkspace W.view i)
  | (k, i) <- zip [0..9] $ scon [0..9] ]
 --}
 --}
 --{- floatKeys
 <> twoK "M" "f" [(k, withFocused $ windows . \w -> W.float w r)  | (k,r) <- mfloatMolds ]
 --}
 --}
 )
 --{- where
 where
  --{- type definitions
  aNext, aPrev, fUp, fDown :: X ()
  fullFloat :: Window -> WindowSet -> WindowSet
  --}
  allSafe fwd bak = withAll (\_ -> safeShift fwd <+> safeMove bak) <+> safeMove fwd <+> wreverse <+> up -- leave `up` here, other up happens before
  aNext = allSafe Next Prev
  aPrev = allSafe Prev Next
  fullFloat = flip W.float $ W.RationalRect 0 0 1 1
  up = updatePointer (0.5, 0.5) (0.75, 0.75)
  wrev2 = \_ -> W.modify' $
   -- completely reverse stack (kinda)
   \(W.Stack f u d) -> W.Stack (last d) [] (reverse (init d) <> u <> [f])
  wreverse = windows $ W.modify' $
   -- completely reverse stack (kinda)
   \(W.Stack f u d) -> W.Stack (last d) [] (reverse (init d) <> u <> [f])
--{- disaster town
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
--}
--{- utility functions
--{- type definitions
-- TODO start building XMonad with a C Preprocessor, linked to Stack (not cabal,
-- since using nix)
-- #define XXX = X () -> X () -> X ()
ifWS',    ifLay'  :: AXXX String
ifWS ,    ifLay   :: String -> (WindowSet -> WindowSet) -> X ()
ifFloat', ifTile' :: XXX
ifFloat , ifTile  :: (WindowSet -> WindowSet) -> X ()
nott,     iff     :: [Window] -> M.Map Window W.RationalRect -> [Window]
nNSP, usednNSP    :: WSType
safeShift', safeShift, safeMove :: Direction1D -> X ()
modifs :: [String] -> [String]   -> [[String]]
mapKs  :: String   -> [[String]] -> [X ()] -> [(String, X ())]
twoK   :: String   -> String     -> [(String, X ())] -> [(String, X ())]
--}
--{- if workspace.name
ifWS' s fn bk  = withWindowSet $ \ws -> if s `isInfixOf` (W.currentTag) ws then fn else bk
ifWS  s fn     = ifWS' s (windows fn) $ pure ()
--}
--{- if layout.name
ifLay' s fn bk = withWindowSet $ \ws -> if s `isInfixOf` (description . W.layout . W.workspace . W.current) ws then fn else bk
ifLay  s fn    = ifLay' s (windows fn) $ pure ()
--}
--{- if item in stack, filter amongst stacks
-- inn :: Maybe Window -> WindowSet -> Bool
-- inn  item  set = case item of Just i -> M.member i set; _ -> False
nott  items set = filter (not . flip M.member set) items
iff   items set = filter (      flip M.member set) items
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
nNSP = WSIs (return (\x -> W.tag x /= "NSP"))
usednNSP = WSIs (return (\x -> isJust (W.stack x) && W.tag x /= "NSP"))
safeMove direction = moveTo direction usednNSP
safeShift' direction = shiftTo direction nNSP
safeShift direction = safeShift' direction <+> safeMove direction
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
--{- dynamic keybinds
modifs list keys = [ [ m <> "-" <> k | k <- keys] | m <- list] <> [keys]
mapKs modif keys actions =
 concat [ [
  (modif <> "-" <> k, actions!i) | k <- keys!i
  ] | i <- [1 .. length actions] ]
twoK modif first list =
 let mm = modif <> "-" in
 concat $ map
  (\x -> [( concat [mm,first," ",x,k], f ) | (k,f) <- list ])
  ["", mm]
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
    (u `nott` floating)
 $  (reverse u) `iff` floating
 <> d `iff` floating
 <> d `nott` floating
--}
--}
