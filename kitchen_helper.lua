local version = "25.02.2026"
script_author("melvin-costra")
script_name("Kitchen helper")
script_version(version)
script_url("https://github.com/melvin-costra/kitchen-helper.git")

------------------------------------ Libs  ------------------------------------
require "lib.moonloader"
local ev = require "samp.events"
local imgui = require 'imgui'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

local rkeys = require "rkeys"
imgui.HotKey = require('imgui_addons').HotKey

------------------------------------ Vars  ------------------------------------
local CONFIG_PATH = "moonloader/config/kitchen.json"
local window = imgui.ImBool(false)
local currentPage = 1
local currentDishName = ""
local pages = { "Авто-готовка", "Авто-еда" }
local antiflood = os.clock()
local commandStates = {}
local isSendSatietyCommand = false
local isStartEating = false
local isCooking, isUpdatingData, isEating, isHealing = false, false, false, false
local dishesQueue = {}
local tLastKeys = {}
local data = {
  skill = -1,
  ingredients = {
    inventory = {
      ["Грибы"] = 0,
      ["Сырая рыба"] = 0,
      ["Жареная рыба"] = 0,
      ["Мясо дикой коровы"] = 0,
      ["Мясо оленя"] = 0,
      ["Мясо черепахи"] = 0,
      ["Мясо акулы"] = 0,
      ["Готовые грибы"] = 0,
      ["Тушеное черепашье мясо"] = 0,
      ["Жареная говядина"] = 0,
      ["Жареное мясо оленя"] = 0,
      ["Жареное акулье мясо"] = 0,
      ["Рагу из черепашьего мяса"] = 0,
      ["Говядина с грибами"] = 0,
      ["Оленина с грибами"] = 0,
      ["Уха с мясом акулы"] = 0,
      ["Морское блюдо"] = 0,
      ["Уха из форели"] = 0,
      ["Уха из щуки"] = 0,
      ["Рыбная похлебка"] = 0,
      ["Запечённый карп"] = 0,
      ["Жареный кальмар"] = 0,
      ["Рыбные тако"] = 0,
      ["Морской пенный пудинг"] = 0,
      ["Жареная рыба-еж"] = 0,
    },
    fish = {
      ["Сардина"] = 0,
      ["Радужная форель"] = 0,
      ["Щука"] = 0,
      ["Лосось"] = 0,
      ["Карп"] = 0,
      ["Кальмар"] = 0,
      ["Тунец"] = 0,
      ["Мелкая камбала"] = 0,
      ["Рыба-еж"] = 0,
    }
  },
  my_satiety = -1,
  my_hp = -1
}

------------------------------------ Settings  ------------------------------------
local cfg = {
  dishes = {
    ["Готовые грибы"] = {
      is_cooking = false,
      skill = 0,
      key = "inventory",
      ingredients = {
        ["Грибы"] = 1,
      },
      is_eating = false,
      hp = 0,
      satiety = 10,
      max_satiety = 50,
    },
    ["Жареная рыба"] = {
      is_cooking = false,
      skill = 0,
      key = "inventory",
      ingredients = {
        ["Сырая рыба"] = 20000,
      },
      is_eating = false,
      hp = 0,
      satiety = 35,
      max_satiety = 75,
    },
    ["Жареная говядина"] = {
      is_cooking = false,
      skill = 0,
      key = "inventory",
      ingredients = {
        ["Мясо дикой коровы"] = 1,
      },
      is_eating = false,
      hp = 0,
      satiety = 35,
      max_satiety = 75,
    },
    ["Жареное мясо оленя"] = {
      is_cooking = false,
      skill = 0,
      key = "inventory",
      ingredients = {
        ["Мясо оленя"] = 1,
      },
      is_eating = false,
      hp = 0,
      satiety = 35,
      max_satiety = 75,
    },
    ["Тушеное черепашье мясо"] = {
      is_cooking = false,
      skill = 0,
      key = "inventory",
      ingredients = {
        ["Мясо черепахи"] = 1,
      },
      is_eating = false,
      hp = 0,
      satiety = 35,
      max_satiety = 75,
    },
    ["Жареное акулье мясо"] = {
      is_cooking = false,
      skill = 0,
      key = "inventory",
      ingredients = {
        ["Мясо акулы"] = 1,
      },
      is_eating = false,
      hp = 0,
      satiety = 35,
      max_satiety = 75,
    },
    ["Рагу из черепашьего мяса"] = {
      is_cooking = false,
      skill = 500,
      key = "inventory",
      ingredients = {
        ["Тушеное черепашье мясо"] = 1,
      },
      is_eating = false,
      hp = 5,
      satiety = 65,
      max_satiety = 150,
    },
    ["Говядина с грибами"] = {
      is_cooking = false,
      skill = 1000,
      key = "inventory",
      ingredients = {
        ["Жареная говядина"] = 1,
        ["Готовые грибы"] = 25,
      },
      is_eating = false,
      hp = 10,
      satiety = 75,
      max_satiety = 150,
    },
    ["Оленина с грибами"] = {
      is_cooking = false,
      skill = 1000,
      key = "inventory",
      ingredients = {
        ["Жареное мясо оленя"] = 1,
        ["Готовые грибы"] = 25,
      },
      is_eating = false,
      hp = 10,
      satiety = 75,
      max_satiety = 150,
    },
    ["Уха с мясом акулы"] = {
      is_cooking = false,
      skill = 1500,
      key = "inventory",
      ingredients = {
        ["Жареное акулье мясо"] = 1,
      },
      is_eating = false,
      hp = 15,
      satiety = 85,
      max_satiety = 150,
    },
    ["Морское блюдо"] = {
      is_cooking = false,
      skill = 2500,
      key = "fish",
      ingredients = {
        ["Сардина"] = 5,
      },
      is_eating = false,
      hp = 25,
      satiety = 25,
      max_satiety = 150,
    },
    ["Уха из форели"] = {
      is_cooking = false,
      skill = 3000,
      key = "fish",
      ingredients = {
        ["Радужная форель"] = 3,
      },
      is_eating = false,
      hp = 30,
      satiety = 30,
      max_satiety = 150,
    },
    ["Уха из щуки"] = {
      is_cooking = false,
      skill = 3500,
      key = "fish",
      ingredients = {
        ["Щука"] = 3,
      },
      is_eating = false,
      hp = 35,
      satiety = 35,
      max_satiety = 150,
    },
    ["Рыбная похлебка"] = {
      is_cooking = false,
      skill = 4000,
      key = "fish",
      ingredients = {
        ["Лосось"] = 3,
      },
      is_eating = false,
      hp = 40,
      satiety = 40,
      max_satiety = 150,
    },
    ["Запечённый карп"] = {
      is_cooking = false,
      skill = 5000,
      key = "fish",
      ingredients = {
        ["Карп"] = 4,
      },
      is_eating = false,
      hp = 50,
      satiety = 50,
      max_satiety = 150,
    },
    ["Жареный кальмар"] = {
      is_cooking = false,
      skill = 6500,
      key = "fish",
      ingredients = {
        ["Кальмар"] = 2,
      },
      is_eating = false,
      hp = 65,
      satiety = 65,
      max_satiety = 150,
    },
    ["Рыбные тако"] = {
      is_cooking = false,
      skill = 6500,
      key = "fish",
      ingredients = {
        ["Тунец"] = 3,
      },
      is_eating = false,
      hp = 65,
      satiety = 65,
      max_satiety = 150,
    },
    ["Морской пенный пудинг"] = {
      is_cooking = false,
      skill = 8000,
      key = "fish",
      ingredients = {
        ["Мелкая камбала"] = 4,
      },
      is_eating = false,
      hp = 80,
      satiety = 80,
      max_satiety = 150,
    },
    ["Жареная рыба-еж"] = {
      is_cooking = false,
      skill = 10000,
      key = "fish",
      ingredients = {
        ["Рыба-еж"] = 1,
      },
      is_eating = false,
      hp = 100,
      satiety = 100,
      max_satiety = 150,
    },
  },
  settings = {
    cook_enabled = false,
    eat_enabled = false,
    act_eat_key = { v = { 18, 49 } },
    act_heal_key = { v = { 18, 51 } },
  },
  version = version
}

