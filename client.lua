local editor = {
    open = false,
    nextId = 1,
    selectedId = nil,
    selectedIds = {},
    elements = {},
    hotboxes = {},
    interaction = nil,
    activeInput = nil,
    exportModal = nil,
    inspectorScroll = 0,
    inspectorArea = nil,
    inspectorScrollMax = 0,
    layersScroll = 0,
    layersArea = nil,
    layersBoxInfo = nil,
    colorPicker = nil,
    canvasZoom = 1.0,
    canvasPanX = 0,
    canvasPanY = 0,
    zoomArea = nil,
    panning = nil,
    exportCache = "",
    cursorBlink = 0,
    exportDirty = true,
    panelDirty = true,
    snapEnabled = true,
    previewScroll = 0,
    previewScrollMax = 0,
    previewArea = nil,
    propertySearch = "",
    propertySearchInput = nil,
    clipboardStyle = nil,
    previewMode = false,
    exportProfile = "full",
    stylePresets = {},
    prefabList = {},
    rubberBand = nil,
    clipboardElements = nil,
    prefabInput = nil,
    prefabScroll = 0,
    assetSearch = "",
    assetSearchInput = nil,
    assetLibrary = {},
    smartGuides = {},
    smartSnapEnabled = true,
    canvas = {
        width = 1280,
        height = 720,
        grid = 40
    },
    tooltip = nil,
    tooltipTime = 0,
    recentColors = {},
    rightPanelTab = "design",  
    theme = {
        overlay      = {12,  12,  14,  215},
        panel        = {28,  28,  31,  245},
        panelSoft    = {36,  36,  40,  245},
        panelAlt     = {44,  44,  49,  255},
        panelHover   = {56,  56,  62,  255},
        panelBorder  = {50,  50,  56,  80 },
        borderSubtle = {38,  38,  42,  255},
        text         = {229, 229, 231, 255},
        textSecond   = {160, 160, 170, 255},
        muted        = {100, 100, 110, 255},
        accent       = {123, 104, 238, 255},
        accentHover  = {149, 128, 248, 255},
        accentActive = {99,  85,  212, 255},
        accentSoft   = {123, 104, 238, 35 },
        success      = {27,  196, 125, 255},
        successHover = {54,  212, 146, 255},
        warning      = {245, 166, 35,  255},
        danger       = {242, 72,  34,  255},
        dangerHover  = {255, 99,  71,  255},
        canvasBg     = {10,  10,  12,  255},
        canvasCheck1 = {20,  20,  23,  255},
        canvasCheck2 = {15,  15,  17,  255},
        canvasGrid   = {255, 255, 255, 10 },
        selection    = {123, 104, 238, 255},
        selectionFill= {123, 104, 238, 28 },
    }
}

local themeColors = {}
local function cacheThemeColors()
    for key, color in pairs(editor.theme) do
        themeColors[key] = tocolor(color[1], color[2], color[3], color[4] or 255)
    end
end


local customFonts = {}
local UI_FONT_BOLD      = "default-bold"
local UI_FONT_MEDIUM    = "default"
local UI_FONT_LIGHT     = "default"
local UI_FONT_BOLD_LG   = "default-bold"
local UI_FONT_BOLD_SM   = "default-bold"
local UI_FONT_BOLD_XS   = "default-bold"
local UI_FONT_MEDIUM_SM = "default"
local UI_FONT_MEDIUM_XS = "default"

local CUSTOM_FONT_DEFS = {
    {key = "gilroy-light",    path = "assets/Gilroy-Light.ttf"},
    {key = "gilroy-regular",  path = "assets/Gilroy-Regular.ttf"},
    {key = "gilroy-medium",   path = "assets/Gilroy-Medium.ttf"},
    {key = "gilroy-semibold", path = "assets/Gilroy-SemiBold.ttf"},
    {key = "gilroy-bold",     path = "assets/Gilroy-Bold.ttf"},
    {key = "bebas-thin",      path = "assets/BebasNeue-Thin.ttf"},
    {key = "bebas-light",     path = "assets/BebasNeue-Light.ttf"},
    {key = "bebas-book",      path = "assets/BebasNeue-Book.ttf"},
    {key = "bebas-regular",   path = "assets/BebasNeue-Regular.ttf"},
    {key = "bebas-bold",      path = "assets/BebasNeue-Bold.ttf"},
    {key = "sfui-light",      path = "assets/SFUIText-Light.ttf"},
    {key = "sfui-regular",    path = "assets/SFUIText-Regular.ttf"},
    {key = "sfui-medium",     path = "assets/SFUIText-Medium.ttf"},
    {key = "sfui-semibold",   path = "assets/SFUIText-Semibold.ttf"},
    {key = "sfui-bold",       path = "assets/SFUIText-Bold.ttf"},
    {key = "sfui-heavy",      path = "assets/SFUIText-Heavy.ttf"},
}

local function loadCustomFonts()
    local sizes = {10, 12, 14, 17}
    for _, w in ipairs(CUSTOM_FONT_DEFS) do
        for _, sz in ipairs(sizes) do
            local fontKey = w.key .. "_" .. sz
            local font = dxCreateFont(w.path, sz)
            if font then
                customFonts[fontKey] = font
            else
                outputChatBox("[DX UI Creator] FONT FAIL: " .. w.path .. " (" .. sz .. "pt)", 214, 76, 76, true)
            end
        end
    end
end

local function resolveFont(fontName)
    if not fontName then return "default-bold" end
    if customFonts[fontName] then return customFonts[fontName] end
    if customFonts[fontName .. "_14"] then return customFonts[fontName .. "_14"] end
    for _, fd in ipairs(CUSTOM_FONT_DEFS) do
        if fd.key == fontName then
            local font = dxCreateFont(fd.path, 14)
            if font then
                customFonts[fontName .. "_14"] = font
                return font
            end
            break
        end
    end
    return fontName
end

local FONT_OPTIONS = {
    "default", "default-bold", "clear", "arial", "sans",
    "pricedown", "bankgothic", "diploma", "beckett",
    "gilroy-light", "gilroy-regular", "gilroy-medium", "gilroy-semibold", "gilroy-bold",
    "bebas-thin", "bebas-light", "bebas-book", "bebas-regular", "bebas-bold",
    "sfui-light", "sfui-regular", "sfui-medium", "sfui-semibold", "sfui-bold", "sfui-heavy",
}
local ALIGN_X_OPTIONS  = {"left","center","right"}
local ALIGN_Y_OPTIONS  = {"top","center","bottom"}
local ANCHOR_X_OPTIONS = {"left","center","right"}
local ANCHOR_Y_OPTIONS = {"top","center","bottom"}
local DOCK_OPTIONS = {"none","fill"}
local ACTION_TYPE_OPTIONS = {"none","toggle_visibility","show","hide","toggle_checkbox","play_animation","chat_message","trigger_event"}
local ANIMATION_TYPE_OPTIONS = {"none","fade","pulse","float","slide-left","slide-right","slide-up","slide-down","zoom"}
local ANIMATION_TRIGGER_OPTIONS = {"auto","hover","click"}

local CANVAS_PRESETS = {
    {label="1280x720",  w=1280, h=720 },
    {label="1920x1080", w=1920, h=1080},
    {label="1366x768",  w=1366, h=768 },
    {label="800x600",   w=800,  h=600 },
    {label="2560x1440", w=2560, h=1440},
    {label="1024x768",  w=1024, h=768 },
}

local roundedCache = {}
local circleCache  = {}
local imageCache   = {}
local undoStack = {}
local redoStack = {}
local MAX_UNDO  = 20
local _panelRT       = nil
local _panelRTW      = 0
local _panelRTH      = 0
local _skipPanelDraw = false
local _lastHoverKey  = ""
local _cachedHotboxes = nil
local _cachedPropertyLists = {}
local _previewCachedRT = nil
local _previewCachedW  = 0
local _previewCachedH  = 0
local _lastPreviewCacheCode = ""
local _lastPreviewScroll = -1
local _canvasElemRT  = nil
local _canvasElemRTW = 0
local _canvasElemRTH = 0
local _canvasRTMode  = false 

local COMMON_EXPORT_KEYS = {
    "visible", "locked", "parentId", "groupId",
    "componentId", "componentInstanceOf", "componentDetached",
    "anchorX", "anchorY",
    "dockX", "dockY", "dockPaddingRight", "dockPaddingBottom",
    "relativeW", "relativeH", "wPercent", "hPercent",
    "clickAction", "actionTarget", "actionValue",
    "animationType", "animationTrigger", "animationDuration", "animationLoop", "animationIntensity",
}

function clamp(value, minV, maxV)
    if value < minV then return minV end
    if value > maxV then return maxV end
    return value
end

function round(value)
    return math.floor(value + 0.5)
end

local function getAnchoredAxisPosition(anchor, offset, size, totalSize)
    if anchor == "center" then
        return round((totalSize - size) / 2 + offset)
    elseif anchor == "right" or anchor == "bottom" then
        return round(totalSize - size - offset)
    end
    return round(offset)
end

local function getElementCanvasRect(element)
    local x, y, w, h
    local baseW = (element.relativeW and element.wPercent) and round(editor.canvas.width * ((element.wPercent or 0) / 100)) or (element.w or 0)
    local baseH = (element.relativeH and element.hPercent) and round(editor.canvas.height * ((element.hPercent or 0) / 100)) or (element.h or 0)
    baseW = math.max(20, baseW)
    baseH = math.max(20, baseH)

    if (element.dockX or "none") == "fill" then
        x = round(element.x or 0)
        w = math.max(20, editor.canvas.width - x - math.max(0, element.dockPaddingRight or 0))
    else
        w = baseW
        x = getAnchoredAxisPosition(element.anchorX or "left", element.x or 0, w, editor.canvas.width)
    end

    if (element.dockY or "none") == "fill" then
        y = round(element.y or 0)
        h = math.max(20, editor.canvas.height - y - math.max(0, element.dockPaddingBottom or 0))
    else
        h = baseH
        y = getAnchoredAxisPosition(element.anchorY or "top", element.y or 0, h, editor.canvas.height)
    end

    return x, y, w, h
end

local function setElementCanvasPosition(element, canvasX, canvasY)
    local _, _, w, h = getElementCanvasRect(element)
    local clampedX = clamp(round(canvasX), 0, math.max(0, editor.canvas.width - w))
    local clampedY = clamp(round(canvasY), 0, math.max(0, editor.canvas.height - h))

    if (element.dockX or "none") == "fill" then
        element.x = clampedX
    elseif (element.anchorX or "left") == "center" then
        element.x = round(clampedX - (editor.canvas.width - w) / 2)
    elseif (element.anchorX or "left") == "right" then
        element.x = round(editor.canvas.width - w - clampedX)
    else
        element.x = clampedX
    end

    if (element.dockY or "none") == "fill" then
        element.y = clampedY
    elseif (element.anchorY or "top") == "center" then
        element.y = round(clampedY - (editor.canvas.height - h) / 2)
    elseif (element.anchorY or "top") == "bottom" then
        element.y = round(editor.canvas.height - h - clampedY)
    else
        element.y = clampedY
    end
end

local function normalizeElementLayout(el)
    local cw, ch = editor.canvas.width, editor.canvas.height
    
    if el.relativeW then
        el.wPercent = clamp(el.wPercent or ((el.w or 20) / cw * 100), 1, 100)
    else
        el.w = math.max(20, el.w or 20)
    end
    
    if el.relativeH then
        el.hPercent = clamp(el.hPercent or ((el.h or 20) / ch * 100), 1, 100)
    else
        el.h = math.max(20, el.h or 20)
    end
    
    if (el.dockX or "none") == "fill" then
        el.dockPaddingRight = math.max(0, el.dockPaddingRight or 0)
        el.x = clamp(el.x or 0, 0, math.max(0, cw - 20 - el.dockPaddingRight))
    else
        local finalW = el.relativeW and (cw * (el.wPercent or 1) / 100) or el.w
        if finalW > cw then
            if el.relativeW then el.wPercent = 100 else el.w = cw end
        end
    end
    
    if (el.dockY or "none") == "fill" then
        el.dockPaddingBottom = math.max(0, el.dockPaddingBottom or 0)
        el.y = clamp(el.y or 0, 0, math.max(0, ch - 20 - el.dockPaddingBottom))
    else
        local finalH = el.relativeH and (ch * (el.hPercent or 1) / 100) or el.h
        if finalH > ch then
            if el.relativeH then el.hPercent = 100 else el.h = ch end
        end
    end
    
    if el.radius then
        local nw = el.relativeW and (cw * (el.wPercent or 0) / 100) or el.w
        local nh = el.relativeH and (ch * (el.hPercent or 0) / 100) or el.h
        if el.dockX == "fill" then nw = cw - (el.x or 0) - (el.dockPaddingRight or 0) end
        if el.dockY == "fill" then nh = ch - (el.y or 0) - (el.dockPaddingBottom or 0) end
        el.radius = clamp(el.radius, 0, math.floor(math.min(nw, nh) / 2))
    end
end

local _animValues = {}
local _animTargets = {}
local _lastFrameTime = getTickCount()

local function lerp(a, b, t)
    return a + (b - a) * t
end

local function animLerp(key, target, speed)
    speed = speed or 10
    if not _animValues[key] then _animValues[key] = target end
    _animTargets[key] = target
    local dt = (getTickCount() - _lastFrameTime) / 1000
    dt = math.min(dt, 0.05)
    _animValues[key] = lerp(_animValues[key], target, 1 - math.exp(-speed * dt))
    if math.abs(_animValues[key] - target) < 0.5 then _animValues[key] = target end
    return _animValues[key]
end

local function animColor(key, r, g, b, a, speed)
    local cr = animLerp(key .. "_r", r, speed or 8)
    local cg = animLerp(key .. "_g", g, speed or 8)
    local cb = animLerp(key .. "_b", b, speed or 8)
    local ca = animLerp(key .. "_a", a or 255, speed or 8)
    return tocolor(cr, cg, cb, ca)
end

local _iconCache = {}

local ICON_SVGS = {
    window = '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><rect x="2" y="3" width="20" height="18" rx="3" stroke="#FFFFFF" stroke-width="2"/><line x1="2" y1="8" x2="22" y2="8" stroke="#FFFFFF" stroke-width="2"/><circle cx="5.5" cy="5.5" r="1" fill="#FF6B6B"/><circle cx="8.5" cy="5.5" r="1" fill="#FFD93D"/><circle cx="11.5" cy="5.5" r="1" fill="#6BCB77"/></svg>',
    button = '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><rect x="2" y="6" width="20" height="12" rx="4" stroke="#FFFFFF" stroke-width="2"/><line x1="8" y1="12" x2="16" y2="12" stroke="#FFFFFF" stroke-width="2" stroke-linecap="round"/></svg>',
    label = '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M5 7H7L12 17L17 7H19" stroke="#FFFFFF" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/><line x1="8" y1="14" x2="16" y2="14" stroke="#FFFFFF" stroke-width="2" stroke-linecap="round"/></svg>',
    rectangle = '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><rect x="3" y="5" width="18" height="14" rx="2" stroke="#FFFFFF" stroke-width="2"/></svg>',
    image = '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><rect x="2" y="3" width="20" height="18" rx="3" stroke="#FFFFFF" stroke-width="2"/><circle cx="8" cy="9" r="2" stroke="#FFFFFF" stroke-width="1.5"/><path d="M2 17L7 13L11 16L16 11L22 17" stroke="#FFFFFF" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>',
    circle = '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><circle cx="12" cy="12" r="9" stroke="#FFFFFF" stroke-width="2"/></svg>',
    container = '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><rect x="2" y="2" width="20" height="20" rx="3" stroke="#FFFFFF" stroke-width="2" stroke-dasharray="4 2"/><rect x="6" y="6" width="5" height="5" rx="1" fill="#FFFFFF" opacity="0.5"/><rect x="13" y="6" width="5" height="5" rx="1" fill="#FFFFFF" opacity="0.5"/><rect x="6" y="13" width="5" height="5" rx="1" fill="#FFFFFF" opacity="0.5"/></svg>',
    progressbar = '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><rect x="2" y="8" width="20" height="8" rx="4" stroke="#FFFFFF" stroke-width="2"/><rect x="4" y="10" width="11" height="4" rx="2" fill="#FFFFFF"/></svg>',
    checkbox = '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><rect x="3" y="3" width="12" height="12" rx="2" stroke="#FFFFFF" stroke-width="2"/><path d="M5.5 9L8 11.5L11 7" stroke="#FFFFFF" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/><line x1="18" y1="7" x2="21" y2="7" stroke="#FFFFFF" stroke-width="2" stroke-linecap="round"/><line x1="18" y1="12" x2="21" y2="12" stroke="#FFFFFF" stroke-width="2" stroke-linecap="round"/></svg>',
    editbox = '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><rect x="2" y="5" width="20" height="14" rx="3" stroke="#FFFFFF" stroke-width="2"/><line x1="6" y1="12" x2="14" y2="12" stroke="#FFFFFF" stroke-width="2" stroke-linecap="round"/><line x1="14" y1="9" x2="14" y2="15" stroke="#FFFFFF" stroke-width="1.5" stroke-linecap="round"/></svg>',
    line = '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><line x1="3" y1="12" x2="21" y2="12" stroke="#FFFFFF" stroke-width="2.5" stroke-linecap="round"/><circle cx="3" cy="12" r="2" fill="#FFFFFF"/><circle cx="21" cy="12" r="2" fill="#FFFFFF"/></svg>',
    gradient = '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><defs><linearGradient id="g1" x1="0" y1="0" x2="1" y2="0"><stop offset="0%" stop-color="#FFFFFF" stop-opacity="1"/><stop offset="100%" stop-color="#FFFFFF" stop-opacity="0.1"/></linearGradient></defs><rect x="2" y="5" width="20" height="14" rx="3" fill="url(#g1)"/><rect x="2" y="5" width="20" height="14" rx="3" stroke="#FFFFFF" stroke-width="1.5"/></svg>',
    icon = '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><polygon points="12,3 15.5,9.5 23,10.5 17.5,16 19,23 12,19.5 5,23 6.5,16 1,10.5 8.5,9.5" stroke="#FFFFFF" stroke-width="2" stroke-linejoin="round"/></svg>',
    save = '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M19 21H5C3.89 21 3 20.1 3 19V5C3 3.89 3.89 3 5 3H16L21 8V19C21 20.1 20.1 21 19 21Z" stroke="#FFFFFF" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/><path d="M17 21V13H7V21" stroke="#FFFFFF" stroke-width="2"/><path d="M7 3V8H15" stroke="#FFFFFF" stroke-width="2"/></svg>',
    load = '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M22 19C22 20.1 21.1 21 20 21H4C2.9 21 2 20.1 2 19V8C2 6.9 2.9 6 4 6H9L11 3H20C21.1 3 22 3.9 22 5V19Z" stroke="#FFFFFF" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>',
    code = '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><polyline points="16,18 22,12 16,6" stroke="#FFFFFF" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/><polyline points="8,6 2,12 8,18" stroke="#FFFFFF" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>',
    copy = '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><rect x="9" y="9" width="13" height="13" rx="2" stroke="#FFFFFF" stroke-width="2"/><path d="M5 15H4C2.9 15 2 14.1 2 13V4C2 2.9 2.9 2 4 2H13C14.1 2 15 2.9 15 4V5" stroke="#FFFFFF" stroke-width="2"/></svg>',
    trash = '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><polyline points="3,6 5,6 21,6" stroke="#FFFFFF" stroke-width="2" stroke-linecap="round"/><path d="M19 6V20C19 21.1 18.1 22 17 22H7C5.9 22 5 21.1 5 20V6" stroke="#FFFFFF" stroke-width="2"/><path d="M8 6V4C8 2.9 8.9 2 10 2H14C15.1 2 16 2.9 16 4V6" stroke="#FFFFFF" stroke-width="2"/></svg>',
    layers = '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><polygon points="12,2 2,7 12,12 22,7" stroke="#FFFFFF" stroke-width="2" stroke-linejoin="round"/><polyline points="2,17 12,22 22,17" stroke="#FFFFFF" stroke-width="2" stroke-linejoin="round"/><polyline points="2,12 12,17 22,12" stroke="#FFFFFF" stroke-width="2" stroke-linejoin="round"/></svg>',
    front = '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><rect x="8" y="8" width="13" height="13" rx="2" stroke="#FFFFFF" stroke-width="2"/><rect x="3" y="3" width="10" height="10" rx="2" stroke="#FFFFFF" stroke-width="1.5" stroke-dasharray="3 2"/></svg>',
    back = '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><rect x="3" y="3" width="13" height="13" rx="2" stroke="#FFFFFF" stroke-width="2"/><rect x="8" y="8" width="13" height="13" rx="2" stroke="#FFFFFF" stroke-width="1.5" stroke-dasharray="3 2"/></svg>',
    duplicate = '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><rect x="8" y="8" width="13" height="13" rx="2" stroke="#FFFFFF" stroke-width="2"/><path d="M5 15H4C2.9 15 2 14.1 2 13V4C2 2.9 2.9 2 4 2H13C14.1 2 15 2.9 15 4V5" stroke="#FFFFFF" stroke-width="2"/><line x1="14.5" y1="11.5" x2="14.5" y2="17.5" stroke="#FFFFFF" stroke-width="2" stroke-linecap="round"/><line x1="11.5" y1="14.5" x2="17.5" y2="14.5" stroke="#FFFFFF" stroke-width="2" stroke-linecap="round"/></svg>',
    clear = '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><circle cx="12" cy="12" r="9" stroke="#FFFFFF" stroke-width="2"/><line x1="9" y1="9" x2="15" y2="15" stroke="#FFFFFF" stroke-width="2" stroke-linecap="round"/><line x1="15" y1="9" x2="9" y2="15" stroke="#FFFFFF" stroke-width="2" stroke-linecap="round"/></svg>',
    drag_handle = '<svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg"><circle cx="5" cy="4" r="1.2" fill="#FFFFFF"/><circle cx="11" cy="4" r="1.2" fill="#FFFFFF"/><circle cx="5" cy="8" r="1.2" fill="#FFFFFF"/><circle cx="11" cy="8" r="1.2" fill="#FFFFFF"/><circle cx="5" cy="12" r="1.2" fill="#FFFFFF"/><circle cx="11" cy="12" r="1.2" fill="#FFFFFF"/></svg>',
    lock = '<svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg"><rect x="3" y="7" width="10" height="7" rx="1.5" stroke="#FFFFFF" stroke-width="1.5"/><path d="M5 7V5C5 3.34 6.34 2 8 2C9.66 2 11 3.34 11 5V7" stroke="#FFFFFF" stroke-width="1.5" stroke-linecap="round"/></svg>',
    eye_on = '<svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M1 8C1 8 3.5 3 8 3C12.5 3 15 8 15 8C15 8 12.5 13 8 13C3.5 13 1 8 1 8Z" stroke="#FFFFFF" stroke-width="1.3" stroke-linecap="round"/><circle cx="8" cy="8" r="2" stroke="#FFFFFF" stroke-width="1.3"/></svg>',
    eye_off = '<svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M1 8C1 8 3.5 3 8 3C12.5 3 15 8 15 8" stroke="#FFFFFF" stroke-width="1.3" stroke-linecap="round"/><line x1="2" y1="2" x2="14" y2="14" stroke="#FFFFFF" stroke-width="1.3" stroke-linecap="round"/></svg>',
}

local function getIcon(name)
    if _iconCache[name] then
        if isElement(_iconCache[name]) then return _iconCache[name] end
        _iconCache[name] = nil
    end
    local svg = ICON_SVGS[name]
    if not svg then return nil end
    local sw = tonumber(svg:match('width="(%d+)"')) or 24
    local sh = tonumber(svg:match('height="(%d+)"')) or 24
    _iconCache[name] = svgCreate(sw, sh, svg)
    _uiSvgPendingFrames = 3
    return _iconCache[name]
end

local _uiRoundedCache = {}
local _uiSvgPendingFrames = 0

function dxDrawUiRounded(cacheKey, x, y, w, h, radius, color, postGUI)
    w      = math.max(1, round(w))
    h      = math.max(1, round(h))
    radius = clamp(round(radius or 0), 0, math.floor(math.min(w, h) / 2))
    if radius <= 0 then dxDrawRectangle(x, y, w, h, color, postGUI or false); return end
    local key = w .. "_" .. h .. "_" .. radius
    _uiRoundedCache[cacheKey] = _uiRoundedCache[cacheKey] or {}
    if not _uiRoundedCache[cacheKey][key] or not isElement(_uiRoundedCache[cacheKey][key]) then
        local path = string.format(
            '<svg width="%d" height="%d" viewBox="0 0 %d %d" fill="none" xmlns="http://www.w3.org/2000/svg"><rect width="%d" height="%d" rx="%d" fill="#FFFFFF"/></svg>',
            w, h, w, h, w, h, radius)
        _uiRoundedCache[cacheKey][key] = svgCreate(w, h, path)
        _uiSvgPendingFrames = 3
    end
    if _uiRoundedCache[cacheKey][key] then
        dxDrawImage(x, y, w, h, _uiRoundedCache[cacheKey][key], 0, 0, 0, color, postGUI or false)
    end
end

local _previewDrag = nil

local PROPERTY_DEFS = {
    common = {
        {kind="group", label="Kimlik"},
        {key="label",  label="Ad",      kind="rename"},
        {key="parentId", label="Parent", kind="text"},
        {key="groupId",  label="Grup",   kind="text"},
        {key="componentId", label="Bileşen ID",   kind="text"},
        {key="componentInstanceOf", label="B. Kaynağı",   kind="text"},
        {key="componentDetached", label="Ayrılmış",   kind="boolean"},
        {kind="group", label="Konum ve Boyut"},
        {key="x",      label="X",       kind="number"},
        {key="y",      label="Y",       kind="number"},
        {key="w",      label="Genişlik",kind="number"},
        {key="h",      label="Yükseklik",kind="number"},
        {key="anchorX",label="Anchor X", kind="enum", options=ANCHOR_X_OPTIONS},
        {key="anchorY",label="Anchor Y", kind="enum", options=ANCHOR_Y_OPTIONS},
        {key="dockX",  label="Dock X",   kind="enum", options=DOCK_OPTIONS},
        {key="dockY",  label="Dock Y",   kind="enum", options=DOCK_OPTIONS},
        {key="dockPaddingRight", label="Sağ Boşluk", kind="number"},
        {key="dockPaddingBottom",label="Alt Boşluk", kind="number"},
        {key="relativeW", label="Göreceli G.", kind="boolean"},
        {key="relativeH", label="Göreceli Y.", kind="boolean"},
        {key="wPercent", label="G. Yüzdesi", kind="number"},
        {key="hPercent", label="Y. Yüzdesi", kind="number"},
        {kind="group", label="Durum"},
        {key="locked", label="Kilitli", kind="boolean"},
        {key="visible",label="Görünür", kind="boolean"},
        {kind="group", label="Etkileşim"},
        {key="clickAction", label="Tık Aksiyonu", kind="enum", options=ACTION_TYPE_OPTIONS},
        {key="actionTarget", label="Hedef ID", kind="text"},
        {key="actionValue", label="Değer", kind="text"},
        {kind="group", label="Animasyon"},
        {key="animationType", label="Animasyon", kind="enum", options=ANIMATION_TYPE_OPTIONS},
        {key="animationTrigger", label="Tetik", kind="enum", options=ANIMATION_TRIGGER_OPTIONS},
        {key="animationDuration", label="Süre (ms)", kind="number"},
        {key="animationLoop", label="Döngü", kind="boolean"},
        {key="animationIntensity", label="Yoğunluk", kind="number"},
    },
    window = {
        {kind="group", label="İçerik"},
        {key="title",        label="Başlık",      kind="text"},
        {kind="group", label="Yazı Ayarları"},
        {key="fontScale",    label="Boyut",       kind="number"},
        {key="font",         label="Font",        kind="enum",    options=FONT_OPTIONS},
        {key="alignX",       label="Hiza X",      kind="enum",    options=ALIGN_X_OPTIONS},
        {key="alignY",       label="Hiza Y",      kind="enum",    options=ALIGN_Y_OPTIONS},
        {key="clip",         label="Kırp",        kind="boolean"},
        {key="wordBreak",    label="Kelime Sar",  kind="boolean"},
        {key="colorCoded",   label="Renk Kodu",   kind="boolean"},
        {kind="group", label="Pencere"},
        {key="headerHeight", label="Üst Yük.",    kind="number"},
        {key="titlePaddingX",label="İç Boşluk X", kind="number"},
        {kind="group", label="Renkler"},
        {key="headerColor",  label="Üst Renk",    kind="color"},
        {key="bodyColor",    label="Gövde Renk",  kind="color"},
        {key="textColor",    label="Yazı Renk",   kind="color"},
        {key="shadowColor",  label="Gölge Renk",  kind="color"},
        {key="shadowOffsetX",label="Gölge X",     kind="number"},
        {key="shadowOffsetY",label="Gölge Y",     kind="number"},
    },
    rectangle = {
        {kind="group", label="Görünüm"},
        {key="color",  label="Renk",   kind="color"},
        {key="radius", label="Yarıçap",kind="number"},
    },
    button = {
        {kind="group", label="İçerik"},
        {key="text",         label="Yazı",        kind="text"},
        {kind="group", label="Yazı Ayarları"},
        {key="fontScale",    label="Boyut",       kind="number"},
        {key="font",         label="Font",        kind="enum",   options=FONT_OPTIONS},
        {key="alignX",       label="Hiza X",      kind="enum",   options=ALIGN_X_OPTIONS},
        {key="alignY",       label="Hiza Y",      kind="enum",   options=ALIGN_Y_OPTIONS},
        {key="clip",         label="Kırp",        kind="boolean"},
        {key="wordBreak",    label="Kelime Sar",  kind="boolean"},
        {key="colorCoded",   label="Renk Kodu",   kind="boolean"},
        {kind="group", label="Görünüm"},
        {key="radius",       label="Yarıçap",     kind="number"},
        {key="color",        label="Temel Renk",  kind="color"},
        {key="hoverColor",   label="Hover Renk",  kind="color"},
        {key="textColor",    label="Yazı Renk",   kind="color"},
        {key="shadowColor",  label="Gölge Renk",  kind="color"},
        {key="shadowOffsetX",label="Gölge X",     kind="number"},
        {key="shadowOffsetY",label="Gölge Y",     kind="number"},
    },
    label = {
        {kind="group", label="İçerik"},
        {key="text",         label="Yazı",        kind="text"},
        {kind="group", label="Yazı Ayarları"},
        {key="fontScale",    label="Boyut",       kind="number"},
        {key="font",         label="Font",        kind="enum",   options=FONT_OPTIONS},
        {key="alignX",       label="Hiza X",      kind="enum",   options=ALIGN_X_OPTIONS},
        {key="alignY",       label="Hiza Y",      kind="enum",   options=ALIGN_Y_OPTIONS},
        {key="clip",         label="Kırp",        kind="boolean"},
        {key="wordBreak",    label="Kelime Sar",  kind="boolean"},
        {key="colorCoded",   label="Renk Kodu",   kind="boolean"},
        {kind="group", label="Renkler"},
        {key="textColor",    label="Yazı Renk",   kind="color"},
        {key="shadowColor",  label="Gölge Renk",  kind="color"},
        {key="shadowOffsetX",label="Gölge X",     kind="number"},
        {key="shadowOffsetY",label="Gölge Y",     kind="number"},
    },
    image = {
        {kind="group", label="Görsel"},
        {key="imagePath", label="Yol",     kind="text"},
        {key="color",     label="Ton",     kind="color"},
        {key="radius",    label="Yarıçap", kind="number"},
    },
    container = {
        {kind="group", label="Kapsayıcı"},
        {key="color",  label="Renk",    kind="color"},
        {key="radius", label="Yarıçap", kind="number"},
    },
    progressbar = {
        {kind="group", label="Doluluk"},
        {key="progress",      label="Yüzde",     kind="number"},
        {key="text",          label="Yazı",      kind="text"},
        {key="color",         label="Arka Plan", kind="color"},
        {key="progressColor", label="Dolgu",     kind="color"},
        {key="textColor",     label="Yazı Renk", kind="color"},
        {key="radius",        label="Yarıçap",   kind="number"},
    },
    checkbox = {
        {kind="group", label="Onay Kutusu"},
        {key="checked",    label="Seçili",    kind="boolean"},
        {key="text",       label="Yazı",      kind="text"},
        {key="boxColor",   label="Kutu",      kind="color"},
        {key="checkColor", label="Tik",       kind="color"},
        {key="textColor",  label="Yazı Renk", kind="color"},
        {key="fontScale",  label="Boyut",     kind="number"},
        {key="font",       label="Font",      kind="enum", options=FONT_OPTIONS},
    },
    editbox = {
        {kind="group", label="Metin Kutusu"},
        {key="text",        label="Metin",       kind="text"},
        {key="placeholder", label="Yer Tutucu",  kind="text"},
        {key="color",       label="Arka Plan",   kind="color"},
        {key="borderColor", label="Çerçeve",     kind="color"},
        {key="textColor",   label="Yazı",        kind="color"},
        {key="fontScale",   label="Boyut",       kind="number"},
        {key="font",        label="Font",        kind="enum", options=FONT_OPTIONS},
        {key="radius",      label="Yarıçap",     kind="number"},
        {key="masked",      label="Şifre",       kind="boolean"},
    },
    line = {
        {kind="group", label="Çizgi"},
        {key="color",     label="Renk",      kind="color"},
        {key="thickness", label="Kalınlık",  kind="number"},
    },
    gradient = {
        {kind="group", label="Gradyan"},
        {key="color",         label="Başlangıç", kind="color"},
        {key="gradientColor", label="Bitiş",     kind="color"},
        {key="gradientMode",  label="Yön",       kind="enum", options={"horizontal","vertical"}},
        {key="radius",        label="Yarıçap",   kind="number"},
    },
    icon = {
        {kind="group", label="İkon"},
        {key="iconName", label="Ikon",  kind="enum", options={"window","button","label","rectangle","image","circle","container","progressbar","checkbox","editbox","line","gradient","icon","save","load","code","copy","trash","layers","front","back","duplicate","clear","lock","eye_on","eye_off"}},
        {key="color",    label="Renk",  kind="color"},
        {key="iconSize", label="Boyut", kind="number"},
    },
    circle = {
        {kind="group", label="Görünüm"},
        {key="color",       label="Renk",         kind="color"},
        {key="borderColor", label="Çerçeve Renk", kind="color"},
        {key="borderWidth", label="Çerçeve Kaln.", kind="number"},
    },
}

