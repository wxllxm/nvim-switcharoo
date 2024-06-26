local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values
local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
  error("This plugin requires nvim-telescope/telescope.nvim")
end

-- Error handling for required modules
if not pickers or not finders or not actions or not action_state or not conf then
  error("Failed to load Telescope modules")
end

local M = {}
local opts = {}

M.setup = function(user_opts)
  local default_opts = {
    directories = {
      { "Users", "/Users/" },
    },
  }

  opts = vim.tbl_deep_extend("keep", user_opts or {}, default_opts)

  if not opts.directories then
    print("Warning: opts.directories is not initialised!")
  end
end

M.cd = function()
  if not opts.directories then
    print("Error: Please run the setup function ()")
    return
  end

  pickers
      .new(opts, {
        prompt_title = "Folders",
        finder = finders.new_table({
          results = opts.directories,
          entry_maker = function(entry)
            return {
              value = entry[2],
              display = entry[1],
              ordinal = entry[1],
            }
          end,
        }),
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            vim.cmd("cd " .. selection.value)
            vim.cmd("Ex " .. selection.value)
          end)
          return true
        end,
      })
      :find()
end

local nvim_switcharoo = function()
  M.cd()
end

return telescope.register_extension({
  setup = M.setup,
  exports = {
    nvim_switcharoo = nvim_switcharoo,
  },
})
