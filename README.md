# Columns

A version of the classic falling-gems puzzle game **Columns**, written in MIPS assembly. Built as the final project for **CSC258 (Computer Organization)** at the University of Toronto.

Stacks of three coloured gems fall into the well. Move them, reorder them and drop them so that three or more gems of the same colour line up horizontally, vertically or diagonally. Matching gems are cleared, everything above them falls, and the game ends when the well fills up.

## Features

- Start screen and difficulty selection
- Gravity that gets faster with difficulty
- Matching in rows, columns and both diagonals, with chain reactions
- Score counter
- Ghost marker showing where the current column will land
- Pause, restart and game-over screens
- The Columns theme playing in the background

## How to run

The game runs on [Saturn](https://github.com/1whatleytay/saturn/releases), a MIPS IDE and simulator.

1. Download and install Saturn from its [releases page](https://github.com/1whatleytay/saturn/releases).
2. Open `columns.asm` in Saturn.
3. Set up the bitmap display:

   | Setting | Value |
   | --- | --- |
   | Unit width | 8 px |
   | Unit height | 8 px |
   | Display width | 256 px |
   | Display height | 256 px |
   | Base address | `0x10008000` (`$gp`) |

4. Assemble and run, then click the bitmap display so it receives your keyboard input.

## Controls

**Start screen**

| Key | Action |
| --- | --- |
| `Space` | Start |
| `1` / `2` / `3` | Choose easy, medium or hard |

**In game**

| Key | Action |
| --- | --- |
| `A` / `D` | Move left / right |
| `W` | Change the order of the gems in the column |
| `S` | Move down one row |
| `Space` | Drop the column instantly |
| `P` | Pause |
| `R` | Restart |
| `Q` | Quit |

There are also two hidden difficulty levels. Try `0` and `4` on the difficulty screen.

## Documentation

The full project write-up is in [ProjectDoc.pdf](https://github.com/user-attachments/files/24240524/ProjectDoc.pdf).

## Authors

- Berke Basak
- Mert Rassa
