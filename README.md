# Ankh Crossword Loader

Player for .puz files, used for crosswords from newspapers such as the L.A.
Times.

At the moment it loads and displays the LA Times from 2014-04-22 by default.
Give it a different filename on the command line to load that instead.

When a puzzle is loaded, if there is a game in progress (.ankh) file, then
that will be loaded to allow continuation.

When the grid is correctly complete, the time is displayed.

## Keys and Mouse

    A-Z         Fill in letter

    Bksp        Delete content and move to the previous cell. If the current cell
                was already empty then the previous cell will be cleared instead.

    Spacebar    Swap between across and down

    Tab         Move to the next word in the same direction
    Shift-Tab   Move to the previous word in the same direction

    F1          Swap help mode on and off, incorrect letters are then highlighted

    Escape      Exit, saving progress when not complete

Click on a cell to highlight it. Clicking on the currently highlighted cell
will swap between highlighting the current across or down word.

Click on a clue to select the word.

When the grid is filled, but there are wrong entries, help mode is turned on
automatically.

## Coming Events!

- [x] Highlight an across word
- [x] Highlight a down word
- [x] Highlight the current cell
- [x] Swap between Across and Down Highlight
- [x] Allow for letter entry
- [x] Highlight the next cell after entering a letter
- [x] Highlight the next word after ending the current one
- [x] Save progress
- [x] Load progress
- [x] Fix .ankh file UTF-8 loading / saving bug
- [ ] Add some tests for the loader
- [ ] Handle scrambled puzzles

## Acknowledged Copyrights

The background Ankh image comes from [Icon Archive](www.iconarchive.com)
and was designed by [DesgnBolts](http://www.designbolts.com/)

## Crosswords

Compatible crosswords can be loaded from [CrosswordFiend](https://crosswordfiend.com/download/)

### Git client

I have used Git at the command-line for 10 years. Over that time, I have tried
many different graphical shells for Git, without finding one that was easier
and nicer to use than the command-line (in my view).

I have now found that [GitKraken](https://www.gitkraken.com) is an excellent
Git shell and would advise using it to everyone.

### Questions

If you have any questions about this repository, or any others of mine, please
don't hesitate to contact me.
