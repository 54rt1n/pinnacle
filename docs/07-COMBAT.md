# PINNACLE - 07 - Combat

## Rules

### Basics
Every character has a battle sheet.
```
Sheet:
Health: <Health>
Stance: <Engaged; Defending; Hidden; Prone; Defenseless; Sleeping; Dead>
Weapon: <Weapon Type>
Attack: <Attack Stat>
Defend: <Defend Stat>
Damage: <Damage Stat>
Critical: <Critical Stat>
Deflection: <P> / <S> / <B> / <M> / <OH>
```

### Equipping

Each character has a `Mainhand` and an `Offhand` equipment slot.

A normal weapon can be equipped by any character in the `Mainhand` slot.  If it is `Two Handed`, it takes both the `Mainhand` and `Offhand` slots.

If there is an available `Offhand` slot, then any character can equip a shield or weapon.  If a weapon is equipped, then the base weapon damage is added to the damage roll.

If an `Offhand Penalty` applies, then all `Attack` and `Defend` rolls are at `-2`.

### Damage

The damage types are Pierce (P), Slash (S), Bludgeon (B), Magic (M), and Off-Hand (O).

Armor provides Deflection.

To make a `Damage` roll, the character rolls `Might` and adds the weapon `Base Damage`.  This damage has a damage type depending on the weapon.

A `Damage` roll is opposed by `Endurance` / 2 + `Deflection`, depending on the damage type.

A magic damage roll is resisted by `Grit` + `M` deflection.

### Critical

A `Critical` roll is made by rolling `Cunning` / 2 vs `Fortitude` after a successful attack.  If the roll is successful, the
attack is a `Critical Attack`, and deals `damage = base_damage * 1.5`.

### Knockout

When a character takes damage so that their hit points drop below zero, they are `Knocked Out`.  They will become `Defenseless`, and will regain consciousness if their hit points return to a positive number.  Characters can still suffer damage  unless they acquire a `Mortal Wound`.  Then they are dead unless `Resurrect`ed.

### Defenseless

A defenseless opponent can not oppose an `Attack` roll.  All attacks are considered `Critical Attacks`.

### Combat Trade

Each level of combat trade adds a `+1` to every roll during combat.  No `Offhand Penalty` for combat trained characters.

### Mounted Combat

If the character has `Riding` and `Combat`, they can ride a mount in combat.  It gives them the ability to move two squares in any direction or three squares in a single direction.  If the third move is an attack, it is considered to be a `Charge`.

### Hidden

When attacking from hidden, check `Cunning` vs `Awareness`, or opponent is considered `Defenseless`.

### Backstab

Backstab is a special modifier, that when making a flanked or hidden attack with a `Backstab` capable weapon, adds +3 `Critical` per level of Roguery.

### Knockdown

When the defender loses a roll, they must make a `Grit` roll vs the amount by which they lost.  If they fail, they are knocked down and become `Prone`.  This does not apply to `Mounted` characters.

### Prone

Prone characters Attack and Defend rolls are divided by two.  It takes 1 turn to stand up.  Roll `Willpower` vs Armor `Prone Penalty` to stand.

### Large

Large items can not be used while mounted.  When moving, an `Endurance` check vs 6 to move.

## Melee

When two combatants are next to one-another, a character can attack to strike his opponent.

### Roll

The roll is as follows:
```
State A: 
Health: 60
Weapon (Dagger) Offhand (Main Gauche) Armor (Leather) 
Attack (6m + 3k + 1) Defend (6m + 2p + 1) Damage P (3 + 2b + 3k + 1)
Deflection: 2P 2S 3B 0M 1O

State B: 
Health: 40
Weapon (+1 Staff) Offhand (None) Armor (Chain) 
Attack (4b + 1k + 1) Defend (4b + 3f + 1) Damage B (4 + 4b + 1k + 1)
Deflection: 4P 5S 3B 0M 0O

A Attacks B
A - Throws: 6m + 3k...  2m + 3k + 2k = 7
B - Throws: 4b + 3f + 1...  4b + 1b + 1f + 1 = 7
Tie goes to the defender.  Attack misses.

B Attacks A
B - Throws: 4b + 1k + 1...  4b + 1b + 1k + 1k + 1 = 8
A - Throws: 6m + 3p...  1b + 1b = 2
B hits A
B - Damage Throw: 4 + 4b + 1k + 1... 4 + 2b + 1k + 1k + 1 = 9
A - Deflection Throw: 3B + 1O = 4
A Takes 5 damage.
```

## Ranged

Ranged attacks can be made when the attacker is at a distance from their target. The maximum range depends on the weapon being used. When making a ranged attack, the attacker must have a clear line of sight to their target.

### Roll

The roll is as follows:

```
State A:
Health: 60
Weapon (Longbow) Offhand (None) Armor (Leather)
Attack (6m + 3k) Defend (6m + 2p) Damage P (4 + 2b + 3k)
Deflection: 2P 2S 3B 0M 1O

State B:
Health: 40
Weapon (Crossbow) Offhand (None) Armor (Chain)
Attack (4b + 1k + 1) Defend (4b + 3f + 1) Damage P (5 + 4b + 1k + 1)
Deflection: 4P 5S 3B 0M 0O

A Attacks B (at range)
A - Throws: 6m + 3k...  4m + 3k + 1k = 8
B - Throws: 4b + 3f + 1...  2b + 1f + 1 = 4
A hits B
A - Damage Throw: 4 + 2b + 3k + 1... 4 + 1b + 3k + 1k + 1 = 9
B - Deflection Throw: 4P + 0O = 4
B Takes 5 damage.

B Attacks A (at range)
B - Throws: 4b + 1k + 1...  3b + 1k + 1k + 1 = 6
A - Throws: 6m + 2p...  5m + 2p + 1 = 8
Tie goes to the defender. Attack misses.
```