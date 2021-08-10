# `theme_utils` module

Theme-related utilities for [TextAdept](https://orbitalquark.github.io/textadept/).

This module allows the user to set a primary and an alternate theme, and toggle between them. It also provides a dialog  to select a theme from a list of installed themes.

## Installation

Clone this repository into your user modules directory:

```
git clone https://github.com/manuelmontenegro/theme_utils.git ~/.textadept/modules/theme_utils
```

Add the following to your user configuration file (`~/.textadept/init.lua`)

```lua
if not CURSES then
  theme_utils = require('theme_utils')

  -- Set theme settings. These will be applied to all themes.
  theme_utils.theme_env = { font = 'Fira Code Medium', size = 13 }  
  -- Specify the names of primary/alternate themes.
  theme_utils.set_primary_theme('dracula')
  theme_utils.set_alternate_theme('base16-equilibrium-light')
  -- [Optional] Assign keyboard shortcuts to functions
  keys['ctrl+t'] = theme_utils.toggle_theme	     -- Toggle between primary/alternate
  keys['ctrl+l'] = theme_utils.select_theme      -- Select a theme from a list
  keys['f4'] = theme_utils.next_theme		     -- Cycle between themes (next)
  keys['shift+f4'] = theme_utils.previous_theme  -- Cycle between themes (previous)
end
```

All the functions can also be accessed from *View → Themes* menu.

## Known issues

It has only been tested in Linux.

## Documentation

See the [LDoc documentation](https://manuelmontenegro.github.io/theme_utils/) for more details.

## License

See `LICENSE.md` for more details.