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
  done
```

You will get

```bash
$ stack run
Starting DB with test.fiabledb connection
DB file not found
You want to create a new DB? (y/n)
y
Records found: [
    {
        "id": 1,
        "value": {},
        "version": 3
    },
    {
        "id": 1,
        "value": {
            "address": {
                "number": 123,
                "street": "Siempre Viva"
            },
            "age": 30,
            "name": "Xavier",
            "phone": "987654321"
        },
        "version": 2
    },
    {
        "id": 1,
        "value": {
            "address": {
                "number": 123,
                "street": "Calle 1"
            },
            "age": 29,
            "name": "Xavier"
        },
        "version": 1
    }
]
Closing DB connection...
```
