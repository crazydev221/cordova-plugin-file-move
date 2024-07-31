var exec = require('cordova/exec');

exports.moveFolders = function(success, error) {
    exec(success, error, 'FileMovePlugin', 'moveFolders', []);
};
