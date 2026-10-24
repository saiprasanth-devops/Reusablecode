#!/bin/bash

service=cart
inputservicefilename=cartservicefile


source ./commonmethods.sh

startingstep
nodejs_setup "$service" "$inputservicefilename"