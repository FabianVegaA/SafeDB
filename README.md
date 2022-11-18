# SafeDB

This is a toy inmutable database. It is a simple key-value store.

> **Note:** This is a toy project. It is response to the challenge [InfinitaRecursión](https://newsletter.andros.dev) 15 and later challenge.

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
  get 1
  update 1 $
    object
      [ "name" .= ("John" :: Text),
        "age" .= (31 :: Int)
      ]
  get 1
  done
```

You will get

```bash
$ stack run
stack run
Starting DB with custom connection (test.fiabledb)
DB file not found
You want to create a new DB? (y/n)
y
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
Records found: [
    {
        "id": 2,
        "value": 2,
        "version": {
            "age": 31,
            "name": "John"
        }
    },
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
Closing DB connection...
```
