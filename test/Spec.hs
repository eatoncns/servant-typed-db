{-# LANGUAGE OverloadedStrings #-}
module Main (main) where

import Lib (app, initConnectionPool)
import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON
import System.Process
import Database.PostgreSQL.Typed
import Data.Pool
import DatabaseConnection
import Servant

main :: IO ()
main = do
  dbURI <- readProcess "pg_tmp" ["-t", "-w", "5"] []
  let (host, port) = parseDbURI dbURI
  db_pool <- initConnectionPool defaultPGDatabase{pgDBAddr = Left (host, port)}
  hspec (spec $ app db_pool)

spec :: Application -> Spec
spec app =
  with (return app) $
  describe "GET /users" $ do
    it "responds with 200" $ get "/users" `shouldRespondWith` 200
    it "responds with [User]" $ do
      let users =
            "[{\"userId\":1,\"userFirstName\":\"Isaac\",\"userLastName\":\"Newton\"},{\"userId\":2,\"userFirstName\":\"Albert\",\"userLastName\":\"Einstein\"}]"
      get "/users" `shouldRespondWith` users
