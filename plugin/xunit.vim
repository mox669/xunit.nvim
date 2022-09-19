" Title:        xunit.nvim - xUnit-Testsuite for Neovim
" Description:  Run xUnit-Tests from neovim 
" Maintainer:   olekatpyle <https://github.com/olekatpyle>

if exists("g:loaded_xunit")
    finish
endif

let g:loaded_xunit = 1

hi def link XVirtNormal Normal
hi def link XVirtPassed DiagnosticInfo 
hi def link XVirtFailed DiagnosticError
hi def link XFloatBorder Normal 
hi def link XFloatNormal NormalFloat
