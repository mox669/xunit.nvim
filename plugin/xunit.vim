" Title:        xunit.nvim - xUnit-Testsuite for Neovim
" Description:  Run xUnit-Tests from neovim 
" Maintainer:   olekatpyle <https://github.com/olekatpyle>

" Prevents the plugin from being loaded multiple times. If the loaded
" variable exists, do nothing more. Otherwise, assign the loaded
" variable and continue running this instance of the plugin.
if exists("g:loaded_xunit")
    finish
endif

let g:loaded_xunit = 1

" Exposes the plugin's functions for use as commands in Neovim.
" command! -nargs=0 FetchTodos lua require("example-plugin").fetch_todos()
" command! -nargs=0 InsertTodo lua require("example-plugin").insert_todo()
" command! -nargs=0 CompleteTodo lua require("example-plugin").complete_todo()
