// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "StudioNeeco/FlatGrass"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.37
		_MaxWindStrength("Max Wind Strength", Range( 0 , 1)) = 0.126967
		_WindSwinging("WindSwinging", Range( 0 , 1)) = 0.25
		_WindAmplitudeMultiplier("WindAmplitudeMultiplier", Float) = 1
		_ShadowRamp("ShadowRamp", 2D) = "white" {}
		_NormalMap("Normal Map", 2D) = "bump" {}
		_Albedo("Albedo", 2D) = "white" {}
		_BaseTextureColor("Base Texture Color", Color) = (0.509434,0.509434,0.509434,0)
		_ShadowScale("Shadow Scale", Range( 0 , 1)) = 0.5
		_RShadowIntensity("R Shadow Intensity", Range( 0 , 1)) = 0.5
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" }
		Cull Off
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma multi_compile_instancing
		#include "VS_InstancedIndirect.cginc"
		#pragma multi_compile GPU_FRUSTUM_ON __
		#pragma instancing_options assumeuniformscaling lodfade maxcount:50 procedural:setupScale forwardadd
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
			float3 worldNormal;
			INTERNAL_DATA
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float _MaxWindStrength;
		uniform float _WindStrength;
		uniform sampler2D _WindVectors;
		uniform float _WindAmplitudeMultiplier;
		uniform float _WindAmplitude;
		uniform float _WindSpeed;
		uniform float4 _WindDirection;
		uniform float _WindSwinging;
		uniform sampler2D _Albedo;
		uniform float4 _Albedo_ST;
		uniform float4 _BaseTextureColor;
		uniform sampler2D _ShadowRamp;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform float _ShadowScale;
		uniform float _RShadowIntensity;
		uniform float _Cutoff = 0.37;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float WindStrength522 = _WindStrength;
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float2 appendResult469 = (float2(_WindDirection.x , _WindDirection.z));
			float3 WindVector91 = UnpackNormal( tex2Dlod( _WindVectors, float4( ( ( ( (ase_worldPos).xz * 0.01 ) * _WindAmplitudeMultiplier * _WindAmplitude ) + ( ( ( _WindSpeed * 0.05 ) * _Time.w ) * appendResult469 ) ), 0, 0.0) ) );
			float3 break277 = WindVector91;
			float3 appendResult495 = (float3(break277.x , 0.0 , break277.y));
			float3 temp_cast_0 = (-1.0).xxx;
			float3 lerpResult249 = lerp( (float3( 0,0,0 ) + (appendResult495 - temp_cast_0) * (float3( 1,0,0 ) - float3( 0,0,0 )) / (float3( 1,0,0 ) - temp_cast_0)) , appendResult495 , _WindSwinging);
			float3 lerpResult74 = lerp( ( ( _MaxWindStrength * WindStrength522 ) * lerpResult249 ) , float3( 0,0,0 ) , ( 1.0 - v.color.r ));
			float3 Wind84 = lerpResult74;
			float3 break437 = Wind84;
			float3 appendResult391 = (float3(break437.x , 0.0 , break437.z));
			float3 ase_vertex3Pos = v.vertex.xyz;
			float3 VertexOffset330 = ( appendResult391 * ase_vertex3Pos.y );
			v.vertex.xyz += VertexOffset330;
			v.vertex.w = 1;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			#ifdef UNITY_PASS_FORWARDBASE
			float ase_lightAtten = data.atten;
			if( _LightColor0.a == 0)
			ase_lightAtten = 0;
			#else
			float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
			float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
			#endif
			#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
			half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
			float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
			float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
			ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
			#endif
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			float4 tex2DNode712 = tex2D( _Albedo, uv_Albedo );
			float alpha718 = tex2DNode712.a;
			float rim740 = 0.0;
			float4 albedo714 = ( _BaseTextureColor * tex2DNode712 );
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float3 normal706 = UnpackNormal( tex2D( _NormalMap, uv_NormalMap ) );
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult689 = dot( normalize( (WorldNormalVector( i , normal706 )) ) , ase_worldlightDir );
			float normal_lightdir694 = dotResult689;
			float2 temp_cast_0 = ((normal_lightdir694*_ShadowScale + _ShadowScale)).xx;
			float4 tex2DNode700 = tex2D( _ShadowRamp, temp_cast_0 );
			float4 shadow701 = ( albedo714 * tex2DNode700 );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			UnityGI gi723 = gi;
			float3 diffNorm723 = WorldNormalVector( i , normal706 );
			gi723 = UnityGI_Base( data, 1, diffNorm723 );
			float3 indirectDiffuse723 = gi723.indirect.diffuse + diffNorm723 * 0.0001;
			float4 temp_cast_2 = (_RShadowIntensity).xxxx;
			float4 lighting722 = ( shadow701 * pow( ( ase_lightColor * float4( ( indirectDiffuse723 + ase_lightAtten ) , 0.0 ) ) , temp_cast_2 ) );
			c.rgb = ( rim740 + lighting722 ).rgb;
			c.a = 1;
			clip( alpha718 - _Cutoff );
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
		}

		ENDCG
		CGPROGRAM
		#pragma exclude_renderers xbox360 psp2 n3ds wiiu 
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows exclude_path:deferred nolightmap  nodirlightmap dithercrossfade vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				UnityGI gi;
				UNITY_INITIALIZE_OUTPUT( UnityGI, gi );
				o.Alpha = LightingStandardCustomLighting( o, worldViewDir, gi ).a;
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18800
641;45;1039;984;-1002.455;1036.097;2.016762;True;True
Node;AmplifyShaderEditor.CommentaryNode;368;-5333.621,-617.4507;Inherit;False;2299.111;956.0105;Comment;18;91;410;222;298;221;72;297;79;520;469;75;308;384;69;67;77;319;383;Wind vectors;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;383;-5180.332,-172.7985;Float;False;Constant;_Float7;Float 7;19;0;Create;True;0;0;0;False;0;False;0.05;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;319;-5301.856,-272.3053;Float;False;Global;_WindSpeed;_WindSpeed;11;0;Create;True;0;0;0;False;0;False;0.5;0.094;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;77;-5190.033,-492.1619;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SwizzleNode;75;-4963.432,-492.1698;Inherit;False;FLOAT2;0;2;2;2;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;-4849.716,-219.3255;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TimeNode;69;-4975.215,-73.72457;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;308;-4960.62,123.9925;Float;False;Global;_WindDirection;_WindDirection;13;0;Create;True;0;0;0;False;0;False;1,0,0,0;0,0,-1,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;384;-4968.567,-380.5072;Float;False;Constant;_Float8;Float 8;19;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;520;-4638.779,-316.9297;Float;False;Global;_WindAmplitude;_WindAmplitude;20;0;Create;True;0;0;0;False;0;False;1;1.75;1;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;-4637.517,-118.8256;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;72;-4761.627,-496.2278;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;469;-4657.158,160.7638;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;297;-4634.901,-402.729;Float;False;Property;_WindAmplitudeMultiplier;WindAmplitudeMultiplier;4;0;Create;True;0;0;0;False;0;False;1;0.34;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;298;-4294.355,-452.7758;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;221;-4397.112,7.513467;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;222;-4090.91,-342.1855;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;410;-3907.902,-367.3049;Inherit;True;Global;_WindVectors;_WindVectors;1;2;[NoScaleOffset];[Normal];Create;True;0;0;0;False;0;False;-1;None;6c795dd1d1d319e479e68164001557e8;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;705;179.0612,1981.504;Inherit;True;Property;_NormalMap;Normal Map;6;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;706;480.1484,2038.179;Inherit;False;normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;369;-1720.892,-538.3197;Inherit;False;2670.73;665.021;Comment;16;277;248;16;83;249;66;70;74;84;385;408;495;500;521;522;687;Wind animations;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;91;-3512.528,-366.5786;Float;False;WindVector;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;521;-1660.365,-286.9055;Inherit;False;91;WindVector;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;708;1518.013,2009.841;Inherit;False;706;normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;697;1729.928,1927.767;Inherit;False;746.9364;407.3196;Comment;4;688;690;689;694;Normal.LightDir;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;688;1789.314,1977.767;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;690;1779.928,2156.086;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.BreakToComponentsNode;277;-1421.993,-291.0309;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;408;-986.638,-197.8045;Float;False;Constant;_Float14;Float 14;20;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;385;-649.6371,-393.2316;Float;False;Global;_WindStrength;_WindStrength;19;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;495;-1126.578,-294.3544;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;689;2014.559,2031.236;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;715;2873.404,1439.564;Inherit;False;837.2107;520.8698;Comment;4;711;712;713;714;Albedo;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;711;2969.454,1489.564;Inherit;False;Property;_BaseTextureColor;Base Texture Color;8;0;Create;True;0;0;0;False;0;False;0.509434,0.509434,0.509434,0;0.3374999,0.4049999,0.3097058,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;704;3738.358,1597.041;Inherit;False;1105.766;310.243;Comment;6;698;700;702;703;717;752;Shadow;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;694;2172.865,2053.736;Inherit;False;normal_lightdir;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;522;-421.2961,-399.7816;Float;False;WindStrength;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;248;-729.0991,-111.5008;Float;False;Property;_WindSwinging;WindSwinging;3;0;Create;True;0;0;0;False;0;False;0.25;0.471;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;687;-795.4694,-318.2836;Inherit;False;5;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;1,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;1,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-699.4681,-479.3216;Float;False;Property;_MaxWindStrength;Max Wind Strength;2;0;Create;True;0;0;0;False;0;False;0.126967;0.258;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;712;2923.404,1730.434;Inherit;True;Property;_Albedo;Albedo;7;0;Create;True;0;0;0;False;0;False;-1;None;ac8f5b43362a9482bb0c22af806d0a4f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;702;3788.358,1779.722;Inherit;False;Property;_ShadowScale;Shadow Scale;9;0;Create;True;0;0;0;False;0;False;0.5;0.428;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;698;3839.781,1647.041;Inherit;False;694;normal_lightdir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;728;2046.299,2729.064;Inherit;False;1137.955;571.3555;Comment;11;726;723;724;725;719;727;720;721;722;761;762;Lighting;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;249;-345.8907,-312.6119;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexColorNode;83;-68.49285,-259.7756;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;-67.49004,-457.2806;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;713;3302.421,1663.132;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;714;3486.615,1691.47;Inherit;False;albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;500;178.0528,-260.0242;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;199.9455,-400.6985;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;703;4091.194,1705.576;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;726;2096.299,3076.297;Inherit;False;706;normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;716;4453.734,1491.063;Inherit;False;714;albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;74;446.3538,-392.0356;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LightAttenuation;724;2246.42,3190.419;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;700;4308.652,1677.284;Inherit;True;Property;_ShadowRamp;ShadowRamp;5;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.IndirectDiffuseLighting;723;2277.94,3065.429;Inherit;False;Tangent;1;0;FLOAT3;0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;84;700.2378,-388.2877;Float;False;Wind;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;374;1187.574,-488.0728;Inherit;False;1330.308;567.8552;Comment;6;330;391;437;85;763;764;Vertex function layer blend;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;725;2508.356,3138.25;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LightColorNode;719;2198.926,2845.839;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;717;4801.494,1613.426;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;701;4953.238,1616.945;Inherit;False;shadow;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;762;2682.708,3214.505;Inherit;False;Property;_RShadowIntensity;R Shadow Intensity;10;0;Create;True;0;0;0;False;0;False;0.5;0.489;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;727;2622.04,3030.506;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;85;1319.229,-434.2046;Inherit;False;84;Wind;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PowerNode;761;2774.615,3108.98;Inherit;False;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;437;1700.013,-422.0683;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;720;2567.063,2779.064;Inherit;False;701;shadow;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;748;3284.773,2652.789;Inherit;False;1677.026;953.8582;Comment;17;732;735;730;731;736;738;733;737;740;729;742;734;744;745;746;747;749;Rim;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;721;2894.436,2825.181;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;391;2017.694,-425.0627;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;763;1936.216,-231.4086;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;740;4935.09,3133.463;Inherit;False;rim;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;235;1251.543,783.1223;Inherit;False;452.9371;811.1447;Final;4;99;206;331;750;Outputs;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;722;3043.652,2836.311;Inherit;False;lighting;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;764;2176.211,-368.5485;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;330;2299.029,-387.1858;Float;False;VertexOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;718;3343.768,1932.526;Inherit;False;alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;750;1429.357,960.7736;Inherit;False;740;rim;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;696;1708.42,2410.778;Inherit;False;665.3926;435.6716;Comment;4;691;692;693;695;Normal.ViewDir;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;206;1391.084,1036.619;Inherit;False;722;lighting;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;744;4075.896,2803.813;Inherit;False;694;normal_lightdir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;693;1985.995,2577.342;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;732;3697.773,2970.604;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;731;3534.773,2954.604;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;729;3334.773,3003.604;Inherit;False;695;normal_viewdir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;331;1472.476,1262.813;Inherit;False;330;VertexOffset;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;99;1447.84,829.9214;Inherit;False;718;alpha;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;752;4664.36,1767.614;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;751;1665.357,1025.774;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;730;3342.773,2899.604;Inherit;False;Constant;_RimOffset;Rim Offset;9;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;735;3842.774,3104.604;Inherit;False;Constant;_RimPower;Rim Power;0;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;736;4219.386,3262.647;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.LightAttenuation;745;4075.897,2702.789;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;695;2148.813,2540.336;Inherit;False;normal_viewdir;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;709;1493.218,2427.821;Inherit;False;706;normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;747;4429.313,3041.068;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;746;4314.682,2806.874;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;734;4126.768,2942.604;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;738;4437.386,3311.647;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;749;4597.517,3106.357;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;737;4210.386,3399.647;Inherit;False;Constant;_RimColor;Rim Color;0;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;742;4784.983,3121.581;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;692;1775.072,2662.449;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;691;1758.42,2460.778;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.OneMinusNode;733;3880.773,2952.604;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2704.745,921.4941;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;StudioNeeco/FlatGrass;False;False;False;False;False;False;True;False;True;False;False;False;True;False;False;False;True;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.37;True;True;0;True;Opaque;;AlphaTest;ForwardOnly;10;d3d9;d3d11_9x;d3d11;glcore;gles;gles3;metal;vulkan;xboxone;ps4;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;0;4;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;1;False;-1;1;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;3;Include;VS_InstancedIndirect.cginc;False;;Custom;Pragma;multi_compile GPU_FRUSTUM_ON __;False;;Custom;Pragma;instancing_options assumeuniformscaling lodfade maxcount:50 procedural:setupScale forwardadd;False;;Custom;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;75;0;77;0
WireConnection;67;0;319;0
WireConnection;67;1;383;0
WireConnection;79;0;67;0
WireConnection;79;1;69;4
WireConnection;72;0;75;0
WireConnection;72;1;384;0
WireConnection;469;0;308;1
WireConnection;469;1;308;3
WireConnection;298;0;72;0
WireConnection;298;1;297;0
WireConnection;298;2;520;0
WireConnection;221;0;79;0
WireConnection;221;1;469;0
WireConnection;222;0;298;0
WireConnection;222;1;221;0
WireConnection;410;1;222;0
WireConnection;706;0;705;0
WireConnection;91;0;410;0
WireConnection;688;0;708;0
WireConnection;277;0;521;0
WireConnection;495;0;277;0
WireConnection;495;2;277;1
WireConnection;689;0;688;0
WireConnection;689;1;690;0
WireConnection;694;0;689;0
WireConnection;522;0;385;0
WireConnection;687;0;495;0
WireConnection;687;1;408;0
WireConnection;249;0;687;0
WireConnection;249;1;495;0
WireConnection;249;2;248;0
WireConnection;66;0;16;0
WireConnection;66;1;522;0
WireConnection;713;0;711;0
WireConnection;713;1;712;0
WireConnection;714;0;713;0
WireConnection;500;0;83;1
WireConnection;70;0;66;0
WireConnection;70;1;249;0
WireConnection;703;0;698;0
WireConnection;703;1;702;0
WireConnection;703;2;702;0
WireConnection;74;0;70;0
WireConnection;74;2;500;0
WireConnection;700;1;703;0
WireConnection;723;0;726;0
WireConnection;84;0;74;0
WireConnection;725;0;723;0
WireConnection;725;1;724;0
WireConnection;717;0;716;0
WireConnection;717;1;700;0
WireConnection;701;0;717;0
WireConnection;727;0;719;0
WireConnection;727;1;725;0
WireConnection;761;0;727;0
WireConnection;761;1;762;0
WireConnection;437;0;85;0
WireConnection;721;0;720;0
WireConnection;721;1;761;0
WireConnection;391;0;437;0
WireConnection;391;2;437;2
WireConnection;722;0;721;0
WireConnection;764;0;391;0
WireConnection;764;1;763;2
WireConnection;330;0;764;0
WireConnection;718;0;712;4
WireConnection;693;0;691;0
WireConnection;693;1;692;0
WireConnection;731;0;730;0
WireConnection;752;0;700;0
WireConnection;751;0;750;0
WireConnection;751;1;206;0
WireConnection;695;0;693;0
WireConnection;747;0;746;0
WireConnection;747;1;734;0
WireConnection;746;0;745;0
WireConnection;746;1;744;0
WireConnection;734;0;733;0
WireConnection;738;0;736;0
WireConnection;749;0;747;0
WireConnection;742;0;749;0
WireConnection;691;0;709;0
WireConnection;733;0;732;0
WireConnection;0;10;99;0
WireConnection;0;13;751;0
WireConnection;0;11;331;0
ASEEND*/
//CHKSM=3D73A8A73BAA4770C955E8BD77997120D1086E95