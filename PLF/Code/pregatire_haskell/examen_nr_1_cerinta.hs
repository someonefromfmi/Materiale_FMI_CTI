import Test.QuickCheck
import Data.Char
import Data.Maybe
import Control.Monad
import Control.Applicative
import System.Random
import Data.List
-- fie urmatoarele tipuri de date algebrice:
data Pos = L | R deriving(Eq, Show)
data Deque a = Empty | Cons Pos a (Deque a)

-- consideram urmatorul exemplu
exDeque :: Deque Int
exDeque = Cons R 15 $ Cons R 6 $ Cons L 2 $ Cons L 4 $ Cons R 3 Empty

-- Partea I

-- TODO: Ex 1
-- instance Show (Deque a) where
-- TODO: Ex 2
toList :: Deque a -> [a]
toList = undefined
-- TODO: Ex 3
-- instance Monoid (Deque a) where

-- instance Foldable (Deque a) where
-- TODO: Ex 4
listEvenGeNFoldr :: Deque Int -> Int -> [Int]
listEvenGeNFoldr = undefined
-- TODO: Ex 5
-- genDeque :: Arbitrary a => Int -> Gen (Deque a)
-- genDeque 0 = return Empty
-- genDeque n = do
--     len <- choose (0, n)
--     xs <- vector len
--     ps <- vector len
--     return (build ps xs)
--         where
--             build [] [] = Empty
--             build (p:ps) (x:xs) = Cons p x (build ps xs)
--             build _ _ = error "Error"

-- Partea II
-- Fie urmatorul tip de date:

newtype WriterMaybe w a = WriterMaybe { runWriterMaybe :: (w, Maybe a) }
    deriving Show

-- TODO: Ex 6
-- instance Monad (Writer w) where

-- Consideram functia:
tell :: Monoid w => w -> WriterMaybe w ()
tell l = WriterMaybe (l, Just ())

-- Fie tipul de date Log:
type Log = [(Pos, Int)]

{-
    Utilizam monada definita anterior pentru a ne asigura ca toate
    inserarile pe care le facem intr-un Deque Int sunt valori
    negative. Consideram functia:
-}

-- insertChecked :: Pos -> Int -> Deque Int -> WriterMaybe Log (Deque Int)
-- insertChecked pos x dq
--     | x < 0 = tell [(pos, x)] >> WriterMaybe ([], Nothing)
--     | otherwise = tell [(pos, x)] >> return (Cons pos x dq)

-- TODO: Ex 7
buildDequeChecked :: [(Pos, Int)] -> WriterMaybe Log (Deque Int)
buildDequeChecked = undefined

-- Partea III

-- TODO: Ex 8
parseCmd :: Parser (Pos, Int)
parseCmd = undefined

sep :: Parser ()
sep = do
    skipSpace
    char ','
    skipSpace
    return ()

many' :: Parser a -> Parser [a]
many' p = some' p `alt` return []

some' :: Parser a -> Parser [a]
some' p = do
    x <- p
    xs <- many' p
    return (x:xs)

-- sepBy :: Parser a -> Parser a -> Parser () -> Parser [a]
-- sepBy p sep = (do
--     x <- p
--     xs <- many' (sep >> p)
--     return (x:xs)) `alt` return []

-- TODO: Ex 9
-- parseAll :: Parse [(Pos, Int)]
parseAll = undefined

buildFromString :: String -> WriterMaybe Log (Deque Int)
buildFromString s = buildDequeChecked (parse parseAll s)

-- cu apelul in terminal:
-- > buildFromString "l 1, r 2, 1 -5, r 5"
-- WriterMaybe {runWriterMaybe = ([(L, 1),(R,2),(L,-5)], Nothing)}

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







