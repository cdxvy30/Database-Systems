# Build a PostgreSQL Extension
## Requirements
1. Let users can use `fuzzyjoin` to join joinable columns.
2. Let users can input two tables to join.
3. Create a repository including README.

## Prerequisites
1. Build PostgreSQL from source.
    - Fork [postgres](https://github.com/postgres/postgres)

## Building Infrastructure
- PostgreSQL installation provides a build infrastructure for extensions, called PGXS, so that simple extension modules can be built simply against an already installed server.
- PGXS is mainly intended for extensions that include C code, although it can be used for pure-SQL extensions too.
- Note that PGXS is not intended to be a universal build system framework that can be used to build any software interfacing to PostgreSQL; it simply automates common build rules for simple server extension modules. For more complicated packages, you might need to write your own build system.

- There are four basic file types that are required for building an extension:
    1. Makefile: Which uses PGXS PostgreSQL’s build infrastructure for extensions.
    2. Control File: Carries information about the extension.
    3. SQL File(s): If the extension has any SQL code, it may reside in form SQL files (optional)
    4. C Code: The shared object that we want to build (optional).

### Write a Makefile
- 

### Control file


## Test
###  Directly install and use `autofj` in Postgres
- Extremely slow

## References
1. [Extension Building Infrastructure](https://www.postgresql.org/docs/current/extend-pgxs.html)
2. [fuzzystrmatch Official Extension](https://github.com/postgres/postgres/tree/master/contrib/fuzzystrmatch)
3. []()