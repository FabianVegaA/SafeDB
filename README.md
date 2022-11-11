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
main = runDB $ do
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
  get 2
  done
```

You will get

```bash
$ stack run
Starting DB with default connection (test.fiabledb)
Records found: [
    {
        "id": 1,
        "value": 1,
        "version": {
            "age": 30,
            "name": "John"
        }
    }
]
Records found: [
    {
        "id": 2,
        "value": 1,
        "version": {
            "address": "123 Main St",
            "age": 25,
            "name": "Jane"
        }
    }
]
Closing DB connection
```
