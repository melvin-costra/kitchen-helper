script_author("melvin-costra")
script_name("Kitchen helper")
script_version("09.02.2026")
script_url("https://github.com/melvin-costra/kitchen-helper.git")

------------------------------------ Libs  ------------------------------------
require "lib.moonloader"
local ev = require "samp.events"
local imgui = require 'imgui'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

------------------------------------ Vars  ------------------------------------
local CONFIG_PATH = "moonloader/config/kitchen.json"
local window = imgui.ImBool(false)
local antiflood = os.clock() * 1000
local commandStates = {}
local isCooking = false
local currentDish = ""

------------------------------------ Settings  ------------------------------------
local cfg = {
  dishes = {
    ["Готовые грибы"] = {
      enabled = false,
    },
    ["Жареная рыба"] = {
      enabled = false,
    },
    ["Жареная говядина"] = {
      enabled = false,
    },
    ["Жареное мясо оленя"] = {
      enabled = false,
    },
    ["Тушеное черепашье мясо"] = {
      enabled = false,
    },
    ["Жареное акулье мясо"] = {
      enabled = false,
    },
    ["Рагу из черепашьего мяса"] = {
      enabled = false,
    },
    ["Говядина с грибами"] = {
      enabled = false,
    },
    ["Оленина с грибами"] = {
      enabled = false,
    },
    ["Уха с мясом акулы"] = {
      enabled = false,
    },
    ["Морское блюдо"] = {
      enabled = false,
    },
    ["Уха из форели"] = {
      enabled = false,
    },
    ["Уха из щуки"] = {
      enabled = false,
    },
    ["Рыбная похлебка"] = {
      enabled = false,
    },
    ["Запечённый карп"] = {
      enabled = false,
    },
    ["Жареный кальмар"] = {
      enabled = false,
    },
    ["Рыбные тако"] = {
      enabled = false,
    },
    ["Морской пенный пудинг"] = {
      enabled = false,
    },
    ["Жареная рыба-еж"] = {
      enabled = false,
    },
  },
  settings = {
    enabled = false,
  }
}

function checkSavedCFG(savedCFG)
  if savedCFG.settings == nil and savedCFG.dishes == nil then
    return false
  end
  local count1, count2 = 0, 0
  for key in pairs(cfg.settings) do
    if savedCFG.settings[key] == nil then
      return false
    end
    count1 = count1 + 1
  end
  for key in pairs(cfg.dishes) do
    if savedCFG.dishes[key] == nil then
      return false
    end
  end
  for key in pairs(savedCFG.settings) do
    count2 = count2 + 1
  end
  return count1 == count2
end

function saveCFG()
  local save = io.open(CONFIG_PATH, "w")
  if save then
    save:write(encodeJson(cfg))
    save:close()
  end
end

------------------------------------ Main  ------------------------------------
function main()
  if not isSampfuncsLoaded() or not isSampLoaded() then return end
  while not isSampAvailable() do wait(100) end
  if not doesDirectoryExist('moonloader/config') then createDirectory("moonloader/config") end
  if not doesFileExist(CONFIG_PATH) then
    saveCFG()
  else
    local file = io.open(CONFIG_PATH, 'r')
    if file then
      local fileCFG = decodeJson(file:read('*a'))
      if checkSavedCFG(fileCFG) then
        cfg = fileCFG
      end
    end
  end

  sampRegisterChatCommand("kh", function()
    window.v = not window.v
  end)
  sampRegisterChatCommand("kc", function()
    if not cfg.settings.enabled then return end
    if isCooking then
      stopCooking()
      return
    end
    isCooking = true
    sendCommand("/kitchen cooking")
    sendChatMessage("Готовка включена. Жми {6AB1FF}R{FFFFFF} для остановки")
  end)

  while true do
    wait(0)
    imgui.Process = window.v
    cooking()
  end
end

function cooking()
  if isCooking and isKeyJustPressed(VK_R) then stopCooking() end
end

