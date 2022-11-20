{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import Data.Aeson (Value, (.=))
import Data.Aeson.Types (object)
import Data.Text (Text)
import Interpret (runDB)
import Lib (delete, done, get, initDB, insert, update)

instance Semigroup Value where
  (<>) = undefined

instance Monoid Value where
  mempty = object []
  mappend = (<>)

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
  delete 2
  get 2
  update 1 $
    object
      [ "name" .= ("John" :: Text),
        "age" .= (31 :: Int)
      ]
  done