function checkSavedCFG(savedCFG)
  if savedCFG.version == nil or savedCFG.version ~= version then
    return false
  end
  return true
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
      else
        saveCFG()
      end
    end
  end

  sampRegisterChatCommand("kh", function()
    window.v = not window.v
    if window.v then
      isUpdatingData = true
      sendCommand("/kitchen skill")
    end
  end)
  sampRegisterChatCommand("kc", startCooking)

  bindEat = rkeys.registerHotKey(cfg.settings.act_eat_key.v, true, startEating)
  bindHeal = rkeys.registerHotKey(cfg.settings.act_heal_key.v, true, startHealing)

  lua_thread.create(trackSatiety)

  while true do
    wait(0)
    imgui.Process = window.v
    if isSendSatietyCommand then
      sendCommand("/satiety")
      isSendSatietyCommand = false
    end
    if isStartEating then
      startEating()
      isStartEating = false
    end
    if isCooking and isKeyJustPressed(VK_R) and not sampIsCursorActive() then stopCooking() end
    if isEating and isKeyJustPressed(VK_R) and not sampIsCursorActive() then
      stopEating()
      cfg.settings.eat_enabled = false
      saveCFG()
      sendChatMessage("Авто-поедание отключено")
    end
  end
end

-- Cooking
function startCooking()
  if not cfg.settings.cook_enabled then return end
  if isCooking then
    stopCooking()
    return
  end
  for _, v in pairs(cfg.dishes) do
    if v.is_cooking then
      isCooking = true
      sendCommand("/kitchen cooking")
      sendChatMessage("Готовка включена. Жми {6AB1FF}R{FFFFFF} для остановки")
      return
    end
  end
  sendChatMessage("Сначала выбери хотя бы одно блюдо в меню авто-готовки (/kh)")
end

function stopCooking()
  if isCooking then
    sendChatMessage("Готовка остановлена")
  end
  isCooking, isUpdatingData = false, false
  commandStates = {}
  dishesQueue = {}
end

function selectAvailableDishes()
  for _, v in pairs(cfg.dishes) do
    local hasAllIngredients = true
    for ing, count in pairs(v.ingredients) do
      if data.ingredients[v.key][ing] < count then 
        hasAllIngredients = false
        break
      end
    end
    if hasAllIngredients and data.skill >= v.skill then
      v.is_cooking = true
    else
      v.is_cooking = false
    end
  end
end

-- Eating & Healing
function startEating()
  if not cfg.settings.eat_enabled or isHealing or sampIsCursorActive() then return end
  if isEating then
    stopEating()
    return
  end
  for _, v in pairs(cfg.dishes) do
    if v.is_eating then
      isEating = true
      sendCommand("/satiety")
      sendChatMessage("Кушаем. Жми {6AB1FF}R{FFFFFF} для остановки")
      return
    end
  end
  sendChatMessage("Сначала выбери хотя бы одно блюдо в меню авто-еды (/kh)")
end

function stopEating()
  isEating = false
  isHealing = false
  commandStates = {}
  currentDishName = ""
end

function startHealing()
  if not cfg.settings.eat_enabled or isEating or sampIsCursorActive() then return end
  if isHealing then
    stopHealing()
    return
  end
  data.my_hp = getCharHealth(PLAYER_PED)
  if data.my_hp >= 100 then
    sendChatMessage("У тебя максимальное HP")
    stopEating()
    return
  end
  for _, v in pairs(cfg.dishes) do
    if v.is_eating and v.hp > 0 then
      isHealing = true
      sendCommand("/eat")
      sendChatMessage("Лечимся. Жми {6AB1FF}R{FFFFFF} для остановки")
      return
    end
  end
  sendChatMessage("Сначала выбери хотя бы одно блюдо в меню которое пополняет HP (/kh)")
end

function selectExistingDishes()
  for k, v in pairs(cfg.dishes) do
    if data.ingredients.inventory[k] > 0 then
      v.is_eating = true
    else
      v.is_eating = false
    end
  end
end

function trackSatiety()
  local satietyInterval = 35
  local checkInterval = 300

  local lastTime = os.clock()
  local satietyAccum = 0
  local checkAccum = 0

  while true do
    wait(0)

    local currentTime = os.clock()
    local delta = currentTime - lastTime
    lastTime = currentTime

    if cfg.settings.eat_enabled and sampIsLocalPlayerSpawned() and not isEating and not isUpdatingData then
      satietyAccum = satietyAccum + delta
      checkAccum = checkAccum + delta

      if data.my_satiety > 0 and satietyAccum >= satietyInterval then
        local toRemove = math.floor(satietyAccum / satietyInterval)
        satietyAccum = satietyAccum % satietyInterval
        data.my_satiety = math.max(0, data.my_satiety - toRemove)
      end

      if data.my_satiety == 0 then
        isStartEating = true
      end

      if checkAccum >= checkInterval then
        local times = math.floor(checkAccum / checkInterval)
        checkAccum = checkAccum % checkInterval
        if times > 0 then
          isSendSatietyCommand = true
        end
      end

      if data.my_satiety == -1 then
        satietyAccum = 0
        if checkAccum >= 30 then
          isSendSatietyCommand = true
          checkAccum = 0
        end
      end
    else
      satietyAccum = 0
      checkAccum = 0
      lastTime = os.clock()
    end
  end
