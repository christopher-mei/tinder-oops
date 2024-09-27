const { Sequelize } = require('sequelize');

const sequelize = new Sequelize(
  process.env.DATABASE_URL,
  {
    host: process.env.DATABASE_HOST,
    port: process.env.DATABASE_PORT || 5432, // Default to 5432 if DATABASE_PORT is not set
    dialect: 'postgres',
    protocol: 'postgres',
  }
);

sequelize
  .authenticate()
  .then(() => {
    console.log('Connection has been established successfully.');
  })
  .catch((error) => {
    console.error('Unable to connect to the database:', error);
  });

module.exports = sequelize;