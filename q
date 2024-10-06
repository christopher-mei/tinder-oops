warning: LF will be replaced by CRLF in migrations/20241001195815-create-user.js.
The file will have its original line endings in your working directory
[1mdiff --git a/controllers/userController.js b/controllers/userController.js[m
[1mindex f6a3c5a..0f0506f 100644[m
[1m--- a/controllers/userController.js[m
[1m+++ b/controllers/userController.js[m
[36m@@ -1,7 +1,8 @@[m
 const express = require('express');[m
 const bcrypt = require('bcryptjs');[m
 const jwt = require('jsonwebtoken');[m
[31m-const User = require('../models/User');[m
[32m+[m[32mconst { User } = require('../models');[m
[32m+[m[32mconst upload = require('../middleware/upload'); // Import the upload middleware[m
 [m
 const userRouter = express.Router();[m
 const JWT_SECRET = process.env.JWT_SECRET;[m
[36m@@ -67,8 +68,9 @@[m [muserRouter.get('/profile', authenticate, async (req, res) => {[m
 });[m
 [m
 // User update route (protected)[m
[31m-userRouter.put('/update', authenticate, async (req, res) => {[m
[31m-  const { name, email, bio, age, photo, location } = req.body;[m
[32m+[m[32muserRouter.put('/update', authenticate, upload.single('image'), async (req, res) => {[m
[32m+[m[32m  const { name, email, bio, age, location } = req.body;[m
[32m+[m[32m  const image = req.file ? req.file.path : null;[m
   try {[m
     const user = await User.findByPk(req.user.userId);[m
     if (!user) {[m
[36m@@ -80,8 +82,8 @@[m [muserRouter.put('/update', authenticate, async (req, res) => {[m
     user.email = email || user.email;[m
     user.bio = bio || user.bio;[m
     user.age = age || user.age;[m
[31m-    user.photo = photo || user.photo;[m
     user.location = location || user.location;[m
[32m+[m[32m    user.image = image || user.image;[m
 [m
     // Save the updated user[m
     await user.save();[m
[1mdiff --git a/middleware/upload.js b/middleware/upload.js[m
[1mnew file mode 100644[m
[1mindex 0000000..cfd7fc9[m
[1m--- /dev/null[m
[1m+++ b/middleware/upload.js[m
[36m@@ -0,0 +1,40 @@[m
[32m+[m[32mconst multer = require('multer');[m
[32m+[m[32mconst path = require('path');[m
[32m+[m[32mconst fs = require('fs');[m
[32m+[m
[32m+[m[32m// Ensure the upload directory exists[m
[32m+[m[32mconst uploadDir = 'uploads/';[m
[32m+[m[32mif (!fs.existsSync(uploadDir)) {[m
[32m+[m[32m  fs.mkdirSync(uploadDir, { recursive: true });[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m// Configure storage for uploaded files[m
[32m+[m[32mconst storage = multer.diskStorage({[m
[32m+[m[32m  destination: (req, file, cb) => {[m
[32m+[m[32m    cb(null, uploadDir); // Directory to save uploaded files[m
[32m+[m[32m  },[m
[32m+[m[32m  filename: (req, file, cb) => {[m
[32m+[m[32m    cb(null, `${Date.now()}-${file.originalname}`);[m
[32m+[m[32m  },[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32m// File filter to accept only images[m
[32m+[m[32mconst fileFilter = (req, file, cb) => {[m
[32m+[m[32m  const allowedTypes = /jpeg|jpg|png|gif/;[m
[32m+[m[32m  const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());[m
[32m+[m[32m  const mimetype = allowedTypes.test(file.mimetype);[m
[32m+[m
[32m+[m[32m  if (extname && mimetype) {[m
[32m+[m[32m    return cb(null, true);[m
[32m+[m[32m  } else {[m
[32m+[m[32m    cb(new Error('Error: Images Only!'));[m
[32m+[m[32m  }[m
[32m+[m[32m};[m
[32m+[m
[32m+[m[32mconst upload = multer({[m
[32m+[m[32m  storage,[m
[32m+[m[32m  fileFilter,[m
[32m+[m[32m  limits: { fileSize: 1024 * 1024 * 5 }, // Limit file size to 5MB[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mmodule.exports = upload;[m
\ No newline at end of file[m
[1mdiff --git a/migrations/20241001195815-create-user.js b/migrations/20241001195815-create-user.js[m
[1mindex b6e01de..ab5ddbb 100644[m
[1m--- a/migrations/20241001195815-create-user.js[m
[1m+++ b/migrations/20241001195815-create-user.js[m
[36m@@ -1,22 +1,52 @@[m
[31m-'use strict';[m
[31m-[m
[31m-/** @type {import('sequelize-cli').Migration} */[m
[32m+[m[32m// migrations/XXXXXX-create-user.js[m
 module.exports = {[m
[31m-  async up (queryInterface, Sequelize) {[m
[31m-    /**[m
[31m-     * Add altering commands here.[m
[31m-     *[m
[31m-     * Example:[m
[31m-     * await queryInterface.createTable('users', { id: Sequelize.INTEGER });[m
[31m-     */[m
[32m+[m[32m  up: async (queryInterface, Sequelize) => {[m
[32m+[m[32m    await queryInterface.createTable('Users', {[m
[32m+[m[32m      id: {[m
[32m+[m[32m        allowNull: false,[m
[32m+[m[32m        autoIncrement: true,[m
[32m+[m[32m        primaryKey: true,[m
[32m+[m[32m        type: Sequelize.INTEGER[m
[32m+[m[32m      },[m
[32m+[m[32m      username: {[m
[32m+[m[32m        type: Sequelize.STRING,[m
[32m+[m[32m        allowNull: false[m
[32m+[m[32m      },[m
[32m+[m[32m      email: {[m
[32m+[m[32m        type: Sequelize.STRING,[m
[32m+[m[32m        allowNull: false,[m
[32m+[m[32m        unique: true[m
[32m+[m[32m      },[m
[32m+[m[32m      password: {[m
[32m+[m[32m        type: Sequelize.STRING,[m
[32m+[m[32m        allowNull: false[m
[32m+[m[32m      },[m
[32m+[m[32m      bio: {[m
[32m+[m[32m        type: Sequelize.TEXT,[m
[32m+[m[32m        allowNull: true[m
[32m+[m[32m      },[m
[32m+[m[32m      age: {[m
[32m+[m[32m        type: Sequelize.INTEGER,[m
[32m+[m[32m        allowNull: true[m
[32m+[m[32m      },[m
[32m+[m[32m      location: {[m
[32m+[m[32m        type: Sequelize.STRING,[m
[32m+[m[32m        allowNull: true[m
[32m+[m[32m      },[m
[32m+[m[32m      createdAt: {[m
[32m+[m[32m        allowNull: false,[m
[32m+[m[32m        type: Sequelize.DATE,[m
[32m+[m[32m        defaultValue: Sequelize.NOW[m
[32m+[m[32m      },[m
[32m+[m[32m      updatedAt: {[m
[32m+[m[32m        allowNull: false,[m
[32m+[m[32m        type: Sequelize.DATE,[m
[32m+[m[32m        defaultValue: Sequelize.NOW[m
[32m+[m[32m      }[m
[32m+[m[32m    });[m
   },[m
 [m
[31m-  async down (queryInterface, Sequelize) {[m
[31m-    /**[m
[31m-     * Add reverting commands here.[m
[31m-     *[m
[31m-     * Example:[m
[31m-     * await queryInterface.dropTable('users');[m
[31m-     */[m
[32m+[m[32m  down: async (queryInterface, Sequelize) => {[m
[32m+[m[32m    await queryInterface.dropTable('Users');[m
   }[m
 };[m
[1mdiff --git a/migrations/20241004161006-add-image-to-users.js b/migrations/20241004161006-add-image-to-users.js[m
[1mnew file mode 100644[m
[1mindex 0000000..b125a9e[m
[1m--- /dev/null[m
[1m+++ b/migrations/20241004161006-add-image-to-users.js[m
[36m@@ -0,0 +1,13 @@[m
[32m+[m[32m'use strict';[m
[32m+[m
[32m+[m[32mmodule.exports = {[m
[32m+[m[32m  up: async (queryInterface, Sequelize) => {[m
[32m+[m[32m    await queryInterface.addColumn('Users', 'image', {[m
[32m+[m[32m      type: Sequelize.STRING,[m
[32m+[m[32m      allowNull: true,[m
[32m+[m[32m    });[m
[32m+[m[32m  },[m
[32m+[m[32m  down: async (queryInterface, Sequelize) => {[m
[32m+[m[32m    await queryInterface.removeColumn('Users', 'image');[m
[32m+[m[32m  },[m
[32m+[m[32m};[m
\ No newline at end of file[m
[1mdiff --git a/models/User.js b/models/User.js[m
[1mindex bc47d4b..2748734 100644[m
[1m--- a/models/User.js[m
[1m+++ b/models/User.js[m
[36m@@ -1,3 +1,4 @@[m
[32m+[m[32m// models/User.js[m
 const { Sequelize, DataTypes } = require('sequelize');[m
 const sequelize = require('../util/database');[m
 [m
[36m@@ -21,17 +22,21 @@[m [mconst User = sequelize.define('User', {[m
     allowNull: false,[m
   },[m
   bio: {[m
[31m-    type: DataTypes.TEXT, // Using TEXT for potentially longer bio content[m
[31m-    allowNull: true, // Bio is optional[m
[32m+[m[32m    type: DataTypes.TEXT,[m
[32m+[m[32m    allowNull: true,[m
   },[m
   age: {[m
     type: DataTypes.INTEGER,[m
[31m-    allowNull: true, // Age is optional[m
[32m+[m[32m    allowNull: true,[m
   },[m
   location: {[m
     type: DataTypes.STRING,[m
     allowNull: true,[m
   },[m
[32m+[m[32m  image: {[m
[32m+[m[32m    type: DataTypes.STRING,[m
[32m+[m[32m    allowNull: true,[m
[32m+[m[32m  },[m
 });[m
 [m
 module.exports = User;[m
\ No newline at end of file[m
[1mdiff --git a/models/index.js b/models/index.js[m
[1mindex 254818e..9d336bc 100644[m
[1m--- a/models/index.js[m
[1m+++ b/models/index.js[m
[36m@@ -31,7 +31,7 @@[m [mObject.keys(db).forEach(modelName => {[m
   }[m
 });[m
 [m
[31m-db.sequelize = sequelize;[m
[32m+[m[32mdb.sequelize = sequelize; // Sequelize instance[m
[32m+[m[32mdb.Sequelize = Sequelize; // Sequelize library[m
 [m
[31m-[m
[31m-module.exports = db;[m
[32m+[m[32mmodule.exports = db;[m
\ No newline at end of file[m
[1mdiff --git a/node_modules/.bin/mkdirp b/node_modules/.bin/mkdirp[m
[1mnew file mode 100644[m
[1mindex 0000000..1ab9c81[m
[1m--- /dev/null[m
[1m+++ b/node_modules/.bin/mkdirp[m
[36m@@ -0,0 +1,16 @@[m
[32m+[m[32m#!/bin/sh[m
[32m+[m[32mbasedir=$(dirname "$(echo "$0" | sed -e 's,\\,/,g')")[m
[32m+[m
[32m+[m[32mcase `uname` in[m
[32m+[m[32m    *CYGWIN*|*MINGW*|*MSYS*)[m
[32m+[m[32m        if command -v cygpath > /dev/null 2>&1; then[m
[32m+[m[32m            basedir=`cygpath -w "$basedir"`[m
[32m+[m[32m        fi[m
[32m+[m[32m    ;;[m
[32m+[m[32mesac[m
[32m+[m
[32m+[m[32mif [ -x "$basedir/node" ]; then[m
[32m+[m[32m  exec "$basedir/node"  "$basedir/../mkdirp/bin/cmd.js" "$@"[m
[32m+[m[32melse[m[41m [m
[32m+[m[32m  exec node  "$basedir/../mkdirp/bin/cmd.js" "$@"[m
[32m+[m[32mfi[m
[1mdiff --git a/node_modules/.bin/mkdirp.cmd b/node_modules/.bin/mkdirp.cmd[m
[1mnew file mode 100644[m
[1mindex 0000000..a865dd9[m
[1m--- /dev/null[m
[1m+++ b/node_modules/.bin/mkdirp.cmd[m
[36m@@ -0,0 +1,17 @@[m
[32m+[m[32m@ECHO off[m
[32m+[m[32mGOTO start[m
[32m+[m[32m:find_dp0[m
[32m+[m[32mSET dp0=%~dp0[m
[32m+[m[32mEXIT /b[m
[32m+[m[32m:start[m
[32m+[m[32mSETLOCAL[m
[32m+[m[32mCALL :find_dp0[m
[32m+[m
[32m+[m[32mIF EXIST "%dp0%\node.exe" ([m
[32m+[m[32m  SET "_prog=%dp0%\node.exe"[m
[32m+[m[32m) ELSE ([m
[32m+[m[32m  SET "_prog=node"[m
[32m+[m[32m  SET PATHEXT=%PATHEXT:;.JS;=;%[m
[32m+[m[32m)[m
[32m+[m
[32m+[m[32mendLocal & goto #_undefined_# 2>NUL || title %COMSPEC% & "%_prog%"  "%dp0%\..\mkdirp\bin\cmd.js" %*[m
[1mdiff --git a/node_modules/.bin/mkdirp.ps1 b/node_modules/.bin/mkdirp.ps1[m
[1mnew file mode 100644[m
[1mindex 0000000..911e854[m
[1m--- /dev/null[m
[1m+++ b/node_modules/.bin/mkdirp.ps1[m
[36m@@ -0,0 +1,28 @@[m
[32m+[m[32m#!/usr/bin/env pwsh[m
[32m+[m[32m$basedir=Split-Path $MyInvocation.MyCommand.Definition -Parent[m
[32m+[m
[32m+[m[32m$exe=""[m
[32m+[m[32mif ($PSVersionTable.PSVersion -lt "6.0" -or $IsWindows) {[m
[32m+[m[32m  # Fix case when both the Windows and Linux builds of Node[m
[32m+[m[32m  # are installed in the same directory[m
[32m+[m[32m  $exe=".exe"[m
[32m+[m[32m}[m
[32m+[m[32m$ret=0[m
[32m+[m[32mif (Test-Path "$basedir/node$exe") {[m
[32m+[m[32m  # Support pipeline input[m
[32m+[m[32m  if ($MyInvocation.ExpectingInput) {[m
[32m+[m[32m    $input | & "$basedir/node$exe"  "$basedir/../mkdirp/bin/cmd.js" $args[m
[32m+[m[32m  } else {[m
[32m+[m[32m    & "$basedir/node$exe"  "$basedir/../mkdirp/bin/cmd.js" $args[m
[32m+[m[32m  }[m
[32m+[m[32m  $ret=$LASTEXITCODE[m
[32m+[m[32m} else {[m
[32m+[m[32m  # Support pipeline input[m
[32m+[m[32m  if ($MyInvocation.ExpectingInput) {[m
[32m+[m[32m    $input | & "node$exe"  "$basedir/../mkdirp/bin/cmd.js" $args[m
[32m+[m[32m  } else {[m
[32m+[m[32m    & "node$exe"  "$basedir/../mkdirp/bin/cmd.js" $args[m
[32m+[m[32m  }[m
[32m+[m[32m  $ret=$LASTEXITCODE[m
[32m+[m[32m}[m
[32m+[m[32mexit $ret[m
[1mdiff --git a/node_modules/.package-lock.json b/node_modules/.package-lock.json[m
[1mindex 2c246f5..d663a21 100644[m
[1m--- a/node_modules/.package-lock.json[m
[1m+++ b/node_modules/.package-lock.json[m
[36m@@ -61,6 +61,12 @@[m
         "node": ">= 8"[m
       }[m
     },[m
[32m+[m[32m    "node_modules/append-field": {[m
[32m+[m[32m      "version": "1.0.0",[m
[32m+[m[32m      "resolved": "https://registry.npmjs.org/append-field/-/append-field-1.0.0.tgz",[m
[32m+[m[32m      "integrity": "sha512-klpgFSWLW1ZEs8svjfb7g4qWY0YS5imI82dTg+QahUvJ8YqAY0P10Uk8tTyh9ZGuYEZEMaeJYCF5BFuX552hsw==",[m
[32m+[m[32m      "license": "MIT"[m
[32m+[m[32m    },[m
     "node_modules/array-flatten": {[m
       "version": "1.1.1",[m
       "resolved": "https://registry.npmjs.org/array-flatten/-/array-flatten-1.1.1.tgz",[m
[36m@@ -147,6 +153,23 @@[m
       "integrity": "sha512-zRpUiDwd/xk6ADqPMATG8vc9VPrkck7T07OIx0gnjmJAnHnTVXNQG3vfvWNuiZIkwu9KrKdA1iJKfsfTVxE6NA==",[m
       "license": "BSD-3-Clause"[m
     },[m
[32m+[m[32m    "node_modules/buffer-from": {[m
[32m+[m[32m      "version": "1.1.2",[m
[32m+[m[32m      "resolved": "https://registry.npmjs.org/buffer-from/-/buffer-from-1.1.2.tgz",[m
[32m+[m[32m      "integrity": "sha512-E+XQCRwSbaaiChtv6k6Dwgc+bx+Bs6vuKJHHl5kox/BaKbhiXzqQOwK4cO22yElGp2OCmjwVhT3HmxgyPGnJfQ==",[m
[32m+[m[32m      "license": "MIT"[m
[32m+[m[32m    },[m
[32m+[m[32m    "node_modules/busboy": {[m
[32m+[m[32m      "version": "1.6.0",[m
[32m+[m[32m      "resolved": "https://registry.npmjs.org/busboy/-/busboy-1.6.0.tgz",[m
[32m+[m[32m      "integrity": "sha512-8SFQbg/0hQ9xy3UNTB0YEnsNBbWfhf7RtnzpL7TkBiTBRfrQ9Fxcnz7VJsleJpyp6rVLvXiuORqjlHi5q+PYuA==",[m
[32m+[m[32m      "dependencies": {[m
[32m+[m[32m        "streamsearch": "^1.1.0"[m
[32m+[m[32m      },[m
[32m+[m[32m      "engines": {[m
[32m+[m[32m        "node": ">=10.16.0"[m
[32m+[m[32m      }[m
[32m+[m[32m    },[m
     "node_modules/bytes": {[m
       "version": "3.1.2",[m
       "resolved": "https://registry.npmjs.org/bytes/-/bytes-3.1.2.tgz",[m
[36m@@ -207,6 +230,21 @@[m
       "dev": true,[m
       "license": "MIT"[m
     },[m
[32m+[m[32m    "node_modules/concat-stream": {[m
[32m+[m[32m      "version": "1.6.2",[m
[32m+[m[32m      "resolved": "https://registry.npmjs.org/concat-stream/-/concat-stream-1.6.2.tgz",[m
[32m+[m[32m      "integrity": "sha512-27HBghJxjiZtIk3Ycvn/4kbJk/1uZuJFfuPEns6LaEvpvG1f0hTea8lilrouyo9mVc2GWdcEZ8OLoGmSADlrCw==",[m
[32m+[m[32m      "engines": [[m
[32m+[m[32m        "node >= 0.8"[m
[32m+[m[32m      ],[m
[32m+[m[32m      "license": "MIT",[m
[32m+[m[32m      "dependencies": {[m
[32m+[m[32m        "buffer-from": "^1.0.0",[m
[32m+[m[32m        "inherits": "^2.0.3",[m
[32m+[m[32m        "readable-stream": "^2.2.2",[m
[32m+[m[32m        "typedarray": "^0.0.6"[m
[32m+[m[32m      }[m
[32m+[m[32m    },[m
     "node_modules/content-disposition": {[m
       "version": "0.5.4",[m
       "resolved": "https://registry.npmjs.org/content-disposition/-/content-disposition-0.5.4.tgz",[m
[36m@@ -243,6 +281,12 @@[m
       "integrity": "sha512-QADzlaHc8icV8I7vbaJXJwod9HWYp8uCqf1xa4OfNu1T7JVxQIrUgOWtHdNDtPiywmFbiS12VjotIXLrKM3orQ==",[m
       "license": "MIT"[m
     },[m
[32m+[m[32m    "node_modules/core-util-is": {[m
[32m+[m[32m      "version": "1.0.3",[m
[32m+[m[32m      "resolved": "https://registry.npmjs.org/core-util-is/-/core-util-is-1.0.3.tgz",[m
[32m+[m[32m      "integrity": "sha512-ZQBvi1DcpJ4GDqanjucZ2Hj3wEO5pZDS89BWbkcrvdxksJorwUDDZamX9ldFkp9aw2lmBDLgkObEA4DWNJ9FYQ==",[m
[32m+[m[32m      "license": "MIT"[m
[32m+[m[32m    },[m
     "node_modules/cors": {[m
       "version": "2.8.5",[m
       "resolved": "https://registry.npmjs.org/cors/-/cors-2.8.5.tgz",[m
[36m@@ -686,6 +730,12 @@[m
         "node": ">=0.12.0"[m
       }[m
     },[m
[32m+[m[32m    "node_modules/isarray": {[m
[32m+[m[32m      "version": "1.0.0",[m
[32m+[m[32m      "resolved": "https://registry.npmjs.org/isarray/-/isarray-1.0.0.tgz",[m
[32m+[m[32m      "integrity": "sha512-VLghIWNM6ELQzo7zwmcg0NmTVyWKYjvIeM83yjp0wRDTmUnrM678fQbcKBo6n2CJEF0szoG//ytg+TKla89ALQ==",[m
[32m+[m[32m      "license": "MIT"[m
[32m+[m[32m    },[m
     "node_modules/jsonwebtoken": {[m
       "version": "9.0.2",[m
       "resolved": "https://registry.npmjs.org/jsonwebtoken/-/jsonwebtoken-9.0.2.tgz",[m
[36m@@ -856,6 +906,27 @@[m
         "node": "*"[m
       }[m
     },[m
[32m+[m[32m    "node_modules/minimist": {[m
[32m+[m[32m      "version": "1.2.8",[m
[32m+[m[32m      "resolved": "https://registry.npmjs.org/minimist/-/minimist-1.2.8.tgz",[m
[32m+[m[32m      "integrity": "sha512-2yyAR8qBkN3YuheJanUpWC5U3bb5osDywNB8RzDVlDwDHbocAJveqqj1u8+SVD7jkWT4yvsHCpWqqWqAxb0zCA==",[m
[32m+[m[32m      "license": "MIT",[m
[32m+[m[32m      "funding": {[m
[32m+[m[32m        "url": "https://github.com/sponsors/ljharb"[m
[32m+[m[32m      }[m
[32m+[m[32m    },[m
[32m+[m[32m    "node_modules/mkdirp": {[m
[32m+[m[32m      "version": "0.5.6",[m
[32m+[m[32m      "resolved": "https://registry.npmjs.org/mkdirp/-/mkdirp-0.5.6.tgz",[m
[32m+[m[32m      "integrity": "sha512-FP+p8RB8OWpF3YZBCrP5gtADmtXApB5AMLn+vdyA+PyxCjrCs00mjyUozssO33cwDeT3wNGdLxJ5M//YqtHAJw==",[m
[32m+[m[32m      "license": "MIT",[m
[32m+[m[32m      "dependencies": {[m
[32m+[m[32m        "minimist": "^1.2.6"[m
[32m+[m[32m      },[m
[32m+[m[32m      "bin": {[m
[32m+[m[32m        "mkdirp": "bin/cmd.js"[m
[32m+[m[32m      }[m
[32m+[m[32m    },[m
     "node_modules/moment": {[m
       "version": "2.30.1",[m
       "resolved": "https://registry.npmjs.org/moment/-/moment-2.30.1.tgz",[m
[36m@@ -883,6 +954,24 @@[m
       "integrity": "sha512-Tpp60P6IUJDTuOq/5Z8cdskzJujfwqfOTkrwIwj7IRISpnkJnT6SyJ4PCPnGMoFjC9ddhal5KVIYtAt97ix05A==",[m
       "license": "MIT"[m
     },[m
[32m+[m[32m    "node_modules/multer": {[m
[32m+[m[32m      "version": "1.4.5-lts.1",[m
[32m+[m[32m      "resolved": "https://registry.npmjs.org/multer/-/multer-1.4.5-lts.1.tgz",[m
[32m+[m[32m      "integrity": "sha512-ywPWvcDMeH+z9gQq5qYHCCy+ethsk4goepZ45GLD63fOu0YcNecQxi64nDs3qluZB+murG3/D4dJ7+dGctcCQQ==",[m
[32m+[m[32m      "license": "MIT",[m
[32m+[m[32m      "dependencies": {[m
[32m+[m[32m        "append-field": "^1.0.0",[m
[32m+[m[32m        "busboy": "^1.0.0",[m
[32m+[m[32m        "concat-stream": "^1.5.2",[m
[32m+[m[32m        "mkdirp": "^0.5.4",[m
[32m+[m[32m        "object-assign": "^4.1.1",[m
[32m+[m[32m        "type-is": "^1.6.4",[m
[32m+[m[32m        "xtend": "^4.0.0"[m
[32m+[m[32m      },[m
[32m+[m[32m      "engines": {[m
[32m+[m[32m        "node": ">= 6.0.0"[m
[32m+[m[32m      }[m
[32m+[m[32m    },[m
     "node_modules/negotiator": {[m
       "version": "0.6.3",[m
       "resolved": "https://registry.npmjs.org/negotiator/-/negotiator-0.6.3.tgz",[m
[36m@@ -1157,6 +1246,12 @@[m
         "node": ">=0.10.0"[m
       }[m
     },[m
[32m+[m[32m    "node_modules/process-nextick-args": {[m
[32m+[m[32m      "version": "2.0.1",[m
[32m+[m[32m      "resolved": "https://registry.npmjs.org/process-nextick-args/-/process-nextick-args-2.0.1.tgz",[m
[32m+[m[32m      "integrity": "sha512-3ouUOpQhtgrbOa17J7+uxOTpITYWaGP7/AhoR3+A+/1e9skrzelGi/dXzEYyvbxubEF6Wn2ypscTKiKJFFn1ag==",[m
[32m+[m[32m      "license": "MIT"[m
[32m+[m[32m    },[m
     "node_modules/proxy-addr": {[m
       "version": "2.0.7",[m
       "resolved": "https://registry.npmjs.org/proxy-addr/-/proxy-addr-2.0.7.tgz",[m
[36m@@ -1216,6 +1311,27 @@[m
         "node": ">= 0.8"[m
       }[m
     },[m
[32m+[m[32m    "node_modules/readable-stream": {[m
[32m+[m[32m      "version": "2.3.8",[m
[32m+[m[32m      "resolved": "https://registry.npmjs.org/readable-stream/-/readable-stream-2.3.8.tgz",[m
[32m+[m[32m      "integrity": "sha512-8p0AUk4XODgIewSi0l8Epjs+EVnWiK7NoDIEGU0HhE7+ZyY8D1IMY7odu5lRrFXGg71L15KG8QrPmum45RTtdA==",[m
[32m+[m[32m      "license": "MIT",[m
[32m+[m[32m      "dependencies": {[m
[32m+[m[32m        "core-util-is": "~1.0.0",[m
[32m+[m[32m        "inherits": "~2.0.3",[m
[32m+[m[32m        "isarray": "~1.0.0",[m
[32m+[m[32m        "process-nextick-args": "~2.0.0",[m
[32m+[m[32m        "safe-buffer": "~5.1.1",[m
[32m+[m[32m        "string_decoder": "~1.1.1",[m
[32m+[m[32m        "util-deprecate": "~1.0.1"[m
[32m+[m[32m      }[m
[32m+[m[32m    },[m
[32m+[m[32m    "node_modules/readable-stream/node_modules/safe-buffer": {[m
[32m+[m[32m      "version": "5.1.2",[m
[32m+[m[32m      "resolved": "https://registry.npmjs.org/safe-buffer/-/safe-buffer-5.1.2.tgz",[m
[32m+[m[32m      "integrity": "sha512-Gd2UZBJDkXlY7GbJxfsE8/nvKkUEU1G38c1siN6QP6a9PT9MmHB8GnpscSmMJSoF8LOIrt8ud/wPtojys4G6+g==",[m
[32m+[m[32m      "license": "MIT"[m
[32m+[m[32m    },[m
     "node_modules/readdirp": {[m
       "version": "3.6.0",[m
       "resolved": "https://registry.npmjs.org/readdirp/-/readdirp-3.6.0.tgz",[m
[36m@@ -1493,6 +1609,29 @@[m
         "node": ">= 0.8"[m
       }[m
     },[m
[32m+[m[32m    "node_modules/streamsearch": {[m
[32m+[m[32m      "version": "1.1.0",[m
[32m+[m[32m      "resolved": "https://registry.npmjs.org/streamsearch/-/streamsearch-1.1.0.tgz",[m
[32m+[m[32m      "integrity": "sha512-Mcc5wHehp9aXz1ax6bZUyY5afg9u2rv5cqQI3mRrYkGC8rW2hM02jWuwjtL++LS5qinSyhj2QfLyNsuc+VsExg==",[m
[32m+[m[32m      "engines": {[m
[32m+[m[32m        "node": ">=10.0.0"[m
[32m+[m[32m      }[m
[32m+[m[32m    },[m
[32m+[m[32m    "node_modules/string_decoder": {[m
[32m+[m[32m      "version": "1.1.1",[m
[32m+[m[32m      "resolved": "https://registry.npmjs.org/string_decoder/-/string_decoder-1.1.1.tgz",[m
[32m+[m[32m      "integrity": "sha512-n/ShnvDi6FHbbVfviro+WojiFzv+s8MPMHBczVePfUpDJLwoLT0ht1l4YwBCbi8pJAveEEdnkHyPyTP/mzRfwg==",[m
[32m+[m[32m      "license": "MIT",[m
[32m+[m[32m      "dependencies": {[m
[32m+[m[32m        "safe-buffer": "~5.1.0"[m
[32m+[m[32m      }[m
[32m+[m[32m    },[m
[32m+[m[32m    "node_modules/string_decoder/node_modules/safe-buffer": {[m
[32m+[m[32m      "version": "5.1.2",[m
[32m+[m[32m      "resolved": "https://registry.npmjs.org/safe-buffer/-/safe-buffer-5.1.2.tgz",[m
[32m+[m[32m      "integrity": "sha512-Gd2UZBJDkXlY7GbJxfsE8/nvKkUEU1G38c1siN6QP6a9PT9MmHB8GnpscSmMJSoF8LOIrt8ud/wPtojys4G6+g==",[m
[32m+[m[32m      "license": "MIT"[m
[32m+[m[32m    },[m
     "node_modules/supports-color": {[m
       "version": "5.5.0",[m
       "resolved": "https://registry.npmjs.org/supports-color/-/supports-color-5.5.0.tgz",[m
[36m@@ -1557,6 +1696,12 @@[m
         "node": ">= 0.6"[m
       }[m
     },[m
[32m+[m[32m    "node_modules/typedarray": {[m
[32m+[m[32m      "version": "0.0.6",[m
[32m+[m[32m      "resolved": "https://registry.npmjs.org/typedarray/-/typedarray-0.0.6.tgz",[m
[32m+[m[32m      "integrity": "sha512-/aCDEGatGvZ2BIk+HmLf4ifCJFwvKFNb9/JeZPMulfgFracn9QFcAf5GO8B/mweUjSoblS5In0cWhqpfs/5PQA==",[m
[32m+[m[32m      "license": "MIT"[m
[32m+[m[32m    },[m
     "node_modules/undefsafe": {[m
       "version": "2.0.5",[m
       "resolved": "https://registry.npmjs.org/undefsafe/-/undefsafe-2.0.5.tgz",[m
[36m@@ -1585,6 +1730,12 @@[m
         "node": ">= 0.8"[m
       }[m
     },[m
[32m+[m[32m    "node_modules/util-deprecate": {[m
[32m+[m[32m      "version": "1.0.2",[m
[32m+[m[32m      "resolved": "https://registry.npmjs.org/util-deprecate/-/util-deprecate-1.0.2.tgz",[m
[32m+[m[32m      "integrity": "sha512-EPD5q1uXyFxJpCrLnCc1nHnq3gOa6DZBocAIiI2TaSCA7VCJ1UJDMagCzIkXNsUYfD1daK//LTEQ8xiIbrHtcw==",[m
[32m+[m[32m      "license": "MIT"[m
[32m+[m[32m    },[m
     "node_modules/utils-merge": {[m
       "version": "1.0.1",[m
       "resolved": "https://registry.npmjs.org/utils-merge/-/utils-merge-1.0.1.tgz",[m
[1mdiff --git a/node_modules/append-field/.npmignore b/node_modules/append-field/.npmignore[m
[1mnew file mode 100644[m
[1mindex 0000000..c2658d7[m
[1m--- /dev/null[m
[1m+++ b/node_modules/append-field/.npmignore[m
[36m@@ -0,0 +1 @@[m
[32m+[m[32mnode_modules/[m
[1mdiff --git a/node_modules/append-field/LICENSE b/node_modules/append-field/LICENSE[m
[1mnew file mode 100644[m
[1mindex 0000000..14b1f89[m
[1m--- /dev/null[m
[1m+++ b/node_modules/append-field/LICENSE[m
[36m@@ -0,0 +1,21 @@[m
[32m+[m[32mThe MIT License (MIT)[m
[32m+[m
[32m+[m[32mCopyright (c) 2015 Linus Unnebäck[m
[32m+[m
[32m+[m[32mPermission is hereby granted, free of charge, to any person obtaining a copy[m
[32m+[m[32mof this software and associated documentation files (the "Software"), to deal[m
[32m+[m[32min the Software without restriction, including without limitation the rights[m
[32m+[m[32mto use, copy, modify, merge, publish, distribute, sublicense, and/or sell[m
[32m+[m[32mcopies of the Software, and to permit persons to whom the Software is[m
[32m+[m[32mfurnished to do so, subject to the following conditions:[m
[32m+[m
[32m+[m[32mThe above copyright notice and this permission notice shall be included in all[m
[32m+[m[32mcopies or substantial portions of the Software.[m
[32m+[m
[32m+[m[32mTHE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR[m
[32m+[m[32mIMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,[m
[32m+[m[32mFITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE[m
[32m+[m[32mAUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER[m
[32m+[m[32mLIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,[m
[32m+[m[32mOUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE[m
[32m+[m[32mSOFTWARE.[m
[1mdiff --git a/node_modules/append-field/README.md b/node_modules/append-field/README.md[m
[1mnew file mode 100644[m
[1mindex 0000000..62b901b[m
[1m--- /dev/null[m
[1m+++ b/node_modules/append-field/README.md[m
[36m@@ -0,0 +1,44 @@[m
[32m+[m[32m# `append-field`[m
[32m+[m
[32m+[m[32mA [W3C HTML JSON forms spec](http://www.w3.org/TR/html-json-forms/) compliant[m
[32m+[m[32mfield appender (for lack of a better name). Useful for people implementing[m
[32m+[m[32m`application/x-www-form-urlencoded` and `multipart/form-data` parsers.[m
[32m+[m
[32m+[m[32mIt works best on objects created with `Object.create(null)`. Otherwise it might[m
[32m+[m[32mconflict with variables from the prototype (e.g. `hasOwnProperty`).[m
[32m+[m
[32m+[m[32m## Installation[m
[32m+[m
[32m+[m[32m```sh[m
[32m+[m[32mnpm install --save append-field[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32m## Usage[m
[32m+[m
[32m+[m[32m```javascript[m
[32m+[m[32mvar appendField = require('append-field')[m
[32m+[m[32mvar obj = Object.create(null)[m
[32m+[m
[32m+[m[32mappendField(obj, 'pets[0][species]', 'Dahut')[m
[32m+[m[32mappendField(obj, 'pets[0][name]', 'Hypatia')[m
[32m+[m[32mappendField(obj, 'pets[1][species]', 'Felis Stultus')[m
[32m+[m[32mappendField(obj, 'pets[1][name]', 'Billie')[m
[32m+[m
[32m+[m[32mconsole.log(obj)[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32m```text[m
[32m+[m[32m{ pets:[m
[32m+[m[32m   [ { species: 'Dahut', name: 'Hypatia' },[m
[32m+[m[32m     { species: 'Felis Stultus', name: 'Billie' } ] }[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32m## API[m
[32m+[m
[32m+[m[32m### `appendField(store, key, value)`[m
[32m+[m
[32m+[m[32mAdds the field named `key` with the value `value` to the object `store`.[m
[32m+[m
[32m+[m[32m## License[m
[32m+[m
[32m+[m[32mMIT[m
[1mdiff --git a/node_modules/append-field/index.js b/node_modules/append-field/index.js[m
[1mnew file mode 100644[m
[1mindex 0000000..fc5acc8[m
[1m--- /dev/null[m
[1m+++ b/node_modules/append-field/index.js[m
[36m@@ -0,0 +1,12 @@[m
[32m+[m[32mvar parsePath = require('./lib/parse-path')[m
[32m+[m[32mvar setValue = require('./lib/set-value')[m
[32m+[m
[32m+[m[32mfunction appendField (store, key, value) {[m
[32m+[m[32m  var steps = parsePath(key)[m
[32m+[m
[32m+[m[32m  steps.reduce(function (context, step) {[m
[32m+[m[32m    return setValue(context, step, context[step.key], value)[m
[32m+[m[32m  }, store)[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mmodule.exports = appendField[m
[1mdiff --git a/node_modules/append-field/lib/parse-path.js b/node_modules/append-field/lib/parse-path.js[m
[1mnew file mode 100644[m
[1mindex 0000000..31d6179[m
[1m--- /dev/null[m
[1m+++ b/node_modules/append-field/lib/parse-path.js[m
[36m@@ -0,0 +1,53 @@[m
[32m+[m[32mvar reFirstKey = /^[^\[]*/[m
[32m+[m[32mvar reDigitPath = /^\[(\d+)\]/[m
[32m+[m[32mvar reNormalPath = /^\[([^\]]+)\]/[m
[32m+[m
[32m+[m[32mfunction parsePath (key) {[m
[32m+[m[32m  function failure () {[m
[32m+[m[32m    return [{ type: 'object', key: key, last: true }][m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  var firstKey = reFirstKey.exec(key)[0][m
[32m+[m[32m  if (!firstKey) return failure()[m
[32m+[m
[32m+[m[32m  var len = key.length[m
[32m+[m[32m  var pos = firstKey.length[m
[32m+[m[32m  var tail = { type: 'object', key: firstKey }[m
[32m+[m[32m  var steps = [tail][m
[32m+[m
[32m+[m[32m  while (pos < len) {[m
[32m+[m[32m    var m[m
[32m+[m
[32m+[m[32m    if (key[pos] === '[' && key[pos + 1] === ']') {[m
[32m+[m[32m      pos += 2[m
[32m+[m[32m      tail.append = true[m
[32m+[m[32m      if (pos !== len) return failure()[m
[32m+[m[32m      continue[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    m = reDigitPath.exec(key.substring(pos))[m
[32m+[m[32m    if (m !== null) {[m
[32m+[m[32m      pos += m[0].length[m
[32m+[m[32m      tail.nextType = 'array'[m
[32m+[m[32m      tail = { type: 'array', key: parseInt(m[1], 10) }[m
[32m+[m[32m      steps.push(tail)[m
[32m+[m[32m      continue[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    m = reNormalPath.exec(key.substring(pos))[m
[32m+[m[32m    if (m !== null) {[m
[32m+[m[32m      pos += m[0].length[m
[32m+[m[32m      tail.nextType = 'object'[m
[32m+[m[32m      tail = { type: 'object', key: m[1] }[m
[32m+[m[32m      steps.push(tail)[m
[32m+[m[32m      continue[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    return failure()[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  tail.last = true[m
[32m+[m[32m  return steps[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mmodule.exports = parsePath[m
[1mdiff --git a/node_modules/append-field/lib/set-value.js b/node_modules/append-field/lib/set-value.js[m
[1mnew file mode 100644[m
[1mindex 0000000..c15e873[m
[1m--- /dev/null[m
[1m+++ b/node_modules/append-field/lib/set-value.js[m
[36m@@ -0,0 +1,64 @@[m
[32m+[m[32mfunction valueType (value) {[m
[32m+[m[32m  if (value === undefined) return 'undefined'[m
[32m+[m[32m  if (Array.isArray(value)) return 'array'[m
[32m+[m[32m  if (typeof value === 'object') return 'object'[m
[32m+[m[32m  return 'scalar'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction setLastValue (context, step, currentValue, entryValue) {[m
[32m+[m[32m  switch (valueType(currentValue)) {[m
[32m+[m[32m    case 'undefined':[m
[32m+[m[32m      if (step.append) {[m
[32m+[m[32m        context[step.key] = [entryValue][m
[32m+[m[32m      } else {[m
[32m+[m[32m        context[step.key] = entryValue[m
[32m+[m[32m      }[m
[32m+[m[32m      break[m
[32m+[m[32m    case 'array':[m
[32m+[m[32m      context[step.key].push(entryValue)[m
[32m+[m[32m      break[m
[32m+[m[32m    case 'object':[m
[32m+[m[32m      return setLastValue(currentValue, { type: 'object', key: '', last: true }, currentValue[''], entryValue)[m
[32m+[m[32m    case 'scalar':[m
[32m+[m[32m      context[step.key] = [context[step.key], entryValue][m
[32m+[m[32m      break[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  return context[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction setValue (context, step, currentValue, entryValue) {[m
[32m+[m[32m  if (step.last) return setLastValue(context, step, currentValue, entryValue)[m
[32m+[m
[32m+[m[32m  var obj[m
[32m+[m[32m  switch (valueType(currentValue)) {[m
[32m+[m[32m    case 'undefined':[m
[32m+[m[32m      if (step.nextType === 'array') {[m
[32m+[m[32m        context[step.key] = [][m
[32m+[m[32m      } else {[m
[32m+[m[32m        context[step.key] = Object.create(null)[m
[32m+[m[32m      }[m
[32m+[m[32m      return context[step.key][m
[32m+[m[32m    case 'object':[m
[32m+[m[32m      return context[step.key][m
[32m+[m[32m    case 'array':[m
[32m+[m[32m      if (step.nextType === 'array') {[m
[32m+[m[32m        return currentValue[m
[32m+[m[32m      }[m
[32m+[m
[32m+[m[32m      obj = Object.create(null)[m
[32m+[m[32m      context[step.key] = obj[m
[32m+[m[32m      currentValue.forEach(function (item, i) {[m
[32m+[m[32m        if (item !== undefined) obj['' + i] = item[m
[32m+[m[32m      })[m
[32m+[m
[32m+[m[32m      return obj[m
[32m+[m[32m    case 'scalar':[m
[32m+[m[32m      obj = Object.create(null)[m
[32m+[m[32m      obj[''] = currentValue[m
[32m+[m[32m      context[step.key] = obj[m
[32m+[m[32m      return obj[m
[32m+[m[32m  }[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mmodule.exports = setValue[m
[1mdiff --git a/node_modules/append-field/package.json b/node_modules/append-field/package.json[m
[1mnew file mode 100644[m
[1mindex 0000000..8d6e716[m
[1m--- /dev/null[m
[1m+++ b/node_modules/append-field/package.json[m
[36m@@ -0,0 +1,19 @@[m
[32m+[m[32m{[m
[32m+[m[32m  "name": "append-field",[m
[32m+[m[32m  "version": "1.0.0",[m
[32m+[m[32m  "license": "MIT",[m
[32m+[m[32m  "author": "Linus Unnebäck <linus@folkdatorn.se>",[m
[32m+[m[32m  "main": "index.js",[m
[32m+[m[32m  "devDependencies": {[m
[32m+[m[32m    "mocha": "^2.2.4",[m
[32m+[m[32m    "standard": "^6.0.5",[m
[32m+[m[32m    "testdata-w3c-json-form": "^0.2.0"[m
[32m+[m[32m  },[m
[32m+[m[32m  "scripts": {[m
[32m+[m[32m    "test": "standard && mocha"[m
[32m+[m[32m  },[m
[32m+[m[32m  "repository": {[m
[32m+[m[32m    "type": "git",[m
[32m+[m[32m    "url": "http://github.com/LinusU/node-append-field.git"[m
[32m+[m[32m  }[m
[32m+[m[32m}[m
[1mdiff --git a/node_modules/append-field/test/forms.js b/node_modules/append-field/test/forms.js[m
[1mnew file mode 100644[m
[1mindex 0000000..dd6fbc9[m
[1m--- /dev/null[m
[1m+++ b/node_modules/append-field/test/forms.js[m
[36m@@ -0,0 +1,19 @@[m
[32m+[m[32m/* eslint-env mocha */[m
[32m+[m
[32m+[m[32mvar assert = require('assert')[m
[32m+[m[32mvar appendField = require('../')[m
[32m+[m[32mvar testData = require('testdata-w3c-json-form')[m
[32m+[m
[32m+[m[32mdescribe('Append Field', function () {[m
[32m+[m[32m  for (var test of testData) {[m
[32m+[m[32m    it('handles ' + test.name, function () {[m
[32m+[m[32m      var store = Object.create(null)[m
[32m+[m
[32m+[m[32m      for (var field of test.fields) {[m
[32m+[m[32m        appendField(store, field.key, field.value)[m
[32m+[m[32m      }[m
[32m+[m
[32m+[m[32m      assert.deepEqual(store, test.expected)[m
[32m+[m[32m    })[m
[32m+[m[32m  }[m
[32m+[m[32m})[m
[1mdiff --git a/node_modules/buffer-from/LICENSE b/node_modules/buffer-from/LICENSE[m
[1mnew file mode 100644[m
[1mindex 0000000..e4bf1d6[m
[1m--- /dev/null[m
[1m+++ b/node_modules/buffer-from/LICENSE[m
[36m@@ -0,0 +1,21 @@[m
[32m+[m[32mMIT License[m
[32m+[m
[32m+[m[32mCopyright (c) 2016, 2018 Linus Unnebäck[m
[32m+[m
[32m+[m[32mPermission is hereby granted, free of charge, to any person obtaining a copy[m
[32m+[m[32mof this software and associated documentation files (the "Software"), to deal[m
[32m+[m[32min the Software without restriction, including without limitation the rights[m
[32m+[m[32mto use, copy, modify, merge, publish, distribute, sublicense, and/or sell[m
[32m+[m[32mcopies of the Software, and to permit persons to whom the Software is[m
[32m+[m[32mfurnished to do so, subject to the following conditions:[m
[32m+[m
[32m+[m[32mThe above copyright notice and this permission notice shall be included in all[m
[32m+[m[32mcopies or substantial portions of the Software.[m
[32m+[m
[32m+[m[32mTHE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR[m
[32m+[m[32mIMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,[m
[32m+[m[32mFITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE[m
[32m+[m[32mAUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER[m
[32m+[m[32mLIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,[m
[32m+[m[32mOUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE[m
[32m+[m[32mSOFTWARE.[m
[1mdiff --git a/node_modules/buffer-from/index.js b/node_modules/buffer-from/index.js[m
[1mnew file mode 100644[m
[1mindex 0000000..e1a58b5[m
[1m--- /dev/null[m
[1m+++ b/node_modules/buffer-from/index.js[m
[36m@@ -0,0 +1,72 @@[m
[32m+[m[32m/* eslint-disable node/no-deprecated-api */[m
[32m+[m
[32m+[m[32mvar toString = Object.prototype.toString[m
[32m+[m
[32m+[m[32mvar isModern = ([m
[32m+[m[32m  typeof Buffer !== 'undefined' &&[m
[32m+[m[32m  typeof Buffer.alloc === 'function' &&[m
[32m+[m[32m  typeof Buffer.allocUnsafe === 'function' &&[m
[32m+[m[32m  typeof Buffer.from === 'function'[m
[32m+[m[32m)[m
[32m+[m
[32m+[m[32mfunction isArrayBuffer (input) {[m
[32m+[m[32m  return toString.call(input).slice(8, -1) === 'ArrayBuffer'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction fromArrayBuffer (obj, byteOffset, length) {[m
[32m+[m[32m  byteOffset >>>= 0[m
[32m+[m
[32m+[m[32m  var maxLength = obj.byteLength - byteOffset[m
[32m+[m
[32m+[m[32m  if (maxLength < 0) {[m
[32m+[m[32m    throw new RangeError("'offset' is out of bounds")[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  if (length === undefined) {[m
[32m+[m[32m    length = maxLength[m
[32m+[m[32m  } else {[m
[32m+[m[32m    length >>>= 0[m
[32m+[m
[32m+[m[32m    if (length > maxLength) {[m
[32m+[m[32m      throw new RangeError("'length' is out of bounds")[m
[32m+[m[32m    }[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  return isModern[m
[32m+[m[32m    ? Buffer.from(obj.slice(byteOffset, byteOffset + length))[m
[32m+[m[32m    : new Buffer(new Uint8Array(obj.slice(byteOffset, byteOffset + length)))[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction fromString (string, encoding) {[m
[32m+[m[32m  if (typeof encoding !== 'string' || encoding === '') {[m
[32m+[m[32m    encoding = 'utf8'[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  if (!Buffer.isEncoding(encoding)) {[m
[32m+[m[32m    throw new TypeError('"encoding" must be a valid string encoding')[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  return isModern[m
[32m+[m[32m    ? Buffer.from(string, encoding)[m
[32m+[m[32m    : new Buffer(string, encoding)[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction bufferFrom (value, encodingOrOffset, length) {[m
[32m+[m[32m  if (typeof value === 'number') {[m
[32m+[m[32m    throw new TypeError('"value" argument must not be a number')[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  if (isArrayBuffer(value)) {[m
[32m+[m[32m    return fromArrayBuffer(value, encodingOrOffset, length)[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  if (typeof value === 'string') {[m
[32m+[m[32m    return fromString(value, encodingOrOffset)[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  return isModern[m
[32m+[m[32m    ? Buffer.from(value)[m
[32m+[m[32m    : new Buffer(value)[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mmodule.exports = bufferFrom[m
[1mdiff --git a/node_modules/buffer-from/package.json b/node_modules/buffer-from/package.json[m
[1mnew file mode 100644[m
[1mindex 0000000..6ac5327[m
[1m--- /dev/null[m
[1m+++ b/node_modules/buffer-from/package.json[m
[36m@@ -0,0 +1,19 @@[m
[32m+[m[32m{[m
[32m+[m[32m  "name": "buffer-from",[m
[32m+[m[32m  "version": "1.1.2",[m
[32m+[m[32m  "license": "MIT",[m
[32m+[m[32m  "repository": "LinusU/buffer-from",[m
[32m+[m[32m  "files": [[m
[32m+[m[32m    "index.js"[m
[32m+[m[32m  ],[m
[32m+[m[32m  "scripts": {[m
[32m+[m[32m    "test": "standard && node test"[m
[32m+[m[32m  },[m
[32m+[m[32m  "devDependencies": {[m
[32m+[m[32m    "standard": "^12.0.1"[m
[32m+[m[32m  },[m
[32m+[m[32m  "keywords": [[m
[32m+[m[32m    "buffer",[m
[32m+[m[32m    "buffer from"[m
[32m+[m[32m  ][m
[32m+[m[32m}[m
[1mdiff --git a/node_modules/buffer-from/readme.md b/node_modules/buffer-from/readme.md[m
[1mnew file mode 100644[m
[1mindex 0000000..9880a55[m
[1m--- /dev/null[m
[1m+++ b/node_modules/buffer-from/readme.md[m
[36m@@ -0,0 +1,69 @@[m
[32m+[m[32m# Buffer From[m
[32m+[m
[32m+[m[32mA [ponyfill](https://ponyfill.com) for `Buffer.from`, uses native implementation if available.[m
[32m+[m
[32m+[m[32m## Installation[m
[32m+[m
[32m+[m[32m```sh[m
[32m+[m[32mnpm install --save buffer-from[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32m## Usage[m
[32m+[m
[32m+[m[32m```js[m
[32m+[m[32mconst bufferFrom = require('buffer-from')[m
[32m+[m
[32m+[m[32mconsole.log(bufferFrom([1, 2, 3, 4]))[m
[32m+[m[32m//=> <Buffer 01 02 03 04>[m
[32m+[m
[32m+[m[32mconst arr = new Uint8Array([1, 2, 3, 4])[m
[32m+[m[32mconsole.log(bufferFrom(arr.buffer, 1, 2))[m
[32m+[m[32m//=> <Buffer 02 03>[m
[32m+[m
[32m+[m[32mconsole.log(bufferFrom('test', 'utf8'))[m
[32m+[m[32m//=> <Buffer 74 65 73 74>[m
[32m+[m
[32m+[m[32mconst buf = bufferFrom('test')[m
[32m+[m[32mconsole.log(bufferFrom(buf))[m
[32m+[m[32m//=> <Buffer 74 65 73 74>[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32m## API[m
[32m+[m
[32m+[m[32m### bufferFrom(array)[m
[32m+[m
[32m+[m[32m- `array` &lt;Array&gt;[m
[32m+[m
[32m+[m[32mAllocates a new `Buffer` using an `array` of octets.[m
[32m+[m
[32m+[m[32m### bufferFrom(arrayBuffer[, byteOffset[, length]])[m
[32m+[m
[32m+[m[32m- `arrayBuffer` &lt;ArrayBuffer&gt; The `.buffer` property of a TypedArray or ArrayBuffer[m
[32m+[m[32m- `byteOffset` &lt;Integer&gt; Where to start copying from `arrayBuffer`. **Default:** `0`[m
[32m+[m[32m- `length` &lt;Integer&gt; How many bytes to copy from `arrayBuffer`. **Default:** `arrayBuffer.length - byteOffset`[m
[32m+[m
[32m+[m[32mWhen passed a reference to the `.buffer` property of a TypedArray instance, the[m
[32m+[m[32mnewly created `Buffer` will share the same allocated memory as the TypedArray.[m
[32m+[m
[32m+[m[32mThe optional `byteOffset` and `length` arguments specify a memory range within[m
[32m+[m[32mthe `arrayBuffer` that will be shared by the `Buffer`.[m
[32m+[m
[32m+[m[32m### bufferFrom(buffer)[m
[32m+[m
[32m+[m[32m- `buffer` &lt;Buffer&gt; An existing `Buffer` to copy data from[m
[32m+[m
[32m+[m[32mCopies the passed `buffer` data onto a new `Buffer` instance.[m
[32m+[m
[32m+[m[32m### bufferFrom(string[, encoding])[m
[32m+[m
[32m+[m[32m- `string` &lt;String&gt; A string to encode.[m
[32m+[m[32m- `encoding` &lt;String&gt; The encoding of `string`. **Default:** `'utf8'`[m
[32m+[m
[32m+[m[32mCreates a new `Buffer` containing the given JavaScript string `string`. If[m
[32m+[m[32mprovided, the `encoding` parameter identifies the character encoding of[m
[32m+[m[32m`string`.[m
[32m+[m
[32m+[m[32m## See also[m
[32m+[m
[32m+[m[32m- [buffer-alloc](https://github.com/LinusU/buffer-alloc) A ponyfill for `Buffer.alloc`[m
[32m+[m[32m- [buffer-alloc-unsafe](https://github.com/LinusU/buffer-alloc-unsafe) A ponyfill for `Buffer.allocUnsafe`[m
[1mdiff --git a/node_modules/busboy/.eslintrc.js b/node_modules/busboy/.eslintrc.js[m
[1mnew file mode 100644[m
[1mindex 0000000..be9311d[m
[1m--- /dev/null[m
[1m+++ b/node_modules/busboy/.eslintrc.js[m
[36m@@ -0,0 +1,5 @@[m
[32m+[m[32m'use strict';[m
[32m+[m
[32m+[m[32mmodule.exports = {[m
[32m+[m[32m  extends: '@mscdex/eslint-config',[m
[32m+[m[32m};[m
[1mdiff --git a/node_modules/busboy/.github/workflows/ci.yml b/node_modules/busboy/.github/workflows/ci.yml[m
[1mnew file mode 100644[m
[1mindex 0000000..799bae0[m
[1m--- /dev/null[m
[1m+++ b/node_modules/busboy/.github/workflows/ci.yml[m
[36m@@ -0,0 +1,24 @@[m
[32m+[m[32mname: CI[m
[32m+[m
[32m+[m[32mon:[m
[32m+[m[32m  pull_request:[m
[32m+[m[32m  push:[m
[32m+[m[32m    branches: [ master ][m
[32m+[m
[32m+[m[32mjobs:[m
[32m+[m[32m  tests-linux:[m
[32m+[m[32m    runs-on: ubuntu-latest[m
[32m+[m[32m    strategy:[m
[32m+[m[32m      fail-fast: false[m
[32m+[m[32m      matrix:[m
[32m+[m[32m        node-version: [10.16.0, 10.x, 12.x, 14.x, 16.x][m
[32m+[m[32m    steps:[m
[32m+[m[32m      - uses: actions/checkout@v2[m
[32m+[m[32m      - name: Use Node.js ${{ matrix.node-version }}[m
[32m+[m[32m        uses: actions/setup-node@v1[m
[32m+[m[32m        with:[m
[32m+[m[32m          node-version: ${{ matrix.node-version }}[m
[32m+[m[32m      - name: Install module[m
[32m+[m[32m        run: npm install[m
[32m+[m[32m      - name: Run tests[m
[32m+[m[32m        run: npm test[m
[1mdiff --git a/node_modules/busboy/.github/workflows/lint.yml b/node_modules/busboy/.github/workflows/lint.yml[m
[1mnew file mode 100644[m
[1mindex 0000000..9f9e1f5[m
[1m--- /dev/null[m
[1m+++ b/node_modules/busboy/.github/workflows/lint.yml[m
[36m@@ -0,0 +1,23 @@[m
[32m+[m[32mname: lint[m
[32m+[m
[32m+[m[32mon:[m
[32m+[m[32m  pull_request:[m
[32m+[m[32m  push:[m
[32m+[m[32m    branches: [ master ][m
[32m+[m
[32m+[m[32menv:[m
[32m+[m[32m  NODE_VERSION: 16.x[m
[32m+[m
[32m+[m[32mjobs:[m
[32m+[m[32m  lint-js:[m
[32m+[m[32m    runs-on: ubuntu-latest[m
[32m+[m[32m    steps:[m
[32m+[m[32m      - uses: actions/checkout@v2[m
[32m+[m[32m      - name: Use Node.js ${{ env.NODE_VERSION }}[m
[32m+[m[32m        uses: actions/setup-node@v1[m
[32m+[m[32m        with:[m
[32m+[m[32m          node-version: ${{ env.NODE_VERSION }}[m
[32m+[m[32m      - name: Install ESLint + ESLint configs/plugins[m
[32m+[m[32m        run: npm install --only=dev[m
[32m+[m[32m      - name: Lint files[m
[32m+[m[32m        run: npm run lint[m
[1mdiff --git a/node_modules/busboy/LICENSE b/node_modules/busboy/LICENSE[m
[1mnew file mode 100644[m
[1mindex 0000000..290762e[m
[1m--- /dev/null[m
[1m+++ b/node_modules/busboy/LICENSE[m
[36m@@ -0,0 +1,19 @@[m
[32m+[m[32mCopyright Brian White. All rights reserved.[m
[32m+[m
[32m+[m[32mPermission is hereby granted, free of charge, to any person obtaining a copy[m
[32m+[m[32mof this software and associated documentation files (the "Software"), to[m
[32m+[m[32mdeal in the Software without restriction, including without limitation the[m
[32m+[m[32mrights to use, copy, modify, merge, publish, distribute, sublicense, and/or[m
[32m+[m[32msell copies of the Software, and to permit persons to whom the Software is[m
[32m+[m[32mfurnished to do so, subject to the following conditions:[m
[32m+[m
[32m+[m[32mThe above copyright notice and this permission notice shall be included in[m
[32m+[m[32mall copies or substantial portions of the Software.[m
[32m+[m
[32m+[m[32mTHE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR[m
[32m+[m[32mIMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,[m
[32m+[m[32mFITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE[m
[32m+[m[32mAUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER[m
[32m+[m[32mLIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING[m
[32m+[m[32mFROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS[m
[32m+[m[32mIN THE SOFTWARE.[m
\ No newline at end of file[m
[1mdiff --git a/node_modules/busboy/README.md b/node_modules/busboy/README.md[m
[1mnew file mode 100644[m
[1mindex 0000000..654af30[m
[1m--- /dev/null[m
[1m+++ b/node_modules/busboy/README.md[m
[36m@@ -0,0 +1,191 @@[m
[32m+[m[32m# Description[m
[32m+[m
[32m+[m[32mA node.js module for parsing incoming HTML form data.[m
[32m+[m
[32m+[m[32mChanges (breaking or otherwise) in v1.0.0 can be found [here](https://github.com/mscdex/busboy/issues/266).[m
[32m+[m
[32m+[m[32m# Requirements[m
[32m+[m
[32m+[m[32m* [node.js](http://nodejs.org/) -- v10.16.0 or newer[m
[32m+[m
[32m+[m
[32m+[m[32m# Install[m
[32m+[m
[32m+[m[32m    npm install busboy[m
[32m+[m
[32m+[m
[32m+[m[32m# Examples[m
[32m+[m
[32m+[m[32m* Parsing (multipart) with default options:[m
[32m+[m
[32m+[m[32m```js[m
[32m+[m[32mconst http = require('http');[m
[32m+[m
[32m+[m[32mconst busboy = require('busboy');[m
[32m+[m
[32m+[m[32mhttp.createServer((req, res) => {[m
[32m+[m[32m  if (req.method === 'POST') {[m
[32m+[m[32m    console.log('POST request');[m
[32m+[m[32m    const bb = busboy({ headers: req.headers });[m
[32m+[m[32m    bb.on('file', (name, file, info) => {[m
[32m+[m[32m      const { filename, encoding, mimeType } = info;[m
[32m+[m[32m      console.log([m
[32m+[m[32m        `File [${name}]: filename: %j, encoding: %j, mimeType: %j`,[m
[32m+[m[32m        filename,[m
[32m+[m[32m        encoding,[m
[32m+[m[32m        mimeType[m
[32m+[m[32m      );[m
[32m+[m[32m      file.on('data', (data) => {[m
[32m+[m[32m        console.log(`File [${name}] got ${data.length} bytes`);[m
[32m+[m[32m      }).on('close', () => {[m
[32m+[m[32m        console.log(`File [${name}] done`);[m
[32m+[m[32m      });[m
[32m+[m[32m    });[m
[32m+[m[32m    bb.on('field', (name, val, info) => {[m
[32m+[m[32m      console.log(`Field [${name}]: value: %j`, val);[m
[32m+[m[32m    });[m
[32m+[m[32m    bb.on('close', () => {[m
[32m+[m[32m      console.log('Done parsing form!');[m
[32m+[m[32m      res.writeHead(303, { Connection: 'close', Location: '/' });[m
[32m+[m[32m      res.end();[m
[32m+[m[32m    });[m
[32m+[m[32m    req.pipe(bb);[m
[32m+[m[32m  } else if (req.method === 'GET') {[m
[32m+[m[32m    res.writeHead(200, { Connection: 'close' });[m
[32m+[m[32m    res.end(`[m
[32m+[m[32m      <html>[m
[32m+[m[32m        <head></head>[m
[32m+[m[32m        <body>[m
[32m+[m[32m          <form method="POST" enctype="multipart/form-data">[m
[32m+[m[32m            <input type="file" name="filefield"><br />[m
[32m+[m[32m            <input type="text" name="textfield"><br />[m
[32m+[m[32m            <input type="submit">[m
[32m+[m[32m          </form>[m
[32m+[m[32m        </body>[m
[32m+[m[32m      </html>[m
[32m+[m[32m    `);[m
[32m+[m[32m  }[m
[32m+[m[32m}).listen(8000, () => {[m
[32m+[m[32m  console.log('Listening for requests');[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32m// Example output:[m
[32m+[m[32m//[m
[32m+[m[32m// Listening for requests[m
[32m+[m[32m//   < ... form submitted ... >[m
[32m+[m[32m// POST request[m
[32m+[m[32m// File [filefield]: filename: "logo.jpg", encoding: "binary", mime: "image/jpeg"[m
[32m+[m[32m// File [filefield] got 11912 bytes[m
[32m+[m[32m// Field [textfield]: value: "testing! :-)"[m
[32m+[m[32m// File [filefield] done[m
[32m+[m[32m// Done parsing form![m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32m* Save all incoming files to disk:[m
[32m+[m
[32m+[m[32m```js[m
[32m+[m[32mconst { randomFillSync } = require('crypto');[m
[32m+[m[32mconst fs = require('fs');[m
[32m+[m[32mconst http = require('http');[m
[32m+[m[32mconst os = require('os');[m
[32m+[m[32mconst path = require('path');[m
[32m+[m
[32m+[m[32mconst busboy = require('busboy');[m
[32m+[m
[32m+[m[32mconst random = (() => {[m
[32m+[m[32m  const buf = Buffer.alloc(16);[m
[32m+[m[32m  return () => randomFillSync(buf).toString('hex');[m
[32m+[m[32m})();[m
[32m+[m
[32m+[m[32mhttp.createServer((req, res) => {[m
[32m+[m[32m  if (req.method === 'POST') {[m
[32m+[m[32m    const bb = busboy({ headers: req.headers });[m
[32m+[m[32m    bb.on('file', (name, file, info) => {[m
[32m+[m[32m      const saveTo = path.join(os.tmpdir(), `busboy-upload-${random()}`);[m
[32m+[m[32m      file.pipe(fs.createWriteStream(saveTo));[m
[32m+[m[32m    });[m
[32m+[m[32m    bb.on('close', () => {[m
[32m+[m[32m      res.writeHead(200, { 'Connection': 'close' });[m
[32m+[m[32m      res.end(`That's all folks!`);[m
[32m+[m[32m    });[m
[32m+[m[32m    req.pipe(bb);[m
[32m+[m[32m    return;[m
[32m+[m[32m  }[m
[32m+[m[32m  res.writeHead(404);[m
[32m+[m[32m  res.end();[m
[32m+[m[32m}).listen(8000, () => {[m
[32m+[m[32m  console.log('Listening for requests');[m
[32m+[m[32m});[m
[32m+[m[32m```[m
[32m+[m
[32m+[m
[32m+[m[32m# API[m
[32m+[m
[32m+[m[32m## Exports[m
[32m+[m
[32m+[m[32m`busboy` exports a single function:[m
[32m+[m
[32m+[m[32m**( _function_ )**(< _object_ >config) - Creates and returns a new _Writable_ form parser stream.[m
[32m+[m
[32m+[m[32m* Valid `config` properties:[m
[32m+[m
[32m+[m[32m    * **headers** - _object_ - These are the HTTP headers of the incoming request, which are used by individual parsers.[m
[32m+[m
[32m+[m[32m    * **highWaterMark** - _integer_ - highWaterMark to use for the parser stream. **Default:** node's _stream.Writable_ default.[m
[32m+[m
[32m+[m[32m    * **fileHwm** - _integer_ - highWaterMark to use for individual file streams. **Default:** node's _stream.Readable_ default.[m
[32m+[m
[32m+[m[32m    * **defCharset** - _string_ - Default character set to use when one isn't defined. **Default:** `'utf8'`.[m
[32m+[m
[32m+[m[32m    * **defParamCharset** - _string_ - For multipart forms, the default character set to use for values of part header parameters (e.g. filename) that are not extended parameters (that contain an explicit charset). **Default:** `'latin1'`.[m
[32m+[m
[32m+[m[32m    * **preservePath** - _boolean_ - If paths in filenames from file parts in a `'multipart/form-data'` request shall be preserved. **Default:** `false`.[m
[32m+[m
[32m+[m[32m    * **limits** - _object_ - Various limits on incoming data. Valid properties are:[m
[32m+[m
[32m+[m[32m        * **fieldNameSize** - _integer_ - Max field name size (in bytes). **Default:** `100`.[m
[32m+[m
[32m+[m[32m        * **fieldSize** - _integer_ - Max field value size (in bytes). **Default:** `1048576` (1MB).[m
[32m+[m
[32m+[m[32m        * **fields** - _integer_ - Max number of non-file fields. **Default:** `Infinity`.[m
[32m+[m
[32m+[m[32m        * **fileSize** - _integer_ - For multipart forms, the max file size (in bytes). **Default:** `Infinity`.[m
[32m+[m
[32m+[m[32m        * **files** - _integer_ - For multipart forms, the max number of file fields. **Default:** `Infinity`.[m
[32m+[m
[32m+[m[32m        * **parts** - _integer_ - For multipart forms, the max number of parts (fields + files). **Default:** `Infinity`.[m
[32m+[m
[32m+[m[32m        * **headerPairs** - _integer_ - For multipart forms, the max number of header key-value pairs to parse. **Default:** `2000` (same as node's http module).[m
[32m+[m
[32m+[m[32mThis function can throw exceptions if there is something wrong with the values in `config`. For example, if the Content-Type in `headers` is missing entirely, is not a supported type, or is missing the boundary for `'multipart/form-data'` requests.[m
[32m+[m
[32m+[m[32m## (Special) Parser stream events[m
[32m+[m
[32m+[m[32m* **file**(< _string_ >name, < _Readable_ >stream, < _object_ >info) - Emitted for each new file found. `name` contains the form field name. `stream` is a _Readable_ stream containing the file's data. No transformations/conversions (e.g. base64 to raw binary) are done on the file's data. `info` contains the following properties:[m
[32m+[m
[32m+[m[32m    * `filename` - _string_ - If supplied, this contains the file's filename. **WARNING:** You should almost _never_ use this value as-is (especially if you are using `preservePath: true` in your `config`) as it could contain malicious input. You are better off generating your own (safe) filenames, or at the very least using a hash of the filename.[m
[32m+[m
[32m+[m[32m    * `encoding` - _string_ - The file's `'Content-Transfer-Encoding'` value.[m
[32m+[m
[32m+[m[32m    * `mimeType` - _string_ - The file's `'Content-Type'` value.[m
[32m+[m
[32m+[m[32m    **Note:** If you listen for this event, you should always consume the `stream` whether you care about its contents or not (you can simply do `stream.resume();` if you want to discard/skip the contents), otherwise the `'finish'`/`'close'` event will never fire on the busboy parser stream.[m
[32m+[m[32m    However, if you aren't accepting files, you can either simply not listen for the `'file'` event at all or set `limits.files` to `0`, and any/all files will be automatically skipped (these skipped files will still count towards any configured `limits.files` and `limits.parts` limits though).[m
[32m+[m
[32m+[m[32m    **Note:** If a configured `limits.fileSize` limit was reached for a file, `stream` will both have a boolean property `truncated` set to `true` (best checked at the end of the stream) and emit a `'limit'` event to notify you when this happens.[m
[32m+[m
[32m+[m[32m* **field**(< _string_ >name, < _string_ >value, < _object_ >info) - Emitted for each new non-file field found. `name` contains the form field name. `value` contains the string value of the field. `info` contains the following properties:[m
[32m+[m
[32m+[m[32m    * `nameTruncated` - _boolean_ - Whether `name` was truncated or not (due to a configured `limits.fieldNameSize` limit)[m
[32m+[m
[32m+[m[32m    * `valueTruncated` - _boolean_ - Whether `value` was truncated or not (due to a configured `limits.fieldSize` limit)[m
[32m+[m
[32m+[m[32m    * `encoding` - _string_ - The field's `'Content-Transfer-Encoding'` value.[m
[32m+[m
[32m+[m[32m    * `mimeType` - _string_ - The field's `'Content-Type'` value.[m
[32m+[m
[32m+[m[32m* **partsLimit**() - Emitted when the configured `limits.parts` limit has been reached. No more `'file'` or `'field'` events will be emitted.[m
[32m+[m
[32m+[m[32m* **filesLimit**() - Emitted when the configured `limits.files` limit has been reached. No more `'file'` events will be emitted.[m
[32m+[m
[32m+[m[32m* **fieldsLimit**() - Emitted when the configured `limits.fields` limit has been reached. No more `'field'` events will be emitted.[m
[1mdiff --git a/node_modules/busboy/bench/bench-multipart-fields-100mb-big.js b/node_modules/busboy/bench/bench-multipart-fields-100mb-big.js[m
[1mnew file mode 100644[m
[1mindex 0000000..ef15729[m
[1m--- /dev/null[m
[1m+++ b/node_modules/busboy/bench/bench-multipart-fields-100mb-big.js[m
[36m@@ -0,0 +1,149 @@[m
[32m+[m[32m'use strict';[m
[32m+[m
[32m+[m[32mfunction createMultipartBuffers(boundary, sizes) {[m
[32m+[m[32m  const bufs = [];[m
[32m+[m[32m  for (let i = 0; i < sizes.length; ++i) {[m
[32m+[m[32m    const mb = sizes[i] * 1024 * 1024;[m
[32m+[m[32m    bufs.push(Buffer.from([[m
[32m+[m[32m      `--${boundary}`,[m
[32m+[m[32m      `content-disposition: form-data; name="field${i + 1}"`,[m
[32m+[m[32m      '',[m
[32m+[m[32m      '0'.repeat(mb),[m
[32m+[m[32m      '',[m
[32m+[m[32m    ].join('\r\n')));[m
[32m+[m[32m  }[m
[32m+[m[32m  bufs.push(Buffer.from([[m
[32m+[m[32m    `--${boundary}--`,[m
[32m+[m[32m    '',[m
[32m+[m[32m  ].join('\r\n')));[m
[32m+[m[32m  return bufs;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mconst boundary = '-----------------------------168072824752491622650073';[m
[32m+[m[32mconst buffers = createMultipartBuffers(boundary, [[m
[32m+[m[32m  10,[m
[32m+[m[32m  10,[m
[32m+[m[32m  10,[m
[32m+[m[32m  20,[m
[32m+[m[32m  50,[m
[32m+[m[32m]);[m
[32m+[m[32mconst calls = {[m
[32m+[m[32m  partBegin: 0,[m
[32m+[m[32m  headerField: 0,[m
[32m+[m[32m  headerValue: 0,[m
[32m+[m[32m  headerEnd: 0,[m
[32m+[m[32m  headersEnd: 0,[m
[32m+[m[32m  partData: 0,[m
[32m+[m[32m  partEnd: 0,[m
[32m+[m[32m  end: 0,[m
[32m+[m[32m};[m
[32m+[m
[32m+[m[32mconst moduleName = process.argv[2];[m
[32m+[m[32mswitch (moduleName) {[m
[32m+[m[32m  case 'busboy': {[m
[32m+[m[32m    const busboy = require('busboy');[m
[32m+[m
[32m+[m[32m    const parser = busboy({[m
[32m+[m[32m      limits: {[m
[32m+[m[32m        fieldSizeLimit: Infinity,[m
[32m+[m[32m      },[m
[32m+[m[32m      headers: {[m
[32m+[m[32m        'content-type': `multipart/form-data; boundary=${boundary}`,[m
[32m+[m[32m      },[m
[32m+[m[32m    });[m
[32m+[m[32m    parser.on('field', (name, val, info) => {[m
[32m+[m[32m      ++calls.partBegin;[m
[32m+[m[32m      ++calls.partData;[m
[32m+[m[32m      ++calls.partEnd;[m
[32m+[m[32m    }).on('close', () => {[m
[32m+[m[32m      ++calls.end;[m
[32m+[m[32m      console.timeEnd(moduleName);[m
[32m+[m[32m    });[m
[32m+[m
[32m+[m[32m    console.time(moduleName);[m
[32m+[m[32m    for (const buf of buffers)[m
[32m+[m[32m      parser.write(buf);[m
[32m+[m[32m    break;[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  case 'formidable': {[m
[32m+[m[32m    const { MultipartParser } = require('formidable');[m
[32m+[m
[32m+[m[32m    const parser = new MultipartParser();[m
[32m+[m[32m    parser.initWithBoundary(boundary);[m
[32m+[m[32m    parser.on('data', ({ name }) => {[m
[32m+[m[32m      ++calls[name];[m
[32m+[m[32m      if (name === 'end')[m
[32m+[m[32m        console.timeEnd(moduleName);[m
[32m+[m[32m    });[m
[32m+[m
[32m+[m[32m    console.time(moduleName);[m
[32m+[m[32m    for (const buf of buffers)[m
[32m+[m[32m      parser.write(buf);[m
[32m+[m
[32m+[m[32m    break;[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  case 'multiparty': {[m
[32m+[m[32m    const { Readable } = require('stream');[m
[32m+[m
[32m+[m[32m    const { Form } = require('multiparty');[m
[32m+[m
[32m+[m[32m    const form = new Form({[m
[32m+[m[32m      maxFieldsSize: Infinity,[m
[32m+[m[32m      maxFields: Infinity,[m
[32m+[m[32m      maxFilesSize: Infinity,[m
[32m+[m[32m      autoFields: false,[m
[32m+[m[32m      autoFiles: false,[m
[32m+[m[32m    });[m
[32m+[m
[32m+[m[32m    const req = new Readable({ read: () => {} });[m
[32m+[m[32m    req.headers = {[m
[32m+[m[32m      'content-type': `multipart/form-data; boundary=${boundary}`,[m
[32m+[m[32m    };[m
[32m+[m
[32m+[m[32m    function hijack(name, fn) {[m
[32m+[m[32m      const oldFn = form[name];[m
[32m+[m[32m      form[name] = function() {[m
[32m+[m[32m        fn();[m
[32m+[m[32m        return oldFn.apply(this, arguments);[m
[32m+[m[32m      };[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    hijack('onParseHeaderField', () => {[m
[32m+[m[32m      ++calls.headerField;[m
[32m+[m[32m    });[m
[32m+[m[32m    hijack('onParseHeaderValue', () => {[m
[32m+[m[32m      ++calls.headerValue;[m
[32m+[m[32m    });[m
[32m+[m[32m    hijack('onParsePartBegin', () => {[m
[32m+[m[32m      ++calls.partBegin;[m
[32m+[m[32m    });[m
[32m+[m[32m    hijack('onParsePartData', () => {[m
[32m+[m[32m      ++calls.partData;[m
[32m+[m[32m    });[m
[32m+[m[32m    hijack('onParsePartEnd', () => {[m
[32m+[m[32m      ++calls.partEnd;[m
[32m+[m[32m    });[m
[32m+[m
[32m+[m[32m    form.on('close', () => {[m
[32m+[m[32m      ++calls.end;[m
[32m+[m[32m      console.timeEnd(moduleName);[m
[32m+[m[32m    }).on('part', (p) => p.resume());[m
[32m+[m
[32m+[m[32m    console.time(moduleName);[m
[32m+[m[32m    form.parse(req);[m
[32m+[m[32m    for (const buf of buffers)[m
[32m+[m[32m      req.push(buf);[m
[32m+[m[32m    req.push(null);[m
[32m+[m
[32m+[m[32m    break;[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  default:[m
[32m+[m[32m    if (moduleName === undefined)[m
[32m+[m[32m      console.error('Missing parser module name');[m
[32m+[m[32m    else[m
[32m+[m[32m      console.error(`Invalid parser module name: ${moduleName}`);[m
[32m+[m[32m    process.exit(1);[m
[32m+[m[32m}[m
[1mdiff --git a/node_modules/busboy/bench/bench-multipart-fields-100mb-small.js b/node_modules/busboy/bench/bench-multipart-fields-100mb-small.js[m
[1mnew file mode 100644[m
[1mindex 0000000..f32d421[m
[1m--- /dev/null[m
[1m+++ b/node_modules/busboy/bench/bench-multipart-fields-100mb-small.js[m
[36m@@ -0,0 +1,143 @@[m
[32m+[m[32m'use strict';[m
[32m+[m
[32m+[m[32mfunction createMultipartBuffers(boundary, sizes) {[m
[32m+[m[32m  const bufs = [];[m
[32m+[m[32m  for (let i = 0; i < sizes.length; ++i) {[m
[32m+[m[32m    const mb = sizes[i] * 1024 * 1024;[m
[32m+[m[32m    bufs.push(Buffer.from([[m
[32m+[m[32m      `--${boundary}`,[m
[32m+[m[32m      `content-disposition: form-data; name="field${i + 1}"`,[m
[32m+[m[32m      '',[m
[32m+[m[32m      '0'.repeat(mb),[m
[32m+[m[32m      '',[m
[32m+[m[32m    ].join('\r\n')));[m
[32m+[m[32m  }[m
[32m+[m[32m  bufs.push(Buffer.from([[m
[32m+[m[32m    `--${boundary}--`,[m
[32m+[m[32m    '',[m
[32m+[m[32m  ].join('\r\n')));[m
[32m+[m[32m  return bufs;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mconst boundary = '-----------------------------168072824752491622650073';[m
[32m+[m[32mconst buffers = createMultipartBuffers(boundary, (new Array(100)).fill(1));[m
[32m+[m[32mconst calls = {[m
[32m+[m[32m  partBegin: 0,[m
[32m+[m[32m  headerField: 0,[m
[32m+[m[32m  headerValue: 0,[m
[32m+[m[32m  headerEnd: 0,[m
[32m+[m[32m  headersEnd: 0,[m
[32m+[m[32m  partData: 0,[m
[32m+[m[32m  partEnd: 0,[m
[32m+[m[32m  end: 0,[m
[32m+[m[32m};[m
[32m+[m
[32m+[m[32mconst moduleName = process.argv[2];[m
[32m+[m[32mswitch (moduleName) {[m
[32m+[m[32m  case 'busboy': {[m
[32m+[m[32m    const busboy = require('busboy');[m
[32m+[m
[32m+[m[32m    const parser = busboy({[m
[32m+[m[32m      limits: {[m
[32m+[m[32m        fieldSizeLimit: Infinity,[m
[32m+[m[32m      },[m
[32m+[m[32m      headers: {[m
[32m+[m[32m        'content-type': `multipart/form-data; boundary=${boundary}`,[m
[32m+[m[32m      },[m
[32m+[m[32m    });[m
[32m+[m[32m    parser.on('field', (name, val, info) => {[m
[32m+[m[32m      ++calls.partBegin;[m
[32m+[m[32m      ++calls.partData;[m
[32m+[m[32m      ++calls.partEnd;[m
[32m+[m[32m    }).on('close', () => {[m
[32m+[m[32m      ++calls.end;[m
[32m+[m[32m      console.timeEnd(moduleName);[m
[32m+[m[32m    });[m
[32m+[m
[32m+[m[32m    console.time(moduleName);[m
[32m+[m[32m    for (const buf of buffers)[m
[32m+[m[32m      parser.write(buf);[m
[32m+[m[32m    break;[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  case 'formidable': {[m
[32m+[m[32m    const { MultipartParser } = require('formidable');[m
[32m+[m
[32m+[m[32m    const parser = new MultipartParser();[m
[32m+[m[32m    parser.initWithBoundary(boundary);[m
[32m+[m[32m    parser.on('data', ({ name }) => {[m
[32m+[m[32m      ++calls[name];[m
[32m+[m[32m      if (name === 'end')[m
[32m+[m[32m        console.timeEnd(moduleName);[m
[32m+[m[32m    });[m
[32m+[m
[32m+[m[32m    console.time(moduleName);[m
[32m+[m[32m    for (const buf of buffers)[m
[32m+[m[32m      parser.write(buf);[m
[32m+[m
[32m+[m[32m    break;[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  case 'multiparty': {[m
[32m+[m[32m    const { Readable } = require('stream');[m
[32m+[m
[32m+[m[32m    const { Form } = require('multiparty');[m
[32m+[m
[32m+[m[32m    const form = new Form({[m
[32m+[m[32m      maxFieldsSize: Infinity,[m
[32m+[m[32m      maxFields: Infinity,[m
[32m+[m[32m      maxFilesSize: Infinity,[m
[32m+[m[32m      autoFields: false,[m
[32m+[m[32m      autoFiles: false,[m
[32m+[m[32m    });[m
[32m+[m
[32m+[m[32m    const req = new Readable({ read: () => {} });[m
[32m+[m[32m    req.headers = {[m
[32m+[m[32m      'content-type': `multipart/form-data; boundary=${boundary}`,[m
[32m+[m[32m    };[m
[32m+[m
[32m+[m[32m    function hijack(name, fn) {[m
[32m+[m[32m      const oldFn = form[name];[m
[32m+[m[32m      form[name] = function() {[m
[32m+[m[32m        fn();[m
[32m+[m[32m        return oldFn.apply(this, arguments);[m
[32m+[m[32m      };[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    hijack('onParseHeaderField', () => {[m
[32m+[m[32m      ++calls.headerField;[m
[32m+[m[32m    });[m
[32m+[m[32m    hijack('onParseHeaderValue', () => {[m
[32m+[m[32m      ++calls.headerValue;[m
[32m+[m[32m    });[m
[32m+[m[32m    hijack('onParsePartBegin', () => {[m
[32m+[m[32m      ++calls.partBegin;[m
[32m+[m[32m    });[m
[32m+[m[32m    hijack('onParsePartData', () => {[m
[32m+[m[32m      ++calls.partData;[m
[32m+[m[32m    });[m
[32m+[m[32m    hijack('onParsePartEnd', () => {[m
[32m+[m[32m      ++calls.partEnd;[m
[32m+[m[32m    });[m
[32m+[m
[32m+[m[32m    form.on('close', () => {[m
[32m+[m[32m      ++calls.end;[m
[32m+[m[32m      console.timeEnd(moduleName);[m
[32m+[m[32m    }).on('part', (p) => p.resume());[m
[32m+[m
[32m+[m[32m    console.time(moduleName);[m
[32m+[m[32m    form.parse(req);[m
[32m+[m[32m    for (const buf of buffers)[m
[32m+[m[32m      req.push(buf);[m
[32m+[m[32m    req.push(null);[m
[32m+[m
[32m+[m[32m    break;[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  default:[m
[32m+[m[32m    if (moduleName === undefined)[m
[32m+[m[32m      console.error('Missing parser module name');[m
[32m+[m[32m    else[m
[32m+[m[32m      console.error(`Invalid parser module name: ${moduleName}`);[m
[32m+[m[32m    process.exit(1);[m
[32m+[m[32m}[m
[1mdiff --git a/node_modules/busboy/bench/bench-multipart-files-100mb-big.js b/node_modules/busboy/bench/bench-multipart-files-100mb-big.js[m
[1mnew file mode 100644[m
[1mindex 0000000..b46bdee[m
[1m--- /dev/null[m
[1m+++ b/node_modules/busboy/bench/bench-multipart-files-100mb-big.js[m
[36m@@ -0,0 +1,154 @@[m
[32m+[m[32m'use strict';[m
[32m+[m
[32m+[m[32mfunction createMultipartBuffers(boundary, sizes) {[m
[32m+[m[32m  const bufs = [];[m
[32m+[m[32m  for (let i = 0; i < sizes.length; ++i) {[m
[32m+[m[32m    const mb = sizes[i] * 1024 * 1024;[m
[32m+[m[32m    bufs.push(Buffer.from([[m
[32m+[m[32m      `--${boundary}`,[m
[32m+[m[32m      `content-disposition: form-data; name="file${i + 1}"; `[m
[32m+[m[32m        + `filename="random${i + 1}.bin"`,[m
[32m+[m[32m      'content-type: application/octet-stream',[m
[32m+[m[32m      '',[m
[32m+[m[32m      '0'.repeat(mb),[m
[32m+[m[32m      '',[m
[32m+[m[32m    ].join('\r\n')));[m
[32m+[m[32m  }[m
[32m+[m[32m  bufs.push(Buffer.from([[m
[32m+[m[32m    `--${boundary}--`,[m
[32m+[m[32m    '',[m
[32m+[m[32m  ].join('\r\n')));[m
[32m+[m[32m  return bufs;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mconst boundary = '-----------------------------168072824752491622650073';[m
[32m+[m[32mconst buffers = createMultipartBuffers(boundary, [[m
[32m+[m[32m  10,[m
[32m+[m[32m  10,[m
[32m+[m[32m  10,[m
[32m+[m[32m  20,[m
[32m+[m[32m  50,[m
[32m+[m[32m]);[m
[32m+[m[32mconst calls = {[m
[32m+[m[32m  partBegin: 0,[m
[32m+[m[32m  headerField: 0,[m
[32m+[m[32m  headerValue: 0,[m
[32m+[m[32m  headerEnd: 0,[m
[32m+[m[32m  headersEnd: 0,[m
[32m+[m[32m  partData: 0,[m
[32m+[m[32m  partEnd: 0,[m
[32m+[m[32m  end: 0,[m
[32m+[m[32m};[m
[32m+[m
[32m+[m[32mconst moduleName = process.argv[2];[m
[32m+[m[32mswitch (moduleName) {[m
[32m+[m[32m  case 'busboy': {[m
[32m+[m[32m    const busboy = require('busboy');[m
[32m+[m
[32m+[m[32m    const parser = busboy({[m
[32m+[m[32m      limits: {[m
[32m+[m[32m        fieldSizeLimit: Infinity,[m
[32m+[m[32m      },[m
[32m+[m[32m      headers: {[m
[32m+[m[32m        'content-type': `multipart/form-data; boundary=${boundary}`,[m
[32m+[m[32m      },[m
[32m+[m[32m    });[m
[32m+[m[32m    parser.on('file', (name, stream, info) => {[m
[32m+[m[32m      ++calls.partBegin;[m
[32m+[m[32m      stream.on('data', (chunk) => {[m
[32m+[m[32m        ++calls.partData;[m
[32m+[m[32m      }).on('end', () => {[m
[32m+[m[32m        ++calls.partEnd;[m
[32m+[m[32m      });[m
[32m+[m[32m    }).on('close', () => {[m
[32m+[m[32m      ++calls.end;[m
[32m+[m[32m      console.timeEnd(moduleName);[m
[32m+[m[32m    });[m
[32m+[m
[32m+[m[32m    console.time(moduleName);[m
[32m+[m[32m    for (const buf of buffers)[m
[32m+[m[32m      parser.write(buf);[m
[32m+[m[32m    break;[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  case 'formidable': {[m
[32m+[m[32m    const { MultipartParser } = require('formidable');[m
[32m+[m
[32m+[m[32m    const parser = new MultipartParser();[m
[32m+[m[32m    parser.initWithBoundary(boundary);[m
[32m+[m[32m    parser.on('data', ({ name }) => {[m
[32m+[m[32m      ++calls[name];[m
[32m+[m[32m      if (name === 'end')[m
[32m+[m[32m        console.timeEnd(moduleName);[m
[32m+[m[32m    });[m
[32m+[m
[32m+[m[32m    console.time(moduleName);[m
[32m+[m[32m    for (const buf of buffers)[m
[32m+[m[32m      parser.write(buf);[m
[32m+[m
[32m+[m[32m    break;[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  case 'multiparty': {[m
[32m+[m[32m    const { Readable } = require('stream');[m
[32m+[m
[32m+[m[32m    const { Form } = require('multiparty');[m
[32m+[m
[32m+[m[32m    const form = new Form({[m
[32m+[m[32m      maxFieldsSize: Infinity,[m
[32m+[m[32m      maxFields: Infinity,[m
[32m+[m[32m      maxFilesSize: Infinity,[m
[32m+[m[32m      autoFields: false,[m
[32m+[m[32m      autoFiles: false,[m
[32m+[m[32m    });[m
[32m+[m
[32m+[m[32m    const req = new Readable({ read: () => {} });[m
[32m+[m[32m    req.headers = {[m
[32m+[m[32m      'content-type': `multipart/form-data; boundary=${boundary}`,[m
[32m+[m[32m    };[m
[32m+[m
[32m+[m[32m    function hijack(name, fn) {[m
[32m+[m[32m      const oldFn = form[name];[m
[32m+[m[32m      form[name] = function() {[m
[32m+[m[32m        fn();[m
[32m+[m[32m        return oldFn.apply(this, arguments);[m
[32m+[m[32m      };[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    hijack('onParseHeaderField', () => {[m
[32m+[m[32m      ++calls.headerField;[m
[32m+[m[32m    });[m
[32m+[m[32m    hijack('onParseHeaderValue', () => {[m
[32m+[m[32m      ++calls.headerValue;[m
[32m+[m[32m    });[m
[32m+[m[32m    hijack('onParsePartBegin', () => {[m
[32m+[m[32m      ++calls.partBegin;[m
[32m+[m[32m    });[m
[32m+[m[32m    hijack('onParsePartData', () => {[m
[32m+[m[32m      ++calls.partData;[m
[32m+[m[32m    });[m
[32m+[m[32m    hijack('onParsePartEnd', () => {[m
[32m+[m[32m      ++calls.partEnd;[m
[32m+[m[32m    });[m
[32m+[m
[32m+[m[32m    form.on('close', () => {[m
[32m+[m[32m      ++calls.end;[m
[32m+[m[32m      console.timeEnd(moduleName);[m
[32m+[m[32m    }).on('part', (p) => p.resume());[m
[32m+[m
[32m+[m[32m    console.time(moduleName);[m
[32m+[m[32m    form.parse(req);[m
[32m+[m[32m    for (const buf of buffers)[m
[32m+[m[32m      req.push(buf);[m
[32m+[m[32m    req.push(null);[m
[32m+[m
[32m+[m[32m    break;[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  default:[m
[32m+[m[32m    if (moduleName === undefined)[m
[32m+[m[32m      console.error('Missing parser module name');[m
[32m+[m[32m    else[m
[32m+[m[32m      console.error(`Invalid parser module name: ${moduleName}`);[m
[32m+[m[32m    process.exit(1);[m
[32m+[m[32m}[m
[1mdiff --git a/node_modules/busboy/bench/bench-multipart-files-100mb-small.js b/node_modules/busboy/bench/bench-multipart-files-100mb-small.js[m
[1mnew file mode 100644[m
[1mindex 0000000..46b5dff[m
[1m--- /dev/null[m
[1m+++ b/node_modules/busboy/bench/bench-multipart-files-100mb-small.js[m
[36m@@ -0,0 +1,148 @@[m
[32m+[m[32m'use strict';[m
[32m+[m
[32m+[m[32mfunction createMultipartBuffers(boundary, sizes) {[m
[32m+[m[32m  const bufs = [];[m
[32m+[m[32m  for (let i = 0; i < sizes.length; ++i) {[m
[32m+[m[32m    const mb = sizes[i] * 1024 * 1024;[m
[32m+[m[32m    bufs.push(Buffer.from([[m
[32m+[m[32m      `--${boundary}`,[m
[32m+[m[32m      `content-disposition: form-data; name="file${i + 1}"; `[m
[32m+[m[32m        + `filename="random${i + 1}.bin"`,[m
[32m+[m[32m      'content-type: application/octet-stream',[m
[32m+[m[32m      '',[m
[32m+[m[32m      '0'.repeat(mb),[m
[32m+[m[32m      '',[m
[32m+[m[32m    ].join('\r\n')));[m
[32m+[m[32m  }[m
[32m+[m[32m  bufs.push(Buffer.from([[m
[32m+[m[32m    `--${boundary}--`,[m
[32m+[m[32m    '',[m
[32m+[m[32m  ].join('\r\n')));[m
[32m+[m[32m  return bufs;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mconst boundary = '-----------------------------168072824752491622650073';[m
[32m+[m[32mconst buffers = createMultipartBuffers(boundary, (new Array(100)).fill(1));[m
[32m+[m[32mconst calls = {[m
[32m+[m[32m  partBegin: 0,[m
[32m+[m[32m  headerField: 0,[m
[32m+[m[32m  headerValue: 0,[m
[32m+[m[32m  headerEnd: 0,[m
[32m+[m[32m  headersEnd: 0,[m
[32m+[m[32m  partData: 0,[m
[32m+[m[32m  partEnd: 0,[m
[32m+[m[32m  end: 0,[m
[32m+[m[32m};[m
[32m+[m
[32m+[m[32mconst moduleName = process.argv[2];[m
[32m+[m[32mswitch (moduleName) {[m
[32m+[m[32m  case 'busboy': {[m
[32m+[m[32m    const busboy = require('busboy');[m
[32m+[m
[32m+[m[32m    const parser = busboy({[m
[32m+[m[32m      limits: {[m
[32m+[m[32m        fieldSizeLimit: Infinity,[m
[32m+[m[32m      },[m
[32m+[m[32m      headers: {[m
[32m+[m[32m        'content-type': `multipart/form-data; boundary=${boundary}`,[m
[32m+[m[32m      },[m
[32m+[m[32m    });[m
[32m+[m[32m    parser.on('file', (name, stream, info) => {[m
[32m+[m[32m      ++calls.partBegin;[m
[32m+[m[32m      stream.on('data', (chunk) => {[m
[32m+[m[32m        ++calls.partData;[m
[32m+[m[32m      }).on('end', () => {[m
[32m+[m[32m        ++calls.partEnd;[m
[32m+[m[32m      });[m
[32m+[m[32m    }).on('close', () => {[m
[32m+[m[32m      ++calls.end;[m
[32m+[m[32m      console.timeEnd(moduleName);[m
[32m+[m[32m    });[m
[32m+[m
[32m+[m[32m    console.time(moduleName);[m
[32m+[m[32m    for (const buf of buffers)[m
[32m+[m[32m      parser.write(buf);[m
[32m+[m[32m    break;[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  case 'formidable': {[m
[32m+[m[32m    const { MultipartParser } = require('formidable');[m
[32m+[m
[32m+[m[32m    const parser = new MultipartParser();[m
[32m+[m[32m    parser.initWithBoundary(boundary);[m
[32m+[m[32m    parser.on('data', ({ name }) => {[m
[32m+[m[32m      ++calls[name];[m
[32m+[m[32m      if (name === 'end')[m
[32m+[m[32m        console.timeEnd(moduleName);[m
[32m+[m[32m    });[m
[32m+[m
[32m+[m[32m    console.time(moduleName);[m
[32m+[m[32m    for (const buf of buffers)[m
[32m+[m[32m      parser.write(buf);[m
[32m+[m
[32m+[m[32m    break;[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  case 'multiparty': {[m
[32m+[m[32m    const { Readable } = require('stream');[m
[32m+[m
[32m+[m[32m    const { Form } = require('multiparty');[m
[32m+[m
[32m+[m[32m    const form = new Form({[m
[32m+[m[32m      maxFieldsSize: Infinity,[m
[32m+[m[32m      maxFields: Infinity,[m
[32m+[m[32m      maxFilesSize: Infinity,[m
[32m+[m[32m      autoFields: false,[m
[32m+[m[32m      autoFiles: false,[m
[32m+[m[32m    });[m
[32m+[m
[32m+[m[32m    const req = new Readable({ read: () => {} });[m
[32m+[m[32m    req.headers = {[m
[32m+[m[32m      'content-type': `multipart/form-data; boundary=${boundary}`,[m
[32m+[m[32m    };[m
[32m+[m
[32m+[m[32m    function hijack(name, fn) {[m
[32m+[m[32m      const oldFn = form[name];[m
[32m+[m[32m      form[name] = function() {[m
[32m+[m[32m        fn();[m
[32m+[m[32m        return oldFn.apply(this, arguments);[m
[32m+[m[32m      };[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    hijack('onParseHeaderField', () => {[m
[32m+[m[32m      ++calls.headerField;[m
[32m+[m[32m    });[m
[32m+[m[32m    hijack('onParseHeaderValue', () => {[m
[32m+[m[32m      ++calls.headerValue;[m
[32m+[m[32m    });[m
[32m+[m[32m    hijack('onParsePartBegin', () => {[m
[32m+[m[32m      ++calls.partBegin;[m
[32m+[m[32m    });[m
[32m+[m[32m    hijack('onParsePartData', () => {[m
[32m+[m[32m      ++calls.partData;[m
[32m+[m[32m    });[m
[32m+[m[32m    hijack('onParsePartEnd', () => {[m
[32m+[m[32m      ++calls.partEnd;[m
[32m+[m[32m    });[m
[32m+[m
[32m+[m[32m    form.on('close', () => {[m
[32m+[m[32m      ++calls.end;[m
[32m+[m[32m      console.timeEnd(moduleName);[m
[32m+[m[32m    }).on('part', (p) => p.resume());[m
[32m+[m
[32m+[m[32m    console.time(moduleName);[m
[32m+[m[32m    form.parse(req);[m
[32m+[m[32m    for (const buf of buffers)[m
[32m+[m[32m      req.push(buf);[m
[32m+[m[32m    req.push(null);[m
[32m+[m
[32m+[m[32m    break;[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  default:[m
[32m+[m[32m    if (moduleName === undefined)[m
[32m+[m[32m      console.error('Missing parser module name');[m
[32m+[m[32m    else[m
[32m+[m[32m      console.error(`Invalid parser module name: ${moduleName}`);[m
[32m+[m[32m    process.exit(1);[m
[32m+[m[32m}[m
[1mdiff --git a/node_modules/busboy/bench/bench-urlencoded-fields-100pairs-small.js b/node_modules/busboy/bench/bench-urlencoded-fields-100pairs-small.js[m
[1mnew file mode 100644[m
[1mindex 0000000..5c337df[m
[1m--- /dev/null[m
[1m+++ b/node_modules/busboy/bench/bench-urlencoded-fields-100pairs-small.js[m
[36m@@ -0,0 +1,101 @@[m
[32m+[m[32m'use strict';[m
[32m+[m
[32m+[m[32mconst buffers = [[m
[32m+[m[32m  Buffer.from([m
[32m+[m[32m    (new Array(100)).fill('').map((_, i) => `key${i}=value${i}`).join('&')[m
[32m+[m[32m  ),[m
[32m+[m[32m];[m
[32m+[m[32mconst calls = {[m
[32m+[m[32m  field: 0,[m
[32m+[m[32m  end: 0,[m
[32m+[m[32m};[m
[32m+[m
[32m+[m[32mlet n = 3e3;[m
[32m+[m
[32m+[m[32mconst moduleName = process.argv[2];[m
[32m+[m[32mswitch (moduleName) {[m
[32m+[m[32m  case 'busboy': {[m
[32m+[m[32m    const busboy = require('busboy');[m
[32m+[m
[32m+[m[32m    console.time(moduleName);[m
[32m+[m[32m    (function next() {[m
[32m+[m[32m      const parser = busboy({[m
[32m+[m[32m        limits: {[m
[32m+[m[32m          fieldSizeLimit: Infinity,[m
[32m+[m[32m        },[m
[32m+[m[32m        headers: {[m
[32m+[m[32m          'content-type': 'application/x-www-form-urlencoded; charset=utf-8',[m
[32m+[m[32m        },[m
[32m+[m[32m      });[m
[32m+[m[32m      parser.on('field', (name, val, info) => {[m
[32m+[m[32m        ++calls.field;[m
[32m+[m[32m      }).on('close', () => {[m
[32m+[m[32m        ++calls.end;[m
[32m+[m[32m        if (--n === 0)[m
[32m+[m[32m          console.timeEnd(moduleName);[m
[32m+[m[32m        else[m
[32m+[m[32m          process.nextTick(next);[m
[32m+[m[32m      });[m
[32m+[m
[32m+[m[32m      for (const buf of buffers)[m
[32m+[m[32m        parser.write(buf);[m
[32m+[m[32m      parser.end();[m
[32m+[m[32m    })();[m
[32m+[m[32m    break;[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  case 'formidable': {[m
[32m+[m[32m    const QuerystringParser =[m
[32m+[m[32m      require('formidable/src/parsers/Querystring.js');[m
[32m+[m
[32m+[m[32m    console.time(moduleName);[m
[32m+[m[32m    (function next() {[m
[32m+[m[32m      const parser = new QuerystringParser();[m
[32m+[m[32m      parser.on('data', (obj) => {[m
[32m+[m[32m        ++calls.field;[m
[32m+[m[32m      }).on('end', () => {[m
[32m+[m[32m        ++calls.end;[m
[32m+[m[32m        if (--n === 0)[m
[32m+[m[32m          console.timeEnd(moduleName);[m
[32m+[m[32m        else[m
[32m+[m[32m          process.nextTick(next);[m
[32m+[m[32m      });[m
[32m+[m
[32m+[m[32m      for (const buf of buffers)[m
[32m+[m[32m        parser.write(buf);[m
[32m+[m[32m      parser.end();[m
[32m+[m[32m    })();[m
[32m+[m[32m    break;[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  case 'formidable-streaming': {[m
[32m+[m[32m    const QuerystringParser =[m
[32m+[m[32m      require('formidable/src/parsers/StreamingQuerystring.js');[m
[32m+[m
[32m+[m[32m    console.time(moduleName);[m
[32m+[m[32m    (function next() {[m
[32m+[m[32m      const parser = new QuerystringParser();[m
[32m+[m[32m      parser.on('data', (obj) => {[m
[32m+[m[32m        ++calls.field;[m
[32m+[m[32m      }).on('end', () => {[m
[32m+[m[32m        ++calls.end;[m
[32m+[m[32m        if (--n === 0)[m
[32m+[m[32m          console.timeEnd(moduleName);[m
[32m+[m[32m        else[m
[32m+[m[32m          process.nextTick(next);[m
[32m+[m[32m      });[m
[32m+[m
[32m+[m[32m      for (const buf of buffers)[m
[32m+[m[32m        parser.write(buf);[m
[32m+[m[32m      parser.end();[m
[32m+[m[32m    })();[m
[32m+[m[32m    break;[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  default:[m
[32m+[m[32m    if (moduleName === undefined)[m
[32m+[m[32m      console.error('Missing parser module name');[m
[32m+[m[32m    else[m
[32m+[m[32m      console.error(`Invalid parser module name: ${moduleName}`);[m
[32m+[m[32m    process.exit(1);[m
[32m+[m[32m}[m
[1mdiff --git a/node_modules/busboy/bench/bench-urlencoded-fields-900pairs-small-alt.js b/node_modules/busboy/bench/bench-urlencoded-fields-900pairs-small-alt.js[m
[1mnew file mode 100644[m
[1mindex 0000000..1f5645c[m
[1m--- /dev/null[m
[1m+++ b/node_modules/busboy/bench/bench-urlencoded-fields-900pairs-small-alt.js[m
[36m@@ -0,0 +1,84 @@[m
[32m+[m[32m'use strict';[m
[32m+[m
[32m+[m[32mconst buffers = [[m
[32m+[m[32m  Buffer.from([m
[32m+[m[32m    (new Array(900)).fill('').map((_, i) => `key${i}=value${i}`).join('&')[m
[32m+[m[32m  ),[m
[32m+[m[32m];[m
[32m+[m[32mconst calls = {[m
[32m+[m[32m  field: 0,[m
[32m+[m[32m  end: 0,[m
[32m+[m[32m};[m
[32m+[m
[32m+[m[32mconst moduleName = process.argv[2];[m
[32m+[m[32mswitch (moduleName) {[m
[32m+[m[32m  case 'busboy': {[m
[32m+[m[32m    const busboy = require('busboy');[m
[32m+[m
[32m+[m[32m    console.time(moduleName);[m
[32m+[m[32m    const parser = busboy({[m
[32m+[m[32m      limits: {[m
[32m+[m[32m        fieldSizeLimit: Infinity,[m
[32m+[m[32m      },[m
[32m+[m[32m      headers: {[m
[32m+[m[32m        'content-type': 'application/x-www-form-urlencoded; charset=utf-8',[m
[32m+[m[32m      },[m
[32m+[m[32m    });[m
[32m+[m[32m    parser.on('field', (name, val, info) => {[m
[32m+[m[32m      ++calls.field;[m
[32m+[m[32m    }).on('close', () => {[m
[32m+[m[32m      ++calls.end;[m
[32m+[m[32m      console.timeEnd(moduleName);[m
[32m+[m[32m    });[m
[32m+[m
[32m+[m[32m    for (const buf of buffers)[m
[32m+[m[32m      parser.write(buf);[m
[32m+[m[32m    parser.end();[m
[32m+[m[32m    break;[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  case 'formidable': {[m
[32m+[m[32m    const QuerystringParser =[m
[32m+[m[32m      require('formidable/src/parsers/Querystring.js');[m
[32m+[m
[32m+[m[32m    console.time(moduleName);[m
[32m+[m[32m    const parser = new QuerystringParser();[m
[32m+[m[32m    parser.on('data', (obj) => {[m
[32m+[m[32m      ++calls.field;[m
[32m+[m[32m    }).on('end', () => {[m
[32m+[m[32m      ++calls.end;[m
[32m+[m[32m      console.timeEnd(moduleName);[m
[32m+[m[32m    });[m
[32m+[m
[32m+[m[32m    for (const buf of buffers)[m
[32m+[m[32m      parser.write(buf);[m
[32m+[m[32m    parser.end();[m
[32m+[m[32m    break;[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  case 'formidable-streaming': {[m
[32m+[m[32m    const QuerystringParser =[m
[32m+[m[32m      require('formidable/src/parsers/StreamingQuerystring.js');[m
[32m+[m
[32m+[m[32m    console.time(moduleName);[m
[32m+[m[32m    const parser = new QuerystringParser();[m
[32m+[m[32m    parser.on('data', (obj) => {[m
[32m+[m[32m      ++calls.field;[m
[32m+[m[32m    }).on('end', () => {[m
[32m+[m[32m      ++calls.end;[m
[32m+[m[32m      console.timeEnd(moduleName);[m
[32m+[m[32m    });[m
[32m+[m
[32m+[m[32m    for (const buf of buffers)[m
[32m+[m[32m      parser.write(buf);[m
[32m+[m[32m    parser.end();[m
[32m+[m[32m    break;[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  default:[m
[32m+[m[32m    if (moduleName === undefined)[m
[32m+[m[32m      console.error('Missing parser module name');[m
[32m+[m[32m    else[m
[32m+[m[32m      console.error(`Invalid parser module name: ${moduleName}`);[m
[32m+[m[32m    process.exit(1);[m
[32m+[m[32m}[m
[1mdiff --git a/node_modules/busboy/lib/index.js b/node_modules/busboy/lib/index.js[m
[1mnew file mode 100644[m
[1mindex 0000000..873272d[m
[1m--- /dev/null[m
[1m+++ b/node_modules/busboy/lib/index.js[m
[36m@@ -0,0 +1,57 @@[m
[32m+[m[32m'use strict';[m
[32m+[m
[32m+[m[32mconst { parseContentType } = require('./utils.js');[m
[32m+[m
[32m+[m[32mfunction getInstance(cfg) {[m
[32m+[m[32m  const headers = cfg.headers;[m
[32m+[m[32m  const conType = parseContentType(headers['content-type']);[m
[32m+[m[32m  if (!conType)[m
[32m+[m[32m    throw new Error('Malformed content type');[m
[32m+[m
[32m+[m[32m  for (const type of TYPES) {[m
[32m+[m[32m    const matched = type.detect(conType);[m
[32m+[m[32m    if (!matched)[m
[32m+[m[32m      continue;[m
[32m+[m
[32m+[m[32m    const instanceCfg = {[m
[32m+[m[32m      limits: cfg.limits,[m
[32m+[m[32m      headers,[m
[32m+[m[32m      conType,[m
[32m+[m[32m      highWaterMark: undefined,[m
[32m+[m[32m      fileHwm: undefined,[m
[32m+[m[32m      defCharset: undefined,[m
[32m+[m[32m      defParamCharset: undefined,[m
[32m+[m[32m      preservePath: false,[m
[32m+[m[32m    };[m
[32m+[m[32m    if (cfg.highWaterMark)[m
[32m+[m[32m      instanceCfg.highWaterMark = cfg.highWaterMark;[m
[32m+[m[32m    if (cfg.fileHwm)[m
[32m+[m[32m      instanceCfg.fileHwm = cfg.fileHwm;[m
[32m+[m[32m    instanceCfg.defCharset = cfg.defCharset;[m
[32m+[m[32m    instanceCfg.defParamCharset = cfg.defParamCharset;[m
[32m+[m[32m    instanceCfg.preservePath = cfg.preservePath;[m
[32m+[m[32m    return new type(instanceCfg);[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  throw new Error(`Unsupported content type: ${headers['content-type']}`);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m// Note: types are explicitly listed here for easier bundling[m
[32m+[m[32m// See: https://github.com/mscdex/busboy/issues/121[m
[32m+[m[32mconst TYPES = [[m
[32m+[m[32m  require('./types/multipart'),[m
[32m+[m[32m  require('./types/urlencoded'),[m
[32m+[m[32m].filter(function(typemod) { return typeof typemod.detect === 'function'; });[m
[32m+[m
[32m+[m[32mmodule.exports = (cfg) => {[m
[32m+[m[32m  if (typeof cfg !== 'object' || cfg === null)[m
[32m+[m[32m    cfg = {};[m
[32m+[m
[32m+[m[32m  if (typeof cfg.headers !== 'object'[m
[32m+[m[32m      || cfg.headers === null[m
[32m+[m[32m      || typeof cfg.headers['content-type'] !== 'string') {[m
[32m+[m[32m    throw new Error('Missing Content-Type');[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  return getInstance(cfg);[m
[32m+[m[32m};[m
[1mdiff --git a/node_modules/busboy/lib/types/multipart.js b/node_modules/busboy/lib/types/multipart.js[m
[1mnew file mode 100644[m
[1mindex 0000000..cc0d7bb[m
[1m--- /dev/null[m
[1m+++ b/node_modules/busboy/lib/types/multipart.js[m
[36m@@ -0,0 +1,653 @@[m
[32m+[m[32m'use strict';[m
[32m+[m
[32m+[m[32mconst { Readable, Writable } = require('stream');[m
[32m+[m
[32m+[m[32mconst StreamSearch = require('streamsearch');[m
[32m+[m
[32m+[m[32mconst {[m
[32m+[m[32m  basename,[m
[32m+[m[32m  convertToUTF8,[m
[32m+[m[32m  getDecoder,[m
[32m+[m[32m  parseContentType,[m
[32m+[m[32m  parseDisposition,[m
[32m+[m[32m} = require('../utils.js');[m
[32m+[m
[32m+[m[32mconst BUF_CRLF = Buffer.from('\r\n');[m
[32m+[m[32mconst BUF_CR = Buffer.from('\r');[m
[32m+[m[32mconst BUF_DASH = Buffer.from('-');[m
[32m+[m
[32m+[m[32mfunction noop() {}[m
[32m+[m
[32m+[m[32mconst MAX_HEADER_PAIRS = 2000; // From node[m
[32m+[m[32mconst MAX_HEADER_SIZE = 16 * 1024; // From node (its default value)[m
[32m+[m
[32m+[m[32mconst HPARSER_NAME = 0;[m
[32m+[m[32mconst HPARSER_PRE_OWS = 1;[m
[32m+[m[32mconst HPARSER_VALUE = 2;[m
[32m+[m[32mclass HeaderParser {[m
[32m+[m[32m  constructor(cb) {[m
[32m+[m[32m    this.header = Object.create(null);[m
[32m+[m[32m    this.pairCount = 0;[m
[32m+[m[32m    this.byteCount = 0;[m
[32m+[m[32m    this.state = HPARSER_NAME;[m
[32m+[m[32m    this.name = '';[m
[32m+[m[32m    this.value = '';[m
[32m+[m[32m    this.crlf = 0;[m
[32m+[m[32m    this.cb = cb;[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  reset() {[m
[32m+[m[32m    this.header = Object.create(null);[m
[32m+[m[32m    this.pairCount = 0;[m
[32m+[m[32m    this.byteCount = 0;[m
[32m+[m[32m    this.state = HPARSER_NAME;[m
[32m+[m[32m    this.name = '';[m
[32m+[m[32m    this.value = '';[m
[32m+[m[32m    this.crlf = 0;[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  push(chunk, pos, end) {[m
[32m+[m[32m    let start = pos;[m
[32m+[m[32m    while (pos < end) {[m
[32m+[m[32m      switch (this.state) {[m
[32m+[m[32m        case HPARSER_NAME: {[m
[32m+[m[32m          let done = false;[m
[32m+[m[32m          for (; pos < end; ++pos) {[m
[32m+[m[32m            if (this.byteCount === MAX_HEADER_SIZE)[m
[32m+[m[32m              return -1;[m
[32m+[m[32m            ++this.byteCount;[m
[32m+[m[32m            const code = chunk[pos];[m
[32m+[m[32m            if (TOKEN[code] !== 1) {[m
[32m+[m[32m              if (code !== 58/* ':' */)[m
[32m+[m[32m                return -1;[m
[32m+[m[32m              this.name += chunk.latin1Slice(start, pos);[m
[32m+[m[32m              if (this.name.length === 0)[m
[32m+[m[32m                return -1;[m
[32m+[m[32m              ++pos;[m
[32m+[m[32m              done = true;[m
[32m+[m[32m              this.state = HPARSER_PRE_OWS;[m
[32m+[m[32m              break;[m
[32m+[m[32m            }[m
[32m+[m[32m          }[m
[32m+[m[32m          if (!done) {[m
[32m+[m[32m            this.name += chunk.latin1Slice(start, pos);[m
[32m+[m[32m            break;[m
[32m+[m[32m          }[m
[32m+[m[32m          // FALLTHROUGH[m
[32m+[m[32m        }[m
[32m+[m[32m        case HPARSER_PRE_OWS: {[m
[32m+[m[32m          // Skip optional whitespace[m
[32m+[m[32m          let done = false;[m
[32m+[m[32m          for (; pos < end; ++pos) {[m
[32m+[m[32m            if (this.byteCount === MAX_HEADER_SIZE)[m
[32m+[m[32m              return -1;[m
[32m+[m[32m            ++this.byteCount;[m
[32m+[m[32m            const code = chunk[pos];[m
[32m+[m[32m            if (code !== 32/* ' ' */ && code !== 9/* '\t' */) {[m
[32m+[m[32m              start = pos;[m
[32m+[m[32m              done = true;[m
[32m+[m[32m              this.state = HPARSER_VALUE;[m
[32m+[m[32m              break;[m
[32m+[m[32m            }[m
[32m+[m[32m          }[m
[32m+[m[32m          if (!done)[m
[32m+[m[32m            break;[m
[32m+[m[32m          // FALLTHROUGH[m
[32m+[m[32m        }[m
[32m+[m[32m        case HPARSER_VALUE:[m
[32m+[m[32m          switch (this.crlf) {[m
[32m+[m[32m            case 0: // Nothing yet[m
[32m+[m[32m              for (; pos < end; ++pos) {[m
[32m+[m[32m                if (this.byteCount === MAX_HEADER_SIZE)[m
[32m+[m[32m                  return -1;[m
[32m+[m[32m                ++this.byteCount;[m
[32m+[m[32m                const code = chunk[pos];[m
[32m+[m[32m                if (FIELD_VCHAR[code] !== 1) {[m
[32m+[m[32m                  if (code !== 13/* '\r' */)[m
[32m+[m[32m                    return -1;[m
[32m+[m[32m                  ++this.crlf;[m
[32m+[m[32m                  break;[m
[32m+[m[32m                }[m
[32m+[m[32m              }[m
[32m+[m[32m              this.value += chunk.latin1Slice(start, pos++);[m
[32m+[m[32m              break;[m
[32m+[m[32m            case 1: // Received CR[m
[32m+[m[32m              if (this.byteCount === MAX_HEADER_SIZE)[m
[32m+[m[32m                return -1;[m
[32m+[m[32m              ++this.byteCount;[m
[32m+[m[32m              if (chunk[pos++] !== 10/* '\n' */)[m
[32m+[m[32m                return -1;[m
[32m+[m[32m              ++this.crlf;[m
[32m+[m[32m              break;[m
[32m+[m[32m            case 2: { // Received CR LF[m
[32m+[m[32m              if (this.byteCount === MAX_HEADER_SIZE)[m
[32m+[m[32m                return -1;[m
[32m+[m[32m              ++this.byteCount;[m
[32m+[m[32m              const code = chunk[pos];[m
[32m+[m[32m              if (code === 32/* ' ' */ || code === 9/* '\t' */) {[m
[32m+[m[32m                // Folded value[m
[32m+[m[32m                start = pos;[m
[32m+[m[32m                this.crlf = 0;[m
[32m+[m[32m              } else {[m
[32m+[m[32m                if (++this.pairCount < MAX_HEADER_PAIRS) {[m
[32m+[m[32m                  this.name = this.name.toLowerCase();[m
[32m+[m[32m                  if (this.header[this.name] === undefined)[m
[32m+[m[32m                    this.header[this.name] = [this.value];[m
[32m+[m[32m                  else[m
[32m+[m[32m                    this.header[this.name].push(this.value);[m
[32m+[m[32m                }[m
[32m+[m[32m                if (code === 13/* '\r' */) {[m
[32m+[m[32m                  ++this.crlf;[m
[32m+[m[32m                  ++pos;[m
[32m+[m[32m                } else {[m
[32m+[m[32m                  // Assume start of next header field name[m
[32m+[m[32m                  start = pos;[m
[32m+[m[32m                  this.crlf = 0;[m
[32m+[m[32m                  this.state = HPARSER_NAME;[m
[32m+[m[32m                  this.name = '';[m
[32m+[m[32m                  this.value = '';[m
[32m+[m[32m                }[m
[32m+[m[32m              }[m
[32m+[m[32m              break;[m
[32m+[m[32m            }[m
[32m+[m[32m            case 3: { // Received CR LF CR[m
[32m+[m[32m              if (this.byteCount === MAX_HEADER_SIZE)[m
[32m+[m[32m                return -1;[m
[32m+[m[32m              ++this.byteCount;[m
[32m+[m[32m              if (chunk[pos++] !== 10/* '\n' */)[m
[32m+[m[32m                return -1;[m
[32m+[m[32m              // End of header[m
[32m+[m[32m              const header = this.header;[m
[32m+[m[32m              this.reset();[m
[32m+[m[32m              this.cb(header);[m
[32m+[m[32m              return pos;[m
[32m+[m[32m            }[m
[32m+[m[32m          }[m
[32m+[m[32m          break;[m
[32m+[m[32m      }[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    return pos;[m
[32m+[m[32m  }[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mclass FileStream extends Readable {[m
[32m+[m[32m  constructor(opts, owner) {[m
[32m+[m[32m    super(opts);[m
[32m+[m[32m    this.truncated = false;[m
[32m+[m[32m    this._readcb = null;[m
[32m+[m[32m    this.once('end', () => {[m
[32m+[m[32m      // We need to make sure that we call any outstanding _writecb() that is[m
[32m+[m[32m      // associated with this file so that processing of the rest of the form[m
[32m+[m[32m      // can continue. This may not happen if the file stream ends right after[m
[32m+[m[32m      // backpressure kicks in, so we force it here.[m
[32m+[m[32m      this._read();[m
[32m+[m[32m      if (--owner._fileEndsLeft === 0 && owner._finalcb) {[m
[32m+[m[32m        const cb = owner._finalcb;[m
[32m+[m[32m        owner._finalcb = null;[m
[32m+[m[32m        // Make sure other 'end' event handlers get a chance to be executed[m
[32m+[m[32m        // before busboy's 'finish' event is emitted[m
[32m+[m[32m        process.nextTick(cb);[m
[32m+[m[32m      }[m
[32m+[m[32m    });[m
[32m+[m[32m  }[m
[32m+[m[32m  _read(n) {[m
[32m+[m[32m    const cb = this._readcb;[m
[32m+[m[32m    if (cb) {[m
[32m+[m[32m      this._readcb = null;[m
[32m+[m[32m      cb();[m
[32m+[m[32m    }[m
[32m+[m[32m  }[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mconst ignoreData = {[m
[32m+[m[32m  push: (chunk, pos) => {},[m
[32m+[m[32m  destroy: () => {},[m
[32m+[m[32m};[m
[32m+[m
[32m+[m[32mfunction callAndUnsetCb(self, err) {[m
[32m+[m[32m  const cb = self._writecb;[m
[32m+[m[32m  self._writecb = null;[m
[32m+[m[32m  if (err)[m
[32m+[m[32m    self.destroy(err);[m
[32m+[m[32m  else if (cb)[m
[32m+[m[32m    cb();[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction nullDecoder(val, hint) {[m
[32m+[m[32m  return val;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mclass Multipart extends Writable {[m
[32m+[m[32m  constructor(cfg) {[m
[32m+[m[32m    const streamOpts = {[m
[32m+[m[32m      autoDestroy: true,[m
[32m+[m[32m      emitClose: true,[m
[32m+[m[32m      highWaterMark: (typeof cfg.highWaterMark === 'number'[m
[32m+[m[32m                      ? cfg.highWaterMark[m
[32m+[m[32m                      : undefined),[m
[32m+[m[32m    };[m
[32m+[m[32m    super(streamOpts);[m
[32m+[m
[32m+[m[32m    if (!cfg.conType.params || typeof cfg.conType.params.boundary !== 'string')[m
[32m+[m[32m      throw new Error('Multipart: Boundary not found');[m
[32m+[m
[32m+[m[32m    const boundary = cfg.conType.params.boundary;[m
[32m+[m[32m    const paramDecoder = (typeof cfg.defParamCharset === 'string'[m
[32m+[m[32m                            && cfg.defParamCharset[m
[32m+[m[32m                          ? getDecoder(cfg.defParamCharset)[m
[32m+[m[32m                          : nullDecoder);[m
[32m+[m[32m    const defCharset = (cfg.defCharset || 'utf8');[m
[32m+[m[32m    const preservePath = cfg.preservePath;[m
[32m+[m[32m    const fileOpts = {[m
[32m+[m[32m      autoDestroy: true,[m
[32m+[m[32m      emitClose: true,[m
[32m+[m[32m      highWaterMark: (typeof cfg.fileHwm === 'number'[m
[32m+[m[32m                      ? cfg.fileHwm[m
[32m+[m[32m                      : undefined),[m
[32m+[m[32m    };[m
[32m+[m
[32m+[m[32m    const limits = cfg.limits;[m
[32m+[m[32m    const fieldSizeLimit = (limits && typeof limits.fieldSize === 'number'[m
[32m+[m[32m                            ? limits.fieldSize[m
[32m+[m[32m                            : 1 * 1024 * 1024);[m
[32m+[m[32m    const fileSizeLimit = (limits && typeof limits.fileSize === 'number'[m
[32m+[m[32m                           ? limits.fileSize[m
[32m+[m[32m                           : Infinity);[m
[32m+[m[32m    const filesLimit = (limits && typeof limits.files === 'number'[m
[32m+[m[32m                        ? limits.files[m
[32m+[m[32m                        : Infinity);[m
[32m+[m[32m    const fieldsLimit = (limits && typeof limits.fields === 'number'[m
[32m+[m[32m                         ? limits.fields[m
[32m+[m[32m                         : Infinity);[m
[32m+[m[32m    const partsLimit = (limits && typeof limits.parts === 'number'[m
[32m+[m[32m                        ? limits.parts[m
[32m+[m[32m                        : Infinity);[m
[32m+[m
[32m+[m[32m    let parts = -1; // Account for initial boundary[m
[32m+[m[32m    let fields = 0;[m
[32m+[m[32m    let files = 0;[m
[32m+[m[32m    let skipPart = false;[m
[32m+[m
[32m+[m[32m    this._fileEndsLeft = 0;[m
[32m+[m[32m    this._fileStream = undefined;[m
[32m+[m[32m    this._complete = false;[m
[32m+[m[32m    let fileSize = 0;[m
[32m+[m
[32m+[m[32m    let field;[m
[32m+[m[32m    let fieldSize = 0;[m
[32m+[m[32m    let partCharset;[m
[32m+[m[32m    let partEncoding;[m
[32m+[m[32m    let partType;[m
[32m+[m[32m    let partName;[m
[32m+[m[32m    let partTruncated = false;[m
[32m+[m
[32m+[m[32m    let hitFilesLimit = false;[m
[32m+[m[32m    let hitFieldsLimit = false;[m
[32m+[m
[32m+[m[32m    this._hparser = null;[m
[32m+[m[32m    const hparser = new HeaderParser((header) => {[m
[32m+[m[32m      this._hparser = null;[m
[32m+[m[32m      skipPart = false;[m
[32m+[m
[32m+[m[32m      partType = 'text/plain';[m
[32m+[m[32m      partCharset = defCharset;[m
[32m+[m[32m      partEncoding = '7bit';[m
[32m+[m[32m      partName = undefined;[m
[32m+[m[32m      partTruncated = false;[m
[32m+[m
[32m+[m[32m      let filename;[m
[32m+[m[32m      if (!header['content-disposition']) {[m
[32m+[m[32m        skipPart = true;[m
[32m+[m[32m        return;[m
[32m+[m[32m      }[m
[32m+[m
[32m+[m[32m      const disp = parseDisposition(header['content-disposition'][0],[m
[32m+[m[32m                                    paramDecoder);[m
[32m+[m[32m      if (!disp || disp.type !== 'form-data') {[m
[32m+[m[32m        skipPart = true;[m
[32m+[m[32m        return;[m
[32m+[m[32m      }[m
[32m+[m
[32m+[m[32m      if (disp.params) {[m
[32m+[m[32m        if (disp.params.name)[m
[32m+[m[32m          partName = disp.params.name;[m
[32m+[m
[32m+[m[32m        if (disp.params['filename*'])[m
[32m+[m[32m          filename = disp.params['filename*'];[m
[32m+[m[32m        else if (disp.params.filename)[m
[32m+[m[32m          filename = disp.params.filename;[m
[32m+[m
[32m+[m[32m        if (filename !== undefined && !preservePath)[m
[32m+[m[32m          filename = basename(filename);[m
[32m+[m[32m      }[m
[32m+[m
[32m+[m[32m      if (header['content-type']) {[m
[32m+[m[32m        const conType = parseContentType(header['content-type'][0]);[m
[32m+[m[32m        if (conType) {[m
[32m+[m[32m          partType = `${conType.type}/${conType.subtype}`;[m
[32m+[m[32m          if (conType.params && typeof conType.params.charset === 'string')[m
[32m+[m[32m            partCharset = conType.params.charset.toLowerCase();[m
[32m+[m[32m        }[m
[32m+[m[32m      }[m
[32m+[m
[32m+[m[32m      if (header['content-transfer-encoding'])[m
[32m+[m[32m        partEncoding = header['content-transfer-encoding'][0].toLowerCase();[m
[32m+[m
[32m+[m[32m      if (partType === 'application/octet-stream' || filename !== undefined) {[m
[32m+[m[32m        // File[m
[32m+[m
[32m+[m[32m        if (files === filesLimit) {[m
[32m+[m[32m          if (!hitFilesLimit) {[m
[32m+[m[32m            hitFilesLimit = true;[m
[32m+[m[32m            this.emit('filesLimit');[m
[32m+[m[32m          }[m
[32m+[m[32m          skipPart = true;[m
[32m+[m[32m          return;[m
[32m+[m[32m        }[m
[32m+[m[32m        ++files;[m
[32m+[m
[32m+[m[32m        if (this.listenerCount('file') === 0) {[m
[32m+[m[32m          skipPart = true;[m
[32m+[m[32m          return;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        fileSize = 0;[m
[32m+[m[32m        this._fileStream = new FileStream(fileOpts, this);[m
[32m+[m[32m        ++this._fileEndsLeft;[m
[32m+[m[32m        this.emit([m
[32m+[m[32m          'file',[m
[32m+[m[32m          partName,[m
[32m+[m[32m          this._fileStream,[m
[32m+[m[32m          { filename,[m
[32m+[m[32m            encoding: partEncoding,[m
[32m+[m[32m            mimeType: partType }[m
[32m+[m[32m        );[m
[32m+[m[32m      } else {[m
[32m+[m[32m        // Non-file[m
[32m+[m
[32m+[m[32m        if (fields === fieldsLimit) {[m
[32m+[m[32m          if (!hitFieldsLimit) {[m
[32m+[m[32m            hitFieldsLimit = true;[m
[32m+[m[32m            this.emit('fieldsLimit');[m
[32m+[m[32m          }[m
[32m+[m[32m          skipPart = true;[m
[32m+[m[32m          return;[m
[32m+[m[32m        }[m
[32m+[m[32m        ++fields;[m
[32m+[m
[32m+[m[32m        if (this.listenerCount('field') === 0) {[m
[32m+[m[32m          skipPart = true;[m
[32m+[m[32m          return;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        field = [];[m
[32m+[m[32m        fieldSize = 0;[m
[32m+[m[32m      }[m
[32m+[m[32m    });[m
[32m+[m
[32m+[m[32m    let matchPostBoundary = 0;[m
[32m+[m[32m    const ssCb = (isMatch, data, start, end, isDataSafe) => {[m
[32m+[m[32mretrydata:[m
[32m+[m[32m      while (data) {[m
[32m+[m[32m        if (this._hparser !== null) {[m
[32m+[m[32m          const ret = this._hparser.push(data, start, end);[m
[32m+[m[32m          if (ret === -1) {[m
[32m+[m[32m            this._hparser = null;[m
[32m+[m[32m            hparser.reset();[m
[32m+[m[32m            this.emit('error', new Error('Malformed part header'));[m
[32m+[m[32m            break;[m
[32m+[m[32m          }[m
[32m+[m[32m          start = ret;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        if (start === end)[m
[32m+[m[32m          break;[m
[32m+[m
[32m+[m[32m        if (matchPostBoundary !== 0) {[m
[32m+[m[32m          if (matchPostBoundary === 1) {[m
[32m+[m[32m            switch (data[start]) {[m
[32m+[m[32m              case 45: // '-'[m
[32m+[m[32m                // Try matching '--' after boundary[m
[32m+[m[32m                matchPostBoundary = 2;[m
[32m+[m[32m                ++start;[m
[32m+[m[32m                break;[m
[32m+[m[32m              case 13: // '\r'[m
[32m+[m[32m                // Try matching CR LF before header[m
[32m+[m[32m                matchPostBoundary = 3;[m
[32m+[m[32m                ++start;[m
[32m+[m[32m                break;[m
[32m+[m[32m              default:[m
[32m+[m[32m                matchPostBoundary = 0;[m
[32m+[m[32m            }[m
[32m+[m[32m            if (start === end)[m
[32m+[m[32m              return;[m
[32m+[m[32m          }[m
[32m+[m
[32m+[m[32m          if (matchPostBoundary === 2) {[m
[32m+[m[32m            matchPostBoundary = 0;[m
[32m+[m[32m            if (data[start] === 45/* '-' */) {[m
[32m+[m[32m              // End of multipart data[m
[32m+[m[32m              this._complete = true;[m
[32m+[m[32m              this._bparser = ignoreData;[m
[32m+[m[32m              return;[m
[32m+[m[32m            }[m
[32m+[m[32m            // We saw something other than '-', so put the dash we consumed[m
[32m+[m[32m            // "back"[m
[32m+[m[32m            const writecb = this._writecb;[m
[32m+[m[32m            this._writecb = noop;[m
[32m+[m[32m            ssCb(false, BUF_DASH, 0, 1, false);[m
[32m+[m[32m            this._writecb = writecb;[m
[32m+[m[32m          } else if (matchPostBoundary === 3) {[m
[32m+[m[32m            matchPostBoundary = 0;[m
[32m+[m[32m            if (data[start] === 10/* '\n' */) {[m
[32m+[m[32m              ++start;[m
[32m+[m[32m              if (parts >= partsLimit)[m
[32m+[m[32m                break;[m
[32m+[m[32m              // Prepare the header parser[m
[32m+[m[32m              this._hparser = hparser;[m
[32m+[m[32m              if (start === end)[m
[32m+[m[32m                break;[m
[32m+[m[32m              // Process the remaining data as a header[m
[32m+[m[32m              continue retrydata;[m
[32m+[m[32m            } else {[m
[32m+[m[32m              // We saw something other than LF, so put the CR we consumed[m
[32m+[m[32m              // "back"[m
[32m+[m[32m              const writecb = this._writecb;[m
[32m+[m[32m              this._writecb = noop;[m
[32m+[m[32m              ssCb(false, BUF_CR, 0, 1, false);[m
[32m+[m[32m              this._writecb = writecb;[m
[32m+[m[32m            }[m
[32m+[m[32m          }[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        if (!skipPart) {[m
[32m+[m[32m          if (this._fileStream) {[m
[32m+[m[32m            let chunk;[m
[32m+[m[32m            const actualLen = Math.min(end - start, fileSizeLimit - fileSize);[m
[32m+[m[32m            if (!isDataSafe) {[m
[32m+[m[32m              chunk = Buffer.allocUnsafe(actualLen);[m
[32m+[m[32m              data.copy(chunk, 0, start, start + actualLen);[m
[32m+[m[32m            } else {[m
[32m+[m[32m              chunk = data.slice(start, start + actualLen);[m
[32m+[m[32m            }[m
[32m+[m
[32m+[m[32m            fileSize += chunk.length;[m
[32m+[m[32m            if (fileSize === fileSizeLimit) {[m
[32m+[m[32m              if (chunk.length > 0)[m
[32m+[m[32m                this._fileStream.push(chunk);[m
[32m+[m[32m              this._fileStream.emit('limit');[m
[32m+[m[32m              this._fileStream.truncated = true;[m
[32m+[m[32m              skipPart = true;[m
[32m+[m[32m            } else if (!this._fileStream.push(chunk)) {[m
[32m+[m[32m              if (this._writecb)[m
[32m+[m[32m                this._fileStream._readcb = this._writecb;[m
[32m+[m[32m              this._writecb = null;[m
[32m+[m[32m            }[m
[32m+[m[32m          } else if (field !== undefined) {[m
[32m+[m[32m            let chunk;[m
[32m+[m[32m            const actualLen = Math.min([m
[32m+[m[32m              end - start,[m
[32m+[m[32m              fieldSizeLimit - fieldSize[m
[32m+[m[32m            );[m
[32m+[m[32m            if (!isDataSafe) {[m
[32m+[m[32m              chunk = Buffer.allocUnsafe(actualLen);[m
[32m+[m[32m              data.copy(chunk, 0, start, start + actualLen);[m
[32m+[m[32m            } else {[m
[32m+[m[32m              chunk = data.slice(start, start + actualLen);[m
[32m+[m[32m            }[m
[32m+[m
[32m+[m[32m            fieldSize += actualLen;[m
[32m+[m[32m            field.push(chunk);[m
[32m+[m[32m            if (fieldSize === fieldSizeLimit) {[m
[32m+[m[32m              skipPart = true;[m
[32m+[m[32m              partTruncated = true;[m
[32m+[m[32m            }[m
[32m+[m[32m          }[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        break;[m
[32m+[m[32m      }[m
[32m+[m
[32m+[m[32m      if (isMatch) {[m
[32m+[m[32m        matchPostBoundary = 1;[m
[32m+[m
[32m+[m[32m        if (this._fileStream) {[m
[32m+[m[32m          // End the active file stream if the previous part was a file[m
[32m+[m[32m          this._fileStream.push(null);[m
[32m+[m[32m          this._fileStream = null;[m
[32m+[m[32m        } else if (field !== undefined) {[m
[32m+[m[32m          let data;[m
[32m+[m[32m          switch (field.length) {[m
[32m+[m[32m            case 0:[m
[32m+[m[32m              data = '';[m
[32m+[m[32m              break;[m
[32m+[m[32m            case 1:[m
[32m+[m[32m              data = convertToUTF8(field[0], partCharset, 0);[m
[32m+[m[32m              break;[m
[32m+[m[32m            default:[m
[32m+[m[32m              data = convertToUTF8([m
[32m+[m[32m                Buffer.concat(field, fieldSize),[m
[32m+[m[32m                partCharset,[m
[32m+[m[32m                0[m
[32m+[m[32m              );[m
[32m+[m[32m          }[m
[32m+[m[32m          field = undefined;[m
[32m+[m[32m          fieldSize = 0;[m
[32m+[m[32m          this.emit([m
[32m+[m[32m            'field',[m
[32m+[m[32m            partName,[m
[32m+[m[32m            data,[m
[32m+[m[32m            { nameTruncated: false,[m
[32m+[m[32m              valueTruncated: partTruncated,[m
[32m+[m[32m              encoding: partEncoding,[m
[32m+[m[32m              mimeType: partType }[m
[32m+[m[32m          );[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        if (++parts === partsLimit)[m
[32m+[m[32m          this.emit('partsLimit');[m
[32m+[m[32m      }[m
[32m+[m[32m    };[m
[32m+[m[32m    this._bparser = new StreamSearch(`\r\n--${boundary}`, ssCb);[m
[32m+[m
[32m+[m[32m    this._writecb = null;[m
[32m+[m[32m    this._finalcb = null;[m
[32m+[m
[32m+[m[32m    // Just in case there is no preamble[m
[32m+[m[32m    this.write(BUF_CRLF);[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  static detect(conType) {[m
[32m+[m[32m    return (conType.type === 'multipart' && conType.subtype === 'form-data');[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  _write(chunk, enc, cb) {[m
[32m+[m[32m    this._writecb = cb;[m
[32m+[m[32m    this._bparser.push(chunk, 0);[m
[32m+[m[32m    if (this._writecb)[m
[32m+[m[32m      callAndUnsetCb(this);[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  _destroy(err, cb) {[m
[32m+[m[32m    this._hparser = null;[m
[32m+[m[32m    this._bparser = ignoreData;[m
[32m+[m[32m    if (!err)[m
[32m+[m[32m      err = checkEndState(this);[m
[32m+[m[32m    const fileStream = this._fileStream;[m
[32m+[m[32m    if (fileStream) {[m
[32m+[m[32m      this._fileStream = null;[m
[32m+[m[32m      fileStream.destroy(err);[m
[32m+[m[32m    }[m
[32m+[m[32m    cb(err);[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  _final(cb) {[m
[32m+[m[32m    this._bparser.destroy();[m
[32m+[m[32m    if (!this._complete)[m
[32m+[m[32m      return cb(new Error('Unexpected end of form'));[m
[32m+[m[32m    if (this._fileEndsLeft)[m
[32m+[m[32m      this._finalcb = finalcb.bind(null, this, cb);[m
[32m+[m[32m    else[m
[32m+[m[32m      finalcb(this, cb);[m
[32m+[m[32m  }[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction finalcb(self, cb, err) {[m
[32m+[m[32m  if (err)[m
[32m+[m[32m    return cb(err);[m
[32m+[m[32m  err = checkEndState(self);[m
[32m+[m[32m  cb(err);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction checkEndState(self) {[m
[32m+[m[32m  if (self._hparser)[m
[32m+[m[32m    return new Error('Malformed part header');[m
[32m+[m[32m  const fileStream = self._fileStream;[m
[32m+[m[32m  if (fileStream) {[m
[32m+[m[32m    self._fileStream = null;[m
[32m+[m[32m    fileStream.destroy(new Error('Unexpected end of file'));[m
[32m+[m[32m  }[m
[32m+[m[32m  if (!self._complete)[m
[32m+[m[32m    return new Error('Unexpected end of form');[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mconst TOKEN = [[m
[32m+[m[32m  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,[m
[32m+[m[32m  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,[m
[32m+[m[32m  0, 1, 0, 1, 1, 1, 1, 1, 0, 0, 1, 1, 0, 1, 1, 0,[m
[32m+[m[32m  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0,[m
[32m+[m[32m  0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,[m
[32m+[m[32m  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1,[m
[32m+[m[32m  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,[m
[32m+[m[32m  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0,[m
[32m+[m[32m  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,[m
[32m+[m[32m  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,[m
[32m+[m[32m  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,[m
[32m+[m[32m  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,[m
[32m+[m[32m  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,[m
[32m+[m[32m  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,[m
[32m+[m[32m  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,[m
[32m+[m[32m  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,[m
[32m+[m[32m];[m
[32m+[m
[32m+[m[32mconst FIELD_VCHAR = [[m
[32m+[m[32m  0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0,[m
[32m+[m[32m  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,[m
[32m+[m[32m  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,[m
[32m+[m[32m  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,[m
[32m+[m[32m  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,[m
[32m+[m[32m  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,[m
[32m+[m[32m  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,[m
[32m+[m[32m  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,[m
[32m+[m[32m  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,[m
[32m+[m[32m  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,[m
[32m+[m[32m  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,[m
[32m+[m[32m  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,[m
[32m+[m[32m  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,[m
[32m+[m[32m  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,[m
[32m+[m[32m  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,[m
[32m+[m[32m  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,[m
[32m+[m[32m];[m
[32m+[m
[32m+[m[32mmodule.exports = Multipart;[m
[1mdiff --git a/node_modules/busboy/lib/types/urlencoded.js b/node_modules/busboy/lib/types/urlencoded.js[m
[1mnew file mode 100644[m
[1mindex 0000000..5c463a2[m
[1m--- /dev/null[m
[1m+++ b/node_modules/busboy/lib/types/urlencoded.js[m
[36m@@ -0,0 +1,350 @@[m
[32m+[m[32m'use strict';[m
[32m+[m
[32m+[m[32mconst { Writable } = require('stream');[m
[32m+[m
[32m+[m[32mconst { getDecoder } = require('../utils.js');[m
[32m+[m
[32m+[m[32mclass URLEncoded extends Writable {[m
[32m+[m[32m  constructor(cfg) {[m
[32m+[m[32m    const streamOpts = {[m
[32m+[m[32m      autoDestroy: true,[m
[32m+[m[32m      emitClose: true,[m
[32m+[m[32m      highWaterMark: (typeof cfg.highWaterMark === 'number'[m
[32m+[m[32m                      ? cfg.highWaterMark[m
[32m+[m[32m                      : undefined),[m
[32m+[m[32m    };[m
[32m+[m[32m    super(streamOpts);[m
[32m+[m
[32m+[m[32m    let charset = (cfg.defCharset || 'utf8');[m
[32m+[m[32m    if (cfg.conType.params && typeof cfg.conType.params.charset === 'string')[m
[32m+[m[32m      charset = cfg.conType.params.charset;[m
[32m+[m
[32m+[m[32m    this.charset = charset;[m
[32m+[m
[32m+[m[32m    const limits = cfg.limits;[m
[32m+[m[32m    this.fieldSizeLimit = (limits && typeof limits.fieldSize === 'number'[m
[32m+[m[32m                           ? limits.fieldSize[m
[32m+[m[32m                           : 1 * 1024 * 1024);[m
[32m+[m[32m    this.fieldsLimit = (limits && typeof limits.fields === 'number'[m
[32m+[m[32m                        ? limits.fields[m
[32m+[m[32m                        : Infinity);[m
[32m+[m[32m    this.fieldNameSizeLimit = ([m
[32m+[m[32m      limits && typeof limits.fieldNameSize === 'number'[m
[32m+[m[32m      ? limits.fieldNameSize[m
[32m+[m[32m      : 100[m
[32m+[m[32m    );[m
[32m+[m
[32m+[m[32m    this._inKey = true;[m
[32m+[m[32m    this._keyTrunc = false;[m
[32m+[m[32m    this._valTrunc = false;[m
[32m+[m[32m    this._bytesKey = 0;[m
[32m+[m[32m    this._bytesVal = 0;[m
[32m+[m[32m    this._fields = 0;[m
[32m+[m[32m    this._key = '';[m
[32m+[m[32m    this._val = '';[m
[32m+[m[32m    this._byte = -2;[m
[32m+[m[32m    this._lastPos = 0;[m
[32m+[m[32m    this._encode = 0;[m
[32m+[m[32m    this._decoder = getDecoder(charset);[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  static detect(conType) {[m
[32m+[m[32m    return (conType.type === 'application'[m
[32m+[m[32m            && conType.subtype === 'x-www-form-urlencoded');[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  _write(chunk, enc, cb) {[m
[32m+[m[32m    if (this._fields >= this.fieldsLimit)[m
[32m+[m[32m      return cb();[m
[32m+[m
[32m+[m[32m    let i = 0;[m
[32m+[m[32m    const len = chunk.length;[m
[32m+[m[32m    this._lastPos = 0;[m
[32m+[m
[32m+[m[32m    // Check if we last ended mid-percent-encoded byte[m
[32m+[m[32m    if (this._byte !== -2) {[m
[32m+[m[32m      i = readPctEnc(this, chunk, i, len);[m
[32m+[m[32m      if (i === -1)[m
[32m+[m[32m        return cb(new Error('Malformed urlencoded form'));[m
[32m+[m[32m      if (i >= len)[m
[32m+[m[32m        return cb();[m
[32m+[m[32m      if (this._inKey)[m
[32m+[m[32m        ++this._bytesKey;[m
[32m+[m[32m      else[m
[32m+[m[32m        ++this._bytesVal;[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32mmain:[m
[32m+[m[32m    while (i < len) {[m
[32m+[m[32m      if (this._inKey) {[m
[32m+[m[32m        // Parsing key[m
[32m+[m
[32m+[m[32m        i = skipKeyBytes(this, chunk, i, len);[m
[32m+[m
[32m+[m[32m        while (i < len) {[m
[32m+[m[32m          switch (chunk[i]) {[m
[32m+[m[32m            case 61: // '='[m
[32m+[m[32m              if (this._lastPos < i)[m
[32m+[m[32m                this._key += chunk.latin1Slice(this._lastPos, i);[m
[32m+[m[32m              this._lastPos = ++i;[m
[32m+[m[32m              this._key = this._decoder(this._key, this._encode);[m
[32m+[m[32m              this._encode = 0;[m
[32m+[m[32m              this._inKey = false;[m
[32m+[m[32m              continue main;[m
[32m+[m[32m            case 38: // '&'[m
[32m+[m[32m              if (this._lastPos < i)[m
[32m+[m[32m                this._key += chunk.latin1Slice(this._lastPos, i);[m
[32m+[m[32m              this._lastPos = ++i;[m
[32m+[m[32m              this._key = this._decoder(this._key, this._encode);[m
[32m+[m[32m              this._encode = 0;[m
[32m+[m[32m              if (this._bytesKey > 0) {[m
[32m+[m[32m                this.emit([m
[32m+[m[32m                  'field',[m
[32m+[m[32m                  this._key,[m
[32m+[m[32m                  '',[m
[32m+[m[32m                  { nameTruncated: this._keyTrunc,[m
[32m+[m[32m                    valueTruncated: false,[m
[32m+[m[32m                    encoding: this.charset,[m
[32m+[m[32m                    mimeType: 'text/plain' }[m
[32m+[m[32m                );[m
[32m+[m[32m              }[m
[32m+[m[32m              this._key = '';[m
[32m+[m[32m              this._val = '';[m
[32m+[m[32m              this._keyTrunc = false;[m
[32m+[m[32m              this._valTrunc = false;[m
[32m+[m[32m              this._bytesKey = 0;[m
[32m+[m[32m              this._bytesVal = 0;[m
[32m+[m[32m              if (++this._fields >= this.fieldsLimit) {[m
[32m+[m[32m                this.emit('fieldsLimit');[m
[32m+[m[32m                return cb();[m
[32m+[m[32m              }[m
[32m+[m[32m              continue;[m
[32m+[m[32m            case 43: // '+'[m
[32m+[m[32m              if (this._lastPos < i)[m
[32m+[m[32m                this._key += chunk.latin1Slice(this._lastPos, i);[m
[32m+[m[32m              this._key += ' ';[m
[32m+[m[32m              this._lastPos = i + 1;[m
[32m+[m[32m              break;[m
[32m+[m[32m            case 37: // '%'[m
[32m+[m[32m              if (this._encode === 0)[m
[32m+[m[32m                this._encode = 1;[m
[32m+[m[32m              if (this._lastPos < i)[m
[32m+[m[32m                this._key += chunk.latin1Slice(this._lastPos, i);[m
[32m+[m[32m              this._lastPos = i + 1;[m
[32m+[m[32m              this._byte = -1;[m
[32m+[m[32m              i = readPctEnc(this, chunk, i + 1, len);[m
[32m+[m[32m              if (i === -1)[m
[32m+[m[32m                return cb(new Error('Malformed urlencoded form'));[m
[32m+[m[32m              if (i >= len)[m
[32m+[m[32m                return cb();[m
[32m+[m[32m              ++this._bytesKey;[m
[32m+[m[32m              i = skipKeyBytes(this, chunk, i, len);[m
[32m+[m[32m              continue;[m
[32m+[m[32m          }[m
[32m+[m[32m          ++i;[m
[32m+[m[32m          ++this._bytesKey;[m
[32m+[m[32m          i = skipKeyBytes(this, chunk, i, len);[m
[32m+[m[32m        }[m
[32m+[m[32m        if (this._lastPos < i)[m
[32m+[m[32m          this._key += chunk.latin1Slice(this._lastPos, i);[m
[32m+[m[32m      } else {[m
[32m+[m[32m        // Parsing value[m
[32m+[m
[32m+[m[32m        i = skipValBytes(this, chunk, i, len);[m
[32m+[m
[32m+[m[32m        while (i < len) {[m
[32m+[m[32m          switch (chunk[i]) {[m
[32m+[m[32m            case 38: // '&'[m
[32m+[m[32m              if (this._lastPos < i)[m
[32m+[m[32m                this._val += chunk.latin1Slice(this._lastPos, i);[m
[32m+[m[32m              this._lastPos = ++i;[m
[32m+[m[32m              this._inKey = true;[m
[32m+[m[32m              this._val = this._decoder(this._val, this._encode);[m
[32m+[m[32m              this._encode = 0;[m
[32m+[m[32m              if (this._bytesKey > 0 || this._bytesVal > 0) {[m
[32m+[m[32m                this.emit([m
[32m+[m[32m                  'field',[m
[32m+[m[32m                  this._key,[m
[32m+[m[32m                  this._val,[m
[32m+[m[32m                  { nameTruncated: this._keyTrunc,[m
[32m+[m[32m                    valueTruncated: this._valTrunc,[m
[32m+[m[32m                    encoding: this.charset,[m
[32m+[m[32m                    mimeType: 'text/plain' }[m
[32m+[m[32m                );[m
[32m+[m[32m              }[m
[32m+[m[32m              this._key = '';[m
[32m+[m[32m              this._val = '';[m
[32m+[m[32m              this._keyTrunc = false;[m
[32m+[m[32m              this._valTrunc = false;[m
[32m+[m[32m              this._bytesKey = 0;[m
[32m+[m[32m              this._bytesVal = 0;[m
[32m+[m[32m              if (++this._fields >= this.fieldsLimit) {[m
[32m+[m[32m                this.emit('fieldsLimit');[m
[32m+[m[32m                return cb();[m
[32m+[m[32m              }[m
[32m+[m[32m              continue main;[m
[32m+[m[32m            case 43: // '+'[m
[32m+[m[32m              if (this._lastPos < i)[m
[32m+[m[32m                this._val += chunk.latin1Slice(this._lastPos, i);[m
[32m+[m[32m              this._val += ' ';[m
[32m+[m[32m              this._lastPos = i + 1;[m
[32m+[m[32m              break;[m
[32m+[m[32m            case 37: // '%'[m
[32m+[m[32m              if (this._encode === 0)[m
[32m+[m[32m                this._encode = 1;[m
[32m+[m[32m              if (this._lastPos < i)[m
[32m+[m[32m                this._val += chunk.latin1Slice(this._lastPos, i);[m
[32m+[m[32m              this._lastPos = i + 1;[m
[32m+[m[32m              this._byte = -1;[m
[32m+[m[32m              i = readPctEnc(this, chunk, i + 1, len);[m
[32m+[m[32m              if (i === -1)[m
[32m+[m[32m                return cb(new Error('Malformed urlencoded form'));[m
[32m+[m[32m              if (i >= len)[m
[32m+[m[32m                return cb();[m
[32m+[m[32m              ++this._bytesVal;[m
[32m+[m[32m              i = skipValBytes(this, chunk, i, len);[m
[32m+[m[32m              continue;[m
[32m+[m[32m          }[m
[32m+[m[32m          ++i;[m
[32m+[m[32m          ++this._bytesVal;[m
[32m+[m[32m          i = skipValBytes(this, chunk, i, len);[m
[32m+[m[32m        }[m
[32m+[m[32m        if (this._lastPos < i)[m
[32m+[m[32m          this._val += chunk.latin1Slice(this._lastPos, i);[m
[32m+[m[32m      }[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    cb();[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  _final(cb) {[m
[32m+[m[32m    if (this._byte !== -2)[m
[32m+[m[32m      return cb(new Error('Malformed urlencoded form'));[m
[32m+[m[32m    if (!this._inKey || this._bytesKey > 0 || this._bytesVal > 0) {[m
[32m+[m[32m      if (this._inKey)[m
[32m+[m[32m        this._key = this._decoder(this._key, this._encode);[m
[32m+[m[32m      else[m
[32m+[m[32m        this._val = this._decoder(this._val, this._encode);[m
[32m+[m[32m      this.emit([m
[32m+[m[32m        'field',[m
[32m+[m[32m        this._key,[m
[32m+[m[32m        this._val,[m
[32m+[m[32m        { nameTruncated: this._keyTrunc,[m
[32m+[m[32m          valueTruncated: this._valTrunc,[m
[32m+[m[32m          encoding: this.charset,[m
[32m+[m[32m          mimeType: 'text/plain' }[m
[32m+[m[32m      );[m
[32m+[m[32m    }[m
[32m+[m[32m    cb();[m
[32m+[m[32m  }[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction readPctEnc(self, chunk, pos, len) {[m
[32m+[m[32m  if (pos >= len)[m
[32m+[m[32m    return len;[m
[32m+[m
[32m+[m[32m  if (self._byte === -1) {[m
[32m+[m[32m    // We saw a '%' but no hex characters yet[m
[32m+[m[32m    const hexUpper = HEX_VALUES[chunk[pos++]];[m
[32m+[m[32m    if (hexUpper === -1)[m
[32m+[m[32m      return -1;[m
[32m+[m
[32m+[m[32m    if (hexUpper >= 8)[m
[32m+[m[32m      self._encode = 2; // Indicate high bits detected[m
[32m+[m
[32m+[m[32m    if (pos < len) {[m
[32m+[m[32m      // Both hex characters are in this chunk[m
[32m+[m[32m      const hexLower = HEX_VALUES[chunk[pos++]];[m
[32m+[m[32m      if (hexLower === -1)[m
[32m+[m[32m        return -1;[m
[32m+[m
[32m+[m[32m      if (self._inKey)[m
[32m+[m[32m        self._key += String.fromCharCode((hexUpper << 4) + hexLower);[m
[32m+[m[32m      else[m
[32m+[m[32m        self._val += String.fromCharCode((hexUpper << 4) + hexLower);[m
[32m+[m
[32m+[m[32m      self._byte = -2;[m
[32m+[m[32m      self._lastPos = pos;[m
[32m+[m[32m    } else {[m
[32m+[m[32m      // Only one hex character was available in this chunk[m
[32m+[m[32m      self._byte = hexUpper;[m
[32m+[m[32m    }[m
[32m+[m[32m  } else {[m
[32m+[m[32m    // We saw only one hex character so far[m
[32m+[m[32m    const hexLower = HEX_VALUES[chunk[pos++]];[m
[32m+[m[32m    if (hexLower === -1)[m
[32m+[m[32m      return -1;[m
[32m+[m
[32m+[m[32m    if (self._inKey)[m
[32m+[m[32m      self._key += String.fromCharCode((self._byte << 4) + hexLower);[m
[32m+[m[32m    else[m
[32m+[m[32m      self._val += String.fromCharCode((self._byte << 4) + hexLower);[m
[32m+[m
[32m+[m[32m    self._byte = -2;[m
[32m+[m[32m    self._lastPos = pos;[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  return pos;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction skipKeyBytes(self, chunk, pos, len) {[m
[32m+[m[32m  // Skip bytes if we've truncated[m
[32m+[m[32m  if (self._bytesKey > self.fieldNameSizeLimit) {[m
[32m+[m[32m    if (!self._keyTrunc) {[m
[32m+[m[32m      if (self._lastPos < pos)[m
[32m+[m[32m        self._key += chunk.latin1Slice(self._lastPos, pos - 1);[m
[32m+[m[32m    }[m
[32m+[m[32m    self._keyTrunc = true;[m
[32m+[m[32m    for (; pos < len; ++pos) {[m
[32m+[m[32m      const code = chunk[pos];[m
[32m+[m[32m      if (code === 61/* '=' */ || code === 38/* '&' */)[m
[32m+[m[32m        break;[m
[32m+[m[32m      ++self._bytesKey;[m
[32m+[m[32m    }[m
[32m+[m[32m    self._lastPos = pos;[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  return pos;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction skipValBytes(self, chunk, pos, len) {[m
[32m+[m[32m  // Skip bytes if we've truncated[m
[32m+[m[32m  if (self._bytesVal > self.fieldSizeLimit) {[m
[32m+[m[32m    if (!self._valTrunc) {[m
[32m+[m[32m      if (self._lastPos < pos)[m
[32m+[m[32m        self._val += chunk.latin1Slice(self._lastPos, pos - 1);[m
[32m+[m[32m    }[m
[32m+[m[32m    self._valTrunc = true;[m
[32m+[m[32m    for (; pos < len; ++pos) {[m
[32m+[m[32m      if (chunk[pos] === 38/* '&' */)[m
[32m+[m[32m        break;[m
[32m+[m[32m      ++self._bytesVal;[m
[32m+[m[32m    }[m
[32m+[m[32m    self._lastPos = pos;[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  return pos;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m/* eslint-disable no-multi-spaces */[m
[32m+[m[32mconst HEX_VALUES = [[m
[32m+[m[32m  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,[m
[32m+[m[32m  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,[m
[32m+[m[32m  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,[m
[32m+[m[32m   0,  1,  2,  3,  4,  5,  6,  7,  8,  9, -1, -1, -1, -1, -1, -1,[m
[32m+[m[32m  -1, 10, 11, 12, 13, 14, 15, -1, -1, -1, -1, -1, -1, -1, -1, -1,[m
[32m+[m[32m  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,[m
[32m+[m[32m  -1, 10, 11, 12, 13, 14, 15, -1, -1, -1, -1, -1, -1, -1, -1, -1,[m
[32m+[m[32m  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,[m
[32m+[m[32m  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,[m
[32m+[m[32m  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,[m
[32m+[m[32m  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,[m
[32m+[m[32m  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,[m
[32m+[m[32m  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,[m
[32m+[m[32m  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,[m
[32m+[m[32m  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,[m
[32m+[m[32m  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,[m
[32m+[m[32m];[m
[32m+[m[32m/* eslint-enable no-multi-spaces */[m
[32m+[m
[32m+[m[32mmodule.exports = URLEncoded;[m
[1mdiff --git a/node_modules/busboy/lib/utils.js b/node_modules/busboy/lib/utils.js[m
[1mnew file mode 100644[m
[1mindex 0000000..8274f6c[m
[1m--- /dev/null[m
[1m+++ b/node_modules/busboy/lib/utils.js[m
[36m@@ -0,0 +1,596 @@[m
[32m+[m[32m'use strict';[m
[32m+[m
[32m+[m[32mfunction parseContentType(str) {[m
[32m+[m[32m  if (str.length === 0)[m
[32m+[m[32m    return;[m
[32m+[m
[32m+[m[32m  const params = Object.create(null);[m
[32m+[m[32m  let i = 0;[m
[32m+[m
[32m+[m[32m  // Parse type[m
[32m+[m[32m  for (; i < str.length; ++i) {[m
[32m+[m[32m    const code = str.charCodeAt(i);[m
[32m+[m[32m    if (TOKEN[code] !== 1) {[m
[32m+[m[32m      if (code !== 47/* '/' */ || i === 0)[m
[32m+[m[32m        return;[m
[32m+[m[32m      break;[m
[32m+[m[32m    }[m
[32m+[m[32m  }[m
[32m+[m[32m  // Check for type without subtype[m
[32m+[m[32m  if (i === str.length)[m
[32m+[m[32m    return;[m
[32m+[m
[32m+[m[32m  const type = str.slice(0, i).toLowerCase();[m
[32m+[m
[32m+[m[32m  // Parse subtype[m
[32m+[m[32m  const subtypeStart = ++i;[m
[32m+[m[32m  for (; i < str.length; ++i) {[m
[32m+[m[32m    const code = str.charCodeAt(i);[m
[32m+[m[32m    if (TOKEN[code] !== 1) {[m
[32m+[m[32m      // Make sure we have a subtype[m
[32m+[m[32m      if (i === subtypeStart)[m
[32m+[m[32m        return;[m
[32m+[m
[32m+[m[32m      if (parseContentTypeParams(str, i, params) === undefined)[m
[32m+[m[32m        return;[m
[32m+[m[32m      break;[m
[32m+[m[32m    }[m
[32m+[m[32m  }[m
[32m+[m[32m  // Make sure we have a subtype[m
[32m+[m[32m  if (i === subtypeStart)[m
[32m+[m[32m    return;[m
[32m+[m
[32m+[m[32m  const subtype = str.slice(subtypeStart, i).toLowerCase();[m
[32m+[m
[32m+[m[32m  return { type, subtype, params };[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction parseContentTypeParams(str, i, params) {[m
[32m+[m[32m  while (i < str.length) {[m
[32m+[m[32m    // Consume whitespace[m
[32m+[m[32m    for (; i < str.length; ++i) {[m
[32m+[m[32m      const code = str.charCodeAt(i);[m
[32m+[m[32m      if (code !== 32/* ' ' */ && code !== 9/* '\t' */)[m
[32m+[m[32m        break;[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    // Ended on whitespace[m
[32m+[m[32m    if (i === str.length)[m
[32m+[m[32m      break;[m
[32m+[m
[32m+[m[32m    // Check for malformed parameter[m
[32m+[m[32m    if (str.charCodeAt(i++) !== 59/* ';' */)[m
[32m+[m[32m      return;[m
[32m+[m
[32m+[m[32m    // Consume whitespace[m
[32m+[m[32m    for (; i < str.length; ++i) {[m
[32m+[m[32m      const code = str.charCodeAt(i);[m
[32m+[m[32m      if (code !== 32/* ' ' */ && code !== 9/* '\t' */)[m
[32m+[m[32m        break;[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    // Ended on whitespace (malformed)[m
[32m+[m[32m    if (i === str.length)[m
[32m+[m[32m      return;[m
[32m+[m
[32m+[m[32m    let name;[m
[32m+[m[32m    const nameStart = i;[m
[32m+[m[32m    // Parse parameter name[m
[32m+[m[32m    for (; i < str.length; ++i) {[m
[32m+[m[32m      const code = str.charCodeAt(i);[m
[32m+[m[32m      if (TOKEN[code] !== 1) {[m
[32m+[m[32m        if (code !== 61/* '=' */)[m
[32m+[m[32m          return;[m
[32m+[m[32m        break;[m
[32m+[m[32m      }[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    // No value (malformed)[m
[32m+[m[32m    if (i === str.length)[m
[32m+[m[32m      return;[m
[32m+[m
[32m+[m[32m    name = str.slice(nameStart, i);[m
[32m+[m[32m    ++i; // Skip over '='[m
[32m+[m
[32m+[m[32m    // No value (malformed)[m
[32m+[m[32m    if (i === str.length)[m
[32m+[m[32m      return;[m
[32m+[m
[32m+[m[32m    let value = '';[m
[32m+[m[32m    let valueStart;[m
[32m+[m[32m    if (str.charCodeAt(i) === 34/* '"' */) {[m
[32m+[m[32m      valueStart = ++i;[m
[32m+[m[32m      let escaping = false;[m
[32m+[m[32m      // Parse quoted value[m
[32m+[m[32m      for (; i < str.length; ++i) {[m
[32m+[m[32m        const code = str.charCodeAt(i);[m
[32m+[m[32m        if (code === 92/* '\\' */) {[m
[32m+[m[32m          if (escaping) {[m
[32m+[m[32m            valueStart = i;[m
[32m+[m[32m            escaping = false;[m
[32m+[m[32m          } else {[m
[32m+[m[32m            value += str.slice(valueStart, i);[m
[32m+[m[32m            escaping = true;[m
[32m+[m[32m          }[m
[32m+[m[32m          continue;[m
[32m+[m[32m        }[m
[32m+[m[32m        if (code === 34/* '"' */) {[m
[32m+[m[32m          if (escaping) {[m
[32m+[m[32m            valueStart = i;[m
[32m+[m[32m            escaping = false;[m
[32m+[m[32m            continue;[m
[32m+[m[32m          }[m
[32m+[m[32m          value += str.slice(valueStart, i);[m
[32m+[m[32m          break;[m
[32m+[m[32m        }[m
[32m+[m[32m        if (escaping) {[m
[32m+[m[32m          valueStart = i - 1;[m
[32m+[m[32m          escaping = false;[m
[32m+[m[32m        }[m
[32m+[m[32m        // Invalid unescaped quoted character (malformed)[m
[32m+[m[32m        if (QDTEXT[code] !== 1)[m
[32m+[m[32m          return;[m
[32m+[m[32m      }[m
[32m+[m
[32m+[m[32m      // No end quote (malformed)[m
[32m+[m[32m      if (i === str.length)[m
[32m+[m[32m        return;[m
[32m+[m
[32m+[m[32m      ++i; // Skip over double quote[m
[32m+[m[32m    } else {[m
[32m+[m[32m      valueStart = i;[m
[32m+[m[32m      // Parse unquoted value[m
[32m+[m[32m      for (; i < str.length; ++i) {[m
[32m+[m[32m        const code = str.charCodeAt(i);[m
[32m+[m[32m        if (TOKEN[code] !== 1) {[m
[32m+[m[32m          // No value (malformed)[m
[32m+[m[32m          if (i === valueStart)[m
[32m+[m[32m            return;[m
[32m+[m[32m          break;[m
[32m+[m[32m        }[m
[32m+[m[32m      }[m
[32m+[m[32m      value = str.slice(valueStart, i);[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    name = name.toLowerCase();[m
[32m+[m[32m    if (params[name] === undefined)[m
[32m+[m[32m      params[name] = value;[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  return params;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction parseDisposition(str, defDecoder) {[m
[32m+[m[32m  if (str.length === 0)[m
[32m+[m[32m    return;[m
[32m+[m
[32m+[m[32m  const params = Object.create(null);[m
[32m+[m[32m  let i = 0;[m
[32m+[m
[32m+[m[32m  for (; i < str.length; ++i) {[m
[32m+[m[32m    const code = str.charCodeAt(i);[m
[32m+[m[32m    if (TOKEN[code] !== 1) {[m
[32m+[m[32m      if (parseDispositionParams(str, i, params, defDecoder) === undefined)[m
[32m+[m[32m        return;[m
[32m+[m[32m      break;[m
[32m+[m[32m    }[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  const type = str.slice(0, i).toLowerCase();[m
[32m+[m
[32m+[m[32m  return { type, params };[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction parseDispositionParams(str, i, params, defDecoder) {[m
[32m+[m[32m  while (i < str.length) {[m
[32m+[m[32m    // Consume whitespace[m
[32m+[m[32m    for (; i < str.length; ++i) {[m
[32m+[m[32m      const code = str.charCodeAt(i);[m
[32m+[m[32m      if (code !== 32/* ' ' */ && code !== 9/* '\t' */)[m
[32m+[m[32m        break;[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    // Ended on whitespace[m
[32m+[m[32m    if (i === str.length)[m
[32m+[m[32m      break;[m
[32m+[m
[32m+[m[32m    // Check for malformed parameter[m
[32m+[m[32m    if (str.charCodeAt(i++) !== 59/* ';' */)[m
[32m+[m[32m      return;[m
[32m+[m
[32m+[m[32m    // Consume whitespace[m
[32m+[m[32m    for (; i < str.length; ++i) {[m
[32m+[m[32m      const code = str.charCodeAt(i);[m
[32m+[m[32m      if (code !== 32/* ' ' */ && code !== 9/* '\t' */)[m
[32m+[m[32m        break;[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    // Ended on whitespace (malformed)[m
[32m+[m[32m    if (i === str.length)[m
[32m+[m[32m      return;[m
[32m+[m
[32m+[m[32m    let name;[m
[32m+[m[32m    const nameStart = i;[m
[32m+[m[32m    // Parse parameter name[m
[32m+[m[32m    for (; i < str.length; ++i) {[m
[32m+[m[32m      const code = str.charCodeAt(i);[m
[32m+[m[32m      if (TOKEN[code] !== 1) {[m
[32m+[m[32m        if (code === 61/* '=' */)[m
[32m+[m[32m          break;[m
[32m+[m[32m        return;[m
[32m+[m[32m      }[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    // No value (malformed)[m
[32m+[m[32m    if (i === str.length)[m
[32m+[m[32m      return;[m
[32m+[m
[32m+[m[32m    let value = '';[m
[32m+[m[32m    let valueStart;[m
[32m+[m[32m    let charset;[m
[32m+[m[32m    //~ let lang;[m
[32m+[m[32m    name = str.slice(nameStart, i);[m
[32m+[m[32m    if (name.charCodeAt(name.length - 1) === 42/* '*' */) {[m
[32m+[m[32m      // Extended value[m
[32m+[m
[32m+[m[32m      const charsetStart = ++i;[m
[32m+[m[32m      // Parse charset name[m
[32m+[m[32m      for (; i < str.length; ++i) {[m
[32m+[m[32m        const code = str.charCodeAt(i);[m
[32m+[m[32m        if (CHARSET[code] !== 1) {[m
[32m+[m[32m          if (code !== 39/* '\'' */)[m
[32m+[m[32m            return;[m
[32m+[m[32m          break;[m
[32m+[m[32m        }[m
[32m+[m[32m      }[m
[32m+[m
[32m+[m[32m      // Incomplete charset (malformed)[m
[32m+[m[32m      if (i === str.length)[m
[32m+[m[32m        return;[m
[32m+[m
[32m+[m[32m      charset = str.slice(charsetStart, i);[m
[32m+[m[32m      ++i; // Skip over the '\''[m
[32m+[m
[32m+[m[32m      //~ const langStart = ++i;[m
[32m+[m[32m      // Parse language name[m
[32m+[m[32m      for (; i < str.length; ++i) {[m
[32m+[m[32m        const code = str.charCodeAt(i);[m
[32m+[m[32m        if (code === 39/* '\'' */)[m
[32m+[m[32m          break;[m
[32m+[m[32m      }[m
[32m+[m
[32m+[m[32m      // Incomplete language (malformed)[m
[32m+[m[32m      if (i === str.length)[m
[32m+[m[32m        return;[m
[32m+[m
[32m+[m[32m      //~ lang = str.slice(langStart, i);[m
[32m+[m[32m      ++i; // Skip over the '\''[m
[32m+[m
[32m+[m[32m      // No value (malformed)[m
[32m+[m[32m      if (i === str.length)[m
[32m+[m[32m        return;[m
[32m+[m
[32m+[m[32m      valueStart = i;[m
[32m+[m
[32m+[m[32m      let encode = 0;[m
[32m+[m[32m      // Parse value[m
[32m+[m[32m      for (; i < str.length; ++i) {[m
[32m+[m[32m        const code = str.charCodeAt(i);[m
[32m+[m[32m        if (EXTENDED_VALUE[code] !== 1) {[m
[32m+[m[32m          if (code === 37/* '%' */) {[m
[32m+[m[32m            let hexUpper;[m
[32m+[m[32m            let hexLower;[m
[32m+[m[32m            if (i + 2 < str.length[m
[32m+[m[32m                && (hexUpper = HEX_VALUES[str.charCodeAt(i + 1)]) !== -1[m
[32m+[m[32m                && (hexLower = HEX_VALUES[str.charCodeAt(i + 2)]) !== -1) {[m
[32m+[m[32m              const byteVal = (hexUpper << 4) + hexLower;[m
[32m+[m[32m              value += str.slice(valueStart, i);[m
[32m+[m[32m              value += String.fromCharCode(byteVal);[m
[32m+[m[32m              i += 2;[m
[32m+[m[32m              valueStart = i + 1;[m
[32m+[m[32m              if (byteVal >= 128)[m
[32m+[m[32m                encode = 2;[m
[32m+[m[32m              else if (encode === 0)[m
[32m+[m[32m                encode = 1;[m
[32m+[m[32m              continue;[m
[32m+[m[32m            }[m
[32m+[m[32m            // '%' disallowed in non-percent encoded contexts (malformed)[m
[32m+[m[32m            return;[m
[32m+[m[32m          }[m
[32m+[m[32m          break;[m
[32m+[m[32m        }[m
[32m+[m[32m      }[m
[32m+[m
[32m+[m[32m      value += str.slice(valueStart, i);[m
[32m+[m[32m      value = convertToUTF8(value, charset, encode);[m
[32m+[m[32m      if (value === undefined)[m
[32m+[m[32m        return;[m
[32m+[m[32m    } else {[m
[32m+[m[32m      // Non-extended value[m
[32m+[m
[32m+[m[32m      ++i; // Skip over '='[m
[32m+[m
[32m+[m[32m      // No value (malformed)[m
[32m+[m[32m      if (i === str.length)[m
[32m+[m[32m        return;[m
[32m+[m
[32m+[m[32m      if (str.charCodeAt(i) === 34/* '"' */) {[m
[32m+[m[32m        valueStart = ++i;[m
[32m+[m[32m        let escaping = false;[m
[32m+[m[32m        // Parse quoted value[m
[32m+[m[32m        for (; i < str.length; ++i) {[m
[32m+[m[32m          const code = str.charCodeAt(i);[m
[32m+[m[32m          if (code === 92/* '\\' */) {[m
[32m+[m[32m            if (escaping) {[m
[32m+[m[32m              valueStart = i;[m
[32m+[m[32m              escaping = false;[m
[32m+[m[32m            } else {[m
[32m+[m[32m              value += str.slice(valueStart, i);[m
[32m+[m[32m              escaping = true;[m
[32m+[m[32m            }[m
[32m+[m[32m            continue;[m
[32m+[m[32m          }[m
[32m+[m[32m          if (code === 34/* '"' */) {[m
[32m+[m[32m            if (escaping) {[m
[32m+[m[32m              valueStart = i;[m
[32m+[m[32m              escaping = false;[m
[32m+[m[32m              continue;[m
[32m+[m[32m            }[m
[32m+[m[32m            value += str.slice(valueStart, i);[m
[32m+[m[32m            break;[m
[32m+[m[32m          }[m
[32m+[m[32m          if (escaping) {[m
[32m+[m[32m            valueStart = i - 1;[m
[32m+[m[32m            escaping = false;[m
[32m+[m[32m          }[m
[32m+[m[32m          // Invalid unescaped quoted character (malformed)[m
[32m+[m[32m          if (QDTEXT[code] !== 1)[m
[32m+[m[32m            return;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        // No end quote (malformed)[m
[32m+[m[32m        if (i === str.length)[m
[32m+[m[32m          return;[m
[32m+[m
[32m+[m[32m        ++i; // Skip over double quote[m
[32m+[m[32m      } else {[m
[32m+[m[32m        valueStart = i;[m
[32m+[m[32m        // Parse unquoted value[m
[32m+[m[32m        for (; i < str.length; ++i) {[m
[32m+[m[32m          const code = str.charCodeAt(i);[m
[32m+[m[32m          if (TOKEN[code] !== 1) {[m
[32m+[m[32m            // No value (malformed)[m
[32m+[m[32m            if (i === valueStart)[m
[32m+[m[32m              return;[m
[32m+[m[32m            break;[m
[32m+[m[32m          }[m
[32m+[m[32m        }[m
[32m+[m[32m        value = str.slice(valueStart, i);[m
[32m+[m[32m      }[m
[32m+[m
[32m+[m[32m      value = defDecoder(value, 2);[m
[32m+[m[32m      if (value === undefined)[m
[32m+[m[32m        return;[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    name = name.toLowerCase();[m
[32m+[m[32m    if (params[name] === undefined)[m
[32m+[m[32m      params[name] = value;[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  return params;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction getDecoder(charset) {[m
[32m+[m[32m  let lc;[m
[32m+[m[32m  while (true) {[m
[32m+[m[32m    switch (charset) {[m
[32m+[m[32m      case 'utf-8':[m
[32m+[m[32m      case 'utf8':[m
[32m+[m[32m        return decoders.utf8;[m
[32m+[m[32m      case 'latin1':[m
[32m+[m[32m      case 'ascii': // TODO: Make these a separate, strict decoder?[m
[32m+[m[32m      case 'us-ascii':[m
[32m+[m[32m      case 'iso-8859-1':[m
[32m+[m[32m      case 'iso8859-1':[m
[32m+[m[32m      case 'iso88591':[m
[32m+[m[32m      case 'iso_8859-1':[m
[32m+[m[32m      case 'windows-1252':[m
[32m+[m[32m      case 'iso_8859-1:1987':[m
[32m+[m[32m      case 'cp1252':[m
[32m+[m[32m      case 'x-cp1252':[m
[32m+[m[32m        return decoders.latin1;[m
[32m+[m[32m      case 'utf16le':[m
[32m+[m[32m      case 'utf-16le':[m
[32m+[m[32m      case 'ucs2':[m
[32m+[m[32m      case 'ucs-2':[m
[32m+[m[32m        return decoders.utf16le;[m
[32m+[m[32m      case 'base64':[m
[32m+[m[32m        return decoders.base64;[m
[32m+[m[32m      default:[m
[32m+[m[32m        if (lc === undefined) {[m
[32m+[m[32m          lc = true;[m
[32m+[m[32m          charset = charset.toLowerCase();[m
[32m+[m[32m          continue;[m
[32m+[m[32m        }[m
[32m+[m[32m        return decoders.other.bind(charset);[m
[32m+[m[32m    }[m
[32m+[m[32m  }[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mconst decoders = {[m
[32m+[m[32m  utf8: (data, hint) => {[m
[32m+[m[32m    if (data.length === 0)[m
[32m+[m[32m      return '';[m
[32m+[m[32m    if (typeof data === 'string') {[m
[32m+[m[32m      // If `data` never had any percent-encoded bytes or never had any that[m
[32m+[m[32m      // were outside of the ASCII range, then we can safely just return the[m
[32m+[m[32m      // input since UTF-8 is ASCII compatible[m
[32m+[m[32m      if (hint < 2)[m
[32m+[m[32m        return data;[m
[32m+[m
[32m+[m[32m      data = Buffer.from(data, 'latin1');[m
[32m+[m[32m    }[m
[32m+[m[32m    return data.utf8Slice(0, data.length);[m
[32m+[m[32m  },[m
[32m+[m
[32m+[m[32m  latin1: (data, hint) => {[m
[32m+[m[32m    if (data.length === 0)[m
[32m+[m[32m      return '';[m
[32m+[m[32m    if (typeof data === 'string')[m
[32m+[m[32m      return data;[m
[32m+[m[32m    return data.latin1Slice(0, data.length);[m
[32m+[m[32m  },[m
[32m+[m
[32m+[m[32m  utf16le: (data, hint) => {[m
[32m+[m[32m    if (data.length === 0)[m
[32m+[m[32m      return '';[m
[32m+[m[32m    if (typeof data === 'string')[m
[32m+[m[32m      data = Buffer.from(data, 'latin1');[m
[32m+[m[32m    return data.ucs2Slice(0, data.length);[m
[32m+[m[32m  },[m
[32m+[m
[32m+[m[32m  base64: (data, hint) => {[m
[32m+[m[32m    if (data.length === 0)[m
[32m+[m[32m      return '';[m
[32m+[m[32m    if (typeof data === 'string')[m
[32m+[m[32m      data = Buffer.from(data, 'latin1');[m
[32m+[m[32m    return data.base64Slice(0, data.length);[m
[32m+[m[32m  },[m
[32m+[m
[32m+[m[32m  other: (data, hint) => {[m
[32m+[m[32m    if (data.length === 0)[m
[32m+[m[32m      return '';[m
[32m+[m[32m    if (typeof data === 'string')[m
[32m+[m[32m      data = Buffer.from(data, 'latin1');[m
[32m+[m[32m    try {[m
[32m+[m[32m      const decoder = new TextDecoder(this);[m
[32m+[m[32m      return decoder.decode(data);[m
[32m+[m[32m    } catch {}[m
[32m+[m[32m  },[m
[32m+[m[32m};[m
[32m+[m
[32m+[m[32mfunction convertToUTF8(data, charset, hint) {[m
[32m+[m[32m  const decode = getDecoder(charset);[m
[32m+[m[32m  if (decode)[m
[32m+[m[32m    return decode(data, hint);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction basename(path) {[m
[32m+[m[32m  if (typeof path !== 'string')[m
[32m+[m[32m    return '';[m
[32m+[m[32m  for (let i = path.length - 1; i >= 0; --i) {[m
[32m+[m[32m    switch (path.charCodeAt(i)) {[m
[32m+[m[32m      case 0x2F: // '/'[m
[32m+[m[32m      case 0x5C: // '\'[m
[32m+[m[32m        path = path.slice(i + 1);[m
[32m+[m[32m        return (path === '..' || path === '.' ? '' : path);[m
[32m+[m[32m    }[m
[32m+[m[32m  }[m
[32m+[m[32m  return (path === '..' || path === '.' ? '' : path);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mconst TOKEN = [[m
[32m+[m[32m  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,[m
[32m+[m[32m  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,[m
[32m+[m[32m  0, 1, 0, 1, 1, 1, 1, 1, 0, 0, 1, 1, 0, 1, 1, 0,[m
[32m+[m[32m  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0,[m
[32m+[m[32m  0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,[m
[32m+[m[32m  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1,[m
[32m+[m[32m  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,[m
[32m+[m[32m  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0,[m
[32m+[m[32m  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,[m
[32m+[m[32m  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,[m
[32m+[m[32m  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,[m
[32m+[m[32m  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,[m
[32m+[m[32m  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,[m
[32m+[m[32m  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,[m
[32m+[m[32m  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,[m
[32m+[m[32m  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,[m
[32m+[m[32m];[m
[32m+[m
[32m+[m[32mconst QDTEXT = [[m
[32m+[m[32m  0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0,[m
[32m+[m[32m  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,[m
[32m+[m[32m  1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,[m
[32m+[m[32m  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,[m
[32m+[m[32m  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,[m
[32m+[m[32m  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1,[m
[32m+[m[32m  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,[m
[32m+[m[32m  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,[m
[32m+[m[32m  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,[m
[32m+[m[32m  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,[m
[32m+[m[32m  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,[m
[32m+[m[32m  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,[m
[32m+[m[32m  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,[m
[32m+[m[32m  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,[m
[32m+[m[32m  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,[m
[32m+[m[32m  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,[m
[32m+[m[32m];[m
[32m+[m
[32m+[m[32mconst CHARSET = [[m
[32m+[m[32m  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,[m
[32m+[m[32m  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,[m
[32m+[m[32m  0, 1, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0,[m
[32m+[m[32m  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0,[m
[32m+[m[32m  0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,[m
[32m+[m[32m  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1,[m
[32m+[m[32m  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,[m
[32m+[m[32m  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 0,[m
[32m+[m[32m  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,[m
[32m+[m[32m  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,[m
[32m+[m[32m  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,[m
[32m+[m[32m  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,[m
[32m+[m[32m  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,[m
[32m+[m[32m  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,[m
[32m+[m[32m  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,[m
[32m+[m[32m  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,[m
[32m+[m[32m];[m
[32m+[m
[32m+[m[32mconst EXTENDED_VALUE = [[m
[32m+[m[32m  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,[m
[32m+[m[32m  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,[m
[32m+[m[32m  0, 1, 0, 1, 1, 0, 1, 0, 0, 0, 0, 1, 0, 1, 1, 0,[m
[32m+[m[32m  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0,[m
[32m+[m[32m  0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,[m
[32m+[m[32m  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1,[m
[32m+[m[32m  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,[m
[32m+[m[32m  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0,[m
[32m+[m[32m  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,[m
[32m+[m[32m  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,[m
[32m+[m[32m  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,[m
[32m+[m[32m  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,[m
[32m+[m[32m  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,[m
[32m+[m[32m  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,[m
[32m+[m[32m  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,[m
[32m+[m[32m  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,[m
[32m+[m[32m];[m
[32m+[m
[32m+[m[32m/* eslint-disable no-multi-spaces */[m
[32m+[m[32mconst HEX_VALUES = [[m
[32m+[m[32m  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,[m
[32m+[m[32m  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,[m
[32m+[m[32m  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,[m
[32m+[m[32m   0,  1,  2,  3,  4,  5,  6,  7,  8,  9, -1, -1, -1, -1, -1, -1,[m
[32m+[m[32m  -1, 10, 11, 12, 13, 14, 15, -1, -1, -1, -1, -1, -1, -1, -1, -1,[m
[32m+[m[32m  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,[m
[32m+[m[32m  -1, 10, 11, 12, 13, 14, 15, -1, -1, -1, -1, -1, -1, -1, -1, -1,[m
[32m+[m[32m  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,[m
[32m+[m[32m  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,[m
[32m+[m[32m  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,[m
[32m+[m[32m  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,[m
[32m+[m[32m  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,[m
[32m+[m[32m  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,[m
[32m+[m[32m  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,[m
[32m+[m[32m  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,[m
[32m+[m[32m  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,[m
[32m+[m[32m];[m
[32m+[m[32m/* eslint-enable no-multi-spaces */[m
[32m+[m
[32m+[m[32mmodule.exports = {[m
[32m+[m[32m  basename,[m
[32m+[m[32m  convertToUTF8,[m
[32m+[m[32m  getDecoder,[m
[32m+[m[32m  parseContentType,[m
[32m+[m[32m  parseDisposition,[m
[32m+[m[32m};[m
[1mdiff --git a/node_modules/busboy/package.json b/node_modules/busboy/package.json[m
[1mnew file mode 100644[m
[1mindex 0000000..ac2577f[m
[1m--- /dev/null[m
[1m+++ b/node_modules/busboy/package.json[m
[36m@@ -0,0 +1,22 @@[m
[32m+[m[32m{ "name": "busboy",[m
[32m+[m[32m  "version": "1.6.0",[m
[32m+[m[32m  "author": "Brian White <mscdex@mscdex.net>",[m
[32m+[m[32m  "description": "A streaming parser for HTML form data for node.js",[m
[32m+[m[32m  "main": "./lib/index.js",[m
[32m+[m[32m  "dependencies": {[m
[32m+[m[32m    "streamsearch": "^1.1.0"[m
[32m+[m[32m  },[m
[32m+[m[32m  "devDependencies": {[m
[32m+[m[32m    "@mscdex/eslint-config": "^1.1.0",[m
[32m+[m[32m    "eslint": "^7.32.0"[m
[32m+[m[32m  },[m
[32m+[m[32m  "scripts": {[m
[32m+[m[32m    "test": "node test/test.js",[m
[32m+[m[32m    "lint": "eslint --cache --report-unused-disable-directives --ext=.js .eslintrc.js lib test bench",[m
[32m+[m[32m    "lint:fix": "npm run lint -- --fix"[m
[32m+[m[32m  },[m
[32m+[m[32m  "engines": { "node": ">=10.16.0" },[m
[32m+[m[32m  "keywords": [ "uploads", "forms", "multipart", "form-data" ],[m
[32m+[m[32m  "licenses": [ { "type": "MIT", "url": "http://github.com/mscdex/busboy/raw/master/LICENSE" } ],[m
[32m+[m[32m  "repository": { "type": "git", "url": "http://github.com/mscdex/busboy.git" }[m
[32m+[m[32m}[m
[1mdiff --git a/node_modules/busboy/test/common.js b/node_modules/busboy/test/common.js[m
[1mnew file mode 100644[m
[1mindex 0000000..fb82ad8[m
[1m--- /dev/null[m
[1m+++ b/node_modules/busboy/test/common.js[m
[36m@@ -0,0 +1,109 @@[m
[32m+[m[32m'use strict';[m
[32m+[m
[32m+[m[32mconst assert = require('assert');[m
[32m+[m[32mconst { inspect } = require('util');[m
[32m+[m
[32m+[m[32mconst mustCallChecks = [];[m
[32m+[m
[32m+[m[32mfunction noop() {}[m
[32m+[m
[32m+[m[32mfunction runCallChecks(exitCode) {[m
[32m+[m[32m  if (exitCode !== 0) return;[m
[32m+[m
[32m+[m[32m  const failed = mustCallChecks.filter((context) => {[m
[32m+[m[32m    if ('minimum' in context) {[m
[32m+[m[32m      context.messageSegment = `at least ${context.minimum}`;[m
[32m+[m[32m      return context.actual < context.minimum;[m
[32m+[m[32m    }[m
[32m+[m[32m    context.messageSegment = `exactly ${context.exact}`;[m
[32m+[m[32m    return context.actual !== context.exact;[m
[32m+[m[32m  });[m
[32m+[m
[32m+[m[32m  failed.forEach((context) => {[m
[32m+[m[32m    console.error('Mismatched %s function calls. Expected %s, actual %d.',[m
[32m+[m[32m                  context.name,[m
[32m+[m[32m                  context.messageSegment,[m
[32m+[m[32m                  context.actual);[m
[32m+[m[32m    console.error(context.stack.split('\n').slice(2).join('\n'));[m
[32m+[m[32m  });[m
[32m+[m
[32m+[m[32m  if (failed.length)[m
[32m+[m[32m    process.exit(1);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction mustCall(fn, exact) {[m
[32m+[m[32m  return _mustCallInner(fn, exact, 'exact');[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction mustCallAtLeast(fn, minimum) {[m
[32m+[m[32m  return _mustCallInner(fn, minimum, 'minimum');[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction _mustCallInner(fn, criteria = 1, field) {[m
[32m+[m[32m  if (process._exiting)[m
[32m+[m[32m    throw new Error('Cannot use common.mustCall*() in process exit handler');[m
[32m+[m
[32m+[m[32m  if (typeof fn === 'number') {[m
[32m+[m[32m    criteria = fn;[m
[32m+[m[32m    fn = noop;[m
[32m+[m[32m  } else if (fn === undefined) {[m
[32m+[m[32m    fn = noop;[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  if (typeof criteria !== 'number')[m
[32m+[m[32m    throw new TypeError(`Invalid ${field} value: ${criteria}`);[m
[32m+[m
[32m+[m[32m  const context = {[m
[32m+[m[32m    [field]: criteria,[m
[32m+[m[32m    actual: 0,[m
[32m+[m[32m    stack: inspect(new Error()),[m
[32m+[m[32m    name: fn.name || '<anonymous>'[m
[32m+[m[32m  };[m
[32m+[m
[32m+[m[32m  // Add the exit listener only once to avoid listener leak warnings[m
[32m+[m[32m  if (mustCallChecks.length === 0)[m
[32m+[m[32m    process.on('exit', runCallChecks);[m
[32m+[m
[32m+[m[32m  mustCallChecks.push(context);[m
[32m+[m
[32m+[m[32m  function wrapped(...args) {[m
[32m+[m[32m    ++context.actual;[m
[32m+[m[32m    return fn.call(this, ...args);[m
[32m+[m[32m  }[m
[32m+[m[32m  // TODO: remove origFn?[m
[32m+[m[32m  wrapped.origFn = fn;[m
[32m+[m
[32m+[m[32m  return wrapped;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction getCallSite(top) {[m
[32m+[m[32m  const originalStackFormatter = Error.prepareStackTrace;[m
[32m+[m[32m  Error.prepareStackTrace = (err, stack) =>[m
[32m+[m[32m    `${stack[0].getFileName()}:${stack[0].getLineNumber()}`;[m
[32m+[m[32m  const err = new Error();[m
[32m+[m[32m  Error.captureStackTrace(err, top);[m
[32m+[m[32m  // With the V8 Error API, the stack is not formatted until it is accessed[m
[32m+[m[32m  // eslint-disable-next-line no-unused-expressions[m
[32m+[m[32m  err.stack;[m
[32m+[m[32m  Error.prepareStackTrace = originalStackFormatter;[m
[32m+[m[32m  return err.stack;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction mustNotCall(msg) {[m
[32m+[m[32m  const callSite = getCallSite(mustNotCall);[m
[32m+[m[32m  return function mustNotCall(...args) {[m
[32m+[m[32m    args = args.map(inspect).join(', ');[m
[32m+[m[32m    const argsInfo = (args.length > 0[m
[32m+[m[32m                      ? `\ncalled with arguments: ${args}`[m
[32m+[m[32m                      : '');[m
[32m+[m[32m    assert.fail([m
[32m+[m[32m      `${msg || 'function should not have been called'} at ${callSite}`[m
[32m+[m[32m        + argsInfo);[m
[32m+[m[32m  };[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mmodule.exports = {[m
[32m+[m[32m  mustCall,[m
[32m+[m[32m  mustCallAtLeast,[m
[32m+[m[32m  mustNotCall,[m
[32m+[m[32m};[m
[1mdiff --git a/node_modules/busboy/test/test-types-multipart-charsets.js b/node_modules/busboy/test/test-types-multipart-charsets.js[m
[1mnew file mode 100644[m
[1mindex 0000000..ed9c38a[m
[1m--- /dev/null[m
[1m+++ b/node_modules/busboy/test/test-types-multipart-charsets.js[m
[36m@@ -0,0 +1,94 @@[m
[32m+[m[32m'use strict';[m
[32m+[m
[32m+[m[32mconst assert = require('assert');[m
[32m+[m[32mconst { inspect } = require('util');[m
[32m+[m
[32m+[m[32mconst { mustCall } = require(`${__dirname}/common.js`);[m
[32m+[m
[32m+[m[32mconst busboy = require('..');[m
[32m+[m
[32m+[m[32mconst input = Buffer.from([[m
[32m+[m[32m  '-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m 'Content-Disposition: form-data; '[m
[32m+[m[32m   + 'name="upload_file_0"; filename="テスト.dat"',[m
[32m+[m[32m 'Content-Type: application/octet-stream',[m
[32m+[m[32m '',[m
[32m+[m[32m 'A'.repeat(1023),[m
[32m+[m[32m '-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k--'[m
[32m+[m[32m].join('\r\n'));[m
[32m+[m[32mconst boundary = '---------------------------paZqsnEHRufoShdX6fh0lUhXBP4k';[m
[32m+[m[32mconst expected = [[m
[32m+[m[32m  { type: 'file',[m
[32m+[m[32m    name: 'upload_file_0',[m
[32m+[m[32m    data: Buffer.from('A'.repeat(1023)),[m
[32m+[m[32m    info: {[m
[32m+[m[32m      filename: 'テスト.dat',[m
[32m+[m[32m      encoding: '7bit',[m
[32m+[m[32m      mimeType: 'application/octet-stream',[m
[32m+[m[32m    },[m
[32m+[m[32m    limited: false,[m
[32m+[m[32m  },[m
[32m+[m[32m];[m
[32m+[m[32mconst bb = busboy({[m
[32m+[m[32m  defParamCharset: 'utf8',[m
[32m+[m[32m  headers: {[m
[32m+[m[32m    'content-type': `multipart/form-data; boundary=${boundary}`,[m
[32m+[m[32m  }[m
[32m+[m[32m});[m
[32m+[m[32mconst results = [];[m
[32m+[m
[32m+[m[32mbb.on('field', (name, val, info) => {[m
[32m+[m[32m  results.push({ type: 'field', name, val, info });[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mbb.on('file', (name, stream, info) => {[m
[32m+[m[32m  const data = [];[m
[32m+[m[32m  let nb = 0;[m
[32m+[m[32m  const file = {[m
[32m+[m[32m    type: 'file',[m
[32m+[m[32m    name,[m
[32m+[m[32m    data: null,[m
[32m+[m[32m    info,[m
[32m+[m[32m    limited: false,[m
[32m+[m[32m  };[m
[32m+[m[32m  results.push(file);[m
[32m+[m[32m  stream.on('data', (d) => {[m
[32m+[m[32m    data.push(d);[m
[32m+[m[32m    nb += d.length;[m
[32m+[m[32m  }).on('limit', () => {[m
[32m+[m[32m    file.limited = true;[m
[32m+[m[32m  }).on('close', () => {[m
[32m+[m[32m    file.data = Buffer.concat(data, nb);[m
[32m+[m[32m    assert.strictEqual(stream.truncated, file.limited);[m
[32m+[m[32m  }).once('error', (err) => {[m
[32m+[m[32m    file.err = err.message;[m
[32m+[m[32m  });[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mbb.on('error', (err) => {[m
[32m+[m[32m  results.push({ error: err.message });[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mbb.on('partsLimit', () => {[m
[32m+[m[32m  results.push('partsLimit');[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mbb.on('filesLimit', () => {[m
[32m+[m[32m  results.push('filesLimit');[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mbb.on('fieldsLimit', () => {[m
[32m+[m[32m  results.push('fieldsLimit');[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mbb.on('close', mustCall(() => {[m
[32m+[m[32m  assert.deepStrictEqual([m
[32m+[m[32m    results,[m
[32m+[m[32m    expected,[m
[32m+[m[32m    'Results mismatch.\n'[m
[32m+[m[32m      + `Parsed: ${inspect(results)}\n`[m
[32m+[m[32m      + `Expected: ${inspect(expected)}`[m
[32m+[m[32m  );[m
[32m+[m[32m}));[m
[32m+[m
[32m+[m[32mbb.end(input);[m
[1mdiff --git a/node_modules/busboy/test/test-types-multipart-stream-pause.js b/node_modules/busboy/test/test-types-multipart-stream-pause.js[m
[1mnew file mode 100644[m
[1mindex 0000000..df7268a[m
[1m--- /dev/null[m
[1m+++ b/node_modules/busboy/test/test-types-multipart-stream-pause.js[m
[36m@@ -0,0 +1,102 @@[m
[32m+[m[32m'use strict';[m
[32m+[m
[32m+[m[32mconst assert = require('assert');[m
[32m+[m[32mconst { randomFillSync } = require('crypto');[m
[32m+[m[32mconst { inspect } = require('util');[m
[32m+[m
[32m+[m[32mconst busboy = require('..');[m
[32m+[m
[32m+[m[32mconst { mustCall } = require('./common.js');[m
[32m+[m
[32m+[m[32mconst BOUNDARY = 'u2KxIV5yF1y+xUspOQCCZopaVgeV6Jxihv35XQJmuTx8X3sh';[m
[32m+[m
[32m+[m[32mfunction formDataSection(key, value) {[m
[32m+[m[32m  return Buffer.from([m
[32m+[m[32m    `\r\n--${BOUNDARY}`[m
[32m+[m[32m      + `\r\nContent-Disposition: form-data; name="${key}"`[m
[32m+[m[32m      + `\r\n\r\n${value}`[m
[32m+[m[32m  );[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction formDataFile(key, filename, contentType) {[m
[32m+[m[32m  const buf = Buffer.allocUnsafe(100000);[m
[32m+[m[32m  return Buffer.concat([[m
[32m+[m[32m    Buffer.from(`\r\n--${BOUNDARY}\r\n`),[m
[32m+[m[32m    Buffer.from(`Content-Disposition: form-data; name="${key}"`[m
[32m+[m[32m                  + `; filename="${filename}"\r\n`),[m
[32m+[m[32m    Buffer.from(`Content-Type: ${contentType}\r\n\r\n`),[m
[32m+[m[32m    randomFillSync(buf)[m
[32m+[m[32m  ]);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mconst reqChunks = [[m
[32m+[m[32m  Buffer.concat([[m
[32m+[m[32m    formDataFile('file', 'file.bin', 'application/octet-stream'),[m
[32m+[m[32m    formDataSection('foo', 'foo value'),[m
[32m+[m[32m  ]),[m
[32m+[m[32m  formDataSection('bar', 'bar value'),[m
[32m+[m[32m  Buffer.from(`\r\n--${BOUNDARY}--\r\n`)[m
[32m+[m[32m];[m
[32m+[m[32mconst bb = busboy({[m
[32m+[m[32m  headers: {[m
[32m+[m[32m    'content-type': `multipart/form-data; boundary=${BOUNDARY}`[m
[32m+[m[32m  }[m
[32m+[m[32m});[m
[32m+[m[32mconst expected = [[m
[32m+[m[32m  { type: 'file',[m
[32m+[m[32m    name: 'file',[m
[32m+[m[32m    info: {[m
[32m+[m[32m      filename: 'file.bin',[m
[32m+[m[32m      encoding: '7bit',[m
[32m+[m[32m      mimeType: 'application/octet-stream',[m
[32m+[m[32m    },[m
[32m+[m[32m  },[m
[32m+[m[32m  { type: 'field',[m
[32m+[m[32m    name: 'foo',[m
[32m+[m[32m    val: 'foo value',[m
[32m+[m[32m    info: {[m
[32m+[m[32m      nameTruncated: false,[m
[32m+[m[32m      valueTruncated: false,[m
[32m+[m[32m      encoding: '7bit',[m
[32m+[m[32m      mimeType: 'text/plain',[m
[32m+[m[32m    },[m
[32m+[m[32m  },[m
[32m+[m[32m  { type: 'field',[m
[32m+[m[32m    name: 'bar',[m
[32m+[m[32m    val: 'bar value',[m
[32m+[m[32m    info: {[m
[32m+[m[32m      nameTruncated: false,[m
[32m+[m[32m      valueTruncated: false,[m
[32m+[m[32m      encoding: '7bit',[m
[32m+[m[32m      mimeType: 'text/plain',[m
[32m+[m[32m    },[m
[32m+[m[32m  },[m
[32m+[m[32m];[m
[32m+[m[32mconst results = [];[m
[32m+[m
[32m+[m[32mbb.on('field', (name, val, info) => {[m
[32m+[m[32m  results.push({ type: 'field', name, val, info });[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mbb.on('file', (name, stream, info) => {[m
[32m+[m[32m  results.push({ type: 'file', name, info });[m
[32m+[m[32m  // Simulate a pipe where the destination is pausing (perhaps due to waiting[m
[32m+[m[32m  // for file system write to finish)[m
[32m+[m[32m  setTimeout(() => {[m
[32m+[m[32m    stream.resume();[m
[32m+[m[32m  }, 10);[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mbb.on('close', mustCall(() => {[m
[32m+[m[32m  assert.deepStrictEqual([m
[32m+[m[32m    results,[m
[32m+[m[32m    expected,[m
[32m+[m[32m    'Results mismatch.\n'[m
[32m+[m[32m      + `Parsed: ${inspect(results)}\n`[m
[32m+[m[32m      + `Expected: ${inspect(expected)}`[m
[32m+[m[32m  );[m
[32m+[m[32m}));[m
[32m+[m
[32m+[m[32mfor (const chunk of reqChunks)[m
[32m+[m[32m  bb.write(chunk);[m
[32m+[m[32mbb.end();[m
[1mdiff --git a/node_modules/busboy/test/test-types-multipart.js b/node_modules/busboy/test/test-types-multipart.js[m
[1mnew file mode 100644[m
[1mindex 0000000..9755642[m
[1m--- /dev/null[m
[1m+++ b/node_modules/busboy/test/test-types-multipart.js[m
[36m@@ -0,0 +1,1053 @@[m
[32m+[m[32m'use strict';[m
[32m+[m
[32m+[m[32mconst assert = require('assert');[m
[32m+[m[32mconst { inspect } = require('util');[m
[32m+[m
[32m+[m[32mconst busboy = require('..');[m
[32m+[m
[32m+[m[32mconst active = new Map();[m
[32m+[m
[32m+[m[32mconst tests = [[m
[32m+[m[32m  { source: [[m
[32m+[m[32m      ['-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m       'Content-Disposition: form-data; name="file_name_0"',[m
[32m+[m[32m       '',[m
[32m+[m[32m       'super alpha file',[m
[32m+[m[32m       '-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m       'Content-Disposition: form-data; name="file_name_1"',[m
[32m+[m[32m       '',[m
[32m+[m[32m       'super beta file',[m
[32m+[m[32m       '-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m       'Content-Disposition: form-data; '[m
[32m+[m[32m         + 'name="upload_file_0"; filename="1k_a.dat"',[m
[32m+[m[32m       'Content-Type: application/octet-stream',[m
[32m+[m[32m       '',[m
[32m+[m[32m       'A'.repeat(1023),[m
[32m+[m[32m       '-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m       'Content-Disposition: form-data; '[m
[32m+[m[32m         + 'name="upload_file_1"; filename="1k_b.dat"',[m
[32m+[m[32m       'Content-Type: application/octet-stream',[m
[32m+[m[32m       '',[m
[32m+[m[32m       'B'.repeat(1023),[m
[32m+[m[32m       '-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k--'[m
[32m+[m[32m      ].join('\r\n')[m
[32m+[m[32m    ],[m
[32m+[m[32m    boundary: '---------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m    expected: [[m
[32m+[m[32m      { type: 'field',[m
[32m+[m[32m        name: 'file_name_0',[m
[32m+[m[32m        val: 'super alpha file',[m
[32m+[m[32m        info: {[m
[32m+[m[32m          nameTruncated: false,[m
[32m+[m[32m          valueTruncated: false,[m
[32m+[m[32m          encoding: '7bit',[m
[32m+[m[32m          mimeType: 'text/plain',[m
[32m+[m[32m        },[m
[32m+[m[32m      },[m
[32m+[m[32m      { type: 'field',[m
[32m+[m[32m        name: 'file_name_1',[m
[32m+[m[32m        val: 'super beta file',[m
[32m+[m[32m        info: {[m
[32m+[m[32m          nameTruncated: false,[m
[32m+[m[32m          valueTruncated: false,[m
[32m+[m[32m          encoding: '7bit',[m
[32m+[m[32m          mimeType: 'text/plain',[m
[32m+[m[32m        },[m
[32m+[m[32m      },[m
[32m+[m[32m      { type: 'file',[m
[32m+[m[32m        name: 'upload_file_0',[m
[32m+[m[32m        data: Buffer.from('A'.repeat(1023)),[m
[32m+[m[32m        info: {[m
[32m+[m[32m          filename: '1k_a.dat',[m
[32m+[m[32m          encoding: '7bit',[m
[32m+[m[32m          mimeType: 'application/octet-stream',[m
[32m+[m[32m        },[m
[32m+[m[32m        limited: false,[m
[32m+[m[32m      },[m
[32m+[m[32m      { type: 'file',[m
[32m+[m[32m        name: 'upload_file_1',[m
[32m+[m[32m        data: Buffer.from('B'.repeat(1023)),[m
[32m+[m[32m        info: {[m
[32m+[m[32m          filename: '1k_b.dat',[m
[32m+[m[32m          encoding: '7bit',[m
[32m+[m[32m          mimeType: 'application/octet-stream',[m
[32m+[m[32m        },[m
[32m+[m[32m        limited: false,[m
[32m+[m[32m      },[m
[32m+[m[32m    ],[m
[32m+[m[32m    what: 'Fields and files'[m
[32m+[m[32m  },[m
[32m+[m[32m  { source: [[m
[32m+[m[32m      ['------WebKitFormBoundaryTB2MiQ36fnSJlrhY',[m
[32m+[m[32m       'Content-Disposition: form-data; name="cont"',[m
[32m+[m[32m       '',[m
[32m+[m[32m       'some random content',[m
[32m+[m[32m       '------WebKitFormBoundaryTB2MiQ36fnSJlrhY',[m
[32m+[m[32m       'Content-Disposition: form-data; name="pass"',[m
[32m+[m[32m       '',[m
[32m+[m[32m       'some random pass',[m
[32m+[m[32m       '------WebKitFormBoundaryTB2MiQ36fnSJlrhY',[m
[32m+[m[32m       'Content-Disposition: form-data; name=bit',[m
[32m+[m[32m       '',[m
[32m+[m[32m       '2',[m
[32m+[m[32m       '------WebKitFormBoundaryTB2MiQ36fnSJlrhY--'[m
[32m+[m[32m      ].join('\r\n')[m
[32m+[m[32m    ],[m
[32m+[m[32m    boundary: '----WebKitFormBoundaryTB2MiQ36fnSJlrhY',[m
[32m+[m[32m    expected: [[m
[32m+[m[32m      { type: 'field',[m
[32m+[m[32m        name: 'cont',[m
[32m+[m[32m        val: 'some random content',[m
[32m+[m[32m        info: {[m
[32m+[m[32m          nameTruncated: false,[m
[32m+[m[32m          valueTruncated: false,[m
[32m+[m[32m          encoding: '7bit',[m
[32m+[m[32m          mimeType: 'text/plain',[m
[32m+[m[32m        },[m
[32m+[m[32m      },[m
[32m+[m[32m      { type: 'field',[m
[32m+[m[32m        name: 'pass',[m
[32m+[m[32m        val: 'some random pass',[m
[32m+[m[32m        info: {[m
[32m+[m[32m          nameTruncated: false,[m
[32m+[m[32m          valueTruncated: false,[m
[32m+[m[32m          encoding: '7bit',[m
[32m+[m[32m          mimeType: 'text/plain',[m
[32m+[m[32m        },[m
[32m+[m[32m      },[m
[32m+[m[32m      { type: 'field',[m
[32m+[m[32m        name: 'bit',[m
[32m+[m[32m        val: '2',[m
[32m+[m[32m        info: {[m
[32m+[m[32m          nameTruncated: false,[m
[32m+[m[32m          valueTruncated: false,[m
[32m+[m[32m          encoding: '7bit',[m
[32m+[m[32m          mimeType: 'text/plain',[m
[32m+[m[32m        },[m
[32m+[m[32m      },[m
[32m+[m[32m    ],[m
[32m+[m[32m    what: 'Fields only'[m
[32m+[m[32m  },[m
[32m+[m[32m  { source: [[m
[32m+[m[32m      ''[m
[32m+[m[32m    ],[m
[32m+[m[32m    boundary: '----WebKitFormBoundaryTB2MiQ36fnSJlrhY',[m
[32m+[m[32m    expected: [[m
[32m+[m[32m      { error: 'Unexpected end of form' },[m
[32m+[m[32m    ],[m
[32m+[m[32m    what: 'No fields and no files'[m
[32m+[m[32m  },[m
[32m+[m[32m  { source: [[m
[32m+[m[32m      ['-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m       'Content-Disposition: form-data; name="file_name_0"',[m
[32m+[m[32m       '',[m
[32m+[m[32m       'super alpha file',[m
[32m+[m[32m       '-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m       'Content-Disposition: form-data; '[m
[32m+[m[32m         + 'name="upload_file_0"; filename="1k_a.dat"',[m
[32m+[m[32m       'Content-Type: application/octet-stream',[m
[32m+[m[32m       '',[m
[32m+[m[32m       'ABCDEFGHIJKLMNOPQRSTUVWXYZ',[m
[32m+[m[32m       '-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k--'[m
[32m+[m[32m      ].join('\r\n')[m
[32m+[m[32m    ],[m
[32m+[m[32m    boundary: '---------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m    limits: {[m
[32m+[m[32m      fileSize: 13,[m
[32m+[m[32m      fieldSize: 5[m
[32m+[m[32m    },[m
[32m+[m[32m    expected: [[m
[32m+[m[32m      { type: 'field',[m
[32m+[m[32m        name: 'file_name_0',[m
[32m+[m[32m        val: 'super',[m
[32m+[m[32m        info: {[m
[32m+[m[32m          nameTruncated: false,[m
[32m+[m[32m          valueTruncated: true,[m
[32m+[m[32m          encoding: '7bit',[m
[32m+[m[32m          mimeType: 'text/plain',[m
[32m+[m[32m        },[m
[32m+[m[32m      },[m
[32m+[m[32m      { type: 'file',[m
[32m+[m[32m        name: 'upload_file_0',[m
[32m+[m[32m        data: Buffer.from('ABCDEFGHIJKLM'),[m
[32m+[m[32m        info: {[m
[32m+[m[32m          filename: '1k_a.dat',[m
[32m+[m[32m          encoding: '7bit',[m
[32m+[m[32m          mimeType: 'application/octet-stream',[m
[32m+[m[32m        },[m
[32m+[m[32m        limited: true,[m
[32m+[m[32m      },[m
[32m+[m[32m    ],[m
[32m+[m[32m    what: 'Fields and files (limits)'[m
[32m+[m[32m  },[m
[32m+[m[32m  { source: [[m
[32m+[m[32m      ['-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m       'Content-Disposition: form-data; name="file_name_0"',[m
[32m+[m[32m       '',[m
[32m+[m[32m       'super alpha file',[m
[32m+[m[32m       '-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m       'Content-Disposition: form-data; '[m
[32m+[m[32m         + 'name="upload_file_0"; filename="1k_a.dat"',[m
[32m+[m[32m       'Content-Type: application/octet-stream',[m
[32m+[m[32m       '',[m
[32m+[m[32m       'ABCDEFGHIJKLMNOPQRSTUVWXYZ',[m
[32m+[m[32m       '-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k--'[m
[32m+[m[32m      ].join('\r\n')[m
[32m+[m[32m    ],[m
[32m+[m[32m    boundary: '---------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m    limits: {[m
[32m+[m[32m      files: 0[m
[32m+[m[32m    },[m
[32m+[m[32m    expected: [[m
[32m+[m[32m      { type: 'field',[m
[32m+[m[32m        name: 'file_name_0',[m
[32m+[m[32m        val: 'super alpha file',[m
[32m+[m[32m        info: {[m
[32m+[m[32m          nameTruncated: false,[m
[32m+[m[32m          valueTruncated: false,[m
[32m+[m[32m          encoding: '7bit',[m
[32m+[m[32m          mimeType: 'text/plain',[m
[32m+[m[32m        },[m
[32m+[m[32m      },[m
[32m+[m[32m      'filesLimit',[m
[32m+[m[32m    ],[m
[32m+[m[32m    what: 'Fields and files (limits: 0 files)'[m
[32m+[m[32m  },[m
[32m+[m[32m  { source: [[m
[32m+[m[32m      ['-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m       'Content-Disposition: form-data; name="file_name_0"',[m
[32m+[m[32m       '',[m
[32m+[m[32m       'super alpha file',[m
[32m+[m[32m       '-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m       'Content-Disposition: form-data; name="file_name_1"',[m
[32m+[m[32m       '',[m
[32m+[m[32m       'super beta file',[m
[32m+[m[32m       '-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m       'Content-Disposition: form-data; '[m
[32m+[m[32m         + 'name="upload_file_0"; filename="1k_a.dat"',[m
[32m+[m[32m       'Content-Type: application/octet-stream',[m
[32m+[m[32m       '',[m
[32m+[m[32m       'A'.repeat(1023),[m
[32m+[m[32m       '-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m       'Content-Disposition: form-data; '[m
[32m+[m[32m         + 'name="upload_file_1"; filename="1k_b.dat"',[m
[32m+[m[32m       'Content-Type: application/octet-stream',[m
[32m+[m[32m       '',[m
[32m+[m[32m       'B'.repeat(1023),[m
[32m+[m[32m       '-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k--'[m
[32m+[m[32m      ].join('\r\n')[m
[32m+[m[32m    ],[m
[32m+[m[32m    boundary: '---------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m    expected: [[m
[32m+[m[32m      { type: 'field',[m
[32m+[m[32m        name: 'file_name_0',[m
[32m+[m[32m        val: 'super alpha file',[m
[32m+[m[32m        info: {[m
[32m+[m[32m          nameTruncated: false,[m
[32m+[m[32m          valueTruncated: false,[m
[32m+[m[32m          encoding: '7bit',[m
[32m+[m[32m          mimeType: 'text/plain',[m
[32m+[m[32m        },[m
[32m+[m[32m      },[m
[32m+[m[32m      { type: 'field',[m
[32m+[m[32m        name: 'file_name_1',[m
[32m+[m[32m        val: 'super beta file',[m
[32m+[m[32m        info: {[m
[32m+[m[32m          nameTruncated: false,[m
[32m+[m[32m          valueTruncated: false,[m
[32m+[m[32m          encoding: '7bit',[m
[32m+[m[32m          mimeType: 'text/plain',[m
[32m+[m[32m        },[m
[32m+[m[32m      },[m
[32m+[m[32m    ],[m
[32m+[m[32m    events: ['field'],[m
[32m+[m[32m    what: 'Fields and (ignored) files'[m
[32m+[m[32m  },[m
[32m+[m[32m  { source: [[m
[32m+[m[32m      ['-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m       'Content-Disposition: form-data; '[m
[32m+[m[32m         + 'name="upload_file_0"; filename="/tmp/1k_a.dat"',[m
[32m+[m[32m       'Content-Type: application/octet-stream',[m
[32m+[m[32m       '',[m
[32m+[m[32m       'ABCDEFGHIJKLMNOPQRSTUVWXYZ',[m
[32m+[m[32m       '-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m       'Content-Disposition: form-data; '[m
[32m+[m[32m         + 'name="upload_file_1"; filename="C:\\files\\1k_b.dat"',[m
[32m+[m[32m       'Content-Type: application/octet-stream',[m
[32m+[m[32m       '',[m
[32m+[m[32m       'ABCDEFGHIJKLMNOPQRSTUVWXYZ',[m
[32m+[m[32m       '-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m       'Content-Disposition: form-data; '[m
[32m+[m[32m         + 'name="upload_file_2"; filename="relative/1k_c.dat"',[m
[32m+[m[32m       'Content-Type: application/octet-stream',[m
[32m+[m[32m       '',[m
[32m+[m[32m       'ABCDEFGHIJKLMNOPQRSTUVWXYZ',[m
[32m+[m[32m       '-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k--'[m
[32m+[m[32m      ].join('\r\n')[m
[32m+[m[32m    ],[m
[32m+[m[32m    boundary: '---------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m    expected: [[m
[32m+[m[32m      { type: 'file',[m
[32m+[m[32m        name: 'upload_file_0',[m
[32m+[m[32m        data: Buffer.from('ABCDEFGHIJKLMNOPQRSTUVWXYZ'),[m
[32m+[m[32m        info: {[m
[32m+[m[32m          filename: '1k_a.dat',[m
[32m+[m[32m          encoding: '7bit',[m
[32m+[m[32m          mimeType: 'application/octet-stream',[m
[32m+[m[32m        },[m
[32m+[m[32m        limited: false,[m
[32m+[m[32m      },[m
[32m+[m[32m      { type: 'file',[m
[32m+[m[32m        name: 'upload_file_1',[m
[32m+[m[32m        data: Buffer.from('ABCDEFGHIJKLMNOPQRSTUVWXYZ'),[m
[32m+[m[32m        info: {[m
[32m+[m[32m          filename: '1k_b.dat',[m
[32m+[m[32m          encoding: '7bit',[m
[32m+[m[32m          mimeType: 'application/octet-stream',[m
[32m+[m[32m        },[m
[32m+[m[32m        limited: false,[m
[32m+[m[32m      },[m
[32m+[m[32m      { type: 'file',[m
[32m+[m[32m        name: 'upload_file_2',[m
[32m+[m[32m        data: Buffer.from('ABCDEFGHIJKLMNOPQRSTUVWXYZ'),[m
[32m+[m[32m        info: {[m
[32m+[m[32m          filename: '1k_c.dat',[m
[32m+[m[32m          encoding: '7bit',[m
[32m+[m[32m          mimeType: 'application/octet-stream',[m
[32m+[m[32m        },[m
[32m+[m[32m        limited: false,[m
[32m+[m[32m      },[m
[32m+[m[32m    ],[m
[32m+[m[32m    what: 'Files with filenames containing paths'[m
[32m+[m[32m  },[m
[32m+[m[32m  { source: [[m
[32m+[m[32m      ['-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m       'Content-Disposition: form-data; '[m
[32m+[m[32m         + 'name="upload_file_0"; filename="/absolute/1k_a.dat"',[m
[32m+[m[32m       'Content-Type: application/octet-stream',[m
[32m+[m[32m       '',[m
[32m+[m[32m       'ABCDEFGHIJKLMNOPQRSTUVWXYZ',[m
[32m+[m[32m       '-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m       'Content-Disposition: form-data; '[m
[32m+[m[32m         + 'name="upload_file_1"; filename="C:\\absolute\\1k_b.dat"',[m
[32m+[m[32m       'Content-Type: application/octet-stream',[m
[32m+[m[32m       '',[m
[32m+[m[32m       'ABCDEFGHIJKLMNOPQRSTUVWXYZ',[m
[32m+[m[32m       '-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m       'Content-Disposition: form-data; '[m
[32m+[m[32m         + 'name="upload_file_2"; filename="relative/1k_c.dat"',[m
[32m+[m[32m       'Content-Type: application/octet-stream',[m
[32m+[m[32m       '',[m
[32m+[m[32m       'ABCDEFGHIJKLMNOPQRSTUVWXYZ',[m
[32m+[m[32m       '-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k--'[m
[32m+[m[32m      ].join('\r\n')[m
[32m+[m[32m    ],[m
[32m+[m[32m    boundary: '---------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m    preservePath: true,[m
[32m+[m[32m    expected: [[m
[32m+[m[32m      { type: 'file',[m
[32m+[m[32m        name: 'upload_file_0',[m
[32m+[m[32m        data: Buffer.from('ABCDEFGHIJKLMNOPQRSTUVWXYZ'),[m
[32m+[m[32m        info: {[m
[32m+[m[32m          filename: '/absolute/1k_a.dat',[m
[32m+[m[32m          encoding: '7bit',[m
[32m+[m[32m          mimeType: 'application/octet-stream',[m
[32m+[m[32m        },[m
[32m+[m[32m        limited: false,[m
[32m+[m[32m      },[m
[32m+[m[32m      { type: 'file',[m
[32m+[m[32m        name: 'upload_file_1',[m
[32m+[m[32m        data: Buffer.from('ABCDEFGHIJKLMNOPQRSTUVWXYZ'),[m
[32m+[m[32m        info: {[m
[32m+[m[32m          filename: 'C:\\absolute\\1k_b.dat',[m
[32m+[m[32m          encoding: '7bit',[m
[32m+[m[32m          mimeType: 'application/octet-stream',[m
[32m+[m[32m        },[m
[32m+[m[32m        limited: false,[m
[32m+[m[32m      },[m
[32m+[m[32m      { type: 'file',[m
[32m+[m[32m        name: 'upload_file_2',[m
[32m+[m[32m        data: Buffer.from('ABCDEFGHIJKLMNOPQRSTUVWXYZ'),[m
[32m+[m[32m        info: {[m
[32m+[m[32m          filename: 'relative/1k_c.dat',[m
[32m+[m[32m          encoding: '7bit',[m
[32m+[m[32m          mimeType: 'application/octet-stream',[m
[32m+[m[32m        },[m
[32m+[m[32m        limited: false,[m
[32m+[m[32m      },[m
[32m+[m[32m    ],[m
[32m+[m[32m    what: 'Paths to be preserved through the preservePath option'[m
[32m+[m[32m  },[m
[32m+[m[32m  { source: [[m
[32m+[m[32m      ['------WebKitFormBoundaryTB2MiQ36fnSJlrhY',[m
[32m+[m[32m       'Content-Disposition: form-data; name="cont"',[m
[32m+[m[32m       'Content-Type: ',[m
[32m+[m[32m       '',[m
[32m+[m[32m       'some random content',[m
[32m+[m[32m       '------WebKitFormBoundaryTB2MiQ36fnSJlrhY',[m
[32m+[m[32m       'Content-Disposition: ',[m
[32m+[m[32m       '',[m
[32m+[m[32m       'some random pass',[m
[32m+[m[32m       '------WebKitFormBoundaryTB2MiQ36fnSJlrhY--'[m
[32m+[m[32m      ].join('\r\n')[m
[32m+[m[32m    ],[m
[32m+[m[32m    boundary: '----WebKitFormBoundaryTB2MiQ36fnSJlrhY',[m
[32m+[m[32m    expected: [[m
[32m+[m[32m      { type: 'field',[m
[32m+[m[32m        name: 'cont',[m
[32m+[m[32m        val: 'some random content',[m
[32m+[m[32m        info: {[m
[32m+[m[32m          nameTruncated: false,[m
[32m+[m[32m          valueTruncated: false,[m
[32m+[m[32m          encoding: '7bit',[m
[32m+[m[32m          mimeType: 'text/plain',[m
[32m+[m[32m        },[m
[32m+[m[32m      },[m
[32m+[m[32m    ],[m
[32m+[m[32m    what: 'Empty content-type and empty content-disposition'[m
[32m+[m[32m  },[m
[32m+[m[32m  { source: [[m
[32m+[m[32m      ['-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m       'Content-Disposition: form-data; '[m
[32m+[m[32m         + 'name="file"; filename*=utf-8\'\'n%C3%A4me.txt',[m
[32m+[m[32m       'Content-Type: application/octet-stream',[m
[32m+[m[32m       '',[m
[32m+[m[32m       'ABCDEFGHIJKLMNOPQRSTUVWXYZ',[m
[32m+[m[32m       '-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k--'[m
[32m+[m[32m      ].join('\r\n')[m
[32m+[m[32m    ],[m
[32m+[m[32m    boundary: '---------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m    expected: [[m
[32m+[m[32m      { type: 'file',[m
[32m+[m[32m        name: 'file',[m
[32m+[m[32m        data: Buffer.from('ABCDEFGHIJKLMNOPQRSTUVWXYZ'),[m
[32m+[m[32m        info: {[m
[32m+[m[32m          filename: 'näme.txt',[m
[32m+[m[32m          encoding: '7bit',[m
[32m+[m[32m          mimeType: 'application/octet-stream',[m
[32m+[m[32m        },[m
[32m+[m[32m        limited: false,[m
[32m+[m[32m      },[m
[32m+[m[32m    ],[m
[32m+[m[32m    what: 'Unicode filenames'[m
[32m+[m[32m  },[m
[32m+[m[32m  { source: [[m
[32m+[m[32m      ['--asdasdasdasd\r\n',[m
[32m+[m[32m       'Content-Type: text/plain\r\n',[m
[32m+[m[32m       'Content-Disposition: form-data; name="foo"\r\n',[m
[32m+[m[32m       '\r\n',[m
[32m+[m[32m       'asd\r\n',[m
[32m+[m[32m       '--asdasdasdasd--'[m
[32m+[m[32m      ].join(':)')[m
[32m+[m[32m    ],[m
[32m+[m[32m    boundary: 'asdasdasdasd',[m
[32m+[m[32m    expected: [[m
[32m+[m[32m      { error: 'Malformed part header' },[m
[32m+[m[32m      { error: 'Unexpected end of form' },[m
[32m+[m[32m    ],[m
[32m+[m[32m    what: 'Stopped mid-header'[m
[32m+[m[32m  },[m
[32m+[m[32m  { source: [[m
[32m+[m[32m      ['------WebKitFormBoundaryTB2MiQ36fnSJlrhY',[m
[32m+[m[32m       'Content-Disposition: form-data; name="cont"',[m
[32m+[m[32m       'Content-Type: application/json',[m
[32m+[m[32m       '',[m
[32m+[m[32m       '{}',[m
[32m+[m[32m       '------WebKitFormBoundaryTB2MiQ36fnSJlrhY--',[m
[32m+[m[32m      ].join('\r\n')[m
[32m+[m[32m    ],[m
[32m+[m[32m    boundary: '----WebKitFormBoundaryTB2MiQ36fnSJlrhY',[m
[32m+[m[32m    expected: [[m
[32m+[m[32m      { type: 'field',[m
[32m+[m[32m        name: 'cont',[m
[32m+[m[32m        val: '{}',[m
[32m+[m[32m        info: {[m
[32m+[m[32m          nameTruncated: false,[m
[32m+[m[32m          valueTruncated: false,[m
[32m+[m[32m          encoding: '7bit',[m
[32m+[m[32m          mimeType: 'application/json',[m
[32m+[m[32m        },[m
[32m+[m[32m      },[m
[32m+[m[32m    ],[m
[32m+[m[32m    what: 'content-type for fields'[m
[32m+[m[32m  },[m
[32m+[m[32m  { source: [[m
[32m+[m[32m      '------WebKitFormBoundaryTB2MiQ36fnSJlrhY--',[m
[32m+[m[32m    ],[m
[32m+[m[32m    boundary: '----WebKitFormBoundaryTB2MiQ36fnSJlrhY',[m
[32m+[m[32m    expected: [],[m
[32m+[m[32m    what: 'empty form'[m
[32m+[m[32m  },[m
[32m+[m[32m  { source: [[m
[32m+[m[32m      ['-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m       'Content-Disposition: form-data; '[m
[32m+[m[32m         + 'name=upload_file_0; filename="1k_a.dat"',[m
[32m+[m[32m       'Content-Type: application/octet-stream',[m
[32m+[m[32m       'Content-Transfer-Encoding: binary',[m
[32m+[m[32m       '',[m
[32m+[m[32m       '',[m
[32m+[m[32m      ].join('\r\n')[m
[32m+[m[32m    ],[m
[32m+[m[32m    boundary: '---------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m    expected: [[m
[32m+[m[32m      { type: 'file',[m
[32m+[m[32m        name: 'upload_file_0',[m
[32m+[m[32m        data: Buffer.alloc(0),[m
[32m+[m[32m        info: {[m
[32m+[m[32m          filename: '1k_a.dat',[m
[32m+[m[32m          encoding: 'binary',[m
[32m+[m[32m          mimeType: 'application/octet-stream',[m
[32m+[m[32m        },[m
[32m+[m[32m        limited: false,[m
[32m+[m[32m        err: 'Unexpected end of form',[m
[32m+[m[32m      },[m
[32m+[m[32m      { error: 'Unexpected end of form' },[m
[32m+[m[32m    ],[m
[32m+[m[32m    what: 'Stopped mid-file #1'[m
[32m+[m[32m  },[m
[32m+[m[32m  { source: [[m
[32m+[m[32m      ['-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m       'Content-Disposition: form-data; '[m
[32m+[m[32m         + 'name=upload_file_0; filename="1k_a.dat"',[m
[32m+[m[32m       'Content-Type: application/octet-stream',[m
[32m+[m[32m       '',[m
[32m+[m[32m       'a',[m
[32m+[m[32m      ].join('\r\n')[m
[32m+[m[32m    ],[m
[32m+[m[32m    boundary: '---------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m    expected: [[m
[32m+[m[32m      { type: 'file',[m
[32m+[m[32m        name: 'upload_file_0',[m
[32m+[m[32m        data: Buffer.from('a'),[m
[32m+[m[32m        info: {[m
[32m+[m[32m          filename: '1k_a.dat',[m
[32m+[m[32m          encoding: '7bit',[m
[32m+[m[32m          mimeType: 'application/octet-stream',[m
[32m+[m[32m        },[m
[32m+[m[32m        limited: false,[m
[32m+[m[32m        err: 'Unexpected end of form',[m
[32m+[m[32m      },[m
[32m+[m[32m      { error: 'Unexpected end of form' },[m
[32m+[m[32m    ],[m
[32m+[m[32m    what: 'Stopped mid-file #2'[m
[32m+[m[32m  },[m
[32m+[m[32m  { source: [[m
[32m+[m[32m      ['-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m       'Content-Disposition: form-data; '[m
[32m+[m[32m         + 'name="upload_file_0"; filename="notes.txt"',[m
[32m+[m[32m       'Content-Type: text/plain; charset=utf8',[m
[32m+[m[32m       '',[m
[32m+[m[32m       'a',[m
[32m+[m[32m       '-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k--',[m
[32m+[m[32m      ].join('\r\n')[m
[32m+[m[32m    ],[m
[32m+[m[32m    boundary: '---------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m    expected: [[m
[32m+[m[32m      { type: 'file',[m
[32m+[m[32m        name: 'upload_file_0',[m
[32m+[m[32m        data: Buffer.from('a'),[m
[32m+[m[32m        info: {[m
[32m+[m[32m          filename: 'notes.txt',[m
[32m+[m[32m          encoding: '7bit',[m
[32m+[m[32m          mimeType: 'text/plain',[m
[32m+[m[32m        },[m
[32m+[m[32m        limited: false,[m
[32m+[m[32m      },[m
[32m+[m[32m    ],[m
[32m+[m[32m    what: 'Text file with charset'[m
[32m+[m[32m  },[m
[32m+[m[32m  { source: [[m
[32m+[m[32m      ['-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m       'Content-Disposition: form-data; '[m
[32m+[m[32m         + 'name="upload_file_0"; filename="notes.txt"',[m
[32m+[m[32m       'Content-Type: ',[m
[32m+[m[32m       ' text/plain; charset=utf8',[m
[32m+[m[32m       '',[m
[32m+[m[32m       'a',[m
[32m+[m[32m       '-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k--',[m
[32m+[m[32m      ].join('\r\n')[m
[32m+[m[32m    ],[m
[32m+[m[32m    boundary: '---------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m    expected: [[m
[32m+[m[32m      { type: 'file',[m
[32m+[m[32m        name: 'upload_file_0',[m
[32m+[m[32m        data: Buffer.from('a'),[m
[32m+[m[32m        info: {[m
[32m+[m[32m          filename: 'notes.txt',[m
[32m+[m[32m          encoding: '7bit',[m
[32m+[m[32m          mimeType: 'text/plain',[m
[32m+[m[32m        },[m
[32m+[m[32m        limited: false,[m
[32m+[m[32m      },[m
[32m+[m[32m    ],[m
[32m+[m[32m    what: 'Folded header value'[m
[32m+[m[32m  },[m
[32m+[m[32m  { source: [[m
[32m+[m[32m      ['-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m       'Content-Type: text/plain; charset=utf8',[m
[32m+[m[32m       '',[m
[32m+[m[32m       'a',[m
[32m+[m[32m       '-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k--',[m
[32m+[m[32m      ].join('\r\n')[m
[32m+[m[32m    ],[m
[32m+[m[32m    boundary: '---------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m    expected: [],[m
[32m+[m[32m    what: 'No Content-Disposition'[m
[32m+[m[32m  },[m
[32m+[m[32m  { source: [[m
[32m+[m[32m      ['-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m       'Content-Disposition: form-data; name="file_name_0"',[m
[32m+[m[32m       '',[m
[32m+[m[32m       'a'.repeat(64 * 1024),[m
[32m+[m[32m       '-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m       'Content-Disposition: form-data; '[m
[32m+[m[32m         + 'name="upload_file_0"; filename="notes.txt"',[m
[32m+[m[32m       'Content-Type: ',[m
[32m+[m[32m       ' text/plain; charset=utf8',[m
[32m+[m[32m       '',[m
[32m+[m[32m       'bc',[m
[32m+[m[32m       '-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k--',[m
[32m+[m[32m      ].join('\r\n')[m
[32m+[m[32m    ],[m
[32m+[m[32m    boundary: '---------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m    limits: {[m
[32m+[m[32m      fieldSize: Infinity,[m
[32m+[m[32m    },[m
[32m+[m[32m    expected: [[m
[32m+[m[32m      { type: 'file',[m
[32m+[m[32m        name: 'upload_file_0',[m
[32m+[m[32m        data: Buffer.from('bc'),[m
[32m+[m[32m        info: {[m
[32m+[m[32m          filename: 'notes.txt',[m
[32m+[m[32m          encoding: '7bit',[m
[32m+[m[32m          mimeType: 'text/plain',[m
[32m+[m[32m        },[m
[32m+[m[32m        limited: false,[m
[32m+[m[32m      },[m
[32m+[m[32m    ],[m
[32m+[m[32m    events: [ 'file' ],[m
[32m+[m[32m    what: 'Skip field parts if no listener'[m
[32m+[m[32m  },[m
[32m+[m[32m  { source: [[m
[32m+[m[32m      ['-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m       'Content-Disposition: form-data; name="file_name_0"',[m
[32m+[m[32m       '',[m
[32m+[m[32m       'a',[m
[32m+[m[32m       '-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m       'Content-Disposition: form-data; '[m
[32m+[m[32m         + 'name="upload_file_0"; filename="notes.txt"',[m
[32m+[m[32m       'Content-Type: ',[m
[32m+[m[32m       ' text/plain; charset=utf8',[m
[32m+[m[32m       '',[m
[32m+[m[32m       'bc',[m
[32m+[m[32m       '-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k--',[m
[32m+[m[32m      ].join('\r\n')[m
[32m+[m[32m    ],[m
[32m+[m[32m    boundary: '---------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m    limits: {[m
[32m+[m[32m      parts: 1,[m
[32m+[m[32m    },[m
[32m+[m[32m    expected: [[m
[32m+[m[32m      { type: 'field',[m
[32m+[m[32m        name: 'file_name_0',[m
[32m+[m[32m        val: 'a',[m
[32m+[m[32m        info: {[m
[32m+[m[32m          nameTruncated: false,[m
[32m+[m[32m          valueTruncated: false,[m
[32m+[m[32m          encoding: '7bit',[m
[32m+[m[32m          mimeType: 'text/plain',[m
[32m+[m[32m        },[m
[32m+[m[32m      },[m
[32m+[m[32m      'partsLimit',[m
[32m+[m[32m    ],[m
[32m+[m[32m    what: 'Parts limit'[m
[32m+[m[32m  },[m
[32m+[m[32m  { source: [[m
[32m+[m[32m      ['-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m       'Content-Disposition: form-data; name="file_name_0"',[m
[32m+[m[32m       '',[m
[32m+[m[32m       'a',[m
[32m+[m[32m       '-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m       'Content-Disposition: form-data; name="file_name_1"',[m
[32m+[m[32m       '',[m
[32m+[m[32m       'b',[m
[32m+[m[32m       '-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k--',[m
[32m+[m[32m      ].join('\r\n')[m
[32m+[m[32m    ],[m
[32m+[m[32m    boundary: '---------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m    limits: {[m
[32m+[m[32m      fields: 1,[m
[32m+[m[32m    },[m
[32m+[m[32m    expected: [[m
[32m+[m[32m      { type: 'field',[m
[32m+[m[32m        name: 'file_name_0',[m
[32m+[m[32m        val: 'a',[m
[32m+[m[32m        info: {[m
[32m+[m[32m          nameTruncated: false,[m
[32m+[m[32m          valueTruncated: false,[m
[32m+[m[32m          encoding: '7bit',[m
[32m+[m[32m          mimeType: 'text/plain',[m
[32m+[m[32m        },[m
[32m+[m[32m      },[m
[32m+[m[32m      'fieldsLimit',[m
[32m+[m[32m    ],[m
[32m+[m[32m    what: 'Fields limit'[m
[32m+[m[32m  },[m
[32m+[m[32m  { source: [[m
[32m+[m[32m      ['-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m       'Content-Disposition: form-data; '[m
[32m+[m[32m         + 'name="upload_file_0"; filename="notes.txt"',[m
[32m+[m[32m       'Content-Type: text/plain; charset=utf8',[m
[32m+[m[32m       '',[m
[32m+[m[32m       'ab',[m
[32m+[m[32m       '-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m       'Content-Disposition: form-data; '[m
[32m+[m[32m         + 'name="upload_file_1"; filename="notes2.txt"',[m
[32m+[m[32m       'Content-Type: text/plain; charset=utf8',[m
[32m+[m[32m       '',[m
[32m+[m[32m       'cd',[m
[32m+[m[32m       '-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k--',[m
[32m+[m[32m      ].join('\r\n')[m
[32m+[m[32m    ],[m
[32m+[m[32m    boundary: '---------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m    limits: {[m
[32m+[m[32m      files: 1,[m
[32m+[m[32m    },[m
[32m+[m[32m    expected: [[m
[32m+[m[32m      { type: 'file',[m
[32m+[m[32m        name: 'upload_file_0',[m
[32m+[m[32m        data: Buffer.from('ab'),[m
[32m+[m[32m        info: {[m
[32m+[m[32m          filename: 'notes.txt',[m
[32m+[m[32m          encoding: '7bit',[m
[32m+[m[32m          mimeType: 'text/plain',[m
[32m+[m[32m        },[m
[32m+[m[32m        limited: false,[m
[32m+[m[32m      },[m
[32m+[m[32m      'filesLimit',[m
[32m+[m[32m    ],[m
[32m+[m[32m    what: 'Files limit'[m
[32m+[m[32m  },[m
[32m+[m[32m  { source: [[m
[32m+[m[32m      ['-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m       'Content-Disposition: form-data; '[m
[32m+[m[32m         + `name="upload_file_0"; filename="${'a'.repeat(64 * 1024)}.txt"`,[m
[32m+[m[32m       'Content-Type: text/plain; charset=utf8',[m
[32m+[m[32m       '',[m
[32m+[m[32m       'ab',[m
[32m+[m[32m       '-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m       'Content-Disposition: form-data; '[m
[32m+[m[32m         + 'name="upload_file_1"; filename="notes2.txt"',[m
[32m+[m[32m       'Content-Type: text/plain; charset=utf8',[m
[32m+[m[32m       '',[m
[32m+[m[32m       'cd',[m
[32m+[m[32m       '-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k--',[m
[32m+[m[32m      ].join('\r\n')[m
[32m+[m[32m    ],[m
[32m+[m[32m    boundary: '---------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m    expected: [[m
[32m+[m[32m      { error: 'Malformed part header' },[m
[32m+[m[32m      { type: 'file',[m
[32m+[m[32m        name: 'upload_file_1',[m
[32m+[m[32m        data: Buffer.from('cd'),[m
[32m+[m[32m        info: {[m
[32m+[m[32m          filename: 'notes2.txt',[m
[32m+[m[32m          encoding: '7bit',[m
[32m+[m[32m          mimeType: 'text/plain',[m
[32m+[m[32m        },[m
[32m+[m[32m        limited: false,[m
[32m+[m[32m      },[m
[32m+[m[32m    ],[m
[32m+[m[32m    what: 'Oversized part header'[m
[32m+[m[32m  },[m
[32m+[m[32m  { source: [[m
[32m+[m[32m      ['-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m       'Content-Disposition: form-data; '[m
[32m+[m[32m         + 'name="upload_file_0"; filename="notes.txt"',[m
[32m+[m[32m       'Content-Type: text/plain; charset=utf8',[m
[32m+[m[32m       '',[m
[32m+[m[32m       'a'.repeat(31) + '\r',[m
[32m+[m[32m      ].join('\r\n'),[m
[32m+[m[32m      'b'.repeat(40),[m
[32m+[m[32m      '\r\n-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k--',[m
[32m+[m[32m    ],[m
[32m+[m[32m    boundary: '---------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m    fileHwm: 32,[m
[32m+[m[32m    expected: [[m
[32m+[m[32m      { type: 'file',[m
[32m+[m[32m        name: 'upload_file_0',[m
[32m+[m[32m        data: Buffer.from('a'.repeat(31) + '\r' + 'b'.repeat(40)),[m
[32m+[m[32m        info: {[m
[32m+[m[32m          filename: 'notes.txt',[m
[32m+[m[32m          encoding: '7bit',[m
[32m+[m[32m          mimeType: 'text/plain',[m
[32m+[m[32m        },[m
[32m+[m[32m        limited: false,[m
[32m+[m[32m      },[m
[32m+[m[32m    ],[m
[32m+[m[32m    what: 'Lookbehind data should not stall file streams'[m
[32m+[m[32m  },[m
[32m+[m[32m  { source: [[m
[32m+[m[32m      ['-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m       'Content-Disposition: form-data; '[m
[32m+[m[32m         + `name="upload_file_0"; filename="${'a'.repeat(8 * 1024)}.txt"`,[m
[32m+[m[32m       'Content-Type: text/plain; charset=utf8',[m
[32m+[m[32m       '',[m
[32m+[m[32m       'ab',[m
[32m+[m[32m       '-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m       'Content-Disposition: form-data; '[m
[32m+[m[32m         + `name="upload_file_1"; filename="${'b'.repeat(8 * 1024)}.txt"`,[m
[32m+[m[32m       'Content-Type: text/plain; charset=utf8',[m
[32m+[m[32m       '',[m
[32m+[m[32m       'cd',[m
[32m+[m[32m       '-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m       'Content-Disposition: form-data; '[m
[32m+[m[32m         + `name="upload_file_2"; filename="${'c'.repeat(8 * 1024)}.txt"`,[m
[32m+[m[32m       'Content-Type: text/plain; charset=utf8',[m
[32m+[m[32m       '',[m
[32m+[m[32m       'ef',[m
[32m+[m[32m       '-----------------------------paZqsnEHRufoShdX6fh0lUhXBP4k--',[m
[32m+[m[32m      ].join('\r\n')[m
[32m+[m[32m    ],[m
[32m+[m[32m    boundary: '---------------------------paZqsnEHRufoShdX6fh0lUhXBP4k',[m
[32m+[m[32m    expected: [[m
[32m+[m[32m      { type: 'file',[m
[32m+[m[32m        name: 'upload_file_0',[m
[32m+[m[32m        data: Buffer.from('ab'),[m
[32m+[m[32m        info: {[m
[32m+[m[32m          filename: `${'a'.repeat(8 * 1024)}.txt`,[m
[32m+[m[32m          encoding: '7bit',[m
[32m+[m[32m          mimeType: 'text/plain',[m
[32m+[m[32m        },[m
[32m+[m[32m        limited: false,[m
[32m+[m[32m      },[m
[32m+[m[32m      { type: 'file',[m
[32m+[m[32m        name: 'upload_file_1',[m
[32m+[m[32m        data: Buffer.from('cd'),[m
[32m+[m[32m        info: {[m
[32m+[m[32m          filename: `${'b'.repeat(8 * 1024)}.txt`,[m
[32m+[m[32m          encoding: '7bit',[m
[32m+[m[32m          mimeType: 'text/plain',[m
[32m+[m[32m        },[m
[32m+[m[32m        limited: false,[m
[32m+[m[32m      },[m
[32m+[m[32m      { type: 'file',[m
[32m+[m[32m        name: 'upload_file_2',[m
[32m+[m[32m        data: Buffer.from('ef'),[m
[32m+[m[32m        info: {[m
[32m+[m[32m          filename: `${'c'.repeat(8 * 1024)}.txt`,[m
[32m+[m[32m          encoding: '7bit',[m
[32m+[m[32m          mimeType: 'text/plain',[m
[32m+[m[32m        },[m
[32m+[m[32m        limited: false,[m
[32m+[m[32m      },[m
[32m+[m[32m    ],[m
[32m+[m[32m    what: 'Header size limit should be per part'[m
[32m+[m[32m  },[m
[32m+[m[32m  { source: [[m
[32m+[m[32m      '\r\n--d1bf46b3-aa33-4061-b28d-6c5ced8b08ee\r\n',[m
[32m+[m[32m      'Content-Type: application/gzip\r\n'[m
[32m+[m[32m        + 'Content-Encoding: gzip\r\n'[m
[32m+[m[32m        + 'Content-Disposition: form-data; name=batch-1; filename=batch-1'[m
[32m+[m[32m        + '\r\n\r\n',[m
[32m+[m[32m      '\r\n--d1bf46b3-aa33-4061-b28d-6c5ced8b08ee--',[m
[32m+[m[32m    ],[m
[32m+[m[32m    boundary: 'd1bf46b3-aa33-4061-b28d-6c5ced8b08ee',[m
[32m+[m[32m    expected: [[m
[32m+[m[32m      { type: 'file',[m
[32m+[m[32m        name: 'batch-1',[m
[32m+[m[32m        data: Buffer.alloc(0),[m
[32m+[m[32m        info: {[m
[32m+[m[32m          filename: 'batch-1',[m
[32m+[m[32m          encoding: '7bit',[m
[32m+[m[32m          mimeType: 'application/gzip',[m
[32m+[m[32m        },[m
[32m+[m[32m        limited: false,[m
[32m+[m[32m      },[m
[32m+[m[32m    ],[m
[32m+[m[32m    what: 'Empty part'[m
[32m+[m[32m  },[m
[32m+[m[32m];[m
[32m+[m
[32m+[m[32mfor (const test of tests) {[m
[32m+[m[32m  active.set(test, 1);[m
[32m+[m
[32m+[m[32m  const { what, boundary, events, limits, preservePath, fileHwm } = test;[m
[32m+[m[32m  const bb = busboy({[m
[32m+[m[32m    fileHwm,[m
[32m+[m[32m    limits,[m
[32m+[m[32m    preservePath,[m
[32m+[m[32m    headers: {[m
[32m+[m[32m      'content-type': `multipart/form-data; boundary=${boundary}`,[m
[32m+[m[32m    }[m
[32m+[m[32m  });[m
[32m+[m[32m  const results = [];[m
[32m+[m
[32m+[m[32m  if (events === undefined || events.includes('field')) {[m
[32m+[m[32m    bb.on('field', (name, val, info) => {[m
[32m+[m[32m      results.push({ type: 'field', name, val, info });[m
[32m+[m[32m    });[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  if (events === undefined || events.includes('file')) {[m
[32m+[m[32m    bb.on('file', (name, stream, info) => {[m
[32m+[m[32m      const data = [];[m
[32m+[m[32m      let nb = 0;[m
[32m+[m[32m      const file = {[m
[32m+[m[32m        type: 'file',[m
[32m+[m[32m        name,[m
[32m+[m[32m        data: null,[m
[32m+[m[32m        info,[m
[32m+[m[32m        limited: false,[m
[32m+[m[32m      };[m
[32m+[m[32m      results.push(file);[m
[32m+[m[32m      stream.on('data', (d) => {[m
[32m+[m[32m        data.push(d);[m
[32m+[m[32m        nb += d.length;[m
[32m+[m[32m      }).on('limit', () => {[m
[32m+[m[32m        file.limited = true;[m
[32m+[m[32m      }).on('close', () => {[m
[32m+[m[32m        file.data = Buffer.concat(data, nb);[m
[32m+[m[32m        assert.strictEqual(stream.truncated, file.limited);[m
[32m+[m[32m      }).once('error', (err) => {[m
[32m+[m[32m        file.err = err.message;[m
[32m+[m[32m      });[m
[32m+[m[32m    });[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  bb.on('error', (err) => {[m
[32m+[m[32m    results.push({ error: err.message });[m
[32m+[m[32m  });[m
[32m+[m
[32m+[m[32m  bb.on('partsLimit', () => {[m
[32m+[m[32m    results.push('partsLimit');[m
[32m+[m[32m  });[m
[32m+[m
[32m+[m[32m  bb.on('filesLimit', () => {[m
[32m+[m[32m    results.push('filesLimit');[m
[32m+[m[32m  });[m
[32m+[m
[32m+[m[32m  bb.on('fieldsLimit', () => {[m
[32m+[m[32m    results.push('fieldsLimit');[m
[32m+[m[32m  });[m
[32m+[m
[32m+[m[32m  bb.on('close', () => {[m
[32m+[m[32m    active.delete(test);[m
[32m+[m
[32m+[m[32m    assert.deepStrictEqual([m
[32m+[m[32m      results,[m
[32m+[m[32m      test.expected,[m
[32m+[m[32m      `[${what}] Results mismatch.\n`[m
[32m+[m[32m        + `Parsed: ${inspect(results)}\n`[m
[32m+[m[32m        + `Expected: ${inspect(test.expected)}`[m
[32m+[m[32m    );[m
[32m+[m[32m  });[m
[32m+[m
[32m+[m[32m  for (const src of test.source) {[m
[32m+[m[32m    const buf = (typeof src === 'string' ? Buffer.from(src, 'utf8') : src);[m
[32m+[m[32m    bb.write(buf);[m
[32m+[m[32m  }[m
[32m+[m[32m  bb.end();[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m// Byte-by-byte versions[m
[32m+[m[32mfor (let test of tests) {[m
[32m+[m[32m  test = { ...test };[m
[32m+[m[32m  test.what += ' (byte-by-byte)';[m
[32m+[m[32m  active.set(test, 1);[m
[32m+[m
[32m+[m[32m  const { what, boundary, events, limits, preservePath, fileHwm } = test;[m
[32m+[m[32m  const bb = busboy({[m
[32m+[m[32m    fileHwm,[m
[32m+[m[32m    limits,[m
[32m+[m[32m    preservePath,[m
[32m+[m[32m    headers: {[m
[32m+[m[32m      'content-type': `multipart/form-data; boundary=${boundary}`,[m
[32m+[m[32m    }[m
[32m+[m[32m  });[m
[32m+[m[32m  const results = [];[m
[32m+[m
[32m+[m[32m  if (events === undefined || events.includes('field')) {[m
[32m+[m[32m    bb.on('field', (name, val, info) => {[m
[32m+[m[32m      results.push({ type: 'field', name, val, info });[m
[32m+[m[32m    });[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  if (events === undefined || events.includes('file')) {[m
[32m+[m[32m    bb.on('file', (name, stream, info) => {[m
[32m+[m[32m      const data = [];[m
[32m+[m[32m      let nb = 0;[m
[32m+[m[32m      const file = {[m
[32m+[m[32m        type: 'file',[m
[32m+[m[32m        name,[m
[32m+[m[32m        data: null,[m
[32m+[m[32m        info,[m
[32m+[m[32m        limited: false,[m
[32m+[m[32m      };[m
[32m+[m[32m      results.push(file);[m
[32m+[m[32m      stream.on('data', (d) => {[m
[32m+[m[32m        data.push(d);[m
[32m+[m[32m        nb += d.length;[m
[32m+[m[32m      }).on('limit', () => {[m
[32m+[m[32m        file.limited = true;[m
[32m+[m[32m      }).on('close', () => {[m
[32m+[m[32m        file.data = Buffer.concat(data, nb);[m
[32m+[m[32m        assert.strictEqual(stream.truncated, file.limited);[m
[32m+[m[32m      }).once('error', (err) => {[m
[32m+[m[32m        file.err = err.message;[m
[32m+[m[32m      });[m
[32m+[m[32m    });[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  bb.on('error', (err) => {[m
[32m+[m[32m    results.push({ error: err.message });[m
[32m+[m[32m  });[m
[32m+[m
[32m+[m[32m  bb.on('partsLimit', () => {[m
[32m+[m[32m    results.push('partsLimit');[m
[32m+[m[32m  });[m
[32m+[m
[32m+[m[32m  bb.on('filesLimit', () => {[m
[32m+[m[32m    results.push('filesLimit');[m
[32m+[m[32m  });[m
[32m+[m
[32m+[m[32m  bb.on('fieldsLimit', () => {[m
[32m+[m[32m    results.push('fieldsLimit');[m
[32m+[m[32m  });[m
[32m+[m
[32m+[m[32m  bb.on('close', () => {[m
[32m+[m[32m    active.delete(test);[m
[32m+[m
[32m+[m[32m    assert.deepStrictEqual([m
[32m+[m[32m      results,[m
[32m+[m[32m      test.expected,[m
[32m+[m[32m      `[${what}] Results mismatch.\n`[m
[32m+[m[32m        + `Parsed: ${inspect(results)}\n`[m
[32m+[m[32m        + `Expected: ${inspect(test.expected)}`[m
[32m+[m[32m    );[m
[32m+[m[32m  });[m
[32m+[m
[32m+[m[32m  for (const src of test.source) {[m
[32m+[m[32m    const buf = (typeof src === 'string' ? Buffer.from(src, 'utf8') : src);[m
[32m+[m[32m    for (let i = 0; i < buf.length; ++i)[m
[32m+[m[32m      bb.write(buf.slice(i, i + 1));[m
[32m+[m[32m  }[m
[32m+[m[32m  bb.end();[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m{[m
[32m+[m[32m  let exception = false;[m
[32m+[m[32m  process.once('uncaughtException', (ex) => {[m
[32m+[m[32m    exception = true;[m
[32m+[m[32m    throw ex;[m
[32m+[m[32m  });[m
[32m+[m[32m  process.on('exit', () => {[m
[32m+[m[32m    if (exception || active.size === 0)[m
[32m+[m[32m      return;[m
[32m+[m[32m    process.exitCode = 1;[m
[32m+[m[32m    console.error('==========================');[m
[32m+[m[32m    console.error(`${active.size} test(s) did not finish:`);[m
[32m+[m[32m    console.error('==========================');[m
[32m+[m[32m    console.error(Array.from(active.keys()).map((v) => v.what).join('\n'));[m
[32m+[m[32m  });[m
[32m+[m[32m}[m
[1mdiff --git a/node_modules/busboy/test/test-types-urlencoded.js b/node_modules/busboy/test/test-types-urlencoded.js[m
[1mnew file mode 100644[m
[1mindex 0000000..c35962b[m
[1m--- /dev/null[m
[1m+++ b/node_modules/busboy/test/test-types-urlencoded.js[m
[36m@@ -0,0 +1,488 @@[m
[32m+[m[32m'use strict';[m
[32m+[m
[32m+[m[32mconst assert = require('assert');[m
[32m+[m[32mconst { transcode } = require('buffer');[m
[32m+[m[32mconst { inspect } = require('util');[m
[32m+[m
[32m+[m[32mconst busboy = require('..');[m
[32m+[m
[32m+[m[32mconst active = new Map();[m
[32m+[m
[32m+[m[32mconst tests = [[m
[32m+[m[32m  { source: ['foo'],[m
[32m+[m[32m    expected: [[m
[32m+[m[32m      ['foo',[m
[32m+[m[32m       '',[m
[32m+[m[32m       { nameTruncated: false,[m
[32m+[m[32m         valueTruncated: false,[m
[32m+[m[32m         encoding: 'utf-8',[m
[32m+[m[32m         mimeType: 'text/plain' },[m
[32m+[m[32m      ],[m
[32m+[m[32m    ],[m
[32m+[m[32m    what: 'Unassigned value'[m
[32m+[m[32m  },[m
[32m+[m[32m  { source: ['foo=bar'],[m
[32m+[m[32m    expected: [[m
[32m+[m[32m      ['foo',[m
[32m+[m[32m       'bar',[m
[32m+[m[32m       { nameTruncated: false,[m
[32m+[m[32m         valueTruncated: false,[m
[32m+[m[32m         encoding: 'utf-8',[m
[32m+[m[32m         mimeType: 'text/plain' },[m
[32m+[m[32m      ],[m
[32m+[m[32m    ],[m
[32m+[m[32m    what: 'Assigned value'[m
[32m+[m[32m  },[m
[32m+[m[32m  { source: ['foo&bar=baz'],[m
[32m+[m[32m    expected: [[m
[32m+[m[32m      ['foo',[m
[32m+[m[32m       '',[m
[32m+[m[32m       { nameTruncated: false,[m
[32m+[m[32m         valueTruncated: false,[m
[32m+[m[32m         encoding: 'utf-8',[m
[32m+[m[32m         mimeType: 'text/plain' },[m
[32m+[m[32m      ],[m
[32m+[m[32m      ['bar',[m
[32m+[m[32m       'baz',[m
[32m+[m[32m       { nameTruncated: false,[m
[32m+[m[32m         valueTruncated: false,[m
[32m+[m[32m         encoding: 'utf-8',[m
[32m+[m[32m         mimeType: 'text/plain' },[m
[32m+[m[32m      ],[m
[32m+[m[32m    ],[m
[32m+[m[32m    what: 'Unassigned and assigned value'[m
[32m+[m[32m  },[m
[32m+[m[32m  { source: ['foo=bar&baz'],[m
[32m+[m[32m    expected: [[m
[32m+[m[32m      ['foo',[m
[32m+[m[32m       'bar',[m
[32m+[m[32m       { nameTruncated: false,[m
[32m+[m[32m         valueTruncated: false,[m
[32m+[m[32m         encoding: 'utf-8',[m
[32m+[m[32m         mimeType: 'text/plain' },[m
[32m+[m[32m      ],[m
[32m+[m[32m      ['baz',[m
[32m+[m[32m       '',[m
[32m+[m[32m       { nameTruncated: false,[m
[32m+[m[32m         valueTruncated: false,[m
[32m+[m[32m         encoding: 'utf-8',[m
[32m+[m[32m         mimeType: 'text/plain' },[m
[32m+[m[32m      ],[m
[32m+[m[32m    ],[m
[32m+[m[32m    what: 'Assigned and unassigned value'[m
[32m+[m[32m  },[m
[32m+[m[32m  { source: ['foo=bar&baz=bla'],[m
[32m+[m[32m    expected: [[m
[32m+[m[32m      ['foo',[m
[32m+[m[32m       'bar',[m
[32m+[m[32m       { nameTruncated: false,[m
[32m+[m[32m         valueTruncated: false,[m
[32m+[m[32m         encoding: 'utf-8',[m
[32m+[m[32m         mimeType: 'text/plain' },[m
[32m+[m[32m      ],[m
[32m+[m[32m      ['baz',[m
[32m+[m[32m       'bla',[m
[32m+[m[32m       { nameTruncated: false,[m
[32m+[m[32m         valueTruncated: false,[m
[32m+[m[32m         encoding: 'utf-8',[m
[32m+[m[32m         mimeType: 'text/plain' },[m
[32m+[m[32m      ],[m
[32m+[m[32m    ],[m
[32m+[m[32m    what: 'Two assigned values'[m
[32m+[m[32m  },[m
[32m+[m[32m  { source: ['foo&bar'],[m
[32m+[m[32m    expected: [[m
[32m+[m[32m      ['foo',[m
[32m+[m[32m       '',[m
[32m+[m[32m       { nameTruncated: false,[m
[32m+[m[32m         valueTruncated: false,[m
[32m+[m[32m         encoding: 'utf-8',[m
[32m+[m[32m         mimeType: 'text/plain' },[m
[32m+[m[32m      ],[m
[32m+[m[32m      ['bar',[m
[32m+[m[32m       '',[m
[32m+[m[32m       { nameTruncated: false,[m
[32m+[m[32m         valueTruncated: false,[m
[32m+[m[32m         encoding: 'utf-8',[m
[32m+[m[32m         mimeType: 'text/plain' },[m
[32m+[m[32m      ],[m
[32m+[m[32m    ],[m
[32m+[m[32m    what: 'Two unassigned values'[m
[32m+[m[32m  },[m
[32m+[m[32m  { source: ['foo&bar&'],[m
[32m+[m[32m    expected: [[m
[32m+[m[32m      ['foo',[m
[32m+[m[32m       '',[m
[32m+[m[32m       { nameTruncated: false,[m
[32m+[m[32m         valueTruncated: false,[m
[32m+[m[32m         encoding: 'utf-8',[m
[32m+[m[32m         mimeType: 'text/plain' },[m
[32m+[m[32m      ],[m
[32m+[m[32m      ['bar',[m
[32m+[m[32m       '',[m
[32m+[m[32m       { nameTruncated: false,[m
[32m+[m[32m         valueTruncated: false,[m
[32m+[m[32m         encoding: 'utf-8',[m
[32m+[m[32m         mimeType: 'text/plain' },[m
[32m+[m[32m      ],[m
[32m+[m[32m    ],[m
[32m+[m[32m    what: 'Two unassigned values and ampersand'[m
[32m+[m[32m  },[m
[32m+[m[32m  { source: ['foo+1=bar+baz%2Bquux'],[m
[32m+[m[32m    expected: [[m
[32m+[m[32m      ['foo 1',[m
[32m+[m[32m       'bar baz+quux',[m
[32m+[m[32m       { nameTruncated: false,[m
[32m+[m[32m         valueTruncated: false,[m
[32m+[m[32m         encoding: 'utf-8',[m
[32m+[m[32m         mimeType: 'text/plain' },[m
[32m+[m[32m      ],[m
[32m+[m[32m    ],[m
[32m+[m[32m    what: 'Assigned key and value with (plus) space'[m
[32m+[m[32m  },[m
[32m+[m[32m  { source: ['foo=bar%20baz%21'],[m
[32m+[m[32m    expected: [[m
[32m+[m[32m      ['foo',[m
[32m+[m[32m       'bar baz!',[m
[32m+[m[32m       { nameTruncated: false,[m
[32m+[m[32m         valueTruncated: false,[m
[32m+[m[32m         encoding: 'utf-8',[m
[32m+[m[32m         mimeType: 'text/plain' },[m
[32m+[m[32m      ],[m
[32m+[m[32m    ],[m
[32m+[m[32m    what: 'Assigned value with encoded bytes'[m
[32m+[m[32m  },[m
[32m+[m[32m  { source: ['foo%20bar=baz%20bla%21'],[m
[32m+[m[32m    expected: [[m
[32m+[m[32m      ['foo bar',[m
[32m+[m[32m       'baz bla!',[m
[32m+[m[32m       { nameTruncated: false,[m
[32m+[m[32m         valueTruncated: false,[m
[32m+[m[32m         encoding: 'utf-8',[m
[32m+[m[32m         mimeType: 'text/plain' },[m
[32m+[m[32m      ],[m
[32m+[m[32m    ],[m
[32m+[m[32m    what: 'Assigned value with encoded bytes #2'[m
[32m+[m[32m  },[m
[32m+[m[32m  { source: ['foo=bar%20baz%21&num=1000'],[m
[32m+[m[32m    expected: [[m
[32m+[m[32m      ['foo',[m
[32m+[m[32m       'bar baz!',[m
[32m+[m[32m       { nameTruncated: false,[m
[32m+[m[32m         valueTruncated: false,[m
[32m+[m[32m         encoding: 'utf-8',[m
[32m+[m[32m         mimeType: 'text/plain' },[m
[32m+[m[32m      ],[m
[32m+[m[32m      ['num',[m
[32m+[m[32m       '1000',[m
[32m+[m[32m       { nameTruncated: false,[m
[32m+[m[32m         valueTruncated: false,[m
[32m+[m[32m         encoding: 'utf-8',[m
[32m+[m[32m         mimeType: 'text/plain' },[m
[32m+[m[32m      ],[m
[32m+[m[32m    ],[m
[32m+[m[32m    what: 'Two assigned values, one with encoded bytes'[m
[32m+[m[32m  },[m
[32m+[m[32m  { source: [[m
[32m+[m[32m      Array.from(transcode(Buffer.from('foo'), 'utf8', 'utf16le')).map([m
[32m+[m[32m        (n) => `%${n.toString(16).padStart(2, '0')}`[m
[32m+[m[32m      ).join(''),[m
[32m+[m[32m      '=',[m
[32m+[m[32m      Array.from(transcode(Buffer.from('😀!'), 'utf8', 'utf16le')).map([m
[32m+[m[32m        (n) => `%${n.toString(16).padStart(2, '0')}`[m
[32m+[m[32m      ).join(''),[m
[32m+[m[32m    ],[m
[32m+[m[32m    expected: [[m
[32m+[m[32m      ['foo',[m
[32m+[m[32m       '😀!',[m
[32m+[m[32m       { nameTruncated: false,[m
[32m+[m[32m         valueTruncated: false,[m
[32m+[m[32m         encoding: 'UTF-16LE',[m
[32m+[m[32m         mimeType: 'text/plain' },[m
[32m+[m[32m      ],[m
[32m+[m[32m    ],[m
[32m+[m[32m    charset: 'UTF-16LE',[m
[32m+[m[32m    what: 'Encoded value with multi-byte charset'[m
[32m+[m[32m  },[m
[32m+[m[32m  { source: [[m
[32m+[m[32m      'foo=<',[m
[32m+[m[32m      Array.from(transcode(Buffer.from('©:^þ'), 'utf8', 'latin1')).map([m
[32m+[m[32m        (n) => `%${n.toString(16).padStart(2, '0')}`[m
[32m+[m[32m      ).join(''),[m
[32m+[m[32m    ],[m
[32m+[m[32m    expected: [[m
[32m+[m[32m      ['foo',[m
[32m+[m[32m       '<©:^þ',[m
[32m+[m[32m       { nameTruncated: false,[m
[32m+[m[32m         valueTruncated: false,[m
[32m+[m[32m         encoding: 'ISO-8859-1',[m
[32m+[m[32m         mimeType: 'text/plain' },[m
[32m+[m[32m      ],[m
[32m+[m[32m    ],[m
[32m+[m[32m    charset: 'ISO-8859-1',[m
[32m+[m[32m    what: 'Encoded value with single-byte, ASCII-compatible, non-UTF8 charset'[m
[32m+[m[32m  },[m
[32m+[m[32m  { source: ['foo=bar&baz=bla'],[m
[32m+[m[32m    expected: [],[m
[32m+[m[32m    what: 'Limits: zero fields',[m
[32m+[m[32m    limits: { fields: 0 }[m
[32m+[m[32m  },[m
[32m+[m[32m  { source: ['foo=bar&baz=bla'],[m
[32m+[m[32m    expected: [[m
[32m+[m[32m      ['foo',[m
[32m+[m[32m       'bar',[m
[32m+[m[32m       { nameTruncated: false,[m
[32m+[m[32m         valueTruncated: false,[m
[32m+[m[32m         encoding: 'utf-8',[m
[32m+[m[32m         mimeType: 'text/plain' },[m
[32m+[m[32m      ],[m
[32m+[m[32m    ],[m
[32m+[m[32m    what: 'Limits: one field',[m
[32m+[m[32m    limits: { fields: 1 }[m
[32m+[m[32m  },[m
[32m+[m[32m  { source: ['foo=bar&baz=bla'],[m
[32m+[m[32m    expected: [[m
[32m+[m[32m      ['foo',[m
[32m+[m[32m       'bar',[m
[32m+[m[32m       { nameTruncated: false,[m
[32m+[m[32m         valueTruncated: false,[m
[32m+[m[32m         encoding: 'utf-8',[m
[32m+[m[32m         mimeType: 'text/plain' },[m
[32m+[m[32m      ],[m
[32m+[m[32m      ['baz',[m
[32m+[m[32m       'bla',[m
[32m+[m[32m       { nameTruncated: false,[m
[32m+[m[32m         valueTruncated: false,[m
[32m+[m[32m         encoding: 'utf-8',[m
[32m+[m[32m         mimeType: 'text/plain' },[m
[32m+[m[32m      ],[m
[32m+[m[32m    ],[m
[32m+[m[32m    what: 'Limits: field part lengths match limits',[m
[32m+[m[32m    limits: { fieldNameSize: 3, fieldSize: 3 }[m
[32m+[m[32m  },[m
[32m+[m[32m  { source: ['foo=bar&baz=bla'],[m
[32m+[m[32m    expected: [[m
[32m+[m[32m      ['fo',[m
[32m+[m[32m       'bar',[m
[32m+[m[32m       { nameTruncated: true,[m
[32m+[m[32m         valueTruncated: false,[m
[32m+[m[32m         encoding: 'utf-8',[m
[32m+[m[32m         mimeType: 'text/plain' },[m
[32m+[m[32m      ],[m
[32m+[m[32m      ['ba',[m
[32m+[m[32m       'bla',[m
[32m+[m[32m       { nameTruncated: true,[m
[32m+[m[32m         valueTruncated: false,[m
[32m+[m[32m         encoding: 'utf-8',[m
[32m+[m[32m         mimeType: 'text/plain' },[m
[32m+[m[32m      ],[m
[32m+[m[32m    ],[m
[32m+[m[32m    what: 'Limits: truncated field name',[m
[32m+[m[32m    limits: { fieldNameSize: 2 }[m
[32m+[m[32m  },[m
[32m+[m[32m  { source: ['foo=bar&baz=bla'],[m
[32m+[m[32m    expected: [[m
[32m+[m[32m      ['foo',[m
[32m+[m[32m       'ba',[m
[32m+[m[32m       { nameTruncated: false,[m
[32m+[m[32m         valueTruncated: true,[m
[32m+[m[32m         encoding: 'utf-8',[m
[32m+[m[32m         mimeType: 'text/plain' },[m
[32m+[m[32m      ],[m
[32m+[m[32m      ['baz',[m
[32m+[m[32m       'bl',[m
[32m+[m[32m       { nameTruncated: false,[m
[32m+[m[32m         valueTruncated: true,[m
[32m+[m[32m         encoding: 'utf-8',[m
[32m+[m[32m         mimeType: 'text/plain' },[m
[32m+[m[32m      ],[m
[32m+[m[32m    ],[m
[32m+[m[32m    what: 'Limits: truncated field value',[m
[32m+[m[32m    limits: { fieldSize: 2 }[m
[32m+[m[32m  },[m
[32m+[m[32m  { source: ['foo=bar&baz=bla'],[m
[32m+[m[32m    expected: [[m
[32m+[m[32m      ['fo',[m
[32m+[m[32m       'ba',[m
[32m+[m[32m       { nameTruncated: true,[m
[32m+[m[32m         valueTruncated: true,[m
[32m+[m[32m         encoding: 'utf-8',[m
[32m+[m[32m         mimeType: 'text/plain' },[m
[32m+[m[32m      ],[m
[32m+[m[32m      ['ba',[m
[32m+[m[32m       'bl',[m
[32m+[m[32m       { nameTruncated: true,[m
[32m+[m[32m         valueTruncated: true,[m
[32m+[m[32m         encoding: 'utf-8',[m
[32m+[m[32m         mimeType: 'text/plain' },[m
[32m+[m[32m      ],[m
[32m+[m[32m    ],[m
[32m+[m[32m    what: 'Limits: truncated field name and value',[m
[32m+[m[32m    limits: { fieldNameSize: 2, fieldSize: 2 }[m
[32m+[m[32m  },[m
[32m+[m[32m  { source: ['foo=bar&baz=bla'],[m
[32m+[m[32m    expected: [[m
[32m+[m[32m      ['fo',[m
[32m+[m[32m       '',[m
[32m+[m[32m       { nameTruncated: true,[m
[32m+[m[32m         valueTruncated: true,[m
[32m+[m[32m         encoding: 'utf-8',[m
[32m+[m[32m         mimeType: 'text/plain' },[m
[32m+[m[32m      ],[m
[32m+[m[32m      ['ba',[m
[32m+[m[32m       '',[m
[32m+[m[32m       { nameTruncated: true,[m
[32m+[m[32m         valueTruncated: true,[m
[32m+[m[32m         encoding: 'utf-8',[m
[32m+[m[32m         mimeType: 'text/plain' },[m
[32m+[m[32m      ],[m
[32m+[m[32m    ],[m
[32m+[m[32m    what: 'Limits: truncated field name and zero value limit',[m
[32m+[m[32m    limits: { fieldNameSize: 2, fieldSize: 0 }[m
[32m+[m[32m  },[m
[32m+[m[32m  { source: ['foo=bar&baz=bla'],[m
[32m+[m[32m    expected: [[m
[32m+[m[32m      ['',[m
[32m+[m[32m       '',[m
[32m+[m[32m       { nameTruncated: true,[m
[32m+[m[32m         valueTruncated: true,[m
[32m+[m[32m         encoding: 'utf-8',[m
[32m+[m[32m         mimeType: 'text/plain' },[m
[32m+[m[32m      ],[m
[32m+[m[32m      ['',[m
[32m+[m[32m       '',[m
[32m+[m[32m       { nameTruncated: true,[m
[32m+[m[32m         valueTruncated: true,[m
[32m+[m[32m         encoding: 'utf-8',[m
[32m+[m[32m         mimeType: 'text/plain' },[m
[32m+[m[32m      ],[m
[32m+[m[32m    ],[m
[32m+[m[32m    what: 'Limits: truncated zero field name and zero value limit',[m
[32m+[m[32m    limits: { fieldNameSize: 0, fieldSize: 0 }[m
[32m+[m[32m  },[m
[32m+[m[32m  { source: ['&'],[m
[32m+[m[32m    expected: [],[m
[32m+[m[32m    what: 'Ampersand'[m
[32m+[m[32m  },[m
[32m+[m[32m  { source: ['&&&&&'],[m
[32m+[m[32m    expected: [],[m
[32m+[m[32m    what: 'Many ampersands'[m
[32m+[m[32m  },[m
[32m+[m[32m  { source: ['='],[m
[32m+[m[32m    expected: [[m
[32m+[m[32m      ['',[m
[32m+[m[32m       '',[m
[32m+[m[32m       { nameTruncated: false,[m
[32m+[m[32m         valueTruncated: false,[m
[32m+[m[32m         encoding: 'utf-8',[m
[32m+[m[32m         mimeType: 'text/plain' },[m
[32m+[m[32m      ],[m
[32m+[m[32m    ],[m
[32m+[m[32m    what: 'Assigned value, empty name and value'[m
[32m+[m[32m  },[m
[32m+[m[32m  { source: [''],[m
[32m+[m[32m    expected: [],[m
[32m+[m[32m    what: 'Nothing'[m
[32m+[m[32m  },[m
[32m+[m[32m];[m
[32m+[m
[32m+[m[32mfor (const test of tests) {[m
[32m+[m[32m  active.set(test, 1);[m
[32m+[m
[32m+[m[32m  const { what } = test;[m
[32m+[m[32m  const charset = test.charset || 'utf-8';[m
[32m+[m[32m  const bb = busboy({[m
[32m+[m[32m    limits: test.limits,[m
[32m+[m[32m    headers: {[m
[32m+[m[32m      'content-type': `application/x-www-form-urlencoded; charset=${charset}`,[m
[32m+[m[32m    },[m
[32m+[m[32m  });[m
[32m+[m[32m  const results = [];[m
[32m+[m
[32m+[m[32m  bb.on('field', (key, val, info) => {[m
[32m+[m[32m    results.push([key, val, info]);[m
[32m+[m[32m  });[m
[32m+[m
[32m+[m[32m  bb.on('file', () => {[m
[32m+[m[32m    throw new Error(`[${what}] Unexpected file`);[m
[32m+[m[32m  });[m
[32m+[m
[32m+[m[32m  bb.on('close', () => {[m
[32m+[m[32m    active.delete(test);[m
[32m+[m
[32m+[m[32m    assert.deepStrictEqual([m
[32m+[m[32m      results,[m
[32m+[m[32m      test.expected,[m
[32m+[m[32m      `[${what}] Results mismatch.\n`[m
[32m+[m[32m        + `Parsed: ${inspect(results)}\n`[m
[32m+[m[32m        + `Expected: ${inspect(test.expected)}`[m
[32m+[m[32m    );[m
[32m+[m[32m  });[m
[32m+[m
[32m+[m[32m  for (const src of test.source) {[m
[32m+[m[32m    const buf = (typeof src === 'string' ? Buffer.from(src, 'utf8') : src);[m
[32m+[m[32m    bb.write(buf);[m
[32m+[m[32m  }[m
[32m+[m[32m  bb.end();[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m// Byte-by-byte versions[m
[32m+[m[32mfor (let test of tests) {[m
[32m+[m[32m  test = { ...test };[m
[32m+[m[32m  test.what += ' (byte-by-byte)';[m
[32m+[m[32m  active.set(test, 1);[m
[32m+[m
[32m+[m[32m  const { what } = test;[m
[32m+[m[32m  const charset = test.charset || 'utf-8';[m
[32m+[m[32m  const bb = busboy({[m
[32m+[m[32m    limits: test.limits,[m
[32m+[m[32m    headers: {[m
[32m+[m[32m      'content-type': `application/x-www-form-urlencoded; charset="${charset}"`,[m
[32m+[m[32m    },[m
[32m+[m[32m  });[m
[32m+[m[32m  const results = [];[m
[32m+[m
[32m+[m[32m  bb.on('field', (key, val, info) => {[m
[32m+[m[32m    results.push([key, val, info]);[m
[32m+[m[32m  });[m
[32m+[m
[32m+[m[32m  bb.on('file', () => {[m
[32m+[m[32m    throw new Error(`[${what}] Unexpected file`);[m
[32m+[m[32m  });[m
[32m+[m
[32m+[m[32m  bb.on('close', () => {[m
[32m+[m[32m    active.delete(test);[m
[32m+[m
[32m+[m[32m    assert.deepStrictEqual([m
[32m+[m[32m      results,[m
[32m+[m[32m      test.expected,[m
[32m+[m[32m      `[${what}] Results mismatch.\n`[m
[32m+[m[32m        + `Parsed: ${inspect(results)}\n`[m
[32m+[m[32m        + `Expected: ${inspect(test.expected)}`[m
[32m+[m[32m    );[m
[32m+[m[32m  });[m
[32m+[m
[32m+[m[32m  for (const src of test.source) {[m
[32m+[m[32m    const buf = (typeof src === 'string' ? Buffer.from(src, 'utf8') : src);[m
[32m+[m[32m    for (let i = 0; i < buf.length; ++i)[m
[32m+[m[32m      bb.write(buf.slice(i, i + 1));[m
[32m+[m[32m  }[m
[32m+[m[32m  bb.end();[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m{[m
[32m+[m[32m  let exception = false;[m
[32m+[m[32m  process.once('uncaughtException', (ex) => {[m
[32m+[m[32m    exception = true;[m
[32m+[m[32m    throw ex;[m
[32m+[m[32m  });[m
[32m+[m[32m  process.on('exit', () => {[m
[32m+[m[32m    if (exception || active.size === 0)[m
[32m+[m[32m      return;[m
[32m+[m[32m    process.exitCode = 1;[m
[32m+[m[32m    console.error('==========================');[m
[32m+[m[32m    console.error(`${active.size} test(s) did not finish:`);[m
[32m+[m[32m    console.error('==========================');[m
[32m+[m[32m    console.error(Array.from(active.keys()).map((v) => v.what).join('\n'));[m
[32m+[m[32m  });[m
[32m+[m[32m}[m
[1mdiff --git a/node_modules/busboy/test/test.js b/node_modules/busboy/test/test.js[m
[1mnew file mode 100644[m
[1mindex 0000000..d0380f2[m
[1m--- /dev/null[m
[1m+++ b/node_modules/busboy/test/test.js[m
[36m@@ -0,0 +1,20 @@[m
[32m+[m[32m'use strict';[m
[32m+[m
[32m+[m[32mconst { spawnSync } = require('child_process');[m
[32m+[m[32mconst { readdirSync } = require('fs');[m
[32m+[m[32mconst { join } = require('path');[m
[32m+[m
[32m+[m[32mconst files = readdirSync(__dirname).sort();[m
[32m+[m[32mfor (const filename of files) {[m
[32m+[m[32m  if (filename.startsWith('test-')) {[m
[32m+[m[32m    const path = join(__dirname, filename);[m
[32m+[m[32m    console.log(`> Running ${filename} ...`);[m
[32m+[m[32m    const result = spawnSync(`${process.argv0} ${path}`, {[m
[32m+[m[32m      shell: true,[m
[32m+[m[32m      stdio: 'inherit',[m
[32m+[m[32m      windowsHide: true[m
[32m+[m[32m    });[m
[32m+[m[32m    if (result.status !== 0)[m
[32m+[m[32m      process.exitCode = 1;[m
[32m+[m[32m  }[m
[32m+[m[32m}[m
[1mdiff --git a/node_modules/concat-stream/LICENSE b/node_modules/concat-stream/LICENSE[m
[1mnew file mode 100644[m
[1mindex 0000000..99c130e[m
[1m--- /dev/null[m
[1m+++ b/node_modules/concat-stream/LICENSE[m
[36m@@ -0,0 +1,24 @@[m
[32m+[m[32mThe MIT License[m
[32m+[m
[32m+[m[32mCopyright (c) 2013 Max Ogden[m
[32m+[m
[32m+[m[32mPermission is hereby granted, free of charge,[m[41m [m
[32m+[m[32mto any person obtaining a copy of this software and[m[41m [m
[32m+[m[32massociated documentation files (the "Software"), to[m[41m [m
[32m+[m[32mdeal in the Software without restriction, including[m[41m [m
[32m+[m[32mwithout limitation the rights to use, copy, modify,[m[41m [m
[32m+[m[32mmerge, publish, distribute, sublicense, and/or sell[m[41m [m
[32m+[m[32mcopies of the Software, and to permit persons to whom[m[41m [m
[32m+[m[32mthe Software is furnished to do so,[m[41m [m
[32m+[m[32msubject to the following conditions:[m
[32m+[m
[32m+[m[32mThe above copyright notice and this permission notice[m[41m [m
[32m+[m[32mshall be included in all copies or substantial portions of the Software.[m
[32m+[m
[32m+[m[32mTHE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,[m[41m [m
[32m+[m[32mEXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES[m[41m [m
[32m+[m[32mOF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.[m[41m [m
[32m+[m[32mIN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR[m[41m [m
[32m+[m[32mANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,[m[41m [m
[32m+[m[32mTORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE[m[41m [m
[32m+[m[32mSOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.[m
\ No newline at end of file[m
[1mdiff --git a/node_modules/concat-stream/index.js b/node_modules/concat-stream/index.js[m
[1mnew file mode 100644[m
[1mindex 0000000..dd672a7[m
[1m--- /dev/null[m
[1m+++ b/node_modules/concat-stream/index.js[m
[36m@@ -0,0 +1,144 @@[m
[32m+[m[32mvar Writable = require('readable-stream').Writable[m
[32m+[m[32mvar inherits = require('inherits')[m
[32m+[m[32mvar bufferFrom = require('buffer-from')[m
[32m+[m
[32m+[m[32mif (typeof Uint8Array === 'undefined') {[m
[32m+[m[32m  var U8 = require('typedarray').Uint8Array[m
[32m+[m[32m} else {[m
[32m+[m[32m  var U8 = Uint8Array[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction ConcatStream(opts, cb) {[m
[32m+[m[32m  if (!(this instanceof ConcatStream)) return new ConcatStream(opts, cb)[m
[32m+[m
[32m+[m[32m  if (typeof opts === 'function') {[m
[32m+[m[32m    cb = opts[m
[32m+[m[32m    opts = {}[m
[32m+[m[32m  }[m
[32m+[m[32m  if (!opts) opts = {}[m
[32m+[m
[32m+[m[32m  var encoding = opts.encoding[m
[32m+[m[32m  var shouldInferEncoding = false[m
[32m+[m
[32m+[m[32m  if (!encoding) {[m
[32m+[m[32m    shouldInferEncoding = true[m
[32m+[m[32m  } else {[m
[32m+[m[32m    encoding =  String(encoding).toLowerCase()[m
[32m+[m[32m    if (encoding === 'u8' || encoding === 'uint8') {[m
[32m+[m[32m      encoding = 'uint8array'[m
[32m+[m[32m    }[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  Writable.call(this, { objectMode: true })[m
[32m+[m
[32m+[m[32m  this.encoding = encoding[m
[32m+[m[32m  this.shouldInferEncoding = shouldInferEncoding[m
[32m+[m
[32m+[m[32m  if (cb) this.on('finish', function () { cb(this.getBody()) })[m
[32m+[m[32m  this.body = [][m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mmodule.exports = ConcatStream[m
[32m+[m[32minherits(ConcatStream, Writable)[m
[32m+[m
[32m+[m[32mConcatStream.prototype._write = function(chunk, enc, next) {[m
[32m+[m[32m  this.body.push(chunk)[m
[32m+[m[32m  next()[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mConcatStream.prototype.inferEncoding = function (buff) {[m
[32m+[m[32m  var firstBuffer = buff === undefined ? this.body[0] : buff;[m
[32m+[m[32m  if (Buffer.isBuffer(firstBuffer)) return 'buffer'[m
[32m+[m[32m  if (typeof Uint8Array !== 'undefined' && firstBuffer instanceof Uint8Array) return 'uint8array'[m
[32m+[m[32m  if (Array.isArray(firstBuffer)) return 'array'[m
[32m+[m[32m  if (typeof firstBuffer === 'string') return 'string'[m
[32m+[m[32m  if (Object.prototype.toString.call(firstBuffer) === "[object Object]") return 'object'[m
[32m+[m[32m  return 'buffer'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mConcatStream.prototype.getBody = function () {[m
[32m+[m[32m  if (!this.encoding && this.body.length === 0) return [][m
[32m+[m[32m  if (this.shouldInferEncoding) this.encoding = this.inferEncoding()[m
[32m+[m[32m  if (this.encoding === 'array') return arrayConcat(this.body)[m
[32m+[m[32m  if (this.encoding === 'string') return stringConcat(this.body)[m
[32m+[m[32m  if (this.encoding === 'buffer') return bufferConcat(this.body)[m
[32m+[m[32m  if (this.encoding === 'uint8array') return u8Concat(this.body)[m
[32m+[m[32m  return this.body[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mvar isArray = Array.isArray || function (arr) {[m
[32m+[m[32m  return Object.prototype.toString.call(arr) == '[object Array]'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction isArrayish (arr) {[m
[32m+[m[32m  return /Array\]$/.test(Object.prototype.toString.call(arr))[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction isBufferish (p) {[m
[32m+[m[32m  return typeof p === 'string' || isArrayish(p) || (p && typeof p.subarray === 'function')[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction stringConcat (parts) {[m
[32m+[m[32m  var strings = [][m
[32m+[m[32m  var needsToString = false[m
[32m+[m[32m  for (var i = 0; i < parts.length; i++) {[m
[32m+[m[32m    var p = parts[i][m
[32m+[m[32m    if (typeof p === 'string') {[m
[32m+[m[32m      strings.push(p)[m
[32m+[m[32m    } else if (Buffer.isBuffer(p)) {[m
[32m+[m[32m      strings.push(p)[m
[32m+[m[32m    } else if (isBufferish(p)) {[m
[32m+[m[32m      strings.push(bufferFrom(p))[m
[32m+[m[32m    } else {[m
[32m+[m[32m      strings.push(bufferFrom(String(p)))[m
[32m+[m[32m    }[m
[32m+[m[32m  }[m
[32m+[m[32m  if (Buffer.isBuffer(parts[0])) {[m
[32m+[m[32m    strings = Buffer.concat(strings)[m
[32m+[m[32m    strings = strings.toString('utf8')[m
[32m+[m[32m  } else {[m
[32m+[m[32m    strings = strings.join('')[m
[32m+[m[32m  }[m
[32m+[m[32m  return strings[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction bufferConcat (parts) {[m
[32m+[m[32m  var bufs = [][m
[32m+[m[32m  for (var i = 0; i < parts.length; i++) {[m
[32m+[m[32m    var p = parts[i][m
[32m+[m[32m    if (Buffer.isBuffer(p)) {[m
[32m+[m[32m      bufs.push(p)[m
[32m+[m[32m    } else if (isBufferish(p)) {[m
[32m+[m[32m      bufs.push(bufferFrom(p))[m
[32m+[m[32m    } else {[m
[32m+[m[32m      bufs.push(bufferFrom(String(p)))[m
[32m+[m[32m    }[m
[32m+[m[32m  }[m
[32m+[m[32m  return Buffer.concat(bufs)[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction arrayConcat (parts) {[m
[32m+[m[32m  var res = [][m
[32m+[m[32m  for (var i = 0; i < parts.length; i++) {[m
[32m+[m[32m    res.push.apply(res, parts[i])[m
[32m+[m[32m  }[m
[32m+[m[32m  return res[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction u8Concat (parts) {[m
[32m+[m[32m  var len = 0[m
[32m+[m[32m  for (var i = 0; i < parts.length; i++) {[m
[32m+[m[32m    if (typeof parts[i] === 'string') {[m
[32m+[m[32m      parts[i] = bufferFrom(parts[i])[m
[32m+[m[32m    }[m
[32m+[m[32m    len += parts[i].length[m
[32m+[m[32m  }[m
[32m+[m[32m  var u8 = new U8(len)[m
[32m+[m[32m  for (var i = 0, offset = 0; i < parts.length; i++) {[m
[32m+[m[32m    var part = parts[i][m
[32m+[m[32m    for (var j = 0; j < part.length; j++) {[m
[32m+[m[32m      u8[offset++] = part[j][m
[32m+[m[32m    }[m
[32m+[m[32m  }[m
[32m+[m[32m  return u8[m
[32m+[m[32m}[m
[1mdiff --git a/node_modules/concat-stream/package.json b/node_modules/concat-stream/package.json[m
[1mnew file mode 100644[m
[1mindex 0000000..f709022[m
[1m--- /dev/null[m
[1m+++ b/node_modules/concat-stream/package.json[m
[36m@@ -0,0 +1,55 @@[m
[32m+[m[32m{[m
[32m+[m[32m  "name": "concat-stream",[m
[32m+[m[32m  "version": "1.6.2",[m
[32m+[m[32m  "description": "writable stream that concatenates strings or binary data and calls a callback with the result",[m
[32m+[m[32m  "tags": [[m
[32m+[m[32m    "stream",[m
[32m+[m[32m    "simple",[m
[32m+[m[32m    "util",[m
[32m+[m[32m    "utility"[m
[32m+[m[32m  ],[m
[32m+[m[32m  "author": "Max Ogden <max@maxogden.com>",[m
[32m+[m[32m  "repository": {[m
[32m+[m[32m    "type": "git",[m
[32m+[m[32m    "url": "http://github.com/maxogden/concat-stream.git"[m
[32m+[m[32m  },[m
[32m+[m[32m  "bugs": {[m
[32m+[m[32m    "url": "http://github.com/maxogden/concat-stream/issues"[m
[32m+[m[32m  },[m
[32m+[m[32m  "engines": [[m
[32m+[m[32m    "node >= 0.8"[m
[32m+[m[32m  ],[m
[32m+[m[32m  "main": "index.js",[m
[32m+[m[32m  "files": [[m
[32m+[m[32m    "index.js"[m
[32m+[m[32m  ],[m
[32m+[m[32m  "scripts": {[m
[32m+[m[32m    "test": "tape test/*.js test/server/*.js"[m
[32m+[m[32m  },[m
[32m+[m[32m  "license": "MIT",[m
[32m+[m[32m  "dependencies": {[m
[32m+[m[32m    "buffer-from": "^1.0.0",[m
[32m+[m[32m    "inherits": "^2.0.3",[m
[32m+[m[32m    "readable-stream": "^2.2.2",[m
[32m+[m[32m    "typedarray": "^0.0.6"[m
[32m+[m[32m  },[m
[32m+[m[32m  "devDependencies": {[m
[32m+[m[32m    "tape": "^4.6.3"[m
[32m+[m[32m  },[m
[32m+[m[32m  "testling": {[m
[32m+[m[32m    "files": "test/*.js",[m
[32m+[m[32m    "browsers": [[m
[32m+[m[32m      "ie/8..latest",[m
[32m+[m[32m      "firefox/17..latest",[m
[32m+[m[32m      "firefox/nightly",[m
[32m+[m[32m      "chrome/22..latest",[m
[32m+[m[32m      "chrome/canary",[m
[32m+[m[32m      "opera/12..latest",[m
[32m+[m[32m      "opera/next",[m
[32m+[m[32m      "safari/5.1..latest",[m
[32m+[m[32m      "ipad/6.0..latest",[m
[32m+[m[32m      "iphone/6.0..latest",[m
[32m+[m[32m      "android-browser/4.2..latest"[m
[32m+[m[32m    ][m
[32m+[m[32m  }[m
[32m+[m[32m}[m
[1mdiff --git a/node_modules/concat-stream/readme.md b/node_modules/concat-stream/readme.md[m
[1mnew file mode 100644[m
[1mindex 0000000..7aa19c4[m
[1m--- /dev/null[m
[1m+++ b/node_modules/concat-stream/readme.md[m
[36m@@ -0,0 +1,102 @@[m
[32m+[m[32m# concat-stream[m
[32m+[m
[32m+[m[32mWritable stream that concatenates all the data from a stream and calls a callback with the result. Use this when you want to collect all the data from a stream into a single buffer.[m
[32m+[m
[32m+[m[32m[![Build Status](https://travis-ci.org/maxogden/concat-stream.svg?branch=master)](https://travis-ci.org/maxogden/concat-stream)[m
[32m+[m
[32m+[m[32m[![NPM](https://nodei.co/npm/concat-stream.png)](https://nodei.co/npm/concat-stream/)[m
[32m+[m
[32m+[m[32m### description[m
[32m+[m
[32m+[m[32mStreams emit many buffers. If you want to collect all of the buffers, and when the stream ends concatenate all of the buffers together and receive a single buffer then this is the module for you.[m
[32m+[m
[32m+[m[32mOnly use this if you know you can fit all of the output of your stream into a single Buffer (e.g. in RAM).[m
[32m+[m
[32m+[m[32mThere are also `objectMode` streams that emit things other than Buffers, and you can concatenate these too. See below for details.[m
[32m+[m
[32m+[m[32m## Related[m
[32m+[m
[32m+[m[32m`concat-stream` is part of the [mississippi stream utility collection](https://github.com/maxogden/mississippi) which includes more useful stream modules similar to this one.[m
[32m+[m
[32m+[m[32m### examples[m
[32m+[m
[32m+[m[32m#### Buffers[m
[32m+[m
[32m+[m[32m```js[m
[32m+[m[32mvar fs = require('fs')[m
[32m+[m[32mvar concat = require('concat-stream')[m
[32m+[m
[32m+[m[32mvar readStream = fs.createReadStream('cat.png')[m
[32m+[m[32mvar concatStream = concat(gotPicture)[m
[32m+[m
[32m+[m[32mreadStream.on('error', handleError)[m
[32m+[m[32mreadStream.pipe(concatStream)[m
[32m+[m
[32m+[m[32mfunction gotPicture(imageBuffer) {[m
[32m+[m[32m  // imageBuffer is all of `cat.png` as a node.js Buffer[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction handleError(err) {[m
[32m+[m[32m  // handle your error appropriately here, e.g.:[m
[32m+[m[32m  console.error(err) // print the error to STDERR[m
[32m+[m[32m  process.exit(1) // exit program with non-zero exit code[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32m#### Arrays[m
[32m+[m
[32m+[m[32m```js[m
[32m+[m[32mvar write = concat(function(data) {})[m
[32m+[m[32mwrite.write([1,2,3])[m
[32m+[m[32mwrite.write([4,5,6])[m
[32m+[m[32mwrite.end()[m
[32m+[m[32m// data will be [1,2,3,4,5,6] in the above callback[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32m#### Uint8Arrays[m
[32m+[m
[32m+[m[32m```js[m
[32m+[m[32mvar write = concat(function(data) {})[m
[32m+[m[32mvar a = new Uint8Array(3)[m
[32m+[m[32ma[0] = 97; a[1] = 98; a[2] = 99[m
[32m+[m[32mwrite.write(a)[m
[32m+[m[32mwrite.write('!')[m
[32m+[m[32mwrite.end(Buffer.from('!!1'))[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32mSee `test/` for more examples[m
[32m+[m
[32m+[m[32m# methods[m
[32m+[m
[32m+[m[32m```js[m
[32m+[m[32mvar concat = require('concat-stream')[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32m## var writable = concat(opts={}, cb)[m
[32m+[m
[32m+[m[32mReturn a `writable` stream that will fire `cb(data)` with all of the data that[m
[32m+[m[32mwas written to the stream. Data can be written to `writable` as strings,[m
[32m+[m[32mBuffers, arrays of byte integers, and Uint8Arrays.[m[41m [m
[32m+[m
[32m+[m[32mBy default `concat-stream` will give you back the same data type as the type of the first buffer written to the stream. Use `opts.encoding` to set what format `data` should be returned as, e.g. if you if you don't want to rely on the built-in type checking or for some other reason.[m
[32m+[m
[32m+[m[32m* `string` - get a string[m
[32m+[m[32m* `buffer` - get back a Buffer[m
[32m+[m[32m* `array` - get an array of byte integers[m
[32m+[m[32m* `uint8array`, `u8`, `uint8` - get back a Uint8Array[m
[32m+[m[32m* `object`, get back an array of Objects[m
[32m+[m
[32m+[m[32mIf you don't specify an encoding, and the types can't be inferred (e.g. you write things that aren't in the list above), it will try to convert concat them into a `Buffer`.[m
[32m+[m
[32m+[m[32mIf nothing is written to `writable` then `data` will be an empty array `[]`.[m
[32m+[m
[32m+[m[32m# error handling[m
[32m+[m
[32m+[m[32m`concat-stream` does not handle errors for you, so you must handle errors on whatever streams you pipe into `concat-stream`. This is a general rule when programming with node.js streams: always handle errors on each and every stream. Since `concat-stream` is not itself a stream it does not emit errors.[m
[32m+[m
[32m+[m[32mWe recommend using [`end-of-stream`](https://npmjs.org/end-of-stream) or [`pump`](https://npmjs.org/pump) for writing error tolerant stream code.[m
[32m+[m
[32m+[m[32m# license[m
[32m+[m
[32m+[m[32mMIT LICENSE[m
[1mdiff --git a/node_modules/core-util-is/LICENSE b/node_modules/core-util-is/LICENSE[m
[1mnew file mode 100644[m
[1mindex 0000000..d8d7f94[m
[1m--- /dev/null[m
[1m+++ b/node_modules/core-util-is/LICENSE[m
[36m@@ -0,0 +1,19 @@[m
[32m+[m[32mCopyright Node.js contributors. All rights reserved.[m
[32m+[m
[32m+[m[32mPermission is hereby granted, free of charge, to any person obtaining a copy[m
[32m+[m[32mof this software and associated documentation files (the "Software"), to[m
[32m+[m[32mdeal in the Software without restriction, including without limitation the[m
[32m+[m[32mrights to use, copy, modify, merge, publish, distribute, sublicense, and/or[m
[32m+[m[32msell copies of the Software, and to permit persons to whom the Software is[m
[32m+[m[32mfurnished to do so, subject to the following conditions:[m
[32m+[m
[32m+[m[32mThe above copyright notice and this permission notice shall be included in[m
[32m+[m[32mall copies or substantial portions of the Software.[m
[32m+[m
[32m+[m[32mTHE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR[m
[32m+[m[32mIMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,[m
[32m+[m[32mFITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE[m
[32m+[m[32mAUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER[m
[32m+[m[32mLIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING[m
[32m+[m[32mFROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS[m
[32m+[m[32mIN THE SOFTWARE.[m
[1mdiff --git a/node_modules/core-util-is/README.md b/node_modules/core-util-is/README.md[m
[1mnew file mode 100644[m
[1mindex 0000000..5a76b41[m
[1m--- /dev/null[m
[1m+++ b/node_modules/core-util-is/README.md[m
[36m@@ -0,0 +1,3 @@[m
[32m+[m[32m# core-util-is[m
[32m+[m
[32m+[m[32mThe `util.is*` functions introduced in Node v0.12.[m
[1mdiff --git a/node_modules/core-util-is/lib/util.js b/node_modules/core-util-is/lib/util.js[m
[1mnew file mode 100644[m
[1mindex 0000000..6e5a20d[m
[1m--- /dev/null[m
[1m+++ b/node_modules/core-util-is/lib/util.js[m
[36m@@ -0,0 +1,107 @@[m
[32m+[m[32m// Copyright Joyent, Inc. and other Node contributors.[m
[32m+[m[32m//[m
[32m+[m[32m// Permission is hereby granted, free of charge, to any person obtaining a[m
[32m+[m[32m// copy of this software and associated documentation files (the[m
[32m+[m[32m// "Software"), to deal in the Software without restriction, including[m
[32m+[m[32m// without limitation the rights to use, copy, modify, merge, publish,[m
[32m+[m[32m// distribute, sublicense, and/or sell copies of the Software, and to permit[m
[32m+[m[32m// persons to whom the Software is furnished to do so, subject to the[m
[32m+[m[32m// following conditions:[m
[32m+[m[32m//[m
[32m+[m[32m// The above copyright notice and this permission notice shall be included[m
[32m+[m[32m// in all copies or substantial portions of the Software.[m
[32m+[m[32m//[m
[32m+[m[32m// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS[m
[32m+[m[32m// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF[m
[32m+[m[32m// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN[m
[32m+[m[32m// NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,[m
[32m+[m[32m// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR[m
[32m+[m[32m// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE[m
[32m+[m[32m// USE OR OTHER DEALINGS IN THE SOFTWARE.[m
[32m+[m
[32m+[m[32m// NOTE: These type checking functions intentionally don't use `instanceof`[m
[32m+[m[32m// because it is fragile and can be easily faked with `Object.create()`.[m
[32m+[m
[32m+[m[32mfunction isArray(arg) {[m
[32m+[m[32m  if (Array.isArray) {[m
[32m+[m[32m    return Array.isArray(arg);[m
[32m+[m[32m  }[m
[32m+[m[32m  return objectToString(arg) === '[object Array]';[m
[32m+[m[32m}[m
[32m+[m[32mexports.isArray = isArray;[m
[32m+[m
[32m+[m[32mfunction isBoolean(arg) {[m
[32m+[m[32m  return typeof arg === 'boolean';[m
[32m+[m[32m}[m
[32m+[m[32mexports.isBoolean = isBoolean;[m
[32m+[m
[32m+[m[32mfunction isNull(arg) {[m
[32m+[m[32m  return arg === null;[m
[32m+[m[32m}[m
[32m+[m[32mexports.isNull = isNull;[m
[32m+[m
[32m+[m[32mfunction isNullOrUndefined(arg) {[m
[32m+[m[32m  return arg == null;[m
[32m+[m[32m}[m
[32m+[m[32mexports.isNullOrUndefined = isNullOrUndefined;[m
[32m+[m
[32m+[m[32mfunction isNumber(arg) {[m
[32m+[m[32m  return typeof arg === 'number';[m
[32m+[m[32m}[m
[32m+[m[32mexports.isNumber = isNumber;[m
[32m+[m
[32m+[m[32mfunction isString(arg) {[m
[32m+[m[32m  return typeof arg === 'string';[m
[32m+[m[32m}[m
[32m+[m[32mexports.isString = isString;[m
[32m+[m
[32m+[m[32mfunction isSymbol(arg) {[m
[32m+[m[32m  return typeof arg === 'symbol';[m
[32m+[m[32m}[m
[32m+[m[32mexports.isSymbol = isSymbol;[m
[32m+[m
[32m+[m[32mfunction isUndefined(arg) {[m
[32m+[m[32m  return arg === void 0;[m
[32m+[m[32m}[m
[32m+[m[32mexports.isUndefined = isUndefined;[m
[32m+[m
[32m+[m[32mfunction isRegExp(re) {[m
[32m+[m[32m  return objectToString(re) === '[object RegExp]';[m
[32m+[m[32m}[m
[32m+[m[32mexports.isRegExp = isRegExp;[m
[32m+[m
[32m+[m[32mfunction isObject(arg) {[m
[32m+[m[32m  return typeof arg === 'object' && arg !== null;[m
[32m+[m[32m}[m
[32m+[m[32mexports.isObject = isObject;[m
[32m+[m
[32m+[m[32mfunction isDate(d) {[m
[32m+[m[32m  return objectToString(d) === '[object Date]';[m
[32m+[m[32m}[m
[32m+[m[32mexports.isDate = isDate;[m
[32m+[m
[32m+[m[32mfunction isError(e) {[m
[32m+[m[32m  return (objectToString(e) === '[object Error]' || e instanceof Error);[m
[32m+[m[32m}[m
[32m+[m[32mexports.isError = isError;[m
[32m+[m
[32m+[m[32mfunction isFunction(arg) {[m
[32m+[m[32m  return typeof arg === 'function';[m
[32m+[m[32m}[m
[32m+[m[32mexports.isFunction = isFunction;[m
[32m+[m
[32m+[m[32mfunction isPrimitive(arg) {[m
[32m+[m[32m  return arg === null ||[m
[32m+[m[32m         typeof arg === 'boolean' ||[m
[32m+[m[32m         typeof arg === 'number' ||[m
[32m+[m[32m         typeof arg === 'string' ||[m
[32m+[m[32m         typeof arg === 'symbol' ||  // ES6 symbol[m
[32m+[m[32m         typeof arg === 'undefined';[m
[32m+[m[32m}[m
[32m+[m[32mexports.isPrimitive = isPrimitive;[m
[32m+[m
[32m+[m[32mexports.isBuffer = require('buffer').Buffer.isBuffer;[m
[32m+[m
[32m+[m[32mfunction objectToString(o) {[m
[32m+[m[32m  return Object.prototype.toString.call(o);[m
[32m+[m[32m}[m
[1mdiff --git a/node_modules/core-util-is/package.json b/node_modules/core-util-is/package.json[m
[1mnew file mode 100644[m
[1mindex 0000000..b0c51f5[m
[1m--- /dev/null[m
[1m+++ b/node_modules/core-util-is/package.json[m
[36m@@ -0,0 +1,38 @@[m
[32m+[m[32m{[m
[32m+[m[32m  "name": "core-util-is",[m
[32m+[m[32m  "version": "1.0.3",[m
[32m+[m[32m  "description": "The `util.is*` functions introduced in Node v0.12.",[m
[32m+[m[32m  "main": "lib/util.js",[m
[32m+[m[32m  "files": [[m
[32m+[m[32m    "lib"[m
[32m+[m[32m  ],[m
[32m+[m[32m  "repository": {[m
[32m+[m[32m    "type": "git",[m
[32m+[m[32m    "url": "git://github.com/isaacs/core-util-is"[m
[32m+[m[32m  },[m
[32m+[m[32m  "keywords": [[m
[32m+[m[32m    "util",[m
[32m+[m[32m    "isBuffer",[m
[32m+[m[32m    "isArray",[m
[32m+[m[32m    "isNumber",[m
[32m+[m[32m    "isString",[m
[32m+[m[32m    "isRegExp",[m
[32m+[m[32m    "isThis",[m
[32m+[m[32m    "isThat",[m
[32m+[m[32m    "polyfill"[m
[32m+[m[32m  ],[m
[32m+[m[32m  "author": "Isaac Z. Schlueter <i@izs.me> (http://blog.izs.me/)",[m
[32m+[m[32m  "license": "MIT",[m
[32m+[m[32m  "bugs": {[m
[32m+[m[32m    "url": "https://github.com/isaacs/core-util-is/issues"[m
[32m+[m[32m  },[m
[32m+[m[32m  "scripts": {[m
[32m+[m[32m    "test": "tap test.js",[m
[32m+[m[32m    "preversion": "npm test",[m
[32m+[m[32m    "postversion": "npm publish",[m
[32m+[m[32m    "prepublishOnly": "git push origin --follow-tags"[m
[32m+[m[32m  },[m
[32m+[m[32m  "devDependencies": {[m
[32m+[m[32m    "tap": "^15.0.9"[m
[32m+[m[32m  }[m
[32m+[m[32m}[m
[1mdiff --git a/node_modules/isarray/.npmignore b/node_modules/isarray/.npmignore[m
[1mnew file mode 100644[m
[1mindex 0000000..3c3629e[m
[1m--- /dev/null[m
[1m+++ b/node_modules/isarray/.npmignore[m
[36m@@ -0,0 +1 @@[m
[32m+[m[32mnode_modules[m
[1mdiff --git a/node_modules/isarray/.travis.yml b/node_modules/isarray/.travis.yml[m
[1mnew file mode 100644[m
[1mindex 0000000..cc4dba2[m
[1m--- /dev/null[m
[1m+++ b/node_modules/isarray/.travis.yml[m
[36m@@ -0,0 +1,4 @@[m
[32m+[m[32mlanguage: node_js[m
[32m+[m[32mnode_js:[m
[32m+[m[32m  - "0.8"[m
[32m+[m[32m  - "0.10"[m
[1mdiff --git a/node_modules/isarray/Makefile b/node_modules/isarray/Makefile[m
[1mnew file mode 100644[m
[1mindex 0000000..787d56e[m
[1m--- /dev/null[m
[1m+++ b/node_modules/isarray/Makefile[m
[36m@@ -0,0 +1,6 @@[m
[32m+[m
[32m+[m[32mtest:[m
[32m+[m	[32m@node_modules/.bin/tape test.js[m
[32m+[m
[32m+[m[32m.PHONY: test[m
[32m+[m
[1mdiff --git a/node_modules/isarray/README.md b/node_modules/isarray/README.md[m
[1mnew file mode 100644[m
[1mindex 0000000..16d2c59[m
[1m--- /dev/null[m
[1m+++ b/node_modules/isarray/README.md[m
[36m@@ -0,0 +1,60 @@[m
[32m+[m
[32m+[m[32m# isarray[m
[32m+[m
[32m+[m[32m`Array#isArray` for older browsers.[m
[32m+[m
[32m+[m[32m[![build status](https://secure.travis-ci.org/juliangruber/isarray.svg)](http://travis-ci.org/juliangruber/isarray)[m
[32m+[m[32m[![downloads](https://img.shields.io/npm/dm/isarray.svg)](https://www.npmjs.org/package/isarray)[m
[32m+[m
[32m+[m[32m[![browser support](https://ci.testling.com/juliangruber/isarray.png)[m
[32m+[m[32m](https://ci.testling.com/juliangruber/isarray)[m
[32m+[m
[32m+[m[32m## Usage[m
[32m+[m
[32m+[m[32m```js[m
[32m+[m[32mvar isArray = require('isarray');[m
[32m+[m
[32m+[m[32mconsole.log(isArray([])); // => true[m
[32m+[m[32mconsole.log(isArray({})); // => false[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32m## Installation[m
[32m+[m
[32m+[m[32mWith [npm](http://npmjs.org) do[m
[32m+[m
[32m+[m[32m```bash[m
[32m+[m[32m$ npm install isarray[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32mThen bundle for the browser with[m
[32m+[m[32m[browserify](https://github.com/substack/browserify).[m
[32m+[m
[32m+[m[32mWith [component](http://component.io) do[m
[32m+[m
[32m+[m[32m```bash[m
[32m+[m[32m$ component install juliangruber/isarray[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32m## License[m
[32m+[m
[32m+[m[32m(MIT)[m
[32m+[m
[32m+[m[32mCopyright (c) 2013 Julian Gruber &lt;julian@juliangruber.com&gt;[m
[32m+[m
[32m+[m[32mPermission is hereby granted, free of charge, to any person obtaining a copy of[m
[32m+[m[32mthis software and associated documentation files (the "Software"), to deal in[m
[32m+[m[32mthe Software without restriction, including without limitation the rights to[m
[32m+[m[32muse, copy, modify, merge, publish, distribute, sublicense, and/or sell copies[m
[32m+[m[32mof the Software, and to permit persons to whom the Software is furnished to do[m
[32m+[m[32mso, subject to the following conditions:[m
[32m+[m
[32m+[m[32mThe above copyright notice and this permission notice shall be included in all[m
[32m+[m[32mcopies or substantial portions of the Software.[m
[32m+[m
[32m+[m[32mTHE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR[m
[32m+[m[32mIMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,[m
[32m+[m[32mFITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE[m
[32m+[m[32mAUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER[m
[32m+[m[32mLIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,[m
[32m+[m[32mOUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE[m
[32m+[m[32mSOFTWARE.[m
[1mdiff --git a/node_modules/isarray/component.json b/node_modules/isarray/component.json[m
[1mnew file mode 100644[m
[1mindex 0000000..9e31b68[m
[1m--- /dev/null[m
[1m+++ b/node_modules/isarray/component.json[m
[36m@@ -0,0 +1,19 @@[m
[32m+[m[32m{[m
[32m+[m[32m  "name" : "isarray",[m
[32m+[m[32m  "description" : "Array#isArray for older browsers",[m
[32m+[m[32m  "version" : "0.0.1",[m
[32m+[m[32m  "repository" : "juliangruber/isarray",[m
[32m+[m[32m  "homepage": "https://github.com/juliangruber/isarray",[m
[32m+[m[32m  "main" : "index.js",[m
[32m+[m[32m  "scripts" : [[m
[32m+[m[32m    "index.js"[m
[32m+[m[32m  ],[m
[32m+[m[32m  "dependencies" : {},[m
[32m+[m[32m  "keywords": ["browser","isarray","array"],[m
[32m+[m[32m  "author": {[m
[32m+[m[32m    "name": "Julian Gruber",[m
[32m+[m[32m    "email": "mail@juliangruber.com",[m
[32m+[m[32m    "url": "http://juliangruber.com"[m
[32m+[m[32m  },[m
[32m+[m[32m  "license": "MIT"[m
[32m+[m[32m}[m
[1mdiff --git a/node_modules/isarray/index.js b/node_modules/isarray/index.js[m
[1mnew file mode 100644[m
[1mindex 0000000..a57f634[m
[1m--- /dev/null[m
[1m+++ b/node_modules/isarray/index.js[m
[36m@@ -0,0 +1,5 @@[m
[32m+[m[32mvar toString = {}.toString;[m
[32m+[m
[32m+[m[32mmodule.exports = Array.isArray || function (arr) {[m
[32m+[m[32m  return toString.call(arr) == '[object Array]';[m
[32m+[m[32m};[m
[1mdiff --git a/node_modules/isarray/package.json b/node_modules/isarray/package.json[m
[1mnew file mode 100644[m
[1mindex 0000000..1a4317a[m
[1m--- /dev/null[m
[1m+++ b/node_modules/isarray/package.json[m
[36m@@ -0,0 +1,45 @@[m
[32m+[m[32m{[m
[32m+[m[32m  "name": "isarray",[m
[32m+[m[32m  "description": "Array#isArray for older browsers",[m
[32m+[m[32m  "version": "1.0.0",[m
[32m+[m[32m  "repository": {[m
[32m+[m[32m    "type": "git",[m
[32m+[m[32m    "url": "git://github.com/juliangruber/isarray.git"[m
[32m+[m[32m  },[m
[32m+[m[32m  "homepage": "https://github.com/juliangruber/isarray",[m
[32m+[m[32m  "main": "index.js",[m
[32m+[m[32m  "dependencies": {},[m
[32m+[m[32m  "devDependencies": {[m
[32m+[m[32m    "tape": "~2.13.4"[m
[32m+[m[32m  },[m
[32m+[m[32m  "keywords": [[m
[32m+[m[32m    "browser",[m
[32m+[m[32m    "isarray",[m
[32m+[m[32m    "array"[m
[32m+[m[32m  ],[m
[32m+[m[32m  "author": {[m
[32m+[m[32m    "name": "Julian Gruber",[m
[32m+[m[32m    "email": "mail@juliangruber.com",[m
[32m+[m[32m    "url": "http://juliangruber.com"[m
[32m+[m[32m  },[m
[32m+[m[32m  "license": "MIT",[m
[32m+[m[32m  "testling": {[m
[32m+[m[32m    "files": "test.js",[m
[32m+[m[32m    "browsers": [[m
[32m+[m[32m      "ie/8..latest",[m
[32m+[m[32m      "firefox/17..latest",[m
[32m+[m[32m      "firefox/nightly",[m
[32m+[m[32m      "chrome/22..latest",[m
[32m+[m[32m      "chrome/canary",[m
[32m+[m[32m      "opera/12..latest",[m
[32m+[m[32m      "opera/next",[m
[32m+[m[32m      "safari/5.1..latest",[m
[32m+[m[32m      "ipad/6.0..latest",[m
[32m+[m[32m      "iphone/6.0..latest",[m
[32m+[m[32m      "android-browser/4.2..latest"[m
[32m+[m[32m    ][m
[32m+[m[32m  },[m
[32m+[m[32m  "scripts": {[m
[32m+[m[32m    "test": "tape test.js"[m
[32m+[m[32m  }[m
[32m+[m[32m}[m
[1mdiff --git a/node_modules/isarray/test.js b/node_modules/isarray/test.js[m
[1mnew file mode 100644[m
[1mindex 0000000..e0c3444[m
[1m--- /dev/null[m
[1m+++ b/node_modules/isarray/test.js[m
[36m@@ -0,0 +1,20 @@[m
[32m+[m[32mvar isArray = require('./');[m
[32m+[m[32mvar test = require('tape');[m
[32m+[m
[32m+[m[32mtest('is array', function(t){[m
[32m+[m[32m  t.ok(isArray([]));[m
[32m+[m[32m  t.notOk(isArray({}));[m
[32m+[m[32m  t.notOk(isArray(null));[m
[32m+[m[32m  t.notOk(isArray(false));[m
[32m+[m
[32m+[m[32m  var obj = {};[m
[32m+[m[32m  obj[0] = true;[m
[32m+[m[32m  t.notOk(isArray(obj));[m
[32m+[m
[32m+[m[32m  var arr = [];[m
[32m+[m[32m  arr.foo = 'bar';[m
[32m+[m[32m  t.ok(isArray(arr));[m
[32m+[m
[32m+[m[32m  t.end();[m
[32m+[m[32m});[m
[32m+[m
[1mdiff --git a/node_modules/minimist/.eslintrc b/node_modules/minimist/.eslintrc[m
[1mnew file mode 100644[m
[1mindex 0000000..bd1a5e0[m
[1m--- /dev/null[m
[1m+++ b/node_modules/minimist/.eslintrc[m
[36m@@ -0,0 +1,29 @@[m
[32m+[m[32m{[m
[32m+[m	[32m"root": true,[m
[32m+[m
[32m+[m	[32m"extends": "@ljharb/eslint-config/node/0.4",[m
[32m+[m
[32m+[m	[32m"rules": {[m
[32m+[m		[32m"array-element-newline": 0,[m
[32m+[m		[32m"complexity": 0,[m
[32m+[m		[32m"func-style": [2, "declaration"],[m
[32m+[m		[32m"max-lines-per-function": 0,[m
[32m+[m		[32m"max-nested-callbacks": 1,[m
[32m+[m		[32m"max-statements-per-line": 1,[m
[32m+[m		[32m"max-statements": 0,[m
[32m+[m		[32m"multiline-comment-style": 0,[m
[32m+[m		[32m"no-continue": 1,[m
[32m+[m		[32m"no-param-reassign": 1,[m
[32m+[m		[32m"no-restricted-syntax": 1,[m
[32m+[m		[32m"object-curly-newline": 0,[m
[32m+[m	[32m},[m
[32m+[m
[32m+[m	[32m"overrides": [[m
[32m+[m		[32m{[m
[32m+[m			[32m"files": "test/**",[m
[32m+[m			[32m"rules": {[m
[32m+[m				[32m"camelcase": 0,[m
[32m+[m			[32m},[m
[32m+[m		[32m},[m
[32m+[m	[32m][m
[32m+[m[32m}[m
[1mdiff --git a/node_modules/minimist/.github/FUNDING.yml b/node_modules/minimist/.github/FUNDING.yml[m
[1mnew file mode 100644[m
[1mindex 0000000..a936622[m
[1m--- /dev/null[m
[1m+++ b/node_modules/minimist/.github/FUNDING.yml[m
[36m@@ -0,0 +1,12 @@[m
[32m+[m[32m# These are supported funding model platforms[m
[32m+[m
[32m+[m[32mgithub: [ljharb][m
[32m+[m[32mpatreon: # Replace with a single Patreon username[m
[32m+[m[32mopen_collective: # Replace with a single Open Collective username[m
[32m+[m[32mko_fi: # Replace with a single Ko-fi username[m
[32m+[m[32mtidelift: npm/minimist[m
[32m+[m[32mcommunity_bridge: # Replace with a single Community Bridge project-name e.g., cloud-foundry[m
[32m+[m[32mliberapay: # Replace with a single Liberapay username[m
[32m+[m[32missuehunt: # Replace with a single IssueHunt username[m
[32m+[m[32motechie: # Replace with a single Otechie username[m
[32m+[m[32mcustom: # Replace with up to 4 custom sponsorship URLs e.g., ['link1', 'link2'][m
[1mdiff --git a/node_modules/minimist/.nycrc b/node_modules/minimist/.nycrc[m
[1mnew file mode 100644[m
[1mindex 0000000..55c3d29[m
[1m--- /dev/null[m
[1m+++ b/node_modules/minimist/.nycrc[m
[36m@@ -0,0 +1,14 @@[m
[32m+[m[32m{[m
[32m+[m	[32m"all": true,[m
[32m+[m	[32m"check-coverage": false,[m
[32m+[m	[32m"reporter": ["text-summary", "text", "html", "json"],[m
[32m+[m	[32m"lines": 86,[m
[32m+[m	[32m"statements": 85.93,[m
[32m+[m	[32m"functions": 82.43,[m
[32m+[m	[32m"branches": 76.06,[m
[32m+[m	[32m"exclude": [[m
[32m+[m		[32m"coverage",[m
[32m+[m		[32m"example",[m
[32m+[m		[32m"test"[m
[32m+[m	[32m][m
[32m+[m[32m}[m
[1mdiff --git a/node_modules/minimist/CHANGELOG.md b/node_modules/minimist/CHANGELOG.md[m
[1mnew file mode 100644[m
[1mindex 0000000..c9a1e15[m
[1m--- /dev/null[m
[1m+++ b/node_modules/minimist/CHANGELOG.md[m
[36m@@ -0,0 +1,298 @@[m
[32m+[m[32m# Changelog[m
[32m+[m
[32m+[m[32mAll notable changes to this project will be documented in this file.[m
[32m+[m
[32m+[m[32mThe format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)[m
[32m+[m[32mand this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).[m
[32m+[m
[32m+[m[32m## [v1.2.8](https://github.com/minimistjs/minimist/compare/v1.2.7...v1.2.8) - 2023-02-09[m
[32m+[m
[32m+[m[32m### Merged[m
[32m+[m
[32m+[m[32m- [Fix] Fix long option followed by single dash [`#17`](https://github.com/minimistjs/minimist/pull/17)[m
[32m+[m[32m- [Tests] Remove duplicate test [`#12`](https://github.com/minimistjs/minimist/pull/12)[m
[32m+[m[32m- [Fix] opt.string works with multiple aliases [`#10`](https://github.com/minimistjs/minimist/pull/10)[m
[32m+[m
[32m+[m[32m### Fixed[m
[32m+[m
[32m+[m[32m- [Fix] Fix long option followed by single dash (#17) [`#15`](https://github.com/minimistjs/minimist/issues/15)[m
[32m+[m[32m- [Tests] Remove duplicate test (#12) [`#8`](https://github.com/minimistjs/minimist/issues/8)[m
[32m+[m[32m- [Fix] Fix long option followed by single dash [`#15`](https://github.com/minimistjs/minimist/issues/15)[m
[32m+[m[32m- [Fix] opt.string works with multiple aliases (#10) [`#9`](https://github.com/minimistjs/minimist/issues/9)[m
[32m+[m[32m- [Fix] Fix handling of short option with non-trivial equals [`#5`](https://github.com/minimistjs/minimist/issues/5)[m
[32m+[m[32m- [Tests] Remove duplicate test [`#8`](https://github.com/minimistjs/minimist/issues/8)[m
[32m+[m[32m- [Fix] opt.string works with multiple aliases [`#9`](https://github.com/minimistjs/minimist/issues/9)[m
[32m+[m
[32m+[m[32m### Commits[m
[32m+[m
[32m+[m[32m- Merge tag 'v0.2.3' [`a026794`](https://github.com/minimistjs/minimist/commit/a0267947c7870fc5847cf2d437fbe33f392767da)[m
[32m+[m[32m- [eslint] fix indentation and whitespace [`5368ca4`](https://github.com/minimistjs/minimist/commit/5368ca4147e974138a54cc0dc4cea8f756546b70)[m
[32m+[m[32m- [eslint] fix indentation and whitespace [`e5f5067`](https://github.com/minimistjs/minimist/commit/e5f5067259ceeaf0b098d14bec910f87e58708c7)[m
[32m+[m[32m- [eslint] more cleanup [`62fde7d`](https://github.com/minimistjs/minimist/commit/62fde7d935f83417fb046741531a9e2346a36976)[m
[32m+[m[32m- [eslint] more cleanup [`36ac5d0`](https://github.com/minimistjs/minimist/commit/36ac5d0d95e4947d074e5737d94814034ca335d1)[m
[32m+[m[32m- [meta] add `auto-changelog` [`73923d2`](https://github.com/minimistjs/minimist/commit/73923d223553fca08b1ba77e3fbc2a492862ae4c)[m
[32m+[m[32m- [actions] add reusable workflows [`d80727d`](https://github.com/minimistjs/minimist/commit/d80727df77bfa9e631044d7f16368d8f09242c91)[m
[32m+[m[32m- [eslint] add eslint; rules to enable later are warnings [`48bc06a`](https://github.com/minimistjs/minimist/commit/48bc06a1b41f00e9cdf183db34f7a51ba70e98d4)[m
[32m+[m[32m- [eslint] fix indentation [`34b0f1c`](https://github.com/minimistjs/minimist/commit/34b0f1ccaa45183c3c4f06a91f9b405180a6f982)[m
[32m+[m[32m- [readme] rename and add badges [`5df0fe4`](https://github.com/minimistjs/minimist/commit/5df0fe49211bd09a3636f8686a7cb3012c3e98f0)[m
[32m+[m[32m- [Dev Deps] switch from `covert` to `nyc` [`a48b128`](https://github.com/minimistjs/minimist/commit/a48b128fdb8d427dfb20a15273f83e38d97bef07)[m
[32m+[m[32m- [Dev Deps] update `covert`, `tape`; remove unnecessary `tap` [`f0fb958`](https://github.com/minimistjs/minimist/commit/f0fb958e9a1fe980cdffc436a211b0bda58f621b)[m
[32m+[m[32m- [meta] create FUNDING.yml; add `funding` in package.json [`3639e0c`](https://github.com/minimistjs/minimist/commit/3639e0c819359a366387e425ab6eabf4c78d3caa)[m
[32m+[m[32m- [meta] use `npmignore` to autogenerate an npmignore file [`be2e038`](https://github.com/minimistjs/minimist/commit/be2e038c342d8333b32f0fde67a0026b79c8150e)[m
[32m+[m[32m- Only apps should have lockfiles [`282b570`](https://github.com/minimistjs/minimist/commit/282b570e7489d01b03f2d6d3dabf79cd3e5f84cf)[m
[32m+[m[32m- isConstructorOrProto adapted from PR [`ef9153f`](https://github.com/minimistjs/minimist/commit/ef9153fc52b6cea0744b2239921c5dcae4697f11)[m
[32m+[m[32m- [Dev Deps] update `@ljharb/eslint-config`, `aud` [`098873c`](https://github.com/minimistjs/minimist/commit/098873c213cdb7c92e55ae1ef5aa1af3a8192a79)[m
[32m+[m[32m- [Dev Deps] update `@ljharb/eslint-config`, `aud` [`3124ed3`](https://github.com/minimistjs/minimist/commit/3124ed3e46306301ebb3c834874ce0241555c2c4)[m
[32m+[m[32m- [meta] add `safe-publish-latest` [`4b927de`](https://github.com/minimistjs/minimist/commit/4b927de696d561c636b4f43bf49d4597cb36d6d6)[m
[32m+[m[32m- [Tests] add `aud` in `posttest` [`b32d9bd`](https://github.com/minimistjs/minimist/commit/b32d9bd0ab340f4e9f8c3a97ff2a4424f25fab8c)[m
[32m+[m[32m- [meta] update repo URLs [`f9fdfc0`](https://github.com/minimistjs/minimist/commit/f9fdfc032c54884d9a9996a390c63cd0719bbe1a)[m
[32m+[m[32m- [actions] Avoid 0.6 tests due to build failures [`ba92fe6`](https://github.com/minimistjs/minimist/commit/ba92fe6ebbdc0431cca9a2ea8f27beb492f5e4ec)[m
[32m+[m[32m- [Dev Deps] update `tape` [`950eaa7`](https://github.com/minimistjs/minimist/commit/950eaa74f112e04d23e9c606c67472c46739b473)[m
[32m+[m[32m- [Dev Deps] add missing `npmignore` dev dep [`3226afa`](https://github.com/minimistjs/minimist/commit/3226afaf09e9d127ca369742437fe6e88f752d6b)[m
[32m+[m[32m- Merge tag 'v0.2.2' [`980d7ac`](https://github.com/minimistjs/minimist/commit/980d7ac61a0b4bd552711251ac107d506b23e41f)[m
[32m+[m
[32m+[m[32m## [v1.2.7](https://github.com/minimistjs/minimist/compare/v1.2.6...v1.2.7) - 2022-10-10[m
[32m+[m
[32m+[m[32m### Commits[m
[32m+[m
[32m+[m[32m- [meta] add `auto-changelog` [`0ebf4eb`](https://github.com/minimistjs/minimist/commit/0ebf4ebcd5f7787a5524d31a849ef41316b83c3c)[m
[32m+[m[32m- [actions] add reusable workflows [`e115b63`](https://github.com/minimistjs/minimist/commit/e115b63fa9d3909f33b00a2db647ff79068388de)[m
[32m+[m[32m- [eslint] add eslint; rules to enable later are warnings [`f58745b`](https://github.com/minimistjs/minimist/commit/f58745b9bb84348e1be72af7dbba5840c7c13013)[m
[32m+[m[32m- [Dev Deps] switch from `covert` to `nyc` [`ab03356`](https://github.com/minimistjs/minimist/commit/ab033567b9c8b31117cb026dc7f1e592ce455c65)[m
[32m+[m[32m- [readme] rename and add badges [`236f4a0`](https://github.com/minimistjs/minimist/commit/236f4a07e4ebe5ee44f1496ec6974991ab293ffd)[m
[32m+[m[32m- [meta] create FUNDING.yml; add `funding` in package.json [`783a49b`](https://github.com/minimistjs/minimist/commit/783a49bfd47e8335d3098a8cac75662cf71eb32a)[m
[32m+[m[32m- [meta] use `npmignore` to autogenerate an npmignore file [`f81ece6`](https://github.com/minimistjs/minimist/commit/f81ece6aaec2fa14e69ff4f1e0407a8c4e2635a2)[m
[32m+[m[32m- Only apps should have lockfiles [`56cad44`](https://github.com/minimistjs/minimist/commit/56cad44c7f879b9bb5ec18fcc349308024a89bfc)[m
[32m+[m[32m- [Dev Deps] update `covert`, `tape`; remove unnecessary `tap` [`49c5f9f`](https://github.com/minimistjs/minimist/commit/49c5f9fb7e6a92db9eb340cc679de92fb3aacded)[m
[32m+[m[32m- [Tests] add `aud` in `posttest` [`228ae93`](https://github.com/minimistjs/minimist/commit/228ae938f3cd9db9dfd8bd7458b076a7b2aef280)[m
[32m+[m[32m- [meta] add `safe-publish-latest` [`01fc23f`](https://github.com/minimistjs/minimist/commit/01fc23f5104f85c75059972e01dd33796ab529ff)[m
[32m+[m[32m- [meta] update repo URLs [`6b164c7`](https://github.com/minimistjs/minimist/commit/6b164c7d68e0b6bf32f894699effdfb7c63041dd)[m
[32m+[m
[32m+[m[32m## [v1.2.6](https://github.com/minimistjs/minimist/compare/v1.2.5...v1.2.6) - 2022-03-21[m
[32m+[m
[32m+[m[32m### Commits[m
[32m+[m
[32m+[m[32m- test from prototype pollution PR [`bc8ecee`](https://github.com/minimistjs/minimist/commit/bc8ecee43875261f4f17eb20b1243d3ed15e70eb)[m
[32m+[m[32m- isConstructorOrProto adapted from PR [`c2b9819`](https://github.com/minimistjs/minimist/commit/c2b981977fa834b223b408cfb860f933c9811e4d)[m
[32m+[m[32m- security notice for additional prototype pollution issue [`ef88b93`](https://github.com/minimistjs/minimist/commit/ef88b9325f77b5ee643ccfc97e2ebda577e4c4e2)[m
[32m+[m
[32m+[m[32m## [v1.2.5](https://github.com/minimistjs/minimist/compare/v1.2.4...v1.2.5) - 2020-03-12[m
[32m+[m
[32m+[m[32m## [v1.2.4](https://github.com/minimistjs/minimist/compare/v1.2.3...v1.2.4) - 2020-03-11[m
[32m+[m
[32m+[m[32m### Commits[m
[32m+[m
[32m+[m[32m- security notice [`4cf1354`](https://github.com/minimistjs/minimist/commit/4cf1354839cb972e38496d35e12f806eea92c11f)[m
[32m+[m[32m- additional test for constructor prototype pollution [`1043d21`](https://github.com/minimistjs/minimist/commit/1043d212c3caaf871966e710f52cfdf02f9eea4b)[m
[32m+[m
[32m+[m[32m## [v1.2.3](https://github.com/minimistjs/minimist/compare/v1.2.2...v1.2.3) - 2020-03-10[m
[32m+[m
[32m+[m[32m### Commits[m
[32m+[m
[32m+[m[32m- more failing proto pollution tests [`13c01a5`](https://github.com/minimistjs/minimist/commit/13c01a5327736903704984b7f65616b8476850cc)[m
[32m+[m[32m- even more aggressive checks for protocol pollution [`38a4d1c`](https://github.com/minimistjs/minimist/commit/38a4d1caead72ef99e824bb420a2528eec03d9ab)[m
[32m+[m
[32m+[m[32m## [v1.2.2](https://github.com/minimistjs/minimist/compare/v1.2.1...v1.2.2) - 2020-03-10[m
[32m+[m
[32m+[m[32m### Commits[m
[32m+[m
[32m+[m[32m- failing test for protocol pollution [`0efed03`](https://github.com/minimistjs/minimist/commit/0efed0340ec8433638758f7ca0c77cb20a0bfbab)[m
[32m+[m[32m- cleanup [`67d3722`](https://github.com/minimistjs/minimist/commit/67d3722413448d00a62963d2d30c34656a92d7e2)[m
[32m+[m[32m- console.dir -&gt; console.log [`47acf72`](https://github.com/minimistjs/minimist/commit/47acf72c715a630bf9ea013867f47f1dd69dfc54)[m
[32m+[m[32m- don't assign onto __proto__ [`63e7ed0`](https://github.com/minimistjs/minimist/commit/63e7ed05aa4b1889ec2f3b196426db4500cbda94)[m
[32m+[m
[32m+[m[32m## [v1.2.1](https://github.com/minimistjs/minimist/compare/v1.2.0...v1.2.1) - 2020-03-10[m
[32m+[m
[32m+[m[32m### Merged[m
[32m+[m
[32m+[m[32m- move the `opts['--']` example back where it belongs [`#63`](https://github.com/minimistjs/minimist/pull/63)[m
[32m+[m
[32m+[m[32m### Commits[m
[32m+[m
[32m+[m[32m- add test [`6be5dae`](https://github.com/minimistjs/minimist/commit/6be5dae35a32a987bcf4137fcd6c19c5200ee909)[m
[32m+[m[32m- fix bad boolean regexp [`ac3fc79`](https://github.com/minimistjs/minimist/commit/ac3fc796e63b95128fdbdf67ea7fad71bd59aa76)[m
[32m+[m
[32m+[m[32m## [v1.2.0](https://github.com/minimistjs/minimist/compare/v1.1.3...v1.2.0) - 2015-08-24[m
[32m+[m
[32m+[m[32m### Commits[m
[32m+[m
[32m+[m[32m- failing -k=v short test [`63416b8`](https://github.com/minimistjs/minimist/commit/63416b8cd1d0d70e4714564cce465a36e4dd26d7)[m
[32m+[m[32m- kv short fix [`6bbe145`](https://github.com/minimistjs/minimist/commit/6bbe14529166245e86424f220a2321442fe88dc3)[m
[32m+[m[32m- failing kv short test [`f72ab7f`](https://github.com/minimistjs/minimist/commit/f72ab7f4572adc52902c9b6873cc969192f01b10)[m
[32m+[m[32m- fixed kv test [`f5a48c3`](https://github.com/minimistjs/minimist/commit/f5a48c3e50e40ca54f00c8e84de4b4d6e9897fa8)[m
[32m+[m[32m- enforce space between arg key and value [`86b321a`](https://github.com/minimistjs/minimist/commit/86b321affe648a8e016c095a4f0efa9d9074f502)[m
[32m+[m
[32m+[m[32m## [v1.1.3](https://github.com/minimistjs/minimist/compare/v1.1.2...v1.1.3) - 2015-08-06[m
[32m+[m
[32m+[m[32m### Commits[m
[32m+[m
[32m+[m[32m- add failing test - boolean alias array [`0fa3c5b`](https://github.com/minimistjs/minimist/commit/0fa3c5b3dd98551ddecf5392831b4c21211743fc)[m
[32m+[m[32m- fix boolean values with multiple aliases [`9c0a6e7`](https://github.com/minimistjs/minimist/commit/9c0a6e7de25a273b11bbf9a7464f0bd833779795)[m
[32m+[m
[32m+[m[32m## [v1.1.2](https://github.com/minimistjs/minimist/compare/v1.1.1...v1.1.2) - 2015-07-22[m
[32m+[m
[32m+[m[32m### Commits[m
[32m+[m
[32m+[m[32m- Convert boolean arguments to boolean values [`8f3dc27`](https://github.com/minimistjs/minimist/commit/8f3dc27cf833f1d54671b6d0bcb55c2fe19672a9)[m
[32m+[m[32m- use non-ancient npm, node 0.12 and iojs [`61ed1d0`](https://github.com/minimistjs/minimist/commit/61ed1d034b9ec7282764ce76f3992b1a0b4906ae)[m
[32m+[m[32m- an older npm for 0.8 [`25cf778`](https://github.com/minimistjs/minimist/commit/25cf778b1220e7838a526832ad6972f75244054f)[m
[32m+[m
[32m+[m[32m## [v1.1.1](https://github.com/minimistjs/minimist/compare/v1.1.0...v1.1.1) - 2015-03-10[m
[32m+[m
[32m+[m[32m### Commits[m
[32m+[m
[32m+[m[32m- check that they type of a value is a boolean, not just that it is currently set to a boolean [`6863198`](https://github.com/minimistjs/minimist/commit/6863198e36139830ff1f20ffdceaddd93f2c1db9)[m
[32m+[m[32m- upgrade tape, fix type issues from old tape version [`806712d`](https://github.com/minimistjs/minimist/commit/806712df91604ed02b8e39aa372b84aea659ee34)[m
[32m+[m[32m- test for setting a boolean to a null default [`8c444fe`](https://github.com/minimistjs/minimist/commit/8c444fe89384ded7d441c120915ea60620b01dd3)[m
[32m+[m[32m- if the previous value was a boolean, without an default (or with an alias) don't make an array either [`e5f419a`](https://github.com/minimistjs/minimist/commit/e5f419a3b5b3bc3f9e5ac71b7040621af70ed2dd)[m
[32m+[m
[32m+[m[32m## [v1.1.0](https://github.com/minimistjs/minimist/compare/v1.0.0...v1.1.0) - 2014-08-10[m
[32m+[m
[32m+[m[32m### Commits[m
[32m+[m
[32m+[m[32m- add support for handling "unknown" options not registered with the parser. [`6f3cc5d`](https://github.com/minimistjs/minimist/commit/6f3cc5d4e84524932a6ef2ce3592acc67cdd4383)[m
[32m+[m[32m- reformat package.json [`02ed371`](https://github.com/minimistjs/minimist/commit/02ed37115194d3697ff358e8e25e5e66bab1d9f8)[m
[32m+[m[32m- coverage script [`e5531ba`](https://github.com/minimistjs/minimist/commit/e5531ba0479da3b8138d3d8cac545d84ccb1c8df)[m
[32m+[m[32m- extra fn to get 100% coverage again [`a6972da`](https://github.com/minimistjs/minimist/commit/a6972da89e56bf77642f8ec05a13b6558db93498)[m
[32m+[m
[32m+[m[32m## [v1.0.0](https://github.com/minimistjs/minimist/compare/v0.2.3...v1.0.0) - 2014-08-10[m
[32m+[m
[32m+[m[32m### Commits[m
[32m+[m
[32m+[m[32m- added stopEarly option [`471c7e4`](https://github.com/minimistjs/minimist/commit/471c7e4a7e910fc7ad8f9df850a186daf32c64e9)[m
[32m+[m[32m- fix list [`fef6ae7`](https://github.com/minimistjs/minimist/commit/fef6ae79c38b9dc1c49569abb7cd04eb965eac5e)[m
[32m+[m
[32m+[m[32m## [v0.2.3](https://github.com/minimistjs/minimist/compare/v0.2.2...v0.2.3) - 2023-02-09[m
[32m+[m
[32m+[m[32m### Merged[m
[32m+[m
[32m+[m[32m- [Fix] Fix long option followed by single dash [`#17`](https://github.com/minimistjs/minimist/pull/17)[m
[32m+[m[32m- [Tests] Remove duplicate test [`#12`](https://github.com/minimistjs/minimist/pull/12)[m
[32m+[m[32m- [Fix] opt.string works with multiple aliases [`#10`](https://github.com/minimistjs/minimist/pull/10)[m
[32m+[m
[32m+[m[32m### Fixed[m
[32m+[m
[32m+[m[32m- [Fix] Fix long option followed by single dash (#17) [`#15`](https://github.com/minimistjs/minimist/issues/15)[m
[32m+[m[32m- [Tests] Remove duplicate test (#12) [`#8`](https://github.com/minimistjs/minimist/issues/8)[m
[32m+[m[32m- [Fix] opt.string works with multiple aliases (#10) [`#9`](https://github.com/minimistjs/minimist/issues/9)[m
[32m+[m
[32m+[m[32m### Commits[m
[32m+[m
[32m+[m[32m- [eslint] fix indentation and whitespace [`e5f5067`](https://github.com/minimistjs/minimist/commit/e5f5067259ceeaf0b098d14bec910f87e58708c7)[m
[32m+[m[32m- [eslint] more cleanup [`36ac5d0`](https://github.com/minimistjs/minimist/commit/36ac5d0d95e4947d074e5737d94814034ca335d1)[m
[32m+[m[32m- [eslint] fix indentation [`34b0f1c`](https://github.com/minimistjs/minimist/commit/34b0f1ccaa45183c3c4f06a91f9b405180a6f982)[m
[32m+[m[32m- isConstructorOrProto adapted from PR [`ef9153f`](https://github.com/minimistjs/minimist/commit/ef9153fc52b6cea0744b2239921c5dcae4697f11)[m
[32m+[m[32m- [Dev Deps] update `@ljharb/eslint-config`, `aud` [`098873c`](https://github.com/minimistjs/minimist/commit/098873c213cdb7c92e55ae1ef5aa1af3a8192a79)[m
[32m+[m[32m- [Dev Deps] add missing `npmignore` dev dep [`3226afa`](https://github.com/minimistjs/minimist/commit/3226afaf09e9d127ca369742437fe6e88f752d6b)[m
[32m+[m
[32m+[m[32m## [v0.2.2](https://github.com/minimistjs/minimist/compare/v0.2.1...v0.2.2) - 2022-10-10[m
[32m+[m
[32m+[m[32m### Commits[m
[32m+[m
[32m+[m[32m- [meta] add `auto-changelog` [`73923d2`](https://github.com/minimistjs/minimist/commit/73923d223553fca08b1ba77e3fbc2a492862ae4c)[m
[32m+[m[32m- [actions] add reusable workflows [`d80727d`](https://github.com/minimistjs/minimist/commit/d80727df77bfa9e631044d7f16368d8f09242c91)[m
[32m+[m[32m- [eslint] add eslint; rules to enable later are warnings [`48bc06a`](https://github.com/minimistjs/minimist/commit/48bc06a1b41f00e9cdf183db34f7a51ba70e98d4)[m
[32m+[m[32m- [readme] rename and add badges [`5df0fe4`](https://github.com/minimistjs/minimist/commit/5df0fe49211bd09a3636f8686a7cb3012c3e98f0)[m
[32m+[m[32m- [Dev Deps] switch from `covert` to `nyc` [`a48b128`](https://github.com/minimistjs/minimist/commit/a48b128fdb8d427dfb20a15273f83e38d97bef07)[m
[32m+[m[32m- [Dev Deps] update `covert`, `tape`; remove unnecessary `tap` [`f0fb958`](https://github.com/minimistjs/minimist/commit/f0fb958e9a1fe980cdffc436a211b0bda58f621b)[m
[32m+[m[32m- [meta] create FUNDING.yml; add `funding` in package.json [`3639e0c`](https://github.com/minimistjs/minimist/commit/3639e0c819359a366387e425ab6eabf4c78d3caa)[m
[32m+[m[32m- [meta] use `npmignore` to autogenerate an npmignore file [`be2e038`](https://github.com/minimistjs/minimist/commit/be2e038c342d8333b32f0fde67a0026b79c8150e)[m
[32m+[m[32m- Only apps should have lockfiles [`282b570`](https://github.com/minimistjs/minimist/commit/282b570e7489d01b03f2d6d3dabf79cd3e5f84cf)[m
[32m+[m[32m- [meta] add `safe-publish-latest` [`4b927de`](https://github.com/minimistjs/minimist/commit/4b927de696d561c636b4f43bf49d4597cb36d6d6)[m
[32m+[m[32m- [Tests] add `aud` in `posttest` [`b32d9bd`](https://github.com/minimistjs/minimist/commit/b32d9bd0ab340f4e9f8c3a97ff2a4424f25fab8c)[m
[32m+[m[32m- [meta] update repo URLs [`f9fdfc0`](https://github.com/minimistjs/minimist/commit/f9fdfc032c54884d9a9996a390c63cd0719bbe1a)[m
[32m+[m
[32m+[m[32m## [v0.2.1](https://github.com/minimistjs/minimist/compare/v0.2.0...v0.2.1) - 2020-03-12[m
[32m+[m
[32m+[m[32m## [v0.2.0](https://github.com/minimistjs/minimist/compare/v0.1.0...v0.2.0) - 2014-06-19[m
[32m+[m
[32m+[m[32m### Commits[m
[32m+[m
[32m+[m[32m- support all-boolean mode [`450a97f`](https://github.com/minimistjs/minimist/commit/450a97f6e2bc85c7a4a13185c19a818d9a5ebe69)[m
[32m+[m
[32m+[m[32m## [v0.1.0](https://github.com/minimistjs/minimist/compare/v0.0.10...v0.1.0) - 2014-05-12[m
[32m+[m
[32m+[m[32m### Commits[m
[32m+[m
[32m+[m[32m- Provide a mechanism to segregate -- arguments [`ce4a1e6`](https://github.com/minimistjs/minimist/commit/ce4a1e63a7e8d5ab88d2a3768adefa6af98a445a)[m
[32m+[m[32m- documented argv['--'] [`14db0e6`](https://github.com/minimistjs/minimist/commit/14db0e6dbc6d2b9e472adaa54dad7004b364634f)[m
[32m+[m[32m- Adding a test-case for notFlags segregation [`715c1e3`](https://github.com/minimistjs/minimist/commit/715c1e3714be223f998f6c537af6b505f0236c16)[m
[32m+[m
[32m+[m[32m## [v0.0.10](https://github.com/minimistjs/minimist/compare/v0.0.9...v0.0.10) - 2014-05-11[m
[32m+[m
[32m+[m[32m### Commits[m
[32m+[m
[32m+[m[32m- dedicated boolean test [`46e448f`](https://github.com/minimistjs/minimist/commit/46e448f9f513cfeb2bcc8b688b9b47ba1e515c2b)[m
[32m+[m[32m- dedicated num test [`9bf2d36`](https://github.com/minimistjs/minimist/commit/9bf2d36f1d3b8795be90b8f7de0a937f098aa394)[m
[32m+[m[32m- aliased values treated as strings [`1ab743b`](https://github.com/minimistjs/minimist/commit/1ab743bad4484d69f1259bed42f9531de01119de)[m
[32m+[m[32m- cover the case of already numbers, at 100% coverage [`b2bb044`](https://github.com/minimistjs/minimist/commit/b2bb04436599d77a2ce029e8e555e25b3aa55d13)[m
[32m+[m[32m- another test for higher coverage [`3662624`](https://github.com/minimistjs/minimist/commit/3662624be976d5489d486a856849c048d13be903)[m
[32m+[m
[32m+[m[32m## [v0.0.9](https://github.com/minimistjs/minimist/compare/v0.0.8...v0.0.9) - 2014-05-08[m
[32m+[m
[32m+[m[32m### Commits[m
[32m+[m
[32m+[m[32m- Eliminate `longest` fn. [`824f642`](https://github.com/minimistjs/minimist/commit/824f642038d1b02ede68b6261d1d65163390929a)[m
[32m+[m
[32m+[m[32m## [v0.0.8](https://github.com/minimistjs/minimist/compare/v0.0.7...v0.0.8) - 2014-02-20[m
[32m+[m
[32m+[m[32m### Commits[m
[32m+[m
[32m+[m[32m- return '' if flag is string and empty [`fa63ed4`](https://github.com/minimistjs/minimist/commit/fa63ed4651a4ef4eefddce34188e0d98d745a263)[m
[32m+[m[32m- handle joined single letters [`66c248f`](https://github.com/minimistjs/minimist/commit/66c248f0241d4d421d193b022e9e365f11178534)[m
[32m+[m
[32m+[m[32m## [v0.0.7](https://github.com/minimistjs/minimist/compare/v0.0.6...v0.0.7) - 2014-02-08[m
[32m+[m
[32m+[m[32m### Commits[m
[32m+[m
[32m+[m[32m- another swap of .test for .match [`d1da408`](https://github.com/minimistjs/minimist/commit/d1da40819acbe846d89a5c02721211e3c1260dde)[m
[32m+[m
[32m+[m[32m## [v0.0.6](https://github.com/minimistjs/minimist/compare/v0.0.5...v0.0.6) - 2014-02-08[m
[32m+[m
[32m+[m[32m### Commits[m
[32m+[m
[32m+[m[32m- use .test() instead of .match() to not crash on non-string values in the arguments array [`7e0d1ad`](https://github.com/minimistjs/minimist/commit/7e0d1add8c9e5b9b20a4d3d0f9a94d824c578da1)[m
[32m+[m
[32m+[m[32m## [v0.0.5](https://github.com/minimistjs/minimist/compare/v0.0.4...v0.0.5) - 2013-09-18[m
[32m+[m
[32m+[m[32m### Commits[m
[32m+[m
[32m+[m[32m- Improve '--' handling. [`b11822c`](https://github.com/minimistjs/minimist/commit/b11822c09cc9d2460f30384d12afc0b953c037a4)[m
[32m+[m
[32m+[m[32m## [v0.0.4](https://github.com/minimistjs/minimist/compare/v0.0.3...v0.0.4) - 2013-09-17[m
[32m+[m
[32m+[m[32m## [v0.0.3](https://github.com/minimistjs/minimist/compare/v0.0.2...v0.0.3) - 2013-09-12[m
[32m+[m
[32m+[m[32m### Commits[m
[32m+[m
[32m+[m[32m- failing test for single dash preceeding a double dash [`b465514`](https://github.com/minimistjs/minimist/commit/b465514b82c9ae28972d714facd951deb2ad762b)[m
[32m+[m[32m- fix for the dot test [`6a095f1`](https://github.com/minimistjs/minimist/commit/6a095f1d364c8fab2d6753d2291a0649315d297a)[m
[32m+[m
[32m+[m[32m## [v0.0.2](https://github.com/minimistjs/minimist/compare/v0.0.1...v0.0.2) - 2013-08-28[m
[32m+[m
[32m+[m[32m### Commits[m
[32m+[m
[32m+[m[32m- allow dotted aliases & defaults [`321c33e`](https://github.com/minimistjs/minimist/commit/321c33e755485faaeb44eeb1c05d33b2e0a5a7c4)[m
[32m+[m[32m- use a better version of ff [`e40f611`](https://github.com/minimistjs/minimist/commit/e40f61114cf7be6f7947f7b3eed345853a67dbbb)[m
[32m+[m
[32m+[m[32m## [v0.0.1](https://github.com/minimistjs/minimist/compare/v0.0.0...v0.0.1) - 2013-06-25[m
[32m+[m
[32m+[m[32m### Commits[m
[32m+[m
[32m+[m[32m- remove trailing commas [`6ff0fa0`](https://github.com/minimistjs/minimist/commit/6ff0fa055064f15dbe06d50b89d5173a6796e1db)[m
[32m+[m
[32m+[m[32m## v0.0.0 - 2013-06-25[m
[32m+[m
[32m+[m[32m### Commits[m
[32m+[m
[32m+[m[32m- half of the parse test ported [`3079326`](https://github.com/minimistjs/minimist/commit/307932601325087de6cf94188eb798ffc4f3088a)[m
[32m+[m[32m- stripped down code and a passing test from optimist [`7cced88`](https://github.com/minimistjs/minimist/commit/7cced88d82e399d1a03ed23eb667f04d3f320d10)[m
[32m+[m[32m- ported parse tests completely over [`9448754`](https://github.com/minimistjs/minimist/commit/944875452e0820df6830b1408c26a0f7d3e1db04)[m
[32m+[m[32m- docs, package.json [`a5bf46a`](https://github.com/minimistjs/minimist/commit/a5bf46ac9bb3bd114a9c340276c62c1091e538d5)[m
[32m+[m[32m- move more short tests into short.js [`503edb5`](https://github.com/minimistjs/minimist/commit/503edb5c41d89c0d40831ee517154fc13b0f18b9)[m
[32m+[m[32m- default bool test was wrong, not the code [`1b9f5db`](https://github.com/minimistjs/minimist/commit/1b9f5db4741b49962846081b68518de824992097)[m
[32m+[m[32m- passing long tests ripped out of parse.js [`7972c4a`](https://github.com/minimistjs/minimist/commit/7972c4aff1f4803079e1668006658e2a761a0428)[m
[32m+[m[32m- badges [`84c0370`](https://github.com/minimistjs/minimist/commit/84c037063664d42878aace715fe6572ce01b6f3b)[m
[32m+[m[32m- all the tests now ported, some failures [`64239ed`](https://github.com/minimistjs/minimist/commit/64239edfe92c711c4eb0da254fcdfad2a5fdb605)[m
[32m+[m[32m- failing short test [`f8a5341`](https://github.com/minimistjs/minimist/commit/f8a534112dd1138d2fad722def56a848480c446f)[m
[32m+[m[32m- fixed the numeric test [`6b034f3`](https://github.com/minimistjs/minimist/commit/6b034f37c79342c60083ed97fd222e16928aac51)[m
[1mdiff --git a/node_modules/minimist/LICENSE b/node_modules/minimist/LICENSE[m
[1mnew file mode 100644[m
[1mindex 0000000..ee27ba4[m
[1m--- /dev/null[m
[1m+++ b/node_modules/minimist/LICENSE[m
[36m@@ -0,0 +1,18 @@[m
[32m+[m[32mThis software is released under the MIT license:[m
[32m+[m
[32m+[m[32mPermission is hereby granted, free of charge, to any person obtaining a copy of[m
[32m+[m[32mthis software and associated documentation files (the "Software"), to deal in[m
[32m+[m[32mthe Software without restriction, including without limitation the rights to[m
[32m+[m[32muse, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of[m
[32m+[m[32mthe Software, and to permit persons to whom the Software is furnished to do so,[m
[32m+[m[32msubject to the following conditions:[m
[32m+[m
[32m+[m[32mThe above copyright notice and this permission notice shall be included in all[m
[32m+[m[32mcopies or substantial portions of the Software.[m
[32m+[m
[32m+[m[32mTHE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR[m
[32m+[m[32mIMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS[m
[32m+[m[32mFOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR[m
[32m+[m[32mCOPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER[m
[32m+[m[32mIN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN[m
[32m+[m[32mCONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.[m
[1mdiff --git a/node_modules/minimist/README.md b/node_modules/minimist/README.md[m
[1mnew file mode 100644[m
[1mindex 0000000..74da323[m
[1m--- /dev/null[m
[1m+++ b/node_modules/minimist/README.md[m
[36m@@ -0,0 +1,121 @@[m
[32m+[m[32m# minimist <sup>[![Version Badge][npm-version-svg]][package-url]</sup>[m
[32m+[m
[32m+[m[32m[![github actions][actions-image]][actions-url][m
[32m+[m[32m[![coverage][codecov-image]][codecov-url][m
[32m+[m[32m[![License][license-image]][license-url][m
[32m+[m[32m[![Downloads][downloads-image]][downloads-url][m
[32m+[m
[32m+[m[32m[![npm badge][npm-badge-png]][package-url][m
[32m+[m
[32m+[m[32mparse argument options[m
[32m+[m
[32m+[m[32mThis module is the guts of optimist's argument parser without all the[m
[32m+[m[32mfanciful decoration.[m
[32m+[m
[32m+[m[32m# example[m
[32m+[m
[32m+[m[32m``` js[m
[32m+[m[32mvar argv = require('minimist')(process.argv.slice(2));[m
[32m+[m[32mconsole.log(argv);[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32m```[m
[32m+[m[32m$ node example/parse.js -a beep -b boop[m
[32m+[m[32m{ _: [], a: 'beep', b: 'boop' }[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32m```[m
[32m+[m[32m$ node example/parse.js -x 3 -y 4 -n5 -abc --beep=boop foo bar baz[m
[32m+[m[32m{[m
[32m+[m	[32m_: ['foo', 'bar', 'baz'],[m
[32m+[m	[32mx: 3,[m
[32m+[m	[32my: 4,[m
[32m+[m	[32mn: 5,[m
[32m+[m	[32ma: true,[m
[32m+[m	[32mb: true,[m
[32m+[m	[32mc: true,[m
[32m+[m	[32mbeep: 'boop'[m
[32m+[m[32m}[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32m# security[m
[32m+[m
[32m+[m[32mPrevious versions had a prototype pollution bug that could cause privilege[m
[32m+[m[32mescalation in some circumstances when handling untrusted user input.[m
[32m+[m
[32m+[m[32mPlease use version 1.2.6 or later:[m
[32m+[m
[32m+[m[32m* https://security.snyk.io/vuln/SNYK-JS-MINIMIST-2429795 (version <=1.2.5)[m
[32m+[m[32m* https://snyk.io/vuln/SNYK-JS-MINIMIST-559764 (version <=1.2.3)[m
[32m+[m
[32m+[m[32m# methods[m
[32m+[m
[32m+[m[32m``` js[m
[32m+[m[32mvar parseArgs = require('minimist')[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32m## var argv = parseArgs(args, opts={})[m
[32m+[m
[32m+[m[32mReturn an argument object `argv` populated with the array arguments from `args`.[m
[32m+[m
[32m+[m[32m`argv._` contains all the arguments that didn't have an option associated with[m
[32m+[m[32mthem.[m
[32m+[m
[32m+[m[32mNumeric-looking arguments will be returned as numbers unless `opts.string` or[m
[32m+[m[32m`opts.boolean` is set for that argument name.[m
[32m+[m
[32m+[m[32mAny arguments after `'--'` will not be parsed and will end up in `argv._`.[m
[32m+[m
[32m+[m[32moptions can be:[m
[32m+[m
[32m+[m[32m* `opts.string` - a string or array of strings argument names to always treat as[m
[32m+[m[32mstrings[m
[32m+[m[32m* `opts.boolean` - a boolean, string or array of strings to always treat as[m
[32m+[m[32mbooleans. if `true` will treat all double hyphenated arguments without equal signs[m
[32m+[m[32mas boolean (e.g. affects `--foo`, not `-f` or `--foo=bar`)[m
[32m+[m[32m* `opts.alias` - an object mapping string names to strings or arrays of string[m
[32m+[m[32margument names to use as aliases[m
[32m+[m[32m* `opts.default` - an object mapping string argument names to default values[m
[32m+[m[32m* `opts.stopEarly` - when true, populate `argv._` with everything after the[m
[32m+[m[32mfirst non-option[m
[32m+[m[32m* `opts['--']` - when true, populate `argv._` with everything before the `--`[m
[32m+[m[32mand `argv['--']` with everything after the `--`. Here's an example:[m
[32m+[m
[32m+[m[32m  ```[m
[32m+[m[32m  > require('./')('one two three -- four five --six'.split(' '), { '--': true })[m
[32m+[m[32m  {[m
[32m+[m[32m    _: ['one', 'two', 'three'],[m
[32m+[m[32m    '--': ['four', 'five', '--six'][m
[32m+[m[32m  }[m
[32m+[m[32m  ```[m
[32m+[m
[32m+[m[32m  Note that with `opts['--']` set, parsing for arguments still stops after the[m
[32m+[m[32m  `--`.[m
[32m+[m
[32m+[m[32m* `opts.unknown` - a function which is invoked with a command line parameter not[m
[32m+[m[32mdefined in the `opts` configuration object. If the function returns `false`, the[m
[32m+[m[32munknown option is not added to `argv`.[m
[32m+[m
[32m+[m[32m# install[m
[32m+[m
[32m+[m[32mWith [npm](https://npmjs.org) do:[m
[32m+[m
[32m+[m[32m```[m
[32m+[m[32mnpm install minimist[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32m# license[m
[32m+[m
[32m+[m[32mMIT[m
[32m+[m
[32m+[m[32m[package-url]: https://npmjs.org/package/minimist[m
[32m+[m[32m[npm-version-svg]: https://versionbadg.es/minimistjs/minimist.svg[m
[32m+[m[32m[npm-badge-png]: https://nodei.co/npm/minimist.png?downloads=true&stars=true[m
[32m+[m[32m[license-image]: https://img.shields.io/npm/l/minimist.svg[m
[32m+[m[32m[license-url]: LICENSE[m
[32m+[m[32m[downloads-image]: https://img.shields.io/npm/dm/minimist.svg[m
[32m+[m[32m[downloads-url]: https://npm-stat.com/charts.html?package=minimist[m
[32m+[m[32m[codecov-image]: https://codecov.io/gh/minimistjs/minimist/branch/main/graphs/badge.svg[m
[32m+[m[32m[codecov-url]: https://app.codecov.io/gh/minimistjs/minimist/[m
[32m+[m[32m[actions-image]: https://img.shields.io/endpoint?url=https://github-actions-badge-u3jn4tfpocch.runkit.sh/minimistjs/minimist[m
[32m+[m[32m[actions-url]: https://github.com/minimistjs/minimist/actions[m
[1mdiff --git a/node_modules/minimist/example/parse.js b/node_modules/minimist/example/parse.js[m
[1mnew file mode 100644[m
[1mindex 0000000..9d90ffb[m
[1m--- /dev/null[m
[1m+++ b/node_modules/minimist/example/parse.js[m
[36m@@ -0,0 +1,4 @@[m
[32m+[m[32m'use strict';[m
[32m+[m
[32m+[m[32mvar argv = require('../')(process.argv.slice(2));[m
[32m+[m[32mconsole.log(argv);[m
[1mdiff --git a/node_modules/minimist/index.js b/node_modules/minimist/index.js[m
[1mnew file mode 100644[m
[1mindex 0000000..f020f39[m
[1m--- /dev/null[m
[1m+++ b/node_modules/minimist/index.js[m
[36m@@ -0,0 +1,263 @@[m
[32m+[m[32m'use strict';[m
[32m+[m
[32m+[m[32mfunction hasKey(obj, keys) {[m
[32m+[m	[32mvar o = obj;[m
[32m+[m	[32mkeys.slice(0, -1).forEach(function (key) {[m
[32m+[m		[32mo = o[key] || {};[m
[32m+[m	[32m});[m
[32m+[m
[32m+[m	[32mvar key = keys[keys.length - 1];[m
[32m+[m	[32mreturn key in o;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction isNumber(x) {[m
[32m+[m	[32mif (typeof x === 'number') { return true; }[m
[32m+[m	[32mif ((/^0x[0-9a-f]+$/i).test(x)) { return true; }[m
[32m+[m	[32mreturn (/^[-+]?(?:\d+(?:\.\d*)?|\.\d+)(e[-+]?\d+)?$/).test(x);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction isConstructorOrProto(obj, key) {[m
[32m+[m	[32mreturn (key === 'constructor' && typeof obj[key] === 'function') || key === '__proto__';[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mmodule.exports = function (args, opts) {[m
[32m+[m	[32mif (!opts) { opts = {}; }[m
[32m+[m
[32m+[m	[32mvar flags = {[m
[32m+[m		[32mbools: {},[m
[32m+[m		[32mstrings: {},[m
[32m+[m		[32munknownFn: null,[m
[32m+[m	[32m};[m
[32m+[m
[32m+[m	[32mif (typeof opts.unknown === 'function') {[m
[32m+[m		[32mflags.unknownFn = opts.unknown;[m
[32m+[m	[32m}[m
[32m+[m
[32m+[m	[32mif (typeof opts.boolean === 'boolean' && opts.boolean) {[m
[32m+[m		[32mflags.allBools = true;[m
[32m+[m	[32m} else {[m
[32m+[m		[32m[].concat(opts.boolean).filter(Boolean).forEach(function (key) {[m
[32m+[m			[32mflags.bools[key] = true;[m
[32m+[m		[32m});[m
[32m+[m	[32m}[m
[32m+[m
[32m+[m	[32mvar aliases = {};[m
[32m+[m
[32m+[m	[32mfunction aliasIsBoolean(key) {[m
[32m+[m		[32mreturn aliases[key].some(function (x) {[m
[32m+[m			[32mreturn flags.bools[x];[m
[32m+[m		[32m});[m
[32m+[m	[32m}[m
[32m+[m
[32m+[m	[32mObject.keys(opts.alias || {}).forEach(function (key) {[m
[32m+[m		[32maliases[key] = [].concat(opts.alias[key]);[m
[32m+[m		[32maliases[key].forEach(function (x) {[m
[32m+[m			[32maliases[x] = [key].concat(aliases[key].filter(function (y) {[m
[32m+[m				[32mreturn x !== y;[m
[32m+[m			[32m}));[m
[32m+[m		[32m});[m
[32m+[m	[32m});[m
[32m+[m
[32m+[m	[32m[].concat(opts.string).filter(Boolean).forEach(function (key) {[m
[32m+[m		[32mflags.strings[key] = true;[m
[32m+[m		[32mif (aliases[key]) {[m
[32m+[m			[32m[].concat(aliases[key]).forEach(function (k) {[m
[32m+[m				[32mflags.strings[k] = true;[m
[32m+[m			[32m});[m
[32m+[m		[32m}[m
[32m+[m	[32m});[m
[32m+[m
[32m+[m	[32mvar defaults = opts.default || {};[m
[32m+[m
[32m+[m	[32mvar argv = { _: [] };[m
[32m+[m
[32m+[m	[32mfunction argDefined(key, arg) {[m
[32m+[m		[32mreturn (flags.allBools && (/^--[^=]+$/).test(arg))[m
[32m+[m			[32m|| flags.strings[key][m
[32m+[m			[32m|| flags.bools[key][m
[32m+[m			[32m|| aliases[key];[m
[32m+[m	[32m}[m
[32m+[m
[32m+[m	[32mfunction setKey(obj, keys, value) {[m
[32m+[m		[32mvar o = obj;[m
[32m+[m		[32mfor (var i = 0; i < keys.length - 1; i++) {[m
[32m+[m			[32mvar key = keys[i];[m
[32m+[m			[32mif (isConstructorOrProto(o, key)) { return; }[m
[32m+[m			[32mif (o[key] === undefined) { o[key] = {}; }[m
[32m+[m			[32mif ([m
[32m+[m				[32mo[key] === Object.prototype[m
[32m+[m				[32m|| o[key] === Number.prototype[m
[32m+[m				[32m|| o[key] === String.prototype[m
[32m+[m			[32m) {[m
[32m+[m				[32mo[key] = {};[m
[32m+[m			[32m}[m
[32m+[m			[32mif (o[key] === Array.prototype) { o[key] = []; }[m
[32m+[m			[32mo = o[key];[m
[32m+[m		[32m}[m
[32m+[m
[32m+[m		[32mvar lastKey = keys[keys.length - 1];[m
[32m+[m		[32mif (isConstructorOrProto(o, lastKey)) { return; }[m
[32m+[m		[32mif ([m
[32m+[m			[32mo === Object.prototype[m
[32m+[m			[32m|| o === Number.prototype[m
[32m+[m			[32m|| o === String.prototype[m
[32m+[m		[32m) {[m
[32m+[m			[32mo = {};[m
[32m+[m		[32m}[m
[32m+[m		[32mif (o === Array.prototype) { o = []; }[m
[32m+[m		[32mif (o[lastKey] === undefined || flags.bools[lastKey] || typeof o[lastKey] === 'boolean') {[m
[32m+[m			[32mo[lastKey] = value;[m
[32m+[m		[32m} else if (Array.isArray(o[lastKey])) {[m
[32m+[m			[32mo[lastKey].push(value);[m
[32m+[m		[32m} else {[m
[32m+[m			[32mo[lastKey] = [o[lastKey], value];[m
[32m+[m		[32m}[m
[32m+[m	[32m}[m
[32m+[m
[32m+[m	[32mfunction setArg(key, val, arg) {[m
[32m+[m		[32mif (arg && flags.unknownFn && !argDefined(key, arg)) {[m
[32m+[m			[32mif (flags.unknownFn(arg) === false) { return; }[m
[32m+[m		[32m}[m
[32m+[m
[32m+[m		[32mvar value = !flags.strings[key] && isNumber(val)[m
[32m+[m			[32m? Number(val)[m
[32m+[m			[32m: val;[m
[32m+[m		[32msetKey(argv, key.split('.'), value);[m
[32m+[m
[32m+[m		[32m(aliases[key] || []).forEach(function (x) {[m
[32m+[m			[32msetKey(argv, x.split('.'), value);[m
[32m+[m		[32m});[m
[32m+[m	[32m}[m
[32m+[m
[32m+[m	[32mObject.keys(flags.bools).forEach(function (key) {[m
[32m+[m		[32msetArg(key, defaults[key] === undefined ? false : defaults[key]);[m
[32m+[m	[32m});[m
[32m+[m
[32m+[m	[32mvar notFlags = [];[m
[32m+[m
[32m+[m	[32mif (args.indexOf('--') !== -1) {[m
[32m+[m		[32mnotFlags = args.slice(args.indexOf('--') + 1);[m
[32m+[m		[32margs = args.slice(0, args.indexOf('--'));[m
[32m+[m	[32m}[m
[32m+[m
[32m+[m	[32mfor (var i = 0; i < args.length; i++) {[m
[32m+[m		[32mvar arg = args[i];[m
[32m+[m		[32mvar key;[m
[32m+[m		[32mvar next;[m
[32m+[m
[32m+[m		[32mif ((/^--.+=/).test(arg)) {[m
[32m+[m			[32m// Using [\s\S] instead of . because js doesn't support the[m
[32m+[m			[32m// 'dotall' regex modifier. See:[m
[32m+[m			[32m// http://stackoverflow.com/a/1068308/13216[m
[32m+[m			[32mvar m = arg.match(/^--([^=]+)=([\s\S]*)$/);[m
[32m+[m			[32mkey = m[1];[m
[32m+[m			[32mvar value = m[2];[m
[32m+[m			[32mif (flags.bools[key]) {[m
[32m+[m				[32mvalue = value !== 'false';[m
[32m+[m			[32m}[m
[32m+[m			[32msetArg(key, value, arg);[m
[32m+[m		[32m} else if ((/^--no-.+/).test(arg)) {[m
[32m+[m			[32mkey = arg.match(/^--no-(.+)/)[1];[m
[32m+[m			[32msetArg(key, false, arg);[m
[32m+[m		[32m} else if ((/^--.+/).test(arg)) {[m
[32m+[m			[32mkey = arg.match(/^--(.+)/)[1];[m
[32m+[m			[32mnext = args[i + 1];[m
[32m+[m			[32mif ([m
[32m+[m				[32mnext !== undefined[m
[32m+[m				[32m&& !(/^(-|--)[^-]/).test(next)[m
[32m+[m				[32m&& !flags.bools[key][m
[32m+[m				[32m&& !flags.allBools[m
[32m+[m				[32m&& (aliases[key] ? !aliasIsBoolean(key) : true)[m
[32m+[m			[32m) {[m
[32m+[m				[32msetArg(key, next, arg);[m
[32m+[m				[32mi += 1;[m
[32m+[m			[32m} else if ((/^(true|false)$/).test(next)) {[m
[32m+[m				[32msetArg(key, next === 'true', arg);[m
[32m+[m				[32mi += 1;[m
[32m+[m			[32m} else {[m
[32m+[m				[32msetArg(key, flags.strings[key] ? '' : true, arg);[m
[32m+[m			[32m}[m
[32m+[m		[32m} else if ((/^-[^-]+/).test(arg)) {[m
[32m+[m			[32mvar letters = arg.slice(1, -1).split('');[m
[32m+[m
[32m+[m			[32mvar broken = false;[m
[32m+[m			[32mfor (var j = 0; j < letters.length; j++) {[m
[32m+[m				[32mnext = arg.slice(j + 2);[m
[32m+[m
[32m+[m				[32mif (next === '-') {[m
[32m+[m					[32msetArg(letters[j], next, arg);[m
[32m+[m					[32mcontinue;[m
[32m+[m				[32m}[m
[32m+[m
[32m+[m				[32mif ((/[A-Za-z]/).test(letters[j]) && next[0] === '=') {[m
[32m+[m					[32msetArg(letters[j], next.slice(1), arg);[m
[32m+[m					[32mbroken = true;[m
[32m+[m					[32mbreak;[m
[32m+[m				[32m}[m
[32m+[m
[32m+[m				[32mif ([m
[32m+[m					[32m(/[A-Za-z]/).test(letters[j])[m
[32m+[m					[32m&& (/-?\d+(\.\d*)?(e-?\d+)?$/).test(next)[m
[32m+[m				[32m) {[m
[32m+[m					[32msetArg(letters[j], next, arg);[m
[32m+[m					[32mbroken = true;[m
[32m+[m					[32mbreak;[m
[32m+[m				[32m}[m
[32m+[m
[32m+[m				[32mif (letters[j + 1] && letters[j + 1].match(/\W/)) {[m
[32m+[m					[32msetArg(letters[j], arg.slice(j + 2), arg);[m
[32m+[m					[32mbroken = true;[m
[32m+[m					[32mbreak;[m
[32m+[m				[32m} else {[m
[32m+[m					[32msetArg(letters[j], flags.strings[letters[j]] ? '' : true, arg);[m
[32m+[m				[32m}[m
[32m+[m			[32m}[m
[32m+[m
[32m+[m			[32mkey = arg.slice(-1)[0];[m
[32m+[m			[32mif (!broken && key !== '-') {[m
[32m+[m				[32mif ([m
[32m+[m					[32margs[i + 1][m
[32m+[m					[32m&& !(/^(-|--)[^-]/).test(args[i + 1])[m
[32m+[m					[32m&& !flags.bools[key][m
[32m+[m					[32m&& (aliases[key] ? !aliasIsBoolean(key) : true)[m
[32m+[m				[32m) {[m
[32m+[m					[32msetArg(key, args[i + 1], arg);[m
[32m+[m					[32mi += 1;[m
[32m+[m				[32m} else if (args[i + 1] && (/^(true|false)$/).test(args[i + 1])) {[m
[32m+[m					[32msetArg(key, args[i + 1] === 'true', arg);[m
[32m+[m					[32mi += 1;[m
[32m+[m				[32m} else {[m
[32m+[m					[32msetArg(key, flags.strings[key] ? '' : true, arg);[m
[32m+[m				[32m}[m
[32m+[m			[32m}[m
[32m+[m		[32m} else {[m
[32m+[m			[32mif (!flags.unknownFn || flags.unknownFn(arg) !== false) {[m
[32m+[m				[32margv._.push(flags.strings._ || !isNumber(arg) ? arg : Number(arg));[m
[32m+[m			[32m}[m
[32m+[m			[32mif (opts.stopEarly) {[m
[32m+[m				[32margv._.push.apply(argv._, args.slice(i + 1));[m
[32m+[m				[32mbreak;[m
[32m+[m			[32m}[m
[32m+[m		[32m}[m
[32m+[m	[32m}[m
[32m+[m
[32m+[m	[32mObject.keys(defaults).forEach(function (k) {[m
[32m+[m		[32mif (!hasKey(argv, k.split('.'))) {[m
[32m+[m			[32msetKey(argv, k.split('.'), defaults[k]);[m
[32m+[m
[32m+[m			[32m(aliases[k] || []).forEach(function (x) {[m
[32m+[m				[32msetKey(argv, x.split('.'), defaults[k]);[m
[32m+[m			[32m});[m
[32m+[m		[32m}[m
[32m+[m	[32m});[m
[32m+[m
[32m+[m	[32mif (opts['--']) {[m
[32m+[m		[32margv['--'] = notFlags.slice();[m
[32m+[m	[32m} else {[m
[32m+[m		[32mnotFlags.forEach(function (k) {[m
[32m+[m			[32margv._.push(k);[m
[32m+[m		[32m});[m
[32m+[m	[32m}[m
[32m+[m
[32m+[m	[32mreturn argv;[m
[32m+[m[32m};[m
[1mdiff --git a/node_modules/minimist/package.json b/node_modules/minimist/package.json[m
[1mnew file mode 100644[m
[1mindex 0000000..c10a334[m
[1m--- /dev/null[m
[1m+++ b/node_modules/minimist/package.json[m
[36m@@ -0,0 +1,75 @@[m
[32m+[m[32m{[m
[32m+[m	[32m"name": "minimist",[m
[32m+[m	[32m"version": "1.2.8",[m
[32m+[m	[32m"description": "parse argument options",[m
[32m+[m	[32m"main": "index.js",[m
[32m+[m	[32m"devDependencies": {[m
[32m+[m		[32m"@ljharb/eslint-config": "^21.0.1",[m
[32m+[m		[32m"aud": "^2.0.2",[m
[32m+[m		[32m"auto-changelog": "^2.4.0",[m
[32m+[m		[32m"eslint": "=8.8.0",[m
[32m+[m		[32m"in-publish": "^2.0.1",[m
[32m+[m		[32m"npmignore": "^0.3.0",[m
[32m+[m		[32m"nyc": "^10.3.2",[m
[32m+[m		[32m"safe-publish-latest": "^2.0.0",[m
[32m+[m		[32m"tape": "^5.6.3"[m
[32m+[m	[32m},[m
[32m+[m	[32m"scripts": {[m
[32m+[m		[32m"prepack": "npmignore --auto --commentLines=auto",[m
[32m+[m		[32m"prepublishOnly": "safe-publish-latest",[m
[32m+[m		[32m"prepublish": "not-in-publish || npm run prepublishOnly",[m
[32m+[m		[32m"lint": "eslint --ext=js,mjs .",[m
[32m+[m		[32m"pretest": "npm run lint",[m
[32m+[m		[32m"tests-only": "nyc tape 'test/**/*.js'",[m
[32m+[m		[32m"test": "npm run tests-only",[m
[32m+[m		[32m"posttest": "aud --production",[m
[32m+[m		[32m"version": "auto-changelog && git add CHANGELOG.md",[m
[32m+[m		[32m"postversion": "auto-changelog && git add CHANGELOG.md && git commit --no-edit --amend && git tag -f \"v$(node -e \"console.log(require('./package.json').version)\")\""[m
[32m+[m	[32m},[m
[32m+[m	[32m"testling": {[m
[32m+[m		[32m"files": "test/*.js",[m
[32m+[m		[32m"browsers": [[m
[32m+[m			[32m"ie/6..latest",[m
[32m+[m			[32m"ff/5",[m
[32m+[m			[32m"firefox/latest",[m
[32m+[m			[32m"chrome/10",[m
[32m+[m			[32m"chrome/latest",[m
[32m+[m			[32m"safari/5.1",[m
[32m+[m			[32m"safari/latest",[m
[32m+[m			[32m"opera/12"[m
[32m+[m		[32m][m
[32m+[m	[32m},[m
[32m+[m	[32m"repository": {[m
[32m+[m		[32m"type": "git",[m
[32m+[m		[32m"url": "git://github.com/minimistjs/minimist.git"[m
[32m+[m	[32m},[m
[32m+[m	[32m"homepage": "https://github.com/minimistjs/minimist",[m
[32m+[m	[32m"keywords": [[m
[32m+[m		[32m"argv",[m
[32m+[m		[32m"getopt",[m
[32m+[m		[32m"parser",[m
[32m+[m		[32m"optimist"[m
[32m+[m	[32m],[m
[32m+[m	[32m"author": {[m
[32m+[m		[32m"name": "James Halliday",[m
[32m+[m		[32m"email": "mail@substack.net",[m
[32m+[m		[32m"url": "http://substack.net"[m
[32m+[m	[32m},[m
[32m+[m	[32m"funding": {[m
[32m+[m		[32m"url": "https://github.com/sponsors/ljharb"[m
[32m+[m	[32m},[m
[32m+[m	[32m"license": "MIT",[m
[32m+[m	[32m"auto-changelog": {[m
[32m+[m		[32m"output": "CHANGELOG.md",[m
[32m+[m		[32m"template": "keepachangelog",[m
[32m+[m		[32m"unreleased": false,[m
[32m+[m		[32m"commitLimit": false,[m
[32m+[m		[32m"backfillLimit": false,[m
[32m+[m		[32m"hideCredit": true[m
[32m+[m	[32m},[m
[32m+[m	[32m"publishConfig": {[m
[32m+[m		[32m"ignore": [[m
[32m+[m			[32m".github/workflows"[m
[32m+[m		[32m][m
[32m+[m	[32m}[m
[32m+[m[32m}[m
[1mdiff --git a/node_modules/minimist/test/all_bool.js b/node_modules/minimist/test/all_bool.js[m
[1mnew file mode 100644[m
[1mindex 0000000..befa0c9[m
[1m--- /dev/null[m
[1m+++ b/node_modules/minimist/test/all_bool.js[m
[36m@@ -0,0 +1,34 @@[m
[32m+[m[32m'use strict';[m
[32m+[m
[32m+[m[32mvar parse = require('../');[m
[32m+[m[32mvar test = require('tape');[m
[32m+[m
[32m+[m[32mtest('flag boolean true (default all --args to boolean)', function (t) {[m
[32m+[m	[32mvar argv = parse(['moo', '--honk', 'cow'], {[m
[32m+[m		[32mboolean: true,[m
[32m+[m	[32m});[m
[32m+[m
[32m+[m	[32mt.deepEqual(argv, {[m
[32m+[m		[32mhonk: true,[m
[32m+[m		[32m_: ['moo', 'cow'],[m
[32m+[m	[32m});[m
[32m+[m
[32m+[m	[32mt.deepEqual(typeof argv.honk, 'boolean');[m
[32m+[m	[32mt.end();[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mtest('flag boolean true only affects double hyphen arguments without equals signs', function (t) {[m
[32m+[m	[32mvar argv = parse(['moo', '--honk', 'cow', '-p', '55', '--tacos=good'], {[m
[32m+[m		[32mboolean: true,[m
[32m+[m	[32m});[m
[32m+[m
[32m+[m	[32mt.deepEqual(argv, {[m
[32m+[m		[32mhonk: true,[m
[32m+[m		[32mtacos: 'good',[m
[32m+[m		[32mp: 55,[m
[32m+[m		[32m_: ['moo', 'cow'],[m
[32m+[m	[32m});[m
[32m+[m
[32m+[m	[32mt.deepEqual(typeof argv.honk, 'boolean');[m
[32m+[m	[32mt.end();[m
[32m+[m[32m});[m
[1mdiff --git a/node_modules/minimist/test/bool.js b/node_modules/minimist/test/bool.js[m
[1mnew file mode 100644[m
[1mindex 0000000..e58d47e[m
[1m--- /dev/null[m
[1m+++ b/node_modules/minimist/test/bool.js[m
[36m@@ -0,0 +1,177 @@[m
[32m+[m[32m'use strict';[m
[32m+[m
[32m+[m[32mvar parse = require('../');[m
[32m+[m[32mvar test = require('tape');[m
[32m+[m
[32m+[m[32mtest('flag boolean default false', function (t) {[m
[32m+[m	[32mvar argv = parse(['moo'], {[m
[32m+[m		[32mboolean: ['t', 'verbose'],[m
[32m+[m		[32mdefault: { verbose: false, t: false },[m
[32m+[m	[32m});[m
[32m+[m
[32m+[m	[32mt.deepEqual(argv, {[m
[32m+[m		[32mverbose: false,[m
[32m+[m		[32mt: false,[m
[32m+[m		[32m_: ['moo'],[m
[32m+[m	[32m});[m
[32m+[m
[32m+[m	[32mt.deepEqual(typeof argv.verbose, 'boolean');[m
[32m+[m	[32mt.deepEqual(typeof argv.t, 'boolean');[m
[32m+[m	[32mt.end();[m
[32m+[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mtest('boolean groups', function (t) {[m
[32m+[m	[32mvar argv = parse(['-x', '-z', 'one', 'two', 'three'], {[m
[32m+[m		[32mboolean: ['x', 'y', 'z'],[m
[32m+[m	[32m});[m
[32m+[m
[32m+[m	[32mt.deepEqual(argv, {[m
[32m+[m		[32mx: true,[m
[32m+[m		[32my: false,[m
[32m+[m		[32mz: true,[m
[32m+[m		[32m_: ['one', 'two', 'three'],[m
[32m+[m	[32m});[m
[32m+[m
[32m+[m	[32mt.deepEqual(typeof argv.x, 'boolean');[m
[32m+[m	[32mt.deepEqual(typeof argv.y, 'boolean');[m
[32m+[m	[32mt.deepEqual(typeof argv.z, 'boolean');[m
[32m+[m	[32mt.end();[m
[32m+[m[32m});[m
[32m+[m[32mtest('boolean and alias with chainable api', function (t) {[m
[32m+[m	[32mvar aliased = ['-h', 'derp'];[m
[32m+[m	[32mvar regular = ['--herp', 'derp'];[m
[32m+[m	[32mvar aliasedArgv = parse(aliased, {[m
[32m+[m		[32mboolean: 'herp',[m
[32m+[m		[32malias: { h: 'herp' },[m
[32m+[m	[32m});[m
[32m+[m	[32mvar propertyArgv = parse(regular, {[m
[32m+[m		[32mboolean: 'herp',[m
[32m+[m		[32malias: { h: 'herp' },[m
[32m+[m	[32m});[m
[32m+[m	[32mvar expected = {[m
[32m+[m		[32mherp: true,[m
[32m+[m		[32mh: true,[m
[32m+[m		[32m_: ['derp'],[m
[32m+[m	[32m};[m
[32m+[m
[32m+[m	[32mt.same(aliasedArgv, expected);[m
[32m+[m	[32mt.same(propertyArgv, expected);[m
[32m+[m	[32mt.end();[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mtest('boolean and alias with options hash', function (t) {[m
[32m+[m	[32mvar aliased = ['-h', 'derp'];[m
[32m+[m	[32mvar regular = ['--herp', 'derp'];[m
[32m+[m	[32mvar opts = {[m
[32m+[m		[32malias: { h: 'herp' },[m
[32m+[m		[32mboolean: 'herp',[m
[32m+[m	[32m};[m
[32m+[m	[32mvar aliasedArgv = parse(aliased, opts);[m
[32m+[m	[32mvar propertyArgv = parse(regular, opts);[m
[32m+[m	[32mvar expected = {[m
[32m+[m		[32mherp: true,[m
[32m+[m		[32mh: true,[m
[32m+[m		[32m_: ['derp'],[m
[32m+[m	[32m};[m
[32m+[m	[32mt.same(aliasedArgv, expected);[m
[32m+[m	[32mt.same(propertyArgv, expected);[m
[32m+[m	[32mt.end();[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mtest('boolean and alias array with options hash', function (t) {[m
[32m+[m	[32mvar aliased = ['-h', 'derp'];[m
[32m+[m	[32mvar regular = ['--herp', 'derp'];[m
[32m+[m	[32mvar alt = ['--harp', 'derp'];[m
[32m+[m	[32mvar opts = {[m
[32m+[m		[32malias: { h: ['herp', 'harp'] },[m
[32m+[m		[32mboolean: 'h',[m
[32m+[m	[32m};[m
[32m+[m	[32mvar aliasedArgv = parse(aliased, opts);[m
[32m+[m	[32mvar propertyArgv = parse(regular, opts);[m
[32m+[m	[32mvar altPropertyArgv = parse(alt, opts);[m
[32m+[m	[32mvar expected = {[m
[32m+[m		[32mharp: true,[m
[32m+[m		[32mherp: true,[m
[32m+[m		[32mh: true,[m
[32m+[m		[32m_: ['derp'],[m
[32m+[m	[32m};[m
[32m+[m	[32mt.same(aliasedArgv, expected);[m
[32m+[m	[32mt.same(propertyArgv, expected);[m
[32m+[m	[32mt.same(altPropertyArgv, expected);[m
[32m+[m	[32mt.end();[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mtest('boolean and alias using explicit true', function (t) {[m
[32m+[m	[32mvar aliased = ['-h', 'true'];[m
[32m+[m	[32mvar regular = ['--herp', 'true'];[m
[32m+[m	[32mvar opts = {[m
[32m+[m		[32malias: { h: 'herp' },[m
[32m+[m		[32mboolean: 'h',[m
[32m+[m	[32m};[m
[32m+[m	[32mvar aliasedArgv = parse(aliased, opts);[m
[32m+[m	[32mvar propertyArgv = parse(regular, opts);[m
[32m+[m	[32mvar expected = {[m
[32m+[m		[32mherp: true,[m
[32m+[m		[32mh: true,[m
[32m+[m		[32m_: [],[m
[32m+[m	[32m};[m
[32m+[m
[32m+[m	[32mt.same(aliasedArgv, expected);[m
[32m+[m	[32mt.same(propertyArgv, expected);[m
[32m+[m	[32mt.end();[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32m// regression, see https://github.com/substack/node-optimist/issues/71[m
[32m+[m[32mtest('boolean and --x=true', function (t) {[m
[32m+[m	[32mvar parsed = parse(['--boool', '--other=true'], {[m
[32m+[m		[32mboolean: 'boool',[m
[32m+[m	[32m});[m
[32m+[m
[32m+[m	[32mt.same(parsed.boool, true);[m
[32m+[m	[32mt.same(parsed.other, 'true');[m
[32m+[m
[32m+[m	[32mparsed = parse(['--boool', '--other=false'], {[m
[32m+[m		[32mboolean: 'boool',[m
[32m+[m	[32m});[m
[32m+[m
[32m+[m	[32mt.same(parsed.boool, true);[m
[32m+[m	[32mt.same(parsed.other, 'false');[m
[32m+[m	[32mt.end();[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mtest('boolean --boool=true', function (t) {[m
[32m+[m	[32mvar parsed = parse(['--boool=true'], {[m
[32m+[m		[32mdefault: {[m
[32m+[m			[32mboool: false,[m
[32m+[m		[32m},[m
[32m+[m		[32mboolean: ['boool'],[m
[32m+[m	[32m});[m
[32m+[m
[32m+[m	[32mt.same(parsed.boool, true);[m
[32m+[m	[32mt.end();[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mtest('boolean --boool=false', function (t) {[m
[32m+[m	[32mvar parsed = parse(['--boool=false'], {[m
[32m+[m		[32mdefault: {[m
[32m+[m			[32mboool: true,[m
[32m+[m		[32m},[m
[32m+[m		[32mboolean: ['boool'],[m
[32m+[m	[32m});[m
[32m+[m
[32m+[m	[32mt.same(parsed.boool, false);[m
[32m+[m	[32mt.end();[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mtest('boolean using something similar to true', function (t) {[m
[32m+[m	[32mvar opts = { boolean: 'h' };[m
[32m+[m	[32mvar result = parse(['-h', 'true.txt'], opts);[m
[32m+[m	[32mvar expected = {[m
[32m+[m		[32mh: true,[m
[32m+[m		[32m_: ['true.txt'],[m
[32m+[m	[32m};[m
[32m+[m
[32m+[m	[32mt.same(result, expected);[m
[32m+[m	[32mt.end();[m
[32m+[m[32m});[m
[1mdiff --git a/node_modules/minimist/test/dash.js b/node_modules/minimist/test/dash.js[m
[1mnew file mode 100644[m
[1mindex 0000000..7078817[m
[1m--- /dev/null[m
[1m+++ b/node_modules/minimist/test/dash.js[m
[36m@@ -0,0 +1,43 @@[m
[32m+[m[32m'use strict';[m
[32m+[m
[32m+[m[32mvar parse = require('../');[m
[32m+[m[32mvar test = require('tape');[m
[32m+[m
[32m+[m[32mtest('-', function (t) {[m
[32m+[m	[32mt.plan(6);[m
[32m+[m	[32mt.deepEqual(parse(['-n', '-']), { n: '-', _: [] });[m
[32m+[m	[32mt.deepEqual(parse(['--nnn', '-']), { nnn: '-', _: [] });[m
[32m+[m	[32mt.deepEqual(parse(['-']), { _: ['-'] });[m
[32m+[m	[32mt.deepEqual(parse(['-f-']), { f: '-', _: [] });[m
[32m+[m	[32mt.deepEqual([m
[32m+[m		[32mparse(['-b', '-'], { boolean: 'b' }),[m
[32m+[m		[32m{ b: true, _: ['-'] }[m
[32m+[m	[32m);[m
[32m+[m	[32mt.deepEqual([m
[32m+[m		[32mparse(['-s', '-'], { string: 's' }),[m
[32m+[m		[32m{ s: '-', _: [] }[m
[32m+[m	[32m);[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mtest('-a -- b', function (t) {[m
[32m+[m	[32mt.plan(2);[m
[32m+[m	[32mt.deepEqual(parse(['-a', '--', 'b']), { a: true, _: ['b'] });[m
[32m+[m	[32mt.deepEqual(parse(['--a', '--', 'b']), { a: true, _: ['b'] });[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mtest('move arguments after the -- into their own `--` array', function (t) {[m
[32m+[m	[32mt.plan(1);[m
[32m+[m	[32mt.deepEqual([m
[32m+[m		[32mparse(['--name', 'John', 'before', '--', 'after'], { '--': true }),[m
[32m+[m		[32m{ name: 'John', _: ['before'], '--': ['after'] }[m
[32m+[m	[32m);[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mtest('--- option value', function (t) {[m
[32m+[m	[32m// A multi-dash value is largely an edge case, but check the behaviour is as expected,[m
[32m+[m	[32m// and in particular the same for short option and long option (as made consistent in Jan 2023).[m
[32m+[m	[32mt.plan(2);[m
[32m+[m	[32mt.deepEqual(parse(['-n', '---']), { n: '---', _: [] });[m
[32m+[m	[32mt.deepEqual(parse(['--nnn', '---']), { nnn: '---', _: [] });[m
[32m+[m[32m});[m
[32m+[m
[1mdiff --git a/node_modules/minimist/test/default_bool.js b/node_modules/minimist/test/default_bool.js[m
[1mnew file mode 100644[m
[1mindex 0000000..4e9f625[m
[1m--- /dev/null[m
[1m+++ b/node_modules/minimist/test/default_bool.js[m
[36m@@ -0,0 +1,37 @@[m
[32m+[m[32m'use strict';[m
[32m+[m
[32m+[m[32mvar test = require('tape');[m
[32m+[m[32mvar parse = require('../');[m
[32m+[m
[32m+[m[32mtest('boolean default true', function (t) {[m
[32m+[m	[32mvar argv = parse([], {[m
[32m+[m		[32mboolean: 'sometrue',[m
[32m+[m		[32mdefault: { sometrue: true },[m
[32m+[m	[32m});[m
[32m+[m	[32mt.equal(argv.sometrue, true);[m
[32m+[m	[32mt.end();[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mtest('boolean default false', function (t) {[m
[32m+[m	[32mvar argv = parse([], {[m
[32m+[m		[32mboolean: 'somefalse',[m
[32m+[m		[32mdefault: { somefalse: false },[m
[32m+[m	[32m});[m
[32m+[m	[32mt.equal(argv.somefalse, false);[m
[32m+[m	[32mt.end();[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mtest('boolean default to null', function (t) {[m
[32m+[m	[32mvar argv = parse([], {[m
[32m+[m		[32mboolean: 'maybe',[m
[32m+[m		[32mdefault: { maybe: null },[m
[32m+[m	[32m});[m
[32m+[m	[32mt.equal(argv.maybe, null);[m
[32m+[m
[32m+[m	[32mvar argvLong = parse(['--maybe'], {[m
[32m+[m		[32mboolean: 'maybe',[m
[32m+[m		[32mdefault: { maybe: null },[m
[32m+[m	[32m});[m
[32m+[m	[32mt.equal(argvLong.maybe, true);[m
[32m+[m	[32mt.end();[m
[32m+[m[32m});[m
[1mdiff --git a/node_modules/minimist/test/dotted.js b/node_modules/minimist/test/dotted.js[m
[1mnew file mode 100644[m
[1mindex 0000000..126ff03[m
[1m--- /dev/null[m
[1m+++ b/node_modules/minimist/test/dotted.js[m
[36m@@ -0,0 +1,24 @@[m
[32m+[m[32m'use strict';[m
[32m+[m
[32m+[m[32mvar parse = require('../');[m
[32m+[m[32mvar test = require('tape');[m
[32m+[m
[32m+[m[32mtest('dotted alias', function (t) {[m
[32m+[m	[32mvar argv = parse(['--a.b', '22'], { default: { 'a.b': 11 }, alias: { 'a.b': 'aa.bb' } });[m
[32m+[m	[32mt.equal(argv.a.b, 22);[m
[32m+[m	[32mt.equal(argv.aa.bb, 22);[m
[32m+[m	[32mt.end();[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mtest('dotted default', function (t) {[m
[32m+[m	[32mvar argv = parse('', { default: { 'a.b': 11 }, alias: { 'a.b': 'aa.bb' } });[m
[32m+[m	[32mt.equal(argv.a.b, 11);[m
[32m+[m	[32mt.equal(argv.aa.bb, 11);[m
[32m+[m	[32mt.end();[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mtest('dotted default with no alias', function (t) {[m
[32m+[m	[32mvar argv = parse('', { default: { 'a.b': 11 } });[m
[32m+[m	[32mt.equal(argv.a.b, 11);[m
[32m+[m	[32mt.end();[m
[32m+[m[32m});[m
[1mdiff --git a/node_modules/minimist/test/kv_short.js b/node_modules/minimist/test/kv_short.js[m
[1mnew file mode 100644[m
[1mindex 0000000..6d1b53a[m
[1m--- /dev/null[m
[1m+++ b/node_modules/minimist/test/kv_short.js[m
[36m@@ -0,0 +1,32 @@[m
[32m+[m[32m'use strict';[m
[32m+[m
[32m+[m[32mvar parse = require('../');[m
[32m+[m[32mvar test = require('tape');[m
[32m+[m
[32m+[m[32mtest('short -k=v', function (t) {[m
[32m+[m	[32mt.plan(1);[m
[32m+[m
[32m+[m	[32mvar argv = parse(['-b=123']);[m
[32m+[m	[32mt.deepEqual(argv, { b: 123, _: [] });[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mtest('multi short -k=v', function (t) {[m
[32m+[m	[32mt.plan(1);[m
[32m+[m
[32m+[m	[32mvar argv = parse(['-a=whatever', '-b=robots']);[m
[32m+[m	[32mt.deepEqual(argv, { a: 'whatever', b: 'robots', _: [] });[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mtest('short with embedded equals -k=a=b', function (t) {[m
[32m+[m	[32mt.plan(1);[m
[32m+[m
[32m+[m	[32mvar argv = parse(['-k=a=b']);[m
[32m+[m	[32mt.deepEqual(argv, { k: 'a=b', _: [] });[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mtest('short with later equals like -ab=c', function (t) {[m
[32m+[m	[32mt.plan(1);[m
[32m+[m
[32m+[m	[32mvar argv = parse(['-ab=c']);[m
[32m+[m	[32mt.deepEqual(argv, { a: true, b: 'c', _: [] });[m
[32m+[m[32m});[m
[1mdiff --git a/node_modules/minimist/test/long.js b/node_modules/minimist/test/long.js[m
[1mnew file mode 100644[m
[1mindex 0000000..9fef51f[m
[1m--- /dev/null[m
[1m+++ b/node_modules/minimist/test/long.js[m
[36m@@ -0,0 +1,33 @@[m
[32m+[m[32m'use strict';[m
[32m+[m
[32m+[m[32mvar test = require('tape');[m
[32m+[m[32mvar parse = require('../');[m
[32m+[m
[32m+[m[32mtest('long opts', function (t) {[m
[32m+[m	[32mt.deepEqual([m
[32m+[m		[32mparse(['--bool']),[m
[32m+[m		[32m{ bool: true, _: [] },[m
[32m+[m		[32m'long boolean'[m
[32m+[m	[32m);[m
[32m+[m	[32mt.deepEqual([m
[32m+[m		[32mparse(['--pow', 'xixxle']),[m
[32m+[m		[32m{ pow: 'xixxle', _: [] },[m
[32m+[m		[32m'long capture sp'[m
[32m+[m	[32m);[m
[32m+[m	[32mt.deepEqual([m
[32m+[m		[32mparse(['--pow=xixxle']),[m
[32m+[m		[32m{ pow: 'xixxle', _: [] },[m
[32m+[m		[32m'long capture eq'[m
[32m+[m	[32m);[m
[32m+[m	[32mt.deepEqual([m
[32m+[m		[32mparse(['--host', 'localhost', '--port', '555']),[m
[32m+[m		[32m{ host: 'localhost', port: 555, _: [] },[m
[32m+[m		[32m'long captures sp'[m
[32m+[m	[32m);[m
[32m+[m	[32mt.deepEqual([m
[32m+[m		[32mparse(['--host=localhost', '--port=555']),[m
[32m+[m		[32m{ host: 'localhost', port: 555, _: [] },[m
[32m+[m		[32m'long captures eq'[m
[32m+[m	[32m);[m
[32m+[m	[32mt.end();[m
[32m+[m[32m});[m
[1mdiff --git a/node_modules/minimist/test/num.js b/node_modules/minimist/test/num.js[m
[1mnew file mode 100644[m
[1mindex 0000000..074393e[m
[1m--- /dev/null[m
[1m+++ b/node_modules/minimist/test/num.js[m
[36m@@ -0,0 +1,38 @@[m
[32m+[m[32m'use strict';[m
[32m+[m
[32m+[m[32mvar parse = require('../');[m
[32m+[m[32mvar test = require('tape');[m
[32m+[m
[32m+[m[32mtest('nums', function (t) {[m
[32m+[m	[32mvar argv = parse([[m
[32m+[m		[32m'-x', '1234',[m
[32m+[m		[32m'-y', '5.67',[m
[32m+[m		[32m'-z', '1e7',[m
[32m+[m		[32m'-w', '10f',[m
[32m+[m		[32m'--hex', '0xdeadbeef',[m
[32m+[m		[32m'789',[m
[32m+[m	[32m]);[m
[32m+[m	[32mt.deepEqual(argv, {[m
[32m+[m		[32mx: 1234,[m
[32m+[m		[32my: 5.67,[m
[32m+[m		[32mz: 1e7,[m
[32m+[m		[32mw: '10f',[m
[32m+[m		[32mhex: 0xdeadbeef,[m
[32m+[m		[32m_: [789],[m
[32m+[m	[32m});[m
[32m+[m	[32mt.deepEqual(typeof argv.x, 'number');[m
[32m+[m	[32mt.deepEqual(typeof argv.y, 'number');[m
[32m+[m	[32mt.deepEqual(typeof argv.z, 'number');[m
[32m+[m	[32mt.deepEqual(typeof argv.w, 'string');[m
[32m+[m	[32mt.deepEqual(typeof argv.hex, 'number');[m
[32m+[m	[32mt.deepEqual(typeof argv._[0], 'number');[m
[32m+[m	[32mt.end();[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mtest('already a number', function (t) {[m
[32m+[m	[32mvar argv = parse(['-x', 1234, 789]);[m
[32m+[m	[32mt.deepEqual(argv, { x: 1234, _: [789] });[m
[32m+[m	[32mt.deepEqual(typeof argv.x, 'number');[m
[32m+[m	[32mt.deepEqual(typeof argv._[0], 'number');[m
[32m+[m	[32mt.end();[m
[32m+[m[32m});[m
[1mdiff --git a/node_modules/minimist/test/parse.js b/node_modules/minimist/test/parse.js[m
[1mnew file mode 100644[m
[1mindex 0000000..65d9d90[m
[1m--- /dev/null[m
[1m+++ b/node_modules/minimist/test/parse.js[m
[36m@@ -0,0 +1,209 @@[m
[32m+[m[32m'use strict';[m
[32m+[m
[32m+[m[32mvar parse = require('../');[m
[32m+[m[32mvar test = require('tape');[m
[32m+[m
[32m+[m[32mtest('parse args', function (t) {[m
[32m+[m	[32mt.deepEqual([m
[32m+[m		[32mparse(['--no-moo']),[m
[32m+[m		[32m{ moo: false, _: [] },[m
[32m+[m		[32m'no'[m
[32m+[m	[32m);[m
[32m+[m	[32mt.deepEqual([m
[32m+[m		[32mparse(['-v', 'a', '-v', 'b', '-v', 'c']),[m
[32m+[m		[32m{ v: ['a', 'b', 'c'], _: [] },[m
[32m+[m		[32m'multi'[m
[32m+[m	[32m);[m
[32m+[m	[32mt.end();[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mtest('comprehensive', function (t) {[m
[32m+[m	[32mt.deepEqual([m
[32m+[m		[32mparse([[m
[32m+[m			[32m'--name=meowmers', 'bare', '-cats', 'woo',[m
[32m+[m			[32m'-h', 'awesome', '--multi=quux',[m
[32m+[m			[32m'--key', 'value',[m
[32m+[m			[32m'-b', '--bool', '--no-meep', '--multi=baz',[m
[32m+[m			[32m'--', '--not-a-flag', 'eek',[m
[32m+[m		[32m]),[m
[32m+[m		[32m{[m
[32m+[m			[32mc: true,[m
[32m+[m			[32ma: true,[m
[32m+[m			[32mt: true,[m
[32m+[m			[32ms: 'woo',[m
[32m+[m			[32mh: 'awesome',[m
[32m+[m			[32mb: true,[m
[32m+[m			[32mbool: true,[m
[32m+[m			[32mkey: 'value',[m
[32m+[m			[32mmulti: ['quux', 'baz'],[m
[32m+[m			[32mmeep: false,[m
[32m+[m			[32mname: 'meowmers',[m
[32m+[m			[32m_: ['bare', '--not-a-flag', 'eek'],[m
[32m+[m		[32m}[m
[32m+[m	[32m);[m
[32m+[m	[32mt.end();[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mtest('flag boolean', function (t) {[m
[32m+[m	[32mvar argv = parse(['-t', 'moo'], { boolean: 't' });[m
[32m+[m	[32mt.deepEqual(argv, { t: true, _: ['moo'] });[m
[32m+[m	[32mt.deepEqual(typeof argv.t, 'boolean');[m
[32m+[m	[32mt.end();[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mtest('flag boolean value', function (t) {[m
[32m+[m	[32mvar argv = parse(['--verbose', 'false', 'moo', '-t', 'true'], {[m
[32m+[m		[32mboolean: ['t', 'verbose'],[m
[32m+[m		[32mdefault: { verbose: true },[m
[32m+[m	[32m});[m
[32m+[m
[32m+[m	[32mt.deepEqual(argv, {[m
[32m+[m		[32mverbose: false,[m
[32m+[m		[32mt: true,[m
[32m+[m		[32m_: ['moo'],[m
[32m+[m	[32m});[m
[32m+[m
[32m+[m	[32mt.deepEqual(typeof argv.verbose, 'boolean');[m
[32m+[m	[32mt.deepEqual(typeof argv.t, 'boolean');[m
[32m+[m	[32mt.end();[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mtest('newlines in params', function (t) {[m
[32m+[m	[32mvar args = parse(['-s', 'X\nX']);[m
[32m+[m	[32mt.deepEqual(args, { _: [], s: 'X\nX' });[m
[32m+[m
[32m+[m	[32m// reproduce in bash:[m
[32m+[m	[32m// VALUE="new[m
[32m+[m	[32m// line"[m
[32m+[m	[32m// node program.js --s="$VALUE"[m
[32m+[m	[32margs = parse(['--s=X\nX']);[m
[32m+[m	[32mt.deepEqual(args, { _: [], s: 'X\nX' });[m
[32m+[m	[32mt.end();[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mtest('strings', function (t) {[m
[32m+[m	[32mvar s = parse(['-s', '0001234'], { string: 's' }).s;[m
[32m+[m	[32mt.equal(s, '0001234');[m
[32m+[m	[32mt.equal(typeof s, 'string');[m
[32m+[m
[32m+[m	[32mvar x = parse(['-x', '56'], { string: 'x' }).x;[m
[32m+[m	[32mt.equal(x, '56');[m
[32m+[m	[32mt.equal(typeof x, 'string');[m
[32m+[m	[32mt.end();[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mtest('stringArgs', function (t) {[m
[32m+[m	[32mvar s = parse(['  ', '  '], { string: '_' })._;[m
[32m+[m	[32mt.same(s.length, 2);[m
[32m+[m	[32mt.same(typeof s[0], 'string');[m
[32m+[m	[32mt.same(s[0], '  ');[m
[32m+[m	[32mt.same(typeof s[1], 'string');[m
[32m+[m	[32mt.same(s[1], '  ');[m
[32m+[m	[32mt.end();[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mtest('empty strings', function (t) {[m
[32m+[m	[32mvar s = parse(['-s'], { string: 's' }).s;[m
[32m+[m	[32mt.equal(s, '');[m
[32m+[m	[32mt.equal(typeof s, 'string');[m
[32m+[m
[32m+[m	[32mvar str = parse(['--str'], { string: 'str' }).str;[m
[32m+[m	[32mt.equal(str, '');[m
[32m+[m	[32mt.equal(typeof str, 'string');[m
[32m+[m
[32m+[m	[32mvar letters = parse(['-art'], {[m
[32m+[m		[32mstring: ['a', 't'],[m
[32m+[m	[32m});[m
[32m+[m
[32m+[m	[32mt.equal(letters.a, '');[m
[32m+[m	[32mt.equal(letters.r, true);[m
[32m+[m	[32mt.equal(letters.t, '');[m
[32m+[m
[32m+[m	[32mt.end();[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mtest('string and alias', function (t) {[m
[32m+[m	[32mvar x = parse(['--str', '000123'], {[m
[32m+[m		[32mstring: 's',[m
[32m+[m		[32malias: { s: 'str' },[m
[32m+[m	[32m});[m
[32m+[m
[32m+[m	[32mt.equal(x.str, '000123');[m
[32m+[m	[32mt.equal(typeof x.str, 'string');[m
[32m+[m	[32mt.equal(x.s, '000123');[m
[32m+[m	[32mt.equal(typeof x.s, 'string');[m
[32m+[m
[32m+[m	[32mvar y = parse(['-s', '000123'], {[m
[32m+[m		[32mstring: 'str',[m
[32m+[m		[32malias: { str: 's' },[m
[32m+[m	[32m});[m
[32m+[m
[32m+[m	[32mt.equal(y.str, '000123');[m
[32m+[m	[32mt.equal(typeof y.str, 'string');[m
[32m+[m	[32mt.equal(y.s, '000123');[m
[32m+[m	[32mt.equal(typeof y.s, 'string');[m
[32m+[m
[32m+[m	[32mvar z = parse(['-s123'], {[m
[32m+[m		[32malias: { str: ['s', 'S'] },[m
[32m+[m		[32mstring: ['str'],[m
[32m+[m	[32m});[m
[32m+[m
[32m+[m	[32mt.deepEqual([m
[32m+[m		[32mz,[m
[32m+[m		[32m{ _: [], s: '123', S: '123', str: '123' },[m
[32m+[m		[32m'opt.string works with multiple aliases'[m
[32m+[m	[32m);[m
[32m+[m	[32mt.end();[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mtest('slashBreak', function (t) {[m
[32m+[m	[32mt.same([m
[32m+[m		[32mparse(['-I/foo/bar/baz']),[m
[32m+[m		[32m{ I: '/foo/bar/baz', _: [] }[m
[32m+[m	[32m);[m
[32m+[m	[32mt.same([m
[32m+[m		[32mparse(['-xyz/foo/bar/baz']),[m
[32m+[m		[32m{ x: true, y: true, z: '/foo/bar/baz', _: [] }[m
[32m+[m	[32m);[m
[32m+[m	[32mt.end();[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mtest('alias', function (t) {[m
[32m+[m	[32mvar argv = parse(['-f', '11', '--zoom', '55'], {[m
[32m+[m		[32malias: { z: 'zoom' },[m
[32m+[m	[32m});[m
[32m+[m	[32mt.equal(argv.zoom, 55);[m
[32m+[m	[32mt.equal(argv.z, argv.zoom);[m
[32m+[m	[32mt.equal(argv.f, 11);[m
[32m+[m	[32mt.end();[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mtest('multiAlias', function (t) {[m
[32m+[m	[32mvar argv = parse(['-f', '11', '--zoom', '55'], {[m
[32m+[m		[32malias: { z: ['zm', 'zoom'] },[m
[32m+[m	[32m});[m
[32m+[m	[32mt.equal(argv.zoom, 55);[m
[32m+[m	[32mt.equal(argv.z, argv.zoom);[m
[32m+[m	[32mt.equal(argv.z, argv.zm);[m
[32m+[m	[32mt.equal(argv.f, 11);[m
[32m+[m	[32mt.end();[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mtest('nested dotted objects', function (t) {[m
[32m+[m	[32mvar argv = parse([[m
[32m+[m		[32m'--foo.bar', '3', '--foo.baz', '4',[m
[32m+[m		[32m'--foo.quux.quibble', '5', '--foo.quux.o_O',[m
[32m+[m		[32m'--beep.boop',[m
[32m+[m	[32m]);[m
[32m+[m
[32m+[m	[32mt.same(argv.foo, {[m
[32m+[m		[32mbar: 3,[m
[32m+[m		[32mbaz: 4,[m
[32m+[m		[32mquux: {[m
[32m+[m			[32mquibble: 5,[m
[32m+[m			[32mo_O: true,[m
[32m+[m		[32m},[m
[32m+[m	[32m});[m
[32m+[m	[32mt.same(argv.beep, { boop: true });[m
[32m+[m	[32mt.end();[m
[32m+[m[32m});[m
[1mdiff --git a/node_modules/minimist/test/parse_modified.js b/node_modules/minimist/test/parse_modified.js[m
[1mnew file mode 100644[m
[1mindex 0000000..32965d1[m
[1m--- /dev/null[m
[1m+++ b/node_modules/minimist/test/parse_modified.js[m
[36m@@ -0,0 +1,11 @@[m
[32m+[m[32m'use strict';[m
[32m+[m
[32m+[m[32mvar parse = require('../');[m
[32m+[m[32mvar test = require('tape');[m
[32m+[m
[32m+[m[32mtest('parse with modifier functions', function (t) {[m
[32m+[m	[32mt.plan(1);[m
[32m+[m
[32m+[m	[32mvar argv = parse(['-b', '123'], { boolean: 'b' });[m
[32m+[m	[32mt.deepEqual(argv, { b: true, _: [123] });[m
[32m+[m[32m});[m
[1mdiff --git a/node_modules/minimist/test/proto.js b/node_modules/minimist/test/proto.js[m
[1mnew file mode 100644[m
[1mindex 0000000..6e629dd[m
[1m--- /dev/null[m
[1m+++ b/node_modules/minimist/test/proto.js[m
[36m@@ -0,0 +1,64 @@[m
[32m+[m[32m'use strict';[m
[32m+[m
[32m+[m[32m/* eslint no-proto: 0 */[m
[32m+[m
[32m+[m[32mvar parse = require('../');[m
[32m+[m[32mvar test = require('tape');[m
[32m+[m
[32m+[m[32mtest('proto pollution', function (t) {[m
[32m+[m	[32mvar argv = parse(['--__proto__.x', '123']);[m
[32m+[m	[32mt.equal({}.x, undefined);[m
[32m+[m	[32mt.equal(argv.__proto__.x, undefined);[m
[32m+[m	[32mt.equal(argv.x, undefined);[m
[32m+[m	[32mt.end();[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mtest('proto pollution (array)', function (t) {[m
[32m+[m	[32mvar argv = parse(['--x', '4', '--x', '5', '--x.__proto__.z', '789']);[m
[32m+[m	[32mt.equal({}.z, undefined);[m
[32m+[m	[32mt.deepEqual(argv.x, [4, 5]);[m
[32m+[m	[32mt.equal(argv.x.z, undefined);[m
[32m+[m	[32mt.equal(argv.x.__proto__.z, undefined);[m
[32m+[m	[32mt.end();[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mtest('proto pollution (number)', function (t) {[m
[32m+[m	[32mvar argv = parse(['--x', '5', '--x.__proto__.z', '100']);[m
[32m+[m	[32mt.equal({}.z, undefined);[m
[32m+[m	[32mt.equal((4).z, undefined);[m
[32m+[m	[32mt.equal(argv.x, 5);[m
[32m+[m	[32mt.equal(argv.x.z, undefined);[m
[32m+[m	[32mt.end();[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mtest('proto pollution (string)', function (t) {[m
[32m+[m	[32mvar argv = parse(['--x', 'abc', '--x.__proto__.z', 'def']);[m
[32m+[m	[32mt.equal({}.z, undefined);[m
[32m+[m	[32mt.equal('...'.z, undefined);[m
[32m+[m	[32mt.equal(argv.x, 'abc');[m
[32m+[m	[32mt.equal(argv.x.z, undefined);[m
[32m+[m	[32mt.end();[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mtest('proto pollution (constructor)', function (t) {[m
[32m+[m	[32mvar argv = parse(['--constructor.prototype.y', '123']);[m
[32m+[m	[32mt.equal({}.y, undefined);[m
[32m+[m	[32mt.equal(argv.y, undefined);[m
[32m+[m	[32mt.end();[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mtest('proto pollution (constructor function)', function (t) {[m
[32m+[m	[32mvar argv = parse(['--_.concat.constructor.prototype.y', '123']);[m
[32m+[m	[32mfunction fnToBeTested() {}[m
[32m+[m	[32mt.equal(fnToBeTested.y, undefined);[m
[32m+[m	[32mt.equal(argv.y, undefined);[m
[32m+[m	[32mt.end();[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32m// powered by snyk - https://github.com/backstage/backstage/issues/10343[m
[32m+[m[32mtest('proto pollution (constructor function) snyk', function (t) {[m
[32m+[m	[32mvar argv = parse('--_.constructor.constructor.prototype.foo bar'.split(' '));[m
[32m+[m	[32mt.equal(function () {}.foo, undefined);[m
[32m+[m	[32mt.equal(argv.y, undefined);[m
[32m+[m	[32mt.end();[m
[32m+[m[32m});[m
[1mdiff --git a/node_modules/minimist/test/short.js b/node_modules/minimist/test/short.js[m
[1mnew file mode 100644[m
[1mindex 0000000..4a7b843[m
[1m--- /dev/null[m
[1m+++ b/node_modules/minimist/test/short.js[m
[36m@@ -0,0 +1,69 @@[m
[32m+[m[32m'use strict';[m
[32m+[m
[32m+[m[32mvar parse = require('../');[m
[32m+[m[32mvar test = require('tape');[m
[32m+[m
[32m+[m[32mtest('numeric short args', function (t) {[m
[32m+[m	[32mt.plan(2);[m
[32m+[m	[32mt.deepEqual(parse(['-n123']), { n: 123, _: [] });[m
[32m+[m	[32mt.deepEqual([m
[32m+[m		[32mparse(['-123', '456']),[m
[32m+[m		[32m{ 1: true, 2: true, 3: 456, _: [] }[m
[32m+[m	[32m);[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mtest('short', function (t) {[m
[32m+[m	[32mt.deepEqual([m
[32m+[m		[32mparse(['-b']),[m
[32m+[m		[32m{ b: true, _: [] },[m
[32m+[m		[32m'short boolean'[m
[32m+[m	[32m);[m
[32m+[m	[32mt.deepEqual([m
[32m+[m		[32mparse(['foo', 'bar', 'baz']),[m
[32m+[m		[32m{ _: ['foo', 'bar', 'baz'] },[m
[32m+[m		[32m'bare'[m
[32m+[m	[32m);[m
[32m+[m	[32mt.deepEqual([m
[32m+[m		[32mparse(['-cats']),[m
[32m+[m		[32m{ c: true, a: true, t: true, s: true, _: [] },[m
[32m+[m		[32m'group'[m
[32m+[m	[32m);[m
[32m+[m	[32mt.deepEqual([m
[32m+[m		[32mparse(['-cats', 'meow']),[m
[32m+[m		[32m{ c: true, a: true, t: true, s: 'meow', _: [] },[m
[32m+[m		[32m'short group next'[m
[32m+[m	[32m);[m
[32m+[m	[32mt.deepEqual([m
[32m+[m		[32mparse(['-h', 'localhost']),[m
[32m+[m		[32m{ h: 'localhost', _: [] },[m
[32m+[m		[32m'short capture'[m
[32m+[m	[32m);[m
[32m+[m	[32mt.deepEqual([m
[32m+[m		[32mparse(['-h', 'localhost', '-p', '555']),[m
[32m+[m		[32m{ h: 'localhost', p: 555, _: [] },[m
[32m+[m		[32m'short captures'[m
[32m+[m	[32m);[m
[32m+[m	[32mt.end();[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mtest('mixed short bool and capture', function (t) {[m
[32m+[m	[32mt.same([m
[32m+[m		[32mparse(['-h', 'localhost', '-fp', '555', 'script.js']),[m
[32m+[m		[32m{[m
[32m+[m			[32mf: true, p: 555, h: 'localhost',[m
[32m+[m			[32m_: ['script.js'],[m
[32m+[m		[32m}[m
[32m+[m	[32m);[m
[32m+[m	[32mt.end();[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mtest('short and long', function (t) {[m
[32m+[m	[32mt.deepEqual([m
[32m+[m		[32mparse(['-h', 'localhost', '-fp', '555', 'script.js']),[m
[32m+[m		[32m{[m
[32m+[m			[32mf: true, p: 555, h: 'localhost',[m
[32m+[m			[32m_: ['script.js'],[m
[32m+[m		[32m}[m
[32m+[m	[32m);[m
[32m+[m	[32mt.end();[m
[32m+[m[32m});[m
[1mdiff --git a/node_modules/minimist/test/stop_early.js b/node_modules/minimist/test/stop_early.js[m
[1mnew file mode 100644[m
[1mindex 0000000..52a6a91[m
[1m--- /dev/null[m
[1m+++ b/node_modules/minimist/test/stop_early.js[m
[36m@@ -0,0 +1,17 @@[m
[32m+[m[32m'use strict';[m
[32m+[m
[32m+[m[32mvar parse = require('../');[m
[32m+[m[32mvar test = require('tape');[m
[32m+[m
[32m+[m[32mtest('stops parsing on the first non-option when stopEarly is set', function (t) {[m
[32m+[m	[32mvar argv = parse(['--aaa', 'bbb', 'ccc', '--ddd'], {[m
[32m+[m		[32mstopEarly: true,[m
[32m+[m	[32m});[m
[32m+[m
[32m+[m	[32mt.deepEqual(argv, {[m
[32m+[m		[32maaa: 'bbb',[m
[32m+[m		[32m_: ['ccc', '--ddd'],[m
[32m+[m	[32m});[m
[32m+[m
[32m+[m	[32mt.end();[m
[32m+[m[32m});[m
[1mdiff --git a/node_modules/minimist/test/unknown.js b/node_modules/minimist/test/unknown.js[m
[1mnew file mode 100644[m
[1mindex 0000000..4f2e0ca[m
[1m--- /dev/null[m
[1m+++ b/node_modules/minimist/test/unknown.js[m
[36m@@ -0,0 +1,104 @@[m
[32m+[m[32m'use strict';[m
[32m+[m
[32m+[m[32mvar parse = require('../');[m
[32m+[m[32mvar test = require('tape');[m
[32m+[m
[32m+[m[32mtest('boolean and alias is not unknown', function (t) {[m
[32m+[m	[32mvar unknown = [];[m
[32m+[m	[32mfunction unknownFn(arg) {[m
[32m+[m		[32munknown.push(arg);[m
[32m+[m		[32mreturn false;[m
[32m+[m	[32m}[m
[32m+[m	[32mvar aliased = ['-h', 'true', '--derp', 'true'];[m
[32m+[m	[32mvar regular = ['--herp', 'true', '-d', 'true'];[m
[32m+[m	[32mvar opts = {[m
[32m+[m		[32malias: { h: 'herp' },[m
[32m+[m		[32mboolean: 'h',[m
[32m+[m		[32munknown: unknownFn,[m
[32m+[m	[32m};[m
[32m+[m	[32mparse(aliased, opts);[m
[32m+[m	[32mparse(regular, opts);[m
[32m+[m
[32m+[m	[32mt.same(unknown, ['--derp', '-d']);[m
[32m+[m	[32mt.end();[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mtest('flag boolean true any double hyphen argument is not unknown', function (t) {[m
[32m+[m	[32mvar unknown = [];[m
[32m+[m	[32mfunction unknownFn(arg) {[m
[32m+[m		[32munknown.push(arg);[m
[32m+[m		[32mreturn false;[m
[32m+[m	[32m}[m
[32m+[m	[32mvar argv = parse(['--honk', '--tacos=good', 'cow', '-p', '55'], {[m
[32m+[m		[32mboolean: true,[m
[32m+[m		[32munknown: unknownFn,[m
[32m+[m	[32m});[m
[32m+[m	[32mt.same(unknown, ['--tacos=good', 'cow', '-p']);[m
[32m+[m	[32mt.same(argv, {[m
[32m+[m		[32mhonk: true,[m
[32m+[m		[32m_: [],[m
[32m+[m	[32m});[m
[32m+[m	[32mt.end();[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mtest('string and alias is not unknown', function (t) {[m
[32m+[m	[32mvar unknown = [];[m
[32m+[m	[32mfunction unknownFn(arg) {[m
[32m+[m		[32munknown.push(arg);[m
[32m+[m		[32mreturn false;[m
[32m+[m	[32m}[m
[32m+[m	[32mvar aliased = ['-h', 'hello', '--derp', 'goodbye'];[m
[32m+[m	[32mvar regular = ['--herp', 'hello', '-d', 'moon'];[m
[32m+[m	[32mvar opts = {[m
[32m+[m		[32malias: { h: 'herp' },[m
[32m+[m		[32mstring: 'h',[m
[32m+[m		[32munknown: unknownFn,[m
[32m+[m	[32m};[m
[32m+[m	[32mparse(aliased, opts);[m
[32m+[m	[32mparse(regular, opts);[m
[32m+[m
[32m+[m	[32mt.same(unknown, ['--derp', '-d']);[m
[32m+[m	[32mt.end();[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mtest('default and alias is not unknown', function (t) {[m
[32m+[m	[32mvar unknown = [];[m
[32m+[m	[32mfunction unknownFn(arg) {[m
[32m+[m		[32munknown.push(arg);[m
[32m+[m		[32mreturn false;[m
[32m+[m	[32m}[m
[32m+[m	[32mvar aliased = ['-h', 'hello'];[m
[32m+[m	[32mvar regular = ['--herp', 'hello'];[m
[32m+[m	[32mvar opts = {[m
[32m+[m		[32mdefault: { h: 'bar' },[m
[32m+[m		[32malias: { h: 'herp' },[m
[32m+[m		[32munknown: unknownFn,[m
[32m+[m	[32m};[m
[32m+[m	[32mparse(aliased, opts);[m
[32m+[m	[32mparse(regular, opts);[m
[32m+[m
[32m+[m	[32mt.same(unknown, []);[m
[32m+[m	[32mt.end();[m
[32m+[m	[32munknownFn(); // exercise fn for 100% coverage[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mtest('value following -- is not unknown', function (t) {[m
[32m+[m	[32mvar unknown = [];[m
[32m+[m	[32mfunction unknownFn(arg) {[m
[32m+[m		[32munknown.push(arg);[m
[32m+[m		[32mreturn false;[m
[32m+[m	[32m}[m
[32m+[m	[32mvar aliased = ['--bad', '--', 'good', 'arg'];[m
[32m+[m	[32mvar opts = {[m
[32m+[m		[32m'--': true,[m
[32m+[m		[32munknown: unknownFn,[m
[32m+[m	[32m};[m
[32m+[m	[32mvar argv = parse(aliased, opts);[m
[32m+[m
[32m+[m	[32mt.same(unknown, ['--bad']);[m
[32m+[m	[32mt.same(argv, {[m
[32m+[m		[32m'--': ['good', 'arg'],[m
[32m+[m		[32m_: [],[m
[32m+[m	[32m});[m
[32m+[m	[32mt.end();[m
[32m+[m[32m});[m
[1mdiff --git a/node_modules/minimist/test/whitespace.js b/node_modules/minimist/test/whitespace.js[m
[1mnew file mode 100644[m
[1mindex 0000000..4fdaf1d[m
[1m--- /dev/null[m
[1m+++ b/node_modules/minimist/test/whitespace.js[m
[36m@@ -0,0 +1,10 @@[m
[32m+[m[32m'use strict';[m
[32m+[m
[32m+[m[32mvar parse = require('../');[m
[32m+[m[32mvar test = require('tape');[m
[32m+[m
[32m+[m[32mtest('whitespace should be whitespace', function (t) {[m
[32m+[m	[32mt.plan(1);[m
[32m+[m	[32mvar x = parse(['-x', '\t']).x;[m
[32m+[m	[32mt.equal(x, '\t');[m
[32m+[m[32m});[m
[1mdiff --git a/node_modules/mkdirp/LICENSE b/node_modules/mkdirp/LICENSE[m
[1mnew file mode 100644[m
[1mindex 0000000..432d1ae[m
[1m--- /dev/null[m
[1m+++ b/node_modules/mkdirp/LICENSE[m
[36m@@ -0,0 +1,21 @@[m
[32m+[m[32mCopyright 2010 James Halliday (mail@substack.net)[m
[32m+[m
[32m+[m[32mThis project is free software released under the MIT/X11 license:[m
[32m+[m
[32m+[m[32mPermission is hereby granted, free of charge, to any person obtaining a copy[m
[32m+[m[32mof this software and associated documentation files (the "Software"), to deal[m
[32m+[m[32min the Software without restriction, including without limitation the rights[m
[32m+[m[32mto use, copy, modify, merge, publish, distribute, sublicense, and/or sell[m
[32m+[m[32mcopies of the Software, and to permit persons to whom the Software is[m
[32m+[m[32mfurnished to do so, subject to the following conditions:[m
[32m+[m
[32m+[m[32mThe above copyright notice and this permission notice shall be included in[m
[32m+[m[32mall copies or substantial portions of the Software.[m
[32m+[m
[32m+[m[32mTHE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR[m
[32m+[m[32mIMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,[m
[32m+[m[32mFITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE[m
[32m+[m[32mAUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER[m
[32m+[m[32mLIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,[m
[32m+[m[32mOUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN[m
[32m+[m[32mTHE SOFTWARE.[m
[1mdiff --git a/node_modules/mkdirp/bin/cmd.js b/node_modules/mkdirp/bin/cmd.js[m
[1mnew file mode 100644[m
[1mindex 0000000..d95de15[m
[1m--- /dev/null[m
[1m+++ b/node_modules/mkdirp/bin/cmd.js[m
[36m@@ -0,0 +1,33 @@[m
[32m+[m[32m#!/usr/bin/env node[m
[32m+[m
[32m+[m[32mvar mkdirp = require('../');[m
[32m+[m[32mvar minimist = require('minimist');[m
[32m+[m[32mvar fs = require('fs');[m
[32m+[m
[32m+[m[32mvar argv = minimist(process.argv.slice(2), {[m
[32m+[m[32m    alias: { m: 'mode', h: 'help' },[m
[32m+[m[32m    string: [ 'mode' ][m
[32m+[m[32m});[m
[32m+[m[32mif (argv.help) {[m
[32m+[m[32m    fs.createReadStream(__dirname + '/usage.txt').pipe(process.stdout);[m
[32m+[m[32m    return;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mvar paths = argv._.slice();[m
[32m+[m[32mvar mode = argv.mode ? parseInt(argv.mode, 8) : undefined;[m
[32m+[m
[32m+[m[32m(function next () {[m
[32m+[m[32m    if (paths.length === 0) return;[m
[32m+[m[32m    var p = paths.shift();[m
[32m+[m[41m    [m
[32m+[m[32m    if (mode === undefined) mkdirp(p, cb)[m
[32m+[m[32m    else mkdirp(p, mode, cb)[m
[32m+[m[41m    [m
[32m+[m[32m    function cb (err) {[m
[32m+[m[32m        if (err) {[m
[32m+[m[32m            console.error(err.message);[m
[32m+[m[32m            process.exit(1);[m
[32m+[m[32m        }[m
[32m+[m[32m        else next();[m
[32m+[m[32m    }[m
[32m+[m[32m})();[m
[1mdiff --git a/node_modules/mkdirp/bin/usage.txt b/node_modules/mkdirp/bin/usage.txt[m
[1mnew file mode 100644[m
[1mindex 0000000..f952aa2[m
[1m--- /dev/null[m
[1m+++ b/node_modules/mkdirp/bin/usage.txt[m
[36m@@ -0,0 +1,12 @@[m
[32m+[m[32musage: mkdirp [DIR1,DIR2..] {OPTIONS}[m
[32m+[m
[32m+[m[32m  Create each supplied directory including any necessary parent directories that[m
[32m+[m[32m  don't yet exist.[m
[32m+[m[41m  [m
[32m+[m[32m  If the directory already exists, do nothing.[m
[32m+[m
[32m+[m[32mOPTIONS are:[m
[32m+[m
[32m+[m[32m  -m, --mode   If a directory needs to be created, set the mode as an octal[m
[32m+[m[32m               permission string.[m
[32m+[m
[1mdiff --git a/node_modules/mkdirp/index.js b/node_modules/mkdirp/index.js[m
[1mnew file mode 100644[m
[1mindex 0000000..0890ac3[m
[1m--- /dev/null[m
[1m+++ b/node_modules/mkdirp/index.js[m
[36m@@ -0,0 +1,102 @@[m
[32m+[m[32mvar path = require('path');[m
[32m+[m[32mvar fs = require('fs');[m
[32m+[m[32mvar _0777 = parseInt('0777', 8);[m
[32m+[m
[32m+[m[32mmodule.exports = mkdirP.mkdirp = mkdirP.mkdirP = mkdirP;[m
[32m+[m
[32m+[m[32mfunction mkdirP (p, opts, f, made) {[m
[32m+[m[32m    if (typeof opts === 'function') {[m
[32m+[m[32m        f = opts;[m
[32m+[m[32m        opts = {};[m
[32m+[m[32m    }[m
[32m+[m[32m    else if (!opts || typeof opts !== 'object') {[m
[32m+[m[32m        opts = { mode: opts };[m
[32m+[m[32m    }[m
[32m+[m[41m    [m
[32m+[m[32m    var mode = opts.mode;[m
[32m+[m[32m    var xfs = opts.fs || fs;[m
[32m+[m[41m    [m
[32m+[m[32m    if (mode === undefined) {[m
[32m+[m[32m        mode = _0777[m
[32m+[m[32m    }[m
[32m+[m[32m    if (!made) made = null;[m
[32m+[m[41m    [m
[32m+[m[32m    var cb = f || /* istanbul ignore next */ function () {};[m
[32m+[m[32m    p = path.resolve(p);[m
[32m+[m[41m    [m
[32m+[m[32m    xfs.mkdir(p, mode, function (er) {[m
[32m+[m[32m        if (!er) {[m
[32m+[m[32m            made = made || p;[m
[32m+[m[32m            return cb(null, made);[m
[32m+[m[32m        }[m
[32m+[m[32m        switch (er.code) {[m
[32m+[m[32m            case 'ENOENT':[m
[32m+[m[32m                /* istanbul ignore if */[m
[32m+[m[32m                if (path.dirname(p) === p) return cb(er);[m
[32m+[m[32m                mkdirP(path.dirname(p), opts, function (er, made) {[m
[32m+[m[32m                    /* istanbul ignore if */[m
[32m+[m[32m                    if (er) cb(er, made);[m
[32m+[m[32m                    else mkdirP(p, opts, cb, made);[m
[32m+[m[32m                });[m
[32m+[m[32m                break;[m
[32m+[m
[32m+[m[32m            // In the case of any other error, just see if there's a dir[m
[32m+[m[32m            // there already.  If so, then hooray!  If not, then something[m
[32m+[m[32m            // is borked.[m
[32m+[m[32m            default:[m
[32m+[m[32m                xfs.stat(p, function (er2, stat) {[m
[32m+[m[32m                    // if the stat fails, then that's super weird.[m
[32m+[m[32m                    // let the original error be the failure reason.[m
[32m+[m[32m                    if (er2 || !stat.isDirectory()) cb(er, made)[m
[32m+[m[32m                    else cb(null, made);[m
[32m+[m[32m                });[m
[32m+[m[32m                break;[m
[32m+[m[32m        }[m
[32m+[m[32m    });[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mmkdirP.sync = function sync (p, opts, made) {[m
[32m+[m[32m    if (!opts || typeof opts !== 'object') {[m
[32m+[m[32m        opts = { mode: opts };[m
[32m+[m[32m    }[m
[32m+[m[41m    [m
[32m+[m[32m    var mode = opts.mode;[m
[32m+[m[32m    var xfs = opts.fs || fs;[m
[32m+[m[41m    [m
[32m+[m[32m    if (mode === undefined) {[m
[32m+[m[32m        mode = _0777[m
[32m+[m[32m    }[m
[32m+[m[32m    if (!made) made = null;[m
[32m+[m
[32m+[m[32m    p = path.resolve(p);[m
[32m+[m
[32m+[m[32m    try {[m
[32m+[m[32m        xfs.mkdirSync(p, mode);[m
[32m+[m[32m        made = made || p;[m
[32m+[m[32m    }[m
[32m+[m[32m    catch (err0) {[m
[32m+[m[32m        switch (err0.code) {[m
[32m+[m[32m            case 'ENOENT' :[m
[32m+[m[32m                made = sync(path.dirname(p), opts, made);[m
[32m+[m[32m                sync(p, opts, made);[m
[32m+[m[32m                break;[m
[32m+[m
[32m+[m[32m            // In the case of any other error, just see if there's a dir[m
[32m+[m[32m            // there already.  If so, then hooray!  If not, then something[m
[32m+[m[32m            // is borked.[m
[32m+[m[32m            default:[m
[32m+[m[32m                var stat;[m
[32m+[m[32m                try {[m
[32m+[m[32m                    stat = xfs.statSync(p);[m
[32m+[m[32m                }[m
[32m+[m[32m                catch (err1) /* istanbul ignore next */ {[m
[32m+[m[32m                    throw err0;[m
[32m+[m[32m                }[m
[32m+[m[32m                /* istanbul ignore if */[m
[32m+[m[32m                if (!stat.isDirectory()) throw err0;[m
[32m+[m[32m                break;[m
[32m+[m[32m        }[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    return made;[m
[32m+[m[32m};[m
[1mdiff --git a/node_modules/mkdirp/package.json b/node_modules/mkdirp/package.json[m
[1mnew file mode 100644[m
[1mindex 0000000..951e58d[m
[1m--- /dev/null[m
[1m+++ b/node_modules/mkdirp/package.json[m
[36m@@ -0,0 +1,33 @@[m
[32m+[m[32m{[m
[32m+[m[32m  "name": "mkdirp",[m
[32m+[m[32m  "description": "Recursively mkdir, like `mkdir -p`",[m
[32m+[m[32m  "version": "0.5.6",[m
[32m+[m[32m  "publishConfig": {[m
[32m+[m[32m    "tag": "legacy"[m
[32m+[m[32m  },[m
[32m+[m[32m  "author": "James Halliday <mail@substack.net> (http://substack.net)",[m
[32m+[m[32m  "main": "index.js",[m
[32m+[m[32m  "keywords": [[m
[32m+[m[32m    "mkdir",[m
[32m+[m[32m    "directory"[m
[32m+[m[32m  ],[m
[32m+[m[32m  "repository": {[m
[32m+[m[32m    "type": "git",[m
[32m+[m[32m    "url": "https://github.com/substack/node-mkdirp.git"[m
[32m+[m[32m  },[m
[32m+[m[32m  "scripts": {[m
[32m+[m[32m    "test": "tap test/*.js"[m
[32m+[m[32m  },[m
[32m+[m[32m  "dependencies": {[m
[32m+[m[32m    "minimist": "^1.2.6"[m
[32m+[m[32m  },[m
[32m+[m[32m  "devDependencies": {[m
[32m+[m[32m    "tap": "^16.0.1"[m
[32m+[m[32m  },[m
[32m+[m[32m  "bin": "bin/cmd.js",[m
[32m+[m[32m  "license": "MIT",[m
[32m+[m[32m  "files": [[m
[32m+[m[32m    "bin",[m
[32m+[m[32m    "index.js"[m
[32m+[m[32m  ][m
[32m+[m[32m}[m
[1mdiff --git a/node_modules/mkdirp/readme.markdown b/node_modules/mkdirp/readme.markdown[m
[1mnew file mode 100644[m
[1mindex 0000000..fc314bf[m
[1m--- /dev/null[m
[1m+++ b/node_modules/mkdirp/readme.markdown[m
[36m@@ -0,0 +1,100 @@[m
[32m+[m[32m# mkdirp[m
[32m+[m
[32m+[m[32mLike `mkdir -p`, but in node.js![m
[32m+[m
[32m+[m[32m[![build status](https://secure.travis-ci.org/substack/node-mkdirp.png)](http://travis-ci.org/substack/node-mkdirp)[m
[32m+[m
[32m+[m[32m# example[m
[32m+[m
[32m+[m[32m## pow.js[m
[32m+[m
[32m+[m[32m```js[m
[32m+[m[32mvar mkdirp = require('mkdirp');[m
[32m+[m[41m    [m
[32m+[m[32mmkdirp('/tmp/foo/bar/baz', function (err) {[m
[32m+[m[32m    if (err) console.error(err)[m
[32m+[m[32m    else console.log('pow!')[m
[32m+[m[32m});[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32mOutput[m
[32m+[m
[32m+[m[32m```[m
[32m+[m[32mpow![m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32mAnd now /tmp/foo/bar/baz exists, huzzah![m
[32m+[m
[32m+[m[32m# methods[m
[32m+[m
[32m+[m[32m```js[m
[32m+[m[32mvar mkdirp = require('mkdirp');[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32m## mkdirp(dir, opts, cb)[m
[32m+[m
[32m+[m[32mCreate a new directory and any necessary subdirectories at `dir` with octal[m
[32m+[m[32mpermission string `opts.mode`. If `opts` is a non-object, it will be treated as[m
[32m+[m[32mthe `opts.mode`.[m
[32m+[m
[32m+[m[32mIf `opts.mode` isn't specified, it defaults to `0777`.[m
[32m+[m
[32m+[m[32m`cb(err, made)` fires with the error or the first directory `made`[m
[32m+[m[32mthat had to be created, if any.[m
[32m+[m
[32m+[m[32mYou can optionally pass in an alternate `fs` implementation by passing in[m
[32m+[m[32m`opts.fs`. Your implementation should have `opts.fs.mkdir(path, mode, cb)` and[m
[32m+[m[32m`opts.fs.stat(path, cb)`.[m
[32m+[m
[32m+[m[32m## mkdirp.sync(dir, opts)[m
[32m+[m
[32m+[m[32mSynchronously create a new directory and any necessary subdirectories at `dir`[m
[32m+[m[32mwith octal permission string `opts.mode`. If `opts` is a non-object, it will be[m
[32m+[m[32mtreated as the `opts.mode`.[m
[32m+[m
[32m+[m[32mIf `opts.mode` isn't specified, it defaults to `0777`.[m
[32m+[m
[32m+[m[32mReturns the first directory that had to be created, if any.[m
[32m+[m
[32m+[m[32mYou can optionally pass in an alternate `fs` implementation by passing in[m
[32m+[m[32m`opts.fs`. Your implementation should have `opts.fs.mkdirSync(path, mode)` and[m
[32m+[m[32m`opts.fs.statSync(path)`.[m
[32m+[m
[32m+[m[32m# usage[m
[32m+[m
[32m+[m[32mThis package also ships with a `mkdirp` command.[m
[32m+[m
[32m+[m[32m```[m
[32m+[m[32musage: mkdirp [DIR1,DIR2..] {OPTIONS}[m
[32m+[m
[32m+[m[32m  Create each supplied directory including any necessary parent directories that[m
[32m+[m[32m  don't yet exist.[m
[32m+[m[41m  [m
[32m+[m[32m  If the directory already exists, do nothing.[m
[32m+[m
[32m+[m[32mOPTIONS are:[m
[32m+[m
[32m+[m[32m  -m, --mode   If a directory needs to be created, set the mode as an octal[m
[32m+[m[32m               permission string.[m
[32m+[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32m# install[m
[32m+[m
[32m+[m[32mWith [npm](http://npmjs.org) do:[m
[32m+[m
[32m+[m[32m```[m
[32m+[m[32mnpm install mkdirp[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32mto get the library, or[m
[32m+[m
[32m+[m[32m```[m
[32m+[m[32mnpm install -g mkdirp[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32mto get the command.[m
[32m+[m
[32m+[m[32m# license[m
[32m+[m
[32m+[m[32mMIT[m
[1mdiff --git a/node_modules/multer/LICENSE b/node_modules/multer/LICENSE[m
[1mnew file mode 100644[m
[1mindex 0000000..6c011b1[m
[1m--- /dev/null[m
[1m+++ b/node_modules/multer/LICENSE[m
[36m@@ -0,0 +1,17 @@[m
[32m+[m[32mCopyright (c) 2014 Hage Yaapa <[http://www.hacksparrow.com](http://www.hacksparrow.com)>[m
[32m+[m
[32m+[m[32mPermission is hereby granted, free of charge, to any person obtaining a copy[m
[32m+[m[32mof this software and associated documentation files (the "Software"), to deal[m
[32m+[m[32min the Software without restriction, including without limitation the rights[m
[32m+[m[32mto use, copy, modify, merge, publish, distribute, sublicense, and/or sell[m
[32m+[m[32mcopies of the Software, and to permit persons to whom the Software is[m
[32m+[m[32mfurnished to do so, subject to the following conditions:[m
[32m+[m
[32m+[m[32mThe above copyright notice and this permission notice shall be included in[m
[32m+[m[32mall copies or substantial portions of the Software.[m
[32m+[m
[32m+[m[32mTHE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR[m
[32m+[m[32mIMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,[m
[32m+[m[32mFITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE[m
[32m+[m[32mAUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER[m
[32m+[m[32mLIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.[m
[1mdiff --git a/node_modules/multer/README.md b/node_modules/multer/README.md[m
[1mnew file mode 100644[m
[1mindex 0000000..7f5d080[m
[1m--- /dev/null[m
[1m+++ b/node_modules/multer/README.md[m
[36m@@ -0,0 +1,333 @@[m
[32m+[m[32m# Multer [![Build Status](https://travis-ci.org/expressjs/multer.svg?branch=master)](https://travis-ci.org/expressjs/multer) [![NPM version](https://badge.fury.io/js/multer.svg)](https://badge.fury.io/js/multer) [![js-standard-style](https://img.shields.io/badge/code%20style-standard-brightgreen.svg?style=flat)](https://github.com/feross/standard)[m
[32m+[m
[32m+[m[32mMulter is a node.js middleware for handling `multipart/form-data`, which is primarily used for uploading files. It is written[m
[32m+[m[32mon top of [busboy](https://github.com/mscdex/busboy) for maximum efficiency.[m
[32m+[m
[32m+[m[32m**NOTE**: Multer will not process any form which is not multipart (`multipart/form-data`).[m
[32m+[m
[32m+[m[32m## Translations[m[41m [m
[32m+[m
[32m+[m[32mThis README is also available in other languages:[m
[32m+[m
[32m+[m[32m- [Español](https://github.com/expressjs/multer/blob/master/doc/README-es.md) (Spanish)[m
[32m+[m[32m- [简体中文](https://github.com/expressjs/multer/blob/master/doc/README-zh-cn.md) (Chinese)[m
[32m+[m[32m- [한국어](https://github.com/expressjs/multer/blob/master/doc/README-ko.md) (Korean)[m
[32m+[m[32m- [Русский язык](https://github.com/expressjs/multer/blob/master/doc/README-ru.md) (Russian)[m
[32m+[m[32m- [Việt Nam](https://github.com/expressjs/multer/blob/master/doc/README-vi.md) (Vietnam)[m
[32m+[m[32m- [Português](https://github.com/expressjs/multer/blob/master/doc/README-pt-br.md) (Portuguese Brazil)[m
[32m+[m
[32m+[m[32m## Installation[m
[32m+[m
[32m+[m[32m```sh[m
[32m+[m[32m$ npm install --save multer[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32m## Usage[m
[32m+[m
[32m+[m[32mMulter adds a `body` object and a `file` or `files` object to the `request` object. The `body` object contains the values of the text fields of the form, the `file` or `files` object contains the files uploaded via the form.[m
[32m+[m
[32m+[m[32mBasic usage example:[m
[32m+[m
[32m+[m[32mDon't forget the `enctype="multipart/form-data"` in your form.[m
[32m+[m
[32m+[m[32m```html[m
[32m+[m[32m<form action="/profile" method="post" enctype="multipart/form-data">[m
[32m+[m[32m  <input type="file" name="avatar" />[m
[32m+[m[32m</form>[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32m```javascript[m
[32m+[m[32mconst express = require('express')[m
[32m+[m[32mconst multer  = require('multer')[m
[32m+[m[32mconst upload = multer({ dest: 'uploads/' })[m
[32m+[m
[32m+[m[32mconst app = express()[m
[32m+[m
[32m+[m[32mapp.post('/profile', upload.single('avatar'), function (req, res, next) {[m
[32m+[m[32m  // req.file is the `avatar` file[m
[32m+[m[32m  // req.body will hold the text fields, if there were any[m
[32m+[m[32m})[m
[32m+[m
[32m+[m[32mapp.post('/photos/upload', upload.array('photos', 12), function (req, res, next) {[m
[32m+[m[32m  // req.files is array of `photos` files[m
[32m+[m[32m  // req.body will contain the text fields, if there were any[m
[32m+[m[32m})[m
[32m+[m
[32m+[m[32mconst cpUpload = upload.fields([{ name: 'avatar', maxCount: 1 }, { name: 'gallery', maxCount: 8 }])[m
[32m+[m[32mapp.post('/cool-profile', cpUpload, function (req, res, next) {[m
[32m+[m[32m  // req.files is an object (String -> Array) where fieldname is the key, and the value is array of files[m
[32m+[m[32m  //[m
[32m+[m[32m  // e.g.[m
[32m+[m[32m  //  req.files['avatar'][0] -> File[m
[32m+[m[32m  //  req.files['gallery'] -> Array[m
[32m+[m[32m  //[m
[32m+[m[32m  // req.body will contain the text fields, if there were any[m
[32m+[m[32m})[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32mIn case you need to handle a text-only multipart form, you should use the `.none()` method:[m
[32m+[m
[32m+[m[32m```javascript[m
[32m+[m[32mconst express = require('express')[m
[32m+[m[32mconst app = express()[m
[32m+[m[32mconst multer  = require('multer')[m
[32m+[m[32mconst upload = multer()[m
[32m+[m
[32m+[m[32mapp.post('/profile', upload.none(), function (req, res, next) {[m
[32m+[m[32m  // req.body contains the text fields[m
[32m+[m[32m})[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32mHere's an example on how multer is used an HTML form. Take special note of the `enctype="multipart/form-data"` and `name="uploaded_file"` fields:[m
[32m+[m
[32m+[m[32m```html[m
[32m+[m[32m<form action="/stats" enctype="multipart/form-data" method="post">[m
[32m+[m[32m  <div class="form-group">[m
[32m+[m[32m    <input type="file" class="form-control-file" name="uploaded_file">[m
[32m+[m[32m    <input type="text" class="form-control" placeholder="Number of speakers" name="nspeakers">[m
[32m+[m[32m    <input type="submit" value="Get me the stats!" class="btn btn-default">[m[41m            [m
[32m+[m[32m  </div>[m
[32m+[m[32m</form>[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32mThen in your javascript file you would add these lines to access both the file and the body. It is important that you use the `name` field value from the form in your upload function. This tells multer which field on the request it should look for the files in. If these fields aren't the same in the HTML form and on your server, your upload will fail:[m
[32m+[m
[32m+[m[32m```javascript[m
[32m+[m[32mconst multer  = require('multer')[m
[32m+[m[32mconst upload = multer({ dest: './public/data/uploads/' })[m
[32m+[m[32mapp.post('/stats', upload.single('uploaded_file'), function (req, res) {[m
[32m+[m[32m   // req.file is the name of your file in the form above, here 'uploaded_file'[m
[32m+[m[32m   // req.body will hold the text fields, if there were any[m[41m [m
[32m+[m[32m   console.log(req.file, req.body)[m
[32m+[m[32m});[m
[32m+[m[32m```[m
[32m+[m
[32m+[m
[32m+[m
[32m+[m[32m## API[m
[32m+[m
[32m+[m[32m### File information[m
[32m+[m
[32m+[m[32mEach file contains the following information:[m
[32m+[m
[32m+[m[32mKey | Description | Note[m
[32m+[m[32m--- | --- | ---[m
[32m+[m[32m`fieldname` | Field name specified in the form |[m
[32m+[m[32m`originalname` | Name of the file on the user's computer |[m
[32m+[m[32m`encoding` | Encoding type of the file |[m
[32m+[m[32m`mimetype` | Mime type of the file |[m
[32m+[m[32m`size` | Size of the file in bytes |[m
[32m+[m[32m`destination` | The folder to which the file has been saved | `DiskStorage`[m
[32m+[m[32m`filename` | The name of the file within the `destination` | `DiskStorage`[m
[32m+[m[32m`path` | The full path to the uploaded file | `DiskStorage`[m
[32m+[m[32m`buffer` | A `Buffer` of the entire file | `MemoryStorage`[m
[32m+[m
[32m+[m[32m### `multer(opts)`[m
[32m+[m
[32m+[m[32mMulter accepts an options object, the most basic of which is the `dest`[m
[32m+[m[32mproperty, which tells Multer where to upload the files. In case you omit the[m
[32m+[m[32moptions object, the files will be kept in memory and never written to disk.[m
[32m+[m
[32m+[m[32mBy default, Multer will rename the files so as to avoid naming conflicts. The[m
[32m+[m[32mrenaming function can be customized according to your needs.[m
[32m+[m
[32m+[m[32mThe following are the options that can be passed to Multer.[m
[32m+[m
[32m+[m[32mKey | Description[m
[32m+[m[32m--- | ---[m
[32m+[m[32m`dest` or `storage` | Where to store the files[m
[32m+[m[32m`fileFilter` | Function to control which files are accepted[m
[32m+[m[32m`limits` | Limits of the uploaded data[m
[32m+[m[32m`preservePath` | Keep the full path of files instead of just the base name[m
[32m+[m
[32m+[m[32mIn an average web app, only `dest` might be required, and configured as shown in[m
[32m+[m[32mthe following example.[m
[32m+[m
[32m+[m[32m```javascript[m
[32m+[m[32mconst upload = multer({ dest: 'uploads/' })[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32mIf you want more control over your uploads, you'll want to use the `storage`[m
[32m+[m[32moption instead of `dest`. Multer ships with storage engines `DiskStorage`[m
[32m+[m[32mand `MemoryStorage`; More engines are available from third parties.[m
[32m+[m
[32m+[m[32m#### `.single(fieldname)`[m
[32m+[m
[32m+[m[32mAccept a single file with the name `fieldname`. The single file will be stored[m
[32m+[m[32min `req.file`.[m
[32m+[m
[32m+[m[32m#### `.array(fieldname[, maxCount])`[m
[32m+[m
[32m+[m[32mAccept an array of files, all with the name `fieldname`. Optionally error out if[m
[32m+[m[32mmore than `maxCount` files are uploaded. The array of files will be stored in[m
[32m+[m[32m`req.files`.[m
[32m+[m
[32m+[m[32m#### `.fields(fields)`[m
[32m+[m
[32m+[m[32mAccept a mix of files, specified by `fields`. An object with arrays of files[m
[32m+[m[32mwill be stored in `req.files`.[m
[32m+[m
[32m+[m[32m`fields` should be an array of objects with `name` and optionally a `maxCount`.[m
[32m+[m[32mExample:[m
[32m+[m
[32m+[m[32m```javascript[m
[32m+[m[32m[[m
[32m+[m[32m  { name: 'avatar', maxCount: 1 },[m
[32m+[m[32m  { name: 'gallery', maxCount: 8 }[m
[32m+[m[32m][m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32m#### `.none()`[m
[32m+[m
[32m+[m[32mAccept only text fields. If any file upload is made, error with code[m
[32m+[m[32m"LIMIT\_UNEXPECTED\_FILE" will be issued.[m
[32m+[m
[32m+[m[32m#### `.any()`[m
[32m+[m
[32m+[m[32mAccepts all files that comes over the wire. An array of files will be stored in[m
[32m+[m[32m`req.files`.[m
[32m+[m
[32m+[m[32m**WARNING:** Make sure that you always handle the files that a user uploads.[m
[32m+[m[32mNever add multer as a global middleware since a malicious user could upload[m
[32m+[m[32mfiles to a route that you didn't anticipate. Only use this function on routes[m
[32m+[m[32mwhere you are handling the uploaded files.[m
[32m+[m
[32m+[m[32m### `storage`[m
[32m+[m
[32m+[m[32m#### `DiskStorage`[m
[32m+[m
[32m+[m[32mThe disk storage engine gives you full control on storing files to disk.[m
[32m+[m
[32m+[m[32m```javascript[m
[32m+[m[32mconst storage = multer.diskStorage({[m
[32m+[m[32m  destination: function (req, file, cb) {[m
[32m+[m[32m    cb(null, '/tmp/my-uploads')[m
[32m+[m[32m  },[m
[32m+[m[32m  filename: function (req, file, cb) {[m
[32m+[m[32m    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9)[m
[32m+[m[32m    cb(null, file.fieldname + '-' + uniqueSuffix)[m
[32m+[m[32m  }[m
[32m+[m[32m})[m
[32m+[m
[32m+[m[32mconst upload = multer({ storage: storage })[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32mThere are two options available, `destination` and `filename`. They are both[m
[32m+[m[32mfunctions that determine where the file should be stored.[m
[32m+[m
[32m+[m[32m`destination` is used to determine within which folder the uploaded files should[m
[32m+[m[32mbe stored. This can also be given as a `string` (e.g. `'/tmp/uploads'`). If no[m
[32m+[m[32m`destination` is given, the operating system's default directory for temporary[m
[32m+[m[32mfiles is used.[m
[32m+[m
[32m+[m[32m**Note:** You are responsible for creating the directory when providing[m
[32m+[m[32m`destination` as a function. When passing a string, multer will make sure that[m
[32m+[m[32mthe directory is created for you.[m
[32m+[m
[32m+[m[32m`filename` is used to determine what the file should be named inside the folder.[m
[32m+[m[32mIf no `filename` is given, each file will be given a random name that doesn't[m
[32m+[m[32minclude any file extension.[m
[32m+[m
[32m+[m[32m**Note:** Multer will not append any file extension for you, your function[m
[32m+[m[32mshould return a filename complete with an file extension.[m
[32m+[m
[32m+[m[32mEach function gets passed both the request (`req`) and some information about[m
[32m+[m[32mthe file (`file`) to aid with the decision.[m
[32m+[m
[32m+[m[32mNote that `req.body` might not have been fully populated yet. It depends on the[m
[32m+[m[32morder that the client transmits fields and files to the server.[m
[32m+[m
[32m+[m[32mFor understanding the calling convention used in the callback (needing to pass[m
[32m+[m[32mnull as the first param), refer to[m
[32m+[m[32m[Node.js error handling](https://www.joyent.com/node-js/production/design/errors)[m
[32m+[m
[32m+[m[32m#### `MemoryStorage`[m
[32m+[m
[32m+[m[32mThe memory storage engine stores the files in memory as `Buffer` objects. It[m
[32m+[m[32mdoesn't have any options.[m
[32m+[m
[32m+[m[32m```javascript[m
[32m+[m[32mconst storage = multer.memoryStorage()[m
[32m+[m[32mconst upload = multer({ storage: storage })[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32mWhen using memory storage, the file info will contain a field called[m
[32m+[m[32m`buffer` that contains the entire file.[m
[32m+[m
[32m+[m[32m**WARNING**: Uploading very large files, or relatively small files in large[m
[32m+[m[32mnumbers very quickly, can cause your application to run out of memory when[m
[32m+[m[32mmemory storage is used.[m
[32m+[m
[32m+[m[32m### `limits`[m
[32m+[m
[32m+[m[32mAn object specifying the size limits of the following optional properties. Multer passes this object into busboy directly, and the details of the properties can be found on [busboy's page](https://github.com/mscdex/busboy#busboy-methods).[m
[32m+[m
[32m+[m[32mThe following integer values are available:[m
[32m+[m
[32m+[m[32mKey | Description | Default[m
[32m+[m[32m--- | --- | ---[m
[32m+[m[32m`fieldNameSize` | Max field name size | 100 bytes[m
[32m+[m[32m`fieldSize` | Max field value size (in bytes) | 1MB[m
[32m+[m[32m`fields` | Max number of non-file fields | Infinity[m
[32m+[m[32m`fileSize` | For multipart forms, the max file size (in bytes) | Infinity[m
[32m+[m[32m`files` | For multipart forms, the max number of file fields | Infinity[m
[32m+[m[32m`parts` | For multipart forms, the max number of parts (fields + files) | Infinity[m
[32m+[m[32m`headerPairs` | For multipart forms, the max number of header key=>value pairs to parse | 2000[m
[32m+[m
[32m+[m[32mSpecifying the limits can help protect your site against denial of service (DoS) attacks.[m
[32m+[m
[32m+[m[32m### `fileFilter`[m
[32m+[m
[32m+[m[32mSet this to a function to control which files should be uploaded and which[m
[32m+[m[32mshould be skipped. The function should look like this:[m
[32m+[m
[32m+[m[32m```javascript[m
[32m+[m[32mfunction fileFilter (req, file, cb) {[m
[32m+[m
[32m+[m[32m  // The function should call `cb` with a boolean[m
[32m+[m[32m  // to indicate if the file should be accepted[m
[32m+[m
[32m+[m[32m  // To reject this file pass `false`, like so:[m
[32m+[m[32m  cb(null, false)[m
[32m+[m
[32m+[m[32m  // To accept the file pass `true`, like so:[m
[32m+[m[32m  cb(null, true)[m
[32m+[m
[32m+[m[32m  // You can always pass an error if something goes wrong:[m
[32m+[m[32m  cb(new Error('I don\'t have a clue!'))[m
[32m+[m
[32m+[m[32m}[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32m## Error handling[m
[32m+[m
[32m+[m[32mWhen encountering an error, Multer will delegate the error to Express. You can[m
[32m+[m[32mdisplay a nice error page using [the standard express way](http://expressjs.com/guide/error-handling.html).[m
[32m+[m
[32m+[m[32mIf you want to catch errors specifically from Multer, you can call the[m
[32m+[m[32mmiddleware function by yourself. Also, if you want to catch only [the Multer errors](https://github.com/expressjs/multer/blob/master/lib/multer-error.js), you can use the `MulterError` class that is attached to the `multer` object itself (e.g. `err instanceof multer.MulterError`).[m
[32m+[m
[32m+[m[32m```javascript[m
[32m+[m[32mconst multer = require('multer')[m
[32m+[m[32mconst upload = multer().single('avatar')[m
[32m+[m
[32m+[m[32mapp.post('/profile', function (req, res) {[m
[32m+[m[32m  upload(req, res, function (err) {[m
[32m+[m[32m    if (err instanceof multer.MulterError) {[m
[32m+[m[32m      // A Multer error occurred when uploading.[m
[32m+[m[32m    } else if (err) {[m
[32m+[m[32m      // An unknown error occurred when uploading.[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    // Everything went fine.[m
[32m+[m[32m  })[m
[32m+[m[32m})[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32m## Custom storage engine[m
[32m+[m
[32m+[m[32mFor information on how to build your own storage engine, see [Multer Storage Engine](https://github.com/expressjs/multer/blob/master/StorageEngine.md).[m
[32m+[m
[32m+[m[32m## License[m
[32m+[m
[32m+[m[32m[MIT](LICENSE)[m
[1mdiff --git a/node_modules/multer/index.js b/node_modules/multer/index.js[m
[1mnew file mode 100644[m
[1mindex 0000000..d5b67eb[m
[1m--- /dev/null[m
[1m+++ b/node_modules/multer/index.js[m
[36m@@ -0,0 +1,104 @@[m
[32m+[m[32mvar makeMiddleware = require('./lib/make-middleware')[m
[32m+[m
[32m+[m[32mvar diskStorage = require('./storage/disk')[m
[32m+[m[32mvar memoryStorage = require('./storage/memory')[m
[32m+[m[32mvar MulterError = require('./lib/multer-error')[m
[32m+[m
[32m+[m[32mfunction allowAll (req, file, cb) {[m
[32m+[m[32m  cb(null, true)[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction Multer (options) {[m
[32m+[m[32m  if (options.storage) {[m
[32m+[m[32m    this.storage = options.storage[m
[32m+[m[32m  } else if (options.dest) {[m
[32m+[m[32m    this.storage = diskStorage({ destination: options.dest })[m
[32m+[m[32m  } else {[m
[32m+[m[32m    this.storage = memoryStorage()[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  this.limits = options.limits[m
[32m+[m[32m  this.preservePath = options.preservePath[m
[32m+[m[32m  this.fileFilter = options.fileFilter || allowAll[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mMulter.prototype._makeMiddleware = function (fields, fileStrategy) {[m
[32m+[m[32m  function setup () {[m
[32m+[m[32m    var fileFilter = this.fileFilter[m
[32m+[m[32m    var filesLeft = Object.create(null)[m
[32m+[m
[32m+[m[32m    fields.forEach(function (field) {[m
[32m+[m[32m      if (typeof field.maxCount === 'number') {[m
[32m+[m[32m        filesLeft[field.name] = field.maxCount[m
[32m+[m[32m      } else {[m
[32m+[m[32m        filesLeft[field.name] = Infinity[m
[32m+[m[32m      }[m
[32m+[m[32m    })[m
[32m+[m
[32m+[m[32m    function wrappedFileFilter (req, file, cb) {[m
[32m+[m[32m      if ((filesLeft[file.fieldname] || 0) <= 0) {[m
[32m+[m[32m        return cb(new MulterError('LIMIT_UNEXPECTED_FILE', file.fieldname))[m
[32m+[m[32m      }[m
[32m+[m
[32m+[m[32m      filesLeft[file.fieldname] -= 1[m
[32m+[m[32m      fileFilter(req, file, cb)[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    return {[m
[32m+[m[32m      limits: this.limits,[m
[32m+[m[32m      preservePath: this.preservePath,[m
[32m+[m[32m      storage: this.storage,[m
[32m+[m[32m      fileFilter: wrappedFileFilter,[m
[32m+[m[32m      fileStrategy: fileStrategy[m
[32m+[m[32m    }[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  return makeMiddleware(setup.bind(this))[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mMulter.prototype.single = function (name) {[m
[32m+[m[32m  return this._makeMiddleware([{ name: name, maxCount: 1 }], 'VALUE')[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mMulter.prototype.array = function (name, maxCount) {[m
[32m+[m[32m  return this._makeMiddleware([{ name: name, maxCount: maxCount }], 'ARRAY')[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mMulter.prototype.fields = function (fields) {[m
[32m+[m[32m  return this._makeMiddleware(fields, 'OBJECT')[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mMulter.prototype.none = function () {[m
[32m+[m[32m  return this._makeMiddleware([], 'NONE')[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mMulter.prototype.any = function () {[m
[32m+[m[32m  function setup () {[m
[32m+[m[32m    return {[m
[32m+[m[32m      limits: this.limits,[m
[32m+[m[32m      preservePath: this.preservePath,[m
[32m+[m[32m      storage: this.storage,[m
[32m+[m[32m      fileFilter: this.fileFilter,[m
[32m+[m[32m      fileStrategy: 'ARRAY'[m
[32m+[m[32m    }[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  return makeMiddleware(setup.bind(this))[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction multer (options) {[m
[32m+[m[32m  if (options === undefined) {[m
[32m+[m[32m    return new Multer({})[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  if (typeof options === 'object' && options !== null) {[m
[32m+[m[32m    return new Multer(options)[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  throw new TypeError('Expected object for argument options')[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mmodule.exports = multer[m
[32m+[m[32mmodule.exports.diskStorage = diskStorage[m
[32m+[m[32mmodule.exports.memoryStorage = memoryStorage[m
[32m+[m[32mmodule.exports.MulterError = MulterError[m
[1mdiff --git a/node_modules/multer/lib/counter.js b/node_modules/multer/lib/counter.js[m
[1mnew file mode 100644[m
[1mindex 0000000..29c410c[m
[1m--- /dev/null[m
[1m+++ b/node_modules/multer/lib/counter.js[m
[36m@@ -0,0 +1,28 @@[m
[32m+[m[32mvar EventEmitter = require('events').EventEmitter[m
[32m+[m
[32m+[m[32mfunction Counter () {[m
[32m+[m[32m  EventEmitter.call(this)[m
[32m+[m[32m  this.value = 0[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mCounter.prototype = Object.create(EventEmitter.prototype)[m
[32m+[m
[32m+[m[32mCounter.prototype.increment = function increment () {[m
[32m+[m[32m  this.value++[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mCounter.prototype.decrement = function decrement () {[m
[32m+[m[32m  if (--this.value === 0) this.emit('zero')[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mCounter.prototype.isZero = function isZero () {[m
[32m+[m[32m  return (this.value === 0)[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mCounter.prototype.onceZero = function onceZero (fn) {[m
[32m+[m[32m  if (this.isZero()) return fn()[m
[32m+[m
[32m+[m[32m  this.once('zero', fn)[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mmodule.exports = Counter[m
[1mdiff --git a/node_modules/multer/lib/file-appender.js b/node_modules/multer/lib/file-appender.js[m
[1mnew file mode 100644[m
[1mindex 0000000..1a2c5e7[m
[1m--- /dev/null[m
[1m+++ b/node_modules/multer/lib/file-appender.js[m
[36m@@ -0,0 +1,67 @@[m
[32m+[m[32mvar objectAssign = require('object-assign')[m
[32m+[m
[32m+[m[32mfunction arrayRemove (arr, item) {[m
[32m+[m[32m  var idx = arr.indexOf(item)[m
[32m+[m[32m  if (~idx) arr.splice(idx, 1)[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction FileAppender (strategy, req) {[m
[32m+[m[32m  this.strategy = strategy[m
[32m+[m[32m  this.req = req[m
[32m+[m
[32m+[m[32m  switch (strategy) {[m
[32m+[m[32m    case 'NONE': break[m
[32m+[m[32m    case 'VALUE': break[m
[32m+[m[32m    case 'ARRAY': req.files = []; break[m
[32m+[m[32m    case 'OBJECT': req.files = Object.create(null); break[m
[32m+[m[32m    default: throw new Error('Unknown file strategy: ' + strategy)[m
[32m+[m[32m  }[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mFileAppender.prototype.insertPlaceholder = function (file) {[m
[32m+[m[32m  var placeholder = {[m
[32m+[m[32m    fieldname: file.fieldname[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  switch (this.strategy) {[m
[32m+[m[32m    case 'NONE': break[m
[32m+[m[32m    case 'VALUE': break[m
[32m+[m[32m    case 'ARRAY': this.req.files.push(placeholder); break[m
[32m+[m[32m    case 'OBJECT':[m
[32m+[m[32m      if (this.req.files[file.fieldname]) {[m
[32m+[m[32m        this.req.files[file.fieldname].push(placeholder)[m
[32m+[m[32m      } else {[m
[32m+[m[32m        this.req.files[file.fieldname] = [placeholder][m
[32m+[m[32m      }[m
[32m+[m[32m      break[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  return placeholder[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mFileAppender.prototype.removePlaceholder = function (placeholder) {[m
[32m+[m[32m  switch (this.strategy) {[m
[32m+[m[32m    case 'NONE': break[m
[32m+[m[32m    case 'VALUE': break[m
[32m+[m[32m    case 'ARRAY': arrayRemove(this.req.files, placeholder); break[m
[32m+[m[32m    case 'OBJECT':[m
[32m+[m[32m      if (this.req.files[placeholder.fieldname].length === 1) {[m
[32m+[m[32m        delete this.req.files[placeholder.fieldname][m
[32m+[m[32m      } else {[m
[32m+[m[32m        arrayRemove(this.req.files[placeholder.fieldname], placeholder)[m
[32m+[m[32m      }[m
[32m+[m[32m      break[m
[32m+[m[32m  }[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mFileAppender.prototype.replacePlaceholder = function (placeholder, file) {[m
[32m+[m[32m  if (this.strategy === 'VALUE') {[m
[32m+[m[32m    this.req.file = file[m
[32m+[m[32m    return[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  delete placeholder.fieldname[m
[32m+[m[32m  objectAssign(placeholder, file)[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mmodule.exports = FileAppender[m
[1mdiff --git a/node_modules/multer/lib/make-middleware.js b/node_modules/multer/lib/make-middleware.js[m
[1mnew file mode 100644[m
[1mindex 0000000..6627cf4[m
[1m--- /dev/null[m
[1m+++ b/node_modules/multer/lib/make-middleware.js[m
[36m@@ -0,0 +1,173 @@[m
[32m+[m[32mvar is = require('type-is')[m
[32m+[m[32mvar Busboy = require('busboy')[m
[32m+[m[32mvar extend = require('xtend')[m
[32m+[m[32mvar appendField = require('append-field')[m
[32m+[m
[32m+[m[32mvar Counter = require('./counter')[m
[32m+[m[32mvar MulterError = require('./multer-error')[m
[32m+[m[32mvar FileAppender = require('./file-appender')[m
[32m+[m[32mvar removeUploadedFiles = require('./remove-uploaded-files')[m
[32m+[m
[32m+[m[32mfunction makeMiddleware (setup) {[m
[32m+[m[32m  return function multerMiddleware (req, res, next) {[m
[32m+[m[32m    if (!is(req, ['multipart'])) return next()[m
[32m+[m
[32m+[m[32m    var options = setup()[m
[32m+[m
[32m+[m[32m    var limits = options.limits[m
[32m+[m[32m    var storage = options.storage[m
[32m+[m[32m    var fileFilter = options.fileFilter[m
[32m+[m[32m    var fileStrategy = options.fileStrategy[m
[32m+[m[32m    var preservePath = options.preservePath[m
[32m+[m
[32m+[m[32m    req.body = Object.create(null)[m
[32m+[m
[32m+[m[32m    var busboy[m
[32m+[m
[32m+[m[32m    try {[m
[32m+[m[32m      busboy = Busboy({ headers: req.headers, limits: limits, preservePath: preservePath })[m
[32m+[m[32m    } catch (err) {[m
[32m+[m[32m      return next(err)[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    var appender = new FileAppender(fileStrategy, req)[m
[32m+[m[32m    var isDone = false[m
[32m+[m[32m    var readFinished = false[m
[32m+[m[32m    var errorOccured = false[m
[32m+[m[32m    var pendingWrites = new Counter()[m
[32m+[m[32m    var uploadedFiles = [][m
[32m+[m
[32m+[m[32m    function done (err) {[m
[32m+[m[32m      if (isDone) return[m
[32m+[m[32m      isDone = true[m
[32m+[m[32m      req.unpipe(busboy)[m
[32m+[m[32m      busboy.removeAllListeners()[m
[32m+[m[32m      next(err)[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    function indicateDone () {[m
[32m+[m[32m      if (readFinished && pendingWrites.isZero() && !errorOccured) done()[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    function abortWithError (uploadError) {[m
[32m+[m[32m      if (errorOccured) return[m
[32m+[m[32m      errorOccured = true[m
[32m+[m
[32m+[m[32m      pendingWrites.onceZero(function () {[m
[32m+[m[32m        function remove (file, cb) {[m
[32m+[m[32m          storage._removeFile(req, file, cb)[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        removeUploadedFiles(uploadedFiles, remove, function (err, storageErrors) {[m
[32m+[m[32m          if (err) return done(err)[m
[32m+[m
[32m+[m[32m          uploadError.storageErrors = storageErrors[m
[32m+[m[32m          done(uploadError)[m
[32m+[m[32m        })[m
[32m+[m[32m      })[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    function abortWithCode (code, optionalField) {[m
[32m+[m[32m      abortWithError(new MulterError(code, optionalField))[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    // handle text field data[m
[32m+[m[32m    busboy.on('field', function (fieldname, value, { nameTruncated, valueTruncated }) {[m
[32m+[m[32m      if (fieldname == null) return abortWithCode('MISSING_FIELD_NAME')[m
[32m+[m[32m      if (nameTruncated) return abortWithCode('LIMIT_FIELD_KEY')[m
[32m+[m[32m      if (valueTruncated) return abortWithCode('LIMIT_FIELD_VALUE', fieldname)[m
[32m+[m
[32m+[m[32m      // Work around bug in Busboy (https://github.com/mscdex/busboy/issues/6)[m
[32m+[m[32m      if (limits && Object.prototype.hasOwnProperty.call(limits, 'fieldNameSize')) {[m
[32m+[m[32m        if (fieldname.length > limits.fieldNameSize) return abortWithCode('LIMIT_FIELD_KEY')[m
[32m+[m[32m      }[m
[32m+[m
[32m+[m[32m      appendField(req.body, fieldname, value)[m
[32m+[m[32m    })[m
[32m+[m
[32m+[m[32m    // handle files[m
[32m+[m[32m    busboy.on('file', function (fieldname, fileStream, { filename, encoding, mimeType }) {[m
[32m+[m[32m      // don't attach to the files object, if there is no file[m
[32m+[m[32m      if (!filename) return fileStream.resume()[m
[32m+[m
[32m+[m[32m      // Work around bug in Busboy (https://github.com/mscdex/busboy/issues/6)[m
[32m+[m[32m      if (limits && Object.prototype.hasOwnProperty.call(limits, 'fieldNameSize')) {[m
[32m+[m[32m        if (fieldname.length > limits.fieldNameSize) return abortWithCode('LIMIT_FIELD_KEY')[m
[32m+[m[32m      }[m
[32m+[m
[32m+[m[32m      var file = {[m
[32m+[m[32m        fieldname: fieldname,[m
[32m+[m[32m        originalname: filename,[m
[32m+[m[32m        encoding: encoding,[m
[32m+[m[32m        mimetype: mimeType[m
[32m+[m[32m      }[m
[32m+[m
[32m+[m[32m      var placeholder = appender.insertPlaceholder(file)[m
[32m+[m
[32m+[m[32m      fileFilter(req, file, function (err, includeFile) {[m
[32m+[m[32m        if (err) {[m
[32m+[m[32m          appender.removePlaceholder(placeholder)[m
[32m+[m[32m          return abortWithError(err)[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        if (!includeFile) {[m
[32m+[m[32m          appender.removePlaceholder(placeholder)[m
[32m+[m[32m          return fileStream.resume()[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        var aborting = false[m
[32m+[m[32m        pendingWrites.increment()[m
[32m+[m
[32m+[m[32m        Object.defineProperty(file, 'stream', {[m
[32m+[m[32m          configurable: true,[m
[32m+[m[32m          enumerable: false,[m
[32m+[m[32m          value: fileStream[m
[32m+[m[32m        })[m
[32m+[m
[32m+[m[32m        fileStream.on('error', function (err) {[m
[32m+[m[32m          pendingWrites.decrement()[m
[32m+[m[32m          abortWithError(err)[m
[32m+[m[32m        })[m
[32m+[m
[32m+[m[32m        fileStream.on('limit', function () {[m
[32m+[m[32m          aborting = true[m
[32m+[m[32m          abortWithCode('LIMIT_FILE_SIZE', fieldname)[m
[32m+[m[32m        })[m
[32m+[m
[32m+[m[32m        storage._handleFile(req, file, function (err, info) {[m
[32m+[m[32m          if (aborting) {[m
[32m+[m[32m            appender.removePlaceholder(placeholder)[m
[32m+[m[32m            uploadedFiles.push(extend(file, info))[m
[32m+[m[32m            return pendingWrites.decrement()[m
[32m+[m[32m          }[m
[32m+[m
[32m+[m[32m          if (err) {[m
[32m+[m[32m            appender.removePlaceholder(placeholder)[m
[32m+[m[32m            pendingWrites.decrement()[m
[32m+[m[32m            return abortWithError(err)[m
[32m+[m[32m          }[m
[32m+[m
[32m+[m[32m          var fileInfo = extend(file, info)[m
[32m+[m
[32m+[m[32m          appender.replacePlaceholder(placeholder, fileInfo)[m
[32m+[m[32m          uploadedFiles.push(fileInfo)[m
[32m+[m[32m          pendingWrites.decrement()[m
[32m+[m[32m          indicateDone()[m
[32m+[m[32m        })[m
[32m+[m[32m      })[m
[32m+[m[32m    })[m
[32m+[m
[32m+[m[32m    busboy.on('error', function (err) { abortWithError(err) })[m
[32m+[m[32m    busboy.on('partsLimit', function () { abortWithCode('LIMIT_PART_COUNT') })[m
[32m+[m[32m    busboy.on('filesLimit', function () { abortWithCode('LIMIT_FILE_COUNT') })[m
[32m+[m[32m    busboy.on('fieldsLimit', function () { abortWithCode('LIMIT_FIELD_COUNT') })[m
[32m+[m[32m    busboy.on('close', function () {[m
[32m+[m[32m      readFinished = true[m
[32m+[m[32m      indicateDone()[m
[32m+[m[32m    })[m
[32m+[m
[32m+[m[32m    req.pipe(busboy)[m
[32m+[m[32m  }[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mmodule.exports = makeMiddleware[m
[1mdiff --git a/node_modules/multer/lib/multer-error.js b/node_modules/multer/lib/multer-error.js[m
[1mnew file mode 100644[m
[1mindex 0000000..d56b00e[m
[1m--- /dev/null[m
[1m+++ b/node_modules/multer/lib/multer-error.js[m
[36m@@ -0,0 +1,24 @@[m
[32m+[m[32mvar util = require('util')[m
[32m+[m
[32m+[m[32mvar errorMessages = {[m
[32m+[m[32m  LIMIT_PART_COUNT: 'Too many parts',[m
[32m+[m[32m  LIMIT_FILE_SIZE: 'File too large',[m
[32m+[m[32m  LIMIT_FILE_COUNT: 'Too many files',[m
[32m+[m[32m  LIMIT_FIELD_KEY: 'Field name too long',[m
[32m+[m[32m  LIMIT_FIELD_VALUE: 'Field value too long',[m
[32m+[m[32m  LIMIT_FIELD_COUNT: 'Too many fields',[m
[32m+[m[32m  LIMIT_UNEXPECTED_FILE: 'Unexpected field',[m
[32m+[m[32m  MISSING_FIELD_NAME: 'Field name missing'[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction MulterError (code, field) {[m
[32m+[m[32m  Error.captureStackTrace(this, this.constructor)[m
[32m+[m[32m  this.name = this.constructor.name[m
[32m+[m[32m  this.message = errorMessages[code][m
[32m+[m[32m  this.code = code[m
[32m+[m[32m  if (field) this.field = field[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mutil.inherits(MulterError, Error)[m
[32m+[m
[32m+[m[32mmodule.exports = MulterError[m
[1mdiff --git a/node_modules/multer/lib/remove-uploaded-files.js b/node_modules/multer/lib/remove-uploaded-files.js[m
[1mnew file mode 100644[m
[1mindex 0000000..f0b16ea[m
[1m--- /dev/null[m
[1m+++ b/node_modules/multer/lib/remove-uploaded-files.js[m
[36m@@ -0,0 +1,28 @@[m
[32m+[m[32mfunction removeUploadedFiles (uploadedFiles, remove, cb) {[m
[32m+[m[32m  var length = uploadedFiles.length[m
[32m+[m[32m  var errors = [][m
[32m+[m
[32m+[m[32m  if (length === 0) return cb(null, errors)[m
[32m+[m
[32m+[m[32m  function handleFile (idx) {[m
[32m+[m[32m    var file = uploadedFiles[idx][m
[32m+[m
[32m+[m[32m    remove(file, function (err) {[m
[32m+[m[32m      if (err) {[m
[32m+[m[32m        err.file = file[m
[32m+[m[32m        err.field = file.fieldname[m
[32m+[m[32m        errors.push(err)[m
[32m+[m[32m      }[m
[32m+[m
[32m+[m[32m      if (idx < length - 1) {[m
[32m+[m[32m        handleFile(idx + 1)[m
[32m+[m[32m      } else {[m
[32m+[m[32m        cb(null, errors)[m
[32m+[m[32m      }[m
[32m+[m[32m    })[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  handleFile(0)[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mmodule.exports = removeUploadedFiles[m
[1mdiff --git a/node_modules/multer/package.json b/node_modules/multer/package.json[m
[1mnew file mode 100644[m
[1mindex 0000000..8545a73[m
[1m--- /dev/null[m
[1m+++ b/node_modules/multer/package.json[m
[36m@@ -0,0 +1,52 @@[m
[32m+[m[32m{[m
[32m+[m[32m  "name": "multer",[m
[32m+[m[32m  "description": "Middleware for handling `multipart/form-data`.",[m
[32m+[m[32m  "version": "1.4.5-lts.1",[m
[32m+[m[32m  "contributors": [[m
[32m+[m[32m    "Hage Yaapa <captain@hacksparrow.com> (http://www.hacksparrow.com)",[m
[32m+[m[32m    "Jaret Pfluger <https://github.com/jpfluger>",[m
[32m+[m[32m    "Linus Unnebäck <linus@folkdatorn.se>"[m
[32m+[m[32m  ],[m
[32m+[m[32m  "license": "MIT",[m
[32m+[m[32m  "repository": "expressjs/multer",[m
[32m+[m[32m  "keywords": [[m
[32m+[m[32m    "form",[m
[32m+[m[32m    "post",[m
[32m+[m[32m    "multipart",[m
[32m+[m[32m    "form-data",[m
[32m+[m[32m    "formdata",[m
[32m+[m[32m    "express",[m
[32m+[m[32m    "middleware"[m
[32m+[m[32m  ],[m
[32m+[m[32m  "dependencies": {[m
[32m+[m[32m    "append-field": "^1.0.0",[m
[32m+[m[32m    "busboy": "^1.0.0",[m
[32m+[m[32m    "concat-stream": "^1.5.2",[m
[32m+[m[32m    "mkdirp": "^0.5.4",[m
[32m+[m[32m    "object-assign": "^4.1.1",[m
[32m+[m[32m    "type-is": "^1.6.4",[m
[32m+[m[32m    "xtend": "^4.0.0"[m
[32m+[m[32m  },[m
[32m+[m[32m  "devDependencies": {[m
[32m+[m[32m    "deep-equal": "^2.0.3",[m
[32m+[m[32m    "express": "^4.13.1",[m
[32m+[m[32m    "form-data": "^1.0.0-rc1",[m
[32m+[m[32m    "fs-temp": "^1.1.2",[m
[32m+[m[32m    "mocha": "^3.5.3",[m
[32m+[m[32m    "rimraf": "^2.4.1",[m
[32m+[m[32m    "standard": "^14.3.3",[m
[32m+[m[32m    "testdata-w3c-json-form": "^1.0.0"[m
[32m+[m[32m  },[m
[32m+[m[32m  "engines": {[m
[32m+[m[32m    "node": ">= 6.0.0"[m
[32m+[m[32m  },[m
[32m+[m[32m  "files": [[m
[32m+[m[32m    "LICENSE",[m
[32m+[m[32m    "index.js",[m
[32m+[m[32m    "storage/",[m
[32m+[m[32m    "lib/"[m
[32m+[m[32m  ],[m
[32m+[m[32m  "scripts": {[m
[32m+[m[32m    "test": "standard && mocha"[m
[32m+[m[32m  }[m
[32m+[m[32m}[m
[1mdiff --git a/node_modules/multer/storage/disk.js b/node_modules/multer/storage/disk.js[m
[1mnew file mode 100644[m
[1mindex 0000000..2f77c9f[m
[1m--- /dev/null[m
[1m+++ b/node_modules/multer/storage/disk.js[m
[36m@@ -0,0 +1,66 @@[m
[32m+[m[32mvar fs = require('fs')[m
[32m+[m[32mvar os = require('os')[m
[32m+[m[32mvar path = require('path')[m
[32m+[m[32mvar crypto = require('crypto')[m
[32m+[m[32mvar mkdirp = require('mkdirp')[m
[32m+[m
[32m+[m[32mfunction getFilename (req, file, cb) {[m
[32m+[m[32m  crypto.randomBytes(16, function (err, raw) {[m
[32m+[m[32m    cb(err, err ? undefined : raw.toString('hex'))[m
[32m+[m[32m  })[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction getDestination (req, file, cb) {[m
[32m+[m[32m  cb(null, os.tmpdir())[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction DiskStorage (opts) {[m
[32m+[m[32m  this.getFilename = (opts.filename || getFilename)[m
[32m+[m
[32m+[m[32m  if (typeof opts.destination === 'string') {[m
[32m+[m[32m    mkdirp.sync(opts.destination)[m
[32m+[m[32m    this.getDestination = function ($0, $1, cb) { cb(null, opts.destination) }[m
[32m+[m[32m  } else {[m
[32m+[m[32m    this.getDestination = (opts.destination || getDestination)[m
[32m+[m[32m  }[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mDiskStorage.prototype._handleFile = function _handleFile (req, file, cb) {[m
[32m+[m[32m  var that = this[m
[32m+[m
[32m+[m[32m  that.getDestination(req, file, function (err, destination) {[m
[32m+[m[32m    if (err) return cb(err)[m
[32m+[m
[32m+[m[32m    that.getFilename(req, file, function (err, filename) {[m
[32m+[m[32m      if (err) return cb(err)[m
[32m+[m
[32m+[m[32m      var finalPath = path.join(destination, filename)[m
[32m+[m[32m      var outStream = fs.createWriteStream(finalPath)[m
[32m+[m
[32m+[m[32m      file.stream.pipe(outStream)[m
[32m+[m[32m      outStream.on('error', cb)[m
[32m+[m[32m      outStream.on('finish', function () {[m
[32m+[m[32m        cb(null, {[m
[32m+[m[32m          destination: destination,[m
[32m+[m[32m          filename: filename,[m
[32m+[m[32m          path: finalPath,[m
[32m+[m[32m          size: outStream.bytesWritten[m
[32m+[m[32m        })[m
[32m+[m[32m      })[m
[32m+[m[32m    })[m
[32m+[m[32m  })[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mDiskStorage.prototype._removeFile = function _removeFile (req, file, cb) {[m
[32m+[m[32m  var path = file.path[m
[32m+[m
[32m+[m[32m  delete file.destination[m
[32m+[m[32m  delete file.filename[m
[32m+[m[32m  delete file.path[m
[32m+[m
[32m+[m[32m  fs.unlink(path, cb)[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mmodule.exports = function (opts) {[m
[32m+[m[32m  return new DiskStorage(opts)[m
[32m+[m[32m}[m
[1mdiff --git a/node_modules/multer/storage/memory.js b/node_modules/multer/storage/memory.js[m
[1mnew file mode 100644[m
[1mindex 0000000..f953ded[m
[1m--- /dev/null[m
[1m+++ b/node_modules/multer/storage/memory.js[m
[36m@@ -0,0 +1,21 @@[m
[32m+[m[32mvar concat = require('concat-stream')[m
[32m+[m
[32m+[m[32mfunction MemoryStorage (opts) {}[m
[32m+[m
[32m+[m[32mMemoryStorage.prototype._handleFile = function _handleFile (req, file, cb) {[m
[32m+[m[32m  file.stream.pipe(concat({ encoding: 'buffer' }, function (data) {[m
[32m+[m[32m    cb(null, {[m
[32m+[m[32m      buffer: data,[m
[32m+[m[32m      size: data.length[m
[32m+[m[32m    })[m
[32m+[m[32m  }))[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mMemoryStorage.prototype._removeFile = function _removeFile (req, file, cb) {[m
[32m+[m[32m  delete file.buffer[m
[32m+[m[32m  cb(null)[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mmodule.exports = function (opts) {[m
[32m+[m[32m  return new MemoryStorage(opts)[m
[32m+[m[32m}[m
[1mdiff --git a/node_modules/process-nextick-args/index.js b/node_modules/process-nextick-args/index.js[m
[1mnew file mode 100644[m
[1mindex 0000000..3eecf11[m
[1m--- /dev/null[m
[1m+++ b/node_modules/process-nextick-args/index.js[m
[36m@@ -0,0 +1,45 @@[m
[32m+[m[32m'use strict';[m
[32m+[m
[32m+[m[32mif (typeof process === 'undefined' ||[m
[32m+[m[32m    !process.version ||[m
[32m+[m[32m    process.version.indexOf('v0.') === 0 ||[m
[32m+[m[32m    process.version.indexOf('v1.') === 0 && process.version.indexOf('v1.8.') !== 0) {[m
[32m+[m[32m  module.exports = { nextTick: nextTick };[m
[32m+[m[32m} else {[m
[32m+[m[32m  module.exports = process[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction nextTick(fn, arg1, arg2, arg3) {[m
[32m+[m[32m  if (typeof fn !== 'function') {[m
[32m+[m[32m    throw new TypeError('"callback" argument must be a function');[m
[32m+[m[32m  }[m
[32m+[m[32m  var len = arguments.length;[m
[32m+[m[32m  var args, i;[m
[32m+[m[32m  switch (len) {[m
[32m+[m[32m  case 0:[m
[32m+[m[32m  case 1:[m
[32m+[m[32m    return process.nextTick(fn);[m
[32m+[m[32m  case 2:[m
[32m+[m[32m    return process.nextTick(function afterTickOne() {[m
[32m+[m[32m      fn.call(null, arg1);[m
[32m+[m[32m    });[m
[32m+[m[32m  case 3:[m
[32m+[m[32m    return process.nextTick(function afterTickTwo() {[m
[32m+[m[32m      fn.call(null, arg1, arg2);[m
[32m+[m[32m    });[m
[32m+[m[32m  case 4:[m
[32m+[m[32m    return process.nextTick(function afterTickThree() {[m
[32m+[m[32m      fn.call(null, arg1, arg2, arg3);[m
[32m+[m[32m    });[m
[32m+[m[32m  default:[m
[32m+[m[32m    args = new Array(len - 1);[m
[32m+[m[32m    i = 0;[m
[32m+[m[32m    while (i < args.length) {[m
[32m+[m[32m      args[i++] = arguments[i];[m
[32m+[m[32m    }[m
[32m+[m[32m    return process.nextTick(function afterTick() {[m
[32m+[m[32m      fn.apply(null, args);[m
[32m+[m[32m    });[m
[32m+[m[32m  }[m
[32m+[m[32m}[m
[32m+[m
[1mdiff --git a/node_modules/process-nextick-args/license.md b/node_modules/process-nextick-args/license.md[m
[1mnew file mode 100644[m
[1mindex 0000000..c67e353[m
[1m--- /dev/null[m
[1m+++ b/node_modules/process-nextick-args/license.md[m
[36m@@ -0,0 +1,19 @@[m
[32m+[m[32m# Copyright (c) 2015 Calvin Metcalf[m
[32m+[m
[32m+[m[32mPermission is hereby granted, free of charge, to any person obtaining a copy[m
[32m+[m[32mof this software and associated documentation files (the "Software"), to deal[m
[32m+[m[32min the Software without restriction, including without limitation the rights[m
[32m+[m[32mto use, copy, modify, merge, publish, distribute, sublicense, and/or sell[m
[32m+[m[32mcopies of the Software, and to permit persons to whom the Software is[m
[32m+[m[32mfurnished to do so, subject to the following conditions:[m
[32m+[m
[32m+[m[32mThe above copyright notice and this permission notice shall be included in all[m
[32m+[m[32mcopies or substantial portions of the Software.[m
[32m+[m
[32m+[m[32m**THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR[m
[32m+[m[32mIMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,[m
[32m+[m[32mFITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE[m
[32m+[m[32mAUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER[m
[32m+[m[32mLIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,[m
[32m+[m[32mOUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE[m
[32m+[m[32mSOFTWARE.**[m
[1mdiff --git a/node_modules/process-nextick-args/package.json b/node_modules/process-nextick-args/package.json[m
[1mnew file mode 100644[m
[1mindex 0000000..6070b72[m
[1m--- /dev/null[m
[1m+++ b/node_modules/process-nextick-args/package.json[m
[36m@@ -0,0 +1,25 @@[m
[32m+[m[32m{[m
[32m+[m[32m  "name": "process-nextick-args",[m
[32m+[m[32m  "version": "2.0.1",[m
[32m+[m[32m  "description": "process.nextTick but always with args",[m
[32m+[m[32m  "main": "index.js",[m
[32m+[m[32m  "files": [[m
[32m+[m[32m    "index.js"[m
[32m+[m[32m  ],[m
[32m+[m[32m  "scripts": {[m
[32m+[m[32m    "test": "node test.js"[m
[32m+[m[32m  },[m
[32m+[m[32m  "repository": {[m
[32m+[m[32m    "type": "git",[m
[32m+[m[32m    "url": "https://github.com/calvinmetcalf/process-nextick-args.git"[m
[32m+[m[32m  },[m
[32m+[m[32m  "author": "",[m
[32m+[m[32m  "license": "MIT",[m
[32m+[m[32m  "bugs": {[m
[32m+[m[32m    "url": "https://github.com/calvinmetcalf/process-nextick-args/issues"[m
[32m+[m[32m  },[m
[32m+[m[32m  "homepage": "https://github.com/calvinmetcalf/process-nextick-args",[m
[32m+[m[32m  "devDependencies": {[m
[32m+[m[32m    "tap": "~0.2.6"[m
[32m+[m[32m  }[m
[32m+[m[32m}[m
[1mdiff --git a/node_modules/process-nextick-args/readme.md b/node_modules/process-nextick-args/readme.md[m
[1mnew file mode 100644[m
[1mindex 0000000..ecb432c[m
[1m--- /dev/null[m
[1m+++ b/node_modules/process-nextick-args/readme.md[m
[36m@@ -0,0 +1,18 @@[m
[32m+[m[32mprocess-nextick-args[m
[32m+[m[32m=====[m
[32m+[m
[32m+[m[32m[![Build Status](https://travis-ci.org/calvinmetcalf/process-nextick-args.svg?branch=master)](https://travis-ci.org/calvinmetcalf/process-nextick-args)[m
[32m+[m
[32m+[m[32m```bash[m
[32m+[m[32mnpm install --save process-nextick-args[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32mAlways be able to pass arguments to process.nextTick, no matter the platform[m
[32m+[m
[32m+[m[32m```js[m
[32m+[m[32mvar pna = require('process-nextick-args');[m
[32m+[m
[32m+[m[32mpna.nextTick(function (a, b, c) {[m
[32m+[m[32m  console.log(a, b, c);[m
[32m+[m[32m}, 'step', 3,  'profit');[m
[32m+[m[32m```[m
[1mdiff --git a/node_modules/readable-stream/.travis.yml b/node_modules/readable-stream/.travis.yml[m
[1mnew file mode 100644[m
[1mindex 0000000..f62cdac[m
[1m--- /dev/null[m
[1m+++ b/node_modules/readable-stream/.travis.yml[m
[36m@@ -0,0 +1,34 @@[m
[32m+[m[32msudo: false[m
[32m+[m[32mlanguage: node_js[m
[32m+[m[32mbefore_install:[m
[32m+[m[32m  - (test $NPM_LEGACY && npm install -g npm@2 && npm install -g npm@3) || true[m
[32m+[m[32mnotifications:[m
[32m+[m[32m  email: false[m
[32m+[m[32mmatrix:[m
[32m+[m[32m  fast_finish: true[m
[32m+[m[32m  include:[m
[32m+[m[32m  - node_js: '0.8'[m
[32m+[m[32m    env: NPM_LEGACY=true[m
[32m+[m[32m  - node_js: '0.10'[m
[32m+[m[32m    env: NPM_LEGACY=true[m
[32m+[m[32m  - node_js: '0.11'[m
[32m+[m[32m    env: NPM_LEGACY=true[m
[32m+[m[32m  - node_js: '0.12'[m
[32m+[m[32m    env: NPM_LEGACY=true[m
[32m+[m[32m  - node_js: 1[m
[32m+[m[32m    env: NPM_LEGACY=true[m
[32m+[m[32m  - node_js: 2[m
[32m+[m[32m    env: NPM_LEGACY=true[m
[32m+[m[32m  - node_js: 3[m
[32m+[m[32m    env: NPM_LEGACY=true[m
[32m+[m[32m  - node_js: 4[m
[32m+[m[32m  - node_js: 5[m
[32m+[m[32m  - node_js: 6[m
[32m+[m[32m  - node_js: 7[m
[32m+[m[32m  - node_js: 8[m
[32m+[m[32m  - node_js: 9[m
[32m+[m[32mscript: "npm run test"[m
[32m+[m[32menv:[m
[32m+[m[32m  global:[m
[32m+[m[32m  - secure: rE2Vvo7vnjabYNULNyLFxOyt98BoJexDqsiOnfiD6kLYYsiQGfr/sbZkPMOFm9qfQG7pjqx+zZWZjGSswhTt+626C0t/njXqug7Yps4c3dFblzGfreQHp7wNX5TFsvrxd6dAowVasMp61sJcRnB2w8cUzoe3RAYUDHyiHktwqMc=[m
[32m+[m[32m  - secure: g9YINaKAdMatsJ28G9jCGbSaguXCyxSTy+pBO6Ch0Cf57ZLOTka3HqDj8p3nV28LUIHZ3ut5WO43CeYKwt4AUtLpBS3a0dndHdY6D83uY6b2qh5hXlrcbeQTq2cvw2y95F7hm4D1kwrgZ7ViqaKggRcEupAL69YbJnxeUDKWEdI=[m
[1mdiff --git a/node_modules/readable-stream/CONTRIBUTING.md b/node_modules/readable-stream/CONTRIBUTING.md[m
[1mnew file mode 100644[m
[1mindex 0000000..f478d58[m
[1m--- /dev/null[m
[1m+++ b/node_modules/readable-stream/CONTRIBUTING.md[m
[36m@@ -0,0 +1,38 @@[m
[32m+[m[32m# Developer's Certificate of Origin 1.1[m
[32m+[m
[32m+[m[32mBy making a contribution to this project, I certify that:[m
[32m+[m
[32m+[m[32m* (a) The contribution was created in whole or in part by me and I[m
[32m+[m[32m  have the right to submit it under the open source license[m
[32m+[m[32m  indicated in the file; or[m
[32m+[m
[32m+[m[32m* (b) The contribution is based upon previous work that, to the best[m
[32m+[m[32m  of my knowledge, is covered under an appropriate open source[m
[32m+[m[32m  license and I have the right under that license to submit that[m
[32m+[m[32m  work with modifications, whether created in whole or in part[m
[32m+[m[32m  by me, under the same open source license (unless I am[m
[32m+[m[32m  permitted to submit under a different license), as indicated[m
[32m+[m[32m  in the file; or[m
[32m+[m
[32m+[m[32m* (c) The contribution was provided directly to me by some other[m
[32m+[m[32m  person who certified (a), (b) or (c) and I have not modified[m
[32m+[m[32m  it.[m
[32m+[m
[32m+[m[32m* (d) I understand and agree that this project and the contribution[m
[32m+[m[32m  are public and that a record of the contribution (including all[m
[32m+[m[32m  personal information I submit with it, including my sign-off) is[m
[32m+[m[32m  maintained indefinitely and may be redistributed consistent with[m
[32m+[m[32m  this project or the open source license(s) involved.[m
[32m+[m
[32m+[m[32m## Moderation Policy[m
[32m+[m
[32m+[m[32mThe [Node.js Moderation Policy] applies to this WG.[m
[32m+[m
[32m+[m[32m## Code of Conduct[m
[32m+[m
[32m+[m[32mThe [Node.js Code of Conduct][] applies to this WG.[m
[32m+[m
[32m+[m[32m[Node.js Code of Conduct]:[m
[32m+[m[32mhttps://github.com/nodejs/node/blob/master/CODE_OF_CONDUCT.md[m
[32m+[m[32m[Node.js Moderation Policy]:[m
[32m+[m[32mhttps://github.com/nodejs/TSC/blob/master/Moderation-Policy.md[m
[1mdiff --git a/node_modules/readable-stream/GOVERNANCE.md b/node_modules/readable-stream/GOVERNANCE.md[m
[1mnew file mode 100644[m
[1mindex 0000000..16ffb93[m
[1m--- /dev/null[m
[1m+++ b/node_modules/readable-stream/GOVERNANCE.md[m
[36m@@ -0,0 +1,136 @@[m
[32m+[m[32m### Streams Working Group[m
[32m+[m
[32m+[m[32mThe Node.js Streams is jointly governed by a Working Group[m
[32m+[m[32m(WG)[m
[32m+[m[32mthat is responsible for high-level guidance of the project.[m
[32m+[m
[32m+[m[32mThe WG has final authority over this project including:[m
[32m+[m
[32m+[m[32m* Technical direction[m
[32m+[m[32m* Project governance and process (including this policy)[m
[32m+[m[32m* Contribution policy[m
[32m+[m[32m* GitHub repository hosting[m
[32m+[m[32m* Conduct guidelines[m
[32m+[m[32m* Maintaining the list of additional Collaborators[m
[32m+[m
[32m+[m[32mFor the current list of WG members, see the project[m
[32m+[m[32m[README.md](./README.md#current-project-team-members).[m
[32m+[m
[32m+[m[32m### Collaborators[m
[32m+[m
[32m+[m[32mThe readable-stream GitHub repository is[m
[32m+[m[32mmaintained by the WG and additional Collaborators who are added by the[m
[32m+[m[32mWG on an ongoing basis.[m
[32m+[m
[32m+[m[32mIndividuals making significant and valuable contributions are made[m
[32m+[m[32mCollaborators and given commit-access to the project. These[m
[32m+[m[32mindividuals are identified by the WG and their addition as[m
[32m+[m[32mCollaborators is discussed during the WG meeting.[m
[32m+[m
[32m+[m[32m_Note:_ If you make a significant contribution and are not considered[m
[32m+[m[32mfor commit-access log an issue or contact a WG member directly and it[m
[32m+[m[32mwill be brought up in the next WG meeting.[m
[32m+[m
[32m+[m[32mModifications of the contents of the readable-stream repository are[m
[32m+[m[32mmade on[m
[32m+[m[32ma collaborative basis. Anybody with a GitHub account may propose a[m
[32m+[m[32mmodification via pull request and it will be considered by the project[m
[32m+[m[32mCollaborators. All pull requests must be reviewed and accepted by a[m
[32m+[m[32mCollaborator with sufficient expertise who is able to take full[m
[32m+[m[32mresponsibility for the change. In the case of pull requests proposed[m
[32m+[m[32mby an existing Collaborator, an additional Collaborator is required[m
[32m+[m[32mfor sign-off. Consensus should be sought if additional Collaborators[m
[32m+[m[32mparticipate and there is disagreement around a particular[m
[32m+[m[32mmodification. See _Consensus Seeking Process_ below for further detail[m
[32m+[m[32mon the consensus model used for governance.[m
[32m+[m
[32m+[m[32mCollaborators may opt to elevate significant or controversial[m
[32m+[m[32mmodifications, or modifications that have not found consensus to the[m
[32m+[m[32mWG for discussion by assigning the ***WG-agenda*** tag to a pull[m
[32m+[m[32mrequest or issue. The WG should serve as the final arbiter where[m
[32m+[m[32mrequired.[m
[32m+[m
[32m+[m[32mFor the current list of Collaborators, see the project[m
[32m+[m[32m[README.md](./README.md#members).[m
[32m+[m
[32m+[m[32m### WG Membership[m
[32m+[m
[32m+[m[32mWG seats are not time-limited.  There is no fixed size of the WG.[m
[32m+[m[32mHowever, the expected target is between 6 and 12, to ensure adequate[m
[32m+[m[32mcoverage of important areas of expertise, balanced with the ability to[m
[32m+[m[32mmake decisions efficiently.[m
[32m+[m
[32m+[m[32mThere is no specific set of requirements or qualifications for WG[m
[32m+[m[32mmembership beyond these rules.[m
[32m+[m
[32m+[m[32mThe WG may add additional members to the WG by unanimous consensus.[m
[32m+[m
[32m+[m[32mA WG member may be removed from the WG by voluntary resignation, or by[m
[32m+[m[32munanimous consensus of all other WG members.[m
[32m+[m
[32m+[m[32mChanges to WG membership should be posted in the agenda, and may be[m
[32m+[m[32msuggested as any other agenda item (see "WG Meetings" below).[m
[32m+[m
[32m+[m[32mIf an addition or removal is proposed during a meeting, and the full[m
[32m+[m[32mWG is not in attendance to participate, then the addition or removal[m
[32m+[m[32mis added to the agenda for the subsequent meeting.  This is to ensure[m
[32m+[m[32mthat all members are given the opportunity to participate in all[m
[32m+[m[32mmembership decisions.  If a WG member is unable to attend a meeting[m
[32m+[m[32mwhere a planned membership decision is being made, then their consent[m
[32m+[m[32mis assumed.[m
[32m+[m
[32m+[m[32mNo more than 1/3 of the WG members may be affiliated with the same[m
[32m+[m[32memployer.  If removal or resignation of a WG member, or a change of[m
[32m+[m[32memployment by a WG member, creates a situation where more than 1/3 of[m
[32m+[m[32mthe WG membership shares an employer, then the situation must be[m
[32m+[m[32mimmediately remedied by the resignation or removal of one or more WG[m
[32m+[m[32mmembers affiliated with the over-represented employer(s).[m
[32m+[m
[32m+[m[32m### WG Meetings[m
[32m+[m
[32m+[m[32mThe WG meets occasionally on a Google Hangout On Air. A designated moderator[m
[32m+[m[32mapproved by the WG runs the meeting. Each meeting should be[m
[32m+[m[32mpublished to YouTube.[m
[32m+[m
[32m+[m[32mItems are added to the WG agenda that are considered contentious or[m
[32m+[m[32mare modifications of governance, contribution policy, WG membership,[m
[32m+[m[32mor release process.[m
[32m+[m
[32m+[m[32mThe intention of the agenda is not to approve or review all patches;[m
[32m+[m[32mthat should happen continuously on GitHub and be handled by the larger[m
[32m+[m[32mgroup of Collaborators.[m
[32m+[m
[32m+[m[32mAny community member or contributor can ask that something be added to[m
[32m+[m[32mthe next meeting's agenda by logging a GitHub Issue. Any Collaborator,[m
[32m+[m[32mWG member or the moderator can add the item to the agenda by adding[m
[32m+[m[32mthe ***WG-agenda*** tag to the issue.[m
[32m+[m
[32m+[m[32mPrior to each WG meeting the moderator will share the Agenda with[m
[32m+[m[32mmembers of the WG. WG members can add any items they like to the[m
[32m+[m[32magenda at the beginning of each meeting. The moderator and the WG[m
[32m+[m[32mcannot veto or remove items.[m
[32m+[m
[32m+[m[32mThe WG may invite persons or representatives from certain projects to[m
[32m+[m[32mparticipate in a non-voting capacity.[m
[32m+[m
[32m+[m[32mThe moderator is responsible for summarizing the discussion of each[m
[32m+[m[32magenda item and sends it as a pull request after the meeting.[m
[32m+[m
[32m+[m[32m### Consensus Seeking Process[m
[32m+[m
[32m+[m[32mThe WG follows a[m
[32m+[m[32m[Consensus[m
[32m+[m[32mSeeking](http://en.wikipedia.org/wiki/Consensus-seeking_decision-making)[m
[32m+[m[32mdecision-making model.[m
[32m+[m
[32m+[m[32mWhen an agenda item has appeared to reach a consensus the moderator[m
[32m+[m[32mwill ask "Does anyone object?" as a final call for dissent from the[m
[32m+[m[32mconsensus.[m
[32m+[m
[32m+[m[32mIf an agenda item cannot reach a consensus a WG member can call for[m
[32m+[m[32meither a closing vote or a vote to table the issue to the next[m
[32m+[m[32mmeeting. The call for a vote must be seconded by a majority of the WG[m
[32m+[m[32mor else the discussion will continue. Simple majority wins.[m
[32m+[m
[32m+[m[32mNote that changes to WG membership require a majority consensus.  See[m
[32m+[m[32m"WG Membership" above.[m
[1mdiff --git a/node_modules/readable-stream/LICENSE b/node_modules/readable-stream/LICENSE[m
[1mnew file mode 100644[m
[1mindex 0000000..2873b3b[m
[1m--- /dev/null[m
[1m+++ b/node_modules/readable-stream/LICENSE[m
[36m@@ -0,0 +1,47 @@[m
[32m+[m[32mNode.js is licensed for use as follows:[m
[32m+[m
[32m+[m[32m"""[m
[32m+[m[32mCopyright Node.js contributors. All rights reserved.[m
[32m+[m
[32m+[m[32mPermission is hereby granted, free of charge, to any person obtaining a copy[m
[32m+[m[32mof this software and associated documentation files (the "Software"), to[m
[32m+[m[32mdeal in the Software without restriction, including without limitation the[m
[32m+[m[32mrights to use, copy, modify, merge, publish, distribute, sublicense, and/or[m
[32m+[m[32msell copies of the Software, and to permit persons to whom the Software is[m
[32m+[m[32mfurnished to do so, subject to the following conditions:[m
[32m+[m
[32m+[m[32mThe above copyright notice and this permission notice shall be included in[m
[32m+[m[32mall copies or substantial portions of the Software.[m
[32m+[m
[32m+[m[32mTHE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR[m
[32m+[m[32mIMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,[m
[32m+[m[32mFITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE[m
[32m+[m[32mAUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER[m
[32m+[m[32mLIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING[m
[32m+[m[32mFROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS[m
[32m+[m[32mIN THE SOFTWARE.[m
[32m+[m[32m"""[m
[32m+[m
[32m+[m[32mThis license applies to parts of Node.js originating from the[m
[32m+[m[32mhttps://github.com/joyent/node repository:[m
[32m+[m
[32m+[m[32m"""[m
[32m+[m[32mCopyright Joyent, Inc. and other Node contributors. All rights reserved.[m
[32m+[m[32mPermission is hereby granted, free of charge, to any person obtaining a copy[m
[32m+[m[32mof this software and associated documentation files (the "Software"), to[m
[32m+[m[32mdeal in the Software without restriction, including without limitation the[m
[32m+[m[32mrights to use, copy, modify, merge, publish, distribute, sublicense, and/or[m
[32m+[m[32msell copies of the Software, and to permit persons to whom the Software is[m
[32m+[m[32mfurnished to do so, subject to the following conditions:[m
[32m+[m
[32m+[m[32mThe above copyright notice and this permission notice shall be included in[m
[32m+[m[32mall copies or substantial portions of the Software.[m
[32m+[m
[32m+[m[32mTHE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR[m
[32m+[m[32mIMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,[m
[32m+[m[32mFITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE[m
[32m+[m[32mAUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER[m
[32m+[m[32mLIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING[m
[32m+[m[32mFROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS[m
[32m+[m[32mIN THE SOFTWARE.[m
[32m+[m[32m"""[m
[1mdiff --git a/node_modules/readable-stream/README.md b/node_modules/readable-stream/README.md[m
[1mnew file mode 100644[m
[1mindex 0000000..f1c5a93[m
[1m--- /dev/null[m
[1m+++ b/node_modules/readable-stream/README.md[m
[36m@@ -0,0 +1,58 @@[m
[32m+[m[32m# readable-stream[m
[32m+[m
[32m+[m[32m***Node-core v8.17.0 streams for userland*** [![Build Status](https://travis-ci.org/nodejs/readable-stream.svg?branch=master)](https://travis-ci.org/nodejs/readable-stream)[m
[32m+[m
[32m+[m
[32m+[m[32m[![NPM](https://nodei.co/npm/readable-stream.png?downloads=true&downloadRank=true)](https://nodei.co/npm/readable-stream/)[m
[32m+[m[32m[![NPM](https://nodei.co/npm-dl/readable-stream.png?&months=6&height=3)](https://nodei.co/npm/readable-stream/)[m
[32m+[m
[32m+[m
[32m+[m[32m[![Sauce Test Status](https://saucelabs.com/browser-matrix/readable-stream.svg)](https://saucelabs.com/u/readable-stream)[m
[32m+[m
[32m+[m[32m```bash[m
[32m+[m[32mnpm install --save readable-stream[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32m***Node-core streams for userland***[m
[32m+[m
[32m+[m[32mThis package is a mirror of the Streams2 and Streams3 implementations in[m
[32m+[m[32mNode-core.[m
[32m+[m
[32m+[m[32mFull documentation may be found on the [Node.js website](https://nodejs.org/dist/v8.17.0/docs/api/stream.html).[m
[32m+[m
[32m+[m[32mIf you want to guarantee a stable streams base, regardless of what version of[m
[32m+[m[32mNode you, or the users of your libraries are using, use **readable-stream** *only* and avoid the *"stream"* module in Node-core, for background see [this blogpost](http://r.va.gg/2014/06/why-i-dont-use-nodes-core-stream-module.html).[m
[32m+[m
[32m+[m[32mAs of version 2.0.0 **readable-stream** uses semantic versioning.[m
[32m+[m
[32m+[m[32m# Streams Working Group[m
[32m+[m
[32m+[m[32m`readable-stream` is maintained by the Streams Working Group, which[m
[32m+[m[32moversees the development and maintenance of the Streams API within[m
[32m+[m[32mNode.js. The responsibilities of the Streams Working Group include:[m
[32m+[m
[32m+[m[32m* Addressing stream issues on the Node.js issue tracker.[m
[32m+[m[32m* Authoring and editing stream documentation within the Node.js project.[m
[32m+[m[32m* Reviewing changes to stream subclasses within the Node.js project.[m
[32m+[m[32m* Redirecting changes to streams from the Node.js project to this[m
[32m+[m[32m  project.[m
[32m+[m[32m* Assisting in the implementation of stream providers within Node.js.[m
[32m+[m[32m* Recommending versions of `readable-stream` to be included in Node.js.[m
[32m+[m[32m* Messaging about the future of streams to give the community advance[m
[32m+[m[32m  notice of changes.[m
[32m+[m
[32m+[m[32m<a name="members"></a>[m
[32m+[m[32m## Team Members[m
[32m+[m
[32m+[m[32m* **Chris Dickinson** ([@chrisdickinson](https://github.com/chrisdickinson)) &lt;christopher.s.dickinson@gmail.com&gt;[m
[32m+[m[32m  - Release GPG key: 9554F04D7259F04124DE6B476D5A82AC7E37093B[m
[32m+[m[32m* **Calvin Metcalf** ([@calvinmetcalf](https://github.com/calvinmetcalf)) &lt;calvin.metcalf@gmail.com&gt;[m
[32m+[m[32m  - Release GPG key: F3EF5F62A87FC27A22E643F714CE4FF5015AA242[m
[32m+[m[32m* **Rod Vagg** ([@rvagg](https://github.com/rvagg)) &lt;rod@vagg.org&gt;[m
[32m+[m[32m  - Release GPG key: DD8F2338BAE7501E3DD5AC78C273792F7D83545D[m
[32m+[m[32m* **Sam Newman** ([@sonewman](https://github.com/sonewman)) &lt;newmansam@outlook.com&gt;[m
[32m+[m[32m* **Mathias Buus** ([@mafintosh](https://github.com/mafintosh)) &lt;mathiasbuus@gmail.com&gt;[m
[32m+[m[32m* **Domenic Denicola** ([@domenic](https://github.com/domenic)) &lt;d@domenic.me&gt;[m
[32m+[m[32m* **Matteo Collina** ([@mcollina](https://github.com/mcollina)) &lt;matteo.collina@gmail.com&gt;[m
[32m+[m[32m  - Release GPG key: 3ABC01543F22DD2239285CDD818674489FBC127E[m
[32m+[m[32m* **Irina Shestak** ([@lrlna](https://github.com/lrlna)) &lt;shestak.irina@gmail.com&gt;[m
[1mdiff --git a/node_modules/readable-stream/doc/wg-meetings/2015-01-30.md b/node_modules/readable-stream/doc/wg-meetings/2015-01-30.md[m
[1mnew file mode 100644[m
[1mindex 0000000..83275f1[m
[1m--- /dev/null[m
[1m+++ b/node_modules/readable-stream/doc/wg-meetings/2015-01-30.md[m
[36m@@ -0,0 +1,60 @@[m
[32m+[m[32m# streams WG Meeting 2015-01-30[m
[32m+[m
[32m+[m[32m## Links[m
[32m+[m
[32m+[m[32m* **Google Hangouts Video**: http://www.youtube.com/watch?v=I9nDOSGfwZg[m
[32m+[m[32m* **GitHub Issue**: https://github.com/iojs/readable-stream/issues/106[m
[32m+[m[32m* **Original Minutes Google Doc**: https://docs.google.com/document/d/17aTgLnjMXIrfjgNaTUnHQO7m3xgzHR2VXBTmi03Qii4/[m
[32m+[m
[32m+[m[32m## Agenda[m
[32m+[m
[32m+[m[32mExtracted from https://github.com/iojs/readable-stream/labels/wg-agenda prior to meeting.[m
[32m+[m
[32m+[m[32m* adopt a charter [#105](https://github.com/iojs/readable-stream/issues/105)[m
[32m+[m[32m* release and versioning strategy [#101](https://github.com/iojs/readable-stream/issues/101)[m
[32m+[m[32m* simpler stream creation [#102](https://github.com/iojs/readable-stream/issues/102)[m
[32m+[m[32m* proposal: deprecate implicit flowing of streams [#99](https://github.com/iojs/readable-stream/issues/99)[m
[32m+[m
[32m+[m[32m## Minutes[m
[32m+[m
[32m+[m[32m### adopt a charter[m
[32m+[m
[32m+[m[32m* group: +1's all around[m
[32m+[m
[32m+[m[32m### What versioning scheme should be adopted?[m
[32m+[m[32m* group: +1’s 3.0.0[m
[32m+[m[32m* domenic+group: pulling in patches from other sources where appropriate[m
[32m+[m[32m* mikeal: version independently, suggesting versions for io.js[m
[32m+[m[32m* mikeal+domenic: work with TC to notify in advance of changes[m
[32m+[m[32msimpler stream creation[m
[32m+[m
[32m+[m[32m### streamline creation of streams[m
[32m+[m[32m* sam: streamline creation of streams[m
[32m+[m[32m* domenic: nice simple solution posted[m
[32m+[m[32m  but, we lose the opportunity to change the model[m
[32m+[m[32m  may not be backwards incompatible (double check keys)[m
[32m+[m
[32m+[m[32m  **action item:** domenic will check[m
[32m+[m
[32m+[m[32m### remove implicit flowing of streams on(‘data’)[m
[32m+[m[32m* add isFlowing / isPaused[m
[32m+[m[32m* mikeal: worrying that we’re documenting polyfill methods – confuses users[m
[32m+[m[32m* domenic: more reflective API is probably good, with warning labels for users[m
[32m+[m[32m* new section for mad scientists (reflective stream access)[m
[32m+[m[32m* calvin: name the “third state”[m
[32m+[m[32m* mikeal: maybe borrow the name from whatwg?[m
[32m+[m[32m* domenic: we’re missing the “third state”[m
[32m+[m[32m* consensus: kind of difficult to name the third state[m
[32m+[m[32m* mikeal: figure out differences in states / compat[m
[32m+[m[32m* mathias: always flow on data – eliminates third state[m
[32m+[m[32m  * explore what it breaks[m
[32m+[m
[32m+[m[32m**action items:**[m
[32m+[m[32m* ask isaac for ability to list packages by what public io.js APIs they use (esp. Stream)[m
[32m+[m[32m* ask rod/build for infrastructure[m
[32m+[m[32m* **chris**: explore the “flow on data” approach[m
[32m+[m[32m* add isPaused/isFlowing[m
[32m+[m[32m* add new docs section[m
[32m+[m[32m* move isPaused to that section[m
[32m+[m
[32m+[m
[1mdiff --git a/node_modules/readable-stream/duplex-browser.js b/node_modules/readable-stream/duplex-browser.js[m
[1mnew file mode 100644[m
[1mindex 0000000..f8b2db8[m
[1m--- /dev/null[m
[1m+++ b/node_modules/readable-stream/duplex-browser.js[m
[36m@@ -0,0 +1 @@[m
[32m+[m[32mmodule.exports = require('./lib/_stream_duplex.js');[m
[1mdiff --git a/node_modules/readable-stream/duplex.js b/node_modules/readable-stream/duplex.js[m
[1mnew file mode 100644[m
[1mindex 0000000..46924cb[m
[1m--- /dev/null[m
[1m+++ b/node_modules/readable-stream/duplex.js[m
[36m@@ -0,0 +1 @@[m
[32m+[m[32mmodule.exports = require('./readable').Duplex[m
[1mdiff --git a/node_modules/readable-stream/lib/_stream_duplex.js b/node_modules/readable-stream/lib/_stream_duplex.js[m
[1mnew file mode 100644[m
[1mindex 0000000..57003c3[m
[1m--- /dev/null[m
[1m+++ b/node_modules/readable-stream/lib/_stream_duplex.js[m
[36m@@ -0,0 +1,131 @@[m
[32m+[m[32m// Copyright Joyent, Inc. and other Node contributors.[m
[32m+[m[32m//[m
[32m+[m[32m// Permission is hereby granted, free of charge, to any person obtaining a[m
[32m+[m[32m// copy of this software and associated documentation files (the[m
[32m+[m[32m// "Software"), to deal in the Software without restriction, including[m
[32m+[m[32m// without limitation the rights to use, copy, modify, merge, publish,[m
[32m+[m[32m// distribute, sublicense, and/or sell copies of the Software, and to permit[m
[32m+[m[32m// persons to whom the Software is furnished to do so, subject to the[m
[32m+[m[32m// following conditions:[m
[32m+[m[32m//[m
[32m+[m[32m// The above copyright notice and this permission notice shall be included[m
[32m+[m[32m// in all copies or substantial portions of the Software.[m
[32m+[m[32m//[m
[32m+[m[32m// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS[m
[32m+[m[32m// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF[m
[32m+[m[32m// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN[m
[32m+[m[32m// NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,[m
[32m+[m[32m// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR[m
[32m+[m[32m// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE[m
[32m+[m[32m// USE OR OTHER DEALINGS IN THE SOFTWARE.[m
[32m+[m
[32m+[m[32m// a duplex stream is just a stream that is both readable and writable.[m
[32m+[m[32m// Since JS doesn't have multiple prototypal inheritance, this class[m
[32m+[m[32m// prototypally inherits from Readable, and then parasitically from[m
[32m+[m[32m// Writable.[m
[32m+[m
[32m+[m[32m'use strict';[m
[32m+[m
[32m+[m[32m/*<replacement>*/[m
[32m+[m
[32m+[m[32mvar pna = require('process-nextick-args');[m
[32m+[m[32m/*</replacement>*/[m
[32m+[m
[32m+[m[32m/*<replacement>*/[m
[32m+[m[32mvar objectKeys = Object.keys || function (obj) {[m
[32m+[m[32m  var keys = [];[m
[32m+[m[32m  for (var key in obj) {[m
[32m+[m[32m    keys.push(key);[m
[32m+[m[32m  }return keys;[m
[32m+[m[32m};[m
[32m+[m[32m/*</replacement>*/[m
[32m+[m
[32m+[m[32mmodule.exports = Duplex;[m
[32m+[m
[32m+[m[32m/*<replacement>*/[m
[32m+[m[32mvar util = Object.create(require('core-util-is'));[m
[32m+[m[32mutil.inherits = require('inherits');[m
[32m+[m[32m/*</replacement>*/[m
[32m+[m
[32m+[m[32mvar Readable = require('./_stream_readable');[m
[32m+[m[32mvar Writable = require('./_stream_writable');[m
[32m+[m
[32m+[m[32mutil.inherits(Duplex, Readable);[m
[32m+[m
[32m+[m[32m{[m
[32m+[m[32m  // avoid scope creep, the keys array can then be collected[m
[32m+[m[32m  var keys = objectKeys(Writable.prototype);[m
[32m+[m[32m  for (var v = 0; v < keys.length; v++) {[m
[32m+[m[32m    var method = keys[v];[m
[32m+[m[32m    if (!Duplex.prototype[method]) Duplex.prototype[method] = Writable.prototype[method];[m
[32m+[m[32m  }[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction Duplex(options) {[m
[32m+[m[32m  if (!(this instanceof Duplex)) return new Duplex(options);[m
[32m+[m
[32m+[m[32m  Readable.call(this, options);[m
[32m+[m[32m  Writable.call(this, options);[m
[32m+[m
[32m+[m[32m  if (options && options.readable === false) this.readable = false;[m
[32m+[m
[32m+[m[32m  if (options && options.writable === false) this.writable = false;[m
[32m+[m
[32m+[m[32m  this.allowHalfOpen = true;[m
[32m+[m[32m  if (options && options.allowHalfOpen === false) this.allowHalfOpen = false;[m
[32m+[m
[32m+[m[32m  this.once('end', onend);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mObject.defineProperty(Duplex.prototype, 'writableHighWaterMark', {[m
[32m+[m[32m  // making it explicit this property is not enumerable[m
[32m+[m[32m  // because otherwise some prototype manipulation in[m
[32m+[m[32m  // userland will fail[m
[32m+[m[32m  enumerable: false,[m
[32m+[m[32m  get: function () {[m
[32m+[m[32m    return this._writableState.highWaterMark;[m
[32m+[m[32m  }[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32m// the no-half-open enforcer[m
[32m+[m[32mfunction onend() {[m
[32m+[m[32m  // if we allow half-open state, or if the writable side ended,[m
[32m+[m[32m  // then we're ok.[m
[32m+[m[32m  if (this.allowHalfOpen || this._writableState.ended) return;[m
[32m+[m
[32m+[m[32m  // no more data can be written.[m
[32m+[m[32m  // But allow more writes to happen in this tick.[m
[32m+[m[32m  pna.nextTick(onEndNT, this);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction onEndNT(self) {[m
[32m+[m[32m  self.end();[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mObject.defineProperty(Duplex.prototype, 'destroyed', {[m
[32m+[m[32m  get: function () {[m
[32m+[m[32m    if (this._readableState === undefined || this._writableState === undefined) {[m
[32m+[m[32m      return false;[m
[32m+[m[32m    }[m
[32m+[m[32m    return this._readableState.destroyed && this._writableState.destroyed;[m
[32m+[m[32m  },[m
[32m+[m[32m  set: function (value) {[m
[32m+[m[32m    // we ignore the value if the stream[m
[32m+[m[32m    // has not been initialized yet[m
[32m+[m[32m    if (this._readableState === undefined || this._writableState === undefined) {[m
[32m+[m[32m      return;[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    // backward compatibility, the user is explicitly[m
[32m+[m[32m    // managing destroyed[m
[32m+[m[32m    this._readableState.destroyed = value;[m
[32m+[m[32m    this._writableState.destroyed = value;[m
[32m+[m[32m  }[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mDuplex.prototype._destroy = function (err, cb) {[m
[32m+[m[32m  this.push(null);[m
[32m+[m[32m  this.end();[m
[32m+[m
[32m+[m[32m  pna.nextTick(cb, err);[m
[32m+[m[32m};[m
\ No newline at end of file[m
[1mdiff --git a/node_modules/readable-stream/lib/_stream_passthrough.js b/node_modules/readable-stream/lib/_stream_passthrough.js[m
[1mnew file mode 100644[m
[1mindex 0000000..612edb4[m
[1m--- /dev/null[m
[1m+++ b/node_modules/readable-stream/lib/_stream_passthrough.js[m
[36m@@ -0,0 +1,47 @@[m
[32m+[m[32m// Copyright Joyent, Inc. and other Node contributors.[m
[32m+[m[32m//[m
[32m+[m[32m// Permission is hereby granted, free of charge, to any person obtaining a[m
[32m+[m[32m// copy of this software and associated documentation files (the[m
[32m+[m[32m// "Software"), to deal in the Software without restriction, including[m
[32m+[m[32m// without limitation the rights to use, copy, modify, merge, publish,[m
[32m+[m[32m// distribute, sublicense, and/or sell copies of the Software, and to permit[m
[32m+[m[32m// persons to whom the Software is furnished to do so, subject to the[m
[32m+[m[32m// following conditions:[m
[32m+[m[32m//[m
[32m+[m[32m// The above copyright notice and this permission notice shall be included[m
[32m+[m[32m// in all copies or substantial portions of the Software.[m
[32m+[m[32m//[m
[32m+[m[32m// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS[m
[32m+[m[32m// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF[m
[32m+[m[32m// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN[m
[32m+[m[32m// NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,[m
[32m+[m[32m// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR[m
[32m+[m[32m// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE[m
[32m+[m[32m// USE OR OTHER DEALINGS IN THE SOFTWARE.[m
[32m+[m
[32m+[m[32m// a passthrough stream.[m
[32m+[m[32m// basically just the most minimal sort of Transform stream.[m
[32m+[m[32m// Every written chunk gets output as-is.[m
[32m+[m
[32m+[m[32m'use strict';[m
[32m+[m
[32m+[m[32mmodule.exports = PassThrough;[m
[32m+[m
[32m+[m[32mvar Transform = require('./_stream_transform');[m
[32m+[m
[32m+[m[32m/*<replacement>*/[m
[32m+[m[32mvar util = Object.create(require('core-util-is'));[m
[32m+[m[32mutil.inherits = require('inherits');[m
[32m+[m[32m/*</replacement>*/[m
[32m+[m
[32m+[m[32mutil.inherits(PassThrough, Transform);[m
[32m+[m
[32m+[m[32mfunction PassThrough(options) {[m
[32m+[m[32m  if (!(this instanceof PassThrough)) return new PassThrough(options);[m
[32m+[m
[32m+[m[32m  Transform.call(this, options);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mPassThrough.prototype._transform = function (chunk, encoding, cb) {[m
[32m+[m[32m  cb(null, chunk);[m
[32m+[m[32m};[m
\ No newline at end of file[m
[1mdiff --git a/node_modules/readable-stream/lib/_stream_readable.js b/node_modules/readable-stream/lib/_stream_readable.js[m
[1mnew file mode 100644[m
[1mindex 0000000..3af95cb[m
[1m--- /dev/null[m
[1m+++ b/node_modules/readable-stream/lib/_stream_readable.js[m
[36m@@ -0,0 +1,1019 @@[m
[32m+[m[32m// Copyright Joyent, Inc. and other Node contributors.[m
[32m+[m[32m//[m
[32m+[m[32m// Permission is hereby granted, free of charge, to any person obtaining a[m
[32m+[m[32m// copy of this software and associated documentation files (the[m
[32m+[m[32m// "Software"), to deal in the Software without restriction, including[m
[32m+[m[32m// without limitation the rights to use, copy, modify, merge, publish,[m
[32m+[m[32m// distribute, sublicense, and/or sell copies of the Software, and to permit[m
[32m+[m[32m// persons to whom the Software is furnished to do so, subject to the[m
[32m+[m[32m// following conditions:[m
[32m+[m[32m//[m
[32m+[m[32m// The above copyright notice and this permission notice shall be included[m
[32m+[m[32m// in all copies or substantial portions of the Software.[m
[32m+[m[32m//[m
[32m+[m[32m// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS[m
[32m+[m[32m// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF[m
[32m+[m[32m// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN[m
[32m+[m[32m// NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,[m
[32m+[m[32m// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR[m
[32m+[m[32m// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE[m
[32m+[m[32m// USE OR OTHER DEALINGS IN THE SOFTWARE.[m
[32m+[m
[32m+[m[32m'use strict';[m
[32m+[m
[32m+[m[32m/*<replacement>*/[m
[32m+[m
[32m+[m[32mvar pna = require('process-nextick-args');[m
[32m+[m[32m/*</replacement>*/[m
[32m+[m
[32m+[m[32mmodule.exports = Readable;[m
[32m+[m
[32m+[m[32m/*<replacement>*/[m
[32m+[m[32mvar isArray = require('isarray');[m
[32m+[m[32m/*</replacement>*/[m
[32m+[m
[32m+[m[32m/*<replacement>*/[m
[32m+[m[32mvar Duplex;[m
[32m+[m[32m/*</replacement>*/[m
[32m+[m
[32m+[m[32mReadable.ReadableState = ReadableState;[m
[32m+[m
[32m+[m[32m/*<replacement>*/[m
[32m+[m[32mvar EE = require('events').EventEmitter;[m
[32m+[m
[32m+[m[32mvar EElistenerCount = function (emitter, type) {[m
[32m+[m[32m  return emitter.listeners(type).length;[m
[32m+[m[32m};[m
[32m+[m[32m/*</replacement>*/[m
[32m+[m
[32m+[m[32m/*<replacement>*/[m
[32m+[m[32mvar Stream = require('./internal/streams/stream');[m
[32m+[m[32m/*</replacement>*/[m
[32m+[m
[32m+[m[32m/*<replacement>*/[m
[32m+[m
[32m+[m[32mvar Buffer = require('safe-buffer').Buffer;[m
[32m+[m[32mvar OurUint8Array = (typeof global !== 'undefined' ? global : typeof window !== 'undefined' ? window : typeof self !== 'undefined' ? self : {}).Uint8Array || function () {};[m
[32m+[m[32mfunction _uint8ArrayToBuffer(chunk) {[m
[32m+[m[32m  return Buffer.from(chunk);[m
[32m+[m[32m}[m
[32m+[m[32mfunction _isUint8Array(obj) {[m
[32m+[m[32m  return Buffer.isBuffer(obj) || obj instanceof OurUint8Array;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m/*</replacement>*/[m
[32m+[m
[32m+[m[32m/*<replacement>*/[m
[32m+[m[32mvar util = Object.create(require('core-util-is'));[m
[32m+[m[32mutil.inherits = require('inherits');[m
[32m+[m[32m/*</replacement>*/[m
[32m+[m
[32m+[m[32m/*<replacement>*/[m
[32m+[m[32mvar debugUtil = require('util');[m
[32m+[m[32mvar debug = void 0;[m
[32m+[m[32mif (debugUtil && debugUtil.debuglog) {[m
[32m+[m[32m  debug = debugUtil.debuglog('stream');[m
[32m+[m[32m} else {[m
[32m+[m[32m  debug = function () {};[m
[32m+[m[32m}[m
[32m+[m[32m/*</replacement>*/[m
[32m+[m
[32m+[m[32mvar BufferList = require('./internal/streams/BufferList');[m
[32m+[m[32mvar destroyImpl = require('./internal/streams/destroy');[m
[32m+[m[32mvar StringDecoder;[m
[32m+[m
[32m+[m[32mutil.inherits(Readable, Stream);[m
[32m+[m
[32m+[m[32mvar kProxyEvents = ['error', 'close', 'destroy', 'pause', 'resume'];[m
[32m+[m
[32m+[m[32mfunction prependListener(emitter, event, fn) {[m
[32m+[m[32m  // Sadly this is not cacheable as some libraries bundle their own[m
[32m+[m[32m  // event emitter implementation with them.[m
[32m+[m[32m  if (typeof emitter.prependListener === 'function') return emitter.prependListener(event, fn);[m
[32m+[m
[32m+[m[32m  // This is a hack to make sure that our error handler is attached before any[m
[32m+[m[32m  // userland ones.  NEVER DO THIS. This is here only because this code needs[m
[32m+[m[32m  // to continue to work with older versions of Node.js that do not include[m
[32m+[m[32m  // the prependListener() method. The goal is to eventually remove this hack.[m
[32m+[m[32m  if (!emitter._events || !emitter._events[event]) emitter.on(event, fn);else if (isArray(emitter._events[event])) emitter._events[event].unshift(fn);else emitter._events[event] = [fn, emitter._events[event]];[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction ReadableState(options, stream) {[m
[32m+[m[32m  Duplex = Duplex || require('./_stream_duplex');[m
[32m+[m
[32m+[m[32m  options = options || {};[m
[32m+[m
[32m+[m[32m  // Duplex streams are both readable and writable, but share[m
[32m+[m[32m  // the same options object.[m
[32m+[m[32m  // However, some cases require setting options to different[m
[32m+[m[32m  // values for the readable and the writable sides of the duplex stream.[m
[32m+[m[32m  // These options can be provided separately as readableXXX and writableXXX.[m
[32m+[m[32m  var isDuplex = stream instanceof Duplex;[m
[32m+[m
[32m+[m[32m  // object stream flag. Used to make read(n) ignore n and to[m
[32m+[m[32m  // make all the buffer merging and length checks go away[m
[32m+[m[32m  this.objectMode = !!options.objectMode;[m
[32m+[m
[32m+[m[32m  if (isDuplex) this.objectMode = this.objectMode || !!options.readableObjectMode;[m
[32m+[m
[32m+[m[32m  // the point at which it stops calling _read() to fill the buffer[m
[32m+[m[32m  // Note: 0 is a valid value, means "don't call _read preemptively ever"[m
[32m+[m[32m  var hwm = options.highWaterMark;[m
[32m+[m[32m  var readableHwm = options.readableHighWaterMark;[m
[32m+[m[32m  var defaultHwm = this.objectMode ? 16 : 16 * 1024;[m
[32m+[m
[32m+[m[32m  if (hwm || hwm === 0) this.highWaterMark = hwm;else if (isDuplex && (readableHwm || readableHwm === 0)) this.highWaterMark = readableHwm;else this.highWaterMark = defaultHwm;[m
[32m+[m
[32m+[m[32m  // cast to ints.[m
[32m+[m[32m  this.highWaterMark = Math.floor(this.highWaterMark);[m
[32m+[m
[32m+[m[32m  // A linked list is used to store data chunks instead of an array because the[m
[32m+[m[32m  // linked list can remove elements from the beginning faster than[m
[32m+[m[32m  // array.shift()[m
[32m+[m[32m  this.buffer = new BufferList();[m
[32m+[m[32m  this.length = 0;[m
[32m+[m[32m  this.pipes = null;[m
[32m+[m[32m  this.pipesCount = 0;[m
[32m+[m[32m  this.flowing = null;[m
[32m+[m[32m  this.ended = false;[m
[32m+[m[32m  this.endEmitted = false;[m
[32m+[m[32m  this.reading = false;[m
[32m+[m
[32m+[m[32m  // a flag to be able to tell if the event 'readable'/'data' is emitted[m
[32m+[m[32m  // immediately, or on a later tick.  We set this to true at first, because[m
[32m+[m[32m  // any actions that shouldn't happen until "later" should generally also[m
[32m+[m[32m  // not happen before the first read call.[m
[32m+[m[32m  this.sync = true;[m
[32m+[m
[32m+[m[32m  // whenever we return null, then we set a flag to say[m
[32m+[m[32m  // that we're awaiting a 'readable' event emission.[m
[32m+[m[32m  this.needReadable = false;[m
[32m+[m[32m  this.emittedReadable = false;[m
[32m+[m[32m  this.readableListening = false;[m
[32m+[m[32m  this.resumeScheduled = false;[m
[32m+[m
[32m+[m[32m  // has it been destroyed[m
[32m+[m[32m  this.destroyed = false;[m
[32m+[m
[32m+[m[32m  // Crypto is kind of old and crusty.  Historically, its default string[m
[32m+[m[32m  // encoding is 'binary' so we have to make this configurable.[m
[32m+[m[32m  // Everything else in the universe uses 'utf8', though.[m
[32m+[m[32m  this.defaultEncoding = options.defaultEncoding || 'utf8';[m
[32m+[m
[32m+[m[32m  // the number of writers that are awaiting a drain event in .pipe()s[m
[32m+[m[32m  this.awaitDrain = 0;[m
[32m+[m
[32m+[m[32m  // if true, a maybeReadMore has been scheduled[m
[32m+[m[32m  this.readingMore = false;[m
[32m+[m
[32m+[m[32m  this.decoder = null;[m
[32m+[m[32m  this.encoding = null;[m
[32m+[m[32m  if (options.encoding) {[m
[32m+[m[32m    if (!StringDecoder) StringDecoder = require('string_decoder/').StringDecoder;[m
[32m+[m[32m    this.decoder = new StringDecoder(options.encoding);[m
[32m+[m[32m    this.encoding = options.encoding;[m
[32m+[m[32m  }[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction Readable(options) {[m
[32m+[m[32m  Duplex = Duplex || require('./_stream_duplex');[m
[32m+[m
[32m+[m[32m  if (!(this instanceof Readable)) return new Readable(options);[m
[32m+[m
[32m+[m[32m  this._readableState = new ReadableState(options, this);[m
[32m+[m
[32m+[m[32m  // legacy[m
[32m+[m[32m  this.readable = true;[m
[32m+[m
[32m+[m[32m  if (options) {[m
[32m+[m[32m    if (typeof options.read === 'function') this._read = options.read;[m
[32m+[m
[32m+[m[32m    if (typeof options.destroy === 'function') this._destroy = options.destroy;[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  Stream.call(this);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mObject.defineProperty(Readable.prototype, 'destroyed', {[m
[32m+[m[32m  get: function () {[m
[32m+[m[32m    if (this._readableState === undefined) {[m
[32m+[m[32m      return false;[m
[32m+[m[32m    }[m
[32m+[m[32m    return this._readableState.destroyed;[m
[32m+[m[32m  },[m
[32m+[m[32m  set: function (value) {[m
[32m+[m[32m    // we ignore the value if the stream[m
[32m+[m[32m    // has not been initialized yet[m
[32m+[m[32m    if (!this._readableState) {[m
[32m+[m[32m      return;[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    // backward compatibility, the user is explicitly[m
[32m+[m[32m    // managing destroyed[m
[32m+[m[32m    this._readableState.destroyed = value;[m
[32m+[m[32m  }[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mReadable.prototype.destroy = destroyImpl.destroy;[m
[32m+[m[32mReadable.prototype._undestroy = destroyImpl.undestroy;[m
[32m+[m[32mReadable.prototype._destroy = function (err, cb) {[m
[32m+[m[32m  this.push(null);[m
[32m+[m[32m  cb(err);[m
[32m+[m[32m};[m
[32m+[m
[32m+[m[32m// Manually shove something into the read() buffer.[m
[32m+[m[32m// This returns true if the highWaterMark has not been hit yet,[m
[32m+[m[32m// similar to how Writable.write() returns true if you should[m
[32m+[m[32m// write() some more.[m
[32m+[m[32mReadable.prototype.push = function (chunk, encoding) {[m
[32m+[m[32m  var state = this._readableState;[m
[32m+[m[32m  var skipChunkCheck;[m
[32m+[m
[32m+[m[32m  if (!state.objectMode) {[m
[32m+[m[32m    if (typeof chunk === 'string') {[m
[32m+[m[32m      encoding = encoding || state.defaultEncoding;[m
[32m+[m[32m      if (encoding !== state.encoding) {[m
[32m+[m[32m        chunk = Buffer.from(chunk, encoding);[m
[32m+[m[32m        encoding = '';[m
[32m+[m[32m      }[m
[32m+[m[32m      skipChunkCheck = true;[m
[32m+[m[32m    }[m
[32m+[m[32m  } else {[m
[32m+[m[32m    skipChunkCheck = true;[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  return readableAddChunk(this, chunk, encoding, false, skipChunkCheck);[m
[32m+[m[32m};[m
[32m+[m
[32m+[m[32m// Unshift should *always* be something directly out of read()[m
[32m+[m[32mReadable.prototype.unshift = function (chunk) {[m
[32m+[m[32m  return readableAddChunk(this, chunk, null, true, false);[m
[32m+[m[32m};[m
[32m+[m
[32m+[m[32mfunction readableAddChunk(stream, chunk, encoding, addToFront, skipChunkCheck) {[m
[32m+[m[32m  var state = stream._readableState;[m
[32m+[m[32m  if (chunk === null) {[m
[32m+[m[32m    state.reading = false;[m
[32m+[m[32m    onEofChunk(stream, state);[m
[32m+[m[32m  } else {[m
[32m+[m[32m    var er;[m
[32m+[m[32m    if (!skipChunkCheck) er = chunkInvalid(state, chunk);[m
[32m+[m[32m    if (er) {[m
[32m+[m[32m      stream.emit('error', er);[m
[32m+[m[32m    } else if (state.objectMode || chunk && chunk.length > 0) {[m
[32m+[m[32m      if (typeof chunk !== 'string' && !state.objectMode && Object.getPrototypeOf(chunk) !== Buffer.prototype) {[m
[32m+[m[32m        chunk = _uint8ArrayToBuffer(chunk);[m
[32m+[m[32m      }[m
[32m+[m
[32m+[m[32m      if (addToFront) {[m
[32m+[m[32m        if (state.endEmitted) stream.emit('error', new Error('stream.unshift() after end event'));else addChunk(stream, state, chunk, true);[m
[32m+[m[32m      } else if (state.ended) {[m
[32m+[m[32m        stream.emit('error', new Error('stream.push() after EOF'));[m
[32m+[m[32m      } else {[m
[32m+[m[32m        state.reading = false;[m
[32m+[m[32m        if (state.decoder && !encoding) {[m
[32m+[m[32m          chunk = state.decoder.write(chunk);[m
[32m+[m[32m          if (state.objectMode || chunk.length !== 0) addChunk(stream, state, chunk, false);else maybeReadMore(stream, state);[m
[32m+[m[32m        } else {[m
[32m+[m[32m          addChunk(stream, state, chunk, false);[m
[32m+[m[32m        }[m
[32m+[m[32m      }[m
[32m+[m[32m    } else if (!addToFront) {[m
[32m+[m[32m      state.reading = false;[m
[32m+[m[32m    }[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  return needMoreData(state);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction addChunk(stream, state, chunk, addToFront) {[m
[32m+[m[32m  if (state.flowing && state.length === 0 && !state.sync) {[m
[32m+[m[32m    stream.emit('data', chunk);[m
[32m+[m[32m    stream.read(0);[m
[32m+[m[32m  } else {[m
[32m+[m[32m    // update the buffer info.[m
[32m+[m[32m    state.length += state.objectMode ? 1 : chunk.length;[m
[32m+[m[32m    if (addToFront) state.buffer.unshift(chunk);else state.buffer.push(chunk);[m
[32m+[m
[32m+[m[32m    if (state.needReadable) emitReadable(stream);[m
[32m+[m[32m  }[m
[32m+[m[32m  maybeReadMore(stream, state);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction chunkInvalid(state, chunk) {[m
[32m+[m[32m  var er;[m
[32m+[m[32m  if (!_isUint8Array(chunk) && typeof chunk !== 'string' && chunk !== undefined && !state.objectMode) {[m
[32m+[m[32m    er = new TypeError('Invalid non-string/buffer chunk');[m
[32m+[m[32m  }[m
[32m+[m[32m  return er;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m// if it's past the high water mark, we can push in some more.[m
[32m+[m[32m// Also, if we have no data yet, we can stand some[m
[32m+[m[32m// more bytes.  This is to work around cases where hwm=0,[m
[32m+[m[32m// such as the repl.  Also, if the push() triggered a[m
[32m+[m[32m// readable event, and the user called read(largeNumber) such that[m
[32m+[m[32m// needReadable was set, then we ought to push more, so that another[m
[32m+[m[32m// 'readable' event will be triggered.[m
[32m+[m[32mfunction needMoreData(state) {[m
[32m+[m[32m  return !state.ended && (state.needReadable || state.length < state.highWaterMark || state.length === 0);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mReadable.prototype.isPaused = function () {[m
[32m+[m[32m  return this._readableState.flowing === false;[m
[32m+[m[32m};[m
[32m+[m
[32m+[m[32m// backwards compatibility.[m
[32m+[m[32mReadable.prototype.setEncoding = function (enc) {[m
[32m+[m[32m  if (!StringDecoder) StringDecoder = require('string_decoder/').StringDecoder;[m
[32m+[m[32m  this._readableState.decoder = new StringDecoder(enc);[m
[32m+[m[32m  this._readableState.encoding = enc;[m
[32m+[m[32m  return this;[m
[32m+[m[32m};[m
[32m+[m
[32m+[m[32m// Don't raise the hwm > 8MB[m
[32m+[m[32mvar MAX_HWM = 0x800000;[m
[32m+[m[32mfunction computeNewHighWaterMark(n) {[m
[32m+[m[32m  if (n >= MAX_HWM) {[m
[32m+[m[32m    n = MAX_HWM;[m
[32m+[m[32m  } else {[m
[32m+[m[32m    // Get the next highest power of 2 to prevent increasing hwm excessively in[m
[32m+[m[32m    // tiny amounts[m
[32m+[m[32m    n--;[m
[32m+[m[32m    n |= n >>> 1;[m
[32m+[m[32m    n |= n >>> 2;[m
[32m+[m[32m    n |= n >>> 4;[m
[32m+[m[32m    n |= n >>> 8;[m
[32m+[m[32m    n |= n >>> 16;[m
[32m+[m[32m    n++;[m
[32m+[m[32m  }[m
[32m+[m[32m  return n;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m// This function is designed to be inlinable, so please take care when making[m
[32m+[m[32m// changes to the function body.[m
[32m+[m[32mfunction howMuchToRead(n, state) {[m
[32m+[m[32m  if (n <= 0 || state.length === 0 && state.ended) return 0;[m
[32m+[m[32m  if (state.objectMode) return 1;[m
[32m+[m[32m  if (n !== n) {[m
[32m+[m[32m    // Only flow one buffer at a time[m
[32m+[m[32m    if (state.flowing && state.length) return state.buffer.head.data.length;else return state.length;[m
[32m+[m[32m  }[m
[32m+[m[32m  // If we're asking for more than the current hwm, then raise the hwm.[m
[32m+[m[32m  if (n > state.highWaterMark) state.highWaterMark = computeNewHighWaterMark(n);[m
[32m+[m[32m  if (n <= state.length) return n;[m
[32m+[m[32m  // Don't have enough[m
[32m+[m[32m  if (!state.ended) {[m
[32m+[m[32m    state.needReadable = true;[m
[32m+[m[32m    return 0;[m
[32m+[m[32m  }[m
[32m+[m[32m  return state.length;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m// you can override either this method, or the async _read(n) below.[m
[32m+[m[32mReadable.prototype.read = function (n) {[m
[32m+[m[32m  debug('read', n);[m
[32m+[m[32m  n = parseInt(n, 10);[m
[32m+[m[32m  var state = this._readableState;[m
[32m+[m[32m  var nOrig = n;[m
[32m+[m
[32m+[m[32m  if (n !== 0) state.emittedReadable = false;[m
[32m+[m
[32m+[m[32m  // if we're doing read(0) to trigger a readable event, but we[m
[32m+[m[32m  // already have a bunch of data in the buffer, then just trigger[m
[32m+[m[32m  // the 'readable' event and move on.[m
[32m+[m[32m  if (n === 0 && state.needReadable && (state.length >= state.highWaterMark || state.ended)) {[m
[32m+[m[32m    debug('read: emitReadable', state.length, state.ended);[m
[32m+[m[32m    if (state.length === 0 && state.ended) endReadable(this);else emitReadable(this);[m
[32m+[m[32m    return null;[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  n = howMuchToRead(n, state);[m
[32m+[m
[32m+[m[32m  // if we've ended, and we're now clear, then finish it up.[m
[32m+[m[32m  if (n === 0 && state.ended) {[m
[32m+[m[32m    if (state.length === 0) endReadable(this);[m
[32m+[m[32m    return null;[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  // All the actual chunk generation logic needs to be[m
[32m+[m[32m  // *below* the call to _read.  The reason is that in certain[m
[32m+[m[32m  // synthetic stream cases, such as passthrough streams, _read[m
[32m+[m[32m  // may be a completely synchronous operation which may change[m
[32m+[m[32m  // the state of the read buffer, providing enough data when[m
[32m+[m[32m  // before there was *not* enough.[m
[32m+[m[32m  //[m
[32m+[m[32m  // So, the steps are:[m
[32m+[m[32m  // 1. Figure out what the state of things will be after we do[m
[32m+[m[32m  // a read from the buffer.[m
[32m+[m[32m  //[m
[32m+[m[32m  // 2. If that resulting state will trigger a _read, then call _read.[m
[32m+[m[32m  // Note that this may be asynchronous, or synchronous.  Yes, it is[m
[32m+[m[32m  // deeply ugly to write APIs this way, but that still doesn't mean[m
[32m+[m[32m  // that the Readable class should behave improperly, as streams are[m
[32m+[m[32m  // designed to be sync/async agnostic.[m
[32m+[m[32m  // Take note if the _read call is sync or async (ie, if the read call[m
[32m+[m[32m  // has returned yet), so that we know whether or not it's safe to emit[m
[32m+[m[32m  // 'readable' etc.[m
[32m+[m[32m  //[m
[32m+[m[32m  // 3. Actually pull the requested chunks out of the buffer and return.[m
[32m+[m
[32m+[m[32m  // if we need a readable event, then we need to do some reading.[m
[32m+[m[32m  var doRead = state.needReadable;[m
[32m+[m[32m  debug('need readable', doRead);[m
[32m+[m
[32m+[m[32m  // if we currently have less than the highWaterMark, then also read some[m
[32m+[m[32m  if (state.length === 0 || state.length - n < state.highWaterMark) {[m
[32m+[m[32m    doRead = true;[m
[32m+[m[32m    debug('length less than watermark', doRead);[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  // however, if we've ended, then there's no point, and if we're already[m
[32m+[m[32m  // reading, then it's unnecessary.[m
[32m+[m[32m  if (state.ended || state.reading) {[m
[32m+[m[32m    doRead = false;[m
[32m+[m[32m    debug('reading or ended', doRead);[m
[32m+[m[32m  } else if (doRead) {[m
[32m+[m[32m    debug('do read');[m
[32m+[m[32m    state.reading = true;[m
[32m+[m[32m    state.sync = true;[m
[32m+[m[32m    // if the length is currently zero, then we *need* a readable event.[m
[32m+[m[32m    if (state.length === 0) state.needReadable = true;[m
[32m+[m[32m    // call internal read method[m
[32m+[m[32m    this._read(state.highWaterMark);[m
[32m+[m[32m    state.sync = false;[m
[32m+[m[32m    // If _read pushed data synchronously, then `reading` will be false,[m
[32m+[m[32m    // and we need to re-evaluate how much data we can return to the user.[m
[32m+[m[32m    if (!state.reading) n = howMuchToRead(nOrig, state);[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  var ret;[m
[32m+[m[32m  if (n > 0) ret = fromList(n, state);else ret = null;[m
[32m+[m
[32m+[m[32m  if (ret === null) {[m
[32m+[m[32m    state.needReadable = true;[m
[32m+[m[32m    n = 0;[m
[32m+[m[32m  } else {[m
[32m+[m[32m    state.length -= n;[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  if (state.length === 0) {[m
[32m+[m[32m    // If we have nothing in the buffer, then we want to know[m
[32m+[m[32m    // as soon as we *do* get something into the buffer.[m
[32m+[m[32m    if (!state.ended) state.needReadable = true;[m
[32m+[m
[32m+[m[32m    // If we tried to read() past the EOF, then emit end on the next tick.[m
[32m+[m[32m    if (nOrig !== n && state.ended) endReadable(this);[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  if (ret !== null) this.emit('data', ret);[m
[32m+[m
[32m+[m[32m  return ret;[m
[32m+[m[32m};[m
[32m+[m
[32m+[m[32mfunction onEofChunk(stream, state) {[m
[32m+[m[32m  if (state.ended) return;[m
[32m+[m[32m  if (state.decoder) {[m
[32m+[m[32m    var chunk = state.decoder.end();[m
[32m+[m[32m    if (chunk && chunk.length) {[m
[32m+[m[32m      state.buffer.push(chunk);[m
[32m+[m[32m      state.length += state.objectMode ? 1 : chunk.length;[m
[32m+[m[32m    }[m
[32m+[m[32m  }[m
[32m+[m[32m  state.ended = true;[m
[32m+[m
[32m+[m[32m  // emit 'readable' now to make sure it gets picked up.[m
[32m+[m[32m  emitReadable(stream);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m// Don't emit readable right away in sync mode, because this can trigger[m
[32m+[m[32m// another read() call => stack overflow.  This way, it might trigger[m
[32m+[m[32m// a nextTick recursion warning, but that's not so bad.[m
[32m+[m[32mfunction emitReadable(stream) {[m
[32m+[m[32m  var state = stream._readableState;[m
[32m+[m[32m  state.needReadable = false;[m
[32m+[m[32m  if (!state.emittedReadable) {[m
[32m+[m[32m    debug('emitReadable', state.flowing);[m
[32m+[m[32m    state.emittedReadable = true;[m
[32m+[m[32m    if (state.sync) pna.nextTick(emitReadable_, stream);else emitReadable_(stream);[m
[32m+[m[32m  }[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction emitReadable_(stream) {[m
[32m+[m[32m  debug('emit readable');[m
[32m+[m[32m  stream.emit('readable');[m
[32m+[m[32m  flow(stream);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m// at this point, the user has presumably seen the 'readable' event,[m
[32m+[m[32m// and called read() to consume some data.  that may have triggered[m
[32m+[m[32m// in turn another _read(n) call, in which case reading = true if[m
[32m+[m[32m// it's in progress.[m
[32m+[m[32m// However, if we're not ended, or reading, and the length < hwm,[m
[32m+[m[32m// then go ahead and try to read some more preemptively.[m
[32m+[m[32mfunction maybeReadMore(stream, state) {[m
[32m+[m[32m  if (!state.readingMore) {[m
[32m+[m[32m    state.readingMore = true;[m
[32m+[m[32m    pna.nextTick(maybeReadMore_, stream, state);[m
[32m+[m[32m  }[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction maybeReadMore_(stream, state) {[m
[32m+[m[32m  var len = state.length;[m
[32m+[m[32m  while (!state.reading && !state.flowing && !state.ended && state.length < state.highWaterMark) {[m
[32m+[m[32m    debug('maybeReadMore read 0');[m
[32m+[m[32m    stream.read(0);[m
[32m+[m[32m    if (len === state.length)[m
[32m+[m[32m      // didn't get any data, stop spinning.[m
[32m+[m[32m      break;else len = state.length;[m
[32m+[m[32m  }[m
[32m+[m[32m  state.readingMore = false;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m// abstract method.  to be overridden in specific implementation classes.[m
[32m+[m[32m// call cb(er, data) where data is <= n in length.[m
[32m+[m[32m// for virtual (non-string, non-buffer) streams, "length" is somewhat[m
[32m+[m[32m// arbitrary, and perhaps not very meaningful.[m
[32m+[m[32mReadable.prototype._read = function (n) {[m
[32m+[m[32m  this.emit('error', new Error('_read() is not implemented'));[m
[32m+[m[32m};[m
[32m+[m
[32m+[m[32mReadable.prototype.pipe = function (dest, pipeOpts) {[m
[32m+[m[32m  var src = this;[m
[32m+[m[32m  var state = this._readableState;[m
[32m+[m
[32m+[m[32m  switch (state.pipesCount) {[m
[32m+[m[32m    case 0:[m
[32m+[m[32m      state.pipes = dest;[m
[32m+[m[32m      break;[m
[32m+[m[32m    case 1:[m
[32m+[m[32m      state.pipes = [state.pipes, dest];[m
[32m+[m[32m      break;[m
[32m+[m[32m    default:[m
[32m+[m[32m      state.pipes.push(dest);[m
[32m+[m[32m      break;[m
[32m+[m[32m  }[m
[32m+[m[32m  state.pipesCount += 1;[m
[32m+[m[32m  debug('pipe count=%d opts=%j', state.pipesCount, pipeOpts);[m
[32m+[m
[32m+[m[32m  var doEnd = (!pipeOpts || pipeOpts.end !== false) && dest !== process.stdout && dest !== process.stderr;[m
[32m+[m
[32m+[m[32m  var endFn = doEnd ? onend : unpipe;[m
[32m+[m[32m  if (state.endEmitted) pna.nextTick(endFn);else src.once('end', endFn);[m
[32m+[m
[32m+[m[32m  dest.on('unpipe', onunpipe);[m
[32m+[m[32m  function onunpipe(readable, unpipeInfo) {[m
[32m+[m[32m    debug('onunpipe');[m
[32m+[m[32m    if (readable === src) {[m
[32m+[m[32m      if (unpipeInfo && unpipeInfo.hasUnpiped === false) {[m
[32m+[m[32m        unpipeInfo.hasUnpiped = true;[m
[32m+[m[32m        cleanup();[m
[32m+[m[32m      }[m
[32m+[m[32m    }[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  function onend() {[m
[32m+[m[32m    debug('onend');[m
[32m+[m[32m    dest.end();[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  // when the dest drains, it reduces the awaitDrain counter[m
[32m+[m[32m  // on the source.  This would be more elegant with a .once()[m
[32m+[m[32m  // handler in flow(), but adding and removing repeatedly is[m
[32m+[m[32m  // too slow.[m
[32m+[m[32m  var ondrain = pipeOnDrain(src);[m
[32m+[m[32m  dest.on('drain', ondrain);[m
[32m+[m
[32m+[m[32m  var cleanedUp = false;[m
[32m+[m[32m  function cleanup() {[m
[32m+[m[32m    debug('cleanup');[m
[32m+[m[32m    // cleanup event handlers once the pipe is broken[m
[32m+[m[32m    dest.removeListener('close', onclose);[m
[32m+[m[32m    dest.removeListener('finish', onfinish);[m
[32m+[m[32m    dest.removeListener('drain', ondrain);[m
[32m+[m[32m    dest.removeListener('error', onerror);[m
[32m+[m[32m    dest.removeListener('unpipe', onunpipe);[m
[32m+[m[32m    src.removeListener('end', onend);[m
[32m+[m[32m    src.removeListener('end', unpipe);[m
[32m+[m[32m    src.removeListener('data', ondata);[m
[32m+[m
[32m+[m[32m    cleanedUp = true;[m
[32m+[m
[32m+[m[32m    // if the reader is waiting for a drain event from this[m
[32m+[m[32m    // specific writer, then it would cause it to never start[m
[32m+[m[32m    // flowing again.[m
[32m+[m[32m    // So, if this is awaiting a drain, then we just call it now.[m
[32m+[m[32m    // If we don't know, then assume that we are waiting for one.[m
[32m+[m[32m    if (state.awaitDrain && (!dest._writableState || dest._writableState.needDrain)) ondrain();[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  // If the user pushes more data while we're writing to dest then we'll end up[m
[32m+[m[32m  // in ondata again. However, we only want to increase awaitDrain once because[m
[32m+[m[32m  // dest will only emit one 'drain' event for the multiple writes.[m
[32m+[m[32m  // => Introduce a guard on increasing awaitDrain.[m
[32m+[m[32m  var increasedAwaitDrain = false;[m
[32m+[m[32m  src.on('data', ondata);[m
[32m+[m[32m  function ondata(chunk) {[m
[32m+[m[32m    debug('ondata');[m
[32m+[m[32m    increasedAwaitDrain = false;[m
[32m+[m[32m    var ret = dest.write(chunk);[m
[32m+[m[32m    if (false === ret && !increasedAwaitDrain) {[m
[32m+[m[32m      // If the user unpiped during `dest.write()`, it is possible[m
[32m+[m[32m      // to get stuck in a permanently paused state if that write[m
[32m+[m[32m      // also returned false.[m
[32m+[m[32m      // => Check whether `dest` is still a piping destination.[m
[32m+[m[32m      if ((state.pipesCount === 1 && state.pipes === dest || state.pipesCount > 1 && indexOf(state.pipes, dest) !== -1) && !cleanedUp) {[m
[32m+[m[32m        debug('false write response, pause', state.awaitDrain);[m
[32m+[m[32m        state.awaitDrain++;[m
[32m+[m[32m        increasedAwaitDrain = true;[m
[32m+[m[32m      }[m
[32m+[m[32m      src.pause();[m
[32m+[m[32m    }[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  // if the dest has an error, then stop piping into it.[m
[32m+[m[32m  // however, don't suppress the throwing behavior for this.[m
[32m+[m[32m  function onerror(er) {[m
[32m+[m[32m    debug('onerror', er);[m
[32m+[m[32m    unpipe();[m
[32m+[m[32m    dest.removeListener('error', onerror);[m
[32m+[m[32m    if (EElistenerCount(dest, 'error') === 0) dest.emit('error', er);[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  // Make sure our error handler is attached before userland ones.[m
[32m+[m[32m  prependListener(dest, 'error', onerror);[m
[32m+[m
[32m+[m[32m  // Both close and finish should trigger unpipe, but only once.[m
[32m+[m[32m  function onclose() {[m
[32m+[m[32m    dest.removeListener('finish', onfinish);[m
[32m+[m[32m    unpipe();[m
[32m+[m[32m  }[m
[32m+[m[32m  dest.once('close', onclose);[m
[32m+[m[32m  function onfinish() {[m
[32m+[m[32m    debug('onfinish');[m
[32m+[m[32m    dest.removeListener('close', onclose);[m
[32m+[m[32m    unpipe();[m
[32m+[m[32m  }[m
[32m+[m[32m  dest.once('finish', onfinish);[m
[32m+[m
[32m+[m[32m  function unpipe() {[m
[32m+[m[32m    debug('unpipe');[m
[32m+[m[32m    src.unpipe(dest);[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  // tell the dest that it's being piped to[m
[32m+[m[32m  dest.emit('pipe', src);[m
[32m+[m
[32m+[m[32m  // start the flow if it hasn't been started already.[m
[32m+[m[32m  if (!state.flowing) {[m
[32m+[m[32m    debug('pipe resume');[m
[32m+[m[32m    src.resume();[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  return dest;[m
[32m+[m[32m};[m
[32m+[m
[32m+[m[32mfunction pipeOnDrain(src) {[m
[32m+[m[32m  return function () {[m
[32m+[m[32m    var state = src._readableState;[m
[32m+[m[32m    debug('pipeOnDrain', state.awaitDrain);[m
[32m+[m[32m    if (state.awaitDrain) state.awaitDrain--;[m
[32m+[m[32m    if (state.awaitDrain === 0 && EElistenerCount(src, 'data')) {[m
[32m+[m[32m      state.flowing = true;[m
[32m+[m[32m      flow(src);[m
[32m+[m[32m    }[m
[32m+[m[32m  };[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mReadable.prototype.unpipe = function (dest) {[m
[32m+[m[32m  var state = this._readableState;[m
[32m+[m[32m  var unpipeInfo = { hasUnpiped: false };[m
[32m+[m
[32m+[m[32m  // if we're not piping anywhere, then do nothing.[m
[32m+[m[32m  if (state.pipesCount === 0) return this;[m
[32m+[m
[32m+[m[32m  // just one destination.  most common case.[m
[32m+[m[32m  if (state.pipesCount === 1) {[m
[32m+[m[32m    // passed in one, but it's not the right one.[m
[32m+[m[32m    if (dest && dest !== state.pipes) return this;[m
[32m+[m
[32m+[m[32m    if (!dest) dest = state.pipes;[m
[32m+[m
[32m+[m[32m    // got a match.[m
[32m+[m[32m    state.pipes = null;[m
[32m+[m[32m    state.pipesCount = 0;[m
[32m+[m[32m    state.flowing = false;[m
[32m+[m[32m    if (dest) dest.emit('unpipe', this, unpipeInfo);[m
[32m+[m[32m    return this;[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  // slow case. multiple pipe destinations.[m
[32m+[m
[32m+[m[32m  if (!dest) {[m
[32m+[m[32m    // remove all.[m
[32m+[m[32m    var dests = state.pipes;[m
[32m+[m[32m    var len = state.pipesCount;[m
[32m+[m[32m    state.pipes = null;[m
[32m+[m[32m    state.pipesCount = 0;[m
[32m+[m[32m    state.flowing = false;[m
[32m+[m
[32m+[m[32m    for (var i = 0; i < len; i++) {[m
[32m+[m[32m      dests[i].emit('unpipe', this, { hasUnpiped: false });[m
[32m+[m[32m    }return this;[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  // try to find the right one.[m
[32m+[m[32m  var index = indexOf(state.pipes, dest);[m
[32m+[m[32m  if (index === -1) return this;[m
[32m+[m
[32m+[m[32m  state.pipes.splice(index, 1);[m
[32m+[m[32m  state.pipesCount -= 1;[m
[32m+[m[32m  if (state.pipesCount === 1) state.pipes = state.pipes[0];[m
[32m+[m
[32m+[m[32m  dest.emit('unpipe', this, unpipeInfo);[m
[32m+[m
[32m+[m[32m  return this;[m
[32m+[m[32m};[m
[32m+[m
[32m+[m[32m// set up data events if they are asked for[m
[32m+[m[32m// Ensure readable listeners eventually get something[m
[32m+[m[32mReadable.prototype.on = function (ev, fn) {[m
[32m+[m[32m  var res = Stream.prototype.on.call(this, ev, fn);[m
[32m+[m
[32m+[m[32m  if (ev === 'data') {[m
[32m+[m[32m    // Start flowing on next tick if stream isn't explicitly paused[m
[32m+[m[32m    if (this._readableState.flowing !== false) this.resume();[m
[32m+[m[32m  } else if (ev === 'readable') {[m
[32m+[m[32m    var state = this._readableState;[m
[32m+[m[32m    if (!state.endEmitted && !state.readableListening) {[m
[32m+[m[32m      state.readableListening = state.needReadable = true;[m
[32m+[m[32m      state.emittedReadable = false;[m
[32m+[m[32m      if (!state.reading) {[m
[32m+[m[32m        pna.nextTick(nReadingNextTick, this);[m
[32m+[m[32m      } else if (state.length) {[m
[32m+[m[32m        emitReadable(this);[m
[32m+[m[32m      }[m
[32m+[m[32m    }[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  return res;[m
[32m+[m[32m};[m
[32m+[m[32mReadable.prototype.addListener = Readable.prototype.on;[m
[32m+[m
[32m+[m[32mfunction nReadingNextTick(self) {[m
[32m+[m[32m  debug('readable nexttick read 0');[m
[32m+[m[32m  self.read(0);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m// pause() and resume() are remnants of the legacy readable stream API[m
[32m+[m[32m// If the user uses them, then switch into old mode.[m
[32m+[m[32mReadable.prototype.resume = function () {[m
[32m+[m[32m  var state = this._readableState;[m
[32m+[m[32m  if (!state.flowing) {[m
[32m+[m[32m    debug('resume');[m
[32m+[m[32m    state.flowing = true;[m
[32m+[m[32m    resume(this, state);[m
[32m+[m[32m  }[m
[32m+[m[32m  return this;[m
[32m+[m[32m};[m
[32m+[m
[32m+[m[32mfunction resume(stream, state) {[m
[32m+[m[32m  if (!state.resumeScheduled) {[m
[32m+[m[32m    state.resumeScheduled = true;[m
[32m+[m[32m    pna.nextTick(resume_, stream, state);[m
[32m+[m[32m  }[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction resume_(stream, state) {[m
[32m+[m[32m  if (!state.reading) {[m
[32m+[m[32m    debug('resume read 0');[m
[32m+[m[32m    stream.read(0);[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  state.resumeScheduled = false;[m
[32m+[m[32m  state.awaitDrain = 0;[m
[32m+[m[32m  stream.emit('resume');[m
[32m+[m[32m  flow(stream);[m
[32m+[m[32m  if (state.flowing && !state.reading) stream.read(0);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mReadable.prototype.pause = function () {[m
[32m+[m[32m  debug('call pause flowing=%j', this._readableState.flowing);[m
[32m+[m[32m  if (false !== this._readableState.flowing) {[m
[32m+[m[32m    debug('pause');[m
[32m+[m[32m    this._readableState.flowing = false;[m
[32m+[m[32m    this.emit('pause');[m
[32m+[m[32m  }[m
[32m+[m[32m  return this;[m
[32m+[m[32m};[m
[32m+[m
[32m+[m[32mfunction flow(stream) {[m
[32m+[m[32m  var state = stream._readableState;[m
[32m+[m[32m  debug('flow', state.flowing);[m
[32m+[m[32m  while (state.flowing && stream.read() !== null) {}[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m// wrap an old-style stream as the async data source.[m
[32m+[m[32m// This is *not* part of the readable stream interface.[m
[32m+[m[32m// It is an ugly unfortunate mess of history.[m
[32m+[m[32mReadable.prototype.wrap = function (stream) {[m
[32m+[m[32m  var _this = this;[m
[32m+[m
[32m+[m[32m  var state = this._readableState;[m
[32m+[m[32m  var paused = false;[m
[32m+[m
[32m+[m[32m  stream.on('end', function () {[m
[32m+[m[32m    debug('wrapped end');[m
[32m+[m[32m    if (state.decoder && !state.ended) {[m
[32m+[m[32m      var chunk = state.decoder.end();[m
[32m+[m[32m      if (chunk && chunk.length) _this.push(chunk);[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    _this.push(null);[m
[32m+[m[32m  });[m
[32m+[m
[32m+[m[32m  stream.on('data', function (chunk) {[m
[32m+[m[32m    debug('wrapped data');[m
[32m+[m[32m    if (state.decoder) chunk = state.decoder.write(chunk);[m
[32m+[m
[32m+[m[32m    // don't skip over falsy values in objectMode[m
[32m+[m[32m    if (state.objectMode && (chunk === null || chunk === undefined)) return;else if (!state.objectMode && (!chunk || !chunk.length)) return;[m
[32m+[m
[32m+[m[32m    var ret = _this.push(chunk);[m
[32m+[m[32m    if (!ret) {[m
[32m+[m[32m      paused = true;[m
[32m+[m[32m      stream.pause();[m
[32m+[m[32m    }[m
[32m+[m[32m  });[m
[32m+[m
[32m+[m[32m  // proxy all the other methods.[m
[32m+[m[32m  // important when wrapping filters and duplexes.[m
[32m+[m[32m  for (var i in stream) {[m
[32m+[m[32m    if (this[i] === undefined && typeof stream[i] === 'function') {[m
[32m+[m[32m      this[i] = function (method) {[m
[32m+[m[32m        return function () {[m
[32m+[m[32m          return stream[method].apply(stream, arguments);[m
[32m+[m[32m        };[m
[32m+[m[32m      }(i);[m
[32m+[m[32m    }[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  // proxy certain important events.[m
[32m+[m[32m  for (var n = 0; n < kProxyEvents.length; n++) {[m
[32m+[m[32m    stream.on(kProxyEvents[n], this.emit.bind(this, kProxyEvents[n]));[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  // when we try to consume some more bytes, simply unpause the[m
[32m+[m[32m  // underlying stream.[m
[32m+[m[32m  this._read = function (n) {[m
[32m+[m[32m    debug('wrapped _read', n);[m
[32m+[m[32m    if (paused) {[m
[32m+[m[32m      paused = false;[m
[32m+[m[32m      stream.resume();[m
[32m+[m[32m    }[m
[32m+[m[32m  };[m
[32m+[m
[32m+[m[32m  return this;[m
[32m+[m[32m};[m
[32m+[m
[32m+[m[32mObject.defineProperty(Readable.prototype, 'readableHighWaterMark', {[m
[32m+[m[32m  // making it explicit this property is not enumerable[m
[32m+[m[32m  // because otherwise some prototype manipulation in[m
[32m+[m[32m  // userland will fail[m
[32m+[m[32m  enumerable: false,[m
[32m+[m[32m  get: function () {[m
[32m+[m[32m    return this._readableState.highWaterMark;[m
[32m+[m[32m  }[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32m// exposed for testing purposes only.[m
[32m+[m[32mReadable._fromList = fromList;[m
[32m+[m
[32m+[m[32m// Pluck off n bytes from an array of buffers.[m
[32m+[m[32m// Length is the combined lengths of all the buffers in the list.[m
[32m+[m[32m// This function is designed to be inlinable, so please take care when making[m
[32m+[m[32m// changes to the function body.[m
[32m+[m[32mfunction fromList(n, state) {[m
[32m+[m[32m  // nothing buffered[m
[32m+[m[32m  if (state.length === 0) return null;[m
[32m+[m
[32m+[m[32m  var ret;[m
[32m+[m[32m  if (state.objectMode) ret = state.buffer.shift();else if (!n || n >= state.length) {[m
[32m+[m[32m    // read it all, truncate the list[m
[32m+[m[32m    if (state.decoder) ret = state.buffer.join('');else if (state.buffer.length === 1) ret = state.buffer.head.data;else ret = state.buffer.concat(state.length);[m
[32m+[m[32m    state.buffer.clear();[m
[32m+[m[32m  } else {[m
[32m+[m[32m    // read part of list[m
[32m+[m[32m    ret = fromListPartial(n, state.buffer, state.decoder);[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  return ret;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m// Extracts only enough buffered data to satisfy the amount requested.[m
[32m+[m[32m// This function is designed to be inlinable, so please take care when making[m
[32m+[m[32m// changes to the function body.[m
[32m+[m[32mfunction fromListPartial(n, list, hasStrings) {[m
[32m+[m[32m  var ret;[m
[32m+[m[32m  if (n < list.head.data.length) {[m
[32m+[m[32m    // slice is the same for buffers and strings[m
[32m+[m[32m    ret = list.head.data.slice(0, n);[m
[32m+[m[32m    list.head.data = list.head.data.slice(n);[m
[32m+[m[32m  } else if (n === list.head.data.length) {[m
[32m+[m[32m    // first chunk is a perfect match[m
[32m+[m[32m    ret = list.shift();[m
[32m+[m[32m  } else {[m
[32m+[m[32m    // result spans more than one buffer[m
[32m+[m[32m    ret = hasStrings ? copyFromBufferString(n, list) : copyFromBuffer(n, list);[m
[32m+[m[32m  }[m
[32m+[m[32m  return ret;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m// Copies a specified amount of characters from the list of buffered data[m
[32m+[m[32m// chunks.[m
[32m+[m[32m// This function is designed to be inlinable, so please take care when making[m
[32m+[m[32m// changes to the function body.[m
[32m+[m[32mfunction copyFromBufferString(n, list) {[m
[32m+[m[32m  var p = list.head;[m
[32m+[m[32m  var c = 1;[m
[32m+[m[32m  var ret = p.data;[m
[32m+[m[32m  n -= ret.length;[m
[32m+[m[32m  while (p = p.next) {[m
[32m+[m[32m    var str = p.data;[m
[32m+[m[32m    var nb = n > str.length ? str.length : n;[m
[32m+[m[32m    if (nb === str.length) ret += str;else ret += str.slice(0, n);[m
[32m+[m[32m    n -= nb;[m
[32m+[m[32m    if (n === 0) {[m
[32m+[m[32m      if (nb === str.length) {[m
[32m+[m[32m        ++c;[m
[32m+[m[32m        if (p.next) list.head = p.next;else list.head = list.tail = null;[m
[32m+[m[32m      } else {[m
[32m+[m[32m        list.head = p;[m
[32m+[m[32m        p.data = str.slice(nb);[m
[32m+[m[32m      }[m
[32m+[m[32m      break;[m
[32m+[m[32m    }[m
[32m+[m[32m    ++c;[m
[32m+[m[32m  }[m
[32m+[m[32m  list.length -= c;[m
[32m+[m[32m  return ret;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m// Copies a specified amount of bytes from the list of buffered data chunks.[m
[32m+[m[32m// This function is designed to be inlinable, so please take care when making[m
[32m+[m[32m// changes to the function body.[m
[32m+[m[32mfunction copyFromBuffer(n, list) {[m
[32m+[m[32m  var ret = Buffer.allocUnsafe(n);[m
[32m+[m[32m  var p = list.head;[m
[32m+[m[32m  var c = 1;[m
[32m+[m[32m  p.data.copy(ret);[m
[32m+[m[32m  n -= p.data.length;[m
[32m+[m[32m  while (p = p.next) {[m
[32m+[m[32m    var buf = p.data;[m
[32m+[m[32m    var nb = n > buf.length ? buf.length : n;[m
[32m+[m[32m    buf.copy(ret, ret.length - n, 0, nb);[m
[32m+[m[32m    n -= nb;[m
[32m+[m[32m    if (n === 0) {[m
[32m+[m[32m      if (nb === buf.length) {[m
[32m+[m[32m        ++c;[m
[32m+[m[32m        if (p.next) list.head = p.next;else list.head = list.tail = null;[m
[32m+[m[32m      } else {[m
[32m+[m[32m        list.head = p;[m
[32m+[m[32m        p.data = buf.slice(nb);[m
[32m+[m[32m      }[m
[32m+[m[32m      break;[m
[32m+[m[32m    }[m
[32m+[m[32m    ++c;[m
[32m+[m[32m  }[m
[32m+[m[32m  list.length -= c;[m
[32m+[m[32m  return ret;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction endReadable(stream) {[m
[32m+[m[32m  var state = stream._readableState;[m
[32m+[m
[32m+[m[32m  // If we get here before consuming all the bytes, then that is a[m
[32m+[m[32m  // bug in node.  Should never happen.[m
[32m+[m[32m  if (state.length > 0) throw new Error('"endReadable()" called on non-empty stream');[m
[32m+[m
[32m+[m[32m  if (!state.endEmitted) {[m
[32m+[m[32m    state.ended = true;[m
[32m+[m[32m    pna.nextTick(endReadableNT, state, stream);[m
[32m+[m[32m  }[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction endReadableNT(state, stream) {[m
[32m+[m[32m  // Check that we didn't get one last unshift.[m
[32m+[m[32m  if (!state.endEmitted && state.length === 0) {[m
[32m+[m[32m    state.endEmitted = true;[m
[32m+[m[32m    stream.readable = false;[m
[32m+[m[32m    stream.emit('end');[m
[32m+[m[32m  }[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction indexOf(xs, x) {[m
[32m+[m[32m  for (var i = 0, l = xs.length; i < l; i++) {[m
[32m+[m[32m    if (xs[i] === x) return i;[m
[32m+[m[32m  }[m
[32m+[m[32m  return -1;[m
[32m+[m[32m}[m
\ No newline at end of file[m
[1mdiff --git a/node_modules/readable-stream/lib/_stream_transform.js b/node_modules/readable-stream/lib/_stream_transform.js[m
[1mnew file mode 100644[m
[1mindex 0000000..fcfc105[m
[1m--- /dev/null[m
[1m+++ b/node_modules/readable-stream/lib/_stream_transform.js[m
[36m@@ -0,0 +1,214 @@[m
[32m+[m[32m// Copyright Joyent, Inc. and other Node contributors.[m
[32m+[m[32m//[m
[32m+[m[32m// Permission is hereby granted, free of charge, to any person obtaining a[m
[32m+[m[32m// copy of this software and associated documentation files (the[m
[32m+[m[32m// "Software"), to deal in the Software without restriction, including[m
[32m+[m[32m// without limitation the rights to use, copy, modify, merge, publish,[m
[32m+[m[32m// distribute, sublicense, and/or sell copies of the Software, and to permit[m
[32m+[m[32m// persons to whom the Software is furnished to do so, subject to the[m
[32m+[m[32m// following conditions:[m
[32m+[m[32m//[m
[32m+[m[32m// The above copyright notice and this permission notice shall be included[m
[32m+[m[32m// in all copies or substantial portions of the Software.[m
[32m+[m[32m//[m
[32m+[m[32m// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS[m
[32m+[m[32m// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF[m
[32m+[m[32m// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN[m
[32m+[m[32m// NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,[m
[32m+[m[32m// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR[m
[32m+[m[32m// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE[m
[32m+[m[32m// USE OR OTHER DEALINGS IN THE SOFTWARE.[m
[32m+[m
[32m+[m[32m// a transform stream is a readable/writable stream where you do[m
[32m+[m[32m// something with the data.  Sometimes it's called a "filter",[m
[32m+[m[32m// but that's not a great name for it, since that implies a thing where[m
[32m+[m[32m// some bits pass through, and others are simply ignored.  (That would[m
[32m+[m[32m// be a valid example of a transform, of course.)[m
[32m+[m[32m//[m
[32m+[m[32m// While the output is causally related to the input, it's not a[m
[32m+[m[32m// necessarily symmetric or synchronous transformation.  For example,[m
[32m+[m[32m// a zlib stream might take multiple plain-text writes(), and then[m
[32m+[m[32m// emit a single compressed chunk some time in the future.[m
[32m+[m[32m//[m
[32m+[m[32m// Here's how this works:[m
[32m+[m[32m//[m
[32m+[m[32m// The Transform stream has all the aspects of the readable and writable[m
[32m+[m[32m// stream classes.  When you write(chunk), that calls _write(chunk,cb)[m
[32m+[m[32m// internally, and returns false if there's a lot of pending writes[m
[32m+[m[32m// buffered up.  When you call read(), that calls _read(n) until[m
[32m+[m[32m// there's enough pending readable data buffered up.[m
[32m+[m[32m//[m
[32m+[m[32m// In a transform stream, the written data is placed in a buffer.  When[m
[32m+[m[32m// _read(n) is called, it transforms the queued up data, calling the[m
[32m+[m[32m// buffered _write cb's as it consumes chunks.  If consuming a single[m
[32m+[m[32m// written chunk would result in multiple output chunks, then the first[m
[32m+[m[32m// outputted bit calls the readcb, and subsequent chunks just go into[m
[32m+[m[32m// the read buffer, and will cause it to emit 'readable' if necessary.[m
[32m+[m[32m//[m
[32m+[m[32m// This way, back-pressure is actually determined by the reading side,[m
[32m+[m[32m// since _read has to be called to start processing a new chunk.  However,[m
[32m+[m[32m// a pathological inflate type of transform can cause excessive buffering[m
[32m+[m[32m// here.  For example, imagine a stream where every byte of input is[m
[32m+[m[32m// interpreted as an integer from 0-255, and then results in that many[m
[32m+[m[32m// bytes of output.  Writing the 4 bytes {ff,ff,ff,ff} would result in[m
[32m+[m[32m// 1kb of data being output.  In this case, you could write a very small[m
[32m+[m[32m// amount of input, and end up with a very large amount of output.  In[m
[32m+[m[32m// such a pathological inflating mechanism, there'd be no way to tell[m
[32m+[m[32m// the system to stop doing the transform.  A single 4MB write could[m
[32m+[m[32m// cause the system to run out of memory.[m
[32m+[m[32m//[m
[32m+[m[32m// However, even in such a pathological case, only a single written chunk[m
[32m+[m[32m// would be consumed, and then the rest would wait (un-transformed) until[m
[32m+[m[32m// the results of the previous transformed chunk were consumed.[m
[32m+[m
[32m+[m[32m'use strict';[m
[32m+[m
[32m+[m[32mmodule.exports = Transform;[m
[32m+[m
[32m+[m[32mvar Duplex = require('./_stream_duplex');[m
[32m+[m
[32m+[m[32m/*<replacement>*/[m
[32m+[m[32mvar util = Object.create(require('core-util-is'));[m
[32m+[m[32mutil.inherits = require('inherits');[m
[32m+[m[32m/*</replacement>*/[m
[32m+[m
[32m+[m[32mutil.inherits(Transform, Duplex);[m
[32m+[m
[32m+[m[32mfunction afterTransform(er, data) {[m
[32m+[m[32m  var ts = this._transformState;[m
[32m+[m[32m  ts.transforming = false;[m
[32m+[m
[32m+[m[32m  var cb = ts.writecb;[m
[32m+[m
[32m+[m[32m  if (!cb) {[m
[32m+[m[32m    return this.emit('error', new Error('write callback called multiple times'));[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  ts.writechunk = null;[m
[32m+[m[32m  ts.writecb = null;[m
[32m+[m
[32m+[m[32m  if (data != null) // single equals check for both `null` and `undefined`[m
[32m+[m[32m    this.push(data);[m
[32m+[m
[32m+[m[32m  cb(er);[m
[32m+[m
[32m+[m[32m  var rs = this._readableState;[m
[32m+[m[32m  rs.reading = false;[m
[32m+[m[32m  if (rs.needReadable || rs.length < rs.highWaterMark) {[m
[32m+[m[32m    this._read(rs.highWaterMark);[m
[32m+[m[32m  }[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction Transform(options) {[m
[32m+[m[32m  if (!(this instanceof Transform)) return new Transform(options);[m
[32m+[m
[32m+[m[32m  Duplex.call(this, options);[m
[32m+[m
[32m+[m[32m  this._transformState = {[m
[32m+[m[32m    afterTransform: afterTransform.bind(this),[m
[32m+[m[32m    needTransform: false,[m
[32m+[m[32m    transforming: false,[m
[32m+[m[32m    writecb: null,[m
[32m+[m[32m    writechunk: null,[m
[32m+[m[32m    writeencoding: null[m
[32m+[m[32m  };[m
[32m+[m
[32m+[m[32m  // start out asking for a readable event once data is transformed.[m
[32m+[m[32m  this._readableState.needReadable = true;[m
[32m+[m
[32m+[m[32m  // we have implemented the _read method, and done the other things[m
[32m+[m[32m  // that Readable wants before the first _read call, so unset the[m
[32m+[m[32m  // sync guard flag.[m
[32m+[m[32m  this._readableState.sync = false;[m
[32m+[m
[32m+[m[32m  if (options) {[m
[32m+[m[32m    if (typeof options.transform === 'function') this._transform = options.transform;[m
[32m+[m
[32m+[m[32m    if (typeof options.flush === 'function') this._flush = options.flush;[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  // When the writable side finishes, then flush out anything remaining.[m
[32m+[m[32m  this.on('prefinish', prefinish);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction prefinish() {[m
[32m+[m[32m  var _this = this;[m
[32m+[m
[32m+[m[32m  if (typeof this._flush === 'function') {[m
[32m+[m[32m    this._flush(function (er, data) {[m
[32m+[m[32m      done(_this, er, data);[m
[32m+[m[32m    });[m
[32m+[m[32m  } else {[m
[32m+[m[32m    done(this, null, null);[m
[32m+[m[32m  }[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mTransform.prototype.push = function (chunk, encoding) {[m
[32m+[m[32m  this._transformState.needTransform = false;[m
[32m+[m[32m  return Duplex.prototype.push.call(this, chunk, encoding);[m
[32m+[m[32m};[m
[32m+[m
[32m+[m[32m// This is the part where you do stuff![m
[32m+[m[32m// override this function in implementation classes.[m
[32m+[m[32m// 'chunk' is an input chunk.[m
[32m+[m[32m//[m
[32m+[m[32m// Call `push(newChunk)` to pass along transformed output[m
[32m+[m[32m// to the readable side.  You may call 'push' zero or more times.[m
[32m+[m[32m//[m
[32m+[m[32m// Call `cb(err)` when you are done with this chunk.  If you pass[m
[32m+[m[32m// an error, then that'll put the hurt on the whole operation.  If you[m
[32m+[m[32m// never call cb(), then you'll never get another chunk.[m
[32m+[m[32mTransform.prototype._transform = function (chunk, encoding, cb) {[m
[32m+[m[32m  throw new Error('_transform() is not implemented');[m
[32m+[m[32m};[m
[32m+[m
[32m+[m[32mTransform.prototype._write = function (chunk, encoding, cb) {[m
[32m+[m[32m  var ts = this._transformState;[m
[32m+[m[32m  ts.writecb = cb;[m
[32m+[m[32m  ts.writechunk = chunk;[m
[32m+[m[32m  ts.writeencoding = encoding;[m
[32m+[m[32m  if (!ts.transforming) {[m
[32m+[m[32m    var rs = this._readableState;[m
[32m+[m[32m    if (ts.needTransform || rs.needReadable || rs.length < rs.highWaterMark) this._read(rs.highWaterMark);[m
[32m+[m[32m  }[m
[32m+[m[32m};[m
[32m+[m
[32m+[m[32m// Doesn't matter what the args are here.[m
[32m+[m[32m// _transform does all the work.[m
[32m+[m[32m// That we got here means that the readable side wants more data.[m
[32m+[m[32mTransform.prototype._read = function (n) {[m
[32m+[m[32m  var ts = this._transformState;[m
[32m+[m
[32m+[m[32m  if (ts.writechunk !== null && ts.writecb && !ts.transforming) {[m
[32m+[m[32m    ts.transforming = true;[m
[32m+[m[32m    this._transform(ts.writechunk, ts.writeencoding, ts.afterTransform);[m
[32m+[m[32m  } else {[m
[32m+[m[32m    // mark that we need a transform, so that any data that comes in[m
[32m+[m[32m    // will get processed, now that we've asked for it.[m
[32m+[m[32m    ts.needTransform = true;[m
[32m+[m[32m  }[m
[32m+[m[32m};[m
[32m+[m
[32m+[m[32mTransform.prototype._destroy = function (err, cb) {[m
[32m+[m[32m  var _this2 = this;[m
[32m+[m
[32m+[m[32m  Duplex.prototype._destroy.call(this, err, function (err2) {[m
[32m+[m[32m    cb(err2);[m
[32m+[m[32m    _this2.emit('close');[m
[32m+[m[32m  });[m
[32m+[m[32m};[m
[32m+[m
[32m+[m[32mfunction done(stream, er, data) {[m
[32m+[m[32m  if (er) return stream.emit('error', er);[m
[32m+[m
[32m+[m[32m  if (data != null) // single equals check for both `null` and `undefined`[m
[32m+[m[32m    stream.push(data);[m
[32m+[m
[32m+[m[32m  // if there's nothing in the write buffer, then that means[m
[32m+[m[32m  // that nothing more will ever be provided[m
[32m+[m[32m  if (stream._writableState.length) throw new Error('Calling transform done when ws.length != 0');[m
[32m+[m
[32m+[m[32m  if (stream._transformState.transforming) throw new Error('Calling transform done when still transforming');[m
[32m+[m
[32m+[m[32m  return stream.push(null);[m
[32m+[m[32m}[m
\ No newline at end of file[m
[1mdiff --git a/node_modules/readable-stream/lib/_stream_writable.js b/node_modules/readable-stream/lib/_stream_writable.js[m
[1mnew file mode 100644[m
[1mindex 0000000..e1e897f[m
[1m--- /dev/null[m
[1m+++ b/node_modules/readable-stream/lib/_stream_writable.js[m
[36m@@ -0,0 +1,685 @@[m
[32m+[m[32m// Copyright Joyent, Inc. and other Node contributors.[m
[32m+[m[32m//[m
[32m+[m[32m// Permission is hereby granted, free of charge, to any person obtaining a[m
[32m+[m[32m// copy of this software and associated documentation files (the[m
[32m+[m[32m// "Software"), to deal in the Software without restriction, including[m
[32m+[m[32m// without limitation the rights to use, copy, modify, merge, publish,[m
[32m+[m[32m// distribute, sublicense, and/or sell copies of the Software, and to permit[m
[32m+[m[32m// persons to whom the Software is furnished to do so, subject to the[m
[32m+[m[32m// following conditions:[m
[32m+[m[32m//[m
[32m+[m[32m// The above copyright notice and this permission notice shall be included[m
[32m+[m[32m// in all copies or substantial portions of the Software.[m
[32m+[m[32m//[m
[32m+[m[32m// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS[m
[32m+[m[32m// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF[m
[32m+[m[32m// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN[m
[32m+[m[32m// NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,[m
[32m+[m[32m// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR[m
[32m+[m[32m// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE[m
[32m+[m[32m// USE OR OTHER DEALINGS IN THE SOFTWARE.[m
[32m+[m
[32m+[m[32m// A bit simpler than readable streams.[m
[32m+[m[32m// Implement an async ._write(chunk, encoding, cb), and it'll handle all[m
[32m+[m[32m// the drain event emission and buffering.[m
[32m+[m
[32m+[m[32m'use strict';[m
[32m+[m
[32m+[m[32m/*<replacement>*/[m
[32m+[m
[32m+[m[32mvar pna = require('process-nextick-args');[m
[32m+[m[32m/*</replacement>*/[m
[32m+[m
[32m+[m[32mmodule.exports = Writable;[m
[32m+[m
[32m+[m[32m/* <replacement> */[m
[32m+[m[32mfunction WriteReq(chunk, encoding, cb) {[m
[32m+[m[32m  this.chunk = chunk;[m
[32m+[m[32m  this.encoding = encoding;[m
[32m+[m[32m  this.callback = cb;[m
[32m+[m[32m  this.next = null;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m// It seems a linked list but it is not[m
[32m+[m[32m// there will be only 2 of these for each stream[m
[32m+[m[32mfunction CorkedRequest(state) {[m
[32m+[m[32m  var _this = this;[m
[32m+[m
[32m+[m[32m  this.next = null;[m
[32m+[m[32m  this.entry = null;[m
[32m+[m[32m  this.finish = function () {[m
[32m+[m[32m    onCorkedFinish(_this, state);[m
[32m+[m[32m  };[m
[32m+[m[32m}[m
[32m+[m[32m/* </replacement> */[m
[32m+[m
[32m+[m[32m/*<replacement>*/[m
[32m+[m[32mvar asyncWrite = !process.browser && ['v0.10', 'v0.9.'].indexOf(process.version.slice(0, 5)) > -1 ? setImmediate : pna.nextTick;[m
[32m+[m[32m/*</replacement>*/[m
[32m+[m
[32m+[m[32m/*<replacement>*/[m
[32m+[m[32mvar Duplex;[m
[32m+[m[32m/*</replacement>*/[m
[32m+[m
[32m+[m[32mWritable.WritableState = WritableState;[m
[32m+[m
[32m+[m[32m/*<replacement>*/[m
[32m+[m[32mvar util = Object.create(require('core-util-is'));[m
[32m+[m[32mutil.inherits = require('inherits');[m
[32m+[m[32m/*</replacement>*/[m
[32m+[m
[32m+[m[32m/*<replacement>*/[m
[32m+[m[32mvar internalUtil = {[m
[32m+[m[32m  deprecate: require('util-deprecate')[m
[32m+[m[32m};[m
[32m+[m[32m/*</replacement>*/[m
[32m+[m
[32m+[m[32m/*<replacement>*/[m
[32m+[m[32mvar Stream = require('./internal/streams/stream');[m
[32m+[m[32m/*</replacement>*/[m
[32m+[m
[32m+[m[32m/*<replacement>*/[m
[32m+[m
[32m+[m[32mvar Buffer = require('safe-buffer').Buffer;[m
[32m+[m[32mvar OurUint8Array = (typeof global !== 'undefined' ? global : typeof window !== 'undefined' ? window : typeof self !== 'undefined' ? self : {}).Uint8Array || function () {};[m
[32m+[m[32mfunction _uint8ArrayToBuffer(chunk) {[m
[32m+[m[32m  return Buffer.from(chunk);[m
[32m+[m[32m}[m
[32m+[m[32mfunction _isUint8Array(obj) {[m
[32m+[m[32m  return Buffer.isBuffer(obj) || obj instanceof OurUint8Array;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m/*</replacement>*/[m
[32m+[m
[32m+[m[32mvar destroyImpl = require('./internal/streams/destroy');[m
[32m+[m
[32m+[m[32mutil.inherits(Writable, Stream);[m
[32m+[m
[32m+[m[32mfunction nop() {}[m
[32m+[m
[32m+[m[32mfunction WritableState(options, stream) {[m
[32m+[m[32m  Duplex = Duplex || require('./_stream_duplex');[m
[32m+[m
[32m+[m[32m  options = options || {};[m
[32m+[m
[32m+[m[32m  // Duplex streams are both readable and writable, but share[m
[32m+[m[32m  // the same options object.[m
[32m+[m[32m  // However, some cases require setting options to different[m
[32m+[m[32m  // values for the readable and the writable sides of the duplex stream.[m
[32m+[m[32m  // These options can be provided separately as readableXXX and writableXXX.[m
[32m+[m[32m  var isDuplex = stream instanceof Duplex;[m
[32m+[m
[32m+[m[32m  // object stream flag to indicate whether or not this stream[m
[32m+[m[32m  // contains buffers or objects.[m
[32m+[m[32m  this.objectMode = !!options.objectMode;[m
[32m+[m
[32m+[m[32m  if (isDuplex) this.objectMode = this.objectMode || !!options.writableObjectMode;[m
[32m+[m
[32m+[m[32m  // the point at which write() starts returning false[m
[32m+[m[32m  // Note: 0 is a valid value, means that we always return false if[m
[32m+[m[32m  // the entire buffer is not flushed immediately on write()[m
[32m+[m[32m  var hwm = options.highWaterMark;[m
[32m+[m[32m  var writableHwm = options.writableHighWaterMark;[m
[32m+[m[32m  var defaultHwm = this.objectMode ? 16 : 16 * 1024;[m
[32m+[m
[32m+[m[32m  if (hwm || hwm === 0) this.highWaterMark = hwm;else if (isDuplex && (writableHwm || writableHwm === 0)) this.highWaterMark = writableHwm;else this.highWaterMark = defaultHwm;[m
[32m+[m
[32m+[m[32m  // cast to ints.[m
[32m+[m[32m  this.highWaterMark = Math.floor(this.highWaterMark);[m
[32m+[m
[32m+[m[32m  // if _final has been called[m
[32m+[m[32m  this.finalCalled = false;[m
[32m+[m
[32m+[m[32m  // drain event flag.[m
[32m+[m[32m  this.needDrain = false;[m
[32m+[m[32m  // at the start of calling end()[m
[32m+[m[32m  this.ending = false;[m
[32m+[m[32m  // when end() has been called, and returned[m
[32m+[m[32m  this.ended = false;[m
[32m+[m[32m  // when 'finish' is emitted[m
[32m+[m[32m  this.finished = false;[m
[32m+[m
[32m+[m[32m  // has it been destroyed[m
[32m+[m[32m  this.destroyed = false;[m
[32m+[m
[32m+[m[32m  // should we decode strings into buffers before passing to _write?[m
[32m+[m[32m  // this is here so that some node-core streams can optimize string[m
[32m+[m[32m  // handling at a lower level.[m
[32m+[m[32m  var noDecode = options.decodeStrings === false;[m
[32m+[m[32m  this.decodeStrings = !noDecode;[m
[32m+[m
[32m+[m[32m  // Crypto is kind of old and crusty.  Historically, its default string[m
[32m+[m[32m  // encoding is 'binary' so we have to make this configurable.[m
[32m+[m[32m  // Everything else in the universe uses 'utf8', though.[m
[32m+[m[32m  this.defaultEncoding = options.defaultEncoding || 'utf8';[m
[32m+[m
[32m+[m[32m  // not an actual buffer we keep track of, but a measurement[m
[32m+[m[32m  // of how much we're waiting to get pushed to some underlying[m
[32m+[m[32m  // socket or file.[m
[32m+[m[32m  this.length = 0;[m
[32m+[m
[32m+[m[32m  // a flag to see when we're in the middle of a write.[m
[32m+[m[32m  this.writing = false;[m
[32m+[m
[32m+[m[32m  // when true all writes will be buffered until .uncork() call[m
[32m+[m[32m  this.corked = 0;[m
[32m+[m
[32m+[m[32m  // a flag to be able to tell if the onwrite cb is called immediately,[m
[32m+[m[32m  // or on a later tick.  We set this to true at first, because any[m
[32m+[m[32m  // actions that shouldn't happen until "later" should generally also[m
[32m+[m[32m  // not happen before the first write call.[m
[32m+[m[32m  this.sync = true;[m
[32m+[m
[32m+[m[32m  // a flag to know if we're processing previously buffered items, which[m
[32m+[m[32m  // may call the _write() callback in the same tick, so that we don't[m
[32m+[m[32m  // end up in an overlapped onwrite situation.[m
[32m+[m[32m  this.bufferProcessing = false;[m
[32m+[m
[32m+[m[32m  // the callback that's passed to _write(chunk,cb)[m
[32m+[m[32m  this.onwrite = function (er) {[m
[32m+[m[32m    onwrite(stream, er);[m
[32m+[m[32m  };[m
[32m+[m
[32m+[m[32m  // the callback that the user supplies to write(chunk,encoding,cb)[m
[32m+[m[32m  this.writecb = null;[m
[32m+[m
[32m+[m[32m  // the amount that is being written when _write is called.[m
[32m+[m[32m  this.writelen = 0;[m
[32m+[m
[32m+[m[32m  this.bufferedRequest = null;[m
[32m+[m[32m  this.lastBufferedRequest = null;[m
[32m+[m
[32m+[m[32m  // number of pending user-supplied write callbacks[m
[32m+[m[32m  // this must be 0 before 'finish' can be emitted[m
[32m+[m[32m  this.pendingcb = 0;[m
[32m+[m
[32m+[m[32m  // emit prefinish if the only thing we're waiting for is _write cbs[m
[32m+[m[32m  // This is relevant for synchronous Transform streams[m
[32m+[m[32m  this.prefinished = false;[m
[32m+[m
[32m+[m[32m  // True if the error was already emitted and should not be thrown again[m
[32m+[m[32m  this.errorEmitted = false;[m
[32m+[m
[32m+[m[32m  // count buffered requests[m
[32m+[m[32m  this.bufferedRequestCount = 0;[m
[32m+[m
[32m+[m[32m  // allocate the first CorkedRequest, there is always[m
[32m+[m[32m  // one allocated and free to use, and we maintain at most two[m
[32m+[m[32m  this.corkedRequestsFree = new CorkedRequest(this);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mWritableState.prototype.getBuffer = function getBuffer() {[m
[32m+[m[32m  var current = this.bufferedRequest;[m
[32m+[m[32m  var out = [];[m
[32m+[m[32m  while (current) {[m
[32m+[m[32m    out.push(current);[m
[32m+[m[32m    current = current.next;[m
[32m+[m[32m  }[m
[32m+[m[32m  return out;[m
[32m+[m[32m};[m
[32m+[m
[32m+[m[32m(function () {[m
[32m+[m[32m  try {[m
[32m+[m[32m    Object.defineProperty(WritableState.prototype, 'buffer', {[m
[32m+[m[32m      get: internalUtil.deprecate(function () {[m
[32m+[m[32m        return this.getBuffer();[m
[32m+[m[32m      }, '_writableState.buffer is deprecated. Use _writableState.getBuffer ' + 'instead.', 'DEP0003')[m
[32m+[m[32m    });[m
[32m+[m[32m  } catch (_) {}[m
[32m+[m[32m})();[m
[32m+[m
[32m+[m[32m// Test _writableState for inheritance to account for Duplex streams,[m
[32m+[m[32m// whose prototype chain only points to Readable.[m
[32m+[m[32mvar realHasInstance;[m
[32m+[m[32mif (typeof Symbol === 'function' && Symbol.hasInstance && typeof Function.prototype[Symbol.hasInstance] === 'function') {[m
[32m+[m[32m  realHasInstance = Function.prototype[Symbol.hasInstance];[m
[32m+[m[32m  Object.defineProperty(Writable, Symbol.hasInstance, {[m
[32m+[m[32m    value: function (object) {[m
[32m+[m[32m      if (realHasInstance.call(this, object)) return true;[m
[32m+[m[32m      if (this !== Writable) return false;[m
[32m+[m
[32m+[m[32m      return object && object._writableState instanceof WritableState;[m
[32m+[m[32m    }[m
[32m+[m[32m  });[m
[32m+[m[32m} else {[m
[32m+[m[32m  realHasInstance = function (object) {[m
[32m+[m[32m    return object instanceof this;[m
[32m+[m[32m  };[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction Writable(options) {[m
[32m+[m[32m  Duplex = Duplex || require('./_stream_duplex');[m
[32m+[m
[32m+[m[32m  // Writable ctor is applied to Duplexes, too.[m
[32m+[m[32m  // `realHasInstance` is necessary because using plain `instanceof`[m
[32m+[m[32m  // would return false, as no `_writableState` property is attached.[m
[32m+[m
[32m+[m[32m  // Trying to use the custom `instanceof` for Writable here will also break the[m
[32m+[m[32m  // Node.js LazyTransform implementation, which has a non-trivial getter for[m
[32m+[m[32m  // `_writableState` that would lead to infinite recursion.[m
[32m+[m[32m  if (!realHasInstance.call(Writable, this) && !(this instanceof Duplex)) {[m
[32m+[m[32m    return new Writable(options);[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  this._writableState = new WritableState(options, this);[m
[32m+[m
[32m+[m[32m  // legacy.[m
[32m+[m[32m  this.writable = true;[m
[32m+[m
[32m+[m[32m  if (options) {[m
[32m+[m[32m    if (typeof options.write === 'function') this._write = options.write;[m
[32m+[m
[32m+[m[32m    if (typeof options.writev === 'function') this._writev = options.writev;[m
[32m+[m
[32m+[m[32m    if (typeof options.destroy === 'function') this._destroy = options.destroy;[m
[32m+[m
[32m+[m[32m    if (typeof options.final === 'function') this._final = options.final;[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  Stream.call(this);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m// Otherwise people can pipe Writable streams, which is just wrong.[m
[32m+[m[32mWritable.prototype.pipe = function () {[m
[32m+[m[32m  this.emit('error', new Error('Cannot pipe, not readable'));[m
[32m+[m[32m};[m
[32m+[m
[32m+[m[32mfunction writeAfterEnd(stream, cb) {[m
[32m+[m[32m  var er = new Error('write after end');[m
[32m+[m[32m  // TODO: defer error events consistently everywhere, not just the cb[m
[32m+[m[32m  stream.emit('error', er);[m
[32m+[m[32m  pna.nextTick(cb, er);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m// Checks that a user-supplied chunk is valid, especially for the particular[m
[32m+[m[32m// mode the stream is in. Currently this means that `null` is never accepted[m
[32m+[m[32m// and undefined/non-string values are only allowed in object mode.[m
[32m+[m[32mfunction validChunk(stream, state, chunk, cb) {[m
[32m+[m[32m  var valid = true;[m
[32m+[m[32m  var er = false;[m
[32m+[m
[32m+[m[32m  if (chunk === null) {[m
[32m+[m[32m    er = new TypeError('May not write null values to stream');[m
[32m+[m[32m  } else if (typeof chunk !== 'string' && chunk !== undefined && !state.objectMode) {[m
[32m+[m[32m    er = new TypeError('Invalid non-string/buffer chunk');[m
[32m+[m[32m  }[m
[32m+[m[32m  if (er) {[m
[32m+[m[32m    stream.emit('error', er);[m
[32m+[m[32m    pna.nextTick(cb, er);[m
[32m+[m[32m    valid = false;[m
[32m+[m[32m  }[m
[32m+[m[32m  return valid;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mWritable.prototype.write = function (chunk, encoding, cb) {[m
[32m+[m[32m  var state = this._writableState;[m
[32m+[m[32m  var ret = false;[m
[32m+[m[32m  var isBuf = !state.objectMode && _isUint8Array(chunk);[m
[32m+[m
[32m+[m[32m  if (isBuf && !Buffer.isBuffer(chunk)) {[m
[32m+[m[32m    chunk = _uint8ArrayToBuffer(chunk);[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  if (typeof encoding === 'function') {[m
[32m+[m[32m    cb = encoding;[m
[32m+[m[32m    encoding = null;[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  if (isBuf) encoding = 'buffer';else if (!encoding) encoding = state.defaultEncoding;[m
[32m+[m
[32m+[m[32m  if (typeof cb !== 'function') cb = nop;[m
[32m+[m
[32m+[m[32m  if (state.ended) writeAfterEnd(this, cb);else if (isBuf || validChunk(this, state, chunk, cb)) {[m
[32m+[m[32m    state.pendingcb++;[m
[32m+[m[32m    ret = writeOrBuffer(this, state, isBuf, chunk, encoding, cb);[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  return ret;[m
[32m+[m[32m};[m
[32m+[m
[32m+[m[32mWritable.prototype.cork = function () {[m
[32m+[m[32m  var state = this._writableState;[m
[32m+[m
[32m+[m[32m  state.corked++;[m
[32m+[m[32m};[m
[32m+[m
[32m+[m[32mWritable.prototype.uncork = function () {[m
[32m+[m[32m  var state = this._writableState;[m
[32m+[m
[32m+[m[32m  if (state.corked) {[m
[32m+[m[32m    state.corked--;[m
[32m+[m
[32m+[m[32m    if (!state.writing && !state.corked && !state.bufferProcessing && state.bufferedRequest) clearBuffer(this, state);[m
[32m+[m[32m  }[m
[32m+[m[32m};[m
[32m+[m
[32m+[m[32mWritable.prototype.setDefaultEncoding = function setDefaultEncoding(encoding) {[m
[32m+[m[32m  // node::ParseEncoding() requires lower case.[m
[32m+[m[32m  if (typeof encoding === 'string') encoding = encoding.toLowerCase();[m
[32m+[m[32m  if (!(['hex', 'utf8', 'utf-8', 'ascii', 'binary', 'base64', 'ucs2', 'ucs-2', 'utf16le', 'utf-16le', 'raw'].indexOf((encoding + '').toLowerCase()) > -1)) throw new TypeError('Unknown encoding: ' + encoding);[m
[32m+[m[32m  this._writableState.defaultEncoding = encoding;[m
[32m+[m[32m  return this;[m
[32m+[m[32m};[m
[32m+[m
[32m+[m[32mfunction decodeChunk(state, chunk, encoding) {[m
[32m+[m[32m  if (!state.objectMode && state.decodeStrings !== false && typeof chunk === 'string') {[m
[32m+[m[32m    chunk = Buffer.from(chunk, encoding);[m
[32m+[m[32m  }[m
[32m+[m[32m  return chunk;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mObject.defineProperty(Writable.prototype, 'writableHighWaterMark', {[m
[32m+[m[32m  // making it explicit this property is not enumerable[m
[32m+[m[32m  // because otherwise some prototype manipulation in[m
[32m+[m[32m  // userland will fail[m
[32m+[m[32m  enumerable: false,[m
[32m+[m[32m  get: function () {[m
[32m+[m[32m    return this._writableState.highWaterMark;[m
[32m+[m[32m  }[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32m// if we're already writing something, then just put this[m
[32m+[m[32m// in the queue, and wait our turn.  Otherwise, call _write[m
[32m+[m[32m// If we return false, then we need a drain event, so set that flag.[m
[32m+[m[32mfunction writeOrBuffer(stream, state, isBuf, chunk, encoding, cb) {[m
[32m+[m[32m  if (!isBuf) {[m
[32m+[m[32m    var newChunk = decodeChunk(state, chunk, encoding);[m
[32m+[m[32m    if (chunk !== newChunk) {[m
[32m+[m[32m      isBuf = true;[m
[32m+[m[32m      encoding = 'buffer';[m
[32m+[m[32m      chunk = newChunk;[m
[32m+[m[32m    }[m
[32m+[m[32m  }[m
[32m+[m[32m  var len = state.objectMode ? 1 : chunk.length;[m
[32m+[m
[32m+[m[32m  state.length += len;[m
[32m+[m
[32m+[m[32m  var ret = state.length < state.highWaterMark;[m
[32m+[m[32m  // we must ensure that previous needDrain will not be reset to false.[m
[32m+[m[32m  if (!ret) state.needDrain = true;[m
[32m+[m
[32m+[m[32m  if (state.writing || state.corked) {[m
[32m+[m[32m    var last = state.lastBufferedRequest;[m
[32m+[m[32m    state.lastBufferedRequest = {[m
[32m+[m[32m      chunk: chunk,[m
[32m+[m[32m      encoding: encoding,[m
[32m+[m[32m      isBuf: isBuf,[m
[32m+[m[32m      callback: cb,[m
[32m+[m[32m      next: null[m
[32m+[m[32m    };[m
[32m+[m[32m    if (last) {[m
[32m+[m[32m      last.next = state.lastBufferedRequest;[m
[32m+[m[32m    } else {[m
[32m+[m[32m      state.bufferedRequest = state.lastBufferedRequest;[m
[32m+[m[32m    }[m
[32m+[m[32m    state.bufferedRequestCount += 1;[m
[32m+[m[32m  } else {[m
[32m+[m[32m    doWrite(stream, state, false, len, chunk, encoding, cb);[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  return ret;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction doWrite(stream, state, writev, len, chunk, encoding, cb) {[m
[32m+[m[32m  state.writelen = len;[m
[32m+[m[32m  state.writecb = cb;[m
[32m+[m[32m  state.writing = true;[m
[32m+[m[32m  state.sync = true;[m
[32m+[m[32m  if (writev) stream._writev(chunk, state.onwrite);else stream._write(chunk, encoding, state.onwrite);[m
[32m+[m[32m  state.sync = false;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction onwriteError(stream, state, sync, er, cb) {[m
[32m+[m[32m  --state.pendingcb;[m
[32m+[m
[32m+[m[32m  if (sync) {[m
[32m+[m[32m    // defer the callback if we are being called synchronously[m
[32m+[m[32m    // to avoid piling up things on the stack[m
[32m+[m[32m    pna.nextTick(cb, er);[m
[32m+[m[32m    // this can emit finish, and it will always happen[m
[32m+[m[32m    // after error[m
[32m+[m[32m    pna.nextTick(finishMaybe, stream, state);[m
[32m+[m[32m    stream._writableState.errorEmitted = true;[m
[32m+[m[32m    stream.emit('error', er);[m
[32m+[m[32m  } else {[m
[32m+[m[32m    // the caller expect this to happen before if[m
[32m+[m[32m    // it is async[m
[32m+[m[32m    cb(er);[m
[32m+[m[32m    stream._writableState.errorEmitted = true;[m
[32m+[m[32m    stream.emit('error', er);[m
[32m+[m[32m    // this can emit finish, but finish must[m
[32m+[m[32m    // always follow error[m
[32m+[m[32m    finishMaybe(stream, state);[m
[32m+[m[32m  }[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction onwriteStateUpdate(state) {[m
[32m+[m[32m  state.writing = false;[m
[32m+[m[32m  state.writecb = null;[m
[32m+[m[32m  state.length -= state.writelen;[m
[32m+[m[32m  state.writelen = 0;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction onwrite(stream, er) {[m
[32m+[m[32m  var state = stream._writableState;[m
[32m+[m[32m  var sync = state.sync;[m
[32m+[m[32m  var cb = state.writecb;[m
[32m+[m
[32m+[m[32m  onwriteStateUpdate(state);[m
[32m+[m
[32m+[m[32m  if (er) onwriteError(stream, state, sync, er, cb);else {[m
[32m+[m[32m    // Check if we're actually ready to finish, but don't emit yet[m
[32m+[m[32m    var finished = needFinish(state);[m
[32m+[m
[32m+[m[32m    if (!finished && !state.corked && !state.bufferProcessing && state.bufferedRequest) {[m
[32m+[m[32m      clearBuffer(stream, state);[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    if (sync) {[m
[32m+[m[32m      /*<replacement>*/[m
[32m+[m[32m      asyncWrite(afterWrite, stream, state, finished, cb);[m
[32m+[m[32m      /*</replacement>*/[m
[32m+[m[32m    } else {[m
[32m+[m[32m      afterWrite(stream, state, finished, cb);[m
[32m+[m[32m    }[m
[32m+[m[32m  }[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction afterWrite(stream, state, finished, cb) {[m
[32m+[m[32m  if (!finished) onwriteDrain(stream, state);[m
[32m+[m[32m  state.pendingcb--;[m
[32m+[m[32m  cb();[m
[32m+[m[32m  finishMaybe(stream, state);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m// Must force callback to be called on nextTick, so that we don't[m
[32m+[m[32m// emit 'drain' before the write() consumer gets the 'false' return[m
[32m+[m[32m// value, and has a chance to attach a 'drain' listener.[m
[32m+[m[32mfunction onwriteDrain(stream, state) {[m
[32m+[m[32m  if (state.length === 0 && state.needDrain) {[m
[32m+[m[32m    state.needDrain = false;[m
[32m+[m[32m    stream.emit('drain');[m
[32m+[m[32m  }[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m// if there's something in the buffer waiting, then process it[m
[32m+[m[32mfunction clearBuffer(stream, state) {[m
[32m+[m[32m  state.bufferProcessing = true;[m
[32m+[m[32m  var entry = state.bufferedRequest;[m
[32m+[m
[32m+[m[32m  if (stream._writev && entry && entry.next) {[m
[32m+[m[32m    // Fast case, write everything using _writev()[m
[32m+[m[32m    var l = state.bufferedRequestCount;[m
[32m+[m[32m    var buffer = new Array(l);[m
[32m+[m[32m    var holder = state.corkedRequestsFree;[m
[32m+[m[32m    holder.entry = entry;[m
[32m+[m
[32m+[m[32m    var count = 0;[m
[32m+[m[32m    var allBuffers = true;[m
[32m+[m[32m    while (entry) {[m
[32m+[m[32m      buffer[count] = entry;[m
[32m+[m[32m      if (!entry.isBuf) allBuffers = false;[m
[32m+[m[32m      entry = entry.next;[m
[32m+[m[32m      count += 1;[m
[32m+[m[32m    }[m
[32m+[m[32m    buffer.allBuffers = allBuffers;[m
[32m+[m
[32m+[m[32m    doWrite(stream, state, true, state.length, buffer, '', holder.finish);[m
[32m+[m
[32m+[m[32m    // doWrite is almost always async, defer these to save a bit of time[m
[32m+[m[32m    // as the hot path ends with doWrite[m
[32m+[m[32m    state.pendingcb++;[m
[32m+[m[32m    state.lastBufferedRequest = null;[m
[32m+[m[32m    if (holder.next) {[m
[32m+[m[32m      state.corkedRequestsFree = holder.next;[m
[32m+[m[32m      holder.next = null;[m
[32m+[m[32m    } else {[m
[32m+[m[32m      state.corkedRequestsFree = new CorkedRequest(state);[m
[32m+[m[32m    }[m
[32m+[m[32m    state.bufferedRequestCount = 0;[m
[32m+[m[32m  } else {[m
[32m+[m[32m    // Slow case, write chunks one-by-one[m
[32m+[m[32m    while (entry) {[m
[32m+[m[32m      var chunk = entry.chunk;[m
[32m+[m[32m      var encoding = entry.encoding;[m
[32m+[m[32m      var cb = entry.callback;[m
[32m+[m[32m      var len = state.objectMode ? 1 : chunk.length;[m
[32m+[m
[32m+[m[32m      doWrite(stream, state, false, len, chunk, encoding, cb);[m
[32m+[m[32m      entry = entry.next;[m
[32m+[m[32m      state.bufferedRequestCount--;[m
[32m+[m[32m      // if we didn't call the onwrite immediately, then[m
[32m+[m[32m      // it means that we need to wait until it does.[m
[32m+[m[32m      // also, that means that the chunk and cb are currently[m
[32m+[m[32m      // being processed, so move the buffer counter past them.[m
[32m+[m[32m      if (state.writing) {[m
[32m+[m[32m        break;[m
[32m+[m[32m      }[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    if (entry === null) state.lastBufferedRequest = null;[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  state.bufferedRequest = entry;[m
[32m+[m[32m  state.bufferProcessing = false;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mWritable.prototype._write = function (chunk, encoding, cb) {[m
[32m+[m[32m  cb(new Error('_write() is not implemented'));[m
[32m+[m[32m};[m
[32m+[m
[32m+[m[32mWritable.prototype._writev = null;[m
[32m+[m
[32m+[m[32mWritable.prototype.end = function (chunk, encoding, cb) {[m
[32m+[m[32m  var state = this._writableState;[m
[32m+[m
[32m+[m[32m  if (typeof chunk === 'function') {[m
[32m+[m[32m    cb = chunk;[m
[32m+[m[32m    chunk = null;[m
[32m+[m[32m    encoding = null;[m
[32m+[m[32m  } else if (typeof encoding === 'function') {[m
[32m+[m[32m    cb = encoding;[m
[32m+[m[32m    encoding = null;[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  if (chunk !== null && chunk !== undefined) this.write(chunk, encoding);[m
[32m+[m
[32m+[m[32m  // .end() fully uncorks[m
[32m+[m[32m  if (state.corked) {[m
[32m+[m[32m    state.corked = 1;[m
[32m+[m[32m    this.uncork();[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  // ignore unnecessary end() calls.[m
[32m+[m[32m  if (!state.ending) endWritable(this, state, cb);[m
[32m+[m[32m};[m
[32m+[m
[32m+[m[32mfunction needFinish(state) {[m
[32m+[m[32m  return state.ending && state.length === 0 && state.bufferedRequest === null && !state.finished && !state.writing;[m
[32m+[m[32m}[m
[32m+[m[32mfunction callFinal(stream, state) {[m
[32m+[m[32m  stream._final(function (err) {[m
[32m+[m[32m    state.pendingcb--;[m
[32m+[m[32m    if (err) {[m
[32m+[m[32m      stream.emit('error', err);[m
[32m+[m[32m    }[m
[32m+[m[32m    state.prefinished = true;[m
[32m+[m[32m    stream.emit('prefinish');[m
[32m+[m[32m    finishMaybe(stream, state);[m
[32m+[m[32m  });[m
[32m+[m[32m}[m
[32m+[m[32mfunction prefinish(stream, state) {[m
[32m+[m[32m  if (!state.prefinished && !state.finalCalled) {[m
[32m+[m[32m    if (typeof stream._final === 'function') {[m
[32m+[m[32m      state.pendingcb++;[m
[32m+[m[32m      state.finalCalled = true;[m
[32m+[m[32m      pna.nextTick(callFinal, stream, state);[m
[32m+[m[32m    } else {[m
[32m+[m[32m      state.prefinished = true;[m
[32m+[m[32m      stream.emit('prefinish');[m
[32m+[m[32m    }[m
[32m+[m[32m  }[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction finishMaybe(stream, state) {[m
[32m+[m[32m  var need = needFinish(state);[m
[32m+[m[32m  if (need) {[m
[32m+[m[32m    prefinish(stream, state);[m
[32m+[m[32m    if (state.pendingcb === 0) {[m
[32m+[m[32m      state.finished = true;[m
[32m+[m[32m      stream.emit('finish');[m
[32m+[m[32m    }[m
[32m+[m[32m  }[m
[32m+[m[32m  return need;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction endWritable(stream, state, cb) {[m
[32m+[m[32m  state.ending = true;[m
[32m+[m[32m  finishMaybe(stream, state);[m
[32m+[m[32m  if (cb) {[m
[32m+[m[32m    if (state.finished) pna.nextTick(cb);else stream.once('finish', cb);[m
[32m+[m[32m  }[m
[32m+[m[32m  state.ended = true;[m
[32m+[m[32m  stream.writable = false;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction onCorkedFinish(corkReq, state, err) {[m
[32m+[m[32m  var entry = corkReq.entry;[m
[32m+[m[32m  corkReq.entry = null;[m
[32m+[m[32m  while (entry) {[m
[32m+[m[32m    var cb = entry.callback;[m
[32m+[m[32m    state.pendingcb--;[m
[32m+[m[32m    cb(err);[m
[32m+[m[32m    entry = entry.next;[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  // reuse the free corkReq.[m
[32m+[m[32m  state.corkedRequestsFree.next = corkReq;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mObject.defineProperty(Writable.prototype, 'destroyed', {[m
[32m+[m[32m  get: function () {[m
[32m+[m[32m    if (this._writableState === undefined) {[m
[32m+[m[32m      return false;[m
[32m+[m[32m    }[m
[32m+[m[32m    return this._writableState.destroyed;[m
[32m+[m[32m  },[m
[32m+[m[32m  set: function (value) {[m
[32m+[m[32m    // we ignore the value if the stream[m
[32m+[m[32m    // has not been initialized yet[m
[32m+[m[32m    if (!this._writableState) {[m
[32m+[m[32m      return;[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    // backward compatibility, the user is explicitly[m
[32m+[m[32m    // managing destroyed[m
[32m+[m[32m    this._writableState.destroyed = value;[m
[32m+[m[32m  }[m
[32m+[m[32m});[m
[32m+[m
[32m+[m[32mWritable.prototype.destroy = destroyImpl.destroy;[m
[32m+[m[32mWritable.prototype._undestroy = destroyImpl.undestroy;[m
[32m+[m[32mWritable.prototype._destroy = function (err, cb) {[m
[32m+[m[32m  this.end();[m
[32m+[m[32m  cb(err);[m
[32m+[m[32m};[m
\ No newline at end of file[m
[1mdiff --git a/node_modules/readable-stream/lib/internal/streams/BufferList.js b/node_modules/readable-stream/lib/internal/streams/BufferList.js[m
[1mnew file mode 100644[m
[1mindex 0000000..5e08097[m
[1m--- /dev/null[m
[1m+++ b/node_modules/readable-stream/lib/internal/streams/BufferList.js[m
[36m@@ -0,0 +1,78 @@[m
[32m+[m[32m'use strict';[m
[32m+[m
[32m+[m[32mfunction _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }[m
[32m+[m
[32m+[m[32mvar Buffer = require('safe-buffer').Buffer;[m
[32m+[m[32mvar util = require('util');[m
[32m+[m
[32m+[m[32mfunction copyBuffer(src, target, offset) {[m
[32m+[m[32m  src.copy(target, offset);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mmodule.exports = function () {[m
[32m+[m[32m  function BufferList() {[m
[32m+[m[32m    _classCallCheck(this, BufferList);[m
[32m+[m
[32m+[m[32m    this.head = null;[m
[32m+[m[32m    this.tail = null;[m
[32m+[m[32m    this.length = 0;[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  BufferList.prototype.push = function push(v) {[m
[32m+[m[32m    var entry = { data: v, next: null };[m
[32m+[m[32m    if (this.length > 0) this.tail.next = entry;else this.head = entry;[m
[32m+[m[32m    this.tail = entry;[m
[32m+[m[32m    ++this.length;[m
[32m+[m[32m  };[m
[32m+[m
[32m+[m[32m  BufferList.prototype.unshift = function unshift(v) {[m
[32m+[m[32m    var entry = { data: v, next: this.head };[m
[32m+[m[32m    if (this.length === 0) this.tail = entry;[m
[32m+[m[32m    this.head = entry;[m
[32m+[m[32m    ++this.length;[m
[32m+[m[32m  };[m
[32m+[m
[32m+[m[32m  BufferList.prototype.shift = function shift() {[m
[32m+[m[32m    if (this.length === 0) return;[m
[32m+[m[32m    var ret = this.head.data;[m
[32m+[m[32m    if (this.length === 1) this.head = this.tail = null;else this.head = this.head.next;[m
[32m+[m[32m    --this.length;[m
[32m+[m[32m    return ret;[m
[32m+[m[32m  };[m
[32m+[m
[32m+[m[32m  BufferList.prototype.clear = function clear() {[m
[32m+[m[32m    this.head = this.tail = null;[m
[32m+[m[32m    this.length = 0;[m
[32m+[m[32m  };[m
[32m+[m
[32m+[m[32m  BufferList.prototype.join = function join(s) {[m
[32m+[m[32m    if (this.length === 0) return '';[m
[32m+[m[32m    var p = this.head;[m
[32m+[m[32m    var ret = '' + p.data;[m
[32m+[m[32m    while (p = p.next) {[m
[32m+[m[32m      ret += s + p.data;[m
[32m+[m[32m    }return ret;[m
[32m+[m[32m  };[m
[32m+[m
[32m+[m[32m  BufferList.prototype.concat = function concat(n) {[m
[32m+[m[32m    if (this.length === 0) return Buffer.alloc(0);[m
[32m+[m[32m    var ret = Buffer.allocUnsafe(n >>> 0);[m
[32m+[m[32m    var p = this.head;[m
[32m+[m[32m    var i = 0;[m
[32m+[m[32m    while (p) {[m
[32m+[m[32m      copyBuffer(p.data, ret, i);[m
[32m+[m[32m      i += p.data.length;[m
[32m+[m[32m      p = p.next;[m
[32m+[m[32m    }[m
[32m+[m[32m    return ret;[m
[32m+[m[32m  };[m
[32m+[m
[32m+[m[32m  return BufferList;[m
[32m+[m[32m}();[m
[32m+[m
[32m+[m[32mif (util && util.inspect && util.inspect.custom) {[m
[32m+[m[32m  module.exports.prototype[util.inspect.custom] = function () {[m
[32m+[m[32m    var obj = util.inspect({ length: this.length });[m
[32m+[m[32m    return this.constructor.name + ' ' + obj;[m
[32m+[m[32m  };[m
[32m+[m[32m}[m
\ No newline at end of file[m
[1mdiff --git a/node_modules/readable-stream/lib/internal/streams/destroy.js b/node_modules/readable-stream/lib/internal/streams/destroy.js[m
[1mnew file mode 100644[m
[1mindex 0000000..85a8214[m
[1m--- /dev/null[m
[1m+++ b/node_modules/readable-stream/lib/internal/streams/destroy.js[m
[36m@@ -0,0 +1,84 @@[m
[32m+[m[32m'use strict';[m
[32m+[m
[32m+[m[32m/*<replacement>*/[m
[32m+[m
[32m+[m[32mvar pna = require('process-nextick-args');[m
[32m+[m[32m/*</replacement>*/[m
[32m+[m
[32m+[m[32m// undocumented cb() API, needed for core, not for public API[m
[32m+[m[32mfunction destroy(err, cb) {[m
[32m+[m[32m  var _this = this;[m
[32m+[m
[32m+[m[32m  var readableDestroyed = this._readableState && this._readableState.destroyed;[m
[32m+[m[32m  var writableDestroyed = this._writableState && this._writableState.destroyed;[m
[32m+[m
[32m+[m[32m  if (readableDestroyed || writableDestroyed) {[m
[32m+[m[32m    if (cb) {[m
[32m+[m[32m      cb(err);[m
[32m+[m[32m    } else if (err) {[m
[32m+[m[32m      if (!this._writableState) {[m
[32m+[m[32m        pna.nextTick(emitErrorNT, this, err);[m
[32m+[m[32m      } else if (!this._writableState.errorEmitted) {[m
[32m+[m[32m        this._writableState.errorEmitted = true;[m
[32m+[m[32m        pna.nextTick(emitErrorNT, this, err);[m
[32m+[m[32m      }[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    return this;[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  // we set destroyed to true before firing error callbacks in order[m
[32m+[m[32m  // to make it re-entrance safe in case destroy() is called within callbacks[m
[32m+[m
[32m+[m[32m  if (this._readableState) {[m
[32m+[m[32m    this._readableState.destroyed = true;[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  // if this is a duplex stream mark the writable part as destroyed as well[m
[32m+[m[32m  if (this._writableState) {[m
[32m+[m[32m    this._writableState.destroyed = true;[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  this._destroy(err || null, function (err) {[m
[32m+[m[32m    if (!cb && err) {[m
[32m+[m[32m      if (!_this._writableState) {[m
[32m+[m[32m        pna.nextTick(emitErrorNT, _this, err);[m
[32m+[m[32m      } else if (!_this._writableState.errorEmitted) {[m
[32m+[m[32m        _this._writableState.errorEmitted = true;[m
[32m+[m[32m        pna.nextTick(emitErrorNT, _this, err);[m
[32m+[m[32m      }[m
[32m+[m[32m    } else if (cb) {[m
[32m+[m[32m      cb(err);[m
[32m+[m[32m    }[m
[32m+[m[32m  });[m
[32m+[m
[32m+[m[32m  return this;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction undestroy() {[m
[32m+[m[32m  if (this._readableState) {[m
[32m+[m[32m    this._readableState.destroyed = false;[m
[32m+[m[32m    this._readableState.reading = false;[m
[32m+[m[32m    this._readableState.ended = false;[m
[32m+[m[32m    this._readableState.endEmitted = false;[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  if (this._writableState) {[m
[32m+[m[32m    this._writableState.destroyed = false;[m
[32m+[m[32m    this._writableState.ended = false;[m
[32m+[m[32m    this._writableState.ending = false;[m
[32m+[m[32m    this._writableState.finalCalled = false;[m
[32m+[m[32m    this._writableState.prefinished = false;[m
[32m+[m[32m    this._writableState.finished = false;[m
[32m+[m[32m    this._writableState.errorEmitted = false;[m
[32m+[m[32m  }[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction emitErrorNT(self, err) {[m
[32m+[m[32m  self.emit('error', err);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mmodule.exports = {[m
[32m+[m[32m  destroy: destroy,[m
[32m+[m[32m  undestroy: undestroy[m
[32m+[m[32m};[m
\ No newline at end of file[m
[1mdiff --git a/node_modules/readable-stream/lib/internal/streams/stream-browser.js b/node_modules/readable-stream/lib/internal/streams/stream-browser.js[m
[1mnew file mode 100644[m
[1mindex 0000000..9332a3f[m
[1m--- /dev/null[m
[1m+++ b/node_modules/readable-stream/lib/internal/streams/stream-browser.js[m
[36m@@ -0,0 +1 @@[m
[32m+[m[32mmodule.exports = require('events').EventEmitter;[m
[1mdiff --git a/node_modules/readable-stream/lib/internal/streams/stream.js b/node_modules/readable-stream/lib/internal/streams/stream.js[m
[1mnew file mode 100644[m
[1mindex 0000000..ce2ad5b[m
[1m--- /dev/null[m
[1m+++ b/node_modules/readable-stream/lib/internal/streams/stream.js[m
[36m@@ -0,0 +1 @@[m
[32m+[m[32mmodule.exports = require('stream');[m
[1mdiff --git a/node_modules/readable-stream/node_modules/safe-buffer/LICENSE b/node_modules/readable-stream/node_modules/safe-buffer/LICENSE[m
[1mnew file mode 100644[m
[1mindex 0000000..0c068ce[m
[1m--- /dev/null[m
[1m+++ b/node_modules/readable-stream/node_modules/safe-buffer/LICENSE[m
[36m@@ -0,0 +1,21 @@[m
[32m+[m[32mThe MIT License (MIT)[m
[32m+[m
[32m+[m[32mCopyright (c) Feross Aboukhadijeh[m
[32m+[m
[32m+[m[32mPermission is hereby granted, free of charge, to any person obtaining a copy[m
[32m+[m[32mof this software and associated documentation files (the "Software"), to deal[m
[32m+[m[32min the Software without restriction, including without limitation the rights[m
[32m+[m[32mto use, copy, modify, merge, publish, distribute, sublicense, and/or sell[m
[32m+[m[32mcopies of the Software, and to permit persons to whom the Software is[m
[32m+[m[32mfurnished to do so, subject to the following conditions:[m
[32m+[m
[32m+[m[32mThe above copyright notice and this permission notice shall be included in[m
[32m+[m[32mall copies or substantial portions of the Software.[m
[32m+[m
[32m+[m[32mTHE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR[m
[32m+[m[32mIMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,[m
[32m+[m[32mFITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE[m
[32m+[m[32mAUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER[m
[32m+[m[32mLIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,[m
[32m+[m[32mOUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN[m
[32m+[m[32mTHE SOFTWARE.[m
[1mdiff --git a/node_modules/readable-stream/node_modules/safe-buffer/README.md b/node_modules/readable-stream/node_modules/safe-buffer/README.md[m
[1mnew file mode 100644[m
[1mindex 0000000..e9a81af[m
[1m--- /dev/null[m
[1m+++ b/node_modules/readable-stream/node_modules/safe-buffer/README.md[m
[36m@@ -0,0 +1,584 @@[m
[32m+[m[32m# safe-buffer [![travis][travis-image]][travis-url] [![npm][npm-image]][npm-url] [![downloads][downloads-image]][downloads-url] [![javascript style guide][standard-image]][standard-url][m
[32m+[m
[32m+[m[32m[travis-image]: https://img.shields.io/travis/feross/safe-buffer/master.svg[m
[32m+[m[32m[travis-url]: https://travis-ci.org/feross/safe-buffer[m
[32m+[m[32m[npm-image]: https://img.shields.io/npm/v/safe-buffer.svg[m
[32m+[m[32m[npm-url]: https://npmjs.org/package/safe-buffer[m
[32m+[m[32m[downloads-image]: https://img.shields.io/npm/dm/safe-buffer.svg[m
[32m+[m[32m[downloads-url]: https://npmjs.org/package/safe-buffer[m
[32m+[m[32m[standard-image]: https://img.shields.io/badge/code_style-standard-brightgreen.svg[m
[32m+[m[32m[standard-url]: https://standardjs.com[m
[32m+[m
[32m+[m[32m#### Safer Node.js Buffer API[m
[32m+[m
[32m+[m[32m**Use the new Node.js Buffer APIs (`Buffer.from`, `Buffer.alloc`,[m
[32m+[m[32m`Buffer.allocUnsafe`, `Buffer.allocUnsafeSlow`) in all versions of Node.js.**[m
[32m+[m
[32m+[m[32m**Uses the built-in implementation when available.**[m
[32m+[m
[32m+[m[32m## install[m
[32m+[m
[32m+[m[32m```[m
[32m+[m[32mnpm install safe-buffer[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32m## usage[m
[32m+[m
[32m+[m[32mThe goal of this package is to provide a safe replacement for the node.js `Buffer`.[m
[32m+[m
[32m+[m[32mIt's a drop-in replacement for `Buffer`. You can use it by adding one `require` line to[m
[32m+[m[32mthe top of your node.js modules:[m
[32m+[m
[32m+[m[32m```js[m
[32m+[m[32mvar Buffer = require('safe-buffer').Buffer[m
[32m+[m
[32m+[m[32m// Existing buffer code will continue to work without issues:[m
[32m+[m
[32m+[m[32mnew Buffer('hey', 'utf8')[m
[32m+[m[32mnew Buffer([1, 2, 3], 'utf8')[m
[32m+[m[32mnew Buffer(obj)[m
[32m+[m[32mnew Buffer(16) // create an uninitialized buffer (potentially unsafe)[m
[32m+[m
[32m+[m[32m// But you can use these new explicit APIs to make clear what you want:[m
[32m+[m
[32m+[m[32mBuffer.from('hey', 'utf8') // convert from many types to a Buffer[m
[32m+[m[32mBuffer.alloc(16) // create a zero-filled buffer (safe)[m
[32m+[m[32mBuffer.allocUnsafe(16) // create an uninitialized buffer (potentially unsafe)[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32m## api[m
[32m+[m
[32m+[m[32m### Class Method: Buffer.from(array)[m
[32m+[m[32m<!-- YAML[m
[32m+[m[32madded: v3.0.0[m
[32m+[m[32m-->[m
[32m+[m
[32m+[m[32m* `array` {Array}[m
[32m+[m
[32m+[m[32mAllocates a new `Buffer` using an `array` of octets.[m
[32m+[m
[32m+[m[32m```js[m
[32m+[m[32mconst buf = Buffer.from([0x62,0x75,0x66,0x66,0x65,0x72]);[m
[32m+[m[32m  // creates a new Buffer containing ASCII bytes[m
[32m+[m[32m  // ['b','u','f','f','e','r'][m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32mA `TypeError` will be thrown if `array` is not an `Array`.[m
[32m+[m
[32m+[m[32m### Class Method: Buffer.from(arrayBuffer[, byteOffset[, length]])[m
[32m+[m[32m<!-- YAML[m
[32m+[m[32madded: v5.10.0[m
[32m+[m[32m-->[m
[32m+[m
[32m+[m[32m* `arrayBuffer` {ArrayBuffer} The `.buffer` property of a `TypedArray` or[m
[32m+[m[32m  a `new ArrayBuffer()`[m
[32m+[m[32m* `byteOffset` {Number} Default: `0`[m
[32m+[m[32m* `length` {Number} Default: `arrayBuffer.length - byteOffset`[m
[32m+[m
[32m+[m[32mWhen passed a reference to the `.buffer` property of a `TypedArray` instance,[m
[32m+[m[32mthe newly created `Buffer` will share the same allocated memory as the[m
[32m+[m[32mTypedArray.[m
[32m+[m
[32m+[m[32m```js[m
[32m+[m[32mconst arr = new Uint16Array(2);[m
[32m+[m[32marr[0] = 5000;[m
[32m+[m[32marr[1] = 4000;[m
[32m+[m
[32m+[m[32mconst buf = Buffer.from(arr.buffer); // shares the memory with arr;[m
[32m+[m
[32m+[m[32mconsole.log(buf);[m
[32m+[m[32m  // Prints: <Buffer 88 13 a0 0f>[m
[32m+[m
[32m+[m[32m// changing the TypedArray changes the Buffer also[m
[32m+[m[32marr[1] = 6000;[m
[32m+[m
[32m+[m[32mconsole.log(buf);[m
[32m+[m[32m  // Prints: <Buffer 88 13 70 17>[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32mThe optional `byteOffset` and `length` arguments specify a memory range within[m
[32m+[m[32mthe `arrayBuffer` that will be shared by the `Buffer`.[m
[32m+[m
[32m+[m[32m```js[m
[32m+[m[32mconst ab = new ArrayBuffer(10);[m
[32m+[m[32mconst buf = Buffer.from(ab, 0, 2);[m
[32m+[m[32mconsole.log(buf.length);[m
[32m+[m[32m  // Prints: 2[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32mA `TypeError` will be thrown if `arrayBuffer` is not an `ArrayBuffer`.[m
[32m+[m
[32m+[m[32m### Class Method: Buffer.from(buffer)[m
[32m+[m[32m<!-- YAML[m
[32m+[m[32madded: v3.0.0[m
[32m+[m[32m-->[m
[32m+[m
[32m+[m[32m* `buffer` {Buffer}[m
[32m+[m
[32m+[m[32mCopies the passed `buffer` data onto a new `Buffer` instance.[m
[32m+[m
[32m+[m[32m```js[m
[32m+[m[32mconst buf1 = Buffer.from('buffer');[m
[32m+[m[32mconst buf2 = Buffer.from(buf1);[m
[32m+[m
[32m+[m[32mbuf1[0] = 0x61;[m
[32m+[m[32mconsole.log(buf1.toString());[m
[32m+[m[32m  // 'auffer'[m
[32m+[m[32mconsole.log(buf2.toString());[m
[32m+[m[32m  // 'buffer' (copy is not changed)[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32mA `TypeError` will be thrown if `buffer` is not a `Buffer`.[m
[32m+[m
[32m+[m[32m### Class Method: Buffer.from(str[, encoding])[m
[32m+[m[32m<!-- YAML[m
[32m+[m[32madded: v5.10.0[m
[32m+[m[32m-->[m
[32m+[m
[32m+[m[32m* `str` {String} String to encode.[m
[32m+[m[32m* `encoding` {String} Encoding to use, Default: `'utf8'`[m
[32m+[m
[32m+[m[32mCreates a new `Buffer` containing the given JavaScript string `str`. If[m
[32m+[m[32mprovided, the `encoding` parameter identifies the character encoding.[m
[32m+[m[32mIf not provided, `encoding` defaults to `'utf8'`.[m
[32m+[m
[32m+[m[32m```js[m
[32m+[m[32mconst buf1 = Buffer.from('this is a tést');[m
[32m+[m[32mconsole.log(buf1.toString());[m
[32m+[m[32m  // prints: this is a tést[m
[32m+[m[32mconsole.log(buf1.toString('ascii'));[m
[32m+[m[32m  // prints: this is a tC)st[m
[32m+[m
[32m+[m[32mconst buf2 = Buffer.from('7468697320697320612074c3a97374', 'hex');[m
[32m+[m[32mconsole.log(buf2.toString());[m
[32m+[m[32m  // prints: this is a tést[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32mA `TypeError` will be thrown if `str` is not a string.[m
[32m+[m
[32m+[m[32m### Class Method: Buffer.alloc(size[, fill[, encoding]])[m
[32m+[m[32m<!-- YAML[m
[32m+[m[32madded: v5.10.0[m
[32m+[m[32m-->[m
[32m+[m
[32m+[m[32m* `size` {Number}[m
[32m+[m[32m* `fill` {Value} Default: `undefined`[m
[32m+[m[32m* `encoding` {String} Default: `utf8`[m
[32m+[m
[32m+[m[32mAllocates a new `Buffer` of `size` bytes. If `fill` is `undefined`, the[m
[32m+[m[32m`Buffer` will be *zero-filled*.[m
[32m+[m
[32m+[m[32m```js[m
[32m+[m[32mconst buf = Buffer.alloc(5);[m
[32m+[m[32mconsole.log(buf);[m
[32m+[m[32m  // <Buffer 00 00 00 00 00>[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32mThe `size` must be less than or equal to the value of[m
[32m+[m[32m`require('buffer').kMaxLength` (on 64-bit architectures, `kMaxLength` is[m
[32m+[m[32m`(2^31)-1`). Otherwise, a [`RangeError`][] is thrown. A zero-length Buffer will[m
[32m+[m[32mbe created if a `size` less than or equal to 0 is specified.[m
[32m+[m
[32m+[m[32mIf `fill` is specified, the allocated `Buffer` will be initialized by calling[m
[32m+[m[32m`buf.fill(fill)`. See [`buf.fill()`][] for more information.[m
[32m+[m
[32m+[m[32m```js[m
[32m+[m[32mconst buf = Buffer.alloc(5, 'a');[m
[32m+[m[32mconsole.log(buf);[m
[32m+[m[32m  // <Buffer 61 61 61 61 61>[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32mIf both `fill` and `encoding` are specified, the allocated `Buffer` will be[m
[32m+[m[32minitialized by calling `buf.fill(fill, encoding)`. For example:[m
[32m+[m
[32m+[m[32m```js[m
[32m+[m[32mconst buf = Buffer.alloc(11, 'aGVsbG8gd29ybGQ=', 'base64');[m
[32m+[m[32mconsole.log(buf);[m
[32m+[m[32m  // <Buffer 68 65 6c 6c 6f 20 77 6f 72 6c 64>[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32mCalling `Buffer.alloc(size)` can be significantly slower than the alternative[m
[32m+[m[32m`Buffer.allocUnsafe(size)` but ensures that the newly created `Buffer` instance[m
[32m+[m[32mcontents will *never contain sensitive data*.[m
[32m+[m
[32m+[m[32mA `TypeError` will be thrown if `size` is not a number.[m
[32m+[m
[32m+[m[32m### Class Method: Buffer.allocUnsafe(size)[m
[32m+[m[32m<!-- YAML[m
[32m+[m[32madded: v5.10.0[m
[32m+[m[32m-->[m
[32m+[m
[32m+[m[32m* `size` {Number}[m
[32m+[m
[32m+[m[32mAllocates a new *non-zero-filled* `Buffer` of `size` bytes.  The `size` must[m
[32m+[m[32mbe less than or equal to the value of `require('buffer').kMaxLength` (on 64-bit[m
[32m+[m[32marchitectures, `kMaxLength` is `(2^31)-1`). Otherwise, a [`RangeError`][] is[m
[32m+[m[32mthrown. A zero-length Buffer will be created if a `size` less than or equal to[m
[32m+[m[32m0 is specified.[m
[32m+[m
[32m+[m[32mThe underlying memory for `Buffer` instances created in this way is *not[m
[32m+[m[32minitialized*. The contents of the newly created `Buffer` are unknown and[m
[32m+[m[32m*may contain sensitive data*. Use [`buf.fill(0)`][] to initialize such[m
[32m+[m[32m`Buffer` instances to zeroes.[m
[32m+[m
[32m+[m[32m```js[m
[32m+[m[32mconst buf = Buffer.allocUnsafe(5);[m
[32m+[m[32mconsole.log(buf);[m
[32m+[m[32m  // <Buffer 78 e0 82 02 01>[m
[32m+[m[32m  // (octets will be different, every time)[m
[32m+[m[32mbuf.fill(0);[m
[32m+[m[32mconsole.log(buf);[m
[32m+[m[32m  // <Buffer 00 00 00 00 00>[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32mA `TypeError` will be thrown if `size` is not a number.[m
[32m+[m
[32m+[m[32mNote that the `Buffer` module pre-allocates an internal `Buffer` instance of[m
[32m+[m[32msize `Buffer.poolSize` that is used as a pool for the fast allocation of new[m
[32m+[m[32m`Buffer` instances created using `Buffer.allocUnsafe(size)` (and the deprecated[m
[32m+[m[32m`new Buffer(size)` constructor) only when `size` is less than or equal to[m
[32m+[m[32m`Buffer.poolSize >> 1` (floor of `Buffer.poolSize` divided by two). The default[m
[32m+[m[32mvalue of `Buffer.poolSize` is `8192` but can be modified.[m
[32m+[m
[32m+[m[32mUse of this pre-allocated internal memory pool is a key difference between[m
[32m+[m[32mcalling `Buffer.alloc(size, fill)` vs. `Buffer.allocUnsafe(size).fill(fill)`.[m
[32m+[m[32mSpecifically, `Buffer.alloc(size, fill)` will *never* use the internal Buffer[m
[32m+[m[32mpool, while `Buffer.allocUnsafe(size).fill(fill)` *will* use the internal[m
[32m+[m[32mBuffer pool if `size` is less than or equal to half `Buffer.poolSize`. The[m
[32m+[m[32mdifference is subtle but can be important when an application requires the[m
[32m+[m[32madditional performance that `Buffer.allocUnsafe(size)` provides.[m
[32m+[m
[32m+[m[32m### Class Method: Buffer.allocUnsafeSlow(size)[m
[32m+[m[32m<!-- YAML[m
[32m+[m[32madded: v5.10.0[m
[32m+[m[32m-->[m
[32m+[m
[32m+[m[32m* `size` {Number}[m
[32m+[m
[32m+[m[32mAllocates a new *non-zero-filled* and non-pooled `Buffer` of `size` bytes.  The[m
[32m+[m[32m`size` must be less than or equal to the value of[m
[32m+[m[32m`require('buffer').kMaxLength` (on 64-bit architectures, `kMaxLength` is[m
[32m+[m[32m`(2^31)-1`). Otherwise, a [`RangeError`][] is thrown. A zero-length Buffer will[m
[32m+[m[32mbe created if a `size` less than or equal to 0 is specified.[m
[32m+[m
[32m+[m[32mThe underlying memory for `Buffer` instances created in this way is *not[m
[32m+[m[32minitialized*. The contents of the newly created `Buffer` are unknown and[m
[32m+[m[32m*may contain sensitive data*. Use [`buf.fill(0)`][] to initialize such[m
[32m+[m[32m`Buffer` instances to zeroes.[m
[32m+[m
[32m+[m[32mWhen using `Buffer.allocUnsafe()` to allocate new `Buffer` instances,[m
[32m+[m[32mallocations under 4KB are, by default, sliced from a single pre-allocated[m
[32m+[m[32m`Buffer`. This allows applications to avoid the garbage collection overhead of[m
[32m+[m[32mcreating many individually allocated Buffers. This approach improves both[m
[32m+[m[32mperformance and memory usage by eliminating the need to track and cleanup as[m
[32m+[m[32mmany `Persistent` objects.[m
[32m+[m
[32m+[m[32mHowever, in the case where a developer may need to retain a small chunk of[m
[32m+[m[32mmemory from a pool for an indeterminate amount of time, it may be appropriate[m
[32m+[m[32mto create an un-pooled Buffer instance using `Buffer.allocUnsafeSlow()` then[m
[32m+[m[32mcopy out the relevant bits.[m
[32m+[m
[32m+[m[32m```js[m
[32m+[m[32m// need to keep around a few small chunks of memory[m
[32m+[m[32mconst store = [];[m
[32m+[m
[32m+[m[32msocket.on('readable', () => {[m
[32m+[m[32m  const data = socket.read();[m
[32m+[m[32m  // allocate for retained data[m
[32m+[m[32m  const sb = Buffer.allocUnsafeSlow(10);[m
[32m+[m[32m  // copy the data into the new allocation[m
[32m+[m[32m  data.copy(sb, 0, 0, 10);[m
[32m+[m[32m  store.push(sb);[m
[32m+[m[32m});[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32mUse of `Buffer.allocUnsafeSlow()` should be used only as a last resort *after*[m
[32m+[m[32ma developer has observed undue memory retention in their applications.[m
[32m+[m
[32m+[m[32mA `TypeError` will be thrown if `size` is not a number.[m
[32m+[m
[32m+[m[32m### All the Rest[m
[32m+[m
[32m+[m[32mThe rest of the `Buffer` API is exactly the same as in node.js.[m
[32m+[m[32m[See the docs](https://nodejs.org/api/buffer.html).[m
[32m+[m
[32m+[m
[32m+[m[32m## Related links[m
[32m+[m
[32m+[m[32m- [Node.js issue: Buffer(number) is unsafe](https://github.com/nodejs/node/issues/4660)[m
[32m+[m[32m- [Node.js Enhancement Proposal: Buffer.from/Buffer.alloc/Buffer.zalloc/Buffer() soft-deprecate](https://github.com/nodejs/node-eps/pull/4)[m
[32m+[m
[32m+[m[32m## Why is `Buffer` unsafe?[m
[32m+[m
[32m+[m[32mToday, the node.js `Buffer` constructor is overloaded to handle many different argument[m
[32m+[m[32mtypes like `String`, `Array`, `Object`, `TypedArrayView` (`Uint8Array`, etc.),[m
[32m+[m[32m`ArrayBuffer`, and also `Number`.[m
[32m+[m
[32m+[m[32mThe API is optimized for convenience: you can throw any type at it, and it will try to do[m
[32m+[m[32mwhat you want.[m
[32m+[m
[32m+[m[32mBecause the Buffer constructor is so powerful, you often see code like this:[m
[32m+[m
[32m+[m[32m```js[m
[32m+[m[32m// Convert UTF-8 strings to hex[m
[32m+[m[32mfunction toHex (str) {[m
[32m+[m[32m  return new Buffer(str).toString('hex')[m
[32m+[m[32m}[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32m***But what happens if `toHex` is called with a `Number` argument?***[m
[32m+[m
[32m+[m[32m### Remote Memory Disclosure[m
[32m+[m
[32m+[m[32mIf an attacker can make your program call the `Buffer` constructor with a `Number`[m
[32m+[m[32margument, then they can make it allocate uninitialized memory from the node.js process.[m
[32m+[m[32mThis could potentially disclose TLS private keys, user data, or database passwords.[m
[32m+[m
[32m+[m[32mWhen the `Buffer` constructor is passed a `Number` argument, it returns an[m
[32m+[m[32m**UNINITIALIZED** block of memory of the specified `size`. When you create a `Buffer` like[m
[32m+[m[32mthis, you **MUST** overwrite the contents before returning it to the user.[m
[32m+[m
[32m+[m[32mFrom the [node.js docs](https://nodejs.org/api/buffer.html#buffer_new_buffer_size):[m
[32m+[m
[32m+[m[32m> `new Buffer(size)`[m
[32m+[m[32m>[m
[32m+[m[32m> - `size` Number[m
[32m+[m[32m>[m
[32m+[m[32m> The underlying memory for `Buffer` instances created in this way is not initialized.[m
[32m+[m[32m> **The contents of a newly created `Buffer` are unknown and could contain sensitive[m
[32m+[m[32m> data.** Use `buf.fill(0)` to initialize a Buffer to zeroes.[m
[32m+[m
[32m+[m[32m(Emphasis our own.)[m
[32m+[m
[32m+[m[32mWhenever the programmer intended to create an uninitialized `Buffer` you often see code[m
[32m+[m[32mlike this:[m
[32m+[m
[32m+[m[32m```js[m
[32m+[m[32mvar buf = new Buffer(16)[m
[32m+[m
[32m+[m[32m// Immediately overwrite the uninitialized buffer with data from another buffer[m
[32m+[m[32mfor (var i = 0; i < buf.length; i++) {[m
[32m+[m[32m  buf[i] = otherBuf[i][m
[32m+[m[32m}[m
[32m+[m[32m```[m
[32m+[m
[32m+[m
[32m+[m[32m### Would this ever be a problem in real code?[m
[32m+[m
[32m+[m[32mYes. It's surprisingly common to forget to check the type of your variables in a[m
[32m+[m[32mdynamically-typed language like JavaScript.[m
[32m+[m
[32m+[m[32mUsually the consequences of assuming the wrong type is that your program crashes with an[m
[32m+[m[32muncaught exception. But the failure mode for forgetting to check the type of arguments to[m
[32m+[m[32mthe `Buffer` constructor is more catastrophic.[m
[32m+[m
[32m+[m[32mHere's an example of a vulnerable service that takes a JSON payload and converts it to[m
[32m+[m[32mhex:[m
[32m+[m
[32m+[m[32m```js[m
[32m+[m[32m// Take a JSON payload {str: "some string"} and convert it to hex[m
[32m+[m[32mvar server = http.createServer(function (req, res) {[m
[32m+[m[32m  var data = ''[m
[32m+[m[32m  req.setEncoding('utf8')[m
[32m+[m[32m  req.on('data', function (chunk) {[m
[32m+[m[32m    data += chunk[m
[32m+[m[32m  })[m
[32m+[m[32m  req.on('end', function () {[m
[32m+[m[32m    var body = JSON.parse(data)[m
[32m+[m[32m    res.end(new Buffer(body.str).toString('hex'))[m
[32m+[m[32m  })[m
[32m+[m[32m})[m
[32m+[m
[32m+[m[32mserver.listen(8080)[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32mIn this example, an http client just has to send:[m
[32m+[m
[32m+[m[32m```json[m
[32m+[m[32m{[m
[32m+[m[32m  "str": 1000[m
[32m+[m[32m}[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32mand it will get back 1,000 bytes of uninitialized memory from the server.[m
[32m+[m
[32m+[m[32mThis is a very serious bug. It's similar in severity to the[m
[32m+[m[32m[the Heartbleed bug](http://heartbleed.com/) that allowed disclosure of OpenSSL process[m
[32m+[m[32mmemory by remote attackers.[m
[32m+[m
[32m+[m
[32m+[m[32m### Which real-world packages were vulnerable?[m
[32m+[m
[32m+[m[32m#### [`bittorrent-dht`](https://www.npmjs.com/package/bittorrent-dht)[m
[32m+[m
[32m+[m[32m[Mathias Buus](https://github.com/mafintosh) and I[m
[32m+[m[32m([Feross Aboukhadijeh](http://feross.org/)) found this issue in one of our own packages,[m
[32m+[m[32m[`bittorrent-dht`](https://www.npmjs.com/package/bittorrent-dht). The bug would allow[m
[32m+[m[32manyone on the internet to send a series of messages to a user of `bittorrent-dht` and get[m
[32m+[m[32mthem to reveal 20 bytes at a time of uninitialized memory from the node.js process.[m
[32m+[m
[32m+[m[32mHere's[m
[32m+[m[32m[the commit](https://github.com/feross/bittorrent-dht/commit/6c7da04025d5633699800a99ec3fbadf70ad35b8)[m
[32m+[m[32mthat fixed it. We released a new fixed version, created a[m
[32m+[m[32m[Node Security Project disclosure](https://nodesecurity.io/advisories/68), and deprecated all[m
[32m+[m[32mvulnerable versions on npm so users will get a warning to upgrade to a newer version.[m
[32m+[m
[32m+[m[32m#### [`ws`](https://www.npmjs.com/package/ws)[m
[32m+[m
[32m+[m[32mThat got us wondering if there were other vulnerable packages. Sure enough, within a short[m
[32m+[m[32mperiod of time, we found the same issue in [`ws`](https://www.npmjs.com/package/ws), the[m
[32m+[m[32mmost popular WebSocket implementation in node.js.[m
[32m+[m
[32m+[m[32mIf certain APIs were called with `Number` parameters instead of `String` or `Buffer` as[m
[32m+[m[32mexpected, then uninitialized server memory would be disclosed to the remote peer.[m
[32m+[m
[32m+[m[32mThese were the vulnerable methods:[m
[32m+[m
[32m+[m[32m```js[m
[32m+[m[32msocket.send(number)[m
[32m+[m[32msocket.ping(number)[m
[32m+[m[32msocket.pong(number)[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32mHere's a vulnerable socket server with some echo functionality:[m
[32m+[m
[32m+[m[32m```js[m
[32m+[m[32mserver.on('connection', function (socket) {[m
[32m+[m[32m  socket.on('message', function (message) {[m
[32m+[m[32m    message = JSON.parse(message)[m
[32m+[m[32m    if (message.type === 'echo') {[m
[32m+[m[32m      socket.send(message.data) // send back the user's message[m
[32m+[m[32m    }[m
[32m+[m[32m  })[m
[32m+[m[32m})[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32m`socket.send(number)` called on the server, will disclose server memory.[m
[32m+[m
[32m+[m[32mHere's [the release](https://github.com/websockets/ws/releases/tag/1.0.1) where the issue[m
[32m+[m[32mwas fixed, with a more detailed explanation. Props to[m
[32m+[m[32m[Arnout Kazemier](https://github.com/3rd-Eden) for the quick fix. Here's the[m
[32m+[m[32m[Node Security Project disclosure](https://nodesecurity.io/advisories/67).[m
[32m+[m
[32m+[m
[32m+[m[32m### What's the solution?[m
[32m+[m
[32m+[m[32mIt's important that node.js offers a fast way to get memory otherwise performance-critical[m
[32m+[m[32mapplications would needlessly get a lot slower.[m
[32m+[m
[32m+[m[32mBut we need a better way to *signal our intent* as programmers. **When we want[m
[32m+[m[32muninitialized memory, we should request it explicitly.**[m
[32m+[m
[32m+[m[32mSensitive functionality should not be packed into a developer-friendly API that loosely[m
[32m+[m[32maccepts many different types. This type of API encourages the lazy practice of passing[m
[32m+[m[32mvariables in without checking the type very carefully.[m
[32m+[m
[32m+[m[32m#### A new API: `Buffer.allocUnsafe(number)`[m
[32m+[m
[32m+[m[32mThe functionality of creating buffers with uninitialized memory should be part of another[m
[32m+[m[32mAPI. We propose `Buffer.allocUnsafe(number)`. This way, it's not part of an API that[m
[32m+[m[32mfrequently gets user input of all sorts of different types passed into it.[m
[32m+[m
[32m+[m[32m```js[m
[32m+[m[32mvar buf = Buffer.allocUnsafe(16) // careful, uninitialized memory![m
[32m+[m
[32m+[m[32m// Immediately overwrite the uninitialized buffer with data from another buffer[m
[32m+[m[32mfor (var i = 0; i < buf.length; i++) {[m
[32m+[m[32m  buf[i] = otherBuf[i][m
[32m+[m[32m}[m
[32m+[m[32m```[m
[32m+[m
[32m+[m
[32m+[m[32m### How do we fix node.js core?[m
[32m+[m
[32m+[m[32mWe sent [a PR to node.js core](https://github.com/nodejs/node/pull/4514) (merged as[m
[32m+[m[32m`semver-major`) which defends against one case:[m
[32m+[m
[32m+[m[32m```js[m
[32m+[m[32mvar str = 16[m
[32m+[m[32mnew Buffer(str, 'utf8')[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32mIn this situation, it's implied that the programmer intended the first argument to be a[m
[32m+[m[32mstring, since they passed an encoding as a second argument. Today, node.js will allocate[m
[32m+[m[32muninitialized memory in the case of `new Buffer(number, encoding)`, which is probably not[m
[32m+[m[32mwhat the programmer intended.[m
[32m+[m
[32m+[m[32mBut this is only a partial solution, since if the programmer does `new Buffer(variable)`[m
[32m+[m[32m(without an `encoding` parameter) there's no way to know what they intended. If `variable`[m
[32m+[m[32mis sometimes a number, then uninitialized memory will sometimes be returned.[m
[32m+[m
[32m+[m[32m### What's the real long-term fix?[m
[32m+[m
[32m+[m[32mWe could deprecate and remove `new Buffer(number)` and use `Buffer.allocUnsafe(number)` when[m
[32m+[m[32mwe need uninitialized memory. But that would break 1000s of packages.[m
[32m+[m
[32m+[m[32m~~We believe the best solution is to:~~[m
[32m+[m
[32m+[m[32m~~1. Change `new Buffer(number)` to return safe, zeroed-out memory~~[m
[32m+[m
[32m+[m[32m~~2. Create a new API for creating uninitialized Buffers. We propose: `Buffer.allocUnsafe(number)`~~[m
[32m+[m
[32m+[m[32m#### Update[m
[32m+[m
[32m+[m[32mWe now support adding three new APIs:[m
[32m+[m
[32m+[m[32m- `Buffer.from(value)` - convert from any type to a buffer[m
[32m+[m[32m- `Buffer.alloc(size)` - create a zero-filled buffer[m
[32m+[m[32m- `Buffer.allocUnsafe(size)` - create an uninitialized buffer with given size[m
[32m+[m
[32m+[m[32mThis solves the core problem that affected `ws` and `bittorrent-dht` which is[m
[32m+[m[32m`Buffer(variable)` getting tricked into taking a number argument.[m
[32m+[m
[32m+[m[32mThis way, existing code continues working and the impact on the npm ecosystem will be[m
[32m+[m[32mminimal. Over time, npm maintainers can migrate performance-critical code to use[m
[32m+[m[32m`Buffer.allocUnsafe(number)` instead of `new Buffer(number)`.[m
[32m+[m
[32m+[m
[32m+[m[32m### Conclusion[m
[32m+[m
[32m+[m[32mWe think there's a serious design issue with the `Buffer` API as it exists today. It[m
[32m+[m[32mpromotes insecure software by putting high-risk functionality into a convenient API[m
[32m+[m[32mwith friendly "developer ergonomics".[m
[32m+[m
[32m+[m[32mThis wasn't merely a theoretical exercise because we found the issue in some of the[m
[32m+[m[32mmost popular npm packages.[m
[32m+[m
[32m+[m[32mFortunately, there's an easy fix that can be applied today. Use `safe-buffer` in place of[m
[32m+[m[32m`buffer`.[m
[32m+[m
[32m+[m[32m```js[m
[32m+[m[32mvar Buffer = require('safe-buffer').Buffer[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32mEventually, we hope that node.js core can switch to this new, safer behavior. We believe[m
[32m+[m[32mthe impact on the ecosystem would be minimal since it's not a breaking change.[m
[32m+[m[32mWell-maintained, popular packages would be updated to use `Buffer.alloc` quickly, while[m
[32m+[m[32molder, insecure packages would magically become safe from this attack vector.[m
[32m+[m
[32m+[m
[32m+[m[32m## links[m
[32m+[m
[32m+[m[32m- [Node.js PR: buffer: throw if both length and enc are passed](https://github.com/nodejs/node/pull/4514)[m
[32m+[m[32m- [Node Security Project disclosure for `ws`](https://nodesecurity.io/advisories/67)[m
[32m+[m[32m- [Node Security Project disclosure for`bittorrent-dht`](https://nodesecurity.io/advisories/68)[m
[32m+[m
[32m+[m
[32m+[m[32m## credit[m
[32m+[m
[32m+[m[32mThe original issues in `bittorrent-dht`[m
[32m+[m[32m([disclosure](https://nodesecurity.io/advisories/68)) and[m
[32m+[m[32m`ws` ([disclosure](https://nodesecurity.io/advisories/67)) were discovered by[m
[32m+[m[32m[Mathias Buus](https://github.com/mafintosh) and[m
[32m+[m[32m[Feross Aboukhadijeh](http://feross.org/).[m
[32m+[m
[32m+[m[32mThanks to [Adam Baldwin](https://github.com/evilpacket) for helping disclose these issues[m
[32m+[m[32mand for his work running the [Node Security Project](https://nodesecurity.io/).[m
[32m+[m
[32m+[m[32mThanks to [John Hiesey](https://github.com/jhiesey) for proofreading this README and[m
[32m+[m[32mauditing the code.[m
[32m+[m
[32m+[m
[32m+[m[32m## license[m
[32m+[m
[32m+[m[32mMIT. Copyright (C) [Feross Aboukhadijeh](http://feross.org)[m
[1mdiff --git a/node_modules/readable-stream/node_modules/safe-buffer/index.d.ts b/node_modules/readable-stream/node_modules/safe-buffer/index.d.ts[m
[1mnew file mode 100644[m
[1mindex 0000000..e9fed80[m
[1m--- /dev/null[m
[1m+++ b/node_modules/readable-stream/node_modules/safe-buffer/index.d.ts[m
[36m@@ -0,0 +1,187 @@[m
[32m+[m[32mdeclare module "safe-buffer" {[m
[32m+[m[32m  export class Buffer {[m
[32m+[m[32m    length: number[m
[32m+[m[32m    write(string: string, offset?: number, length?: number, encoding?: string): number;[m
[32m+[m[32m    toString(encoding?: string, start?: number, end?: number): string;[m
[32m+[m[32m    toJSON(): { type: 'Buffer', data: any[] };[m
[32m+[m[32m    equals(otherBuffer: Buffer): boolean;[m
[32m+[m[32m    compare(otherBuffer: Buffer, targetStart?: number, targetEnd?: number, sourceStart?: number, sourceEnd?: number): number;[m
[32m+[m[32m    copy(targetBuffer: Buffer, targetStart?: number, sourceStart?: number, sourceEnd?: number): number;[m
[32m+[m[32m    slice(start?: number, end?: number): Buffer;[m
[32m+[m[32m    writeUIntLE(value: number, offset: number, byteLength: number, noAssert?: boolean): number;[m
[32m+[m[32m    writeUIntBE(value: number, offset: number, byteLength: number, noAssert?: boolean): number;[m
[32m+[m[32m    writeIntLE(value: number, offset: number, byteLength: number, noAssert?: boolean): number;[m
[32m+[m[32m    writeIntBE(value: number, offset: number, byteLength: number, noAssert?: boolean): number;[m
[32m+[m[32m    readUIntLE(offset: number, byteLength: number, noAssert?: boolean): number;[m
[32m+[m[32m    readUIntBE(offset: number, byteLength: number, noAssert?: boolean): number;[m
[32m+[m[32m    readIntLE(offset: number, byteLength: number, noAssert?: boolean): number;[m
[32m+[m[32m    readIntBE(offset: number, byteLength: number, noAssert?: boolean): number;[m
[32m+[m[32m    readUInt8(offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    readUInt16LE(offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    readUInt16BE(offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    readUInt32LE(offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    readUInt32BE(offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    readInt8(offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    readInt16LE(offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    readInt16BE(offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    readInt32LE(offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    readInt32BE(offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    readFloatLE(offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    readFloatBE(offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    readDoubleLE(offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    readDoubleBE(offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    swap16(): Buffer;[m
[32m+[m[32m    swap32(): Buffer;[m
[32m+[m[32m    swap64(): Buffer;[m
[32m+[m[32m    writeUInt8(value: number, offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    writeUInt16LE(value: number, offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    writeUInt16BE(value: number, offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    writeUInt32LE(value: number, offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    writeUInt32BE(value: number, offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    writeInt8(value: number, offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    writeInt16LE(value: number, offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    writeInt16BE(value: number, offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    writeInt32LE(value: number, offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    writeInt32BE(value: number, offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    writeFloatLE(value: number, offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    writeFloatBE(value: number, offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    writeDoubleLE(value: number, offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    writeDoubleBE(value: number, offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    fill(value: any, offset?: number, end?: number): this;[m
[32m+[m[32m    indexOf(value: string | number | Buffer, byteOffset?: number, encoding?: string): number;[m
[32m+[m[32m    lastIndexOf(value: string | number | Buffer, byteOffset?: number, encoding?: string): number;[m
[32m+[m[32m    includes(value: string | number | Buffer, byteOffset?: number, encoding?: string): boolean;[m
[32m+[m
[32m+[m[32m    /**[m
[32m+[m[32m     * Allocates a new buffer containing the given {str}.[m
[32m+[m[32m     *[m
[32m+[m[32m     * @param str String to store in buffer.[m
[32m+[m[32m     * @param encoding encoding to use, optional.  Default is 'utf8'[m
[32m+[m[32m     */[m
[32m+[m[32m     constructor (str: string, encoding?: string);[m
[32m+[m[32m    /**[m
[32m+[m[32m     * Allocates a new buffer of {size} octets.[m
[32m+[m[32m     *[m
[32m+[m[32m     * @param size count of octets to allocate.[m
[32m+[m[32m     */[m
[32m+[m[32m    constructor (size: number);[m
[32m+[m[32m    /**[m
[32m+[m[32m     * Allocates a new buffer containing the given {array} of octets.[m
[32m+[m[32m     *[m
[32m+[m[32m     * @param array The octets to store.[m
[32m+[m[32m     */[m
[32m+[m[32m    constructor (array: Uint8Array);[m
[32m+[m[32m    /**[m
[32m+[m[32m     * Produces a Buffer backed by the same allocated memory as[m
[32m+[m[32m     * the given {ArrayBuffer}.[m
[32m+[m[32m     *[m
[32m+[m[32m     *[m
[32m+[m[32m     * @param arrayBuffer The ArrayBuffer with which to share memory.[m
[32m+[m[32m     */[m
[32m+[m[32m    constructor (arrayBuffer: ArrayBuffer);[m
[32m+[m[32m    /**[m
[32m+[m[32m     * Allocates a new buffer containing the given {array} of octets.[m
[32m+[m[32m     *[m
[32m+[m[32m     * @param array The octets to store.[m
[32m+[m[32m     */[m
[32m+[m[32m    constructor (array: any[]);[m
[32m+[m[32m    /**[m
[32m+[m[32m     * Copies the passed {buffer} data onto a new {Buffer} instance.[m
[32m+[m[32m     *[m
[32m+[m[32m     * @param buffer The buffer to copy.[m
[32m+[m[32m     */[m
[32m+[m[32m    constructor (buffer: Buffer);[m
[32m+[m[32m    prototype: Buffer;[m
[32m+[m[32m    /**[m
[32m+[m[32m     * Allocates a new Buffer using an {array} of octets.[m
[32m+[m[32m     *[m
[32m+[m[32m     * @param array[m
[32m+[m[32m     */[m
[32m+[m[32m    static from(array: any[]): Buffer;[m
[32m+[m[32m    /**[m
[32m+[m[32m     * When passed a reference to the .buffer property of a TypedArray instance,[m
[32m+[m[32m     * the newly created Buffer will share the same allocated memory as the TypedArray.[m
[32m+[m[32m     * The optional {byteOffset} and {length} arguments specify a memory range[m
[32m+[m[32m     * within the {arrayBuffer} that will be shared by the Buffer.[m
[32m+[m[32m     *[m
[32m+[m[32m     * @param arrayBuffer The .buffer property of a TypedArray or a new ArrayBuffer()[m
[32m+[m[32m     * @param byteOffset[m
[32m+[m[32m     * @param length[m
[32m+[m[32m     */[m
[32m+[m[32m    static from(arrayBuffer: ArrayBuffer, byteOffset?: number, length?: number): Buffer;[m
[32m+[m[32m    /**[m
[32m+[m[32m     * Copies the passed {buffer} data onto a new Buffer instance.[m
[32m+[m[32m     *[m
[32m+[m[32m     * @param buffer[m
[32m+[m[32m     */[m
[32m+[m[32m    static from(buffer: Buffer): Buffer;[m
[32m+[m[32m    /**[m
[32m+[m[32m     * Creates a new Buffer containing the given JavaScript string {str}.[m
[32m+[m[32m     * If provided, the {encoding} parameter identifies the character encoding.[m
[32m+[m[32m     * If not provided, {encoding} defaults to 'utf8'.[m
[32m+[m[32m     *[m
[32m+[m[32m     * @param str[m
[32m+[m[32m     */[m
[32m+[m[32m    static from(str: string, encoding?: string): Buffer;[m
[32m+[m[32m    /**[m
[32m+[m[32m     * Returns true if {obj} is a Buffer[m
[32m+[m[32m     *[m
[32m+[m[32m     * @param obj object to test.[m
[32m+[m[32m     */[m
[32m+[m[32m    static isBuffer(obj: any): obj is Buffer;[m
[32m+[m[32m    /**[m
[32m+[m[32m     * Returns true if {encoding} is a valid encoding argument.[m
[32m+[m[32m     * Valid string encodings in Node 0.12: 'ascii'|'utf8'|'utf16le'|'ucs2'(alias of 'utf16le')|'base64'|'binary'(deprecated)|'hex'[m
[32m+[m[32m     *[m
[32m+[m[32m     * @param encoding string to test.[m
[32m+[m[32m     */[m
[32m+[m[32m    static isEncoding(encoding: string): boolean;[m
[32m+[m[32m    /**[m
[32m+[m[32m     * Gives the actual byte length of a string. encoding defaults to 'utf8'.[m
[32m+[m[32m     * This is not the same as String.prototype.length since that returns the number of characters in a string.[m
[32m+[m[32m     *[m
[32m+[m[32m     * @param string string to test.[m
[32m+[m[32m     * @param encoding encoding used to evaluate (defaults to 'utf8')[m
[32m+[m[32m     */[m
[32m+[m[32m    static byteLength(string: string, encoding?: string): number;[m
[32m+[m[32m    /**[m
[32m+[m[32m     * Returns a buffer which is the result of concatenating all the buffers in the list together.[m
[32m+[m[32m     *[m
[32m+[m[32m     * If the list has no items, or if the totalLength is 0, then it returns a zero-length buffer.[m
[32m+[m[32m     * If the list has exactly one item, then the first item of the list is returned.[m
[32m+[m[32m     * If the list has more than one item, then a new Buffer is created.[m
[32m+[m[32m     *[m
[32m+[m[32m     * @param list An array of Buffer objects to concatenate[m
[32m+[m[32m     * @param totalLength Total length of the buffers when concatenated.[m
[32m+[m[32m     *   If totalLength is not provided, it is read from the buffers in the list. However, this adds an additional loop to the function, so it is faster to provide the length explicitly.[m
[32m+[m[32m     */[m
[32m+[m[32m    static concat(list: Buffer[], totalLength?: number): Buffer;[m
[32m+[m[32m    /**[m
[32m+[m[32m     * The same as buf1.compare(buf2).[m
[32m+[m[32m     */[m
[32m+[m[32m    static compare(buf1: Buffer, buf2: Buffer): number;[m
[32m+[m[32m    /**[m
[32m+[m[32m     * Allocates a new buffer of {size} octets.[m
[32m+[m[32m     *[m
[32m+[m[32m     * @param size count of octets to allocate.[m
[32m+[m[32m     * @param fill if specified, buffer will be initialized by calling buf.fill(fill).[m
[32m+[m[32m     *    If parameter is omitted, buffer will be filled with zeros.[m
[32m+[m[32m     * @param encoding encoding used for call to buf.fill while initalizing[m
[32m+[m[32m     */[m
[32m+[m[32m    static alloc(size: number, fill?: string | Buffer | number, encoding?: string): Buffer;[m
[32m+[m[32m    /**[m
[32m+[m[32m     * Allocates a new buffer of {size} octets, leaving memory not initialized, so the contents[m
[32m+[m[32m     * of the newly created Buffer are unknown and may contain sensitive data.[m
[32m+[m[32m     *[m
[32m+[m[32m     * @param size count of octets to allocate[m
[32m+[m[32m     */[m
[32m+[m[32m    static allocUnsafe(size: number): Buffer;[m
[32m+[m[32m    /**[m
[32m+[m[32m     * Allocates a new non-pooled buffer of {size} octets, leaving memory not initialized, so the contents[m
[32m+[m[32m     * of the newly created Buffer are unknown and may contain sensitive data.[m
[32m+[m[32m     *[m
[32m+[m[32m     * @param size count of octets to allocate[m
[32m+[m[32m     */[m
[32m+[m[32m    static allocUnsafeSlow(size: number): Buffer;[m
[32m+[m[32m  }[m
[32m+[m[32m}[m
\ No newline at end of file[m
[1mdiff --git a/node_modules/readable-stream/node_modules/safe-buffer/index.js b/node_modules/readable-stream/node_modules/safe-buffer/index.js[m
[1mnew file mode 100644[m
[1mindex 0000000..22438da[m
[1m--- /dev/null[m
[1m+++ b/node_modules/readable-stream/node_modules/safe-buffer/index.js[m
[36m@@ -0,0 +1,62 @@[m
[32m+[m[32m/* eslint-disable node/no-deprecated-api */[m
[32m+[m[32mvar buffer = require('buffer')[m
[32m+[m[32mvar Buffer = buffer.Buffer[m
[32m+[m
[32m+[m[32m// alternative to using Object.keys for old browsers[m
[32m+[m[32mfunction copyProps (src, dst) {[m
[32m+[m[32m  for (var key in src) {[m
[32m+[m[32m    dst[key] = src[key][m
[32m+[m[32m  }[m
[32m+[m[32m}[m
[32m+[m[32mif (Buffer.from && Buffer.alloc && Buffer.allocUnsafe && Buffer.allocUnsafeSlow) {[m
[32m+[m[32m  module.exports = buffer[m
[32m+[m[32m} else {[m
[32m+[m[32m  // Copy properties from require('buffer')[m
[32m+[m[32m  copyProps(buffer, exports)[m
[32m+[m[32m  exports.Buffer = SafeBuffer[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction SafeBuffer (arg, encodingOrOffset, length) {[m
[32m+[m[32m  return Buffer(arg, encodingOrOffset, length)[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m// Copy static methods from Buffer[m
[32m+[m[32mcopyProps(Buffer, SafeBuffer)[m
[32m+[m
[32m+[m[32mSafeBuffer.from = function (arg, encodingOrOffset, length) {[m
[32m+[m[32m  if (typeof arg === 'number') {[m
[32m+[m[32m    throw new TypeError('Argument must not be a number')[m
[32m+[m[32m  }[m
[32m+[m[32m  return Buffer(arg, encodingOrOffset, length)[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mSafeBuffer.alloc = function (size, fill, encoding) {[m
[32m+[m[32m  if (typeof size !== 'number') {[m
[32m+[m[32m    throw new TypeError('Argument must be a number')[m
[32m+[m[32m  }[m
[32m+[m[32m  var buf = Buffer(size)[m
[32m+[m[32m  if (fill !== undefined) {[m
[32m+[m[32m    if (typeof encoding === 'string') {[m
[32m+[m[32m      buf.fill(fill, encoding)[m
[32m+[m[32m    } else {[m
[32m+[m[32m      buf.fill(fill)[m
[32m+[m[32m    }[m
[32m+[m[32m  } else {[m
[32m+[m[32m    buf.fill(0)[m
[32m+[m[32m  }[m
[32m+[m[32m  return buf[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mSafeBuffer.allocUnsafe = function (size) {[m
[32m+[m[32m  if (typeof size !== 'number') {[m
[32m+[m[32m    throw new TypeError('Argument must be a number')[m
[32m+[m[32m  }[m
[32m+[m[32m  return Buffer(size)[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mSafeBuffer.allocUnsafeSlow = function (size) {[m
[32m+[m[32m  if (typeof size !== 'number') {[m
[32m+[m[32m    throw new TypeError('Argument must be a number')[m
[32m+[m[32m  }[m
[32m+[m[32m  return buffer.SlowBuffer(size)[m
[32m+[m[32m}[m
[1mdiff --git a/node_modules/readable-stream/node_modules/safe-buffer/package.json b/node_modules/readable-stream/node_modules/safe-buffer/package.json[m
[1mnew file mode 100644[m
[1mindex 0000000..623fbc3[m
[1m--- /dev/null[m
[1m+++ b/node_modules/readable-stream/node_modules/safe-buffer/package.json[m
[36m@@ -0,0 +1,37 @@[m
[32m+[m[32m{[m
[32m+[m[32m  "name": "safe-buffer",[m
[32m+[m[32m  "description": "Safer Node.js Buffer API",[m
[32m+[m[32m  "version": "5.1.2",[m
[32m+[m[32m  "author": {[m
[32m+[m[32m    "name": "Feross Aboukhadijeh",[m
[32m+[m[32m    "email": "feross@feross.org",[m
[32m+[m[32m    "url": "http://feross.org"[m
[32m+[m[32m  },[m
[32m+[m[32m  "bugs": {[m
[32m+[m[32m    "url": "https://github.com/feross/safe-buffer/issues"[m
[32m+[m[32m  },[m
[32m+[m[32m  "devDependencies": {[m
[32m+[m[32m    "standard": "*",[m
[32m+[m[32m    "tape": "^4.0.0"[m
[32m+[m[32m  },[m
[32m+[m[32m  "homepage": "https://github.com/feross/safe-buffer",[m
[32m+[m[32m  "keywords": [[m
[32m+[m[32m    "buffer",[m
[32m+[m[32m    "buffer allocate",[m
[32m+[m[32m    "node security",[m
[32m+[m[32m    "safe",[m
[32m+[m[32m    "safe-buffer",[m
[32m+[m[32m    "security",[m
[32m+[m[32m    "uninitialized"[m
[32m+[m[32m  ],[m
[32m+[m[32m  "license": "MIT",[m
[32m+[m[32m  "main": "index.js",[m
[32m+[m[32m  "types": "index.d.ts",[m
[32m+[m[32m  "repository": {[m
[32m+[m[32m    "type": "git",[m
[32m+[m[32m    "url": "git://github.com/feross/safe-buffer.git"[m
[32m+[m[32m  },[m
[32m+[m[32m  "scripts": {[m
[32m+[m[32m    "test": "standard && tape test/*.js"[m
[32m+[m[32m  }[m
[32m+[m[32m}[m
[1mdiff --git a/node_modules/readable-stream/package.json b/node_modules/readable-stream/package.json[m
[1mnew file mode 100644[m
[1mindex 0000000..514c178[m
[1m--- /dev/null[m
[1m+++ b/node_modules/readable-stream/package.json[m
[36m@@ -0,0 +1,52 @@[m
[32m+[m[32m{[m
[32m+[m[32m  "name": "readable-stream",[m
[32m+[m[32m  "version": "2.3.8",[m
[32m+[m[32m  "description": "Streams3, a user-land copy of the stream library from Node.js",[m
[32m+[m[32m  "main": "readable.js",[m
[32m+[m[32m  "dependencies": {[m
[32m+[m[32m    "core-util-is": "~1.0.0",[m
[32m+[m[32m    "inherits": "~2.0.3",[m
[32m+[m[32m    "isarray": "~1.0.0",[m
[32m+[m[32m    "process-nextick-args": "~2.0.0",[m
[32m+[m[32m    "safe-buffer": "~5.1.1",[m
[32m+[m[32m    "string_decoder": "~1.1.1",[m
[32m+[m[32m    "util-deprecate": "~1.0.1"[m
[32m+[m[32m  },[m
[32m+[m[32m  "devDependencies": {[m
[32m+[m[32m    "assert": "^1.4.0",[m
[32m+[m[32m    "babel-polyfill": "^6.9.1",[m
[32m+[m[32m    "buffer": "^4.9.0",[m
[32m+[m[32m    "lolex": "^2.3.2",[m
[32m+[m[32m    "nyc": "^6.4.0",[m
[32m+[m[32m    "tap": "^0.7.0",[m
[32m+[m[32m    "tape": "^4.8.0"[m
[32m+[m[32m  },[m
[32m+[m[32m  "scripts": {[m
[32m+[m[32m    "test": "tap test/parallel/*.js test/ours/*.js && node test/verify-dependencies.js",[m
[32m+[m[32m    "ci": "tap test/parallel/*.js test/ours/*.js --tap | tee test.tap && node test/verify-dependencies.js",[m
[32m+[m[32m    "cover": "nyc npm test",[m
[32m+[m[32m    "report": "nyc report --reporter=lcov"[m
[32m+[m[32m  },[m
[32m+[m[32m  "repository": {[m
[32m+[m[32m    "type": "git",[m
[32m+[m[32m    "url": "git://github.com/nodejs/readable-stream"[m
[32m+[m[32m  },[m
[32m+[m[32m  "keywords": [[m
[32m+[m[32m    "readable",[m
[32m+[m[32m    "stream",[m
[32m+[m[32m    "pipe"[m
[32m+[m[32m  ],[m
[32m+[m[32m  "browser": {[m
[32m+[m[32m    "util": false,[m
[32m+[m[32m    "./readable.js": "./readable-browser.js",[m
[32m+[m[32m    "./writable.js": "./writable-browser.js",[m
[32m+[m[32m    "./duplex.js": "./duplex-browser.js",[m
[32m+[m[32m    "./lib/internal/streams/stream.js": "./lib/internal/streams/stream-browser.js"[m
[32m+[m[32m  },[m
[32m+[m[32m  "nyc": {[m
[32m+[m[32m    "include": [[m
[32m+[m[32m      "lib/**.js"[m
[32m+[m[32m    ][m
[32m+[m[32m  },[m
[32m+[m[32m  "license": "MIT"[m
[32m+[m[32m}[m
[1mdiff --git a/node_modules/readable-stream/passthrough.js b/node_modules/readable-stream/passthrough.js[m
[1mnew file mode 100644[m
[1mindex 0000000..ffd791d[m
[1m--- /dev/null[m
[1m+++ b/node_modules/readable-stream/passthrough.js[m
[36m@@ -0,0 +1 @@[m
[32m+[m[32mmodule.exports = require('./readable').PassThrough[m
[1mdiff --git a/node_modules/readable-stream/readable-browser.js b/node_modules/readable-stream/readable-browser.js[m
[1mnew file mode 100644[m
[1mindex 0000000..e503725[m
[1m--- /dev/null[m
[1m+++ b/node_modules/readable-stream/readable-browser.js[m
[36m@@ -0,0 +1,7 @@[m
[32m+[m[32mexports = module.exports = require('./lib/_stream_readable.js');[m
[32m+[m[32mexports.Stream = exports;[m
[32m+[m[32mexports.Readable = exports;[m
[32m+[m[32mexports.Writable = require('./lib/_stream_writable.js');[m
[32m+[m[32mexports.Duplex = require('./lib/_stream_duplex.js');[m
[32m+[m[32mexports.Transform = require('./lib/_stream_transform.js');[m
[32m+[m[32mexports.PassThrough = require('./lib/_stream_passthrough.js');[m
[1mdiff --git a/node_modules/readable-stream/readable.js b/node_modules/readable-stream/readable.js[m
[1mnew file mode 100644[m
[1mindex 0000000..ec89ec5[m
[1m--- /dev/null[m
[1m+++ b/node_modules/readable-stream/readable.js[m
[36m@@ -0,0 +1,19 @@[m
[32m+[m[32mvar Stream = require('stream');[m
[32m+[m[32mif (process.env.READABLE_STREAM === 'disable' && Stream) {[m
[32m+[m[32m  module.exports = Stream;[m
[32m+[m[32m  exports = module.exports = Stream.Readable;[m
[32m+[m[32m  exports.Readable = Stream.Readable;[m
[32m+[m[32m  exports.Writable = Stream.Writable;[m
[32m+[m[32m  exports.Duplex = Stream.Duplex;[m
[32m+[m[32m  exports.Transform = Stream.Transform;[m
[32m+[m[32m  exports.PassThrough = Stream.PassThrough;[m
[32m+[m[32m  exports.Stream = Stream;[m
[32m+[m[32m} else {[m
[32m+[m[32m  exports = module.exports = require('./lib/_stream_readable.js');[m
[32m+[m[32m  exports.Stream = Stream || exports;[m
[32m+[m[32m  exports.Readable = exports;[m
[32m+[m[32m  exports.Writable = require('./lib/_stream_writable.js');[m
[32m+[m[32m  exports.Duplex = require('./lib/_stream_duplex.js');[m
[32m+[m[32m  exports.Transform = require('./lib/_stream_transform.js');[m
[32m+[m[32m  exports.PassThrough = require('./lib/_stream_passthrough.js');[m
[32m+[m[32m}[m
[1mdiff --git a/node_modules/readable-stream/transform.js b/node_modules/readable-stream/transform.js[m
[1mnew file mode 100644[m
[1mindex 0000000..b1baba2[m
[1m--- /dev/null[m
[1m+++ b/node_modules/readable-stream/transform.js[m
[36m@@ -0,0 +1 @@[m
[32m+[m[32mmodule.exports = require('./readable').Transform[m
[1mdiff --git a/node_modules/readable-stream/writable-browser.js b/node_modules/readable-stream/writable-browser.js[m
[1mnew file mode 100644[m
[1mindex 0000000..ebdde6a[m
[1m--- /dev/null[m
[1m+++ b/node_modules/readable-stream/writable-browser.js[m
[36m@@ -0,0 +1 @@[m
[32m+[m[32mmodule.exports = require('./lib/_stream_writable.js');[m
[1mdiff --git a/node_modules/readable-stream/writable.js b/node_modules/readable-stream/writable.js[m
[1mnew file mode 100644[m
[1mindex 0000000..3211a6f[m
[1m--- /dev/null[m
[1m+++ b/node_modules/readable-stream/writable.js[m
[36m@@ -0,0 +1,8 @@[m
[32m+[m[32mvar Stream = require("stream")[m
[32m+[m[32mvar Writable = require("./lib/_stream_writable.js")[m
[32m+[m
[32m+[m[32mif (process.env.READABLE_STREAM === 'disable') {[m
[32m+[m[32m  module.exports = Stream && Stream.Writable || Writable[m
[32m+[m[32m} else {[m
[32m+[m[32m  module.exports = Writable[m
[32m+[m[32m}[m
[1mdiff --git a/node_modules/streamsearch/.eslintrc.js b/node_modules/streamsearch/.eslintrc.js[m
[1mnew file mode 100644[m
[1mindex 0000000..be9311d[m
[1m--- /dev/null[m
[1m+++ b/node_modules/streamsearch/.eslintrc.js[m
[36m@@ -0,0 +1,5 @@[m
[32m+[m[32m'use strict';[m
[32m+[m
[32m+[m[32mmodule.exports = {[m
[32m+[m[32m  extends: '@mscdex/eslint-config',[m
[32m+[m[32m};[m
[1mdiff --git a/node_modules/streamsearch/.github/workflows/ci.yml b/node_modules/streamsearch/.github/workflows/ci.yml[m
[1mnew file mode 100644[m
[1mindex 0000000..29d5178[m
[1m--- /dev/null[m
[1m+++ b/node_modules/streamsearch/.github/workflows/ci.yml[m
[36m@@ -0,0 +1,24 @@[m
[32m+[m[32mname: CI[m
[32m+[m
[32m+[m[32mon:[m
[32m+[m[32m  pull_request:[m
[32m+[m[32m  push:[m
[32m+[m[32m    branches: [ master ][m
[32m+[m
[32m+[m[32mjobs:[m
[32m+[m[32m  tests-linux:[m
[32m+[m[32m    runs-on: ubuntu-latest[m
[32m+[m[32m    strategy:[m
[32m+[m[32m      fail-fast: false[m
[32m+[m[32m      matrix:[m
[32m+[m[32m        node-version: [10.x, 12.x, 14.x, 16.x][m
[32m+[m[32m    steps:[m
[32m+[m[32m      - uses: actions/checkout@v2[m
[32m+[m[32m      - name: Use Node.js ${{ matrix.node-version }}[m
[32m+[m[32m        uses: actions/setup-node@v1[m
[32m+[m[32m        with:[m
[32m+[m[32m          node-version: ${{ matrix.node-version }}[m
[32m+[m[32m      - name: Install module[m
[32m+[m[32m        run: npm install[m
[32m+[m[32m      - name: Run tests[m
[32m+[m[32m        run: npm test[m
[1mdiff --git a/node_modules/streamsearch/.github/workflows/lint.yml b/node_modules/streamsearch/.github/workflows/lint.yml[m
[1mnew file mode 100644[m
[1mindex 0000000..9f9e1f5[m
[1m--- /dev/null[m
[1m+++ b/node_modules/streamsearch/.github/workflows/lint.yml[m
[36m@@ -0,0 +1,23 @@[m
[32m+[m[32mname: lint[m
[32m+[m
[32m+[m[32mon:[m
[32m+[m[32m  pull_request:[m
[32m+[m[32m  push:[m
[32m+[m[32m    branches: [ master ][m
[32m+[m
[32m+[m[32menv:[m
[32m+[m[32m  NODE_VERSION: 16.x[m
[32m+[m
[32m+[m[32mjobs:[m
[32m+[m[32m  lint-js:[m
[32m+[m[32m    runs-on: ubuntu-latest[m
[32m+[m[32m    steps:[m
[32m+[m[32m      - uses: actions/checkout@v2[m
[32m+[m[32m      - name: Use Node.js ${{ env.NODE_VERSION }}[m
[32m+[m[32m        uses: actions/setup-node@v1[m
[32m+[m[32m        with:[m
[32m+[m[32m          node-version: ${{ env.NODE_VERSION }}[m
[32m+[m[32m      - name: Install ESLint + ESLint configs/plugins[m
[32m+[m[32m        run: npm install --only=dev[m
[32m+[m[32m      - name: Lint files[m
[32m+[m[32m        run: npm run lint[m
[1mdiff --git a/node_modules/streamsearch/LICENSE b/node_modules/streamsearch/LICENSE[m
[1mnew file mode 100644[m
[1mindex 0000000..290762e[m
[1m--- /dev/null[m
[1m+++ b/node_modules/streamsearch/LICENSE[m
[36m@@ -0,0 +1,19 @@[m
[32m+[m[32mCopyright Brian White. All rights reserved.[m
[32m+[m
[32m+[m[32mPermission is hereby granted, free of charge, to any person obtaining a copy[m
[32m+[m[32mof this software and associated documentation files (the "Software"), to[m
[32m+[m[32mdeal in the Software without restriction, including without limitation the[m
[32m+[m[32mrights to use, copy, modify, merge, publish, distribute, sublicense, and/or[m
[32m+[m[32msell copies of the Software, and to permit persons to whom the Software is[m
[32m+[m[32mfurnished to do so, subject to the following conditions:[m
[32m+[m
[32m+[m[32mThe above copyright notice and this permission notice shall be included in[m
[32m+[m[32mall copies or substantial portions of the Software.[m
[32m+[m
[32m+[m[32mTHE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR[m
[32m+[m[32mIMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,[m
[32m+[m[32mFITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE[m
[32m+[m[32mAUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER[m
[32m+[m[32mLIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING[m
[32m+[m[32mFROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS[m
[32m+[m[32mIN THE SOFTWARE.[m
\ No newline at end of file[m
[1mdiff --git a/node_modules/streamsearch/README.md b/node_modules/streamsearch/README.md[m
[1mnew file mode 100644[m
[1mindex 0000000..c3934d1[m
[1m--- /dev/null[m
[1m+++ b/node_modules/streamsearch/README.md[m
[36m@@ -0,0 +1,95 @@[m
[32m+[m[32mDescription[m
[32m+[m[32m===========[m
[32m+[m
[32m+[m[32mstreamsearch is a module for [node.js](http://nodejs.org/) that allows searching a stream using the Boyer-Moore-Horspool algorithm.[m
[32m+[m
[32m+[m[32mThis module is based heavily on the Streaming Boyer-Moore-Horspool C++ implementation by Hongli Lai [here](https://github.com/FooBarWidget/boyer-moore-horspool).[m
[32m+[m
[32m+[m
[32m+[m[32mRequirements[m
[32m+[m[32m============[m
[32m+[m
[32m+[m[32m* [node.js](http://nodejs.org/) -- v10.0.0 or newer[m
[32m+[m
[32m+[m
[32m+[m[32mInstallation[m
[32m+[m[32m============[m
[32m+[m
[32m+[m[32m    npm install streamsearch[m
[32m+[m
[32m+[m[32mExample[m
[32m+[m[32m=======[m
[32m+[m
[32m+[m[32m```js[m
[32m+[m[32m  const { inspect } = require('util');[m
[32m+[m
[32m+[m[32m  const StreamSearch = require('streamsearch');[m
[32m+[m
[32m+[m[32m  const needle = Buffer.from('\r\n');[m
[32m+[m[32m  const ss = new StreamSearch(needle, (isMatch, data, start, end) => {[m
[32m+[m[32m    if (data)[m
[32m+[m[32m      console.log('data: ' + inspect(data.toString('latin1', start, end)));[m
[32m+[m[32m    if (isMatch)[m
[32m+[m[32m      console.log('match!');[m
[32m+[m[32m  });[m
[32m+[m
[32m+[m[32m  const chunks = [[m
[32m+[m[32m    'foo',[m
[32m+[m[32m    ' bar',[m
[32m+[m[32m    '\r',[m
[32m+[m[32m    '\n',[m
[32m+[m[32m    'baz, hello\r',[m
[32m+[m[32m    '\n world.',[m
[32m+[m[32m    '\r\n Node.JS rules!!\r\n\r\n',[m
[32m+[m[32m  ];[m
[32m+[m[32m  for (const chunk of chunks)[m
[32m+[m[32m    ss.push(Buffer.from(chunk));[m
[32m+[m
[32m+[m[32m  // output:[m
[32m+[m[32m  //[m
[32m+[m[32m  // data: 'foo'[m
[32m+[m[32m  // data: ' bar'[m
[32m+[m[32m  // match![m
[32m+[m[32m  // data: 'baz, hello'[m
[32m+[m[32m  // match![m
[32m+[m[32m  // data: ' world.'[m
[32m+[m[32m  // match![m
[32m+[m[32m  // data: ' Node.JS rules!!'[m
[32m+[m[32m  // match![m
[32m+[m[32m  // data: ''[m
[32m+[m[32m  // match![m
[32m+[m[32m```[m
[32m+[m
[32m+[m
[32m+[m[32mAPI[m
[32m+[m[32m===[m
[32m+[m
[32m+[m[32mProperties[m
[32m+[m[32m----------[m
[32m+[m
[32m+[m[32m* **maxMatches** - < _integer_ > - The maximum number of matches. Defaults to `Infinity`.[m
[32m+[m
[32m+[m[32m* **matches** - < _integer_ > - The current match count.[m
[32m+[m
[32m+[m
[32m+[m[32mFunctions[m
[32m+[m[32m---------[m
[32m+[m
[32m+[m[32m* **(constructor)**(< _mixed_ >needle, < _function_ >callback) - Creates and returns a new instance for searching for a _Buffer_ or _string_ `needle`. `callback` is called any time there is non-matching data and/or there is a needle match. `callback` will be called with the following arguments:[m
[32m+[m
[32m+[m[32m  1. `isMatch` - _boolean_ - Indicates whether a match has been found[m
[32m+[m
[32m+[m[32m  2. `data` - _mixed_ - If set, this contains data that did not match the needle.[m
[32m+[m
[32m+[m[32m  3. `start` - _integer_ - The index in `data` where the non-matching data begins (inclusive).[m
[32m+[m
[32m+[m[32m  4. `end` - _integer_ - The index in `data` where the non-matching data ends (exclusive).[m
[32m+[m
[32m+[m[32m  5. `isSafeData` - _boolean_ - Indicates if it is safe to store a reference to `data` (e.g. as-is or via `data.slice()`) or not, as in some cases `data` may point to a Buffer whose contents change over time.[m
[32m+[m
[32m+[m[32m* **destroy**() - _(void)_ - Emits any last remaining unmatched data that may still be buffered and then resets internal state.[m
[32m+[m
[32m+[m[32m* **push**(< _Buffer_ >chunk) - _integer_ - Processes `chunk`, searching for a match. The return value is the last processed index in `chunk` + 1.[m
[32m+[m
[32m+[m[32m* **reset**() - _(void)_ - Resets internal state. Useful for when you wish to start searching a new/different stream for example.[m
[32m+[m
[1mdiff --git a/node_modules/streamsearch/lib/sbmh.js b/node_modules/streamsearch/lib/sbmh.js[m
[1mnew file mode 100644[m
[1mindex 0000000..510cae2[m
[1m--- /dev/null[m
[1m+++ b/node_modules/streamsearch/lib/sbmh.js[m
[36m@@ -0,0 +1,267 @@[m
[32m+[m[32m'use strict';[m
[32m+[m[32m/*[m
[32m+[m[32m  Based heavily on the Streaming Boyer-Moore-Horspool C++ implementation[m
[32m+[m[32m  by Hongli Lai at: https://github.com/FooBarWidget/boyer-moore-horspool[m
[32m+[m[32m*/[m
[32m+[m[32mfunction memcmp(buf1, pos1, buf2, pos2, num) {[m
[32m+[m[32m  for (let i = 0; i < num; ++i) {[m
[32m+[m[32m    if (buf1[pos1 + i] !== buf2[pos2 + i])[m
[32m+[m[32m      return false;[m
[32m+[m[32m  }[m
[32m+[m[32m  return true;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mclass SBMH {[m
[32m+[m[32m  constructor(needle, cb) {[m
[32m+[m[32m    if (typeof cb !== 'function')[m
[32m+[m[32m      throw new Error('Missing match callback');[m
[32m+[m
[32m+[m[32m    if (typeof needle === 'string')[m
[32m+[m[32m      needle = Buffer.from(needle);[m
[32m+[m[32m    else if (!Buffer.isBuffer(needle))[m
[32m+[m[32m      throw new Error(`Expected Buffer for needle, got ${typeof needle}`);[m
[32m+[m
[32m+[m[32m    const needleLen = needle.length;[m
[32m+[m
[32m+[m[32m    this.maxMatches = Infinity;[m
[32m+[m[32m    this.matches = 0;[m
[32m+[m
[32m+[m[32m    this._cb = cb;[m
[32m+[m[32m    this._lookbehindSize = 0;[m
[32m+[m[32m    this._needle = needle;[m
[32m+[m[32m    this._bufPos = 0;[m
[32m+[m
[32m+[m[32m    this._lookbehind = Buffer.allocUnsafe(needleLen);[m
[32m+[m
[32m+[m[32m    // Initialize occurrence table.[m
[32m+[m[32m    this._occ = [[m
[32m+[m[32m      needleLen, needleLen, needleLen, needleLen, needleLen, needleLen,[m
[32m+[m[32m      needleLen, needleLen, needleLen, needleLen, needleLen, needleLen,[m
[32m+[m[32m      needleLen, needleLen, needleLen, needleLen, needleLen, needleLen,[m
[32m+[m[32m      needleLen, needleLen, needleLen, needleLen, needleLen, needleLen,[m
[32m+[m[32m      needleLen, needleLen, needleLen, needleLen, needleLen, needleLen,[m
[32m+[m[32m      needleLen, needleLen, needleLen, needleLen, needleLen, needleLen,[m
[32m+[m[32m      needleLen, needleLen, needleLen, needleLen, needleLen, needleLen,[m
[32m+[m[32m      needleLen, needleLen, needleLen, needleLen, needleLen, needleLen,[m
[32m+[m[32m      needleLen, needleLen, needleLen, needleLen, needleLen, needleLen,[m
[32m+[m[32m      needleLen, needleLen, needleLen, needleLen, needleLen, needleLen,[m
[32m+[m[32m      needleLen, needleLen, needleLen, needleLen, needleLen, needleLen,[m
[32m+[m[32m      needleLen, needleLen, needleLen, needleLen, needleLen, needleLen,[m
[32m+[m[32m      needleLen, needleLen, needleLen, needleLen, needleLen, needleLen,[m
[32m+[m[32m      needleLen, needleLen, needleLen, needleLen, needleLen, needleLen,[m
[32m+[m[32m      needleLen, needleLen, needleLen, needleLen, needleLen, needleLen,[m
[32m+[m[32m      needleLen, needleLen, needleLen, needleLen, needleLen, needleLen,[m
[32m+[m[32m      needleLen, needleLen, needleLen, needleLen, needleLen, needleLen,[m
[32m+[m[32m      needleLen, needleLen, needleLen, needleLen, needleLen, needleLen,[m
[32m+[m[32m      needleLen, needleLen, needleLen, needleLen, needleLen, needleLen,[m
[32m+[m[32m      needleLen, needleLen, needleLen, needleLen, needleLen, needleLen,[m
[32m+[m[32m      needleLen, needleLen, needleLen, needleLen, needleLen, needleLen,[m
[32m+[m[32m      needleLen, needleLen, needleLen, needleLen, needleLen, needleLen,[m
[32m+[m[32m      needleLen, needleLen, needleLen, needleLen, needleLen, needleLen,[m
[32m+[m[32m      needleLen, needleLen, needleLen, needleLen, needleLen, needleLen,[m
[32m+[m[32m      needleLen, needleLen, needleLen, needleLen, needleLen, needleLen,[m
[32m+[m[32m      needleLen, needleLen, needleLen, needleLen, needleLen, needleLen,[m
[32m+[m[32m      needleLen, needleLen, needleLen, needleLen, needleLen, needleLen,[m
[32m+[m[32m      needleLen, needleLen, needleLen, needleLen, needleLen, needleLen,[m
[32m+[m[32m      needleLen, needleLen, needleLen, needleLen, needleLen, needleLen,[m
[32m+[m[32m      needleLen, needleLen, needleLen, needleLen, needleLen, needleLen,[m
[32m+[m[32m      needleLen, needleLen, needleLen, needleLen, needleLen, needleLen,[m
[32m+[m[32m      needleLen, needleLen, needleLen, needleLen, needleLen, needleLen,[m
[32m+[m[32m      needleLen, needleLen, needleLen, needleLen, needleLen, needleLen,[m
[32m+[m[32m      needleLen, needleLen, needleLen, needleLen, needleLen, needleLen,[m
[32m+[m[32m      needleLen, needleLen, needleLen, needleLen, needleLen, needleLen,[m
[32m+[m[32m      needleLen, needleLen, needleLen, needleLen, needleLen, needleLen,[m
[32m+[m[32m      needleLen, needleLen, needleLen, needleLen, needleLen, needleLen,[m
[32m+[m[32m      needleLen, needleLen, needleLen, needleLen, needleLen, needleLen,[m
[32m+[m[32m      needleLen, needleLen, needleLen, needleLen, needleLen, needleLen,[m
[32m+[m[32m      needleLen, needleLen, needleLen, needleLen, needleLen, needleLen,[m
[32m+[m[32m      needleLen, needleLen, needleLen, needleLen, needleLen, needleLen,[m
[32m+[m[32m      needleLen, needleLen, needleLen, needleLen, needleLen, needleLen,[m
[32m+[m[32m      needleLen, needleLen, needleLen, needleLen[m
[32m+[m[32m    ];[m
[32m+[m
[32m+[m[32m    // Populate occurrence table with analysis of the needle, ignoring the last[m
[32m+[m[32m    // letter.[m
[32m+[m[32m    if (needleLen > 1) {[m
[32m+[m[32m      for (let i = 0; i < needleLen - 1; ++i)[m
[32m+[m[32m        this._occ[needle[i]] = needleLen - 1 - i;[m
[32m+[m[32m    }[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  reset() {[m
[32m+[m[32m    this.matches = 0;[m
[32m+[m[32m    this._lookbehindSize = 0;[m
[32m+[m[32m    this._bufPos = 0;[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  push(chunk, pos) {[m
[32m+[m[32m    let result;[m
[32m+[m[32m    if (!Buffer.isBuffer(chunk))[m
[32m+[m[32m      chunk = Buffer.from(chunk, 'latin1');[m
[32m+[m[32m    const chunkLen = chunk.length;[m
[32m+[m[32m    this._bufPos = pos || 0;[m
[32m+[m[32m    while (result !== chunkLen && this.matches < this.maxMatches)[m
[32m+[m[32m      result = feed(this, chunk);[m
[32m+[m[32m    return result;[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  destroy() {[m
[32m+[m[32m    const lbSize = this._lookbehindSize;[m
[32m+[m[32m    if (lbSize)[m
[32m+[m[32m      this._cb(false, this._lookbehind, 0, lbSize, false);[m
[32m+[m[32m    this.reset();[m
[32m+[m[32m  }[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction feed(self, data) {[m
[32m+[m[32m  const len = data.length;[m
[32m+[m[32m  const needle = self._needle;[m
[32m+[m[32m  const needleLen = needle.length;[m
[32m+[m
[32m+[m[32m  // Positive: points to a position in `data`[m
[32m+[m[32m  //           pos == 3 points to data[3][m
[32m+[m[32m  // Negative: points to a position in the lookbehind buffer[m
[32m+[m[32m  //           pos == -2 points to lookbehind[lookbehindSize - 2][m
[32m+[m[32m  let pos = -self._lookbehindSize;[m
[32m+[m[32m  const lastNeedleCharPos = needleLen - 1;[m
[32m+[m[32m  const lastNeedleChar = needle[lastNeedleCharPos];[m
[32m+[m[32m  const end = len - needleLen;[m
[32m+[m[32m  const occ = self._occ;[m
[32m+[m[32m  const lookbehind = self._lookbehind;[m
[32m+[m
[32m+[m[32m  if (pos < 0) {[m
[32m+[m[32m    // Lookbehind buffer is not empty. Perform Boyer-Moore-Horspool[m
[32m+[m[32m    // search with character lookup code that considers both the[m
[32m+[m[32m    // lookbehind buffer and the current round's haystack data.[m
[32m+[m[32m    //[m
[32m+[m[32m    // Loop until[m
[32m+[m[32m    //   there is a match.[m
[32m+[m[32m    // or until[m
[32m+[m[32m    //   we've moved past the position that requires the[m
[32m+[m[32m    //   lookbehind buffer. In this case we switch to the[m
[32m+[m[32m    //   optimized loop.[m
[32m+[m[32m    // or until[m
[32m+[m[32m    //   the character to look at lies outside the haystack.[m
[32m+[m[32m    while (pos < 0 && pos <= end) {[m
[32m+[m[32m      const nextPos = pos + lastNeedleCharPos;[m
[32m+[m[32m      const ch = (nextPos < 0[m
[32m+[m[32m                  ? lookbehind[self._lookbehindSize + nextPos][m
[32m+[m[32m                  : data[nextPos]);[m
[32m+[m
[32m+[m[32m      if (ch === lastNeedleChar[m
[32m+[m[32m          && matchNeedle(self, data, pos, lastNeedleCharPos)) {[m
[32m+[m[32m        self._lookbehindSize = 0;[m
[32m+[m[32m        ++self.matches;[m
[32m+[m[32m        if (pos > -self._lookbehindSize)[m
[32m+[m[32m          self._cb(true, lookbehind, 0, self._lookbehindSize + pos, false);[m
[32m+[m[32m        else[m
[32m+[m[32m          self._cb(true, undefined, 0, 0, true);[m
[32m+[m
[32m+[m[32m        return (self._bufPos = pos + needleLen);[m
[32m+[m[32m      }[m
[32m+[m
[32m+[m[32m      pos += occ[ch];[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    // No match.[m
[32m+[m
[32m+[m[32m    // There's too few data for Boyer-Moore-Horspool to run,[m
[32m+[m[32m    // so let's use a different algorithm to skip as much as[m
[32m+[m[32m    // we can.[m
[32m+[m[32m    // Forward pos until[m
[32m+[m[32m    //   the trailing part of lookbehind + data[m
[32m+[m[32m    //   looks like the beginning of the needle[m
[32m+[m[32m    // or until[m
[32m+[m[32m    //   pos == 0[m
[32m+[m[32m    while (pos < 0 && !matchNeedle(self, data, pos, len - pos))[m
[32m+[m[32m      ++pos;[m
[32m+[m
[32m+[m[32m    if (pos < 0) {[m
[32m+[m[32m      // Cut off part of the lookbehind buffer that has[m
[32m+[m[32m      // been processed and append the entire haystack[m
[32m+[m[32m      // into it.[m
[32m+[m[32m      const bytesToCutOff = self._lookbehindSize + pos;[m
[32m+[m
[32m+[m[32m      if (bytesToCutOff > 0) {[m
[32m+[m[32m        // The cut off data is guaranteed not to contain the needle.[m
[32m+[m[32m        self._cb(false, lookbehind, 0, bytesToCutOff, false);[m
[32m+[m[32m      }[m
[32m+[m
[32m+[m[32m      self._lookbehindSize -= bytesToCutOff;[m
[32m+[m[32m      lookbehind.copy(lookbehind, 0, bytesToCutOff, self._lookbehindSize);[m
[32m+[m[32m      lookbehind.set(data, self._lookbehindSize);[m
[32m+[m[32m      self._lookbehindSize += len;[m
[32m+[m
[32m+[m[32m      self._bufPos = len;[m
[32m+[m[32m      return len;[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    // Discard lookbehind buffer.[m
[32m+[m[32m    self._cb(false, lookbehind, 0, self._lookbehindSize, false);[m
[32m+[m[32m    self._lookbehindSize = 0;[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  pos += self._bufPos;[m
[32m+[m
[32m+[m[32m  const firstNeedleChar = needle[0];[m
[32m+[m
[32m+[m[32m  // Lookbehind buffer is now empty. Perform Boyer-Moore-Horspool[m
[32m+[m[32m  // search with optimized character lookup code that only considers[m
[32m+[m[32m  // the current round's haystack data.[m
[32m+[m[32m  while (pos <= end) {[m
[32m+[m[32m    const ch = data[pos + lastNeedleCharPos];[m
[32m+[m
[32m+[m[32m    if (ch === lastNeedleChar[m
[32m+[m[32m        && data[pos] === firstNeedleChar[m
[32m+[m[32m        && memcmp(needle, 0, data, pos, lastNeedleCharPos)) {[m
[32m+[m[32m      ++self.matches;[m
[32m+[m[32m      if (pos > 0)[m
[32m+[m[32m        self._cb(true, data, self._bufPos, pos, true);[m
[32m+[m[32m      else[m
[32m+[m[32m        self._cb(true, undefined, 0, 0, true);[m
[32m+[m
[32m+[m[32m      return (self._bufPos = pos + needleLen);[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    pos += occ[ch];[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  // There was no match. If there's trailing haystack data that we cannot[m
[32m+[m[32m  // match yet using the Boyer-Moore-Horspool algorithm (because the trailing[m
[32m+[m[32m  // data is less than the needle size) then match using a modified[m
[32m+[m[32m  // algorithm that starts matching from the beginning instead of the end.[m
[32m+[m[32m  // Whatever trailing data is left after running this algorithm is added to[m
[32m+[m[32m  // the lookbehind buffer.[m
[32m+[m[32m  while (pos < len) {[m
[32m+[m[32m    if (data[pos] !== firstNeedleChar[m
[32m+[m[32m        || !memcmp(data, pos, needle, 0, len - pos)) {[m
[32m+[m[32m      ++pos;[m
[32m+[m[32m      continue;[m
[32m+[m[32m    }[m
[32m+[m[32m    data.copy(lookbehind, 0, pos, len);[m
[32m+[m[32m    self._lookbehindSize = len - pos;[m
[32m+[m[32m    break;[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  // Everything until `pos` is guaranteed not to contain needle data.[m
[32m+[m[32m  if (pos > 0)[m
[32m+[m[32m    self._cb(false, data, self._bufPos, pos < len ? pos : len, true);[m
[32m+[m
[32m+[m[32m  self._bufPos = len;[m
[32m+[m[32m  return len;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction matchNeedle(self, data, pos, len) {[m
[32m+[m[32m  const lb = self._lookbehind;[m
[32m+[m[32m  const lbSize = self._lookbehindSize;[m
[32m+[m[32m  const needle = self._needle;[m
[32m+[m
[32m+[m[32m  for (let i = 0; i < len; ++i, ++pos) {[m
[32m+[m[32m    const ch = (pos < 0 ? lb[lbSize + pos] : data[pos]);[m
[32m+[m[32m    if (ch !== needle[i])[m
[32m+[m[32m      return false;[m
[32m+[m[32m  }[m
[32m+[m[32m  return true;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mmodule.exports = SBMH;[m
[1mdiff --git a/node_modules/streamsearch/package.json b/node_modules/streamsearch/package.json[m
[1mnew file mode 100644[m
[1mindex 0000000..51df8f9[m
[1m--- /dev/null[m
[1m+++ b/node_modules/streamsearch/package.json[m
[36m@@ -0,0 +1,34 @@[m
[32m+[m[32m{[m
[32m+[m[32m  "name": "streamsearch",[m
[32m+[m[32m  "version": "1.1.0",[m
[32m+[m[32m  "author": "Brian White <mscdex@mscdex.net>",[m
[32m+[m[32m  "description": "Streaming Boyer-Moore-Horspool searching for node.js",[m
[32m+[m[32m  "main": "./lib/sbmh.js",[m
[32m+[m[32m  "engines": {[m
[32m+[m[32m    "node": ">=10.0.0"[m
[32m+[m[32m  },[m
[32m+[m[32m  "devDependencies": {[m
[32m+[m[32m    "@mscdex/eslint-config": "^1.1.0",[m
[32m+[m[32m    "eslint": "^7.32.0"[m
[32m+[m[32m  },[m
[32m+[m[32m  "scripts": {[m
[32m+[m[32m    "test": "node test/test.js",[m
[32m+[m[32m    "lint": "eslint --cache --report-unused-disable-directives --ext=.js .eslintrc.js lib test",[m
[32m+[m[32m    "lint:fix": "npm run lint -- --fix"[m
[32m+[m[32m  },[m
[32m+[m[32m  "keywords": [[m
[32m+[m[32m    "stream",[m
[32m+[m[32m    "horspool",[m
[32m+[m[32m    "boyer-moore-horspool",[m
[32m+[m[32m    "boyer-moore",[m
[32m+[m[32m    "search"[m
[32m+[m[32m  ],[m
[32m+[m[32m  "licenses": [{[m
[32m+[m[32m    "type": "MIT",[m
[32m+[m[32m    "url": "http://github.com/mscdex/streamsearch/raw/master/LICENSE"[m
[32m+[m[32m  }],[m
[32m+[m[32m  "repository": {[m
[32m+[m[32m    "type": "git",[m
[32m+[m[32m    "url": "http://github.com/mscdex/streamsearch.git"[m
[32m+[m[32m  }[m
[32m+[m[32m}[m
[1mdiff --git a/node_modules/streamsearch/test/test.js b/node_modules/streamsearch/test/test.js[m
[1mnew file mode 100644[m
[1mindex 0000000..39a04d7[m
[1m--- /dev/null[m
[1m+++ b/node_modules/streamsearch/test/test.js[m
[36m@@ -0,0 +1,70 @@[m
[32m+[m[32m'use strict';[m
[32m+[m
[32m+[m[32mconst assert = require('assert');[m
[32m+[m
[32m+[m[32mconst StreamSearch = require('../lib/sbmh.js');[m
[32m+[m
[32m+[m[32m[[m
[32m+[m[32m  {[m
[32m+[m[32m    needle: '\r\n',[m
[32m+[m[32m    chunks: [[m
[32m+[m[32m      'foo',[m
[32m+[m[32m      ' bar',[m
[32m+[m[32m      '\r',[m
[32m+[m[32m      '\n',[m
[32m+[m[32m      'baz, hello\r',[m
[32m+[m[32m      '\n world.',[m
[32m+[m[32m      '\r\n Node.JS rules!!\r\n\r\n',[m
[32m+[m[32m    ],[m
[32m+[m[32m    expect: [[m
[32m+[m[32m      [false, 'foo'],[m
[32m+[m[32m      [false, ' bar'],[m
[32m+[m[32m      [ true, null],[m
[32m+[m[32m      [false, 'baz, hello'],[m
[32m+[m[32m      [ true, null],[m
[32m+[m[32m      [false, ' world.'],[m
[32m+[m[32m      [ true, null],[m
[32m+[m[32m      [ true, ' Node.JS rules!!'],[m
[32m+[m[32m      [ true, ''],[m
[32m+[m[32m    ],[m
[32m+[m[32m  },[m
[32m+[m[32m  {[m
[32m+[m[32m    needle: '---foobarbaz',[m
[32m+[m[32m    chunks: [[m
[32m+[m[32m      '---foobarbaz',[m
[32m+[m[32m      'asdf',[m
[32m+[m[32m      '\r\n',[m
[32m+[m[32m      '---foobarba',[m
[32m+[m[32m      '---foobar',[m
[32m+[m[32m      'ba',[m
[32m+[m[32m      '\r\n---foobarbaz--\r\n',[m
[32m+[m[32m    ],[m
[32m+[m[32m    expect: [[m
[32m+[m[32m      [ true, null],[m
[32m+[m[32m      [false, 'asdf'],[m
[32m+[m[32m      [false, '\r\n'],[m
[32m+[m[32m      [false, '---foobarba'],[m
[32m+[m[32m      [false, '---foobarba'],[m
[32m+[m[32m      [ true, '\r\n'],[m
[32m+[m[32m      [false, '--\r\n'],[m
[32m+[m[32m    ],[m
[32m+[m[32m  },[m
[32m+[m[32m].forEach((test, i) => {[m
[32m+[m[32m  console.log(`Running test #${i + 1}`);[m
[32m+[m[32m  const { needle, chunks, expect } = test;[m
[32m+[m
[32m+[m[32m  const results = [];[m
[32m+[m[32m  const ss = new StreamSearch(Buffer.from(needle),[m
[32m+[m[32m                              (isMatch, data, start, end) => {[m
[32m+[m[32m    if (data)[m
[32m+[m[32m      data = data.toString('latin1', start, end);[m
[32m+[m[32m    else[m
[32m+[m[32m      data = null;[m
[32m+[m[32m    results.push([isMatch, data]);[m
[32m+[m[32m  });[m
[32m+[m
[32m+[m[32m  for (const chunk of chunks)[m
[32m+[m[32m    ss.push(Buffer.from(chunk));[m
[32m+[m
[32m+[m[32m  assert.deepStrictEqual(results, expect);[m
[32m+[m[32m});[m
[1mdiff --git a/node_modules/string_decoder/.travis.yml b/node_modules/string_decoder/.travis.yml[m
[1mnew file mode 100644[m
[1mindex 0000000..3347a72[m
[1m--- /dev/null[m
[1m+++ b/node_modules/string_decoder/.travis.yml[m
[36m@@ -0,0 +1,50 @@[m
[32m+[m[32msudo: false[m
[32m+[m[32mlanguage: node_js[m
[32m+[m[32mbefore_install:[m
[32m+[m[32m  - npm install -g npm@2[m
[32m+[m[32m  - test $NPM_LEGACY && npm install -g npm@latest-3 || npm install npm -g[m
[32m+[m[32mnotifications:[m
[32m+[m[32m  email: false[m
[32m+[m[32mmatrix:[m
[32m+[m[32m  fast_finish: true[m
[32m+[m[32m  include:[m
[32m+[m[32m  - node_js: '0.8'[m
[32m+[m[32m    env:[m
[32m+[m[32m      - TASK=test[m
[32m+[m[32m      - NPM_LEGACY=true[m
[32m+[m[32m  - node_js: '0.10'[m
[32m+[m[32m    env:[m
[32m+[m[32m      - TASK=test[m
[32m+[m[32m      - NPM_LEGACY=true[m
[32m+[m[32m  - node_js: '0.11'[m
[32m+[m[32m    env:[m
[32m+[m[32m      - TASK=test[m
[32m+[m[32m      - NPM_LEGACY=true[m
[32m+[m[32m  - node_js: '0.12'[m
[32m+[m[32m    env:[m
[32m+[m[32m      - TASK=test[m
[32m+[m[32m      - NPM_LEGACY=true[m
[32m+[m[32m  - node_js: 1[m
[32m+[m[32m    env:[m
[32m+[m[32m      - TASK=test[m
[32m+[m[32m      - NPM_LEGACY=true[m
[32m+[m[32m  - node_js: 2[m
[32m+[m[32m    env:[m
[32m+[m[32m      - TASK=test[m
[32m+[m[32m      - NPM_LEGACY=true[m
[32m+[m[32m  - node_js: 3[m
[32m+[m[32m    env:[m
[32m+[m[32m      - TASK=test[m
[32m+[m[32m      - NPM_LEGACY=true[m
[32m+[m[32m  - node_js: 4[m
[32m+[m[32m    env: TASK=test[m
[32m+[m[32m  - node_js: 5[m
[32m+[m[32m    env: TASK=test[m
[32m+[m[32m  - node_js: 6[m
[32m+[m[32m    env: TASK=test[m
[32m+[m[32m  - node_js: 7[m
[32m+[m[32m    env: TASK=test[m
[32m+[m[32m  - node_js: 8[m
[32m+[m[32m    env: TASK=test[m
[32m+[m[32m  - node_js: 9[m
[32m+[m[32m    env: TASK=test[m
[1mdiff --git a/node_modules/string_decoder/LICENSE b/node_modules/string_decoder/LICENSE[m
[1mnew file mode 100644[m
[1mindex 0000000..778edb2[m
[1m--- /dev/null[m
[1m+++ b/node_modules/string_decoder/LICENSE[m
[36m@@ -0,0 +1,48 @@[m
[32m+[m[32mNode.js is licensed for use as follows:[m
[32m+[m
[32m+[m[32m"""[m
[32m+[m[32mCopyright Node.js contributors. All rights reserved.[m
[32m+[m
[32m+[m[32mPermission is hereby granted, free of charge, to any person obtaining a copy[m
[32m+[m[32mof this software and associated documentation files (the "Software"), to[m
[32m+[m[32mdeal in the Software without restriction, including without limitation the[m
[32m+[m[32mrights to use, copy, modify, merge, publish, distribute, sublicense, and/or[m
[32m+[m[32msell copies of the Software, and to permit persons to whom the Software is[m
[32m+[m[32mfurnished to do so, subject to the following conditions:[m
[32m+[m
[32m+[m[32mThe above copyright notice and this permission notice shall be included in[m
[32m+[m[32mall copies or substantial portions of the Software.[m
[32m+[m
[32m+[m[32mTHE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR[m
[32m+[m[32mIMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,[m
[32m+[m[32mFITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE[m
[32m+[m[32mAUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER[m
[32m+[m[32mLIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING[m
[32m+[m[32mFROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS[m
[32m+[m[32mIN THE SOFTWARE.[m
[32m+[m[32m"""[m
[32m+[m
[32m+[m[32mThis license applies to parts of Node.js originating from the[m
[32m+[m[32mhttps://github.com/joyent/node repository:[m
[32m+[m
[32m+[m[32m"""[m
[32m+[m[32mCopyright Joyent, Inc. and other Node contributors. All rights reserved.[m
[32m+[m[32mPermission is hereby granted, free of charge, to any person obtaining a copy[m
[32m+[m[32mof this software and associated documentation files (the "Software"), to[m
[32m+[m[32mdeal in the Software without restriction, including without limitation the[m
[32m+[m[32mrights to use, copy, modify, merge, publish, distribute, sublicense, and/or[m
[32m+[m[32msell copies of the Software, and to permit persons to whom the Software is[m
[32m+[m[32mfurnished to do so, subject to the following conditions:[m
[32m+[m
[32m+[m[32mThe above copyright notice and this permission notice shall be included in[m
[32m+[m[32mall copies or substantial portions of the Software.[m
[32m+[m
[32m+[m[32mTHE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR[m
[32m+[m[32mIMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,[m
[32m+[m[32mFITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE[m
[32m+[m[32mAUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER[m
[32m+[m[32mLIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING[m
[32m+[m[32mFROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS[m
[32m+[m[32mIN THE SOFTWARE.[m
[32m+[m[32m"""[m
[32m+[m
[1mdiff --git a/node_modules/string_decoder/README.md b/node_modules/string_decoder/README.md[m
[1mnew file mode 100644[m
[1mindex 0000000..5fd5831[m
[1m--- /dev/null[m
[1m+++ b/node_modules/string_decoder/README.md[m
[36m@@ -0,0 +1,47 @@[m
[32m+[m[32m# string_decoder[m
[32m+[m
[32m+[m[32m***Node-core v8.9.4 string_decoder for userland***[m
[32m+[m
[32m+[m
[32m+[m[32m[![NPM](https://nodei.co/npm/string_decoder.png?downloads=true&downloadRank=true)](https://nodei.co/npm/string_decoder/)[m
[32m+[m[32m[![NPM](https://nodei.co/npm-dl/string_decoder.png?&months=6&height=3)](https://nodei.co/npm/string_decoder/)[m
[32m+[m
[32m+[m
[32m+[m[32m```bash[m
[32m+[m[32mnpm install --save string_decoder[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32m***Node-core string_decoder for userland***[m
[32m+[m
[32m+[m[32mThis package is a mirror of the string_decoder implementation in Node-core.[m
[32m+[m
[32m+[m[32mFull documentation may be found on the [Node.js website](https://nodejs.org/dist/v8.9.4/docs/api/).[m
[32m+[m
[32m+[m[32mAs of version 1.0.0 **string_decoder** uses semantic versioning.[m
[32m+[m
[32m+[m[32m## Previous versions[m
[32m+[m
[32m+[m[32mPrevious version numbers match the versions found in Node core, e.g. 0.10.24 matches Node 0.10.24, likewise 0.11.10 matches Node 0.11.10.[m
[32m+[m
[32m+[m[32m## Update[m
[32m+[m
[32m+[m[32mThe *build/* directory contains a build script that will scrape the source from the [nodejs/node](https://github.com/nodejs/node) repo given a specific Node version.[m
[32m+[m
[32m+[m[32m## Streams Working Group[m
[32m+[m
[32m+[m[32m`string_decoder` is maintained by the Streams Working Group, which[m
[32m+[m[32moversees the development and maintenance of the Streams API within[m
[32m+[m[32mNode.js. The responsibilities of the Streams Working Group include:[m
[32m+[m
[32m+[m[32m* Addressing stream issues on the Node.js issue tracker.[m
[32m+[m[32m* Authoring and editing stream documentation within the Node.js project.[m
[32m+[m[32m* Reviewing changes to stream subclasses within the Node.js project.[m
[32m+[m[32m* Redirecting changes to streams from the Node.js project to this[m
[32m+[m[32m  project.[m
[32m+[m[32m* Assisting in the implementation of stream providers within Node.js.[m
[32m+[m[32m* Recommending versions of `readable-stream` to be included in Node.js.[m
[32m+[m[32m* Messaging about the future of streams to give the community advance[m
[32m+[m[32m  notice of changes.[m
[32m+[m
[32m+[m[32mSee [readable-stream](https://github.com/nodejs/readable-stream) for[m
[32m+[m[32mmore details.[m
[1mdiff --git a/node_modules/string_decoder/lib/string_decoder.js b/node_modules/string_decoder/lib/string_decoder.js[m
[1mnew file mode 100644[m
[1mindex 0000000..2e89e63[m
[1m--- /dev/null[m
[1m+++ b/node_modules/string_decoder/lib/string_decoder.js[m
[36m@@ -0,0 +1,296 @@[m
[32m+[m[32m// Copyright Joyent, Inc. and other Node contributors.[m
[32m+[m[32m//[m
[32m+[m[32m// Permission is hereby granted, free of charge, to any person obtaining a[m
[32m+[m[32m// copy of this software and associated documentation files (the[m
[32m+[m[32m// "Software"), to deal in the Software without restriction, including[m
[32m+[m[32m// without limitation the rights to use, copy, modify, merge, publish,[m
[32m+[m[32m// distribute, sublicense, and/or sell copies of the Software, and to permit[m
[32m+[m[32m// persons to whom the Software is furnished to do so, subject to the[m
[32m+[m[32m// following conditions:[m
[32m+[m[32m//[m
[32m+[m[32m// The above copyright notice and this permission notice shall be included[m
[32m+[m[32m// in all copies or substantial portions of the Software.[m
[32m+[m[32m//[m
[32m+[m[32m// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS[m
[32m+[m[32m// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF[m
[32m+[m[32m// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN[m
[32m+[m[32m// NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,[m
[32m+[m[32m// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR[m
[32m+[m[32m// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE[m
[32m+[m[32m// USE OR OTHER DEALINGS IN THE SOFTWARE.[m
[32m+[m
[32m+[m[32m'use strict';[m
[32m+[m
[32m+[m[32m/*<replacement>*/[m
[32m+[m
[32m+[m[32mvar Buffer = require('safe-buffer').Buffer;[m
[32m+[m[32m/*</replacement>*/[m
[32m+[m
[32m+[m[32mvar isEncoding = Buffer.isEncoding || function (encoding) {[m
[32m+[m[32m  encoding = '' + encoding;[m
[32m+[m[32m  switch (encoding && encoding.toLowerCase()) {[m
[32m+[m[32m    case 'hex':case 'utf8':case 'utf-8':case 'ascii':case 'binary':case 'base64':case 'ucs2':case 'ucs-2':case 'utf16le':case 'utf-16le':case 'raw':[m
[32m+[m[32m      return true;[m
[32m+[m[32m    default:[m
[32m+[m[32m      return false;[m
[32m+[m[32m  }[m
[32m+[m[32m};[m
[32m+[m
[32m+[m[32mfunction _normalizeEncoding(enc) {[m
[32m+[m[32m  if (!enc) return 'utf8';[m
[32m+[m[32m  var retried;[m
[32m+[m[32m  while (true) {[m
[32m+[m[32m    switch (enc) {[m
[32m+[m[32m      case 'utf8':[m
[32m+[m[32m      case 'utf-8':[m
[32m+[m[32m        return 'utf8';[m
[32m+[m[32m      case 'ucs2':[m
[32m+[m[32m      case 'ucs-2':[m
[32m+[m[32m      case 'utf16le':[m
[32m+[m[32m      case 'utf-16le':[m
[32m+[m[32m        return 'utf16le';[m
[32m+[m[32m      case 'latin1':[m
[32m+[m[32m      case 'binary':[m
[32m+[m[32m        return 'latin1';[m
[32m+[m[32m      case 'base64':[m
[32m+[m[32m      case 'ascii':[m
[32m+[m[32m      case 'hex':[m
[32m+[m[32m        return enc;[m
[32m+[m[32m      default:[m
[32m+[m[32m        if (retried) return; // undefined[m
[32m+[m[32m        enc = ('' + enc).toLowerCase();[m
[32m+[m[32m        retried = true;[m
[32m+[m[32m    }[m
[32m+[m[32m  }[m
[32m+[m[32m};[m
[32m+[m
[32m+[m[32m// Do not cache `Buffer.isEncoding` when checking encoding names as some[m
[32m+[m[32m// modules monkey-patch it to support additional encodings[m
[32m+[m[32mfunction normalizeEncoding(enc) {[m
[32m+[m[32m  var nenc = _normalizeEncoding(enc);[m
[32m+[m[32m  if (typeof nenc !== 'string' && (Buffer.isEncoding === isEncoding || !isEncoding(enc))) throw new Error('Unknown encoding: ' + enc);[m
[32m+[m[32m  return nenc || enc;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m// StringDecoder provides an interface for efficiently splitting a series of[m
[32m+[m[32m// buffers into a series of JS strings without breaking apart multi-byte[m
[32m+[m[32m// characters.[m
[32m+[m[32mexports.StringDecoder = StringDecoder;[m
[32m+[m[32mfunction StringDecoder(encoding) {[m
[32m+[m[32m  this.encoding = normalizeEncoding(encoding);[m
[32m+[m[32m  var nb;[m
[32m+[m[32m  switch (this.encoding) {[m
[32m+[m[32m    case 'utf16le':[m
[32m+[m[32m      this.text = utf16Text;[m
[32m+[m[32m      this.end = utf16End;[m
[32m+[m[32m      nb = 4;[m
[32m+[m[32m      break;[m
[32m+[m[32m    case 'utf8':[m
[32m+[m[32m      this.fillLast = utf8FillLast;[m
[32m+[m[32m      nb = 4;[m
[32m+[m[32m      break;[m
[32m+[m[32m    case 'base64':[m
[32m+[m[32m      this.text = base64Text;[m
[32m+[m[32m      this.end = base64End;[m
[32m+[m[32m      nb = 3;[m
[32m+[m[32m      break;[m
[32m+[m[32m    default:[m
[32m+[m[32m      this.write = simpleWrite;[m
[32m+[m[32m      this.end = simpleEnd;[m
[32m+[m[32m      return;[m
[32m+[m[32m  }[m
[32m+[m[32m  this.lastNeed = 0;[m
[32m+[m[32m  this.lastTotal = 0;[m
[32m+[m[32m  this.lastChar = Buffer.allocUnsafe(nb);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mStringDecoder.prototype.write = function (buf) {[m
[32m+[m[32m  if (buf.length === 0) return '';[m
[32m+[m[32m  var r;[m
[32m+[m[32m  var i;[m
[32m+[m[32m  if (this.lastNeed) {[m
[32m+[m[32m    r = this.fillLast(buf);[m
[32m+[m[32m    if (r === undefined) return '';[m
[32m+[m[32m    i = this.lastNeed;[m
[32m+[m[32m    this.lastNeed = 0;[m
[32m+[m[32m  } else {[m
[32m+[m[32m    i = 0;[m
[32m+[m[32m  }[m
[32m+[m[32m  if (i < buf.length) return r ? r + this.text(buf, i) : this.text(buf, i);[m
[32m+[m[32m  return r || '';[m
[32m+[m[32m};[m
[32m+[m
[32m+[m[32mStringDecoder.prototype.end = utf8End;[m
[32m+[m
[32m+[m[32m// Returns only complete characters in a Buffer[m
[32m+[m[32mStringDecoder.prototype.text = utf8Text;[m
[32m+[m
[32m+[m[32m// Attempts to complete a partial non-UTF-8 character using bytes from a Buffer[m
[32m+[m[32mStringDecoder.prototype.fillLast = function (buf) {[m
[32m+[m[32m  if (this.lastNeed <= buf.length) {[m
[32m+[m[32m    buf.copy(this.lastChar, this.lastTotal - this.lastNeed, 0, this.lastNeed);[m
[32m+[m[32m    return this.lastChar.toString(this.encoding, 0, this.lastTotal);[m
[32m+[m[32m  }[m
[32m+[m[32m  buf.copy(this.lastChar, this.lastTotal - this.lastNeed, 0, buf.length);[m
[32m+[m[32m  this.lastNeed -= buf.length;[m
[32m+[m[32m};[m
[32m+[m
[32m+[m[32m// Checks the type of a UTF-8 byte, whether it's ASCII, a leading byte, or a[m
[32m+[m[32m// continuation byte. If an invalid byte is detected, -2 is returned.[m
[32m+[m[32mfunction utf8CheckByte(byte) {[m
[32m+[m[32m  if (byte <= 0x7F) return 0;else if (byte >> 5 === 0x06) return 2;else if (byte >> 4 === 0x0E) return 3;else if (byte >> 3 === 0x1E) return 4;[m
[32m+[m[32m  return byte >> 6 === 0x02 ? -1 : -2;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m// Checks at most 3 bytes at the end of a Buffer in order to detect an[m
[32m+[m[32m// incomplete multi-byte UTF-8 character. The total number of bytes (2, 3, or 4)[m
[32m+[m[32m// needed to complete the UTF-8 character (if applicable) are returned.[m
[32m+[m[32mfunction utf8CheckIncomplete(self, buf, i) {[m
[32m+[m[32m  var j = buf.length - 1;[m
[32m+[m[32m  if (j < i) return 0;[m
[32m+[m[32m  var nb = utf8CheckByte(buf[j]);[m
[32m+[m[32m  if (nb >= 0) {[m
[32m+[m[32m    if (nb > 0) self.lastNeed = nb - 1;[m
[32m+[m[32m    return nb;[m
[32m+[m[32m  }[m
[32m+[m[32m  if (--j < i || nb === -2) return 0;[m
[32m+[m[32m  nb = utf8CheckByte(buf[j]);[m
[32m+[m[32m  if (nb >= 0) {[m
[32m+[m[32m    if (nb > 0) self.lastNeed = nb - 2;[m
[32m+[m[32m    return nb;[m
[32m+[m[32m  }[m
[32m+[m[32m  if (--j < i || nb === -2) return 0;[m
[32m+[m[32m  nb = utf8CheckByte(buf[j]);[m
[32m+[m[32m  if (nb >= 0) {[m
[32m+[m[32m    if (nb > 0) {[m
[32m+[m[32m      if (nb === 2) nb = 0;else self.lastNeed = nb - 3;[m
[32m+[m[32m    }[m
[32m+[m[32m    return nb;[m
[32m+[m[32m  }[m
[32m+[m[32m  return 0;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m// Validates as many continuation bytes for a multi-byte UTF-8 character as[m
[32m+[m[32m// needed or are available. If we see a non-continuation byte where we expect[m
[32m+[m[32m// one, we "replace" the validated continuation bytes we've seen so far with[m
[32m+[m[32m// a single UTF-8 replacement character ('\ufffd'), to match v8's UTF-8 decoding[m
[32m+[m[32m// behavior. The continuation byte check is included three times in the case[m
[32m+[m[32m// where all of the continuation bytes for a character exist in the same buffer.[m
[32m+[m[32m// It is also done this way as a slight performance increase instead of using a[m
[32m+[m[32m// loop.[m
[32m+[m[32mfunction utf8CheckExtraBytes(self, buf, p) {[m
[32m+[m[32m  if ((buf[0] & 0xC0) !== 0x80) {[m
[32m+[m[32m    self.lastNeed = 0;[m
[32m+[m[32m    return '\ufffd';[m
[32m+[m[32m  }[m
[32m+[m[32m  if (self.lastNeed > 1 && buf.length > 1) {[m
[32m+[m[32m    if ((buf[1] & 0xC0) !== 0x80) {[m
[32m+[m[32m      self.lastNeed = 1;[m
[32m+[m[32m      return '\ufffd';[m
[32m+[m[32m    }[m
[32m+[m[32m    if (self.lastNeed > 2 && buf.length > 2) {[m
[32m+[m[32m      if ((buf[2] & 0xC0) !== 0x80) {[m
[32m+[m[32m        self.lastNeed = 2;[m
[32m+[m[32m        return '\ufffd';[m
[32m+[m[32m      }[m
[32m+[m[32m    }[m
[32m+[m[32m  }[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m// Attempts to complete a multi-byte UTF-8 character using bytes from a Buffer.[m
[32m+[m[32mfunction utf8FillLast(buf) {[m
[32m+[m[32m  var p = this.lastTotal - this.lastNeed;[m
[32m+[m[32m  var r = utf8CheckExtraBytes(this, buf, p);[m
[32m+[m[32m  if (r !== undefined) return r;[m
[32m+[m[32m  if (this.lastNeed <= buf.length) {[m
[32m+[m[32m    buf.copy(this.lastChar, p, 0, this.lastNeed);[m
[32m+[m[32m    return this.lastChar.toString(this.encoding, 0, this.lastTotal);[m
[32m+[m[32m  }[m
[32m+[m[32m  buf.copy(this.lastChar, p, 0, buf.length);[m
[32m+[m[32m  this.lastNeed -= buf.length;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m// Returns all complete UTF-8 characters in a Buffer. If the Buffer ended on a[m
[32m+[m[32m// partial character, the character's bytes are buffered until the required[m
[32m+[m[32m// number of bytes are available.[m
[32m+[m[32mfunction utf8Text(buf, i) {[m
[32m+[m[32m  var total = utf8CheckIncomplete(this, buf, i);[m
[32m+[m[32m  if (!this.lastNeed) return buf.toString('utf8', i);[m
[32m+[m[32m  this.lastTotal = total;[m
[32m+[m[32m  var end = buf.length - (total - this.lastNeed);[m
[32m+[m[32m  buf.copy(this.lastChar, 0, end);[m
[32m+[m[32m  return buf.toString('utf8', i, end);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m// For UTF-8, a replacement character is added when ending on a partial[m
[32m+[m[32m// character.[m
[32m+[m[32mfunction utf8End(buf) {[m
[32m+[m[32m  var r = buf && buf.length ? this.write(buf) : '';[m
[32m+[m[32m  if (this.lastNeed) return r + '\ufffd';[m
[32m+[m[32m  return r;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m// UTF-16LE typically needs two bytes per character, but even if we have an even[m
[32m+[m[32m// number of bytes available, we need to check if we end on a leading/high[m
[32m+[m[32m// surrogate. In that case, we need to wait for the next two bytes in order to[m
[32m+[m[32m// decode the last character properly.[m
[32m+[m[32mfunction utf16Text(buf, i) {[m
[32m+[m[32m  if ((buf.length - i) % 2 === 0) {[m
[32m+[m[32m    var r = buf.toString('utf16le', i);[m
[32m+[m[32m    if (r) {[m
[32m+[m[32m      var c = r.charCodeAt(r.length - 1);[m
[32m+[m[32m      if (c >= 0xD800 && c <= 0xDBFF) {[m
[32m+[m[32m        this.lastNeed = 2;[m
[32m+[m[32m        this.lastTotal = 4;[m
[32m+[m[32m        this.lastChar[0] = buf[buf.length - 2];[m
[32m+[m[32m        this.lastChar[1] = buf[buf.length - 1];[m
[32m+[m[32m        return r.slice(0, -1);[m
[32m+[m[32m      }[m
[32m+[m[32m    }[m
[32m+[m[32m    return r;[m
[32m+[m[32m  }[m
[32m+[m[32m  this.lastNeed = 1;[m
[32m+[m[32m  this.lastTotal = 2;[m
[32m+[m[32m  this.lastChar[0] = buf[buf.length - 1];[m
[32m+[m[32m  return buf.toString('utf16le', i, buf.length - 1);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m// For UTF-16LE we do not explicitly append special replacement characters if we[m
[32m+[m[32m// end on a partial character, we simply let v8 handle that.[m
[32m+[m[32mfunction utf16End(buf) {[m
[32m+[m[32m  var r = buf && buf.length ? this.write(buf) : '';[m
[32m+[m[32m  if (this.lastNeed) {[m
[32m+[m[32m    var end = this.lastTotal - this.lastNeed;[m
[32m+[m[32m    return r + this.lastChar.toString('utf16le', 0, end);[m
[32m+[m[32m  }[m
[32m+[m[32m  return r;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction base64Text(buf, i) {[m
[32m+[m[32m  var n = (buf.length - i) % 3;[m
[32m+[m[32m  if (n === 0) return buf.toString('base64', i);[m
[32m+[m[32m  this.lastNeed = 3 - n;[m
[32m+[m[32m  this.lastTotal = 3;[m
[32m+[m[32m  if (n === 1) {[m
[32m+[m[32m    this.lastChar[0] = buf[buf.length - 1];[m
[32m+[m[32m  } else {[m
[32m+[m[32m    this.lastChar[0] = buf[buf.length - 2];[m
[32m+[m[32m    this.lastChar[1] = buf[buf.length - 1];[m
[32m+[m[32m  }[m
[32m+[m[32m  return buf.toString('base64', i, buf.length - n);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction base64End(buf) {[m
[32m+[m[32m  var r = buf && buf.length ? this.write(buf) : '';[m
[32m+[m[32m  if (this.lastNeed) return r + this.lastChar.toString('base64', 0, 3 - this.lastNeed);[m
[32m+[m[32m  return r;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m// Pass bytes on through for single-byte encodings (e.g. ascii, latin1, hex)[m
[32m+[m[32mfunction simpleWrite(buf) {[m
[32m+[m[32m  return buf.toString(this.encoding);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction simpleEnd(buf) {[m
[32m+[m[32m  return buf && buf.length ? this.write(buf) : '';[m
[32m+[m[32m}[m
\ No newline at end of file[m
[1mdiff --git a/node_modules/string_decoder/node_modules/safe-buffer/LICENSE b/node_modules/string_decoder/node_modules/safe-buffer/LICENSE[m
[1mnew file mode 100644[m
[1mindex 0000000..0c068ce[m
[1m--- /dev/null[m
[1m+++ b/node_modules/string_decoder/node_modules/safe-buffer/LICENSE[m
[36m@@ -0,0 +1,21 @@[m
[32m+[m[32mThe MIT License (MIT)[m
[32m+[m
[32m+[m[32mCopyright (c) Feross Aboukhadijeh[m
[32m+[m
[32m+[m[32mPermission is hereby granted, free of charge, to any person obtaining a copy[m
[32m+[m[32mof this software and associated documentation files (the "Software"), to deal[m
[32m+[m[32min the Software without restriction, including without limitation the rights[m
[32m+[m[32mto use, copy, modify, merge, publish, distribute, sublicense, and/or sell[m
[32m+[m[32mcopies of the Software, and to permit persons to whom the Software is[m
[32m+[m[32mfurnished to do so, subject to the following conditions:[m
[32m+[m
[32m+[m[32mThe above copyright notice and this permission notice shall be included in[m
[32m+[m[32mall copies or substantial portions of the Software.[m
[32m+[m
[32m+[m[32mTHE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR[m
[32m+[m[32mIMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,[m
[32m+[m[32mFITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE[m
[32m+[m[32mAUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER[m
[32m+[m[32mLIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,[m
[32m+[m[32mOUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN[m
[32m+[m[32mTHE SOFTWARE.[m
[1mdiff --git a/node_modules/string_decoder/node_modules/safe-buffer/README.md b/node_modules/string_decoder/node_modules/safe-buffer/README.md[m
[1mnew file mode 100644[m
[1mindex 0000000..e9a81af[m
[1m--- /dev/null[m
[1m+++ b/node_modules/string_decoder/node_modules/safe-buffer/README.md[m
[36m@@ -0,0 +1,584 @@[m
[32m+[m[32m# safe-buffer [![travis][travis-image]][travis-url] [![npm][npm-image]][npm-url] [![downloads][downloads-image]][downloads-url] [![javascript style guide][standard-image]][standard-url][m
[32m+[m
[32m+[m[32m[travis-image]: https://img.shields.io/travis/feross/safe-buffer/master.svg[m
[32m+[m[32m[travis-url]: https://travis-ci.org/feross/safe-buffer[m
[32m+[m[32m[npm-image]: https://img.shields.io/npm/v/safe-buffer.svg[m
[32m+[m[32m[npm-url]: https://npmjs.org/package/safe-buffer[m
[32m+[m[32m[downloads-image]: https://img.shields.io/npm/dm/safe-buffer.svg[m
[32m+[m[32m[downloads-url]: https://npmjs.org/package/safe-buffer[m
[32m+[m[32m[standard-image]: https://img.shields.io/badge/code_style-standard-brightgreen.svg[m
[32m+[m[32m[standard-url]: https://standardjs.com[m
[32m+[m
[32m+[m[32m#### Safer Node.js Buffer API[m
[32m+[m
[32m+[m[32m**Use the new Node.js Buffer APIs (`Buffer.from`, `Buffer.alloc`,[m
[32m+[m[32m`Buffer.allocUnsafe`, `Buffer.allocUnsafeSlow`) in all versions of Node.js.**[m
[32m+[m
[32m+[m[32m**Uses the built-in implementation when available.**[m
[32m+[m
[32m+[m[32m## install[m
[32m+[m
[32m+[m[32m```[m
[32m+[m[32mnpm install safe-buffer[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32m## usage[m
[32m+[m
[32m+[m[32mThe goal of this package is to provide a safe replacement for the node.js `Buffer`.[m
[32m+[m
[32m+[m[32mIt's a drop-in replacement for `Buffer`. You can use it by adding one `require` line to[m
[32m+[m[32mthe top of your node.js modules:[m
[32m+[m
[32m+[m[32m```js[m
[32m+[m[32mvar Buffer = require('safe-buffer').Buffer[m
[32m+[m
[32m+[m[32m// Existing buffer code will continue to work without issues:[m
[32m+[m
[32m+[m[32mnew Buffer('hey', 'utf8')[m
[32m+[m[32mnew Buffer([1, 2, 3], 'utf8')[m
[32m+[m[32mnew Buffer(obj)[m
[32m+[m[32mnew Buffer(16) // create an uninitialized buffer (potentially unsafe)[m
[32m+[m
[32m+[m[32m// But you can use these new explicit APIs to make clear what you want:[m
[32m+[m
[32m+[m[32mBuffer.from('hey', 'utf8') // convert from many types to a Buffer[m
[32m+[m[32mBuffer.alloc(16) // create a zero-filled buffer (safe)[m
[32m+[m[32mBuffer.allocUnsafe(16) // create an uninitialized buffer (potentially unsafe)[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32m## api[m
[32m+[m
[32m+[m[32m### Class Method: Buffer.from(array)[m
[32m+[m[32m<!-- YAML[m
[32m+[m[32madded: v3.0.0[m
[32m+[m[32m-->[m
[32m+[m
[32m+[m[32m* `array` {Array}[m
[32m+[m
[32m+[m[32mAllocates a new `Buffer` using an `array` of octets.[m
[32m+[m
[32m+[m[32m```js[m
[32m+[m[32mconst buf = Buffer.from([0x62,0x75,0x66,0x66,0x65,0x72]);[m
[32m+[m[32m  // creates a new Buffer containing ASCII bytes[m
[32m+[m[32m  // ['b','u','f','f','e','r'][m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32mA `TypeError` will be thrown if `array` is not an `Array`.[m
[32m+[m
[32m+[m[32m### Class Method: Buffer.from(arrayBuffer[, byteOffset[, length]])[m
[32m+[m[32m<!-- YAML[m
[32m+[m[32madded: v5.10.0[m
[32m+[m[32m-->[m
[32m+[m
[32m+[m[32m* `arrayBuffer` {ArrayBuffer} The `.buffer` property of a `TypedArray` or[m
[32m+[m[32m  a `new ArrayBuffer()`[m
[32m+[m[32m* `byteOffset` {Number} Default: `0`[m
[32m+[m[32m* `length` {Number} Default: `arrayBuffer.length - byteOffset`[m
[32m+[m
[32m+[m[32mWhen passed a reference to the `.buffer` property of a `TypedArray` instance,[m
[32m+[m[32mthe newly created `Buffer` will share the same allocated memory as the[m
[32m+[m[32mTypedArray.[m
[32m+[m
[32m+[m[32m```js[m
[32m+[m[32mconst arr = new Uint16Array(2);[m
[32m+[m[32marr[0] = 5000;[m
[32m+[m[32marr[1] = 4000;[m
[32m+[m
[32m+[m[32mconst buf = Buffer.from(arr.buffer); // shares the memory with arr;[m
[32m+[m
[32m+[m[32mconsole.log(buf);[m
[32m+[m[32m  // Prints: <Buffer 88 13 a0 0f>[m
[32m+[m
[32m+[m[32m// changing the TypedArray changes the Buffer also[m
[32m+[m[32marr[1] = 6000;[m
[32m+[m
[32m+[m[32mconsole.log(buf);[m
[32m+[m[32m  // Prints: <Buffer 88 13 70 17>[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32mThe optional `byteOffset` and `length` arguments specify a memory range within[m
[32m+[m[32mthe `arrayBuffer` that will be shared by the `Buffer`.[m
[32m+[m
[32m+[m[32m```js[m
[32m+[m[32mconst ab = new ArrayBuffer(10);[m
[32m+[m[32mconst buf = Buffer.from(ab, 0, 2);[m
[32m+[m[32mconsole.log(buf.length);[m
[32m+[m[32m  // Prints: 2[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32mA `TypeError` will be thrown if `arrayBuffer` is not an `ArrayBuffer`.[m
[32m+[m
[32m+[m[32m### Class Method: Buffer.from(buffer)[m
[32m+[m[32m<!-- YAML[m
[32m+[m[32madded: v3.0.0[m
[32m+[m[32m-->[m
[32m+[m
[32m+[m[32m* `buffer` {Buffer}[m
[32m+[m
[32m+[m[32mCopies the passed `buffer` data onto a new `Buffer` instance.[m
[32m+[m
[32m+[m[32m```js[m
[32m+[m[32mconst buf1 = Buffer.from('buffer');[m
[32m+[m[32mconst buf2 = Buffer.from(buf1);[m
[32m+[m
[32m+[m[32mbuf1[0] = 0x61;[m
[32m+[m[32mconsole.log(buf1.toString());[m
[32m+[m[32m  // 'auffer'[m
[32m+[m[32mconsole.log(buf2.toString());[m
[32m+[m[32m  // 'buffer' (copy is not changed)[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32mA `TypeError` will be thrown if `buffer` is not a `Buffer`.[m
[32m+[m
[32m+[m[32m### Class Method: Buffer.from(str[, encoding])[m
[32m+[m[32m<!-- YAML[m
[32m+[m[32madded: v5.10.0[m
[32m+[m[32m-->[m
[32m+[m
[32m+[m[32m* `str` {String} String to encode.[m
[32m+[m[32m* `encoding` {String} Encoding to use, Default: `'utf8'`[m
[32m+[m
[32m+[m[32mCreates a new `Buffer` containing the given JavaScript string `str`. If[m
[32m+[m[32mprovided, the `encoding` parameter identifies the character encoding.[m
[32m+[m[32mIf not provided, `encoding` defaults to `'utf8'`.[m
[32m+[m
[32m+[m[32m```js[m
[32m+[m[32mconst buf1 = Buffer.from('this is a tést');[m
[32m+[m[32mconsole.log(buf1.toString());[m
[32m+[m[32m  // prints: this is a tést[m
[32m+[m[32mconsole.log(buf1.toString('ascii'));[m
[32m+[m[32m  // prints: this is a tC)st[m
[32m+[m
[32m+[m[32mconst buf2 = Buffer.from('7468697320697320612074c3a97374', 'hex');[m
[32m+[m[32mconsole.log(buf2.toString());[m
[32m+[m[32m  // prints: this is a tést[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32mA `TypeError` will be thrown if `str` is not a string.[m
[32m+[m
[32m+[m[32m### Class Method: Buffer.alloc(size[, fill[, encoding]])[m
[32m+[m[32m<!-- YAML[m
[32m+[m[32madded: v5.10.0[m
[32m+[m[32m-->[m
[32m+[m
[32m+[m[32m* `size` {Number}[m
[32m+[m[32m* `fill` {Value} Default: `undefined`[m
[32m+[m[32m* `encoding` {String} Default: `utf8`[m
[32m+[m
[32m+[m[32mAllocates a new `Buffer` of `size` bytes. If `fill` is `undefined`, the[m
[32m+[m[32m`Buffer` will be *zero-filled*.[m
[32m+[m
[32m+[m[32m```js[m
[32m+[m[32mconst buf = Buffer.alloc(5);[m
[32m+[m[32mconsole.log(buf);[m
[32m+[m[32m  // <Buffer 00 00 00 00 00>[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32mThe `size` must be less than or equal to the value of[m
[32m+[m[32m`require('buffer').kMaxLength` (on 64-bit architectures, `kMaxLength` is[m
[32m+[m[32m`(2^31)-1`). Otherwise, a [`RangeError`][] is thrown. A zero-length Buffer will[m
[32m+[m[32mbe created if a `size` less than or equal to 0 is specified.[m
[32m+[m
[32m+[m[32mIf `fill` is specified, the allocated `Buffer` will be initialized by calling[m
[32m+[m[32m`buf.fill(fill)`. See [`buf.fill()`][] for more information.[m
[32m+[m
[32m+[m[32m```js[m
[32m+[m[32mconst buf = Buffer.alloc(5, 'a');[m
[32m+[m[32mconsole.log(buf);[m
[32m+[m[32m  // <Buffer 61 61 61 61 61>[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32mIf both `fill` and `encoding` are specified, the allocated `Buffer` will be[m
[32m+[m[32minitialized by calling `buf.fill(fill, encoding)`. For example:[m
[32m+[m
[32m+[m[32m```js[m
[32m+[m[32mconst buf = Buffer.alloc(11, 'aGVsbG8gd29ybGQ=', 'base64');[m
[32m+[m[32mconsole.log(buf);[m
[32m+[m[32m  // <Buffer 68 65 6c 6c 6f 20 77 6f 72 6c 64>[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32mCalling `Buffer.alloc(size)` can be significantly slower than the alternative[m
[32m+[m[32m`Buffer.allocUnsafe(size)` but ensures that the newly created `Buffer` instance[m
[32m+[m[32mcontents will *never contain sensitive data*.[m
[32m+[m
[32m+[m[32mA `TypeError` will be thrown if `size` is not a number.[m
[32m+[m
[32m+[m[32m### Class Method: Buffer.allocUnsafe(size)[m
[32m+[m[32m<!-- YAML[m
[32m+[m[32madded: v5.10.0[m
[32m+[m[32m-->[m
[32m+[m
[32m+[m[32m* `size` {Number}[m
[32m+[m
[32m+[m[32mAllocates a new *non-zero-filled* `Buffer` of `size` bytes.  The `size` must[m
[32m+[m[32mbe less than or equal to the value of `require('buffer').kMaxLength` (on 64-bit[m
[32m+[m[32marchitectures, `kMaxLength` is `(2^31)-1`). Otherwise, a [`RangeError`][] is[m
[32m+[m[32mthrown. A zero-length Buffer will be created if a `size` less than or equal to[m
[32m+[m[32m0 is specified.[m
[32m+[m
[32m+[m[32mThe underlying memory for `Buffer` instances created in this way is *not[m
[32m+[m[32minitialized*. The contents of the newly created `Buffer` are unknown and[m
[32m+[m[32m*may contain sensitive data*. Use [`buf.fill(0)`][] to initialize such[m
[32m+[m[32m`Buffer` instances to zeroes.[m
[32m+[m
[32m+[m[32m```js[m
[32m+[m[32mconst buf = Buffer.allocUnsafe(5);[m
[32m+[m[32mconsole.log(buf);[m
[32m+[m[32m  // <Buffer 78 e0 82 02 01>[m
[32m+[m[32m  // (octets will be different, every time)[m
[32m+[m[32mbuf.fill(0);[m
[32m+[m[32mconsole.log(buf);[m
[32m+[m[32m  // <Buffer 00 00 00 00 00>[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32mA `TypeError` will be thrown if `size` is not a number.[m
[32m+[m
[32m+[m[32mNote that the `Buffer` module pre-allocates an internal `Buffer` instance of[m
[32m+[m[32msize `Buffer.poolSize` that is used as a pool for the fast allocation of new[m
[32m+[m[32m`Buffer` instances created using `Buffer.allocUnsafe(size)` (and the deprecated[m
[32m+[m[32m`new Buffer(size)` constructor) only when `size` is less than or equal to[m
[32m+[m[32m`Buffer.poolSize >> 1` (floor of `Buffer.poolSize` divided by two). The default[m
[32m+[m[32mvalue of `Buffer.poolSize` is `8192` but can be modified.[m
[32m+[m
[32m+[m[32mUse of this pre-allocated internal memory pool is a key difference between[m
[32m+[m[32mcalling `Buffer.alloc(size, fill)` vs. `Buffer.allocUnsafe(size).fill(fill)`.[m
[32m+[m[32mSpecifically, `Buffer.alloc(size, fill)` will *never* use the internal Buffer[m
[32m+[m[32mpool, while `Buffer.allocUnsafe(size).fill(fill)` *will* use the internal[m
[32m+[m[32mBuffer pool if `size` is less than or equal to half `Buffer.poolSize`. The[m
[32m+[m[32mdifference is subtle but can be important when an application requires the[m
[32m+[m[32madditional performance that `Buffer.allocUnsafe(size)` provides.[m
[32m+[m
[32m+[m[32m### Class Method: Buffer.allocUnsafeSlow(size)[m
[32m+[m[32m<!-- YAML[m
[32m+[m[32madded: v5.10.0[m
[32m+[m[32m-->[m
[32m+[m
[32m+[m[32m* `size` {Number}[m
[32m+[m
[32m+[m[32mAllocates a new *non-zero-filled* and non-pooled `Buffer` of `size` bytes.  The[m
[32m+[m[32m`size` must be less than or equal to the value of[m
[32m+[m[32m`require('buffer').kMaxLength` (on 64-bit architectures, `kMaxLength` is[m
[32m+[m[32m`(2^31)-1`). Otherwise, a [`RangeError`][] is thrown. A zero-length Buffer will[m
[32m+[m[32mbe created if a `size` less than or equal to 0 is specified.[m
[32m+[m
[32m+[m[32mThe underlying memory for `Buffer` instances created in this way is *not[m
[32m+[m[32minitialized*. The contents of the newly created `Buffer` are unknown and[m
[32m+[m[32m*may contain sensitive data*. Use [`buf.fill(0)`][] to initialize such[m
[32m+[m[32m`Buffer` instances to zeroes.[m
[32m+[m
[32m+[m[32mWhen using `Buffer.allocUnsafe()` to allocate new `Buffer` instances,[m
[32m+[m[32mallocations under 4KB are, by default, sliced from a single pre-allocated[m
[32m+[m[32m`Buffer`. This allows applications to avoid the garbage collection overhead of[m
[32m+[m[32mcreating many individually allocated Buffers. This approach improves both[m
[32m+[m[32mperformance and memory usage by eliminating the need to track and cleanup as[m
[32m+[m[32mmany `Persistent` objects.[m
[32m+[m
[32m+[m[32mHowever, in the case where a developer may need to retain a small chunk of[m
[32m+[m[32mmemory from a pool for an indeterminate amount of time, it may be appropriate[m
[32m+[m[32mto create an un-pooled Buffer instance using `Buffer.allocUnsafeSlow()` then[m
[32m+[m[32mcopy out the relevant bits.[m
[32m+[m
[32m+[m[32m```js[m
[32m+[m[32m// need to keep around a few small chunks of memory[m
[32m+[m[32mconst store = [];[m
[32m+[m
[32m+[m[32msocket.on('readable', () => {[m
[32m+[m[32m  const data = socket.read();[m
[32m+[m[32m  // allocate for retained data[m
[32m+[m[32m  const sb = Buffer.allocUnsafeSlow(10);[m
[32m+[m[32m  // copy the data into the new allocation[m
[32m+[m[32m  data.copy(sb, 0, 0, 10);[m
[32m+[m[32m  store.push(sb);[m
[32m+[m[32m});[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32mUse of `Buffer.allocUnsafeSlow()` should be used only as a last resort *after*[m
[32m+[m[32ma developer has observed undue memory retention in their applications.[m
[32m+[m
[32m+[m[32mA `TypeError` will be thrown if `size` is not a number.[m
[32m+[m
[32m+[m[32m### All the Rest[m
[32m+[m
[32m+[m[32mThe rest of the `Buffer` API is exactly the same as in node.js.[m
[32m+[m[32m[See the docs](https://nodejs.org/api/buffer.html).[m
[32m+[m
[32m+[m
[32m+[m[32m## Related links[m
[32m+[m
[32m+[m[32m- [Node.js issue: Buffer(number) is unsafe](https://github.com/nodejs/node/issues/4660)[m
[32m+[m[32m- [Node.js Enhancement Proposal: Buffer.from/Buffer.alloc/Buffer.zalloc/Buffer() soft-deprecate](https://github.com/nodejs/node-eps/pull/4)[m
[32m+[m
[32m+[m[32m## Why is `Buffer` unsafe?[m
[32m+[m
[32m+[m[32mToday, the node.js `Buffer` constructor is overloaded to handle many different argument[m
[32m+[m[32mtypes like `String`, `Array`, `Object`, `TypedArrayView` (`Uint8Array`, etc.),[m
[32m+[m[32m`ArrayBuffer`, and also `Number`.[m
[32m+[m
[32m+[m[32mThe API is optimized for convenience: you can throw any type at it, and it will try to do[m
[32m+[m[32mwhat you want.[m
[32m+[m
[32m+[m[32mBecause the Buffer constructor is so powerful, you often see code like this:[m
[32m+[m
[32m+[m[32m```js[m
[32m+[m[32m// Convert UTF-8 strings to hex[m
[32m+[m[32mfunction toHex (str) {[m
[32m+[m[32m  return new Buffer(str).toString('hex')[m
[32m+[m[32m}[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32m***But what happens if `toHex` is called with a `Number` argument?***[m
[32m+[m
[32m+[m[32m### Remote Memory Disclosure[m
[32m+[m
[32m+[m[32mIf an attacker can make your program call the `Buffer` constructor with a `Number`[m
[32m+[m[32margument, then they can make it allocate uninitialized memory from the node.js process.[m
[32m+[m[32mThis could potentially disclose TLS private keys, user data, or database passwords.[m
[32m+[m
[32m+[m[32mWhen the `Buffer` constructor is passed a `Number` argument, it returns an[m
[32m+[m[32m**UNINITIALIZED** block of memory of the specified `size`. When you create a `Buffer` like[m
[32m+[m[32mthis, you **MUST** overwrite the contents before returning it to the user.[m
[32m+[m
[32m+[m[32mFrom the [node.js docs](https://nodejs.org/api/buffer.html#buffer_new_buffer_size):[m
[32m+[m
[32m+[m[32m> `new Buffer(size)`[m
[32m+[m[32m>[m
[32m+[m[32m> - `size` Number[m
[32m+[m[32m>[m
[32m+[m[32m> The underlying memory for `Buffer` instances created in this way is not initialized.[m
[32m+[m[32m> **The contents of a newly created `Buffer` are unknown and could contain sensitive[m
[32m+[m[32m> data.** Use `buf.fill(0)` to initialize a Buffer to zeroes.[m
[32m+[m
[32m+[m[32m(Emphasis our own.)[m
[32m+[m
[32m+[m[32mWhenever the programmer intended to create an uninitialized `Buffer` you often see code[m
[32m+[m[32mlike this:[m
[32m+[m
[32m+[m[32m```js[m
[32m+[m[32mvar buf = new Buffer(16)[m
[32m+[m
[32m+[m[32m// Immediately overwrite the uninitialized buffer with data from another buffer[m
[32m+[m[32mfor (var i = 0; i < buf.length; i++) {[m
[32m+[m[32m  buf[i] = otherBuf[i][m
[32m+[m[32m}[m
[32m+[m[32m```[m
[32m+[m
[32m+[m
[32m+[m[32m### Would this ever be a problem in real code?[m
[32m+[m
[32m+[m[32mYes. It's surprisingly common to forget to check the type of your variables in a[m
[32m+[m[32mdynamically-typed language like JavaScript.[m
[32m+[m
[32m+[m[32mUsually the consequences of assuming the wrong type is that your program crashes with an[m
[32m+[m[32muncaught exception. But the failure mode for forgetting to check the type of arguments to[m
[32m+[m[32mthe `Buffer` constructor is more catastrophic.[m
[32m+[m
[32m+[m[32mHere's an example of a vulnerable service that takes a JSON payload and converts it to[m
[32m+[m[32mhex:[m
[32m+[m
[32m+[m[32m```js[m
[32m+[m[32m// Take a JSON payload {str: "some string"} and convert it to hex[m
[32m+[m[32mvar server = http.createServer(function (req, res) {[m
[32m+[m[32m  var data = ''[m
[32m+[m[32m  req.setEncoding('utf8')[m
[32m+[m[32m  req.on('data', function (chunk) {[m
[32m+[m[32m    data += chunk[m
[32m+[m[32m  })[m
[32m+[m[32m  req.on('end', function () {[m
[32m+[m[32m    var body = JSON.parse(data)[m
[32m+[m[32m    res.end(new Buffer(body.str).toString('hex'))[m
[32m+[m[32m  })[m
[32m+[m[32m})[m
[32m+[m
[32m+[m[32mserver.listen(8080)[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32mIn this example, an http client just has to send:[m
[32m+[m
[32m+[m[32m```json[m
[32m+[m[32m{[m
[32m+[m[32m  "str": 1000[m
[32m+[m[32m}[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32mand it will get back 1,000 bytes of uninitialized memory from the server.[m
[32m+[m
[32m+[m[32mThis is a very serious bug. It's similar in severity to the[m
[32m+[m[32m[the Heartbleed bug](http://heartbleed.com/) that allowed disclosure of OpenSSL process[m
[32m+[m[32mmemory by remote attackers.[m
[32m+[m
[32m+[m
[32m+[m[32m### Which real-world packages were vulnerable?[m
[32m+[m
[32m+[m[32m#### [`bittorrent-dht`](https://www.npmjs.com/package/bittorrent-dht)[m
[32m+[m
[32m+[m[32m[Mathias Buus](https://github.com/mafintosh) and I[m
[32m+[m[32m([Feross Aboukhadijeh](http://feross.org/)) found this issue in one of our own packages,[m
[32m+[m[32m[`bittorrent-dht`](https://www.npmjs.com/package/bittorrent-dht). The bug would allow[m
[32m+[m[32manyone on the internet to send a series of messages to a user of `bittorrent-dht` and get[m
[32m+[m[32mthem to reveal 20 bytes at a time of uninitialized memory from the node.js process.[m
[32m+[m
[32m+[m[32mHere's[m
[32m+[m[32m[the commit](https://github.com/feross/bittorrent-dht/commit/6c7da04025d5633699800a99ec3fbadf70ad35b8)[m
[32m+[m[32mthat fixed it. We released a new fixed version, created a[m
[32m+[m[32m[Node Security Project disclosure](https://nodesecurity.io/advisories/68), and deprecated all[m
[32m+[m[32mvulnerable versions on npm so users will get a warning to upgrade to a newer version.[m
[32m+[m
[32m+[m[32m#### [`ws`](https://www.npmjs.com/package/ws)[m
[32m+[m
[32m+[m[32mThat got us wondering if there were other vulnerable packages. Sure enough, within a short[m
[32m+[m[32mperiod of time, we found the same issue in [`ws`](https://www.npmjs.com/package/ws), the[m
[32m+[m[32mmost popular WebSocket implementation in node.js.[m
[32m+[m
[32m+[m[32mIf certain APIs were called with `Number` parameters instead of `String` or `Buffer` as[m
[32m+[m[32mexpected, then uninitialized server memory would be disclosed to the remote peer.[m
[32m+[m
[32m+[m[32mThese were the vulnerable methods:[m
[32m+[m
[32m+[m[32m```js[m
[32m+[m[32msocket.send(number)[m
[32m+[m[32msocket.ping(number)[m
[32m+[m[32msocket.pong(number)[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32mHere's a vulnerable socket server with some echo functionality:[m
[32m+[m
[32m+[m[32m```js[m
[32m+[m[32mserver.on('connection', function (socket) {[m
[32m+[m[32m  socket.on('message', function (message) {[m
[32m+[m[32m    message = JSON.parse(message)[m
[32m+[m[32m    if (message.type === 'echo') {[m
[32m+[m[32m      socket.send(message.data) // send back the user's message[m
[32m+[m[32m    }[m
[32m+[m[32m  })[m
[32m+[m[32m})[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32m`socket.send(number)` called on the server, will disclose server memory.[m
[32m+[m
[32m+[m[32mHere's [the release](https://github.com/websockets/ws/releases/tag/1.0.1) where the issue[m
[32m+[m[32mwas fixed, with a more detailed explanation. Props to[m
[32m+[m[32m[Arnout Kazemier](https://github.com/3rd-Eden) for the quick fix. Here's the[m
[32m+[m[32m[Node Security Project disclosure](https://nodesecurity.io/advisories/67).[m
[32m+[m
[32m+[m
[32m+[m[32m### What's the solution?[m
[32m+[m
[32m+[m[32mIt's important that node.js offers a fast way to get memory otherwise performance-critical[m
[32m+[m[32mapplications would needlessly get a lot slower.[m
[32m+[m
[32m+[m[32mBut we need a better way to *signal our intent* as programmers. **When we want[m
[32m+[m[32muninitialized memory, we should request it explicitly.**[m
[32m+[m
[32m+[m[32mSensitive functionality should not be packed into a developer-friendly API that loosely[m
[32m+[m[32maccepts many different types. This type of API encourages the lazy practice of passing[m
[32m+[m[32mvariables in without checking the type very carefully.[m
[32m+[m
[32m+[m[32m#### A new API: `Buffer.allocUnsafe(number)`[m
[32m+[m
[32m+[m[32mThe functionality of creating buffers with uninitialized memory should be part of another[m
[32m+[m[32mAPI. We propose `Buffer.allocUnsafe(number)`. This way, it's not part of an API that[m
[32m+[m[32mfrequently gets user input of all sorts of different types passed into it.[m
[32m+[m
[32m+[m[32m```js[m
[32m+[m[32mvar buf = Buffer.allocUnsafe(16) // careful, uninitialized memory![m
[32m+[m
[32m+[m[32m// Immediately overwrite the uninitialized buffer with data from another buffer[m
[32m+[m[32mfor (var i = 0; i < buf.length; i++) {[m
[32m+[m[32m  buf[i] = otherBuf[i][m
[32m+[m[32m}[m
[32m+[m[32m```[m
[32m+[m
[32m+[m
[32m+[m[32m### How do we fix node.js core?[m
[32m+[m
[32m+[m[32mWe sent [a PR to node.js core](https://github.com/nodejs/node/pull/4514) (merged as[m
[32m+[m[32m`semver-major`) which defends against one case:[m
[32m+[m
[32m+[m[32m```js[m
[32m+[m[32mvar str = 16[m
[32m+[m[32mnew Buffer(str, 'utf8')[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32mIn this situation, it's implied that the programmer intended the first argument to be a[m
[32m+[m[32mstring, since they passed an encoding as a second argument. Today, node.js will allocate[m
[32m+[m[32muninitialized memory in the case of `new Buffer(number, encoding)`, which is probably not[m
[32m+[m[32mwhat the programmer intended.[m
[32m+[m
[32m+[m[32mBut this is only a partial solution, since if the programmer does `new Buffer(variable)`[m
[32m+[m[32m(without an `encoding` parameter) there's no way to know what they intended. If `variable`[m
[32m+[m[32mis sometimes a number, then uninitialized memory will sometimes be returned.[m
[32m+[m
[32m+[m[32m### What's the real long-term fix?[m
[32m+[m
[32m+[m[32mWe could deprecate and remove `new Buffer(number)` and use `Buffer.allocUnsafe(number)` when[m
[32m+[m[32mwe need uninitialized memory. But that would break 1000s of packages.[m
[32m+[m
[32m+[m[32m~~We believe the best solution is to:~~[m
[32m+[m
[32m+[m[32m~~1. Change `new Buffer(number)` to return safe, zeroed-out memory~~[m
[32m+[m
[32m+[m[32m~~2. Create a new API for creating uninitialized Buffers. We propose: `Buffer.allocUnsafe(number)`~~[m
[32m+[m
[32m+[m[32m#### Update[m
[32m+[m
[32m+[m[32mWe now support adding three new APIs:[m
[32m+[m
[32m+[m[32m- `Buffer.from(value)` - convert from any type to a buffer[m
[32m+[m[32m- `Buffer.alloc(size)` - create a zero-filled buffer[m
[32m+[m[32m- `Buffer.allocUnsafe(size)` - create an uninitialized buffer with given size[m
[32m+[m
[32m+[m[32mThis solves the core problem that affected `ws` and `bittorrent-dht` which is[m
[32m+[m[32m`Buffer(variable)` getting tricked into taking a number argument.[m
[32m+[m
[32m+[m[32mThis way, existing code continues working and the impact on the npm ecosystem will be[m
[32m+[m[32mminimal. Over time, npm maintainers can migrate performance-critical code to use[m
[32m+[m[32m`Buffer.allocUnsafe(number)` instead of `new Buffer(number)`.[m
[32m+[m
[32m+[m
[32m+[m[32m### Conclusion[m
[32m+[m
[32m+[m[32mWe think there's a serious design issue with the `Buffer` API as it exists today. It[m
[32m+[m[32mpromotes insecure software by putting high-risk functionality into a convenient API[m
[32m+[m[32mwith friendly "developer ergonomics".[m
[32m+[m
[32m+[m[32mThis wasn't merely a theoretical exercise because we found the issue in some of the[m
[32m+[m[32mmost popular npm packages.[m
[32m+[m
[32m+[m[32mFortunately, there's an easy fix that can be applied today. Use `safe-buffer` in place of[m
[32m+[m[32m`buffer`.[m
[32m+[m
[32m+[m[32m```js[m
[32m+[m[32mvar Buffer = require('safe-buffer').Buffer[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32mEventually, we hope that node.js core can switch to this new, safer behavior. We believe[m
[32m+[m[32mthe impact on the ecosystem would be minimal since it's not a breaking change.[m
[32m+[m[32mWell-maintained, popular packages would be updated to use `Buffer.alloc` quickly, while[m
[32m+[m[32molder, insecure packages would magically become safe from this attack vector.[m
[32m+[m
[32m+[m
[32m+[m[32m## links[m
[32m+[m
[32m+[m[32m- [Node.js PR: buffer: throw if both length and enc are passed](https://github.com/nodejs/node/pull/4514)[m
[32m+[m[32m- [Node Security Project disclosure for `ws`](https://nodesecurity.io/advisories/67)[m
[32m+[m[32m- [Node Security Project disclosure for`bittorrent-dht`](https://nodesecurity.io/advisories/68)[m
[32m+[m
[32m+[m
[32m+[m[32m## credit[m
[32m+[m
[32m+[m[32mThe original issues in `bittorrent-dht`[m
[32m+[m[32m([disclosure](https://nodesecurity.io/advisories/68)) and[m
[32m+[m[32m`ws` ([disclosure](https://nodesecurity.io/advisories/67)) were discovered by[m
[32m+[m[32m[Mathias Buus](https://github.com/mafintosh) and[m
[32m+[m[32m[Feross Aboukhadijeh](http://feross.org/).[m
[32m+[m
[32m+[m[32mThanks to [Adam Baldwin](https://github.com/evilpacket) for helping disclose these issues[m
[32m+[m[32mand for his work running the [Node Security Project](https://nodesecurity.io/).[m
[32m+[m
[32m+[m[32mThanks to [John Hiesey](https://github.com/jhiesey) for proofreading this README and[m
[32m+[m[32mauditing the code.[m
[32m+[m
[32m+[m
[32m+[m[32m## license[m
[32m+[m
[32m+[m[32mMIT. Copyright (C) [Feross Aboukhadijeh](http://feross.org)[m
[1mdiff --git a/node_modules/string_decoder/node_modules/safe-buffer/index.d.ts b/node_modules/string_decoder/node_modules/safe-buffer/index.d.ts[m
[1mnew file mode 100644[m
[1mindex 0000000..e9fed80[m
[1m--- /dev/null[m
[1m+++ b/node_modules/string_decoder/node_modules/safe-buffer/index.d.ts[m
[36m@@ -0,0 +1,187 @@[m
[32m+[m[32mdeclare module "safe-buffer" {[m
[32m+[m[32m  export class Buffer {[m
[32m+[m[32m    length: number[m
[32m+[m[32m    write(string: string, offset?: number, length?: number, encoding?: string): number;[m
[32m+[m[32m    toString(encoding?: string, start?: number, end?: number): string;[m
[32m+[m[32m    toJSON(): { type: 'Buffer', data: any[] };[m
[32m+[m[32m    equals(otherBuffer: Buffer): boolean;[m
[32m+[m[32m    compare(otherBuffer: Buffer, targetStart?: number, targetEnd?: number, sourceStart?: number, sourceEnd?: number): number;[m
[32m+[m[32m    copy(targetBuffer: Buffer, targetStart?: number, sourceStart?: number, sourceEnd?: number): number;[m
[32m+[m[32m    slice(start?: number, end?: number): Buffer;[m
[32m+[m[32m    writeUIntLE(value: number, offset: number, byteLength: number, noAssert?: boolean): number;[m
[32m+[m[32m    writeUIntBE(value: number, offset: number, byteLength: number, noAssert?: boolean): number;[m
[32m+[m[32m    writeIntLE(value: number, offset: number, byteLength: number, noAssert?: boolean): number;[m
[32m+[m[32m    writeIntBE(value: number, offset: number, byteLength: number, noAssert?: boolean): number;[m
[32m+[m[32m    readUIntLE(offset: number, byteLength: number, noAssert?: boolean): number;[m
[32m+[m[32m    readUIntBE(offset: number, byteLength: number, noAssert?: boolean): number;[m
[32m+[m[32m    readIntLE(offset: number, byteLength: number, noAssert?: boolean): number;[m
[32m+[m[32m    readIntBE(offset: number, byteLength: number, noAssert?: boolean): number;[m
[32m+[m[32m    readUInt8(offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    readUInt16LE(offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    readUInt16BE(offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    readUInt32LE(offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    readUInt32BE(offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    readInt8(offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    readInt16LE(offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    readInt16BE(offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    readInt32LE(offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    readInt32BE(offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    readFloatLE(offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    readFloatBE(offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    readDoubleLE(offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    readDoubleBE(offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    swap16(): Buffer;[m
[32m+[m[32m    swap32(): Buffer;[m
[32m+[m[32m    swap64(): Buffer;[m
[32m+[m[32m    writeUInt8(value: number, offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    writeUInt16LE(value: number, offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    writeUInt16BE(value: number, offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    writeUInt32LE(value: number, offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    writeUInt32BE(value: number, offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    writeInt8(value: number, offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    writeInt16LE(value: number, offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    writeInt16BE(value: number, offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    writeInt32LE(value: number, offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    writeInt32BE(value: number, offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    writeFloatLE(value: number, offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    writeFloatBE(value: number, offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    writeDoubleLE(value: number, offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    writeDoubleBE(value: number, offset: number, noAssert?: boolean): number;[m
[32m+[m[32m    fill(value: any, offset?: number, end?: number): this;[m
[32m+[m[32m    indexOf(value: string | number | Buffer, byteOffset?: number, encoding?: string): number;[m
[32m+[m[32m    lastIndexOf(value: string | number | Buffer, byteOffset?: number, encoding?: string): number;[m
[32m+[m[32m    includes(value: string | number | Buffer, byteOffset?: number, encoding?: string): boolean;[m
[32m+[m
[32m+[m[32m    /**[m
[32m+[m[32m     * Allocates a new buffer containing the given {str}.[m
[32m+[m[32m     *[m
[32m+[m[32m     * @param str String to store in buffer.[m
[32m+[m[32m     * @param encoding encoding to use, optional.  Default is 'utf8'[m
[32m+[m[32m     */[m
[32m+[m[32m     constructor (str: string, encoding?: string);[m
[32m+[m[32m    /**[m
[32m+[m[32m     * Allocates a new buffer of {size} octets.[m
[32m+[m[32m     *[m
[32m+[m[32m     * @param size count of octets to allocate.[m
[32m+[m[32m     */[m
[32m+[m[32m    constructor (size: number);[m
[32m+[m[32m    /**[m
[32m+[m[32m     * Allocates a new buffer containing the given {array} of octets.[m
[32m+[m[32m     *[m
[32m+[m[32m     * @param array The octets to store.[m
[32m+[m[32m     */[m
[32m+[m[32m    constructor (array: Uint8Array);[m
[32m+[m[32m    /**[m
[32m+[m[32m     * Produces a Buffer backed by the same allocated memory as[m
[32m+[m[32m     * the given {ArrayBuffer}.[m
[32m+[m[32m     *[m
[32m+[m[32m     *[m
[32m+[m[32m     * @param arrayBuffer The ArrayBuffer with which to share memory.[m
[32m+[m[32m     */[m
[32m+[m[32m    constructor (arrayBuffer: ArrayBuffer);[m
[32m+[m[32m    /**[m
[32m+[m[32m     * Allocates a new buffer containing the given {array} of octets.[m
[32m+[m[32m     *[m
[32m+[m[32m     * @param array The octets to store.[m
[32m+[m[32m     */[m
[32m+[m[32m    constructor (array: any[]);[m
[32m+[m[32m    /**[m
[32m+[m[32m     * Copies the passed {buffer} data onto a new {Buffer} instance.[m
[32m+[m[32m     *[m
[32m+[m[32m     * @param buffer The buffer to copy.[m
[32m+[m[32m     */[m
[32m+[m[32m    constructor (buffer: Buffer);[m
[32m+[m[32m    prototype: Buffer;[m
[32m+[m[32m    /**[m
[32m+[m[32m     * Allocates a new Buffer using an {array} of octets.[m
[32m+[m[32m     *[m
[32m+[m[32m     * @param array[m
[32m+[m[32m     */[m
[32m+[m[32m    static from(array: any[]): Buffer;[m
[32m+[m[32m    /**[m
[32m+[m[32m     * When passed a reference to the .buffer property of a TypedArray instance,[m
[32m+[m[32m     * the newly created Buffer will share the same allocated memory as the TypedArray.[m
[32m+[m[32m     * The optional {byteOffset} and {length} arguments specify a memory range[m
[32m+[m[32m     * within the {arrayBuffer} that will be shared by the Buffer.[m
[32m+[m[32m     *[m
[32m+[m[32m     * @param arrayBuffer The .buffer property of a TypedArray or a new ArrayBuffer()[m
[32m+[m[32m     * @param byteOffset[m
[32m+[m[32m     * @param length[m
[32m+[m[32m     */[m
[32m+[m[32m    static from(arrayBuffer: ArrayBuffer, byteOffset?: number, length?: number): Buffer;[m
[32m+[m[32m    /**[m
[32m+[m[32m     * Copies the passed {buffer} data onto a new Buffer instance.[m
[32m+[m[32m     *[m
[32m+[m[32m     * @param buffer[m
[32m+[m[32m     */[m
[32m+[m[32m    static from(buffer: Buffer): Buffer;[m
[32m+[m[32m    /**[m
[32m+[m[32m     * Creates a new Buffer containing the given JavaScript string {str}.[m
[32m+[m[32m     * If provided, the {encoding} parameter identifies the character encoding.[m
[32m+[m[32m     * If not provided, {encoding} defaults to 'utf8'.[m
[32m+[m[32m     *[m
[32m+[m[32m     * @param str[m
[32m+[m[32m     */[m
[32m+[m[32m    static from(str: string, encoding?: string): Buffer;[m
[32m+[m[32m    /**[m
[32m+[m[32m     * Returns true if {obj} is a Buffer[m
[32m+[m[32m     *[m
[32m+[m[32m     * @param obj object to test.[m
[32m+[m[32m     */[m
[32m+[m[32m    static isBuffer(obj: any): obj is Buffer;[m
[32m+[m[32m    /**[m
[32m+[m[32m     * Returns true if {encoding} is a valid encoding argument.[m
[32m+[m[32m     * Valid string encodings in Node 0.12: 'ascii'|'utf8'|'utf16le'|'ucs2'(alias of 'utf16le')|'base64'|'binary'(deprecated)|'hex'[m
[32m+[m[32m     *[m
[32m+[m[32m     * @param encoding string to test.[m
[32m+[m[32m     */[m
[32m+[m[32m    static isEncoding(encoding: string): boolean;[m
[32m+[m[32m    /**[m
[32m+[m[32m     * Gives the actual byte length of a string. encoding defaults to 'utf8'.[m
[32m+[m[32m     * This is not the same as String.prototype.length since that returns the number of characters in a string.[m
[32m+[m[32m     *[m
[32m+[m[32m     * @param string string to test.[m
[32m+[m[32m     * @param encoding encoding used to evaluate (defaults to 'utf8')[m
[32m+[m[32m     */[m
[32m+[m[32m    static byteLength(string: string, encoding?: string): number;[m
[32m+[m[32m    /**[m
[32m+[m[32m     * Returns a buffer which is the result of concatenating all the buffers in the list together.[m
[32m+[m[32m     *[m
[32m+[m[32m     * If the list has no items, or if the totalLength is 0, then it returns a zero-length buffer.[m
[32m+[m[32m     * If the list has exactly one item, then the first item of the list is returned.[m
[32m+[m[32m     * If the list has more than one item, then a new Buffer is created.[m
[32m+[m[32m     *[m
[32m+[m[32m     * @param list An array of Buffer objects to concatenate[m
[32m+[m[32m     * @param totalLength Total length of the buffers when concatenated.[m
[32m+[m[32m     *   If totalLength is not provided, it is read from the buffers in the list. However, this adds an additional loop to the function, so it is faster to provide the length explicitly.[m
[32m+[m[32m     */[m
[32m+[m[32m    static concat(list: Buffer[], totalLength?: number): Buffer;[m
[32m+[m[32m    /**[m
[32m+[m[32m     * The same as buf1.compare(buf2).[m
[32m+[m[32m     */[m
[32m+[m[32m    static compare(buf1: Buffer, buf2: Buffer): number;[m
[32m+[m[32m    /**[m
[32m+[m[32m     * Allocates a new buffer of {size} octets.[m
[32m+[m[32m     *[m
[32m+[m[32m     * @param size count of octets to allocate.[m
[32m+[m[32m     * @param fill if specified, buffer will be initialized by calling buf.fill(fill).[m
[32m+[m[32m     *    If parameter is omitted, buffer will be filled with zeros.[m
[32m+[m[32m     * @param encoding encoding used for call to buf.fill while initalizing[m
[32m+[m[32m     */[m
[32m+[m[32m    static alloc(size: number, fill?: string | Buffer | number, encoding?: string): Buffer;[m
[32m+[m[32m    /**[m
[32m+[m[32m     * Allocates a new buffer of {size} octets, leaving memory not initialized, so the contents[m
[32m+[m[32m     * of the newly created Buffer are unknown and may contain sensitive data.[m
[32m+[m[32m     *[m
[32m+[m[32m     * @param size count of octets to allocate[m
[32m+[m[32m     */[m
[32m+[m[32m    static allocUnsafe(size: number): Buffer;[m
[32m+[m[32m    /**[m
[32m+[m[32m     * Allocates a new non-pooled buffer of {size} octets, leaving memory not initialized, so the contents[m
[32m+[m[32m     * of the newly created Buffer are unknown and may contain sensitive data.[m
[32m+[m[32m     *[m
[32m+[m[32m     * @param size count of octets to allocate[m
[32m+[m[32m     */[m
[32m+[m[32m    static allocUnsafeSlow(size: number): Buffer;[m
[32m+[m[32m  }[m
[32m+[m[32m}[m
\ No newline at end of file[m
[1mdiff --git a/node_modules/string_decoder/node_modules/safe-buffer/index.js b/node_modules/string_decoder/node_modules/safe-buffer/index.js[m
[1mnew file mode 100644[m
[1mindex 0000000..22438da[m
[1m--- /dev/null[m
[1m+++ b/node_modules/string_decoder/node_modules/safe-buffer/index.js[m
[36m@@ -0,0 +1,62 @@[m
[32m+[m[32m/* eslint-disable node/no-deprecated-api */[m
[32m+[m[32mvar buffer = require('buffer')[m
[32m+[m[32mvar Buffer = buffer.Buffer[m
[32m+[m
[32m+[m[32m// alternative to using Object.keys for old browsers[m
[32m+[m[32mfunction copyProps (src, dst) {[m
[32m+[m[32m  for (var key in src) {[m
[32m+[m[32m    dst[key] = src[key][m
[32m+[m[32m  }[m
[32m+[m[32m}[m
[32m+[m[32mif (Buffer.from && Buffer.alloc && Buffer.allocUnsafe && Buffer.allocUnsafeSlow) {[m
[32m+[m[32m  module.exports = buffer[m
[32m+[m[32m} else {[m
[32m+[m[32m  // Copy properties from require('buffer')[m
[32m+[m[32m  copyProps(buffer, exports)[m
[32m+[m[32m  exports.Buffer = SafeBuffer[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction SafeBuffer (arg, encodingOrOffset, length) {[m
[32m+[m[32m  return Buffer(arg, encodingOrOffset, length)[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m// Copy static methods from Buffer[m
[32m+[m[32mcopyProps(Buffer, SafeBuffer)[m
[32m+[m
[32m+[m[32mSafeBuffer.from = function (arg, encodingOrOffset, length) {[m
[32m+[m[32m  if (typeof arg === 'number') {[m
[32m+[m[32m    throw new TypeError('Argument must not be a number')[m
[32m+[m[32m  }[m
[32m+[m[32m  return Buffer(arg, encodingOrOffset, length)[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mSafeBuffer.alloc = function (size, fill, encoding) {[m
[32m+[m[32m  if (typeof size !== 'number') {[m
[32m+[m[32m    throw new TypeError('Argument must be a number')[m
[32m+[m[32m  }[m
[32m+[m[32m  var buf = Buffer(size)[m
[32m+[m[32m  if (fill !== undefined) {[m
[32m+[m[32m    if (typeof encoding === 'string') {[m
[32m+[m[32m      buf.fill(fill, encoding)[m
[32m+[m[32m    } else {[m
[32m+[m[32m      buf.fill(fill)[m
[32m+[m[32m    }[m
[32m+[m[32m  } else {[m
[32m+[m[32m    buf.fill(0)[m
[32m+[m[32m  }[m
[32m+[m[32m  return buf[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mSafeBuffer.allocUnsafe = function (size) {[m
[32m+[m[32m  if (typeof size !== 'number') {[m
[32m+[m[32m    throw new TypeError('Argument must be a number')[m
[32m+[m[32m  }[m
[32m+[m[32m  return Buffer(size)[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mSafeBuffer.allocUnsafeSlow = function (size) {[m
[32m+[m[32m  if (typeof size !== 'number') {[m
[32m+[m[32m    throw new TypeError('Argument must be a number')[m
[32m+[m[32m  }[m
[32m+[m[32m  return buffer.SlowBuffer(size)[m
[32m+[m[32m}[m
[1mdiff --git a/node_modules/string_decoder/node_modules/safe-buffer/package.json b/node_modules/string_decoder/node_modules/safe-buffer/package.json[m
[1mnew file mode 100644[m
[1mindex 0000000..623fbc3[m
[1m--- /dev/null[m
[1m+++ b/node_modules/string_decoder/node_modules/safe-buffer/package.json[m
[36m@@ -0,0 +1,37 @@[m
[32m+[m[32m{[m
[32m+[m[32m  "name": "safe-buffer",[m
[32m+[m[32m  "description": "Safer Node.js Buffer API",[m
[32m+[m[32m  "version": "5.1.2",[m
[32m+[m[32m  "author": {[m
[32m+[m[32m    "name": "Feross Aboukhadijeh",[m
[32m+[m[32m    "email": "feross@feross.org",[m
[32m+[m[32m    "url": "http://feross.org"[m
[32m+[m[32m  },[m
[32m+[m[32m  "bugs": {[m
[32m+[m[32m    "url": "https://github.com/feross/safe-buffer/issues"[m
[32m+[m[32m  },[m
[32m+[m[32m  "devDependencies": {[m
[32m+[m[32m    "standard": "*",[m
[32m+[m[32m    "tape": "^4.0.0"[m
[32m+[m[32m  },[m
[32m+[m[32m  "homepage": "https://github.com/feross/safe-buffer",[m
[32m+[m[32m  "keywords": [[m
[32m+[m[32m    "buffer",[m
[32m+[m[32m    "buffer allocate",[m
[32m+[m[32m    "node security",[m
[32m+[m[32m    "safe",[m
[32m+[m[32m    "safe-buffer",[m
[32m+[m[32m    "security",[m
[32m+[m[32m    "uninitialized"[m
[32m+[m[32m  ],[m
[32m+[m[32m  "license": "MIT",[m
[32m+[m[32m  "main": "index.js",[m
[32m+[m[32m  "types": "index.d.ts",[m
[32m+[m[32m  "repository": {[m
[32m+[m[32m    "type": "git",[m
[32m+[m[32m    "url": "git://github.com/feross/safe-buffer.git"[m
[32m+[m[32m  },[m
[32m+[m[32m  "scripts": {[m
[32m+[m[32m    "test": "standard && tape test/*.js"[m
[32m+[m[32m  }[m
[32m+[m[32m}[m
[1mdiff --git a/node_modules/string_decoder/package.json b/node_modules/string_decoder/package.json[m
[1mnew file mode 100644[m
[1mindex 0000000..518c3eb[m
[1m--- /dev/null[m
[1m+++ b/node_modules/string_decoder/package.json[m
[36m@@ -0,0 +1,31 @@[m
[32m+[m[32m{[m
[32m+[m[32m  "name": "string_decoder",[m
[32m+[m[32m  "version": "1.1.1",[m
[32m+[m[32m  "description": "The string_decoder module from Node core",[m
[32m+[m[32m  "main": "lib/string_decoder.js",[m
[32m+[m[32m  "dependencies": {[m
[32m+[m[32m    "safe-buffer": "~5.1.0"[m
[32m+[m[32m  },[m
[32m+[m[32m  "devDependencies": {[m
[32m+[m[32m    "babel-polyfill": "^6.23.0",[m
[32m+[m[32m    "core-util-is": "^1.0.2",[m
[32m+[m[32m    "inherits": "^2.0.3",[m
[32m+[m[32m    "tap": "~0.4.8"[m
[32m+[m[32m  },[m
[32m+[m[32m  "scripts": {[m
[32m+[m[32m    "test": "tap test/parallel/*.js && node test/verify-dependencies",[m
[32m+[m[32m    "ci": "tap test/parallel/*.js test/ours/*.js --tap | tee test.tap && node test/verify-dependencies.js"[m
[32m+[m[32m  },[m
[32m+[m[32m  "repository": {[m
[32m+[m[32m    "type": "git",[m
[32m+[m[32m    "url": "git://github.com/nodejs/string_decoder.git"[m
[32m+[m[32m  },[m
[32m+[m[32m  "homepage": "https://github.com/nodejs/string_decoder",[m
[32m+[m[32m  "keywords": [[m
[32m+[m[32m    "string",[m
[32m+[m[32m    "decoder",[m
[32m+[m[32m    "browser",[m
[32m+[m[32m    "browserify"[m
[32m+[m[32m  ],[m
[32m+[m[32m  "license": "MIT"[m
[32m+[m[32m}[m
[1mdiff --git a/node_modules/typedarray/.travis.yml b/node_modules/typedarray/.travis.yml[m
[1mnew file mode 100644[m
[1mindex 0000000..cc4dba2[m
[1m--- /dev/null[m
[1m+++ b/node_modules/typedarray/.travis.yml[m
[36m@@ -0,0 +1,4 @@[m
[32m+[m[32mlanguage: node_js[m
[32m+[m[32mnode_js:[m
[32m+[m[32m  - "0.8"[m
[32m+[m[32m  - "0.10"[m
[1mdiff --git a/node_modules/typedarray/LICENSE b/node_modules/typedarray/LICENSE[m
[1mnew file mode 100644[m
[1mindex 0000000..11adfae[m
[1m--- /dev/null[m
[1m+++ b/node_modules/typedarray/LICENSE[m
[36m@@ -0,0 +1,35 @@[m
[32m+[m[32m/*[m
[32m+[m[32m Copyright (c) 2010, Linden Research, Inc.[m
[32m+[m[32m Copyright (c) 2012, Joshua Bell[m
[32m+[m
[32m+[m[32m Permission is hereby granted, free of charge, to any person obtaining a copy[m
[32m+[m[32m of this software and associated documentation files (the "Software"), to deal[m
[32m+[m[32m in the Software without restriction, including without limitation the rights[m
[32m+[m[32m to use, copy, modify, merge, publish, distribute, sublicense, and/or sell[m
[32m+[m[32m copies of the Software, and to permit persons to whom the Software is[m
[32m+[m[32m furnished to do so, subject to the following conditions:[m
[32m+[m
[32m+[m[32m The above copyright notice and this permission notice shall be included in[m
[32m+[m[32m all copies or substantial portions of the Software.[m
[32m+[m
[32m+[m[32m THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR[m
[32m+[m[32m IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,[m
[32m+[m[32m FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE[m
[32m+[m[32m AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER[m
[32m+[m[32m LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,[m
[32m+[m[32m OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN[m
[32m+[m[32m THE SOFTWARE.[m
[32m+[m[32m $/LicenseInfo$[m
[32m+[m[32m */[m
[32m+[m
[32m+[m[32m// Original can be found at:[m
[32m+[m[32m//   https://bitbucket.org/lindenlab/llsd[m
[32m+[m[32m// Modifications by Joshua Bell inexorabletash@gmail.com[m
[32m+[m[32m//   https://github.com/inexorabletash/polyfill[m
[32m+[m
[32m+[m[32m// ES3/ES5 implementation of the Krhonos Typed Array Specification[m
[32m+[m[32m//   Ref: http://www.khronos.org/registry/typedarray/specs/latest/[m
[32m+[m[32m//   Date: 2011-02-01[m
[32m+[m[32m//[m
[32m+[m[32m// Variations:[m
[32m+[m[32m//  * Allows typed_array.get/set() as alias for subscripts (typed_array[])[m
[1mdiff --git a/node_modules/typedarray/example/tarray.js b/node_modules/typedarray/example/tarray.js[m
[1mnew file mode 100644[m
[1mindex 0000000..8423d7c[m
[1m--- /dev/null[m
[1m+++ b/node_modules/typedarray/example/tarray.js[m
[36m@@ -0,0 +1,4 @@[m
[32m+[m[32mvar Uint8Array = require('../').Uint8Array;[m
[32m+[m[32mvar ua = new Uint8Array(5);[m
[32m+[m[32mua[1] = 256 + 55;[m
[32m+[m[32mconsole.log(ua[1]);[m
[1mdiff --git a/node_modules/typedarray/index.js b/node_modules/typedarray/index.js[m
[1mnew file mode 100644[m
[1mindex 0000000..5e54084[m
[1m--- /dev/null[m
[1m+++ b/node_modules/typedarray/index.js[m
[36m@@ -0,0 +1,630 @@[m
[32m+[m[32mvar undefined = (void 0); // Paranoia[m
[32m+[m
[32m+[m[32m// Beyond this value, index getters/setters (i.e. array[0], array[1]) are so slow to[m
[32m+[m[32m// create, and consume so much memory, that the browser appears frozen.[m
[32m+[m[32mvar MAX_ARRAY_LENGTH = 1e5;[m
[32m+[m
[32m+[m[32m// Approximations of internal ECMAScript conversion functions[m
[32m+[m[32mvar ECMAScript = (function() {[m
[32m+[m[32m  // Stash a copy in case other scripts modify these[m
[32m+[m[32m  var opts = Object.prototype.toString,[m
[32m+[m[32m      ophop = Object.prototype.hasOwnProperty;[m
[32m+[m
[32m+[m[32m  return {[m
[32m+[m[32m    // Class returns internal [[Class]] property, used to avoid cross-frame instanceof issues:[m
[32m+[m[32m    Class: function(v) { return opts.call(v).replace(/^\[object *|\]$/g, ''); },[m
[32m+[m[32m    HasProperty: function(o, p) { return p in o; },[m
[32m+[m[32m    HasOwnProperty: function(o, p) { return ophop.call(o, p); },[m
[32m+[m[32m    IsCallable: function(o) { return typeof o === 'function'; },[m
[32m+[m[32m    ToInt32: function(v) { return v >> 0; },[m
[32m+[m[32m    ToUint32: function(v) { return v >>> 0; }[m
[32m+[m[32m  };[m
[32m+[m[32m}());[m
[32m+[m
[32m+[m[32m// Snapshot intrinsics[m
[32m+[m[32mvar LN2 = Math.LN2,[m
[32m+[m[32m    abs = Math.abs,[m
[32m+[m[32m    floor = Math.floor,[m
[32m+[m[32m    log = Math.log,[m
[32m+[m[32m    min = Math.min,[m
[32m+[m[32m    pow = Math.pow,[m
[32m+[m[32m    round = Math.round;[m
[32m+[m
[32m+[m[32m// ES5: lock down object properties[m
[32m+[m[32mfunction configureProperties(obj) {[m
[32m+[m[32m  if (getOwnPropNames && defineProp) {[m
[32m+[m[32m    var props = getOwnPropNames(obj), i;[m
[32m+[m[32m    for (i = 0; i < props.length; i += 1) {[m
[32m+[m[32m      defineProp(obj, props[i], {[m
[32m+[m[32m        value: obj[props[i]],[m
[32m+[m[32m        writable: false,[m
[32m+[m[32m        enumerable: false,[m
[32m+[m[32m        configurable: false[m
[32m+[m[32m      });[m
[32m+[m[32m    }[m
[32m+[m[32m  }[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m// emulate ES5 getter/setter API using legacy APIs[m
[32m+[m[32m// http://blogs.msdn.com/b/ie/archive/2010/09/07/transitioning-existing-code-to-the-es5-getter-setter-apis.aspx[m
[32m+[m[32m// (second clause tests for Object.defineProperty() in IE<9 that only supports extending DOM prototypes, but[m
[32m+[m[32m// note that IE<9 does not support __defineGetter__ or __defineSetter__ so it just renders the method harmless)[m
[32m+[m[32mvar defineProp[m
[32m+[m[32mif (Object.defineProperty && (function() {[m
[32m+[m[32m      try {[m
[32m+[m[32m        Object.defineProperty({}, 'x', {});[m
[32m+[m[32m        return true;[m
[32m+[m[32m      } catch (e) {[m
[32m+[m[32m        return false;[m
[32m+[m[32m      }[m
[32m+[m[32m    })()) {[m
[32m+[m[32m  defineProp = Object.defineProperty;[m
[32m+[m[32m} else {[m
[32m+[m[32m  defineProp = function(o, p, desc) {[m
[32m+[m[32m    if (!o === Object(o)) throw new TypeError("Object.defineProperty called on non-object");[m
[32m+[m[32m    if (ECMAScript.HasProperty(desc, 'get') && Object.prototype.__defineGetter__) { Object.prototype.__defineGetter__.call(o, p, desc.get); }[m
[32m+[m[32m    if (ECMAScript.HasProperty(desc, 'set') && Object.prototype.__defineSetter__) { Object.prototype.__defineSetter__.call(o, p, desc.set); }[m
[32m+[m[32m    if (ECMAScript.HasProperty(desc, 'value')) { o[p] = desc.value; }[m
[32m+[m[32m    return o;[m
[32m+[m[32m  };[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mvar getOwnPropNames = Object.getOwnPropertyNames || function (o) {[m
[32m+[m[32m  if (o !== Object(o)) throw new TypeError("Object.getOwnPropertyNames called on non-object");[m
[32m+[m[32m  var props = [], p;[m
[32m+[m[32m  for (p in o) {[m
[32m+[m[32m    if (ECMAScript.HasOwnProperty(o, p)) {[m
[32m+[m[32m      props.push(p);[m
[32m+[m[32m    }[m
[32m+[m[32m  }[m
[32m+[m[32m  return props;[m
[32m+[m[32m};[m
[32m+[m
[32m+[m[32m// ES5: Make obj[index] an alias for obj._getter(index)/obj._setter(index, value)[m
[32m+[m[32m// for index in 0 ... obj.length[m
[32m+[m[32mfunction makeArrayAccessors(obj) {[m
[32m+[m[32m  if (!defineProp) { return; }[m
[32m+[m
[32m+[m[32m  if (obj.length > MAX_ARRAY_LENGTH) throw new RangeError("Array too large for polyfill");[m
[32m+[m
[32m+[m[32m  function makeArrayAccessor(index) {[m
[32m+[m[32m    defineProp(obj, index, {[m
[32m+[m[32m      'get': function() { return obj._getter(index); },[m
[32m+[m[32m      'set': function(v) { obj._setter(index, v); },[m
[32m+[m[32m      enumerable: true,[m
[32m+[m[32m      configurable: false[m
[32m+[m[32m    });[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  var i;[m
[32m+[m[32m  for (i = 0; i < obj.length; i += 1) {[m
[32m+[m[32m    makeArrayAccessor(i);[m
[32m+[m[32m  }[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m// Internal conversion functions:[m
[32m+[m[32m//    pack<Type>()   - take a number (interpreted as Type), output a byte array[m
[32m+[m[32m//    unpack<Type>() - take a byte array, output a Type-like number[m
[32m+[m
[32m+[m[32mfunction as_signed(value, bits) { var s = 32 - bits; return (value << s) >> s; }[m
[32m+[m[32mfunction as_unsigned(value, bits) { var s = 32 - bits; return (value << s) >>> s; }[m
[32m+[m
[32m+[m[32mfunction packI8(n) { return [n & 0xff]; }[m
[32m+[m[32mfunction unpackI8(bytes) { return as_signed(bytes[0], 8); }[m
[32m+[m
[32m+[m[32mfunction packU8(n) { return [n & 0xff]; }[m
[32m+[m[32mfunction unpackU8(bytes) { return as_unsigned(bytes[0], 8); }[m
[32m+[m
[32m+[m[32mfunction packU8Clamped(n) { n = round(Number(n)); return [n < 0 ? 0 : n > 0xff ? 0xff : n & 0xff]; }[m
[32m+[m
[32m+[m[32mfunction packI16(n) { return [(n >> 8) & 0xff, n & 0xff]; }[m
[32m+[m[32mfunction unpackI16(bytes) { return as_signed(bytes[0] << 8 | bytes[1], 16); }[m
[32m+[m
[32m+[m[32mfunction packU16(n) { return [(n >> 8) & 0xff, n & 0xff]; }[m
[32m+[m[32mfunction unpackU16(bytes) { return as_unsigned(bytes[0] << 8 | bytes[1], 16); }[m
[32m+[m
[32m+[m[32mfunction packI32(n) { return [(n >> 24) & 0xff, (n >> 16) & 0xff, (n >> 8) & 0xff, n & 0xff]; }[m
[32m+[m[32mfunction unpackI32(bytes) { return as_signed(bytes[0] << 24 | bytes[1] << 16 | bytes[2] << 8 | bytes[3], 32); }[m
[32m+[m
[32m+[m[32mfunction packU32(n) { return [(n >> 24) & 0xff, (n >> 16) & 0xff, (n >> 8) & 0xff, n & 0xff]; }[m
[32m+[m[32mfunction unpackU32(bytes) { return as_unsigned(bytes[0] << 24 | bytes[1] << 16 | bytes[2] << 8 | bytes[3], 32); }[m
[32m+[m
[32m+[m[32mfunction packIEEE754(v, ebits, fbits) {[m
[32m+[m
[32m+[m[32m  var bias = (1 << (ebits - 1)) - 1,[m
[32m+[m[32m      s, e, f, ln,[m
[32m+[m[32m      i, bits, str, bytes;[m
[32m+[m
[32m+[m[32m  function roundToEven(n) {[m
[32m+[m[32m    var w = floor(n), f = n - w;[m
[32m+[m[32m    if (f < 0.5)[m
[32m+[m[32m      return w;[m
[32m+[m[32m    if (f > 0.5)[m
[32m+[m[32m      return w + 1;[m
[32m+[m[32m    return w % 2 ? w + 1 : w;[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  // Compute sign, exponent, fraction[m
[32m+[m[32m  if (v !== v) {[m
[32m+[m[32m    // NaN[m
[32m+[m[32m    // http://dev.w3.org/2006/webapi/WebIDL/#es-type-mapping[m
[32m+[m[32m    e = (1 << ebits) - 1; f = pow(2, fbits - 1); s = 0;[m
[32m+[m[32m  } else if (v === Infinity || v === -Infinity) {[m
[32m+[m[32m    e = (1 << ebits) - 1; f = 0; s = (v < 0) ? 1 : 0;[m
[32m+[m[32m  } else if (v === 0) {[m
[32m+[m[32m    e = 0; f = 0; s = (1 / v === -Infinity) ? 1 : 0;[m
[32m+[m[32m  } else {[m
[32m+[m[32m    s = v < 0;[m
[32m+[m[32m    v = abs(v);[m
[32m+[m
[32m+[m[32m    if (v >= pow(2, 1 - bias)) {[m
[32m+[m[32m      e = min(floor(log(v) / LN2), 1023);[m
[32m+[m[32m      f = roundToEven(v / pow(2, e) * pow(2, fbits));[m
[32m+[m[32m      if (f / pow(2, fbits) >= 2) {[m
[32m+[m[32m        e = e + 1;[m
[32m+[m[32m        f = 1;[m
[32m+[m[32m      }[m
[32m+[m[32m      if (e > bias) {[m
[32m+[m[32m        // Overflow[m
[32m+[m[32m        e = (1 << ebits) - 1;[m
[32m+[m[32m        f = 0;[m
[32m+[m[32m      } else {[m
[32m+[m[32m        // Normalized[m
[32m+[m[32m        e = e + bias;[m
[32m+[m[32m        f = f - pow(2, fbits);[m
[32m+[m[32m      }[m
[32m+[m[32m    } else {[m
[32m+[m[32m      // Denormalized[m
[32m+[m[32m      e = 0;[m
[32m+[m[32m      f = roundToEven(v / pow(2, 1 - bias - fbits));[m
[32m+[m[32m    }[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  // Pack sign, exponent, fraction[m
[32m+[m[32m  bits = [];[m
[32m+[m[32m  for (i = fbits; i; i -= 1) { bits.push(f % 2 ? 1 : 0); f = floor(f / 2); }[m
[32m+[m[32m  for (i = ebits; i; i -= 1) { bits.push(e % 2 ? 1 : 0); e = floor(e / 2); }[m
[32m+[m[32m  bits.push(s ? 1 : 0);[m
[32m+[m[32m  bits.reverse();[m
[32m+[m[32m  str = bits.join('');[m
[32m+[m
[32m+[m[32m  // Bits to bytes[m
[32m+[m[32m  bytes = [];[m
[32m+[m[32m  while (str.length) {[m
[32m+[m[32m    bytes.push(parseInt(str.substring(0, 8), 2));[m
[32m+[m[32m    str = str.substring(8);[m
[32m+[m[32m  }[m
[32m+[m[32m  return bytes;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction unpackIEEE754(bytes, ebits, fbits) {[m
[32m+[m
[32m+[m[32m  // Bytes to bits[m
[32m+[m[32m  var bits = [], i, j, b, str,[m
[32m+[m[32m      bias, s, e, f;[m
[32m+[m
[32m+[m[32m  for (i = bytes.length; i; i -= 1) {[m
[32m+[m[32m    b = bytes[i - 1];[m
[32m+[m[32m    for (j = 8; j; j -= 1) {[m
[32m+[m[32m      bits.push(b % 2 ? 1 : 0); b = b >> 1;[m
[32m+[m[32m    }[m
[32m+[m[32m  }[m
[32m+[m[32m  bits.reverse();[m
[32m+[m[32m  str = bits.join('');[m
[32m+[m
[32m+[m[32m  // Unpack sign, exponent, fraction[m
[32m+[m[32m  bias = (1 << (ebits - 1)) - 1;[m
[32m+[m[32m  s = parseInt(str.substring(0, 1), 2) ? -1 : 1;[m
[32m+[m[32m  e = parseInt(str.substring(1, 1 + ebits), 2);[m
[32m+[m[32m  f = parseInt(str.substring(1 + ebits), 2);[m
[32m+[m
[32m+[m[32m  // Produce number[m
[32m+[m[32m  if (e === (1 << ebits) - 1) {[m
[32m+[m[32m    return f !== 0 ? NaN : s * Infinity;[m
[32m+[m[32m  } else if (e > 0) {[m
[32m+[m[32m    // Normalized[m
[32m+[m[32m    return s * pow(2, e - bias) * (1 + f / pow(2, fbits));[m
[32m+[m[32m  } else if (f !== 0) {[m
[32m+[m[32m    // Denormalized[m
[32m+[m[32m    return s * pow(2, -(bias - 1)) * (f / pow(2, fbits));[m
[32m+[m[32m  } else {[m
[32m+[m[32m    return s < 0 ? -0 : 0;[m
[32m+[m[32m  }[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mfunction unpackF64(b) { return unpackIEEE754(b, 11, 52); }[m
[32m+[m[32mfunction packF64(v) { return packIEEE754(v, 11, 52); }[m
[32m+[m[32mfunction unpackF32(b) { return unpackIEEE754(b, 8, 23); }[m
[32m+[m[32mfunction packF32(v) { return packIEEE754(v, 8, 23); }[m
[32m+[m
[32m+[m
[32m+[m[32m//[m
[32m+[m[32m// 3 The ArrayBuffer Type[m
[32m+[m[32m//[m
[32m+[m
[32m+[m[32m(function() {[m
[32m+[m
[32m+[m[32m  /** @constructor */[m
[32m+[m[32m  var ArrayBuffer = function ArrayBuffer(length) {[m
[32m+[m[32m    length = ECMAScript.ToInt32(length);[m
[32m+[m[32m    if (length < 0) throw new RangeError('ArrayBuffer size is not a small enough positive integer');[m
[32m+[m
[32m+[m[32m    this.byteLength = length;[m
[32m+[m[32m    this._bytes = [];[m
[32m+[m[32m    this._bytes.length = length;[m
[32m+[m
[32m+[m[32m    var i;[m
[32m+[m[32m    for (i = 0; i < this.byteLength; i += 1) {[m
[32m+[m[32m      this._bytes[i] = 0;[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    configureProperties(this);[m
[32m+[m[32m  };[m
[32m+[m
[32m+[m[32m  exports.ArrayBuffer = exports.ArrayBuffer || ArrayBuffer;[m
[32m+[m
[32m+[m[32m  //[m
[32m+[m[32m  // 4 The ArrayBufferView Type[m
[32m+[m[32m  //[m
[32m+[m
[32m+[m[32m  // NOTE: this constructor is not exported[m
[32m+[m[32m  /** @constructor */[m
[32m+[m[32m  var ArrayBufferView = function ArrayBufferView() {[m
[32m+[m[32m    //this.buffer = null;[m
[32m+[m[32m    //this.byteOffset = 0;[m
[32m+[m[32m    //this.byteLength = 0;[m
[32m+[m[32m  };[m
[32m+[m
[32m+[m[32m  //[m
[32m+[m[32m  // 5 The Typed Array View Types[m
[32m+[m[32m  //[m
[32m+[m
[32m+[m[32m  function makeConstructor(bytesPerElement, pack, unpack) {[m
[32m+[m[32m    // Each TypedArray type requires a distinct constructor instance with[m
[32m+[m[32m    // identical logic, which this produces.[m
[32m+[m
[32m+[m[32m    var ctor;[m
[32m+[m[32m    ctor = function(buffer, byteOffset, length) {[m
[32m+[m[32m      var array, sequence, i, s;[m
[32m+[m
[32m+[m[32m      if (!arguments.length || typeof arguments[0] === 'number') {[m
[32m+[m[32m        // Constructor(unsigned long length)[m
[32m+[m[32m        this.length = ECMAScript.ToInt32(arguments[0]);[m
[32m+[m[32m        if (length < 0) throw new RangeError('ArrayBufferView size is not a small enough positive integer');[m
[32m+[m
[32m+[m[32m        this.byteLength = this.length * this.BYTES_PER_ELEMENT;[m
[32m+[m[32m        this.buffer = new ArrayBuffer(this.byteLength);[m
[32m+[m[32m        this.byteOffset = 0;[m
[32m+[m[32m      } else if (typeof arguments[0] === 'object' && arguments[0].constructor === ctor) {[m
[32m+[m[32m        // Constructor(TypedArray array)[m
[32m+[m[32m        array = arguments[0];[m
[32m+[m
[32m+[m[32m        this.length = array.length;[m
[32m+[m[32m        this.byteLength = this.length * this.BYTES_PER_ELEMENT;[m
[32m+[m[32m        this.buffer = new ArrayBuffer(this.byteLength);[m
[32m+[m[32m        this.byteOffset = 0;[m
[32m+[m
[32m+[m[32m        for (i = 0; i < this.length; i += 1) {[m
[32m+[m[32m          this._setter(i, array._getter(i));[m
[32m+[m[32m        }[m
[32m+[m[32m      } else if (typeof arguments[0] === 'object' &&[m
[32m+[m[32m                 !(arguments[0] instanceof ArrayBuffer || ECMAScript.Class(arguments[0]) === 'ArrayBuffer')) {[m
[32m+[m[32m        // Constructor(sequence<type> array)[m
[32m+[m[32m        sequence = arguments[0];[m
[32m+[m
[32m+[m[32m        this.length = ECMAScript.ToUint32(sequence.length);[m
[32m+[m[32m        this.byteLength = this.length * this.BYTES_PER_ELEMENT;[m
[32m+[m[32m        this.buffer = new ArrayBuffer(this.byteLength);[m
[32m+[m[32m        this.byteOffset = 0;[m
[32m+[m
[32m+[m[32m        for (i = 0; i < this.length; i += 1) {[m
[32m+[m[32m          s = sequence[i];[m
[32m+[m[32m          this._setter(i, Number(s));[m
[32m+[m[32m        }[m
[32m+[m[32m      } else if (typeof arguments[0] === 'object' &&[m
[32m+[m[32m                 (arguments[0] instanceof ArrayBuffer || ECMAScript.Class(arguments[0]) === 'ArrayBuffer')) {[m
[32m+[m[32m        // Constructor(ArrayBuffer buffer,[m
[32m+[m[32m        //             optional unsigned long byteOffset, optional unsigned long length)[m
[32m+[m[32m        this.buffer = buffer;[m
[32m+[m
[32m+[m[32m        this.byteOffset = ECMAScript.ToUint32(byteOffset);[m
[32m+[m[32m        if (this.byteOffset > this.buffer.byteLength) {[m
[32m+[m[32m          throw new RangeError("byteOffset out of range");[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        if (this.byteOffset % this.BYTES_PER_ELEMENT) {[m
[32m+[m[32m          // The given byteOffset must be a multiple of the element[m
[32m+[m[32m          // size of the specific type, otherwise an exception is raised.[m
[32m+[m[32m          throw new RangeError("ArrayBuffer length minus the byteOffset is not a multiple of the element size.");[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        if (arguments.length < 3) {[m
[32m+[m[32m          this.byteLength = this.buffer.byteLength - this.byteOffset;[m
[32m+[m
[32m+[m[32m          if (this.byteLength % this.BYTES_PER_ELEMENT) {[m
[32m+[m[32m            throw new RangeError("length of buffer minus byteOffset not a multiple of the element size");[m
[32m+[m[32m          }[m
[32m+[m[32m          this.length = this.byteLength / this.BYTES_PER_ELEMENT;[m
[32m+[m[32m        } else {[m
[32m+[m[32m          this.length = ECMAScript.ToUint32(length);[m
[32m+[m[32m          this.byteLength = this.length * this.BYTES_PER_ELEMENT;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        if ((this.byteOffset + this.byteLength) > this.buffer.byteLength) {[m
[32m+[m[32m          throw new RangeError("byteOffset and length reference an area beyond the end of the buffer");[m
[32m+[m[32m        }[m
[32m+[m[32m      } else {[m
[32m+[m[32m        throw new TypeError("Unexpected argument type(s)");[m
[32m+[m[32m      }[m
[32m+[m
[32m+[m[32m      this.constructor = ctor;[m
[32m+[m
[32m+[m[32m      configureProperties(this);[m
[32m+[m[32m      makeArrayAccessors(this);[m
[32m+[m[32m    };[m
[32m+[m
[32m+[m[32m    ctor.prototype = new ArrayBufferView();[m
[32m+[m[32m    ctor.prototype.BYTES_PER_ELEMENT = bytesPerElement;[m
[32m+[m[32m    ctor.prototype._pack = pack;[m
[32m+[m[32m    ctor.prototype._unpack = unpack;[m
[32m+[m[32m    ctor.BYTES_PER_ELEMENT = bytesPerElement;[m
[32m+[m
[32m+[m[32m    // getter type (unsigned long index);[m
[32m+[m[32m    ctor.prototype._getter = function(index) {[m
[32m+[m[32m      if (arguments.length < 1) throw new SyntaxError("Not enough arguments");[m
[32m+[m
[32m+[m[32m      index = ECMAScript.ToUint32(index);[m
[32m+[m[32m      if (index >= this.length) {[m
[32m+[m[32m        return undefined;[m
[32m+[m[32m      }[m
[32m+[m
[32m+[m[32m      var bytes = [], i, o;[m
[32m+[m[32m      for (i = 0, o = this.byteOffset + index * this.BYTES_PER_ELEMENT;[m
[32m+[m[32m           i < this.BYTES_PER_ELEMENT;[m
[32m+[m[32m           i += 1, o += 1) {[m
[32m+[m[32m        bytes.push(this.buffer._bytes[o]);[m
[32m+[m[32m      }[m
[32m+[m[32m      return this._unpack(bytes);[m
[32m+[m[32m    };[m
[32m+[m
[32m+[m[32m    // NONSTANDARD: convenience alias for getter: type get(unsigned long index);[m
[32m+[m[32m    ctor.prototype.get = ctor.prototype._getter;[m
[32m+[m
[32m+[m[32m    // setter void (unsigned long index, type value);[m
[32m+[m[32m    ctor.prototype._setter = function(index, value) {[m
[32m+[m[32m      if (arguments.length < 2) throw new SyntaxError("Not enough arguments");[m
[32m+[m
[32m+[m[32m      index = ECMAScript.ToUint32(index);[m
[32m+[m[32m      if (index >= this.length) {[m
[32m+[m[32m        return undefined;[m
[32m+[m[32m      }[m
[32m+[m
[32m+[m[32m      var bytes = this._pack(value), i, o;[m
[32m+[m[32m      for (i = 0, o = this.byteOffset + index * this.BYTES_PER_ELEMENT;[m
[32m+[m[32m           i < this.BYTES_PER_ELEMENT;[m
[32m+[m[32m           i += 1, o += 1) {[m
[32m+[m[32m        this.buffer._bytes[o] = bytes[i];[m
[32m+[m[32m      }[m
[32m+[m[32m    };[m
[32m+[m
[32m+[m[32m    // void set(TypedArray array, optional unsigned long offset);[m
[32m+[m[32m    // void set(sequence<type> array, optional unsigned long offset);[m
[32m+[m[32m    ctor.prototype.set = function(index, value) {[m
[32m+[m[32m      if (arguments.length < 1) throw new SyntaxError("Not enough arguments");[m
[32m+[m[32m      var array, sequence, offset, len,[m
[32m+[m[32m          i, s, d,[m
[32m+[m[32m          byteOffset, byteLength, tmp;[m
[32m+[m
[32m+[m[32m      if (typeof arguments[0] === 'object' && arguments[0].constructor === this.constructor) {[m
[32m+[m[32m        // void set(TypedArray array, optional unsigned long offset);[m
[32m+[m[32m        array = arguments[0];[m
[32m+[m[32m        offset = ECMAScript.ToUint32(arguments[1]);[m
[32m+[m
[32m+[m[32m        if (offset + array.length > this.length) {[m
[32m+[m[32m          throw new RangeError("Offset plus length of array is out of range");[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        byteOffset = this.byteOffset + offset * this.BYTES_PER_ELEMENT;[m
[32m+[m[32m        byteLength = array.length * this.BYTES_PER_ELEMENT;[m
[32m+[m
[32m+[m[32m        if (array.buffer === this.buffer) {[m
[32m+[m[32m          tmp = [];[m
[32m+[m[32m          for (i = 0, s = array.byteOffset; i < byteLength; i += 1, s += 1) {[m
[32m+[m[32m            tmp[i] = array.buffer._bytes[s];[m
[32m+[m[32m          }[m
[32m+[m[32m          for (i = 0, d = byteOffset; i < byteLength; i += 1, d += 1) {[m
[32m+[m[32m            this.buffer._bytes[d] = tmp[i];[m
[32m+[m[32m          }[m
[32m+[m[32m        } else {[m
[32m+[m[32m          for (i = 0, s = array.byteOffset, d = byteOffset;[m
[32m+[m[32m               i < byteLength; i += 1, s += 1, d += 1) {[m
[32m+[m[32m            this.buffer._bytes[d] = array.buffer._bytes[s];[m
[32m+[m[32m          }[m
[32m+[m[32m        }[m
[32m+[m[32m      } else if (typeof arguments[0] === 'object' && typeof arguments[0].length !== 'undefined') {[m
[32m+[m[32m        // void set(sequence<type> array, optional unsigned long offset);[m
[32m+[m[32m        sequence = arguments[0];[m
[32m+[m[32m        len = ECMAScript.ToUint32(sequence.length);[m
[32m+[m[32m        offset = ECMAScript.ToUint32(arguments[1]);[m
[32m+[m
[32m+[m[32m        if (offset + len > this.length) {[m
[32m+[m[32m          throw new RangeError("Offset plus length of array is out of range");[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        for (i = 0; i < len; i += 1) {[m
[32m+[m[32m          s = sequence[i];[m
[32m+[m[32m          this._setter(offset + i, Number(s));[m
[32m+[m[32m        }[m
[32m+[m[32m      } else {[m
[32m+[m[32m        throw new TypeError("Unexpected argument type(s)");[m
[32m+[m[32m      }[m
[32m+[m[32m    };[m
[32m+[m
[32m+[m[32m    // TypedArray subarray(long begin, optional long end);[m
[32m+[m[32m    ctor.prototype.subarray = function(start, end) {[m
[32m+[m[32m      function clamp(v, min, max) { return v < min ? min : v > max ? max : v; }[m
[32m+[m
[32m+[m[32m      start = ECMAScript.ToInt32(start);[m
[32m+[m[32m      end = ECMAScript.ToInt32(end);[m
[32m+[m
[32m+[m[32m      if (arguments.length < 1) { start = 0; }[m
[32m+[m[32m      if (arguments.length < 2) { end = this.length; }[m
[32m+[m
[32m+[m[32m      if (start < 0) { start = this.length + start; }[m
[32m+[m[32m      if (end < 0) { end = this.length + end; }[m
[32m+[m
[32m+[m[32m      start = clamp(start, 0, this.length);[m
[32m+[m[32m      end = clamp(end, 0, this.length);[m
[32m+[m
[32m+[m[32m      var len = end - start;[m
[32m+[m[32m      if (len < 0) {[m
[32m+[m[32m        len = 0;[m
[32m+[m[32m      }[m
[32m+[m
[32m+[m[32m      return new this.constructor([m
[32m+[m[32m        this.buffer, this.byteOffset + start * this.BYTES_PER_ELEMENT, len);[m
[32m+[m[32m    };[m
[32m+[m
[32m+[m[32m    return ctor;[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  var Int8Array = makeConstructor(1, packI8, unpackI8);[m
[32m+[m[32m  var Uint8Array = makeConstructor(1, packU8, unpackU8);[m
[32m+[m[32m  var Uint8ClampedArray = makeConstructor(1, packU8Clamped, unpackU8);[m
[32m+[m[32m  var Int16Array = makeConstructor(2, packI16, unpackI16);[m
[32m+[m[32m  var Uint16Array = makeConstructor(2, packU16, unpackU16);[m
[32m+[m[32m  var Int32Array = makeConstructor(4, packI32, unpackI32);[m
[32m+[m[32m  var Uint32Array = makeConstructor(4, packU32, unpackU32);[m
[32m+[m[32m  var Float32Array = makeConstructor(4, packF32, unpackF32);[m
[32m+[m[32m  var Float64Array = makeConstructor(8, packF64, unpackF64);[m
[32m+[m
[32m+[m[32m  exports.Int8Array = exports.Int8Array || Int8Array;[m
[32m+[m[32m  exports.Uint8Array = exports.Uint8Array || Uint8Array;[m
[32m+[m[32m  exports.Uint8ClampedArray = exports.Uint8ClampedArray || Uint8ClampedArray;[m
[32m+[m[32m  exports.Int16Array = exports.Int16Array || Int16Array;[m
[32m+[m[32m  exports.Uint16Array = exports.Uint16Array || Uint16Array;[m
[32m+[m[32m  exports.Int32Array = exports.Int32Array || Int32Array;[m
[32m+[m[32m  exports.Uint32Array = exports.Uint32Array || Uint32Array;[m
[32m+[m[32m  exports.Float32Array = exports.Float32Array || Float32Array;[m
[32m+[m[32m  exports.Float64Array = exports.Float64Array || Float64Array;[m
[32m+[m[32m}());[m
[32m+[m
[32m+[m[32m//[m
[32m+[m[32m// 6 The DataView View Type[m
[32m+[m[32m//[m
[32m+[m
[32m+[m[32m(function() {[m
[32m+[m[32m  function r(array, index) {[m
[32m+[m[32m    return ECMAScript.IsCallable(array.get) ? array.get(index) : array[index];[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  var IS_BIG_ENDIAN = (function() {[m
[32m+[m[32m    var u16array = new(exports.Uint16Array)([0x1234]),[m
[32m+[m[32m        u8array = new(exports.Uint8Array)(u16array.buffer);[m
[32m+[m[32m    return r(u8array, 0) === 0x12;[m
[32m+[m[32m  }());[m
[32m+[m
[32m+[m[32m  // Constructor(ArrayBuffer buffer,[m
[32m+[m[32m  //             optional unsigned long byteOffset,[m
[32m+[m[32m  //             optional unsigned long byteLength)[m
[32m+[m[32m  /** @constructor */[m
[32m+[m[32m  var DataView = function DataView(buffer, byteOffset, byteLength) {[m
[32m+[m[32m    if (arguments.length === 0) {[m
[32m+[m[32m      buffer = new exports.ArrayBuffer(0);[m
[32m+[m[32m    } else if (!(buffer instanceof exports.ArrayBuffer || ECMAScript.Class(buffer) === 'ArrayBuffer')) {[m
[32m+[m[32m      throw new TypeError("TypeError");[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    this.buffer = buffer || new exports.ArrayBuffer(0);[m
[32m+[m
[32m+[m[32m    this.byteOffset = ECMAScript.ToUint32(byteOffset);[m
[32m+[m[32m    if (this.byteOffset > this.buffer.byteLength) {[m
[32m+[m[32m      throw new RangeError("byteOffset out of range");[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    if (arguments.length < 3) {[m
[32m+[m[32m      this.byteLength = this.buffer.byteLength - this.byteOffset;[m
[32m+[m[32m    } else {[m
[32m+[m[32m      this.byteLength = ECMAScript.ToUint32(byteLength);[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    if ((this.byteOffset + this.byteLength) > this.buffer.byteLength) {[m
[32m+[m[32m      throw new RangeError("byteOffset and length reference an area beyond the end of the buffer");[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    configureProperties(this);[m
[32m+[m[32m  };[m
[32m+[m
[32m+[m[32m  function makeGetter(arrayType) {[m
[32m+[m[32m    return function(byteOffset, littleEndian) {[m
[32m+[m
[32m+[m[32m      byteOffset = ECMAScript.ToUint32(byteOffset);[m
[32m+[m
[32m+[m[32m      if (byteOffset + arrayType.BYTES_PER_ELEMENT > this.byteLength) {[m
[32m+[m[32m        throw new RangeError("Array index out of range");[m
[32m+[m[32m      }[m
[32m+[m[32m      byteOffset += this.byteOffset;[m
[32m+[m
[32m+[m[32m      var uint8Array = new exports.Uint8Array(this.buffer, byteOffset, arrayType.BYTES_PER_ELEMENT),[m
[32m+[m[32m          bytes = [], i;[m
[32m+[m[32m      for (i = 0; i < arrayType.BYTES_PER_ELEMENT; i += 1) {[m
[32m+[m[32m        bytes.push(r(uint8Array, i));[m
[32m+[m[32m      }[m
[32m+[m
[32m+[m[32m      if (Boolean(littleEndian) === Boolean(IS_BIG_ENDIAN)) {[m
[32m+[m[32m        bytes.reverse();[m
[32m+[m[32m      }[m
[32m+[m
[32m+[m[32m      return r(new arrayType(new exports.Uint8Array(bytes).buffer), 0);[m
[32m+[m[32m    };[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  DataView.prototype.getUint8 = makeGetter(exports.Uint8Array);[m
[32m+[m[32m  DataView.prototype.getInt8 = makeGetter(exports.Int8Array);[m
[32m+[m[32m  DataView.prototype.getUint16 = makeGetter(exports.Uint16Array);[m
[32m+[m[32m  DataView.prototype.getInt16 = makeGetter(exports.Int16Array);[m
[32m+[m[32m  DataView.prototype.getUint32 = makeGetter(exports.Uint32Array);[m
[32m+[m[32m  DataView.prototype.getInt32 = makeGetter(exports.Int32Array);[m
[32m+[m[32m  DataView.prototype.getFloat32 = makeGetter(exports.Float32Array);[m
[32m+[m[32m  DataView.prototype.getFloat64 = makeGetter(exports.Float64Array);[m
[32m+[m
[32m+[m[32m  function makeSetter(arrayType) {[m
[32m+[m[32m    return function(byteOffset, value, littleEndian) {[m
[32m+[m
[32m+[m[32m      byteOffset = ECMAScript.ToUint32(byteOffset);[m
[32m+[m[32m      if (byteOffset + arrayType.BYTES_PER_ELEMENT > this.byteLength) {[m
[32m+[m[32m        throw new RangeError("Array index out of range");[m
[32m+[m[32m      }[m
[32m+[m
[32m+[m[32m      // Get bytes[m
[32m+[m[32m      var typeArray = new arrayType([value]),[m
[32m+[m[32m          byteArray = new exports.Uint8Array(typeArray.buffer),[m
[32m+[m[32m          bytes = [], i, byteView;[m
[32m+[m
[32m+[m[32m      for (i = 0; i < arrayType.BYTES_PER_ELEMENT; i += 1) {[m
[32m+[m[32m        bytes.push(r(byteArray, i));[m
[32m+[m[32m      }[m
[32m+[m
[32m+[m[32m      // Flip if necessary[m
[32m+[m[32m      if (Boolean(littleEndian) === Boolean(IS_BIG_ENDIAN)) {[m
[32m+[m[32m        bytes.reverse();[m
[32m+[m[32m      }[m
[32m+[m
[32m+[m[32m      // Write them[m
[32m+[m[32m      byteView = new exports.Uint8Array(this.buffer, byteOffset, arrayType.BYTES_PER_ELEMENT);[m
[32m+[m[32m      byteView.set(bytes);[m
[32m+[m[32m    };[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  DataView.prototype.setUint8 = makeSetter(exports.Uint8Array);[m
[32m+[m[32m  DataView.prototype.setInt8 = makeSetter(exports.Int8Array);[m
[32m+[m[32m  DataView.prototype.setUint16 = makeSetter(exports.Uint16Array);[m
[32m+[m[32m  DataView.prototype.setInt16 = makeSetter(exports.Int16Array);[m
[32m+[m[32m  DataView.prototype.setUint32 = makeSetter(exports.Uint32Array);[m
[32m+[m[32m  DataView.prototype.setInt32 = makeSetter(exports.Int32Array);[m
[32m+[m[32m  DataView.prototype.setFloat32 = makeSetter(exports.Float32Array);[m
[32m+[m[32m  DataView.prototype.setFloat64 = makeSetter(exports.Float64Array);[m
[32m+[m
[32m+[m[32m  exports.DataView = exports.DataView || DataView;[m
[32m+[m
[32m+[m[32m}());[m
[1mdiff --git a/node_modules/typedarray/package.json b/node_modules/typedarray/package.json[m
[1mnew file mode 100644[m
[1mindex 0000000..a7854a0[m
[1m--- /dev/null[m
[1m+++ b/node_modules/typedarray/package.json[m
[36m@@ -0,0 +1,55 @@[m
[32m+[m[32m{[m
[32m+[m[32m  "name": "typedarray",[m
[32m+[m[32m  "version": "0.0.6",[m
[32m+[m[32m  "description": "TypedArray polyfill for old browsers",[m
[32m+[m[32m  "main": "index.js",[m
[32m+[m[32m  "devDependencies": {[m
[32m+[m[32m    "tape": "~2.3.2"[m
[32m+[m[32m  },[m
[32m+[m[32m  "scripts": {[m
[32m+[m[32m    "test": "tape test/*.js test/server/*.js"[m
[32m+[m[32m  },[m
[32m+[m[32m  "repository": {[m
[32m+[m[32m    "type": "git",[m
[32m+[m[32m    "url": "git://github.com/substack/typedarray.git"[m
[32m+[m[32m  },[m
[32m+[m[32m  "homepage": "https://github.com/substack/typedarray",[m
[32m+[m[32m  "keywords": [[m
[32m+[m[32m    "ArrayBuffer",[m
[32m+[m[32m    "DataView",[m
[32m+[m[32m    "Float32Array",[m
[32m+[m[32m    "Float64Array",[m
[32m+[m[32m    "Int8Array",[m
[32m+[m[32m    "Int16Array",[m
[32m+[m[32m    "Int32Array",[m
[32m+[m[32m    "Uint8Array",[m
[32m+[m[32m    "Uint8ClampedArray",[m
[32m+[m[32m    "Uint16Array",[m
[32m+[m[32m    "Uint32Array",[m
[32m+[m[32m    "typed",[m
[32m+[m[32m    "array",[m
[32m+[m[32m    "polyfill"[m
[32m+[m[32m  ],[m
[32m+[m[32m  "author": {[m
[32m+[m[32m    "name": "James Halliday",[m
[32m+[m[32m    "email": "mail@substack.net",[m
[32m+[m[32m    "url": "http://substack.net"[m
[32m+[m[32m  },[m
[32m+[m[32m  "license": "MIT",[m
[32m+[m[32m  "testling": {[m
[32m+[m[32m    "files": "test/*.js",[m
[32m+[m[32m    "browsers": [[m
[32m+[m[32m      "ie/6..latest",[m
[32m+[m[32m      "firefox/16..latest",[m
[32m+[m[32m      "firefox/nightly",[m
[32m+[m[32m      "chrome/22..latest",[m
[32m+[m[32m      "chrome/canary",[m
[32m+[m[32m      "opera/12..latest",[m
[32m+[m[32m      "opera/next",[m
[32m+[m[32m      "safari/5.1..latest",[m
[32m+[m[32m      "ipad/6.0..latest",[m
[32m+[m[32m      "iphone/6.0..latest",[m
[32m+[m[32m      "android-browser/4.2..latest"[m
[32m+[m[32m    ][m
[32m+[m[32m  }[m
[32m+[m[32m}[m
[1mdiff --git a/node_modules/typedarray/readme.markdown b/node_modules/typedarray/readme.markdown[m
[1mnew file mode 100644[m
[1mindex 0000000..d18f6f7[m
[1m--- /dev/null[m
[1m+++ b/node_modules/typedarray/readme.markdown[m
[36m@@ -0,0 +1,61 @@[m
[32m+[m[32m# typedarray[m
[32m+[m
[32m+[m[32mTypedArray polyfill ripped from [this[m
[32m+[m[32mmodule](https://raw.github.com/inexorabletash/polyfill).[m
[32m+[m
[32m+[m[32m[![build status](https://secure.travis-ci.org/substack/typedarray.png)](http://travis-ci.org/substack/typedarray)[m
[32m+[m
[32m+[m[32m[![testling badge](https://ci.testling.com/substack/typedarray.png)](https://ci.testling.com/substack/typedarray)[m
[32m+[m
[32m+[m[32m# example[m
[32m+[m
[32m+[m[32m``` js[m
[32m+[m[32mvar Uint8Array = require('typedarray').Uint8Array;[m
[32m+[m[32mvar ua = new Uint8Array(5);[m
[32m+[m[32mua[1] = 256 + 55;[m
[32m+[m[32mconsole.log(ua[1]);[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32moutput:[m
[32m+[m
[32m+[m[32m```[m
[32m+[m[32m55[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32m# methods[m
[32m+[m
[32m+[m[32m``` js[m
[32m+[m[32mvar TA = require('typedarray')[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32mThe `TA` object has the following constructors:[m
[32m+[m
[32m+[m[32m* TA.ArrayBuffer[m
[32m+[m[32m* TA.DataView[m
[32m+[m[32m* TA.Float32Array[m
[32m+[m[32m* TA.Float64Array[m
[32m+[m[32m* TA.Int8Array[m
[32m+[m[32m* TA.Int16Array[m
[32m+[m[32m* TA.Int32Array[m
[32m+[m[32m* TA.Uint8Array[m
[32m+[m[32m* TA.Uint8ClampedArray[m
[32m+[m[32m* TA.Uint16Array[m
[32m+[m[32m* TA.Uint32Array[m
[32m+[m
[32m+[m[32m# install[m
[32m+[m
[32m+[m[32mWith [npm](https://npmjs.org) do:[m
[32m+[m
[32m+[m[32m```[m
[32m+[m[32mnpm install typedarray[m
[32m+[m[32m```[m
[32m+[m
[32m+[m[32mTo use this module in the browser, compile with[m
[32m+[m[32m[browserify](http://browserify.org)[m
[32m+[m[32mor download a UMD build from browserify CDN:[m
[32m+[m
[32m+[m[32mhttp://wzrd.in/standalone/typedarray@latest[m
[32m+[m
[32m+[m[32m# license[m
[32m+[m
[32m+[m[32mMIT[m
[1mdiff --git a/node_modules/typedarray/test/server/undef_globals.js b/node_modules/typedarray/test/server/undef_globals.js[m
[1mnew file mode 100644[m
[1mindex 0000000..425950f[m
[1m--- /dev/null[m
[1m+++ b/node_modules/typedarray/test/server/undef_globals.js[m
[36m@@ -0,0 +1,19 @@[m
[32m+[m[32mvar test = require('tape');[m
[32m+[m[32mvar vm = require('vm');[m
[32m+[m[32mvar fs = require('fs');[m
[32m+[m[32mvar src = fs.readFileSync(__dirname + '/../../index.js', 'utf8');[m
[32m+[m
[32m+[m[32mtest('u8a without globals', function (t) {[m
[32m+[m[32m    var c = {[m
[32m+[m[32m        module: { exports: {} },[m
[32m+[m[32m    };[m
[32m+[m[32m    c.exports = c.module.exports;[m
[32m+[m[32m    vm.runInNewContext(src, c);[m
[32m+[m[32m    var TA = c.module.exports;[m
[32m+[m[32m    var ua = new(TA.Uint8Array)(5);[m
[32m+[m[41m    [m
[32m+[m[32m    t.equal(ua.length, 5);[m
[32m+[m[32m    ua[1] = 256 + 55;[m
[32m+[m[32m    t.equal(ua[1], 55);[m
[32m+[m[32m    t.end();[m
[32m+[m[32m});[m
[1mdiff --git a/node_modules/typedarray/test/tarray.js b/node_modules/typedarray/test/tarray.js[m
[1mnew file mode 100644[m
[1mindex 0000000..df596a3[m
[1m--- /dev/null[m
[1m+++ b/node_modules/typedarray/test/tarray.js[m
[36m@@ -0,0 +1,10 @@[m
[32m+[m[32mvar TA = require('../');[m
[32m+[m[32mvar test = require('tape');[m
[32m+[m
[32m+[m[32mtest('tiny u8a test', function (t) {[m
[32m+[m[32m    var ua = new(TA.Uint8Array)(5);[m
[32m+[m[32m    t.equal(ua.length, 5);[m
[32m+[m[32m    ua[1] = 256 + 55;[m
[32m+[m[32m    t.equal(ua[1], 55);[m
[32m+[m[32m    t.end();[m
[32m+[m[32m});[m
[1mdiff --git a/node_modules/util-deprecate/History.md b/node_modules/util-deprecate/History.md[m
[1mnew file mode 100644[m
[1mindex 0000000..acc8675[m
[1m--- /dev/null[m
[1m+++ b/node_modules/util-deprecate/History.md[m
[36m@@ -0,0 +1,16 @@[m
[32m+[m
[32m+[m[32m1.0.2 / 2015-10-07[m
[32m+[m[32m==================[m
[32m+[m
[32m+[m[32m  * use try/catch when checking `localStorage` (#3, @kumavis)[m
[32m+[m
[32m+[m[32m1.0.1 / 2014-11-25[m
[32m+[m[32m==================[m
[32m+[m
[32m+[m[32m  * browser: use `console.warn()` for deprecation calls[m
[32m+[m[32m  * browser: more jsdocs[m
[32m+[m
[32m+[m[32m1.0.0 / 2014-04-30[m
[32m+[m[32m==================[m
[32m+[m
[32m+[m[32m  * initial commit[m
[1mdiff --git a/node_modules/util-deprecate/LICENSE b/node_modules/util-deprecate/LICENSE[m
[1mnew file mode 100644[m
[1mindex 0000000..6a60e8c[m
[1m--- /dev/null[m
[1m+++ b/node_modules/util-deprecate/LICENSE[m
[36m@@ -0,0 +1,24 @@[m
[32m+[m[32m(The MIT License)[m
[32m+[m
[32m+[m[32mCopyright (c) 2014 Nathan Rajlich <nathan@tootallnate.net>[m
[32m+[m
[32m+[m[32mPermission is hereby granted, free of charge, to any person[m
[32m+[m[32mobtaining a copy of this software and associated documentation[m
[32m+[m[32mfiles (the "Software"), to deal in the Software without[m
[32m+[m[32mrestriction, including without limitation the rights to use,[m
[32m+[m[32mcopy, modify, merge, publish, distribute, sublicense, and/or sell[m
[32m+[m[32mcopies of the Software, and to permit persons to whom the[m
[32m+[m[32mSoftware is furnished to do so, subject to the following[m
[32m+[m[32mconditions:[m
[32m+[m
[32m+[m[32mThe above copyright notice and this permission notice shall be[m
[32m+[m[32mincluded in all copies or substantial portions of the Software.[m
[32m+[m
[32m+[m[32mTHE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,[m
[32m+[m[32mEXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES[m
[32m+[m[32mOF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND[m
[32m+[m[32mNONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT[m
[32m+[m[32mHOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,[m
[32m+[m[32mWHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING[m
[32m+[m[32mFROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR[m
[32m+[m[32mOTHER DEALINGS IN THE SOFTWARE.[m
[1mdiff --git a/node_modules/util-deprecate/README.md b/node_modules/util-deprecate/README.md[m
[1mnew file mode 100644[m
[1mindex 0000000..75622fa[m
[1m--- /dev/null[m
[1m+++ b/node_modules/util-deprecate/README.md[m
[36m@@ -0,0 +1,53 @@[m
[32m+[m[32mutil-deprecate[m
[32m+[m[32m==============[m
[32m+[m[32m### The Node.js `util.deprecate()` function with browser support[m
[32m+[m
[32m+[m[32mIn Node.js, this module simply re-exports the `util.deprecate()` function.[m
[32m+[m
[32m+[m[32mIn the web browser (i.e. via browserify), a browser-specific implementation[m
[32m+[m[32mof the `util.deprecate()` function is used.[m
[32m+[m
[32m+[m
[32m+[m[32m## API[m
[32m+[m
[32m+[m[32mA `deprecate()` function is the only thing exposed by this module.[m
[32m+[m
[32m+[m[32m``` javascript[m
[32m+[m[32m// setup:[m
[32m+[m[32mexports.foo = deprecate(foo, 'foo() is deprecated, use bar() instead');[m
[32m+[m
[32m+[m
[32m+[m[32m// users see:[m
[32m+[m[32mfoo();[m
[32m+[m[32m// foo() is deprecated, use bar() instead[m
[32m+[m[32mfoo();[m
[32m+[m[32mfoo();[m
[32m+[m[32m```[m
[32m+[m
[32m+[m
[32m+[m[32m## License[m
[32m+[m
[32m+[m[32m(The MIT License)[m
[32m+[m
[32m+[m[32mCopyright (c) 2014 Nathan Rajlich <nathan@tootallnate.net>[m
[32m+[m
[32m+[m[32mPermission is hereby granted, free of charge, to any person[m
[32m+[m[32mobtaining a copy of this software and associated documentation[m
[32m+[m[32mfiles (the "Software"), to deal in the Software without[m
[32m+[m[32mrestriction, including without limitation the rights to use,[m
[32m+[m[32mcopy, modify, merge, publish, distribute, sublicense, and/or sell[m
[32m+[m[32mcopies of the Software, and to permit persons to whom the[m
[32m+[m[32mSoftware is furnished to do so, subject to the following[m
[32m+[m[32mconditions:[m
[32m+[m
[32m+[m[32mThe above copyright notice and this permission notice shall be[m
[32m+[m[32mincluded in all copies or substantial portions of the Software.[m
[32m+[m
[32m+[m[32mTHE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,[m
[32m+[m[32mEXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES[m
[32m+[m[32mOF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND[m
[32m+[m[32mNONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT[m
[32m+[m[32mHOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,[m
[32m+[m[32mWHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING[m
[32m+[m[32mFROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR[m
[32m+[m[32mOTHER DEALINGS IN THE SOFTWARE.[m
[1mdiff --git a/node_modules/util-deprecate/browser.js b/node_modules/util-deprecate/browser.js[m
[1mnew file mode 100644[m
[1mindex 0000000..549ae2f[m
[1m--- /dev/null[m
[1m+++ b/node_modules/util-deprecate/browser.js[m
[36m@@ -0,0 +1,67 @@[m
[32m+[m
[32m+[m[32m/**[m
[32m+[m[32m * Module exports.[m
[32m+[m[32m */[m
[32m+[m
[32m+[m[32mmodule.exports = deprecate;[m
[32m+[m
[32m+[m[32m/**[m
[32m+[m[32m * Mark that a method should not be used.[m
[32m+[m[32m * Returns a modified function which warns once by default.[m
[32m+[m[32m *[m
[32m+[m[32m * If `localStorage.noDeprecation = true` is set, then it is a no-op.[m
[32m+[m[32m *[m
[32m+[m[32m * If `localStorage.throwDeprecation = true` is set, then deprecated functions[m
[32m+[m[32m * will throw an Error when invoked.[m
[32m+[m[32m *[m
[32m+[m[32m * If `localStorage.traceDeprecation = true` is set, then deprecated functions[m
[32m+[m[32m * will invoke `console.trace()` instead of `console.error()`.[m
[32m+[m[32m *[m
[32m+[m[32m * @param {Function} fn - the function to deprecate[m
[32m+[m[32m * @param {String} msg - the string to print to the console when `fn` is invoked[m
[32m+[m[32m * @returns {Function} a new "deprecated" version of `fn`[m
[32m+[m[32m * @api public[m
[32m+[m[32m */[m
[32m+[m
[32m+[m[32mfunction deprecate (fn, msg) {[m
[32m+[m[32m  if (config('noDeprecation')) {[m
[32m+[m[32m    return fn;[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  var warned = false;[m
[32m+[m[32m  function deprecated() {[m
[32m+[m[32m    if (!warned) {[m
[32m+[m[32m      if (config('throwDeprecation')) {[m
[32m+[m[32m        throw new Error(msg);[m
[32m+[m[32m      } else if (config('traceDeprecation')) {[m
[32m+[m[32m        console.trace(msg);[m
[32m+[m[32m      } else {[m
[32m+[m[32m        console.warn(msg);[m
[32m+[m[32m      }[m
[32m+[m[32m      warned = true;[m
[32m+[m[32m    }[m
[32m+[m[32m    return fn.apply(this, arguments);[m
[32m+[m[32m  }[m
[32m+[m
[32m+[m[32m  return deprecated;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m/**[m
[32m+[m[32m * Checks `localStorage` for boolean values for the given `name`.[m
[32m+[m[32m *[m
[32m+[m[32m * @param {String} name[m
[32m+[m[32m * @returns {Boolean}[m
[32m+[m[32m * @api private[m
[32m+[m[32m */[m
[32m+[m
[32m+[m[32mfunction config (name) {[m
[32m+[m[32m  // accessing global.localStorage can trigger a DOMException in sandboxed iframes[m
[32m+[m[32m  try {[m
[32m+[m[32m    if (!global.localStorage) return false;[m
[32m+[m[32m  } catch (_) {[m
[32m+[m[32m    return false;[m
[32m+[m[32m  }[m
[32m+[m[32m  var val = global.localStorage[name];[m
[32m+[m[32m  if (null == val) return false;[m
[32m+[m[32m  return String(val).toLowerCase() === 'true';[m
[32m+[m[32m}[m
[1mdiff --git a/node_modules/util-deprecate/node.js b/node_modules/util-deprecate/node.js[m
[1mnew file mode 100644[m
[1mindex 0000000..5e6fcff[m
[1m--- /dev/null[m
[1m+++ b/node_modules/util-deprecate/node.js[m
[36m@@ -0,0 +1,6 @@[m
[32m+[m
[32m+[m[32m/**[m
[32m+[m[32m * For Node.js, simply re-export the core `util.deprecate` function.[m
[32m+[m[32m */[m
[32m+[m
[32m+[m[32mmodule.exports = require('util').deprecate;[m
[1mdiff --git a/node_modules/util-deprecate/package.json b/node_modules/util-deprecate/package.json[m
[1mnew file mode 100644[m
[1mindex 0000000..2e79f89[m
[1m--- /dev/null[m
[1m+++ b/node_modules/util-deprecate/package.json[m
[36m@@ -0,0 +1,27 @@[m
[32m+[m[32m{[m
[32m+[m[32m  "name": "util-deprecate",[m
[32m+[m[32m  "version": "1.0.2",[m
[32m+[m[32m  "description": "The Node.js `util.deprecate()` function with browser support",[m
[32m+[m[32m  "main": "node.js",[m
[32m+[m[32m  "browser": "browser.js",[m
[32m+[m[32m  "scripts": {[m
[32m+[m[32m    "test": "echo \"Error: no test specified\" && exit 1"[m
[32m+[m[32m  },[m
[32m+[m[32m  "repository": {[m
[32m+[m[32m    "type": "git",[m
[32m+[m[32m    "url": "git://github.com/TooTallNate/util-deprecate.git"[m
[32m+[m[32m  },[m
[32m+[m[32m  "keywords": [[m
[32m+[m[32m    "util",[m
[32m+[m[32m    "deprecate",[m
[32m+[m[32m    "browserify",[m
[32m+[m[32m    "browser",[m
[32m+[m[32m    "node"[m
[32m+[m[32m  ],[m
[32m+[m[32m  "author": "Nathan Rajlich <nathan@tootallnate.net> (http://n8.io/)",[m
[32m+[m[32m  "license": "MIT",[m
[32m+[m[32m  "bugs": {[m
[32m+[m[32m    "url": "https://github.com/TooTallNate/util-deprecate/issues"[m
[32m+[m[32m  },[m
[32m+[m[32m  "homepage": "https://github.com/TooTallNate/util-deprecate"[m
[32m+[m[32m}[m
[1mdiff --git a/package-lock.json b/package-lock.json[m
[1mindex 809a9f7..109824f 100644[m
[1m--- a/package-lock.json[m
[1m+++ b/package-lock.json[m
[36m@@ -15,6 +15,7 @@[m
         "dotenv": "^16.4.5",[m
         "express": "^4.21.0",[m
         "jsonwebtoken": "^9.0.2",[m
[32m+[m[32m        "multer": "^1.4.5-lts.1",[m
         "pg": "^8.13.0",[m
         "pg-hstore": "^2.3.4",[m
         "sequelize": "^6.37.3"[m
[36m@@ -80,6 +81,12 @@[m
         "node": ">= 8"[m
       }[m
     },[m
[32m+[m[32m    "node_modules/append-field": {[m
[32m+[m[32m      "version": "1.0.0",[m
[32m+[m[32m      "resolved": "https://registry.npmjs.org/append-field/-/append-field-1.0.0.tgz",[m
[32m+[m[32m      "integrity": "sha512-klpgFSWLW1ZEs8svjfb7g4qWY0YS5imI82dTg+QahUvJ8YqAY0P10Uk8tTyh9ZGuYEZEMaeJYCF5BFuX552hsw==",[m
[32m+[m[32m      "license": "MIT"[m
[32m+[m[32m    },[m
     "node_modules/array-flatten": {[m
       "version": "1.1.1",[m
       "resolved": "https://registry.npmjs.org/array-flatten/-/array-flatten-1.1.1.tgz",[m
[36m@@ -166,6 +173,23 @@[m
       "integrity": "sha512-zRpUiDwd/xk6ADqPMATG8vc9VPrkck7T07OIx0gnjmJAnHnTVXNQG3vfvWNuiZIkwu9KrKdA1iJKfsfTVxE6NA==",[m
       "license": "BSD-3-Clause"[m
     },[m
[32m+[m[32m    "node_modules/buffer-from": {[m
[32m+[m[32m      "version": "1.1.2",[m
[32m+[m[32m      "resolved": "https://registry.npmjs.org/buffer-from/-/buffer-from-1.1.2.tgz",[m
[32m+[m[32m      "integrity": "sha512-E+XQCRwSbaaiChtv6k6Dwgc+bx+Bs6vuKJHHl5kox/BaKbhiXzqQOwK4cO22yElGp2OCmjwVhT3HmxgyPGnJfQ==",[m
[32m+[m[32m      "license": "MIT"[m
[32m+[m[32m    },[m
[32m+[m[32m    "node_modules/busboy": {[m
[32m+[m[32m      "version": "1.6.0",[m
[32m+[m[32m      "resolved": "https://registry.npmjs.org/busboy/-/busboy-1.6.0.tgz",[m
[32m+[m[32m      "integrity": "sha512-8SFQbg/0hQ9xy3UNTB0YEnsNBbWfhf7RtnzpL7TkBiTBRfrQ9Fxcnz7VJsleJpyp6rVLvXiuORqjlHi5q+PYuA==",[m
[32m+[m[32m      "dependencies": {[m
[32m+[m[32m        "streamsearch": "^1.1.0"[m
[32m+[m[32m      },[m
[32m+[m[32m      "engines": {[m
[32m+[m[32m        "node": ">=10.16.0"[m
[32m+[m[32m      }[m
[32m+[m[32m    },[m
     "node_modules/bytes": {[m
       "version": "3.1.2",[m
       "resolved": "https://registry.npmjs.org/bytes/-/bytes-3.1.2.tgz",[m
[36m@@ -226,6 +250,21 @@[m
       "dev": true,[m
       "license": "MIT"[m
     },[m
[32m+[m[32m    "node_modules/concat-stream": {[m
[32m+[m[32m      "version": "1.6.2",[m
[32m+[m[32m      "resolved": "https://registry.npmjs.org/concat-stream/-/concat-stream-1.6.2.tgz",[m
[32m+[m[32m      "integrity": "sha512-27HBghJxjiZtIk3Ycvn/4kbJk/1uZuJFfuPEns6LaEvpvG1f0hTea8lilrouyo9mVc2GWdcEZ8OLoGmSADlrCw==",[m
[32m+[m[32m      "engines": [[m
[32m+[m[32m        "node >= 0.8"[m
[32m+[m[32m      ],[m
[32m+[m[32m      "license": "MIT",[m
[32m+[m[32m      "dependencies": {[m
[32m+[m[32m        "buffer-from": "^1.0.0",[m
[32m+[m[32m        "inherits": "^2.0.3",[m
[32m+[m[32m        "readable-stream": "^2.2.2",[m
[32m+[m[32m        "typedarray": "^0.0.6"[m
[32m+[m[32m      }[m
[32m+[m[32m    },[m
     "node_modules/content-disposition": {[m
       "version": "0.5.4",[m
       "resolved": "https://registry.npmjs.org/content-disposition/-/content-disposition-0.5.4.tgz",[m
[36m@@ -262,6 +301,12 @@[m
       "integrity": "sha512-QADzlaHc8icV8I7vbaJXJwod9HWYp8uCqf1xa4OfNu1T7JVxQIrUgOWtHdNDtPiywmFbiS12VjotIXLrKM3orQ==",[m
       "license": "MIT"[m
     },[m
[32m+[m[32m    "node_modules/core-util-is": {[m
[32m+[m[32m      "version": "1.0.3",[m
[32m+[m[32m      "resolved": "https://registry.npmjs.org/core-util-is/-/core-util-is-1.0.3.tgz",[m
[32m+[m[32m      "integrity": "sha512-ZQBvi1DcpJ4GDqanjucZ2Hj3wEO5pZDS89BWbkcrvdxksJorwUDDZamX9ldFkp9aw2lmBDLgkObEA4DWNJ9FYQ==",[m
[32m+[m[32m      "license": "MIT"[m
[32m+[m[32m    },[m
     "node_modules/cors": {[m
       "version": "2.8.5",[m
       "resolved": "https://registry.npmjs.org/cors/-/cors-2.8.5.tgz",[m
[36m@@ -720,6 +765,12 @@[m
         "node": ">=0.12.0"[m
       }[m
     },[m
[32m+[m[32m    "node_modules/isarray": {[m
[32m+[m[32m      "version": "1.0.0",[m
[32m+[m[32m      "resolved": "https://registry.npmjs.org/isarray/-/isarray-1.0.0.tgz",[m
[32m+[m[32m      "integrity": "sha512-VLghIWNM6ELQzo7zwmcg0NmTVyWKYjvIeM83yjp0wRDTmUnrM678fQbcKBo6n2CJEF0szoG//ytg+TKla89ALQ==",[m
[32m+[m[32m      "license": "MIT"[m
[32m+[m[32m    },[m
     "node_modules/jsonwebtoken": {[m
       "version": "9.0.2",[m
       "resolved": "https://registry.npmjs.org/jsonwebtoken/-/jsonwebtoken-9.0.2.tgz",[m
[36m@@ -890,6 +941,27 @@[m
         "node": "*"[m
       }[m
     },[m
[32m+[m[32m    "node_modules/minimist": {[m
[32m+[m[32m      "version": "1.2.8",[m
[32m+[m[32m      "resolved": "https://registry.npmjs.org/minimist/-/minimist-1.2.8.tgz",[m
[32m+[m[32m      "integrity": "sha512-2yyAR8qBkN3YuheJanUpWC5U3bb5osDywNB8RzDVlDwDHbocAJveqqj1u8+SVD7jkWT4yvsHCpWqqWqAxb0zCA==",[m
[32m+[m[32m      "license": "MIT",[m
[32m+[m[32m      "funding": {[m
[32m+[m[32m        "url": "https://github.com/sponsors/ljharb"[m
[32m+[m[32m      }[m
[32m+[m[32m    },[m
[32m+[m[32m    "node_modules/mkdirp": {[m
[32m+[m[32m      "version": "0.5.6",[m
[32m+[m[32m      "resolved": "https://registry.npmjs.org/mkdirp/-/mkdirp-0.5.6.tgz",[m
[32m+[m[32m      "integrity": "sha512-FP+p8RB8OWpF3YZBCrP5gtADmtXApB5AMLn+vdyA+PyxCjrCs00mjyUozssO33cwDeT3wNGdLxJ5M//YqtHAJw==",[m
[32m+[m[32m      "license": "MIT",[m
[32m+[m[32m      "dependencies": {[m
[32m+[m[32m        "minimist": "^1.2.6"[m
[32m+[m[32m      },[m
[32m+[m[32m      "bin": {[m
[32m+[m[32m        "mkdirp": "bin/cmd.js"[m
[32m+[m[32m      }[m
[32m+[m[32m    },[m
     "node_modules/moment": {[m
       "version": "2.30.1",[m
       "resolved": "https://registry.npmjs.org/moment/-/moment-2.30.1.tgz",[m
[36m@@ -917,6 +989,24 @@[m
       "integrity": "sha512-Tpp60P6IUJDTuOq/5Z8cdskzJujfwqfOTkrwIwj7IRISpnkJnT6SyJ4PCPnGMoFjC9ddhal5KVIYtAt97ix05A==",[m
       "license": "MIT"[m
     },[m
[32m+[m[32m    "node_modules/multer": {[m
[32m+[m[32m      "version": "1.4.5-lts.1",[m
[32m+[m[32m      "resolved": "https://registry.npmjs.org/multer/-/multer-1.4.5-lts.1.tgz",[m
[32m+[m[32m      "integrity": "sha512-ywPWvcDMeH+z9gQq5qYHCCy+ethsk4goepZ45GLD63fOu0YcNecQxi64nDs3qluZB+murG3/D4dJ7+dGctcCQQ==",[m
[32m+[m[32m      "license": "MIT",[m
[32m+[m[32m      "dependencies": {[m
[32m+[m[32m        "append-field": "^1.0.0",[m
[32m+[m[32m        "busboy": "^1.0.0",[m
[32m+[m[32m        "concat-stream": "^1.5.2",[m
[32m+[m[32m        "mkdirp": "^0.5.4",[m
[32m+[m[32m        "object-assign": "^4.1.1",[m
[32m+[m[32m        "type-is": "^1.6.4",[m
[32m+[m[32m        "xtend": "^4.0.0"[m
[32m+[m[32m      },[m
[32m+[m[32m      "engines": {[m
[32m+[m[32m        "node": ">= 6.0.0"[m
[32m+[m[32m      }[m
[32m+[m[32m    },[m
     "node_modules/negotiator": {[m
       "version": "0.6.3",[m
       "resolved": "https://registry.npmjs.org/negotiator/-/negotiator-0.6.3.tgz",[m
[36m@@ -1191,6 +1281,12 @@[m
         "node": ">=0.10.0"[m
       }[m
     },[m
[32m+[m[32m    "node_modules/process-nextick-args": {[m
[32m+[m[32m      "version": "2.0.1",[m
[32m+[m[32m      "resolved": "https://registry.npmjs.org/process-nextick-args/-/process-nextick-args-2.0.1.tgz",[m
[32m+[m[32m      "integrity": "sha512-3ouUOpQhtgrbOa17J7+uxOTpITYWaGP7/AhoR3+A+/1e9skrzelGi/dXzEYyvbxubEF6Wn2ypscTKiKJFFn1ag==",[m
[32m+[m[32m      "license": "MIT"[m
[32m+[m[32m    },[m
     "node_modules/proxy-addr": {[m
       "version": "2.0.7",[m
       "resolved": "https://registry.npmjs.org/proxy-addr/-/proxy-addr-2.0.7.tgz",[m
[36m@@ -1250,6 +1346,27 @@[m
         "node": ">= 0.8"[m
       }[m
     },[m
[32m+[m[32m    "node_modules/readable-stream": {[m
[32m+[m[32m      "version": "2.3.8",[m
[32m+[m[32m      "resolved": "https://registry.npmjs.org/readable-stream/-/readable-stream-2.3.8.tgz",[m
[32m+[m[32m      "integrity": "sha512-8p0AUk4XODgIewSi0l8Epjs+EVnWiK7NoDIEGU0HhE7+ZyY8D1IMY7odu5lRrFXGg71L15KG8QrPmum45RTtdA==",[m
[32m+[m[32m      "license": "MIT",[m
[32m+[m[32m      "dependencies": {[m
[32m+[m[32m        "core-util-is": "~1.0.0",[m
[32m+[m[32m        "inherits": "~2.0.3",[m
[32m+[m[32m        "isarray": "~1.0.0",[m
[32m+[m[32m        "process-nextick-args": "~2.0.0",[m
[32m+[m[32m        "safe-buffer": "~5.1.1",[m
[32m+[m[32m        "string_decoder": "~1.1.1",[m
[32m+[m[32m        "util-deprecate": "~1.0.1"[m
[32m+[m[32m      }[m
[32m+[m[32m    },[m
[32m+[m[32m    "node_modules/readable-stream/node_modules/safe-buffer": {[m
[32m+[m[32m      "version": "5.1.2",[m
[32m+[m[32m      "resolved": "https://registry.npmjs.org/safe-buffer/-/safe-buffer-5.1.2.tgz",[m
[32m+[m[32m      "integrity": "sha512-Gd2UZBJDkXlY7GbJxfsE8/nvKkUEU1G38c1siN6QP6a9PT9MmHB8GnpscSmMJSoF8LOIrt8ud/wPtojys4G6+g==",[m
[32m+[m[32m      "license": "MIT"[m
[32m+[m[32m    },[m
     "node_modules/readdirp": {[m
       "version": "3.6.0",[m
       "resolved": "https://registry.npmjs.org/readdirp/-/readdirp-3.6.0.tgz",[m
[36m@@ -1527,6 +1644,29 @@[m
         "node": ">= 0.8"[m
       }[m
     },[m
[32m+[m[32m    "node_modules/streamsearch": {[m
[32m+[m[32m      "version": "1.1.0",[m
[32m+[m[32m      "resolved": "https://registry.npmjs.org/streamsearch/-/streamsearch-1.1.0.tgz",[m
[32m+[m[32m      "integrity": "sha512-Mcc5wHehp9aXz1ax6bZUyY5afg9u2rv5cqQI3mRrYkGC8rW2hM02jWuwjtL++LS5qinSyhj2QfLyNsuc+VsExg==",[m
[32m+[m[32m      "engines": {[m
[32m+[m[32m        "node": ">=10.0.0"[m
[32m+[m[32m      }[m
[32m+[m[32m    },[m
[32m+[m[32m    "node_modules/string_decoder": {[m
[32m+[m[32m      "version": "1.1.1",[m
[32m+[m[32m      "resolved": "https://registry.npmjs.org/string_decoder/-/string_decoder-1.1.1.tgz",[m
[32m+[m[32m      "integrity": "sha512-n/ShnvDi6FHbbVfviro+WojiFzv+s8MPMHBczVePfUpDJLwoLT0ht1l4YwBCbi8pJAveEEdnkHyPyTP/mzRfwg==",[m
[32m+[m[32m      "license": "MIT",[m
[32m+[m[32m      "dependencies": {[m
[32m+[m[32m        "safe-buffer": "~5.1.0"[m
[32m+[m[32m      }[m
[32m+[m[32m    },[m
[32m+[m[32m    "node_modules/string_decoder/node_modules/safe-buffer": {[m
[32m+[m[32m      "version": "5.1.2",[m
[32m+[m[32m      "resolved": "https://registry.npmjs.org/safe-buffer/-/safe-buffer-5.1.2.tgz",[m
[32m+[m[32m      "integrity": "sha512-Gd2UZBJDkXlY7GbJxfsE8/nvKkUEU1G38c1siN6QP6a9PT9MmHB8GnpscSmMJSoF8LOIrt8ud/wPtojys4G6+g==",[m
[32m+[m[32m      "license": "MIT"[m
[32m+[m[32m    },[m
     "node_modules/supports-color": {[m
       "version": "5.5.0",[m
       "resolved": "https://registry.npmjs.org/supports-color/-/supports-color-5.5.0.tgz",[m
[36m@@ -1591,6 +1731,12 @@[m
         "node": ">= 0.6"[m
       }[m
     },[m
[32m+[m[32m    "node_modules/typedarray": {[m
[32m+[m[32m      "version": "0.0.6",[m
[32m+[m[32m      "resolved": "https://registry.npmjs.org/typedarray/-/typedarray-0.0.6.tgz",[m
[32m+[m[32m      "integrity": "sha512-/aCDEGatGvZ2BIk+HmLf4ifCJFwvKFNb9/JeZPMulfgFracn9QFcAf5GO8B/mweUjSoblS5In0cWhqpfs/5PQA==",[m
[32m+[m[32m      "license": "MIT"[m
[32m+[m[32m    },[m
     "node_modules/undefsafe": {[m
       "version": "2.0.5",[m
       "resolved": "https://registry.npmjs.org/undefsafe/-/undefsafe-2.0.5.tgz",[m
[36m@@ -1619,6 +1765,12 @@[m
         "node": ">= 0.8"[m
       }[m
     },[m
[32m+[m[32m    "node_modules/util-deprecate": {[m
[32m+[m[32m      "version": "1.0.2",[m
[32m+[m[32m      "resolved": "https://registry.npmjs.org/util-deprecate/-/util-deprecate-1.0.2.tgz",[m
[32m+[m[32m      "integrity": "sha512-EPD5q1uXyFxJpCrLnCc1nHnq3gOa6DZBocAIiI2TaSCA7VCJ1UJDMagCzIkXNsUYfD1daK//LTEQ8xiIbrHtcw==",[m
[32m+[m[32m      "license": "MIT"[m
[32m+[m[32m    },[m
     "node_modules/utils-merge": {[m
       "version": "1.0.1",[m
       "resolved": "https://registry.npmjs.org/utils-merge/-/utils-merge-1.0.1.tgz",[m
[1mdiff --git a/package.json b/package.json[m
[1mindex 4cdd7e1..b1bbd6e 100644[m
[1m--- a/package.json[m
[1m+++ b/package.json[m
[36m@@ -17,6 +17,7 @@[m
     "dotenv": "^16.4.5",[m
     "express": "^4.21.0",[m
     "jsonwebtoken": "^9.0.2",[m
[32m+[m[32m    "multer": "^1.4.5-lts.1",[m
     "pg": "^8.13.0",[m
     "pg-hstore": "^2.3.4",[m
     "sequelize": "^6.37.3"[m
