import Control.Concurrent 
import Control.Concurrent.STM 
import Text.XHtml (action)

data TMVar_ a = TMVar_ (TVar (Maybe a))

-- Nothing -> variabila e empty
-- pentru blocare folosim retry

newEmptyTMVar_ :: STM(TMVar_ a)
newEmptyTMVar_ = do
    t <- newTVar Nothing
    return (TMVar_ t)

takeTMVar_ :: TMVar_ a -> STM (a)
takeTMVar_ (TMVar_ t) = do
    m <- readTVar t
    case m of 
        Nothing -> retry
        Just a -> do
            writeTVar t Nothing
            return a

putTMVar_ :: TMVar_ a -> a -> STM ()
putTMVar_ (TMVar_ t) x = do
    m <- readTVar t
    case m of
        Just _ -> retry
        Nothing -> do
            writeTVar t (Just x)
            return ()

data Async a = Async(TMVar_ a)

async action = do
    var <- atomically $ do
        var <- newEmptyTMVar_
        return var
    forkIO $ do
        r <- action
        atomically $ putTMVar_ var r
    return (Async var)

wait (Async var) = takeTMVar_ var

myAction x = do
    threadDelay (x * 1000000)

main = do
    promise1 <- async $ myAction 3
    promise2 <- async $ myAction 2

    r1 <- atomically $ wait promise1
    r2 <- atomically $ wait promise2

    putStrLn "uga uga"

    return ()