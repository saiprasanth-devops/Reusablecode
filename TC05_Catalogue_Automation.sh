#!/bin/bash

service=catalogue
inputservicefilename=catalogueservicefile

source ./commonmethods.sh

startingstep
nodejs_setup "$service" "$inputservicefilename"


