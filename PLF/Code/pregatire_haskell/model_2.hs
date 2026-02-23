import Test.QuickCheck (Arbitrary (arbitrary), elements, quickCheck)
import Prelude hiding (Left, Right)
-- Prezentarea tipurilor de date

type Pos = Int

data Elem = Head | Tail | Food

data GamePosition = GamePos {
    xPos :: Pos,
    yPos :: Pos
}

data GameBoard = GameBoard [(Elem, GamePosition)]

boardExample :: GameBoard
boardExample = GameBoard [(Tail, GamePos { xPos = 1, yPos = 0 }),
    (Tail, GamePos { xPos = 1, yPos = 1}),
    (Tail, GamePos { xPos = 1, yPos = 2}),
    (Tail, GamePos { xPos = 2, yPos = 2}),
    (Tail, GamePos { xPos = 3, yPos = 2}),
    (Head, GamePos { xPos = 3, yPos = 3}),
    (Food, GamePos { xPos = 4, yPos = 3})]

-- TODO ex 1
instance Eq Elem where
    (==) :: Elem -> Elem -> Bool
    Head == Head = True
    Tail == Tail = True
    Food == Food = True
    _ == _ = False

instance Show Elem where
    show Head = "Head"
    show Tail = "Tail"
    show Food = "Food"

instance Eq GamePosition where
    p1 == p2 =
        xPos p1 == xPos p2 && yPos p1 == yPos p2

instance Show GamePosition where
    show :: GamePosition -> String
    show (GamePos x y) =
        "xPos: " ++ show x ++ " " ++ "yPos: " ++ show y

    -- show g = 
    --     "xPos: " ++ show (xPos g) ++ " " ++ "yPos: " ++ show (yPos g)

instance Show GameBoard where
    show (GameBoard l) = "Board: " ++ show l

-- TODO ex 2
getHead :: GameBoard -> Maybe GamePosition
getHead (GameBoard []) = Nothing
getHead (GameBoard ((elem, pos):xs))
    | elem == Head = Just pos
    | otherwise    = getHead (GameBoard xs)

getHead' :: GameBoard -> Maybe GamePosition
getHead' (GameBoard xs) = foldr (\(elem,pos) u -> if elem == Head then Just pos else u) Nothing xs

instance Arbitrary Elem where
    arbitrary = do
        elements [Head, Tail, Food]

instance Arbitrary GamePosition where
    arbitrary = do
        xPosa <- arbitrary
        yPosa <- arbitrary
        return $ GamePos xPosa yPosa

instance Arbitrary GameBoard where
    arbitrary = do
        l <- arbitrary
        return $ GameBoard l

prop_qc b =
    getHead b == getHead' b

test_prop_qc = quickCheck prop_qc

-- TODO ex 3
data Direction = Left | Right | Up | Down deriving (Eq, Show)

oneMove :: GameBoard -> Direction -> Maybe GameBoard
oneMove (GameBoard positions) dir =
    case getHead (GameBoard positions) of
        Nothing -> Nothing
        Just headPos ->
            let newHeadPos = movePosition headPos dir
                snakeBody = [pos | (elem, pos) <- positions, elem == Tail || elem == Head]
            in if newHeadPos `elem` snakeBody
               then Nothing
               else
                   let
                       withOldHeadAsTail = map (\(elem, pos) -> if elem == Head then (Tail, pos) else (elem, pos)) positions
                       withNewHead = (Head, newHeadPos) : withOldHeadAsTail
                       snakeParts = [(elem, pos) | (elem, pos) <- withNewHead, elem == Head || elem == Tail]
                       foodParts = [(elem, pos) | (elem, pos) <- withNewHead, elem == Food]
                       shortenedSnake = if length snakeParts > 1 then init snakeParts else snakeParts
                   in Just (GameBoard (shortenedSnake ++ foodParts))

movePosition :: GamePosition -> Direction -> GamePosition
movePosition (GamePos x y) dir = case dir of
    Left  -> GamePos (x - 1) y
    Right -> GamePos (x + 1) y
    Up    -> GamePos x (y + 1)
    Down  -> GamePos x (y - 1)


-- TODO ex 4
type SnakeLog = String
data SnakeWriter a = SnakeWriter { runSnakeWriter :: (a, SnakeLog) }
    deriving Show

instance Functor SnakeWriter where
    fmap :: (a -> b) -> SnakeWriter a -> SnakeWriter b
    fmap f (SnakeWriter (a, log)) = SnakeWriter (f a, log)

instance Applicative SnakeWriter where
    pure x = SnakeWriter (x, "")
    (<*>) :: SnakeWriter (a -> b) -> SnakeWriter a -> SnakeWriter b
    SnakeWriter(f, log1) <*> SnakeWriter(x, log2) = SnakeWriter (f x, log1 ++ log2)

instance Monad SnakeWriter where
    return = pure
    (>>=) :: SnakeWriter a -> (a -> SnakeWriter b) -> SnakeWriter b
    SnakeWriter (a, log1) >>= f =
        let SnakeWriter (b, log2) = f a
        in SnakeWriter (b, log1 ++ log2)

oneMoveMonad :: GameBoard -> GamePosition -> SnakeWriter GameBoard
oneMoveMonad (GameBoard positions) newHeadPos = do
    let snakeBody = [pos | (elem, pos) <- positions, elem == Tail || elem == Head]
    if newHeadPos `elem` snakeBody
       then do
           SnakeWriter ((), "Game Over! Snake bit itself at position " ++ show newHeadPos ++ "\n")
           return (GameBoard positions)
       else do
           SnakeWriter ((), "Moved head to position " ++ show newHeadPos ++ "\n")
           let withOldHeadAsTail = map (\(elem, pos) -> if elem == Head then (Tail, pos) else (elem, pos)) positions
               withNewHead = (Head, newHeadPos) : withOldHeadAsTail
               snakeParts = [(elem, pos) | (elem, pos) <- withNewHead, elem == Head || elem == Tail]
               foodParts = [(elem, pos) | (elem, pos) <- withNewHead, elem == Food]
               shortenedSnake = if length snakeParts > 1 then init snakeParts else snakeParts
               newBoard = GameBoard (shortenedSnake ++ foodParts)
           return newBoard


