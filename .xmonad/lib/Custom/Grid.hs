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
mgrids =
 [ ("<Backspace>", bringSelected gsconfig)  -- bring selected window
 , ("]", custom spawn mconfigs)             -- my configs
 , ("\\", custom spawn mapps)               -- my apps
 , ("<Return>", goToSelected gsconfig)      -- goto selected window
 ]
-- mallGrids =
--  [ "=", nest (pure ()) (
--  \x -> head $ lFilter mgrids x
--  ) mgrids
--  ]
--}
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
mgrids :: [(String, X ())]
custom :: (String -> X ()) -> [(String, String)] -> X ()
--rand :: (MonadIO m) => [a] -> m a
--rand :: liftIO
--rand :: [String] -> IO String
rand :: [a] -> IO a
colors :: a -> Bool -> X (String, String)
--}

{- references
--}

