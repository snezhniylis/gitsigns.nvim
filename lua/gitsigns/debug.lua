local M = {
   debug_mode = false,
   messages = {},
}

function M.dprint(msg, bufnr, caller)
   if not M.debug_mode then
      return
   end
   local name = caller or debug.getinfo(2, 'n').name or ''
   local msg2
   if bufnr then
      msg2 = string.format('%s(%s): %s', name, bufnr, msg)
   else
      msg2 = string.format('%s: %s', name, msg)
   end
   table.insert(M.messages, msg2)
end

function M.eprint(msg)

   if vim.in_fast_event() then
      vim.schedule(function()
         print('error: ' .. msg)
      end)
   else
      print('error: ' .. msg)
   end
end

function M.add_debug_functions(cache)
   local R = {}
   R.dump_cache = function()
      vim.api.nvim_echo({ { vim.inspect(cache, {
   process = function(raw_item, path)
      if path[#path] == vim.inspect.METATABLE then
         return nil
      elseif type(raw_item) == "function" then
         return nil
      elseif type(raw_item) == "table" then
         local key = path[#path]
         if key == 'compare_text' then
            local item = raw_item
            return { length = #item, head = item[1] }
         elseif key == 'hunks' then
            local ret = {}
            for _, h in ipairs(raw_item) do
               local a = vim.deepcopy(h)
               a.added = nil
               a.removed = nil
               ret[#ret + 1] = a
            end
            return ret
         elseif key == 'pending_signs' then
            local keys = vim.tbl_keys(raw_item)
            local max = 100
            if #keys > max then
               keys.length = #keys
               for i = max, #keys do
                  keys[i] = nil
               end
               keys[max] = '...'
            end
            return keys
         end
      end
      return raw_item
   end,
}), }, }, false, {})
      return cache
   end

   R.debug_messages = function(noecho)
      if not noecho then
         for _, m in ipairs(M.messages) do
            vim.api.nvim_echo({ { m } }, false, {})
         end
      end
      return M.messages
   end

   R.clear_debug = function()
      M.messages = {}
   end

   return R
end

return M
