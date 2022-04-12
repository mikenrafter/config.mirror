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
 , enabled, query
 , Conf(..)
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
 State (p, b) <- XS.get -- prev ws, and FS state
 Conf  (tg,t) <- XS.get -- tag and theme
 withWorkspace \i -> withF \ws ->
  case ws of
  -- if a window is present on the workspace
  Just w ->
   hasTag tg w >>= \isTagged ->
    -- if out of sync with ext.state
    if b /= isTagged || p /= i then
     -- update ext.state
     XS.put ( State (i, isTagged) ) >>
     -- apply updates
     case isTagged of
      True  -> borderState False w <+> setTheme (invisible t) <+> relax <+> space False
      False -> borderState True  w <+> setTheme t             <+> strut <+> space True
    -- otherwise do nothing
    else pure ()
  -- if no window
  otherwise -> XS.put ( State (i, False) )
 where
  withF f = withWindowSet \w -> f $ W.peek w
  relax = broadcastMessage $ SetStruts [] [minBound .. maxBound]
  strut = broadcastMessage $ SetStruts    [minBound .. maxBound] []
  space bool = foldr1 (<+>)
   $ flip map [setScreenSpacingEnabled, setWindowSpacingEnabled] \x -> x bool
  invisible t = t{decoHeight=0,decoWidth=0}
  setTheme t = broadcastMessage $ SetTheme t
  withWorkspace f = withWindowSet $ \w -> f $ show $ W.currentTag w
  focus'WS f = withWindowSet $ \w -> whenJust (W.peek w) $ f withWorkspace
--}

-- easy read/write functions
withTag   :: (String -> X a) -> X a
withTheme :: (Theme  -> X a) -> X a
setTag    ::  String -> X ()
setTheme  ::  Theme  -> X ()

withTheme f = XS.get >>= \(Conf (_,t )) -> f t
withTag   f = XS.get >>= \(Conf (tg,_)) -> f tg
setTheme  t = withTag    \tg -> XS.put $ Conf (tg, t)
setTag   tg = withTheme  \t  -> XS.put $ Conf (tg, t)

enabled :: Window -> X Bool
enabled _ = XS.get >>= \(State (_,b)) -> return b

query :: Query Bool
query = ask >>= liftX . enabled



-- quality of life functions
off, on :: Window -> X ()

refresh  = withTag \tg -> withTaggedGlobalP tg W.sink >> logHook
off w    = withTag \tg -> delTag tg w >> refresh
on w     = withTag \tg -> addTag tg w >> refresh
toggle w = withTag \tg ->
 hasTag tg w >>= \case
  True  -> off w
  False -> on w



start :: ManageHook
start = ask >>= \x -> liftX $ on x >> idHook


data Conf = Conf (String, Theme)
instance ExtensionClass Conf where
 initialValue = Conf ("FS", def Theme)

data State = State (String, Bool)
instance ExtensionClass State where
 initialValue = State ("", False)

-- Extended variant of X.A.NoBorders
borderState :: Bool -> Window -> X ()
borderState bool w = do
    bw <- asks (borderWidth . config)
    withDisplay \d -> io do
        cw <- wa_border_width <$> getWindowAttributes d w
        if bool
            then setWindowBorderWidth d w bw
            else setWindowBorderWidth d w 0
