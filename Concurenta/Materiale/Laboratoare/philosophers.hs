import Control.Concurrent 
import Control.Concurrent.STM 
import Control.Monad

{-
    Problema filosofilor

    Fiecare filosof executa la infinit urmatorul ciclu:
    - asteapta sa manance
    - ia furculita din stanga
    - ia furculita din dreapta
    - mananca
    - elibereaza furculita din stanga
    - elibereaza furculita din dreapta
    - filosofeaza

    Probl:
    - excludere mutuala: doi filosofi nu pot folosi aceasi furculita simultan
    - coada circulara: filosofii se asteapta unul pe celalalt

    -> deadlock: fiecare filosof are o furculita si asteapta ca ceilalti vecini sa elibereze una
    -> starvation: un filosof nu mananca niciodata

    Solutie:
    - daca luarea/eliberarea furculitelor sunt operatii atomice -> eliminam deadlock ul
    - daca actiunea de a manca are si durata finita, eliminam starvation
-}

type Fork = TVar Bool -- true daca furculita e libera
type Name = String -- pt numele filosofului

takeFork :: Fork -> STM ()
takeFork fork = do
    b <- readTVar fork
    if b then writeTVar fork False else retry

releaseFork fork = writeTVar fork True

takeprint m str = do 
    takeMVar m 
    putStrLn str 
    putMVar m () 

runPhilosopher stdo (name, (left, right)) = forever $ do
    takeprint stdo $ name ++ " e flamand"
    atomically $ do
        takeFork left
        takeFork right
    takeprint stdo $ name ++ " poate manca"
    threadDelay 20000000
    takeprint stdo $ name ++ " a terminat de mancat si acum filosofeste"
    atomically $ do
        releaseFork left
        releaseFork right

    threadDelay 100000000

philosophers :: [Name]
philosophers = ["Kant", "Chomsky", "Socrate", "Kripke"]

main = do
    stdo <- newMVar () 
    forks <- atomically $ do
        localForks <- mapM (const $ newTVar True) [1..5]
        return localForks
    let forkPairs = zip forks ((tail forks) ++ [head forks])
    let philosophersWithForks = zip philosophers forkPairs

    mapM_ (forkIO . runPhilosopher stdo) philosophersWithForks

    getLine