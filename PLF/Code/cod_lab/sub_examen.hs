import Data.Char
import Data.Maybe
import Control.Monad
import Control.Applicative
import System.Random
import Data.List


data Pos = L | R deriving Show
data Deque a = Empty | Cons Pos a (Deque a)

exDeque :: Deque Int
exDeque = Cons R 15 $ Cons R 6 $ Cons L 2 $ Cons L 4 $ Cons R 3 Empty

-- ex 1
instance Eq Pos where
    L == L = True
    R == R = True
    _ == _ = False
instance Eq (Deque a) where
    Empty == Empty = True
    (Cons p1 val1 d1) == (Cons p2 val2 d2) = p1 == p2 && d1 == d2
    _ == _ = False

instance Show a => Show (Deque a) where
    show Empty = "[]"
    show deque1 = stg deque1 ++ "[]" ++ dr deque1
        where
            stg Empty = ""
            stg (Cons p val d)
                | p == L = show val ++ " < " ++ stg d
                | otherwise = stg d
            dr Empty = ""
            dr (Cons p val d)
                | p == R = dr d ++ " > " ++ show val
                | otherwise = dr d

-- ex 2
toList :: Deque a -> [a]
toList Empty = []
toList deque1 = st deque1 <> dr deque1
    where
        st Empty = []
        st (Cons p val d)
            | p == L = val : st d
            | otherwise = st d
        dr Empty = []
        dr (Cons p val d)
            | p == R = dr d <> [val]
            | otherwise = dr d

toLists :: Deque a -> ([a], [a])
toLists deque = (st deque, dr deque)
    where 
        st Empty = []
        st (Cons p val d)
            | p == L = val : st d
            | otherwise = st d
        dr Empty = []
        dr (Cons p val d)
            | p == R = dr d <> [val]
            | otherwise = dr d

-- ex 3
instance Semigroup (Deque a) where
    Empty <> Empty = Empty
    Empty <> d = d
    d <> Empty = d
    (Cons p val d) <> deque = Cons p val (d <> deque)

instance Monoid (Deque a) where
    mempty = Empty

instance Foldable Deque where
    foldr _ acc Empty = acc
    foldr op acc (Cons _ val d) = 
        foldr op (val `op` acc) d 

-- ex 4
-- pas 0:
-- sumEvenLtN :: Deque Int -> Int -> Int
-- sumEvenLtN Empty _ = 0
-- sumEvenLtN (Cons p val d) n 
--     -- | val `mod` 

-- pas 0
listEvenGeN :: Deque Int -> Int -> [Int]
listEvenGeN deque n' =  y (toList deque) n'
    where 
        y [] _ = []
        y (x:xs) n 
            | even x && x >= n = x : (y xs n)
            | otherwise = y xs n

{-
pas 1: redenumim functia cu g
g [] _ = []
g (x:xs) n 
    | even x && x >= n = x : (g xs n)
    | otherwise = g xs n

pas 2: garzi -> if then else
g [] _ = []
g (x:xs) n = if even x && x >= n then x : (g xs n) else g xs n

pas 3: currying 
f [] = \_ -> [] INIT
f (x:xs) = \n -> if even x && x >= n then x : (g xs n) else g xs n

pas 4: universalitate
g (x : xs) = f x (g xs)
f x (g xs) = \n -> if even x && x >= n then x : (g xs n) else g xs n

pas 5: redenumim g xs cu u
f x u = \n -> if even x && x >= n then x : (u n) else u n

pas 6: extragem functia
f = \x u n -> if even x && x >= n then x : (u n) else u n
-}

listEvenGeNFoldr :: Deque Int -> Int -> [Int]
listEvenGeNFoldr = foldr (\x u n -> if even x && x >= n then x : (u n) else u n) (\_ -> [])

instance Arbitrary Pos where
    arbitrary = elements [L, R] 

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

listEvenGeNHOF :: Deque Int -> Int -> [Int]
listEvenGeNHOF d n = filter (\x -> x >= n && even x) (toList d)

my_prop d n = listEvenGeNFoldr d n == listEvenGeNHOF d n

newtype WriterMaybe w a = WriterMaybe {runWriterMaybe :: (w, Maybe a)} deriving Show

