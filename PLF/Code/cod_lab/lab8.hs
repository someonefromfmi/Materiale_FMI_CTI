{-
    Lab8: Programare funcionala - Haskell

Haskell 
    - limbaj care introduce paradigma prog func
    - functiile sunt operatori principali
    - nu avem nevoie de paranteze in mom in care apelam fc
    - f(x) -> in Haskell este f x
    - g(x, y) -> in Haskell (g x y)

    - putem scrie functii
    - putem evalua fc/expr respective
    - ne intereseaza si tipul acestor fc 

    - avem o clasa a tipului numeric, Num
    - pt clasa Num, avem Int, Integer, Double, Float etc
    - putem compune expr aritmetice, utilizand +,-,
     /(exacta,double), *, ** (double), ^(Int), `mod`, 
     `div`
    - mod 5 3 este echivalent cu 5 `mod` 3 REST
    - div 5 3 este echiv cu 5 `div` 3 CAT

    - putem defini variab si le putem asigna o val
    - x = 3
    - x
    - > 3
    - intr-un program, insa variab nu sunt mutabile
    - Bool: True, False
    - && - and
    - || - or

    - definim o functie
    - <function_name> [<args>]* = <function_body>
-}

myInt = 55555555555555555555555555555555555555555555

double :: Num a => a -> a
double x = x + x

-- pt a incarca programul, folosim :l (load)
-- instante de Num(variabile de tip): Int, Integer, Double
-- :r - reload

add :: Int -> Int -> Int
add x y = x + y

-- currying/uncurrying
{-
    add :: Int -> Int -> Int 
    add :: Int -> Int (este o partitie a functiei add
        care primeste un argument x si returneaza x + 2)
    add :: Int 
    
    - :t (add 3 5) este Int
    - aceste procese sn currying/uncurrying

-}

maxim :: Int -> Int -> Int
maxim x y = if x > y then x else y 


maxim' :: Int -> Int -> Int
maxim' x y 
    | x > y = x
    | otherwise = y

-- punem mereu otherwise pe case ul default

-- Liste
-- structuri de date care pot retine elemente de
-- acelasi tip
-- au aceeasi scriere ca in prolog: [1, 2, 3]
-- exact ca in prolog listele sunt definite INDUCTIV
-- cazul de baza: list vida este []
-- cazul recursiv: (h:t), dar preferam in Haskell (x:xs)

-- suma elementelor dintr-o lista

sumList :: [Int] -> Int
sumList [] = 0                  -- cazul de baza
sumList (x:xs) = x + sumList xs -- cazul recursiv

-- sumList' :: [Int] -> Int
-- sumList' list 
--     | list == [] = 0
--     | list == (x:xs) = x + sumList' xs

-- avem predefinita fc zip :: [a] -> [b] -> [(a, b)]
-- zip [1, 2, 3] [4, 5, 6] <=>  [1, 2, 3] `zip` [4, 5, 6]
-- daca avem o pereche (a, b), primul elem se acceseaza cu fst
-- iar al doilea cu snd

-- 1.
sumThree :: Int -> Int -> Int -> Int
sumThree x y z = x + y + z

-- 2
maxFour :: Int -> Int -> Int -> Int -> Int
maxFour x y z w = maxim x $ maxim y $ maxim z w

-- $: operator de aplicare, asociativ la dreapta
-- g $ z t este g (z t)

-- pt a nu scrie mereu tipurile explicit
-- putem defini functiile cu signaturi peste clase de tipuri
-- vom lucra cu specificatii algebrice - tipuri noi de date
-- pt fiecare tip custom pe care il definim,
-- va trb sa scriem instante ale claselor de tipuri

-- Num - clasa numerica
-- Eq - clasa tipurilor care este definita ca egalitate
-- Show - clasa tipurilor care pot fi afisate ca string
-- Ord - clasa tipurilor ordonabile

maxim'' :: Ord a => a -> a -> a
maxim'' x y 
    | x > y = x
    | otherwise = y

-- exemplu pt tipurile de date algebrice
-- redefinim Boolean
-- definitia tipurilor de date algebrice se face prin keyword-ul data

data MyBool = MyTrue | MyFalse
    -- deriving(Show)

instance Show MyBool where
    show MyFalse = "F"
    show MyTrue = "T"

instance Eq MyBool where
    (==) MyFalse MyFalse = True
    (==) MyTrue MyTrue = True
    (==) _ _ = False

myAnd :: MyBool -> MyBool -> MyBool
myAnd MyTrue MyTrue = MyTrue
myAnd _ _ = MyFalse

myOr :: MyBool -> MyBool -> MyBool
myOr MyFalse MyFalse = MyFalse
myOr _ _ = MyTrue

-- cand specificatia tipului este cu |
-- (adica alegem sa fie sau MyTrue sau MyFalse)
-- atunci MyBool sn tip SUMA

-- numele tipului de date se scrie cu Majuscula 
-- si sn constructor de tip
-- data D = D1 | D2
-- D1, D2 - constructori de tip
-- utilizarea in functii este prin pattern matching

-- 3
data Choice = Rock
            | Paper 
            | Scissors
            deriving (Eq, Show)

data Result = Victory
            | Defeat
            | Draw
            deriving(Show)

game :: Choice -> Choice -> Result
game p1 p2 
    | p1 == p2 = Draw
game Rock Scissors = Victory
game Paper Rock = Victory
game Scissors Paper = Victory
game _ _ = Defeat
