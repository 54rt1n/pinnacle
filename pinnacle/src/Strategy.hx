package ;

import CharacterManager;
import Location;
import Config;
import Pathfind;

enum CharacterObjective { 
    Idle;
    GoHome;
    GoWork;
    Sleep;
    FindFood;
    Fight;
    Healing;
}

enum CharacterDecision {
    Move(x : Int, y : Int, z : Int);
    Wait;
}

function objectiveFactory() : Map<CharacterObjective, ObjectiveStrategy> {
    var result = new Map<CharacterObjective, ObjectiveStrategy>();
    result.set(CharacterObjective.Idle, new IdleStrategy());
    result.set(CharacterObjective.GoHome, new GoHomeStrategy());
    result.set(CharacterObjective.GoWork, new GoWorkStrategy());
    result.set(CharacterObjective.Sleep, new SleepStrategy());
    result.set(CharacterObjective.FindFood, new FindFoodStrategy());
    result.set(CharacterObjective.Fight, new FightStrategy());
    result.set(CharacterObjective.Healing, new SleepStrategy());

    return result;
}

interface ObjectiveStrategy {
    public function determine(character: Character, manager : CharacterManager, location : Location) : CharacterDecision;
}

class IdleStrategy implements ObjectiveStrategy {
    public function new() {}

    public function determine(character: Character, manager : CharacterManager, location : Location) : CharacterDecision {
        var config = character.config;
        if (config.debug) {
            trace('${config.name} IdleStrategy');
        }
        var rolePoints = [
            [config.x + 1, config.y, config.z],
            [config.x - 1, config.y, config.z],
            [config.x, config.y + 1, config.z],
            [config.x, config.y - 1, config.z],
        ].filter((p) -> {
            var role = location.roleAt(p[0], p[1], p[2]);
            if (config.debug)
                trace('role at ${p[0]}, ${p[1]}, ${p[2]} is ${role}');
            return role == null || role == config.role || role == Role.Neutral;
        });

        var choices : Array<CharacterDecision> = [
            for (p in rolePoints) CharacterDecision.Move(p[0], p[1], p[2])
        ];
        choices.push(CharacterDecision.Wait);
        return choices[Math.floor(Math.random() * choices.length)];
    }
}

class GoHomeStrategy implements ObjectiveStrategy {
    public function new() {}

    function wander(character : Character, location : Location) {
        var coord = character.coord();
        var points = coord.getNeighbors(location).filter((c) -> {
            return location.isHome(c, character.config.home);
        });

        var choices : Array<CharacterDecision> = [
            for (p in points) CharacterDecision.Move(p.x, p.y, p.z)
        ];
        choices.push(CharacterDecision.Wait);
        return choices[Math.floor(Math.random() * choices.length)];
    }

    public function determine(character: Character, manager : CharacterManager, location : Location) : CharacterDecision {
        // TODO: Implement GoHomeStrategy logic
        if (character.config.debug)
            trace('${character.config.name} - GoHomeStrategy');
        var destination = location.getHomeFor(character.config.settlement, character.config.home);
        if (destination == null) {
            // trace('No bed found for ${character.config.name}');
            return CharacterDecision.Wait;
        } else {
            if (location.isHome(character.coord(), character.config.home))
                return wander(character, location);
            else if (destination.equals(character.coord()))
                return wander(character, location);
            else {
                var step = character.restep(destination, location);
                if (step != null)
                    return CharacterDecision.Move(step.x, step.y, step.z);
                else
                    return CharacterDecision.Wait;
            }
        }
    }
}

class SleepStrategy implements ObjectiveStrategy {
    public function new() {}

    public function log(character: Character, destination: Coordinate) {
        var items = "";
        for (step in character.currentPath)
            items += '(${step.x}, ${step.y}, ${step.z}),';
        if (character.config.debug)
            trace('destination (${destination.x}, ${destination.y}, ${destination.z}): $items');
    }

    public function determine(character: Character, manager : CharacterManager, location : Location) : CharacterDecision {
        // TODO: Implement GoHomeStrategy logic
        if (character.config.debug)
            trace('${character.config.name} - SleepStrategy');

        var destination = location.getBedFor(character.config.settlement, character.config.bed);
        if (destination == null) {
            // trace('No bed found for ${character.config.name}');
            return CharacterDecision.Wait;
        } else {
            if (destination.equals(character.coord())) {
                return CharacterDecision.Wait;
            }
            var step = character.restep(destination, location);
            if (step != null)
                return CharacterDecision.Move(step.x, step.y, step.z);
        }

        return CharacterDecision.Wait;
    }
}

class GoWorkStrategy implements ObjectiveStrategy {
    public function new() {}

    /* We have a few special assignemnts:
    Guest - 5
    Prisoner - 6
    Child - 7
    Homemaker - 8
    Socialite - 9
    */

    function wander(coord : Coordinate, workId : Int, location : Location) {
        var points = coord.getNeighbors(location).filter((c) -> {
            return workId == -1 || location.isWork(c, workId);
        });

        var choices : Array<CharacterDecision> = [
            for (p in points) CharacterDecision.Move(p.x, p.y, p.z)
        ];
        choices.push(CharacterDecision.Wait);
        return choices[Math.floor(Math.random() * choices.length)];
    }

    public function determine(character: Character, manager : CharacterManager, location : Location) : CharacterDecision {
        // TODO: Implement GoWorkStrategy logic
        if (character.config.debug)
            trace('${character.config.name} - GoWorkStrategy');
        var current = character.coord();
        var workId = character.config.assignment;
        var isOffice = workId < 5;
        if (isOffice)
            return wander(current, -1, location);
        var destination = location.getWorkFor(character.config.settlement, character.config.assignment);
        if (destination == null) {
            // trace('No bed found for ${character.config.name}');
            return CharacterDecision.Wait;
        } else {
            if (location.isWork(current, workId))
                return wander(current, workId, location);
            else if (destination.equals(current))
                return wander(current, workId, location);
            else {
                var step = character.restep(destination, location);
                if (step != null)
                    return CharacterDecision.Move(step.x, step.y, step.z);
                else
                    return CharacterDecision.Wait;
            }
        }
    }
}

class FindFoodStrategy implements ObjectiveStrategy {
    public function new() {}

    public function determine(character: Character, manager : CharacterManager, location : Location) : CharacterDecision {
        // TODO: Implement FindFoodStrategy logic
        if (character.config.debug)
            trace('${character.config.name} - FindFoodStrategy');
        return CharacterDecision.Wait; // return an appropriate decision based on the strategy
    }
}

class FightStrategy implements ObjectiveStrategy {
    public function new() {}

    public function determine(character: Character, manager : CharacterManager, location : Location) : CharacterDecision {
        // TODO: Implement FightStrategy logic
        if (character.config.debug)
            trace('${character.config.name} - FightStrategy');
        return CharacterDecision.Wait; // return an appropriate decision based on the strategy
    }
}