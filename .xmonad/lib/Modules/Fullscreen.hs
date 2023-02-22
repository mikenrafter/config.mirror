{-# LANGUAGE LambdaCase, BlockArguments #-}

-- intended to be imported as Qualified
module Modules.Fullscreen
 ( logHook, start, refresh
 , off, on, toggle
 , withTag, withTheme
 , setTag, setTheme
 , enabled, query
 , Conf(..)
 ) where
--{- imports
import XMonad hiding (logHook, refresh)
import qualified XMonad.Util.ExtensibleState as XS
import XMonad.StackSet as W

import XMonad.Actions.TagWindows
import XMonad.Layout.Decoration
import XMonad.Layout.Spacing
--}
--{- logHook
logHook :: X ()
logHook = do
 State (p, b) <- XS.get -- prev ws, and FS state
 Conf  (tg,t) <- XS.get -- tag and theme
 withWorkspace \i -> withF \case
  -- if a window is present on the workspace
  Just w ->
   hasTag tg w >>= \isTagged ->
    -- if out of sync with ext.state
    if b /= isTagged || p /= i then
     -- update ext.state
     XS.put ( State (i, isTagged) ) >>
     -- apply updates
     case isTagged of
-- TODO: remove need to manage borders & spacing
      True  -> borderState False w <+> invisible t <+> space
      False -> borderState True  w <+> visible   t <+> space
    -- otherwise do nothing
    else pure ()
  -- if no window
  otherwise -> XS.put ( State (i, False) )
 where
  withF f = withWindowSet \w -> f $ W.peek w
  -- strange workaround to keep spacing behaving properly when ewmh's FS hook is
  -- above spacing/struts
  space = setScreenSpacingEnabled True
  invisible t = setTheme t{decoHeight=0,decoWidth=0}
  visible     = setTheme
  setTheme t = broadcastMessage $ SetTheme t
  withWorkspace f = withWindowSet $ \w -> f $ show $ W.currentTag w
  focus'WS f = withWindowSet $ \w -> whenJust (W.peek w) $ f withWorkspace
--}
--{- easy read/write functions
withTag   :: (String -> X a) -> X a
withTheme :: (Theme  -> X a) -> X a
setTag    ::  String -> X ()
setTheme  ::  Theme  -> X ()

withTag   f = XS.get >>= \(Conf (tg,_)) -> f tg
withTheme f = XS.get >>= \(Conf (_,t )) -> f t
setTag   tg = withTheme  \t  -> XS.put $ Conf (tg, t)
setTheme  t = withTag    \tg -> XS.put $ Conf (tg, t)

enabled :: Window -> X Bool
enabled _ = XS.get >>= \(State (_,b)) -> return b

query :: Query Bool
query = ask >>= liftX . enabled
--}
--{- quality of life functions
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
--}
--{- plumbing
data Conf = Conf (String, Theme) deriving (Show,Read)
instance ExtensionClass Conf where
 initialValue = Conf ("FS", def Theme)
 extensionType = PersistentExtension

data State = State (String, Bool) deriving (Show,Read)
instance ExtensionClass State where
 initialValue = State ("", False)
 extensionType = PersistentExtension

borderState :: Bool -> Window -> X ()
borderState bool w =
  withDisplay . (\b d -> io $ setWindowBorderWidth d w b)
  =<< if bool
  then asks $ borderWidth . config
  else return (0 :: Dimension)
--}
