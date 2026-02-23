import Data.Char (digitToInt, isDigit)

-- listele sunt reprezentate inductiv 
-- ([], (:)) [] lista vida, : adaugarea unui element la lista 
-- (x:xs) x este head, xs este tail 

-- [1..10] -> creeaza lista [1, 2, 3, ..., 10]
-- [2,4..20] -> [2, 4, 6, 8, ... 20]
-- [3,6,...,19] -> [3, 6, 9, 12, 15, 18]
-- [0..] -> creeaza lista infinita [0,1,2,...,....,.............]

-- 1. a.
removeOddHalfEven :: [Int] -> [Int]
removeOddHalfEven [] = []
removeOddHalfEven (x:xs)
    | even x = (x `div` 2) : removeOddHalfEven xs
    | otherwise = removeOddHalfEven xs

-- ex 1 b
removeOddHalfEvenb :: [Int] -> [Int]
removeOddHalfEvenb l =
    map (`div` 2)
    $ filter even l

-- ex 1 c
removeOddHalfEvenc :: [Int] -> [Int]
removeOddHalfEvenc list =
    [ x `div` 2 | x <- list, even x]

-- 2 a
multDigits :: String -> Int
multDigits [] = 1
multDigits (x:xs)
    | isDigit x = digitToInt x * multDigits xs
    | otherwise = multDigits xs

-- 2 b
multDigitsb :: String -> Int
multDigitsb list = product
   $ map digitToInt
   $ filter isDigit list

-- 2 c
multDigitsc :: String -> Int
multDigitsc list = product
    [digitToInt c | c <- list, isDigit c]

-- 3
doubleOddLt :: [Int] -> Int -> [Int]
doubleOddLt [] _ = []
doubleOddLt (x:xs) n
    | odd x && x < n = (2 * n) : doubleOddLt xs n
    | otherwise = doubleOddLt xs n

-- 6
doubleOddLtfold :: [Int] -> Int -> [Int]
doubleOddLtfold = foldr
    (\x u n -> if (odd x && x < n)
               then (2*x) : u n
               else u n) (\_ -> [])

-- 4
sumEvenElemOddPos :: [Int] -> Int
sumEvenElemOddPos list = sum -- foldr (+) 0
    $ map (\(elem, _) -> elem)
    $ filter (\(elem, index) -> even elem && odd index)
    $ zip list [0..]

-- 5: tema
vocale :: [Char]
vocale = "aeiou"

-- Exercitiul 6 
-- consideram doubleOddLTn si o transformam in foldr 
 
{-
    Avem un algoritm pentru transformare
 
    Pasul 0: scriem functia in forma recursiva 
 
    doubleOddLTn :: [Int] -> Int -> [Int]
    doubleOddLTn [] _ = [] 
    doubleOddLTn (x:xs) n 
        | odd x && x < n    = (2 * x) : doubleOddLTn xs n 
        | otherwise         = doubleOddLTn xs n 
 
    Scopul este sa aducem aceasta functie in forma proprietatii de universalitate 
 
    DACA 
        g [] = init 
        g (x:xs) = f x (g xs)
    ATUNCI 
        g = foldr f init 
 
    Pasul 1: redenumim functia doubleOddLTn cu g 
    g [] _ = [] 
    g (x:xs) n 
        | odd x && x < n    = (2 * x) : g xs n 
        | otherwise         = g xs n 
 
    Pasul 2: schimbam din guards in if-then-else
    g [] _ = []
    g (x:xs) n = if (odd x && x < n) then (2 * x) : g xs n else g xs n 
 
    Pasul 3: aplicam currying si uncurrying 
    g [] = \_ -> []
    g (x:xs) = \n -> if (odd x && x < n) then (2 * x) : g xs n else g xs n 
 
    Pasul 4: aplicam proprietatea de universalitate 
    am gasit deja ca init = \_ -> [] 
    g (x:xs) = f x (g xs)
    g (x:xs) = \n -> if (odd x && x < n) then (2 * x) : g xs n else g xs n 
    deci 
    f x (g xs) = \n -> if (odd x && x < n) then (2 * x) : g xs n else g xs n 
 
    Pasul 5: redenumim g xs = u (APROAPE DE FIECARE DATA)
    f x u = \n -> if (odd x && x < n) then (2 * x) : u n else u n 
        ^                                            ^        ^
 
    Pasul 6: extragem functia f 
    f = \x -> \u -> \n -> if (odd x && x < n) then (2 * x) : u n else u n 
 
    pe care o putem scrie mai frumos 
    f = \x u n -> if (odd x && x < n) then (2 * x) : u n else u n 
 
    in acest moment, avem f si init, deci putem scrie g = foldr f init 
-}
 
