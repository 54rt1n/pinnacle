# PINNACLE - 09 - Quests

## Overview

Quests are a way to give a character a sense of purpose, and a way to allow them to have
progression in their profession, or for the Player to experience an adventure.

An individual character can be assigned to many quests at a time.  They then prioritize the list, and perform the
quests in order.

When a quest is completed, the character is given a reward.

## Schedule Quests

Most quests are pretty innocuous, and are just a way to give the character something to do.  The primary quests are
to go to work, go have dinner, and to go home.

These are the quests that are assigned to the character by the `Scheduler` that manages what they inherit from the `Job`
that they have, or from the `Family` that they are a part of.

Some quests, like `Health` quests or `Food` quests are assigned when a character is injured, or hungry.

## Dynamic Quests

Quests need to be psudeodynamic.  A group of characters should be able to be assigned to a quest, so they act as the
quest giver, and subsequent parts of the chain.  Once the quest is assigned, if someone in the chain dies, the quest is
failed.  There will be new dialog trees given to the character when they are assigned to a quest chain.

Quest givers can be Job specific, Faction specific, Location specific, or Random.  Quests will have an affinity, and when 
completed will shift the `personal_bias` of the character completing the quest.

## Quest Types

### Job Quests

Job quests are quests that are given by a Job.  They will generally pay in `gold`, and give `experience` towards a level.

#### Examples

* Mine 10 ore
* Chop 10 wood
* Craft an item
* Construct a building
* Repair a Wall
* Gather 10 herbs
* Sell items to a vendor

### Family Quests

Family quests are quests that are given by a family member.  They are quests that generally involve the character
spending time with the family member, or doing something for the family member.

#### Examples

* Get married
* Have a baby
* Earn money
* Buy an item (Food)
* Go to a `Building` as a family
* Attend a festival

### Companion Quests

Companion quests are quests that are given by a `Companion`.  They are quests that generally come from the backstory of the
`Companion`, or a romance.

#### Examples

* Go to a `Location` with the `Companion`
* Talk to a `Character`
* Find an item
* Buy an item
* Rescue a person (temporary party member)

### Adventure Quests

Adventure quests are quests that are given by a character that is not part of the main story line.  They are quests that
generally involve the character going to a remote `Location` and completing a task.

#### Examples

* Kill a monster, or several monsters (witcher quests)
* Find a lost item, person, or treasure
* Escort a person (temporary party member)
* Rescue a person (temporary party member)

### Faction Quests

Faction quests are quests that are given by a faction.  They are given by progressively higher ranking members of the
faction.

Completing these quests will draw the `personal_bias` towards the `faction_affinity`, and increase the prosperity
of the faction in the world.

#### Examples

* Talk to a `Character`
* Deliver an item, or message
* Solve a problem
* Investigate a mystery
* Plot against a rival
* Defend against an attack
* Attack a rival
* Steal an item

### Settlement Quests

Settlement quests are quests that are given by a settlement.  They are given by the `Governor` of the settlement.

Completing these quests will draw the `personal_bias` towards the `faction_affinity`, and increase the prosperity
of the settlement in the world.

#### Examples

* Help with bandits
* Defend against an attack
* Gather resources
* Build a building
* Upgrade a building

### Story Quests

Story quests are quests that are part of the main story line.  They are given by the main characters in the story, and 
center around the lore of the world.  Story quests will often have an Order orientation, `[0, 1]`, and completing them will 
change a the World Order level and move the `personal_bias` by some magnitude `L`, 

#### Examples

* Visit a `Place`
* Talk to a `Character`
* Find an item
* Kill a monster, or a person

## Quest Givers

Quest givers are characters that have a quest to give.  Once a quest is given, it will start a new entry in the 
`Character`'s journal.

## Quest Journal

As information is learned from quest, it will update the `Character`s journal.

If the quest is Active, the current state of the quest will be shown in the journal.

Completed and failed quests will be hidden by default for Players, and deleted for standard `Characters`.

## Quest Dialog

Quest interaction triggers are made by entering the quest "Keyword" to a `Character` during dialog.

## Completed

When a quest is completed, the `Party` will have a golden glow.  The will gain some
rewards, in their inventory, experience towards raising their level, or a new trade level.
