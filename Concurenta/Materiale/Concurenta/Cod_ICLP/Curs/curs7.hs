import Control.Concurrent.QSem -- implementare de quantity semaphore
import Control.Concurrent
import Network.HTTP
import Network.Browser
import Network.URI
import Data.ByteString
import qualified Data.ByteString as B
import System.TimeIt --parconc-examples
import Text.Printf --parconc-examples
import Data.IORef
import Control.Monad
import System.Random
import Control.Concurrent.STM
import Data.IORef (writeIORef)


-- Comunicarea asincrona

getURL :: String -> IO ByteString
getURL url = do
  Network.Browser.browse $ do
    setCheckForProxy True
    setDebugLog Nothing
    setOutHandler (const (return ()))
    (_, rsp) <- request (getRequest' (escapeURIString isUnescapedInURI url))
    return (rspBody rsp)
  where
   getRequest' :: String -> Request ByteString
   getRequest' urlString =
    case parseURI urlString of
      Nothing -> error ("getRequest: Not a valid URL - " ++ urlString)
      Just u  -> mkRequest GET u

data Async a = Async (MVar a)

async action = do
    var <- newEmptyMVar
    forkIO $ do
        r <- action
        putMVar var r
    return $ Async var

wait (Async var) = readMVar var

expAsync = do
    a1 <- async (getURL "http://www.example.com/")
    a2 <- async (getURL "http://www.example.org/")
    r1 <- wait a1
    r2 <- wait a2
    print (B.length r1, B.length r2)

timeDownload :: String -> IO ()
timeDownload url = do
    (time, page) <- timeItT $ getURL url
    printf "downloaded: %s (%d bytes, %.5fs)\n" url (B.length page) time

expCrawler = do
    a1 <- async (timeDownload "http://www.example.com/")
    a2 <- async (timeDownload "http://www.example.org/")
    wait a1
    wait a2

sites = ["http://www.example.com/", "http://www.example.org/"]
expSiteList = do
    as <- mapM (async . timeDownload) sites
    mapM_ wait as

-- ! asteapta ca toate actiunile asincorne sa se termine, 
-- ! monitorizand fiecare actiune in parte; un alt thread ar putea
-- ! interveni inainte ca toate actiunile sa se termine
---------------------------------------------------------------------
-- Exemplu: tranzactie bancara
badDeposit acc amount = do
    x <- takeMVar acc
    putMVar acc (x + amount)

badWithdraw acc amount = do
    x <- takeMVar acc
    putMVar acc (x - amount)

badShowBalance acc str = do -- sold
    x <- takeMVar acc
    putMVar acc x
    putStrLn $ "Contul " ++ str ++ ": " ++ show x

badTransfer from to amount = do
    badWithdraw from amount
    threadDelay $ 5^6
    badDeposit to amount

type BadAccount = MVar Int

expTransfer = do
    aMVar <- newMVar 1000
    bMVar <- newMVar 1000
    forkIO $ badTransfer aMVar bMVar 300
    forkIO $ badTransfer bMVar aMVar 500

    badShowBalance aMVar "a"
    badShowBalance bMVar "b"

----------------------------------------------------------------------
-- Variabile atomice

add m = replicateM_ 1000 $ atomicModifyIORef' m (\x -> (x + 1, ()))

expVarAtom = do
    m <- newIORef 0
    a1 <- async $ add m
    a2 <- async $ add m
    r1 <- wait a1
    r2 <- wait a2
    x <- readIORef m
    print x
----------------------------------------------------------------------
-- Doua thread-uri care incrementeaza acelasi contor
expContor = do
    st <- newIORef ""
    a1 <- async $ replicateM 5 $ atomicModifyIORef' st (\s -> (s ++ "A", ()))
    a2 <- async $ replicateM 5 $ atomicModifyIORef' st (\s -> (s ++ "B", ()))
    a3 <- async $ replicateM 5 $ atomicModifyIORef' st (\s -> (s ++ "C", ()))
    r1 <- wait a1
    r2 <- wait a2
    r3 <- wait a3
    x <- readIORef st
    print x

-----------------------------------------------------------------------
-- MVar
act m x = do
    t <- getStdRandom (randomR (100, 1000))
    threadDelay t
    s <- takeMVar m
    putMVar m (s ++ x)

expMVar = do
    st <- newMVar ""
    a1 <- async $ replicateM 5 $ act st "A"
    a2 <- async $ replicateM 5 $ act st "B"
    a3 <- async $ replicateM 5 $ act st "C"
    r1 <- wait a1
    r2 <- wait a2
    r3 <- wait a3
    x <- readMVar st
    print x

-----------------------------------------------------------------------
-- Variabile mutabile
add' rref n = do
    val <- readIORef rref
    writeIORef rref (val + n)

expMut = do
    rref  <- newIORef 0
    add' rref 10
    val <- readIORef rref
    print val

-----------------------------------------------------------------------
type Account = TVar Int

deposit :: Account -> Int -> STM ()
deposit acc amount = do
    x <- readTVar acc
    writeTVar acc (x + amount)

withdraw :: Account -> Int -> STM ()
withdraw acc amount = do
    x <- readTVar acc
    writeTVar acc (x - amount)

transfer :: Account -> Account -> Int -> IO ()
transfer from to amount = atomically $ do
    withdraw from amount
    deposit to amount

showBalance :: Account -> String -> IO ()
showBalance acc str = do -- sold
    x <- atomically $ readTVar acc
    putStrLn $ "Contul " ++ str ++ ": " ++ show x

------------------------------------------------------------------------
expTransf = do
    (a, b) <- atomically $ do
        a <- newTVar 1000
        b <- newTVar 1000
        return (a,b)
    a1 <- async $ transfer a b 300
    a2 <- async $ transfer b a 500
    wait a1
    wait a2
    showBalance a "a"
    showBalance b "b"

------------------------------------------------------------------------
-- Blocare

myCheck True = return ()
myCheck False = retry

limitedWithdraw acc amount = do
    bal <- readTVar acc
    myCheck $ amount <= 0 || amount <= bal
    writeTVar acc (bal - amount)

------------------------------------------------------------------------
-- Alegerea
limitedWithdraw2 acc1 acc2 amt =
    orElse (limitedWithdraw acc1 amt) (limitedWithdraw acc2 amt)

-- Exercitiu: Modificati cerintele cu banca folosind retry si orElse

-------------------------------------------------------------------------
-- The Dining Philosophers

type Fork = TVar Bool -- True daca furculita este libera

takeFork s = do
    b <- readTVar s
    if b
        then writeTVar s False
        else retry -- asteapta pana se elibereaza furculita

releaseFork fork = writeTVar fork True

type Name = String

runPhilosopher (name, (left, right)) = forever $ do
    putStrLn $ name ++ " is hungry."
    atomically $ do
        takeFork left
        takeFork right
    putStrLn $ name ++ " got two forks and is now eating."
    delay <- randomRIO (1, 10)
    threadDelay $ delay * (10^6)
    putStrLn $ name ++ " is done eating. Going back to thinking."
    atomically $ do
        releaseFork left
        releaseFork right
    delay <- randomRIO (1, 10)
    threadDelay $ delay * (10^6)

philosophers = ["Aristotle", "Kant", "Spinoza", "Marx", "Russel"]

-- TODO: prob e nevoie de un takeprint
expPhil = do
    forks <- atomically $ do
        sticks <- mapM (const (newTVar True)) [1..5]
        return sticks

    let forkPairs = Prelude.zip forks $ Prelude.tail forks ++ [Prelude.head forks]
        philosophersWithForks = Prelude.zip philosophers forkPairs

    putStrLn "Running the philosophers. Press enter to quit."

    mapM_ (forkIO . runPhilosopher) philosophersWithForks

    Prelude.getLine

--------------------------------------------------------------------------------------
data MyTMVar a = MyTMVar (TVar (Maybe a))
-- Nothing indica faptul ca variabila e goala

myNewEmptyTMVar = do
    t <- newTVar Nothing
    return $ MyTMVar t

myTakeTMVar (MyTMVar t) = do
    m <- readTVar t
    case m of
        Nothing -> retry -- blocare
        Just a -> do
            writeTVar t Nothing
            return a

myPutTMVar (MyTMVar t) a = do
    m <- readTVar t
    case m of
        Just _ -> retry -- blocare
        Nothing -> do
            writeTVar t (Just a)
            return ()

myTakeBothMVar tv tw = atomically $ do
    v <- myTakeTMVar tv
    w <- myTakeTMVar tw
    return (v, w)

-----------------------------------------------------------------------
-- TODO: probleme aici
type Fork2 = TMVar Int

newFork2 :: Int -> STM Fork2
newFork2 i = newTMVar i

takeFork2 :: Fork2 -> STM Int
takeFork2 fork = takeTMVar fork

releaseFork2 :: Int -> Fork2 -> STM ()
releaseFork2 i fork = putTMVar fork i

type Name2 = String

runPhilosopher2 :: (Name2, (Fork2, Fork2)) -> IO ()
runPhilosopher2 (name, (left, right)) = forever $ do
    putStrLn (name ++ " is hungry.")
    (leftv, rightv) <- atomically $ do
        leftv <- takeFork2 left
        rightv <-takeFork2 right
        return (leftv,rightv)
    putStrLn (name ++ " got forks"++ (show leftv)++","++
        (show rightv)++ " and is now eating.")
    delay <- randomRIO (1,10)
    threadDelay (delay * 1000000)
    putStrLn (name ++ " is done eating. Going back to thinking.")
    atomically $ do
        releaseFork2 leftv left
        releaseFork2 rightv right
    delay <- randomRIO (1, 10)
    threadDelay (delay * 1000000)
-----------------------------------------------------------------------
data STMAsync a = STMAsync (TMVar a)

stmasync action = do
    var <- atomically $ do
        var <- newEmptyTMVar
        return var
    forkIO $ do
        r <- action
        (atomically . putTMVar var) r

    return $ STMAsync var

waitSTM (STMAsync var) = readTMVar var

waitAll asyncs = atomically $ mapM_ waitSTM asyncs

runPhilosopher3 n (name, (left, right)) = if n == 0
    then return ()
    else do
        putStrLn (name ++ " is hungry.")
        atomically $ do
            takeFork left
            takeFork right
        putStrLn (name ++ " got two forks and is now eating.")
        delay <- randomRIO (1,10)
        threadDelay (delay * 1000000)
        if n > 1
            then putStrLn (name ++ " is done eating. Going back to thinking.")
            else putStrLn (name ++ " is leaving.")
        atomically $ do
            releaseFork left
            releaseFork right
        delay <- randomRIO (1, 10)
        threadDelay (delay * 1000000)
        runPhilosopher3 (n - 1) (name, (left, right))

--------------------------------------------------------------------------------
waitEither x y = atomically $ 
    fmap Left (waitSTM x) 
        `orElse` 
    fmap Right (waitSTM y)

waitAny asyncs = atomically $
    Prelude.foldr orElse retry $ Prelude.map waitSTM asyncs








