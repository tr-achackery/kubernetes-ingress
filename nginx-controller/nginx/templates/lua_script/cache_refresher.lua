ngx.log(ngx.DEBUG, "in init worker.." .. ngx.worker.pid())

if ngx.worker.id() ~= 0 then
    return
end

local app_store_manifest_file_name = "AppStoreManifest.json"
local refresh_delay = 60

ngx.log(ngx.DEBUG, "setting worker pid for cache updater: ", ngx.worker.pid())

local watcher_handler
watcher_handler = function()
    local app_store_manifest = ngx.shared.app_store_manifest

    ngx.log(ngx.DEBUG, "in refresher at " .. os.time())

    local f = io.popen("stat -c %Y " .. app_store_manifest_file_name)
    if not f then
        ngx.log(ngx.ERR, "failed to get last modified time")
        return
    end
    local last_modified = f:read()

    if (app_store_manifest:get("last modified") == nil or last_modified > app_store_manifest:get("last modified")) then
        ngx.log(ngx.DEBUG, "start refreshing at " .. os.time())

        -- copy to a temp file first
        os.execute("cp " .. app_store_manifest_file_name .. " " .. app_store_manifest_file_name .. ".temp")

        -- update last modified time
        app_store_manifest:set("last modified", last_modified)

        -- read the temp file and delete it
        local file = io.open(app_store_manifest_file_name .. ".temp", "r")
        local content = file:read("*a")
        file:close()
        os.remove(app_store_manifest_file_name .. ".temp")

        -- parse
        local json = require "../lua_include/json"
        local parsedManifest = json.parse(content)

        -- dump to dict
        for i, app in ipairs(parsedManifest.apps) do
            for j, version in ipairs(app.versions) do
                local defaultPlatform = version.defaultPlatform
                if not defaultPlatform then
                    defaultPlatform = "DotNet"
                end
                app_store_manifest:set(app.name .. version.version, defaultPlatform)
            end
        end
    end

    ngx.log(ngx.DEBUG, "finish refreshing at " .. os.time())
end

ngx.timer.every(refresh_delay, watcher_handler) -- check for cache update for every 60 seconds

watcher_handler()
