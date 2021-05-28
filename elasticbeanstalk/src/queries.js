var promise = require('bluebird');

var options = {
  // Initialization Options
  promiseLib: promise
};

const databaseConfig= {
  "host": process.env.RDS_HOSTNAME,
  "port": 5432,
  "database": process.env.RDS_DATABASE,
  "user": process.env.RDS_USERNAME,
  "password": process.env.RDS_PASSWORD
};

var pgp = require('pg-promise')(options);
//var connectionString = 'postgres://localhost:5432/testdb';
var db = pgp(databaseConfig);

function getAllUsers(req, res, next) {
  db.any('select PGP_SYM_DECRYPT(name::bytea, \'ENCRYPTION_AES_KEY\') as name,PGP_SYM_DECRYPT(ssn::bytea,  \'ENCRYPTION_AES_KEY\') as ssn from table1')
    .then(function (data) {
      res.status(200)
        .json({
          status: 'success',
          data: data,
          message: 'Retrieved ALL users'
        });
    })
    .catch(function (err) {
      return next("Faied to execute DB Query");
    });
}

function getSingleUser(req, res, next) {
  var userID = parseInt(req.params.id);
  db.one('select PGP_SYM_DECRYPT(name::bytea,  \'ENCRYPTION_AES_KEY\') as name,PGP_SYM_DECRYPT(ssn::bytea,  \'ENCRYPTION_AES_KEY\') as ssn from table1 where id = $1', userID)
    .then(function (data) {
      res.status(200)
        .json({
          status: 'success',
          data: data,
          message: 'Retrieved Single User'
        });
    })
    .catch(function (err) {
      return next("Faied to execute DB Query");
    });
}

module.exports = {
  getAllUsers: getAllUsers,
  getSingleUser: getSingleUser,
};
