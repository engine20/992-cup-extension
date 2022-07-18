local delay = {
  clients = {},
  ---updates all entrys
  ---@param self any
  update = function(self)
    local tempTable = Utils.shallow_copy(self.clients)
    for k, e in pairs(self.clients) do
      if e.active then
        e:check(G.time)
      else
        table.remove(tempTable, k)
      end
      self.clients = tempTable
    end
  end,
  startTime = 0,
  duration = 0,
  active = true,
  callback = function() end,
  ---Calls the given function after specified delay
  ---@param self any
  ---@param duration number
  ---@param callback fun():nil
  ---@return integer
  new = function(self, duration, callback)
    local o = {startTime = G.time, duration = duration, callback = callback}
    setmetatable(o, self)
    self.__index = self;
    table.insert(self.clients, o);
    return #self.clients;
  end,
  check = function(self)
    if (self.startTime + self.duration < G.time) then
      self.active = false
      self.callback()
    end
  end
}

return delay
