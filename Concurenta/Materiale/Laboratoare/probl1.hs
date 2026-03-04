{-
    Un restaurant are N locuri
    Initial, restaurantul este gol (i.e. toate locurile sunt libere)
    Cand vine un client, se uita daca exista locuri libere, si daca da, alege primul loc liber, unde sta o perioada de timp.
    Daca nu exista locuri libere, clientul este pus intr-o coada de asteptare.

    Creati un program care simuleaza modul de desfasurare al restaurantului, avand cate un thread pentru fiecare client. 
    Afisati constant mesaje cu ce se intampla in restaurant. 
-}
import Data.List 
import Control.Monad 
import Control.Concurrent 
import Data.Maybe 

data Loc = L | O 
    deriving (Eq, Show)
data Restaurant = MVar ([Loc], [Int])
    -- [Loc] - lista locurilor din restaurant 
    -- [Int] - coada de asteptare 

liber :: Loc -> Bool 
liber loc = (loc == L)

ocupat :: Loc -> Bool 
ocupat loc = (loc == O)

full :: [Loc] -> Bool 
full restaurant = and (map ocupat restaurant) 

ocupaloc i restaurant = let 
    (p1, p2) = splitAt i restaurant in p1 ++ (O : (tail p2))


elibloc i restaurant = let 
    (p1, p2) = splitAt i restaurant in p1 ++ (L : (tail p2))

takeprint m str = do 
    takeMVar m 
    putStrLn str 
    putMVar m () 

client restaurant stdo indexClient = do 
    threadDelay 1000000
    (currentRestaurant, cq) <- takeMVar restaurant
    if full currentRestaurant then do 
        putMVar restaurant (currentRestaurant, cq ++ [indexClient])
        takeprint stdo $ "Clientul " ++ show indexClient ++ " asteapta la coada"
    else do 
        let indexLoc = fromJust $ elemIndex L currentRestaurant
        let newRestaurant = ocupaloc indexLoc currentRestaurant
        putMVar restaurant (newRestaurant, cq) 
        clientin restaurant stdo indexClient indexLoc 

clientin restaurant stdo indexClient indexLoc = do 
    takeprint stdo $ "Clientul " ++ show indexClient ++ " a ocupat locul " ++ show indexLoc 
    threadDelay 5000000
    takeprint stdo $ "Clientul " ++ show indexClient ++ " paraseste restaurantul"
    (currentRestaurant, cq) <- takeMVar restaurant 
    if null cq then do 
        putMVar restaurant (elibloc indexLoc currentRestaurant, cq)
    else do 
        putMVar restaurant (currentRestaurant, tail cq)
        clientin restaurant stdo (head cq) indexLoc 

main = do
    stdo <- newMVar () 
    restaurant <- newMVar ([L, L, L], [])
    let clients = 5 
    mapM_ (forkIO . client restaurant stdo) [1..clients]
    getLine 