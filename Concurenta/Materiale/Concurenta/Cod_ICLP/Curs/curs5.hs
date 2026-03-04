import Data.IORef -- variabile mutabile in monada IO
import Control.Monad
import Control.Concurrent
import Data.Char (toUpper)

pg = do
    putStrLn "Numele"
    s <- getLine
    putStrLn ("Hello " ++ s)

pg' = do
    putStrLn "introdu sirul"
    s <- getLine
    let n = length s
    putStrLn (s ++ " are " ++ show n ++ " litere")

--------------------------------------------------------
add :: IORef Int -> Int -> IO ()
add rref n = do
    val <- readIORef rref
    writeIORef rref (val + n)

expIORef = do
    rref <- newIORef 0
    add rref 10
    val <- readIORef rref
    print val

----------------------------------------------------------------
expThread = do
    forkIO (replicateM_ 100 (putChar 'A')) -- child thread
    replicateM_ 100 (putChar 'B') -- main thread
    putChar '\n' -- OOPS

----------------------------------------------------------------
-- OPA
expThreadId = do
    forkIO $ replicateM_ 100 (myThreadId >>= print) -- child thread
    replicateM_ 100 $ myThreadId >>= print -- main thread

-----------------------------------------------------------------
myread1 = do
    putStrLn "thread1"
    s <- getLine
    putStrLn $ "citit1: " ++ s

myread2 = do
    putStrLn "thread2"
    s <- getLine
    putStrLn $ "citit2: " ++ s

expInterleaving = do
    forkIO (replicateM_ 10 myread1)
    replicateM_ 10 myread2

------------------------------------------------------------------
-- executie secv vs executie concurenta
fib 0 = 1
fib 1 = 2
fib n = fib (n - 1) + fib (n - 2)

act n = do
    let x = fib n
    putStrLn ("Fib " ++ show n ++ " is " ++ show x)

act4 = do
    act 10
    act 20
    act 30
    act 35
    getLine

actFork = do
    forkIO $ act 10
    forkIO $ act 20
    forkIO $ act 30
    forkIO $ act 35
    getLine
-----------------------------------------------------------------
-- comunicarea thread-urilor
myReadMVar m = do -- implementare intuitiva, nu asigura atomiciate
    a <- takeMVar m
    putMVar m a
    return a

expComunicare = do
    m <- newEmptyMVar
    forkIO $ do
        putMVar m 'x'
        putMVar m 'y'
    x <- takeMVar m
    print x
    x <- takeMVar m
    print x

