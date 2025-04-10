FROM eclipse-temurin:21-jdk-jammy

WORKDIR /minecraft

RUN apt-get update && apt-get install -y curl jq && \
    mkdir -p /data && \
    bash -c '\
      VERSION_JSON=$(curl -s https://launchermeta.mojang.com/mc/game/version_manifest.json) && \
      LATEST_VERSION=$(echo $VERSION_JSON | jq -r ".latest.release") && \
      VERSION_URL=$(echo $VERSION_JSON | jq -r --arg v "$LATEST_VERSION" ".versions[] | select(.id == \$v) | .url") && \
      DOWNLOAD_URL=$(curl -s $VERSION_URL | jq -r ".downloads.server.url") && \
      curl -o server.jar $DOWNLOAD_URL && \
      echo "eula=true" > /data/eula.txt \
    '

COPY start.sh /start.sh
RUN chmod +x /start.sh

ENV MEMORY="4G"
ENV GC_OPTS="-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=50 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch"

EXPOSE 25565

CMD ["/start.sh"]
