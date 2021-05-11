
local api = vim.api

local dprint = require("gitsigns.debug").dprint

local M = {}

local GitSignHl = {}









local hls = {
   GitSignsAdd = { 'GitGutterAdd', 'SignifySignAdd', 'DiffAdd' },
   GitSignsChange = { 'GitGutterChange', 'SignifySignChange', 'DiffChange' },
   GitSignsDelete = { 'GitGutterDelete', 'SignifySignDelete', 'DiffDelete' },

   GitSignsAddSec = { 'GitGutterAdd', 'SignifySignAdd', 'DiffAdd' },
   GitSignsChangeSec = { 'GitGutterChange', 'SignifySignChange', 'DiffChange' },
   GitSignsDeleteSec = { 'GitGutterDelete', 'SignifySignDelete', 'DiffDelete' },

   GitSignsCurrentLineBlame = { 'NonText' },
}

local function is_hl_set(hl_name)

   local exists, hl = pcall(api.nvim_get_hl_by_name, hl_name, true)
   local color = hl.foreground or hl.background
   return exists and color ~= nil
end

local function hl_create0(to, from, reverse)
   if is_hl_set(to) then
      return
   end

   if not reverse then
      vim.cmd(('highlight link %s %s'):format(to, from))
      return
   end

   local exists, hl = pcall(api.nvim_get_hl_by_name, from, true)
   if exists then
      local bg = hl.background and ('guibg=#%06x'):format(hl.background) or ''
      local fg = hl.foreground and ('guifg=#%06x'):format(hl.foreground) or ''
      local rv = reverse and 'gui=reverse' or ''
      vim.cmd(table.concat({ 'highlight', to, fg, bg, rv }, ' '))
   end
end



local hl_create = vim.schedule_wrap(hl_create0)

local stdHl = {
   'DiffAdd',
   'DiffChange',
   'DiffDelete',
}

local function isStdHl(hl)
   return vim.tbl_contains(stdHl, hl)
end

local function isGitSignHl(hl)
   return hls[hl] ~= nil
end



function M.setup_highlight(hl_name)
   if not isGitSignHl(hl_name) then
      return
   end

   if is_hl_set(hl_name) then

      return
   end

   for _, d in ipairs(hls[hl_name]) do
      if is_hl_set(d) then
         dprint(('Deriving %s from %s'):format(hl_name, d))
         hl_create(hl_name, d, isStdHl(d))
         return
      end
   end
end

function M.setup_other_highlight(hl, from_hl)
   local hl_pfx, hl_sfx = hl:sub(1, -3), hl:sub(-2, -1)
   if isGitSignHl(hl_pfx) and (hl_sfx == 'Ln' or hl_sfx == 'Nr') then
      dprint(('Deriving %s from %s'):format(hl, from_hl))
      hl_create(hl, from_hl, hl_sfx == 'Ln')
   end
end

return M
