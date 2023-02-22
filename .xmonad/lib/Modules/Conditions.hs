-- intended to be imported as Qualified
module Modules.Conditions
  ( condition, when
  , get, set, toggle
  , Conditions(..)
  ) where
--{- imports
import XMonad (X(..))
import XMonad.Core (ExtensionClass(..), StateExtension(PersistentExtension))
import qualified XMonad.Util.ExtensibleState as XS
import Data.Map as M
import Data.Maybe (fromMaybe)
--}
--{- observers
condition :: String -> X Bool
condition key =
  XS.get >>= \(Conditions conditions) ->
  return $ fromMaybe False $ M.lookup key conditions
when key a =
  condition key >>= \c ->
  if c then a else pure ()
--}
--{- main functions
get = condition
set :: String -> Bool -> X ()
set key value =
  XS.get >>= \(Conditions conditions) ->
  XS.put $ Conditions $ insert key value conditions
toggle :: String -> X Bool
toggle key = get key >>= \v -> let n = not v in set key n *> return n
--}
--{- plumbing
data Conditions = Conditions (Map String Bool) deriving (Show,Read)
instance ExtensionClass Conditions where
 initialValue = Conditions empty
 extensionType = PersistentExtension
--}
