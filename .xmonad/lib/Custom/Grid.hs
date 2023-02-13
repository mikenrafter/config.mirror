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
import XMonad.Actions.GridSelect hiding (select)
import qualified XMonad.Actions.GridSelect as G
import XMonad.Actions.WindowMenu
--}
--{- data
import Data.Bool
import Data.String
--port Data.Random.List (randomElement)
--}
--}
--{- gridselect config
height = 50
width  = height * 2
config :: Colors -> GSConfig a
config colors =
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
grids colors =
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
 , ("X | Conf"   , submenu spawn configs   ) -- my configs
 , ("X | Apps"   , submenu ($"") apps      ) -- my apps
 , ("X | Prompts", submenu ($pc) prompts   ) -- my prompts
 ] where
   pc = Prompt.config
   submenu = sub colors
   cfg = config color
--{- utility functions

-- generic menu
menu colors back action items = gridselect (config colors) items >>= maybe back action
-- nestable submenus
nest colors items = menu colors (return False)
  (>>= \x -> if x then return True else nest colors items) items
-- False -> non- / selected <- True
sub colors = menu colors (return False) . (>> return True)
-- allows mixing submenus & single items
item = (>> return True)
-- used to make any nested menus usable outside
bare = (>> return ())

custom :: Colors -> (a -> X ()) -> [(String, a)] -> X ()
custom = flip menu $ pure ()

colorizer :: Colors -> a -> Bool -> X (String, String)
colorizer colors _ active = do
 fg <- aFG colors
 bg <- aBG colors
 return if active
  then (fg, bg)
  else (bg, fg)

--}
--}
{- references
--}

