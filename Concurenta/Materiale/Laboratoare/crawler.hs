
import System.Process (readProcessWithExitCode)
import System.Exit (ExitCode(..))
import Control.Concurrent 
import Control.Monad () 
import Data.Char

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

main = do
    r1 <- async $ getURL "https://fmi.unibuc.ro"
    r2 <- async $ getURL "https://example.com"
    s1 <- await r1
    s2 <- await r2
    putStrLn s1
    putStrLn s2


