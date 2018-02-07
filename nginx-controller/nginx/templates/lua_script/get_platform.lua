--[[
DotNet,
NodeJS,
WebApi,
Ruby,
Java,
Python
]]
local uri = ngx.var.uri
local found_app_token = false
local app_name = ""
local version = ""

-- TODO: check for AppEngine/ Svc/ ?? at line UrlParser.cs:190
-- TODO: check for soap service, rest service, cat ?? at UrlParser.cs:300

for token in uri:gmatch("[^/]+") do
  if app_name ~= "" then
    version = token
    break
  elseif found_app_token then
    app_name = token
  elseif (token:upper() == "APPS") then
    found_app_token = true
  end
end

if not found_app_token or app_name == "" or version == "" then
  ngx.log(ngx.ERR, "can't get app name from url, got app name: " .. app_name .. ", version: " .. version)
  ngx.log(ngx.ERR, "the uri is " .. uri)
  return false
end

-- get platform
local platform = ngx.shared.app_store_manifest:get(app_name .. version)

-- TODO: get uuid ?? at AppServerManager.cs:603
-- TODO: and whole bunch of other stuff at AppServerManager.cs:606
-- TODO: handle rules at AppServerManager.cs: 1524

if (platform == nil) then
  ngx.log(ngx.ERR, "can't find the platform with given app: " .. app_name .. " and version: " .. version)
  return false
end

if platform == "DotNet" then
  return "dotnetsvc"
elseif platform == "NodeJS" then
  return "nodejssvc"
elseif platform == "WebApi" then
  return "webapi"
else
  ngx.log(ngx.ERR, "can't get asi type with platform: " .. platform)
  return false
end
