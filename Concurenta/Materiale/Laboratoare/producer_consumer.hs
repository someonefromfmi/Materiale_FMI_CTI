import Control.Concurrent
import Control.Monad



producer :: MVar String -> IO ()
producer m = forever $ do
    msg <- getLine
    putMVar m msg

consumer m n = if n == 0
    then return ()
    else do
        msg <- takeMVar m
        putStrLn $ "Consumed: " ++ msg
        consumer m (n - 1)

main :: IO ()
main = do
    m <- newEmptyMVar
    let itemCount = 10
    forkIO $ producer m
    consumer m itemCount