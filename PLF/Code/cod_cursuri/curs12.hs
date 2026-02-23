import Prelude hiding (return)
import Data.Char
import Control.Monad ((<=<))
-- examen: definiri monade, combinatii monade predefinite

-- Functii imbogatite si efecte
-- exp: tipul Maybe a
f :: Int -> Maybe Int
f x = if x < 0 then Nothing else Just x

-- exp: Folosind un tip care are ca efect un mesaj
-- logging in haskell: "imbogatim" rez fc cu mesajul de log
-- ! datele de tip Writer log a sunt definite folosind inregistrari
-- ! o data de tip Writer log a are una din formele 
{-
! Writer (va, vlog) sau Writer { runWriter = (va, vlog) }
! unde va :: a si vlog :: log 
-}
-- ! runWriter este fc de proiectie:
-- ! runWriter :: Writer log a -> (a, log)
-- ! de exemplu runWriter (Writer (1, "msg")) = (1, "msg")
newtype Writer log a = Writer { runWriter :: (a, log) }
f' :: Int -> Writer String Int
f' x = if x < 0 then (Writer (-x, "negativ"))
                else (Writer (x, "pozitiv"))
{-
! Compunerea functiilor
- principala op pe care o facem cu functii este compunerea
f :: a -> b, g :: b -> c, g . f :: a -> c
(.) :: (b -> c) -> (a -> b) -> a -> c
- Ce facem daca f :: a -> m b, g :: b -> m c unde m este un 
constructor de tip care imbogateste tipul?
De ex: 
- m = Maybe
- m = Writer log
! Atentie: m trebuie sa aiba un singur argument 
Vrem sa definim o "compunere" pentru functii imbogatite
(<=<) :: (b -> m c) -> (a -> m b) -> a -> m c
Atunci cand definim g <=< f trebuie sa extragem val intoarsa de f
si sa o trimitem lui g.
-} 
-- exemplu pentru logging:
logIncrement :: Int -> Writer String Int
logIncrement x = Writer
    (x + 1, 
                "Called increment with argument " ++ show x ++ "\n")

-- ! Problema: Cum calculam logIncrement (logINcrement x)?

logIncrement2 :: Int -> Writer String Int
logIncrement2 x =
    let (y, log1) = runWriter (logIncrement x)
        (z, log2) = runWriter (logIncrement y)
    in Writer (z, log1 ++ log2)

{-
! Problema generala
Data fiind functia f :: a -> m b si functia g :: b -> m c, vreau
sa obt o fc g <=< f :: a -> m c care este "compunerea" lui g si f,
propagand efectele laterale
-}

-- clasa de tipuri Monad
{-
class Applicative m => Monad m where
    (>>=) :: m a -> (a -> m b) -> m b
    (>>) :: m a -> m b -> m b
    return :: a -> m a

    ! ma >> mb = ma >>= \_ -> mb

    - m a este tipul computatiilor care produc rezultate de tip a 
    (si au efecte laterale)
    - a -> m b este tipul continuarilor / a functiilor cu efecte laterale
    - >>= este operatia de "secventiere" a computatiilor
    - in Control.Monad sunt def:
        - f >=> g = \x -> f x >>= g
        - (<=<) = flip (>=>)
    ! In Haskell, monada este o clasa de tipuri.
-}

-- proprietatile monadelor
{-
elem neutru la dr: (return x) >>= g = g x
            la stg: x >>= return = x
asociativitate : (f >>= g) >>= h = f >>= (\x -> (g x >>= h))
-}

{-
Notattia do pentru monade
Notatia cu operatori | Do
e >>= \x -> rest     | x <- e
                     | rest
e >>= \_->rest       | e
                     | rest
e >> rest            | e
                     | rest
-}





