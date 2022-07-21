local lrequire = require -- Remove before squishing
require = function(modname) return lrequire('content/cars/ng_porsche_992_cup/extension/Display/' .. modname) end -- Remove before squishing

-- Import classes
Utils = require('modules/utils')
-- G = require('modules/globals')

math.randomseed(os.time())
math.random()
math.random()
math.random()
math.random()
math.random()

-- reimplementing method because of other font
Utils.displayText = function(text, posx, posy, size, font, color, align)
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

-- UPDATE LOOP--
---@diagnostic disable-next-line: lowercase-global
function update(dt)
  if car.isInPitlane then
    display.image({image = 'Display/texRL.zip::Page_Speed.dds', pos = vec2(0, 0), size = vec2(512, 128)})
    pcall(function()
      Utils.displayText(Utils.dec(car.speedKmh > 0.1 and car.speedKmh or 0, 2, ','), 350, -8, 2.3, 'bdp_fox', {1, 1, 1},
                        'right')
    end)
  else
    display.image({image = 'Display/texRL.zip::Page_Laptime.dds', pos = vec2(0, 0), size = vec2(512, 128)})
    pcall(function()
      Utils.displayText(Utils.timeformat(car.lapTimeMs, {':', '.'}), 350, -8, 2.3, 'bdp_fox', {1, 1, 1}, 'right')
    end)
    Utils.displayText(car.lapCount, 460, 55, 1, 'bdp_fox', {1, 1, 1}, 'center')
  end

end
