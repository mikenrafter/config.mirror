module Custom.Misc where
--{- imports
import Custom.Vars
import XMonad
import XMonad.Actions.EasyMotion as E
--}

emConfig :: Settings -> EasyMotionConfig
emConfig the = def
 { sKeys = AnyKeys
   [ xK_t, xK_n, xK_s, xK_e -- home row index and middle finger, alternating
   , xK_v, xK_m             -- index  finger curl
   , xK_f, xK_u             -- middle finger stretch
   , xK_r, xK_i, xK_a, xK_o -- rest of home row, alternating
   ]
 , cancelKey = xK_Escape
 , emFont    = font
 , borderPx  = 0
 , txtCol    = the fore
 , bgCol     = the back
 , overlayF  = E.textSize
 }
