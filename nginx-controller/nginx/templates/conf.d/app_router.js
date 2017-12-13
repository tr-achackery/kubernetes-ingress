function findAppType(appName) {
	var fs = require('fs');
 	var contents = fs.readFileSync('/TR/data/appmanifest/AppStoreManifest.json');
    	var appManifest = JSON.parse(contents);
	
	
	for(var i=0;i<appManifest.apps.length;i++) 
		if(appManifest.apps[i].name.toUpperCase() == appName.toUpperCase())
			return appManifest.apps[i].versions[0].defaultPlatform;
		
	return "";
}

function getPlatformType(req, res) {
    var splitUrl = req.uri.split('/');
    var appPrefixIndex = 0;
    var appName = "";
    for(var i=0;i<splitUrl.length;i++)
    {
       if(splitUrl[i].toUpperCase() == "APPS")
   	{
          appPrefixIndex = i;
          break;
	}
    }

    if(appPrefixIndex >= 0 && appPrefixIndex <= splitUrl.length - 1)
    {
    	appName = splitUrl[appPrefixIndex + 1];
    }
 
    var platformType = findAppType(appName);
    req.log("URI: " + req.uri + "\nPlatform type: " + platformType + "\n");

    return platformType;
}

