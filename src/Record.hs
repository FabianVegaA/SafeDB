{-# LANGUAGE OverloadedStrings #-}

module Record where

import Data.Aeson (FromJSON (..), ToJSON (..), object, withObject, (.:), (.=))

data Record a = Record
  { identifier :: Int,
    rev :: Int,
    value :: a
  }
  deriving (Show)

instance (FromJSON a) => FromJSON (Record a) where
  parseJSON = withObject "Record" $ \v -> Record <$> v .: "id" <*> v .: "value" <*> v .: "version"

instance (ToJSON a) => ToJSON (Record a) where
  toJSON (Record id value version) = object ["id" .= id, "value" .= value, "version" .= version]
