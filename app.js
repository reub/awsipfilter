var http = require("http");
var https = require("https");
var fs = require('fs');

getJSON = function(options, onResult)
{
  var protocol = options.port == 443 ? https : http;
  var request = protocol.request(options, function(response)
  {
    var output = '';
    //console.log(options.host + ':' + response.statusCode);
    response.setEncoding('utf8');

    response.on('data', function (chunk) {
      output += chunk;
    });

    response.on('end', function() {
      obj = JSON.parse(output);
      onResult(response.statusCode, obj);
    });
  });

  request.on('error', function(err) {
    //res.send('error: ' + err.message);
  });

  request.end();
};


var options = {
    host: 'ip-ranges.amazonaws.com',
    port: 443,
    path: '/ip-ranges.json',
    method: 'GET',
    headers: {
        'Content-Type': 'application/json'
    }
};

getJSON(options,
  function(statusCode, result)
  {
    var date = result.createDate;
    var syncToken = result.syncToken;
    var prefixes = result.prefixes;
    var awswhitelist = "";
    for(i=0;i<prefixes.length;i++) {
      awswhitelist += "allow " + prefixes[i].ip_prefix + ";\n";
    }

    whitelist = "# allow local addresses\nallow 127.0.0.1;\nallow 192.168.9.1/24;\n\n#allow Amazon AWS Published Addresses as of " + date + " with syncToken " + syncToken + "\n";
    whitelist += awswhitelist;
    whitelist += "deny all;\n"
    //console.log("whitelist:\n" + whitelist);
    fs.writeFile("/etc/nginx/conf.d/whitelist.conf", whitelist, function(err) {
      if(err) {
        return console.log(err);
      }
      console.log("Saved whitelist.conf");
    });
  });