end

------------------------------------ Imgui  ------------------------------------
function imgui.OnDrawFrame()
  local sw, sh = getScreenResolution()
  local window_width = 280
  local window_height = 440
  local cook_options = {
    cooked_mushrooms = imgui.ImBool(cfg.dishes["Готовые грибы"].is_cooking),
    fried_fish = imgui.ImBool(cfg.dishes["Жареная рыба"].is_cooking),
    fried_beef = imgui.ImBool(cfg.dishes["Жареная говядина"].is_cooking),
    fried_venison = imgui.ImBool(cfg.dishes["Жареное мясо оленя"].is_cooking),
    stewed_turtle_meat = imgui.ImBool(cfg.dishes["Тушеное черепашье мясо"].is_cooking),
    fried_shark_meat = imgui.ImBool(cfg.dishes["Жареное акулье мясо"].is_cooking),
    stewed_turtle_meat_with_mushrooms = imgui.ImBool(cfg.dishes["Рагу из черепашьего мяса"].is_cooking),
    beef_with_mushrooms = imgui.ImBool(cfg.dishes["Говядина с грибами"].is_cooking),
    venison_with_mushrooms = imgui.ImBool(cfg.dishes["Оленина с грибами"].is_cooking),
    shark_meat_soup = imgui.ImBool(cfg.dishes["Уха с мясом акулы"].is_cooking),
    seafood_dish = imgui.ImBool(cfg.dishes["Морское блюдо"].is_cooking),
    trout_fish_soup = imgui.ImBool(cfg.dishes["Уха из форели"].is_cooking),
    pike_fish_soup = imgui.ImBool(cfg.dishes["Уха из щуки"].is_cooking),
    fish_chowder = imgui.ImBool(cfg.dishes["Рыбная похлебка"].is_cooking),
    baked_carp = imgui.ImBool(cfg.dishes["Запечённый карп"].is_cooking),
    fried_squid = imgui.ImBool(cfg.dishes["Жареный кальмар"].is_cooking),
    fish_tacos = imgui.ImBool(cfg.dishes["Рыбные тако"].is_cooking),
    sea_foam_pudding = imgui.ImBool(cfg.dishes["Морской пенный пудинг"].is_cooking),
    fried_porcupinefish = imgui.ImBool(cfg.dishes["Жареная рыба-еж"].is_cooking),
  }
  local eat_options = {
    cooked_mushrooms = imgui.ImBool(cfg.dishes["Готовые грибы"].is_eating),
    fried_fish = imgui.ImBool(cfg.dishes["Жареная рыба"].is_eating),
    fried_beef = imgui.ImBool(cfg.dishes["Жареная говядина"].is_eating),
    fried_venison = imgui.ImBool(cfg.dishes["Жареное мясо оленя"].is_eating),
    stewed_turtle_meat = imgui.ImBool(cfg.dishes["Тушеное черепашье мясо"].is_eating),
    fried_shark_meat = imgui.ImBool(cfg.dishes["Жареное акулье мясо"].is_eating),
    stewed_turtle_meat_with_mushrooms = imgui.ImBool(cfg.dishes["Рагу из черепашьего мяса"].is_eating),
    beef_with_mushrooms = imgui.ImBool(cfg.dishes["Говядина с грибами"].is_eating),
    venison_with_mushrooms = imgui.ImBool(cfg.dishes["Оленина с грибами"].is_eating),
    shark_meat_soup = imgui.ImBool(cfg.dishes["Уха с мясом акулы"].is_eating),
    seafood_dish = imgui.ImBool(cfg.dishes["Морское блюдо"].is_eating),
    trout_fish_soup = imgui.ImBool(cfg.dishes["Уха из форели"].is_eating),
    pike_fish_soup = imgui.ImBool(cfg.dishes["Уха из щуки"].is_eating),
    fish_chowder = imgui.ImBool(cfg.dishes["Рыбная похлебка"].is_eating),
    baked_carp = imgui.ImBool(cfg.dishes["Запечённый карп"].is_eating),
    fried_squid = imgui.ImBool(cfg.dishes["Жареный кальмар"].is_eating),
    fish_tacos = imgui.ImBool(cfg.dishes["Рыбные тако"].is_eating),
    sea_foam_pudding = imgui.ImBool(cfg.dishes["Морской пенный пудинг"].is_eating),
    fried_porcupinefish = imgui.ImBool(cfg.dishes["Жареная рыба-еж"].is_eating),
  }

  imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
  imgui.SetNextWindowSize(imgui.ImVec2(window_width, window_height), imgui.Cond.FirstUseEver)

  imgui.Begin("Kitchen helper by melvin-costra", window, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)

  for i, p in ipairs(pages) do
    if imgui.ButtonClickable(i ~= currentPage, u8(p)) then
        currentPage = i
    end
    imgui.SameLine()
  end
  imgui.NewLine()
  imgui.Separator()

  if currentPage == 1 then
    if imgui.Button(u8("Вкл/Выкл")) then
      cfg.settings.cook_enabled = not cfg.settings.cook_enabled
      if isCooking then stopCooking() end
      saveCFG()
    end
    imgui.SameLine(130)
    imgui.TextColoredRGB("Статус: " .. (cfg.settings.cook_enabled and "{00B200}Включено" or "{FF0F00}Выключено"))
    imgui.TextColoredRGB("Твой скилл: {6AB1FF}" .. data.skill)
    imgui.TextColoredRGB("{9c9c9c}/kc {ffffff}- начать готовку")
  
    imgui.NewLine()
  
    if imgui.ButtonClickable(not isUpdatingData, u8("Выбрать доступные блюда")) then
      selectAvailableDishes()
      saveCFG()
    end
  
    imgui.NewLine()
  
    imgui.TextColoredRGB("Скилл: {6AB1FF}0")
    imgui.SameLine(100)
    imgui.TextColoredRGB("S: {0e8ce6}+35 (75)")
    imgui.SameLine(200)
    imgui.TextColoredRGB("HP: {ff0019}+0")
    if imgui.Checkbox(u8("Готовые грибы"), cook_options.cooked_mushrooms) then
      cfg.dishes["Готовые грибы"].is_cooking = cook_options.cooked_mushrooms.v
      saveCFG()
    end
    imgui.SameLine()
    ShowHelpMarker("Ингредиенты (в наличии / нужно)\nГрибы: {6AB1FF}" .. data.ingredients.inventory["Грибы"] .. " / 1")
    imgui.NewLine()
  
    if imgui.Checkbox(u8("Жареная рыба"), cook_options.fried_fish) then
      cfg.dishes["Жареная рыба"].is_cooking = cook_options.fried_fish.v
      saveCFG()
    end
    imgui.SameLine()
    ShowHelpMarker("Ингредиенты (в наличии / нужно)\nСырая рыба: {6AB1FF}" .. data.ingredients.inventory["Сырая рыба"] .. " / 20000")
    imgui.NewLine()
  
    if imgui.Checkbox(u8("Жареная говядина"), cook_options.fried_beef) then
      cfg.dishes["Жареная говядина"].is_cooking = cook_options.fried_beef.v
      saveCFG()
    end
    imgui.SameLine()
    ShowHelpMarker("Ингредиенты (в наличии / нужно)\nМясо дикой коровы: {6AB1FF}" .. data.ingredients.inventory["Мясо дикой коровы"] .. " / 1")
    imgui.NewLine()
  
    if imgui.Checkbox(u8("Жареное мясо оленя"), cook_options.fried_venison) then
      cfg.dishes["Жареное мясо оленя"].is_cooking = cook_options.fried_venison.v
      saveCFG()
    end
    imgui.SameLine()
    ShowHelpMarker("Ингредиенты (в наличии / нужно)\nМясо оленя: {6AB1FF}" .. data.ingredients.inventory["Мясо оленя"] .. " / 1")
    imgui.NewLine()
  
    if imgui.Checkbox(u8("Тушеное черепашье мясо"), cook_options.stewed_turtle_meat) then
      cfg.dishes["Тушеное черепашье мясо"].is_cooking = cook_options.stewed_turtle_meat.v
      saveCFG()
    end
    imgui.SameLine()
    ShowHelpMarker("Ингредиенты (в наличии / нужно)\nМясо черепахи: {6AB1FF}" .. data.ingredients.inventory["Мясо черепахи"] .. " / 1")
    imgui.NewLine()
  
    if imgui.Checkbox(u8("Жареное акулье мясо"), cook_options.fried_shark_meat) then
      cfg.dishes["Жареное акулье мясо"].is_cooking = cook_options.fried_shark_meat.v
      saveCFG()
    end
    imgui.SameLine()
    ShowHelpMarker("Ингредиенты (в наличии / нужно)\nМясо акулы: {6AB1FF}" .. data.ingredients.inventory["Мясо акулы"] .. " / 1")
    imgui.NewLine()
  
    imgui.NewLine()
  
    imgui.TextColoredRGB("Скилл: {6AB1FF}500")
    imgui.SameLine(100)
    imgui.TextColoredRGB("S: {0e8ce6}+65 (150)")
    imgui.SameLine(200)
    imgui.TextColoredRGB("HP: {ff0019}+5")
    if imgui.Checkbox(u8("Рагу из черепашьего мяса"), cook_options.stewed_turtle_meat_with_mushrooms) then
      cfg.dishes["Рагу из черепашьего мяса"].is_cooking = cook_options.stewed_turtle_meat_with_mushrooms.v
      saveCFG()
    end
    imgui.SameLine()
    ShowHelpMarker("Ингредиенты (в наличии / нужно)\nТушеное черепашье мясо: {6AB1FF}" .. data.ingredients.inventory["Тушеное черепашье мясо"] .. " / 1\nОвощи: {6AB1FF}$50")
    imgui.NewLine()
  
    imgui.NewLine()
  
    imgui.TextColoredRGB("Скилл: {6AB1FF}1000")
    imgui.SameLine(100)
    imgui.TextColoredRGB("S: {0e8ce6}+75 (150)")
    imgui.SameLine(200)
    imgui.TextColoredRGB("HP: {ff0019}+10")
    if imgui.Checkbox(u8("Говядина с грибами"), cook_options.beef_with_mushrooms) then
      cfg.dishes["Говядина с грибами"].is_cooking = cook_options.beef_with_mushrooms.v
      saveCFG()
    end
    imgui.SameLine()
    ShowHelpMarker("Ингредиенты (в наличии / нужно)\nЖареная говядина: {6AB1FF}" .. data.ingredients.inventory["Жареная говядина"] .. " / 1\nГотовые грибы: {6AB1FF}" .. data.ingredients.inventory["Готовые грибы"] .. " / 25")
    imgui.NewLine()
  
    if imgui.Checkbox(u8("Оленина с грибами"), cook_options.venison_with_mushrooms) then
      cfg.dishes["Оленина с грибами"].is_cooking = cook_options.venison_with_mushrooms.v
      saveCFG()
    end
    imgui.SameLine()
    ShowHelpMarker("Ингредиенты (в наличии / нужно)\nЖареное мясо оленя: {6AB1FF}" .. data.ingredients.inventory["Жареное мясо оленя"] .. " / 1\nГотовые грибы: {6AB1FF}" .. data.ingredients.inventory["Готовые грибы"] .. " / 25")
    imgui.NewLine()
  
    imgui.NewLine()
  
    imgui.TextColoredRGB("Скилл: {6AB1FF}1500")
    imgui.SameLine(100)
    imgui.TextColoredRGB("S: {0e8ce6}+85 (150)")
    imgui.SameLine(200)
    imgui.TextColoredRGB("HP: {ff0019}+15")
    if imgui.Checkbox(u8("Уха с мясом акулы"), cook_options.shark_meat_soup) then
      cfg.dishes["Уха с мясом акулы"].is_cooking = cook_options.shark_meat_soup.v
      saveCFG()
    end
    imgui.SameLine()
    ShowHelpMarker("Ингредиенты (в наличии / нужно)\nЖареное акулье мясо: {6AB1FF}" .. data.ingredients.inventory["Жареное акулье мясо"] .. " / 1\nОвощи: {6AB1FF}$50")
    imgui.NewLine()
  
    imgui.NewLine()
  
    imgui.TextColoredRGB("Скилл: {6AB1FF}2500")
    imgui.SameLine(100)
    imgui.TextColoredRGB("S: {0e8ce6}+25 (150)")
    imgui.SameLine(200)
    imgui.TextColoredRGB("HP: {ff0019}+25")
    if imgui.Checkbox(u8("Морское блюдо"), cook_options.seafood_dish) then
      cfg.dishes["Морское блюдо"].is_cooking = cook_options.seafood_dish.v
      saveCFG()
    end
    imgui.SameLine()
    ShowHelpMarker("Ингредиенты (в наличии / нужно)\nСардина: {6AB1FF}" .. data.ingredients.fish["Сардина"] .. " / 5")
    imgui.NewLine()
  
    imgui.NewLine()
  
    imgui.TextColoredRGB("Скилл: {6AB1FF}3000")
    imgui.SameLine(100)
    imgui.TextColoredRGB("S: {0e8ce6}+30 (150)")
    imgui.SameLine(200)
    imgui.TextColoredRGB("HP: {ff0019}+30")
    if imgui.Checkbox(u8("Уха из форели"), cook_options.trout_fish_soup) then
      cfg.dishes["Уха из форели"].is_cooking = cook_options.trout_fish_soup.v
      saveCFG()
    end
    imgui.SameLine()
    ShowHelpMarker("Ингредиенты (в наличии / нужно)\nРадужная форель: {6AB1FF}" .. data.ingredients.fish["Радужная форель"] .. " / 3")
    imgui.NewLine()
  
    imgui.NewLine()
  
    imgui.TextColoredRGB("Скилл: {6AB1FF}3500")
    imgui.SameLine(100)
    imgui.TextColoredRGB("S: {0e8ce6}+35 (150)")
    imgui.SameLine(200)
    imgui.TextColoredRGB("HP: {ff0019}+35")
    if imgui.Checkbox(u8("Уха из щуки"), cook_options.pike_fish_soup) then
      cfg.dishes["Уха из щуки"].is_cooking = cook_options.pike_fish_soup.v
      saveCFG()
    end
    imgui.SameLine()
    ShowHelpMarker("Ингредиенты (в наличии / нужно)\nЩука: {6AB1FF}" .. data.ingredients.fish["Щука"] .. " / 3")
    imgui.NewLine()
  
    imgui.NewLine()
  
    imgui.TextColoredRGB("Скилл: {6AB1FF}4000")
    imgui.SameLine(100)
    imgui.TextColoredRGB("S: {0e8ce6}+40 (150)")
    imgui.SameLine(200)
    imgui.TextColoredRGB("HP: {ff0019}+40")
    if imgui.Checkbox(u8("Рыбная похлебка"), cook_options.fish_chowder) then
      cfg.dishes["Рыбная похлебка"].is_cooking = cook_options.fish_chowder.v
      saveCFG()
    end
    imgui.SameLine()
    ShowHelpMarker("Ингредиенты (в наличии / нужно)\nЛосось: {6AB1FF}" .. data.ingredients.fish["Лосось"] .. " / 3")
    imgui.NewLine()
  
    imgui.NewLine()
  
    imgui.TextColoredRGB("Скилл: {6AB1FF}5000")
    imgui.SameLine(100)
    imgui.TextColoredRGB("S: {0e8ce6}+50 (150)")
    imgui.SameLine(200)
    imgui.TextColoredRGB("HP: {ff0019}+50")
    if imgui.Checkbox(u8("Запечённый карп"), cook_options.baked_carp) then
      cfg.dishes["Запечённый карп"].is_cooking = cook_options.baked_carp.v
      saveCFG()
    end
    imgui.SameLine()
    ShowHelpMarker("Ингредиенты (в наличии / нужно)\nКарп: {6AB1FF}" .. data.ingredients.fish["Карп"] .. " / 4")
    imgui.NewLine()
  
    imgui.NewLine()
  
    imgui.TextColoredRGB("Скилл: {6AB1FF}6500")
    imgui.SameLine(100)
    imgui.TextColoredRGB("S: {0e8ce6}+65 (150)")
    imgui.SameLine(200)
    imgui.TextColoredRGB("HP: {ff0019}+65")
    if imgui.Checkbox(u8("Жареный кальмар"), cook_options.fried_squid) then
      cfg.dishes["Жареный кальмар"].is_cooking = cook_options.fried_squid.v
      saveCFG()
    end
    imgui.SameLine()
    ShowHelpMarker("Ингредиенты (в наличии / нужно)\nКальмар: {6AB1FF}" .. data.ingredients.fish["Кальмар"] .. " / 2")
    imgui.NewLine()
  
    if imgui.Checkbox(u8("Рыбные тако"), cook_options.fish_tacos) then
      cfg.dishes["Рыбные тако"].is_cooking = cook_options.fish_tacos.v
      saveCFG()
    end
    imgui.SameLine()
    ShowHelpMarker("Ингредиенты (в наличии / нужно)\nТунец: {6AB1FF}" .. data.ingredients.fish["Тунец"] .. " / 3")
    imgui.NewLine()
  
    imgui.NewLine()
  
    imgui.TextColoredRGB("Скилл: {6AB1FF}8000")
    imgui.SameLine(100)
    imgui.TextColoredRGB("S: {0e8ce6}+80 (150)")
    imgui.SameLine(200)
    imgui.TextColoredRGB("HP: {ff0019}+80")
    if imgui.Checkbox(u8("Морской пенный пудинг"), cook_options.sea_foam_pudding) then
      cfg.dishes["Морской пенный пудинг"].is_cooking = cook_options.sea_foam_pudding.v
      saveCFG()
    end
    imgui.SameLine()
    ShowHelpMarker("Ингредиенты (в наличии / нужно)\nМелкая камбала: {6AB1FF}" .. data.ingredients.fish["Мелкая камбала"] .. " / 4")
    imgui.NewLine()
  
    imgui.NewLine()
  
    imgui.TextColoredRGB("Скилл: {6AB1FF}10000")
    imgui.SameLine(100)
    imgui.TextColoredRGB("S: {0e8ce6}+100 (150)")
    imgui.SameLine(200)
    imgui.TextColoredRGB("HP: {ff0019}+100")
    if imgui.Checkbox(u8("Жареная рыба-еж"), cook_options.fried_porcupinefish) then
      cfg.dishes["Жареная рыба-еж"].is_cooking = cook_options.fried_porcupinefish.v
      saveCFG()
    end
    imgui.SameLine()
    ShowHelpMarker("Ингредиенты (в наличии / нужно)\nРыба-еж: {6AB1FF}" .. data.ingredients.fish["Рыба-еж"] .. " / 1")
    imgui.NewLine()
  elseif currentPage == 2 then
    if imgui.Button(u8("Вкл/Выкл")) then
      cfg.settings.eat_enabled = not cfg.settings.eat_enabled
      if isEating then stopEating() end
      saveCFG()
    end
    imgui.SameLine(130)
    imgui.TextColoredRGB("Статус: " .. (cfg.settings.eat_enabled and "{00B200}Включено" or "{FF0F00}Выключено"))

    imgui.NewLine()

    if imgui.HotKey("##1", cfg.settings.act_eat_key, tLastKeys, 100) then
      rkeys.changeHotKey(bindEat, cfg.settings.act_eat_key.v)
      saveCFG()
    end
    imgui.SameLine()
    imgui.Text(u8("- покушать"))
    imgui.SameLine()
    ShowHelpMarker("Горячая клавиша чтобы покушать\nБудет кушать блюда, начиная с начала списка")
    imgui.NewLine()

    if imgui.HotKey("##2", cfg.settings.act_heal_key, tLastKeys, 100) then
      rkeys.changeHotKey(bindHeal, cfg.settings.act_heal_key.v)
      saveCFG()
    end
    imgui.SameLine()
    imgui.Text(u8("- пополнить здоровье"))
    imgui.SameLine()
    ShowHelpMarker("Горячая клавиша чтобы пополнить здоровье\nБудет кушать блюда, которые восстанавливают здоровье, в зависимости от текущего количества HP")
    imgui.NewLine()

    imgui.NewLine()
  
    if imgui.ButtonClickable(not isUpdatingData, u8("Выбрать имеющиеся блюда")) then
      selectExistingDishes()
      saveCFG()
    end

    imgui.NewLine()
    imgui.Separator()

    if imgui.Checkbox(u8("Готовые грибы"), eat_options.cooked_mushrooms) then
      cfg.dishes["Готовые грибы"].is_eating = eat_options.cooked_mushrooms.v
      saveCFG()
    end
    imgui.SameLine()
    ShowHelpMarker("Сытость: {0e8ce6}+10 (50)\nHP: {ff0019}+0")
    imgui.SameLine(210)
    imgui.TextColoredRGB("{6AB1FF}" .. data.ingredients.inventory["Готовые грибы"])

    if imgui.Checkbox(u8("Жареная рыба"), eat_options.fried_fish) then
      cfg.dishes["Жареная рыба"].is_eating = eat_options.fried_fish.v
      saveCFG()
    end
    imgui.SameLine()
    ShowHelpMarker("Сытость: {0e8ce6}+35 (75)\nHP: {ff0019}+0")
    imgui.SameLine(210)
    imgui.TextColoredRGB("{6AB1FF}" .. data.ingredients.inventory["Жареная рыба"])

    if imgui.Checkbox(u8("Жареная говядина"), eat_options.fried_beef) then
      cfg.dishes["Жареная говядина"].is_eating = eat_options.fried_beef.v
      saveCFG()
    end
    imgui.SameLine()
    ShowHelpMarker("Сытость: {0e8ce6}+35 (75)\nHP: {ff0019}+0")
    imgui.SameLine(210)
    imgui.TextColoredRGB("{6AB1FF}" .. data.ingredients.inventory["Жареная говядина"])

    if imgui.Checkbox(u8("Жареное мясо оленя"), eat_options.fried_venison) then
      cfg.dishes["Жареное мясо оленя"].is_eating = eat_options.fried_venison.v
      saveCFG()
    end
    imgui.SameLine()
    ShowHelpMarker("Сытость: {0e8ce6}+35 (75)\nHP: {ff0019}+0")
    imgui.SameLine(210)
    imgui.TextColoredRGB("{6AB1FF}" .. data.ingredients.inventory["Жареное мясо оленя"])

    if imgui.Checkbox(u8("Тушеное черепашье мясо"), eat_options.stewed_turtle_meat) then
      cfg.dishes["Тушеное черепашье мясо"].is_eating = eat_options.stewed_turtle_meat.v
      saveCFG()
    end
    imgui.SameLine()
    ShowHelpMarker("Сытость: {0e8ce6}+35 (75)\nHP: {ff0019}+0")
    imgui.SameLine(210)
    imgui.TextColoredRGB("{6AB1FF}" .. data.ingredients.inventory["Тушеное черепашье мясо"])

    if imgui.Checkbox(u8("Жареное акулье мясо"), eat_options.fried_shark_meat) then
      cfg.dishes["Жареное акулье мясо"].is_eating = eat_options.fried_shark_meat.v
      saveCFG()
    end
    imgui.SameLine()
    ShowHelpMarker("Сытость: {0e8ce6}+35 (75)\nHP: {ff0019}+0")
    imgui.SameLine(210)
    imgui.TextColoredRGB("{6AB1FF}" .. data.ingredients.inventory["Жареное акулье мясо"])

    if imgui.Checkbox(u8("Рагу из черепашьего мяса"), eat_options.stewed_turtle_meat_with_mushrooms) then
      cfg.dishes["Рагу из черепашьего мяса"].is_eating = eat_options.stewed_turtle_meat_with_mushrooms.v
      saveCFG()
    end
    imgui.SameLine()
    ShowHelpMarker("Сытость: {0e8ce6}+65 (150)\nHP: {ff0019}+5")
    imgui.SameLine(210)
    imgui.TextColoredRGB("{6AB1FF}" .. data.ingredients.inventory["Рагу из черепашьего мяса"])

    if imgui.Checkbox(u8("Говядина с грибами"), eat_options.beef_with_mushrooms) then
      cfg.dishes["Говядина с грибами"].is_eating = eat_options.beef_with_mushrooms.v
      saveCFG()
    end
    imgui.SameLine()
    ShowHelpMarker("Сытость: {0e8ce6}+75 (150)\nHP: {ff0019}+10")
    imgui.SameLine(210)
    imgui.TextColoredRGB("{6AB1FF}" .. data.ingredients.inventory["Говядина с грибами"])

    if imgui.Checkbox(u8("Оленина с грибами"), eat_options.venison_with_mushrooms) then
      cfg.dishes["Оленина с грибами"].is_eating = eat_options.venison_with_mushrooms.v
      saveCFG()
    end
    imgui.SameLine()
    ShowHelpMarker("Сытость: {0e8ce6}+75 (150)\nHP: {ff0019}+10")
    imgui.SameLine(210)
    imgui.TextColoredRGB("{6AB1FF}" .. data.ingredients.inventory["Оленина с грибами"])

    if imgui.Checkbox(u8("Уха с мясом акулы"), eat_options.shark_meat_soup) then
      cfg.dishes["Уха с мясом акулы"].is_eating = eat_options.shark_meat_soup.v
      saveCFG()
    end
    imgui.SameLine()
    ShowHelpMarker("Сытость: {0e8ce6}+85 (150)\nHP: {ff0019}+15")
    imgui.SameLine(210)
    imgui.TextColoredRGB("{6AB1FF}" .. data.ingredients.inventory["Уха с мясом акулы"])

    if imgui.Checkbox(u8("Морское блюдо"), eat_options.seafood_dish) then
      cfg.dishes["Морское блюдо"].is_eating = eat_options.seafood_dish.v
      saveCFG()
    end
    imgui.SameLine()
    ShowHelpMarker("Сытость: {0e8ce6}+25 (150)\nHP: {ff0019}+25")
    imgui.SameLine(210)
    imgui.TextColoredRGB("{6AB1FF}" .. data.ingredients.inventory["Морское блюдо"])

    if imgui.Checkbox(u8("Уха из форели"), eat_options.trout_fish_soup) then
      cfg.dishes["Уха из форели"].is_eating = eat_options.trout_fish_soup.v
      saveCFG()
    end
    imgui.SameLine()
    ShowHelpMarker("Сытость: {0e8ce6}+30 (150)\nHP: {ff0019}+30")
    imgui.SameLine(210)
    imgui.TextColoredRGB("{6AB1FF}" .. data.ingredients.inventory["Уха из форели"])

    if imgui.Checkbox(u8("Уха из щуки"), eat_options.pike_fish_soup) then
      cfg.dishes["Уха из щуки"].is_eating = eat_options.pike_fish_soup.v
      saveCFG()
    end
    imgui.SameLine()
    ShowHelpMarker("Сытость: {0e8ce6}+35 (150)\nHP: {ff0019}+35")
    imgui.SameLine(210)
    imgui.TextColoredRGB("{6AB1FF}" .. data.ingredients.inventory["Уха из щуки"])

    if imgui.Checkbox(u8("Рыбная похлебка"), eat_options.fish_chowder) then
      cfg.dishes["Рыбная похлебка"].is_eating = eat_options.fish_chowder.v
      saveCFG()
    end
    imgui.SameLine()
    ShowHelpMarker("Сытость: {0e8ce6}+40 (150)\nHP: {ff0019}+40")
    imgui.SameLine(210)
    imgui.TextColoredRGB("{6AB1FF}" .. data.ingredients.inventory["Рыбная похлебка"])

    if imgui.Checkbox(u8("Запечённый карп"), eat_options.baked_carp) then
      cfg.dishes["Запечённый карп"].is_eating = eat_options.baked_carp.v
      saveCFG()
    end
    imgui.SameLine()
    ShowHelpMarker("Сытость: {0e8ce6}+50 (150)\nHP: {ff0019}+50")
    imgui.SameLine(210)
    imgui.TextColoredRGB("{6AB1FF}" .. data.ingredients.inventory["Запечённый карп"])

    if imgui.Checkbox(u8("Жареный кальмар"), eat_options.fried_squid) then
      cfg.dishes["Жареный кальмар"].is_eating = eat_options.fried_squid.v
      saveCFG()
    end
    imgui.SameLine()
    ShowHelpMarker("Сытость: {0e8ce6}+65 (150)\nHP: {ff0019}+65")
    imgui.SameLine(210)
    imgui.TextColoredRGB("{6AB1FF}" .. data.ingredients.inventory["Жареный кальмар"])

    if imgui.Checkbox(u8("Рыбные тако"), eat_options.fish_tacos) then
      cfg.dishes["Рыбные тако"].is_eating = eat_options.fish_tacos.v
      saveCFG()
    end
    imgui.SameLine()
    ShowHelpMarker("Сытость: {0e8ce6}+65 (150)\nHP: {ff0019}+65")
    imgui.SameLine(210)
    imgui.TextColoredRGB("{6AB1FF}" .. data.ingredients.inventory["Рыбные тако"])

    if imgui.Checkbox(u8("Морской пенный пудинг"), eat_options.sea_foam_pudding) then
      cfg.dishes["Морской пенный пудинг"].is_eating = eat_options.sea_foam_pudding.v
      saveCFG()
    end
    imgui.SameLine()
    ShowHelpMarker("Сытость: {0e8ce6}+80 (150)\nHP: {ff0019}+80")
    imgui.SameLine(210)
    imgui.TextColoredRGB("{6AB1FF}" .. data.ingredients.inventory["Морской пенный пудинг"])

    if imgui.Checkbox(u8("Жареная рыба-еж"), eat_options.fried_porcupinefish) then
      cfg.dishes["Жареная рыба-еж"].is_eating = eat_options.fried_porcupinefish.v
      saveCFG()
    end
    imgui.SameLine()
    ShowHelpMarker("Сытость: {0e8ce6}+100 (150)\nHP: {ff0019}+100")
    imgui.SameLine(210)
    imgui.TextColoredRGB("{6AB1FF}" .. data.ingredients.inventory["Жареная рыба-еж"])
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

