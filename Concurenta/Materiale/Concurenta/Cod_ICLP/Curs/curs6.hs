import Control.Concurrent.QSem -- implementare de quantity semaphore
import Control.Concurrent hiding (dupChan, readChan, writeChan, newChan)
import Control.Concurrent.Chan hiding (dupChan, readChan, writeChan, newChan)
import Data.Char
import Control.Monad
import Network.HTTP
import Network.Browser
import Network.URI
import Data.ByteString (ByteString)
import qualified Data.ByteString as B
import System.TimeIt --parconc-examples
import Text.Printf --parconc-examples

worker q stdo w = do
    waitQSem q
    putMVar stdo $ "Worker " ++ show w ++ " acquired the lock."
    threadDelay 2000000 -- microseconds
    signalQSem q
    putMVar stdo $ "Worker " ++ show w ++ " released the lock."

takeprint :: Show a => MVar a -> IO ()
takeprint stdo = do
    s <- takeMVar stdo
    print s

expSem = do
        q <- newQSem 3
        stdo <- newEmptyMVar
        let workers = 5
            prints = 2 * workers
        mapM_ (forkIO . worker q stdo) [1..workers]
        replicateM_ prints $ takeprint stdo

----------------------------------------------------------------       

type MyQSem  = MVar (Int, [MVar ()])

myNewQSem :: Int -> IO MyQSem
myNewQSem n = newMVar (n, [])
    -- qsem <- newQSem 3

myWaitQSem :: MyQSem -> IO() -- ocupa
myWaitQSem qsem = do
    (avail, blks) <- takeMVar qsem
    if avail > 0
        then putMVar qsem (avail - 1, [])
        else do
            blk <- newEmptyMVar
            putMVar qsem (0, blks ++ [blk])
            takeMVar blk -- thread-ul e blocat pe variabila proprie