local DEFAULT_STYLE_PRESETS = {
    {name="Primary Button", type="button", values={color={63,124,255,235}, hoverColor={92,150,255,245}, textColor={255,255,255,255}, radius=16, font="gilroy-semibold", fontScale=1}},
    {name="Danger Button", type="button", values={color={220,78,78,235}, hoverColor={240,98,98,245}, textColor={255,255,255,255}, radius=16}},
    {name="Panel Soft", type="rectangle", values={color={27,31,42,230}, radius=18}},
    {name="Panel Accent", type="window", values={headerColor={63,124,255,245}, bodyColor={18,22,30,235}, textColor={255,255,255,255}}},
    {name="Success Bar", type="progressbar", values={color={32,37,49,220}, progressColor={72,199,130,255}, radius=12, progress=68}},
}

local function rgba(color)
    if type(color) ~= "table" then return tocolor(255, 255, 255, 255) end
    return tocolor(color[1] or 255, color[2] or 255, color[3] or 255, color[4] or 255)
end

function snapToGrid(value, gridSize)
    if not editor.snapEnabled or not gridSize or gridSize <= 0 then return value end
    return round(value / gridSize) * gridSize
end

function insideRect(x, y, rx, ry, rw, rh)
    if not (x and y and rx and ry and rw and rh) then return false end
    return x >= rx and x <= rx + rw and y >= ry and y <= ry + rh
end

function escapeLuaString(value)
    value = tostring(value or "")
    value = value:gsub("\\","\\\\"):gsub("\r",""):gsub("\n","\\n"):gsub("\"","\\\"")
    return value
end

function trim(value)
    local str = tostring(value or ""):gsub("^%s+",""):gsub("%s+$","")
    return str
end

