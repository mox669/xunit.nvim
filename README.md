# Xunit Testsuite [WIP] 

## Todo

+ user config options [  ]
  + mappings [  ]
  + command args [  ]
  + virt_text options [  ]
+ toggle for results float [  ]
+ list all tests in float [  ]
+ clean/refactor codebase [  ]

## Implemented
+ registering all tests per buffer
+ supports `[Fact]`, `[Theory]` and  `[InlineData()]`
+ list all tests with `:XShowTests`
+ execute test command based on selected test in buffer with `:XRunTest`
+ execute all test in buffer with `:XRunAll`
+ floating test result window spawn with `:XShowResult`
+ jump controls to easily jump between tests with `:XJumpNext` and `:XJumpPrev`
+ virt_text annotations using extmarks
+ highlight groups
  + XVirtNormal
  + XVirtPassed
  + XVirtFailed
  + XFloatNormal
  + XFloatBorder

## Known Issues
+ execute_all() will freeze the neovim instance, since it currently uses jobwait() to finish all tests and keep results correct 


