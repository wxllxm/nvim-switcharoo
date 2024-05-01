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
  -- Default options
  local default_opts = {
    dirs = {
      { "Users", "/Users/" },
    },
  }

  -- Merge default options with provided options
  opts = vim.tbl_deep_extend("keep", user_opts or {}, default_opts)

  -- Ensure opts.dirs is initialized
  if not opts.dirs then
    print("Warning: opts.dirs is not initialised!")
  end
end

M.cd = function()
  -- Ensure opts.dirs is initialized
  if not opts.dirs then
    print("Error: Please run the setup function ()")
    return
  end

  -- Create Telescope picker
  pickers
      .new(opts, {
        prompt_title = "Folders",
        finder = finders.new_table({
          results = opts.dirs,
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
            -- Change directory based on the selected entry
            vim.cmd("Ex " .. selection.value)
          end)
          return true
        end,
      })
      :find()
end

return M