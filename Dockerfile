FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json /app/
RUN npm install
COPY . /app/
EXPOSE 3000    
CMD ["npm", "start"]