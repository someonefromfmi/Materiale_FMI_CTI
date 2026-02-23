import Data.List
import Data.Maybe

type Name = String

-- sintaxa
data Hask = HTrue
          | HFalse
          | HLit Int
          | HIf Hask Hask Hask
          | Hask :==: Hask
          | Hask :+: Hask
          | HVar Name
          | HLam Name Hask
          | Hask :$: Hask
    deriving (Read, Show)

infix 4 :==:
infixl 6 :+:
infixl 9 :$:

-- exemplu de expresie
h0 = 
    (HLam "x" (HLam "y" (HVar "x" :+: HVar "y")))
    :$: HLit 3
    :$: HLit 4

-- domenii semantice
data Value = VBool Bool
           | VInt Int
           | VFun (Value -> Value)
           | VError -- pt reprezentarea erorilor

-- mediul de evaluare
type HEnv = [(Name, Value)]
-- unei variab Name i se va asocia o val Value
-- la abstractizare

-- domeniul de evaluare
type DomHask = HEnv -> Value
-- diecarei expresii i se va asocia ca denotatie
-- o functie de la medii de evaluare la valori

-- afisarea valorilor expressilor din Hask
instance Show Value where
    show (VBool b) = show b
    show (VInt i)  = show i
    show (VFun _)  = "<function>"
    show VError    = "<error>"

-- ! functiile nu pot fi afisate efectiv, 
-- ! ci doar generic

-- Egalitate pentru valori
instance Eq Value where
    (VBool b) == (VBool c) = b == c
    (VInt i) == (VInt j)   = i == j
    (VFun _) == (VFun _)   = error "Unkown"
    VError == VError       = error "Unkown"
    _      == _            = False

-- ! functiile si erorile nu pot fi testate daca
-- ! nu sunt egale

-- evaluarea expresiilor Mini-Haskell in Haskell
hEval :: Hask -> HEnv-> Value
hEval HTrue r         = VBool True
hEval HFalse r        = VBool False
hEval (HLit i) r      = VInt i
hEval (HIf c d e) r   =
    hif (hEval c r) (hEval d r) (hEval e r)
       where
        hif (VBool b) v w = if b then v else w
        hif _ _ _         = VError
hEval (d :==: e) r = heq (hEval d r) (hEval e r)
   where
    heq (VInt i) (VInt j) = VBool (i == j)
    heq  _ _              = VError
hEval (d :+: e) r = hadd (hEval d r) (hEval e r)
    where
     hadd (VInt i) (VInt j) = VInt (i + j)
     hadd _ _               = VError
-- evaluarea variabilelor Mini-Haskell in Haskell
hEval (HVar x) r = fromMaybe VError (lookup x r)
-- evaluarea lambda-expresiilor Mini-Haskell in Haskell
-- abstractizarea (intoarce o valoare de tip VFun)
hEval (HLam x e) r = VFun (\v -> hEval e ((x,v):r))
-- aplicarea (aplica o valoare de tip VFun)
hEval (d :$: e) r = happ (hEval d r) (hEval e r)
    where
     happ (VFun f) v = f v
     happ _ _        = VError

test_h0 = hEval h0 [] == VInt 7

