module Utility.Map where
subfix = map . prefix
prefix mod (k,a) = (mod<>k,a)
-- main modifier/combo
leader = map $ prefix lead
lead = mm

-- modifier strings
mm = "M-"
ma = "M1-"
mc = "C-"
ms = "S-"

-- TODO - performance minded version of <any/greedy-Modifier> in core+EZConfig
-- this would prevent the need to make duplicates like [M-k k, M-k M-k,
-- (or) M-S-k k, M-S-k S-k, M-S-k M-S-K, M-S-k M-M1-S-k, M-S-k M-C-M1-S-k]
-- common want, yet requires many "new" keybinds to meet this desire...
-- wasting memory, degrading performance, and increasing compilation time

-- optional modifier on second chord piece
held mod one (two,a) = dupe [one<>" "<>m<>two | m <- ["",mod]] a
-- map held
hold mod one         = concat . map (held mod one)

-- every possible combination, given modifiers
factor = getAp . foldMap Ap . fmap (:[""])

-- factorial of binds and modifiers
multi mods binds = [ (m<>k,a) | (k,a) <- binds, m <- mods ]
-- accepts any modifier
greedy = multi $ factor [ma,mc,ms]

-- many keybinds -> one action
dupe list action = (,action) <+> list
-- map dupe
bound = concat . map (uncurry dupe)
-- adds a suffix to elements being used in `bound`
boundSuffix suffix = map \l, a -> (map (<>suffix) l,a)

-- [binds] <--> [actions], maps them 1-1
bind mod = zipWith \k a -> (mod<>k,a)
