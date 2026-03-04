import Control.Concurrent
import Control.Monad
import Data.Char 
import Data.ByteString as B
import System.TimeIt
import Text.Printf
{-
Problema Producer Consumer
MVar ca monitor
producer-ul va citi incontinuu mesaje de la stdin si le va pune
intr-o locatie partajata de memorie un nr finit de consumeri vor afisa
mesajele respective la stdout
-}

producer :: MVar String -> IO ()
producer m = forever $ do
    msg <- Prelude.getLine
    putMVar m msg

consumer m n = if n == 0
    then return ()
    else do
        msg <- takeMVar m
        putStrLn $ "Msg: " ++ msg
        consumer m (n - 1)

expProdCons = do
    m <- newEmptyMVar
    forkIO $ producer m
    consumer m 5

------------------------------------------------------------------ 
{-
    Reader-Writer 
    - mai multe threaduri au acces la o resursa 
    - unele threaduri scriu (Writer), altele citesc (Reader)
    - resursa poate fi accesata simultan de mai multi cititori 
    - resursa poate fi accesata doar de un singur scriitor 
    - nu poate fi accesata simultan si de cititori, si de scriitori 
 
    Folosim 
    - un semafor binar care da acces la citit sau la scris, writeL 
    - un monitor pentru sincronizarea cititorilor, readL 
-}

type MyLock = MVar ()
newLock = newMVar ()
acquireLock m = takeMVar m
releaseLock m = putMVar m ()

data MyRWLock = MyRWL { readL :: MVar Int, writeL :: MyLock }

newMyRWLock :: IO MyRWLock
newMyRWLock = do
    readL <- newMVar 0
    writeL <- newLock
    return $ MyRWL readL writeL

-- acquireWrite, releaseWrite 
-- acquireReader, releaseReader 

acquireWrite :: MyRWLock -> IO ()
acquireWrite (MyRWL readL writeL) = acquireLock writeL

releaseWrite :: MyRWLock -> IO ()
releaseWrite (MyRWL readL writeL) = releaseLock writeL

acquireRead :: MyRWLock -> IO ()
acquireRead (MyRWL readL writeL) = do
    n <- takeMVar readL
    if n == 0 then do
        acquireLock writeL
        putMVar readL 1
    else
        putMVar readL (n + 1)

releaseRead :: MyRWLock -> IO ()
releaseRead (MyRWL readL writeL) = do
    n <- takeMVar readL
    if n == 1 then do
        releaseLock writeL
        putMVar readL 0
    else
        putMVar readL (n - 1)

-- finalizati problema scriind rolurile pt reader, writer, si un scenariu cu mai multi din fiecare rol 

takeprint :: MVar String -> IO ()
takeprint stdo = do
    s <- takeMVar stdo
    print s

reader :: (Show a1, Show a2) => MVar String -> MyRWLock -> MVar a2 -> a1 -> IO ()
reader stdo rwl buf i = do
    acquireRead rwl
    threadDelay 1000000
    c <- readMVar buf
    putMVar stdo $ "Readerul " ++ show i ++ " citeste: " ++ show c
    releaseRead rwl

writer :: Show a => MVar String -> MyRWLock -> MVar a -> a -> IO ()
writer stdo rwl buf i = do
    acquireWrite rwl
    threadDelay 2000000
    putMVar stdo $ "Writerul " ++ show i ++ " scrie " ++ show i
    c <- takeMVar buf
    putMVar buf i
    releaseWrite rwl
    threadDelay 2000000

main = do
    buf <- newMVar 0
    rwl <- newMyRWLock
    stdo <- newEmptyMVar

    forkIO $ writer stdo rwl buf 1
    forkIO $ reader stdo rwl buf 1
    forkIO $ reader stdo rwl buf 2
    forkIO $ writer stdo rwl buf 2
    forkIO $ reader stdo rwl buf 3
    forkIO $ reader stdo rwl buf 4

    forkIO $ forever $ takeprint stdo

    Prelude.getLine

------------------------------------------------------------------
{-
    Canalele de comunincare - sunt folosite pentru comunicare intre
    thread-uri. Ele sunt implementate tot prin MVar

    data Chan a
    newChan :: IO (Chan a)
    writeChan :: Chan a -> a -> IO () -- nu se blocheaza niciodata
    readChan :: Chan a -> IO a -- este apel blocant doar daca avem canalul vid

    Problema: avem doua canale, wordsIn si wordsOut
    thread-ul principal citeste siruri de caractere 
-}
load wordsIn = forever $ do
    str <- Prelude.getLine
    if str == "exit" then return ()
    else do
        writeChan wordsIn str

move wordsIn wordsOut = do
    str <- readChan wordsIn
    let ls = words str
    mapM_ (writeChan wordsOut) ls

writeStdOut wordsOut = do
    str <- readChan wordsOut
    putStrLn $ Prelude.map toUpper str

expChan = do
    wordsIn <- newChan
    wordsOut <- newChan

    forkIO $ forever $ move wordsIn wordsOut
    forkIO $ forever $ writeStdOut wordsOut

    load wordsIn

--------------------------------------------------------------------
{-
    Comunicarea asincrona 
    - se creeaza un thread pentru fiecare actiune si apoi se asteapta rezultatul actiunii respective 
-}

data Async a = Async (MVar a) 

async :: IO a -> IO (Async a)
async action = do 
    var <- newEmptyMVar 
    forkIO $ do 
        r <- action 
        putMVar var r 
    return (Async var) 

await :: Async a -> IO a
await (Async var) = readMVar var 

fibo :: Int -> Int 
fibo 0 = 1 
fibo 1 = 1 
fibo n = fibo (n - 1) + fibo (n - 2)

expAsync = do 
    a1 <- async $ return $ fibo 35
    a2 <- async $ return $ fibo 36 

    r1 <- await a1 
    r2 <- await a2 

    print (r1, r2)

-- implementati Crawler-ul de la curs cu Async-Await
-- tinyurl.com/curs25261 -> ICLP -> Haskell sapt 6
-- am implementat la curs