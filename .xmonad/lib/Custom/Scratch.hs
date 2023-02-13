module Custom.Scratch where
--{- imports
--{- globals
import Custom.Vars
--}
--{- standards
import XMonad
import XMonad.Util.NamedScratchpad
import qualified XMonad.StackSet as W
--}
import XMonad.Hooks.ManageHelpers hiding ((~?))
import Control.Monad (join)
--}
--{- keybinds and scratches
scratchKeys =
 [ "t", "n", "m", "f", "p", "c", "v", "e", "s" ]

-- TODO make strings only...
scratchPairs =
 [ (1, scratch shell    , eqScratch) -- t erminal
 , (1, edit'            , eqScratch) -- n otes / editor
 , (1, c "vlc"          , matchApp)  -- m edia viewer
 , (1, view'            , cmdClass)  -- f ile viewer
 , (1, c "bitwarden"    , cmdClass)  -- p assword manager
 , (0, c "qalculate-gtk", cmdClass)  -- c alculator
 , (0, c "pavucontrol"  , cmdClass)  -- v olume management
 , (0, c "easyeffects"  , title      =? "EasyEffects")
 , (1, scratch "btm"    , eqScratch) -- s ystem monitor
 ]
 where
  -- vlc main window title: VLC, or something completely different
  -- fullscreen vlc player info popup title: vlc, or nothing, depending on
  -- source used
  -- this' a bit finicky, could be broken by a future release, may need
  -- maintenance
  matchApp  (sk,cmd) = className =? cmd <&&> title /=? "" <&&> title /=? cmd
  eqScratch (sk,cmd) = resource  =? sk  <||> title  =? sk
  cmdClass  (sk,cmd) = className ~? cmd
  c = const

scratchpads =
  flip2 zipWith scratchKeys scratchPairs
  \key (mold,cmd,query) ->
    let titled = "S:"<>caps key in
    NS (cmd titled) (query (titled, cmd)) (meld mold)

meld n = (defaultFloating : map customFloating molds)!!n

--}
--{- floating boxes
mfloatMolds =
 -- keys designed to work with both qwerty and colemak
 let keys = ["f"] : mwinKeys <>
  ([ ["S-f"]
 {- old ver semi-qwerty compatible
 [",","."],["/"], ["l","i"],[";", "o", "'"]]
 -- /.l;
 --}
  ,  ["/"],["S-/"]
  ,  ["."],["S-."]
  ,  ["i"],["S-i"]
  ,  ["o"],["S-o"]
  ])
  in zip keys molds

molds =
 [ tl xPad yPad 1    1 -- full  mold
 , tl xPad yPad 0.5  1 -- left  mold
 , br xPad yPad 0.5  1 -- right mold
 , b  0    0    1    1 -- fullscreen float
 , big   br            -- bottom right big
 , small br            -- bottom right small
 , big   bl            -- bottom left big
 , small bl            -- bottom left small
 , big   tl            -- top left big
 , small tl            -- top left small
 , big   tr            -- top left big
 , small tr            -- top left small
 ]
 where
 b = W.RationalRect
 r (x,y,w,h) = W.RationalRect x y w h
 yPad = 0.05
 xPad = 0.033
 half l = join $ (-) . min l . (1-)
 clamp = max 0.01
 bound = max . (1-)
 big   anchor = anchor xPad yPad 0.5  0.5
 small anchor = anchor xPad yPad 0.3  0.3
 -- apply padding
 -- anchor top-left
 tl x y w h = r (        x,         y,         half w x,         half h y)
 -- anchor top-right
 tr x y w h = r (bound w x,         y, clamp $ half w x,         half h y)
 -- anchor bottom-left
 bl x y w h = r (        x, bound h y,         half w x, clamp $ half h y)
 -- anchor bottom-right
 br x y w h = r (bound w x, bound h y, clamp $ half w x, clamp $ half h y)
--}

{- references
--}

