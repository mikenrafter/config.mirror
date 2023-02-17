{-# LANGUAGE BlockArguments, RecordWildCards #-}
module Custom.Grid where
--{- imports
--{- globals
import Custom.Vars
import qualified Custom.Prompts as Prompt
import Custom.Prompts (prompts)
--}
--{- standard
import XMonad hiding (config)
import System.Random (randomRIO, randomR)
--}
--{- actions
import XMonad.Actions.GridSelect hiding (select)
import qualified XMonad.Actions.GridSelect as G
import XMonad.Actions.WindowMenu
--}
--{- data
import Data.Bool
import Data.String
--port Data.Random.List (randomElement)
--}
import Debug.Trace
--}
--{- gridselect config
height = 50
width  = height * 2
--nfig :: Colors -> GSConfig a
config (Z{..}) =
 (buildDefaultGSConfig $ colorizer colors)
  { gs_cellheight   = height
  , gs_cellwidth    = width
  , gs_cellpadding  = 7
  , gs_originFractX = 0.5
  , gs_originFractY = 0.5
  , gs_font         = font
  }
--}
--{- grid mappings
grids (Z{..}) =
{-
-- [ ("W | bring"  , bringSelected config) -- bring selected window
-- , ("W | goto"   , goToSelected  config) -- goto selected window
-- , ("W | Conf"   , windowMenu          ) -- window management menu
-- , ("X | Conf"   , custom spawn configs) -- my configs
-- , ("X | Apps"   , custom ($"") apps   ) -- my apps
-- , ("X | Prompts", custom ($pc) prompts) -- my prompts
-- ] where pc = Prompt.config
--}
 [ ("W | bring"  , item $ bringSelected cfg) -- bring selected window
 , ("W | goto"   , item $ goToSelected  cfg) -- goto selected window
 , ("W | Conf"   , item $ windowMenu       ) -- window management menu
 , ("X | Conf"   , submenu id    configs   ) -- my configs
 , ("X | Apps"   , submenu id    faves     ) -- my apps
 , ("X | Prompts", submenu ($pc) prompts   ) -- my prompts
 ] where
   pc = Prompt.config settings
   submenu = sub settings
   cfg = config settings
--{- utility functions

-- generic menu
menu settings back action items = gridselect (config settings) items >>= \x -> traceShow "MENU" $ maybe back action x
-- nestable submenus
nest settings items = menu settings (return False)
  (>>= \x -> if x then return True else nest settings items) items
-- False -> non- / selected <- True
sub settings = menu settings (return False) . ((>> return True) .)
-- allows mixing submenus & single items
item = (>> return True)
-- used to make any nested menus usable outside
bare :: X a -> X ()
bare = (>> return ())

--stom :: Colors -> (a -> X ()) -> [(String, a)] -> X ()
custom = flip menu $ pure ()

colorizer :: Colors -> a -> Bool -> X (String, String)
colorizer colors _ active = do
 fg <- liftIO $ aFG colors
 bg <- liftIO $ aBG colors
-- fg <- return "#8fc"
-- bg <- return "#333"
 return if active
  then (fg, bg)
  else (bg, fg)

--}
--}
{- references
--}