doubleOddLTnFoldr :: [Int] -> Int -> [Int]
doubleOddLTnFoldr = foldr (\x u n -> if (odd x && x < n) then (2 * x) : u n else u n) (\_ -> [])

{-
0.
removeOddHalfEven [] = []
removeOddHalfEven (x:xs)
    | even x = (x `div` 2) : removeOddHalfEven xs
    | otherwise = removeOddHalfEven xs

1. 
g [] = []
g (x:xs)
    | even x = (x `div` 2) : g xs
    | otherwise = g xs

2.
g [] = []
g (x:xs) = if even x then (x `div` 2) : g xs else g xs

3.
g [] = \_ -> []
g (x:xs) = if even x then (x `div` 2) : g xs else g xs

4.
init = \_ -> []
f x (g xs) = if even x then (x `div` 2) : g xs else g xs

5. 
g xs = u
f x u = if even x then (x `div` 2) : u else u

6.
f = \x u -> if even x then (x `div` 2) : u else u
Obs: da err la init asa ca punem doar [] 
-}

removeOddHalfEvenFoldr :: [Int] -> [Int]
removeOddHalfEvenFoldr = foldr (\x u -> if even x then (x `div` 2) : u else u) []
test xs = removeOddHalfEven xs == removeOddHalfEvenFoldr xs

{-
0.
multDigits :: String -> Int
multDigits [] = 1
multDigits (x:xs)
    | isDigit x = digitToInt x * multDigits xs
    | otherwise = multDigits xs

1.
g [] = 1
g (x:xs)
    | isDigit x = digitToInt x * g xs
    | otherwise = g xs

2.
g [] = 1
g (x:xs)
    | isDigit x = digitToInt x * g xs
    | otherwise = g xs

3. 
g [] = 1
g (x:xs) = if isDigit x then digitToInt x * g xs else g xs

4. 
init = 1
f x (g xs) = if isDigit x then digitToInt x * g xs else g xs

5.
f x u = if isDigit x then digitToInt x * u else u

6.
f = \x u -> if isDigit x then digitToInt x * u else u
-}

multDigitsFoldr :: String -> Int
multDigitsFoldr = foldr (\x u -> if isDigit x then digitToInt x * u else u) 1

vowelOnly :: [String] -> [String]
vowelOnly = map (filter (`elem` vocale))

-- 7
data LList a = Nil | Cons a (LList a)

l1 :: LList Int
l1 = Cons 1 $ Cons 2 $ Cons 3 $ Nil

instance Show a => Show (LList a) where
    show Nil = "[]"
    show (Cons x xs) = "[" ++ show x ++ "|" ++ show xs ++ "]"

instance Eq a => Eq (LList a) where
    Nil == Nil                   = True
    (Cons x xs) == (Cons x' xs') = x == x' && xs == xs'

lAppend :: LList a -> LList a -> LList a
lAppend Nil l2 = l2
lAppend (Cons x xs) l2 = Cons x (lAppend xs l2)

instance Semigroup (LList a) where
    (<>) :: LList a -> LList a -> LList a
    (<>) = lAppend

instance Monoid (LList a) where
    mempty :: LList a
    mempty = Nil

-- 7 d
lFilter :: (a -> Bool) -> LList a -> LList a
lFilter _ Nil = Nil
lFilter pred (Cons x xs)
    | pred x = Cons x $ lFilter pred xs
    | otherwise = lFilter pred xs

lMap :: (a -> b) -> LList a -> LList b
lMap _ Nil = Nil
lMap f (Cons x xs) = Cons (f x) $ lMap f xs

lFoldr :: (a -> b -> b) -> b -> LList a -> b
lFoldr _ i Nil = i
lFoldr f i (Cons x xs) = f x $ lFoldr f i xs

-- 7 e
lToList :: LList a -> [a]
lToList Nil = []
lToList (Cons x xs) = x : lToList xs

-- 8 a
data Point a b = Pt a b

instance (Show a, Show b) => Show (Point a b) where
    show (Pt a b) = "(" ++ show a ++ ", " ++ show b ++ ")"  

instance (Eq a, Eq b) => Eq (Point a b) where
    (Pt a1 b1) == (Pt a2 b2) = a1 == a2 && b1 == b2

-- b
lZip :: LList a -> LList b -> LList (Point a b)
lZip (Cons x xs) (Cons y ys) = Cons (Pt x y) (lZip xs ys)
lZip _ _ = Nil