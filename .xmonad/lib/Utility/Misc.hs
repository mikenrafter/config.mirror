module Utility.Misc where
--{- flip
-- move last of n to start (0..)
-- N:1 -> 1:N
--ip1 = flip
flip2 :: (a -> b -> c -> o)           -> b -> c -> a           -> o
flip2 = (.) flip  . flip
flip3 :: (a -> b -> c -> d -> o)      -> b -> c -> d -> a      -> o
flip3 = (.) flip2 . flip
flip4 :: (a -> b -> c -> d -> e -> o) -> b -> c -> d -> e -> a -> o
flip4 = (.) flip3 . flip
-- ...
--}

--{- plif
-- move first to n (0..)
-- 1:N -> N:1
--if1 = flip
plif2 :: (a -> b -> c -> o)           -> c -> a -> b           -> o
plif2 = flip . (flip  .)
plif3 :: (a -> b -> c -> d -> o)      -> d -> a -> b -> c      -> o
plif3 = flip . (plif2 .)
plif4 :: (a -> b -> c -> d -> e -> o) -> e -> a -> b -> c -> d -> o
plif4 = flip . (plif3 .)
-- ...
--}
