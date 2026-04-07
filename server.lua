local THIS_RESOURCE = getThisResource()
local THIS_RESOURCE_NAME = getResourceName(THIS_RESOURCE)

local MAX_REMOTE_IMAGE_BYTES = 5 * 1024 * 1024
local MAX_EXPORT_LUA_BYTES = 1024 * 1024
local MAX_EXPORT_META_BYTES = 128 * 1024
local MAX_EXPORT_SERVER_BYTES = 256 * 1024
local MAX_EXPORT_FILE_COUNT = 64

local ALLOWED_FONT_SOURCES = {
    ["Gilroy-Light.ttf"] = "assets/Gilroy-Light.ttf",
    ["Gilroy-Regular.ttf"] = "assets/Gilroy-Regular.ttf",
    ["Gilroy-Medium.ttf"] = "assets/Gilroy-Medium.ttf",
    ["Gilroy-SemiBold.ttf"] = "assets/Gilroy-SemiBold.ttf",
    ["Gilroy-Bold.ttf"] = "assets/Gilroy-Bold.ttf",
    ["BebasNeue-Thin.ttf"] = "assets/BebasNeue-Thin.ttf",
    ["BebasNeue-Light.ttf"] = "assets/BebasNeue-Light.ttf",
    ["BebasNeue-Book.ttf"] = "assets/BebasNeue-Book.ttf",
    ["BebasNeue-Regular.ttf"] = "assets/BebasNeue-Regular.ttf",
    ["BebasNeue-Bold.ttf"] = "assets/BebasNeue-Bold.ttf",
    ["SFUIText-Light.ttf"] = "assets/SFUIText-Light.ttf",
    ["SFUIText-Regular.ttf"] = "assets/SFUIText-Regular.ttf",
    ["SFUIText-Medium.ttf"] = "assets/SFUIText-Medium.ttf",
    ["SFUIText-Semibold.ttf"] = "assets/SFUIText-Semibold.ttf",
    ["SFUIText-Bold.ttf"] = "assets/SFUIText-Bold.ttf",
    ["SFUIText-Heavy.ttf"] = "assets/SFUIText-Heavy.ttf",
}

local function failRemoteImage(player, url)
    triggerClientEvent(player, "dxui:receiveRemoteImage", player, url, false, nil)
end

local function isSafeUrl(url)
    if type(url) ~= "string" then
        return false
    end

    url = url:gsub("^%s+", ""):gsub("%s+$", "")
    local lower = url:lower()
    if #lower < 10 or #lower > 2048 then
        return false
    end
    if lower:sub(1, 7) ~= "http://" and lower:sub(1, 8) ~= "https://" then
        return false
    end

    local host = lower:match("^https?://([^/%?#:]+)")
    if not host then
        return false
    end

    if host == "localhost" or host == "127.0.0.1" or host == "[::1]" or host == "::1" then
        return false
    end

    if host:match("^10%.") or host:match("^127%.") or host:match("^169%.254%.") or host:match("^192%.168%.") then
        return false
    end

    if host:match("^172%.1[6-9]%.") or host:match("^172%.2%d%.") or host:match("^172%.3[0-1]%.") then
        return false
    end

    return true
end

local function normalizeResourcePath(path)
    if type(path) ~= "string" then
        return nil
    end

    path = path:gsub("\\", "/"):gsub("^%s+", ""):gsub("%s+$", "")
    if path == "" or #path > 256 then
        return nil
    end

    if path:sub(1, 1) == "/" or path:sub(1, 1) == ":" then
        return nil
    end

    if path:find("%.%.", 1, true) or path:find("//", 1, true) then
        return nil
    end

    if path:find("[\r\n]") or path:find("[<>:\"|%*%?]") then
        return nil
    end

    return path
end

local function isSafeResourceName(resourceName)
    return type(resourceName) == "string"
        and #resourceName >= 1
        and #resourceName <= 64
        and resourceName:match("^[%w_%-%[%]]+$") ~= nil
end

local function canExportResource(player)
    return hasObjectPermissionTo(player, "function.createResource", false)
        or hasObjectPermissionTo(player, "function.startResource", false)
        or hasObjectPermissionTo(player, "resource." .. THIS_RESOURCE_NAME .. ".export", false)
end

local function readFileFromResource(resourceName, path)
    local file = fileOpen(":" .. resourceName .. "/" .. path, true)
    if not file then
        return nil
    end

    local size = fileGetSize(file)
    local data = fileRead(file, size)
    fileClose(file)

    if not data or #data == 0 then
        return nil
    end

    return data
end

local function readResourceFile(path)
    return readFileFromResource(THIS_RESOURCE_NAME, path)
end

local function deleteFileFromResource(resourceName, path)
    local fullPath = ":" .. resourceName .. "/" .. path
    if fileExists(fullPath) then
        return fileDelete(fullPath)
    end
    return true
end

local function writeFileToResource(resourceName, filePath, data)
    deleteFileFromResource(resourceName, filePath)
    local f = fileCreate(":" .. resourceName .. "/" .. filePath)
    if f then
        fileWrite(f, data)
        fileClose(f)
        return true
    end
    return false
end

local function snapshotResourceFile(resourceName, path)
    local fullPath = ":" .. resourceName .. "/" .. path
    local existed = fileExists(fullPath)
    return {
        path = path,
        existed = existed,
        data = existed and readFileFromResource(resourceName, path) or nil,
    }
end

local function restoreResourceSnapshot(resourceName, snapshot)
    if snapshot.existed then
        return snapshot.data and writeFileToResource(resourceName, snapshot.path, snapshot.data) or false
    end
    return deleteFileFromResource(resourceName, snapshot.path)
end

