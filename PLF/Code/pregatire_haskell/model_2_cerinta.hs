import Test.QuickCheck (Arbitrary (arbitrary))
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
-- instance Eq Elem where

-- instance Show Elem where

-- instance Eq GamePosition where

-- instance Show GamePosition where

-- TODO ex 2
getHead :: GameBoard -> Maybe GamePosition
getHead = undefined

getHead' :: GameBoard -> Maybe GamePosition
getHead' = undefined

instance Arbitrary Elem where
    arbitrary = undefined

instance Arbitrary GamePosition where
    arbitrary = undefined

-- TODO ex 3
data Direction = Left | Right | Up | Down deriving (Eq, Show)

oneMove :: GameBoard -> Direction -> Maybe GameBoard
oneMove = undefined

-- TODO ex 4
type SnakeLog = String
data SnakeWriter a = SnakeWriter { runSnakeWriter :: (a, SnakeLog) }
    deriving Show

-- instance Functor SnakeWriter where

-- instance Applicative SnakeWriter where

-- instance Monad SnakeWriter where

oneMoveMonad :: GameBoard -> GamePosition -> SnakeWriter GameBoard
oneMoveMonad = undefined


