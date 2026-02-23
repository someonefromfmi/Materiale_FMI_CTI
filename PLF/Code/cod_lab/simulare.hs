import Test.QuickCheck (Arbitrary (arbitrary))
import Test.QuickCheck.Gen (elements)
import Test.QuickCheck.Test (quickCheck)
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
    show equip = eqName equip ++ " " ++ show (eqType equip) ++ " " ++ show (ipAddresses equip)

instance Eq NetworkEquipment where
    (==) :: NetworkEquipment -> NetworkEquipment -> Bool
    a1 == a2
        | eqName a1 == eqName a2 && eqType a1 == eqType a2 && ipAddresses a1 == ipAddresses a2 = True
        | otherwise = False

-- ex 2
isExistsRec :: IPAddress -> [NetworkEquipment] -> Bool
isExistsRec _ [] = False
isExistsRec addr (x:xs) =
    (addr `elem` ipAddresses x) || isExistsRec addr xs

isExistsComprehension :: IPAddress -> [NetworkEquipment] -> Bool
isExistsComprehension addr l = 
    addr
    `elem`
    [ y | y <- concat $ map ipAddresses l]

ipExistsHigherOrderFunctions :: IPAddress -> [NetworkEquipment] -> Bool
ipExistsHigherOrderFunctions addr l = 
    addr
    `elem`
    (concat $ map ipAddresses l) 

-- ipExistsFoldr :: IPAddress -> [NetworkEquipment] -> Bool
-- ipExistsFoldr addr l =

instance Arbitrary NetworkEquipment where
    arbitrary = do
        ename <- arbitrary
        etype <- elements [Router, Switch, Server, Host]
        eip <- arbitrary
        return $ NetworkEquipment ename etype eip
        
prop_qc :: IPAddress -> [NetworkEquipment] -> Bool
prop_qc a l = 
    isExistsComprehension a l == isExistsRec a l 

test_prop_qc = quickCheck prop_qc

-- ex 4
-- data Log = Log { equipmentType :: }

