# Xunit Testsuite [WIP] 

## TODO

+ user config options []
+ support for Theories/Inlines []

## Implemented
+ registering all tests (Facts) per buffer
+ execute test command based on selected test in buffer
+ execute all test in buffer
+ floating test result window
+ jump controls to easily jump between tests
+ virt_text annotations using extmarks
+ highlight groups
  + XVirtNormal
  + XVirtPassed
  + XVirtFailed
  + XFloatNormal
  + XFloatBorder

## Known Issues
+ execute_all() will freeze the neovim instance, since it currently uses jobwait() to finish all tests and keep results correct 


