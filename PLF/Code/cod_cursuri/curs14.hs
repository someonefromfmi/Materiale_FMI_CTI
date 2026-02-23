import Control.Monad
import Data.Functor.Identity
import Control.Monad.Writer
import Control.Monad.Reader
import Control.Monad.State
-- interpretoare monadice
type Name = String
data Term = Var Name
          | Con Integer
          | Term :+: Term
          | Lam Name Term
          | App Term Term
          | Amb Term Term -- instructiuni
          | Fail          -- nedeterministe
          | Out Term -- adaugare unei instructiuni de afisare
          | Count
{-
adaugam un contor de instructiuni 'Count', valoarea acestui contor
reprezentand starea.
Astfel, variabilele care reprezinta stare sunt numere intregi.
-}

data Value = Num Integer
           | Fun (Value -> M Value)
           -- vom interpreta termenii in valori 'M Value', unde
           -- 'M' este o monada; variind se obtin comportamente
           -- diferite
           | Wrong
           -- reprezinta o eroare, de exp adunarea unor valori
           -- care nu sunt numere sau aplicarea unui termen care
           -- nu e functie

-- valori si medii de evaluare
instance Show Value where
    show (Num x) = show x
    show (Fun _) = "<function>"
    show Wrong   = "<wrong>"


-- Evaluare - variabile si valori
type Environment = [(Name, Value)]

--interpretarea termenilor in monada 'M'
interp :: Term -> Environment -> M Value
interp (Var x) env   = lookupM x env
interp (Con i) _     = return $ Num i
interp (Lam x e) env = return $
        Fun $ \v -> interp e $ (x,v) : env
-- evaluare: adunare
interp (t1 :+: t2) env = do
    v1 <- interp t1 env
    v2 <- interp t2 env
    addS v1 v2
-- evaluare - aplicarea functiilor
interp (App t1 t2) env = do
    f <- interp t1 env
    v <- interp t2 env
    applyS f v
-- interp Fail _ = []
-- interp (Amb t1 t2) env = interp t1 env ++ interp t2 env
-- interp (Out t) env = do
--     v <- interp t env
--     tell (show v ++ "; ")
--     return v
-- Out t se evalueaza la valoare lui t, cu efectul lateral
-- de a adauga valoarea la sirul de iesire
interp Count _ = do
    i <- get
    return (Num i)

lookupM :: Name -> Environment -> M Value
lookupM x env = case lookup x env of
    Just v -> return v
    Nothing -> return Wrong

-- interpretarea adunarii in monada 'M'
add :: Value -> Value -> M Value
add (Num i) (Num j) = return (Num (i + j))
add _ _ = return Wrong

-- interpretarea aplicarii functiilor in monada 'M'
apply :: Value -> Value -> M Value
apply (Fun k) v = k v -- k :: Value M Value
apply _ _       = return Wrong

test :: Term -> String
test t = showM $ interp t []

-- showM :: Show a => M a -> String

-- program - exemple
pgm :: Term
pgm = App
        (Lam "x" (Var "x" :+: Var "x"))
        (Con 10 :+: Con 11)

pgm' :: Term
pgm' = App
    (Lam "y"
        (App
            (App
                (Lam "f"
                    (Lam "y"
                        (App (Var "f") (Var "y"))
                    )
                )
                (Lam "x"
                    (Var "x" :+: Var "y")
                )
            )
            (Con 3)
        )
    )
    (Con 4)

-- test pgmW -- apelul pt testare

-- Interpretor monadic
-- in continuare vom inlocui monada cu:
-- ! Identity - efectul identitate
-- pt a particulariza interpretorul, definim:
-- type M a = Identity a

-- showM :: Show a => M a -> String
-- showM = show . runIdentity

-- obtinem interpretorul standard, asemanatorul celui discutat
-- pentru limbajul Mini-Haskell

-- ! Interpretare in monada Maybe (optiune)
-- putem renunta la la valoarea Wrong, folosinf monada 'Maybe'
-- type M a = Maybe a
-- showM :: Show a => M a -> String
-- showM (Just a) = show a
-- showM Nothing  = "<wrong>" 

-- ! Interpretare in monada 'Either String'
-- type M a = Either String a
-- showM :: Show a => M a -> String
-- showM (Left s) = "Error: " ++ s
-- showM (Right a)  = "Success: " ++ show a 
-- putem nuanta erorile folosind monada 'Either String'
-- putem inlocui Wrong cu Left

-- ! Interpretare in monada listelor
-- adaugarea unei instructiuni nedeterministe
-- type M a = [a]
-- showM :: M Value -> String
-- showM = show

pgm'' = App
            (Lam "x" $ Var "x" :+: Var "x")
            (Amb (Con 1) (Con 2))

-- Interpretare in monada 'Writer'
-- functie ajutatoare
-- tell :: log -> Writer log ()
-- tell log = Writer ((), log) -- produce mesajul
-- type M a = Writer String a
-- showM :: Show a => M a -> String
-- showM ma = "Output: " ++ w ++ " Value: " ++ show a
--     where (a, w) = runWriter ma

-- pgmW = App
--         (Lam "x" (Var "x" :+: Var "x"))
--         (Out (Con 10) :+: Out (Con 11))
-- type Parser a = String -> [(a, String)]

-- ! Interpretare in monada 'Reader'
-- face accesibila o memorie (environment) nemodificabila (imuabila)
-- fc ajutatoare:
-- ask :: Reader r r -- obt memoria
-- local :: (r -> r) -> Reader r a -> Reader r a -- modif memoria
-- type M a = Reader Environment a
-- showM :: Show a => M a -> String
-- showM ma = show $ runReader ma []

-- deoarece interpretam in monada 'Reader Environment a ' signatura
-- functiei de interpretare este:
-- interpR :: Term -> M Value
-- interpR (Var x) = lookupR x
-- interpR (Con i) = return $ Num i
-- interpR (t1 :+: t2) = do
--     v1 <- interpR t1
--     v2 <- interpR t2
--     add v1 v2
-- interpR (App t1 t2) = do
--     f <- interpR t1
--     v <- interpR t2
--     apply f v
-- interpR (Lam x e) = do
--     env <- ask
--     return $ Fun $ \v ->
--         local (const ((x,v):env)) (interpR e)

-- lookupR :: Name -> M Value
-- lookupR x = do
--     env <- ask
--     case lookup x env of
--         Just v  -> return v
--         Nothing -> return Wrong

-- ! Interpretare in monada State
-- Functii ajutatoare:
-- get :: State st st -- intoarce stare curenta
-- set :: st -> State st () -- seteaza s ca stare curenta
-- modify :: (st -> st) -> State st () -- modifica stare curenta
type M a = State Integer a

showM :: Show a => M a -> String
showM ma = show a ++ "\n" ++ "Count: " ++ show s
    where (a, s) = runState ma 0

tickS :: M ()
tickS = modify (+1) -- \s -> ((), (s+1))

addS :: Value -> Value -> M Value
addS (Num i) (Num j) = tickS >> return (Num $ i + j)
addS _ _              = return Wrong

applyS :: Value -> Value -> M Value
applyS (Fun k) v = tickS >> k v
applyS _ _       = return Wrong
