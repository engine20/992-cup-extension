local lrequire = require -- Remove before squishing
require = function(modname) return lrequire('content/cars/ng_porsche_992_cup/extension/Display/' .. modname) end -- Remove before squishing

-- Import classes
Utils = require('modules/utils')
G = require('modules/globals')
local popup = require('modules/popup')
local eventListener = require('modules/eventListener')
local delay = require('modules/delay')
--

_CFG = {maxpopups = 10}
local carstate = {
  page = 0, -- defines the first page upon loading
  maxstintfuel = 0,
  fuelPerLap = 0
}
INF = 1e308
Legacy = ac.getPatchVersionCode() <= 1709
if Legacy then ac.log('Running Legacy Mode!') end
---@diagnostic disable-next-line: deprecated
local simObject = Legacy and ac.getSimState() or ac.getSim();

ac.debug('page', carstate.page)
ac.debug('Popups', 0)

math.randomseed(os.time())
---@diagnostic disable-next-line: discard-returns
for i = 1, 4 do math.random() end

eventListener:new(function() return car.extraA; end, function(diff)
  if diff == 1 or Legacy then
    carstate.page = 1 + carstate.page;
    if carstate.page > 2 then carstate.page = 0 end
    ac.debug('page', carstate.page)
  end
end)

eventListener:new(function() return simObject.raceSessionType; end, function(_, newVal)
  if (newVal == 2) then
    carstate.page = 1;
    return;
  end
  carstate.page = 0;
end)

eventListener:new(function() return car.fuel; end, function(diff)
  pcall(function()
    if diff > 0 or (Legacy and (car.isInPitlane and car.speedKmh < 1) or car.isInPit) then
      carstate.maxstintfuel = car.fuel;
    end
  end)
end)

eventListener:new(function() return car.lapCount; end,
                  function(_, newVal) carstate.fuelPerLap = (carstate.maxstintfuel - car.fuel) / newVal; end)
-- #region
-- Popups

eventListener:new(function() return car.brakeBias end, function()
  popup:new(2, function()
    display.image({image = 'Display/texDisp.zip::Popup_BrakeBias.png', pos = vec2(924, 125), size = vec2(91, 308)})
  end)
end)

-- #endregion

