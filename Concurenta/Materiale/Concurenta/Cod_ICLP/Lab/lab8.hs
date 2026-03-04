import Control.Concurrent
import Control.Concurrent.STM hiding (takeTMVar, putTMVar, newEmptyTMVar, TMVar)
import Control.Monad

{-
    STM = software transactional memory

    Lucram tranzactional 
    Def: tranzactie - reprez un set de operatii pe care le executam
    ca un tot unitar si care respecta 4 principii
    A - Atomicitate
    C - Consistenta
    I - Izolare
    D - Durabilitate (rezultatele tranzactiei sunt permanente - persista,
    sunt duarbile si alte sinonime)

    Pentru implementare:
    - prin variab atomice (IORef a) - sunt impl folosind instr hardware compare-and-swap
    - sau prin STM - sincronizare fara lock-uri, blocuri de instructiuni
        executate atomic

    Vom lucra in monada STM - asemanatoare monadei IO
    - nu mai avem MVar si TVar
    - in loc de takeMVar avem readTVar
    - in loc de putMVar avem writeTVar
    - atomically :: STM a -> IO a
    - retry :: STM a -- daca folosim retry atunci  tranzactia curenta este
    abandonata si va fi reincercata ulterior 
-}

type Account = TVar Int

deposit :: Account -> Int -> STM ()
deposit acc amount = do 
    currentAmount <- readTVar acc
    writeTVar acc (currentAmount + amount)

withdraw :: Account -> Int -> STM ()
withdraw acc amount = do
    currentAmount <- readTVar acc
    writeTVar acc (currentAmount - amount)

showBalance :: Account -> String -> IO ()
showBalance acc accountName = do
    currentAmount <- atomically $ readTVar acc
    putStrLn $ "Account " ++ accountName ++ ": " ++ show currentAmount

transfer :: Account -> Account -> Int -> IO ()
transfer from to amount = atomically $ do
    withdraw from amount
    -- un moment de inconsistenta
    deposit to amount

expBanca = do
    (a, b) <- atomically $ do
        a <- newTVar 1000
        b <- newTVar 1000
        return (a, b)
    forkIO $ transfer a b 300
    threadDelay $ 10^6
    showBalance a "a"
    showBalance b "b"
----------------------------------------------------------------------
-- TMVar
data TMVar a = TMVar (TVar (Maybe a))
-- Nothing care specifica faptul ca variabila e empty
-- pentru a avea apelul blocant folosim retry

newEmptyTMVar :: STM (TMVar a)
newEmptyTMVar = do
    t <- newTVar Nothing
    return $ TMVar t

-- return (TMVar (newTVar Nothing))
-- TMVar (TVar (Maybe a))

takeTMVar :: TMVar a -> STM a
takeTMVar (TMVar t) = do
    m <- readTVar t
    case m of
        Nothing -> retry
        Just a -> do
            writeTVar t Nothing
            return a

putTMVar :: TMVar a -> a -> STM ()
putTMVar (TMVar t) x = do
    m <- readTVar t
    case m of
        Just _ -> retry
        Nothing -> do
            writeTVar t (Just x)
            return ()

-- l-am facut spat trecuta data Async a = Async (MVar a)
data Async a = Async (TMVar a)

async :: IO a -> IO (Async a)
async action = do
    var <- atomically $ do
        var <- newEmptyTMVar
        return var
    forkIO $ do
        r <- action
        (atomically . putTMVar var) r
    return $ Async var

wait :: Async a -> STM a
wait (Async var) = takeTMVar var

fib 0 = 1
fib 1 = 1
fib n = fib (n - 1) + fib (n - 2) 

expAsync = do
    var <- atomically $ do
        var <- newEmptyTMVar
        return var
    a1 <- async $ return $ fib 15
    a2 <- async $ return $ fib 17
    r1 <- atomically $ wait a1
    r2 <- atomically $ wait a2
    print (r1, r2)
----------------------------------------------------------------------
{-
    Problema filosofilor 
 
    Fiecare filosof executa la infinit urmatorul ciclu: 
    - asteapta sa manance 
    - ia furculita din stanga 
    - o ia si pe cea din dreapta 
    - mananca 
    - elibereaza furculita din stanga 
    - o elibereaza si pe ce din dreapta 
    - filosofeaza 
 
    Probleme:
    - excludere mutuala: doi filosofi diferiti nu pot folosi aceeasi furculita simultan
    - coada circulara: filosofii se asteapta unul pe celalalt 
 
    Deadlock: fiecare filosof are o furculita si asteapta ca ceilalti vecini sa mai elibereze una 
    Starvation: un filosof nu mananca niciodata 
 
    Solutie: 
    - daca luarea/eliberarea furculitelor sunt operatii atomice, atunci eliminam deadlock-ul 
    - daca actiunea de a manca are si durata finita, eliminam starvation-ul 
-}
 
type Fork = TVar Bool -- True daca furculita este libera 
type Name = String -- pentru numele filosofului 
 
takeFork :: Fork -> STM () 
takeFork fork = do 
    b <- readTVar fork  
    if b then writeTVar fork False else retry 
 
releaseFork :: Fork -> STM ()
releaseFork fork = writeTVar fork True  
 
runPhilosopher :: (Name, (Fork, Fork)) -> IO () 
runPhilosopher (name, (left, right)) = forever $ do 
    putStrLn $ name ++ " e flamand"
    atomically $ do 
        takeFork left 
        takeFork right 
    putStrLn $ name ++ " poate manca"
    threadDelay 2000000 
    putStrLn $ name ++ " a terminat de mancat si acum poate filosofa linistit"
    atomically $ do 
        releaseFork left 
        releaseFork right 
    threadDelay 3000000 
 
philosophers :: [Name]
philosophers = ["Kant", "Chomsky", "Descartes", "Socrate", "Kripke"]
 
main = do 
    forks <- atomically $ do 
        localForks <- mapM (const $ newTVar True) [1..length philosophers]
        return localForks 
    let forkPairs = zip forks ((tail forks) ++ [head forks])
    let philosophersWithForks = zip philosophers forkPairs 
 
    mapM_ (forkIO . runPhilosopher) philosophersWithForks
 
    getLine 

-- TODO: de facut sincronizarea la print-uri

takePrint :: MVar () -> String -> IO ()
takePrint m str = do
    takeMVar m
    putStrLn str
    putMVar m ()


