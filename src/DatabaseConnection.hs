module DatabaseConnection (parseDbURI) where

import Data.ByteString.UTF8 as BSU
import Data.List.Split
import Database.PostgreSQL.Typed
import Network.Socket
import Network.URI

-- db uri of form postgres://user:password@host/dbname
parseDbURI :: String -> PGDatabase
parseDbURI uri = case parseURI uri of
  Nothing -> error "invalid URI"
  Just uri -> case uriAuthority uri of
    Nothing -> error "no authority"
    Just auth -> defaultPGDatabase {
        pgDBAddr = Left (hostFrom auth, portFrom auth)
      , pgDBName = BSU.fromString (dbNameFrom uri)
      , pgDBUser = BSU.fromString (userFrom auth)
      , pgDBPass = BSU.fromString (passwordFrom auth)
    }

hostFrom :: URIAuth -> HostName
hostFrom = uriRegName

portFrom :: URIAuth -> ServiceName
portFrom = tail . uriPort  -- remove preceding :

dbNameFrom :: URI -> String
dbNameFrom = tail . uriPath  -- remove preceding /

userFrom :: URIAuth -> String
userFrom = firstElementOf . userInfo

passwordFrom :: URIAuth -> String
passwordFrom = secondElementIfExists . userInfo

userInfo :: URIAuth -> [String]
userInfo = splitOn ":" . init . uriUserInfo  -- remove trailing @


firstElementOf :: [String] -> String
firstElementOf (x:xs) = x
firstElementOf [] = ""

secondElementIfExists :: [String] -> String
secondElementIfExists (x:y:ys) = y
secondElementIfExists (x:[]) = ""
secondElementIfExists [] = ""
