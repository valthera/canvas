# Use Node.js 20 as base
FROM node:20

WORKDIR /app

COPY . .

EXPOSE 3000 54367

RUN chmod +x /app/start.sh

CMD ["/app/start.sh"]