local function copyResourceFileToResource(resourceName, sourcePath, targetPath)
    local data = readResourceFile(sourcePath)
    if not data then
        return false
    end
    return writeFileToResource(resourceName, targetPath, data)
end

local function copyFontToResource(resourceName, fileName)
    local sourcePath = ALLOWED_FONT_SOURCES[fileName]
    if not sourcePath then
        return false
    end
    return copyResourceFileToResource(resourceName, sourcePath, "assets/" .. fileName)
end

addEvent("dxui:requestRemoteImage", true)
addEventHandler("dxui:requestRemoteImage", root, function(url)
    local player = client
    if not player or not isElement(player) then
        return
    end

    if not isSafeUrl(url) then
        failRemoteImage(player, url)
        return
    end

    fetchRemote(url, function(responseData, errno)
        if type(errno) == "table" then
            errno = errno.statusCode or -1
        end

        if errno == 0 and responseData and #responseData > 0 and #responseData <= MAX_REMOTE_IMAGE_BYTES then
            local ext = "png"
            local header = responseData:sub(1, 8)
            if header:sub(1, 3) == "\255\216\255" then
                ext = "jpg"
            elseif header:sub(1, 2) == "BM" then
                ext = "bmp"
            end
            triggerLatentClientEvent(player, "dxui:receiveRemoteImage", 1000000, false, player, url, responseData, ext)
        else
            failRemoteImage(player, url)
        end
    end)
end)

addEvent("dxui:exportFiles", true)
addEventHandler("dxui:exportFiles", root, function(resourceName, luaCode, metaCode, fontFiles, localFiles, serverCode)
    local player = client
    if not player or not isElement(player) then
        return
    end

    if not canExportResource(player) then
        outputChatBox("[DX UI Creator] Export izniniz yok.", player, 214, 76, 76, true)
        return
    end

    if not isSafeResourceName(resourceName) then
        outputChatBox("[DX UI Creator] Gecersiz resource adi.", player, 214, 76, 76, true)
        return
    end

    if type(luaCode) ~= "string" or luaCode == "" or #luaCode > MAX_EXPORT_LUA_BYTES then
        outputChatBox("[DX UI Creator] Export client.lua boyutu gecersiz.", player, 214, 76, 76, true)
        return
    end

    if type(metaCode) ~= "string" or metaCode == "" or #metaCode > MAX_EXPORT_META_BYTES then
        outputChatBox("[DX UI Creator] Export meta.xml boyutu gecersiz.", player, 214, 76, 76, true)
        return
    end

    if serverCode ~= nil and (type(serverCode) ~= "string" or #serverCode > MAX_EXPORT_SERVER_BYTES) then
        outputChatBox("[DX UI Creator] Export server.lua boyutu gecersiz.", player, 214, 76, 76, true)
        return
    end

    fontFiles = type(fontFiles) == "table" and fontFiles or {}
    localFiles = type(localFiles) == "table" and localFiles or {}

    if #fontFiles > MAX_EXPORT_FILE_COUNT or #localFiles > MAX_EXPORT_FILE_COUNT then
        outputChatBox("[DX UI Creator] Export icindeki dosya sayisi fazla.", player, 214, 76, 76, true)
        return
    end

    local res = getResourceFromName(resourceName)
    if not res then
        res = createResource(resourceName)
        if not res then
            outputChatBox("[DX UI Creator] Resource olusturulamadi: " .. resourceName, player, 214, 76, 76, true)
            return
        end
    end

    local snapshots = {}
    local touched = {}

    local function remember(path)
        if not touched[path] then
            touched[path] = true
            snapshots[#snapshots + 1] = snapshotResourceFile(resourceName, path)
        end
    end

    local function rollbackExport()
        for i = #snapshots, 1, -1 do
            restoreResourceSnapshot(resourceName, snapshots[i])
        end
    end

    local function writeTracked(path, data)
        remember(path)
        return writeFileToResource(resourceName, path, data)
    end

    local function copyTracked(sourcePath, targetPath)
        remember(targetPath)
        return copyResourceFileToResource(resourceName, sourcePath, targetPath)
    end

    if not writeTracked("client.lua", luaCode) or not writeTracked("meta.xml", metaCode) then
        rollbackExport()
        outputChatBox("[DX UI Creator] Dosya yazma hatasi! Export geri alindi.", player, 214, 76, 76, true)
        return
    end

    if serverCode and not writeTracked("server.lua", serverCode) then
        rollbackExport()
        outputChatBox("[DX UI Creator] server.lua yazilamadi. Export geri alindi.", player, 214, 76, 76, true)
        return
    end

    for _, ff in ipairs(fontFiles) do
        local fileName = type(ff) == "table" and ff.fileName or nil
        local sourcePath = fileName and ALLOWED_FONT_SOURCES[fileName] or nil
        if not sourcePath or not copyTracked(sourcePath, "assets/" .. fileName) then
            rollbackExport()
            outputChatBox("[DX UI Creator] Font kopyalanamadi: " .. tostring(fileName), player, 214, 76, 76, true)
            return
        end
    end

    for _, resourcePath in ipairs(localFiles) do
        local safePath = normalizeResourcePath(resourcePath)
        if not safePath or not copyTracked(safePath, safePath) then
            rollbackExport()
            outputChatBox("[DX UI Creator] Asset kopyalanamadi: " .. tostring(resourcePath), player, 214, 76, 76, true)
            return
        end
    end

    outputChatBox("[DX UI Creator] Export tamamlandi -> resources/" .. resourceName .. "/", player, 115, 191, 136, true)
    outputChatBox("[DX UI Creator] Baslatmak icin: /start " .. resourceName, player, 88, 140, 255, true)
end)
