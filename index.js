const http = require('http')
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const { Sequelize } = require('sequelize');
const userController = require('./controllers/userController'); // Updated path
const sequelize = require('./util/database'); // Import the Sequelize instance
const path = require('path'); // Add this line



const app = express();
app.use(bodyParser.json());


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


  // Use routes
app.use('/api/users', userController);



const PORT = 3001
app.listen(PORT)
console.log(`Server running on port ${PORT}`)