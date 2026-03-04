import Control.Concurrent
import Control.Monad

inc :: MVar Int -> MVar () -> IO ()
inc cnt done = do
    replicateM_ 1000 $ do
        _cnt <- takeMVar cnt
        putMVar cnt (_cnt + 1)
    putMVar done ()
    
main = do
    m <- newMVar 0
    done1 <- newEmptyMVar
    done2 <- newEmptyMVar

    forkIO $ inc m done1
    forkIO $ inc m done2

    takeMVar done1
    takeMVar done2

    x <- takeMVar m
    print x
