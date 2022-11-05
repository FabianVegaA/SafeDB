module Lib
  ( initDB,
    get,
    set,
    done,
    showDB,
    Operation (..),
    OperationFail (..),
  )
where

import Free (Free (..), liftF)

data Operation key value next
  = Init next
  | Get key next
  | Set key value next
  | Show key next
  | Done

instance Functor (Operation key value) where
  fmap f (Init next) = Init (f next)
  fmap f (Get key next) = Get key (f next)
  fmap f (Set key value next) = Set key value (f next)
  fmap f (Show key next) = Show key (f next)
  fmap _ Done = Done

data OperationFail
  = KeyNotFound
  | RecordNotConsistent
  deriving (Show)

initDB :: Free (Operation key value) ()
initDB = liftF (Init ())

get :: key -> Free (Operation key value) ()
get key = liftF (Get key ())

set :: key -> value -> Free (Operation key value) ()
set key value = liftF (Set key value ())

showDB :: key -> Free (Operation key value) ()
showDB key = liftF (Show key ())

done :: Free (Operation key value) r
done = liftF Done
