# Xunit Testsuite for Neovim
For all the desperate trying to write csharp programs with neovim like me, this plugin adds 
a Xunit testrunner to neovim making it a little bit easier to execute .NET tests and taking the world 
a small step away from relying on VS\*\*\*\* to write csharp on linux. At least if you want to avoid 
verbose commands to run a single test on linux like 
`dotnet test -v diag -l trx --filter FullyQualifiedName=AVeryPackedNamespace.AVeryLongClassName.AVeryLongMethodName`
that is.


## Implemented
+ registering all tests per buffer
+ supports `[Fact]`, `[Theory]` and  `[InlineData()]`
+ list all tests with `:XShowTests`
+ execute test command based on selected test in buffer with `:XRunTest`
+ execute all test in buffer with `:XRunAll`
+ floating popup to list all tests in current buffer with `:XToggleTests`
+ floating test result window spawn with `:XToggleLog`
+ jump controls to easily jump between tests with `:XJumpNext` and `:XJumpPrev`
+ virt_text annotations using extmarks
+ highlight groups
  + XVirtNormal
  + XVirtPassed
  + XVirtFailed

## Usage
Navigate with `:XJumpNext` and `:XJumpPrev` to the tests found in the current buffer or use `:XToggleTests` to list all tests
in the buffer inside a popup menu and select one from there.
After a test has been selected you can execute it inside Neovim with `:XRunTest`. Virt_text annotations show you the result inside 
the buffer. You can check out the test log with `:XToggleLog`. 
Although not ideal, you can run every test inside the buffer with `:XRunAll`. (See ___Known Issues___) 

### Default Configuration
In order to use the plugin, you have to run the setup function and optionally add a config to it:
```lua
require("xunit").setup({

	command = {
		-- perform 'dotnet clean' before running the test. Defaults to true
		clean = true,
		
        -- change the verobsity level of the test log: [m]inimal | [n]ormal | [d]etailed | [diag]nostic
		-- defaults to minimal. (See dotnet test --help)
		-- NOTE: more detailed logs may have impact on performance
		verbosity = "m",
		
        -- add additional arguements to dotnet [t]est (see dotnet test --help for all options)
		targs = {},
		
        -- add additional arguments to dotnet [c]lean (see dotnet clean --help for all options)
		cargs = {},
	},
	
    -- change the virt_text annotation text displayed in the file
	virt_text = {
		idle = "Run test",
		running = "Running...",
		passed = "Passed!",
		failed = "Failed!",
		inln_passed = "ok",
		inln_failed = "x",
	},
    -- change the border used for the popup and the log window	
    border = { "┌", "─", "┐", "└", "┘", "│" },
})
```



## Known Issues
+ execute_all() will freeze the neovim instance, since it currently uses jobwait() to finish all tests and keep results correct 
+ whenever you delete a test or inline data, the ext_marks will remain which looks weird. They get deleted on next BufWrite


