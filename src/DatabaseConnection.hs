module DatabaseConnection where

import Data.ByteString.UTF8 as BSU
import Database.PostgreSQL.Typed
import Network.URI

database :: PGDatabase
database = defaultPGDatabase{pgDBName = BSU.fromString "servant"}

parseDbURI :: String -> (String, String)
parseDbURI uri = case parseURI uri of
  Nothing -> error "invalid URI"
  Just uri -> case uriAuthority uri of
    Nothing -> error "no authority"
    Just auth -> (uriRegName auth, tail $ uriPort auth)
