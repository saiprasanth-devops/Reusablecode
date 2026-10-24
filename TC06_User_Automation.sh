#!/bin/bash

service=user
inputservicefilename=userservicefile


source ./commonmethods.sh

startingstep
nodejs_setup "$service" "$inputservicefilename"