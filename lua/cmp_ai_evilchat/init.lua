local cmp = require('cmp')
local source = require('cmp_ai_evilchat.source')

local M = {}

M.setup = function()
  M.ai_source = source:new()
  cmp.register_source('cmp_ai_evilchat', M.ai_source)
end

return M
