# Bounce.nvim

Simple plugin that displays possible word jumps forward and backward from cursor position as marks with number assigned.

![Alt text](img/picture_1.JPG?raw=true "Forward possible jump positions")
![Alt text](img/picture_2.JPG?raw=true "Backward possible jump positions")

## Limitations

For now plugin can display up to 9 possible jump positions, because more would require displaying them above or below current line.

## Exposed functions

calling `setup` will automatically add `show_word_numbers` and `hide_word_numbers` to Neovim callback and display them after delay is elapsed

calling `show_word_numbers` will display possible jump position instantly

calling `hide_word_numbers` will hide displayed posbbile jump position instantly

## Config

`delay_time` - time in ms it takes to show jump positions after action, default: `1000`
`highlight_group_name` - highlight name to use on jump positions, default: `@text.todo`

## Example installation

```
  {
    'R1PeR/bounce.nvim',
    config = function()
      require('bounce').setup {
        delay_time = 2000,
        highlight_group_name = '@text.todo',
      }
    end,
  },
```