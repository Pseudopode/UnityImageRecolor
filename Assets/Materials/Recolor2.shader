Shader "Unlit/Recolor2"
{
	Properties{
	   _MainTex("Texture Image", 2D) = "white" {}
	   _MaskTex("Mask Image", 2D) = "white" {}
	   _NewColor("New color for recolorization", Color) = (0.5,0.5,0.5,1)
	}
		SubShader{
		   Pass {
			  CGPROGRAM

			  #pragma vertex vert  
			  #pragma fragment frag 

			  uniform sampler2D _MainTex;
			  uniform sampler2D _MaskTex;

			  uniform float4 _NewColor;

			  struct vertexInput {
				 float4 vertex : POSITION;
				 float4 texcoord : TEXCOORD0;
			  };
			  struct vertexOutput {
				 float4 pos : SV_POSITION;
				 float4 tex : TEXCOORD0;
			  };

			  vertexOutput vert(vertexInput input)
			  {
				 vertexOutput output;

				 output.tex = input.texcoord;
				 output.pos = UnityObjectToClipPos(input.vertex);
				 return output;
			  }

			  float3 RGBToHSL(float3 color)
			  {
				 float3 hsl; // init to 0 to avoid warnings ? (and reverse if + remove first part)

				 float fmin = min(min(color.r, color.g), color.b);    //Min. value of RGB
				 float fmax = max(max(color.r, color.g), color.b);    //Max. value of RGB
				 float delta = fmax - fmin;             //Delta RGB value

				 hsl.z = (fmax + fmin) / 2.0; // Luminance

				 if (delta == 0.0)		//This is a gray, no chroma...
				 {
					hsl.x = 0.0;	// Hue
					hsl.y = 0.0;	// Saturation
				 }
				 else                                    //Chromatic data...
				 {
					if (hsl.z < 0.5)
					   hsl.y = delta / (fmax + fmin); // Saturation
					else
					   hsl.y = delta / (2.0 - fmax - fmin); // Saturation

					float deltaR = (((fmax - color.r) / 6.0) + (delta / 2.0)) / delta;
					float deltaG = (((fmax - color.g) / 6.0) + (delta / 2.0)) / delta;
					float deltaB = (((fmax - color.b) / 6.0) + (delta / 2.0)) / delta;

					if (color.r == fmax)
					   hsl.x = deltaB - deltaG; // Hue
					else if (color.g == fmax)
					   hsl.x = (1.0 / 3.0) + deltaR - deltaB; // Hue
					else if (color.b == fmax)
					   hsl.x = (2.0 / 3.0) + deltaG - deltaR; // Hue

					if (hsl.x < 0.0)
					   hsl.x += 1.0; // Hue
					else if (hsl.x > 1.0)
					   hsl.x -= 1.0; // Hue
				 }

				 return hsl;
			  }

			  float HueToRGB(float f1, float f2, float hue)
			  {
				 if (hue < 0.0)
					hue += 1.0;
				 else if (hue > 1.0)
					hue -= 1.0;
				 float res;
				 if ((6.0 * hue) < 1.0)
					res = f1 + (f2 - f1) * 6.0 * hue;
				 else if ((2.0 * hue) < 1.0)
					res = f2;
				 else if ((3.0 * hue) < 2.0)
					res = f1 + (f2 - f1) * ((2.0 / 3.0) - hue) * 6.0;
				 else
					res = f1;
				 return res;
			  }

			  float3 HSLToRGB(float3 hsl)
			  {
				 float3 rgb;

				 if (hsl.y == 0.0)
					rgb = float3(hsl.z,hsl.z,hsl.z); // Luminance
				 else
				 {
					float f2;

					if (hsl.z < 0.5)
					   f2 = hsl.z * (1.0 + hsl.y);
					else
					   f2 = (hsl.z + hsl.y) - (hsl.y * hsl.z);

					float f1 = 2.0 * hsl.z - f2;

					rgb.r = HueToRGB(f1, f2, hsl.x + (1.0 / 3.0));
					rgb.g = HueToRGB(f1, f2, hsl.x);
					rgb.b = HueToRGB(f1, f2, hsl.x - (1.0 / 3.0));
				 }

				 return rgb;
			  }

			  //from https://mouaif.wordpress.com/2009/01/05/photoshop-math-with-glsl-shaders/
			  //Could also be found in glfx.js
			  // Color Mode keeps the brightness of the base color and applies both the hue and saturation of the blend color.
			  float3 BlendColor(float3 base, float3 blend)
			  {
				 float3 blendHSL = RGBToHSL(blend);
				 return HSLToRGB(float3(blendHSL.r, blendHSL.g, RGBToHSL(base).b));
			  }

			  float4 frag(vertexOutput input) : COLOR
			  {
				 float4 inputColor = tex2D(_MainTex, input.tex.xy);

				 float4 mask = tex2D(_MaskTex, input.tex.xy);

				 float grayVal = (inputColor.x + inputColor.y + inputColor.z) / 3.0;

				 float4 beautyMinusProduct = inputColor * (1.0 - mask);

				 float4 productGray = mask * grayVal;

				 float newColorLightness = 1.0;

				 float3 blendedRGB = BlendColor(productGray,_NewColor);

				 return float4(blendedRGB + beautyMinusProduct.rgb,1.0);

				 //return beautyMinusProduct;
			  }

			  ENDCG
		   }
	   }
		   Fallback "Unlit/Texture"
}
