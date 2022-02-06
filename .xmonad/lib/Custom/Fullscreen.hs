{-# OPTIONS_GHC -Wno-missing-signatures -Wno-orphans #-}
{-# LANGUAGE FlexibleContexts #-} -- for L.Hidden
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE BlockArguments #-}
{-# LANGUAGE TypeApplications #-}

module Custom.Fullscreen
 ( logHook, start, refresh
 , off, on, toggle
 , withTag, withTheme
 , setTag, setTheme
 , Conf
 ) where

import XMonad hiding (logHook, refresh, spawn)
import qualified XMonad.Util.ExtensibleState as XS
import XMonad.StackSet as W
import XMonad.Actions.TagWindows
import XMonad.Hooks.ManageDocks (ToggleStruts(..), SetStruts(..))
import XMonad.Layout.Spacing
import XMonad.Layout.Decoration

--{- fs hook
logHook :: X ()
logHook = do
 FSState b    <- XS.get
 Conf  (tg,t) <- XS.get -- tag and theme
 withFocused \w ->
  hasTag tg w >>= \isTagged ->
   if b /= isTagged then
    XS.put ( FSState isTagged ) >>
    case isTagged of
     True  -> borderState False w <+> setTheme (invisible t) <+> relax <+> space False
     False -> borderState True  w <+> setTheme t             <+> strut <+> space True
   else pure ()
 where
  relax = broadcastMessage $ SetStruts [] [minBound .. maxBound]
  strut = broadcastMessage $ SetStruts    [minBound .. maxBound] []
  space bool = foldr1 (<+>)
   $ flip map [setScreenSpacingEnabled, setWindowSpacingEnabled] \x -> x bool
  invisible t = t{decoHeight=0,decoWidth=0}
  setTheme t = broadcastMessage $ SetTheme t
--}

-- easy read/write functions
withTag   :: (String -> X ()) -> X ()
withTheme :: (Theme  -> X ()) -> X ()
setTag    ::  String -> X ()
setTheme  ::  Theme  -> X ()

withTheme f = XS.get >>= \(Conf (_,t )) -> f t
withTag   f = XS.get >>= \(Conf (tg,_)) -> f tg
setTheme  t = withTag    \tg -> XS.put $ Conf (tg, t)
setTag   tg = withTheme  \t  -> XS.put $ Conf (tg, t)


-- quality of life functions
off, on :: Window -> X ()

refresh = withTag \tg -> withTaggedGlobalP tg W.sink >> logHook
off w   = withTag \tg -> delTag tg w >> refresh
on w    = withTag \tg -> addTag tg w >> refresh
toggle w = withTag \tg ->
 hasTag tg w >>= \case
  True  -> off w
  False -> on w



start :: ManageHook
start = ask >>= \x -> liftX $ on x >> idHook


data Conf = Conf (String, Theme)
instance ExtensionClass Conf where
 initialValue = Conf ("FS", def Theme)

data FSState = FSState Bool
instance ExtensionClass FSState where
 initialValue = FSState False

-- Extended variant of X.A.NoBorders
borderState :: Bool -> Window -> X ()
borderState bool w = do
    bw <- asks (borderWidth . config)
    withDisplay $ \d -> io $ do
        cw <- wa_border_width <$> getWindowAttributes d w
        if bool
            then setWindowBorderWidth d w bw
            else setWindowBorderWidth d w 0
