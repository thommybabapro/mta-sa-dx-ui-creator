local editor = {
    open = false,
    nextId = 1,
    selectedId = nil,
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
    canvas = {
        width = 1280,
        height = 720,
        grid = 40
    },
    tooltip = nil,
    tooltipTime = 0,
    theme = {
        overlay      = {8,  10, 14,  230},
        panel        = {18, 18, 24,  250},
        panelSoft    = {28, 28, 36,  250},
        panelAlt     = {38, 38, 48,  250},
        panelBorder  = {50, 50, 62,  120},
        text         = {240,240,248, 255},
        muted        = {130,135,155, 255},
        accent       = {88, 140,255, 255},
        accentHover  = {110,162,255, 255},
        accentSoft   = {60, 110,220, 180},
        success      = {72, 199,130, 255},
        successHover = {92, 219,150, 255},
        warning      = {240,180,60,  255},
        danger       = {235,85, 85,  255},
        dangerHover  = {255,110,110, 255},
        canvasBg     = {24, 24, 28,  255},
        canvasCheck1 = {28, 28, 33,  255},
        canvasCheck2 = {22, 22, 26,  255},
        canvasGrid   = {255,255,255, 22 },
        selection    = {88, 180,255, 255},
        selectionFill= {88, 180,255, 30 }
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

local CANVAS_PRESETS = {
    {label="1280x720",  w=1280, h=720 },
    {label="1920x1080", w=1920, h=1080},
    {label="1366x768",  w=1366, h=768 },
    {label="800x600",   w=800,  h=600 },
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
local _cachedPropertyLists = {}
local _previewCachedRT = nil
local _previewCachedW  = 0
local _previewCachedH  = 0

local function clamp(value, minV, maxV)
    if value < minV then return minV end
    if value > maxV then return maxV end
    return value
end

local function round(value)
    return math.floor(value + 0.5)
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

local function dxDrawUiRounded(cacheKey, x, y, w, h, radius, color, postGUI)
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
        {kind="group", label="Konum ve Boyut"},
        {key="x",      label="X",       kind="number"},
        {key="y",      label="Y",       kind="number"},
        {key="w",      label="Genişlik",kind="number"},
        {key="h",      label="Yükseklik",kind="number"},
        {kind="group", label="Durum"},
        {key="locked", label="Kilitli", kind="boolean"},
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
    circle = {
        {kind="group", label="Görünüm"},
        {key="color",       label="Renk",         kind="color"},
        {key="borderColor", label="Çerçeve Renk", kind="color"},
        {key="borderWidth", label="Çerçeve Kaln.", kind="number"},
    },
}

local function rgba(color)
    return tocolor(color[1], color[2], color[3], color[4] or 255)
end

local function snapToGrid(value, gridSize)
    if not editor.snapEnabled or not gridSize or gridSize <= 0 then return value end
    return round(value / gridSize) * gridSize
end

local function insideRect(x, y, rx, ry, rw, rh)
    return x >= rx and x <= rx + rw and y >= ry and y <= ry + rh
end

local function escapeLuaString(value)
    value = tostring(value or "")
    value = value:gsub("\\","\\\\"):gsub("\r",""):gsub("\n","\\n"):gsub("\"","\\\"")
    return value
end

local function trim(value)
    local str = tostring(value or ""):gsub("^%s+",""):gsub("%s+$","")
    return str
end

local function deleteLastCharacter(value)
    if utf8 and utf8.len then
        local length = utf8.len(value)
        if not length or length <= 0 then return "" end
        return utf8.sub(value, 1, length - 1)
    end
    return string.sub(value, 1, math.max(#value - 1, 0))
end

local function utfLen(s)
    if utf8 and utf8.len then
        local l = utf8.len(s)
        return l or #s
    end
    return #s
end

local function utfSub(s, i, j)
    if utf8 and utf8.sub then return utf8.sub(s, i, j) end
    return string.sub(s, i, j)
end

local function inputGetCursor(input)
    return input.cursor or utfLen(input.value)
end

local function inputGetSelStart(input)
    return input.selStart
end

local function inputGetSelEnd(input)
    return input.selEnd
end

local function inputHasSelection(input)
    return input.selStart and input.selEnd and input.selStart ~= input.selEnd
end

local function inputGetSelectedRange(input)
    if not inputHasSelection(input) then return nil, nil end
    local a, b = input.selStart, input.selEnd
    if a > b then a, b = b, a end
    return a, b
end

local function inputDeleteSelection(input)
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

local function inputSetCursor(input, pos)
    local len = utfLen(input.value)
    input.cursor = clamp(pos, 0, len)
    editor.cursorBlink = getTickCount()
end

local function inputClearSelection(input)
    input.selStart = nil
    input.selEnd = nil
end

local function inputSelectAll(input)
    input.selStart = 0
    input.selEnd = utfLen(input.value)
    input.cursor = input.selEnd
    editor.cursorBlink = getTickCount()
end

local function inputMoveCursor(input, delta, keepSelection)
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

local function inputHome(input, keepSelection)
    local oldCursor = inputGetCursor(input)
    if keepSelection then
        if not input.selStart then input.selStart = oldCursor end
        input.selEnd = 0
    else
        inputClearSelection(input)
    end
    inputSetCursor(input, 0)
end

local function inputEnd(input, keepSelection)
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

local function inputInsertText(input, text)
    inputDeleteSelection(input)
    local cursor = inputGetCursor(input)
    local before = cursor > 0 and utfSub(input.value, 1, cursor) or ""
    local after = utfSub(input.value, cursor + 1, utfLen(input.value))
    input.value = before .. text .. after
    inputSetCursor(input, cursor + utfLen(text))
end

local function inputBackspace(input)
    if inputDeleteSelection(input) then return end
    local cursor = inputGetCursor(input)
    if cursor <= 0 then return end
    local before = cursor > 1 and utfSub(input.value, 1, cursor - 1) or ""
    local after = utfSub(input.value, cursor + 1, utfLen(input.value))
    input.value = before .. after
    inputSetCursor(input, cursor - 1)
end

local function inputDelete(input)
    if inputDeleteSelection(input) then return end
    local cursor = inputGetCursor(input)
    local len = utfLen(input.value)
    if cursor >= len then return end
    local before = cursor > 0 and utfSub(input.value, 1, cursor) or ""
    local after = utfSub(input.value, cursor + 2, len)
    input.value = before .. after
end

local function inputCopySelection(input)
    if not inputHasSelection(input) then return "" end
    local a, b = inputGetSelectedRange(input)
    return utfSub(input.value, a + 1, b)
end

local _frameCursorX, _frameCursorY = nil, nil
local _frameScreenW, _frameScreenH = 0, 0

local function refreshFrameCache()
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

local function getScreenCursor()
    return _frameCursorX, _frameCursorY
end

local function hasVisibleColor(color)
    return type(color) == "table" and (color[4] or 255) > 0
end

local function normalizeBoolean(value)
    local v = trim(value):lower()
    if v=="true" or v=="1" or v=="yes" or v=="on"  then return true  end
    if v=="false"or v=="0" or v=="no"  or v=="off" then return false end
    return nil
end

local function normalizeEnumValue(value, options)
    local v = trim(value):lower()
    for _, opt in ipairs(options or {}) do
        if v == tostring(opt):lower() then return opt end
    end
    return nil
end

local function formatBoolean(value)
    return value and "true" or "false"
end

local function colorToString(color)
    return string.format("%d, %d, %d, %d", color[1], color[2], color[3], color[4] or 255)
end

local function parseColorString(value)
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

local function destroyElementSvgCache(id)
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

local function destroyRoundedCache()
    for id in pairs(roundedCache) do destroyElementSvgCache(id) end
    for id in pairs(circleCache)  do destroyElementSvgCache(id) end
    roundedCache = {}
    circleCache  = {}
end

local function dxDrawRoundedRectangle(id, x, y, w, h, radius, color, postGUI)
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

local function dxDrawEllipse(id, x, y, w, h, color, postGUI)
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

local _fetchingUrls = {}
local _remoteTempCounter = 0

local function getOrLoadTexture(path)
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

local function drawStyledText(text, left, top, right, bottom, options)
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

local function markDirty() editor.exportDirty = true; editor.panelDirty = true end

local function saveUndoState()
    undoStack[#undoStack+1] = {
        elements   = deepCopyElements(editor.elements),
        selectedId = editor.selectedId,
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
    editor.nextId     = state.nextId
    editor.activeInput  = nil
    editor.interaction  = nil
    editor.colorPicker  = nil
    markDirty()
end

local function undo()
    if #undoStack == 0 then outputChatBox("[DX UI Creator] Geri alınacak işlem yok.", 230,164,52,true); return end
    redoStack[#redoStack+1] = {elements=deepCopyElements(editor.elements), selectedId=editor.selectedId, nextId=editor.nextId}
    local state = undoStack[#undoStack]; table.remove(undoStack, #undoStack)
    applyState(state)
    outputChatBox("[DX UI Creator] Geri alındı. ("..#undoStack.." adım kaldı)", 75,144,255,true)
end

local function redo()
    if #redoStack == 0 then outputChatBox("[DX UI Creator] İleri alınacak işlem yok.", 230,164,52,true); return end
    undoStack[#undoStack+1] = {elements=deepCopyElements(editor.elements), selectedId=editor.selectedId, nextId=editor.nextId}
    local state = redoStack[#redoStack]; table.remove(redoStack, #redoStack)
    applyState(state)
    outputChatBox("[DX UI Creator] İleri alındı.", 75,144,255,true)
end

local function getLayout()
    local screenW, screenH = _frameScreenW, _frameScreenH
    if screenW == 0 then screenW, screenH = guiGetScreenSize() end
    local padding    = 18
    local leftWidth  = math.max(260, math.floor(screenW * 0.19))
    local rightWidth = math.max(360, math.floor(screenW * 0.27))
    local middleW    = screenW - leftWidth - rightWidth - padding * 4
    local middleH    = screenH - padding * 2
    local baseScale  = math.min(middleW / editor.canvas.width, middleH / editor.canvas.height)
    baseScale        = math.max(0.1, baseScale)

    local scale      = math.max(0.1, baseScale * editor.canvasZoom)
    local canvasW    = editor.canvas.width  * scale
    local canvasH    = editor.canvas.height * scale
    local canvasX    = padding*2 + leftWidth  + math.max(0, (middleW - canvasW) / 2) + (editor.canvasPanX or 0)
    local canvasY    = padding               + math.max(0, (middleH - canvasH) / 2) + (editor.canvasPanY or 0)

    return {
        screenW = screenW, screenH = screenH,
        left   = {x=padding,                         y=padding, w=leftWidth,  h=screenH-padding*2},
        right  = {x=screenW-rightWidth-padding,      y=padding, w=rightWidth, h=screenH-padding*2},
        canvas = {x=canvasX, y=canvasY, w=canvasW, h=canvasH, scale=scale},
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
    if editor.activeInput and editor.activeInput.elementId ~= id then editor.activeInput = nil end
    editor.colorPicker = nil
end

local function createDefaultElement(typeName)
    local id = string.format("%s_%d", typeName, editor.nextId)
    editor.nextId = editor.nextId + 1
    local el = {
        id=id, type=typeName,
        x=120, y=100, w=240, h=80,
        fontScale=1, font="default-bold",
        alignX="left", alignY="center",
        clip=false, wordBreak=false, colorCoded=false,
        visible=true, shadowColor={0,0,0,0}, shadowOffsetX=1, shadowOffsetY=1,
        radius=0, locked=false,
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
    local sel = getSelectedElement()
    if not sel or sel.locked then return end
    saveUndoState()
    local clone = deepCopyElement(sel)
    clone.id = string.format("%s_%d", clone.type, editor.nextId)
    editor.nextId = editor.nextId + 1
    clone.x = clamp(clone.x + 20, 0, editor.canvas.width  - clone.w)
    clone.y = clamp(clone.y + 20, 0, editor.canvas.height - clone.h)
    clone.locked = false
    table.insert(editor.elements, clone)
    setSelectedElement(clone.id)
    markDirty()
end

local function deleteSelected()
    local i = getElementIndexById(editor.selectedId)
    if not i then return end
    local el = editor.elements[i]
    if el.locked then outputChatBox("[DX UI Creator] Eleman kilitli, once kilidi kaldir.", 230,164,52,true); return end
    saveUndoState()
    destroyElementSvgCache(el.id)
    table.remove(editor.elements, i)
    setSelectedElement(nil)
    markDirty()
end

local function clearCanvas()
    saveUndoState()
    editor.elements = {}
    editor.selectedId = nil
    editor.activeInput = nil
    editor.interaction = nil
    editor.colorPicker = nil
    destroyRoundedCache()
    markDirty()
end

local _lastArrowUndoTime = 0
local function moveSelectedBy(ox, oy)
    local el = getSelectedElement()
    if not el or el.locked then return end
    local now = getTickCount()
    if now - _lastArrowUndoTime > 500 then
        saveUndoState()
        _lastArrowUndoTime = now
    end
    el.x = clamp(el.x + ox, 0, editor.canvas.width  - el.w)
    el.y = clamp(el.y + oy, 0, editor.canvas.height - el.h)
    markDirty()
end

local function alignSelected(mode)
    local el = getSelectedElement()
    if not el or el.locked then return end
    saveUndoState()
    local cw, ch = editor.canvas.width, editor.canvas.height
    if     mode == "left"    then el.x = 0
    elseif mode == "centerX" then el.x = round((cw - el.w) / 2)
    elseif mode == "right"   then el.x = cw - el.w
    elseif mode == "top"     then el.y = 0
    elseif mode == "centerY" then el.y = round((ch - el.h) / 2)
    elseif mode == "bottom"  then el.y = ch - el.h
    end
    markDirty()
end

local function addHotbox(kind, x, y, w, h, data)
    editor.hotboxes[#editor.hotboxes+1] = {kind=kind, x=x, y=y, w=w, h=h, data=data}
end

local function drawOutline(x, y, w, h, color, thickness)
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
}

local function drawTooltip()
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

    saveUndoState()
    el[input.key] = finalValue

    if     input.key == "w"            then el.w            = clamp(el.w, 20, editor.canvas.width  - el.x)
    elseif input.key == "h"            then el.h            = clamp(el.h, 20, editor.canvas.height - el.y)
    elseif input.key == "x"            then el.x            = clamp(el.x, 0,  editor.canvas.width  - el.w)
    elseif input.key == "y"            then el.y            = clamp(el.y, 0,  editor.canvas.height - el.h)
    elseif input.key == "radius"       then el.radius       = clamp(el.radius, 0, math.floor(math.min(el.w, el.h)/2))
    elseif input.key == "headerHeight" then el.headerHeight = clamp(el.headerHeight, 24, math.max(24, el.h))
    elseif input.key == "titlePaddingX"then el.titlePaddingX= clamp(el.titlePaddingX, 0, math.floor(el.w/2))
    elseif input.key == "borderWidth"  then el.borderWidth  = clamp(el.borderWidth, 0, 100)
    end

    editor.activeInput = nil
    markDirty()
    return true
end

local function cancelActiveInput() editor.activeInput = nil; editor.panelDirty = true end

local COLOR_PICKER_W = 220
local COLOR_PICKER_H = 196

local function commitColorPicker()
    if not editor.colorPicker then return end
    local cp = editor.colorPicker
    local el = getSelectedElement()
    if not el or el.id ~= cp.elementId then editor.colorPicker = nil; return end
    saveUndoState()
    el[cp.key] = {cp.r, cp.g, cp.b, cp.a}
    markDirty()
end

local function drawColorPicker(screenW, screenH)
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
end

local SAVE_FILE   = "dxui_save.xml"
local EXPORT_FILE = "dxui_export.lua"
local COLOR_KEYS = {color=true, headerColor=true, bodyColor=true, textColor=true, shadowColor=true, hoverColor=true, borderColor=true}

local function saveToFile()
    local xml = xmlCreateFile(SAVE_FILE, "dxui")
    if not xml then outputChatBox("[DX UI Creator] Kayıt dosyası oluşturulamadı.", 214,76,76,true); return end
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
    local xml = xmlLoadFile(SAVE_FILE)
    if not xml then outputChatBox("[DX UI Creator] Kayıt dosyası bulunamadı: "..SAVE_FILE, 214,76,76,true); return end
    saveUndoState()
    destroyRoundedCache()
    editor.elements = {}; editor.selectedId=nil; editor.activeInput=nil; editor.interaction=nil; editor.colorPicker=nil
    editor.nextId = tonumber(xmlNodeGetAttribute(xml,"nextId")) or editor.nextId
    editor.canvas.width  = tonumber(xmlNodeGetAttribute(xml,"canvasW")) or editor.canvas.width
    editor.canvas.height = tonumber(xmlNodeGetAttribute(xml,"canvasH")) or editor.canvas.height
    for _, node in ipairs(xmlNodeGetChildren(xml) or {}) do
        if xmlNodeGetName(node) == "element" then
            local el = {}
            for key, value in pairs(xmlNodeGetAttributes(node)) do
                local cp = parseColorString(value)
                if cp and COLOR_KEYS[key] then el[key] = cp
                elseif value == "true"  then el[key] = true
                elseif value == "false" then el[key] = false
                elseif tonumber(value) and key~="id" and key~="type" and key~="title" and key~="text" and key~="font" and key~="alignX" and key~="alignY" and key~="imagePath" then
                    el[key] = tonumber(value)
                else el[key] = value end
            end
            if el.id and el.type then table.insert(editor.elements, el) end
        end
    end
    xmlUnloadFile(xml)
    markDirty()
    outputChatBox("[DX UI Creator] Yüklendi: "..SAVE_FILE.." ("..#editor.elements.." eleman)", 115,191,136,true)
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
    for _, key in ipairs(order) do
        if el[key] ~= nil then
            parts[#parts+1] = string.format("%s = %s", key, serializeLuaValue(el[key]))
        end
    end
    return "    { "..table.concat(parts, ", ").." },"
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
    ln("local uiElements = {")
    if #editor.elements == 0 then ln("    -- Henuz eleman yok.")
    else for _, el in ipairs(editor.elements) do ln(createElementCode(el)) end end
    ln("}")
    ln("")
    ln("local function rgba(c) return tocolor(c[1],c[2],c[3],c[4] or 255) end")
    ln("local function hasColor(c) return type(c)==\"table\" and (c[4] or 255)>0 end")
    ln("")
    ln("local function isCursorOnRect(x,y,w,h)")
    ln("    if not isCursorShowing() then return false end")
    ln("    local cx,cy=getCursorPosition(); if not cx then return false end")
    ln("    cx,cy=cx*sx,cy*sy")
    ln("    return cx>=x and cx<=x+w and cy>=y and cy<=y+h")
    ln("end")
    ln("")
    ln("local function _res() sx,sy=guiGetScreenSize(); scaleX,scaleY=sx/_cw,sy/_ch; _scale=math.min(scaleX,scaleY); _offX=(sx-_cw*_scale)/2; _offY=(sy-_ch*_scale)/2 end")
    ln("addEventHandler(\"onClientResourceStart\",resourceRoot,_res)")
    ln("")
    ln("local function dxDrawRounded(id,x,y,w,h,radius,color,postGUI)")
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
    ln("local _builtinFonts={[\"default\"]=true,[\"default-bold\"]=true,[\"arial\"]=true,[\"bankgothic\"]=true,[\"clear\"]=true,[\"danielbd\"]=true,[\"pricedown\"]=true,[\"sans\"]=true,[\"unifont\"]=true}")
    ln("local function resolveFont(name) if not name or not _builtinFonts[name] then return \"default-bold\" end; return name end")
    ln("")
    ln("local function drawStyledText(text,left,top,right,bottom,opts)")
    ln("    local scale=(opts.fontScale or 1)")
    ln("    local font=resolveFont(opts.font)")
    ln("    if hasColor(opts.shadowColor) then")
    ln("        local sx2=(opts.shadowOffsetX or 1)*scaleX; local sy2=(opts.shadowOffsetY or 1)*scaleY")
    ln("        dxDrawText(text,left+sx2,top+sy2,right+sx2,bottom+sy2,rgba(opts.shadowColor),scale,font,opts.alignX or 'left',opts.alignY or 'center',opts.clip,opts.wordBreak,false,opts.colorCoded)")
    ln("    end")
    ln("    dxDrawText(text,left,top,right,bottom,rgba(opts.textColor or {255,255,255,255}),scale,font,opts.alignX or 'left',opts.alignY or 'center',opts.clip,opts.wordBreak,false,opts.colorCoded)")
    ln("end")
    ln("")
    ln("local function drawUiElement(el)")
    ln("    local x,y,w,h=el.x*_scale+_offX, el.y*_scale+_offY, el.w*_scale, el.h*_scale")
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
    ln("            if not el._tex or not isElement(el._tex) then el._tex=dxCreateTexture(el.imagePath,'argb',true,'clamp') end")
    ln("            if el._tex then")
    ln("                dxDrawImage(x,y,w,h,el._tex,0,0,0,rgba(el.color or {255,255,255,255}))")
    ln("            else")
    ln("                dxDrawRounded(el.id,x,y,w,h,r,rgba(el.color or {255,255,255,255}))")
    ln("            end")
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
    ln("local function renderCreatedUi()")
    ln("    for _,el in ipairs(uiElements) do if el.visible~=false then drawUiElement(el) end end")
    ln("end")
    ln("")
    ln("addEventHandler(\"onClientRender\", root, renderCreatedUi)")

    editor.exportCache  = table.concat(L, "\n")
    editor.exportDirty  = false
end

local function ensureExport()
    if editor.exportDirty then generateExportCode() end
end

local function getUsedCustomFonts()
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

local function getUsedRemoteImages()
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

local function getUsedHttpImages()
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

local function generateExportServerCode()
    local L = {}
    local function ln(s) L[#L+1] = s end
    ln("addEvent(\"expui:requestImage\", true)")
    ln("addEventHandler(\"expui:requestImage\", root, function(url)")
    ln("    local player = client")
    ln("    if not player or not isElement(player) then return end")
    ln("    fetchRemote(url, function(data, errno)")
    ln("        if type(errno)==\"table\" then errno=errno.statusCode or -1 end")
    ln("        if errno==0 and data and #data>0 then")
    ln("            local ext=\"png\"")
    ln("            local h=data:sub(1,8)")
    ln("            if h:sub(1,3)==\"\\255\\216\\255\" then ext=\"jpg\"")
    ln("            elseif h:sub(1,2)==\"BM\" then ext=\"bmp\" end")
    ln("            triggerLatentClientEvent(player,\"expui:receiveRemoteImage\",1000000,false,player,url,data,ext)")
    ln("        else")
    ln("            triggerClientEvent(player,\"expui:receiveRemoteImage\",player,url,false,nil)")
    ln("        end")
    ln("    end)")
    ln("end)")
    return table.concat(L, "\n")
end

local function generateFullExportCode()
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
        ln("addEvent(\"expui:receiveRemoteImage\", true)")
        ln("addEventHandler(\"expui:receiveRemoteImage\", root, function(url, data, ext)")
        ln("    if not data then _remPending[url]=nil; return end")
        ln("    local idx = tostring(#_remTex+1)")
        ln("    local tmp = \"_ri\"..idx..\".\"..( ext or \"png\")")
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

    ln("local uiElements = {")
    if #editor.elements == 0 then ln("    -- Henuz eleman yok.")
    else for _, el in ipairs(editor.elements) do ln(createElementCode(el)) end end
    ln("}")
    ln("")
    ln("local function rgba(c) return tocolor(c[1],c[2],c[3],c[4] or 255) end")
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
    ln("local function drawStyledText(text,left,top,right,bottom,opts)")
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
    ln("local function drawUiElement(el)")
    ln("    local x,y,w,h=el.x*_scale+_offX, el.y*_scale+_offY, el.w*_scale, el.h*_scale")
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
    ln("    elseif el.type==\"circle\" then")
    ln("        if (el.borderWidth or 0)>0 and hasColor(el.borderColor) then")
    ln("            local bw=el.borderWidth*math.min(scaleX,scaleY)")
    ln("            dxDrawCircle(el.id..'_b',x-bw,y-bw,w+bw*2,h+bw*2,rgba(el.borderColor))")
    ln("        end")
    ln("        dxDrawCircle(el.id,x,y,w,h,rgba(el.color))")
    ln("    end")
    ln("end")
    ln("")
    ln("local function renderCreatedUi()")
    ln("    for _,el in ipairs(uiElements) do if el.visible~=false then drawUiElement(el) end end")
    ln("end")
    ln("")
    ln("addEventHandler(\"onClientRender\", root, renderCreatedUi)")

    return table.concat(L, "\n")
end

local function escapeXmlAttr(s)
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

    triggerLatentServerEvent("dxui:exportFiles", 2000000, localPlayer, basePath, luaCode, metaCode, fontFiles, serverCode)

    return true
end

local function exportToLuaFile()
    openExportModal()
end

local function refreshUiFonts()
    UI_FONT_BOLD       = customFonts["gilroy-bold_14"]   or "default-bold"
    UI_FONT_MEDIUM     = customFonts["gilroy-medium_14"] or "default"
    UI_FONT_LIGHT      = customFonts["gilroy-light_14"]  or "default"
    UI_FONT_BOLD_LG    = customFonts["gilroy-bold_17"]   or "default-bold"
    UI_FONT_BOLD_SM    = customFonts["gilroy-bold_12"]   or "default-bold"
    UI_FONT_BOLD_XS    = customFonts["gilroy-bold_10"]   or "default-bold"
    UI_FONT_MEDIUM_SM  = customFonts["gilroy-medium_12"] or "default"
    UI_FONT_MEDIUM_XS  = customFonts["gilroy-medium_10"] or "default"
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
        local iSz = 16
        local textW = dxGetTextWidth(label, 1, customFonts["gilroy-medium_14"])
        local totalW = iSz + 6 + textW
        local startX = x + (w - totalW) / 2
        dxDrawImage(startX, y + (h - iSz) / 2, iSz, iSz, icon, 0, 0, 0, themeColors.text)
        dxDrawText(label, startX + iSz + 6, y, x + w - 8, y + h, themeColors.text, 1, customFonts["gilroy-medium_14"], "left", "center", false, false, false)
    else
        dxDrawText(label, x, y, x + w, y + h, themeColors.text, 1, customFonts["gilroy-medium_14"], "center", "center", false, false, false)
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
    dxDrawText(label, x, y, x + w, y + h, themeColors.text, 1, UI_FONT_BOLD_XS, "center", "center", false, false, false)
end

local function drawElementPreview(layout, element)
    local cx, cy    = getScreenCursor()
    local x,y,w,h   = canvasToScreen(layout, element.x, element.y, element.w, element.h)
    local hovered    = cx and insideRect(cx, cy, x, y, w, h)
    local scaledR    = (element.radius or 0) * layout.canvas.scale
    local textOpts   = buildPreviewTextOptions(element, layout.canvas.scale)

    if element.type == "window" then
        local hh  = math.min(h, math.max(24*layout.canvas.scale, (element.headerHeight or 40)*layout.canvas.scale))
        local px2 = (element.titlePaddingX or 16) * layout.canvas.scale
        dxDrawRectangle(x, y, w, h, rgba(element.bodyColor))
        dxDrawRectangle(x, y, w, hh, rgba(element.headerColor))
        drawStyledText(element.title, x+px2, y, x+w-px2, y+hh, textOpts)
    elseif element.type == "rectangle" then
        dxDrawRoundedRectangle(element.id, x, y, w, h, scaledR, rgba(element.color))
    elseif element.type == "button" then
        local bc = hovered and element.hoverColor or element.color
        dxDrawRoundedRectangle(element.id, x, y, w, h, scaledR, rgba(bc))
        drawStyledText(element.text, x+8*layout.canvas.scale, y+4*layout.canvas.scale, x+w-8*layout.canvas.scale, y+h-4*layout.canvas.scale, textOpts)
    elseif element.type == "label" then
        drawStyledText(element.text, x, y, x+w, y+h, textOpts)
    elseif element.type == "image" then
        local tex = element.imagePath and element.imagePath~="" and getOrLoadTexture(element.imagePath) or nil
        if tex then
            dxDrawImage(x, y, w, h, tex, 0, 0, 0, rgba(element.color or {255,255,255,255}))
        else
            dxDrawRectangle(x, y, w, h, tocolor(50,50,60,200))
            drawOutline(x, y, w, h, tocolor(100,100,120,200), 1)
            dxDrawText("IMAGE\n"..(element.imagePath~="" and element.imagePath or "(yol girilmedi)"), x, y, x+w, y+h, tocolor(150,150,170,220), 1, customFonts["gilroy-medium_10"], "center", "center", false, true, false)
        end
    elseif element.type == "circle" then
        if (element.borderWidth or 0) > 0 and hasVisibleColor(element.borderColor) then
            local bw = (element.borderWidth or 0) * layout.canvas.scale
            dxDrawEllipse(element.id.."_b", x-bw, y-bw, w+bw*2, h+bw*2, rgba(element.borderColor))
        end
        dxDrawEllipse(element.id, x, y, w, h, rgba(element.color))
    end

    if editor.selectedId == element.id then
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

    for _, element in ipairs(editor.elements) do
        if element.visible ~= false then
            drawElementPreview(layout, element)
        end
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

local function drawLeftPanel(layout)
    local panel = layout.left
    if not _skipPanelDraw then
        dxDrawUiRounded("left_panel", panel.x, panel.y, panel.w, panel.h, 10, themeColors.panel)
        drawOutline(panel.x, panel.y, panel.w, panel.h, themeColors.panelBorder, 1)
        dxDrawText("DX UI Oluşturucu", panel.x+16, panel.y+14, panel.x+panel.w-16, panel.y+42, themeColors.text, 1, UI_FONT_BOLD_LG, "left", "top", false, false, false)
        dxDrawText("Oyun içi DX arayüz tasarım aracı", panel.x+16, panel.y+42, panel.x+panel.w-16, panel.y+60, themeColors.muted, 1, UI_FONT_MEDIUM_XS, "left", "top", false, false, false)
        local presetY = panel.y + 64
        dxDrawText("Canvas Boyutu:", panel.x+16, presetY, panel.x+100, presetY+18, themeColors.muted, 1, UI_FONT_BOLD_XS, "left", "center", false, false, false)
    end

    local presetY = panel.y + 64
    local pw = (panel.w - 32 - 3*4) / 4
    for i, preset in ipairs(CANVAS_PRESETS) do
        local px2 = panel.x + 16 + (i-1) * (pw+4)
        local active = editor.canvas.width == preset.w and editor.canvas.height == preset.h
        drawSmallButton(px2, presetY+20, pw, 22, preset.label, "preset_"..i, active)
    end

    local st = {normal=editor.theme.panelAlt,  hover=editor.theme.accentHover}
    local ss = {normal=editor.theme.success,   hover=editor.theme.successHover}
    local sl = {normal=editor.theme.panelAlt,  hover=editor.theme.accent}

    local startY = panel.y + 110
    local gutter = 8
    local bw     = (panel.w - 32 - gutter) / 2
    local bh     = 38

    local addButtons = {
        {"Pencere","add_window","window"}, {"Buton","add_button","button"},
        {"Yazı","add_label","label"},     {"Dikdörtgen","add_rectangle","rectangle"},
        {"Resim","add_image","image"},    {"Daire","add_circle","circle"},
    }
    for i, ab in ipairs(addButtons) do
        local col = (i-1) % 2
        local row = math.floor((i-1) / 2)
        drawButton(panel.x+16 + col*(bw+gutter), startY + row*(bh+6), bw, bh, ab[1], ab[2], st, ab[3])
    end

    local saveLoadY = startY + 3*(bh+6) + 4
    drawButton(panel.x+16,           saveLoadY,      bw, bh, "Kaydet",      "save_project",   ss, "save")
    drawButton(panel.x+16+bw+gutter, saveLoadY,      bw, bh, "Yükle",       "load_project",   sl, "load")
    drawButton(panel.x+16,           saveLoadY+bh+6, bw, bh, "Lua'ya Yaz",  "export_to_file", ss, "code")
    drawButton(panel.x+16+bw+gutter, saveLoadY+bh+6, bw, bh, "Kodu Kopyala","copy_export",    st, "copy")

    local shortY = saveLoadY + (bh+6)*2 + 10
    local shortcutCount = 10
    if not _skipPanelDraw then
        dxDrawText("Kısayollar", panel.x+16, shortY, panel.x+panel.w-16, shortY+18, themeColors.text, 1, UI_FONT_BOLD_SM, "left", "top", false, false, false)
        local shortcuts = {
            "F7 / /dxui  :  Editörü aç/kapat",
            "Del          :  Seçili elemanı sil",
            "Ctrl+Z/Y   :  Geri / ileri al",
            "Ctrl+D       :  Kopyala",
            "Ctrl+Shift+C :  Kodu Kopyala",
            "Ctrl+S       :  Kaydet",
            "Yön tuşları :  Taşı  (Shift = 10px)",
            "Alt             :  Snap geçici kapat",
            "G               :  Snap aç / kapat",
            "Scroll canvas:  Zoom",
            "Orta tuş sürükleme: Pan",
        }
        shortcutCount = #shortcuts
        local textY = shortY + 22
        for _, line in ipairs(shortcuts) do
            dxDrawText(line, panel.x+16, textY, panel.x+panel.w-16, textY+16, themeColors.muted, 1, UI_FONT_MEDIUM_XS, "left", "top", false, false, false)
            textY = textY + 17
        end
    end

    local layerStartY = shortY + 22 + shortcutCount * 17
    drawLayersPanel(panel.x+16, layerStartY+8, panel.w-32, panel.y+panel.h-(layerStartY+20))
end
local function drawPropertyRow(x, y, w, property, element)
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

    dxDrawText(property.label, x, y, x+labelW-30, y+rowH, themeColors.muted, 1, UI_FONT_BOLD_SM, "left", "center", false, false, false)
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

local function drawRightPanel(layout)
    local panel = layout.right

    if not _skipPanelDraw then
        dxDrawUiRounded("right_panel", panel.x, panel.y, panel.w, panel.h, 10, themeColors.panel)
        drawOutline(panel.x, panel.y, panel.w, panel.h, themeColors.panelBorder, 1)
        dxDrawText("Denetleyici", panel.x+16, panel.y+14, panel.x+panel.w-16, panel.y+38, themeColors.text, 1, UI_FONT_BOLD_LG, "left", "top", false, false, false)
        dxDrawText("Seçili elemanı düzenle ve dışarı aktar", panel.x+16, panel.y+40, panel.x+panel.w-16, panel.y+58, themeColors.muted, 1, UI_FONT_MEDIUM_XS, "left", "top", false, false, false)
    end

    local sp  = {normal=editor.theme.panelAlt, hover=editor.theme.accentHover}
    local dp  = {normal=editor.theme.danger,   hover=editor.theme.dangerHover}

    local gutter2 = 8
    local bw2 = (panel.w - 32 - gutter2) / 2
    local bh2 = 36
    local baseY = panel.y + 70

    drawButton(panel.x+16,              baseY,            bw2, bh2, "Öne Al",      "bring_front",       sp, "front")
    drawButton(panel.x+16+bw2+gutter2,  baseY,            bw2, bh2, "Arkaya At",   "send_back",         sp, "back")
    drawButton(panel.x+16,              baseY+bh2+6,      bw2, bh2, "Bir Yukarı",  "layer_up",          sp, "front")
    drawButton(panel.x+16+bw2+gutter2,  baseY+bh2+6,      bw2, bh2, "Bir Aşağı",   "layer_down",        sp, "back")
    drawButton(panel.x+16,              baseY+(bh2+6)*2,   bw2, bh2, "Kopyala",     "duplicate_selected",sp, "duplicate")
    drawButton(panel.x+16+bw2+gutter2,  baseY+(bh2+6)*2,   bw2, bh2, "Sil",         "delete_selected",   dp, "trash")

    local alignY = baseY + (bh2+6)*3 + 4
    if not _skipPanelDraw then
        dxDrawText("Hizalama:", panel.x+16, alignY, panel.x+panel.w-16, alignY+16, themeColors.muted, 1, UI_FONT_BOLD_XS, "left", "top", false, false, false)
    end
    local aw  = (panel.w - 32 - 5*4) / 6
    local alignBtns = {
        {"◁", "align_left"},    {"⊣", "align_centerX"},  {"▷", "align_right"},
        {"△", "align_top"},     {"⊥", "align_centerY"},  {"▽", "align_bottom"},
    }
    for i, ab in ipairs(alignBtns) do
        drawSmallButton(panel.x+16+(i-1)*(aw+4), alignY+18, aw, 22, ab[1], ab[2], false)
    end

    drawButton(panel.x+16, alignY+44, panel.w-32, bh2-6, "Tümü Temizle", "clear_canvas", dp, "clear")

    local sel         = getSelectedElement()
    local inspectorY  = alignY + 44 + bh2
    local previewH    = math.min(220, panel.h * 0.22)
    local previewY    = panel.y + panel.h - previewH - 16
    local viewportTop = inspectorY + 50
    local viewportBot = previewY - 10
    local viewportH   = math.max(60, viewportBot - viewportTop)

    if not _skipPanelDraw then
        dxDrawText("Özellikler", panel.x+16, inspectorY, panel.x+panel.w-16, inspectorY+18, themeColors.text, 1, UI_FONT_BOLD_SM, "left", "top", false, false, false)
    end

    if sel then
        if not _skipPanelDraw then
            dxDrawText(sel.id.."  ["..sel.type.."]".. (sel.locked and "  \240\159\148\146" or ""),
                panel.x+16, inspectorY+20, panel.x+panel.w-16, inspectorY+40,
                themeColors.muted, 1, UI_FONT_MEDIUM_XS, "left", "top", false, false, false)
        end

        local properties   = _cachedPropertyLists[sel.type] or buildPropertyList(sel)
        if not _cachedPropertyLists[sel.type] then _cachedPropertyLists[sel.type] = properties end
        local totalHeight = 0
        for _, p in ipairs(properties) do totalHeight = totalHeight + (p.kind == "group" and 26 or 34) end
        totalHeight = totalHeight + (editor.activeInput and 26 or 0)
        editor.inspectorScrollMax = math.max(0, totalHeight - viewportH)
        editor.inspectorScroll    = clamp(editor.inspectorScroll or 0, 0, editor.inspectorScrollMax)
        editor.inspectorArea      = {x=panel.x+16, y=viewportTop, w=panel.w-32, h=viewportH}

        local rowY = viewportTop - editor.inspectorScroll
        for _, property in ipairs(properties) do
            local rowH = property.kind == "group" and 26 or 34
            local rowBot = rowY + rowH
            if rowBot >= viewportTop and rowY <= viewportBot then
                drawPropertyRow(panel.x+16, rowY, panel.w-32, property, sel)
            end
            rowY = rowY + rowH
        end

        if not _skipPanelDraw and editor.activeInput then
            local hintY = rowY + 4
            if hintY+18 >= viewportTop and hintY <= viewportBot then
                dxDrawText("Enter: Onayla  |  Esc: İptal et", panel.x+16, hintY, panel.x+panel.w-16, hintY+18, themeColors.warning, 1, UI_FONT_BOLD_XS, "left", "top", false, false, false)
            end
        end

        if not _skipPanelDraw and editor.inspectorScrollMax > 0 then
            local barX   = panel.x + panel.w - 10
            local thumbH = math.max(20, (viewportH / totalHeight) * viewportH)
            local thumbY = viewportTop + (editor.inspectorScroll / editor.inspectorScrollMax) * (viewportH - thumbH)
            dxDrawUiRounded("iscroll_bg", barX, viewportTop, 4, viewportH, 2, themeColors.panelSoft)
            dxDrawUiRounded("iscroll_thumb", barX, round(thumbY), 4, round(thumbH), 2, themeColors.accent)
        end
    else
        editor.inspectorArea = nil; editor.inspectorScroll = 0; editor.inspectorScrollMax = 0
        if not _skipPanelDraw then
            dxDrawUiRounded("inspector_empty", panel.x+16, inspectorY+26, panel.w-32, 90, 6, themeColors.panelSoft)
            dxDrawText("Canvas üzerinden bir eleman seçin.\nYa da sol panelden yeni eleman ekleyin.", panel.x+28, inspectorY+38, panel.x+panel.w-28, inspectorY+110, themeColors.muted, 1, UI_FONT_MEDIUM_SM, "left", "top", false, true, false)
        end
    end

    editor.previewArea = {x=panel.x+16, y=previewY, w=panel.w-32, h=previewH}
    addHotbox("preview_drag", panel.x+16, previewY, panel.w-32, previewH, {})

    if not _skipPanelDraw then
        if not editor.interaction then ensureExport() end
        dxDrawText("Kod Önizlemesi", panel.x+16, previewY-22, panel.x+panel.w-16, previewY-4, themeColors.text, 1, UI_FONT_BOLD_SM, "left", "top", false, false, false)
        dxDrawUiRounded("preview_bg", panel.x+16, previewY, panel.w-32, previewH, 6, tocolor(8,11,16,220))

        local lineH = 14
        local lineCount = 1
        for _ in editor.exportCache:gmatch("\n") do lineCount = lineCount + 1 end
        local totalTextH = lineCount * lineH
        local innerH = previewH - 20
        editor.previewScrollMax = math.max(0, totalTextH - innerH)
        editor.previewScroll = clamp(editor.previewScroll or 0, 0, editor.previewScrollMax)

        local panelRTActive = _panelRT and isElement(_panelRT)
        if panelRTActive then dxSetRenderTarget() end

        local pvW = math.max(1, round(panel.w-32))
        local pvH = math.max(1, round(previewH))
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

        if panelRTActive then dxSetRenderTarget(_panelRT) end

        if _previewCachedRT then
            dxDrawImage(panel.x+16, previewY, pvW, pvH, _previewCachedRT)
        end

        if editor.previewScrollMax > 0 then
            local barX   = panel.x + panel.w - 20
            local thumbH = math.max(12, (innerH / totalTextH) * previewH)
            local thumbY = previewY + (editor.previewScroll / editor.previewScrollMax) * (previewH - thumbH)
            dxDrawRectangle(barX, previewY, 3, previewH, themeColors.panelAlt)
            dxDrawUiRounded("preview_thumb", barX, round(thumbY), 3, round(thumbH), 2, themeColors.accent)
        end
    end
end

local function findTopElementAt(cx, cy)
    for i = #editor.elements, 1, -1 do
        local el = editor.elements[i]
        if insideRect(cx, cy, el.x, el.y, el.w, el.h) then return el end
    end
    return nil
end

local function beginDrag(element, cx, cy)
    saveUndoState()
    editor.interaction = {mode="drag", elementId=element.id, offsetX=cx-element.x, offsetY=cy-element.y}
end

local function beginResize(element, handle, cx, cy)
    saveUndoState()
    editor.interaction = {
        mode="resize", elementId=element.id, handle=handle,
        startCursorX=cx, startCursorY=cy,
        startX=element.x, startY=element.y, startW=element.w, startH=element.h,
    }
end

local function updateInteraction(layout)
    if not editor.interaction then return end

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
        if useSnap then rawX = snapToGrid(rawX, editor.canvas.grid); rawY = snapToGrid(rawY, editor.canvas.grid) end
        element.x = clamp(round(rawX), 0, editor.canvas.width  - element.w)
        element.y = clamp(round(rawY), 0, editor.canvas.height - element.h)
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

    element.x=nx; element.y=ny; element.w=nw; element.h=nh
    markDirty()
end

local function detectPanelHover(layout)
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
    if insideRect(cx, cy, lp.x, lp.y, lp.w, lp.h) then return "leftpanel" end
    if insideRect(cx, cy, rp.x, rp.y, rp.w, rp.h) then return "rightpanel" end
    return ""
end

local function renderEditor()
    if not editor.open then return end
    _lastFrameTime = getTickCount()
    refreshFrameCache()
    local layout = getLayout()
    updateInteraction(layout)
    editor.hotboxes = {}

    local sw, sh = layout.screenW, layout.screenH

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
        drawLeftPanel(layout)
        drawRightPanel(layout)
        drawColorPicker(sw, sh)
        dxSetBlendMode("blend")
        dxSetRenderTarget()
        editor.panelDirty = false
    else
        _skipPanelDraw = true
        drawLeftPanel(layout)
        drawRightPanel(layout)
        drawColorPicker(sw, sh)
    end

    dxDrawRectangle(0, 0, sw, sh, themeColors.overlay)
    drawCanvas(layout)

    if _panelRT and isElement(_panelRT) then
        dxDrawImage(0, 0, sw, sh, _panelRT)
    else
        _skipPanelDraw = false
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

local function handleAction(action)
    if editor.activeInput and not commitActiveInput() then return end

    if     action == "add_window"        then addElement("window")
    elseif action == "add_button"        then addElement("button")
    elseif action == "add_label"         then addElement("label")
    elseif action == "add_rectangle"     then addElement("rectangle")
    elseif action == "add_image"         then addElement("image")
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
    elseif action:sub(1,7) == "preset_" then
        local i = tonumber(action:sub(8))
        local preset = CANVAS_PRESETS[i]
        if preset then
            saveUndoState()
            editor.canvas.width  = preset.w
            editor.canvas.height = preset.h
            for _, el in ipairs(editor.elements) do
                el.w = math.min(el.w, preset.w)
                el.h = math.min(el.h, preset.h)
                el.x = clamp(el.x, 0, math.max(0, preset.w - el.w))
                el.y = clamp(el.y, 0, math.max(0, preset.h - el.h))
            end
            markDirty()
            outputChatBox("[DX UI Creator] Canvas boyutu: "..preset.label, 75,144,255,true)
        end
    elseif action == "copy_export" then
        ensureExport()
        local copied = type(setClipboard)=="function" and setClipboard(editor.exportCache) ~= false
        if copied then outputChatBox("[DX UI Creator] Export kodu panoya kopyalandi.", 75,144,255,true)
        else outputChatBox("[DX UI Creator] Clipboard destegi yok, sag panelden al.", 230,164,52,true) end
    end
end

local function toggleEditor()
    editor.open = not editor.open
    if not editor.open then editor.interaction=nil; editor.activeInput=nil; editor.colorPicker=nil end
    showCursor(editor.open)
    showChat(not isChatVisible())
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
                    el[dd.key] = dd.options[clickIdx]
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
                setSelectedElement(hb.data.id)
                editor.interaction = {mode="layer_reorder", elementId=hb.data.id, targetSlot=0}
                return
            elseif hb.kind == "property" then
                beginPropertyInput(hb.data); return
            elseif hb.kind == "preview_drag" then
                _previewDrag = { lastY = absoluteY }
                return
            elseif hb.kind == "handle" then
                local sel = getSelectedElement()
                if sel and sel.id == hb.data.id and not sel.locked then
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
        if el then
            setSelectedElement(el.id)
            if not el.locked then beginDrag(el, cx2, cy2) end
        else
            setSelectedElement(nil)
        end
        return
    end

    setSelectedElement(nil)
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

    if (button == "mouse_wheel_up" or button == "mouse_wheel_down") and editor.zoomArea then
        local cx, cy = getScreenCursor()
        if cx and insideRect(cx, cy, editor.zoomArea.x, editor.zoomArea.y, editor.zoomArea.w, editor.zoomArea.h) then
            local delta = button == "mouse_wheel_up" and 0.1 or -0.1
            editor.canvasZoom = clamp(editor.canvasZoom + delta, 0.2, 4.0)
            cancelEvent(); return
        end
    end

    if (button == "mouse_wheel_up" or button == "mouse_wheel_down") and editor.layersArea then
        local cx, cy = getScreenCursor()
        if cx and insideRect(cx, cy, editor.layersArea.x, editor.layersArea.y, editor.layersArea.w, editor.layersArea.h) then
            editor.layersScroll = clamp((editor.layersScroll or 0) + (button=="mouse_wheel_up" and -1 or 1), 0, math.max(0,#editor.elements-1))
            editor.panelDirty = true
            cancelEvent(); return
        end
    end

    if (button == "mouse_wheel_up" or button == "mouse_wheel_down") and editor.inspectorArea then
        local cx, cy = getScreenCursor()
        if cx and insideRect(cx, cy, editor.inspectorArea.x, editor.inspectorArea.y, editor.inspectorArea.w, editor.inspectorArea.h) then
            editor.inspectorScroll = clamp((editor.inspectorScroll or 0) + (button=="mouse_wheel_up" and -36 or 36), 0, editor.inspectorScrollMax or 0)
            editor.panelDirty = true
            cancelEvent(); return
        end
    end

    if (button == "mouse_wheel_up" or button == "mouse_wheel_down") and editor.previewArea then
        local cx, cy = getScreenCursor()
        if cx and insideRect(cx, cy, editor.previewArea.x, editor.previewArea.y, editor.previewArea.w, editor.previewArea.h) then
            editor.previewScroll = clamp((editor.previewScroll or 0) + (button=="mouse_wheel_up" and -28 or 28), 0, editor.previewScrollMax or 0)
            editor.panelDirty = true
            cancelEvent(); return
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
    elseif ctrl and shift and button=="c" then handleAction("copy_export")
    elseif ctrl and button=="s" then saveToFile()
    elseif button == "g" then
        editor.snapEnabled = not editor.snapEnabled
        outputChatBox("[DX UI Creator] Snap-to-grid: "..(editor.snapEnabled and "AÇIK" or "KAPALI"), 75,144,255,true)
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
    local loaded, total = 0, 0
    for _, fd in ipairs(CUSTOM_FONT_DEFS) do
        total = total + 1
        if customFonts[fd.key .. "_14"] then loaded = loaded + 1 end
    end
    outputChatBox("[DX UI Creator] Fontlar: " .. loaded .. "/" .. total .. " yuklendi.", 115, 191, 136, true)
    refreshUiFonts()
    cacheThemeColors()
    generateExportCode()
    local _lastAutoSaveHash = ""
    setTimer(function()
        if #editor.elements > 0 then
            local hash = tostring(#editor.elements) .. "_" .. tostring(editor.nextId)
            for _, el in ipairs(editor.elements) do
                hash = hash .. el.id .. tostring(el.x) .. tostring(el.y) .. tostring(el.w) .. tostring(el.h)
            end
            if hash ~= _lastAutoSaveHash then
                _lastAutoSaveHash = hash
                saveToFile()
                outputChatBox("[DX UI Creator] Otomatik kaydedildi.", 115,191,136,true)
            end
        end
    end, 120000, 0)
    outputChatBox("[DX UI Creator] F7 ile aç. Ctrl+Z geri al, G snap, Scroll zoom, Ctrl+S kaydet.", 75,144,255,true)
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    if #editor.elements > 0 then saveToFile() end
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
