#!/usr/bin/env bash

/usr/local/bin/write_config.sh /etc/burrow/burrow.cfg
if [ $? -ne 0 ]; then
  echo "Unable to write burrow configuration"
  exit 1
fi

/go/bin/burrow --config /etc/burrow/burrow.cfg
