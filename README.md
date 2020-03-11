# typed-db

A minimal example of constructing a JSON api in haskell using [servant](https://www.servant.dev/) and
[postgresql-typed](https://hackage.haskell.org/package/postgresql-typed). The api serves a single endpoint at `/users`.

Database migrations are configured using [sqitch](https://sqitch.org/).

Example test makes use of [pg_tmp](http://eradman.com/ephemeralpg/) to spin up a temp db for test.

### Pre-requisites

Initial setup is a little manual at this point. The following need to be installed prior to dev work:

- [Haskell stack](https://docs.haskellstack.org/en/stable/README/)
- Running postgresql instance with db named `servant`
- [sqitch](https://sqitch.org/)

Assuming that postgres is running at default port the following command will migrate db:

`sqitch deploy`

### Running

`stack run` - to run server

`stack build` - to compile server

`stack test` - run tests
