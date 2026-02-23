module Exp where

import GHC.Base hiding (some, many)
import Data.Char
-- Analiza sintactica
-- Tipul unui analizor sintactic
{-
1.
type Praser a = String -> a
Problema: cel putin pt rezultate partiale, va mai ramane cv de analizat

2. typer Parser a = String -> (a, String)
Probleme:
- dar daca gramatica e ambigua?
- dar daca intrarea nu corespunde niciunui elem din a?
-}

-- Tipul Parser
newtype Parser a =
    Parser { apply :: String -> [(a, String)]}

-- folosirea unui parser
-- apply :: Parser a -> String -> [(a, String)]
-- apply (Parser f) s = f s 

-- Daca exista parsere, da prima varianta
parse :: Parser a -> String -> a
parse m s = head [x | (x,t) <- apply m s, t == ""]

-- Parsere pt caractere
-- Recunoasterea unui caracter
anychar :: Parser Char
anychar = Parser f
    where
        f [] = []
        f (c:s) = [(c,s)]

-- recunoasterea unui caracter cu o proprietate
-- satisfy :: (Char -> Bool) -> Parser Char
-- satisfy p = Parser f
--     where f [] = []
--           f (c:s) | p c = [(c, s)]
--                   | otherwise = []

-- recunoasterea unui anumit caracter
char :: Char -> Parser Char
char c = satisfy ( == c)

-- parsarea unui cuvant cheie
-- recunoasterea unui cuvant cheie
-- string :: String -> Parser String
-- string [] = Parser (\s -> [([], s)])
-- string (x:xs) = Parser f
--     where
--         f s = [(y:z, zs) | (y, ys) <- apply (char x) s,
--                            (z, zs) <- apply (string xs) ys]

-- Monada Parser
instance Monad Parser where
    return x = Parser (\s -> [ (x,s) ])
    m >>= k  = Parser (\s -> [ (y, u)
                                   | (x, t) <- apply m s
                                   , (y, u) <- apply (k x) t
                                   ])

instance Functor Parser where
    fmap = liftM

instance Applicative Parser where
    pure = return
    (<*>) = ap

-- string e echivalent cu:
string :: String -> Parser String
string [] = return []
string (x:xs) = do
    y <- char x
    ys <- string xs
    return (y:ys)

-- combinarea variantelor
digit = satisfy isDigit
abcP = satisfy (`elem` ['A', 'B', 'C'])

alt :: Parser a -> Parser a -> Parser a
alt p1 p2 = Parser f
    where f s = apply p1 s ++ apply p2 s

-- recunoasterea unui caracter cu o proprietate
failP :: Parser a
failP = Parser (\s -> [])

-- satisfy cu monade
satisfy :: (Char -> Bool) -> Parser Char
satisfy p = do
    c <- anychar
    if p c then return c else failP

-- recunoasterea unei secvente repetitive

many :: Parser a -> Parser [a]
many p = alt (some p) (return [])

-- cel putin o repetitie
some :: Parser a -> Parser [a]
some p = do 
    x <- p
    xs <- many p
    return (x:xs)

-- recunoasterea unui nr intreg
-- recunoasterea unui nr nat
decimal :: Parser Int 
decimal = do
    s <- some digit
    return (read s)

-- recunoasterea unui nr negativ
negdecimal :: Parser Int
negdecimal = do
    char '-'
    n <- decimal
    return (-n)

-- Recunoasterea unui nr intreg
integer :: Parser Int
integer = alt decimal negdecimal

{-
Recunoasterea unui identificator
Un identificator este definit de 2 param:
- felul primului caracter (e.g., incepe cu o litera)
- felul restului caracterelor (e.g., litera sau cifra)

Dat fiind un parser pt felul primului caracter si un parser pt
felul urmatoarelor caractere putem parsa un identificator:
-}

-- Recunoasterea unui identificator
iden :: Parser Char -> Parser Char -> Parser String
iden firstCh nextCh = do
    c <- firstCh
    s <- many nextCh
    return (c : s)

-- Exp: 
ide = iden (satisfy isAlpha) (satisfy isAlphaNum)

-- Eliminarea spatiilor
-- Ignorarea spatiilor
skipSpace :: Parser ()
skipSpace = do
    many (satisfy isSpace)
    return ()

-- ignorarea spatiilor de dinainte si dupa
token :: Parser a -> Parser a
token p = do
    skipSpace
    x <- p
    skipSpace
    return x

-- modulul Exp
data Exp = Lit Int
         | Exp :+: Exp
         | Exp :*: Exp
         deriving (Eq, Show)

evalExp :: Exp -> Int
evalExp (Lit n) = n
evalExp (e1 :+: e2) = evalExp e1 + evalExp e2
evalExp (e1 :*: e2) = evalExp e1 * evalExp e2

-- recunoasterea unei expresii
parseExp :: Parser Exp
parseExp = alt parseLit (alt parseAdd parseMul)
    where
        parseLit = do
            n <- integer
            return (Lit n)
        parseAdd = do
            char '('
            d <- token parseExp
            char '+'
            e <- token parseExp
            char ')'
            return (d :+: e)
        parseMul = do
            char '('
            d <- token parseExp
            char '*'
            e <- token parseExp
            char ')'
            return (d :*: e)



