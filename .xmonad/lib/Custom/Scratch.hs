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
import XMonad.Hooks.ManageHelpers
--}
--{- keybinds and scratches
{- human-readable keybinds
t  terminal
/  terminal/screen
n  notes
m  media
f  files
p  passwords
c  calculator
e  easy effects
v  volume

--}
mscratch' =
 [ "t", "/", "n", "m", "f", "p", "c", "v", "e", "s" ]

mscratch =
 [ NS  (sc!1) t  tF  $ cfloat 1 -- t erminal
 , NS  (sc!2) d  sF  $ cfloat 1 -- / screenified terminal
 , NS  (sc!3) n  nF  $ cfloat 1 -- n otes / editor
 , NS  (sc!4) m  mF  $ cfloat 1 -- m edia viewer
 , NS  (sc!5) f  fF  $ cfloat 1 -- f ile viewer
 , NS  (sc!6) p  pF  $ cfloat 1 -- p assword manager
 , NS  (sc!7) c  cF  $ cfloat 0 -- c alculator
 , NS  (sc!8) v  vF  $ cfloat 0 -- v olume management
 , NS  (sc!9) e  eF  $ cfloat 0 -- e asy effects
 , NS (sc!10) s  sF  $ cfloat 1 -- s ystem monitor
 ]
 where
  sc = mscratch'
  sn = [ "S:" <> (caps x) | x <- sc ]
  cfloat n = (defaultFloating : map customFloating mfloatMolds')!!n
  consoleMatch n = resource =? (sn!n) <||> title =? (sn!n)

  t  = mconsole (sn!1) mshell
  tF = consoleMatch 1

  d  = mconsole (sn!2) $ "screen -xaAR scratch -s " <> mshell
  dF = consoleMatch 2

  n  = mconsole (sn!3) meditor'  -- assumes CLI
  nF = consoleMatch 3

  m  = "vlc"
  mF = className =? "vlc" <&&> title /=? "" <&&> title /=? "vlc"
  -- vlc main window title: VLC, or something completely different
  -- fullscreen vlc player info popup title: vlc, or nothing, depending on
  -- source used
  -- this' a bit finicky, could be broken by a future release, may need
  -- maintenance

  f   = mfiles
  fF  = className ~? mfiles

  p   = "bitwarden"
  pF  = className ~? "bitwarden"

  c   = "qalculate-gtk"
  cF  = className ~? "qalculate-gtk"

  v   = "pavucontrol"
  vF  = className ~? "pavucontrol"

  e    = "easyeffects"
  eF   = title =? "EasyEffects"

  s   = mconsole (sn!9) "btm"
  sF  = consoleMatch 9
--}
--{- floating boxes
mfloatMolds =
 -- keys designed to work with both qwerty and colemak
 --let keys = ["f"] : mwinKeys <> [["S-f"], [",","."],["/"], ["l","i"],[";", "o", "'"]] in -- old version, semi-qwerty compatible
 -- /.l;
 let keys = ["f"] : mwinKeys <>
                                ([ ["S-f"]
                                , ["/"],["S-/"]
                                , ["."],["S-."]
                                , ["i"],["S-i"]
                                , ["o"],["S-o"]
                                ]) in

 -- some annoyingly complex mappings to make directional keys work too, add lines in a similar fashion to "f" in order to add more mappings
 -- not all of them need to be mapped, they can be used internally too.
 concat [
 [ (k, mfloatMolds'!i) | k <- keys!i ]
 |  i <- [1 .. length keys ] ]

mfloatMolds' =
 [ tl xPad yPad 1    1    -- full  mold
 , tl xPad yPad 0.5  1    -- left  mold
 , br xPad yPad 0.5  1    -- right mold
 ,  b 0    0    1    1    -- fullscreen float
 , big   br               -- bottom right big
 , small br               -- bottom right small
 , big   bl               -- bottom left big
 , small bl               -- bottom left small
 , big   tl               -- top left big
 , small tl               -- top left small
 , big   tr               -- top left big
 , small tr               -- top left small
 ]
 where
 b = W.RationalRect
 yPad = 0.05
 xPad = 0.033
 big   anchor = anchor xPad yPad 0.5  0.5
 small anchor = anchor xPad yPad 0.3  0.3
 -- apply padding
 -- anchor top-left
 tl = \x y w h -> b   x               y               (min (w-x) $ 1-x-x)              $ min (h-y) $ 1-y-y
 -- anchor top-right
 tr = \x y w h -> b   (max x $ 1-w)   y               (max 0.01 (min (w-x) $ 1-x-x))   $ min (h-y) $ 1-y-y
 -- anchor bottom-left
 bl = \x y w h -> b   x               (max y $ 1-h)   (min (w-x) $ 1-x-x)              $ max 0.01 (min (h-y) $ 1-y-y)
 -- anchor bottom-right
 br = \x y w h -> b   (max x $ 1-w)   (max y $ 1-h)   (max 0.01 (min (w-x) $ 1-x-x))   $ max 0.01 (min (h-y) $ 1-y-y)
--}

{- references
{- -- this tricks vim, enabling syntax highlighting
-}
--}

