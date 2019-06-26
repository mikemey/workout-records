#!/usr/bin/env bash

mongoimport --drop --db=workout-records --collection=cgmsgs --jsonArray upload-congrats-messages.json