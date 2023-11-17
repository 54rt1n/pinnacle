// src/Party.hx
package;

import Config;

class Party {
    public var members : Array<CharConfig>;
    public var food : Int;
    public var gold : Int;

    public function new() {
        members = new Array<CharConfig>();
        food = 0;
        gold = 0;
    }

    public function addGold(amount : Int) : Void {
        gold += amount;
    }

    public function addFood(amount : Int) : Void {
        food += amount;
    }

    public function removeGold(amount : Int) : Void {
        gold -= amount;
    }

    public function removeFood(amount : Int) : Void {
        food -= amount;
    }

    public function addToParty(character : CharConfig) : Bool {
        trace("Adding character " + character.name);
        members.push(character);
        return true;
    }

    public function removeFromParty(character : CharConfig) : Bool {
        var index = members.indexOf(character);
        if (index != -1) {
            members.splice(index, 1);
            return true;
        }
        return false;
    }

}