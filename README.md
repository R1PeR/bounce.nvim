# Bounce.nvim

Simple plugin that displays possible word jumps forward and backward from cursor position as marks with number assigned.

![Alt text](img/picture_1.JPG?raw=true "Forward possible jump positions")
![Alt text](img/picture_2.JPG?raw=true "Backward possible jump positions")
![Alt text](img/picture_3.JPG?raw=true "Virtual line jump positions")

## Exposed functions

calling `setup` will automatically add `show_word_numbers` and `hide_word_numbers` to Neovim callback and display jump positions after delay is elapsed

calling `show_word_numbers` will display possible jump position instantly

calling `hide_word_numbers` will hide displayed possbile jump position instantly

## Config

`delay_time` - time in ms it takes to show jump positions after action, default: `1000`

`highlight_group_name` - highlight name to use on jump positions, default: `@text.todo`

`more_jumps` - display more than 9 jumps, jump numbers will repeat, default: `false`

`display_mode` - sets currently used display mode, can be either "overlay" which overlays numbers on current line or "virtual_line" which creates virtual line(s) below current line to display numbers

## Example installation

```
  {
    'R1PeR/bounce.nvim',
    config = function()
      require('bounce').setup {
        delay_time = 1000,
        highlight_group_name = '@text.todo',
        more_jumps = false,
        display_mode = "overlay",
      }
    end,
  },
```