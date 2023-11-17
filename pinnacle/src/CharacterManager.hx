// src/CharacterManager.hx
package;

import h2d.Object;
import CastleData;
import Config;
import Events;
import LdtkProject;
import Strategy;
import Party;

class CharacterManager extends Object {
    public var main : Character;
    public var app : Pinnacle;
    public var characters:Map<String, Character> = new Map<String, Character>();
    public var characterLocations:Map<String, String> = new Map<String, String>();
    public var gameConfig : WindowConfig;
    public var tileSet : Tileset_Ultima_5;
    public var party = new Party();
    public var strategies: Map<CharacterObjective, ObjectiveStrategy> = new Map();

    public static function create(tileSet : Tileset_Ultima_5, gameConfig : WindowConfig, app : Pinnacle, ?parent: Object) : CharacterManager {
        var mainCharConfig = {
            charId: "player",
            name: 'Player',
            health: 100,
            food: 100,
            viewRadius: 14,
            selfLight: 5,
            trueSight: 0,
            roguery: false,
            faction: 1,
        };
        var strategies = objectiveFactory();
        var manager = new CharacterManager(tileSet, gameConfig, app, strategies, parent);

        var mainCharacter = manager.createCharacter(332, mainCharConfig);
        manager.main = mainCharacter;
        mainCharConfig = manager.main.config;

        return manager;
    }

    public function new(tileSet : Tileset_Ultima_5, gameConfig : WindowConfig, app : Pinnacle,
         strategies : Map<CharacterObjective, ObjectiveStrategy>, ?parent: Object) {
        super(parent);
        this.app = app;
        this.tileSet = tileSet;
        this.gameConfig = gameConfig;
        this.strategies = strategies;
    }

    public function addToParty(character : CharConfig) {
        trace("Adding character " + character.name);
        party.addToParty(character);
        app.updateData();
    }

    public function removeFromParty(character : CharConfig) {
        if (party.removeFromParty(character))
            app.updateData();
    }

    public function loadLocation(locationId : String) {
        for (charData in CastleData.characters.all) {
            if (charData.currentLocation.locationId.toString() == locationId) {
                addCharacter(charData.chartile.tileNo, {
                    charId: charData.charId.toString(), name: charData.name, faction: charData.faction.faction_int,
                    portrait: charData.portrait.resource,
                    settlement: charData.settlement.settlementId.toString(),
                    assignment: charData.assignment.assignmentNo,
                    home: charData.home.homeNo,
                    bed: charData.bed.homeNo,
                }, charData.x, charData.y, charData.z);
            }
        }
    }

    public function createCharacter(charTile: Int, charConfig : CharConfig, tileCount : Int = 4): Character {
        var charTileSet = [for (i in (0...tileCount)) tileSet.getTile(charTile + i)].filter((e) -> e != null);
        var character = new Character(charConfig.charId, charTileSet, gameConfig, charConfig, tileSet, this);
        return character;
    }

    public function addCharacter(charTile: Int, charConfig : CharConfig, x : Int, y : Int, z : Int): Character {
        charConfig.x = x;
        charConfig.y = y;
        charConfig.z = z;
        trace(charConfig);
        if (charConfig.charId == "Sara") {
            charConfig.debug = true;
        }
        var character = createCharacter(charTile, charConfig);
        addChild(character);
        character.hide();
        character.moveTo(x, y, z);
        characters.set(character.charId, character);
        var pos = hashCoord(x, y, z);
        characterLocations.set(pos, character.charId);
        return character;
    }

    public function getCharacterAt(x : Int, y : Int, z : Int) : Character {
        var pos = hashCoord(x, y, z);
        var charId = characterLocations.get(pos);
        if (charId == null) {
            return null;
        } else {
            return characters.get(charId);
        }
    }

    public function setLocation(charId : String, oPos : String, nPos : String) {
        characterLocations.remove(oPos);
        characterLocations.set(nPos, charId);
    }

    public function onResize() {
        for (character in characters) {
            character.moveTo(character.config.x, character.config.y, character.config.z);
        }
        main.moveTo(main.config.x, main.config.y, main.config.z);
    }

    public function dispatchEvent(event : CharacterEvent) {
        trace('dispatching event ${event}');
        for (character in characters) {
            character.addEvent(event);
        }
    }

    function drainStack(character : Character) : Null<CharacterDecision> {
        // TODO we need to add some priority to these so that we can handle situations where
        // the objective selection is more nuanced
        var result : Null<CharacterDecision> = null;
        for (i in 0...character.eventQueue.length) {
            var event = character.eventQueue.pop();
            switch (event) {
                case (CharacterEvent.Midnight):
                    character.currentObjective = CharacterObjective.Sleep;
                case (CharacterEvent.Internacht):
                    character.currentObjective = CharacterObjective.Sleep;
                case (CharacterEvent.Sunup):
                    character.currentObjective = CharacterObjective.GoHome;
                case (CharacterEvent.Morning):
                    character.currentObjective = CharacterObjective.GoWork;
                case (CharacterEvent.Noon):
                    character.currentObjective = CharacterObjective.GoWork;
                case (CharacterEvent.Afternoon):
                    character.currentObjective = CharacterObjective.GoWork;
                case (CharacterEvent.Sundown):
                    character.currentObjective = CharacterObjective.GoHome;
                case (CharacterEvent.Evening):
                    character.currentObjective = CharacterObjective.Sleep;
                case (CharacterEvent.Conversation):
                    result = CharacterDecision.Wait;
                case (CharacterEvent.Attacked):
                    character.currentEmergency = CharacterObjective.Fight;
                case (CharacterEvent.Hungry):
                    if (character.currentEmergency == null)
                        character.currentEmergency = CharacterObjective.FindFood;
                case (CharacterEvent.Tired):
                    if (character.currentEmergency == null)
                        character.currentEmergency = CharacterObjective.Sleep;
                case (CharacterEvent.Sick):
                    if (character.currentEmergency == null)
                        character.currentEmergency = CharacterObjective.Healing;
                case (CharacterEvent.Injured):
                    if (character.currentEmergency == null)
                        character.currentEmergency = CharacterObjective.Healing;
                default:
                    trace('unhandled event ${character.eventQueue.pop()}');
            }
        }
        return result;
    }

    public function determineDecision(character: Character, time : WorldTime, location : Location): CharacterDecision {
        var decision = drainStack(character);
        if (decision != null) return decision;
        var objective = character.currentEmergency;
        if (objective == null) objective = character.currentObjective;
        if (objective == null) objective = CharacterObjective.Idle;
        var strategy = strategies.get(objective);
        if (strategy == null) return CharacterDecision.Wait;
        return strategy.determine(character, this, location);
    }
}