function deleteLastCharacter(value)
    if utf8 and utf8.len then
        local length = utf8.len(value)
        if not length or length <= 0 then return "" end
        return utf8.sub(value, 1, length - 1)
    end
    return string.sub(value, 1, math.max(#value - 1, 0))
end

function utfLen(s)
    if utf8 and utf8.len then
        local l = utf8.len(s)
        return l or #s
    end
    return #s
end

function utfSub(s, i, j)
    if utf8 and utf8.sub then return utf8.sub(s, i, j) end
    return string.sub(s, i, j)
end

function inputGetCursor(input)
    return input.cursor or utfLen(input.value)
end

function inputGetSelStart(input)
    return input.selStart
end

function inputGetSelEnd(input)
    return input.selEnd
end

function inputHasSelection(input)
    return input.selStart and input.selEnd and input.selStart ~= input.selEnd
end

function inputGetSelectedRange(input)
    if not inputHasSelection(input) then return nil, nil end
    local a, b = input.selStart, input.selEnd
    if a > b then a, b = b, a end
    return a, b
end

function inputDeleteSelection(input)
    local a, b = inputGetSelectedRange(input)
    if not a then return false end
    local text = input.value
    local before = a > 0 and utfSub(text, 1, a) or ""
    local after = utfSub(text, b + 1, utfLen(text))
    input.value = before .. after
    input.cursor = a
    input.selStart = nil
    input.selEnd = nil
    return true
end

function inputSetCursor(input, pos)
    local len = utfLen(input.value)
    input.cursor = clamp(pos, 0, len)
    editor.cursorBlink = getTickCount()
end

function inputClearSelection(input)
    input.selStart = nil
    input.selEnd = nil
end

function inputSelectAll(input)
    input.selStart = 0
    input.selEnd = utfLen(input.value)
    input.cursor = input.selEnd
    editor.cursorBlink = getTickCount()
end

function inputMoveCursor(input, delta, keepSelection)
    local oldCursor = inputGetCursor(input)
    local newCursor = clamp(oldCursor + delta, 0, utfLen(input.value))
    if keepSelection then
        if not input.selStart then
            input.selStart = oldCursor
        end
        input.selEnd = newCursor
    else
        if inputHasSelection(input) then
            if delta < 0 then
                local a, _ = inputGetSelectedRange(input)
                newCursor = a
            else
                local _, b = inputGetSelectedRange(input)
                newCursor = b
            end
        end
        inputClearSelection(input)
    end
    inputSetCursor(input, newCursor)
end

function inputHome(input, keepSelection)
    local oldCursor = inputGetCursor(input)
    if keepSelection then
        if not input.selStart then input.selStart = oldCursor end
        input.selEnd = 0
    else
        inputClearSelection(input)
    end
    inputSetCursor(input, 0)
end

function inputEnd(input, keepSelection)
    local oldCursor = inputGetCursor(input)
    local len = utfLen(input.value)
    if keepSelection then
        if not input.selStart then input.selStart = oldCursor end
        input.selEnd = len
    else
        inputClearSelection(input)
    end
    inputSetCursor(input, len)
end

function inputInsertText(input, text)
    inputDeleteSelection(input)
    local cursor = inputGetCursor(input)
    local before = cursor > 0 and utfSub(input.value, 1, cursor) or ""
    local after = utfSub(input.value, cursor + 1, utfLen(input.value))
    input.value = before .. text .. after
    inputSetCursor(input, cursor + utfLen(text))
end

function inputBackspace(input)
    if inputDeleteSelection(input) then return end
    local cursor = inputGetCursor(input)
    if cursor <= 0 then return end
    local before = cursor > 1 and utfSub(input.value, 1, cursor - 1) or ""
    local after = utfSub(input.value, cursor + 1, utfLen(input.value))
    input.value = before .. after
    inputSetCursor(input, cursor - 1)
end

function inputDelete(input)
    if inputDeleteSelection(input) then return end
    local cursor = inputGetCursor(input)
    local len = utfLen(input.value)
    if cursor >= len then return end
    local before = cursor > 0 and utfSub(input.value, 1, cursor) or ""
    local after = utfSub(input.value, cursor + 2, len)
    input.value = before .. after
end

function inputCopySelection(input)
    if not inputHasSelection(input) then return "" end
    local a, b = inputGetSelectedRange(input)
    return utfSub(input.value, a + 1, b)
end

local _frameCursorX, _frameCursorY = nil, nil
local _frameScreenW, _frameScreenH = 0, 0

function refreshFrameCache()
    local sw, sh = guiGetScreenSize()
    _frameScreenW, _frameScreenH = sw, sh
    if isCursorShowing() then
        local cx, cy = getCursorPosition()
        if cx and cy then
            _frameCursorX = cx * sw
            _frameCursorY = cy * sh
            return
        end
    end
    _frameCursorX, _frameCursorY = nil, nil
end

function getScreenCursor()
    return _frameCursorX, _frameCursorY
end

function hasVisibleColor(color)
    return type(color) == "table" and (color[4] or 255) > 0
end

function normalizeBoolean(value)
    local v = trim(value):lower()
    if v=="true" or v=="1" or v=="yes" or v=="on"  then return true  end
    if v=="false"or v=="0" or v=="no"  or v=="off" then return false end
    return nil
end

function normalizeEnumValue(value, options)
    local v = trim(value):lower()
    for _, opt in ipairs(options or {}) do
        if v == tostring(opt):lower() then return opt end
    end
    return nil
end

function formatBoolean(value)
    return value and "true" or "false"
end

function colorToString(color)
    return string.format("%d, %d, %d, %d", color[1], color[2], color[3], color[4] or 255)
end

function parseColorString(value)
    local hex = tostring(value):match("^#?(%x+)$")
    if hex then
        if #hex == 3 then
            return {tonumber(hex:sub(1,1):rep(2),16), tonumber(hex:sub(2,2):rep(2),16), tonumber(hex:sub(3,3):rep(2),16), 255}
        elseif #hex == 6 then
            return {tonumber(hex:sub(1,2),16), tonumber(hex:sub(3,4),16), tonumber(hex:sub(5,6),16), 255}
        elseif #hex == 8 then
            return {tonumber(hex:sub(1,2),16), tonumber(hex:sub(3,4),16), tonumber(hex:sub(5,6),16), tonumber(hex:sub(7,8),16)}
        end
    end
    local numbers = {}
    for chunk in tostring(value):gmatch("[^,]+") do
        numbers[#numbers+1] = tonumber(trim(chunk))
    end
    if #numbers == 3 then numbers[4] = 255 end
    if #numbers ~= 4 then return nil end
    for i = 1, 4 do
        if not numbers[i] then return nil end
        numbers[i] = clamp(round(numbers[i]), 0, 255)
    end
    return numbers
end

function destroyElementSvgCache(id)
    if roundedCache[id] then
        for _, widths in pairs(roundedCache[id]) do
            for _, heights in pairs(widths) do
                for _, svg in pairs(heights) do
                    if isElement(svg) then destroyElement(svg) end
                end
            end
        end
        roundedCache[id] = nil
    end
    if circleCache[id] then
        for _, svg in pairs(circleCache[id]) do
            if isElement(svg) then destroyElement(svg) end
        end
        circleCache[id] = nil
    end
end

function destroyRoundedCache()
    for id in pairs(roundedCache) do destroyElementSvgCache(id) end
    for id in pairs(circleCache)  do destroyElementSvgCache(id) end
    roundedCache = {}
    circleCache  = {}
end

function dxDrawRoundedRectangle(id, x, y, w, h, radius, color, postGUI)
    w      = math.max(1, round(w))
    h      = math.max(1, round(h))
    radius = clamp(round(radius or 0), 0, math.floor(math.min(w, h) / 2))
    if radius <= 0 then
        dxDrawRectangle(x, y, w, h, color, postGUI or false)
        return
    end
    roundedCache[id]    = roundedCache[id]    or {}
    roundedCache[id][w] = roundedCache[id][w] or {}
    roundedCache[id][w][h] = roundedCache[id][w][h] or {}
    if not roundedCache[id][w][h][radius] or not isElement(roundedCache[id][w][h][radius]) then
        local path = string.format(
            '<svg width="%d" height="%d" viewBox="0 0 %d %d" fill="none" xmlns="http://www.w3.org/2000/svg"><rect width="%d" height="%d" rx="%d" fill="#FFFFFF"/></svg>',
            w, h, w, h, w, h, radius)
        roundedCache[id][w][h][radius] = svgCreate(w, h, path)
    end
    if roundedCache[id][w][h][radius] then
        dxDrawImage(x, y, w, h, roundedCache[id][w][h][radius], 0, 0, 0, color, postGUI or false)
    end
end

function dxDrawEllipse(id, x, y, w, h, color, postGUI)
    w = math.max(1, round(w))
    h = math.max(1, round(h))
    local key = w .. "_" .. h
    circleCache[id] = circleCache[id] or {}
    if not circleCache[id][key] or not isElement(circleCache[id][key]) then
        local cx, cy, rx, ry = w/2, h/2, w/2, h/2
        local path = string.format(
            '<svg width="%d" height="%d" viewBox="0 0 %d %d" xmlns="http://www.w3.org/2000/svg"><ellipse cx="%.1f" cy="%.1f" rx="%.1f" ry="%.1f" fill="#FFFFFF"/></svg>',
            w, h, w, h, cx, cy, rx, ry)
        circleCache[id][key] = svgCreate(w, h, path)
    end
    if circleCache[id][key] then
        dxDrawImage(x, y, w, h, circleCache[id][key], 0, 0, 0, color, postGUI or false)
    end
end

function dxDrawGradientRect(id, x, y, w, h, colorA, colorB, vertical)
    local steps = vertical and math.max(8, round(h / 10)) or math.max(8, round(w / 10))
    for i = 0, steps - 1 do
        local t = i / math.max(1, steps - 1)
        local c = {
            lerp(colorA[1], colorB[1], t),
            lerp(colorA[2], colorB[2], t),
            lerp(colorA[3], colorB[3], t),
            lerp(colorA[4] or 255, colorB[4] or 255, t),
        }
        local col = tocolor(c[1], c[2], c[3], c[4] or 255)
        if vertical then
            local sy = y + (h / steps) * i
            dxDrawRectangle(x, sy, w, math.ceil(h / steps), col)
        else
            local sx = x + (w / steps) * i
            dxDrawRectangle(sx, y, math.ceil(w / steps), h, col)
        end
    end
end

local _fetchingUrls = {}
local _remoteTempCounter = 0

function getOrLoadTexture(path)
    if not path or path == "" then return nil end
    if imageCache[path] then
        if isElement(imageCache[path]) then return imageCache[path] end
        if imageCache[path] == "fetching" or imageCache[path] == "failed" then return nil end
        imageCache[path] = nil
    end

    if path:sub(1,7) == "http://" or path:sub(1,8) == "https://" then
        local cleanPath = path:match("^([^%?#]+)") or path
        local ext = cleanPath:match("%.(%w+)$")
        if ext then ext = ext:lower() end
        if ext == "webp" or ext == "svg" or ext == "gif" then
            outputChatBox("[DX UI Creator] Desteklenmeyen format (." .. ext .. "). PNG/JPG/BMP/DDS kullanın: " .. path, 214, 76, 76)
            imageCache[path] = "failed"
            return nil
        end

        if not _fetchingUrls[path] then
            _fetchingUrls[path] = true
            imageCache[path] = "fetching"
            triggerServerEvent("dxui:requestRemoteImage", localPlayer, path)
        end
        return nil
    end

    local tex = dxCreateTexture(path, "argb", true, "clamp")
    if tex then
        imageCache[path] = tex
    else
        imageCache[path] = "failed"
    end
    return tex
end

addEvent("dxui:receiveRemoteImage", true)
addEventHandler("dxui:receiveRemoteImage", localPlayer, function(url, responseData, ext)
    _fetchingUrls[url] = nil
    if responseData and type(responseData) == "string" and #responseData > 0 then
        _remoteTempCounter = _remoteTempCounter + 1
        local guessExt = ext or "png"
        if guessExt ~= "png" and guessExt ~= "jpg" and guessExt ~= "jpeg" and guessExt ~= "bmp" and guessExt ~= "dds" and guessExt ~= "tga" then
            guessExt = "png"
        end
        local tempPath = "_remote_" .. _remoteTempCounter .. "." .. guessExt
        local f = fileCreate(tempPath)
        if f then
            fileWrite(f, responseData)
            fileClose(f)
            local tex = dxCreateTexture(tempPath, "argb", true, "clamp")
            if tex then
                imageCache[url] = tex
                editor.panelDirty = true
            else
                outputChatBox("[DX UI Creator] Gorsel olusturulamadi: " .. url, 214, 76, 76)
                imageCache[url] = "failed"
            end
            fileDelete(tempPath)
        else
            imageCache[url] = "failed"
        end
    else
        outputChatBox("[DX UI Creator] Gorsel indirilemedi: " .. url, 214, 76, 76)
        imageCache[url] = "failed"
    end
end)

function drawStyledText(text, left, top, right, bottom, options)
    options = options or {}
    local font        = resolveFont(options.font or "default-bold")
    local scale       = options.fontScale or 1
    local alignX      = options.alignX or "left"
    local alignY      = options.alignY or "center"
    local clip        = options.clip or false
    local wordBreak   = options.wordBreak or false
    local postGUI     = options.postGUI or false
    local colorCoded  = options.colorCoded or false
    local shadowColor = options.shadowColor
    local sox         = options.shadowOffsetX or 1
    local soy         = options.shadowOffsetY or 1
    if hasVisibleColor(shadowColor) then
        dxDrawText(text, left+sox, top+soy, right+sox, bottom+soy, rgba(shadowColor), scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded)
    end
    dxDrawText(text, left, top, right, bottom, rgba(options.textColor or {255,255,255,255}), scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded)
end

local function buildPreviewTextOptions(element, scale)
    return {
        font         = element.font,
        fontScale    = (element.fontScale or 1) * scale,
        alignX       = element.alignX,
        alignY       = element.alignY,
        clip         = element.clip,
        wordBreak    = element.wordBreak,
        colorCoded   = element.colorCoded,
        textColor    = element.textColor,
        shadowColor  = element.shadowColor,
        shadowOffsetX= (element.shadowOffsetX or 1) * scale,
        shadowOffsetY= (element.shadowOffsetY or 1) * scale,
    }
end

local function easeOutQuad(t)
    t = clamp(t or 0, 0, 1)
    return 1 - (1 - t) * (1 - t)
end

local function modulateColorAlpha(color, alphaMultiplier)
    if type(color) ~= "table" then return color end
    return {
        color[1] or 255,
        color[2] or 255,
        color[3] or 255,
        clamp(round((color[4] or 255) * (alphaMultiplier or 1)), 0, 255),
    }
end

local function getElementAnimationProgress(element, hovered)
    local animType = element.animationType or "none"
    if animType == "none" then
        return nil, false
    end

    local trigger = element.animationTrigger or "auto"
    local duration = clamp(tonumber(element.animationDuration) or 1200, 120, 10000)
    local now = getTickCount()
    editor.runtimeStartTick = editor.runtimeStartTick or now
    editor.animationClickTicks = editor.animationClickTicks or {}

    if trigger == "hover" then
        local blend = animLerp("hover_anim_" .. element.id, hovered and 1 or 0, 12)
        return clamp(blend, 0, 1), false
    end

    if trigger == "click" then
        local started = editor.animationClickTicks[element.id]
        if not started then
            return 0, false
        end
        local t = clamp((now - started) / duration, 0, 1)
        if t >= 1 then
            editor.animationClickTicks[element.id] = nil
        end
        return t, t < 1
    end

    local elapsed = now - editor.runtimeStartTick
    if element.animationLoop then
        local phase = (elapsed % duration) / duration
        return phase, true
    end

    return clamp(elapsed / duration, 0, 1), elapsed < duration
end

local function getElementAnimatedRect(element, x, y, w, h, hovered)
    local animType = element.animationType or "none"
    if animType == "none" then
        return x, y, w, h, 1
    end

    local progress, looped = getElementAnimationProgress(element, hovered)
    if not progress then
        return x, y, w, h, 1
    end

    local intensity = clamp(tonumber(element.animationIntensity) or 18, 0, 100)
    local scale = 1
    local alpha = 1
    local offsetX = 0
    local offsetY = 0
    local wave = looped and (0.5 - 0.5 * math.cos(progress * math.pi * 2)) or math.sin(progress * math.pi)
    local eased = easeOutQuad(progress)

    if animType == "fade" then
        alpha = looped and (0.35 + wave * 0.65) or math.max(0.05, eased)
    elseif animType == "pulse" then
        scale = 1 + (intensity / 100) * (looped and wave or math.max(0, wave))
    elseif animType == "float" then
        local amp = (intensity / 100) * math.max(w, h) * 0.25
        offsetY = looped and (math.sin(progress * math.pi * 2) * amp) or (-wave * amp)
    elseif animType == "slide-left" then
        offsetX = looped and (-math.sin(progress * math.pi * 2) * intensity) or (-(1 - eased) * intensity)
    elseif animType == "slide-right" then
        offsetX = looped and (math.sin(progress * math.pi * 2) * intensity) or ((1 - eased) * intensity)
    elseif animType == "slide-up" then
        offsetY = looped and (-math.sin(progress * math.pi * 2) * intensity) or (-(1 - eased) * intensity)
    elseif animType == "slide-down" then
        offsetY = looped and (math.sin(progress * math.pi * 2) * intensity) or ((1 - eased) * intensity)
    elseif animType == "zoom" then
        local fromScale = 1 - intensity / 120
        scale = looped and (1 + (wave - 0.5) * (intensity / 100)) or lerp(fromScale, 1, eased)
    end

    local drawW = math.max(1, w * scale)
    local drawH = math.max(1, h * scale)
    local drawX = x - (drawW - w) / 2 + offsetX
    local drawY = y - (drawH - h) / 2 + offsetY
    return drawX, drawY, drawW, drawH, alpha
end

local function triggerElementAnimation(elementId)
    editor.animationClickTicks = editor.animationClickTicks or {}
    editor.animationClickTicks[elementId] = getTickCount()
end

local function executeElementAction(element)
    if not element then return false end

    local action = element.clickAction or "none"
    if action == "none" then return false end

    local targetId = trim(element.actionTarget or "")
    local target = targetId ~= "" and getElementById(targetId) or element

    if action == "toggle_visibility" then
        if target then
            target.visible = not (target.visible ~= false)
            markDirty()
            return true
        end
    elseif action == "show" then
        if target then
            target.visible = true
            markDirty()
            return true
        end
    elseif action == "hide" then
        if target then
            target.visible = false
            markDirty()
            return true
        end
    elseif action == "toggle_checkbox" then
        if target and target.type == "checkbox" then
            target.checked = not not (not target.checked)
            markDirty()
            return true
        end
    elseif action == "play_animation" then
        if target then
            triggerElementAnimation(target.id)
            return true
        end
    elseif action == "chat_message" then
        local msg = trim(element.actionValue or "")
        if msg ~= "" then
            outputChatBox("[DX UI Creator] " .. msg, 75, 144, 255, true)
            return true
        end
    elseif action == "trigger_event" then
        local evt = trim(element.actionValue or "")
        if evt ~= "" then
            triggerEvent("dxui:onElementClick", localPlayer, evt, element.id, targetId)
            outputChatBox("[DX UI Creator] Event tetiklendi: " .. evt, 115, 191, 136, true)
            return true
        end
    end

    return false
end

local function deepCopyElement(element)
    local clone = {}
    for key, value in pairs(element) do
        if type(value) == "table" then
            clone[key] = {}
            for i = 1, #value do clone[key][i] = value[i] end
        else
            clone[key] = value
        end
    end
    return clone
end

local function deepCopyElements(elements)
    local copy = {}
    for i, el in ipairs(elements) do copy[i] = deepCopyElement(el) end
    return copy
end

local function normalizeSelection()
    editor.selectedIds = editor.selectedIds or {}
    if editor.selectedId then
        editor.selectedIds[editor.selectedId] = true
    end
end

local function clearSelection()
    editor.selectedId = nil
    editor.selectedIds = {}
end

local function isElementSelected(id)
    return editor.selectedIds and editor.selectedIds[id] == true
end

local function getSelectedElements()
    local list = {}
    normalizeSelection()
    for _, el in ipairs(editor.elements) do
        if isElementSelected(el.id) then
            list[#list+1] = el
        end
    end
    if #list == 0 and editor.selectedId then
        for _, el in ipairs(editor.elements) do
            if el.id == editor.selectedId then
                list[1] = el
                break
            end
        end
    end
    return list
end

local function setSelection(ids, primaryId)
    editor.selectedIds = {}
    if type(ids) == "table" then
        for _, id in ipairs(ids) do
            if id then editor.selectedIds[id] = true end
        end
    elseif ids then
        editor.selectedIds[ids] = true
    end
    editor.selectedId = type(ids) == "table" and primaryId or (primaryId or ids)
    if not editor.selectedId then
        for id in pairs(editor.selectedIds) do editor.selectedId = id break end
    end
    if editor.activeInput and editor.activeInput.elementId ~= editor.selectedId then editor.activeInput = nil end
    editor.colorPicker = nil
    editor.inspectorScroll = 0
    editor.panelDirty = true
end

local function addToSelection(id, makePrimary)
    normalizeSelection()
    editor.selectedIds[id] = true
    if makePrimary or not editor.selectedId then
        editor.selectedId = id
    end
    editor.panelDirty = true
end

local function removeFromSelection(id)
    if not editor.selectedIds then return end
    editor.selectedIds[id] = nil
    if editor.selectedId == id then
        editor.selectedId = nil
        for keepId in pairs(editor.selectedIds) do editor.selectedId = keepId break end
    end
    editor.panelDirty = true
end

local function getElementById(id)
    for _, el in ipairs(editor.elements) do
        if el.id == id then return el end
    end
    return nil
end

local function getChildrenOf(parentId)
    local list = {}
    for _, el in ipairs(editor.elements) do
        if el.parentId == parentId then
            list[#list+1] = el
        end
    end
    return list
end

local function collectDescendants(parentId, out)
    out = out or {}
    for _, child in ipairs(getChildrenOf(parentId)) do
        if not out[child.id] then
            out[child.id] = child
            collectDescendants(child.id, out)
        end
    end
    return out
end

local function moveElementWithChildren(element, dx, dy, moved)
    moved = moved or {}
    if moved[element.id] then return end
    moved[element.id] = true
    local x, y = getElementCanvasRect(element)
    setElementCanvasPosition(element, x + dx, y + dy)
    for _, child in ipairs(getChildrenOf(element.id)) do
        moveElementWithChildren(child, dx, dy, moved)
    end
end

local function markDirty() editor.exportDirty = true; editor.panelDirty = true end

local function saveUndoState()
    undoStack[#undoStack+1] = {
        elements   = deepCopyElements(editor.elements),
        selectedId = editor.selectedId,
        selectedIds= deepCopyElement(editor.selectedIds or {}),
        nextId     = editor.nextId,
    }
    if #undoStack > MAX_UNDO then table.remove(undoStack, 1) end
    redoStack = {}
end

local function applyState(state)
    local existingIds = {}
    for _, el in ipairs(state.elements) do existingIds[el.id] = true end
    for _, el in ipairs(editor.elements) do
        if not existingIds[el.id] then destroyElementSvgCache(el.id) end
    end
    editor.elements   = deepCopyElements(state.elements)
    editor.selectedId = state.selectedId
    editor.selectedIds= deepCopyElement(state.selectedIds or {})
    editor.nextId     = state.nextId
    editor.activeInput  = nil
    editor.interaction  = nil
    editor.colorPicker  = nil
    markDirty()
end

local function undo()
    if #undoStack == 0 then outputChatBox("[DX UI Creator] Geri alınacak işlem yok.", 230,164,52,true); return end
    redoStack[#redoStack+1] = {elements=deepCopyElements(editor.elements), selectedId=editor.selectedId, selectedIds=deepCopyElement(editor.selectedIds or {}), nextId=editor.nextId}
    local state = undoStack[#undoStack]; table.remove(undoStack, #undoStack)
    applyState(state)
    outputChatBox("[DX UI Creator] Geri alındı. ("..#undoStack.." adım kaldı)", 75,144,255,true)
end

local function redo()
    if #redoStack == 0 then outputChatBox("[DX UI Creator] İleri alınacak işlem yok.", 230,164,52,true); return end
    undoStack[#undoStack+1] = {elements=deepCopyElements(editor.elements), selectedId=editor.selectedId, selectedIds=deepCopyElement(editor.selectedIds or {}), nextId=editor.nextId}
    local state = redoStack[#redoStack]; table.remove(redoStack, #redoStack)
    applyState(state)
    outputChatBox("[DX UI Creator] İleri alındı.", 75,144,255,true)
end

local function getLayout()
    local screenW, screenH = _frameScreenW, _frameScreenH
    if screenW == 0 then screenW, screenH = guiGetScreenSize() end
    local padding    = 0
    local topBarH    = 48
    local leftWidth  = 240
    local rightWidth = 280
    local middleW    = screenW - leftWidth - rightWidth
    local middleH    = screenH - topBarH
    local baseScale  = math.min(middleW / editor.canvas.width, middleH / editor.canvas.height)
    baseScale        = math.max(0.1, baseScale)

    local scale      = math.max(0.1, baseScale * editor.canvasZoom)
    local canvasW    = editor.canvas.width  * scale
    local canvasH    = editor.canvas.height * scale
    local canvasX    = leftWidth + math.max(0, (middleW - canvasW) / 2) + (editor.canvasPanX or 0)
    local canvasY    = topBarH  + math.max(0, (middleH - canvasH) / 2) + (editor.canvasPanY or 0)

    return {
        screenW = screenW, screenH = screenH,
        topBarH = topBarH,
        left   = {x=0,                    y=topBarH, w=leftWidth,  h=screenH-topBarH},
        right  = {x=screenW-rightWidth,   y=topBarH, w=rightWidth, h=screenH-topBarH},
        canvas = {x=canvasX, y=canvasY,   w=canvasW, h=canvasH,   scale=scale},
    }
end

local function canvasToScreen(layout, x, y, w, h)
    local s = layout.canvas.scale
    return layout.canvas.x + x*s, layout.canvas.y + y*s, w*s, h*s
end

local function screenToCanvas(layout, x, y)
    local s = layout.canvas.scale
    return (x - layout.canvas.x) / s, (y - layout.canvas.y) / s
end

local function getElementIndexById(id)
    for i, el in ipairs(editor.elements) do
        if el.id == id then return i end
    end
    return nil
end

local function getSelectedElement()
    if not editor.selectedId then return nil end
    local i = getElementIndexById(editor.selectedId)
    return i and editor.elements[i] or nil
end

local function setSelectedElement(id)
    if editor.selectedId ~= id then editor.inspectorScroll = 0; editor.panelDirty = true end
    editor.selectedId = id
    editor.selectedIds = {}
    if id then editor.selectedIds[id] = true end
    if editor.activeInput and editor.activeInput.elementId ~= id then editor.activeInput = nil end
    editor.colorPicker = nil
end

local function createDefaultElement(typeName)
    local id = string.format("%s_%d", typeName, editor.nextId)
    editor.nextId = editor.nextId + 1
    local el = {
        id=id, type=typeName,
        x=120, y=100, w=240, h=80,
        anchorX="left", anchorY="top",
        dockX="none", dockY="none", dockPaddingRight=0, dockPaddingBottom=0,
        relativeW=false, relativeH=false, wPercent=0, hPercent=0,
        fontScale=1, font="default-bold",
        alignX="left", alignY="center",
        clip=false, wordBreak=false, colorCoded=false,
        visible=true, shadowColor={0,0,0,0}, shadowOffsetX=1, shadowOffsetY=1,
        radius=0, locked=false, parentId="", groupId="",
        componentId="", componentInstanceOf="", componentDetached=false,
        clickAction="none", actionTarget="", actionValue="",
        animationType="none", animationTrigger="auto", animationDuration=1200, animationLoop=false, animationIntensity=18,
    }
    if typeName == "window" then
        el.w=360; el.h=240; el.title="Yeni Pencere"; el.fontScale=1.05
        el.headerHeight=40; el.titlePaddingX=16
        el.headerColor={52,120,240,240}; el.bodyColor={18,21,29,235}
        el.textColor={255,255,255,255}; el.shadowColor={0,0,0,120}
    elseif typeName == "rectangle" then
        el.w=260; el.h=120; el.color={97,178,111,230}; el.radius=18
    elseif typeName == "button" then
        el.w=220; el.h=54; el.text="Buton"; el.alignX="center"; el.alignY="center"
        el.radius=14; el.color={230,164,52,235}; el.hoverColor={247,191,92,245}
        el.textColor={28,25,20,255}; el.shadowColor={255,255,255,0}
    elseif typeName == "label" then
        el.w=260; el.h=60; el.text="Baslik"; el.fontScale=1; el.wordBreak=true
        el.textColor={255,255,255,255}; el.shadowColor={0,0,0,190}
    elseif typeName == "image" then
        el.w=240; el.h=160; el.imagePath=""; el.color={255,255,255,255}; el.radius=0
    elseif typeName == "container" then
        el.w=320; el.h=220; el.color={35,40,52,120}; el.radius=18
    elseif typeName == "progressbar" then
        el.w=260; el.h=28; el.progress=60; el.color={27,31,42,220}; el.progressColor={72,199,130,255}; el.text="60%"; el.textColor={255,255,255,255}; el.radius=12; el.alignX="center"
    elseif typeName == "checkbox" then
        el.w=220; el.h=28; el.checked=true; el.text="Checkbox"; el.boxColor={27,31,42,230}; el.checkColor={72,199,130,255}; el.textColor={255,255,255,255}; el.font="gilroy-medium"
    elseif typeName == "editbox" then
        el.w=260; el.h=42; el.text=""; el.placeholder="Bir sey yaz..."; el.color={20,24,32,235}; el.borderColor={63,124,255,150}; el.textColor={255,255,255,255}; el.font="gilroy-medium"; el.radius=12; el.masked=false
    elseif typeName == "line" then
        el.w=220; el.h=2; el.color={255,255,255,180}; el.thickness=2
    elseif typeName == "gradient" then
        el.w=260; el.h=100; el.color={63,124,255,240}; el.gradientColor={148,83,255,240}; el.gradientMode="horizontal"; el.radius=18
    elseif typeName == "icon" then
        el.w=42; el.h=42; el.color={255,255,255,255}; el.iconName="save"; el.iconSize=24
    elseif typeName == "circle" then
        el.w=120; el.h=120; el.color={97,178,111,230}
        el.borderColor={255,255,255,0}; el.borderWidth=0
    end
    return el
end

local function addElement(typeName)
    saveUndoState()
    local el = createDefaultElement(typeName)
    local offset = (#editor.elements % 6) * 24
    el.x = clamp(round((editor.canvas.width  - el.w) / 2) + offset, 0, editor.canvas.width  - el.w)
    el.y = clamp(round((editor.canvas.height - el.h) / 2) + offset, 0, editor.canvas.height - el.h)
    table.insert(editor.elements, el)
    setSelectedElement(el.id)
    updateAssetLibrary()
    markDirty()
end

function updateAssetLibrary()
    local seen = {}
    editor.assetLibrary = {}
    for _, el in ipairs(editor.elements) do
        if el.type == "image" and el.imagePath and el.imagePath ~= "" and not seen[el.imagePath] then
            seen[el.imagePath] = true
            editor.assetLibrary[#editor.assetLibrary+1] = el.imagePath
        end
    end
end

local function ensureStylePresets()
    if #editor.stylePresets == 0 then
        for _, preset in ipairs(DEFAULT_STYLE_PRESETS) do
            editor.stylePresets[#editor.stylePresets+1] = deepCopyElement(preset)
        end
    end
end

local function getSelectionBounds()
    local selected = getSelectedElements()
    if #selected == 0 then return nil end
    local minX, minY, maxX, maxY
    for _, el in ipairs(selected) do
        local x, y, w, h = getElementCanvasRect(el)
        minX = minX and math.min(minX, x) or x
        minY = minY and math.min(minY, y) or y
        maxX = maxX and math.max(maxX, x + w) or (x + w)
        maxY = maxY and math.max(maxY, y + h) or (y + h)
    end
    return minX, minY, maxX, maxY
end

local function distributeSelection(axis)
    local selected = getSelectedElements()
    if #selected < 3 then return end
    saveUndoState()
    table.sort(selected, function(a, b)
        local ax, ay = getElementCanvasRect(a)
        local bx, by = getElementCanvasRect(b)
        return axis == "x" and ax < bx or ay < by
    end)
    local first, last = selected[1], selected[#selected]
    local firstX, firstY, firstW, firstH = getElementCanvasRect(first)
    local lastX, lastY, lastW, lastH = getElementCanvasRect(last)
    local startPos = axis == "x" and firstX or firstY
    local endPos = axis == "x" and (lastX + lastW) or (lastY + lastH)
    local totalSize = 0
    for _, el in ipairs(selected) do
        totalSize = totalSize + (axis == "x" and el.w or el.h)
    end
    local gap = (endPos - startPos - totalSize) / math.max(1, (#selected - 1))
    local cursor = startPos
    for _, el in ipairs(selected) do
        local x, y = getElementCanvasRect(el)
        if axis == "x" then
            setElementCanvasPosition(el, cursor, y)
            cursor = cursor + el.w + gap
        else
            setElementCanvasPosition(el, x, cursor)
            cursor = cursor + el.h + gap
        end
    end
    markDirty()
end

local function applySameSize(axis)
    local selected = getSelectedElements()
    local primary = getSelectedElement()
    if #selected < 2 or not primary then return end
    saveUndoState()
    for _, el in ipairs(selected) do
        if el.id ~= primary.id then
            if axis == "w" then el.w = primary.w else el.h = primary.h end
        end
    end
    markDirty()
end

local function groupSelection()
    local selected = getSelectedElements()
    if #selected < 2 then return end
    saveUndoState()
    local groupId = "group_" .. tostring(editor.nextId)
    for _, el in ipairs(selected) do
        el.groupId = groupId
    end
    markDirty()
end

local function ungroupSelection()
    local selected = getSelectedElements()
    if #selected == 0 then return end
    saveUndoState()
    for _, el in ipairs(selected) do
        el.groupId = ""
    end
    markDirty()
end

local function parentSelectionToPrimary()
    local primary = getSelectedElement()
    local selected = getSelectedElements()
    if not primary or #selected < 2 then return end
    saveUndoState()
    for _, el in ipairs(selected) do
        if el.id ~= primary.id then
            el.parentId = primary.id
        end
    end
    markDirty()
end

local function clearParentFromSelection()
    local selected = getSelectedElements()
    if #selected == 0 then return end
    saveUndoState()
    for _, el in ipairs(selected) do
        el.parentId = ""
    end
    markDirty()
end

local function copySelectedStyle()
    local sel = getSelectedElement()
    if not sel then return end
    local style = {}
    for key, value in pairs(sel) do
        if key ~= "id" and key ~= "type" and key ~= "x" and key ~= "y" and key ~= "w" and key ~= "h"
            and key ~= "parentId" and key ~= "groupId" and key ~= "locked" and key ~= "visible" then
            style[key] = type(value) == "table" and deepCopyElement(value) or value
        end
    end
    editor.clipboardStyle = {type = sel.type, values = style}
    outputChatBox("[DX UI Creator] Stil kopyalandi.", 75,144,255,true)
end

local function pasteSelectedStyle()
    if not editor.clipboardStyle then return end
    local selected = getSelectedElements()
    if #selected == 0 then return end
    saveUndoState()
    for _, el in ipairs(selected) do
        for key, value in pairs(editor.clipboardStyle.values) do
            el[key] = type(value) == "table" and deepCopyElement(value) or value
        end
    end
    markDirty()
end

local function applyStylePreset(index)
    local preset = editor.stylePresets[index]
    local selected = getSelectedElements()
    if not preset or #selected == 0 then return end
    saveUndoState()
    for _, el in ipairs(selected) do
        if not preset.type or el.type == preset.type then
            for key, value in pairs(preset.values) do
                el[key] = type(value) == "table" and deepCopyElement(value) or value
            end
        end
    end
    markDirty()
end

local function savePrefabFromSelection()
    local selected = getSelectedElements()
    if #selected == 0 then return end
    local minX, minY = getSelectionBounds()
    local items = {}
    for _, el in ipairs(selected) do
        local clone = deepCopyElement(el)
        local x, y = getElementCanvasRect(el)
        clone.anchorX = "left"
        clone.anchorY = "top"
        clone.x = x - minX
        clone.y = y - minY
        items[#items+1] = clone
    end
    editor.prefabList[#editor.prefabList+1] = {
        name = "prefab_" .. tostring(#editor.prefabList + 1),
        items = items,
    }
    outputChatBox("[DX UI Creator] Prefab kaydedildi.", 115,191,136,true)
end

local function spawnPrefab(index)
    local prefab = editor.prefabList[index]
    if not prefab then return end
    saveUndoState()
    local created = {}
    local idMap = {}
    local clones = {}
    for _, item in ipairs(prefab.items) do
        local clone = deepCopyElement(item)
        local newId = string.format("%s_%d", clone.type, editor.nextId)
        idMap[clone.id] = newId
        clone.id = newId
        editor.nextId = editor.nextId + 1
        clone.x = clone.x + 80
        clone.y = clone.y + 80
        created[#created+1] = clone.id
        clones[#clones+1] = clone
        table.insert(editor.elements, clone)
    end
    for _, el in ipairs(clones) do
        if idMap[el.parentId] then el.parentId = idMap[el.parentId] end
        if el.groupId and el.groupId ~= "" then
            el.groupId = el.groupId .. "_" .. tostring(editor.nextId)
        end
    end
    setSelection(created, created[#created])
    updateAssetLibrary()
    markDirty()
end

local function moveSelectedLayer(direction)
    local i = getElementIndexById(editor.selectedId)
    if not i then return end
    saveUndoState()
    local el = editor.elements[i]
    if direction == "front" then
        table.remove(editor.elements, i)
        table.insert(editor.elements, el)
    elseif direction == "back" then
        table.remove(editor.elements, i)
        table.insert(editor.elements, 1, el)
    elseif direction == "up" then
        if i < #editor.elements then
            editor.elements[i], editor.elements[i+1] = editor.elements[i+1], editor.elements[i]
        end
    elseif direction == "down" then
        if i > 1 then
            editor.elements[i], editor.elements[i-1] = editor.elements[i-1], editor.elements[i]
        end
    end
    markDirty()
end

local function duplicateSelected()
    local selected = getSelectedElements()
    if #selected == 0 then return end
    saveUndoState()
    local created = {}
    local idMap = {}
    local clones = {}
    for _, sel in ipairs(selected) do
        if not sel.locked then
            local clone = deepCopyElement(sel)
            local oldId = clone.id
            clone.id = string.format("%s_%d", clone.type, editor.nextId)
            idMap[oldId] = clone.id
            editor.nextId = editor.nextId + 1
            clone.x = clamp(clone.x + 20, 0, editor.canvas.width  - clone.w)
            clone.y = clamp(clone.y + 20, 0, editor.canvas.height - clone.h)
            clone.locked = false
            table.insert(editor.elements, clone)
            clones[#clones+1] = clone
            created[#created+1] = clone.id
        end
    end
    for _, clone in ipairs(clones) do
        if clone.parentId and idMap[clone.parentId] then
            clone.parentId = idMap[clone.parentId]
        end
        if clone.groupId and clone.groupId ~= "" then
            clone.groupId = clone.groupId .. "_" .. tostring(editor.nextId)
        end
    end
    if #created > 0 then
        setSelection(created, created[#created])
    end
    markDirty()
end

local function copySelectedElements()
    local selected = getSelectedElements()
    if #selected == 0 then return end
    local minX, minY = nil, nil
    for _, el in ipairs(selected) do
        local x, y = getElementCanvasRect(el)
        minX = minX and math.min(minX, x) or x
        minY = minY and math.min(minY, y) or y
    end
    local copies = {}
    for _, el in ipairs(selected) do
        local clone = deepCopyElement(el)
        local x, y = getElementCanvasRect(el)
        clone._origId = clone.id
        clone.anchorX = "left"
        clone.anchorY = "top"
        clone.x = x - minX
        clone.y = y - minY
        copies[#copies+1] = clone
    end
    editor.clipboardElements = copies
    outputChatBox("[DX UI Creator] " .. #copies .. " eleman kopyalandi. (Ctrl+V ile yapistir)", 75,144,255,true)
end

local function pasteClipboardElements()
    if not editor.clipboardElements or #editor.clipboardElements == 0 then
        outputChatBox("[DX UI Creator] Pano bos. Once Ctrl+C ile kopyala.", 230,164,52,true)
        return
    end
    saveUndoState()
    local created = {}
    local idMap = {}
    local clones = {}
    local centerX = round(editor.canvas.width / 2)
    local centerY = round(editor.canvas.height / 2)
    local totalW, totalH = 0, 0
    for _, item in ipairs(editor.clipboardElements) do
        totalW = math.max(totalW, item.x + item.w)
        totalH = math.max(totalH, item.y + item.h)
    end
    local offsetX = clamp(round(centerX - totalW / 2), 0, editor.canvas.width - 20)
    local offsetY = clamp(round(centerY - totalH / 2), 0, editor.canvas.height - 20)
    for _, item in ipairs(editor.clipboardElements) do
        local clone = deepCopyElement(item)
        local newId = string.format("%s_%d", clone.type, editor.nextId)
        idMap[clone._origId or clone.id] = newId
        clone._origId = nil
        clone.id = newId
        editor.nextId = editor.nextId + 1
        clone.x = clamp(clone.x + offsetX, 0, editor.canvas.width - clone.w)
        clone.y = clamp(clone.y + offsetY, 0, editor.canvas.height - clone.h)
        clone.locked = false
        created[#created+1] = clone.id
        clones[#clones+1] = clone
        table.insert(editor.elements, clone)
    end
    for _, el in ipairs(clones) do
        if el.parentId and idMap[el.parentId] then el.parentId = idMap[el.parentId] end
        if el.groupId and el.groupId ~= "" then
            el.groupId = el.groupId .. "_" .. tostring(editor.nextId)
        end
    end
    if #created > 0 then
        setSelection(created, created[#created])
    end
    updateAssetLibrary()
    markDirty()
    outputChatBox("[DX UI Creator] " .. #created .. " eleman yapistirildi.", 115,191,136,true)
end

local function deleteSelected()
    local selected = getSelectedElements()
    if #selected == 0 then return end
    saveUndoState()
    local deleteMap = {}
    for _, el in ipairs(selected) do
        if el.locked then
            outputChatBox("[DX UI Creator] Kilitli elemanlar silinmedi.", 230,164,52,true)
        else
            deleteMap[el.id] = true
            local descendants = collectDescendants(el.id)
            for id in pairs(descendants) do deleteMap[id] = true end
        end
    end
    for i = #editor.elements, 1, -1 do
        local el = editor.elements[i]
        if deleteMap[el.id] then
            destroyElementSvgCache(el.id)
            table.remove(editor.elements, i)
        end
    end
    clearSelection()
    updateAssetLibrary()
    markDirty()
end

local function clearCanvas()
    saveUndoState()
    editor.elements = {}
    clearSelection()
    editor.activeInput = nil
    editor.interaction = nil
    editor.colorPicker = nil
    destroyRoundedCache()
    updateAssetLibrary()
    markDirty()
end

local _lastArrowUndoTime = 0
local function moveSelectedBy(ox, oy)
    local selected = getSelectedElements()
    if #selected == 0 then return end
    local now = getTickCount()
    if now - _lastArrowUndoTime > 500 then
        saveUndoState()
        _lastArrowUndoTime = now
    end
    local moved = {}
    for _, el in ipairs(selected) do
        if not el.locked then
            moveElementWithChildren(el, ox, oy, moved)
        end
    end
    markDirty()
end

local function alignSelected(mode)
    local selected = getSelectedElements()
    if #selected == 0 then return end
    saveUndoState()
    local cw, ch = editor.canvas.width, editor.canvas.height
    local minX, minY, maxX, maxY = getSelectionBounds()
    local refX = (mode == "centerX" and round((cw - (maxX-minX)) / 2)) or (mode == "right" and (cw - (maxX-minX))) or 0
    local refY = (mode == "centerY" and round((ch - (maxY-minY)) / 2)) or (mode == "bottom" and (ch - (maxY-minY))) or 0
    for _, el in ipairs(selected) do
        if not el.locked then
            local x, y = getElementCanvasRect(el)
            if     mode == "left"    then setElementCanvasPosition(el, x - minX, y)
            elseif mode == "centerX" then setElementCanvasPosition(el, refX + (x - minX), y)
            elseif mode == "right"   then setElementCanvasPosition(el, refX + (x - minX), y)
            elseif mode == "top"     then setElementCanvasPosition(el, x, y - minY)
            elseif mode == "centerY" then setElementCanvasPosition(el, x, refY + (y - minY))
            elseif mode == "bottom"  then setElementCanvasPosition(el, x, refY + (y - minY))
            end
        end
    end
    markDirty()
end

local function addHotbox(kind, x, y, w, h, data)
    editor.hotboxes[#editor.hotboxes+1] = {kind=kind, x=x, y=y, w=w, h=h, data=data}
end

function drawOutline(x, y, w, h, color, thickness)
    thickness = thickness or 1
    dxDrawRectangle(x, y, w, thickness, color)
    dxDrawRectangle(x, y+h-thickness, w, thickness, color)
    dxDrawRectangle(x, y, thickness, h, color)
    dxDrawRectangle(x+w-thickness, y, thickness, h, color)
end

local TOOLTIPS = {
    bring_front="En öne taşır", send_back="En arkaya taşır",
    layer_up="Bir katman yukarı", layer_down="Bir katman aşağı",
    duplicate_selected="Seçili elemanı kopyala (Ctrl+D)",
    delete_selected="Seçili elemanı sil (Del)",
    clear_canvas="Tüm elemanları temizle",
    save_project="Projeyi kaydet (Ctrl+S)", load_project="Kayıtlı projeyi yükle",
    export_to_file="Lua dosyasına aktar", copy_export="Export kodunu kopyala (Ctrl+Shift+C)",
    add_window="Yeni pencere ekle", add_button="Yeni buton ekle",
    add_label="Yeni yazı ekle", add_rectangle="Yeni dikdörtgen ekle",
    add_image="Yeni resim ekle", add_circle="Yeni daire ekle",
    align_left="Sola hizala", align_centerX="Yatay ortala", align_right="Sağa hizala",
    align_top="Yukarı hizala", align_centerY="Dikey ortala", align_bottom="Aşağı hizala",
    ungroup_selection="Grubu çöz (Ctrl+Shift+U)",
    clear_parent="Parent bağını kaldır",
    distribute_x="Elemanları yatayda eşit dağıt",
    distribute_y="Elemanları dikeyde eşit dağıt",
    same_width="Tüm seçililere aynı genişlik",
    same_height="Tüm seçililere aynı yükseklik",
    preview_mode="Önizleme modunu aç/kapat (P)",
    group_selection="Seçilileri grupla (Ctrl+Shift+G)",
    parent_selection="Birincil elemana parent yap",
    copy_style="Seçili elemanın stilini kopyala (Ctrl+Shift+S)",
    paste_style="Kopyalanan stili yapıştır (Ctrl+Shift+V)",
}

function drawTooltip()
    local cx, cy = getScreenCursor()
    if not cx then editor.tooltip = nil; return end
    local foundTip = nil
    for i = #editor.hotboxes, 1, -1 do
        local hb = editor.hotboxes[i]
        if hb.kind == "action" and insideRect(cx, cy, hb.x, hb.y, hb.w, hb.h) then
            foundTip = TOOLTIPS[hb.data.action]
            break
        end
    end
    if foundTip then
        if editor.tooltip ~= foundTip then
            editor.tooltip = foundTip
            editor.tooltipTime = getTickCount()
        end
        local elapsed = getTickCount() - editor.tooltipTime
        if elapsed > 400 then
            local tw = dxGetTextWidth(foundTip, 1, UI_FONT_MEDIUM_XS) + 16
            local th = 22
            local tx = math.min(cx + 12, _frameScreenW - tw - 8)
            local ty = cy - th - 6
            if ty < 4 then ty = cy + 20 end
            dxDrawUiRounded("tooltip_bg", tx, ty, tw, th, 5, tocolor(10,10,14,230))
            drawOutline(tx, ty, tw, th, tocolor(60,60,72,180), 1)
            dxDrawText(foundTip, tx+8, ty, tx+tw-8, ty+th, tocolor(220,220,230,255), 1, UI_FONT_MEDIUM_XS, "left", "center", false, false, false)
        end
    else
        editor.tooltip = nil
    end
end

local function buildPropertyList(element)
    local props = {}
    for _, p in ipairs(PROPERTY_DEFS.common) do props[#props+1] = p end
    local extra = PROPERTY_DEFS[element.type]
    if extra then for _, p in ipairs(extra) do props[#props+1] = p end end
    return props
end

local function getPropertyValueString(element, property)
    if property.kind == "rename" then return element.id end
    local value = element[property.key]
    if property.kind == "color"   then return colorToString(value or {255,255,255,255}) end
    if property.kind == "number"  then
        if property.key == "fontScale" then return string.format("%.2f", value or 1) end
        return tostring(round(value or 0))
    end
    if property.kind == "boolean" then return formatBoolean(value) end
    return tostring(value or "")
end

local function beginPropertyInput(property)
    local el = getSelectedElement()
    if not el then return end
    if property.kind == "color" then
        local color = el[property.key] or {255, 255, 255, 255}
        editor.colorPicker = {
            elementId = el.id,
            key       = property.key,
            r = color[1], g = color[2], b = color[3], a = color[4] or 255,
        }
        editor.activeInput = nil
        editor.enumDropdown = nil
        return
    end
    if property.kind == "enum" then
        editor.colorPicker = nil
        editor.activeInput = nil
        if editor.enumDropdown and editor.enumDropdown.elementId == el.id and editor.enumDropdown.key == property.key then
            editor.enumDropdown = nil
        else
            editor.enumDropdown = {
                elementId = el.id,
                key = property.key,
                options = property.options,
                scroll = 0,
            }
        end
        return
    end
    editor.colorPicker = nil
    editor.enumDropdown = nil
    local val = getPropertyValueString(el, property)
    local len = utfLen(val)
    editor.activeInput = {
        elementId = el.id,
        key       = property.key,
        kind      = property.kind,
        value     = val,
        originalValue = val,
        fresh     = true,
        cursor    = len,
        selStart  = 0,
        selEnd    = len,
    }
    editor.cursorBlink = getTickCount()
end

local function cancelActiveInput()
    editor.activeInput = nil
    editor.panelDirty = true
    return true
end

local function commitActiveInput()
    if not editor.activeInput then return true end
    local input = editor.activeInput
    local el    = getSelectedElement()
    if not el or el.id ~= input.elementId then editor.activeInput = nil; return true end

    local rawValue  = trim(input.value)
    if input.originalValue and rawValue == input.originalValue then
        editor.activeInput = nil
        return true
    end
    local finalValue = rawValue

    if input.kind == "rename" then
        local newId = trim(rawValue)
        if newId == "" then
            outputChatBox("[DX UI Creator] ID boş olamaz.", 214,76,76,true); return false
        end
        for _, other in ipairs(editor.elements) do
            if other.id == newId and other.id ~= el.id then
                outputChatBox("[DX UI Creator] Bu ID zaten kullanılıyor.", 214,76,76,true); return false
            end
        end
        saveUndoState()
        destroyElementSvgCache(el.id)
        if editor.selectedIds and editor.selectedIds[input.elementId] then
            editor.selectedIds[input.elementId] = nil
            editor.selectedIds[newId] = true
        end
        el.id = newId
        if editor.selectedId == input.elementId then editor.selectedId = newId end
        editor.activeInput = nil
        markDirty()
        return true
    elseif input.kind == "number" then
        finalValue = tonumber(rawValue)
        if not finalValue then outputChatBox("[DX UI Creator] Sayisal alan gecersiz.", 214,76,76,true); return false end
        if input.key == "fontScale" then finalValue = clamp(finalValue, 0.4, 4)
        else finalValue = round(finalValue) end
    elseif input.kind == "color" then
        finalValue = parseColorString(rawValue)
        if not finalValue then outputChatBox("[DX UI Creator] Format: 255,255,255,255 veya #RRGGBB", 214,76,76,true); return false end
    elseif input.kind == "boolean" then
        finalValue = normalizeBoolean(rawValue)
        if finalValue == nil then outputChatBox("[DX UI Creator] true/false yaz.", 214,76,76,true); return false end
    elseif input.kind == "enum" then
        local options
        for _, p in ipairs(buildPropertyList(el)) do
            if p.key == input.key then options = p.options; break end
        end
        finalValue = normalizeEnumValue(rawValue, options)
        if not finalValue then outputChatBox("[DX UI Creator] Gecerli secenek gir.", 214,76,76,true); return false end
    end

    local oldX, oldY, oldW, oldH = getElementCanvasRect(el)
    saveUndoState()
    el[input.key] = finalValue

    if     input.key == "w"            then
        if el.relativeW then
            el.wPercent = clamp((finalValue / editor.canvas.width) * 100, 1, 100)
        end
        if (el.dockX or "none") == "fill" then
            el.dockPaddingRight = clamp(editor.canvas.width - oldX - finalValue, 0, editor.canvas.width)
        end
        el.w = clamp(el.w, 20, editor.canvas.width  - oldX)
    elseif input.key == "h"            then
        if el.relativeH then
            el.hPercent = clamp((finalValue / editor.canvas.height) * 100, 1, 100)
        end
        if (el.dockY or "none") == "fill" then
            el.dockPaddingBottom = clamp(editor.canvas.height - oldY - finalValue, 0, editor.canvas.height)
        end
        el.h = clamp(el.h, 20, editor.canvas.height - oldY)
    elseif input.key == "x"            then
        if (el.anchorX or "left") == "center" then
            el.x = clamp(el.x, -math.floor((editor.canvas.width - el.w) / 2), math.floor((editor.canvas.width - el.w) / 2))
        else
            el.x = clamp(el.x, 0, editor.canvas.width - el.w)
        end
    elseif input.key == "y"            then
        if (el.anchorY or "top") == "center" then
            el.y = clamp(el.y, -math.floor((editor.canvas.height - el.h) / 2), math.floor((editor.canvas.height - el.h) / 2))
        else
            el.y = clamp(el.y, 0, editor.canvas.height - el.h)
        end
    elseif input.key == "anchorX" or input.key == "anchorY" then
        setElementCanvasPosition(el, oldX, oldY)
    elseif input.key == "dockX" then
        if el.dockX == "fill" then
            el.anchorX = "left"
            el.x = oldX
            el.dockPaddingRight = clamp(editor.canvas.width - oldX - oldW, 0, editor.canvas.width)
        else
            el.w = oldW
            setElementCanvasPosition(el, oldX, oldY)
        end
    elseif input.key == "dockY" then
        if el.dockY == "fill" then
            el.anchorY = "top"
            el.y = oldY
            el.dockPaddingBottom = clamp(editor.canvas.height - oldY - oldH, 0, editor.canvas.height)
        else
            el.h = oldH
            setElementCanvasPosition(el, oldX, oldY)
        end
    elseif input.key == "dockPaddingRight" then
        el.dockPaddingRight = clamp(el.dockPaddingRight or 0, 0, editor.canvas.width)
    elseif input.key == "dockPaddingBottom" then
        el.dockPaddingBottom = clamp(el.dockPaddingBottom or 0, 0, editor.canvas.height)
    elseif input.key == "relativeW" then
        if el.relativeW then
            el.wPercent = clamp((oldW / editor.canvas.width) * 100, 1, 100)
        else
            el.w = oldW
        end
    elseif input.key == "relativeH" then
        if el.relativeH then
            el.hPercent = clamp((oldH / editor.canvas.height) * 100, 1, 100)
        else
            el.h = oldH
        end
    elseif input.key == "wPercent" then
        el.wPercent = clamp(el.wPercent or 0, 1, 100)
        el.relativeW = true
    elseif input.key == "hPercent" then
        el.hPercent = clamp(el.hPercent or 0, 1, 100)
        el.relativeH = true
    elseif input.key == "radius"       then el.radius       = clamp(el.radius, 0, math.floor(math.min(el.w, el.h)/2))
    elseif input.key == "headerHeight" then el.headerHeight = clamp(el.headerHeight, 24, math.max(24, el.h))
    elseif input.key == "titlePaddingX"then el.titlePaddingX= clamp(el.titlePaddingX, 0, math.floor(el.w/2))
    elseif input.key == "borderWidth"  then el.borderWidth  = clamp(el.borderWidth, 0, 100)
    end

    normalizeElementLayout(el)

    if input.key == "imagePath" then
        updateAssetLibrary()
    end
    editor.activeInput = nil
    markDirty()
    return true
end

local COLOR_PICKER_W = 220
local COLOR_PICKER_H = 260

local function commitColorPicker()
    if not editor.colorPicker then return end
    local cp = editor.colorPicker
    local el = getSelectedElement()
    if not el or el.id ~= cp.elementId then editor.colorPicker = nil; return end
    saveUndoState()
    el[cp.key] = {cp.r, cp.g, cp.b, cp.a}
    local newColor = {cp.r, cp.g, cp.b, cp.a}
    local isDuplicate = false
    for _, rc in ipairs(editor.recentColors) do
        if rc[1]==newColor[1] and rc[2]==newColor[2] and rc[3]==newColor[3] and rc[4]==newColor[4] then isDuplicate=true; break end
    end
    if not isDuplicate then
        table.insert(editor.recentColors, 1, newColor)
        if #editor.recentColors > 12 then table.remove(editor.recentColors) end
    end
    markDirty()
end

function drawColorPicker(screenW, screenH)
    if not editor.colorPicker then return end
    local cp = editor.colorPicker

    local px = screenW - 360 - 16 - COLOR_PICKER_W - 8
    local py = 180

    local channels = {
        {label="R", key="r", val=cp.r, barColor={255,80,80,255}},
        {label="G", key="g", val=cp.g, barColor={80,200,80,255}},
        {label="B", key="b", val=cp.b, barColor={80,130,255,255}},
        {label="A", key="a", val=cp.a, barColor={200,200,200,255}},
    }

    local barX  = px + 36
    local barW  = COLOR_PICKER_W - 56
    local barH  = 18
    local slotH = 32

    for i, ch in ipairs(channels) do
        local rowY = py + 30 + (i-1) * slotH
        addHotbox("color_slider", barX, rowY, barW, barH, {channel=ch.key, barX=barX, barW=barW})
    end
    addHotbox("color_picker_bg", px, py, COLOR_PICKER_W, COLOR_PICKER_H, {})

    if _skipPanelDraw then return end

    dxDrawUiRounded("cpicker_bg", px, py, COLOR_PICKER_W, COLOR_PICKER_H, 8, tocolor(18,21,30,250))
    dxDrawUiRounded("cpicker_hdr", px, py, COLOR_PICKER_W, 26, 0, themeColors.accent)
    dxDrawText("Renk Seçici  [Kapat: Esc]", px+10, py, px+COLOR_PICKER_W-10, py+26, themeColors.text, 1, UI_FONT_BOLD_SM, "left", "center", false, false, false)

    for i, ch in ipairs(channels) do
        local rowY = py + 30 + (i-1) * slotH
        dxDrawText(ch.label, px+8, rowY, px+36, rowY+barH, themeColors.muted, 1, UI_FONT_BOLD_SM, "center", "center", false, false, false)
        dxDrawUiRounded("cbar_bg_"..ch.key, barX, rowY, barW, barH, 4, tocolor(32,37,49,255))
        local fillW = round((ch.val / 255) * barW)
        if fillW > 0 then
            dxDrawUiRounded("cbar_"..ch.key, barX, rowY, fillW, barH, 4, rgba(ch.barColor))
        end
        dxDrawText(tostring(ch.val), barX+barW+6, rowY, barX+barW+26, rowY+barH, themeColors.text, 1, UI_FONT_BOLD_SM, "left", "center", false, false, false)
    end

    local previewY = py + 30 + 4 * slotH + 4
    dxDrawUiRounded("cpicker_preview", px+8, previewY, COLOR_PICKER_W-16, 20, 4, tocolor(cp.r, cp.g, cp.b, cp.a))
    dxDrawText(string.format("rgba(%d,%d,%d,%d)", cp.r,cp.g,cp.b,cp.a), px+8, previewY, px+COLOR_PICKER_W-8, previewY+20, tocolor(255,255,255,180), 1, UI_FONT_MEDIUM_XS, "center", "center", false, false, false)

    local hexY = previewY + 24
    local hexStr = string.format("#%02X%02X%02X%02X", cp.r, cp.g, cp.b, cp.a)
    dxDrawUiRounded("cpicker_hex", px+8, hexY, COLOR_PICKER_W-16, 22, 4, tocolor(32,37,49,255))
    dxDrawText(hexStr, px+8, hexY, px+COLOR_PICKER_W-8, hexY+22, themeColors.text, 1, UI_FONT_BOLD_SM, "center", "center", false, false, false)
    addHotbox("color_hex_copy", px+8, hexY, COLOR_PICKER_W-16, 22, {hex=hexStr})

    if #editor.recentColors > 0 and not _skipPanelDraw then
        local rcY = hexY + 28
        dxDrawText("Son Kullanilan:", px+8, rcY, px+COLOR_PICKER_W-8, rcY+14, themeColors.muted, 1, UI_FONT_MEDIUM_XS, "left", "top", false, false, false)
        rcY = rcY + 16
        local swSize = 18
        local swGap = 4
        local maxPerRow = math.floor((COLOR_PICKER_W - 16) / (swSize + swGap))
        for i, rc in ipairs(editor.recentColors) do
            local col2 = (i-1) % maxPerRow
            local row2 = math.floor((i-1) / maxPerRow)
            local rcX2 = px + 8 + col2 * (swSize + swGap)
            local rcY2 = rcY + row2 * (swSize + swGap)
            dxDrawUiRounded("rc_" .. i, rcX2, rcY2, swSize, swSize, 3, tocolor(rc[1], rc[2], rc[3], rc[4] or 255))
            addHotbox("recent_color", rcX2, rcY2, swSize, swSize, {r=rc[1], g=rc[2], b=rc[3], a=rc[4] or 255})
        end
    end
end

local SAVE_FILE   = "dxui_save.xml"
local EXPORT_FILE = "dxui_export.lua"
local PREFAB_FILE = "dxui_prefabs.xml"
local PROJECT_SCHEMA_VERSION = 1
local PROJECT_BACKUP_LIMIT = 5
local COLOR_KEYS = {color=true, headerColor=true, bodyColor=true, textColor=true, shadowColor=true, hoverColor=true, borderColor=true, progressColor=true, boxColor=true, checkColor=true, gradientColor=true}

local function readLocalFile(path)
    local file = fileOpen(path, true)
    if not file then return nil end
    local size = fileGetSize(file)
    local data = fileRead(file, size)
    fileClose(file)
    if not data or #data == 0 then return nil end
    return data
end

local function writeLocalFile(path, data)
    if fileExists(path) then
        fileDelete(path)
    end
    local file = fileCreate(path)
    if not file then return false end
    fileWrite(file, data)
    fileClose(file)
    return true
end

local function rotateProjectBackups()
    for i = PROJECT_BACKUP_LIMIT, 1, -1 do
        local currentPath = string.format("dxui_save.backup%d.xml", i)
        if fileExists(currentPath) then
            if i == PROJECT_BACKUP_LIMIT then
                fileDelete(currentPath)
            else
                local data = readLocalFile(currentPath)
                if data then
                    writeLocalFile(string.format("dxui_save.backup%d.xml", i + 1), data)
                end
                fileDelete(currentPath)
            end
        end
    end
end

local function backupProjectFile()
    local existingData = readLocalFile(SAVE_FILE)
    if not existingData then return end
    rotateProjectBackups()
    writeLocalFile("dxui_save.backup1.xml", existingData)
end

local function openProjectXml()
    local xml = xmlLoadFile(SAVE_FILE)
    if xml then return xml, SAVE_FILE end
    for i = 1, PROJECT_BACKUP_LIMIT do
        local backupPath = string.format("dxui_save.backup%d.xml", i)
        local backupXml = xmlLoadFile(backupPath)
        if backupXml then
            return backupXml, backupPath
        end
    end
    return nil, nil
end

local function deserializeElementAttributes(attributes)
    local el = {}
    for key, value in pairs(attributes) do
        local cp = parseColorString(value)
        if cp and COLOR_KEYS[key] then
            el[key] = cp
        elseif value == "true" then
            el[key] = true
        elseif value == "false" then
            el[key] = false
        elseif tonumber(value) and key ~= "id" and key ~= "type" and key ~= "title" and key ~= "text" and key ~= "font" and key ~= "alignX" and key ~= "alignY" and key ~= "imagePath" and key ~= "placeholder" and key ~= "iconName" and key ~= "gradientMode" then
            el[key] = tonumber(value)
        else
            el[key] = value
        end
    end
    return el
end

local function saveToFile()
    backupProjectFile()
    local xml = xmlCreateFile(SAVE_FILE, "dxui")
    if not xml then outputChatBox("[DX UI Creator] Kayıt dosyası oluşturulamadı.", 214,76,76,true); return end
    xmlNodeSetAttribute(xml, "schemaVersion", tostring(PROJECT_SCHEMA_VERSION))
    xmlNodeSetAttribute(xml, "savedAt", tostring((getRealTime() or {}).timestamp or getTickCount()))
    xmlNodeSetAttribute(xml, "nextId",  tostring(editor.nextId))
    xmlNodeSetAttribute(xml, "canvasW", tostring(editor.canvas.width))
    xmlNodeSetAttribute(xml, "canvasH", tostring(editor.canvas.height))
    for _, el in ipairs(editor.elements) do
        local node = xmlCreateChild(xml, "element")
        for key, value in pairs(el) do
            if type(value) == "table" and COLOR_KEYS[key] then xmlNodeSetAttribute(node, key, colorToString(value))
            elseif type(value) ~= "table" then xmlNodeSetAttribute(node, key, tostring(value)) end
        end
    end
    xmlSaveFile(xml)
    xmlUnloadFile(xml)
    outputChatBox("[DX UI Creator] Kaydedildi: "..SAVE_FILE.." ("..#editor.elements.." eleman)", 115,191,136,true)
end

local function loadFromFile()
    local xml, loadedPath = openProjectXml()
    if not xml then outputChatBox("[DX UI Creator] Kayıt dosyası bulunamadı: "..SAVE_FILE, 214,76,76,true); return end
    saveUndoState()
    destroyRoundedCache()
    editor.elements = {}; clearSelection(); editor.activeInput=nil; editor.interaction=nil; editor.colorPicker=nil
    editor.nextId = tonumber(xmlNodeGetAttribute(xml,"nextId")) or editor.nextId
    editor.canvas.width  = tonumber(xmlNodeGetAttribute(xml,"canvasW")) or editor.canvas.width
    editor.canvas.height = tonumber(xmlNodeGetAttribute(xml,"canvasH")) or editor.canvas.height
    for _, node in ipairs(xmlNodeGetChildren(xml) or {}) do
        if xmlNodeGetName(node) == "element" then
            local el = deserializeElementAttributes(xmlNodeGetAttributes(node))
            if el.id and el.type then table.insert(editor.elements, el) end
        end
    end
    xmlUnloadFile(xml)
    updateAssetLibrary()
    markDirty()
    if loadedPath and loadedPath ~= SAVE_FILE then
        outputChatBox("[DX UI Creator] Yedek proje yuklendi: "..loadedPath, 230,164,52,true)
    end
    outputChatBox("[DX UI Creator] Yüklendi: "..SAVE_FILE.." ("..#editor.elements.." eleman)", 115,191,136,true)
end

local function savePrefabsToFile()
    local xml = xmlCreateFile(PREFAB_FILE, "prefabs")
    if not xml then return end
    for _, prefab in ipairs(editor.prefabList) do
        local pnode = xmlCreateChild(xml, "prefab")
        xmlNodeSetAttribute(pnode, "name", prefab.name or "prefab")
        for _, item in ipairs(prefab.items or {}) do
            local node = xmlCreateChild(pnode, "element")
            for key, value in pairs(item) do
                if type(value) == "table" and COLOR_KEYS[key] then
                    xmlNodeSetAttribute(node, key, colorToString(value))
                elseif type(value) ~= "table" then
                    xmlNodeSetAttribute(node, key, tostring(value))
                end
            end
        end
    end
    xmlSaveFile(xml)
    xmlUnloadFile(xml)
end

local function loadPrefabsFromFile()
    ensureStylePresets()
    editor.prefabList = {}
    local xml = xmlLoadFile(PREFAB_FILE)
    if not xml then return end
    for _, pnode in ipairs(xmlNodeGetChildren(xml) or {}) do
        if xmlNodeGetName(pnode) == "prefab" then
            local prefab = {name = xmlNodeGetAttribute(pnode, "name") or ("prefab_" .. tostring(#editor.prefabList + 1)), items = {}}
            for _, node in ipairs(xmlNodeGetChildren(pnode) or {}) do
                if xmlNodeGetName(node) == "element" then
                    local el = deserializeElementAttributes(xmlNodeGetAttributes(node))
                    prefab.items[#prefab.items+1] = el
                end
            end
            editor.prefabList[#editor.prefabList+1] = prefab
        end
    end
    xmlUnloadFile(xml)
end

local function saveToXmlOnStop()
    saveToFile()
end

local EXPORT_PROPERTY_ORDER = {
    window    = {"id","type","x","y","w","h","title","fontScale","font","alignX","alignY","clip","wordBreak","colorCoded","headerHeight","titlePaddingX","headerColor","bodyColor","textColor","shadowColor","shadowOffsetX","shadowOffsetY"},
    rectangle = {"id","type","x","y","w","h","color","radius"},
    button    = {"id","type","x","y","w","h","text","fontScale","font","alignX","alignY","clip","wordBreak","colorCoded","radius","color","hoverColor","textColor","shadowColor","shadowOffsetX","shadowOffsetY"},
    label     = {"id","type","x","y","w","h","text","fontScale","font","alignX","alignY","clip","wordBreak","colorCoded","textColor","shadowColor","shadowOffsetX","shadowOffsetY"},
    image     = {"id","type","x","y","w","h","imagePath","color","radius"},
    container = {"id","type","x","y","w","h","color","radius"},
    progressbar = {"id","type","x","y","w","h","progress","text","color","progressColor","textColor","radius","fontScale","font","alignX","alignY"},
    checkbox  = {"id","type","x","y","w","h","checked","text","boxColor","checkColor","textColor","fontScale","font"},
    editbox   = {"id","type","x","y","w","h","text","placeholder","color","borderColor","textColor","fontScale","font","radius","masked"},
    line      = {"id","type","x","y","w","h","color","thickness"},
    gradient  = {"id","type","x","y","w","h","color","gradientColor","gradientMode","radius"},
    icon      = {"id","type","x","y","w","h","iconName","color","iconSize"},
    circle    = {"id","type","x","y","w","h","color","borderColor","borderWidth"},
}

local function serializeLuaValue(value)
    local t = type(value)
    if t == "string"  then return '"'..escapeLuaString(value)..'"'
    elseif t == "number" then
        if math.abs(value - round(value)) < 0.001 then return tostring(round(value)) end
        return string.format("%.2f", value)
    elseif t == "boolean" then return tostring(value)
    elseif t == "table" then
        local parts = {}
        for i = 1, #value do parts[i] = serializeLuaValue(value[i]) end
        return "{ "..table.concat(parts, ", ").." }"
    end
    return "nil"
end

local function createElementCode(el)
    local order = EXPORT_PROPERTY_ORDER[el.type]
    if not order then return "    { }," end
    local parts = {}
    local writtenKeys = {}
    for _, key in ipairs(order) do
        writtenKeys[key] = true
        if el[key] ~= nil then
            parts[#parts+1] = string.format("%s = %s", key, serializeLuaValue(el[key]))
        end
    end
    for _, key in ipairs(COMMON_EXPORT_KEYS) do
        if not writtenKeys[key] and el[key] ~= nil then
            parts[#parts+1] = string.format("%s = %s", key, serializeLuaValue(el[key]))
        end
    end
    return "    { "..table.concat(parts, ", ").." },"
end

local function buildProjectStateHash()
    local parts = {
        tostring(editor.nextId),
        tostring(editor.canvas.width),
        tostring(editor.canvas.height),
        tostring(#editor.elements),
    }

    for _, el in ipairs(editor.elements) do
        parts[#parts+1] = tostring(el.id or "")
        parts[#parts+1] = tostring(el.type or "")
        for _, key in ipairs(COMMON_EXPORT_KEYS) do
            parts[#parts+1] = key .. "=" .. serializeLuaValue(el[key])
        end

        local order = EXPORT_PROPERTY_ORDER[el.type] or {}
        for _, key in ipairs(order) do
            if key ~= "id" and key ~= "type" then
                parts[#parts+1] = key .. "=" .. serializeLuaValue(el[key])
            end
        end
    end

    return table.concat(parts, "|")
end

local function getUsedIconSvgs()
    local icons = {}
    for _, el in ipairs(editor.elements) do
        if el.type == "icon" and el.iconName and ICON_SVGS[el.iconName] then
            icons[el.iconName] = ICON_SVGS[el.iconName]
        end
    end
    return icons
end

local function appendExportIconRuntime(L)
    local usedIcons = getUsedIconSvgs()
    local names = {}
    for name in pairs(usedIcons) do
        names[#names+1] = name
    end
    if #names == 0 then
        local function ln(s) L[#L+1] = s end
        ln("local function getIconTexture(name) return nil end")
        return false
    end

    table.sort(names)

    local function ln(s) L[#L+1] = s end
    ln("local _iconCache = {}")
    ln("local _iconSvgs = {")
    for _, name in ipairs(names) do
        local svg = usedIcons[name]
        local sw = tonumber(svg:match('width=\"(%d+)\"')) or 24
        local sh = tonumber(svg:match('height=\"(%d+)\"')) or 24
        ln(string.format("    [%s] = { w = %d, h = %d, svg = %s },", serializeLuaValue(name), sw, sh, serializeLuaValue(svg)))
    end
    ln("}")
    ln("local function getIconTexture(name)")
    ln("    local data = _iconSvgs[name]")
    ln("    if not data then return nil end")
    ln("    local cached = _iconCache[name]")
    ln("    if cached and isElement(cached) then return cached end")
    ln("    cached = svgCreate(data.w, data.h, data.svg)")
    ln("    if cached then _iconCache[name] = cached end")
    ln("    return cached")
    ln("end")
    ln("")

    return true
end

local function appendCommonExportRuntime(L, hasCustomFonts, hasHttpImages)
    local function ln(s) L[#L+1] = s end
    ln("local function rgba(c) if type(c)~=\"table\" then return tocolor(255,255,255,255) end return tocolor(c[1],c[2],c[3],c[4] or 255) end")
    ln("local function hasColor(c) return type(c)==\"table\" and (c[4] or 255)>0 end")
    ln("")
    ln("local function isCursorOnRect(x,y,w,h)")
    ln("    if not isCursorShowing() then return false end")
    ln("    local cx,cy=getCursorPosition(); if not cx then return false end")
    ln("    cx,cy=cx*sx,cy*sy")
    ln("    return cx>=x and cx<=x+w and cy>=y and cy<=y+h")
    ln("end")
    ln("")
    if hasCustomFonts then
        ln("local function _init() sx,sy=guiGetScreenSize(); scaleX,scaleY=sx/_cw,sy/_ch; _scale=math.min(scaleX,scaleY); _offX=(sx-_cw*_scale)/2; _offY=(sy-_ch*_scale)/2; loadFonts() end")
        ln("addEventHandler(\"onClientResourceStart\",resourceRoot,_init)")
    else
        ln("local function _res() sx,sy=guiGetScreenSize(); scaleX,scaleY=sx/_cw,sy/_ch; _scale=math.min(scaleX,scaleY); _offX=(sx-_cw*_scale)/2; _offY=(sy-_ch*_scale)/2 end")
        ln("addEventHandler(\"onClientResourceStart\",resourceRoot,_res)")
    end
    ln("")
    ln("local function dxDrawRounded(id,x,y,w,h,radius,color,postGUI)")
    ln("    id = tostring(id or 'generic')")
    ln("    w=math.max(1,math.floor(w+0.5)); h=math.max(1,math.floor(h+0.5))")
    ln("    radius=math.min(math.floor((radius or 0)+0.5), math.floor(math.min(w,h)/2))")
    ln("    if radius<=0 then dxDrawRectangle(x,y,w,h,color,postGUI or false); return end")
    ln("    rounded[id]=rounded[id] or {}; rounded[id][w]=rounded[id][w] or {}; rounded[id][w][h]=rounded[id][w][h] or {}")
    ln("    if not rounded[id][w][h][radius] or not isElement(rounded[id][w][h][radius]) then")
    ln("        local p=string.format('<svg width=\"%d\" height=\"%d\" viewBox=\"0 0 %d %d\"><rect width=\"%d\" height=\"%d\" rx=\"%d\" fill=\"#FFF\"/></svg>',w,h,w,h,w,h,radius)")
    ln("        rounded[id][w][h][radius]=svgCreate(w,h,p)")
    ln("    end")
    ln("    if rounded[id][w][h][radius] then dxDrawImage(x,y,w,h,rounded[id][w][h][radius],0,0,0,color,postGUI or false) end")
    ln("end")
    ln("")
    ln("local function dxDrawCircle(id,x,y,w,h,color,postGUI)")
    ln("    id = tostring(id or 'generic')")
    ln("    w=math.max(1,math.floor(w+0.5)); h=math.max(1,math.floor(h+0.5))")
    ln("    local key=w..'_'..h")
    ln("    circles[id]=circles[id] or {}")
    ln("    if not circles[id][key] or not isElement(circles[id][key]) then")
    ln("        local p=string.format('<svg width=\"%d\" height=\"%d\" viewBox=\"0 0 %d %d\"><ellipse cx=\"%.1f\" cy=\"%.1f\" rx=\"%.1f\" ry=\"%.1f\" fill=\"#FFF\"/></svg>',w,h,w,h,w/2,h/2,w/2,h/2)")
    ln("        circles[id][key]=svgCreate(w,h,p)")
    ln("    end")
    ln("    if circles[id][key] then dxDrawImage(x,y,w,h,circles[id][key],0,0,0,color,postGUI or false) end")
    ln("end")
    ln("")
    ln("function drawOutline(x,y,w,h,color,thickness)")
    ln("    thickness = thickness or 1")
    ln("    dxDrawRectangle(x,y,w,thickness,color)")
    ln("    dxDrawRectangle(x,y+h-thickness,w,thickness,color)")
    ln("    dxDrawRectangle(x,y,thickness,h,color)")
    ln("    dxDrawRectangle(x+w-thickness,y,thickness,h,color)")
    ln("end")
    ln("function utfLen(s) local _, count = tostring(s or ''):gsub('[\\128-\\191]', '') return count end")
    ln("function utfSub(s, i, j) return string.sub(s, i, j) end")
    ln("local function delChar(s) if not s or #s==0 then return \"\" end return string.sub(s, 1, #s-1) end")
    ln("")
    ln("function drawStyledText(text,left,top,right,bottom,opts)")
    ln("    local scale=(opts.fontScale or 1)")

    if hasCustomFonts then
        ln("    local font=resolveFont(opts.font)")
    else
        ln("    local _bf={[\"default\"]=true,[\"default-bold\"]=true,[\"arial\"]=true,[\"bankgothic\"]=true,[\"clear\"]=true,[\"danielbd\"]=true,[\"pricedown\"]=true,[\"sans\"]=true,[\"unifont\"]=true}")
        ln("    local font=(opts.font and _bf[opts.font]) and opts.font or 'default-bold'")
    end

    ln("    if hasColor(opts.shadowColor) then")
    ln("        local sx2=(opts.shadowOffsetX or 1)*scaleX; local sy2=(opts.shadowOffsetY or 1)*scaleY")
    ln("        dxDrawText(text,left+sx2,top+sy2,right+sx2,bottom+sy2,rgba(opts.shadowColor),scale,font,opts.alignX or 'left',opts.alignY or 'center',opts.clip,opts.wordBreak,false,opts.colorCoded)")
    ln("    end")
    ln("    dxDrawText(text,left,top,right,bottom,rgba(opts.textColor or {255,255,255,255}),scale,font,opts.alignX or 'left',opts.alignY or 'center',opts.clip,opts.wordBreak,false,opts.colorCoded)")
    ln("end")
    ln("")
    ln("local function resolveAnchoredRect(el)")
    ln("    local x = el.x or 0")
    ln("    local y = el.y or 0")
    ln("    local w = (el.relativeW and el.wPercent) and math.max(20, math.floor(_cw * (el.wPercent / 100) + 0.5)) or (el.w or 0)")
    ln("    local h = (el.relativeH and el.hPercent) and math.max(20, math.floor(_ch * (el.hPercent / 100) + 0.5)) or (el.h or 0)")
    ln("    if el.dockX == 'fill' then w = math.max(20, _cw - x - math.max(0, el.dockPaddingRight or 0)) elseif el.anchorX == 'center' then x = (_cw - w) / 2 + x elseif el.anchorX == 'right' then x = _cw - w - x end")
    ln("    if el.dockY == 'fill' then h = math.max(20, _ch - y - math.max(0, el.dockPaddingBottom or 0)) elseif el.anchorY == 'center' then y = (_ch - h) / 2 + y elseif el.anchorY == 'bottom' then y = _ch - h - y end")
    ln("    return x*_scale+_offX, y*_scale+_offY, w*_scale, h*_scale")
    ln("end")
    ln("")
    ln("local function drawUiElement(el)")
    ln("    local x,y,w,h=resolveAnchoredRect(el)")
    ln("    if el.type==\"window\" then")
    ln("        local hh=math.min(h,math.max(24*scaleY,(el.headerHeight or 40)*scaleY))")
    ln("        local px=(el.titlePaddingX or 16)*scaleX")
    ln("        dxDrawRectangle(x,y,w,h,rgba(el.bodyColor))")
    ln("        dxDrawRectangle(x,y,w,hh,rgba(el.headerColor))")
    ln("        drawStyledText(el.title,x+px,y,x+w-px,y+hh,el)")
    ln("    elseif el.type==\"rectangle\" then")
    ln("        dxDrawRounded(el.id,x,y,w,h,(el.radius or 0)*math.min(scaleX,scaleY),rgba(el.color))")
    ln("    elseif el.type==\"button\" then")
    ln("        local r=(el.radius or 0)*math.min(scaleX,scaleY)")
    ln("        local fill=isCursorOnRect(x,y,w,h) and el.hoverColor or el.color")
    ln("        dxDrawRounded(el.id,x,y,w,h,r,rgba(fill))")
    ln("        drawStyledText(el.text,x+8*scaleX,y+4*scaleY,x+w-8*scaleX,y+h-4*scaleY,el)")
    ln("    elseif el.type==\"label\" then")
    ln("        drawStyledText(el.text,x,y,x+w,y+h,el)")
    ln("    elseif el.type==\"image\" then")
    ln("        local r=(el.radius or 0)*math.min(scaleX,scaleY)")
    ln("        if el.imagePath and el.imagePath~=\"\" then")
    ln("            local isHttp=el.imagePath:sub(1,7)==\"http://\" or el.imagePath:sub(1,8)==\"https://\"")
    ln("            local tex")
    if hasHttpImages then
        ln("            if isHttp then")
        ln("                tex=getRemoteTex(el.imagePath)")
        ln("            else")
        ln("                if not el._tex or not isElement(el._tex) then el._tex=dxCreateTexture(el.imagePath,'argb',true,'clamp') end")
        ln("                tex=el._tex")
        ln("            end")
    else
        ln("            if not isHttp then")
        ln("                if not el._tex or not isElement(el._tex) then el._tex=dxCreateTexture(el.imagePath,'argb',true,'clamp') end")
        ln("                tex=el._tex")
        ln("            end")
    end
    ln("            if tex then")
    ln("                dxDrawImage(x,y,w,h,tex,0,0,0,rgba(el.color or {255,255,255,255}))")
    ln("            else")
    ln("                dxDrawRounded(el.id,x,y,w,h,r,rgba(el.color or {255,255,255,255}))")
    ln("            end")
    ln("        end")
    ln("    elseif el.type==\"container\" then")
    ln("        dxDrawRounded(el.id,x,y,w,h,(el.radius or 0)*math.min(scaleX,scaleY),rgba(el.color))")
    ln("    elseif el.type==\"progressbar\" then")
    ln("        local r=(el.radius or 0)*math.min(scaleX,scaleY)")
    ln("        dxDrawRounded(el.id..'_bg',x,y,w,h,r,rgba(el.color))")
    ln("        local fillW=w*((el.progress or 0)/100)")
    ln("        dxDrawRounded(el.id..'_fill',x,y,fillW,h,r,rgba(el.progressColor or {72,199,130,255}))")
    ln("        if el.text and el.text~='' then drawStyledText(el.text,x,y,x+w,y+h,el) end")
    ln("    elseif el.type==\"checkbox\" then")
    ln("        local box=math.min(h,22*scaleY)")
    ln("        dxDrawRounded(el.id..'_box',x,y+(h-box)/2,box,box,4,rgba(el.boxColor or {27,31,42,230}))")
    ln("        if el.checked then dxDrawText('X',x,y+(h-box)/2,x+box,y+(h+box)/2,rgba(el.checkColor or {72,199,130,255}),1,'default-bold','center','center') end")
    ln("        drawStyledText(el.text or '',x+box+8*scaleX,y,x+w,y+h,el)")
    ln("    elseif el.type==\"editbox\" then")
    ln("        dxDrawRounded(el.id..'_eb',x,y,w,h,(el.radius or 0)*math.min(scaleX,scaleY),rgba(el.color or {20,24,32,235}))")
    ln("        if hasColor(el.borderColor) then drawOutline(x,y,w,h,rgba(el.borderColor),1) end")
    ln("        local shown=(el.text and el.text~='') and el.text or (el.placeholder or '')")
    ln("        if el.masked and el.text and el.text~='' then shown=string.rep('*', utfLen(el.text)) end")
    ln("        drawStyledText(shown,x+12*scaleX,y,x+w-12*scaleX,y+h,{font=el.font,fontScale=el.fontScale,textColor=(el.text and el.text~='') and (el.textColor or {255,255,255,255}) or {160,165,180,255},alignX='left',alignY='center'})")
    ln("    elseif el.type==\"line\" then")
    ln("        dxDrawLine(x,y+h/2,x+w,y+h/2,rgba(el.color or {255,255,255,200}),el.thickness or 2)")
    ln("    elseif el.type==\"gradient\" then")
    ln("        local steps=20")
    ln("        local c1 = type(el.color)=='table' and el.color or {255,255,255,255}; local c2 = type(el.gradientColor)=='table' and el.gradientColor or {0,0,0,255}; for i=0,steps-1 do local t=i/(steps-1); local c={c1[1]+(c2[1]-c1[1])*t, c1[2]+(c2[2]-c1[2])*t, c1[3]+(c2[3]-c1[3])*t, (c1[4] or 255)+((c2[4] or 255)-(c1[4] or 255))*t}; if el.gradientMode=='vertical' then dxDrawRectangle(x,y+(h/steps)*i,w,math.ceil(h/steps),rgba(c)) else dxDrawRectangle(x+(w/steps)*i,y,math.ceil(w/steps),h,rgba(c)) end end")
    ln("    elseif el.type==\"icon\" then")
    ln("        local icon = getIconTexture(el.iconName)")
    ln("        if icon then")
    ln("            local size=math.min(w,h,(el.iconSize or 24)*math.min(scaleX,scaleY))")
    ln("            dxDrawImage(x+(w-size)/2,y+(h-size)/2,size,size,icon,0,0,0,rgba(el.color or {255,255,255,255}))")
    ln("        else")
    ln("            dxDrawText(string.upper((el.iconName or '?'):sub(1,1)),x,y,x+w,y+h,rgba(el.color or {255,255,255,255}),1,'default-bold','center','center')")
    ln("        end")
    ln("    elseif el.type==\"circle\" then")
    ln("        if (el.borderWidth or 0)>0 and hasColor(el.borderColor) then")
    ln("            local bw=el.borderWidth*math.min(scaleX,scaleY)")
    ln("            dxDrawCircle(el.id..'_b',x-bw,y-bw,w+bw*2,h+bw*2,rgba(el.borderColor))")
    ln("        end")
    ln("        dxDrawCircle(el.id,x,y,w,h,rgba(el.color))")
    ln("    end")
    ln("end")
    ln("")

    ln("local activeInput = nil")
    ln("addEventHandler('onClientClick', root, function(btn, state)")
    ln("    if btn~='left' or state~='down' then return end")
    ln("    local clickedAny = false")
    ln("    for i=#uiElements,1,-1 do")
    ln("        local el=uiElements[i]")
    ln("        if el.visible~=false then")
    ln("            local x,y,w,h=resolveAnchoredRect(el)")
    ln("            if isCursorOnRect(x,y,w,h) then")
    ln("                clickedAny=true")
    ln("                if el.type=='editbox' then activeInput=el else activeInput=nil end")
    ln("                if el.type=='checkbox' then el.checked = not el.checked end")
    ln("                if el.clickAction and el.clickAction~='none' then")
    ln("                    if el.clickAction=='toggle_visibility' then")
    ln("                         for _,tgt in ipairs(uiElements) do if tgt.id==el.actionTarget then tgt.visible = not tgt.visible end end")
    ln("                    elseif el.clickAction=='show' then")
    ln("                         for _,tgt in ipairs(uiElements) do if tgt.id==el.actionTarget then tgt.visible = true end end")
    ln("                    elseif el.clickAction=='hide' then")
    ln("                         for _,tgt in ipairs(uiElements) do if tgt.id==el.actionTarget then tgt.visible = false end end")
    ln("                    elseif el.clickAction=='trigger_event' then")
    ln("                         triggerEvent(el.actionValue or '', localPlayer, el)")
    ln("                    elseif el.clickAction=='chat_message' then")
    ln("                         outputChatBox(el.actionValue or '', 255,255,255,true)")
    ln("                    end")
    ln("                end")
    ln("                break")
    ln("            end")
    ln("        end")
    ln("    end")
    ln("    if not clickedAny then activeInput=nil end")
    ln("end)")
    ln("")
    ln("addEventHandler('onClientCharacter', root, function(char)")
    ln("    if not activeInput then return end")
    ln("    activeInput.text = (activeInput.text or '')..char")
    ln("end)")
    ln("")
    ln("addEventHandler('onClientKey', root, function(btn, down)")
    ln("    if not activeInput or not down then return end")
    ln("    if btn=='backspace' then")
    ln("        local t=activeInput.text or ''")
    ln("        if #t > 0 then")
    ln("            local u=t:gsub('[\\128-\\191]', '')")
    ln("            if #u>0 then activeInput.text=delChar(t) end") 
    ln("        end")
    ln("    end")
    ln("end)")
    ln("")
    ln("local function renderCreatedUi()")
    ln("    for _,el in ipairs(uiElements) do if el.visible~=false then drawUiElement(el) end end")
    ln("end")
    ln("")
    ln("addEventHandler(\"onClientRender\", root, renderCreatedUi)")
    ln("")
    ln("-- Animation Runtime")
    ln("local _animStartTick = getTickCount()")
    ln("local _animClickTicks = {}")
    ln("local function lerp2(a,b,t) return a+(b-a)*t end")
    ln("local function easeOut(t) t=math.min(math.max(t,0),1); return 1-(1-t)*(1-t) end")
    ln("local function getAnimProgress(el, hovered)")
    ln("    local aType = el.animationType or 'none'")
    ln("    if aType == 'none' then return nil, false end")
    ln("    local trigger = el.animationTrigger or 'auto'")
    ln("    local dur = math.min(math.max(tonumber(el.animationDuration) or 1200, 120), 10000)")
    ln("    local now = getTickCount()")
    ln("    if trigger == 'hover' then return hovered and 1 or 0, false end")
    ln("    if trigger == 'click' then")
    ln("        local st = _animClickTicks[el.id]; if not st then return 0, false end")
    ln("        local t = math.min((now-st)/dur, 1); if t>=1 then _animClickTicks[el.id]=nil end; return t, t<1")
    ln("    end")
    ln("    local elapsed = now - _animStartTick")
    ln("    if el.animationLoop then return (elapsed % dur) / dur, true end")
    ln("    return math.min(elapsed / dur, 1), elapsed < dur")
    ln("end")
    ln("")
    ln("local function applyAnim(el, x, y, w, h, hovered)")
    ln("    local aType = el.animationType or 'none'")
    ln("    if aType == 'none' then return x, y, w, h, 1 end")
    ln("    local progress, looped = getAnimProgress(el, hovered)")
    ln("    if not progress then return x, y, w, h, 1 end")
    ln("    local intensity = math.min(math.max(tonumber(el.animationIntensity) or 18, 0), 100)")
    ln("    local scale2, alpha, offX, offY = 1, 1, 0, 0")
    ln("    local wave = looped and (0.5-0.5*math.cos(progress*math.pi*2)) or math.sin(progress*math.pi)")
    ln("    local eased = easeOut(progress)")
    ln("    if aType=='fade' then alpha=looped and (0.35+wave*0.65) or math.max(0.05,eased)")
    ln("    elseif aType=='pulse' then scale2=1+(intensity/100)*(looped and wave or math.max(0,wave))")
    ln("    elseif aType=='float' then offY=looped and (math.sin(progress*math.pi*2)*(intensity/100)*math.max(w,h)*0.25) or (-wave*(intensity/100)*math.max(w,h)*0.25)")
    ln("    elseif aType=='slide-left' then offX=looped and (-math.sin(progress*math.pi*2)*intensity) or (-(1-eased)*intensity)")
    ln("    elseif aType=='slide-right' then offX=looped and (math.sin(progress*math.pi*2)*intensity) or ((1-eased)*intensity)")
    ln("    elseif aType=='slide-up' then offY=looped and (-math.sin(progress*math.pi*2)*intensity) or (-(1-eased)*intensity)")
    ln("    elseif aType=='slide-down' then offY=looped and (math.sin(progress*math.pi*2)*intensity) or ((1-eased)*intensity)")
    ln("    elseif aType=='zoom' then local fs=1-intensity/120; scale2=looped and (1+(wave-0.5)*(intensity/100)) or lerp2(fs,1,eased)")
    ln("    end")
    ln("    local dw=math.max(1,w*scale2); local dh=math.max(1,h*scale2)")
    ln("    return x-(dw-w)/2+offX, y-(dh-h)/2+offY, dw, dh, alpha")
    ln("end")
end

local function generateExportCode()
    local L = {}
    local function ln(s) L[#L+1] = s end

    ln("local sx, sy = guiGetScreenSize()")
    ln(string.format("local _cw, _ch = %d, %d", editor.canvas.width, editor.canvas.height))
    ln("local scaleX, scaleY = sx / _cw, sy / _ch")
    ln("local _scale = math.min(scaleX, scaleY)")
    ln("local _offX  = (sx - _cw * _scale) / 2")
    ln("local _offY  = (sy - _ch * _scale) / 2")
    ln("local rounded = {}")
    ln("local circles  = {}")
    ln("")
    appendExportIconRuntime(L)
    ln("local uiElements = {")
    if #editor.elements == 0 then ln("    -- Henuz eleman yok.")
    else for _, el in ipairs(editor.elements) do ln(createElementCode(el)) end end
    ln("}")
    ln("")
    appendCommonExportRuntime(L, false, false)

    editor.exportCache  = table.concat(L, "\n")
    editor.exportDirty  = false
end

function ensureExport()
    if editor.exportDirty then generateExportCode() end
end

function getUsedCustomFonts()
    local used = {}
    for _, el in ipairs(editor.elements) do
        local fontName = el.font
        if fontName then
            for _, fd in ipairs(CUSTOM_FONT_DEFS) do
                if fontName == fd.key then
                    used[fd.key] = fd.path
                    break
                end
            end
        end
    end
    return used
end

function getUsedRemoteImages()
    local urls = {}
    for _, el in ipairs(editor.elements) do
        if el.type == "image" and el.imagePath and el.imagePath ~= "" then
            local p = el.imagePath
            if p:sub(1,7) ~= "http://" and p:sub(1,8) ~= "https://" then
                urls[p] = true
            end
        end
    end
    return urls
end

function getUsedHttpImages()
    local urls = {}
    for _, el in ipairs(editor.elements) do
        if el.type == "image" and el.imagePath and el.imagePath ~= "" then
            local p = el.imagePath
            if p:sub(1,7) == "http://" or p:sub(1,8) == "https://" then
                urls[p] = true
            end
        end
    end
    return urls
end

function generateExportServerCode()
    local L = {}
    local function ln(s) L[#L+1] = s end
    ln("local MAX_REMOTE_IMAGE_BYTES = 5242880")
    ln("local function isSafeUrl(url)")
    ln("    if type(url) ~= 'string' then return false end")
    ln("    url = url:gsub('^%s+', ''):gsub('%s+$', '')")
    ln("    local lower = url:lower()")
    ln("    if #lower < 10 or #lower > 2048 then return false end")
    ln("    if lower:sub(1,7) ~= 'http://' and lower:sub(1,8) ~= 'https://' then return false end")
    ln("    local host = lower:match('^https?://([^/%?#:]+)')")
    ln("    if not host then return false end")
    ln("    if host == 'localhost' or host == '127.0.0.1' or host == '[::1]' or host == '::1' then return false end")
    ln("    if host:match('^10%%.') or host:match('^127%%.') or host:match('^169%%.254%%.') or host:match('^192%%.168%%.') then return false end")
    ln("    if host:match('^172%%.1[6-9]%%.') or host:match('^172%%.2%%d%%.') or host:match('^172%%.3[0-1]%%.') then return false end")
    ln("    return true")
    ln("end")
    ln("local function failRemoteImage(player, url)")
    ln("    triggerClientEvent(player, 'expui:receiveRemoteImage', player, url, false, nil)")
    ln("end")
    ln("addEvent(\"expui:requestImage\", true)")
    ln("addEventHandler(\"expui:requestImage\", root, function(url)")
    ln("    local player = client")
    ln("    if not player or not isElement(player) then return end")
    ln("    if not isSafeUrl(url) then failRemoteImage(player, url); return end")
    ln("    fetchRemote(url, function(data, errno)")
    ln("        if type(errno)==\"table\" then errno=errno.statusCode or -1 end")
    ln("        if errno==0 and data and #data>0 and #data<=MAX_REMOTE_IMAGE_BYTES then")
    ln("            local ext=\"png\"")
    ln("            local h=data:sub(1,8)")
    ln("            if h:sub(1,3)==\"\\255\\216\\255\" then ext=\"jpg\"")
    ln("            elseif h:sub(1,2)==\"BM\" then ext=\"bmp\" end")
    ln("            triggerLatentClientEvent(player,\"expui:receiveRemoteImage\",1000000,false,player,url,data,ext)")
    ln("        else")
    ln("            failRemoteImage(player, url)")
    ln("        end")
    ln("    end)")
    ln("end)")
    return table.concat(L, "\n")
end

function generateFullExportCode()
    ensureExport()

    local L = {}
    local function ln(s) L[#L+1] = s end

    local usedFonts = getUsedCustomFonts()
    local hasCustomFonts = false
    for _ in pairs(usedFonts) do hasCustomFonts = true; break end

    local httpImages = getUsedHttpImages()
    local hasHttpImages = false
    for _ in pairs(httpImages) do hasHttpImages = true; break end

    ln("local sx, sy = guiGetScreenSize()")
    ln(string.format("local _cw, _ch = %d, %d", editor.canvas.width, editor.canvas.height))
    ln("local scaleX, scaleY = sx / _cw, sy / _ch")
    ln("local _scale = math.min(scaleX, scaleY)")
    ln("local _offX  = (sx - _cw * _scale) / 2")
    ln("local _offY  = (sy - _ch * _scale) / 2")
    ln("local rounded = {}")
    ln("local circles  = {}")
    ln("")

    if hasHttpImages then
        ln("local _remTex = {}")
        ln("local _remPending = {}")
        ln("local _remIndex = 0")
        ln("addEvent(\"expui:receiveRemoteImage\", true)")
        ln("addEventHandler(\"expui:receiveRemoteImage\", root, function(url, data, ext)")
        ln("    if not data then _remPending[url]=nil; return end")
        ln("    _remIndex = _remIndex + 1")
        ln("    local tmp = \"_ri\"..tostring(_remIndex)..\".\"..( ext or \"png\")")
        ln("    local f = fileCreate(tmp)")
        ln("    if f then fileWrite(f,data); fileClose(f)")
        ln("        local tex = dxCreateTexture(tmp,\"argb\",true,\"clamp\")")
        ln("        if tex then _remTex[url]=tex end")
        ln("        fileDelete(tmp)")
        ln("    end")
        ln("    _remPending[url]=nil")
        ln("end)")
        ln("local function getRemoteTex(url)")
        ln("    if _remTex[url] then return _remTex[url] end")
        ln("    if not _remPending[url] then")
        ln("        _remPending[url]=true")
        ln("        triggerServerEvent(\"expui:requestImage\", localPlayer, url)")
        ln("    end")
        ln("    return nil")
        ln("end")
        ln("")
    end

    if hasCustomFonts then
        ln("local customFonts = {}")
        ln("local function loadFonts()")
        ln(string.format("    local _sx2, _sy2 = guiGetScreenSize()"))
        ln(string.format("    local _fs = math.max(8, math.floor(14 * math.min(_sx2 / %d, _sy2 / %d)))", editor.canvas.width, editor.canvas.height))
        for key, path in pairs(usedFonts) do
            local fileName = path:match("[^/]+$")
            ln(string.format("    customFonts[\"%s\"] = dxCreateFont(\"assets/%s\", _fs)", key, fileName))
        end
        ln("end")
        ln("")
        ln("local function resolveFont(name)")
        ln("    if not name then return \"default-bold\" end")
        ln("    if customFonts[name] then return customFonts[name] end")
        ln("    local builtins={[\"default\"]=true,[\"default-bold\"]=true,[\"arial\"]=true,[\"bankgothic\"]=true,[\"clear\"]=true,[\"danielbd\"]=true,[\"diplomaticregular\"]=true,[\"externalarab\"]=true,[\"pricedown\"]=true,[\"sabankgothic\"]=true,[\"sagothic\"]=true,[\"saheader\"]=true,[\"sans\"]=true,[\"unifont\"]=true}")
        ln("    if builtins[name] then return name end")
        ln("    return \"default-bold\"")
        ln("end")
        ln("")
    end

    appendExportIconRuntime(L)

    ln("local uiElements = {")
    if #editor.elements == 0 then ln("    -- Henuz eleman yok.")
    else for _, el in ipairs(editor.elements) do ln(createElementCode(el)) end end
    ln("}")
    ln("")
    appendCommonExportRuntime(L, hasCustomFonts, hasHttpImages)

    return table.concat(L, "\n")
end

function escapeXmlAttr(s)
    s = s:gsub("&",  "&amp;")
    s = s:gsub("\"", "&quot;")
    s = s:gsub("<",  "&lt;")
    s = s:gsub(">",  "&gt;")
    return s
end

local function generateExportMetaXml()
    local L = {}
    local function ln(s) L[#L+1] = s end
    ln('<meta>')
    ln('    <info name="exported-ui" version="1.0.0" type="script" />')
    ln('    <script src="client.lua" type="client" cache="false" />')
    local httpImgs = getUsedHttpImages()
    local hasHttp = false
    for _ in pairs(httpImgs) do hasHttp = true; break end
    if hasHttp then
        ln('    <script src="server.lua" type="server" />')
    end
    local usedFonts = getUsedCustomFonts()
    for _, fd in ipairs(CUSTOM_FONT_DEFS) do
        if usedFonts[fd.key] then
            local fileName = fd.path:match("[^/]+$")
            ln('    <file src="assets/' .. escapeXmlAttr(fileName) .. '" />')
        end
    end
    local localImages = getUsedRemoteImages()
    for path in pairs(localImages) do
        ln('    <file src="' .. escapeXmlAttr(path) .. '" />')
    end
    ln('</meta>')
    return table.concat(L, "\n")
end

local function openExportModal()
    editor.exportModal = {
        path = "",
        cursor = 0,
        selStart = nil,
        selEnd = nil,
        status = nil,
    }
end

local function closeExportModal()
    editor.exportModal = nil
end

local function doExport(basePath)
    if not basePath or basePath == "" then
        outputChatBox("[DX UI Creator] Gecersiz konum.", 214,76,76,true)
        return false
    end

    local luaCode  = generateFullExportCode()
    local metaCode = generateExportMetaXml()

    local httpImgs2 = getUsedHttpImages()
    local hasHttp2 = false
    for _ in pairs(httpImgs2) do hasHttp2 = true; break end
    local serverCode = hasHttp2 and generateExportServerCode() or nil

    local fontFiles = {}
    local usedFonts = getUsedCustomFonts()
    for key, path in pairs(usedFonts) do
        fontFiles[#fontFiles+1] = {
            fileName   = path:match("[^/]+$"),
            sourcePath = path,
        }
    end
    local localFiles = {}
    local usedLocalImages = getUsedRemoteImages()
    for path in pairs(usedLocalImages) do
        localFiles[#localFiles+1] = path
    end

    triggerLatentServerEvent("dxui:exportFiles", 2000000, localPlayer, basePath, luaCode, metaCode, fontFiles, localFiles, serverCode)

    return true
end

local function exportToLuaFile()
    openExportModal()
end

local function refreshUiFonts()
    UI_FONT_BOLD       = customFonts["sfui-semibold_14"] or customFonts["gilroy-bold_14"]   or "default-bold"
    UI_FONT_MEDIUM     = customFonts["sfui-regular_14"]  or customFonts["gilroy-medium_14"] or "default"
    UI_FONT_LIGHT      = customFonts["sfui-light_14"]    or customFonts["gilroy-light_14"]  or "default"
    UI_FONT_BOLD_LG    = customFonts["sfui-semibold_17"] or customFonts["gilroy-bold_17"]   or "default-bold"
    UI_FONT_BOLD_SM    = customFonts["sfui-semibold_12"] or customFonts["gilroy-bold_12"]   or "default-bold"
    UI_FONT_BOLD_XS    = customFonts["sfui-medium_12"]   or customFonts["gilroy-bold_10"]   or "default-bold"
    UI_FONT_MEDIUM_SM  = customFonts["sfui-regular_12"]  or customFonts["gilroy-medium_12"] or "default"
    UI_FONT_MEDIUM_XS  = customFonts["sfui-light_12"]    or customFonts["gilroy-medium_10"] or "default"
end

local function drawButton(x, y, w, h, label, action, style, iconName)
    addHotbox("action", x, y, w, h, {action=action})
    if _skipPanelDraw then return end
    local cx, cy = getScreenCursor()
    local hovered = cx and insideRect(cx, cy, x, y, w, h)
    local tgt = hovered and style.hover or style.normal
    local bgColor = rgba(tgt)
    dxDrawUiRounded("btn_" .. action, x, y, w, h, 6, bgColor)
    local icon = iconName and getIcon(iconName)
    if icon then
        local iSz = 14
        local textW = dxGetTextWidth(label, 1, UI_FONT_BOLD_SM)
        local totalW = iSz + 5 + textW
        local startX = x + (w - totalW) / 2
        dxDrawImage(startX, y + (h - iSz) / 2, iSz, iSz, icon, 0, 0, 0, themeColors.text)
        dxDrawText(label, startX + iSz + 5, y, x + w - 6, y + h, themeColors.text, 1, UI_FONT_BOLD_SM, "left", "center", true, false, false)
    else
        dxDrawText(label, x+4, y, x+w-4, y+h, themeColors.text, 1, UI_FONT_BOLD_SM, "center", "center", true, false, false)
    end
end

local function drawSmallButton(x, y, w, h, label, action, active)
    addHotbox("action", x, y, w, h, {action=action})
    if _skipPanelDraw then return end
    local cx, cy = getScreenCursor()
    local hovered = cx and insideRect(cx, cy, x, y, w, h)
    local tgt = active and editor.theme.accent or (hovered and editor.theme.accentSoft or editor.theme.panelAlt)
    local bg = rgba(tgt)
    dxDrawUiRounded("sbtn_" .. action, x, y, w, h, 4, bg)
    local txtColor = active and themeColors.text or themeColors.textSecond
    dxDrawText(label, x+2, y, x+w-2, y+h, txtColor, 1, UI_FONT_BOLD_XS, "center", "center", true, false, false)
end

local function drawElementPreview(layout, element)
    local cx, cy    = _canvasRTMode and nil or getScreenCursor()
    local canvasX, canvasY, canvasW, canvasH = getElementCanvasRect(element)
    local baseX, baseY, baseW, baseH = canvasToScreen(layout, canvasX, canvasY, canvasW, canvasH)
    local hovered = cx and insideRect(cx, cy, baseX, baseY, baseW, baseH)
    local x, y, w, h, alphaMul = getElementAnimatedRect(element, baseX, baseY, baseW, baseH, hovered)
    local scaledR    = (element.radius or 0) * layout.canvas.scale
    local textOpts   = buildPreviewTextOptions(element, layout.canvas.scale)
    textOpts.textColor = modulateColorAlpha(textOpts.textColor or {255,255,255,255}, alphaMul)
    textOpts.shadowColor = modulateColorAlpha(textOpts.shadowColor, alphaMul)

    if element.type == "window" then
        local hh  = math.min(h, math.max(24*layout.canvas.scale, (element.headerHeight or 40)*layout.canvas.scale))
        local px2 = (element.titlePaddingX or 16) * layout.canvas.scale
        dxDrawRectangle(x, y, w, h, rgba(modulateColorAlpha(element.bodyColor, alphaMul)))
        dxDrawRectangle(x, y, w, hh, rgba(modulateColorAlpha(element.headerColor, alphaMul)))
        drawStyledText(element.title, x+px2, y, x+w-px2, y+hh, textOpts)
    elseif element.type == "rectangle" then
        dxDrawRoundedRectangle(element.id, x, y, w, h, scaledR, rgba(modulateColorAlpha(element.color, alphaMul)))
    elseif element.type == "button" then
        local bc = hovered and element.hoverColor or element.color
        dxDrawRoundedRectangle(element.id, x, y, w, h, scaledR, rgba(modulateColorAlpha(bc, alphaMul)))
        drawStyledText(element.text, x+8*layout.canvas.scale, y+4*layout.canvas.scale, x+w-8*layout.canvas.scale, y+h-4*layout.canvas.scale, textOpts)
    elseif element.type == "label" then
        drawStyledText(element.text, x, y, x+w, y+h, textOpts)
    elseif element.type == "image" then
        local tex = element.imagePath and element.imagePath~="" and getOrLoadTexture(element.imagePath) or nil
        if tex then
            dxDrawImage(x, y, w, h, tex, 0, 0, 0, rgba(modulateColorAlpha(element.color or {255,255,255,255}, alphaMul)))
        else
            dxDrawRectangle(x, y, w, h, tocolor(50,50,60,round(200 * alphaMul)))
            drawOutline(x, y, w, h, tocolor(100,100,120,round(200 * alphaMul)), 1)
            dxDrawText("IMAGE\n"..(element.imagePath~="" and element.imagePath or "(yol girilmedi)"), x, y, x+w, y+h, tocolor(150,150,170,round(220 * alphaMul)), 1, customFonts["gilroy-medium_10"], "center", "center", false, true, false)
        end
    elseif element.type == "container" then
        dxDrawRoundedRectangle(element.id, x, y, w, h, scaledR, rgba(modulateColorAlpha(element.color, alphaMul)))
        drawOutline(x, y, w, h, tocolor(255,255,255,round(40 * alphaMul)), 1)
    elseif element.type == "progressbar" then
        dxDrawRoundedRectangle(element.id .. "_bg", x, y, w, h, scaledR, rgba(modulateColorAlpha(element.color, alphaMul)))
        local fillW = math.max(0, math.min(w, w * ((element.progress or 0) / 100)))
        dxDrawRoundedRectangle(element.id .. "_fill", x, y, fillW, h, scaledR, rgba(modulateColorAlpha(element.progressColor or {72,199,130,255}, alphaMul)))
        if element.text and element.text ~= "" then
            drawStyledText(element.text, x, y, x+w, y+h, textOpts)
        end
    elseif element.type == "checkbox" then
        local box = math.min(h, 22 * layout.canvas.scale)
        dxDrawRoundedRectangle(element.id .. "_box", x, y + (h-box)/2, box, box, 4, rgba(element.boxColor or {27,31,42,230}))
        if element.checked then
            dxDrawText("✓", x, y + (h-box)/2, x + box, y + (h+box)/2, rgba(element.checkColor or {72,199,130,255}), 1, UI_FONT_BOLD_SM, "center", "center", false, false, false)
        end
        drawStyledText(element.text or "", x + box + 8, y, x+w, y+h, textOpts)
    elseif element.type == "editbox" then
        dxDrawRoundedRectangle(element.id .. "_eb", x, y, w, h, scaledR, rgba(element.color or {20,24,32,235}))
        if hasVisibleColor(element.borderColor) then
            drawOutline(x, y, w, h, rgba(element.borderColor), 1)
        end
        local shown = element.text ~= "" and element.text or (element.placeholder or "")
        local colorBackup = textOpts.textColor
        if element.text == "" then textOpts.textColor = {160,165,180,255} end
        if element.masked and element.text and element.text ~= "" then
            shown = string.rep("*", utfLen(element.text))
        end
        drawStyledText(shown, x+12, y, x+w-12, y+h, textOpts)
        textOpts.textColor = colorBackup
    elseif element.type == "line" then
        dxDrawLine(x, y + h / 2, x + w, y + h / 2, rgba(element.color or {255,255,255,200}), element.thickness or math.max(1, h))
    elseif element.type == "gradient" then
        dxDrawGradientRect(element.id, x, y, w, h, element.color or {63,124,255,240}, element.gradientColor or {148,83,255,240}, element.gradientMode == "vertical")
        if (element.radius or 0) > 0 then
            drawOutline(x, y, w, h, tocolor(255,255,255,30), 1)
        end
    elseif element.type == "icon" then
        local icon = getIcon(element.iconName or "save")
        if icon then
            local size = math.min(w, h, (element.iconSize or 24) * layout.canvas.scale)
            dxDrawImage(x + (w - size)/2, y + (h - size)/2, size, size, icon, 0, 0, 0, rgba(element.color or {255,255,255,255}))
        end
    elseif element.type == "circle" then
        if (element.borderWidth or 0) > 0 and hasVisibleColor(element.borderColor) then
            local bw = (element.borderWidth or 0) * layout.canvas.scale
            dxDrawEllipse(element.id.."_b", x-bw, y-bw, w+bw*2, h+bw*2, rgba(element.borderColor))
        end
        dxDrawEllipse(element.id, x, y, w, h, rgba(element.color))
    end

    if not _canvasRTMode and isElementSelected(element.id) then
        dxDrawRectangle(x, y, w, h, themeColors.selectionFill)
        drawOutline(x-1, y-1, w+2, h+2, themeColors.selection, 2)

        if element.locked then
            dxDrawText("🔒", x, y, x+w, y+h, tocolor(255,200,50,220), 1.2, UI_FONT_BOLD, "center", "center", false, false, false)
        else
            local handles = {
                {name="nw", x=x-5,   y=y-5  },
                {name="ne", x=x+w-5, y=y-5  },
                {name="sw", x=x-5,   y=y+h-5},
                {name="se", x=x+w-5, y=y+h-5},
            }
            for _, handle in ipairs(handles) do
                dxDrawRectangle(handle.x, handle.y, 10, 10, themeColors.selection)
                drawOutline(handle.x, handle.y, 10, 10, tocolor(8,11,16,255), 1)
                addHotbox("handle", handle.x, handle.y, 10, 10, {id=element.id, handle=handle.name})
            end
        end
    end
end

local _gridRT        = nil
local _gridRTW       = 0
local _gridRTH       = 0
local _gridRTScale   = 0
local _gridRTGridSz  = 0

local function getGridRT(w, h, scale, gridSize)
    local rw = math.max(1, round(w))
    local rh = math.max(1, round(h))
    if _gridRT and isElement(_gridRT)
        and _gridRTW == rw and _gridRTH == rh
        and math.abs(_gridRTScale - scale) < 0.001
        and _gridRTGridSz == gridSize then
        return _gridRT
    end
    if _gridRT and isElement(_gridRT) then destroyElement(_gridRT) end
    _gridRT      = dxCreateRenderTarget(rw, rh, true)
    _gridRTW     = rw; _gridRTH = rh
    _gridRTScale = scale; _gridRTGridSz = gridSize
    if not _gridRT then return nil end

    dxSetRenderTarget(_gridRT, true)

    local checkSize = math.max(4, round(12 * scale))
    local c1 = themeColors.canvasCheck1 or tocolor(28,28,33,255)
    local c2 = themeColors.canvasCheck2 or tocolor(22,22,26,255)
    for cy = 0, rh - 1, checkSize do
        for cx = 0, rw - 1, checkSize do
            local isEven = (math.floor(cx / checkSize) + math.floor(cy / checkSize)) % 2 == 0
            dxDrawRectangle(cx, cy, checkSize, checkSize, isEven and c1 or c2)
        end
    end

    local step = gridSize * scale
    local gridColor = themeColors.canvasGrid or tocolor(255,255,255,22)
    if step >= 6 then
        for ox = step, rw-1, step do
            dxDrawRectangle(ox, 0, 1, rh, gridColor)
        end
        for oy = step, rh-1, step do
            dxDrawRectangle(0, oy, rw, 1, gridColor)
        end
    end
    dxSetRenderTarget()
    return _gridRT
end

local function drawCanvas(layout)
    editor.zoomArea = {x=layout.canvas.x-40, y=layout.canvas.y-40, w=layout.canvas.w+80, h=layout.canvas.h+80}

    dxDrawRectangle(layout.canvas.x-12, layout.canvas.y-12, layout.canvas.w+24, layout.canvas.h+24, tocolor(0,0,0,40))
    dxDrawRectangle(layout.canvas.x-6,  layout.canvas.y-6,  layout.canvas.w+12, layout.canvas.h+12, tocolor(0,0,0,60))
    dxDrawRectangle(layout.canvas.x-2,  layout.canvas.y-2,  layout.canvas.w+4,  layout.canvas.h+4,  tocolor(0,0,0,80))

    local gridRT = getGridRT(layout.canvas.w, layout.canvas.h, layout.canvas.scale, editor.canvas.grid)
    if gridRT then
        dxDrawImage(layout.canvas.x, layout.canvas.y, layout.canvas.w, layout.canvas.h, gridRT, 0, 0, 0, tocolor(255,255,255,255))
    end

    local useRT = layout.canvas.scale < 0.999
    if useRT then
        local cw, ch = editor.canvas.width, editor.canvas.height
        if not _canvasElemRT or not isElement(_canvasElemRT) or _canvasElemRTW ~= cw or _canvasElemRTH ~= ch then
            if _canvasElemRT and isElement(_canvasElemRT) then destroyElement(_canvasElemRT) end
            _canvasElemRT  = dxCreateRenderTarget(cw, ch, true)
            _canvasElemRTW = cw; _canvasElemRTH = ch
        end
        if _canvasElemRT and isElement(_canvasElemRT) then
            local nativeLayout = {canvas = {x=0, y=0, w=cw, h=ch, scale=1.0}}
            dxSetRenderTarget(_canvasElemRT, true)
            _canvasRTMode = true
            for _, element in ipairs(editor.elements) do
                if element.visible ~= false then
                    drawElementPreview(nativeLayout, element)
                end
            end
            _canvasRTMode = false
            dxSetRenderTarget()
            dxDrawImage(layout.canvas.x, layout.canvas.y, layout.canvas.w, layout.canvas.h, _canvasElemRT, 0, 0, 0, tocolor(255,255,255,255))
            for _, element in ipairs(editor.elements) do
                if element.visible ~= false and isElementSelected(element.id) then
                    local canvasX, canvasY, canvasW, canvasH = getElementCanvasRect(element)
                    local sx, sy, sw2, sh2 = canvasToScreen(layout, canvasX, canvasY, canvasW, canvasH)
                    dxDrawRectangle(sx, sy, sw2, sh2, themeColors.selectionFill)
                    drawOutline(sx-1, sy-1, sw2+2, sh2+2, themeColors.selection, 2)
                    if element.locked then
                        dxDrawText("🔒", sx, sy, sx+sw2, sy+sh2, tocolor(255,200,50,220), 1.2, UI_FONT_BOLD, "center", "center", false, false, false)
                    else
                        local handles = {
                            {name="nw", x=sx-5,      y=sy-5      },
                            {name="ne", x=sx+sw2-5,  y=sy-5      },
                            {name="sw", x=sx-5,      y=sy+sh2-5  },
                            {name="se", x=sx+sw2-5,  y=sy+sh2-5  },
                        }
                        for _, handle in ipairs(handles) do
                            dxDrawRectangle(handle.x, handle.y, 10, 10, themeColors.selection)
                            drawOutline(handle.x, handle.y, 10, 10, tocolor(8,11,16,255), 1)
                            addHotbox("handle", handle.x, handle.y, 10, 10, {id=element.id, handle=handle.name})
                        end
                    end
                end
            end
        else
            for _, element in ipairs(editor.elements) do
                if element.visible ~= false then drawElementPreview(layout, element) end
            end
        end
    else
        if _canvasElemRT and isElement(_canvasElemRT) then
            destroyElement(_canvasElemRT)
            _canvasElemRT = nil
        end
        for _, element in ipairs(editor.elements) do
            if element.visible ~= false then
                drawElementPreview(layout, element)
            end
        end
    end

    if editor.smartGuides then
        if editor.smartGuides.x then
            local gx = layout.canvas.x + editor.smartGuides.x * layout.canvas.scale
            dxDrawRectangle(gx, layout.canvas.y, 1, layout.canvas.h, tocolor(88,180,255,160))
        end
        if editor.smartGuides.y then
            local gy = layout.canvas.y + editor.smartGuides.y * layout.canvas.scale
            dxDrawRectangle(layout.canvas.x, gy, layout.canvas.w, 1, tocolor(88,180,255,160))
        end
    end

    if editor.rubberBand and editor.interaction and editor.interaction.mode == "rubber_band" then
        local rb = editor.rubberBand
        local rbX1 = math.min(rb.startX, rb.currentX)
        local rbY1 = math.min(rb.startY, rb.currentY)
        local rbX2 = math.max(rb.startX, rb.currentX)
        local rbY2 = math.max(rb.startY, rb.currentY)
        local sx1, sy1, sw, sh = canvasToScreen(layout, rbX1, rbY1, rbX2 - rbX1, rbY2 - rbY1)
        dxDrawRectangle(sx1, sy1, sw, sh, tocolor(88, 180, 255, 30))
        drawOutline(sx1, sy1, sw, sh, tocolor(88, 180, 255, 180), 1)
    end

    local snapLabel = editor.snapEnabled and "Snap:ON" or "Snap:OFF"
    dxDrawText(
        string.format("Canvas %dx%d  |  %s  |  Zoom:%.0f%%  |  Undo:%d",
            editor.canvas.width, editor.canvas.height, snapLabel,
            editor.canvasZoom * 100, #undoStack),
        layout.canvas.x+12, layout.canvas.y+8,
        layout.canvas.x+layout.canvas.w-12, layout.canvas.y+26,
        themeColors.muted, 1, UI_FONT_BOLD_XS, "left", "top", false, false, false
    )

    local sel = getSelectedElement()
    if sel then
        local status = string.format("%s  |  x:%d y:%d  w:%d h:%d%s",
            sel.id, sel.x, sel.y, sel.w, sel.h, sel.locked and "  🔒" or "")
        dxDrawText(status, layout.canvas.x+12, layout.canvas.y+layout.canvas.h-26, layout.canvas.x+layout.canvas.w-12, layout.canvas.y+layout.canvas.h-8, themeColors.text, 1, UI_FONT_BOLD_SM, "left", "center", false, false, false)
    else
        dxDrawText("Eleman seç veya sol panelden ekle.", layout.canvas.x+12, layout.canvas.y+layout.canvas.h-26, layout.canvas.x+layout.canvas.w-12, layout.canvas.y+layout.canvas.h-8, themeColors.muted, 1, UI_FONT_MEDIUM_XS, "left", "center", false, false, false)
    end
end

local function drawLayersPanel(panelX, panelY, panelW, availableHeight)
    local boxY      = panelY + 28
    local boxHeight = math.max(80, availableHeight - 28)
    editor.layersArea = {x=panelX, y=boxY, w=panelW, h=boxHeight}

    if not _skipPanelDraw then
        dxDrawText("Katmanlar", panelX+16, panelY, panelX+panelW-16, panelY+24, themeColors.text, 1, UI_FONT_BOLD, "left", "top", false, false, false)
        dxDrawUiRounded("layers_bg", panelX, boxY, panelW, boxHeight, 6, themeColors.panelSoft)
    end

    if #editor.elements == 0 then
        if not _skipPanelDraw then
            dxDrawText("Henüz hiç eleman yok.\nSol panelden yeni eleman ekleyin.", panelX+14, boxY+14, panelX+panelW-14, boxY+boxHeight-14, themeColors.muted, 1, UI_FONT_MEDIUM_SM, "left", "top", false, true, false)
        end
        editor.layersBoxInfo = nil
        return
    end

    local rowHeight   = 34
    local innerH      = boxHeight - 12
    local maxRows     = math.max(1, math.floor(innerH / rowHeight))
    local totalRows   = #editor.elements
    local maxScroll   = math.max(0, totalRows - maxRows)
    editor.layersScroll = clamp(editor.layersScroll or 0, 0, maxScroll)

    local startIndex  = #editor.elements - editor.layersScroll
    local visibleCount= 0
    do local idx = startIndex; while idx >= 1 and visibleCount < maxRows do visibleCount=visibleCount+1; idx=idx-1 end end

    editor.layersBoxInfo = {boxY=boxY, rowHeight=rowHeight, visibleCount=visibleCount, startIndex=startIndex, panelX=panelX, panelW=panelW}

    if not _skipPanelDraw and maxScroll > 0 then
        local barX   = panelX + panelW - 8
        local thumbH = math.max(20, (maxRows / totalRows) * innerH)
        local thumbY = boxY + 6 + (editor.layersScroll / maxScroll) * (innerH - thumbH)
        dxDrawUiRounded("lscroll_bg", barX, boxY+6, 4, innerH, 2, themeColors.panelAlt)
        dxDrawUiRounded("lscroll_thumb", barX, round(thumbY), 4, round(thumbH), 2, themeColors.accent)
    end

    local isDragging = editor.interaction and editor.interaction.mode == "layer_reorder"
    local dragId     = isDragging and editor.interaction.elementId or nil
    local targetSlot = isDragging and (editor.interaction.targetSlot or 0) or nil

    local drawn = 0
    local index = startIndex
    while index >= 1 and drawn < maxRows do
        local el   = editor.elements[index]
        local rowY = boxY + 6 + drawn * rowHeight

        if not _skipPanelDraw then
            if isDragging and targetSlot == drawn then
                dxDrawRectangle(panelX+6, rowY-2, panelW-22, 3, themeColors.accent)
            end
            local isDragged = dragId == el.id
            local selected  = editor.selectedId == el.id
            local alpha     = isDragged and 90 or 255
            local rowColor  = selected and tocolor(75,144,255,alpha) or tocolor(32,37,49,alpha)
            local textClr   = selected and tocolor(12,14,18,alpha) or tocolor(236,239,244,alpha)
            local mutedClr  = tocolor(145,154,173,alpha)
            dxDrawUiRounded("layer_"..el.id, panelX+6, rowY, panelW-22, rowHeight-4, 5, rowColor)
            local handleIcon = el.locked and getIcon("lock") or getIcon("drag_handle")
            if handleIcon then
                local iconSize = 16
                local iconX = panelX + 10
                local iconY = rowY + (rowHeight - 4 - iconSize) / 2
                dxDrawImage(iconX, iconY, iconSize, iconSize, handleIcon, 0, 0, 0, mutedClr, false)
            end
            dxDrawText(el.id,   panelX+22, rowY, panelX+panelW-80, rowY+rowHeight-4, textClr, 1, UI_FONT_BOLD_SM, "left",  "center", false, false, false)
            local visClr = (el.visible ~= false) and mutedClr or tocolor(80,80,90,alpha)
            local visIconSvg = (el.visible ~= false) and getIcon("eye_on") or getIcon("eye_off")
            if visIconSvg then
                local viSize = 16
                local viX = panelX + panelW - 40
                local viY = rowY + (rowHeight - 4 - viSize) / 2
                dxDrawImage(viX, viY, viSize, viSize, visIconSvg, 0, 0, 0, visClr, false)
            end
            dxDrawText(el.type, panelX+22, rowY, panelX+panelW-46, rowY+rowHeight-4, mutedClr, 1, UI_FONT_MEDIUM_XS, "right", "center", false, false, false)
        end

        local isDragged2 = dragId == el.id
        if not isDragged2 then
            addHotbox("layer", panelX+6, rowY, panelW-42, rowHeight-4, {id=el.id})
            addHotbox("layer_visibility", panelX+panelW-42, rowY, 20, rowHeight-4, {id=el.id})
        end

        drawn = drawn + 1
        index = index - 1
    end

    if not _skipPanelDraw then
        if isDragging and targetSlot == drawn then
            local lineY = boxY + 6 + drawn * rowHeight - 2
            dxDrawRectangle(panelX+6, lineY, panelW-22, 3, themeColors.accent)
        end
        if isDragging and dragId then
            local _, cursorY2 = getScreenCursor()
            if cursorY2 then
                local dragEl = nil
                for _, el in ipairs(editor.elements) do if el.id == dragId then dragEl=el; break end end
                if dragEl then
                    dxDrawRectangle(panelX+6, cursorY2-rowHeight/2, panelW-22, rowHeight-4, tocolor(75,144,255,200))
                    dxDrawText(dragEl.id, panelX+22, cursorY2-rowHeight/2, panelX+panelW-24, cursorY2+rowHeight/2-4, tocolor(12,14,18,230), 0.88, UI_FONT_BOLD, "left", "center", false, false, false)
                end
            end
        end
    end
end

local function drawTopBar(layout)
    local sw = layout.screenW
    local th = layout.topBarH
    if not _skipPanelDraw then
        dxDrawRectangle(0, 0, sw, th, themeColors.panel)
        dxDrawRectangle(0, th-1, sw, 1, themeColors.borderSubtle)

        dxDrawText("DX UI Creator", 16, 0, 200, th, themeColors.text, 1, UI_FONT_BOLD_SM, "left", "center", false, false, false)

        local presetLabelX = 208
        dxDrawText("Canvas:", presetLabelX, 0, presetLabelX+54, th, themeColors.muted, 1, UI_FONT_MEDIUM_XS, "left", "center", false, false, false)
    end

    local presetShort = {"720p","1080p","768p","600p","1440p","1024"}
    local pBh = 28
    local pBw = 58
    local pGap = 4
    local presetStartX = 268
    for i, preset in ipairs(CANVAS_PRESETS) do
        local active = editor.canvas.width == preset.w and editor.canvas.height == preset.h
        local bx = presetStartX + (i-1)*(pBw+pGap)
        local by = (th - pBh) / 2
        drawSmallButton(bx, by, pBw, pBh, presetShort[i] or preset.label, "preset_"..i, active)
    end

    local sepX = presetStartX + #CANVAS_PRESETS*(pBw+pGap) + 8
    if not _skipPanelDraw then
        dxDrawRectangle(sepX, 10, 1, th-20, themeColors.borderSubtle)
    end

    local gridX = sepX + 12
    if not _skipPanelDraw then
        dxDrawText("Grid", gridX, 0, gridX+26, th, themeColors.muted, 1, UI_FONT_BOLD_XS, "left", "center", false, false, false)
    end
    local gBw = 34
    for i, gs in ipairs({10, 20, 40, 80}) do
        local bx = gridX + 28 + (i-1)*(gBw+3)
        local by = (th - 26) / 2
        drawSmallButton(bx, by, gBw, 26, tostring(gs), "grid_"..gs, editor.canvas.grid == gs)
    end

    local rightEdge = sw - layout.right.w - 12
    local zBw = 52
    local zBh = 28
    local zBy = (th - zBh) / 2
    if not _skipPanelDraw then
        local zText = string.format("%.0f%%", editor.canvasZoom * 100)
        local zTextX = rightEdge - zBw*3 - 12
        dxDrawText(zText, zTextX, 0, zTextX+44, th, themeColors.muted, 1, UI_FONT_BOLD_SM, "right", "center", false, false, false)
    end
    local snapBx = rightEdge - zBw*2 - 8
    local snapActive = editor.snapEnabled
    local snapStyle = snapActive and {normal=editor.theme.accentActive, hover=editor.theme.accent} or {normal=editor.theme.panelAlt, hover=editor.theme.panelHover}
    drawButton(snapBx, zBy, zBw, zBh, "SNAP", "toggle_snap", snapStyle, nil)
    local guideBx = rightEdge - zBw - 4
    local guideActive = editor.smartSnapEnabled
    local guideStyle = guideActive and {normal=editor.theme.accentActive, hover=editor.theme.accent} or {normal=editor.theme.panelAlt, hover=editor.theme.panelHover}
    drawButton(guideBx, zBy, zBw, zBh, "GUIDE", "toggle_smart_snap", guideStyle, nil)
end

function drawLeftPanel(layout)
    local panel = layout.left
    local px = panel.x
    local py = panel.y

    if not _skipPanelDraw then
        dxDrawRectangle(px, py, panel.w, panel.h, themeColors.panel)
        dxDrawRectangle(px+panel.w-1, py, 1, panel.h, themeColors.borderSubtle)
    end

    local pad = 12
    local cy2 = py + pad

    if not _skipPanelDraw then
        dxDrawText("ELEMENTLER", px+pad, cy2, px+panel.w-pad, cy2+16, themeColors.muted, 1, UI_FONT_BOLD_XS, "left", "top", false, false, false)
    end
    cy2 = cy2 + 20

    local gutter = 6
    local bw  = (panel.w - pad*2 - gutter) / 2
    local bh  = 36
    local st  = {normal=editor.theme.panelAlt, hover=editor.theme.panelHover}
    local addButtons = {
        {"Pencere","add_window","window"},     {"Buton","add_button","button"},
        {"Yazı","add_label","label"},          {"Dikdörtgen","add_rectangle","rectangle"},
        {"Resim","add_image","image"},         {"Daire","add_circle","circle"},
        {"Container","add_container","container"}, {"Bar","add_progressbar","progressbar"},
        {"Check","add_checkbox","checkbox"},   {"Edit","add_editbox","editbox"},
        {"Çizgi","add_line","line"},           {"Gradyan","add_gradient","gradient"},
        {"İkon","add_icon","icon"},
    }
    for i, ab in ipairs(addButtons) do
        local col = (i-1) % 2
        local row = math.floor((i-1) / 2)
        drawButton(px+pad + col*(bw+gutter), cy2 + row*(bh+5), bw, bh, ab[1], ab[2], st, ab[3])
    end
    cy2 = cy2 + math.ceil(#addButtons/2) * (bh+5)

    cy2 = cy2 + 8
    if not _skipPanelDraw then
        dxDrawRectangle(px+pad, cy2, panel.w-pad*2, 1, themeColors.borderSubtle)
    end
    cy2 = cy2 + 10

    if not _skipPanelDraw then
        dxDrawText("DOSYA", px+pad, cy2, px+panel.w-pad, cy2+16, themeColors.muted, 1, UI_FONT_BOLD_XS, "left", "top", false, false, false)
    end
    cy2 = cy2 + 20

    local ss = {normal=editor.theme.success,  hover=editor.theme.successHover}
    local sa = {normal=editor.theme.panelAlt, hover=editor.theme.accentHover}
    local fbh = 32
    drawButton(px+pad,           cy2,          bw, fbh, "Kaydet",       "save_project",   ss, "save")
    drawButton(px+pad+bw+gutter, cy2,          bw, fbh, "Yükle",        "load_project",   sa, "load")
    drawButton(px+pad,           cy2+fbh+4,    bw, fbh, "Lua Yaz",   "export_to_file", ss, "code")
    drawButton(px+pad+bw+gutter, cy2+fbh+4,    bw, fbh, "Kopyala",   "copy_export",    sa, "copy")
    cy2 = cy2 + (fbh+4)*2

    cy2 = cy2 + 8
    if not _skipPanelDraw then
        dxDrawRectangle(px+pad, cy2, panel.w-pad*2, 1, themeColors.borderSubtle)
    end
    cy2 = cy2 + 10

    if not _skipPanelDraw then
        dxDrawText("ŞABLONLAR", px+pad, cy2, px+panel.w-pad, cy2+16, themeColors.muted, 1, UI_FONT_BOLD_XS, "left", "top", false, false, false)
    end
    cy2 = cy2 + 20
    local templateBtns = {
        {"Giriş Ekranı","template_login"}, {"Bildirim","template_notification"},
        {"Envanter","template_inventory"}, {"HUD Bar","template_hud"},
    }
    local tBw = (panel.w - pad*2 - gutter) / 2
    for i, tb in ipairs(templateBtns) do
        local col3 = (i-1) % 2
        local row3 = math.floor((i-1) / 2)
        drawSmallButton(px+pad + col3*(tBw+gutter), cy2 + row3*26, tBw, 22, tb[1], tb[2], false)
    end
    cy2 = cy2 + math.ceil(#templateBtns/2)*26

    cy2 = cy2 + 8
    if not _skipPanelDraw then
        dxDrawRectangle(px+pad, cy2, panel.w-pad*2, 1, themeColors.borderSubtle)
    end
    cy2 = cy2 + 10

    if not _skipPanelDraw then
        dxDrawText("KISAYOLLAR", px+pad, cy2, px+panel.w-pad, cy2+16, themeColors.muted, 1, UI_FONT_BOLD_XS, "left", "top", false, false, false)
        local shortcuts = {
            "F7 / /dxui  →  Editör aç/kapat",
            "Del  →  Seçili sil",
            "Ctrl+Z/Y  →  Geri / İleri",
            "Ctrl+C/V  →  Kopyala / Yapıştır",
            "Ctrl+A  →  Tümünü seç",
            "Ctrl+D  →  Çoğalt",
            "Ctrl+S  →  Kaydet",
            "Ctrl+=/-  →  Zoom +/-",
            "G  →  Grid snap",
            "H  →  Kılavuz çizgiler",
            "P  →  Önizleme",
        }
        local textY = cy2 + 18
        for _, line in ipairs(shortcuts) do
            dxDrawText(line, px+pad, textY, px+panel.w-pad, textY+15, themeColors.muted, 1, UI_FONT_MEDIUM_XS, "left", "top", false, false, false)
            textY = textY + 16
        end
        cy2 = textY
    else
        cy2 = cy2 + 18 + 11*16
    end

    cy2 = cy2 + 8
    if not _skipPanelDraw then
        dxDrawRectangle(px+pad, cy2, panel.w-pad*2, 1, themeColors.borderSubtle)
    end
    cy2 = cy2 + 8

    drawLayersPanel(px+pad, cy2, panel.w-pad*2, panel.y+panel.h - cy2 - pad)
end
function drawPropertyRow(x, y, w, property, element)
    if property.kind == "group" then
        local groupH = 26
        if not _skipPanelDraw then
            dxDrawRectangle(x, y + 10, w, 1, themeColors.panelBorder)
            dxDrawText(property.label, x + 2, y + 14, x + w, y + groupH, themeColors.accent, 1, UI_FONT_BOLD_XS, "left", "top", false, false, false)
        end
        return groupH
    end

    local input      = editor.activeInput
    local isEditing  = input and input.elementId==element.id and input.key==property.key
    local rowH       = 34
    local labelW     = 110
    local valueX     = x + labelW
    local valueW     = w - labelW

    addHotbox("property", valueX, y+4, valueW, rowH-8, {key=property.key, kind=property.kind, options=property.options})
    if _skipPanelDraw then return rowH end

    local valueText  = isEditing and input.value or getPropertyValueString(element, property)
    local isColor    = property.kind == "color"

    if isColor then
        local color = element[property.key] or {255,255,255,255}
        local swX   = x + labelW - 26
        dxDrawUiRounded("csw_"..property.key, swX, y+8, 18, rowH-16, 4, rgba(color))
    end

    local isPickerOpen = editor.colorPicker and editor.colorPicker.elementId==element.id and editor.colorPicker.key==property.key
    local isEnumOpen = property.kind == "enum" and editor.enumDropdown and editor.enumDropdown.elementId == element.id and editor.enumDropdown.key == property.key
    local isActive = isEditing or isPickerOpen or isEnumOpen
    local valueBg       = isActive and themeColors.accent or themeColors.panelSoft
    local valueTextColor= isActive and tocolor(10,12,18,255) or themeColors.text

    local labelRight = isColor and (x+labelW-30) or (x+labelW-4)
    dxDrawText(property.label, x, y, labelRight, y+rowH, themeColors.muted, 1, UI_FONT_BOLD_SM, "left", "center", true, false, false)
    dxDrawUiRounded("prop_"..property.key, valueX, y+4, valueW, rowH-8, 4, valueBg)

    local isDropdown = property.kind == "enum" and editor.enumDropdown and editor.enumDropdown.elementId == element.id and editor.enumDropdown.key == property.key
    if isDropdown then
        editor.enumDropdown._anchorX = valueX
        editor.enumDropdown._anchorY = y + rowH
        editor.enumDropdown._anchorW = valueW
        dxDrawText(valueText, valueX+8, y, valueX+valueW-20, y+rowH, valueTextColor, 1, UI_FONT_MEDIUM_SM, "left", "center", true, false, false)
        dxDrawText("▼", valueX+valueW-20, y, valueX+valueW-4, y+rowH, themeColors.muted, 1, UI_FONT_BOLD_XS, "center", "center", false, false, false)
    elseif isEditing then
        local textInner = valueX + 8
        local textRight = valueX + valueW - 8
        local textTop   = y
        local textBot   = y + rowH

        local selA, selB = inputGetSelectedRange(input)
        if selA and selB then
            local beforeSel = selA > 0 and utfSub(input.value, 1, selA) or ""
            local selText   = utfSub(input.value, selA + 1, selB)
            local selStartX = textInner + dxGetTextWidth(beforeSel, 1, UI_FONT_MEDIUM_SM)
            local selW      = dxGetTextWidth(selText, 1, UI_FONT_MEDIUM_SM)
            selW = math.min(selW, textRight - selStartX)
            if selW > 0 then
                dxDrawRectangle(selStartX, y + 6, selW, rowH - 12, tocolor(75, 144, 255, 120))
            end
        end

        dxDrawText(valueText, textInner, textTop, textRight, textBot, valueTextColor, 1, UI_FONT_MEDIUM_SM, "left", "center", true, false, false)

        local blinkPhase = (getTickCount() - (editor.cursorBlink or 0)) % 1000
        if blinkPhase < 530 then
            local cursor = inputGetCursor(input)
            local beforeCursor = cursor > 0 and utfSub(input.value, 1, cursor) or ""
            local cursorX = textInner + dxGetTextWidth(beforeCursor, 1, UI_FONT_MEDIUM_SM)
            cursorX = math.min(cursorX, textRight)
            dxDrawRectangle(cursorX, y + 7, 2, rowH - 14, valueTextColor)
        end
    else
        if property.kind == "enum" then
            dxDrawText(valueText, valueX+8, y, valueX+valueW-20, y+rowH, valueTextColor, 1, UI_FONT_MEDIUM_SM, "left", "center", true, false, false)
            dxDrawText("▼", valueX+valueW-20, y, valueX+valueW-4, y+rowH, themeColors.muted, 1, UI_FONT_BOLD_XS, "center", "center", false, false, false)
        else
            dxDrawText(valueText, valueX+8, y, valueX+valueW-8, y+rowH, valueTextColor, 1, UI_FONT_MEDIUM_SM, "left", "center", true, false, false)
        end
    end

    return rowH
end

function drawRightPanel(layout)
    local panel = layout.right
    local px = panel.x
    local py = panel.y

    if not _skipPanelDraw then
        dxDrawRectangle(px, py, panel.w, panel.h, themeColors.panel)
        dxDrawRectangle(px, py, 1, panel.h, themeColors.borderSubtle)
    end

    local tabH   = 44
    local tabs   = {{"Design","design"}, {"Kod","code"}}
    local tabW   = panel.w / #tabs
    local curTab = editor.rightPanelTab or "design"
    if not _skipPanelDraw then
        dxDrawRectangle(px, py, panel.w, tabH, themeColors.panelSoft)
        dxDrawRectangle(px, py+tabH-1, panel.w, 1, themeColors.borderSubtle)
    end
    for i, tab in ipairs(tabs) do
        local tx = px + (i-1)*tabW
        local isActive = curTab == tab[2]
        addHotbox("action", tx, py, tabW, tabH, {action="tab_right_"..tab[2]})
        if not _skipPanelDraw then
            local tabColor = isActive and themeColors.text or themeColors.muted
            dxDrawText(tab[1], tx, py, tx+tabW, py+tabH, tabColor, 1, UI_FONT_BOLD_SM, "center", "center", false, false, false)
            if isActive then
                dxDrawRectangle(tx+tabW*0.15, py+tabH-2, tabW*0.7, 2, themeColors.accent)
            end
        end
    end

    local sp  = {normal=editor.theme.panelAlt, hover=editor.theme.accentHover}
    local dp  = {normal=editor.theme.danger,   hover=editor.theme.dangerHover}

    local gutter2 = 6
    local bw2 = (panel.w - 24 - gutter2) / 2
    local bh2 = 34
    local baseY = py + tabH + 8

    if curTab == "design" then
        drawButton(px+12,              baseY,            bw2, bh2, "Öne Al",      "bring_front",       sp, "front")
        drawButton(px+12+bw2+gutter2,  baseY,            bw2, bh2, "Arkaya At",   "send_back",         sp, "back")
        drawButton(px+12,              baseY+bh2+6,      bw2, bh2, "Bir Yukarı",  "layer_up",          sp, "front")
        drawButton(px+12+bw2+gutter2,  baseY+bh2+6,      bw2, bh2, "Bir Aşağı",   "layer_down",        sp, "back")
        drawButton(px+12,              baseY+(bh2+6)*2,   bw2, bh2, "Kopyala",     "duplicate_selected",sp, "duplicate")
        drawButton(px+12+bw2+gutter2,  baseY+(bh2+6)*2,   bw2, bh2, "Sil",         "delete_selected",   dp, "trash")
        drawButton(px+12,              baseY+(bh2+6)*3,   bw2, bh2, "Grupla",      "group_selection",   sp, "layers")
        drawButton(px+12+bw2+gutter2,  baseY+(bh2+6)*3,   bw2, bh2, "Çöz",         "ungroup_selection", sp, "layers")
        drawButton(px+12,              baseY+(bh2+6)*4,   bw2, bh2, "Parent Yap",  "parent_selection",  sp, "front")
        drawButton(px+12+bw2+gutter2,  baseY+(bh2+6)*4,   bw2, bh2, "Par.Kaldır",  "clear_parent",      sp, "back")
        drawButton(px+12,              baseY+(bh2+6)*5,   bw2, bh2, "Stil Kopya",  "copy_style",        sp, "copy")
        drawButton(px+12+bw2+gutter2,  baseY+(bh2+6)*5,   bw2, bh2, "Stil Yapistir","paste_style",      sp, "duplicate")

        local alignY = baseY + (bh2+6)*6 + 4
        if not _skipPanelDraw then
            dxDrawText("Hizalama:", px+12, alignY, px+panel.w-12, alignY+16, themeColors.muted, 1, UI_FONT_BOLD_XS, "left", "top", false, false, false)
        end
        local aw  = (panel.w - 24 - 5*4) / 6
        local alignBtns = {
            {"◁", "align_left"},    {"⊣", "align_centerX"},  {"▷", "align_right"},
            {"△", "align_top"},     {"⊥", "align_centerY"},  {"▽", "align_bottom"},
        }
        for i, ab in ipairs(alignBtns) do
            drawSmallButton(px+12+(i-1)*(aw+4), alignY+18, aw, 22, ab[1], ab[2], false)
        end

        local distY = alignY + 44
        if not _skipPanelDraw then
            dxDrawText("Dağıt / Eşitle:", px+12, distY, px+panel.w-12, distY+16, themeColors.muted, 1, UI_FONT_BOLD_XS, "left", "top", false, false, false)
        end
        local dw4 = (panel.w - 24 - 3*4) / 4
        local distBtns = {
            {"Y.Dağıt", "distribute_x"},
            {"D.Dağıt", "distribute_y"},
            {"Eş Gen.",  "same_width"},
            {"Eş Yük.",  "same_height"},
        }
        for i, db in ipairs(distBtns) do
            drawSmallButton(px+12+(i-1)*(dw4+4), distY+18, dw4, 22, db[1], db[2], false)
        end

        local actRowY = distY + 44
        local hw = (panel.w - 32) / 2
        local pvStyle = editor.previewMode and {normal=editor.theme.accent, hover=editor.theme.accentHover} or sp
        drawButton(px+12,       actRowY, hw, bh2-6, editor.previewMode and "✓ Önizleme" or "Önizleme", "preview_mode", pvStyle, nil)
        drawButton(px+20+hw,    actRowY, hw, bh2-6, "Tümü Temizle", "clear_canvas", dp, "clear")

        local sel         = getSelectedElement()
        local inspectorY  = actRowY + bh2
        local viewportTop = inspectorY + 50
        local viewportBot = py + panel.h - 10
        local viewportH   = math.max(60, viewportBot - viewportTop)

        if not _skipPanelDraw then
            dxDrawText("Özellikler", px+12, inspectorY, px+panel.w-12, inspectorY+20, themeColors.text, 1, UI_FONT_BOLD_SM, "left", "top", false, false, false)
        end

        if sel then
            if not _skipPanelDraw then
                dxDrawText(sel.id.."  ["..sel.type.."]".. (sel.locked and "  \240\159\148\146" or ""),
                    px+12, inspectorY+20, px+panel.w-12, inspectorY+40,
                    themeColors.muted, 1, UI_FONT_MEDIUM_XS, "left", "top", false, false, false)
            end

            local properties   = _cachedPropertyLists[sel.type] or buildPropertyList(sel)
            if not _cachedPropertyLists[sel.type] then _cachedPropertyLists[sel.type] = properties end
            local totalHeight = 0
            for _, p in ipairs(properties) do totalHeight = totalHeight + (p.kind == "group" and 26 or 34) end
            totalHeight = totalHeight + (editor.activeInput and 26 or 0)
            editor.inspectorScrollMax = math.max(0, totalHeight - viewportH)
            editor.inspectorScroll    = clamp(editor.inspectorScroll or 0, 0, editor.inspectorScrollMax)
            editor.inspectorArea      = {x=px+12, y=viewportTop, w=panel.w-24, h=viewportH}

            local rowY = viewportTop - editor.inspectorScroll
            for _, property in ipairs(properties) do
                local rowH = property.kind == "group" and 26 or 34
                local rowBot = rowY + rowH
                if rowBot >= viewportTop and rowY <= viewportBot then
                    drawPropertyRow(px+12, rowY, panel.w-24, property, sel)
                end
                rowY = rowY + rowH
            end

            if not _skipPanelDraw and editor.activeInput then
                local hintY = rowY + 4
                if hintY+18 >= viewportTop and hintY <= viewportBot then
                    dxDrawText("Enter: Onayla  |  Esc: İptal et", px+12, hintY, px+panel.w-12, hintY+18, themeColors.warning, 1, UI_FONT_BOLD_XS, "left", "top", false, false, false)
                end
            end

            if not _skipPanelDraw and editor.inspectorScrollMax > 0 then
                local barX   = px + panel.w - 10
                local thumbH = math.max(20, (viewportH / totalHeight) * viewportH)
                local thumbY = viewportTop + (editor.inspectorScroll / editor.inspectorScrollMax) * (viewportH - thumbH)
                dxDrawUiRounded("iscroll_bg", barX, viewportTop, 4, viewportH, 2, themeColors.panelSoft)
                dxDrawUiRounded("iscroll_thumb", barX, round(thumbY), 4, round(thumbH), 2, themeColors.accent)
            end
        else
            editor.inspectorArea = nil; editor.inspectorScroll = 0; editor.inspectorScrollMax = 0
            if not _skipPanelDraw then
                dxDrawUiRounded("inspector_empty", px+12, inspectorY+26, panel.w-24, 90, 6, themeColors.panelSoft)
                dxDrawText("Canvas üzerinden bir eleman seçin.\nYa da sol panelden yeni eleman ekleyin.", px+24, inspectorY+38, px+panel.w-24, inspectorY+110, themeColors.muted, 1, UI_FONT_MEDIUM_SM, "left", "top", false, true, false)
            end
        end

        editor.previewArea = nil

    elseif curTab == "code" then
        editor.inspectorArea = nil; editor.inspectorScroll = 0; editor.inspectorScrollMax = 0

        local previewH    = panel.h - tabH - 32
        local previewY    = py + tabH + 16

        editor.previewArea = {x=px+12, y=previewY, w=panel.w-24, h=previewH}
        addHotbox("preview_drag", px+12, previewY, panel.w-24, previewH, {})

        if not _skipPanelDraw then
            if not editor.interaction then ensureExport() end
            dxDrawText("Kod Önizlemesi", px+12, previewY-22, px+panel.w-12, previewY-4, themeColors.text, 1, UI_FONT_BOLD_SM, "left", "top", false, false, false)
            dxDrawUiRounded("preview_bg", px+12, previewY, panel.w-24, previewH, 6, tocolor(8,11,16,220))

            local lineH = 14
            local lineCount = 1
            for _ in editor.exportCache:gmatch("\n") do lineCount = lineCount + 1 end
            local totalTextH = lineCount * lineH
            local innerH = previewH - 20
            editor.previewScrollMax = math.max(0, totalTextH - innerH)
            editor.previewScroll = clamp(editor.previewScroll or 0, 0, editor.previewScrollMax)

            local panelRTActive = _panelRT and isElement(_panelRT)
            if panelRTActive then dxSetRenderTarget() end

            local pvW = math.max(1, round(panel.w-24))
            local pvH = math.max(1, round(previewH))
            local needsPreviewRedraw = not _previewCachedRT or not isElement(_previewCachedRT)
                                    or _previewCachedW ~= pvW or _previewCachedH ~= pvH
                                    or _lastPreviewCacheCode ~= editor.exportCache
                                    or _lastPreviewScroll ~= editor.previewScroll

            if needsPreviewRedraw then
                if not _previewCachedRT or not isElement(_previewCachedRT) or _previewCachedW ~= pvW or _previewCachedH ~= pvH then
                    if _previewCachedRT and isElement(_previewCachedRT) then destroyElement(_previewCachedRT) end
                    _previewCachedRT = dxCreateRenderTarget(pvW, pvH, true)
                    _previewCachedW = pvW; _previewCachedH = pvH
                end

                if _previewCachedRT then
                    dxSetRenderTarget(_previewCachedRT, true)
                    dxDrawRectangle(0, 0, pvW, pvH, tocolor(8,11,16,220))
                    dxDrawText(editor.exportCache, 8, 10 - editor.previewScroll, pvW-8, totalTextH + 10, themeColors.text, 1, UI_FONT_MEDIUM_XS, "left", "top", true, false, false)
                    dxSetRenderTarget()
                end
                _lastPreviewCacheCode = editor.exportCache
                _lastPreviewScroll = editor.previewScroll
            end

            if panelRTActive then dxSetRenderTarget(_panelRT) end

            if _previewCachedRT then
                dxDrawImage(px+12, previewY, pvW, pvH, _previewCachedRT)
            end

            if editor.previewScrollMax > 0 then
                local barX   = px + panel.w - 16
                local thumbH = math.max(12, (innerH / totalTextH) * previewH)
                local thumbY = previewY + (editor.previewScroll / editor.previewScrollMax) * (previewH - thumbH)
                dxDrawRectangle(barX, previewY, 3, previewH, themeColors.panelAlt)
                dxDrawUiRounded("preview_thumb", barX, round(thumbY), 3, round(thumbH), 2, themeColors.accent)
            end
        end
    end
end

function findTopElementAt(cx, cy)
    for i = #editor.elements, 1, -1 do
        local el = editor.elements[i]
        local x, y, w, h = getElementCanvasRect(el)
        if el.visible ~= false and insideRect(cx, cy, x, y, w, h) then return el end
    end
    return nil
end

function beginDrag(element, cx, cy)
    saveUndoState()
    normalizeSelection()
    if not isElementSelected(element.id) then
        setSelectedElement(element.id)
    end
    local selected = getSelectedElements()
    local snapshots = {}
    for _, el in ipairs(selected) do
        local x, y = getElementCanvasRect(el)
        snapshots[#snapshots+1] = {id=el.id, x=x, y=y}
    end
    local x, y = getElementCanvasRect(element)
    editor.interaction = {mode="drag", elementId=element.id, offsetX=cx-x, offsetY=cy-y, snapshot=snapshots}
end

function beginResize(element, handle, cx, cy)
    saveUndoState()
    normalizeSelection()
    local selected = getSelectedElements()
    local snapshots = {}
    for _, el in ipairs(selected) do
        if not el.locked then
            local x, y, w, h = getElementCanvasRect(el)
            snapshots[#snapshots+1] = {id=el.id, x=x, y=y, w=w, h=h}
        end
    end
    local x, y, w, h = getElementCanvasRect(element)
    editor.interaction = {
        mode="resize", elementId=element.id, handle=handle,
        startCursorX=cx, startCursorY=cy,
        startX=x, startY=y, startW=w, startH=h,
        resizeSnapshots=snapshots,
    }
end

function resolveSmartSnap(targetId, x, y, w, h)
    if not editor.smartSnapEnabled then
        editor.smartGuides = {}
        return x, y
    end
    local threshold = 6
    local bestX, bestY = x, y
    local bestDx, bestDy = threshold + 1, threshold + 1
    editor.smartGuides = {}
    local candidatesX = {x, x + w / 2, x + w}
    local candidatesY = {y, y + h / 2, y + h}
    for _, other in ipairs(editor.elements) do
        if other.id ~= targetId and other.visible ~= false then
            local ox, oy, ow, oh = getElementCanvasRect(other)
            local otherX = {ox, ox + ow / 2, ox + ow}
            local otherY = {oy, oy + oh / 2, oy + oh}
            for ci, cv in ipairs(candidatesX) do
                for _, ov in ipairs(otherX) do
                    local diff = ov - cv
                    if math.abs(diff) < math.abs(bestDx) and math.abs(diff) <= threshold then
                        bestDx = diff
                        if ci == 1 then bestX = x + diff elseif ci == 2 then bestX = x + diff else bestX = x + diff end
                        editor.smartGuides.x = ov
                    end
                end
            end
            for ci, cv in ipairs(candidatesY) do
                for _, ov in ipairs(otherY) do
                    local diff = ov - cv
                    if math.abs(diff) < math.abs(bestDy) and math.abs(diff) <= threshold then
                        bestDy = diff
                        if ci == 1 then bestY = y + diff elseif ci == 2 then bestY = y + diff else bestY = y + diff end
                        editor.smartGuides.y = ov
                    end
                end
            end
        end
    end
    return bestX, bestY
end

function updateInteraction(layout)
    if not editor.interaction then
        editor.smartGuides = {}
        return
    end

    if editor.interaction.mode == "rubber_band" then
        if editor.rubberBand then
            local cx2, cy2 = getScreenCursor()
            if cx2 then
                local canvasX, canvasY = screenToCanvas(layout, cx2, cy2)
                editor.rubberBand.currentX = canvasX
                editor.rubberBand.currentY = canvasY
            end
        end
        return
    end

    if editor.interaction.mode == "layer_reorder" then
        local info = editor.layersBoxInfo
        if not info then return end
        local _, cursorY2 = getScreenCursor()
        if not cursorY2 then return end
        local relY = cursorY2 - info.boxY - 6
        editor.interaction.targetSlot = clamp(math.floor(relY / info.rowHeight + 0.5), 0, info.visibleCount)
        return
    end

    if editor.interaction.mode == "color_slider" then
        local cx2, _ = getScreenCursor()
        if not cx2 or not editor.colorPicker then return end
        local info = editor.interaction
        local ratio = clamp((cx2 - info.barX) / info.barW, 0, 1)
        editor.colorPicker[info.channel] = round(ratio * 255)
        commitColorPicker()
        return
    end

    local element = getSelectedElement()
    if not element or element.id ~= editor.interaction.elementId then editor.interaction=nil; return end

    local cursorX, cursorY = getScreenCursor()
    if not cursorX then return end

    local canvasX, canvasY = screenToCanvas(layout, cursorX, cursorY)
    local altDown = getKeyState and (getKeyState("lalt") or getKeyState("ralt"))
    local useSnap = editor.snapEnabled and not altDown

    if editor.interaction.mode == "drag" then
        local rawX = canvasX - editor.interaction.offsetX
        local rawY = canvasY - editor.interaction.offsetY
        local currentX, currentY, currentW, currentH = getElementCanvasRect(element)
        rawX, rawY = resolveSmartSnap(editor.interaction.elementId, rawX, rawY, currentW, currentH)
        if useSnap then rawX = snapToGrid(rawX, editor.canvas.grid); rawY = snapToGrid(rawY, editor.canvas.grid) end
        local newX = clamp(round(rawX), 0, editor.canvas.width  - currentW)
        local newY = clamp(round(rawY), 0, editor.canvas.height - currentH)
        local dxMove = newX - currentX
        local dyMove = newY - currentY
        local moved = {}
        for _, item in ipairs(editor.interaction.snapshot or {}) do
            local sel = getElementById(item.id)
            if sel and not sel.locked then
                moveElementWithChildren(sel, dxMove, dyMove, moved)
            end
        end
        markDirty(); return
    end

    if editor.interaction.mode ~= "resize" then return end
    local minSize = 20
    local dx = canvasX - editor.interaction.startCursorX
    local dy = canvasY - editor.interaction.startCursorY
    local nx, ny, nw, nh = editor.interaction.startX, editor.interaction.startY, editor.interaction.startW, editor.interaction.startH
    local handle = editor.interaction.handle
    local grid = editor.canvas.grid

    if handle=="se" or handle=="ne" then
        local rawW = editor.interaction.startW + dx
        if useSnap then rawW = snapToGrid(editor.interaction.startX + rawW, grid) - editor.interaction.startX end
        nw = clamp(round(rawW), minSize, editor.canvas.width - editor.interaction.startX)
    else
        local rawX = editor.interaction.startX + dx
        if useSnap then rawX = snapToGrid(rawX, grid) end
        nx = clamp(round(rawX), 0, editor.interaction.startX + editor.interaction.startW - minSize)
        nw = editor.interaction.startW + (editor.interaction.startX - nx)
    end

    if handle=="se" or handle=="sw" then
        local rawH = editor.interaction.startH + dy
        if useSnap then rawH = snapToGrid(editor.interaction.startY + rawH, grid) - editor.interaction.startY end
        nh = clamp(round(rawH), minSize, editor.canvas.height - editor.interaction.startY)
    else
        local rawY = editor.interaction.startY + dy
        if useSnap then rawY = snapToGrid(rawY, grid) end
        ny = clamp(round(rawY), 0, editor.interaction.startY + editor.interaction.startH - minSize)
        nh = editor.interaction.startH + (editor.interaction.startY - ny)
    end

    element.w=nw; element.h=nh
    if element.relativeW then element.wPercent = clamp((nw / editor.canvas.width) * 100, 1, 100) end
    if element.relativeH then element.hPercent = clamp((nh / editor.canvas.height) * 100, 1, 100) end
    setElementCanvasPosition(element, nx, ny)
    normalizeElementLayout(element)

    local deltaX = nx - editor.interaction.startX
    local deltaY = ny - editor.interaction.startY
    local deltaW = nw - editor.interaction.startW
    local deltaH = nh - editor.interaction.startH
    local snapshots = editor.interaction.resizeSnapshots
    if snapshots then
        for _, snap in ipairs(snapshots) do
            if snap.id ~= element.id then
                local sel = getElementById(snap.id)
                if sel then
                    local nextW = clamp(round(snap.w + deltaW), minSize, editor.canvas.width)
                    local nextH = clamp(round(snap.h + deltaH), minSize, editor.canvas.height)
                    sel.w = nextW
                    sel.h = nextH
                    if sel.relativeW then sel.wPercent = clamp((nextW / editor.canvas.width) * 100, 1, 100) end
                    if sel.relativeH then sel.hPercent = clamp((nextH / editor.canvas.height) * 100, 1, 100) end
                    setElementCanvasPosition(sel, snap.x + deltaX, snap.y + deltaY)
                    normalizeElementLayout(sel)
                end
            end
        end
    end
    markDirty()
end

function detectPanelHover(layout)
    local cx, cy = getScreenCursor()
    if not cx then return "" end
    for i = #editor.hotboxes, 1, -1 do
        local hb = editor.hotboxes[i]
        if (hb.kind == "action" or hb.kind == "layer" or hb.kind == "layer_visibility" or hb.kind == "property" or hb.kind == "color_slider") then
            if insideRect(cx, cy, hb.x, hb.y, hb.w, hb.h) then
                return hb.kind .. "_" .. round(hb.x) .. "_" .. round(hb.y)
            end
        end
    end
    local lp = layout.left
    local rp = layout.right
    if insideRect(cx, cy, 0, 0, layout.screenW, layout.topBarH) then return "topbar" end
    if insideRect(cx, cy, lp.x, lp.y, lp.w, lp.h) then return "leftpanel" end
    if insideRect(cx, cy, rp.x, rp.y, rp.w, rp.h) then return "rightpanel" end
    return ""
end

function renderEditor()
    if not editor.open then return end
    _lastFrameTime = getTickCount()
    refreshFrameCache()
    local layout = getLayout()
    updateInteraction(layout)
    editor.hotboxes = {}

    local sw, sh = layout.screenW, layout.screenH

    if editor.previewMode then
        dxDrawRectangle(0, 0, sw, sh, themeColors.overlay)
        drawCanvas(layout)
        return
    end

    if not _panelRT or not isElement(_panelRT) or _panelRTW ~= sw or _panelRTH ~= sh then
        if _panelRT and isElement(_panelRT) then destroyElement(_panelRT) end
        _panelRT = dxCreateRenderTarget(sw, sh, true)
        _panelRTW = sw; _panelRTH = sh
        editor.panelDirty = true
    end

    local needsRedraw = editor.panelDirty
    if editor.interaction then needsRedraw = true end
    if editor.activeInput then needsRedraw = true end
    if _uiSvgPendingFrames > 0 then
        needsRedraw = true
        _uiSvgPendingFrames = _uiSvgPendingFrames - 1
    end

    if needsRedraw and _panelRT and isElement(_panelRT) then
        _skipPanelDraw = false
        dxSetRenderTarget(_panelRT, true)
        dxSetBlendMode("modulate_add")
        drawTopBar(layout)
        drawLeftPanel(layout)
        drawRightPanel(layout)
        drawColorPicker(sw, sh)
        dxSetBlendMode("blend")
        dxSetRenderTarget()
        editor.panelDirty = false
        _cachedHotboxes = {}
        for i, hb in ipairs(editor.hotboxes) do _cachedHotboxes[i] = hb end
    else
        if _cachedHotboxes then
            editor.hotboxes = _cachedHotboxes
        end
    end

    dxDrawRectangle(0, 0, sw, sh, themeColors.overlay)
    drawCanvas(layout)

    if _panelRT and isElement(_panelRT) then
        dxDrawImage(0, 0, sw, sh, _panelRT)
    else
        _skipPanelDraw = false
        drawTopBar(layout)
        drawLeftPanel(layout)
        drawRightPanel(layout)
        drawColorPicker(sw, sh)
    end

    if editor.enumDropdown and editor.enumDropdown._anchorX and editor.enumDropdown.options then
        local dd = editor.enumDropdown
        local optionH = 26
        local maxVisible = math.min(#dd.options, 8)
        local ddW = dd._anchorW
        local ddH = maxVisible * optionH + 8
        local ddX = dd._anchorX
        local ddY = dd._anchorY + 2

        if ddY + ddH > sh - 10 then ddY = dd._anchorY - ddH - 34 end

        dxDrawUiRounded("enum_dd_bg", ddX, ddY, ddW, ddH, 6, tocolor(28, 28, 36, 250))
        drawOutline(ddX, ddY, ddW, ddH, themeColors.panelBorder, 1)

        local el = getSelectedElement()
        local currentVal = el and el[dd.key] or ""
        local cx, cy = getScreenCursor()
        local scrollOffset = dd.scroll or 0
        local totalOptions = #dd.options
        local maxScroll = math.max(0, totalOptions - maxVisible)
        dd.scroll = clamp(scrollOffset, 0, maxScroll)

        for i = 1, maxVisible do
            local optIdx = i + dd.scroll
            if optIdx > totalOptions then break end
            local opt = dd.options[optIdx]
            local optY = ddY + 4 + (i - 1) * optionH
            local isSelected = opt == currentVal
            local isHovered = cx and insideRect(cx, cy, ddX + 4, optY, ddW - 8, optionH)

            if isSelected then
                dxDrawUiRounded("enum_opt_" .. optIdx, ddX + 4, optY, ddW - 8, optionH, 4, themeColors.accent)
                dxDrawText(opt, ddX + 12, optY, ddX + ddW - 12, optY + optionH, tocolor(10, 12, 18, 255), 1, UI_FONT_MEDIUM_SM, "left", "center", true, false, true)
            elseif isHovered then
                dxDrawUiRounded("enum_opt_" .. optIdx, ddX + 4, optY, ddW - 8, optionH, 4, themeColors.panelAlt)
                dxDrawText(opt, ddX + 12, optY, ddX + ddW - 12, optY + optionH, themeColors.text, 1, UI_FONT_MEDIUM_SM, "left", "center", true, false, true)
            else
                dxDrawText(opt, ddX + 12, optY, ddX + ddW - 12, optY + optionH, themeColors.text, 1, UI_FONT_MEDIUM_SM, "left", "center", true, false, true)
            end
        end

        if maxScroll > 0 then
            local barX = ddX + ddW - 8
            local barH = ddH - 8
            local thumbH = math.max(16, (maxVisible / totalOptions) * barH)
            local thumbY = ddY + 4 + (dd.scroll / maxScroll) * (barH - thumbH)
            dxDrawUiRounded("enum_scroll_bg", barX, ddY + 4, 4, barH, 2, themeColors.panelAlt)
            dxDrawUiRounded("enum_scroll_thumb", barX, round(thumbY), 4, round(thumbH), 2, themeColors.accent)
        end

        editor.enumDropdown._ddX = ddX
        editor.enumDropdown._ddY = ddY
        editor.enumDropdown._ddW = ddW
        editor.enumDropdown._ddH = ddH
    end

    if _previewDrag then
        local cx, cy = getScreenCursor()
        if cx and getKeyState("mouse1") then
            local delta = _previewDrag.lastY - cy
            editor.previewScroll = clamp((editor.previewScroll or 0) + delta, 0, editor.previewScrollMax or 0)
            _previewDrag.lastY = cy
            editor.panelDirty = true
        else
            _previewDrag = nil
        end
    end

    if editor.panning then
        local cx, cy = getScreenCursor()
        if cx and getKeyState("mouse3") then
            editor.canvasPanX = (editor.canvasPanX or 0) + (cx - editor.panning.lastX)
            editor.canvasPanY = (editor.canvasPanY or 0) + (cy - editor.panning.lastY)
            editor.panning.lastX = cx
            editor.panning.lastY = cy
        else
            editor.panning = nil
        end
    end

    local hoverKey = detectPanelHover(layout)
    if hoverKey ~= _lastHoverKey then
        _lastHoverKey = hoverKey
        editor.panelDirty = true
    end

    drawTooltip()

    if editor.exportModal then
        local modal = editor.exportModal
        local mw, mh = 500, 220
        local mx = (sw - mw) / 2
        local my = (sh - mh) / 2

        dxDrawRectangle(0, 0, sw, sh, tocolor(0, 0, 0, 160))
        dxDrawUiRounded("export_modal_bg", mx, my, mw, mh, 10, tocolor(24, 24, 32, 250))
        drawOutline(mx, my, mw, mh, themeColors.panelBorder, 1)

        dxDrawText("Export Konumu", mx + 20, my + 16, mx + mw - 20, my + 44, themeColors.text, 1, UI_FONT_BOLD_LG, "left", "top", false, false, true)
        dxDrawText("Resource adini girin (ornek: my-ui)", mx + 20, my + 46, mx + mw - 20, my + 64, themeColors.muted, 1, UI_FONT_MEDIUM_XS, "left", "top", false, false, true)

        local inputX = mx + 20
        local inputY = my + 74
        local inputW = mw - 40
        local inputH = 36
        local isInputActive = true

        dxDrawUiRounded("export_input_bg", inputX, inputY, inputW, inputH, 6, themeColors.accent)

        local displayText = modal.path
        if displayText == "" then
            dxDrawText("resource-adi-girin...", inputX + 10, inputY, inputX + inputW - 10, inputY + inputH, tocolor(80, 80, 100, 255), 1, UI_FONT_MEDIUM, "left", "center", true, false, true)
        else
            dxDrawText(displayText, inputX + 10, inputY, inputX + inputW - 10, inputY + inputH, tocolor(10, 12, 18, 255), 1, UI_FONT_MEDIUM, "left", "center", true, false, true)
        end

        local blinkPhase = (getTickCount() - (editor.cursorBlink or 0)) % 1000
        if blinkPhase < 530 then
            local cursor = modal.cursor or 0
            local beforeCursor = cursor > 0 and utfSub(modal.path, 1, cursor) or ""
            local cursorX = inputX + 10 + dxGetTextWidth(beforeCursor, 1, UI_FONT_MEDIUM)
            cursorX = math.min(cursorX, inputX + inputW - 10)
            dxDrawRectangle(cursorX, inputY + 8, 2, inputH - 16, tocolor(10, 12, 18, 255))
        end

        local btnW = (mw - 52) / 2
        local btnY = my + 126
        local btnH = 36

        local cx, cy = getScreenCursor()
        local hovExport = cx and insideRect(cx, cy, mx + 20, btnY, btnW, btnH)
        local hovCancel = cx and insideRect(cx, cy, mx + 20 + btnW + 12, btnY, btnW, btnH)

        dxDrawUiRounded("export_btn_ok", mx + 20, btnY, btnW, btnH, 6, hovExport and tocolor(92, 219, 150, 255) or tocolor(72, 199, 130, 255))
        dxDrawText("Export Et", mx + 20, btnY, mx + 20 + btnW, btnY + btnH, tocolor(10, 12, 18, 255), 1, UI_FONT_BOLD, "center", "center", false, false, true)

        dxDrawUiRounded("export_btn_cancel", mx + 20 + btnW + 12, btnY, btnW, btnH, 6, hovCancel and tocolor(255, 110, 110, 255) or tocolor(235, 85, 85, 255))
        dxDrawText("Iptal", mx + 20 + btnW + 12, btnY, mx + 20 + btnW*2 + 12, btnY + btnH, tocolor(255, 255, 255, 255), 1, UI_FONT_BOLD, "center", "center", false, false, true)

        if modal.status then
            dxDrawText(modal.status, mx + 20, btnY + btnH + 8, mx + mw - 20, btnY + btnH + 28, themeColors.success, 1, UI_FONT_MEDIUM_XS, "left", "top", false, false, true)
        end

        editor.exportModal._mx = mx
        editor.exportModal._my = my
        editor.exportModal._mw = mw
        editor.exportModal._mh = mh
        editor.exportModal._btnW = btnW
        editor.exportModal._btnY = btnY
        editor.exportModal._btnH = btnH
        editor.exportModal._inputX = inputX
        editor.exportModal._inputY = inputY
        editor.exportModal._inputW = inputW
        editor.exportModal._inputH = inputH
    end
end

local TEMPLATES = {
    login = {
        {type="rectangle", id="login_bg", x=0, y=0, w=1280, h=720, color={12,15,22,255}, radius=0, anchorX="left", anchorY="top"},
        {type="rectangle", id="login_panel", x=440, y=110, w=400, h=500, color={22,26,36,245}, radius=24, anchorX="left", anchorY="top"},
        {type="label", id="login_title", x=520, y=140, w=240, h=50, text="Giriş Yap", textColor={255,255,255,255}, fontScale=1.6, font="gilroy-bold", alignX="center", alignY="center"},
        {type="label", id="login_subtitle", x=490, y=190, w=300, h=30, text="Hesabınıza giriş yapın", textColor={140,145,165,255}, fontScale=0.9, font="gilroy-medium", alignX="center", alignY="center"},
        {type="editbox", id="login_user", x=480, y=250, w=320, h=46, text="", placeholder="Kullanıcı adı...", color={16,19,28,240}, borderColor={63,124,255,120}, textColor={255,255,255,255}, font="gilroy-medium", radius=12},
        {type="editbox", id="login_pass", x=480, y=310, w=320, h=46, text="", placeholder="Şifre...", color={16,19,28,240}, borderColor={63,124,255,120}, textColor={255,255,255,255}, font="gilroy-medium", radius=12, masked=true},
        {type="button", id="login_btn", x=480, y=390, w=320, h=52, text="Giriş Yap", color={63,124,255,240}, hoverColor={92,150,255,250}, textColor={255,255,255,255}, font="gilroy-bold", fontScale=1.1, radius=14, alignX="center", alignY="center"},
        {type="button", id="register_btn", x=480, y=456, w=320, h=44, text="Kayıt Ol", color={32,37,50,230}, hoverColor={42,48,65,240}, textColor={160,170,200,255}, font="gilroy-medium", fontScale=0.95, radius=12, alignX="center", alignY="center"},
        {type="line", id="login_divider", x=500, y=520, w=280, h=2, color={60,65,85,120}, thickness=1},
        {type="label", id="login_footer", x=480, y=540, w=320, h=30, text="© 2026 Server Adı", textColor={80,85,105,200}, fontScale=0.75, font="gilroy-light", alignX="center", alignY="center"},
    },
    notification = {
        {type="rectangle", id="notif_bg", x=440, y=20, w=400, h=90, color={22,28,42,240}, radius=16, anchorX="left", anchorY="top",
            animationType="slide-down", animationTrigger="auto", animationDuration=600, animationIntensity=30},
        {type="rectangle", id="notif_accent", x=440, y=20, w=5, h=90, color={72,199,130,255}, radius=3, anchorX="left", anchorY="top"},
        {type="icon", id="notif_icon", x=460, y=38, w=36, h=36, iconName="save", color={72,199,130,255}, iconSize=28},
        {type="label", id="notif_title", x=506, y=32, w=300, h=26, text="Başarılı!", textColor={255,255,255,255}, fontScale=1.1, font="gilroy-bold", alignX="left", alignY="center"},
        {type="label", id="notif_desc", x=506, y=60, w=310, h=22, text="İşleminiz başarıyla tamamlandı.", textColor={160,170,200,255}, fontScale=0.85, font="gilroy-medium", alignX="left", alignY="center"},
    },
    inventory = {
        {type="rectangle", id="inv_bg", x=240, y=60, w=800, h=600, color={14,17,24,250}, radius=20, anchorX="left", anchorY="top"},
        {type="rectangle", id="inv_header", x=240, y=60, w=800, h=56, color={22,28,42,250}, radius=0, anchorX="left", anchorY="top"},
        {type="label", id="inv_title", x=270, y=60, w=300, h=56, text="Envanter", textColor={255,255,255,255}, fontScale=1.2, font="gilroy-bold", alignX="left", alignY="center"},
        {type="rectangle", id="inv_slot1", x=268, y=140, w=80, h=80, color={28,34,50,230}, radius=12},
        {type="rectangle", id="inv_slot2", x=360, y=140, w=80, h=80, color={28,34,50,230}, radius=12},
        {type="rectangle", id="inv_slot3", x=452, y=140, w=80, h=80, color={28,34,50,230}, radius=12},
        {type="rectangle", id="inv_slot4", x=544, y=140, w=80, h=80, color={28,34,50,230}, radius=12},
        {type="rectangle", id="inv_slot5", x=636, y=140, w=80, h=80, color={28,34,50,230}, radius=12},
        {type="rectangle", id="inv_slot6", x=728, y=140, w=80, h=80, color={28,34,50,230}, radius=12},
        {type="rectangle", id="inv_slot7", x=820, y=140, w=80, h=80, color={28,34,50,230}, radius=12},
        {type="rectangle", id="inv_slot8", x=912, y=140, w=80, h=80, color={28,34,50,230}, radius=12},
        {type="rectangle", id="inv_detail_bg", x=268, y=500, w=744, h=130, color={22,28,42,230}, radius=14},
        {type="label", id="inv_item_name", x=288, y=510, w=300, h=30, text="Seçili Eşya Adı", textColor={255,255,255,255}, fontScale=1.05, font="gilroy-bold", alignX="left", alignY="center"},
        {type="label", id="inv_item_desc", x=288, y=540, w=700, h=30, text="Eşyanın açıklaması burada yer alacak.", textColor={140,150,175,255}, fontScale=0.85, font="gilroy-medium", alignX="left", alignY="center"},
        {type="button", id="inv_use_btn", x=850, y=570, w=140, h=40, text="Kullan", color={63,124,255,240}, hoverColor={92,150,255,250}, textColor={255,255,255,255}, radius=10, font="gilroy-bold", alignX="center", alignY="center"},
    },
    hud = {
        {type="rectangle", id="hud_hp_bg", x=20, y=656, w=260, h=24, color={18,22,32,200}, radius=8, anchorX="left", anchorY="top"},
        {type="progressbar", id="hud_hp_bar", x=20, y=656, w=260, h=24, progress=78, color={18,22,32,0}, progressColor={220,60,60,230}, textColor={255,255,255,255}, text="78 HP", radius=8, fontScale=0.8, font="gilroy-bold", alignX="center"},
        {type="rectangle", id="hud_armor_bg", x=20, y=688, w=260, h=24, color={18,22,32,200}, radius=8, anchorX="left", anchorY="top"},
        {type="progressbar", id="hud_armor_bar", x=20, y=688, w=260, h=24, progress=45, color={18,22,32,0}, progressColor={63,124,255,220}, textColor={255,255,255,255}, text="45 Armor", radius=8, fontScale=0.8, font="gilroy-bold", alignX="center"},
        {type="rectangle", id="hud_money_bg", x=1060, y=20, w=200, h=40, color={18,22,32,200}, radius=10, anchorX="left", anchorY="top"},
        {type="label", id="hud_money_label", x=1070, y=20, w=180, h=40, text="$125,000", textColor={72,199,130,255}, fontScale=1.2, font="gilroy-bold", alignX="right", alignY="center"},
        {type="icon", id="hud_weapon_icon", x=1200, y=654, w=48, h=48, iconName="front", color={255,255,255,200}, iconSize=36},
        {type="label", id="hud_ammo", x=1140, y=660, w=60, h=36, text="30/120", textColor={255,255,255,220}, fontScale=0.9, font="gilroy-bold", alignX="right", alignY="center"},
    },
}

function spawnTemplate(name)
    local template = TEMPLATES[name]
    if not template then return end
    saveUndoState()
    local created = {}
    for _, item in ipairs(template) do
        local el = createDefaultElement(item.type)
        for key, value in pairs(item) do
            if key ~= "type" then
                if type(value) == "table" then
                    el[key] = {}
                    for ii = 1, #value do el[key][ii] = value[ii] end
                else
                    el[key] = value
                end
            end
        end
        el.id = item.id or el.id
        table.insert(editor.elements, el)
        created[#created+1] = el.id
    end
    if #created > 0 then
        setSelection(created, created[#created])
    end
    updateAssetLibrary()
    markDirty()
    outputChatBox("[DX UI Creator] Sablon yuklendi: " .. name .. " (" .. #created .. " eleman)", 115,191,136,true)
end

function handleAction(action)
    if editor.activeInput and not commitActiveInput() then return end

    if     action == "add_window"        then addElement("window")
    elseif action == "add_button"        then addElement("button")
    elseif action == "add_label"         then addElement("label")
    elseif action == "add_rectangle"     then addElement("rectangle")
    elseif action == "add_image"         then addElement("image")
    elseif action == "add_container"     then addElement("container")
    elseif action == "add_progressbar"   then addElement("progressbar")
    elseif action == "add_checkbox"      then addElement("checkbox")
    elseif action == "add_editbox"       then addElement("editbox")
    elseif action == "add_line"          then addElement("line")
    elseif action == "add_gradient"      then addElement("gradient")
    elseif action == "add_icon"          then addElement("icon")
    elseif action == "add_circle"        then addElement("circle")
    elseif action == "bring_front"       then moveSelectedLayer("front")
    elseif action == "send_back"         then moveSelectedLayer("back")
    elseif action == "layer_up"          then moveSelectedLayer("up")
    elseif action == "layer_down"        then moveSelectedLayer("down")
    elseif action == "duplicate_selected"then duplicateSelected()
    elseif action == "delete_selected"   then deleteSelected()
    elseif action == "clear_canvas"      then clearCanvas()
    elseif action == "save_project"      then saveToFile()
    elseif action == "load_project"      then loadFromFile()
    elseif action == "export_to_file"    then exportToLuaFile()
    elseif action == "align_left"        then alignSelected("left")
    elseif action == "align_centerX"     then alignSelected("centerX")
    elseif action == "align_right"       then alignSelected("right")
    elseif action == "align_top"         then alignSelected("top")
    elseif action == "align_centerY"     then alignSelected("centerY")
    elseif action == "align_bottom"      then alignSelected("bottom")
    elseif action == "distribute_x"      then distributeSelection("x")
    elseif action == "distribute_y"      then distributeSelection("y")
    elseif action == "same_width"        then applySameSize("w")
    elseif action == "same_height"       then applySameSize("h")
    elseif action == "group_selection"   then groupSelection()
    elseif action == "ungroup_selection" then ungroupSelection()
    elseif action == "parent_selection"  then parentSelectionToPrimary()
    elseif action == "clear_parent"      then clearParentFromSelection()
    elseif action == "copy_style"        then copySelectedStyle()
    elseif action == "paste_style"       then pasteSelectedStyle()
    elseif action == "preview_mode"      then editor.previewMode = not editor.previewMode; editor.panelDirty = true
    elseif action == "save_prefab"       then savePrefabFromSelection()
    elseif action:sub(1,5) == "grid_" then
        local size = tonumber(action:sub(6))
        if size and size > 0 then
            editor.canvas.grid = size
            editor.panelDirty = true
            outputChatBox("[DX UI Creator] Grid boyutu: " .. size .. "px", 75,144,255,true)
        end
    elseif action:sub(1,7) == "preset_" then
        local i = tonumber(action:sub(8))
        local preset = CANVAS_PRESETS[i]
        if preset then
            saveUndoState()
            editor.canvas.width  = preset.w
            editor.canvas.height = preset.h
            for _, el in ipairs(editor.elements) do
                if not el.relativeW and el.dockX ~= "fill" then
                    el.w = math.min(el.w, preset.w)
                    el.x = clamp(el.x, 0, math.max(0, preset.w - el.w))
                end
                if not el.relativeH and el.dockY ~= "fill" then
                    el.h = math.min(el.h, preset.h)
                    el.y = clamp(el.y, 0, math.max(0, preset.h - el.h))
                end
                if el.dockX == "fill" then el.x = clamp(el.x, 0, math.max(0, preset.w - 20)) end
                if el.dockY == "fill" then el.y = clamp(el.y, 0, math.max(0, preset.h - 20)) end
                normalizeElementLayout(el)
            end
            markDirty()
            outputChatBox("[DX UI Creator] Canvas boyutu: "..preset.label, 75,144,255,true)
        end
    elseif action:sub(1,13) == "style_preset_" then
        applyStylePreset(tonumber(action:sub(14)))
    elseif action:sub(1,7) == "prefab_" then
        spawnPrefab(tonumber(action:sub(8)))
    elseif action == "template_login" then spawnTemplate("login")
    elseif action == "template_notification" then spawnTemplate("notification")
    elseif action == "template_inventory" then spawnTemplate("inventory")
    elseif action == "template_hud" then spawnTemplate("hud")
    elseif action == "copy_export" then
        ensureExport()
        local copied = type(setClipboard)=="function" and setClipboard(editor.exportCache) ~= false
        if copied then outputChatBox("[DX UI Creator] Export kodu panoya kopyalandi.", 75,144,255,true)
        else outputChatBox("[DX UI Creator] Clipboard destegi yok, sag panelden al.", 230,164,52,true) end
    elseif action == "tab_right_design" then
        editor.rightPanelTab = "design"; editor.panelDirty = true
    elseif action == "tab_right_code"   then
        editor.rightPanelTab = "code";   editor.panelDirty = true
    elseif action == "toggle_snap" then
        editor.snapEnabled = not editor.snapEnabled; editor.panelDirty = true
        outputChatBox("[DX UI Creator] Snap: "..(editor.snapEnabled and "Açık" or "Kapalı"), 123,104,238,true)
    elseif action == "toggle_smart_snap" then
        editor.smartSnapEnabled = not editor.smartSnapEnabled; editor.panelDirty = true
        outputChatBox("[DX UI Creator] Kılavuz: "..(editor.smartSnapEnabled and "Açık" or "Kapalı"), 123,104,238,true)
    end
end

function toggleEditor()
    editor.open = not editor.open
    if not editor.open then editor.interaction=nil; editor.activeInput=nil; editor.colorPicker=nil; editor.rubberBand=nil end
    showCursor(editor.open)
    if editor.open then
        editor.wasChatVisible = isChatVisible()
        showChat(false)
    else
        showChat(editor.wasChatVisible == true)
        editor.wasChatVisible = nil
    end
end

addEventHandler("onClientClick", root, function(button, state, absoluteX, absoluteY)
    if not editor.open then return end

    if button == "middle" then
        if state == "down" then
            local layout = getLayout()
            local canvasAreaX = layout.left.x + layout.left.w
            local canvasAreaW = layout.right.x - canvasAreaX
            if absoluteX >= canvasAreaX and absoluteX <= canvasAreaX + canvasAreaW then
                editor.panning = {lastX = absoluteX, lastY = absoluteY}
            end
        else
            editor.panning = nil
        end
        return
    end

    if button ~= "left" then
        if state == "up" then editor.interaction = nil end
        return
    end

    if editor.exportModal and editor.exportModal._mx and state == "down" then
        local m = editor.exportModal
        local btnW = m._btnW
        if insideRect(absoluteX, absoluteY, m._mx + 20, m._btnY, btnW, m._btnH) then
            if doExport(m.path) then
                editor.exportModal.status = "Export baslatildi: " .. m.path
                setTimer(closeExportModal, 1500, 1)
            end
            return
        elseif insideRect(absoluteX, absoluteY, m._mx + 20 + btnW + 12, m._btnY, btnW, m._btnH) then
            closeExportModal()
            return
        elseif not insideRect(absoluteX, absoluteY, m._mx, m._my, m._mw, m._mh) then
            closeExportModal()
            return
        end
        return
    end

    if state == "up" then
        if editor.interaction and editor.interaction.mode == "color_slider" then
            editor.interaction = nil; return
        end
        if editor.interaction and editor.interaction.mode == "layer_reorder" then
            local info    = editor.layersBoxInfo
            local dragId  = editor.interaction.elementId
            local tSlot   = editor.interaction.targetSlot or 0
            if info and dragId then
                local fromIdx = getElementIndexById(dragId)
                if fromIdx then
                    local toIdx = clamp(info.startIndex - tSlot, 1, #editor.elements)
                    if toIdx ~= fromIdx then
                        saveUndoState()
                        local el = table.remove(editor.elements, fromIdx)
                        table.insert(editor.elements, toIdx, el)
                        markDirty()
                    end
                end
            end
            editor.interaction = nil; return
        end
        if editor.interaction and editor.interaction.mode == "rubber_band" then
            if editor.rubberBand then
                local rb = editor.rubberBand
                local rbX1 = math.min(rb.startX, rb.currentX)
                local rbY1 = math.min(rb.startY, rb.currentY)
                local rbX2 = math.max(rb.startX, rb.currentX)
                local rbY2 = math.max(rb.startY, rb.currentY)
                local rbW = rbX2 - rbX1
                local rbH = rbY2 - rbY1
                if rbW > 3 or rbH > 3 then
                    local hitIds = {}
                    for _, el in ipairs(editor.elements) do
                        if el.visible ~= false then
                            local elX, elY, elW, elH = getElementCanvasRect(el)
                            local elX2 = elX + elW
                            local elY2 = elY + elH
                            if elX < rbX2 and elX2 > rbX1 and elY < rbY2 and elY2 > rbY1 then
                                hitIds[#hitIds+1] = el.id
                            end
                        end
                    end
                    if #hitIds > 0 then
                        if rb.ctrl then
                            for _, id in ipairs(hitIds) do addToSelection(id, false) end
                        else
                            setSelection(hitIds, hitIds[#hitIds])
                        end
                    end
                end
                editor.rubberBand = nil
            end
            editor.interaction = nil; return
        end
        editor.interaction = nil; return
    end

    if editor.enumDropdown and editor.enumDropdown._ddX then
        local dd = editor.enumDropdown
        if insideRect(absoluteX, absoluteY, dd._ddX, dd._ddY, dd._ddW, dd._ddH) then
            local optionH = 26
            local clickIdx = math.floor((absoluteY - dd._ddY - 4) / optionH) + 1 + (dd.scroll or 0)
            if clickIdx >= 1 and clickIdx <= #dd.options then
                local el = getSelectedElement()
                if el and el.id == dd.elementId then
                    saveUndoState()
                    local oldX, oldY, oldW, oldH = getElementCanvasRect(el)
                    el[dd.key] = dd.options[clickIdx]
                    if dd.key == "anchorX" or dd.key == "anchorY" then
                        setElementCanvasPosition(el, oldX, oldY)
                    elseif dd.key == "dockX" then
                        if el.dockX == "fill" then
                            el.anchorX = "left"
                            el.x = oldX
                            el.dockPaddingRight = clamp(editor.canvas.width - oldX - oldW, 0, editor.canvas.width)
                        else
                            el.w = oldW
                            setElementCanvasPosition(el, oldX, oldY)
                        end
                    elseif dd.key == "dockY" then
                        if el.dockY == "fill" then
                            el.anchorY = "top"
                            el.y = oldY
                            el.dockPaddingBottom = clamp(editor.canvas.height - oldY - oldH, 0, editor.canvas.height)
                        else
                            el.h = oldH
                            setElementCanvasPosition(el, oldX, oldY)
                        end
                    elseif dd.key == "relativeW" then
                        if el.relativeW then
                            el.wPercent = clamp((oldW / editor.canvas.width) * 100, 1, 100)
                        else
                            el.w = oldW
                        end
                    elseif dd.key == "relativeH" then
                        if el.relativeH then
                            el.hPercent = clamp((oldH / editor.canvas.height) * 100, 1, 100)
                        else
                            el.h = oldH
                        end
                    end
                    markDirty()
                end
            end
            editor.enumDropdown = nil
            return
        else
            editor.enumDropdown = nil
        end
    end

    if editor.colorPicker then
        for i = #editor.hotboxes, 1, -1 do
            local hb = editor.hotboxes[i]
            if insideRect(absoluteX, absoluteY, hb.x, hb.y, hb.w, hb.h) then
                if hb.kind == "color_slider" then
                    local ratio = clamp((absoluteX - hb.data.barX) / hb.data.barW, 0, 1)
                    editor.colorPicker[hb.data.channel] = round(ratio * 255)
                    commitColorPicker()
                    editor.interaction = {mode="color_slider", channel=hb.data.channel, barX=hb.data.barX, barW=hb.data.barW}
                    return
                elseif hb.kind == "color_hex_copy" then
                    if type(setClipboard) == "function" then
                        setClipboard(hb.data.hex)
                        outputChatBox("[DX UI Creator] Hex kopyalandi: "..hb.data.hex, 75,144,255,true)
                    end
                    return
                elseif hb.kind == "recent_color" then
                    editor.colorPicker.r = hb.data.r
                    editor.colorPicker.g = hb.data.g
                    editor.colorPicker.b = hb.data.b
                    editor.colorPicker.a = hb.data.a
                    commitColorPicker()
                    return
                elseif hb.kind == "color_picker_bg" then
                    return
                end
            end
        end
        editor.colorPicker = nil
    end

    local layout = getLayout()

    for i = #editor.hotboxes, 1, -1 do
        local hb = editor.hotboxes[i]
        if insideRect(absoluteX, absoluteY, hb.x, hb.y, hb.w, hb.h) then
            if hb.kind == "action" then
                handleAction(hb.data.action); return
            elseif hb.kind == "layer_visibility" then
                for _, el in ipairs(editor.elements) do
                    if el.id == hb.data.id then
                        saveUndoState()
                        el.visible = not (el.visible ~= false)
                        markDirty()
                        break
                    end
                end
                return
            elseif hb.kind == "layer" then
                local ctrlDown = getKeyState("lctrl") or getKeyState("rctrl")
                if ctrlDown then
                    if isElementSelected(hb.data.id) then removeFromSelection(hb.data.id) else addToSelection(hb.data.id, true) end
                else
                    setSelectedElement(hb.data.id)
                end
                editor.interaction = {mode="layer_reorder", elementId=hb.data.id, targetSlot=0}
                return
            elseif hb.kind == "property" then
                beginPropertyInput(hb.data); return
            elseif hb.kind == "preview_drag" then
                _previewDrag = { lastY = absoluteY }
                return
            elseif hb.kind == "handle" then
                local sel = getElementById(hb.data.id)
                if sel and isElementSelected(sel.id) and not sel.locked then
                    local cx2, cy2 = screenToCanvas(layout, absoluteX, absoluteY)
                    beginResize(sel, hb.data.handle, cx2, cy2); return
                end
            end
        end
    end

    if editor.activeInput and not commitActiveInput() then return end

    if insideRect(absoluteX, absoluteY, layout.canvas.x, layout.canvas.y, layout.canvas.w, layout.canvas.h) then
        local cx2, cy2 = screenToCanvas(layout, absoluteX, absoluteY)
        local el = findTopElementAt(cx2, cy2)
        local ctrlDown = getKeyState("lctrl") or getKeyState("rctrl")
        if el then
            if ctrlDown then
                if isElementSelected(el.id) then removeFromSelection(el.id) else addToSelection(el.id, true) end
            else
                if not isElementSelected(el.id) then
                    setSelectedElement(el.id)
                else
                    editor.selectedId = el.id
                end
            end
            if not el.locked then beginDrag(el, cx2, cy2) end
        else
            if not ctrlDown then clearSelection() end
            editor.rubberBand = {startX = cx2, startY = cy2, currentX = cx2, currentY = cy2, ctrl = ctrlDown}
            editor.interaction = {mode = "rubber_band"}
        end
        return
    end

    clearSelection()
end)

addEventHandler("onClientKey", root, function(button, press)
    if not editor.open or not press then return end

    if editor.exportModal then
        local modal = editor.exportModal
        if button == "escape" then closeExportModal(); cancelEvent(); return end
        if button == "enter" then
            if doExport(modal.path) then
                modal.status = "Export baslatildi: " .. modal.path
                setTimer(closeExportModal, 1500, 1)
            end
            cancelEvent(); return
        end
        if button == "backspace" then
            if modal.cursor > 0 then
                local before = modal.cursor > 1 and utfSub(modal.path, 1, modal.cursor - 1) or ""
                local after = utfSub(modal.path, modal.cursor + 1, utfLen(modal.path))
                modal.path = before .. after
                modal.cursor = modal.cursor - 1
                editor.cursorBlink = getTickCount()
            end
            cancelEvent(); return
        end
        if button == "arrow_l" then
            modal.cursor = math.max(0, modal.cursor - 1)
            editor.cursorBlink = getTickCount()
            cancelEvent(); return
        end
        if button == "arrow_r" then
            modal.cursor = math.min(utfLen(modal.path), modal.cursor + 1)
            editor.cursorBlink = getTickCount()
            cancelEvent(); return
        end
        if button == "delete" then
            local len = utfLen(modal.path)
            if modal.cursor < len then
                local before = modal.cursor > 0 and utfSub(modal.path, 1, modal.cursor) or ""
                local after = utfSub(modal.path, modal.cursor + 2, len)
                modal.path = before .. after
                editor.cursorBlink = getTickCount()
            end
            cancelEvent(); return
        end
        cancelEvent(); return
    end

    if (button == "mouse_wheel_up" or button == "mouse_wheel_down") and editor.enumDropdown and editor.enumDropdown._ddX then
        local dd = editor.enumDropdown
        local cx, cy = getScreenCursor()
        if cx and insideRect(cx, cy, dd._ddX, dd._ddY, dd._ddW, dd._ddH) then
            local maxVisible = math.min(#dd.options, 8)
            local maxScroll = math.max(0, #dd.options - maxVisible)
            dd.scroll = clamp((dd.scroll or 0) + (button == "mouse_wheel_up" and -1 or 1), 0, maxScroll)
            editor.panelDirty = true
            cancelEvent(); return
        end
    end

    if (button == "mouse_wheel_up" or button == "mouse_wheel_down") then
        local cx, cy = getScreenCursor()
        if cx then
            if editor.layersArea and insideRect(cx, cy, editor.layersArea.x, editor.layersArea.y, editor.layersArea.w, editor.layersArea.h) then
                editor.layersScroll = clamp((editor.layersScroll or 0) + (button=="mouse_wheel_up" and -1 or 1), 0, math.max(0,#editor.elements-1))
                editor.panelDirty = true
                cancelEvent(); return
            end
            if editor.inspectorArea and insideRect(cx, cy, editor.inspectorArea.x, editor.inspectorArea.y, editor.inspectorArea.w, editor.inspectorArea.h) then
                editor.inspectorScroll = clamp((editor.inspectorScroll or 0) + (button=="mouse_wheel_up" and -36 or 36), 0, editor.inspectorScrollMax or 0)
                editor.panelDirty = true
                cancelEvent(); return
            end
            if editor.previewArea and insideRect(cx, cy, editor.previewArea.x, editor.previewArea.y, editor.previewArea.w, editor.previewArea.h) then
                editor.previewScroll = clamp((editor.previewScroll or 0) + (button=="mouse_wheel_up" and -28 or 28), 0, editor.previewScrollMax or 0)
                editor.panelDirty = true
                cancelEvent(); return
            end
            if editor.zoomArea and insideRect(cx, cy, editor.zoomArea.x, editor.zoomArea.y, editor.zoomArea.w, editor.zoomArea.h) then
                local delta = button == "mouse_wheel_up" and 0.1 or -0.1
                editor.canvasZoom = clamp(editor.canvasZoom + delta, 0.2, 4.0)
                cancelEvent(); return
            end
        end
    end

    if editor.activeInput then
        local input = editor.activeInput
        local shift2 = getKeyState("lshift") or getKeyState("rshift")
        local ctrl2  = getKeyState("lctrl")  or getKeyState("rctrl")

        if button == "enter" then
            commitActiveInput()
        elseif button == "escape" then
            cancelActiveInput()
        elseif button == "backspace" then
            if input.fresh then
                input.value = ""
                input.fresh = false
                inputSetCursor(input, 0)
                inputClearSelection(input)
            else
                inputBackspace(input)
            end
        elseif button == "delete" then
            if input.fresh then
                input.value = ""
                input.fresh = false
                inputSetCursor(input, 0)
                inputClearSelection(input)
            else
                inputDelete(input)
            end
        elseif button == "arrow_l" then
            input.fresh = false
            if ctrl2 then
                inputHome(input, shift2)
            else
                inputMoveCursor(input, -1, shift2)
            end
        elseif button == "arrow_r" then
            input.fresh = false
            if ctrl2 then
                inputEnd(input, shift2)
            else
                inputMoveCursor(input, 1, shift2)
            end
        elseif button == "home" then
            input.fresh = false
            inputHome(input, shift2)
        elseif button == "end" then
            input.fresh = false
            inputEnd(input, shift2)
        elseif ctrl2 and button == "a" then
            input.fresh = false
            inputSelectAll(input)
        elseif ctrl2 and button == "c" then
            local sel = inputCopySelection(input)
            if sel and sel ~= "" and type(setClipboard) == "function" then
                setClipboard(sel)
            end
        elseif ctrl2 and button == "x" then
            local sel = inputCopySelection(input)
            if sel and sel ~= "" then
                if type(setClipboard) == "function" then setClipboard(sel) end
                inputDeleteSelection(input)
            end
        elseif ctrl2 and button == "v" then
        end
        return
    end

    if button == "escape" and editor.enumDropdown then
        editor.enumDropdown = nil; return
    end

    if button == "escape" and editor.colorPicker then
        editor.colorPicker = nil; return
    end

    local shift = getKeyState("lshift") or getKeyState("rshift")
    local ctrl  = getKeyState("lctrl")  or getKeyState("rctrl")
    local step  = shift and 10 or 1

    if     button == "delete"   then deleteSelected()
    elseif button == "arrow_l"  then moveSelectedBy(-step, 0)
    elseif button == "arrow_r"  then moveSelectedBy( step, 0)
    elseif button == "arrow_u"  then moveSelectedBy(0, -step)
    elseif button == "arrow_d"  then moveSelectedBy(0,  step)
    elseif ctrl and button=="z" then undo()
    elseif ctrl and button=="y" then redo()
    elseif ctrl and button=="d" then duplicateSelected()
    elseif ctrl and shift and button=="g" then groupSelection()
    elseif ctrl and shift and button=="u" then ungroupSelection()
    elseif ctrl and shift and button=="s" then copySelectedStyle()
    elseif ctrl and shift and button=="v" then pasteSelectedStyle()
    elseif ctrl and shift and button=="c" then handleAction("copy_export")
    elseif ctrl and button=="c" then copySelectedElements()
    elseif ctrl and button=="v" then pasteClipboardElements()
    elseif ctrl and button=="a" then
        local allIds = {}
        for _, el in ipairs(editor.elements) do allIds[#allIds+1] = el.id end
        if #allIds > 0 then setSelection(allIds, allIds[#allIds]) end
    elseif ctrl and button=="s" then saveToFile()
    elseif ctrl and (button=="=" or button=="+") then
        editor.canvasZoom = clamp(editor.canvasZoom + 0.1, 0.2, 4.0)
        editor.panelDirty = true
    elseif ctrl and button=="-" then
        editor.canvasZoom = clamp(editor.canvasZoom - 0.1, 0.2, 4.0)
        editor.panelDirty = true
    elseif ctrl and button=="0" then
        editor.canvasZoom = 1.0
        editor.canvasPanX = 0
        editor.canvasPanY = 0
        editor.panelDirty = true
    elseif button == "g" then
        editor.snapEnabled = not editor.snapEnabled
        outputChatBox("[DX UI Creator] Snap-to-grid: "..(editor.snapEnabled and "AÇIK" or "KAPALI"), 75,144,255,true)
    elseif button == "h" then
        editor.smartSnapEnabled = not editor.smartSnapEnabled
        outputChatBox("[DX UI Creator] Akıllı kılavuz: "..(editor.smartSnapEnabled and "AÇIK" or "KAPALI"), 75,144,255,true)
    elseif button == "p" then
        editor.previewMode = not editor.previewMode
        editor.panelDirty = true
    elseif button == "escape" then toggleEditor()
    end
end)

addEventHandler("onClientCharacter", root, function(character)
    if not editor.open then return end
    if editor.exportModal then
        local modal = editor.exportModal
        local validChar = character:match("[%w%-%_%.]")
        if validChar then
            local before = modal.cursor > 0 and utfSub(modal.path, 1, modal.cursor) or ""
            local after = utfSub(modal.path, modal.cursor + 1, utfLen(modal.path))
            modal.path = before .. character .. after
            modal.cursor = modal.cursor + 1
            editor.cursorBlink = getTickCount()
        end
        return
    end
    if not editor.activeInput then return end
    local input = editor.activeInput
    if input.kind == "number" then
        if not tostring(character):match("[%d%-%.]") then return end
    elseif input.kind == "color" then
        if not tostring(character):match("[%d,%s#a-fA-F]") then return end
    end
    if input.fresh then
        input.value = ""
        input.fresh = false
        inputSetCursor(input, 0)
        inputClearSelection(input)
    end
    inputInsertText(input, character)
end)
bindKey("F7", "down", toggleEditor)
addCommandHandler("dxui",       toggleEditor)
addCommandHandler("dxuicreator",toggleEditor)

addEventHandler("onClientPaste", root, function(text)
    if not editor.open or not editor.activeInput then return end
    local input = editor.activeInput
    if input.fresh then
        input.value = ""
        input.fresh = false
        inputSetCursor(input, 0)
        inputClearSelection(input)
    end
    if input.kind == "number" then
        text = text:gsub("[^%d%-%.]", "")
    elseif input.kind == "color" then
        text = text:gsub("[^%d,#a-fA-F ]", "")
    end
    if text ~= "" then
        inputInsertText(input, text)
    end
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
    loadCustomFonts()
    ensureStylePresets()
    loadPrefabsFromFile()
    local loaded, total = 0, 0
    for _, fd in ipairs(CUSTOM_FONT_DEFS) do
        total = total + 1
        if customFonts[fd.key .. "_14"] then loaded = loaded + 1 end
    end
    outputChatBox("[DX UI Creator] Fontlar: " .. loaded .. "/" .. total .. " yuklendi.", 115, 191, 136, true)
    refreshUiFonts()
    cacheThemeColors()
    updateAssetLibrary()
    generateExportCode()
    local _lastAutoSaveHash = ""
    setTimer(function()
        if #editor.elements > 0 then
            local hash = buildProjectStateHash()
            if hash ~= _lastAutoSaveHash then
                _lastAutoSaveHash = hash
                saveToFile()
                outputChatBox("[DX UI Creator] Otomatik kaydedildi.", 115,191,136,true)
            end
        end
    end, 90000, 0)
    outputChatBox("[DX UI Creator] F7 ile aç. Ctrl+Z geri al, G snap, Scroll zoom, Ctrl+S kaydet.", 75,144,255,true)
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    if #editor.elements > 0 then saveToFile() end
    savePrefabsToFile()
    destroyRoundedCache()
    if _panelRT and isElement(_panelRT) then destroyElement(_panelRT) end
    _panelRT = nil
    if _gridRT and isElement(_gridRT) then destroyElement(_gridRT) end
    _gridRT = nil
    for _, font in pairs(customFonts) do
        if isElement(font) then destroyElement(font) end
    end
    customFonts = {}
    for _, tex in pairs(imageCache) do
        if isElement(tex) then destroyElement(tex) end
    end
    imageCache = {}
    if _previewCachedRT and isElement(_previewCachedRT) then destroyElement(_previewCachedRT) end
    _previewCachedRT = nil
    for _, svgs in pairs(_uiRoundedCache) do
        for _, svg in pairs(svgs) do
            if isElement(svg) then destroyElement(svg) end
        end
    end
    _uiRoundedCache = {}
    for _, svg in pairs(_iconCache) do
        if isElement(svg) then destroyElement(svg) end
    end
    _iconCache = {}
end)

addEventHandler("onClientRender", root, renderEditor, false, "low-9999")

addEventHandler("onClientRestore", root, function()
    if not editor.open then return end
    if _panelRT and isElement(_panelRT) then destroyElement(_panelRT) end
    if _previewCachedRT and isElement(_previewCachedRT) then destroyElement(_previewCachedRT) end
    if _gridRT and isElement(_gridRT) then destroyElement(_gridRT) end
    _panelRT = nil
    _previewCachedRT = nil
    _gridRT = nil
    editor.panelDirty = true
end)
