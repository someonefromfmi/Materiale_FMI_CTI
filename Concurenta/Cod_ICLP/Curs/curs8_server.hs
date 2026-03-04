import Control.Concurrent.STM
import System.IO
import Network.Socket

-- canal in STM
data MyTChan a = TChan (TVar (TVarList a)) (TVar (TVarList a))
type TVarList a = TVar (TList a)
data TList a = TNil | TCons a (TVarList a)

myNewTChan :: STM (MyTChan a)
myNewTChan = do
    hole <- newTVar TNil
    read <- newTVar hole
    write <- newTVar hole
    return $ TChan read write

myReadTChan :: MyTChan a -> STM a
myReadTChan (TChan readVar _) = do
    listHead <- readTVar readVar
    head <- readTVar listHead
    case head of
        TNil -> retry
        TCons val tail -> do
            writeTVar readVar tail
            return val

myWriteTChan :: MyTChan a -> a -> STM ()
myWriteTChan (TChan _ writeVar) a = do
    newListEnd <- newTVar TNil
    listEnd <- readTVar writeVar
    writeTVar writeVar newListEnd
    writeTVar listEnd (TCons a newListEnd)

{-
unGetTChan este inversa lui readTChan; cand canalul este gol un thread
poate chema unGetTChan pt a debloca capatul de citire
-} 

-- inversa lui readTChan; cand canalul este gol un thread poate
-- chema unGetTChan pentru a debloca capatul de citire
myUnGetTChan :: MyTChan a -> a -> STM ()
myUnGetTChan (TChan readVar _) a = do
    listHead <- readTVar readVar
    newHead <- newTVar (TCons a listHead)
    writeTVar readVar newHead

myIsEmptyTChan :: MyTChan a -> STM Bool
myIsEmptyTChan (TChan read _) = do
    listhead <- readTVar read
    head <- readTVar listhead
    case head of
        TNil -> return True
        TCons _ _ -> return False

myDupTChan :: MyTChan a -> STM (MyTChan a)
myDupTChan (TChan readVar writeVar) = do
    hole <- readTVar writeVar
    newRead <- newTVar hole
    return $ TChan newRead writeVar

expCanal = do
    c <- atomically myNewTChan 
    atomically $ myWriteTChan c 'a'
    atomically (myReadTChan c) >>= print
    atomically (myIsEmptyTChan c) >>= print
    atomically $ myUnGetTChan c 'a'
    atomically (myIsEmptyTChan c) >>= print
    atomically (myReadTChan c) >>= print
    c2 <- atomically $ myDupTChan c
    atomically $ myWriteTChan c 'b'
    atomically (myReadTChan c) >>= print
    atomically (myReadTChan c2) >>= print

-------------------------------------------------------------------

exio1 = do
    hdl1 <- openFile "f1.txt" ReadMode
    hdl2 <- openFile "f2.txt" AppendMode
    s <- hGetContents hdl1
    putStrLn s
    hPutStr hdl2 s
    hClose hdl1
    hClose hdl2

exio2 = do
    s <- readFile "f1.txt"
    putStrLn s
    writeFile "f2.txt" s

---------------------------------------------------------------------

loopForever :: Socket -> IO ()
loopForever sock = do
    (conn, _) <- accept sock
    handleSock <- socketToHandle conn ReadWriteMode
    line <- hGetLine handleSock
    putStrLn $ "Request received: " ++ line
    hPutStrLn handleSock "Hey, client!"
    hClose handleSock
    loopForever sock

main = do
    sock <- socket AF_INET Stream 0
    setSocketOption sock ReuseAddr 1
    bind sock (SockAddrInet 4242 0)
    listen sock 2
    putStrLn "Listening on port 4242..."
    loopForever sock

---------------------------------------------------------------------
-- TODO: Si restul chestiilor




 