import Data.Char (toUpper, isUpper)
-- functiile sunt valori
-- !functiile nu pot fi comparate
ap n f = if (n<=0) then id else (f . (ap (n - 1) f))

exemplu = ap 3 (\x -> x * x) 4
exemplu' = ap 3 (\(x,y) -> (x * x, y + y)) (4, 5)

-- scrieti o functie care scrie un sir de caractere cu litere mari
scrieLitereMari s = map toUpper s

-- scrieti o fc care selecteaza dintr-o lista de cuvinte pe cele
-- care incep cu litera mare
incepeLM xs = filter (\x -> isUpper (head x)) xs

-- scrieti o functie care calculeaza secventa Collatz care incepe
-- cu n
collatz  :: (Integral a)=> a -> [a]
collatz xn | xn <= 0 = []
           | even xn  = (xn `div` 2) : collatz (xn `div` 2)
           | odd xn = (3 * xn `div` 2) : collatz (3 * xn `div` 2)
           | otherwise = [xn]

collatz' n
      | n == 1 = [1]
      | n > 1  = n : collatz' (next n)
      where next x | even x = x `div` 2
                   | otherwise = 3 * x + 1

-- determinati secventele Collatz de lungime <= 5 care incepe cu 5
-- un numar din intervalul [1,100]

secvCollatz = filter (\x -> length x <= 5) (map collatz [1..100])
            
-- foldr si foldl
myfoldr :: (a -> b -> b) -> b -> [a] -> b
myfoldr f i [] = i
myfoldr f i (x:xs) = f x (myfoldr f i xs) 

myfoldl :: (b -> a -> b) -> b -> [a] -> b
myfoldl h i [] = i
myfoldl h i (x : xs) = foldl h (h i x) xs

-- proprietatea de universalitate
{-
g [] = i
g (x : xs) = f x (g xs)

<=>

g = foldr f i
-}

-- compunerea functiilor
compose :: [a -> a] -> (a -> a)
compose = foldr (.) id

-- sum cu foldr de la stg la dr ???
sum' :: [Int] -> Int
sum' xs = foldr (+) 0 (reverse xs)

-- sum cu acumulator
sum :: [Int] -> Int
sum xs = suml xs 0
         where suml [] acc = acc
               suml (x : xs) acc = suml xs (x + acc)

-- definirea suml cu foldr
-- proprietatea de universalitate
{-
g [] = i
g (x : xs) = f x (g xs)

<=>

g = foldr f i
-}
{-
Observam ca 
suml [] = id -- suml [] n = ns

Vrem sa gasim f astfel incat
suml (X:xs) = f x (suml xs), deoarece din proprietatea de universalitate
va rezulta ca
suml = foldr f id

suml (x:xs) = f x (suml xs) (vrem)
suml (x:xs) n = f x (suml xs) n (vrem)
suml xs (n + x) = f x (suml xs) n (def suml)

Notand u = suml xs, obtinem u (n + x) = f x u n

Solutie:
f = \ x u n -> u (n + x)
suml = foldr (\x u -> f x u) id
suml = foldr (\x u -> (\n -> u (n + x))) id 
suml = foldr (\x u n -> u (n + x)) id
-}

-- Definirea sum cu foldr
sum xs = foldr (\x u n -> u (n + x)) id xs 0
-- sum xs = suml xs 0

-- Inversarea elementelor unei liste
-- sol cu foldl
rev' :: [a] -> [a]
rev' = foldl (<:>) []
      where (<:>) = flip (:)

-- Scrieti o definitie a functiei rev folosind foldr
rev :: [a] -> [a]
rev xs = revl xs []
      where
            revl [] l = l
            revl (x:xs) rxs = revl xs (x:rxs)


{-
-- proprietatea de universalitate
g [] = i
g (x : xs) = f x (g xs)

<=>

g = foldr f i

Observam ca revl [] = id -- revl [] l = l
Vrem sa gasim f astfel incat
revl (x:xs) = f x (revl xs), deoarece, din proprietatea de
universalitate, va rezulta ca
revl = foldr f id

revl (x:xs) = f x (revl xs) (vrem)
revl (x:xs) xs' = f x (revl xs) xs' (vrem)
revl xs (x:xs') = f x (revl xs) xs' (def revl)
Notand u = revl xs, obtinem u (x : xs') = f x u xs'
Solutie:
! Examen dam o fc deja def si o scriem cu foldr/foldl
rev cu foldl
f = \ x u xs' -> u (x:xs')
revl :: [a] -> ([a] -> [a])
revl = foldr (\x u -> f x u) id
revl = foldr (\x u -> (\xs' -> u (x : xs'))) id
revl = foldr (\x u n -> u (x:xs')) id
tipurile sunt determinate corespunzator
-}

rev'' :: [a] -> [a]
rev'' xs = foldr (\x u xs' -> u (x:xs')) id xs []
-- rev xs = revl xs []

-- foldl
myfoldl' h i xs = foldl' h xs i
      where 
            foldl' h [] i = i
            foldl' h (x:xs) i = foldl' h xs (h i x)

-- foldl cu foldr
{-
foldl' h [] = id -- suml [] n = n,
deci g din th de univ va fi (foldl' h). Vrem sa gasim f a.i.
foldl' h (x:xs) = f x (foldl' h xs), deoarece, din proprietatea de
universalitate, va rezulta ca foldl' h = foldr f id

Obs ca functiile au urmatoarele signaturi:
myfoldl' h :: [a] -> (b -> b)
id :: b -> b
f :: a -> (b -> b) -> (b -> b)
unde h :: b -> a -> b
myfoldl' h (x:xs) = f x (foldl' h xs) (vrem)
myfoldl' h (x:xs) i = f x (foldl' h xs) i (vrem)
myfoldl' h xs (h i x) = f x (foldl' h xs) (def foldl')

Notand u = myfoldl' h xs, obtinem u (h i x) = f x u i

Deoarece am dedus ca f :: a -> (b->b) -> (b->b) vom defini
f = \x u -> \i -> u (h i x)

Solutie:
h :: b -> a -> b
myfoldl' h = foldr f id
f = \x u -> \y -> u (h y x)

myfoldl h i xs = myfoldl' h xs i
-}
myfoldl'' h i xs = foldr (\x u -> \y -> u (h y x)) id xs i

{-
ghci> myfoldl'' (+) 0 [1,2,3]
6
ghci> let sing = (:[])
ghci> take 3 (foldr (++) [] (map sing [1..]))
[1,2,3]
ghci> take 3 (myfoldl'' (++) [] (map sing [1..]))
^CInterrupted.
ghci> take 3 (myfoldl'' (++) [] (map sing [1..]))
^CInterrupted.
ghci>
Ce se intampla?
fold nu functioneaza cu liste infinite
-}

primes = sieve [2..]
sieve (p : ps) = p : sieve [x | x <- ps, x `mod` p /= 0]