local version = "15.02.2026"
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

------------------------------------ Vars  ------------------------------------
local CONFIG_PATH = "moonloader/config/kitchen.json"
local window = imgui.ImBool(false)
local antiflood = os.clock() * 1000
local commandStates = {}
local isCooking, isUpdatingData = false, false
local dishesQueue = {}
local data = {
  skill = 0,
  ingredients = {
    inventory = {
      ["Грибы"] = 0,
      ["Сырая рыба"] = 0,
      ["Готовая рыба"] = 0,
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
  }
}

------------------------------------ Settings  ------------------------------------
local cfg = {
  dishes = {
    ["Готовые грибы"] = {
      enabled = false,
      skill = 0,
      key = "inventory",
      ingredients = {
        ["Грибы"] = 1,
      }
    },
    ["Жареная рыба"] = {
      enabled = false,
      skill = 0,
      key = "inventory",
      ingredients = {
        ["Сырая рыба"] = 20000,
      }
    },
    ["Жареная говядина"] = {
      enabled = false,
      skill = 0,
      key = "inventory",
      ingredients = {
        ["Мясо дикой коровы"] = 1,
      }
    },
    ["Жареное мясо оленя"] = {
      enabled = false,
      skill = 0,
      key = "inventory",
      ingredients = {
        ["Мясо оленя"] = 1,
      }
    },
    ["Тушеное черепашье мясо"] = {
      enabled = false,
      skill = 0,
      key = "inventory",
      ingredients = {
        ["Мясо черепахи"] = 1,
      }
    },
    ["Жареное акулье мясо"] = {
      enabled = false,
      skill = 0,
      key = "inventory",
      ingredients = {
        ["Мясо акулы"] = 1,
      }
    },
    ["Рагу из черепашьего мяса"] = {
      enabled = false,
      skill = 500,
      key = "inventory",
      ingredients = {
        ["Тушеное черепашье мясо"] = 1,
      }
    },
    ["Говядина с грибами"] = {
      enabled = false,
      skill = 1000,
      key = "inventory",
      ingredients = {
        ["Жареная говядина"] = 1,
        ["Готовые грибы"] = 25,
      }
    },
    ["Оленина с грибами"] = {
      enabled = false,
      skill = 1000,
      key = "inventory",
      ingredients = {
        ["Жареное мясо оленя"] = 1,
        ["Готовые грибы"] = 25,
      }
    },
    ["Уха с мясом акулы"] = {
      enabled = false,
      skill = 1500,
      key = "inventory",
      ingredients = {
        ["Жареное акулье мясо"] = 1,
      }
    },
    ["Морское блюдо"] = {
      enabled = false,
      skill = 2500,
      key = "fish",
      ingredients = {
        ["Сардина"] = 5,
      }
    },
    ["Уха из форели"] = {
      enabled = false,
      skill = 3000,
      key = "fish",
      ingredients = {
        ["Радужная форель"] = 3,
      }
    },
    ["Уха из щуки"] = {
      enabled = false,
      skill = 3500,
      key = "fish",
      ingredients = {
        ["Щука"] = 3,
      }
    },
    ["Рыбная похлебка"] = {
      enabled = false,
      skill = 4000,
      key = "fish",
      ingredients = {
        ["Лосось"] = 3,
      }
    },
    ["Запечённый карп"] = {
      enabled = false,
      skill = 5000,
      key = "fish",
      ingredients = {
        ["Карп"] = 4,
      }
    },
    ["Жареный кальмар"] = {
      enabled = false,
      skill = 6500,
      key = "fish",
      ingredients = {
        ["Кальмар"] = 2,
      }
    },
    ["Рыбные тако"] = {
      enabled = false,
      skill = 6500,
      key = "fish",
      ingredients = {
        ["Тунец"] = 3,
      }
    },
    ["Морской пенный пудинг"] = {
      enabled = false,
      skill = 8000,
      key = "fish",
      ingredients = {
        ["Мелкая камбала"] = 4,
      }
    },
    ["Жареная рыба-еж"] = {
      enabled = false,
      skill = 10000,
      key = "fish",
      ingredients = {
        ["Рыба-еж"] = 1,
      }
    },
  },
  settings = {
    enabled = false,
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

  while true do
    wait(0)
    imgui.Process = window.v
    if isCooking and isKeyJustPressed(VK_R) and not sampIsCursorActive() then stopCooking() end
  end
end

function startCooking()
  if not cfg.settings.enabled then return end
  if isCooking then
    stopCooking()
    return
  end
  for _, v in pairs(cfg.dishes) do
    if v.enabled then
      isCooking = true
      sendCommand("/kitchen cooking")
      sendChatMessage("Готовка включена. Жми {6AB1FF}R{FFFFFF} для остановки")
      return
    end
  end
  sendChatMessage("Сначала выбери хотя бы одно блюдо в меню (/kh)")
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
  for k, v in pairs(cfg.dishes) do
    local hasAllIngredients = true
    for ing, count in pairs(v.ingredients) do
      if data.ingredients[v.key][ing] < count then 
        hasAllIngredients = false
        break
      end
    end
    if hasAllIngredients and data.skill >= v.skill then
      v.enabled = true
    else
      v.enabled = false
    end
  end
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
  if imgui.Checkbox(u8("Готовые грибы"), options.cooked_mushrooms) then
    cfg.dishes["Готовые грибы"].enabled = options.cooked_mushrooms.v
    saveCFG()
  end
  imgui.SameLine()
  ShowHelpMarker("Ингредиенты (в наличии / нужно)\nГрибы: {6AB1FF}" .. data.ingredients.inventory["Грибы"] .. " / 1")
  imgui.SameLine(200)
  imgui.TextColoredRGB("{6AB1FF}" .. data.ingredients.inventory["Готовые грибы"])

  if imgui.Checkbox(u8("Жареная рыба"), options.fried_fish) then
    cfg.dishes["Жареная рыба"].enabled = options.fried_fish.v
    saveCFG()
  end
  imgui.SameLine()
  ShowHelpMarker("Ингредиенты (в наличии / нужно)\nСырая рыба: {6AB1FF}" .. data.ingredients.inventory["Сырая рыба"] .. " / 20000")
  imgui.SameLine(200)
  imgui.TextColoredRGB("{6AB1FF}" .. data.ingredients.inventory["Готовая рыба"])

  if imgui.Checkbox(u8("Жареная говядина"), options.fried_beef) then
    cfg.dishes["Жареная говядина"].enabled = options.fried_beef.v
    saveCFG()
  end
  imgui.SameLine()
  ShowHelpMarker("Ингредиенты (в наличии / нужно)\nМясо дикой коровы: {6AB1FF}" .. data.ingredients.inventory["Мясо дикой коровы"] .. " / 1")
  imgui.SameLine(200)
  imgui.TextColoredRGB("{6AB1FF}" .. data.ingredients.inventory["Жареная говядина"])

  if imgui.Checkbox(u8("Жареное мясо оленя"), options.fried_venison) then
    cfg.dishes["Жареное мясо оленя"].enabled = options.fried_venison.v
    saveCFG()
  end
  imgui.SameLine()
  ShowHelpMarker("Ингредиенты (в наличии / нужно)\nМясо оленя: {6AB1FF}" .. data.ingredients.inventory["Мясо оленя"] .. " / 1")
  imgui.SameLine(200)
  imgui.TextColoredRGB("{6AB1FF}" .. data.ingredients.inventory["Жареное мясо оленя"])

  if imgui.Checkbox(u8("Тушеное черепашье мясо"), options.stewed_turtle_meat) then
    cfg.dishes["Тушеное черепашье мясо"].enabled = options.stewed_turtle_meat.v
    saveCFG()
  end
  imgui.SameLine()
  ShowHelpMarker("Ингредиенты (в наличии / нужно)\nМясо черепахи: {6AB1FF}" .. data.ingredients.inventory["Мясо черепахи"] .. " / 1")
  imgui.SameLine(200)
  imgui.TextColoredRGB("{6AB1FF}" .. data.ingredients.inventory["Тушеное черепашье мясо"])

  if imgui.Checkbox(u8("Жареное акулье мясо"), options.fried_shark_meat) then
    cfg.dishes["Жареное акулье мясо"].enabled = options.fried_shark_meat.v
    saveCFG()
  end
  imgui.SameLine()
  ShowHelpMarker("Ингредиенты (в наличии / нужно)\nМясо акулы: {6AB1FF}" .. data.ingredients.inventory["Мясо акулы"] .. " / 1")
  imgui.SameLine(200)
  imgui.TextColoredRGB("{6AB1FF}" .. data.ingredients.inventory["Жареное акулье мясо"])

  imgui.NewLine()

  imgui.TextColoredRGB("Скилл: {6AB1FF}500")
  imgui.SameLine(100)
  imgui.TextColoredRGB("S: {0e8ce6}+65 (150)")
  imgui.SameLine(200)
  imgui.TextColoredRGB("HP: {ff0019}+5")
  if imgui.Checkbox(u8("Рагу из черепашьего мяса"), options.stewed_turtle_meat_with_mushrooms) then
    cfg.dishes["Рагу из черепашьего мяса"].enabled = options.stewed_turtle_meat_with_mushrooms.v
    saveCFG()
  end
  imgui.SameLine()
  ShowHelpMarker("Ингредиенты (в наличии / нужно)\nТушеное черепашье мясо: {6AB1FF}" .. data.ingredients.inventory["Тушеное черепашье мясо"] .. " / 1\nОвощи: {6AB1FF}$50")
  imgui.SameLine(200)
  imgui.TextColoredRGB("{6AB1FF}" .. data.ingredients.inventory["Рагу из черепашьего мяса"])

  imgui.NewLine()

  imgui.TextColoredRGB("Скилл: {6AB1FF}1000")
  imgui.SameLine(100)
  imgui.TextColoredRGB("S: {0e8ce6}+75 (150)")
  imgui.SameLine(200)
  imgui.TextColoredRGB("HP: {ff0019}+10")
  if imgui.Checkbox(u8("Говядина с грибами"), options.beef_with_mushrooms) then
    cfg.dishes["Говядина с грибами"].enabled = options.beef_with_mushrooms.v
    saveCFG()
  end
  imgui.SameLine()
  ShowHelpMarker("Ингредиенты (в наличии / нужно)\nЖареная говядина: {6AB1FF}" .. data.ingredients.inventory["Жареная говядина"] .. " / 1\nГотовые грибы: {6AB1FF}" .. data.ingredients.inventory["Готовые грибы"] .. " / 25")
  imgui.SameLine(200)
  imgui.TextColoredRGB("{6AB1FF}" .. data.ingredients.inventory["Говядина с грибами"])

  if imgui.Checkbox(u8("Оленина с грибами"), options.venison_with_mushrooms) then
    cfg.dishes["Оленина с грибами"].enabled = options.venison_with_mushrooms.v
    saveCFG()
  end
  imgui.SameLine()
  ShowHelpMarker("Ингредиенты (в наличии / нужно)\nЖареное мясо оленя: {6AB1FF}" .. data.ingredients.inventory["Жареное мясо оленя"] .. " / 1\nГотовые грибы: {6AB1FF}" .. data.ingredients.inventory["Готовые грибы"] .. " / 25")
  imgui.SameLine(200)
  imgui.TextColoredRGB("{6AB1FF}" .. data.ingredients.inventory["Оленина с грибами"])

  imgui.NewLine()

  imgui.TextColoredRGB("Скилл: {6AB1FF}1500")
  imgui.SameLine(100)
  imgui.TextColoredRGB("S: {0e8ce6}+85 (150)")
  imgui.SameLine(200)
  imgui.TextColoredRGB("HP: {ff0019}+15")
  if imgui.Checkbox(u8("Уха с мясом акулы"), options.shark_meat_soup) then
    cfg.dishes["Уха с мясом акулы"].enabled = options.shark_meat_soup.v
    saveCFG()
  end
  imgui.SameLine()
  ShowHelpMarker("Ингредиенты (в наличии / нужно)\nЖареное акулье мясо: {6AB1FF}" .. data.ingredients.inventory["Жареное акулье мясо"] .. " / 1\nОвощи: {6AB1FF}$50")
  imgui.SameLine(200)
  imgui.TextColoredRGB("{6AB1FF}" .. data.ingredients.inventory["Уха с мясом акулы"])

  imgui.NewLine()

  imgui.TextColoredRGB("Скилл: {6AB1FF}2500")
  imgui.SameLine(100)
  imgui.TextColoredRGB("S: {0e8ce6}+25 (150)")
  imgui.SameLine(200)
  imgui.TextColoredRGB("HP: {ff0019}+25")
  if imgui.Checkbox(u8("Морское блюдо"), options.seafood_dish) then
    cfg.dishes["Морское блюдо"].enabled = options.seafood_dish.v
    saveCFG()
  end
  imgui.SameLine()
  ShowHelpMarker("Ингредиенты (в наличии / нужно)\nСардина: {6AB1FF}" .. data.ingredients.fish["Сардина"] .. " / 5")
  imgui.SameLine(200)
  imgui.TextColoredRGB("{6AB1FF}" .. data.ingredients.inventory["Морское блюдо"])

  imgui.NewLine()

  imgui.TextColoredRGB("Скилл: {6AB1FF}3000")
  imgui.SameLine(100)
  imgui.TextColoredRGB("S: {0e8ce6}+30 (150)")
  imgui.SameLine(200)
  imgui.TextColoredRGB("HP: {ff0019}+30")
  if imgui.Checkbox(u8("Уха из форели"), options.trout_fish_soup) then
    cfg.dishes["Уха из форели"].enabled = options.trout_fish_soup.v
    saveCFG()
  end
  imgui.SameLine()
  ShowHelpMarker("Ингредиенты (в наличии / нужно)\nРадужная форель: {6AB1FF}" .. data.ingredients.fish["Радужная форель"] .. " / 3")
  imgui.SameLine(200)
  imgui.TextColoredRGB("{6AB1FF}" .. data.ingredients.inventory["Уха из форели"])

  imgui.NewLine()

  imgui.TextColoredRGB("Скилл: {6AB1FF}3500")
  imgui.SameLine(100)
  imgui.TextColoredRGB("S: {0e8ce6}+35 (150)")
  imgui.SameLine(200)
  imgui.TextColoredRGB("HP: {ff0019}+35")
  if imgui.Checkbox(u8("Уха из щуки"), options.pike_fish_soup) then
    cfg.dishes["Уха из щуки"].enabled = options.pike_fish_soup.v
    saveCFG()
  end
  imgui.SameLine()
  ShowHelpMarker("Ингредиенты (в наличии / нужно)\nЩука: {6AB1FF}" .. data.ingredients.fish["Щука"] .. " / 3")
  imgui.SameLine(200)
  imgui.TextColoredRGB("{6AB1FF}" .. data.ingredients.inventory["Уха из щуки"])

  imgui.NewLine()

  imgui.TextColoredRGB("Скилл: {6AB1FF}4000")
  imgui.SameLine(100)
  imgui.TextColoredRGB("S: {0e8ce6}+40 (150)")
  imgui.SameLine(200)
  imgui.TextColoredRGB("HP: {ff0019}+40")
  if imgui.Checkbox(u8("Рыбная похлебка"), options.fish_chowder) then
    cfg.dishes["Рыбная похлебка"].enabled = options.fish_chowder.v
    saveCFG()
  end
  imgui.SameLine()
  ShowHelpMarker("Ингредиенты (в наличии / нужно)\nЛосось: {6AB1FF}" .. data.ingredients.fish["Лосось"] .. " / 3")
  imgui.SameLine(200)
  imgui.TextColoredRGB("{6AB1FF}" .. data.ingredients.inventory["Рыбная похлебка"])

  imgui.NewLine()

  imgui.TextColoredRGB("Скилл: {6AB1FF}5000")
  imgui.SameLine(100)
  imgui.TextColoredRGB("S: {0e8ce6}+50 (150)")
  imgui.SameLine(200)
  imgui.TextColoredRGB("HP: {ff0019}+50")
  if imgui.Checkbox(u8("Запечённый карп"), options.baked_carp) then
    cfg.dishes["Запечённый карп"].enabled = options.baked_carp.v
    saveCFG()
  end
  imgui.SameLine()
  ShowHelpMarker("Ингредиенты (в наличии / нужно)\nКарп: {6AB1FF}" .. data.ingredients.fish["Карп"] .. " / 4")
  imgui.SameLine(200)
  imgui.TextColoredRGB("{6AB1FF}" .. data.ingredients.inventory["Запечённый карп"])

  imgui.NewLine()

  imgui.TextColoredRGB("Скилл: {6AB1FF}6500")
  imgui.SameLine(100)
  imgui.TextColoredRGB("S: {0e8ce6}+65 (150)")
  imgui.SameLine(200)
  imgui.TextColoredRGB("HP: {ff0019}+65")
  if imgui.Checkbox(u8("Жареный кальмар"), options.fried_squid) then
    cfg.dishes["Жареный кальмар"].enabled = options.fried_squid.v
    saveCFG()
  end
  imgui.SameLine()
  ShowHelpMarker("Ингредиенты (в наличии / нужно)\nКальмар: {6AB1FF}" .. data.ingredients.fish["Кальмар"] .. " / 2")
  imgui.SameLine(200)
  imgui.TextColoredRGB("{6AB1FF}" .. data.ingredients.inventory["Жареный кальмар"])

  if imgui.Checkbox(u8("Рыбные тако"), options.fish_tacos) then
    cfg.dishes["Рыбные тако"].enabled = options.fish_tacos.v
    saveCFG()
  end
  imgui.SameLine()
  ShowHelpMarker("Ингредиенты (в наличии / нужно)\nТунец: {6AB1FF}" .. data.ingredients.fish["Тунец"] .. " / 3")
  imgui.SameLine(200)
  imgui.TextColoredRGB("{6AB1FF}" .. data.ingredients.inventory["Рыбные тако"])

  imgui.NewLine()

  imgui.TextColoredRGB("Скилл: {6AB1FF}8000")
  imgui.SameLine(100)
  imgui.TextColoredRGB("S: {0e8ce6}+80 (150)")
  imgui.SameLine(200)
  imgui.TextColoredRGB("HP: {ff0019}+80")
  if imgui.Checkbox(u8("Морской пенный пудинг"), options.sea_foam_pudding) then
    cfg.dishes["Морской пенный пудинг"].enabled = options.sea_foam_pudding.v
    saveCFG()
  end
  imgui.SameLine()
  ShowHelpMarker("Ингредиенты (в наличии / нужно)\nМелкая камбала: {6AB1FF}" .. data.ingredients.fish["Мелкая камбала"] .. " / 4")
  imgui.SameLine(200)
  imgui.TextColoredRGB("{6AB1FF}" .. data.ingredients.inventory["Морской пенный пудинг"])

  imgui.NewLine()

  imgui.TextColoredRGB("Скилл: {6AB1FF}10000")
  imgui.SameLine(100)
  imgui.TextColoredRGB("S: {0e8ce6}+100 (150)")
  imgui.SameLine(200)
  imgui.TextColoredRGB("HP: {ff0019}+100")
  if imgui.Checkbox(u8("Жареная рыба-еж"), options.fried_porcupinefish) then
    cfg.dishes["Жареная рыба-еж"].enabled = options.fried_porcupinefish.v
    saveCFG()
  end
  imgui.SameLine()
  ShowHelpMarker("Ингредиенты (в наличии / нужно)\nРыба-еж: {6AB1FF}" .. data.ingredients.fish["Рыба-еж"] .. " / 1")
  imgui.SameLine(200)
  imgui.TextColoredRGB("{6AB1FF}" .. data.ingredients.inventory["Жареная рыба-еж"])
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
function toggleScriptActivation()
  cfg.settings.enabled = not cfg.settings.enabled
  if isCooking then stopCooking() end
  saveCFG()
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
  if isUpdatingData and text:find(" Ваш навык приготовление еды: {FFFFFF}%d+/10000") then
    data.skill = tonumber(text:match(" Ваш навык приготовление еды: {FFFFFF}(%d+)/10000"))
    commandStates["/kitchen skill"] = nil
    sendCommand("/inventory")
    return false
  end
	if cfg.settings.enabled and isCooking then
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
end

function ev.onSendChat(text)
	antiflood = os.clock() * 1000
end

function ev.onSendCommand(cmd)
	antiflood = os.clock() * 1000
end

function ev.onShowDialog(id, style, title, btn1, btn2, text)
  if isUpdatingData or window.v then
    if style == 4 and title == "Карманы" then
      commandStates["/inventory"] = nil
      local remaining = {}
      for name in pairs(data.ingredients.inventory) do
        remaining[name] = true
      end
      for line in text:gmatch("[^\n]+") do
        local raw_text = escape_string(line)
        local name, amount = raw_text:match("%[%d+%] (.+)\\t(%d+) / %d+")
        if data.ingredients.inventory[name] and amount then
          data.ingredients.inventory[name] = tonumber(amount)
          remaining[name] = nil
        end
      end
      for name in pairs(remaining) do
        data.ingredients.inventory[name] = 0
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

  if cfg.settings.enabled and isCooking then
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
          if cfg.dishes[name].enabled then
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
end

function onWindowMessage(m, p)
  if p == VK_ESCAPE and window.v then
    consumeWindowMessage()
    window.v = false
  end
end

function onScriptTerminate()
  stopCooking()
end
