#!/bin/usr/env bash

mkdir -p src/
rm -rf src/my-project
node --version
cd src/

sl scaffold my-project \
    --integrateWithBackstage \
    --issuePrefix=auto \
    --owner=auto \
    --description=hello

cd my-project

sl microservice auth-service  --uniquePrefix=auto --baseOnService --datasourceName=pg --datasourceType=postgres --baseService=authentication-service --includeMigrations --sequelize --facade 