------------------------------------ Imgui  ------------------------------------
function imgui.OnDrawFrame()
  local sw, sh = getScreenResolution()
  local window_width = 280
  local window_height = 440
  local options = {
    enabled = imgui.ImBool(cfg.settings.enabled),
    cooked_mushrooms = imgui.ImBool(cfg.dishes["Готовые грибы"].enabled),
    fried_fish = imgui.ImBool(cfg.dishes["Жареная рыба"].enabled),
    fried_beef = imgui.ImBool(cfg.dishes["Жареная говядина"].enabled),
    fried_venison = imgui.ImBool(cfg.dishes["Жареное мясо оленя"].enabled),
    stewed_turtle_meat = imgui.ImBool(cfg.dishes["Тушеное черепашье мясо"].enabled),
    fried_shark_meat = imgui.ImBool(cfg.dishes["Жареное акулье мясо"].enabled),
    stewed_turtle_meat_with_mushrooms = imgui.ImBool(cfg.dishes["Рагу из черепашьего мяса"].enabled),
    beef_with_mushrooms = imgui.ImBool(cfg.dishes["Говядина с грибами"].enabled),
    venison_with_mushrooms = imgui.ImBool(cfg.dishes["Оленина с грибами"].enabled),
    shark_meat_soup = imgui.ImBool(cfg.dishes["Уха с мясом акулы"].enabled),
    seafood_dish = imgui.ImBool(cfg.dishes["Морское блюдо"].enabled),
    trout_fish_soup = imgui.ImBool(cfg.dishes["Уха из форели"].enabled),
    pike_fish_soup = imgui.ImBool(cfg.dishes["Уха из щуки"].enabled),
    fish_chowder = imgui.ImBool(cfg.dishes["Рыбная похлебка"].enabled),
    baked_carp = imgui.ImBool(cfg.dishes["Запечённый карп"].enabled),
    fried_squid = imgui.ImBool(cfg.dishes["Жареный кальмар"].enabled),
    fish_tacos = imgui.ImBool(cfg.dishes["Рыбные тако"].enabled),
    sea_foam_pudding = imgui.ImBool(cfg.dishes["Морской пенный пудинг"].enabled),
    fried_porcupinefish = imgui.ImBool(cfg.dishes["Жареная рыба-еж"].enabled),
  }

  imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
  imgui.SetNextWindowSize(imgui.ImVec2(window_width, window_height), imgui.Cond.FirstUseEver)

  imgui.Begin("Kitchen helper by melvin-costra", window, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)

  if imgui.Button(u8("Вкл/Выкл")) then toggleScriptActivation() end
  imgui.SameLine(150)
  imgui.TextColoredRGB("Статус: " .. (cfg.settings.enabled and "{00B200}Включен" or "{FF0F00}Выключен"))
  imgui.NewLine()
  imgui.TextColoredRGB("Скилл: {6AB1FF}0")
  if imgui.Checkbox(u8("Готовые грибы"), options.cooked_mushrooms) then
    cfg.dishes["Готовые грибы"].enabled = options.cooked_mushrooms.v
    saveCFG()
  end
  if imgui.Checkbox(u8("Жареная рыба"), options.fried_fish) then
    cfg.dishes["Жареная рыба"].enabled = options.fried_fish.v
    saveCFG()
  end
  if imgui.Checkbox(u8("Жареная говядина"), options.fried_beef) then
    cfg.dishes["Жареная говядина"].enabled = options.fried_beef.v
    saveCFG()
  end
  if imgui.Checkbox(u8("Жареное мясо оленя"), options.fried_venison) then
    cfg.dishes["Жареное мясо оленя"].enabled = options.fried_venison.v
    saveCFG()
  end
  if imgui.Checkbox(u8("Тушеное черепашье мясо"), options.stewed_turtle_meat) then
    cfg.dishes["Тушеное черепашье мясо"].enabled = options.stewed_turtle_meat.v
    saveCFG()
  end
  if imgui.Checkbox(u8("Жареное акулье мясо"), options.fried_shark_meat) then
    cfg.dishes["Жареное акулье мясо"].enabled = options.fried_shark_meat.v
    saveCFG()
  end
  imgui.NewLine()
  imgui.TextColoredRGB("Скилл: {6AB1FF}500")
  if imgui.Checkbox(u8("Рагу из черепашьего мяса"), options.stewed_turtle_meat_with_mushrooms) then
    cfg.dishes["Рагу из черепашьего мяса"].enabled = options.stewed_turtle_meat_with_mushrooms.v
    saveCFG()
  end
  imgui.NewLine()
  imgui.TextColoredRGB("Скилл: {6AB1FF}1000")
  if imgui.Checkbox(u8("Говядина с грибами"), options.beef_with_mushrooms) then
    cfg.dishes["Говядина с грибами"].enabled = options.beef_with_mushrooms.v
    saveCFG()
  end
  if imgui.Checkbox(u8("Оленина с грибами"), options.venison_with_mushrooms) then
    cfg.dishes["Оленина с грибами"].enabled = options.venison_with_mushrooms.v
    saveCFG()
  end
  imgui.NewLine()
  imgui.TextColoredRGB("Скилл: {6AB1FF}1500")
  if imgui.Checkbox(u8("Уха с мясом акулы"), options.shark_meat_soup) then
    cfg.dishes["Уха с мясом акулы"].enabled = options.shark_meat_soup.v
    saveCFG()
  end
  imgui.NewLine()
  imgui.TextColoredRGB("Скилл: {6AB1FF}2500")
  if imgui.Checkbox(u8("Морское блюдо"), options.seafood_dish) then
    cfg.dishes["Морское блюдо"].enabled = options.seafood_dish.v
    saveCFG()
  end
  imgui.NewLine()
  imgui.TextColoredRGB("Скилл: {6AB1FF}3000")
  if imgui.Checkbox(u8("Уха из форели"), options.trout_fish_soup) then
    cfg.dishes["Уха из форели"].enabled = options.trout_fish_soup.v
    saveCFG()
  end
  imgui.NewLine()
  imgui.TextColoredRGB("Скилл: {6AB1FF}3500")
  if imgui.Checkbox(u8("Уха из щуки"), options.pike_fish_soup) then
    cfg.dishes["Уха из щуки"].enabled = options.pike_fish_soup.v
    saveCFG()
  end
  imgui.NewLine()
  imgui.TextColoredRGB("Скилл: {6AB1FF}4000")
  if imgui.Checkbox(u8("Рыбная похлебка"), options.fish_chowder) then
    cfg.dishes["Рыбная похлебка"].enabled = options.fish_chowder.v
    saveCFG()
  end
  imgui.NewLine()
  imgui.TextColoredRGB("Скилл: {6AB1FF}5000")
  if imgui.Checkbox(u8("Запечённый карп"), options.baked_carp) then
    cfg.dishes["Запечённый карп"].enabled = options.baked_carp.v
    saveCFG()
  end
  imgui.NewLine()
  imgui.TextColoredRGB("Скилл: {6AB1FF}6500")
  if imgui.Checkbox(u8("Жареный кальмар"), options.fried_squid) then
    cfg.dishes["Жареный кальмар"].enabled = options.fried_squid.v
    saveCFG()
  end
  if imgui.Checkbox(u8("Рыбные тако"), options.fish_tacos) then
    cfg.dishes["Рыбные тако"].enabled = options.fish_tacos.v
    saveCFG()
  end
  imgui.NewLine()
  imgui.TextColoredRGB("Скилл: {6AB1FF}8000")
  if imgui.Checkbox(u8("Морской пенный пудинг"), options.sea_foam_pudding) then
    cfg.dishes["Морской пенный пудинг"].enabled = options.sea_foam_pudding.v
    saveCFG()
  end
  imgui.NewLine()
  imgui.TextColoredRGB("Скилл: {6AB1FF}10000")
  if imgui.Checkbox(u8("Жареная рыба-еж"), options.fried_porcupinefish) then
    cfg.dishes["Жареная рыба-еж"].enabled = options.fried_porcupinefish.v
    saveCFG()
  end
  imgui.NewLine()
  if imgui.Button(u8("Телеграм канал")) then os.execute('explorer "https://t.me/melvin_costra"') end
  imgui.NewLine()

  imgui.End()
