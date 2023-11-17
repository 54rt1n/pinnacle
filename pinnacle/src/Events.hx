package;

enum CharacterEvent {
    Midnight;
    Internacht;
    Sunup;
    Morning;
    Noon;
    Afternoon;
    Sundown;
    Evening;
    Conversation;
    Attacked;
    Hungry;
    Tired;
    Injured;
    Sick;
    Lonely;
    Angry;
    Depressed;
    Happy;
    Bored;
}

function getTimeEvent(tick : Int) : CharacterEvent {
    if (tick >= 1260) {
        return CharacterEvent.Evening;
    } else if (tick >= 1080) {
        return CharacterEvent.Sundown;
    } else if (tick >= 900) {
        return CharacterEvent.Afternoon;
    } else if (tick >= 720) {
        return CharacterEvent.Noon;
    } else if (tick >= 540) {
        return CharacterEvent.Morning;
    } else if (tick >= 360) {
        return CharacterEvent.Sunup;
    } else if (tick >= 180) {
        return CharacterEvent.Internacht;
    } else {
        return CharacterEvent.Midnight;
    }
}
