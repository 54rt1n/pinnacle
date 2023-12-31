# PINNACLE - 10 - Dialog

## Overview

Dialog is the way that the Player interacts with other Characters in the game.

## Dialog Triggers

Dialog consists of a Player saying something to a Character, and their response.  Trigger words are used to signal what
the Player can say to get a particular dialog response.  Trigger words are highlighted in the dialog response text.

### Layered Dialog

Not all trigger words are available at all times.  A dialog option may require that certain conditions are met before
it is shown.  For example, Some trigger words require a high enough affinity, a certain Attribute level or Trade level
to be available.  Most trigger words require a previous trigger word to have been said first, or a quest trigger to have
been fired.

Trying to use a trigger word where the affinity is too low yields, "That's something I only discuss with friends."

Trying to use a trigger word that is too difficult will result in the character saying, "You have no idea what you are
talking about."

### Dialog Tokens

The `Simulation` hands out `Dialog Token`s to `Character`s, along with a `dialog_priority` value.  The character's dialog
tree is generated by overlaying the `Dialog Token`s in order of `dialog_priority`.

#### Token Types

* `Job` - While a character has a `Job`, they will have this `Transient` token.
* `Former Job` - When a character leaves a `Job`, they will receive a `Persistant` token.
* `Quest Giver` - While a character is a `Quest Giver`, they will have this `Transient` token.
* `Nurture` - Every `Character` born at a `Location` will receive a `Persistant` token.
* `Personality` - Every `Character` will be given a personality token.  At adulthood they receive a `Persistant` token.

#### Special Tokens

The Player has a `Player Bag` of tokens that it hands out to other characters before they engage in dialog.  These tokens
are unique to a `character_id`.  They are `Temporary` tokens.

#### Dealing Out Dialog

There are two levels from which dialog tokens are handed out.  The Global, and the Location.

The Global tokens are seeded into all of the `Character`s in the world as they enter the `Global Bag`.

Every `Location` has a dialog set.  This is a few types of dialog tokens that are handed out:

Every `Location` that has `Character`s will have a set of `Dialog Token`s to give out to the `Character`s there.
These are the personalities of the `Character`s.  Some tokens are completely fleshed out characters with complex dialog trees.
Some tokens are basic, and only have a few dialog triggers.  Most will be themed to the `Location` that they are
in.

Some of these tokens will be lost when the `Character` moves to a different `Location`.

If a `Character` becomes a `Quest Giver`, they will be given a new `Dialog Token` from the `Quest`.

A `Job` will have a `Dialog Token` that is given to all `Character`s with that `Job`.

A particular `Assignment` at a specific building may have a `Dialog Token` that is given to all `Character`s with that
`Assignment`.

### Unknown Trigger

If the Player says something that is not a trigger word, the character will respond with, "I don't know what you mean."

### Quest Triggers

If a Dialog Trigger is for a quest, and it advances the quest forward, the Quest Journal will be updated.

## Basic Dialog

You can always say "Hello", "Name", "Look", "Job", "Family", "Quests", "Health", "Weather", "Faction", "Hint", "Bye".  Any of these may
open new keyword triggers.

### Hello

The character will respond with a greeting.

### Name

The character will respond with their name.

### Look

A description of the character will be given.

### Job

The character will respond with their job.

### Family

The character will respond about their family.

### Quests

If the character likes the Player, they will tell them what quests they are on.

### Health

The character will respond with their health.

### Weather

The character will exchange in small talk about the weather.

### Faction

The character will share about their faction.

### Hint

Lists all the known trigger words, black if used and blue if unused.

### Bye

The character will say goodbye.

## Job Dialog

Some jobs have special dialog.  For example, a Merchant will have a "Trade" trigger.

## Affinity Dialog

Some characters will only mention certain topics to characters with a certain affinity.  If the Player has a high
enough affinity with the character, 
