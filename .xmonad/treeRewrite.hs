--ghc treeRewrite.hs && clear && ./treeRewrite #
import XMonad
import XMonad.StackSet

data Common l a =
 Common
 {
   attributes :: [([Char],[Char])]
-- attributes :: [(String,String)]
 , layout     :: l a
 , stack      :: Stack (Tree l a)
 }
--  deriving (Show,Read,Eq)

instance Show a => Show (Common l a) where
 show (Common attr lay stax) = show attr <>", layout = {...}, "<> show stax

data Tree l a =
 Leaf
-- | Root
-- | Workspace
 | General
 {
   common :: Common l a
 , typeID :: Int
 }
 | Win
 {
   xAttribute :: [(String,String)]
 , id         :: Int
 }
 deriving (Show)
--eriving (Show,Read,Eq)


tall :: Stack (Tree Tall Window) -> Tree Tall Window
tall s = General (Common [("empty","attribute")] (Tall 1 1 1) s) 1

main = do print
 $ tall $ Stack (Win [("title","example")] 39828) [] []
-- tall $ Stack (Win [] 1) [] []

--instance Show a => Show (Tree l) where
--  show Leaf = "Leaf"
--  show (General tid _ attrs up f dn) = "do something with those fields"

