# Nibbler

Nibbler is a NeoVim plugin that allows you to convert numbers between binary, decimal, 
and hexadecimal formats quickly and easily. It also provides a convenient command to 
toggle between the different number formats.

This plugin was developed with multiple objectives: to explore the potential of AI-assisted code development, gain hands-on experience in creating neovim plugins and their practical applications, learn the basics of the Lua programming language, and cater to the specific needs of embedded programming. 

## Features

- Convert a number to its binary representation
- Convert a number to its decimal representation
- Convert a number to its hexadecimal representation
- Toggle between binary, decimal, and hexadecimal representations
- Diplay the decimal representation of a hexadecimal or binary number as virtual text.

## Installation

### lazy.nvim

Add the following to your `plugins.lua` configuration:

```lua
{ 'skosulor/nibbler' },
```

### Configuration

You can configure the plugin using the following options. 

```lua
{
    config = function()
        require('nibbler').setup ({
            display_enabled = true, -- Set to false to disable real-time display (default: true)
        })
    end
}
````

## Usage

Have the cursor over a number an call one of the following commands:

| Function             | Description                                                    |
|----------------------|----------------------------------------------------------------|
| NibblerToHex         | Convert number under cursor/highlighted to hexadecimal         |
| NibblerToBin         | Convert number under cursor/highlighted to binary              |
| NibblerToDec         | Convert number under cursor/highlighted to decimal             |
| NibblerToggle        | Toggle between binary, decimal, and hexadecimal                |
| NibblerToggleDisplay | Toggle virtual text showing decimal value of hex or bin number |


