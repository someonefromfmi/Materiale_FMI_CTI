import Control.Concurrent 
import Control.Monad 
import Data.Char

load wordsIn = forever $ do
    str <- getLine
    if str == "exit" then return ()
    else do
        writeChan wordsIn str

move wordsIn wordsOut = do
    str <- readChan wordsIn
    let ls = words str
    mapM_ (writeChan wordsOut) ls

writeStdOut wordsOut = do
    str <- readChan wordsOut
    putStrLn $ map toUpper str

main = do
    wordsIn <- newChan
    wordsOut <- newChan

    forkIO $ forever $ move wordsIn wordsOut
    forkIO $ forever $ writeStdOut wordsOut

    load wordsIn