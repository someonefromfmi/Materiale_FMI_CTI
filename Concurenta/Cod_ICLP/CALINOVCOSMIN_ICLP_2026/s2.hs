import Control.Concurrent
import Control.Monad
import Data.Char

producer :: Chan Int -> Int -> IO ()
producer chan capacity = forever $ do
    writeChan chan (produce 1)
    where
        produce n = n

consumer :: Chan Int -> IO ()
consumer chan = do
    val <- readChan chan
    putStrLn $ show val ++ "!"

writeStdOut :: Chan [Char] -> IO ()
writeStdOut wordsOut = do
    str <- readChan wordsOut
    putStrLn $ Prelude.map toUpper str

n' :: IO Int
n' = return 200

main :: IO ()
main = do
    n <- n'
    commChan <- newChan 

    forkIO $ producer commChan n
    consumer commChan 
    return ()
