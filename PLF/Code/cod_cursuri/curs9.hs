
numbers = [1, 2, 3, 4, 5]
total = foldl (*) 0 numbers
doubled = map (*2) numbers

-- comment pe o linie
{-
    comment pe mai
    multe linii
-}

fact n = if n == 0
         then 1
         else n * fact(n-1)

fact1 0 = 1
fact1 n = n * fact(n-1)

fact2 n
  | n == 0 = 1
  | otherwise = n * fact (n - 1)

-- legare de variabile
trei = let a = 1
           b = 2
        in a + b -- expresie

trei' = let {a = 1; b = 2} in a + b
trei'' = let a = 1; b = 2 in a + b

x = 1
-- x = 3 crapa din cauza imuabilitatii
z = let x = 3 in x -- nu crapa: let ... in ... creeaza scop local

x' = let 
        z = 5
        g u = z + u
    in let 
            z = 7
        in g 0 + z
-- x = 12

x'' = let z = 5; g u = z + u
      in let z = 7 in g 0
-- x = 5

-- si ...where... creeaza scop local
f x = g x + g x + z 
    where
        g x = 2 * x
        z = x - 1 -- clauza

-- let ... in ... este o expresie
x''' = [let y = 8 in y, 9] -- x = [8,9]

{-
where este o clauza, disponibila doar la nivel de definitie
x = [y where y = 8 , 9] - crapa
-}

-- pattern matching / expresia case
h x | x == 0 = 0
    | x == 1 = y + 1
    | x == 2 = y * y 
    | otherwise = y
  where y = x * x

f' x = case x of 
    0 -> 0
    1 -> y + 1
    2 -> y * y
    _ -> y
  where y = x * x 

-- tipuri de date

data RGB = Rosu | Verde | Albastru

db :: Integer -> Integer
db a = a + a

double x = 2 * x
data Point a = Pt a a -- tip parametrizat, a este variab de tip

-- intervale si progresii
interval = ['c' .. 'e'] -- ['c', 'd', 'e']
progresie = [20, 17 .. 1] -- [20, 17, 14, 11, 8, 5, 2]
progresie' = [2.0, 2.5..4.0] -- [2.0, 2.5, 3.0, 3.5, 4.0]

-- liste infinite
natural = [0..]
first5 = take 5 natural

evenNat = [0,2..] -- progresie infinita
first7even = take 7 evenNat

ones = [1,1..]
zeros = [0, 0..]
both = zip ones zeros
nums = take 5 both

-- functii anonime si sectiuni
inc = \x -> x + 1
add = \x y -> x + y
aplic = \f x -> f x

-- functii de ordin inalt
g xs = [ x * 3 | x <- xs, x >= 2]
g' xs = map (* 3) (filter (>= 2) xs)
g'' = map (* 3 ) . filter (>=2)

-- filtrare, transformare, agregare
q xs = sum [x * x | x <- xs, x > 0] -- descrieri de liste si fc de
-- agregare standard
q' xs = foldr (+) 0 (map sqr (filter pos xs)) -- functii auxiliare
  where
    sqr x = x * x
    pos x = x > 0

q'' xs = foldr (+) 0
            (map (\x -> x * x) (filter (\x -> x > 0) xs))

maxLengthFn = foldr max 0 .
              map length .
              filter (\x -> head x == 'c')


-- 99 problems for haskell




