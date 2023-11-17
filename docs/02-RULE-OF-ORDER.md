# PINNACLE - 02 - Rule of Order

## Table of Contents
1. [Simulation](#simulation)
2. [Order](#order)
3. [Mythology](#mythology)
4. [Chaos](#chaos)
5. [Affinity Space](#affinity-space)
6. [Faction Affinity](#faction-affinity)

## Simulation

The `Simulation` is the name of the great determiner of fate.

## Order

`Order`, explicitly, is the error function which the simulation calculates every `World Tick`.  It is a function of the global 
stability of the game world.  Metrics such as global `Health` levels, `Food` levels, `Gold` levels, and other metrics 
will be used to generate statistics for each `Location`, and the various locations will be used to calculate the global
`Order` level.

## Mythology

The core mythology exists around this concept of order, and how this world exists in a multiverse, and the prophecies of what
will happen when the `Order` level reaches certain thresholds.  There are powerful Mages who can traverse the multiverse.

Legends say that there may even be a parallel universe where the `Order` level is inverted, and the world is in a state
of chaos.  This is the `Chaos` universe.

### Singularity

The `Order` level is a value `[0, 1]`.  If the `Order` level reaches 1, then the `Singularity` occurs.  It is said
that the `Singularity` is the point at which the `Order` and `Chaos` universes merge, and the multiverse is destroyed.

### Religion

There are two major religions in the world, the `Order` cult, and the `Chaos` cult. 

The `Order` cult believes that the `Singularity` is not inevitable, and that a neutral `Order` level must be maintained
at all costs.  

The `Chaos` cult on the other hands worships the perfection of the `Luminent Age`, and seeks to bring absolute `Order`.

Bringing about order, that sounds like a good thing, right?

## Chaos

The `Chaos` universe is a parallel mirror universe to the `Order` universe.

### Balance

This is where it starts to get complex.  You see, both universes are in a state of balance.  The `Chaos` universe feeds
the `Order` universe with the very soul imprints for every character that is born there.  Every `Order` `Character`
originally had a `Soul Twin` in the `Chaos` universe.  The `Simulation` arbitrates all decisions of fate for it's own
designs.

The only thing that technically links the two is that the current `Order` level of the `Chaos` universe is the inverse 
of the `Order` level of the `Order` universe, and that all `affinity`s are the polar inverse...

#### Beasts of Chaos

The `Chaos` world has much more powerful monsters, and the `Chaos` universe is much more dangerous.

#### Chaos Agents

There are `Chaos Agents` who are `Chaos` universe characters who have managed to cross to the `Order` universe.  They
are seeking to bring instability to `Order`, to improve the lives of people in the `Chaos` universe.

They are mortal enemies of the `Order` and `Chaos` cults.

#### Time of Determination

The `Time of Determination` is the event when a new `Character` is to be spawned in the `Order` universe.  The `Simulation`
selects the oldest `Character` in the `Chaos` universe, who has `affinity` values close to the ideal `Order Set` value
for the parents, that does not already have a `Soul Twin` in the `Order` universe.  This `Character` is then spawned in
the `Order` universe, the `Soul Twin` is created, and the original `Character` continues on in the `Chaos` universe.

#### Time of Renewing

The `Time of Renewing` is the event when a new `Character` is to be spawned in the `Chaos` universe.  The `Simulation`
determines where a new `Character` is needed to fill vacant `Jobs`, and they are immediately born, `Adult`, and assigned
to their `Assignment`.  The `Simulation` determines their `A` and `B` values by the demands of the `Simulation`.

#### Time of Elimination

The `Time of Elimination` is when a `Chaos` universe character dies.  The `Simulation` then deletes them from existence.
The `Order` character is no longer a `Soul Twin`, unless a new `Soul Twin` is created.

#### Time of Interjection

The `Time of Interjection` is when a `Chaos` universe character is `Interjected`.  The `Simulation` may need to fill
a `Job`, and there is no qualified candidate.  The `Simulation` then selects the most qualified `Character` in the `Chaos`
universe, that has no `Soul Twin`, and `Interjects` them into the `Order` universe, raising any levels that are too low
to the minimum requirements for the `Job`.  They retain memories of their previous life, and their `affinity` remains the
same.

### Time of Evanescence

The `Chaos` universe will, occasionally fall into a state of `Evanescence`.  This is when the `Order` level of the `Chaos`
universe will fall so far out of balance with the `Order` universe, that the `Chaos` universe is annihilated.  All
`Character`s in the `Chaos` universe are deleted, then every living `Order` character will gain a new `Soul Twin` in the
`Chaos` universe, completely identical to themselves, in every way, except the `L` value is based on the `Chaos` universe
`Order` level.

All `Order` universe `Character`s are immediately returned to the `Order` universe.

All beings in the `Order` universe feels a great sense of simultaneous loss, connection, and hope, but the `Order` level
of the `Order` universe is reduced 10%.

It's almost a bit like the whole game is a giant genetic algorithm, isn't it?

### Dungeons

There are 9 `Dungeons` where the `Chaos` universe is leaking through, and the `Order` level is being inverted. 
They are 9-level mazes of monsters and traps, and the player can find powerful artifacts in these dungeons.  There is a
lot of lore around these dungeons, and the `Chaos` universe.

The levels start at the surface of either world, with the midpoint between the two worlds being the 5th level.  To cross
the middle divide requires a `sigil` and a `word`; which can be discovered by the clever player.

## Affinity Space

What is affinity space?  Affinity space is how we model a `Character`s general biases for and against other `Character`s.

### Character ID

This all works because of what a `character_id` is.  Every `character_id` in the entire world is an RGB value can only be
used once. It is unique for that character.  When a character is born, the character is given a `character_id`. This 
becomes the character's `base_affinity`.

### Affinity

LAB colorspace is used to convert the RGB value to a 3D vector, and then the vector is normalized to a unit vector.  
This is the character's `affinity`.

### Birth & Death

The `character_id` is generated using this `affinity` for each parent. A = mother A, B = father B, and L signifies the 
world `Order` gradient position at birth, a value `(0, 1)`.  The `character_id` is the closest available RGB value to
the LAB value of `(L, A, B)` which has not already been used.  This is known as the `Order Set`.

Some `character_id`'s are removed when the character dies, particularly monsters, bands, chaos agents, and order agents.
The others can only be deleted in a purge.

This means that the `character_id`'s are effectively a permanent record of every character that has ever existed in the
world, so we could easily track genealogy, and other things.

### Chaos Birth

The `Chaos` universe has a completely different instance of the `affinity` space.  The `Chaos Set`. When a `Chaos` character
is born, the `character_id` is the L of `(1 - Order)` and the A and B are the inverted A and B from the parents.

### Interaction

This character views all other characters in the world by their distance from their `affinity`.  The closer the character
is to the `affinity`, the more the character likes them.  The further away, the more the character dislikes them.

A character may adapt over time to feel differently.  Each character has a `personal_bias` value, which is a polar 
rotation that is applied to their `base_affinity`.  Each character may have `Friend`s as well, for which they have a 
`individual_bias` value.

```latex
affinity = base_affinity * personal_bias * individual_bias
```

#### Emergent Behavior

I suspect using balanced societies from a long running simulation would immediately offer some very cool visual storytelling.
It would naturally cluster, making each `Faction` naturally it's own color, or some set of colors.  As the simulation plays
out, along the borders you would have mixed color children, who would potentially want to rebel if the `faction_affinity`
was dramatically different than theirs.

The `Chaos` universe will be an awful place, as children and parents will be constantly at odds with each other.  It is 
unlikely that and `Faction` would be stable for long, or that people would want to live where they were born for long.

It's very likely that some parts of that world will just be a meatgrinder.

I may have to revisit some of the core parameters dealing with the universes being inverted.  I'm not sure how well it
will work out.

## Faction Affinity

A faction as a whole has an `affinity`, which may change over time.  It does not have an `L` magnitude, but inherits
it from the world `Order`.

### Government Types

* Anarchy : Inherits `affinity` from polar mean of population.
* Democracy : Inherits `affinity` from polar mode of population.
* Monarchy : Inherits `affinity` from the monarch.
* Oligarchy : Inherits `affinity` from polar mean of nobility.
* Tribal : Inherits `affinity` from polar mode of nobility.
