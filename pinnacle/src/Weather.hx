package;

enum WeatherType {
    Sunny; Cloudy; Rainy; Snowy; Scorching;
}

class Weather {
    public var currentWeather : WeatherType;

    public function new () {
        currentWeather = WeatherType.Sunny;
    }
}