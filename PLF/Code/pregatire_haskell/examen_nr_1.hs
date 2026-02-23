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
instance Show a => Show (Deque a) where
    show dq =
        let (left, right) = collect dq
            leftStr = showLeft left
            rightStr = showRight right
        in case (leftStr, rightStr) of
            ("", "") -> "[]"
            ("", r)  -> "[] > " ++ r
            (l, "")  -> reverse l ++ " < []"
            (l, r)   -> reverse l ++ " < [] > " ++ r
      where
        collect :: Deque a -> ([a], [a])
        collect Empty = ([], [])
        collect (Cons L x rest) = let (l, r) = collect rest in (l ++ [x], r)
        collect (Cons R x rest) = let (l, r) = collect rest in (l, r ++ [x])

        showLeft :: Show a => [a] -> String
        showLeft [] = ""
        showLeft [x] = show x
        showLeft (x:xs) = show x ++ " < " ++ showLeft xs

        showRight :: Show a => [a] -> String
        showRight [] = ""
        showRight [x] = show x
        showRight (x:xs) = show x ++ " > " ++ showRight xs

-- TODO: Ex 2
toList :: Deque a -> [a]
toList Empty = []
toList (Cons pos a d) =
    if pos == L
        then a : toList d
        else toList d ++ [a]

-- TODO: Ex 3
instance Semigroup (Deque a) where
  (<>) :: Deque a -> Deque a -> Deque a
  (Cons pos1 a1 d1) <> d2 =
    Cons pos1 a1 (d1 <> d2)  

instance Monoid (Deque a) where
      mempty = Empty

instance Foldable Deque where
  foldr = foldrDeque

foldrDeque :: (a -> b -> b) -> b -> Deque a -> b
foldrDeque _ acc Empty = acc
foldrDeque f acc (Cons _ a t) = foldrDeque f (f a acc) t

-- TODO: Ex 4
listEvenGeN :: Deque Int -> Int -> [Int]
listEvenGeN Empty _ = []
listEvenGeN (Cons _ a d) n = if a >= n && even a
                             then a : listEvenGeN d n
                             else listEvenGeN d n

-- listEvenGeNFoldr :: Deque Int -> Int -> [Int]
-- listEvenGeNFoldr = \x u n -> if a >= n && even a then a : u else u (\_ -> [])

-- TODO: Ex 5
instance Arbitrary Pos where
    arbitrary = do
        elements [L, R]

instance Arbitrary a => Arbitrary (Deque a) where
  arbitrary = sized genDeque

genDeque :: Arbitrary a => Int -> Gen (Deque a)
genDeque 0 = return Empty
genDeque n = do
    len <- choose (0, n)
    xs <- vector len
    ps <- vector len
    return (build ps xs)
        where
            build [] [] = Empty
            build (p:ps) (x:xs) = Cons p x (build ps xs)
            build _ _ = error "Error"

prop_qc :: Deque Int -> Int -> Bool
prop_qc d n = 
    listEvenGeN d n == listEvenGeN d n

test_qc = quickCheck prop_qc

-- Partea II
-- Fie urmatorul tip de date:

newtype WriterMaybe w a = WriterMaybe { runWriterMaybe :: (w, Maybe a) }
    deriving Show

-- TODO: Ex 6
instance Functor (WriterMaybe w) where
    fmap :: (a -> b) -> WriterMaybe w a -> WriterMaybe w b
    fmap f (WriterMaybe (w, mx)) = WriterMaybe (w, fmap f mx)

instance Monoid w => Applicative (WriterMaybe w) where
    pure x = WriterMaybe (mempty, Just x)
    (<*>) (WriterMaybe (w1, mf)) (WriterMaybe (w2, mx)) =
        WriterMaybe (w1 <> w2, mf <*> mx)

instance Monoid env => Monad (WriterMaybe env) where
    return = pure
    WriterMaybe (w, mx) >>= f =
        case mx of
            Nothing -> WriterMaybe (w, Nothing)
            Just x  -> let WriterMaybe (w', my) = f x
                       in WriterMaybe (w <> w', my)

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

insertChecked :: Pos -> Int -> Deque Int -> WriterMaybe Log (Deque Int)
insertChecked pos x dq
    | x < 0 = tell [(pos, x)] >> WriterMaybe ([], Nothing)
    | otherwise = tell [(pos, x)] >> return (Cons pos x dq)

-- TODO: Ex 7
buildDequeChecked :: [(Pos, Int)] -> WriterMaybe Log (Deque Int)
buildDequeChecked = buildHelper Empty
  where
    buildHelper dq [] = return dq
    buildHelper dq ((pos, val):rest) = do
      newDq <- insertChecked pos val dq
      buildHelper newDq rest

-- Partea III

-- TODO: Ex 8
parseCmd :: Parser (Pos, Int)
parseCmd = do
    skipSpace
    pos <- parsePos
    skipSpace
    num <- integer
    return (pos, num)
  where
    parsePos = do
        c <- satisfy (\ch -> ch == 'l' || ch == 'L' || ch == 'r' || ch == 'R')
        case c of
            'l' -> return L
            'L' -> return L
            'r' -> return R
            'R' -> return R
            _   -> failP

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

sepBy :: Parser a -> Parser () -> Parser [a]
sepBy p sep = (do
    x <- p
    xs <- many' (sep >> p)
    return (x:xs)) `alt` return []

-- TODO: Ex 9
parseAll :: Parser [(Pos, Int)]
parseAll = sepBy parseCmd sep

buildFromString :: String -> WriterMaybe Log (Deque Int)
buildFromString s = buildDequeChecked (parse parseAll s)

-- cu apelul in terminal:
-- > buildFromString "l 1, r 2, l -5, r 5"
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