--------------------------------------------------------------------
-- thread blocked indefinitely
main'''' = do
    m <- newEmptyMVar
    takeMVar m

--------------------------------------------------------------------
{-
    sincornizare: 2 thread-uri incrementeaza acelasi contor;
        vrem sa citim valoarea dupa ce ambele thread-uri au termiat
-}

addCounter m ms1 = do
    replicateM_ 1000 $ do
        x <- takeMVar m
        threadDelay 100 -- nu afecteaza sincronizarea
        putMVar m (x + 1)
    putMVar ms1 "ok" -- ne asiguram ca ambele thread-uri au terminat

expSync = do
    m <- newMVar 0
    -- ms1 si ms2 actioneaza ca niste semafoare
    -- astfel ne asiguram ca ambele thread-uri au terminat
    ms1 <- newEmptyMVar
    ms2 <- newEmptyMVar

    -- sincronizarea este asigurata de faptul ca ambele
    -- thread-uri apeleaza intai takeMVar
    forkIO (addCounter m ms1)
    forkIO (addCounter m ms2)

    takeMVar ms1
    takeMVar ms2

    x <- takeMVar m
    print x

--------------------------------------------------------------------
-- MVar ca semafor binar

newLock = newMVar () -- MVar care contine ()
aquireLock = takeMVar
releaseLock m = putMVar m ()

act1 m = do
    aquireLock m
    print "I have the lock"
    releaseLock m

act2 m = do
    aquireLock m
    print "Now I have the lock"
    releaseLock m

expMutex = do
    m <- newLock
    -- forever repeta o actiune monadica de un nr infinit de ori
    forkIO $ forever (act1 m)
    forkIO $ forever (act2 m)
    getLine

-- Obs: scrierea este sincronizata de m
-------------------------------------------------------------------
-- sincronizarea accesului la stdout
-- accesul la stdout nu este thread-safe, deci trb sincronizat

-- threadSafeWrite
tsWrite stdo mes = do
    aquireLock stdo
    putStrLn mes
    releaseLock stdo

act' n stdo = do
    let x = fib n
    tsWrite stdo ("Fib " ++ show n ++ " is " ++ show x)

expSyncStdo = do
    stdo <- newLock
    forkIO $ act' 10 stdo
    forkIO $ act' 20 stdo
    forkIO $ act' 30 stdo
    forkIO $ act' 35 stdo
    getLine

--------------------------------------------------------------------
-- modelul producer-consumer cu MVar ca monitor

producer m = forever $ do
    mes <- getLine
    putMVar m mes

consumer m n l =
    if n == 0
        then aquireLock l
        else do
            mes <- takeMVar m
            putStrLn (">" ++ mes)
            consumer m (n - 1) l

expProdCons = do
    m <- newEmptyMVar -- buffer

    l <- newLock
    forkIO (producer m)
    forkIO (consumer m 10 l)
    {-
    Thread-ul consumator se executa pe un thread nou.
    In acest caz, in thread-ul principal trb sa ne asiguram
    ca thread-ul consumator si-a terminat executia (folosind "lacatul" l)
    -}
    releaseLock l

    putStrLn "main thread ends"
---------------------------------------------------------------------
-- prod-cons: 
-- serviciu de logare (modelarea unui canal de comunicare simplu
-- folosind MVar)
{-
Cerinte:
- serviciul de logare prelucreaza mesajele intr-un thread separat
- mesajele trebuie prelucrate in ordinea in care sunt logate
- cand prog se termina, toate mesajele logate trebuie sa fie prelucrate
-}
data Logger = Logger (MVar String)

logger :: Logger -> IO () -- prelucreaza mesajele din logger
logger (Logger m) = loop
    where
        loop = do
            msg <- takeMVar m
            putStrLn (map toUpper msg)
            loop

initLogger :: IO Logger
initLogger = do
    m <- newEmptyMVar
    let log = Logger m
    forkIO (logger log)
    return log

logMessage :: Logger -> String -> IO ()
logMessage (Logger m) s = putMVar m s

logMessThread :: Logger -> IO ()
logMessThread log = do
    msg <- getLine
    if msg == "bye"
        then return ()
        else do
            logMessage log msg
            logMessThread log

expServLogare = do
    log <- initLogger
    logMessThread log

-- Problema: programul nu se asigura ca toate mesajele
-- logate sunt prelucrate
------------------------------------------------------------------
-- Serviciu de logare 2
data LogCommand = Message String | Stop (MVar ())
data Logger2 = Logger2 (MVar LogCommand)

logger2 :: Logger2 -> IO () -- prelucreaza mesajele din logger
logger2 (Logger2 m) = loop
    where
        loop = do
            cmd <- takeMVar m
            case cmd of
                Message msg -> do
                    putStrLn ("mesaj: " ++ msg)
                    loop
                Stop s -> do
                    putStrLn "logger: stop"
                    putMVar s ()
                -- thread-ul logger va debloca s cand
                -- ajunge la stop

initLogger2 :: IO Logger2
initLogger2 = do
    m <- newEmptyMVar
    let log = Logger2 m
    forkIO (logger2 log)
    return log

logMessage2 :: Logger2 -> String -> IO ()
logMessage2 (Logger2 m) s = putMVar m (Message s)

logStop :: Logger2 -> IO ()
logStop (Logger2 m) = do
    s <- newEmptyMVar
    putMVar m (Stop s)
    takeMVar s

logMessThread2 :: Logger2 -> IO ()
logMessThread2 log = do
    msg <- getLine

    if msg == "bye"
        then logStop log
        else do
            logMessage2 log msg
            logMessThread2 log

expServLogare2 = do
    log <- initLogger2
    logMessThread2 log



