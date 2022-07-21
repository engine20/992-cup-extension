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
  page = 0 -- defines the first page upon loading
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
  else
    if car.performanceMeter < 0 then
      display.image({image = 'Display/texDisp.zip::Popup_Delta.png', pos = vec2(630, 251), size = vec2(144, 70)})
    end
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

  popup:update();
  G.firstrun = false;
end
