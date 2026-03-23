# Use a lightweight node image
FROM node:18-bookworm-slim

# Set working directory
WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Copy the rest of the code
COPY . .

# Build the app (Assuming it's a React app)
RUN npm run build --if-present

EXPOSE 3000
CMD ["npm", "start"]
