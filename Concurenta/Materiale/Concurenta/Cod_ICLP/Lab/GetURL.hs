module GetURL (getURL) where

import qualified Data.ByteString as B
import Network.HTTP.Simple

getURL :: String -> IO B.ByteString
getURL url = do
    request <- parseRequest url
    response <- httpBS request
    return $ getResponseBody response
