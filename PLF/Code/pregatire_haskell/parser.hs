import Test.QuickCheck
import Data.Char
import Data.Maybe
import Control.Monad
import Control.Applicative
import System.Random
import Data.List

-- PARSER
newtype Parser a = Parser { apply :: String -> [(a, String)] }

parse :: Parser a -> String -> a
parse m s = head [x | (x, t) <- apply m s, t == ""]

anychar :: Parser Char
anychar = Parser f
    where
        f [] = []
        f (c:s) = [(c, s)]

satisfy :: (Char -> Bool) -> Parser Char
satisfy p = Parser f
    where
        f [] = []
        f (c:s)
            | p c = [(c, s)]
            | otherwise = []

char :: Char -> Parser Char
char c = satisfy (== c)

string :: String -> Parser String
string [] = Parser (\s -> [([], s)])
string (x:xs) = Parser f
    where
        f s = [(y:z, zs) | (y, ys) <- apply (char x) s, (z, zs) <- apply (string xs) ys]

digit = satisfy isDigit

alt :: Parser a -> Parser a -> Parser a
alt p1 p2 = Parser f
    where
        f s = apply p1 s ++ apply p2 s

failP :: Parser a
failP = Parser (\s -> [])

instance Monad Parser where
    return x = Parser (\s -> [(x, s)])
    m >>= k = Parser (\s -> [ (y, u) | (x, t) <- apply m s, (y, u) <- apply (k x) t])

instance Applicative Parser where
    pure = return
    mf <*> ma = do
        f <- mf
        a <- ma
        return (f a)

instance Functor Parser where
    fmap f ma = pure f <*> ma

many :: Parser Char -> Parser String
many p = alt (Main.some p) (return "")

some :: Parser Char -> Parser String
some p = do
    x <- p
    xs <- Main.many p
    return (x:xs)

decimal :: Parser Int
decimal = do
    s <- Main.some digit
    return (read s)

negdecimal :: Parser Int
negdecimal = do
    char '-'
    n <- decimal
    return (-n)

integer :: Parser Int
integer = alt decimal negdecimal

iden :: Parser Char -> Parser Char -> Parser String
iden firstCh nextCh = do
    c <- firstCh
    s <- Main.many nextCh
    return (c:s)

skipSpace :: Parser ()
skipSpace = do
    _ <- Main.many (satisfy isSpace)
    return ()

token :: Parser a -> Parser a
token p = do
    skipSpace
    x <- p
    skipSpace
    return x

-- END PARSER 