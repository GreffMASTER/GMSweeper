# GMSweeper
 A simple minesweeper game made in Löve2d using the GMUI library

## About
This game is a standard version of a classic Microsoft Windows game, minesweeper. It contains 3 difficulties (easy, medium, hard) alongside a custom mode,  
where you can specify the grid width, height and mine count. The game saves top 10 best times for each difficulty.

## How to play
You can check the rules of minesweeper [here](https://en.wikipedia.org/wiki/Minesweeper_(video_game)#Objective_and_strategy).  
To start a new game, press the `Game` button in the top-left corner of the window.  
To reset the current game, press the button with the face on it in the middle of the window.  
To see the highscore table, press the `Scores` button next to the `Game` button.

## How to install
Go to the [latest release](https://github.com/GreffMASTER/GMSweeper/releases/latest) and download the version for your platform.  
Alternatively you can download the .love file and run it in the Löve2d executable.  
To do that, you need to download the [Löve2d framework](https://love2d.org/) and install it on your system.  
After installing it, just drag the .love file onto the executable.

## Command line parameters
You can run the game directly in the custom difficulty by specifying the width, height and mine count in the command line parameters.  
If only parameter is provided, the width and height of the grid will equal to that parameter.  
If mine count is not provided, the mine count will equal to maximum value of the grid width and height.

## About GMUI
GMUI (GreffMASTER's User Interface Library) is a custom GUI library that adds buttons, windows, text boxes and more.  
This library is still in development and does not contain any documentation.

## Credits  
LOVE Development Team - Löve2d, a game engine this game runs on.

## License
This game is licensed under the MIT License, see [LICENSE](https://github.com/GreffMASTER/GMSweeper/blob/main/LICENSE) for details.
