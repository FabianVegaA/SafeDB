# SafeDB

This is a toy inmutable database. It is a simple key-value store.

> **Note:** This is a toy project. It is response to the challenge [InfinitaRecursión](https://newsletter.andros.dev) number 15.

## Ideas

- [x] Use a Free Monad to model the database
- [ ] Add a Console interpreter
- [ ] Optimize requests

## How to run

```bash
$ stack run
```

With the program

```Haskell
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
```

You will get

```bash
$ stack run
Starting DB with default connection (test.fiabledb)
Records: [Record {identifier = 1, value = Person {name = "John", age = 30}, version = 1}]
SafeDB-exe: user error (KeyNotFound)
```
