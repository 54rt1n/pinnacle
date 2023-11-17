// src/WorldTime.hx
package;

class WorldTime {
    public var ticks : Int;
    public var phase : Int;
    public var day : Int;
    public var dayTick : Int;
    public var hour : Int;
    public var minute : Int;

    public function new(ticks : Int = 0) {
        this.ticks = ticks;
        update();
    }

    public function advance() {
        ticks++;
        update();
    }

    function update() {
        day = Math.floor(ticks / 1440);
        dayTick = ticks % 1440;
        hour = Math.floor(minute / 60);
        minute = dayTick % 60;
        phase = Math.floor(day / 30);
    }
}
