# Nibbler

Nibbler is a NeoVim plugin that allows you to convert numbers between binary, decimal, 
and hexadecimal formats quickly and easily. It also provides a convenient command to 
toggle between the different number formats.

## Features

- Convert a number to its binary representation
- Convert a number to its decimal representation
- Convert a number to its hexadecimal representation
- Toggle between binary, decimal, and hexadecimal representations

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

| Function             | Description                                                        |
| ---------------------| -------------------------------------------------------------------|
| NibblerToHex         | Convert the number under the cursor to hexadecimal format          |
| NibblerToBin         | Convert the number under the cursor to binary format               |
| NibblerToDec         | Convert the number under the cursor to decimal format              |
| NibblerToggle        | Toggle between binary, decimal, and hexadecimal formats            |
| NibblerToggleDisplay | Toggle virtual text displaying decimal number of hex or bin number |