end

function apply_custom_style()
  imgui.SwitchContext()
  local style = imgui.GetStyle()
  local colors = style.Colors
  local clr = imgui.Col
  local ImVec4 = imgui.ImVec4

  style.WindowRounding = 2.0
  style.ChildWindowRounding = 2.0
  style.FrameRounding = 5.0
  style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
  style.ScrollbarSize = 16.0
  style.ScrollbarRounding = 0
  style.GrabMinSize = 8.0
  style.GrabRounding = 1.0

  colors[clr.FrameBg]                = ImVec4(0.16, 0.29, 0.48, 0.54)
  colors[clr.FrameBgHovered]         = ImVec4(0.26, 0.59, 0.98, 0.40)
  colors[clr.FrameBgActive]          = ImVec4(0.26, 0.59, 0.98, 0.67)
  colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
  colors[clr.TitleBgActive]          = ImVec4(0.16, 0.29, 0.48, 1.00)
  colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
  colors[clr.CheckMark]              = ImVec4(0.26, 0.59, 0.98, 1.00)
  colors[clr.SliderGrab]             = ImVec4(0.24, 0.52, 0.88, 1.00)
  colors[clr.SliderGrabActive]       = ImVec4(0.26, 0.59, 0.98, 1.00)
  colors[clr.Button]                 = ImVec4(0.26, 0.59, 0.98, 0.40)
  colors[clr.ButtonHovered]          = ImVec4(0.26, 0.59, 0.98, 1.00)
  colors[clr.ButtonActive]           = ImVec4(0.06, 0.53, 0.98, 1.00)
  colors[clr.Header]                 = ImVec4(0.26, 0.59, 0.98, 0.31)
  colors[clr.HeaderHovered]          = ImVec4(0.26, 0.59, 0.98, 0.80)
  colors[clr.HeaderActive]           = ImVec4(0.26, 0.59, 0.98, 1.00)
  colors[clr.Separator]              = colors[clr.Border]
  colors[clr.SeparatorHovered]       = ImVec4(0.26, 0.59, 0.98, 0.78)
  colors[clr.SeparatorActive]        = ImVec4(0.26, 0.59, 0.98, 1.00)
  colors[clr.ResizeGrip]             = ImVec4(0.26, 0.59, 0.98, 0.25)
  colors[clr.ResizeGripHovered]      = ImVec4(0.26, 0.59, 0.98, 0.67)
  colors[clr.ResizeGripActive]       = ImVec4(0.26, 0.59, 0.98, 0.95)
  colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.35)
  colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
  colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
  colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
  colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
  colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
  colors[clr.ComboBg]                = colors[clr.PopupBg]
  colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
  colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
  colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
  colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
  colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
  colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
  colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
  colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
  colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
  colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
  colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
  colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
  colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
  colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
  colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end
