import Control.Monad
import Control.Concurrent.STM
import Control.Concurrent
import System.Random (getStdRandom, Random (randomR))

data Gate = MkGate Int (TVar Int)
data Group = MkGroup Int (TVar (Int, Gate, Gate))

newGate :: Int -> STM Gate
newGate n = do
    tv <- newTVar 0 -- ! cheile vor fi date de santa
    return $ MkGate n tv

passGate :: Gate -> IO ()
passGate (MkGate n tv) = atomically $ do
    n_left <- readTVar tv
    if n_left == 0
        then retry
        else writeTVar tv (n_left - 1)

operateGate :: Gate -> IO ()
operateGate (MkGate n tv) = do
    atomically $ writeTVar tv n
    atomically $ do
        n_left <- readTVar tv
        if n_left > 0
            then retry
            else return ()

newGroup :: Int -> IO Group
newGroup n = atomically $ do
    g1 <- newGate n
    g2 <- newGate n
    tv <- newTVar (n, g1, g2)
    return $ MkGroup n tv

joinGroup :: Group -> IO (Gate, Gate)
joinGroup (MkGroup n tv) = atomically $ do
    (n_left, g1, g2) <- readTVar tv
    if n_left == 0
        then retry
        else do
            writeTVar tv (n_left - 1, g1, g2)
            return (g1, g2)

awaitGroup :: Group -> STM (Gate, Gate)
awaitGroup (MkGroup n tv) = do
    (n_left, g1, g2) <- readTVar tv
    if n_left > 0
        then retry
        else do
            new_g1 <- newGate n
            -- pregateste portile pt grupul urmat
            new_g2 <- newGate n
            writeTVar tv (n, new_g1, new_g2)
            return (g1, g2) -- intoarce portile pt grupul deja format

helper1 :: Group -> IO () -> IO ()
helper1 group do_task = do
    (in_gate, out_gate) <- joinGroup group
    passGate in_gate
    do_task
    passGate out_gate

meetInStudy :: Int -> IO ()
meetInStudy id = putStr $ "Elf " ++ show id ++ " meeting in the stduy\n"

deliverToys :: Int -> IO ()
deliverToys id = putStr $ "Reindeer " ++ show id ++ " delivering toys\n"

elf1 :: Group -> Int -> IO ()
elf1 gp id = helper1 gp $ meetInStudy id

reindeer1 :: Group -> Int -> IO ()
reindeer1 gp id = helper1 gp $ deliverToys id

randomDelay :: IO ()
randomDelay = do
    waitTime <- getStdRandom $ randomR (1, 5*10^6)
    threadDelay waitTime

elf, reindeer :: Group -> Int -> IO ThreadId
elf gp id = forkIO . forever $ do
    elf1 gp id
    randomDelay

reindeer gp id = forkIO .forever $ do
    reindeer1 gp id
    randomDelay

chooseGroup :: Group -> String -> STM (String, (Gate, Gate))
chooseGroup gp task = do
    gates <- awaitGroup gp
    return (task, gates)

santa :: Group -> Group -> IO ()
santa elf_gp rein_gp = do
    putStr "----------------------------------\n"
    (task, (ing_gate, out_gate)) <- atomically $ orElse
        -- ! Renii au prioritate
        (chooseGroup rein_gp "deliver toys")
        (chooseGroup elf_gp "meet in my study")
    putStrLn ("Ho! Ho! Ho! Let's " ++ task)
    operateGate ing_gate
    -- elfii / renii lucreaza cu Santa
    operateGate out_gate

testare = do
    grp <- newGroup 2 -- grup de capacitate 2
    forkIO $ elf1 grp 1 -- elful 1 vrea sa intre la Santa
    forkIO $ elf1 grp 2 -- elful 2 vrea sa intre la Santa
    (in_gate, out_gate) <-
        atomically $ awaitGroup grp -- Santa asteapta formarea grupului
    operateGate in_gate -- Santa deschide poarta de intrare si
    -- asteapta sa intre toti elfii
    operateGate out_gate -- Santa deschide poarta de intrare si
    -- asteapta sa intre toti elfii

main = do
    elf_group <- newGroup 3
    sequence_ [elf elf_group n | n <- [1..10]]

    rein_group <- newGroup 9
    sequence_ [reindeer rein_group n | n <- [1..9]]

    forever $ santa elf_group rein_group