var getVersion = function(_ctx, _payload, _req, res) {
  res.send(200, process.version);
}

var getNodePath = function(_ctx, _payload, _req, res) {
  res.send(200, process.execPath);
}

function configure(app) {
  app.get('/version', getVersion);
  app.get('/nodepath', getNodePath);
}

exports.configure = configure;
