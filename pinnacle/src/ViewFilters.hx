// src/Filters.hx
package;

import h2d.filter.Group;
import h2d.filter.Shader;
import h2d.filter.Filter;

class InvertColorShader extends h3d.shader.ScreenShader {
	static var SRC = {
		@param var texture : Sampler2D;

		function fragment() {
			var pixel : Vec4 = texture.get(calculatedUV);
			// Premultiply alpha to ensure correct transparency.
			pixelColor = vec4((1. - pixel.rgb) * pixel.a, pixel.a);
			// Some other filters directly assign `output.color` and fetch from `input.uv`.
			// While it will work, it does not work well when multiple shaders in one filter are involved.
			// In this case use `calculatedUV` and `pixelColor`.
		}
	}
}

class RedColorShader extends h3d.shader.ScreenShader {
	static var SRC = {
		@param var texture : Sampler2D;

		function fragment() {
			var pixel : Vec4 = texture.get(calculatedUV);
			// Premultiply alpha to ensure correct transparency.
			pixelColor = vec4(pixel.r * 2.6, pixel.g, pixel.b, pixel.a);
		}
	}
}

class BlueColorShader extends h3d.shader.ScreenShader {
	static var SRC = {
		@param var texture : Sampler2D;

		function fragment() {
			var pixel : Vec4 = texture.get(calculatedUV);
			// Premultiply alpha to ensure correct transparency.
			pixelColor = vec4(pixel.r * 0.5, pixel.g * 0.5, pixel.b * 1.6, pixel.a);
		}
	}
}

class TransparentShader extends h3d.shader.ScreenShader {
	static var SRC = {
		@param var texture : Sampler2D;

		function fragment() {
			var pixel : Vec4 = texture.get(calculatedUV);
			// Premultiply alpha to ensure correct transparency.
			pixelColor = vec4(pixel.r, pixel.g, pixel.b * 2.0, pixel.a * 0.25);
		}
	}
}

class GreenColorShader extends h3d.shader.ScreenShader {
	static var SRC = {
		@param var texture : Sampler2D;

		function fragment() {
			var pixel : Vec4 = texture.get(calculatedUV);
			// Premultiply alpha to ensure correct transparency.
			pixelColor = vec4(pixel.r, pixel.g * 1.6, pixel.b, pixel.a);
		}
	}
}

class TwilightShader extends h3d.shader.ScreenShader {
	static var SRC = {
		@param var texture : Sampler2D;

		function fragment() {
			var pixel : Vec4 = texture.get(calculatedUV);
			// Premultiply alpha to ensure correct transparency.
			pixelColor = vec4(pixel.r * 0.8, pixel.g * 0.8, pixel.b * 0.8, pixel.a);
		}
	}
}

class NightShader extends h3d.shader.ScreenShader {
	static var SRC = {
		@param var texture : Sampler2D;

		function fragment() {
			var pixel : Vec4 = texture.get(calculatedUV);
			// Premultiply alpha to ensure correct transparency.
			pixelColor = vec4(pixel.r * 0.5, pixel.g * 0.5, pixel.b * 0.5, pixel.a);
		}
	}
}

class ViewFilters {
    public var battle : Filter;
    public var magic : Filter;
    public var phased : Filter;
    public var rogue : Filter;
    public var chaos: Filter;
	public var twilight : Filter;
	public var night : Filter;

    public var view : Group;
    public var chars : Group;
    public var main : Group;

    public function new() {
        battle = new Shader<RedColorShader>(new RedColorShader(), "texture");
        battle.enable = false;
        magic = new Shader<BlueColorShader>(new BlueColorShader(), "texture");
        magic.enable = false;
        phased = new Shader<TransparentShader>(new TransparentShader(), "texture");
        phased.enable = false;
        rogue = new Shader<GreenColorShader>(new GreenColorShader(), "texture");
        rogue.enable = false;
        chaos = new Shader<InvertColorShader>(new InvertColorShader(), "texture");
        chaos.enable = false;
		twilight = new Shader<TwilightShader>(new TwilightShader(), "texture");
		twilight.enable = false;
		night = new Shader<NightShader>(new NightShader(), "texture");
		night.enable = false;
		var viewArray : Array<Filter> = [magic, chaos, twilight, night];
        //view = new Group();
		//chars = new Group([battle, rogue, chaos, twilight, night]);
		//main = new Group([phased, chaos, twilight, night]);
    }
}
