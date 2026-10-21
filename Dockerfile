FROM node:22.23.1-bookworm-slim
ENV NODE_ENV=production HOST=0.0.0.0 PORT=8000 DATABASE_PATH=/app/data/store.sqlite
WORKDIR /app
COPY --chown=node:node package.json ./
COPY --chown=node:node server ./server
COPY --chown=node:node dist ./dist
RUN mkdir -p /app/data && chown node:node /app/data
USER node
EXPOSE 8000
CMD ["node", "server/index.mjs"]
