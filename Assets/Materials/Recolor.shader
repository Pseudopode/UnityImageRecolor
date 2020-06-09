Shader "Unlit/Recolor"
{
   Properties {
      _MainTex ("Texture Image", 2D) = "white" {}
      _MaskTex ("Mask Image", 2D) = "white" {}
      _NewColor("New color for recolorization", Color) = (0.5,0.5,0.5,1)
   }
   SubShader {
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

         float4 frag(vertexOutput input) : COLOR
         {
			 //input texture file
            float4 inputColor = tex2D(_MainTex, input.tex.xy);
			//input mask
            float4 maskVec = tex2D(_MaskTex, input.tex.xy);

            //mask gray value is equivalent to one of the mask channel (since R=G=B for the mask)
            float mask = maskVec.x;

			//grayscale value of the input image. Average of the 3 channels. /!\ NOT REALISTIC!
            float grayVal = (inputColor.x + inputColor.y + inputColor.z)/3.0;

            float beautyMinusProductR = inputColor.x * (1.0 - mask);
            float beautyMinusProductG = inputColor.y * (1.0 - mask);
            float beautyMinusProductB = inputColor.z * (1.0 - mask);

            float4 beautyMinusProduct = float4(beautyMinusProductR,beautyMinusProductG,beautyMinusProductB,1.0);

            float productGrayR = grayVal * mask;
            float productGrayG = productGrayR;
            float productGrayB = productGrayR;

            float4 productGray = float4(productGrayR, productGrayG, productGrayB, 1.0);

            
            //return maskVec;

            float productRGBR = productGrayR * _NewColor.x;
            float productRGBG = productGrayG * _NewColor.y;
            float productRGBB = productGrayB * _NewColor.z;

            float4 productRGB = float4(productRGBR,productRGBG,productRGBB,1.0);

            float finalR = beautyMinusProductR 
                            + productRGBR
                            ;
            float finalG = beautyMinusProductG
            + productRGBG
                            ;
            float finalB = beautyMinusProductB
            + productRGBB
                            ;

            float4 finalRGB = beautyMinusProduct + productRGB;
                
            //float4 finalColor = float4(finalR, finalG, finalB, 1.0);

            //gl_FragColor = vec4(inputRGB_r,inputRGB_g,inputRGB_b,1.0) ;
            //gl_FragColor = float4(inputRGB_r,0.0,0.0,1.0) ;
            return float4(finalR,finalG,finalB,1.0) ;
            //gl_FragColor = finalColor;
            //return finalRGB;
         }
 
         ENDCG
      }
   }
   Fallback "Unlit/Texture"
}
