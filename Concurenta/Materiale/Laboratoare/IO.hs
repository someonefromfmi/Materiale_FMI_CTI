import Control.Concurrent
import Control.Monad
 
takeprint :: MVar () -> String -> IO ()
takeprint m str = do
    takeMVar m --aquire
    putStrLn str
    putMVar m () --release
 
-- takeprint :: MVar String -> IO ()
-- takeprint m = do
--     str <- takeMVar m
--     putStrLn str
--     dummy <- takeMVar m
--     putStr ""
 
hello :: MVar () -> MVar () -> IO ()
hello m finish = do
    takeprint m "Hello"
    putMVar finish () --release
 
main = do
    m <- newMVar()
    finish <- newEmptyMVar
    forkIO $ hello m finish
 
    takeMVar finish --aquire
    --forkIO $ forever $ takeprint m

