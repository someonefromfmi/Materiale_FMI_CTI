--module main where

import Data.List
import Test.QuickCheck
import Data.Char
import Control.Monad.ST (RealWorld)

-- tipuri de date
-- tip suma:
data Season' = Spring' | Summer' | Autumn' | Winter'

-- tip produs
data Point' a b = Pt' a b

-- ! Point este contructor de tip
-- ! Pt este constructor de date

-- combinatie intre suma si produs
data List a = Nil
            | Cons a (List a)

data Shape = Circle Float | Rectangle Float Float

data MyMaybe a = MyNothing | MyJust a

data Pair a b = Pair a b -- constructorul de tip si cel de date pot
-- sa coincida

data Nat' = Zero | Succ Nat'

data Exp = Lit Int | Add Exp Exp | Mul Exp Exp

data Tree a = Leaf a | Branch (Tree a) (Tree a)

-- tipul Maybe
-- argumente optionale
power :: Maybe Int -> Int -> Int
power Nothing n = 2 ^ n
power (Just m) n = m ^ n

-- rezultate optionale
divide :: Int -> Int -> Maybe Int
divide n 0 = Nothing
divide n m = Just (n `div` m)

-- utilizare gresita
-- wrong :: Int -> Int -> Int
-- wrong n m = divide n m + 3

-- utilizare corecta
right :: Int -> Int -> Int
right n m = case divide n m of
                Nothing -> 3
                Just r -> r + 3

