local lcdFont = "veyron"
local smallFontSize = vec2(130, 110)
local bigFontSize = vec2(320, 300)
local midFontSize = vec2(160, 160)
local carSpeed = 0
local carSpeedDelay = 0.5

local screenRes = 1024
local texturePath = "LCD_sRGB.png"

local lineCoords = {Start = "76, 837", Size = "861, 51"}
local kmhCoords = {Start = "653, 653", Size = "291, 167"}
local defaultGearCoords = {Start = "173, 890", Size = "513, 132"}
local gears = {
  p = {pos = {Start = "184.6, 897"}, coords = {Start = "104.7, 611", Size = "89.8, 115.6"}},
  r = {pos = {Start = "276, 897"}, coords = {Start = "9.9, 491.1", Size = "89.8, 115.6"}},
  r2 = {pos = {Start = "287.8, 908.5"}, coords = {Start = "287.8, 908.5", Size = "67, 93.2"}},
  n = {pos = {Start = "367, 897"}, coords = {Start = "105, 491", Size = "89.8, 115.6"}},
  n2 = {pos = {Start = "378.8, 908.5"}, coords = {Start = "378.8, 908.5", Size = "66.5, 92.6"}},
  d = {pos = {Start = "458.5, 897"}, coords = {Start = "199.7, 611", Size = "89.8, 115.6"}},
  s = {pos = {Start = "549, 897"}, coords = {Start = "9.8, 611", Size = "89.8, 115.6"}},
}

local function toBool(int)
  if int == 0 then
    return false
  elseif int == 1 then
    return true
  end
end

local assistsFile = ac.getFolder(ac.FolderID.Cfg) .. "\\assists.ini"
local ini = ac.INIConfig.load(assistsFile)
local autoShifter = ini:get("AUTO_SHIFTER", "ACTIVE", 0, 0)
local isACAuto = toBool(autoShifter)

local function parseCoords(str)
  local x, y = str:match("([%d%.]+), ([%d%.]+)")
  return { x = tonumber(x), y = tonumber(y) }
end

local function toUvStart(obj)
  local startCoords = parseCoords(obj.Start)
  return vec2(startCoords.x/screenRes, startCoords.y/screenRes)
end

local function toUvEnd(obj)
  local startCoords = parseCoords(obj.Start)
  local sizeCoords = parseCoords(obj.Size)
  return vec2((startCoords.x + sizeCoords.x)/screenRes, (startCoords.y + sizeCoords.y)/screenRes)
end

local function toSize(obj)
  local sizeCoords = parseCoords(obj.Size)
  return vec2(sizeCoords.x, sizeCoords.y)
end

local function toPos(obj)
  local posCoords = parseCoords(obj.Start)
  return vec2(posCoords.x, posCoords.y)
end

local function toTextGear()
  return stringify(car.gear)
end

local function drawGear(gear, x, y)
  display.rect({ pos = toPos(gear.pos), size = toSize(gear.coords), color = rgbm.colors.black })
  display.image{ image = texturePath, pos = toPos(gear.pos), size = toSize(gear.coords), uvStart = toUvStart(gear.coords), uvEnd = toUvEnd(gear.coords) }

  if car.gear == 0 then -- N
    display.image{ image = texturePath, pos = vec2(x+94 , y-1.5), size = toSize(gears.n2.coords), uvStart = toUvStart(gears.n2.coords), uvEnd = toUvEnd(gears.n2.coords) }
  elseif car.gear == -1 then -- R
    display.image{ image = texturePath, pos = vec2(x+94 , y-1.5), size = toSize(gears.r2.coords), uvStart = toUvStart(gears.r2.coords), uvEnd = toUvEnd(gears.r2.coords) }
  else
    display.text({
      pos = vec2(x, y),
      letter = smallFontSize,
      text = toTextGear(),
      spacing = -30,
      alignment = 1,
      width = 210,
      font = lcdFont,
      color = rgbm.colors.white })
  end
end

local function getGear()
  if car.handbrake > 0 then -- P
    return gears.p
  elseif car.gear == 0 then -- N
    return gears.n
  elseif car.gear == -1 then -- R
    return gears.r
  else
    if isACAuto then -- D
      return gears.d
    else -- S
      return gears.s
    end
  end
end

local function drawHUD()
  display.rect({ pos = vec2(0,0), size = vec2(screenRes, screenRes), color = rgbm.colors.black })
  display.image { image = texturePath, pos = toPos(lineCoords), size = toSize(lineCoords), uvStart = toUvStart(lineCoords), uvEnd = toUvEnd(lineCoords) }
  display.image { image = texturePath, pos = toPos(kmhCoords), size = toSize(kmhCoords), uvStart = toUvStart(kmhCoords), uvEnd = toUvEnd(kmhCoords) }
  display.image { image = texturePath, pos = toPos(defaultGearCoords), size = toSize(defaultGearCoords), uvStart = toUvStart(defaultGearCoords), uvEnd = toUvEnd(defaultGearCoords) }
end

local function drawSpeed(x, y, delay)
  if delay then
    setInterval(
      function ()
          carSpeed = math.round(car.speedKmh)
      end, carSpeedDelay, "key")
    clearInterval("key")

    display.text({
      pos = vec2(x, y),
      letter = midFontSize,
      text =  stringify(carSpeed),
      spacing = -60,
      alignment = 0.5,
      width = 750,
      font = lcdFont,
      color = rgbm.colors.white
    })
  else
    display.text({
      pos = vec2(x, y),
      letter = bigFontSize,
      text = stringify(math.round(car.speedKmh)),
      spacing = -120,
      alignment = 1,
      width = 750,
      font = lcdFont,
      color = rgbm.colors.white
    })
  end
end

local function drawOdometer(x, y)
    display.text({
      text = math.floor(car.distanceDrivenTotalKm), --string formatting to pad 0's
      pos = vec2(x, y),
      letter = midFontSize,
      font = lcdFont,
      alignment = 0.5,
      width = 750,
      color = rgbm.colors.white,
      spacing = -60,
    })
end

function script.update(dt)
  drawHUD()
  drawGear(getGear(), 680,910)
  drawSpeed(160, 265, true)
  drawSpeed(0, 550, false)
  drawOdometer(160,50)
end