var promise = require('bluebird');

var options = {
  // Initialization Options
  promiseLib: promise
};

var pgp = require('pg-promise')(options);
//var connectionString = 'postgres://localhost:5432/testdb';
var db = pgp(connectionString);

function getAllUsers(req, res, next) {
  db.any('select PGP_SYM_DECRYPT(name::bytea, "AES_KEY") as name,PGP_SYM_DECRYPT(ssn::bytea, "AES_KEY") as ssn from table1')
    .then(function (data) {
      res.status(200)
        .json({
          status: 'success',
          data: data,
          message: 'Retrieved ALL users'
        });
    })
    .catch(function (err) {
      return next(err);
    });
}

function getSingleUser(req, res, next) {
  var userID = parseInt(req.params.id);
  db.one('select PGP_SYM_DECRYPT(name::bytea, "AES_KEY") as name,PGP_SYM_DECRYPT(ssn::bytea, "AES_KEY") as ssn from table1 where id = $1', userID)
    .then(function (data) {
      res.status(200)
        .json({
          status: 'success',
          data: data,
          message: 'Retrieved Single User'
        });
    })
    .catch(function (err) {
      return next(err);
    });
}

module.exports = {
  getAllUsers: getAllUsers,
  getSingleUser: getSingleUser,
};
