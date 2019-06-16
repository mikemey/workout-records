#!/usr/bin/env bash

if [[ ! ${WR_SERVER_STATIC_DIR} ]]; then
    echo "Environment variable '\$WR_SERVER_STATIC_DIR' not set!"
    exit
  fi

echo "cleaning static-asset directory $WR_SERVER_STATIC_DIR"
rm -rf $WR_SERVER_STATIC_DIR/*

echo "copying static assets..."
cp -r static/img $WR_SERVER_STATIC_DIR
cp -r static/template $WR_SERVER_STATIC_DIR
cp -r static/vendor $WR_SERVER_STATIC_DIR
