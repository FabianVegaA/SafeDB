{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import Data.Aeson ((.=))
import Data.Aeson.Types (object)
import Data.Text (Text)
import Interpret (runDB)
import Lib (done, get, initDB, insert, update)

main :: IO ()
main = runDB (Just "test.fiabledb") $ do
  initDB
  insert $
    object
      [ "name" .= ("John" :: Text),
        "age" .= (30 :: Int)
      ]
  insert $
    object
      [ "name" .= ("Jane" :: Text),
        "age" .= (25 :: Int),
        "address" .= ("123 Main St" :: Text)
      ]
  get 1
  update 1 $
    object
      [ "name" .= ("John" :: Text),
        "age" .= (31 :: Int)
      ]
  get 1
  done