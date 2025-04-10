#!/bin/bash
set -e

mkdir -p /data
[ -f /data/eula.txt ] || echo "eula=true" > /data/eula.txt
ln -sf /data/eula.txt /minecraft/eula.txt
ln -sf /data/server.properties /minecraft/server.properties 2>/dev/null || true

cd /data
exec java $GC_OPTS -Xms$MEMORY -Xmx$MEMORY -jar /minecraft/server.jar nogui