function ShowHelpMarker(param)
  if imgui.IsItemHovered() then
    imgui.BeginTooltip()
    imgui.PushTextWrapPos(imgui.GetFontSize() * 35.0)
    imgui.TextColoredRGB(param)
    imgui.PopTextWrapPos()
    imgui.EndTooltip()
  end
end

function imgui.ButtonClickable(clickable, ...)
  if clickable then
    return imgui.Button(...)

  else
    local r, g, b, a = imgui.ImColor(imgui.GetStyle().Colors[imgui.Col.Button]):GetFloat4()
    imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(r, g, b, a/2) )
    imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(r, g, b, a/2))
    imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(r, g, b, a/2))
    imgui.PushStyleColor(imgui.Col.Text, imgui.GetStyle().Colors[imgui.Col.TextDisabled])
    imgui.Button(...)
    imgui.PopStyleColor()
    imgui.PopStyleColor()
    imgui.PopStyleColor()
    imgui.PopStyleColor()
  end
end

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
  if isUpdatingData then
    if text == " У вас нет еды" then return false end

    local skill = text:match(" Ваш навык приготовление еды: {FFFFFF}(%d+)/10000")
    if skill then
      data.skill = tonumber(skill)
      commandStates["/kitchen skill"] = nil
      sendCommand("/eat")
      return false
    end
  end

	if cfg.settings.cook_enabled and isCooking then
    if text == " (( Введите: /kitchen cooking ещё раз или нажмите l.alt ))" then
      sendCommand("/kitchen cooking")
    elseif text:find("^ Вы приготовили {FFFFFF}'.+'{6AB1FF}: %d+") then
      local amount = tonumber(text:match("^ Вы приготовили {FFFFFF}'.+'{6AB1FF}: (%d+)"))
      data.ingredients[dishesQueue[1].key][dishesQueue[1].name] = amount
      for k, v in pairs(cfg.dishes[dishesQueue[1].name].ingredients) do
        data.ingredients[dishesQueue[1].key][k] = data.ingredients[dishesQueue[1].key][k] - v
      end
      data.skill = data.skill + 1
      sendCommand("/kitchen cooking")
    elseif text == " Вы должны быть рядом с плитой"
    or text == " Вы не умеете это готовить. Продолжайте готовить другие блюда"
    or text == " Недостаточно денег. Требуется 2500 вирт"
    then
      stopCooking()
    end

    if text == " У вас нет нужных ингредиентов" or text == " Нет места" then
      sendChatMessage("Готовка {6AB1FF}'" .. dishesQueue[1].name .. "'{FFFFFF} остановлена. Нету нужных ингредиентов или места")
      table.remove(dishesQueue, 1)
      if #dishesQueue == 0 then
        stopCooking()
        return false
      end
      sendCommand("/kitchen cooking")
      return false
    end
  end

  if isEating then
    local satiety = text:match(" Вы съели {FFFFFF}'.+'{6AB1FF}%. Сытость пополнена до (%d+)%.")
    if text == " Вы не голодны/Превышен лимит допустимой сытости" then
      stopEating()
    elseif satiety then
      data.my_satiety = tonumber(satiety)
      if cfg.dishes[currentDishName] and cfg.dishes[currentDishName].max_satiety == data.my_satiety then
        stopEating()
      else
        antiflood = os.clock() * 1000
        sendCommand("/eat")
      end
    end
  end

  local satiety = text:match(" Ваша «Сытость»: (%d+) / %d+")
  if satiety then
    commandStates["/satiety"] = nil
    satiety = tonumber(satiety)
    data.my_satiety = satiety
    if isEating then
      if satiety <= 150 then
        sendCommand("/eat")
      else
        sendChatMessage("Ты не голодный")
        stopEating()
      end
    end
    return false
  end
