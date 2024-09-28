
require('dotenv').config();
const http = require('http')
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const { Sequelize } = require('sequelize');
const userController = require('./controllers/userController'); // Updated path
const sequelize = require('./util/database'); // Import the Sequelize instance
const path = require('path'); // Add this line
const jwt = require('jsonwebtoken'); // Add this line


const app = express();
app.use(bodyParser.json());

const port = process.env.PORT || 3000; // Use the PORT environment variable or default to 3000

// middleware
app.use(express.json());
app.use(cors());

// Serve the landing page
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'index.html'));
});

// Initialize Sequelize
/*
const sequelize = new Sequelize('database', 'username', 'password', {
  host: 'localhost',
  dialect: 'postgres',
});
*/
// Test the connection
sequelize
  .authenticate()
  .then(() => {
    console.log('Connection has been established successfully.');
  })
  .catch((error) => {
    console.error('Unable to connect to the database:', error);
  });

  // Sync models
sequelize.sync()
.then(() => console.log('Models synchronized...'))
.catch(err => console.log('Error: ' + err));

// JWT Authentication Middleware
function verifyToken(req, res, next) {
  const token = req.headers['authorization'];
  if (!token) {
    return res.status(403).send('A token is required for authentication');
  }
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
  } catch (err) {
    return res.status(401).send('Invalid Token');
  }
  return next();
}

  // Use routes
app.use('/api/users', userController);



app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});