instance Functor (WriterMaybe w) where
    fmap f (WriterMaybe (log, op)) = (WriterMaybe (log, fmap f op))

instance Monoid w => Applicative (WriterMaybe w) where
    pure op = WriterMaybe (mempty, pure op)
    (WriterMaybe (log1, f)) <*> (WriterMaybe (log2, ival)) = WriterMaybe (log1 <> log2, f <*> ival)

instance Monoid w => Monad (WriterMaybe w) where
    return = pure
    (WriterMaybe (log, op)) >>= f =
        case op of
            Nothing -> WriterMaybe (log, Nothing)
            Just x  -> let (WriterMaybe (log', op')) = f x
                       in WriterMaybe (log <> log', op')

tell :: Monoid w => w -> WriterMaybe w ()
tell l = WriterMaybe (l, Just ())

type Log = [(Pos, Int)]

insertChecked :: Pos -> Int -> Deque Int -> WriterMaybe Log (Deque Int)
insertChecked pos x dq
    | x < 0 = tell [(pos, x)] >> WriterMaybe([], Nothing)
    | otherwise = tell [(pos, x)] >> return (Cons pos x dq)

buildDequeChecked :: [(Pos, Int)] -> WriterMaybe Log (Deque Int)
buildDequeChecked [] = return Empty
buildDequeChecked ((p, val):xs) = do
    restDeque <- buildDequeChecked xs
    insertChecked p val restDeque

sep :: Parser ()
sep = do
    skipSpace
    char ','
    skipSpace
    return()

many' :: Parser a -> Parser [a]
many' p = some' p `alt` return []

some' :: Parser a -> Parser [a]
some' p = do
    x <- p
    xs <- many' p
    return (x:xs)

sepBy :: Parser a -> Parser () -> Parser [a]
sepBy p sep = ( do 
    x <- p
    xs <- many' (sep >> p)
    return (x:xs)) `alt` return []

-- 8
parseCmd :: Parser (Pos, Int)
parseCmd = do
    skipSpace
    pos <- alt (char 'l' >> return L) 
               (alt (char 'L' >> return L)
                    (alt (char 'r' >> return R)
                         (char 'R' >> return R)))
    skipSpace
    num <- integer
    return (pos, num)

parseAll :: Parser [(Pos, Int)]
parseAll = sepBy parseCmd sep

buildFromString :: String -> WriterMaybe Log (Deque Int)
buildFromString s = buildDequeChecked (parse parseAll s)


infixr 0 ==>
infix  1 `classify`

--------------------------------------------------------------------
-- Generator

newtype Gen a
  = Gen (Int -> StdGen -> a)

sized :: (Int -> Gen a) -> Gen a
sized fgen = Gen (\n r -> let Gen m = fgen n in m n r)

resize :: Int -> Gen a -> Gen a
resize n (Gen m) = Gen (\_ r -> m n r)

rand :: Gen StdGen
rand = Gen (\n r -> r)

promote :: (a -> Gen b) -> Gen (a -> b)
promote f = Gen (\n r -> \a -> let Gen m = f a in m n r)

variant :: Int -> Gen a -> Gen a
variant v (Gen m) = Gen (\n r -> m n (rands r !! (v+1)))
 where
  rands r0 = r1 : rands r2 where (r1, r2) = split r0

