type IPAddress = String
data EquipmentType = Router | Switch | Host | Server
data NetworkEquipment = NetworkEquipment
    {
        eqName :: String,
        eqType :: EquipmentType,
        ipAddresses :: [IPAddress]
    }

eq1 :: NetworkEquipment
eq1 = NetworkEquipment { eqName = "R-CTI", eqType = Router, ipAddresses = ["139.208.0.1"]}

eq2 :: NetworkEquipment
eq2 = NetworkEquipment { eqName = "SW-CTI", eqType = Switch, ipAddresses = ["139.208.0.2", "139.208.0.1"]}

eq3 :: NetworkEquipment
eq3 = NetworkEquipment { eqName = "HOST-CTI", eqType = Host, ipAddresses = ["139.208.0.10", "139.208.0.11", "139.208.0.12"]}

eq4 :: NetworkEquipment
eq4 = NetworkEquipment { eqName = "SERVER", eqType = Server, ipAddresses = ["139.208.15.254"]}

--TODO ex 1
-- instance Show EquipmentType where

-- instance Eq EquipmentType where

-- instance Show NetworkEquipment where

-- instance Eq NetworkEquipment where

--TODO ex 2
isExistsRec :: IPAddress -> [NetworkEquipment] -> Bool
isExistsRec _ [] = undefined

isExistsComprehension :: IPAddress -> [NetworkEquipment] -> Bool
isExistsComprehension addr l = undefined

ipExistsHigherOrderFunctions :: IPAddress -> [NetworkEquipment] -> Bool
ipExistsHigherOrderFunctions addr l = undefined

ipExistsFoldr:: IPAddress -> [NetworkEquipment] -> Bool
ipExistsFoldr addr l = undefined

--TODO ex 3
-- instance Arbitrary NetworkEquipment

prop_qc :: IPAddress -> [NetworkEquipment] -> Bool
prop_qc = undefined

-- test_prop_qc = quickCheck prop_qc

--TODO ex 4
data Log = Log { equipmentType :: String, message :: String}
    deriving (Eq, Show)
data NetworkWriter a = NetworkWriter { runNetworkWriter :: (a, Log) }

-- instance Semigroup Log where

-- instance Monoid Log where

--TODO ex 5
-- instance Functor NetworkWriter where

-- instance Applicative NetworkWriter where

-- instance Monad NetworkWriter where

--TODO ex 6
addEquipment :: NetworkEquipment -> [NetworkEquipment] -> NetworkWriter [NetworkEquipment]
addEquipment = undefined

removeEquipment :: String -> [NetworkEquipment] -> NetworkWriter [NetworkEquipment]
removeEquipment = undefined

-- runExample :: [NetworkEquipment] -> NetworkWriter [NetworkEquipment]
-- runExample equipments = do
--     eqs1 <- addEquipment eq1 equipments
--     eqs2 <- addEquipment eq2 eqs1
--     eqs3 <- removeEquipment "R-CTI" eqs2
--     return eqs3

-- main :: IO ()
-- main = do
--     let equipments = []
--     let (newEquipments, log) = runNetworkWriter (runExample equipments)
--     putStrLn $ "Final list: " ++ show newEquipments
--     putStrLn "\n--- Logs ---"
--     putStrLn $ messageLog log

