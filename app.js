require('coffee-script').register();
var express = require('express');
//var routes = require('./routes');
var http = require('http');
var path = require('path');
mongodb = require('mongodb');

var app = express();

// all environments
app.set('port', process.env.PORT || 3000);
app.set('views', __dirname + '/views');
app.set('view engine', 'jade');
app.use(express.favicon());
app.use(express.logger('dev'));
app.use(express.bodyParser());
app.use(express.methodOverride());
app.use(app.router);
app.use(require('stylus').middleware(__dirname + '/public'));
app.use(express.static(path.join(__dirname, 'public')));

//Les routes

MONGODB_URI = 'mongodb://localhost:50000/inf4375';

mongodb.MongoClient.connect(MONGODB_URI, {server: {poolSize:1,auto_reconnect: true}}, function (err, database) {
    if (err) {
        console.log("Impossible de se connecter à la base de données");
        process.exit(1);
    } else {
        console.log('Connexion à la bd réussi');
        database.collection('LAHG04077707', function (err, coll) {
            if (err) {
                console.log("Erreur lors de la connexion à la collection.");
                process.exit(1);
            } else {
                console.log("Connexion à la collection réussie.");
                require('./routes')(app, coll);
                http.createServer(app).listen(app.get('port'), function(){
                    console.log('Express server listening on port '+ app.get('port'));
                });
            }
        });
    }
});