generate :: Int -> StdGen -> Gen a -> a
generate n rnd (Gen m) = m size rnd'
 where
  (size, rnd') = randomR (0, n) rnd

--instance Functor Gen where
--  fmap f m = m >>= return . f

instance Monad Gen where
  Gen m >>= k =
    Gen (\n r0 -> let (r1,r2) = split r0
                      Gen m'  = k (m n r1)
                   in m' n r2)
                   
instance Applicative Gen where
  pure a = Gen (\n r -> a)
  mf <*> ma = do
    f <- mf
    a <- ma
    return (f a)       

instance Functor Gen where              
  fmap f ma = pure f <*> ma                     

-- derived

choose :: Random a => (a, a) -> Gen a
choose bounds = (fst . randomR bounds) `fmap` rand

elements :: [a] -> Gen a
elements xs = (xs !!) `fmap` choose (0, length xs - 1)

vector :: Arbitrary a => Int -> Gen [a]
vector n = sequence [ arbitrary | i <- [1..n] ]

oneof :: [Gen a] -> Gen a
oneof gens = elements gens >>= id

frequency :: [(Int, Gen a)] -> Gen a
frequency xs = choose (1, tot) >>= (`pick` xs)
 where
  tot = sum (map fst xs)

  pick n ((k,x):xs)
    | n <= k    = x
    | otherwise = pick (n-k) xs

-- general monadic

two :: Monad m => m a -> m (a, a)
two m = liftM2 (,) m m

three :: Monad m => m a -> m (a, a, a)
three m = liftM3 (,,) m m m

four :: Monad m => m a -> m (a, a, a, a)
four m = liftM4 (,,,) m m m m

--------------------------------------------------------------------
-- Arbitrary

class Arbitrary a where
  arbitrary   :: Gen a
  --coarbitrary :: a -> Gen b -> Gen b

instance Arbitrary () where
  arbitrary     = return ()
 -- coarbitrary _ = variant 0

instance Arbitrary Bool where
  arbitrary     = elements [True, False]
  --coarbitrary b = if b then variant 0 else variant 1

instance Arbitrary Char where
  arbitrary     = choose (32,255) >>= \n -> return (chr n)
 -- coarbitrary n = variant (ord n)

instance Arbitrary Int where
  arbitrary     = sized $ \n -> choose (-n,n)
 -- coarbitrary n = variant (if n >= 0 then 2*n else 2*(-n) + 1)


instance Arbitrary Integer where
  arbitrary     = sized $ \n -> choose (-fromIntegral n,fromIntegral n)
  --coarbitrary n = variant $ (fromInteger(if n >= 0 then 2*n else 2*(-n) + 1)) 

instance Arbitrary Float where
  arbitrary     = liftM3 fraction arbitrary arbitrary arbitrary 
  --coarbitrary x = coarbitrary (decodeFloat x)

instance Arbitrary Double where
  arbitrary     = liftM3 fraction arbitrary arbitrary arbitrary 
 -- coarbitrary x = coarbitrary (decodeFloat x)

fraction a b c = fromInteger a + (fromInteger b / (abs (fromInteger c) + 1))

{-
instance Arbitrary Integer where
  arbitrary     = sized $ \n -> choose (-fromInt n,fromInt n)
  coarbitrary n = variant (fromInteger (if n >= 0 then 2*n else 2*(-n) + 1))

instance Arbitrary Float where
  arbitrary     = liftM3 fraction arbitrary arbitrary arbitrary 
  coarbitrary x = coarbitrary (decodeFloat x)

instance Arbitrary Double where
  arbitrary     = liftM3 fraction arbitrary arbitrary arbitrary 
  coarbitrary x = coarbitrary (decodeFloat x)

fraction a b c = fromInteger a + (fromInteger b / (abs (fromInteger c) + 1))
-}


instance (Arbitrary a, Arbitrary b) => Arbitrary (a, b) where
  arbitrary          = liftM2 (,) arbitrary arbitrary
 -- coarbitrary (a, b) = coarbitrary a . coarbitrary b

instance (Arbitrary a, Arbitrary b, Arbitrary c) => Arbitrary (a, b, c) where
  arbitrary             = liftM3 (,,) arbitrary arbitrary arbitrary
  --coarbitrary (a, b, c) = coarbitrary a . coarbitrary b . coarbitrary c

instance (Arbitrary a, Arbitrary b, Arbitrary c, Arbitrary d)
      => Arbitrary (a, b, c, d)
 where
  arbitrary = liftM4 (,,,) arbitrary arbitrary arbitrary arbitrary
  --coarbitrary (a, b, c, d) =
  --  coarbitrary a . coarbitrary b . coarbitrary c . coarbitrary d

instance Arbitrary a => Arbitrary [a] where
  arbitrary          = sized (\n -> choose (0,n) >>= vector)
 -- coarbitrary []     = variant 0
 -- coarbitrary (a:as) = coarbitrary a . variant 1 . coarbitrary as

--instance (Arbitrary a, Arbitrary b) => Arbitrary (a -> b) where
 -- arbitrary         = promote (`coarbitrary` arbitrary)
 -- coarbitrary f gen = arbitrary >>= ((`coarbitrary` gen) . f)

--------------------------------------------------------------------
-- Testable

data Result
  = Result { ok :: Maybe Bool, stamp :: [String], arguments :: [String] }

nothing :: Result
nothing = Result{ ok = Nothing, stamp = [], arguments = [] }

newtype Property
  = Prop (Gen Result)

result :: Result -> Property
result res = Prop (return res)

evaluate :: Testable a => a -> Gen Result
evaluate a = gen where Prop gen = property a

class Testable a where
  property :: a -> Property

instance  Testable () where
  property _ = result nothing

instance Testable Bool where
  property b = result (nothing{ ok = Just b })

instance Testable Result where
  property res = result res

instance Testable Property where
  property prop = prop

instance (Arbitrary a, Show a, Testable b) => Testable (a -> b) where
  property f = forAll arbitrary f

forAll :: (Show a, Testable b) => Gen a -> (a -> b) -> Property
forAll gen body = Prop $
  do a   <- gen
     res <- evaluate (body a)
     return (argument a res)
 where
  argument a res = res{ arguments = show a : arguments res }

(==>) :: Testable a => Bool -> a -> Property
True  ==> a = property a
False ==> a = property ()

label :: Testable a => String -> a -> Property
label s a = Prop (add `fmap` evaluate a)
 where
  add res = res{ stamp = s : stamp res }

classify :: Testable a => Bool -> String -> a -> Property
classify True  name = label name
classify False _    = property

trivial :: Testable a => Bool -> a -> Property
trivial = (`classify` "trivial")

collect :: (Show a, Testable b) => a -> b -> Property
collect v = label (show v)

--------------------------------------------------------------------
-- Testing

data Config = Config
  { maxTest :: Int
  , maxFail :: Int
  , size    :: Int -> Int
  , every   :: Int -> [String] -> String
  }

quick :: Config
quick = Config
  { maxTest = 100
  , maxFail = 1000
  , size    = (+ 3) . (`div` 2)
  , every   = \n args -> let s = show n in s ++ [ '\b' | _ <- s ]
  }
         
verbose :: Config
verbose = quick
  { every = \n args -> show n ++ ":\n" ++ unlines args
  }

test, quickCheck, verboseCheck :: Testable a => a -> IO ()
test         = check quick
quickCheck   = check quick
verboseCheck = check verbose
         
check :: Testable a => Config -> a -> IO ()
check config a =
  do rnd <- newStdGen
     tests config (evaluate a) rnd 0 0 []

tests :: Config -> Gen Result -> StdGen -> Int -> Int -> [[String]] -> IO () 
tests config gen rnd0 ntest nfail stamps
  | ntest == maxTest config = do done "OK, passed" ntest stamps
  | nfail == maxFail config = do done "Arguments exhausted after" ntest stamps
  | otherwise               =
      do putStr (every config ntest (arguments result))
         case ok result of
           Nothing    ->
             tests config gen rnd1 ntest (nfail+1) stamps
           Just True  ->
             tests config gen rnd1 (ntest+1) nfail (stamp result:stamps)
           Just False ->
             putStr ( "Falsifiable, after "
                   ++ show ntest
                   ++ " tests:\n"
                   ++ unlines (arguments result)
                    )
     where
      result      = generate (size config ntest) rnd2 gen
      (rnd1,rnd2) = split rnd0

done :: String -> Int -> [[String]] -> IO ()
done mesg ntest stamps =
  do putStr ( mesg ++ " " ++ show ntest ++ " tests" ++ table )
 where
  table = display
        . map entry
        . reverse
        . sort
        . map pairLength
        . group
        . sort
        . filter (not . null)
        $ stamps

  display []  = ".\n"
  display [x] = " (" ++ x ++ ").\n"
  display xs  = ".\n" ++ unlines (map (++ ".") xs)

  pairLength xss@(xs:_) = (length xss, xs)
  entry (n, xs)         = percentage n ntest
                       ++ " "
                       ++ concat (intersperse ", " xs)

  percentage n m        = show ((100 * n) `div` m) ++ "%"

--------------------------------------------------------------------
-- the end.

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




