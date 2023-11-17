# PINNACLE - 03 - Characters

## Table of Contents
1. [Basics](#basics)
2. [Mood](#mood)
3. [Effects](#effects)
4. [Attributes](#attributes)
5. [Checks](#checks)
6. [Lifespan](#lifespan)
7. [Gaining Levels](#gaining-levels)
8. [Character Creation](#character-creation)
9. [Equipment](#equipment)
10. [Trades](#trades)
11. [Character Archetypes](#character-archetypes)
12. [Other Ideas](#other-ideas)

Every player, NPC, and monster is a character.

## Basics

### Level
Each character has a character level. This is determined by the experience they have earned, from combat, quests, and other activities. 

### Health
Each character has a health level. If this falls to 0, the character is unconscious. The character only dies if they suffer a `Mortal Wound`. The max health level is determined by the `Body` stat and the `Fortitude` trait, as (10 + `Level` * 2 + `Body` * 5 + `Fortitude` * 10).

### Food
Food is a general number. If you run out of food, a character will proceed throughout the stages of starvation. At first they will get a `Hungry` slight bonus (+1 to all stats), but as they get hungrier, they will go through, `Starvation` after 4 days (-2 to all stats), and after 30 consecutive days they will have to throw a `Endurance` check or die, every day.  Each day the check difficulty increases by +1.

### Gold
Gold is a general number, which will be purchased at the food vendor. If you run out of food, a character will proceed throughout the stages of starvation. At first they will get a slight bonus to all of their stats, but as they get hungrier, they will go through, `Starvation` after 4 days, and after 30 consecutive days they will have to throw a `Endurance` check or die.

## Attributes

### Classes

* Warrior
* Mage
* Rogue

### Stats

Each character has 3 stats, and each stats has 5 levels, 1 to 9.

* Body
* Soul
* Mind

### Traits

Each player has 4 traits, and each trait has 5 levels, 0 to 9.

* Fortitude
* Presence
* Keen
* Learning

## Checks

* `Endurance` - `Body` + `Fortitude`
* `Beauty` - `Body` + `Presence`
* `Might` - `Body` + `Keen`
* `Grace` - `Body` + `Learning`
* `Willpower` - `Mind` + `Fortitude`
* `Awareness` - `Mind` + `Presence`
* `Cunning` - `Mind` + `Keen`
* `Knowledge` - `Mind` + `Learning`
* `Grit` - `Soul` + `Fortitude`
* `Charm` - `Soul` + `Presence`
* `Creativity` - `Soul` + `Keen`
* `Connection` - `Soul` + `Learning`

## Mood

A character has a current `Mood`, based on how their lives are going at the moment.  Starvation and being injured will
lower a character's mood.  Having a good meal, or being healed will raise a character's mood.  A character's mood will
impact their throws, and their interactions with other characters.

### Rules

`mood_value` is compared to the `Mood` threshold to determine a `Character`s curren mood.

### Moods
* Happy (>.75) - +1 to all throws
* Content (>.40) - +0 to all throws
* Unhappy (>.10) - -1 to all throws
* Angry (>0) - +1 to all throws

## Effects

Each character can be influenced by one or more `Effect`s. A `Effect` may impact a character attribute, modify throws,
or be a special condition that allows special actions, or movement.  Modifiers can come from various sources: magic,
equipment, wounds, etc.  An effect may have a duration, or be permanent.  When the duration of an effect expires, the
effect is examined to determine if it should be removed, or if it should be renewed, or if it should be enhanced.

## Lifespan

### Birth

`Character`s are born from two parents.  This is not random, and does not require an action.  There is no pregnancy
period, and the child is born immediately.  A new child is given a `Location` child `Dialog Token`. A child lives with
its parents until it becomes an adult.

### Aging

`Character`s don't age in the standard sense.  When a `Job` position opens up in their faction and there are no
characters that can fill the position, the Child becomes an Adult and takes the position, but takes the `Nurture`
`Dialog Token` from it's original location.

Thus, the following are the age ranges for characters: [Child, Adult]

## Job and Family

Every day at midnight, the simulation performs a global job reassignment.  The simulation will look at all of the
`Job`s in the simulation, for each `Faction`, and give a `Character` an `Assignment` to perform a `Job` at a `Building`.

A `Job` comes with a `Home`.  The character is immediately transported to somewhere `Home` and given a `Quest` to move in.

When a character is assigned a job, the character is assigned a `family_level` based on the `1 - job_tier` of the job.  
The family progresses as follows:

* Solo
* Family Level 1 - +Partner
* Family Level 2 - +Child
* Family Level 3 - +Child
* Family Level 4 - +Child

When a Character reaches family level 2, they are paired with the 'best' Child from their faction of the opposite sex.
That Child becomes an Adult and moves in to the `Home`, and is their `Partner`.

A Character can move from Job to Job, if they are the most qualified candidate for the new Job.  A Character will not
change to a Job that is the same or lower level than their current Job.  If a Character's Partner is the most qualified
for a Job, they will only move if the new Job is the same or higher level than their current Job.

If a Character has a Partner, and they can both be assigned to different Jobs at the same Location, then one of the
Homes in the Settlement in town will be vacant.

### Interjection

A `Chaos` `Character` can be `Interjected` into the `Order` universe.  This is a rare event, and only happens when a
`Job` is not filled by a qualified `Character`.  When a `Character` is `Interjected`, they are moved to the `Order`
universe and given a `Job` `Assignment`, and proceed as normal.  They are given the `Interjected` `Quest` and `Effect`.

## Gaining Levels

The experience curve is defined by the function `f(x) = (86x)^1.6`.  When a character crosses this threshold, they may
rest and gain a level.

When a player rests to gain a level, they have a vision in a dream, in which they see a vision related to the `Order`
level of the world.  They will be given four choices, and the choice they make will determine which `Trait` is raised by 1.

Every five levels, a character will have a vision related to their `Class` and their `Level`, where they are given three
choices, and the choice they make will determine which `Stat` is raised by 1.

During a level up, a character is completely healed.

## Character Creation

Character creation is straightforward:
* All Stats and Traits start at 1.

* Select an Archetype.
* Add 2 to Class Stat, and 1 to each Archetype Trait.
* Assign points - Divide 3 points amongst your Stats.
* Assign traits - Divide 5 points amongst your Traits.
* Assign trades - Assign 1 point in Trades.  This can be applied to Archetype Trades for an additional level.
* Pick a Sex and a Name.

## Equipment
Each character has nine equipment slots:
* Head
* Neck
* Body
* Feet
* Mainhand
* Offhand
* Ring
* Mount
* Trinket / Gadget

### Weapons & Armor
More details on this can be found in the combat page.

## Trades

In addition to the traits, each character can learn trades. This allows them to perform certain actions, and allows them to make throws against actions that aren't available to other characters.

Each trade progresses through levels : Novice, Adept, Expert, and Master.

Trades can be learned by any character, regardless of class.

### Body Trades

These trades focus on physical abilities, combat skills, and mastery over the material world.

* Archery
* Combat
* Harvesting
* Riding
* Sailing
* Survival

### Soul Trades

These trades relate to artistic expression, intuition, and social or emotional connections with others.

* Cooking
* Handling
* Herbalism
* Negotiation
* Performance
* Warfare

### Mind Trades

These trades involve intellectual pursuits, knowledge, and problem-solving skills.

* Alchemy
* Crafting
* Mercantile
* History
* Law
* Roguery

### Leveling Up Trades

Characters will level up their trades by purchasing `Training` from a `Trainer`.

## Character Archetypes

a. Barbarian
- Class: Warrior
- Traits: Fortitude, Keen
- Trades: Combat, Handling, Survival
- Equipment: Club, Leather Armor, Leather Boots, 10g, 20f

b. Farmer
- Class: Warrior
- Traits: Fortitude, Presence
- Trades: Harvesting, Herbalism, Cooking
- Equipment: Club, Leather Armor, Leather Boots, 5g, 100f

c. Knight
- Class: Warrior
- Traits: Presence, Keen
- Trades: Combat, Riding, Warfare
- Equipment: Dagger, Leather Armor, Leather Boots, 10g, 20f

d. Paladin
- Class: Warrior
- Traits: Presence, Learning
- Trades: Combat, Negotiation, Law
- Equipment: Dagger, Leather Armor, Leather Boots, 10g, 20f

e. Mariner
- Class: Warrior
- Traits: Fortitude, Keen
- Trades: Combat, Sailing, Survival
- Equipment: Dagger, Leather Armor, Leather Boots, 10g, 20f

f. Monk
- Class: Mage
- Traits: Presence, Keen
- Trades: Combat, Herbalism, History
- Equipment: Staff, Cloth Armor, Leather Boots, 10g, 20f

g. Shepherd
- Class: Mage
- Traits: Fortitude, Presence
- Trades: Archery, Handling, Survival
- Equipment: Sling, Cloth Armor, Leather Boots, 10g, 20f

h. Tinkerer
- Class: Mage
- Traits: Learning, Fortitude
- Trades: Crafting, Harvesting, Cooking
- Equipment: Dagger, Leather Armor, Leather Boots, 10g, 20f

i. Priest
- Class: Mage
- Traits: Learning, Fortitude
- Trades: Herbalism, History, Negotiation
- Equipment: Staff, Cloth Armor, Leather Boots, 10g, 20f

j. Wizard
- Class: Mage
- Traits: Learning, Keen
- Trades: Combat, Alchemy, History
- Equipment: Staff, Cloth Armor, Leather Boots, 10g, 20f

k. Assassin
- Class: Rogue
- Traits: Fortitude, Keen
- Trades: Combat, Alchemy, Roguery
- Equipment: Dagger, Leather Armor, Leather Boots, 10g, 20f

l. Bard
- Class: Rogue
- Traits: Presence, Learning
- Trades: Performance, History, Negotiation
- Equipment: Sling, Cloth Armor, Leather Boots, 10g, 20f

m. Corsair
- Class: Rogue
- Traits: Fortitude, Presence
- Trades: Combat, Sailing, Mercantile
- Equipment: Dagger, Leather Armor, Leather Boots, 10g, 20f

n. Ranger
- Class: Rogue
- Traits: Presence, Keen
- Trades: Archery, Riding, Survival
- Equipment: Sling, Cloth Armor, Leather Boots, 10g, 20f

o. Thief
- Class: Rogue
- Traits: Keen, Learning
- Trades: Combat, Roguery, Mercantile
- Equipment: Dagger, Leather Armor, Leather Boots, 10g, 20f

## Other Ideas

I like the idea of some sort of `Class` based synergy bonus.  Like, if you are a `Mage` and you gained most of your
experience casting spells and doing `Mage` quests, then you get 2 points at level up, instead of 1. This would encourage
players to play their class.
