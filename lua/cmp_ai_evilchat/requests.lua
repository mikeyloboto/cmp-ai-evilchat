local job = require('plenary.job')
local conf = require('cmp_ai_evilchat.config')
Service = {}

function Service:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Service:complete(
  lines_before, ---@diagnostic disable-line
  lines_after, ---@diagnostic disable-line
  _
) ---@diagnostic disable-line
  error('Not Implemented!')
end

function Service:json_decode(data)
  local status, result = pcall(vim.fn.json_decode, data)
  if status then
    return result
  else
    return nil, result
  end
end

function Service:Get(url, headers, data, cb)
  headers = vim.tbl_extend('force', {}, headers or {})
  headers[#headers + 1] = 'Content-Type: application/json'

  local tmpfname = os.tmpname()
  local f = io.open(tmpfname, 'w+')
  if f == nil then
    vim.notify('Cannot open temporary message file: ' .. tmpfname, vim.log.levels.ERROR)
    return
  end
  f:write(vim.fn.json_encode(data))
  f:close()

  local args = { url, '-d', '@' .. tmpfname }

  local timeout_seconds = conf:get('max_timeout_seconds')
  if tonumber(timeout_seconds) ~= nil then
    args[#args + 1] = '--max-time'
    args[#args + 1] = tonumber(timeout_seconds)
  elseif timeout_seconds ~= nil then
    vim.notify('cmp-ai: your max_timeout_seconds config is not a number', vim.log.levels.WARN)
  end

  for _, h in ipairs(headers) do
    args[#args + 1] = '-H'
    args[#args + 1] = h
  end

  job
    :new({
      command = 'curl',
      args = args,
      on_exit = vim.schedule_wrap(function(response, exit_code)
        os.remove(tmpfname)
        if exit_code ~= 0 then
          if conf:get('log_errors') then
            vim.notify('An Error Occurred ...', vim.log.levels.ERROR)
          end
          cb({ { error = 'ERROR: API Error' } })
        end

        local result = table.concat(response:result(), '\n')
        local json = self:json_decode(result)
        if type(self.params.raw_response_cb) == 'function' then
          self.params.raw_response_cb(json)
        end
        if json == nil then
          cb({ { error = 'No Response.' } })
        else
          cb(json)
        end
      end),
    })
    :start()
end

return Service
