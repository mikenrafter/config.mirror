{-# OPTIONS_GHC -Wno-missing-signatures -Wno-orphans #-}
{-# LANGUAGE FlexibleContexts #-} -- for L.Hidden
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE BlockArguments #-}
{-# LANGUAGE TypeApplications #-}

module Custom.Fullscreen (
 fsHook', fsHook, refreshFS,
 toggleFullscreen, addFS, delFS,
 setFSTheme, FSTheme
 ) where

import XMonad
import qualified XMonad.Util.ExtensibleState as XS
import XMonad.StackSet as W
import XMonad.Actions.TagWindows
import XMonad.Hooks.ManageDocks (ToggleStruts(..), SetStruts(..))
import XMonad.Layout.Spacing
import XMonad.Layout.Decoration

--{- fs hook
-- TODO Custom.EwmhDesktops - line 393

fsHook :: X ()
fsHook = fsHook' False

fsHook' :: Bool -> X ()
fsHook' force = do
 FSTheme t <- XS.get
 withFocused \x ->
  XS.get >>= \(FSState (w,b)) ->
   if w == Just x && force==False
    then if b then pure () else (save x True) >> (fn t x)
    else (save x True) >> (fn t x)
 where
  save w b = XS.put $ FSState (Just w, b)
  relax = broadcastMessage $ SetStruts [] [minBound .. maxBound]
  strut = broadcastMessage $ SetStruts    [minBound .. maxBound] []
  space bool = foldr1 (<+>)
   $ flip map [setScreenSpacingEnabled, setWindowSpacingEnabled] \x -> x bool
  invisible t = t{decoHeight=0,decoWidth=0}
  setTheme t = broadcastMessage $ SetTheme t
  fn t w  = hasTag "FS" w >>= \case
   True  -> borderState False w <+> setTheme (invisible t) <+> relax <+> space False
   False -> borderState True  w <+> setTheme t             <+> strut <+> space True
--}


setFSTheme theme = XS.put $ FSTheme theme


toggleFullscreen w = 
 hasTag "FS" w >>= \case
  True  -> delTag "FS" w
  False -> addTag "FS" w
 >> refreshFS

-- quality of life functions
refreshFS = withTaggedGlobalP "FS" W.sink >> ( fsHook' True )
addFS w = addTag "FS" w >> refreshFS
delFS w = delTag "FS" w >> refreshFS

data FSTheme = FSTheme Theme
instance ExtensionClass FSTheme where
 initialValue = FSTheme (def Theme)

data FSState = FSState (Maybe Window, Bool)
instance ExtensionClass FSState where
 initialValue = FSState (Nothing, False)

-- Extended variant of X.A.NoBorders
borderState :: Bool -> Window -> X ()
borderState bool w = do
    bw <- asks (borderWidth . config)
    withDisplay $ \d -> io $ do
        cw <- wa_border_width <$> getWindowAttributes d w
        if bool
            then setWindowBorderWidth d w bw
            else setWindowBorderWidth d w 0
