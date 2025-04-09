FROM openjdk:17-jdk-slim

WORKDIR /minecraft

RUN apt-get update && apt-get install -y curl jq && \
    VERSION_JSON=$(curl -s https://launchermeta.mojang.com/mc/game/version_manifest.json) && \
    LATEST_VERSION=$(echo $VERSION_JSON | jq -r '.latest.release') && \
    VERSION_URL=$(echo $VERSION_JSON | jq -r --arg v "$LATEST_VERSION" '.versions[] | select(.id == $v) | .url') && \
    DOWNLOAD_URL=$(curl -s $VERSION_URL | jq -r '.downloads.server.url') && \
    curl -o server.jar $DOWNLOAD_URL && \
    echo "eula=true" > /data/eula.txt

VOLUME /data

ENV MEMORY="4G"
ENV GC_OPTS="-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=50 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch"

EXPOSE 25565

CMD ln -sf /data/eula.txt /minecraft/eula.txt && \
    ln -sf /data/server.properties /minecraft/server.properties 2>/dev/null || true && \
    java $GC_OPTS -Xms$MEMORY -Xmx$MEMORY -jar server.jar nogui --world-dir /data
