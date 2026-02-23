import Data.Maybe (fromMaybe)
-- Monade standard
-- Monada Maybe (a functiilor partiale)
radical :: Float -> Maybe Float
radical x | x >= 0 = do return (sqrt x)
          | x < 0  = Nothing

solEq2 :: Float -> Float -> Float -> Maybe Float
solEq2 0 0 0 = return 0
solEq2 0 0 c = Nothing
solEq2 0 b c = return $ negate c / b
solEq2 a b c = do
    rDelta <- radical $ b * b - 4 * a * c
    return $ (negate b + rDelta) / (2 * a)

-- Monada Either (a exceptiilor)
radical' :: Float -> Either String Float
radical' x | x >= 0 = return (sqrt x)
          | x < 0  = Left "radical: argument negativ"

solEq2' :: Float -> Float -> Float -> Either String Float
solEq2' 0 0 0 = return 0
solEq2' 0 0 c = Left "Nu are solutii"
solEq2' 0 b c = return $ negate c / b
solEq2' a b c = do
    rDelta <- radical' $ b * b - 4 * a * c
    return $ (negate b + rDelta) / (2 * a)

-- Monada listelor (computatiilor nedeterministe)
-- ! Computatie nedeterminista in Haskell: 
-- ! rezultatul fc e lista tuturor valorilor posibile

graf = [(1, 2), (2,3), (2,7), (1,4), (4,5), (5,6)]
succesori :: Int -> [Int]
succesori x = [snd p | p <- graf, fst p == x]

succesori2 :: Int -> [Int]
succesori2 x = succesori x >>= succesori

-- Monada Writer (varianta simplificata)

newtype Writer log a = Writer { runWriter :: (a, log) }
-- a este param de tip

instance Functor (Writer log) where
    fmap f (Writer (a, env)) = Writer (f a, env)

instance Monoid log => Applicative (Writer log) where
    pure x = Writer (x, mempty)
    Writer (f, log1) <*> Writer (w2, log2) =
        Writer (f w2, log1 <> log2)

instance Monad (Writer String) where
    return = pure
    ma >>= f = let (w1, log1) = runWriter ma
                   (w2, log2) = runWriter (f w1)
                in Writer (w2, log1 ++ log2)

tell :: log -> Writer log ()
tell msg = Writer ((), msg)

logIncrement :: Int -> Writer String Int
logIncrement x = do
    tell ("increment: " ++ show x ++ "\n")
    return (x + 1)

logIncrement2 :: Int -> Writer String Int
logIncrement2 x = do
    y <- logIncrement x
    logIncrement y

-- Monada state
newtype MyState st a = MyState {runState :: st -> (a, st)}

-- Monada Reader (stare nemodificaila)
newtype Reader env a = Reader { runReader :: env -> a }
    deriving(Functor, Applicative) 

instance Monad (Reader env) where
    return = pure
    -- return x = Reader (\_ -> x)
    ma >>= k = Reader f
        where f env = let a = runReader ma env
                      in runReader (k a) env
    
ask :: Reader env env
ask = Reader id

data Prop = Var String | Prop :&: Prop
type Env = [(String, Bool)]

var :: String -> Reader Env Bool
var x = do
    env <- ask
    return $ fromMaybe False (lookup x env)
-- var = undefined

eval :: Prop -> Reader Env Bool
eval (Var x) = var x
eval (p1 :&: p2) = do
    b1 <- eval p1
    b2 <- eval p2
    return (b1 && b2)


    






