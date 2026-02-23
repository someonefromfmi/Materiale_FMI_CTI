import Test.QuickCheck

myreverse :: [a] -> [a] -- definita generic
myreverse [] = []
myreverse (x:xs) = (myreverse xs) ++ [x]

prdef :: [Int] -> Bool -- precizam tipul
prdef xs = (myreverse xs == reverse xs)

wrongpr :: [Int] -> Bool -- precizam tipul
wrongpr xs = myreverse xs == xs

-- generarea testelor aleatoare depinde de tipul de date
-- tipurile de date care pot fi testate cu QuickCheck trebuie
-- sa fie instante ale clasei Arbitrary

data Season = Spring | Summer | Autumn | Winter
    deriving (Show, Eq)

instance Arbitrary Season where
    arbitrary = elements [Spring, Summer, Autumn, Winter]

prdef1 :: [Season] -> Bool
prdef1 xs = (myreverse xs == reverse xs)
wrongpr1 :: [Season] -> Bool
wrongpr1 xs = myreverse xs == xs

-- definiti o instanta a clasei Arbitrary pt:
data ElemIB = I Int | B Bool
    deriving(Eq, Show)

instance Arbitrary ElemIB where
    arbitrary = do
        x <- arbitrary
        y <- arbitrary
        elements [I x, B y]

wrongpr3 :: [ElemIB] -> Bool
wrongpr3 xs = myreverse xs == xs



