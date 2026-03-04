data LList a = Nil | Cons a (LList a)
	deriving (Show, Eq)

l1 :: LList Int
l1 = Cons 1 $ Cons 2 $ Cons 3 Nil

lAppend :: LList a -> LList a -> LList a
lAppend Nil l2 = l2
lAppend (Cons x xs) l2 = Cons x (lAppend xs l2)