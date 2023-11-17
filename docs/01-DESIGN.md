# PINNACLE - 01 - Game Design

## Index

1. [Game Overview](#game-overview)
2. [Colorspace](#colorspace)
3. [Game World](#game-world)
4. [Rules](#rules)
5. [TBD](#tbd)

## Game Overview

* Single player
* Retro 80's RPG
* 2D Top down
* Turn based
* Open world
* Story driven
* The entire world is actively simulated at all times, so the player's choices really do matter
* Reminiscent of Ultima 4

Think of Ultima 4 style UI and gameplay, combined with a very simple world economy that involves trade and combat and 
monsters and whatnot, combined with the whole world being a live simulation.

### Similarities

* Ultima 4
* Mount and Blade
* Dwarf Fortress
* The Sims

## Colorspace

What is a colorspace?  So, if we imagine LAB colorspace as a way to represent a vector space. The L value is the
magnitude of the vector, and the A and B values are the direction of the vector.  We can find the distance between two
values by calculating the distance between the two vectors: `sqrt((L1 - L2)^2 + (A1 - A2)^2 + (B1 - B2)^2)`.  This is
the distance between two colors in LAB colorspace.

We do have to accept the limitations of using a colorspace to represent a vector space, but I think it is a good
approximation as long as we don't try to jam too much information into any one vector.

## Game World

Welcome to the world.  The most important thing to understand about this game is the concept of `Order`.

You can read all about `Order` in the [Rule Of Order](02-RULE-OF-ORDER.md) document.

### Player

The `Player`, is the `Party` that the player controls.  The `Player` has a `Main Character`, and can have up to 4
`Companion`s at a time.  The `Main Character` is a bug in the simulation.  The bug is, that the simulation has pulled
a consciousness from the 1980's United States, and you are trapped in the simulation.  You are the `Main Character`.

#### Creation

When the `Player` creates a `New Game`, the `Player` is presented with a white flash of light, and then a greyscale loading
screen, reminiscent of a Macintosh boot.  A black console with 80's RPG text graphics appears on a light blue background.
The `Simulation`, is a animated 80's ASCII emoji face that hovers in the corner of the screen.  It acts very much like
a computer program, but very much like a person.  It should feel like a strange experience.  

At first the `Simulation` is very confused, and it demands that you enter your name.

It considers your name, and then asks you to fill out a simple personality test.  The test is a series of questions
that will determine your `Main Character`s class.  It will then say "Mapping soulprint to colorspace analyzer...", and
then it will spit out your character portrait, and assign the `affinity`.  The `Player` can accept, or `Reset`, which
restarts from the white flash.

The `Player` then sees the console fill to take up the whole screen, with the `Simulation`'s face filling the console.
It is straining very hard, text fills the screen. "Restarting Simulation, CHECKPOINT 0x9a461ck1, , SEED 0x00000000..." 
The `Player` wakes up at a `Home`, in a `Place` very reminiscent of the Ultima 5 start cabin.

Their initial `Job` is `Farmhand`, as the `Blueprint` is for a level 1 `Farm`.  The `Player` can choose to work the
`Quest`s as they are assigned for the `Job`, or they can choose to ignore the `Job`, and go off and do whatever they
want.

#### Reassignment

As the `Player` progresses through the game, the `Simulation` may desire to reassign the `Main Character` to a different
`Job`.  The `Player` will be presented with a conversation with `Simulation`, to choose to accept the reassignment, or to
reject it.  If the `Player` rejects the reassignment, the `Simulation` will be very upset, and the `Order` level will
decrease.

When the `Player` accepts the reassignment, the `Player` will be presented with a white flash of light, and then be in
a new `Home`, potentially with their own `Family`.  The `Player` can develop a relationship with their `Partner`.  If
they do not have Children, then the `Player` can bring his `Partner` in to the `Party` as a `Companion`.

If the `Player` rejects the reassignment, then the `Simulation` will not ask again for 60 days.

#### Death

When the `Main Character` dies, the `Player` sees a white flash of light, and then a black console prompt.  
the Simulation spits out an error report, with a stack trace, and the world's current `Order` level, and a 
summary of populations and resources.  The `Player` can then choose to `Continue`, `Load` or `Quit`.  If the `Player`
chooses to `Continue`, the `Player` sees the `Simulation` attempt to recover from the error, but it fails.  `character_id`
is not found.  The `Main Character` is resurrected at the last `Temple` they visited, at full health, with all of their
`Companion`s at whatever state they were in when the `Main Character` died, and the `Order` level is increased.

If the `Player` chooses to `Load`, the `Player` is presented with a list of `Save`s.  The `Player` can choose to load
any `Save`.  The `Simulation` will attempt to recover from it's error, and fail.  It will perform a `Simulation Rollback`.
'...recovered from error, but simulation is unstable.  Rolling back to last stable state...'  The `Player` will enter
the simulation at the last save.

If the `Player` chooses to `Quit`, the `Simulation` suffers a fatal error, `Simulation` starts to smoke some,
red text scrolls, with all of the deep game stats, until the `Player` presses a key, and the game exits.

### Characters

All agents in the simulation are instances of `Character`.  You can start reading about `Character`s in the
[Characters](03-CHARACTERS.md) document.

### Equipment

Characters can equip items.  You can read about `Equipment` in the [Equipment](05-EQUIPMENT.md) document.

### Items

Items are the things that characters can create, harvest, trade, and interact with.  You can read about `Item`s in
the [Items](04-ITEMS.md) document.

### Magic

Magic is a special type of item that can be used to create effects.  You can read about `Magic` in the [Magic](06-MAGIC.md)

### Time

Every `World Tick`, all `Character`s current state is updated.  Then each `Location` instance is executed in
parallel.  Each `World Tick` provides each `Location` with 60 `Tick`s to execute.

`Local Tick`s or simply `Tick`s are the timescale that a `Character` takes actions in.

* A `Tick` is 1/1440th of a day. (1 minute)
* A `World Tick` is 1/24th of a day. (1 hour)
* A `Day` is 24 hours.
* A `Month` is 30 days.  The Moon is new at the 1st and full at the 15th.
* A `Season` is 3 months.
* A `Year` is 4 seasons.

### Zone Types

This world exists at 2 levels of scale:  Overworld and Location.

#### Overworld
- 512x512 grid
* Contains various types of `World Terrain` - Plains, Forest, Hills, Mountains, Jungle, Swamp, Desert, Ocean.
* There can also be variations on the terrain like light/medium/heavy
* A location might have a road (and it's direction).  (Oceans can't have roads.)
* A location might have a river (and it's direction).  (Oceans can't have rivers.)
* This makes 24 different terrain types.  (Heavy mountains are impassable.)
* Some locations are `Interactive`s, a Location may be entered.  A Settlement may be explored or used.  
Examples - Road, Farm, Mine, etc.
* NPCs- caravans, travellers, military companies, animals, monsters, and other groups will travel the overworld, and be
interactive.  When entering the square of a NPC, you can optionally engage - parley, attack, block.

#### Location

* Has a `Theme`, such as `Town`, `Castle`, `Keep`, `University`, `Dungeon`, etc.
* Contains various types of `Location Terrain`.  These will be at a more detailed scale.  A tile in general will have a 
category: Plains, Desert, Forest, Hill, Mountain, Structure, Lake, River, Ocean.
* A tile for each square is actually a layered map.
* There is a underground layer, a ground layer, a covering layer, and a top layer.  The underground layer might contain:
dirt, mud, stone, sand, water, emptiness.
* The ground layer might contain, dirt, gravel, marsh, sand, water, river, ocean.
* The covering layer might contain nothing, grass, shrub, flowers, cactus, waves, fence, road.
* The interactive layer might contain nothing, a tree, a fence, a door, or a level exit.
* The character layer might contain nothing, a character, a monster.
* The top layer might contain nothing, a big tree, a wall.

##### Major Location
- 128x128 grid
* For a large area.
* Examples: a town, a castle, a keep, a university, a dungeon.

##### Place
- 64x64 grid
* For a smaller area.
* Examples: a cottage farm, a cave, or a small dungeon.

##### Spot
- 24x24 grid
* A really small, possibly random area
* Examples: a campfire, a stream, an ambush

## Rules

### Rolls

Actions are accomplished by `rolls` which are a series of `throws`. Throws are a random value between 1 and some value N.
You can throw again if your throw scores N. At the end, all throws are summed for the result.

* Primary Throw - You get one throw for the associated stat and one throw for your trait. If you max out your roll, you
* throw again.  Even 1 gets a single reroll.

* Bonus Throw - There are ways to get bonus throws.

Opposed checks will be done by comparing opposed rolls from the two opponents.

### Battle

When a `Character` is `Attacked`, the world phases out, and the `Character` enters a `Battle`.  If any of the `Character`'s
`Party` is in the `Location`, they will join the `Battle`.

If any other `Character`s are in the instance area, they are also drawn into the `Battle`.  Their disposition will be 
determined by their `Job`, their `affinity` towards the defender, and their `affinity` towards the attacker.

If the `Player` is engaging in the `Battle`, his `Companion`s will join the `Battle`.

Two `Party`s face off in mortal combat.  See [Combat](07-COMBAT.md) for more details.

Battle is either calculated or instanced at a `Spot`.  Battles all resolve in 1 `Tick`. A character can choose to `Flee`
from a battle by running out of the instance. 

## Settlements

Settlements are places where `Character`s can interact with each other.  Settlements contain `Building`s, and `Home`s,
which are assigned to `Character`s as the Settlements grow through the various Building levels.

Each Settlement in the world has a template that defines the types of buildings that will be built in the settlement.
See [Settlements](08-SETTLEMENTS.md) for more details.

## Quests

Quests are the primary motivator to get a `Character` to do something.  Quests are assigned to `Character`s from various
`Quest Source`s, and they will be given a `Quest Reward` for completing the quest. 

Some examples of `Quest Source`s are: `Job`, `Family`, `Health`, `Hunger`, `Personal`, `Faction`, `Dialog`, and `Simulation`.

Only the `Player` can get `Dialog` quests.

Quests are a series of `Objective`s.  Advancing through a quest requires each `Objective` to be completed, in order.  Some
`Objective`s may have a `Schedule` when it will be attempted, or a `Time Limit`, after which the Quest fails..

The number of Quests being completed and failed impacts a `Settlement` growth and world `Order`.  Quests have `Quest Triggers`,
that are called when certain events occur, particularly dialog events.

In addition, failing a quest can have a negative impact on the `Character`'s `affinity`.  Not doing your `Job` will cause
`affinity` drift away from the `faction_affinity`, which could cause the `Character` to be fired from the `Job`!

Some Quests can have world changing impacts. See [Quests](09-QUESTS.md) for more details.

## Dialog

Dialog is the primary way that a `Player` interacts with `Character`s.  

Every `Character` has a set of `Dialog Tokens`.  A `Dialog Token` gives the character a list of `Dialog Trigger` keywords
that will be used to match against the `Player`'s `Dialog` input.  When a `Dialog Trigger` is matched, the criteria are
examined.  If they are met, the response is returned, otherwise an alternate response is returned.  It is possible for a
`Dialog Trigger` to unlock new keywords, and dispatch events (`Quest Triggers`, etc).

See [Dialog](10-DIALOG.md) for more details.

## Actions

Actions are the primary way that a `Character` interacts with the world `Interactable`s and `Character`s.

A character can:
* `Move` in a `Direction`
* `Attack` a `Direction`
* `Use` a `Direction`
* `Talk` to a `Direction`
* `Search` a `Direction`
* `Wait`

See [Actions](11-ACTIONS.md) for more details.

## Personality

A `Character` has a personality.  This is a `Dialog Token`, and a `Personal Quest`, and a personal priority weighting for
`Quest Source`s.

To determine a `Course of Action`, first, the current active quest objectives are listed, filtered by any `Schedule` for
the ``

Each `Objective` has the 
`source_priority`, and the `distance` required to move to complete the `Objective`.

To accomplish Quest `Objective`s, a `Character` determines a `Course of Action`. 

