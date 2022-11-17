{-# LANGUAGE LambdaCase #-}

module Interpret (runDB) where

import Control.Exception (throwIO)
import Data.Aeson (FromJSON, ToJSON, decode, encode)
import Data.Aeson.Encode.Pretty (encodePretty)
import qualified Data.ByteString.Lazy.Char8 as B
import Data.ByteString.Lazy.Internal (packChars, unpackChars)
import Free (Free (..))
import Lib (DBOperation, Operation (..), OperationFail (..))
import Record (Record (..))
import System.Directory (doesFileExist)
import qualified System.IO.Strict as S

runDB :: (ToJSON a, FromJSON a, Show a, Show b) => DBOperation a b -> IO ()
runDB (Pure err) = throwOperation err
runDB (Free a) = case a of
  Init next -> do
    putStrLn "Starting DB with default connection (test.fiabledb)"
    tryConnectDB $ \_ -> runDB next
  Get key next -> tryConnectDB $ \records -> do
    putStr "Records found: "
    let foundRecords = filter (\r -> identifier r == key) records
    if null foundRecords
      then throwOperation KeyNotFound
      else B.putStrLn . encodePretty $ foundRecords
    runDB next
  Insert val next -> tryConnectDB $ \records -> do
    let record = Record (length records + 1) 1 val
    writeDB $ record : records
    runDB next
  Update key val next -> tryConnectDB $ \records -> do
    let foundRecords = filter (\r -> identifier r == key) records
    if null foundRecords
      then throwOperation KeyNotFound
      else do
        let record = head foundRecords
        let newRecord = record {rev = rev record + 1, value = val}
        let newRecords = newRecord : filter (\r -> identifier r /= key) records
        writeDB newRecords
        runDB next
  Done -> putStrLn "Closing DB connection"
  where
    tryConnectDB routine = do
      connectDB >>= \case
        Nothing -> throwOperation DBConnectionError
        Just rs -> routine rs

    connectDB = do
      exists <- doesFileExist "test.fiabledb"
      if exists
        then do
          content <- S.readFile "test.fiabledb"
          return $ decode . packChars $ content
        else do
          putStrLn "DB file not found"
          putStrLn "You want to create a new DB? (y/n)"
          getLine >>= \case
            "y" -> do
              writeFile "test.fiabledb" "[]"
              return $ Just []
            "n" -> return Nothing
            _ -> do
              putStrLn "Invalid option"
              connectDB

    writeDB rs = do
      exist <- doesFileExist "test.fiabledb"
      if exist
        then writeFile "test.fiabledb" . unpackChars . encode $ rs
        else tryConnectDB $ \_ -> writeDB rs

throwOperation :: (Show a) => a -> IO ()
throwOperation = throwIO . userError . show