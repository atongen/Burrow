#!/usr/bin/env bash
#
# write_config.sh
#
# Pulls data from env and writes burrow configuration at runtime.

OUT="$1"

if [ -z "$OUT" ]; then
  >&2 echo "outfile argument is required."
  exit 1
fi

if [ -z "$ZOOKEEPER_HOSTS" ]; then
  >&2 echo "ZOOKEEPER_HOSTS is required."
  exit 1
fi

if [ -z "$KAFKA_CLUSTER" ]; then
  >&2 echo "KAFKA_CLUSTER is required."
  exit 1
fi

if [ -z "$KAFKA_HOSTS" ]; then
  >&2 echo "KAFKA_HOSTS is required."
  exit 1
fi

if [ -z "$ZOOKEEPER_PORT" ]; then
  ZOOKEEPER_PORT=2181
fi

if [ -z "$KAFKA_PORT" ]; then
  KAFKA_PORT=9092
fi

if [ -z "$OFFSETS_TOPIC" ]; then
  OFFSETS_TOPIC="__consumer_offsets"
fi

if [ -z "$HTTP_PORT" ]; then
  HTTP_PORT=9000
fi

IFS=',' read -r -a ZK <<< $ZOOKEEPER_HOSTS
IFS=',' read -r -a KH <<< $KAFKA_HOSTS

echo "[general]" > $OUT
echo "logconfig=/etc/burrow/logging.cfg" >> $OUT
printf "group-blacklist=^(console-consumer-|python-kafka-consumer-).*$\n\n" >> $OUT

echo "[zookeeper]" >> $OUT
for i in "${ZK[@]}"; do
  echo "hostname=${i}" >> $OUT
done
echo "port=${ZOOKEEPER_PORT}" >> $OUT
echo "timeout=6" >> $OUT
printf "lock-path=/burrow/notifier\n\n" >> $OUT

echo "[kafka \"$KAFKA_CLUSTER\"]" >> $OUT
for i in "${KH[@]}"; do
  echo "broker=${i}" >> $OUT
done
echo "broker-port=$KAFKA_PORT" >> $OUT
for i in "${ZK[@]}"; do
  echo "zookeeper=${i}" >> $OUT
done
echo "zookeeper-port=${ZOOKEEPER_PORT}" >> $OUT
echo "zookeeper-path=/${KAFKA_CLUSTER}" >> $OUT
echo "zookeeper-offsets=true" >> $OUT
printf "offsets-topic=${OFFSETS_TOPIC}\n\n" >> $OUT

echo "[tickers]" >> $OUT
printf "broker-offsets=60\n\n" >> $OUT

echo "[lagcheck]" >> $OUT
echo "intervals=10" >> $OUT
printf "expire-group=604800\n\n" >> $OUT

echo "[httpserver]" >> $OUT
echo "server=on" >> $OUT
echo "port=${HTTP_PORT}" >> $OUT
