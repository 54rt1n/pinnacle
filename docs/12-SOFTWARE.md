# PINNACLE - 12 - Software

## Architecture

### World Building
* Ldtk
* Python
* CastleDB

### Game
* [Haxe](https://haxe.org/) / [heaps.io](https://heaps.io/)
* OpenAL Audio

#### HashLink

Haxe uses the `hl` [hashlink](https://hashlink.haxe.org/) virtual machine for testing.

#### Interface
The interface window features a two column layout:

The left column is the game window, where `Scenes` will be rendered.

The right column is split into two rows.  The top row is a character window, where the player's character information windows will be displayed.  The bottom row is a console window where the system will render text, the player can type commands, and conversations with NPCs will occur.

### World

The gameworld is a 512x512 grid, and each cell is a 128x128 grid, thus each position in the world 
can be set in 65536x65536 coordinate space.

#### Location

Each cell in the grid represents a location.  Locations are 128x128, and consist of a ground and terrain layer.

#### Structures

Structures are small level chunks.  Conceptually a structure has a grid bounds, a world-x, world-y offset, and a structure level.

### Layers

#### Gound / Terrain

The base layer for the map is the 0-level.  This contains the base ground terrain for a location.

#### Structures

Structures begin to exist at the 1-level.  Structures are placed in levels above and below.

### Roles and Zones

We need to have a way to define what areas are used for certian things.  Watchmen need to know where the patrol bounds are, communities need areas where they can do things.

So, if conceptually a character has a Job and a Family, then that Job would have a Zone and the Family will have a zone.  They will prefer these tiles, and path to be in the zone at the appropriate time.

Since only one flag can be set for any tile at any time, we have to represent these things in different layers.

Structures can have up to 

#### Roles

This should probably be a long list.

* Farmhand
* Guard
* Innkeeper
* Cook
* Musician
