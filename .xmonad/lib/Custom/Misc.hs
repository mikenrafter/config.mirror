{-# LANGUAGE RecordWildCards, NamedFieldPuns #-}
module Custom.Misc where
--{- imports
import Custom.Vars
import XMonad
import XMonad.Actions.EasyMotion as E
import qualified XMonad.StackSet as W
import XMonad.Actions.ShowText
--}

emConfig :: Z -> EasyMotionConfig
emConfig (Z{..}) = def
 { sKeys = AnyKeys
   [ xK_n, xK_e, xK_i, xK_o -- right half home row
   ]
 , cancelKey = xK_Escape
 , emFont    = mononoki "regular" 32
 , borderPx  = 0
 , txtCol    = fore
 , bgCol     = back
 , overlayF  = E.proportional 0.4 -- (W.RationalRect 0.1 0.1 0.1 0.1)
 }

stConfig :: Z -> ShowTextConfig
stConfig (Z{..}) = def
 { st_font = mononoki "regular" 32
 , st_fg   = fore
 , st_bg   = back
 }
