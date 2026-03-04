import Control.Concurrent
import Control.Concurrent.STM
import Control.Monad

delay :: IO () 
delay = threadDelay 2_000_000 

writeStdOut stdw str = do 
    takeMVar stdw 
    putStrLn str 
    putMVar stdw () 

--                  nr maxim de chei
data Gate = MkGate Int (TVar Int)
--                      nr de chei disponibile la un moment de timp 

newGate :: Int -> STM Gate 
newGate n = do 
    tv <- newTVar 0
    return (MkGate n tv) 

passGate :: Gate -> IO () 
passGate (MkGate n tv) = atomically $ do 
    n_left <- readTVar tv 
    if n_left == 0 then retry 
    else writeTVar tv (n_left - 1)  

operateGate :: Gate -> IO ()
operateGate (MkGate n tv) = do 
    atomically $ writeTVar tv n 
    atomically $ do 
        n_left <- readTVar tv 
        if n_left > 0 then retry 
        else return () 

--                   capacitate 
data Group = MkGroup Int (TVar (Int, Gate, Gate)) 
--                              nr locuri ramase
--                                   poarta de intrare 
--                                          poarta de iesire 

newGroup :: Int -> IO Group 
newGroup n = atomically $ do 
    g1 <- newGate n 
    g2 <- newGate n 
    tv <- newTVar (n, g1, g2)
    return (MkGroup n tv)
 
joinGroup :: Group -> IO (Gate, Gate) 
joinGroup (MkGroup n tv) = atomically $ do 
    (n_left, g1, g2) <- readTVar tv 
    if n_left == 0 then retry
    else do 
        writeTVar tv (n_left - 1, g1, g2) 
        return (g1, g2)
 
awaitGroup :: Group -> STM (Gate, Gate)
awaitGroup (MkGroup n tv) = do 
    (n_left, g1, g2) <- readTVar tv 
    if (n_left > 0) then retry 
    else do 
        new_g1 <- newGate n 
        new_g2 <- newGate n 
        writeTVar tv (n, new_g1, new_g2)
        return (g1, g2) 
 
-- scriem ciclul de viata al unui grup 
helper :: Group -> IO () -> IO () 
helper group do_task = do 
    (in_gate, out_gate) <- joinGroup group 
    passGate in_gate 
    do_task 
    passGate out_gate

studySession i stdw = writeStdOut stdw ("Cercetator " ++ show i ++ " studiaza\n")
archiveWork i stdw = writeStdOut stdw ("Bibliotecar " ++ show i ++ " arhiveaza\n")
restoreWork i stdw = writeStdOut stdw ("Restaurator " ++ show i ++ " restaureaza\n")

researcher gp i stdw = forkIO $ forever $ helper gp (studySession i stdw) >> delay
librarian gp i stdw = forkIO $ forever $ helper gp (archiveWork i stdw) >> delay
restorer gp i stdw = forkIO $ forever $ helper gp (restoreWork i stdw) >> delay

chooseGroup :: Group -> String -> STM (String, (Gate, Gate))
chooseGroup group task = do 
    gates <- awaitGroup group 
    return (task, gates)

coordinator :: Group -> Group -> Group -> IO ()
coordinator researchers librarians restorers = do
    (task, (in_gate, out_gate)) <- atomically $
          chooseGroup librarians "arhiveaza"
      `orElse` chooseGroup restorers "restaureaza"
      `orElse` chooseGroup researchers "studiaza"
    putStr $ "Coordonator: " ++ task ++ "\n"
    operateGate in_gate
    operateGate out_gate

main :: IO ()
main = do
    stdw <- newMVar ()
    gResearchers <- newGroup 10
    gLibrarians <- newGroup 1
    gRestorers <- newGroup 1

    sequence_ [researcher gResearchers i stdw | i <- [1..30]]
    sequence_ [librarian gLibrarians i stdw | i <- [1..8]]
    sequence_ [restorer gRestorers i stdw | i <- [1..5]]

    forever $ coordinator gResearchers gLibrarians gRestorers