apply_custom_style()

function imgui.TextColoredRGB(text)
  local style = imgui.GetStyle()
  local colors = style.Colors
  local ImVec4 = imgui.ImVec4

  local explode_argb = function(argb)
    local a = bit.band(bit.rshift(argb, 24), 0xFF)
    local r = bit.band(bit.rshift(argb, 16), 0xFF)
    local g = bit.band(bit.rshift(argb, 8), 0xFF)
    local b = bit.band(argb, 0xFF)
    return a, r, g, b
  end

  local getcolor = function(color)
    if color:sub(1, 6):upper() == 'SSSSSS' then
      local r, g, b = colors[1].x, colors[1].y, colors[1].z
      local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
      return ImVec4(r, g, b, a / 255)
    end
    local color = type(color) == 'string' and tonumber(color, 16) or color
    if type(color) ~= 'number' then return end
    local r, g, b, a = explode_argb(color)
    return imgui.ImColor(r, g, b, a):GetVec4()
  end

  local render_text = function(text_)
    for w in text_:gmatch('[^\r\n]+') do
      local text, colors_, m = {}, {}, 1
      w = w:gsub('{(......)}', '{%1FF}')
      while w:find('{........}') do
        local n, k = w:find('{........}')
        local color = getcolor(w:sub(n + 1, k - 1))
        if color then
          text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
          colors_[#colors_ + 1] = color
          m = n
        end
        w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
      end
      if text[0] then
        for i = 0, #text do
          imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
          imgui.SameLine(nil, 0)
        end
        imgui.NewLine()
      else imgui.Text(u8(w)) end
    end
  end

  render_text(text)
end

------------------------------------ Utils  ------------------------------------
function toggleScriptActivation()
  cfg.settings.enabled = not cfg.settings.enabled
  commandStates = {}
  if isCooking then stopCooking() end
  saveCFG()
end

function stopCooking()
  isCooking = false
  commandStates["/kitchen cooking"] = nil
  sendChatMessage("Готовка остановлена")
end

function sendCommand(cmd)
  if commandStates[cmd] then
    return
  end
  commandStates[cmd] = true
  lua_thread.create(function()
    repeat
      wait(0)
      if os.clock() * 1000 - antiflood > 500 then
        sampSendChat(cmd)
        antiflood = os.clock() * 1000
      end
    until not commandStates[cmd]
  end)
end

function escape_string(str)
  return str:gsub(".", function(c)
    local b = string.byte(c)
    if c == "\\" then
      return "\\\\"
    elseif c == "\n" then
      return "\\n"
    elseif c == "\t" then
      return "\\t"
    elseif c == "\r" then
      return "\\r"
    else
      return c
    end
  end)
end

function sendChatMessage(text)
  sampAddChatMessage("{0088CC}[KH]: {FFFFFF}" .. text, -1)
end

------------------------------------ Events  ------------------------------------
function ev.onServerMessage(c, text)
	if cfg.settings.enabled and isCooking then
    if text == " (( Введите: /kitchen cooking ещё раз или нажмите l.alt ))"
    or text:find(" Вы приготовили {FFFFFF}'.+'{6AB1FF}: %d+") then
      sendCommand("/kitchen cooking")
    elseif text == " Вы должны быть рядом с плитой"
    or text == " Вы не умеете это готовить. Продолжайте готовить другие блюда"
    then
      stopCooking()
    end

    if text == " У вас нет нужных ингредиентов" then
      cfg.dishes[currentDish].enabled = false
      saveCFG()
      sendChatMessage("Готовка {6AB1FF}'" .. currentDish .. "'{FFFFFF} отключена. Нету нужных ингредиентов")
      sendCommand("/kitchen cooking")
      return false
    end
  end
end

function ev.onSendChat(text)
	antiflood = os.clock() * 1000
end

function ev.onSendCommand(cmd)
	antiflood = os.clock() * 1000
end

function ev.onShowDialog(id, style, title, btn1, btn2, text)
  if cfg.settings.enabled and isCooking then
    if style == 0 and title == "Кухня" then
      commandStates["/kitchen cooking"] = nil
      sampSendDialogResponse(id, 1, 0, "")
      return false
    end
    if style == 5 and title == "Кухня" then
      commandStates["/kitchen cooking"] = nil
      local lines = text:gsub("^[^\n]*\n", "")
      local i = 0
      for line in lines:gmatch("[^\n]+") do
        local raw_text = escape_string(line)
        local name, satiety, hp, skill = raw_text:match("{FFFFFF}(.+)\\t{6AB1FF}(.+)\\t{FFFFFF}(.+)\\t{6AB1FF}(.+)")
        if name and satiety and hp and skill then
          if cfg.dishes[name].enabled then
            sampSendDialogResponse(id, 1, i, "")
            currentDish = name
            return false
          end
        end
        i = i + 1
      end
      stopCooking()
      return false
    end
  end
end

function onWindowMessage(m, p)
  if p == VK_ESCAPE and window.v then
    consumeWindowMessage()
    window.v = false
  end
end

function onScriptTerminate()
  commandStates = {}
end
