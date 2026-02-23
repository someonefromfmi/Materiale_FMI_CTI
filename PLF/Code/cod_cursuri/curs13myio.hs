import Data.Char (toUpper)
type Input = String
type Output = String

newtype MyIO a = MyIO {
    runMyIO :: Input -> (a, Input, Output)
}

instance Monad MyIO where
  (>>=) :: MyIO a -> (a -> MyIO b) -> MyIO b
  (>>=) m k = MyIO f
    where f input = let (x, inputx, outputx) = runMyIO m input
                        (y, inputy, outputy) = runMyIO (k x) inputx
                    in (y, inputy, outputx ++ outputy)
  return :: a -> MyIO a
  return x = MyIO (\input -> (x, input, ""))


instance Applicative MyIO where
    pure :: a -> MyIO a
    pure = return
    (<*>) :: MyIO (a -> b) -> MyIO a -> MyIO b
    mf <*> ma = do { f <- mf; a <- ma; return (f a)}

instance Functor MyIO where
    fmap :: (a -> b) -> MyIO a -> MyIO b
    fmap f ma = do { a <- ma; return (f a)}

myPutChar :: Char -> MyIO ()
myPutChar c = MyIO (\input -> ((), input, [c]))

myGetChar :: MyIO Char
myGetChar = MyIO (\(c:input) -> (c, input, ""))

runIO :: MyIO () -> String -> String
runIO command input = third (runMyIO command input) 
    where third (_,_,x) = x
-- primind o comanda si un sir de intrare, intoarce sirul de iesire

myPutStr :: String -> MyIO ()
myPutStr = foldr (>>) (return ()) . map myPutChar

myPutStrLn :: String -> MyIO ()
myPutStrLn s = myPutStr s >> myPutChar '\n'

myGetLine :: MyIO String
myGetLine = do
    x <- myGetChar
    if x == '\n'
        then return []
        else do
            xs <- myGetLine
            return (x:xs)

echo1 :: MyIO ()
echo1 = do {x <- myGetChar ; myPutChar x}

echo2 :: MyIO ()
echo2 = do {x <- myGetLine ; myPutStrLn x}

echo :: MyIO ()
echo = do
    line <- myGetLine
    if line == ""
        then return ()
        else do
            myPutStrLn (map toUpper line)
            echo

-- legatura cu IO
convert :: MyIO () -> IO ()
convert = interact . runIO

-- clasa de tipuri pentru IO
-- putem def o clasa de tipuri pt a oferi servicii de I/O

class Monad io => MyIOClass io where
    myGetChar' :: io Char -- read a character
    myPutChar' :: Char -> io () -- write a character
    runIO' :: io () -> String -> String
    -- given a command and an input, produce the output
    -- celelalte functionalitati I/O pot fi definite generic
    -- in clasa MyIOClass

-- analog implementarile




