# Ultima 5

I'm taking some of my game design cues from Ultima 5.  I'm going to document some of the things I've learned about the game here.

## *.DAT

 From: https://wiki.ultimacodex.com/wiki/Ultima_V_internal_formats

World Map: 256x256

For each city, we have an information entry for the Npcs of the map:

```
struct NPC_Info {
  NPC_Schedule schedule[32];
  uint8 type[32]; // merchant, guard, etc.
  uint8 dialog_number[32];
};
```
The dialog number gives the entry index to the *.TLK file.

Finally, the schedule says how the Npc moves around in the city and especially when:
```
struct NPC_Schedule {
  uint8 AI_types[3];
  uint8 x_coordinates[3];
  uint8 y_coordinates[3];
  sint8 z_coordinates[3];
  uint8 times[4];
};
```

Notes:

1) All maps can hold a maximum of 31 (not 32) NPC's. In every map, schedule[0], type[0] and dialog_number[0] are not used. However, type[0] is sometimes 0 and sometimes 0x1C, so perhaps it has some unknown purpose.

2) Each NPC_Schedule contains information about 3 locations that the NPC will go to at different times of day. The x and y coordinates are between 0 and 31, because each map has a size of 32x32 tiles. The z coordinates represent the level, relative to level 0. 0xFF would make the NPC go to the level below level 0, while 0x1 would make the NPC go to the level above level 0.

The times are given in hours, so they range from 0 to 23.

times[0] --> NPC goes to location 0

times[1] --> NPC goes to location 1

times[2] --> NPC goes to location 2

times[3] --> NPC goes to location 1

Values for the dialog_number
Value	Meaning
0	"No response" characters, including the guards who leave you alone
>0 && < Nbr defined in the value of the TLK file	Defined by that talk information. Add 256 + dialog_number to get the first sprite. For example dialog_number=68 would be a bard because the bard sprite is 68+256=324.
129	Weapon dealer
130	Barkeeper
131	Horse seller
132	Ship seller
133	Magic seller
134	Guild Master
135	Healer
136	Innkeeper
255	Guards who will harass you

## *.TLK
### The text encoding
For each NPC, there are a certain number of '\0' terminated strings which are encodings of what is the name, job, etc. of the NPC. To decode these texts, I've taken Nodling's decoder and tweaked it a bit.

#### First part: fixed entries
For each NPC, it starts with a certain number of fixed entries:

- Name, Description, Greeting, Job, Bye

#### Second part: key words
We specify it by:

```
<Key word> (Therefore text only)

[<OR character code (see below)> <0 set byte> <Key word> [<OR character code> <0 set byte> <Key word>]...]

<Answer text> (Potentially anything
```

Third part : labels
Then it's question/answers with labels.

Todo

Generalities
For the moment, for each entry, I do :

       if((c >= 160) && (c < 255))
       {
           c -= 128;
       }
       else
       {
           special = true;
       }

If it's a special case, then we have two cases : it's a code based symbol, it's an entry to an array of texts from DATA.OVL (the offset table starts at 0x24f8).

For the moment, I've confirmed these bindings :

```
Symbol value	Meaning
c < 129	entry to the offset table
129	Insert Avatar’s name
131	Conversation pause
135	Or in the key words
136	Ask for avatar's name
140	If/Else the NPC knows the Avatar's name
141	New line
143	Key wait
145 ~ 155	Labels 1 to 10
```

If it's not a special case, then I just copy the character in the string.

General Notes
1) Wishing Wells

There are two wishing wells in the game: - Paws (location 0x16) - Empath Abbey (location 0x1F)

These locations are hard-coded into the game. There is no difference between horses from wishing wells and horses from vendors. It also doesn't make any difference if you wish for "horse" or a car brand.