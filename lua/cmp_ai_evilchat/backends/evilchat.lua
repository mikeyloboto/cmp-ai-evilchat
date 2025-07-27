local requests = require('cmp_ai_evilchat.requests')

EvilChat = requests:new(nil)
BASE_URL = 'http://localhost:1234/v1/chat/completions'

function EvilChat:new(o, params)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  self.params = vim.tbl_deep_extend('keep', params or {}, {
    model = 'gpt-3.5-turbo',
    temperature = 0.1,
    n = 1,
  })

  self.api_key = 'NONE'
  self.headers = {}
  return o
end

function EvilChat:complete(lines_before, lines_after, cb)
  local data = {
    messages = {
      {
        role = 'system',
        content = [=[You are a coding companion.
You need to suggest code for the language ]=] .. vim.o.filetype .. [=[
Given some code prefix and suffix for context, output code which should follow the prefix code.
You should only output valid code in the language ]=] .. vim.o.filetype .. [=[
. to clearly define a code block, including white space, we will wrap the code block
with tags.
Make sure to respect the white space and indentation rules of the language.
Do not output anything in plain language, make sure you only use the relevant programming language verbatim.
For example, consider the following request:
<begin_code_prefix>def print_hello():<end_code_prefix><begin_code_suffix>\n    return<end_code_suffix><begin_code_middle>
Your answer should be:

    print("Hello")
]=],
      },
      -- <end_code_middle>
      {
        role = 'user',
        content = '<begin_code_prefix>' .. lines_before .. '<end_code_prefix>' .. '<begin_code_suffix>' .. lines_after .. '<end_code_suffix><begin_code_middle>',
      },
    },
  }
  data = vim.tbl_deep_extend('keep', data, self.params)
  self:Get(BASE_URL, self.headers, data, function(answer)
    local new_data = {}
    if answer.choices then
      for _, response in ipairs(answer.choices) do
        local entry = response.message.content:gsub('<end_code_middle>', '')
        entry = entry:gsub('```', '')
        table.insert(new_data, entry)
      end
    end
    cb(new_data)
  end)
end

function EvilChat:test()
  self:complete('def factorial(n)\n    if', '    return ans\n', function(data)
    dump(data)
  end)
end

return EvilChat
