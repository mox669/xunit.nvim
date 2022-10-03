# Xunit testsuite for Neovim
For all the desperate trying to write csharp programs with neovim like me, this plugin adds 
a Xunit testrunner to neovim making it a little bit easier to execute .NET tests and taking the world 
a small step away from relying on \*\*\*\*\*\* to write csharp on linux. At least if you want to avoid 
verbose commands to run a single test on linux like 
`dotnet test -v diag -l trx --filter FullyQualifiedName=AVeryPackedNamespace.AVeryLongClassName.AVeryLongMethodName`
that is.

![xunit](https://user-images.githubusercontent.com/77517314/191606904-a1e0b895-5d0a-46f8-ac95-3420472c3f99.gif)

## Implemented
+ registering all tests per buffer
  + checking first, if loaded cs file actually is using Xunit
+ supports `[Fact]`, `[Theory]` and  `[InlineData()]`
+ list all tests with `:XShowTests`
+ execute test command based on selected test in buffer with `:XRunTest`
+ execute all test in buffer with `:XRunAll`
+ floating popup to list all tests in current buffer with `:XToggleTests`
+ floating test log window spawn with `:XToggleLog`
+ jump controls to easily jump between tests with `:XJumpNext` and `:XJumpPrev`
+ virt_text annotations using extmarks
+ highlight groups
  + XVirtNormal
  + XVirtPassed
  + XVirtFailed
+ support for nvim-notify

## Usage
Navigate with `:XJumpNext` and `:XJumpPrev` to the tests found in the current buffer or use `:XToggleTests` to list all tests
in the buffer inside a popup menu and select one from there.
After a test has been selected you can execute it inside Neovim with `:XRunTest`. Virt_text annotations show you the result inside 
the buffer. You can check out the test log with `:XToggleLog`. 
Although not ideal, you can run every test inside the buffer with `:XRunAll`. (See ___Known Issues___) 

__IMPORTANT:__ 
+ the plugin relies on string analysis to validate test results. In order for that to work, dotnet needs to be run in english.
This can be set with the `DOTNET_CLI_UI_LANGUAGE=en` environment variable.
+ `dotnet test` can only be executed from a directory containing a solution file (.sln). There are plans to fix this in the future so 
the user does not have to specifically launch neovim from that directory with the solution file.

### Default Configuration
In order to use the plugin, you have to run the setup function. It is recommended to create a __cs.lua__ file inside
__ftplugin__  directory to only use the plugin when .cs files have been loaded. Add the config:

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
    -- only relevant, if "nvim-notify" is a installed plugin. Enable/disable notfications
    notify = true,
})
```

### Mappings
This plugin does not ship with default key mappings. However they can be easily configured with the provided commands
listed above. For more help check out the help for key-mapping in neovim (`:h key-mapping`) or have a look in this repo:
https://github.com/nanotee/nvim-lua-guide

## Known Issues
+ execute_all() will freeze the neovim instance, since it currently uses jobwait() to finish all tests and keep results correct 
+ whenever you delete a test or inline data, the ext_marks will remain which looks weird. They get deleted on next BufWrite
+ tests can only be executed, if neovim was started from the directory containing the solution file (.sln)

## Contribution
This is my go on making my first nvim plugin, not only to solve the dotnet test annoyance on linux for myself and others
but also to give something back to the neovim community and all enthusiasts.
This being said, this plugin might be far from perfect and I expect a lot of bugs here and there. 
Feel free to open issues or correct me on matters of the code I am wrong about, since this is also my first software written in lua.
Also suggest me any features or changes I should make. I will give my best to satisfy all needs.

### Side Note
I want to mention that I took some inspiration from the following plugins at times, my understanding of lua
or plenary as utility module was not sufficient:

https://github.com/akinsho/toggleterm.nvim

and 

https://github.com/ThePrimeagen/harpoon

ENJOY!
