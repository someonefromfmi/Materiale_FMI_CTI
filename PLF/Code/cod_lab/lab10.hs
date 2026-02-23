import Data.Maybe
-- semigroup (<>) asociativitate
-- monoid (mempty)
-- foldable (foldr) -> List

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
lfilter :: (a -> Bool) -> LList a -> LList a
lfilter _ Nil = Nil
lfilter pred (Cons x xs)
    | pred x = Cons x $ lfilter pred xs
    | otherwise = lfilter pred xs

lMap :: (a -> b) -> LList a -> LList b
lMap _ Nil = Nil
lMap f (Cons x xs) = Cons (f x) $ lMap f xs

lFoldr :: (a -> b -> b) -> b -> LList a -> b
lFoldr _ i Nil = i
lFoldr f i (Cons x xs) = f x $ lFoldr f i xs

lToList :: LList a -> [a]
lToList Nil = []
lToList (Cons x xs) = x : lToList xs

-- lab 10
-- rezolvam 1, 3, 4
-- 1
instance Foldable LList where
    foldr = lFoldr

-- 2 fie urmat tipuri de date algebrice, care reprezinta matrici cu
-- linii de lungime diferita

data Line = L [Int] deriving (Show)
data Matrix = M [Line]

-- a. scrieti o functie care primeste o matrice, un nr intreg n si
-- si returneaza o lista de linii de lungime n
linesN :: Matrix -> Int -> [Line]
linesN (M []) _ = []
linesN (M ((L line):xs)) n
    | length line == n = L line : linesN (M xs) n
    | otherwise = linesN (M xs) n

-- b. scrieti o functie care verif daca toate liniile de lungime n
-- au elem strict pozitive
onlyPosElems  :: Matrix -> Int -> Bool
onlyPosElems m n = f (linesN m n)
    where 
        f mat = g (concatMap (\(L xs) -> xs) mat) 
        g [] = True
        g (x:xs)
            | odd x     = False
            | otherwise =  g xs
-- 3
type Name = String -- tip sinonim

data Prop
    = Var Name
    | F
    | T
    | Not Prop
    | Prop :|: Prop
    | Prop :&: Prop
    deriving(Eq)

infixr 2 :|:
infixr 3 :&:

p1 :: Prop
p1 = (Var "P" :|: Var "Q") :&: (Var "P" :|: Var "Q")

p2 :: Prop
p2 = (Var "P" :|: Var "Q") :&: (Not (Var "P") :&: Not (Var "Q"))

-- a
p3 :: Prop
p3 = (Var "P" :|: (Var "Q" :&: Var "R")) 
        :&: ((Not (Var "P") :|: Not (Var "Q")) :&: (Not (Var "P") :|: Not (Var "R")))

-- b
-- sigur la test final, show pt tipul de date algebric
instance Show Prop where
    show(Var x) = show x
    show T = "T"
    show F = "F"
    show (Not p) = "(" ++ "~" ++ show p ++ ")"
    show (p :|: q) =  "(" ++ "~" ++ show p ++ "|" ++ show q ++ ")"
    show (p :&: q) =  "(" ++ "~" ++ show p ++ "&" ++ show q ++ ")"

-- c
type Env = [(Name, Bool)]
--("P", True), ("Q", False)

-- lookup :: a -> [(a,b)] -> Maybe b
--  daca a exista, se intoarce Just value
-- daca a nu exista, se intoarce Nothing

-- data Maybe a = Just a | Nothing

impureLookup :: Eq a => a -> [(a, b)] -> b
impureLookup key list = fromJust $ lookup key list

eval :: Prop -> Env -> Bool
eval (Var x) env = impureLookup x env
eval F env = False
eval T env = True
eval (Not p) env = not $ eval p env
eval (p :|: q) env = (eval p env) || (eval q env)
eval (p :&: q) env = (eval p env) && (eval q env)

env :: Env
env = [("P", True), ("Q", False)]

-- 4
data Expr = Const Int
          | Expr :+: Expr
          | Expr :*: Expr
          deriving Eq

data Operation = Add | Mult deriving(Eq, Show)

data Tree = Lf Int
          | Node Operation Tree Tree
          deriving(Eq, Show)

instance Show Expr where
    show :: Expr -> String
    show (Const x) = show x
    show (exp1 :+: exp2) = "(" ++ show exp1 ++ "+" ++ show exp2 ++ ")"
    show (exp1 :*: exp2) = "(" ++ show exp1 ++ "*" ++ show exp2 ++ ")"

evalExp :: Expr -> Int
evalExp (Const x) = x
evalExp (exp1 :+: exp2) = (evalExp exp1) + (evalExp exp2)
evalExp (exp1 :*: exp2) = (evalExp exp1) * (evalExp exp2)

evalArb :: Tree -> Int
evalArb (Lf x) = x
evalArb (Node Add t1 t2) = (evalArb t1) + (evalArb t2)
evalArb (Node Mult t1 t2) = (evalArb t1) * (evalArb t2)

expToArb :: Expr -> Tree
expToArb (Const x) = Lf x
expToArb (exp1 :+: exp2) = Node Add (expToArb exp1) (expToArb exp2)
expToArb (exp1 :*: exp2) = Node Mult (expToArb exp1) (expToArb exp2)

expr :: Expr
expr = (Const 2) :+: ((Const 3) :*: (Const (-1)))