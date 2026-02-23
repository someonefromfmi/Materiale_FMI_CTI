-- Monade
-- reprez o structura care permite manipularea
-- codului intr-un mod imperativ
-- pt a impl o monada avem nevoide de functori si
-- functori aplicativi (teoria categoriilor)

-- Functor, Applicative, Monad

-- Functor - generalizeaza map -> fmap
-- fmap :: (a -> b) -> m a -> m b
-- Applicative Functor 
-- pure :: a -> f a - impacheteaza valori in context
-- <*> :: f ( a -> b ) -> f a -> f b - generalizeaza fmap

-- Monad - f1 . f2 . ... . fn -> rez := f1 . f2 ...
--          |    |          |      |
--           side effects        side effect final
-- return :: a -> m a - impacheteaza valori in context     
-- (>>=) :: m a -> (a -> m b) -> m b - secventiaza
-- aplicarea unei fc

-- (>>=), daca este def, permite scrierea cu do-notation

-- Monada Writer
-- este o structura care imi permite sa efectuez
-- calcule/operatii si, in plus, sa tinem un log
-- al acestor operatii

-- env: tipul log-urilor, exp [String]
-- a: tipul operatiilor, exp Int

-- data Writer env a = Writer (a, env)
newtype Writer env a = Writer { runWriter ::(a, env) }
    deriving(Show)

-- newtype este data, dar pt o singura fc incapsulata
-- nu e gresit sa lasam data

-- pt a constr monada writer, trecem prin Functor ->
-- -> Applicative -> Monad

instance Functor (Writer env) where
    fmap f (Writer (a, env)) = Writer (f a, env)

instance Monoid env => Applicative (Writer env) where
    pure x = Writer (x, mempty)
    (<*>) :: Monoid env => Writer env (a -> b) -> Writer env a -> Writer env b
    (<*>) (Writer (f, env1)) (Writer (x, env2)) = Writer (f x, env1 <> env1)

instance Monoid env => Monad (Writer env) where
    return = pure
    Writer(x, env1) >>= f =
        let Writer (y, env2) = f x 
        in Writer (y, env1 <> env2) 

tell :: env -> Writer env ()
tell env = Writer ((), env)

type WriterString = Writer [String]

calc :: Int -> WriterString Int
calc x = do 
    tell ["Starting with: " ++ show x] 
    let y = x + 1
    tell ["Added 1, got " ++ show y]
    let z = y * 2
    tell ["Multiplied by 2, got " ++ show z]

    return z

main :: IO ()
main = do
    let (res, log) = runWriter $ calc 3
    putStrLn $ "Result: " ++ show res
    putStrLn "Log: "
    mapM_ putStrLn log

-- monada pt evaluarea expresiilor in arbori

data ExprTree = Num Int 
              | Add ExprTree ExprTree
              | Sub ExprTree ExprTree
              | Mul ExprTree ExprTree
              | Div ExprTree ExprTree
              deriving (Eq, Show)

-- data Either a b = Left a | Right b
-- Left -> pt erori, Right -> pt val corecte
newtype EvalM a = EvalM { runEvalM :: ([String], Either String a) }

-- pt a constr monada, avem nevoie de Functor -> Applicative -> Monad
instance Functor EvalM where
    fmap f (EvalM (log, Right x)) = EvalM (log, Right (f x))
    fmap _ (EvalM (log, Left e)) = EvalM (log, Left e)

instance Applicative EvalM where
    pure x = EvalM ([], Right x)
    EvalM (log1, Right f) <*> EvalM (log2, Right x) = EvalM (log1 ++ log2, Right (f x))
    EvalM (log1, Left e) <*> EvalM (log2, _) = EvalM (log1 ++ log2, Left e)
    _ <*> EvalM (log2, Left e) = EvalM (log2, Left e)

instance Monad EvalM where
    return = pure
    (EvalM (log1, Right x)) >>= f =
        let EvalM (log2, result) = f x
        in EvalM (log1 ++ log2, result)
    (EvalM (log1, Left e)) >>= _ = EvalM (log1, Left e)

logStep :: String -> EvalM () 
logStep msg = EvalM ([msg], Right ())
 
eval :: ExprTree -> EvalM Int 
eval (Num x) = do 
    logStep ("Found number " ++ show x)
    return x 
eval (Add e1 e2) = do 
    v1 <- eval e1 
    v2 <- eval e2 
    let res = v1 + v2 
    logStep (show v1 ++ " + " ++ show v2 ++ " = " ++ show res)
    return res 
eval (Sub e1 e2) = do 
    v1 <- eval e1 
    v2 <- eval e2 
    let res = v1 - v2 
    logStep (show v1 ++ " - " ++ show v2 ++ " = " ++ show res)
    return res 
eval (Mul e1 e2) = do 
    v1 <- eval e1 
    v2 <- eval e2 
    let res = v1 * v2 
    logStep (show v1 ++ " * " ++ show v2 ++ " = " ++ show res)
    return res 
eval (Div e1 e2) = do 
    v1 <- eval e1 
    v2 <- eval e2 
    if v2 == 0 
        then EvalM (["Division by zero!"], Left "Cannot divide by zero!")
        else do 
            let res = v1 `div` v2 
            logStep (show v1 ++ " / " ++ show v2 ++ " = " ++ show res)
            return res 

expr :: ExprTree
expr = Div (Add (Num 4) (Mul (Num 2) (Num 3))) (Sub (Num 10) (Num 5))

evalExpr :: IO ()
evalExpr = do
    let EvalM (log, result) = eval expr
    putStrLn "Evaluation trace: "
    mapM_ putStrLn log
    putStrLn $ "Result is: " ++ show result