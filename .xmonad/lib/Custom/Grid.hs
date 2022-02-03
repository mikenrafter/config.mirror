{-# LANGUAGE BlockArguments #-}
module Custom.Grid where
--{- imports
--{- globals
import Custom.Vars
--}
--{- standard
import XMonad
import System.Random (randomRIO, randomR)
--}
--{- actions
import XMonad.Actions.GridSelect
import XMonad.Actions.WindowMenu
--}
--{- data
import Data.Bool
import Data.String
import Data.Random.List (randomElement)
--}
--}
--{- gridselect config
mgsh = 50
mgsw = mgsh * 2 -- (mgsh * 8) `div` 4 -- int version of (* 1.5)
gsconfig =
 (buildDefaultGSConfig colors)
  { gs_cellheight   = mgsh
  , gs_cellwidth    = mgsw
  , gs_cellpadding  = 7
  , gs_originFractX = 0.5
  , gs_originFractY = 0.5
  , gs_font         = mfont
  }
--}
--{- grid mappings
mgrids' =
 [ ("W.bring", bringSelected gsconfig)  -- bring selected window
 , ("W.goto",  goToSelected gsconfig)   -- goto selected window
 , ("W.Conf",  windowMenu)              -- window management menu
 , ("X.Conf",  custom spawn mconfigs)   -- my configs
 , ("X.Progs", custom spawn mapps)      -- my apps
 ]
mgrids =
 flip custom grids \x->snd $ mgrids'!!x
 where grids = zip (map fst mgrids') [0..]
--{- utility functions
nest prev next items = gridselect gsconfig items >>= maybe prev next
custom = nest $ pure ()
rand l = (l!) <$> randomRIO (1, length l)
colors _ active = do
 fg <- liftIO $ rand fg'
 bg <- liftIO $ rand bg'
 if active
  then return (fg, bg)
  else return (bg, fg)
--}
--{- type definitions
gsconfig :: GSConfig a
custom :: (a -> X ()) -> [(String, a)] -> X ()
--custom :: (String -> X ()) -> [(String, a)] -> X ()
--nest :: X () -> (String -> X ()) -> [(String, X ())] -> [Char]
--rand :: (MonadIO m) => [a] -> m a
--rand :: liftIO
--rand :: [String] -> IO String
rand :: [a] -> IO a
colors :: a -> Bool -> X (String, String)
--}

{- references
--}

