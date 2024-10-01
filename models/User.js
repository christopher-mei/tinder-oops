const { Sequelize, DataTypes } = require('sequelize');
const sequelize = require('../util/database');

const User = sequelize.define('User', {
  id: {
    type: DataTypes.UUID,
    defaultValue: Sequelize.UUIDV4,
    primaryKey: true,
  },
  name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  email: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true,
  },
  password: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  bio: {
    type: DataTypes.TEXT, // Using TEXT for potentially longer bio content
    allowNull: true, // Bio is optional
  },
  age: {
    type: DataTypes.INTEGER,
    allowNull: true, // Age is optional
  },
  location: {
    type: DataTypes.STRING,
    allowNull: true,
  },
});

module.exports = User;