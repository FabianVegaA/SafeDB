module Interpret (runDB) where

import Control.Exception (throwIO)
import Data.Aeson (decode, encode)
import Data.ByteString.Lazy.Internal (packChars, unpackChars)
import Free (Free (..))
import Lib (Operation (..), OperationFail (..))
import Record (Person (..), Record (..), RecordPerson)
import qualified System.IO.Strict as S

runDB :: (Show r) => Free (Operation Int Person) r -> IO ()
runDB (Free (Init next)) = run next initDB
runDB (Free (Get key next)) = run next $ getDB key
runDB (Free (Set key value next)) = run next $ setDB key value
runDB (Free (Show key next)) = run next $ showDB key
runDB (Free Done) = return ()
runDB (Pure r) = throwIO . userError $ show r

run :: Show r => Free (Operation Int Person) r -> IO a -> IO ()
run next routine = routine >> runDB next

initDB :: IO ()
initDB = do
  putStrLn "Starting DB with default connection (test.fiabledb)"
  writeFile "test.fiabledb" mempty

getDB :: Int -> IO [RecordPerson]
getDB key = do
  db <- S.readFile "test.fiabledb"
  case decode $ packChars db of
    Just records -> return $ filter (\r -> identifier r == key) records
    Nothing -> return []

setDB :: Int -> Person -> IO ()
setDB key value = do
  db <- S.readFile "test.fiabledb"
  res <- getDB key
  addRecord db $ case res of
    [] -> Record 1 value 1
    rs ->
      let next_version = maximum (map identifier rs) + 1
          id' = identifier $ head rs
       in Record id' value next_version
  where
    addRecord :: String -> RecordPerson -> IO ()
    addRecord db record = do
      writeFile "test.fiabledb" . unpackChars . encode $ case decode (packChars db) of
        Just records -> record : records
        Nothing -> [record]

showDB :: Int -> IO ()
showDB key = do
  res <- getDB key
  case res of
    [] -> throwIO . userError $ show KeyNotFound
    rs -> putStrLn $ "Records: " ++ show rs
