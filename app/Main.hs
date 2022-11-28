{-# LANGUAGE OverloadedStrings #-}
{-# OPTIONS_GHC -Wno-orphans #-}

module Main (main) where

import Data.Aeson (Value, (.=))
import Data.Aeson.Types (object)
import Data.Text (Text)
import Interpret (runDB)
import Lib (delete, done, get, getOne, initDB, insert, update)

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
      [ "name" .= ("Xavier" :: Text),
        "age" .= (29 :: Int),
        "address"
          .= object
            [ "street" .= ("Calle 1" :: Text),
              "number" .= (123 :: Int)
            ]
      ]
  update 1 $
    object
      [ "name" .= ("Xavier" :: Text),
        "age" .= (30 :: Int),
        "address"
          .= object
            [ "street" .= ("Siempre Viva" :: Text),
              "number" .= (123 :: Int)
            ],
        "phone" .= ("987654321" :: Text)
      ]
  delete 1
  get 1
  getOne 1
  done