---@diagnostic disable-next-line: lowercase-global
function update(dt)
  G.time = G.time + dt;
  G.run = G.run + 1;
  eventListener:update();
  delay:update();
  ---@diagnostic disable-next-line: deprecated
  simObject = Legacy and ac.getSimState() or ac.getSim();

  if G.firstrun then carstate.maxstintfuel = car.fuel; end

  if carstate.page == 0 then
    display.image({image = 'Display/texDisp.zip::R1.dds', pos = vec2(0, 0), size = vec2(1024, 512)})
  elseif carstate.page == 1 then
    display.image({image = 'Display/texDisp.zip::Q.dds', pos = vec2(0, 0), size = vec2(1024, 512)})
  elseif carstate.page == 2 then
    display.image({image = 'Display/texDisp.zip::R2.dds', pos = vec2(0, 0), size = vec2(1024, 512)})
  end

  if car.isInPitlane then
    display.image({image = 'Display/texDisp.zip::PitSpeed.dds', pos = vec2(0, 0), size = vec2(1024, 512)})
    if car.speedKmh > 81 then
      display.image({image = 'Display/texDisp.zip::PitSpeed_Over.dds', pos = vec2(0, 0), size = vec2(1024, 512)})
    end
    Utils.displayText(car.gear > 0 and car.gear or (car.gear == 0 and 'N' or 'R'), 510, 153, 3.7, '488', {0, 0, 0},
                      'center')
    Utils.displayText(math.floor(car.speedKmh), 780, 170, 2.7, '488', {0, 0, 0}, 'center')
  else
    if carstate.page ~= 1 then
      Utils.displayText(Utils.timeformat(car.lapTimeMs, {':', '.'}, 2, true), 778, 171, 1.2, '488', {1, 1, 1}, 'center')
      Utils.displayText(Utils.timeformat(car.estimatedLapTimeMs, {':', '.'}, 2, true), 851, 271, 0.9, '488', {1, 1, 1},
                        'center')
      if car.performanceMeter < 0 then
        display.image({image = 'Display/texDisp.zip::Popup_Delta.png', pos = vec2(630, 251), size = vec2(144, 70)})
      end
      Utils.displayText((car.performanceMeter == 0 and '  ' or (car.performanceMeter >= 0 and '+ ' or '- ')) ..
                          Utils.dec(math.abs(math.clampN(car.performanceMeter, -99, 99)), 2, '.'), 691, 271, 0.9, '488',
                        {1, 1, 1}, 'center')
      if carstate.page == 0 then
        Utils.displayText(Utils.dec(car.oilTemperature, 1, '.'), 328, 137, 0.9, '488', {1, 1, 1}, 'center')
        Utils.displayText(Utils.dec(car.oilPressure, 1, '.'), 328, 184, 0.9, '488', {1, 1, 1}, 'center')
        Utils.displayText(Utils.dec(car.waterTemperature, 1, '.'), 328, 231, 0.9, '488', {1, 1, 1}, 'center')
        Utils.displayText(Utils.dec((car.waterTemperature - 20) ^ 0.3 * car.oilPressure / 5, 1, '.'), 328, 278, 0.9,
                          '488', {1, 1, 1}, 'center') -- Water Pressure
      else
        Utils.displayText(Utils.dec(carstate.maxstintfuel - car.fuel, 1, ','), 328, 137, 0.9, '488', {1, 1, 1}, 'center')
        Utils.displayText(Utils.dec(carstate.fuelPerLap, 1, ','), 328, 184, 0.9, '488', {1, 1, 1}, 'center')
        Utils.displayText('80.00', 328, 231, 0.9, '488', {1, 1, 1}, 'center')
        Utils.displayText(Utils.dec(car.fuel, 1, '.'), 328, 278, 0.9, '488', {1, 1, 1}, 'center')
      end
    else
      Utils.displayText(Utils.timeformat(car.lapTimeMs, {':', '.'}, 2, true), 263, 223, 1.6, '488', {1, 1, 1}, 'center')
      Utils.displayText((car.performanceMeter == 0 and '  ' or (car.performanceMeter >= 0 and '+ ' or '- ')) ..
                          Utils.dec(math.abs(math.clampN(car.performanceMeter, -99, 99)), 3, '.'), 751, 195, 1.4, '488',
                        {1, 1, 1}, 'center')
      display.image({image = 'Display/texDisp.zip::Overlay.png', pos = vec2(634, 253), size = vec2(281, 65)})
      display.rect({
        pos = vec2(775, 254),
        size = vec2(140 * math.clampN(car.performanceMeter / 0.9, -1, 1), 65),
        color = rgb(1, 1, 1)
      })
    end
    Utils.displayText(car.gear > 0 and car.gear or (car.gear == 0 and 'N' or 'R'), 512, 153, 4.0, '488', {1, 1, 1},
                      'center')
  end

  if (simObject.rainWetness > 0.1 or simObject.rainIntensity > 0.4) then
    display.image({image = 'Display/texDisp.zip::Popup_Wet.png', pos = vec2(924, 65), size = vec2(93, 58)})
  end

  if car.fuel < 7 then
    display.image({image = 'Display/texDisp.zip::Popup_FuelAlarm.png', pos = vec2(629, 223), size = vec2(291, 140)})
  end

  if car.headlightsActive then
    if car.lowBeams then
      display.image({image = 'Display/texDisp.zip::Popup_Lights.png', pos = vec2(141, 82), size = vec2(128 / 3, 86 / 3)})
    else
      display.image({image = 'Display/texDisp.zip::Popup_Beams.png', pos = vec2(141, 82), size = vec2(128 / 3, 86 / 3)})
    end
  end

  Utils.displayText(math.floor(car.speedKmh), 512, 74, 1.15, '488', {1, 1, 1}, 'center')
  Utils.displayText(Utils.dec(math.floor((car.brakeBias * 100 + 0.1) * 2) / 2, 1, ','), 892, 370, 0.8, '488', {1, 1, 1},
                    'right')
  Utils.displayText(car.lapCount, 766, 79, 0.8, '488', {1, 1, 1}, 'center')
  Utils.displayText(car.absMode, 95, 136, 0.7, '488', {1, 1, 1}, 'center')
  Utils.displayText(10, 95, 186, 0.7, '488', {1, 1, 1}, 'center')
  Utils.displayText(2, 95, 235, 0.7, '488', {1, 1, 1}, 'center')
  Utils.displayText(8, 95, 284, 0.7, '488', {1, 1, 1}, 'center')

  Utils.displayText(Utils.dec(car.wheels[0].tyrePressure, 2, ','), 458, 357, 1.0, '488', {1, 1, 1}, 'center')
  Utils.displayText(Utils.dec(car.wheels[1].tyrePressure, 2, ','), 570, 357, 1.0, '488', {1, 1, 1}, 'center')
  Utils.displayText(Utils.dec(car.wheels[2].tyrePressure, 2, ','), 458, 400, 1.0, '488', {1, 1, 1}, 'center')
  Utils.displayText(Utils.dec(car.wheels[3].tyrePressure, 2, ','), 570, 400, 1.0, '488', {1, 1, 1}, 'center')

  popup:update();
  G.firstrun = false;
end
