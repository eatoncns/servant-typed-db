module DatabaseConnection (database, parseDbURI) where

import Data.ByteString.UTF8 as BSU
import Database.PostgreSQL.Typed
import Network.Socket
import Network.URI

database :: PGDatabase
database = defaultPGDatabase{pgDBName = BSU.fromString "servant"}

parseDbURI :: String -> PGDatabase
parseDbURI uri = case parseURI uri of
  Nothing -> error "invalid URI"
  Just uri -> case uriAuthority uri of
    Nothing -> error "no authority"
    Just auth -> defaultPGDatabase {
        pgDBAddr = Left (hostFrom auth, portFrom auth)
      , pgDBName = BSU.fromString (dbNameFrom uri)
      , pgDBUser = BSU.fromString (userFrom auth)
    }

hostFrom :: URIAuth -> HostName
hostFrom = uriRegName

portFrom :: URIAuth -> ServiceName
portFrom = tail . uriPort  -- remove preceding :

dbNameFrom :: URI -> String
dbNameFrom = tail . uriPath  -- remove preceding /

userFrom :: URIAuth -> String
userFrom = init . uriUserInfo  -- remove trailing @