-- Either A B (A sau B)
data Either' a b = Left' a | Right' b
myList :: [Either' Int String]
myList = [Left' 4, Left' 1, Right' "hello", Left' 2,
            Right' " ", Right' "world", Left' 17]

-- definiti o fc care calc suma elementelor intregi
addints :: [Either' Int String] -> Int
addints [] = 0
addints (Left' n : xs) = n + addints xs
addints (Right' s : xs) = addints xs

addints' :: [Either' Int String] -> Int
addints' xs = sum [n | Left' n <- xs]

-- definiti o functie care intoarce concatenarea elementelor
-- de tip string
addstrs :: [Either' Int String] -> String
addstrs xs = concat [n | Right' n <- xs]

addstrs' :: [Either' Int String] -> String
addstrs' [] = ""
addstrs' (Left' n : xs) = addstrs' xs
addstrs' (Right' s : xs) = s ++ addstrs xs

-- type: redenumim tipuri deja existente
type Name = String
type Age = Integer

data Person = Person Name Age

-- Datele se descompun folosind proiectii:
name :: Person -> Name
name (Person name _ ) = name

age' :: Person -> Age
age' (Person _ years) = years

-- datele personale  ca inregistrari
data Person' = Person' { firstName :: String
                       , lastName :: String
                       , age :: Int
                       , height :: Float
                       , phoneNumber :: String
                       }
-- proiectiile sunt definite automat:
{-
firstName :: Person' -> String
lastName :: Person' -> String
age :: Person' -> Int
height :: Person' -> Float
phoneNumber :: Person' -> String
-}

-- putem folosi si froma algebrica
ionel = Person' "Ion" "Ionescu" 20 175.5 "0712334567"

-- declararea tipurilor cu newtype
-- newtype: cand avem un singur constructor cu un singur argument

newtype Calc = C {compute :: Int -> Int}
-- compute :: Calc -> (Int -> Int)

eval :: Calc -> Int -> Int
eval calc x = compute calc $ x

type Names = [Name]
data Prop = Var Name
          | F
          | T
          | Not Prop
          | Prop :|: Prop
          | Prop :&: Prop

names :: Prop -> Names
names (Var x) = [x]
names F = []
names T = []
names (Not p) = names p
names (p :|: q) = nub (names p ++ names q)
names (p :&: q) = nub (names p ++ names q)
-- nub - elimina duplicatele

p :: Prop
p = (Var "P" :|: Var "Q") :&: (Var "P" :&: Var "Q")

par :: String -> String
par s = "(" ++ s ++ ")"

instance Show Prop where
    show = showP
        where
            showP (Var x) = x
            showP F = "F"
            showP T = "T"
            showP (Not p) = par ("~" ++ showP p)
            showP (p :|: q) = par (showP p ++ " | " ++ showP q)
            showP (p :&: q) = par (showP p ++ " & " ++ showP q)

-- constrangeri de tip
-- marcate cu simbolul =>
-- instance (Show a, Show b) => Show (a,b) where
--     show (x,y) = "(" ++ (show x) ++ "," ++ (show y) ++ ")"

{-
instance Show a => Show [a] where
    show [] = "[]"
    show (x:xs) = "[" ++ showSep x xs ++ "]"
        where
            showSep x [] = show x
            showSep x (y:ys) = (show x) ++ ","++(showSep y ys)
-}

-- pentru unele clase predefinite, instantierea poate fi facuta
-- automat folosind deriving
data Season = Spring | Summer | Autumn | Winter
            deriving(Show, Eq)

-- explicit
instance Eq a => Eq (Point' a b) where
    (==) (Pt' x1 y1) (Pt' x2 y2) = x2 == x1

-- testare - QuickCheck
myreverse :: [a] -> [a] -- definita generic
myreverse [] = []
myreverse (x:xs) = myreverse xs ++ [x]

prdef :: Eq a => [a] -> Bool -- precizam tipul
prdef xs = myreverse xs == reverse xs

wrongpr :: Eq a => [a] -> Bool -- precizam tipul
wrongpr xs = myreverse xs == xs

-- testare quickcheck - ADT
predf1 :: [Season] -> Bool
predf1 xs = (myreverse xs == reverse xs)

wrongpr1 :: [Season] -> Bool
wrongpr1 xs = myreverse xs == xs

-- tipurile de date care pot fi testate cu QuickCheck trebuie sa fie
-- instante ale clasei Arbitrary
instance Arbitrary Season where
    arbitrary = elements [Spring, Summer, Autumn, Winter]

-- Actiuni pentru intrari si iesiri
-- comenzi in haskell
type IO' a = RealWorld -> (a, RealWorld)

-- combinarea actiunilor
-- (>>) :: IO () -> IO () -> IO ()
-- putChar :: Char -> IO ()

-- afiseaza un sir de caractere
done :: IO () -- o actiune care, ! daca va fi executata!, nu va face nmc
done = mempty

myPutStr :: String -> IO ()
myPutStr [] = done
myPutStr (x : xs) = putChar x >> myPutStr xs

myPutStr' :: String -> IO ()
myPutStr' = foldr (>>) done . map putChar

-- afiseaza si treci pe urmatorul rand
myPutStrLn :: String -> IO()
myPutStrLn xs = putStr xs >> putChar '\n'

-- (IO (), (>>), done) e monoid

-- citirea unui caracter
-- getChar :: IO Char
-- Daca "sirul de intare" cont "abc"
-- atunci getChar produce
-- -'a'
-- -sirul ramas de intrare "bc"

-- Actiunea care produce o valoare fara niciun efect
-- return :: a -> IO a, asemenator cu done, nu face nmc, dar 
-- produce o valoare

{-
return ""
- Daca sirul de intrare contine "abc"
- atunci return "" producce
    - valoarea ""
    - sirul (neschimbat) de intrare "abc"

!done este un caz special de return 
-}

-- operatorul de legare
-- exp: getChar >>= putChar

-- Combinarea actiunilor cu valori
-- (>>=) :: IO a -> (a -> IO b) -> IO b - operatorul de legare

exemplu = getChar >>= \x -> putChar (toUpper x)
{-
- daca sirul de intrare contine "abc"
- atunci actiunea de mai sus, atunci cand se executa, produce:
    - iesirea "A"
    - sirul ramas de intrare "abc"

! >> e un caz special de >>=
-}

-- citeste o linie
myGetLine :: IO String
myGetLine = getChar >>= \x ->
             if x == '\n' then
                return []
             else
                myGetLine >>= \xs ->
                    return (x:xs)

-- de la intrare la iesire
echo :: IO ()
echo = getLine >>= \line ->
        if   line == ""
        then return ()
        else
             putStrLn (map toUpper line) >>
             echo

-- do notation
myGetLine' = do {
    x <- getChar;
    if x == '\n' then
        return []
    else do {
        xs <- myGetLine';
        return (x:xs)
    }
}

echo' = do {
    line <- getLine;
    if line == "" then
        return ()
    else do {
        myPutStrLn (map toUpper line);
        echo
    }
}

main :: IO ()
main = do
    echo'

{-
citirea/scrierea din fisiere

type FilePath = String
readFile :: FilePath -> IO String
writeFile :: FilePath -> String -> IO ()
appendFile :: FilePath -> String -> IO ()
-}

echof = do
    s <- readFile "fis1.txt"
    putStrLn s
    writeFile "fis2.txt" s

main' = do
    s <- readFile "Input.txt"
    putStrLn $ "Intrare\n" ++ s

    let sprel = map toUpper s -- prelucrare date citite

    putStrLn $ "Iesire\n" ++ sprel
    writeFile "Output.txt" sprel -- append file

-- !readfile citeste continutul fisierului
-- !writeFile si appendFile creaza fisierele daca acestea nu exista

-- citirea/scrierea numerelor din fisiere

listNo str = concatMap words $ lines str

readNumbers file1 file2 = do
    str <- readFile file1
    putStrLn "Intrare\n"
    let numbers = (map read $ listNo str) :: [Int]
    print numbers
    writeFile file2 (show numbers)

-- ! print este putStrLn . show

-- Rationamentele substitutive sunt valabile
{-
Referential transparency
orice expresie poate fi inlocuita cu valoarea ei
-}

addExclamation :: String -> String
addExclamation s = s ++ "!"

{-
main = putStrLn (addExclamation "Hello")
echivalent cu
main = putStrLn ("Hello" ++ "!")
-}

{-
Rationamentele substitutive sunt valabile
-Expresii
(1 + 2) * (1 + 2)
este echivalenta cu expresia
let x = 1 + 2 in x * x
si se evalueaza amandoua cu 9
-Comenzi
pustr "HA!" >> putStr "HA!"
este echivalenta cu
let m = putStr "HA!" in m >> m
si amandoua afiseaza "HA!HA!"
-}

-- Clasa Foldable
-- Exemplu: suma elementelor

sumList :: [Int] -> Int -- suma elem: lista
sumList [] = 0
sumList (x:xs) = x + sumList xs

sumBTree :: Tree Int -> Int -- suma elem. arbore
sumBTree (Leaf x) = x
sumBTree (Branch t1 t2) = sumBTree t1 + sumBTree t2

-- pt liste putem folosi foldr
sumList' :: [Int] -> Int
sumList' = foldr (+) 0 

-- Problema: sa generalizam foldr la alte structuri recursive
foldTree :: (a -> b -> b) -> b -> Tree a -> b
foldTree f i (Leaf x) = f x i
foldTree f i (Branch t1 t2) = foldTree f j t1
    where
        j = foldTree f i t2

myTree = Branch (Branch (Leaf 1) (Leaf 2)) (Branch (Leaf 3) (Leaf 4))

sumTree = foldTree (+) 0

instance Foldable Tree where
    foldr = foldTree

{-
class Foldable t where
    foldr :: (a -> b -> b) -> b -> t a -> b
-}

-- !in definitia clasei Foldable, variabila de tip t nu reprezinta
-- !un tip concret ([a], Sum a), ci un constructor de tip (Tree)
-- !functiile foldl si foldr1 sunt definite automat

treeS = Branch 
            (Branch (Leaf "a") (Leaf "b")) 
            (Branch (Leaf "c") (Leaf "d"))

-- Cum definim instante diferite pentru acelasi tip?
-- se creeaza o copie a tipului folosind newtype
-- copia este definita ca instanta a tipului

newtype Nat = MkNat Integer
{-
newtype
- se foloseste atunci cand un singur constructor este aplicat unui
singur tip de date
- declaratia este m eficienta decat cea cu data
- type redenumeste tipul; newtype face o copie si permite
redefinirea operatiilor
-}

-- clasa Monoid
newtype Sum a = Sum {getSum :: a}
    deriving (Eq, Read, Show)

instance Num a => Semigroup (Sum a) where
    Sum a1 <> Sum a2 = Sum (a1 + a2)

instance Num a => Monoid (Sum a) where
    mempty = Sum 0
    Sum x `mappend` Sum y = Sum (x + y)

-- Functii ca instante
newtype Endo' a = Endo' { appEndo' :: a -> a}

instance Semigroup (Endo' a) where
    Endo' g <> Endo' f = Endo' (g . f)

instance Monoid (Endo' a) where
    mempty = Endo' id
    Endo' g `mappend` Endo' f = Endo' (g . f)  

{-
definitia minimala Foldable: contie fie foldMap, fie foldr
-}

-- Generalizari
-- Cum definim foldr inlocuind listele cu date de tip Exp?
evalExp :: Exp -> Int
evalExp (Lit n) = n
evalExp (Add e1 e2) = evalExp e1 + evalExp e2
evalExp (Mul e1 e2) = evalExp e1 * evalExp e2

-- Vrem sa def foldExp a.i.: evalExp = foldExp (+) (*)

foldExp :: (Int -> t) -> (t -> t -> t) -> (t -> t -> t) -> Exp -> t
foldExp fLit fAdd fMul (Lit n) = fLit n
foldExp fLit fAdd fMul (Add e1 e2) = fAdd v1 v2
    where
        v1 = foldExp fLit fAdd fMul e1
        v2 = foldExp fLit fAdd fMul e2
foldExp fLit fAdd fMul (Mul e1 e2) = fMul v1 v2
    where
        v1 = foldExp fLit fAdd fMul e1
        v2 = foldExp fLit fAdd fMul e2

evalExp' = foldExp fLit (+) (*)
    where
        fLit :: Exp -> Int
        fLit (Lit x) = x

-- runghc curs11.hs
-- you could have invented a monad