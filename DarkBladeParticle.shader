// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "DarkBladeParticle"
{
	Properties
	{
		[Enum(Additive,1,Premultiply,10)]_Dst("Blend Mode", Int) = 1
		_SoftParticle("Soft Particle", Range( 0 , 3)) = 0
		_FadefromCenter("Fade from Center", Range( 0 , 1)) = 0
		_Fresnel("FresnelCulling", Range( 0 , 1)) = 0
		[HDR]_Color("Color Tint", Color) = (1,1,1,0)
		_MainTex("Base Color", 2D) = "white" {}
		_ScrollingBase("Scrolling Base", Vector) = (0,0,0,0)
		[HDR]_SecondaryTint("Secondary Tint", Color) = (1,1,1,1)
		_MainTex1("Secondary Color", 2D) = "white" {}
		_SecondaryStrength("Secondary Strength", Float) = 1
		_ScrollingSecondary("Scrolling Secondary", Vector) = (0,0,0,0)
		[Toggle(_MULTIPLYADDSECONDARY_ON)] _MultiplyAddSecondary("Multiply/Add Secondary", Float) = 0
		_Distortion("Distortion", 2D) = "bump" {}
		_DistortionStrength("Distortion Strength", Range( 0 , 5)) = 0
		_MultiplyStrengthbyAlpha("Multiply Strength by Alpha", Range( 0 , 1)) = 0
		[Toggle(_DISTORTSECONDARYCOLOR_ON)] _DistortSecondaryColor("Distort Secondary Color", Float) = 1
		[HideInInspector]_Src("Src", Int) = 1
		[Enum(Back,0,Front,1,Off,2)]_Culling("Culling", Int) = 0
		_MainTexTiling("Tiling", Vector) = (1,1,0,0)
		_MainTex1Tiling("Tiling", Vector) = (1,1,0,0)
		_MainTex1Offset("Offset", Vector) = (0,0,0,0)
		_MainTexOffset("Offset", Vector) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Custom"  "Queue" = "Transparent+0" "IsEmissive" = "true"  "PreviewType"="Plane" }
		Cull [_Culling]
		ZWrite Off
		Blend [_Src] [_Dst]
		
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#pragma target 3.0
		#pragma shader_feature_local _MULTIPLYADDSECONDARY_ON
		#pragma shader_feature_local _DISTORTSECONDARYCOLOR_ON
		#pragma surface surf Unlit keepalpha noshadow 
		struct Input
		{
			float2 uv_texcoord;
			float4 vertexColor : COLOR;
			float4 screenPos;
			float3 worldPos;
			float3 worldNormal;
			half ASEIsFrontFacing : VFACE;
			INTERNAL_DATA
		};

		uniform int _Dst;
		uniform int _Src;
		uniform int _Culling;
		uniform sampler2D _MainTex;
		uniform float2 _ScrollingBase;
		uniform float2 _MainTexTiling;
		uniform float2 _MainTexOffset;
		uniform sampler2D _Distortion;
		uniform float4 _Distortion_ST;
		uniform float _DistortionStrength;
		uniform float _MultiplyStrengthbyAlpha;
		uniform sampler2D _MainTex1;
		uniform float2 _ScrollingSecondary;
		uniform float2 _MainTex1Tiling;
		uniform float2 _MainTex1Offset;
		uniform float _SecondaryStrength;
		uniform float4 _SecondaryTint;
		uniform float4 _Color;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _SoftParticle;
		uniform float _Fresnel;
		uniform float _FadefromCenter;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_TexCoord10 = i.uv_texcoord * _MainTexTiling + _MainTexOffset;
			float2 panner9 = ( 1.0 * _Time.y * _ScrollingBase + uv_TexCoord10);
			float2 uv_Distortion = i.uv_texcoord * _Distortion_ST.xy + _Distortion_ST.zw;
			float3 tex2DNode33 = UnpackNormal( tex2D( _Distortion, uv_Distortion ) );
			float2 appendResult35 = (float2(tex2DNode33.r , tex2DNode33.g));
			float lerpResult46 = lerp( _DistortionStrength , ( _DistortionStrength * ( 1.0 - i.vertexColor.a ) ) , _MultiplyStrengthbyAlpha);
			float2 lerpResult36 = lerp( float2( 0,0 ) , appendResult35 , lerpResult46);
			float2 MainUV17 = ( panner9 + lerpResult36 );
			float4 tex2DNode5 = tex2D( _MainTex, MainUV17 );
			float2 uv_TexCoord23 = i.uv_texcoord * _MainTex1Tiling + _MainTex1Offset;
			float2 panner26 = ( 1.0 * _Time.y * _ScrollingSecondary + uv_TexCoord23);
			#ifdef _DISTORTSECONDARYCOLOR_ON
				float2 staticSwitch48 = ( panner26 + lerpResult36 );
			#else
				float2 staticSwitch48 = panner26;
			#endif
			float2 SecondaryUV27 = staticSwitch48;
			float temp_output_2_0_g3 = _SecondaryStrength;
			float temp_output_3_0_g3 = ( 1.0 - temp_output_2_0_g3 );
			float3 appendResult7_g3 = (float3(temp_output_3_0_g3 , temp_output_3_0_g3 , temp_output_3_0_g3));
			float4 temp_output_99_0 = ( float4( saturate( ( ( tex2D( _MainTex1, SecondaryUV27 ).rgb * temp_output_2_0_g3 ) + appendResult7_g3 ) ) , 0.0 ) * _SecondaryTint );
			#ifdef _MULTIPLYADDSECONDARY_ON
				float4 staticSwitch21 = ( tex2DNode5 + temp_output_99_0 );
			#else
				float4 staticSwitch21 = ( tex2DNode5 * temp_output_99_0 );
			#endif
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float screenDepth30 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth30 = abs( ( screenDepth30 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _SoftParticle ) );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = i.worldNormal;
			float3 switchResult57 = (((i.ASEIsFrontFacing>0)?(ase_worldNormal):(-ase_worldNormal)));
			float fresnelNdotV53 = dot( switchResult57, ase_worldViewDir );
			float fresnelNode53 = ( 0.0 + 1.1 * pow( 1.0 - fresnelNdotV53, 1.0 ) );
			float2 uv_TexCoord68 = i.uv_texcoord + float2( -0.5,-0.5 );
			float temp_output_70_0 = distance( uv_TexCoord68 , float2( 0,0 ) );
			float3 temp_cast_3 = (saturate( ( step( 0.0 , ( 1.0 - ( temp_output_70_0 * 2.0 ) ) ) * ( 1.0 - sin( ( temp_output_70_0 * UNITY_PI ) ) ) ) )).xxx;
			float temp_output_2_0_g1 = _FadefromCenter;
			float temp_output_3_0_g1 = ( 1.0 - temp_output_2_0_g1 );
			float3 appendResult7_g1 = (float3(temp_output_3_0_g1 , temp_output_3_0_g1 , temp_output_3_0_g1));
			float3 CenterFade90 = ( ( temp_cast_3 * temp_output_2_0_g1 ) + appendResult7_g1 );
			o.Emission = ( staticSwitch21 * tex2DNode5.a * _Color * _Color.a * i.vertexColor * i.vertexColor.a * saturate( distanceDepth30 ) * saturate( ( 1.0 - ( _Fresnel * fresnelNode53 ) ) ) * float4( CenterFade90 , 0.0 ) ).rgb;
			o.Alpha = ( tex2DNode5.a * i.vertexColor * i.vertexColor.a * float4( CenterFade90 , 0.0 ) ).r;
		}

		ENDCG
	}
	CustomEditor "DarkBladeParticleGUI"
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.VertexColorNode;8;-625.6832,400.7637;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;21;-16.14079,102.0434;Inherit;False;Property;_MultiplyAddSecondary;Multiply/Add Secondary;12;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-154.1815,69.44937;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;31;278.5002,602.8458;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;7;-673.4811,229.6759;Inherit;False;Property;_Color;Color Tint;5;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,0;0.8396226,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;55;245.4944,680.2267;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;64;217.0792,750.0762;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;513.4899,613.3717;Inherit;False;4;4;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;68;-958.8615,1868.25;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;-0.5,-0.5;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DistanceOpNode;70;-744.2474,1865.365;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;72;-579.2476,1957.365;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;3.14;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;84;-925.9961,1989.068;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;75;-450.2758,1958.857;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;85;-576.9961,1864.068;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;78;-448.2757,1862.857;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;87;-298.2757,1863.857;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;71;-297.5268,1957.118;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;86;-126.2758,1893.857;Inherit;True;2;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;89;74.90326,1915.632;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;88;272.4454,1867.526;Inherit;True;Lerp White To;-1;;1;047d7c189c36a62438973bad9d37b1c2;0;2;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;90;482.2702,1867.526;Inherit;False;CenterFade;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;91;-126.2267,2108.08;Inherit;False;Property;_FadefromCenter;Fade from Center;3;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;22;-1221.911,624.9152;Inherit;False;27;SecondaryUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;93;-996.1068,794.7756;Inherit;False;Property;_SecondaryStrength;Secondary Strength;10;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;97;-708.8131,677.5106;Inherit;False;Lerp White To;-1;;3;047d7c189c36a62438973bad9d37b1c2;0;2;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;98;-548.8635,674.8326;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FresnelNode;53;-922.0204,1338.079;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1.1;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-891.6328,1224.156;Inherit;False;Property;_Fresnel;FresnelCulling;4;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwitchByFaceNode;57;-1121.766,1358.283;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;58;-1620.88,1317.658;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NegateNode;59;-1375.18,1464.558;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;-633.2492,1340.897;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;54;-486.2689,1345.481;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;30;35.41813,603.1602;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-231.1863,617.8379;Inherit;False;Property;_SoftParticle;Soft Particle;2;0;Create;True;0;0;0;False;0;False;0;0;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;99;-408.5285,667.417;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;100;-707.6941,779.2053;Inherit;False;Property;_SecondaryTint;Secondary Tint;8;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StepOpNode;107;-2136.288,2038.698;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;108;-1877.425,1922.498;Inherit;True;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;105;-2141.288,1816.698;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;109;-2146.845,2261.524;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;110;-2122.73,2478.559;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;102;-2578.538,2171.96;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;101;-1559.481,2151.583;Inherit;True;Property;_TiledBaseColor;Tiled Base Color;18;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;92;205.7753,936.4565;Inherit;False;90;CenterFade;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;114;-1629.197,1963.626;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;115;-1751.987,2230.749;Inherit;False;Constant;_Float0;Float 0;22;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;113;-197.6815,765.6769;Inherit;False;112;TiledColor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;6;511.4178,337.7933;Inherit;False;9;9;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;4;COLOR;0,0,0,0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;20;-143.36,165.2227;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;112;-1291.065,2154.271;Inherit;False;TiledColor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;9;-2680.538,937.0906;Inherit;True;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;34;-2319.516,951.4175;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;17;-2099.456,952.7334;Inherit;False;MainUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.IntNode;62;83.6013,1351.626;Inherit;False;Property;_Dst;Blend Mode;1;1;[Enum];Create;False;0;2;Additive;1;Premultiply;10;0;True;0;False;1;10;False;0;1;INT;0
Node;AmplifyShaderEditor.IntNode;117;79.28522,1428.604;Inherit;False;Property;_Culling;Culling;19;1;[Enum];Create;False;0;3;Back;0;Front;1;Off;2;0;True;0;False;0;0;False;0;1;INT;0
Node;AmplifyShaderEditor.IntNode;61;78.20453,1269.749;Inherit;False;Property;_Src;Src;17;1;[HideInInspector];Create;True;0;0;0;True;0;False;1;1;False;0;1;INT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;23;-2917.901,1290.628;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;29;-2916.296,1416.797;Inherit;False;Property;_ScrollingSecondary;Scrolling Secondary;11;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.PannerNode;26;-2710.241,1344.719;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;48;-2422.401,1345.286;Inherit;False;Property;_DistortSecondaryColor;Distort Secondary Color;16;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;49;-2543.657,1406.118;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;35;-3815.766,1178.959;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;33;-4110.909,1179.216;Inherit;True;Property;_Distortion;Distortion;13;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;36;-3631.178,1157.824;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;38;-3834.799,1056.659;Inherit;False;Constant;_Vector0;Vector 0;11;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.LerpOp;46;-3972.915,1370.352;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;39;-4658.062,1362.587;Inherit;False;Property;_DistortionStrength;Distortion Strength;14;0;Create;True;0;0;0;False;0;False;0;0;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-4239.429,1423.687;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;41;-4550.525,1437.443;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;47;-4402.416,1531.378;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;40;-4524.106,1602.016;Inherit;False;Property;_MultiplyStrengthbyAlpha;Multiply Strength by Alpha;15;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;27;-2132.075,1341.015;Inherit;False;SecondaryUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;5;-755.327,41.20546;Inherit;True;Property;_MainTex;Base Color;6;0;Create;False;0;0;0;False;0;False;-1;None;4b1a9ab11cb7da447b1297087c4b2379;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;15;-1019.267,601.6767;Inherit;True;Property;_MainTex1;Secondary Color;9;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;14;-2884.908,1049.42;Inherit;False;Property;_ScrollingBase;Scrolling Base;7;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;10;-2926.435,935.9621;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;660.5747,360.2228;Float;False;True;-1;2;DarkBladeParticleGUI;0;0;Unlit;DarkBladeParticle;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;2;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;False;0;True;Custom;;Transparent;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;False;1;1;True;_Src;1;True;_Dst;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;1;PreviewType=Plane;False;0;0;True;_Culling;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.GetLocalVarNode;18;-1001.87,64.87761;Inherit;False;17;MainUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;122;-3408.718,993.5678;Inherit;False;Property;_MainTexOffset;Offset;23;0;Create;False;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;121;-3406.045,867.9704;Inherit;False;Property;_MainTexTiling;Tiling;20;0;Create;False;0;0;0;False;0;False;1,1;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;123;-3375.977,1395.026;Inherit;False;Property;_MainTex1Offset;Offset;22;0;Create;False;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;124;-3372.029,1268.155;Inherit;False;Property;_MainTex1Tiling;Tiling;21;0;Create;False;0;0;0;False;0;False;1,1;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
WireConnection;21;1;16;0
WireConnection;21;0;20;0
WireConnection;16;0;5;0
WireConnection;16;1;99;0
WireConnection;31;0;30;0
WireConnection;55;0;54;0
WireConnection;63;0;5;4
WireConnection;63;1;64;0
WireConnection;63;2;64;4
WireConnection;63;3;92;0
WireConnection;70;0;68;0
WireConnection;72;0;70;0
WireConnection;72;1;84;0
WireConnection;75;0;72;0
WireConnection;85;0;70;0
WireConnection;78;0;85;0
WireConnection;87;1;78;0
WireConnection;71;0;75;0
WireConnection;86;0;87;0
WireConnection;86;1;71;0
WireConnection;89;0;86;0
WireConnection;88;1;89;0
WireConnection;88;2;91;0
WireConnection;90;0;88;0
WireConnection;97;1;15;0
WireConnection;97;2;93;0
WireConnection;98;0;97;0
WireConnection;53;0;57;0
WireConnection;57;0;58;0
WireConnection;57;1;59;0
WireConnection;59;0;58;0
WireConnection;56;0;52;0
WireConnection;56;1;53;0
WireConnection;54;0;56;0
WireConnection;30;0;32;0
WireConnection;99;0;98;0
WireConnection;99;1;100;0
WireConnection;107;0;102;2
WireConnection;108;0;105;0
WireConnection;108;1;107;0
WireConnection;108;2;109;0
WireConnection;108;3;110;0
WireConnection;105;0;102;1
WireConnection;109;1;102;1
WireConnection;110;1;102;2
WireConnection;101;1;114;0
WireConnection;101;0;115;0
WireConnection;114;0;108;0
WireConnection;6;0;21;0
WireConnection;6;1;5;4
WireConnection;6;2;7;0
WireConnection;6;3;7;4
WireConnection;6;4;8;0
WireConnection;6;5;8;4
WireConnection;6;6;31;0
WireConnection;6;7;55;0
WireConnection;6;8;92;0
WireConnection;20;0;5;0
WireConnection;20;1;99;0
WireConnection;112;0;101;0
WireConnection;9;0;10;0
WireConnection;9;2;14;0
WireConnection;34;0;9;0
WireConnection;34;1;36;0
WireConnection;17;0;34;0
WireConnection;23;0;124;0
WireConnection;23;1;123;0
WireConnection;26;0;23;0
WireConnection;26;2;29;0
WireConnection;48;1;26;0
WireConnection;48;0;49;0
WireConnection;49;0;26;0
WireConnection;49;1;36;0
WireConnection;35;0;33;1
WireConnection;35;1;33;2
WireConnection;36;0;38;0
WireConnection;36;1;35;0
WireConnection;36;2;46;0
WireConnection;46;0;39;0
WireConnection;46;1;45;0
WireConnection;46;2;40;0
WireConnection;45;0;39;0
WireConnection;45;1;47;0
WireConnection;47;0;41;4
WireConnection;27;0;48;0
WireConnection;5;1;18;0
WireConnection;15;1;22;0
WireConnection;10;0;121;0
WireConnection;10;1;122;0
WireConnection;0;2;6;0
WireConnection;0;9;63;0
ASEEND*/
//CHKSM=A881FBE41EF47936BE64B52D3330031ED7708AC7