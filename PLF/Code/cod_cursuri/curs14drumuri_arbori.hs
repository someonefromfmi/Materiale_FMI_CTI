import Data.Maybe (fromMaybe)
import Test.QuickCheck (elements)
import Test.QuickCheck.Arbitrary
import Control.Monad
-- drumuri in arbori binari
-- arbore binar (exemplu)
data Binar a = Gol | Nod (Binar a) a (Binar a)

exemplu :: Binar Integer
exemplu = Nod 
            (Nod (Nod Gol 2 Gol) 4 (Nod Gol 5 Gol))
            7
            (Nod Gol 9 Gol)

-- un drum in acest arbore il reprezentam ca o secv de directii:
data Directie = Stanga | Dreapta
    deriving (Show)

type Drum = [Directie]

-- Exercitii
{-
a) Dat fiind un drum in arbore, determinati informatia din nodul la
care se ajunge parcurgand directiile date. Daca se ajunge la un nod
gol se va intoarce Nothing
-}

test1, test2 :: Bool
test1 = plimbare [Stanga, Dreapta] exemplu == Just 5
test2 = plimbare [Dreapta, Stanga] exemplu == Nothing

plimbare :: Drum -> Binar a -> Maybe a
plimbare _ Gol = Nothing
plimbare [] (Nod _ x _) = Just x
plimbare (Stanga : is) (Nod st _ _) = plimbare is st
plimbare (Dreapta : is) (Nod _ _ dr) = plimbare is dr

{-
b) Pentru arbori cu elemente de tip Integer definiti o proprietate
care verifica ca nodul final al unui drum este gol sau contine un
element pozitiv
-}

propArb :: Binar Integer -> Drum -> Bool
propArb arb d = fromMaybe 0 (plimbare d arb) >= 0

{-
folosind quickCheck testati ca drumurile unui arbore au aceasta
proprietate sau determinati un contraexemplu 
-}

{-
pt a folosi quickCheck, trebuie sa definim o instanta a clasei 
Arbitrary:
-}

instance Arbitrary Directie where
    arbitrary = elements [Dreapta, Stanga]

ceexemplu = Nod 
            (Nod (Nod Gol (-2) Gol) 4 (Nod Gol 5 Gol))
            7
            (Nod Gol 9 Gol)

{-
c) Presupun ca arborii contin informatie de tip (Cheie, Valoare)
si ca sunt arbori de cautare dupa cheie (elementele din subarbo-
rele stg au cheia mai mica decat cheia din radacina, iar cele din 
subarborele drept au cheia mai mare decat cea din radacina)
-}

type Cheie = Integer
type Valoare = Float

ex :: Binar (Integer, Float)
ex = Nod 
        (Nod
            (Nod Gol (2, 3.5) Gol)
            (4, 1.2)
            (Nod Gol (5, 2.4) Gol))
        (7, 1.9)
        (Nod Gol (9, 0.0) Gol)

{-
Definim monada Writer specializata la String:
-}

newtype WriterStr a = Writer {runWriter :: (a, String) }

instance Monad WriterStr where
    return x = Writer (x, "")
    ma >>= k = let (x, logx) = runWriter ma
                   (y, logy) = runWriter (k x)
                in Writer (y , logx ++ logy)

instance Applicative WriterStr where
    pure = return
    (<*>) = ap 

instance Functor WriterStr where
    fmap = liftM

tell :: String -> WriterStr ()
tell s = Writer ((), s)

{-
scrieti o functie care cauta in arbore valoarea corespunzatoare unei
chei date, intoarce aceasta valoare (daca exista) si are ca efect
lateral inregistrarea drumului parcurs.
-}

cauta :: Cheie -> Binar (Cheie, Valoare) -> WriterStr (Maybe Valoare)
cauta cheie (Nod st (cheie', valoare) dr)
    | cheie == cheie' = return (Just valoare)
    | cheie < cheie' = do
            tell "Stanga;"
            cauta cheie st
    | otherwise = do
        tell "Dreapta;"
        cauta cheie dr
cauta cheie Gol = return Nothing

test3, test4 :: Bool
test3 = runWriter (cauta 5 ex) == (Just 2.4, "Stanga;Dreapta;")
test4 = runWriter (cauta 8 ex) == (Nothing, "Dreapta;Stanga;")


