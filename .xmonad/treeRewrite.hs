--ghc treeRewrite.hs && clear && ./treeRewrite #
import XMonad
import XMonad.StackSet

joins a b = concat $ head b : [ a <> x | x <- tail b ]
mapShow a = joins ", " $ map show a

data Parent l a =
 Parent
 {
   attributes :: [([Char],[Char])]
 , layout     :: l a
 , stack      :: Stack (Tree l a)
 }
--  deriving (Show,Read,Eq)

instance Show a => Show (Parent l a) where
 show (Parent attr lay stax) = "Parent {"<>show attr <>", layout = {...}, "<> show stax<>"}"

--instance Show a => Show (Tree l a) where
-- show (General a b) = mapShow [a,b]
-- show (Win a b c) = mapShow [a,b,c]
-- show (Draw a b c d e f g) = mapShow [a,b,c,d,e,f,g]

-- Maybe split these all up? Probably...
data Tree l a =
 Leaf
 | Root
 { rootLeaf       :: Parent l a
 --, rootEvents     :: Events
 , ignoredHandler :: String -- X()
 , ignored        :: [Tree l a]
 }
 | Workspace
 | General
 {
   parent :: Parent l a
 , typeID :: Int
 }
 | Win
 {
   windowAttrs  :: [(String,String)]
 , xWindowAttrs :: [(String,String)]
 , id           :: Int
 }
 | Draw
 {
   -- temporary - for testing - String, instead of X ()
   transparent :: Bool
 , focusable   :: Bool
 , method      :: String -- X ()
 , child       :: Int -- Maybe (Tree l a)
 , drawAttrs   :: [(String,String)]
 , bounds      :: (Int,Int,Int,Int) -- X,Y W,H
 , function    :: String -- X ()
 }
 deriving (Show)
--eriving (Show,Read,Eq)


-- the tall layout, as an example
tall :: Stack (Tree Tall Window) -> Tree Tall Window
tall s = General (Parent [("empty","attribute")] (Tall 1 1 1) s) 1

-- example for a generic window
exampleWin :: Tree Tall Window
exampleWin = Win [("title","example")] [] 123456

-- example for xmobar
exampleXbar :: Tree Tall Window
exampleXbar = Draw False False "top" 654321 [] (0,0,1920,16) "drawChild"

main = do print
 $ tall $ Stack (exampleWin)
                [exampleXbar, (tall $ Stack (exampleWin) [] [])]
                []
-- tall $ Stack (Win [] 1) [] []

