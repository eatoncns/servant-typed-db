{-# LANGUAGE DataKinds       #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeOperators   #-}
module Lib
    ( app
    , initConnectionPool
    , startApp
    ) where

import Data.Aeson
import Data.Aeson.TH
import Data.Pool
import Data.Tuple.Curry
import Database.PostgreSQL.Typed
import DatabaseConnection
import Network.Wai
import Network.Wai.Handler.Warp
import Servant
import Control.Monad.IO.Class (liftIO)
import Data.Int (Int32)
import GHC.Generics (Generic)

data User = User
  { userId        :: Int32
  , userFirstName :: String
  , userLastName  :: String
  } deriving (Eq, Show, Generic)

instance ToJSON User

type API = "users" :> Get '[JSON] [User]

initConnectionPool :: PGDatabase -> IO (Pool PGConnection)
initConnectionPool db = createPool (pgConnect db)
                                pgDisconnect
                                1   -- stripes
                                60  -- keep unused connections open for a minute
                                10  -- max. 10 connections per stripe

startApp :: String -> IO ()
startApp dbURI = do
  connectionPool <- initConnectionPool $ parseDbURI dbURI
  run 8080 $ app connectionPool

app :: Pool PGConnection -> Application
app connectionPool = serve api $ server connectionPool

api :: Proxy API
api = Proxy

server :: Pool PGConnection -> Server API
server conns = liftIO $ withResource conns loadUsers

loadUsers :: PGConnection -> IO[User]
loadUsers conn = do
  rows <- pgQuery conn [pgSQL|SELECT id, first_name, last_name FROM users|]
  return (map (uncurryN User) rows)
