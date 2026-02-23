-- 1 Cerinte
import Test.QuickCheck

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
instance Show EquipmentType where
    show Router = "Router"
    show Switch = "Switch"
    show Host = "Host"
    show Server = "Server"

instance Eq EquipmentType where
    Router == Router = True
    Switch == Switch = True
    Host == Host = True
    Server == Server = True
    _ == _ = False

instance Show NetworkEquipment where
    show (NetworkEquipment name eqType ipAddresses) = "NE { name = " ++ show name 
        ++ ", type = " ++ show eqType 
        ++ ", ipAddresses = " ++ show ipAddresses ++ " }"

instance Eq NetworkEquipment where
    (NetworkEquipment n1 t1 i1) == (NetworkEquipment n2 t2 i2)
        | n1 == n2 && t1 == t2 && i1 == i2 = True
        | otherwise = False

--TODO ex 2
isExistsRec :: IPAddress -> [NetworkEquipment] -> Bool
isExistsRec _ [] = False
isExistsRec addr (x:xs)
    | addr `elem` ipAddresses x = True
    | otherwise = isExistsRec addr xs

ipExistsComprehension :: IPAddress -> [NetworkEquipment] -> Bool 
ipExistsComprehension ip list = length [neteq | neteq <- list, ip `elem` ipAddresses neteq] > 0

ipExistsHigherOrderFunctions :: IPAddress -> [NetworkEquipment] -> Bool
ipExistsHigherOrderFunctions addr l =
    addr
    `elem`
    concatMap ipAddresses l

ipExistsFoldr' :: [NetworkEquipment] -> IPAddress -> Bool 
ipExistsFoldr' = foldr (\x u ip -> if (ip `elem` ipAddresses x) then True else u ip) (\_ -> False)

--TODO ex 3
instance Arbitrary NetworkEquipment where
    arbitrary = do
        ename <- arbitrary
        etype <- elements [Router, Switch, Server, Host]
        eip <- arbitrary
        return $ NetworkEquipment ename etype eip

prop_qc :: IPAddress -> [NetworkEquipment] -> Bool
prop_qc ip list = ipExistsComprehension ip list == isExistsRec ip list

test_prop_qc = quickCheck prop_qc

--TODO ex 4
data Log = Log { equipmentType :: String, message :: String}
    deriving (Eq, Show)
data NetworkWriter a = NetworkWriter { runNetworkWriter :: (a, Log) }

instance Semigroup Log where
    l1 <> l2 = Log (equipmentType l1 ++ " " ++ equipmentType l2) (message l1 ++ " " ++ message l2)

instance Monoid Log where
    mempty = Log "" ""

--TODO ex 5
instance Functor NetworkWriter where
    fmap f (NetworkWriter (a, log)) = NetworkWriter (f a, log)

instance Applicative NetworkWriter where
    pure x = NetworkWriter (x, Log "" "")
    (NetworkWriter (f, log1)) <*> (NetworkWriter (x, log2)) = NetworkWriter (f x, log1 <> log2)

instance Monad NetworkWriter where
    return = pure
    NetworkWriter (a, log1) >>= f =
        let NetworkWriter (b, log2) = f a
        in NetworkWriter (b, log1 <> log2)

--TODO ex 6
addEquipment :: NetworkEquipment -> [NetworkEquipment] -> NetworkWriter [NetworkEquipment]
addEquipment eq eqs = 
    NetworkWriter (eq : eqs, Log ("equipment: " ++ show eq ++ " ")  ("added " ++ eqName eq ++ "\n") )

removeEquipment :: String -> [NetworkEquipment] -> NetworkWriter [NetworkEquipment]
removeEquipment name eqs =
    let newEqs = filter (\ne -> name /= eqName ne) eqs
    in NetworkWriter (newEqs, Log ("equipments with name: " ++ name) ("removed " ++ name ++ "\n"))

runExample :: [NetworkEquipment] -> NetworkWriter [NetworkEquipment]
runExample equipments = do
    eqs1 <- addEquipment eq1 equipments
    eqs2 <- addEquipment eq2 eqs1
    eqs3 <- removeEquipment "R-CTI" eqs2
    return eqs3

main :: IO ()
main = do
    let equipments = []
    let (newEquipments, log) = runNetworkWriter (runExample equipments)
    putStrLn $ "Final list: " ++ show newEquipments
    putStrLn "\n--- Logs ---"
    putStrLn $ message log

