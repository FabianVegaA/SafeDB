module Lib
  ( initDB,
    get,
    insert,
    done,
    Operation (..),
    OperationFail (..),
    DBOperation,
  )
where

import Free (Free (..), liftF)

data Operation key value next
  = Init next
  | Get key next
  | Insert value next
  | Done

instance Functor (Operation key value) where
  fmap f (Init next) = Init (f next)
  fmap f (Get key next) = Get key (f next)
  fmap f (Insert value next) = Insert value (f next)
  fmap _ Done = Done

data OperationFail
  = KeyNotFound
  | RecordNotConsistent
  | DBConnectionError
  deriving (Show)

initDB :: Free (Operation key value) ()
initDB = liftF (Init ())

get :: key -> Free (Operation key value) ()
get key = liftF (Get key ())

insert :: value -> Free (Operation key value) ()
insert value = liftF (Insert value ())

done :: Free (Operation key value) ()
done = liftF Done

type DBOperation value = Free (Operation Int value)