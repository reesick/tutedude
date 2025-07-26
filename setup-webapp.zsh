#!/bin/zsh

echo "📦 Creating root project folder..."
mkdir web-app
cd web-app

echo "🎨 Setting up frontend (React + Vite + Tailwind + TS)..."
npm create vite@latest client -- --template react-ts
cd client

echo "📁 Installing frontend dependencies..."
npm install
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p

echo "🔧 Configuring Tailwind..."
cat <<EOF > tailwind.config.js
module.exports = {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
EOF

cat <<EOF > src/index.css
@tailwind base;
@tailwind components;
@tailwind utilities;
EOF

echo "✅ Frontend setup done."
cd ..

echo "🛠️ Setting up backend (Node + Express + Mongoose + Socket.IO)..."
mkdir server
cd server
npm init -y

echo "📁 Installing backend dependencies..."
npm install express mongoose cors dotenv socket.io jsonwebtoken bcryptjs multer cloudinary
npm install -D nodemon

echo "📁 Creating server folders..."
mkdir routes controllers models middleware utils

echo "📄 Creating basic server.js..."
cat <<EOF > server.js
const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const { createServer } = require('http');
const { Server } = require('socket.io');

dotenv.config();
const app = express();
const httpServer = createServer(app);
const io = new Server(httpServer, {
  cors: {
    origin: "*"
  }
});

app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 5000;
mongoose.connect(process.env.MONGO_URI)
  .then(() => {
    httpServer.listen(PORT, () => console.log(\`🚀 Server running on port \${PORT}\`));
  })
  .catch(err => console.error("❌ DB Error:", err));

io.on('connection', socket => {
  console.log("🔌 New socket connection:", socket.id);
  socket.on('disconnect', () => {
    console.log("🔌 Socket disconnected:", socket.id);
  });
});
EOF

echo "📄 Creating basic .env file..."
cat <<EOF > .env
PORT=5000
MONGO_URI=your_mongodb_connection_string
JWT_SECRET=your_jwt_secret
EOF

echo "📄 Adding start scripts to package.json..."
npx json -I -f package.json -e 'this.scripts={
  "dev": "nodemon server.js",
  "start": "node server.js"
}'

cd ..

echo "✅ Backend setup done."

echo "📦 Initial project structure:"
tree -L 2

echo "✅ All done! To start:"
echo "Frontend: cd web-app/client && npm run dev"
echo "Backend : cd web-app/server && npm run dev"
