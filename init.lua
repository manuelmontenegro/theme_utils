--- This module contains several utilities for selecting and managing themes.
--
-- It allows us to set a primary theme and an alternate theme, so we can toggle
-- them by means of the `toggle_theme` function, which can be assigned to a key binding.
--
-- This module also allows the user to interactively select a theme among all the installed ones,
-- and to cycle through all the installed themes via the `next_theme` and `previous_theme` functions.
--
-- @module theme_utils


local M = {}

--- Global theme environment.
--
-- This can be used to override the default settings of the current theme.
-- It will be passed as second paremeter of TextAdept's `view:set_theme` method.
--
-- Primary and alternate themes may further override the settings in this table.
-- `set_primary_theme` and `set_alternate_theme` for more details.
M.theme_env = {}


-- Directories containing themes
local THEME_DIRS = { _USERHOME .. '/themes', _HOME .. '/themes' }
-- Names and environments of primary and alternate themes
local primary_theme = { name = 'dark', env = {} }
local alternate_theme = { name = 'light', env = {} }

-- Cached list of available themes. It will be populated in the first call
-- to `load_themes_if_not_available`.
local themes = nil

-- Populates the `themes` variable with the list of themes available
-- at the directories specified in `THEME_DIRS`.
--
-- If `themes` already contains a list, this does nothing.
local function load_themes_if_not_available() 
  if themes ~= nil then return end
  themes = {}

  for _, theme_dir in ipairs(THEME_DIRS) do
    for file in lfs.dir(theme_dir) do
      local full_file = theme_dir .. "/" .. file
      if lfs.attributes(full_file, "mode") == "file" then
        if file:find('%.lua$') then
          themes[#themes + 1] = file:sub(1, file:len() - 4)
        end
      end
    end
  end
end

-- Function that merges two tables and returns a fresh one.
-- Fields of `table1` will be overriden by those of `table2`.
local function merge_tables(table1, table2)
  local result = {}
  for k, v in pairs(table1) do result[k] = v end
  for k, v in pairs(table2) do result[k] = v end
  return result
end

-- Calls `view:set_theme` with the name of the theme contained in the
-- field `buffer.current_theme`. It also applies the environments of the
-- primary and alternate theme, if any of them is the current one.
local function refresh_theme()
  local env_overrides = {}
  if buffer.current_theme == primary_theme.name or buffer.current_theme == nil then    
    env_overrides = primary_theme.env
  elseif buffer.current_theme == alternate_theme.name then
    env_overrides = alternate_theme.env
  end
  view:set_theme(buffer.current_theme, merge_tables(M.theme_env, env_overrides))
end

--- Toggles between primary and alternate themes in the current buffer.
-- If the current buffer contains a theme different from the primary and the
-- alternate theme, then the primary theme will be set.
function M.toggle_theme()
  if buffer.current_theme == primary_theme.name or buffer.current_theme == nil then
    buffer.current_theme = alternate_theme.name
  else
    buffer.current_theme = primary_theme.name
  end
  refresh_theme()
end

--- Returns a list of available themes.
function M.get_themes()
  load_themes_if_not_available()
  return themes
end

--- Sets the name and/or the environment of the primary theme.
--
-- @tparam string name Name of the primary theme
-- @tparam[opt] table env Environment specific to this theme. It may override the fields of `theme_env`.
function M.set_primary_theme(name, env)
  primary_theme.name = name
  primary_theme.env = env or {}
  refresh_theme()
end

--- Sets the name and/or the environment of the alternate theme.
--
-- @tparam string name Name of the alternate theme
-- @tparam[opt] table env Environment specific to this theme. It may override the fields of `theme_env`.
function M.set_alternate_theme(name, env)
  alternate_theme.name = name
  alternate_theme.env = env or {}
  refresh_theme()
end


--- Shows a dialog that allows the user to change the current theme.
function M.select_theme()
  load_themes_if_not_available()
  button, selected = ui.dialogs.filteredlist({
    title = 'Select theme',
    columns = {'Theme'},
    items = themes,
    button1 = 'OK',
    button2 = 'Cancel'
  })
  if button == 1 then
    buffer.current_theme = themes[selected]
    refresh_theme()
  end
end


-- It sets the next or previous theme, depending on the `offset` parameter.
-- If `offset` is 1, the next theme is selected.
-- If `offset` is -1, the previous theme is selected.
local function cycle_theme(offset)
  load_themes_if_not_available()
  
  local current_theme_name = buffer.current_theme or primary_theme.name
  
  local pos_theme = 1
  while pos_theme <= #themes and themes[pos_theme] ~= current_theme_name do
    pos_theme = pos_theme + 1
  end
  
  if pos_theme <= #themes then
    pos_theme = (pos_theme + offset - 1) % #themes + 1
    buffer.current_theme = themes[pos_theme]
    refresh_theme()
    ui.statusbar_text = 'Current theme: ' .. buffer.current_theme
  else
    ui.statusbar_text = 'Current theme not found in themes directory'
  end
end

--- It sets the next theme in the list of the currently installed themes.
function M.next_theme()
  cycle_theme(1)
end

--- It sets the previous theme in the list of the currently installed themes.
function M.previous_theme()
  cycle_theme(-1)
end

local menu_view = textadept.menu.menubar[_L['View']]

local theme_menu = {
  title = '_Themes',
  {'Toggle _default/alternate', M.toggle_theme},
  {'_Select theme',             M.select_theme},
  {'_Next theme',               M.next_theme},
  {'_Previous theme',           M.previous_theme}
}
menu_view[#menu_view + 1] = {'', nil}
menu_view[#menu_view + 1] = theme_menu

return M
