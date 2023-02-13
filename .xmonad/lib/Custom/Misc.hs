{-# LANGUAGE RecordWildCards, NamedFieldPuns #-}
module Custom.Misc where
--{- imports
import Custom.Vars
import XMonad
import XMonad.Actions.EasyMotion as E
import qualified XMonad.StackSet as W
--}

emConfig :: Z -> EasyMotionConfig
emConfig (Z{..}) = def
 { sKeys = AnyKeys
   [ xK_t, xK_n, xK_s, xK_e -- home row index and middle finger, alternating
   , xK_v, xK_m             -- index  finger curl
   , xK_f, xK_u             -- middle finger stretch
   , xK_r, xK_i, xK_a, xK_o -- rest of home row, alternating
   ]
 , cancelKey = xK_Escape
 , emFont    = mononoki "regular" 32
 , borderPx  = 0
 , txtCol    = fore
 , bgCol     = back
 , overlayF  = E.proportional 0.4 -- (W.RationalRect 0.1 0.1 0.1 0.1)
 }
