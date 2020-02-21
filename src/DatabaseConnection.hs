module DatabaseConnection where

import Data.ByteString.UTF8 as BSU
import Database.PostgreSQL.Typed

database :: PGDatabase
database = defaultPGDatabase{pgDBName = BSU.fromString "servant"}

