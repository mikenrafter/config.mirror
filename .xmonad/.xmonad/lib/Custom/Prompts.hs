{-# LANGUAGE BlockArguments, TupleSections, RecordWildCards #-}
module Custom.Prompts where
--{- imports
--{- globals
import qualified Custom.Vars as V
import Custom.Vars hiding (font)
import Utility.Map
--}
--{- standards
import XMonad hiding (config)
import qualified Data.Map as M
import qualified XMonad.Actions.Search as S
import qualified XMonad.StackSet as W
--}
--{- data
import Control.Arrow (first)
import Data.Char (isSpace)
--}
--{- prompt
import XMonad.Prompt
import XMonad.Prompt.FuzzyMatch
import XMonad.Prompt.Man
import XMonad.Prompt.XMonad
import XMonad.Prompt.RunOrRaise
import XMonad.Prompt.Shell
--}
{- misc
 import XMonad.Util.EZConfig (additionalKeysP)
 import XMonad.Prompt.Input  -- for custom prompts
 import XMonad.Util.Run (runProcessWithInput, safeSpawn, spawnPipe)  -- for custom prompts
--}
--}
--{- config
config' (Z{..}) = (config settings) { autoComplete = Nothing }
config  (Z{..}) = def
  { font                = V.font
  , bgColor             = bg 0
  , fgColor             = fg 0
  , bgHLight            = bg 0
  , fgHLight            = fg 1
  , borderColor         = bg 2
  , promptBorderWidth   = 2
  , promptKeymap        = promptKeys -- vimLikeXPKeymap
  , position            = Bottom -- CenteredAt { xpCenterY = 0.025, xpWidth = 1 } -- Top
  , height              = 18
  , historySize         = 256
  , historyFilter       = id
  , defaultText         = []
  , autoComplete        = Just 250000 -- .25s  -- 10^5 -> .1s
  , completionKey       = (0, xK_Tab )
  , showCompletionOnTab = False
  , sorter              = fuzzySort
  , searchPredicate     = fuzzyMatch -- isPrefixOf
  , alwaysHighlight     = True
  , maxComplRows        = Just 10 -- Nothing
  }
--}
--{- keymap
--TODO: EZConfig
promptKeys =
 M.fromList $
 map (first (controlMask,))   -- control + <key>
 [ (xK_v        ,  pasteString)
 , (xK_Right    ,  moveWord Next)
 , (xK_Left     ,  moveWord Prev)
 , (xK_BackSpace,  killWord Prev)
 , (xK_Delete   ,  killWord Next)
 ]
 <>
 map (first (0,)) -- <key>
 [ (xK_Return   , setSuccess True >> setDone True)
 , (xK_KP_Enter , setSuccess True >> setDone True)
 , (xK_BackSpace, deleteString Prev)
 , (xK_Delete   , deleteString Next)
 , (xK_Left     , moveCursor Prev)
 , (xK_Right    , moveCursor Next)
 , (xK_Home     , startOfLine)
 , (xK_End      , endOfLine)
 , (xK_Down     , moveHistory W.focusUp')
 , (xK_Up       , moveHistory W.focusDown')
 , (xK_Escape   , quit)
 ] -- `additionalKeysP` [("M-a", setSuccess True >> setDone True)]

--}
-- prompts
pair = zipWith $ flip (,) . snd
--{- misc
miscMap = bound $ pair misc'
 [ ["m"  ]
 , ["/"  ]
 , ["S-/"]
 ]
--TODO: homegrow these to say man/insist/run instead of runOrRaise/etc
misc@misc' =
 [ ("man"   ,        manPrompt)
 , ("insist", runOrRaisePrompt)
 , ("run"   ,      shellPrompt)
 ]
--}
--{- search engines
engineMap = bound $ pair engines
 [ ["<Space>", "1"]
 , ["y"      , "2"]
 , ["a"      , "3"]
 , ["h"      , "4"]
 , ["w"      , "5"]
 , ["u"      , "6"]
 ]
engines' =
 [ ("ddg"   , "ddg.gg/?q="                          )
 , ("yt"    , "youtube.com/results?search_query="   )
 , ("arch"  , "wiki.archlinux.org/index.php?search=")
 , ("hoogle", "hoogle.haskell.org/?hoogle="         )
 , ("news"  , "ddg.gg/?ia=news&iar=news&q="         )
 , ("slang" , "urbandictionary.com/define.php?term=")
 ]
engines = for engines' \(t,u) -> (t, flip S.promptSearch $ S.searchEngine t u)
--}

promptMap = concat [engineMap,miscMap]
prompts   = concat [engines  ,misc   ]

{- references
--}

