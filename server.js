
/**
 * Module dependencies.
 */
require('coffee-script/register');
coffee = require('coffee-script');
var express = require('express');
var routes = require('./routes');
var user = require('./routes/user');
var whiteboard = require('./routes/whiteboard')
var http = require('http');
var path = require('path');
var fs = require('fs');
var WebSocketServer = require('ws').Server, wss = new WebSocketServer({port: 8080});
var app = express();

// all environments
app.set('port', 80);
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'jade');
app.use(express.favicon());
app.use(express.logger('dev'));
app.use(express.json());
app.use(express.urlencoded());
app.use(express.methodOverride());
app.use(app.router);
app.use(require('stylus').middleware(path.join(__dirname, 'public')));
app.use(express.static(path.join(__dirname, 'public')));

// development only
if ('development' == app.get('env')) {
  app.use(express.errorHandler());
}

app.get('/', routes.index);
app.get('/users', user.list);
app.get('/whiteboard/:id', whiteboard.index)

app.get('/:script.js', function(req, res){
  res.header('Content-Type', 'application/x-javascript');
  cs = fs.readFileSync("./public/javascripts/" + req.params.script + ".coffee", "ascii");
  js = coffee.compile(cs);
  res.send(js);
});

wss.broadcastTo = function(data, url) {
  for(var i in this.clients){
    if(this.clients[i].upgradeReq.url == url){
      this.clients[i].send(data);
    }
  }
};

wss.on('connection', function(ws) {
  url = ws.upgradeReq.url;
  ws.on('message', function(message) {
    console.log('received: %s', message);
    wss.broadcastTo(message,url);
  });
  ws.send('something');
});

http.createServer(app).listen(app.get('port'), function(){
  console.log('Express server listening on port ' + app.get('port'));
});
