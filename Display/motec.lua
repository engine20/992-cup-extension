string.extend = function(input, length, char)
  local v = input
  if length == 0 then
    return input
  else
    for i = 1, length do v = v .. (char or string.sub(input, -1, -1)) end
  end
  return v
end

math.randomseed(os.time())
math.random()
math.random()
math.random()
math.random()
math.random()

math.clamp = function(input, l_threshold, h_threshold)
  return math.min(math.max(input, l_threshold or 0), h_threshold or 1)
end

local twodigits = function(input)
  return tonumber(input) < 10 and '0' .. tonumber(input) or (tonumber(input) >= 100 and '99' or tonumber(input))
end

local dec = function(input, decimals, seperator) -- have fun reading
  return
    string.len(math.floor(input * 10 ^ decimals) / 10 ^ decimals) - string.len(math.floor(input)) < decimals + 1 and
      string.gsub(math.floor(input * 10 ^ decimals) / 10 ^ decimals, '%.', seperator or '.') ..
      (string.len(math.floor(input * 10 ^ decimals) / 10 ^ decimals) - string.len(math.floor(input)) ~= decimals and
        (seperator or '.') or '') .. string.extend('0', decimals - 1 -
                                                     (string.len(math.floor(input * 10 ^ decimals) / 10 ^ decimals) -
                                                       string.len(math.floor(input)))) or
      string.gsub(math.floor(input * 10 ^ decimals) / 10 ^ decimals, '%.', seperator or '.')
end

local timeformat = function(input, seperator, millis, nullonempty) -- same for this one
  return input ~= 0 and (((tonumber(string.sub(tostring(input), 1, -4)) or 0) > 59 and
           math.floor((tonumber(string.sub(tostring(input), 1, -4)) or 0) / 60) or 0) .. (seperator[1] or ':') ..
           twodigits((tonumber(string.sub(tostring(input), 1, -4)) or 0) -
                       ((tonumber(string.sub(tostring(input), 1, -4)) or 0) > 59 and
                         math.floor((tonumber(string.sub(tostring(input), 1, -4)) or 0) / 60) or 0) * 60) ..
           (seperator[2] or ':') .. string.sub(tostring(input), -3, (millis or 2) - 4)) or
           ((nullonempty and '00' or '--') .. (seperator[1] or ':') .. (nullonempty and '00' or '--') ..
             (seperator[2] or ':') ..
             (nullonempty and string.sub('000', 1, (millis or 2) - 4) or string.sub('---', 1, (millis or 2) - 4)))
end

local displayText = function(text, posx, posy, size, font, color, align)
  local lastx = posx

  local digitswidth = 22
  local symbolwidth = 19
  local alphabeticwidth = 32

  local alignmentoffset = (align == 'left' and 0 or
                            (select(2, string.gsub(text, '%d', '')) * digitswidth +
                              select(2, string.gsub(text, '%a', '')) * alphabeticwidth +
                              (string.len(text) - select(2, string.gsub(text, '%d', ''))) * 10) /
                            (align == 'center' and 2 or 1)) * size

  for i = 1, string.len(text) do
    local numeric = string.find(string.sub(text, i, i), '%d') and true or false
    local alphabetic = string.find(string.sub(text, i, i), '%a') and true or false

    display.text({
      text = string.sub(text, i, i),
      pos = vec2((numeric and lastx or
                   (alphabetic and lastx + (size ^ ((1 - size) / 8 + 1) * 10) - 5 or lastx + size ^
                     ((1 - size) / 8 + 0.6) * 10)) - alignmentoffset,
                 numeric and posy or (alphabetic and posy or posy + size * 1)),
      letter = vec2(numeric and 38 * size or (alphabetic and 55 * size or 29 / 1 * size),
                    numeric and 70 * size or (alphabetic and 84 * size or 112 / 1.65 * size)),
      color = rgbm(color[1], color[2], color[3], 1),
      font = font,
      width = 50,
      alignment = 0,
      spacing = -1
    })
    if numeric and string.find(string.sub(text, i + 1, i + 1), '%d') then
      lastx = lastx + size * digitswidth
    elseif alphabetic and string.find(string.sub(text, i + 1, i + 1), '%a') then
      lastx = lastx + size * alphabeticwidth
    else
      lastx = lastx + size * symbolwidth
    end
  end
end

local debugmessge = function(msg, desc) ac.setSystemMessage(msg, desc or math.random()) end

local firstrun = true
local timedelta = 0
-- UPDATE LOOP--
function update(dt)
  if car.isInPitlane then
    display.image({image = 'texRL/Page_Speed.dds', pos = vec2(0, 0), size = vec2(512, 128)})
    pcall(function()
      displayText(dec(car.speedKmh > 0.1 and car.speedKmh or 0, 2, ','), 350, -8, 2.3, 'bdp_fox', {1, 1, 1}, 'right')
    end)
  else
    display.image({image = 'texRL/Page_Laptime.dds', pos = vec2(0, 0), size = vec2(512, 128)})
    pcall(function() displayText(timeformat(car.lapTimeMs, {':', '.'}), 350, -8, 2.3, 'bdp_fox', {1, 1, 1}, 'right') end)
    displayText(car.lapCount, 460, 55, 1, 'bdp_fox', {1, 1, 1}, 'center')
  end

  firstrun = false
end
