# chat_server

## Running the Application Locally

Run `aqueduct serve` from this directory to run the application. For running within an IDE, run `bin/main.dart`. By default, a configuration file named `config.yaml` will be used.

To generate a SwaggerUI client, run `aqueduct document client`.

## Running Application Tests

To run all tests for this application, run the following in this directory:

```
pub run test
```

The default configuration file used when testing is `config.src.yaml`. This file should be checked into version control. It also the template for configuration files used in deployment.

## Deploying an Application

See the documentation for [Deployment](https://aqueduct.io/docs/deploy/).

docker-compose up -d

To generate database migration file:
pub run aqueduct db generate 

To synchronize the database version:
pub run aqueduct db upgrade --connect postgres://admin:password@database:5432/database_chat

Add OAuth2 client to database:
pub run aqueduct auth add-client --id com.1997ckf.chat_server --secret myspecialsecret --connect postgres://admin:password@database:5432/database_chat