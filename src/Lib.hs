module Lib
  ( initDB,
    get,
    getOne,
    insert,
    update,
    delete,
    done,
    Operation (..),
    OperationFail (..),
    DBOperation,
  )
where

import Control.Exception (Exception)
import Free (Free (..), liftF)

data Operation key value next
  = Init next
  | Get key next
  | GetOne key next
  | Insert value next
  | Update key value next
  | Delete key next
  | Done

instance Functor (Operation key value) where
  fmap f (Init next) = Init (f next)
  fmap f (Get key next) = Get key (f next)
  fmap f (GetOne key next) = GetOne key (f next)
  fmap f (Insert value next) = Insert value (f next)
  fmap f (Update key value next) = Update key value (f next)
  fmap f (Delete key next) = Delete key (f next)
  fmap _ Done = Done

data OperationFail
  = KeyNotFound
  | RecordNotConsistent
  | DBConnectionError
  | CorruptedDB String
  | AlreadyDeleted Int
  deriving (Show)

instance Exception OperationFail

initDB :: Free (Operation key value) ()
initDB = liftF (Init ())

get :: key -> Free (Operation key value) ()
get key = liftF (Get key ())

getOne :: key -> Free (Operation key value) ()
getOne key = liftF (GetOne key ())

insert :: value -> Free (Operation key value) ()
insert value = liftF (Insert value ())

update :: key -> value -> Free (Operation key value) ()
update key value = liftF (Update key value ())

delete :: key -> Free (Operation key value) ()
delete key = liftF (Delete key ())

done :: Free (Operation key value) ()
done = liftF Done

type DBOperation value = Free (Operation Int value)