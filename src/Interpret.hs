{-# LANGUAGE LambdaCase #-}

module Interpret (runDB) where

import Control.Exception (throwIO)
import Data.Aeson (FromJSON, ToJSON, eitherDecode, encode)
import Data.Aeson.Encode.Pretty (encodePretty)
import qualified Data.ByteString.Lazy.Char8 as B
import Data.ByteString.Lazy.Internal (packChars, unpackChars)
import Data.Foldable (maximumBy)
import Data.Maybe (fromMaybe)
import Data.Ord (comparing)
import Free (Free (..))
import Lib (DBOperation, Operation (..), OperationFail (..), update)
import Record (Record (..))
import System.Directory (doesFileExist)
import qualified System.IO.Strict as S
import Text.Printf (printf)

runDB ::
  (ToJSON a, FromJSON a, Show a, Show b, Monoid a, Eq a) =>
  Maybe FilePath ->
  DBOperation a b ->
  IO ()
runDB _ (Pure err) = throwIO . userError . show $ err
runDB maybePath (Free a) = case a of
  Init next -> do
    printf "Starting DB with %s connection\n" (fromMaybe "default" maybePath)
    tryConnectDB $ \_ -> run next
  Get key next -> continue next . tryRecover key $ \recovered _ -> do
    putStr "Records found: "
    B.putStrLn . encodePretty $ recovered
  Insert val next -> continue next . tryConnectDB $ \records -> do
    let record = Record (length records + 1) 1 val
    writeDB $ record : records
  Update key val next -> continue next . tryRecover key $ \recovered records -> do
    let record = head recovered
    let newRecord = record {rev = rev record + 1, value = val}
    writeDB $ newRecord : recover key records
  Delete key next -> tryRecover key $ \recovered _ -> do
    let lastUpdated = maximumBy (comparing rev) recovered
    if value lastUpdated == mempty
      then throwIO (AlreadyDeleted key)
      else run $ do
        update key mempty
        next
  Done -> putStrLn "Closing DB connection..."
  where
    path = fromMaybe "test.fiabledb" maybePath
    run = runDB (pure path)
    continue next routine = routine >> run next

    tryConnectDB routine = do
      connectDB >>= \case
        Nothing -> throwIO DBConnectionError
        Just rs -> routine rs

    connectDB = do
      exists <- doesFileExist path
      if exists
        then do
          content <- S.readFile path
          case eitherDecode . packChars $ content of
            Left err -> throwIO $ CorruptedDB err
            Right rs -> return rs
        else do
          putStrLn "DB file not found"
          putStrLn "You want to create a new DB? (y/n)"
          getLine >>= \case
            "y" -> do
              writeFile path "[]"
              return $ Just []
            "n" -> return Nothing
            _ -> do
              putStrLn "Invalid option"
              connectDB

    writeDB rs = do
      exist <- doesFileExist path
      if exist
        then writeFile path . unpackChars . encode $ rs
        else tryConnectDB $ \_ -> writeDB rs

    recover key = filter (\r -> identifier r /= key)

    tryRecover key f = tryConnectDB $ \records -> do
      let recovered = recover key records
      if null recovered
        then throwIO KeyNotFound
        else f recovered records
