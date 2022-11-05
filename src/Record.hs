{-# LANGUAGE OverloadedStrings #-}

module Record where

import Data.Aeson (FromJSON (..), ToJSON (..), object, withObject, (.:), (.=))

data Record a = Record
  { identifier :: Int,
    value :: a,
    version :: Int
  }
  deriving (Show)

data Person = Person
  { name :: String,
    age :: Int
  }
  deriving (Show)

type RecordPerson = Record Person

instance (FromJSON a) => FromJSON (Record a) where
  parseJSON = withObject "Record" $ \v -> Record <$> v .: "id" <*> v .: "value" <*> v .: "version"

instance FromJSON Person where
  parseJSON = withObject "Person" $ \v -> Person <$> v .: "name" <*> v .: "age"

instance (ToJSON a) => ToJSON (Record a) where
  toJSON (Record id value version) = object ["id" .= id, "value" .= value, "version" .= version]

instance ToJSON Person where
  toJSON (Person name age) = object ["name" .= name, "age" .= age]