end

function ev.onSendChat(text)
	antiflood = os.clock() * 1000
end

function ev.onSendCommand(cmd)
	antiflood = os.clock() * 1000
end

function ev.onShowDialog(id, style, title, btn1, btn2, text)
  if isUpdatingData or window.v then
    if (style == 5 or style == 2) and title == "{FFFFFF}Еда" then
      commandStates["/eat"] = nil
      local remaining = {}
      for name in pairs(data.ingredients.inventory) do
        remaining[name] = true
      end
      for line in text:gmatch("[^\n]+") do
        local raw_text = escape_string(line)
        local name, amount = raw_text:match("{FFFFFF}(.+)\\t{6AB1FF}(%d+)")
        if data.ingredients.inventory[name] and amount then
          data.ingredients.inventory[name] = tonumber(amount)
          remaining[name] = nil
        end
      end
      for name in pairs(remaining) do
        data.ingredients.inventory[name] = 0
      end
      sendCommand("/inventory")
      return false
    end

    if style == 4 and title == "Карманы" then
      commandStates["/inventory"] = nil
      for line in text:gmatch("[^\n]+") do
        local raw_text = escape_string(line)
        local name, amount = raw_text:match("%[%d+%] (.+)\\t(%d+) / %d+")
        if data.ingredients.inventory[name] and amount then
          data.ingredients.inventory[name] = tonumber(amount)
        end
      end
      sendCommand("/fish inv")
      return false
    end

    if style == 4 and title == "{FFFFFF} Инвентарь {6AB1FF}| Рыбалка" then
      commandStates["/fish inv"] = nil
      local remaining = {}
      for name in pairs(data.ingredients.fish) do
        remaining[name] = true
      end
      for line in text:gmatch("[^\n]+") do
        local raw_text = escape_string(line)
        local name, amount = raw_text:match("(.+)\\t(%d+)")
        if data.ingredients.fish[name] and amount then
          data.ingredients.fish[name] = tonumber(amount)
          remaining[name] = nil
        end
      end
      for name in pairs(remaining) do
        data.ingredients.fish[name] = 0
      end
      isUpdatingData = false
      return false
    end
  end

  if cfg.settings.cook_enabled and isCooking then
    if style == 0 and title == "Кухня" then
      commandStates["/kitchen cooking"] = nil
      sampSendDialogResponse(id, 1, 0, "")
      return false
    end
    if style == 5 and title == "Кухня" then
      commandStates["/kitchen cooking"] = nil
      if #dishesQueue > 0 then
        sampSendDialogResponse(id, 1, dishesQueue[1].index, "")
        return false
      end
      local lines = text:gsub("^[^\n]*\n", "")
      local i = 0
      for line in lines:gmatch("[^\n]+") do
        local raw_text = escape_string(line)
        local name, satiety, hp, skill = raw_text:match("{FFFFFF}(.+)\\t{6AB1FF}(.+)\\t{FFFFFF}(.+)\\t{6AB1FF}(.+)")
        if name and satiety and hp and skill then
          if cfg.dishes[name].is_cooking then
            table.insert(dishesQueue, { key = cfg.dishes[name].key, name = name, index = i })
          end
        end
        i = i + 1
      end
      if #dishesQueue > 0 then
        sampSendDialogResponse(id, 1, dishesQueue[1].index, "")
      else
        stopCooking()
      end
      return false
    end
  end

  if cfg.settings.eat_enabled then
    if isEating or isHealing then
      if style == 2 and title == "{FFFFFF}Еда" then
        stopEating()
        cfg.settings.eat_enabled = false
        saveCFG()
        return false
      end

      if style == 0 and cfg.dishes[title] ~= nil then
        if isHealing then
          stopEating()
        end
        sampSendDialogResponse(id, 1, 0, "")
        return false
      end

      if style == 5 and title == "{FFFFFF}Еда" then
        commandStates["/eat"] = nil
        local lines = text:gsub("^[^\n]*\n", "")
        local healingDishIndex = -1
        local i = 0
        for line in lines:gmatch("[^\n]+") do
          local raw_text = escape_string(line)
          local name, amount = raw_text:match("{FFFFFF}(.+)\\t{6AB1FF}(%d+)")
          if name and amount then
            if cfg.dishes[name] and cfg.dishes[name].is_eating then
              if isHealing then
                if cfg.dishes[name].hp > 0 then
                  healingDishIndex = i
                  if cfg.dishes[name].hp >= (100 - data.my_hp) then
                    sampSendDialogResponse(id, 1, i, "")
                    return false
                  end
                end
              elseif isEating then
                if cfg.dishes[name].max_satiety > data.my_satiety then
                  currentDishName = name
                  sampSendDialogResponse(id, 1, i, "")
                else
                  sendChatMessage("Твоя сытость превышает максимальную для {6AB1FF}" .. name)
                  stopEating()
                end
                return false
              end
            end
          end
          i = i + 1
        end
        if isHealing then
          if healingDishIndex ~= -1 then
            sampSendDialogResponse(id, 1, healingDishIndex, "")
          else
            sendChatMessage("Блюд для лечения не найдено")
            stopEating()
          end
        elseif isEating then
          sendChatMessage("Блюд для поедания не найдено")
          cfg.settings.eat_enabled = false
          stopEating()
          saveCFG()
        end
        return false
      end
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
  stopCooking()
  stopEating()
end
