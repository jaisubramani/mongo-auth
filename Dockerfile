FROM mongo:3.2
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
