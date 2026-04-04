addEvent("dxui:requestRemoteImage", true)
addEventHandler("dxui:requestRemoteImage", root, function(url)
    local player = client
    if not player or not isElement(player) then return end

    fetchRemote(url, function(responseData, errno)
        if type(errno) == "table" then
            errno = errno.statusCode or -1
        end
        if errno == 0 and responseData and #responseData > 0 then
            local ext = "png"
            local header = responseData:sub(1, 8)
            if header:sub(1, 3) == "\255\216\255" then ext = "jpg"
            elseif header:sub(1, 2) == "BM" then ext = "bmp"
            end
            triggerLatentClientEvent(player, "dxui:receiveRemoteImage", 1000000, false, player, url, responseData, ext)
        else
            triggerClientEvent(player, "dxui:receiveRemoteImage", player, url, false, nil)
        end
    end)
end)

local function writeFileToResource(resourceName, filePath, data)
    local f = fileCreate(":" .. resourceName .. "/" .. filePath)
    if f then
        fileWrite(f, data)
        fileClose(f)
        return true
    end
    return false
end

local function copyFontToResource(resourceName, fileName, sourcePath)
    local srcFile = fileOpen(sourcePath, true)
    if not srcFile then return false end
    local size = fileGetSize(srcFile)
    local data = fileRead(srcFile, size)
    fileClose(srcFile)
    if not data or #data == 0 then return false end
    return writeFileToResource(resourceName, "assets/" .. fileName, data)
end

addEvent("dxui:exportFiles", true)
addEvent("dxui:exportFontFile", true)
addEventHandler("dxui:exportFiles", root, function(resourceName, luaCode, metaCode, fontFiles, serverCode)
    local player = client
    if not player or not isElement(player) then return end

    local res = getResourceFromName(resourceName)
    if not res then
        res = createResource(resourceName)
        if not res then
            outputChatBox("[DX UI Creator] Resource olusturulamadi: " .. resourceName, player, 214, 76, 76, true)
            return
        end
    end

    local ok1 = writeFileToResource(resourceName, "client.lua", luaCode)
    local ok2 = writeFileToResource(resourceName, "meta.xml",   metaCode)

    if not ok1 or not ok2 then
        outputChatBox("[DX UI Creator] Dosya yazma hatasi! Resource'u tekrar baslatin.", player, 214, 76, 76, true)
        return
    end

    if serverCode then
        writeFileToResource(resourceName, "server.lua", serverCode)
    end

    if fontFiles then
        for _, ff in ipairs(fontFiles) do
            copyFontToResource(resourceName, ff.fileName, ff.sourcePath)
        end
    end

    outputChatBox("[DX UI Creator] Export tamamlandi -> resources/" .. resourceName .. "/", player, 115, 191, 136, true)
    outputChatBox("[DX UI Creator] Baslatmak icin: /start " .. resourceName, player, 88, 140, 255, true)
end)
