----
-- xunit.init
-- Entry point
----
local lazy = require("xunit.lazy")
local config = lazy.require("xunit.config")
local parser = require("xunit.parser")
local ui = require("xunit.ui")
local run = require("xunit.run")
local ctrl = require("xunit.controls")

local api = vim.api

local M = {}

local function setup_autocmd()
  local augr = api.nvim_create_augroup("xunit-test", { clear = true })
  api.nvim_create_autocmd("BufEnter", {
    group = augr,
    pattern = "*.cs",
    callback = function()
      local bufnr = api.nvim_get_current_buf()
      if parser.using_xunit(bufnr) and ui.ui_globs[bufnr] == nil then
        parser.parse()
        ui.init_ui()
      end
    end,
  })

  api.nvim_create_autocmd("BufWritePost", {
    group = augr,
    pattern = "*.cs",
    callback = function()
      local bufnr = api.nvim_get_current_buf()
      if parser.using_xunit(bufnr) then
        parser.parse()
      end
    end,
  })
end

local function setup_cmd()
  local cmd = api.nvim_create_user_command
  cmd("XToggleTests", function()
    ui.toggle_quick_menu()
  end, {})

  cmd("XRunAll", function()
    run.execute_all()
  end, {})

  cmd("XRunTest", function()
    run.execute_test()
  end, {})

  cmd("XToggleLog", function()
    run.show_test_log()
  end, {})

  cmd("XNextTest", function()
    ctrl.jumpto_next()
  end, {})

  cmd("XPrevTest", function()
    ctrl.jumpto_prev()
  end, {})
  -- cmd("XDebug", function()
  -- 	ui.del_all_ext()
  -- end, {})
end

function M.setup(user_conf)
  config.set(user_conf)
  setup_autocmd()
  setup_cmd()
end

return M
