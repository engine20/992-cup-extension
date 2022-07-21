local drawRpmLed = function(index, color)
  if not color then
    if index < 4 then
      color = rgbm(0.1, 1, 0.1, 1)
    elseif index < 7 then
      color = rgbm(1, 1, 0.1, 1)
    else
      color = rgbm(1, 0.1, 0.1, 1)
    end
  end
  index = index - 1
  if index < 4 then
    display.rect({pos = vec2(index * 58.5 + 4, 0), size = vec2(55, 58), color = color})
  else
    display.rect({pos = vec2((index - 4) * 58.5 + 4, 68), size = vec2(55, 58), color = color})
  end
end

local drawSlipLed = function(index, color)
  if not color then color = rgbm(1, 1, 0.1, 1) end
  if index < 2 then
    display.rect({pos = vec2(4, index * 60 + 132), size = vec2(55, 58), color = color})
  else
    display.rect({pos = vec2(190, (index - 2) * 60 + 132), size = vec2(55, 58), color = color})
  end
end

local firstrun = true
local blinkseed = 0

function update(dt)
  local start_rpm = 7000
  local max_rpm = 8100
  if car.rpm > 8400 then
    blinkseed = blinkseed + dt
    if math.floor(blinkseed * 7) % 2 == 1 then for i = 1, 8 do drawRpmLed(i, rgbm(0.05, 0.05, 1, 1)) end end
  else
    for i = 0, math.clamp((car.rpm - start_rpm) / ((max_rpm - start_rpm) / 8), 0, 8) do drawRpmLed(i) end
  end
  for i = 0, 3 do if math.abs(car.wheels[i].slipRatio) > 0.3 then drawSlipLed(i) end end
  firstrun = false
end
