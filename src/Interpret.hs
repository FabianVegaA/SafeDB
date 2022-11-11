module Interpret (runDB) where

import Control.Exception (throwIO)
import Data.Aeson (FromJSON, ToJSON, decode, encode)
import Data.Aeson.Encode.Pretty (encodePretty)
import qualified Data.ByteString.Lazy.Char8 as B
import Data.ByteString.Lazy.Internal (packChars, unpackChars)
import Free (Free (..))
import Lib (DBOperation, Operation (..), OperationFail (..))
import Record (Record (..))
import qualified System.IO.Strict as S

runDB :: (ToJSON a, FromJSON a, Show a, Show b) => DBOperation a b -> IO ()
runDB (Pure err) = throwOperation err
runDB (Free a) = case a of
  Init next -> do
    putStrLn "Starting DB with default connection (test.fiabledb)"
    writeFile "test.fiabledb" mempty
    runDB next
  Get key next -> do
    rs <- connectDB
    case rs of
      Nothing -> throwOperation DBConnectionError
      Just records -> do
        putStr "Records found: "
        let foundRecords = filter (\r -> identifier r == key) records
        if null foundRecords
          then throwOperation KeyNotFound
          else B.putStrLn . encodePretty $ foundRecords
        runDB next
  Insert val next -> do
    rs <- connectDB
    let record = Record (length rs + 1) 1 val
    writeFile "test.fiabledb" . unpackChars . encode $ case rs of
      Just records -> record : records
      Nothing -> [record]
    runDB next
  Done -> putStrLn "Closing DB connection"
  where
    connectDB = decode . packChars <$> S.readFile "test.fiabledb"

throwOperation :: (Show a) => a -> IO ()
throwOperation = throwIO . userError . show