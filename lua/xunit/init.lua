----
-- xunit.init
-- Entry point
----
local lazy = require("xunit.lazy")
local config = lazy.require("xunit.config")
local gather = require("xunit.gather")
local ui = require("xunit.ui")
local u = require("xunit.utils")
local run = require("xunit.run")
local ctrl = require("xunit.controls")

local api = vim.api

local M = {}

local function inspect_data()
  local buf = api.nvim_get_current_buf()
  print("Current namespace -> " .. gather.xunit_globs[buf].namespace)
  print("Classname         -> " .. gather.xunit_globs[buf].classname)
  print("\n")
  print("+-------------------------TESTS-------------------------+\n")
  for _, test in pairs(gather.xunit_globs[buf].tests) do
    print("TEST: " .. test.name .. " at line " .. test.line)
    print("Range -> ", vim.inspect(test.offset))
    print("\n")
  end
end

local function setup_autocmd()
  local augr = api.nvim_create_augroup("xunit-test", { clear = true })
  api.nvim_create_autocmd("BufEnter", {
    group = augr,
    pattern = "*.cs",
    callback = function()
      local bufnr = api.nvim_get_current_buf()
      if gather.using_xunit(bufnr) and ui.ui_globs[bufnr] == nil then
        gather.gather()
        ui.init_ui()
      end
    end,
  })

  api.nvim_create_autocmd("BufWritePost", {
    group = augr,
    pattern = "*.cs",
    callback = function()
      local bufnr = api.nvim_get_current_buf()
      if gather.using_xunit(bufnr) then
        gather.gather()
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
