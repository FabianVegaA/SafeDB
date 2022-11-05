module Free (Free(..), liftF) where

data Free f r = Free (f (Free f r)) | Pure r

instance Functor f => Functor (Free f) where
  fmap f (Pure r) = Pure (f r)
  fmap f (Free x) = Free (fmap (fmap f) x)

instance (Functor f) => Applicative (Free f) where
  pure = return
  (Pure f) <*> x = fmap f x
  (Free f) <*> x = Free (fmap (<*> x) f)

instance (Functor f) => Monad (Free f) where
  return = Pure
  (Free x) >>= f = Free (fmap (>>= f) x)
  (Pure r) >>= f = f r

liftF :: (Functor f) => f r -> Free f r
liftF command = Free (fmap Pure command)
