import Control.Concurrent
import Control.Monad
import Data.Char (toUpper)
import Control.Concurrent.Chan
import Control.Concurrent.MVar

-- Structura pentru un canal marginit (bounded channel)
data BoundedChan a = BoundedChan 
    { bcChan :: Chan a          -- canalul propriu-zis
    , bcCapacity :: Int         -- capacitatea maximă
    , bcSize :: MVar Int        -- dimensiunea curentă (folosim MVar pentru sincronizare)
    }

-- Lista de canale marginite
type BoundedChanList a = [BoundedChan a]

-- Creează un canal marginit cu capacitatea N și un element inițial
newBoundedChan :: Int -> a -> IO (BoundedChan a)
newBoundedChan capacity initialVal = do
    chan <- newChan
    sizeRef <- newMVar 1
    writeChan chan initialVal  -- fiecare canal are cel puțin un element
    return $ BoundedChan chan capacity sizeRef

-- Creează o listă de canale marginite, fiecare cu capacitatea N și un element inițial
createBoundedChanList :: Int -> Int -> a -> IO (BoundedChanList a)
createBoundedChanList numChannels capacity initialVal = 
    replicateM numChannels (newBoundedChan capacity initialVal)

-- Citește din canalul la indexul specificat
-- Non-blocant - dacă e gol, afișează mesaj
readFromChannel :: Show a => BoundedChanList a -> Int -> IO ()
readFromChannel chanList idx = do
    if idx < 0 || idx >= length chanList
        then putStrLn $ "Eroare: Indexul " ++ show idx ++ " nu există în listă!"
        else do
            let bc = chanList !! idx
            currentSize <- takeMVar (bcSize bc)
            if currentSize == 0
                then do
                    putMVar (bcSize bc) currentSize
                    putStrLn $ "STDOUT: Canalul " ++ show idx ++ " este gol!"
                else do
                    val <- readChan (bcChan bc)
                    putMVar (bcSize bc) (currentSize - 1)
                    putStrLn $ "Citit din canalul " ++ show idx ++ ": " ++ show val

-- Scrie în canalul la indexul specificat
-- Blocant dacă canalul este la capacitate maximă
writeToChannel :: Show a => BoundedChanList a -> Int -> a -> IO ()
writeToChannel chanList idx val = do
    if idx < 0 || idx >= length chanList
        then putStrLn $ "Eroare: Indexul " ++ show idx ++ " nu există în listă!"
        else do
            let bc = chanList !! idx
            -- Așteaptă până când există spațiu în canal
            waitAndWrite bc val idx

-- Funcție auxiliară care așteaptă să existe spațiu și apoi scrie
waitAndWrite :: Show a => BoundedChan a -> a -> Int -> IO ()
waitAndWrite bc val idx = do
    currentSize <- takeMVar (bcSize bc)
    if currentSize >= bcCapacity bc
        then do
            putMVar (bcSize bc) currentSize
            putStrLn $ "Așteptare: Canalul " ++ show idx ++ " este plin (capacitate " ++ show (bcCapacity bc) ++ ")"
            threadDelay 100000  -- Așteaptă 100ms
            waitAndWrite bc val idx  -- Încearcă din nou
        else do
            writeChan (bcChan bc) val
            putMVar (bcSize bc) (currentSize + 1)
            putStrLn $ "Scris în canalul " ++ show idx ++ ": " ++ show val ++ " (dimensiune: " ++ show (currentSize + 1) ++ "/" ++ show (bcCapacity bc) ++ ")"

-- Exemplu de utilizare
main :: IO ()
main = do
    putStrLn "=== Test Canal Marginit ==="
    putStrLn ""
    
    -- Creează 3 canale, fiecare cu capacitatea 3 și element inițial 0
    chanList <- createBoundedChanList 3 3 (0 :: Int)
    putStrLn "Creat 3 canale cu capacitate 3, fiecare cu elementul inițial 0"
    putStrLn ""
    
-- Funcții suplimentare pentru manipularea listei de canale

-- Afișează starea tuturor canalelor
showChannelStates :: BoundedChanList a -> IO ()
showChannelStates chanList = do
    putStrLn "Starea canalelor:"
    forM_ (zip [0..] chanList) $ \(idx, bc) -> do
        size <- readMVar (bcSize bc)
        putStrLn $ "  Canal " ++ show idx ++ ": " ++ show size ++ "/" ++ show (bcCapacity bc) ++ " elemente"