mySignalQSem :: MyQSem -> IO() -- elibereaza
mySignalQSem qsem = do
    (avail, blks) <- takeMVar qsem
    case blks of
        [] -> putMVar qsem (avail + 1, [])
        (blk : blks') -> do
            putMVar qsem (0, blks')
            putMVar blk ()

------------------------------------------------------------
data MyRWLock = MyRWL { readL :: MVar Int, writeL :: MVar () }

type MyLock = MVar ()
newLock = newMVar ()
aquireLock = takeMVar
releaseLock m = putMVar m ()

newMyRWLock :: IO MyRWLock
newMyRWLock = do
    readL <- newMVar 0
    MyRWL readL <$> newLock

aquireWrite (MyRWL readL writeL) = aquireLock writeL
releaseWrite (MyRWL readL writeL) = releaseLock writeL

aquireRead (MyRWL readL writeL) = do
    n <- takeMVar readL -- n cititori
    if n == 0 then do
        aquireLock writeL
        putMVar readL 1
    else putMVar readL $ n + 1

releaseRead (MyRWL readL writeL) = do
    n <- takeMVar readL
    if n == 1 then do
        releaseLock writeL
        putMVar readL 0
    else putMVar readL $ n - 1

reader i rwl lib = do -- un thread cititor
    aquireRead rwl
    c <- readMVar lib -- non blocking 
    putStrLn $ "Reader " ++ show i ++ " reads: " ++ show c
    releaseRead rwl

writer i rwl lib = do -- un thread scriitor
    aquireWrite rwl
    putStrLn $ "Writer " ++ show i ++ " writes " ++ show i
    c <- takeMVar lib
    putMVar lib i
    releaseWrite rwl

genread n rwl lib =
    if n == 0
        then putStrLn "no more readers"
        else do
            reader n rwl lib
            threadDelay 20
            genread (n - 1) rwl lib

genwrite n rwl lib =
    if n == 0
        then putStrLn "no more writers"
        else do
            writer n rwl lib
            threadDelay 100
            genwrite (n - 1) rwl lib

expReadWrite = do
    lib <- newMVar 0 -- resursa
    rwl <- newMyRWLock -- lacatul rw
    forkIO $ genread 10 rwl lib -- creez 10 thread-uri cititor
    forkIO $ genwrite 5 rwl lib -- creez 5 thread-uri scriitor
    getLine

-- exercitii posibile: capacitate pe cititori, 
--      sa se mai bage un tip de thread-uri (poate reviewers)
-----------------------------------------------------------------------
-- canale de comunicare
-- todo
move c1 c2 = do
    v1 <- readChan c1
    let ls = words v1
    writeList2Chan c2 ls

upout c = do
    str <- readChan c
    putStrLn (map toUpper str)

load c = do
    str <- getLine
    if str == "exit"
        then return ()
        else do
            writeChan c str
            load c
-----------------------------------------------------------------------
--  Canale de comunicare formate din variabile MVar
type Stream a = MVar (Item a)
data Item a = Item a (Stream a)

data Chan a = Chan (MVar (Stream a)) (MVar (Stream a))

newChan = do
    emptyStream <- newEmptyMVar
    readVar <- newMVar emptyStream
    writeVar <- newMVar emptyStream
    return $
        Chan
            readVar -- contine item-ul care va fi citit
            writeVar -- contine variabila in care se va scrie noul item

readChan (Chan rV wV) = do
    stream <- takeMVar rV
    Item val str <- readMVar stream
    putMVar rV str
    return val

writeChan (Chan rV wV) val = do
    newStream <- newEmptyMVar
    writeEnd <- takeMVar wV
    putMVar writeEnd (Item val newStream)
    putMVar wV newStream
----------------------------------------------------------------------
-- Exercitiu: implementarea canalelor multicast

dupChan (Chan _ wV) = do
    writeEnd <- readMVar wV
    newReadVar <- newMVar writeEnd
    return $ Chan newReadVar wV

expDupChan = do
    c <- newChan
    writeChan c 'a'
    readChan c >>= print
    dc <- dupChan c -- creare canal duplicat
    writeChan c 'b'
    readChan c >>= print
    readChan dc >>= print
--------------------------------------------------------------------------
-- comunicare sincrona
readerSync lineVar countVar = do -- main thread
    ls <- fmap lines (readFile "input.txt")
    mapM (putMVar lineVar . Just) ls
    putMVar lineVar Nothing
    n <- takeMVar countVar
    print n

writerSync lineVar countVar = loop 0
    where
        loop n = do 
            l <- takeMVar lineVar
            case l of 
                Just x -> do
                    putStrLn x
                    loop (n + 1)
                Nothing -> putMVar countVar n

expComSync = do
    lineVar <- newEmptyMVar
    countVar <- newEmptyMVar
    forkIO $ writerSync lineVar countVar
    readerSync lineVar countVar
--------------------------------------------------------------------------

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

action x = do
    r <- getURL x 
    print(B.length r)

readerUrl lineVar countVar = do
    ls <- fmap lines (readFile "inputurl.txt")
    mapM (putMVar lineVar . Just) ls
    putMVar lineVar Nothing
    n <- takeMVar countVar
    print n

writerUrl lineVar countVar = loop 0
    where
        loop n = do
            l <- takeMVar lineVar
            case l of 
                Just x -> do
                    action x
                    loop (n + 1)
                Nothing -> putMVar countVar n
-----------------------------------------------------------------------
-- Exemplu: incarcarea mai multor pagini web
expWeb = do
    m1 <- newEmptyMVar
    forkIO $ do
        r <- getURL "http://www.example.com/"
        putMVar m1 r

    m2 <- newEmptyMVar
    forkIO $ do
        r <- getURL "http://www.example.org/"
        putMVar m2 r

    r1 <- takeMVar m1
    r2 <- takeMVar m2

    print(B.length r1, B.length r2)
------------------------------------------------------------------------
-- Comunicare asincrona

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
    print(B.length r1, B.length r2) 
----------------------------------------------------------------------
timeDownload :: String -> IO ()
timeDownload url = do 
    (time, page) <- timeItT $ getURL url
    printf "downloaded: %s (%d bytes, %.5fs)\n" url (B.length page) time

expCrawler = do 
    a1 <- async (timeDownload "http://www.example.com/") 
    a2 <- async (timeDownload "http://www.example.org/") 
    wait a1 
    wait a2 
