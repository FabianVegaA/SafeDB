module Main (main) where

import Free (Free (..))
import Interpret (runDB)
import Lib (Operation (..), done, initDB, set, showDB)
import Record (Person (..))

main :: IO ()
main = runDB program

program :: Free (Operation Int Person) ()
program = do
  initDB
  set 1 $ Person "John" 30
  showDB 1
  set 1 $ Person "John" 31
  showDB 10
  done
