#ifndef UNITY_ENTITY_LIGHTING_INCLUDED
#define UNITY_ENTITY_LIGHTING_INCLUDED

#include "common.hlsl"

// TODO: Check if PI is correctly handled!

// Ref: "Efficient Evaluation of Irradiance Environment Maps" from ShaderX 2
float3 SHEvalLinearL0L1(float3 N, float4 shAr, float4 shAg, float4 shAb)
{
	float4 vA = float4(N, 1.0);

	float3 x1;
	// Linear (L1) + constant (L0) polynomial terms
	x1.r = dot(shAr, vA);
	x1.g = dot(shAg, vA);
	x1.b = dot(shAb, vA);

	return x1;
}

float3 SHEvalLinearL2(float3 N, float4 shBr, float4 shBg, float4 shBb, float4 shC)
{
	float3 x2;
	// 4 of the quadratic (L2) polynomials
	float4 vB = N.xyzz * N.yzzx;
	x2.r = dot(shBr, vB);
	x2.g = dot(shBg, vB);
	x2.b = dot(shBb, vB);

	// Final (5th) quadratic (L2) polynomial
	float vC = N.x * N.x - N.y * N.y;
	float3 x3 = shC.rgb * vC;

	return x2 + x3;
}

float3 SampleSH9(float4 SHCoefficients[7], float3 N)
{
	float4 shAr = SHCoefficients[0];
	float4 shAg = SHCoefficients[1];
	float4 shAb = SHCoefficients[2];
	float4 shBr = SHCoefficients[3];
	float4 shBg = SHCoefficients[4];
	float4 shBb = SHCoefficients[5];
	float4 shCr = SHCoefficients[6];
	
	// Linear + constant polynomial terms
	float3 res = SHEvalLinearL0L1(N, shAr, shAg, shAb);

	// Quadratic polynomials
	res += SHEvalLinearL2(N, shBr, shBg, shBb, shCr);

	return res;
}

// This sample a 3D volume storing SH
// Volume is store as 3D texture with 4 R, G, B, X set of 4 coefficient store atlas in same 3D texture. X unused.
// TODO: the packing here is innefficient as we will fetch values far away from each other and they may not fit into the cache
// Suggest we pack only RGB not X and continuous
float3 SampleProbeVolumeSH4(TEXTURE3D_ARGS(SHVolumeTexture, SHVolumeSampler), float3 positionWS, float3 normalWS, float4x4 WorldToTexture, float texelSizeX)
{
	float3 texCoord = mul(WorldToTexture, float4(positionWS, 1.0)).xyz;
	// Each component is store in the same texture 3D. Each use one quater on the x axis
	// Here we get R component then increase by step size (0.25) to get other component. This assume 4 component
	// but last one is not used.
	// Clamp to edge of the "internal" texture, as R is from half texel to size of R texture minus half texel.
	// This avoid leaking
	texCoord.x = Clamp(texCoord.x * 0.25, 0.5 * texelSizeX, 0.25 - 0.5 * texelSizeX);

	float4 shAr = SAMPLE_TEXTURE3D(SHVolumeTexture, SHVolumeSampler, texCoord);
	texCoord.x += 0.25;
	float4 shAg = SAMPLE_TEXTURE3D(SHVolumeTexture, SHVolumeSampler, texCoord);
	texCoord.x += 0.25;
	float4 shAb = SAMPLE_TEXTURE3D(SHVolumeTexture, SHVolumeSampler, texCoord);

	return SHEvalLinearL0L1(normalWS, shAr, shAg, shAb);
}

// Following functions are to sample enlighten lightmaps (or lightmaps encoded the same way as our
// enlighten implementation). They assume use of RGB9E5 for illuminance map.
// It is required for other platform that aren't supporting this format to implement variant of these functions
// (But these kind of platform should use regular render loop and not news shaders).

float3 SampleSingleLightmap(TEXTURE2D_ARGS(lightmapTex, lightmapSampler), float2 uv, float4 transform)
{
	// transform is scale and bias
	uv = uv * transform.xy + transform.zw;
	// Remark: Lightmap is RGB9E5
	return SAMPLE_TEXTURE2D(lightmapTex, lightmapSampler, uv).rgb;
}

float3 SampleDirectionalLightmap(TEXTURE2D_ARGS(lightmapTex, lightmapSampler), TEXTURE2D_ARGS(lightmapDirTex, lightmapDirSampler), float2 uv, float4 transform, float3 normalWS)
{
	// In directional mode Enlighten bakes dominant light direction
	// in a way, that using it for half Lambert and then dividing by a "rebalancing coefficient"
	// gives a result close to plain diffuse response lightmaps, but normalmapped.

	// Note that dir is not unit length on purpose. Its length is "directionality", like
	// for the directional specular lightmaps.

	// transform is scale and bias
	uv = uv * transform.xy + transform.zw;

	float4 direction = SAMPLE_TEXTURE2D(lightmapDirTex, lightmapDirSampler, uv);
	// Remark: Lightmap is RGB9E5
	float3 illuminance = SAMPLE_TEXTURE2D(lightmapTex, lightmapSampler, uv).rgb;
	float halfLambert = dot(normalWS, direction.xyz - 0.5) + 0.5;
	return illuminance * halfLambert / max(1e-4, direction.w);
}

#endif // UNITY_ENTITY_LIGHTING_INCLUDED