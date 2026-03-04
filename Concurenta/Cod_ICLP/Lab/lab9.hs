import Control.Concurrent 
import Control.Concurrent.STM 
import Control.Monad 
 
{-
    Problema Santa 
    - un thread principal cu rol de orchestrator: Santa 
    - si prietenii sai care sunt workerii - renii si elfii 
 
    Programul are 10 threaduri elf, 9 threaduri ren si un thread principal, Santa 
    elfii si renii trebuie sa formeze grupuri de o anumita capacitate 
 
    dupa ce s-a realizat o grupare, ea este preluata de Santa 
        - renii au prioritate 
        - cand Santa accepta un nou grup, celalalt trebuie sa fie plecat deja 
         (Santa trebuie sa fie disponibil)
 
    threadurile ruleaza la infinit
 
    Ciclul de viata pentru un elf sau ren (individual)
    - incearca sa intre intr-un grup 
    - dupa ce grupul s-a format, grupul incearca sa intre la Santa 
    - executa o anumita actiune la Santa 
    - pleaca de la Santa 
 
    Dupa ce grupul s-a format, el primeste doua "porti" - una de intrare, respectiv una de iesire 
    Portile sunt operate de Santa 
-}
 
delay :: IO () 
delay = threadDelay 2_000_000 
 
-- reamintim ca in Haskell scrierea la stdout nu este sincronizata 
-- deci trebuie sa o facem manual 
 
-- folosim MVar ca mutex 
-- facem writeStdOut sa fie thread-safe
-- takeMVar -> acquire si putMVar -> release
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
        if (n_left > 0) then retry 
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
 
-- simulam task-urile 
 
meetInStudy :: Int -> MVar () -> IO () 
meetInStudy id stdw = writeStdOut stdw $ "Elf " ++ show id ++ " meeting in the study\n" 
 
deliverToys :: Int -> MVar () -> IO ()
deliverToys id stdw = writeStdOut stdw $ "Reindeer " ++ show id ++ " delivering toys\n"
 
elfHelper :: Group -> Int -> MVar () -> IO () 
elfHelper group id stdw = helper group (meetInStudy id stdw)
 
reindeerHelper :: Group -> Int -> MVar () -> IO ()
reindeerHelper group id stdw = helper group (deliverToys id stdw) 
 
elf :: Group -> Int -> MVar () -> IO ThreadId 
elf group id stdw = forkIO . forever $ do 
    elfHelper group id stdw 
    delay 
 
reindeer :: Group -> Int -> MVar () -> IO ThreadId 
reindeer group id stdw = forkIO . forever $ do 
    reindeerHelper group id stdw 
    delay 
 
-- scriem o functie care il ajuta pe Santa sa aleaga grupurile 
chooseGroup :: Group -> String -> STM (String, (Gate, Gate))
chooseGroup group task = do 
    gates <- awaitGroup group 
    return (task, gates)
 
 
-- orchestratorul 
santa :: Group -> Group -> MVar () -> IO () 
santa elf_group reindeer_group stdo = do 
    (task, (in_gate, out_gate)) <- atomically $ orElse 
        (chooseGroup reindeer_group "deliver toys")
        (chooseGroup elf_group "meet in my study")
    writeStdOut stdo $ "Let's " ++ task ++ " \n"
    operateGate in_gate 
    operateGate out_gate 
 
main = do 
    stdw <- newMVar () 
    elf_group <- newGroup 3 
    sequence_ [elf elf_group n stdw | n <- [1..10]]
 
    rein_group <- newGroup 9 
    sequence_ [reindeer rein_group n stdw | n <- [1..9]]
 
    forever $ santa elf_group rein_group stdw