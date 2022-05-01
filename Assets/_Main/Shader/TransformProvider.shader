Shader "Raymarching/TransformProvider"
{

Properties
{
    [Header(PBS)]
    _Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
    _Metallic("Metallic", Range(0.0, 1.0)) = 0.5
    _Glossiness("Smoothness", Range(0.0, 1.0)) = 0.5

    [Header(Pass)]
    [Enum(UnityEngine.Rendering.CullMode)] _Cull("Culling", Int) = 2

    [Toggle][KeyEnum(Off, On)] _ZWrite("ZWrite", Float) = 1

    [Header(Raymarching)]
    _Loop("Loop", Range(1, 100)) = 30
    _MinDistance("Minimum Distance", Range(0.001, 0.1)) = 0.01
    _DistanceMultiplier("Distance Multiplier", Range(0.001, 2.0)) = 1.0
    _ShadowLoop("Shadow Loop", Range(1, 100)) = 30
    _ShadowMinDistance("Shadow Minimum Distance", Range(0.001, 0.1)) = 0.01
    _ShadowExtraBias("Shadow Extra Bias", Range(0.0, 0.1)) = 0.0
    [PowerSlider(10.0)] _NormalDelta("NormalDelta", Range(0.00001, 0.1)) = 0.0001

// @block Properties
[Header(Additional Parameters)]

[Header(Float Parameters)]
_Smooth("Smooth", float) = 17.5
    
[Header(Color Parameters)]
_HeadColor("Head Color", Color) = (1.0, 1.0, 1.0, 1.0)
_TorsoUpperColor("TorsoUpper Color", Color) = (1.0, 1.0, 1.0, 1.0)
_TorsoMidColor("TorsoMid Color", Color) = (1.0, 1.0, 1.0, 1.0)
_TorsoLowerColor("TorsoLower Color", Color) = (1.0, 1.0, 1.0, 1.0)
_TorsoMidExtraColor("TorsoMidExtra Color", Color) = (1.0, 1.0, 1.0, 1.0)
_LeftArmUpperColor("LeftArmUpper Color", Color) = (1.0, 1.0, 1.0, 1.0)
_LeftArmMidColor("LeftArmMid Color", Color) = (1.0, 1.0, 1.0, 1.0)
_LeftArmLowerColor("LeftArmLower Color", Color) = (1.0, 1.0, 1.0, 1.0)
_RightArmUpperColor("RightArmUpper Color", Color) = (1.0, 1.0, 1.0, 1.0)
_RightArmMidColor("RightArmMid Color", Color) = (1.0, 1.0, 1.0, 1.0)
_RightArmLowerColor("RightArmLower Color", Color) = (1.0, 1.0, 1.0, 1.0)
_LeftLegUpperColor("LeftLegUpper Color", Color) = (1.0, 1.0, 1.0, 1.0)
_LeftLegLowerColor("LeftLegLower Color", Color) = (1.0, 1.0, 1.0, 1.0)
_LeftLegMidColor("LeftLegMid Color", Color) = (1.0, 1.0, 1.0, 1.0)
_RightLegUpperColor("RightLegUpper Color", Color) = (1.0, 1.0, 1.0, 1.0)
_RightLegLowerColor("RightLegLower Color", Color) = (1.0, 1.0, 1.0, 1.0)
_RightLegMidColor("RightLegMid Color", Color) = (1.0, 1.0, 1.0, 1.0)
// @endblock
}

SubShader
{

Tags
{
    "RenderType" = "Opaque"
    "Queue" = "Geometry"
    "DisableBatching" = "True"
}

Cull [_Cull]

CGINCLUDE

#define WORLD_SPACE

#define OBJECT_SHAPE_CUBE

#define USE_RAYMARCHING_DEPTH

#define SPHERICAL_HARMONICS_PER_PIXEL

#define DISTANCE_FUNCTION DistanceFunction
#define PostEffectOutput SurfaceOutputStandard
#define POST_EFFECT PostEffect

#include "Assets\uRaymarching\Shaders\Include\Legacy/Common.cginc"

// @block DistanceFunction
// These inverse transform matrices are provided
// from TransformProvider script
float4x4 _Head;
float4x4 _TorsoUpper;
float4x4 _TorsoMid;
float4x4 _TorsoLower;
float4x4 _TorsoMidExtra;
float4x4 _LeftArmUpper;
float4x4 _LeftArmMid;
float4x4 _LeftArmLower;
float4x4 _RightArmUpper;
float4x4 _RightArmMid;
float4x4 _RightArmLower;
float4x4 _LeftLegUpper;
float4x4 _LeftLegLower;
float4x4 _LeftLegMid;
float4x4 _RightLegUpper;
float4x4 _RightLegLower;
float4x4 _RightLegMid;

float _Smooth;

// Global Variables

    float4 headPos;
    float4 torsoUpperPos;
    float4 torsoMidPos;
    float4 torsoLowerPos;
    float4 torsoMidExtraPos;
    float4 leftArmUpperPos; 
    float4 leftArmMidPos;
    float4 leftArmLowerPos;
    float4 rightArmUpperPos;
    float4 rightArmMidPos;
    float4 rightArmLowerPos;
    float4 leftLegUpperPos; 
    float4 leftLegLowerPos; 
    float4 leftLegMidPos;
    float4 rightLegUpperPos;
    float4 rightLegLowerPos;
    float4 rightLegMidPos;

    float head;
    float torsoUpper;
    float torsoMid;
    float torsoLower; 
    float torsoMidExtra;
    
    float leftArmUpper; 
    float leftArmMid; 
    float leftArmLower;
    
    float rightArmUpper;
    float rightArmMid;
    float rightArmLower;
    
    float leftLegUpper;
    float leftLegLower;
    float leftLegMid;
    
    float rightLegUpper;
    float rightLegLower;
    float rightLegMid;

inline float DistanceFunction(float3 wpos)
{
    headPos = mul(_Head, float4(wpos, 1.0));
    torsoUpperPos = mul(_TorsoUpper, float4(wpos, 1.0));
    torsoMidPos = mul(_TorsoMid, float4(wpos, 1.0));
    torsoLowerPos = mul(_TorsoLower, float4(wpos, 1.0));
    torsoMidExtraPos = mul(_TorsoMidExtra, float4(wpos, 1.0));
    leftArmUpperPos = mul(_LeftArmUpper, float4(wpos, 1.0));
    leftArmMidPos = mul(_LeftArmMid, float4(wpos, 1.0));
    leftArmLowerPos = mul(_LeftArmLower, float4(wpos, 1.0));
    rightArmUpperPos = mul(_RightArmUpper, float4(wpos, 1.0));
    rightArmMidPos = mul(_RightArmMid, float4(wpos, 1.0));
    rightArmLowerPos = mul(_RightArmLower, float4(wpos, 1.0));
    leftLegUpperPos = mul(_LeftLegUpper, float4(wpos, 1.0));
    leftLegLowerPos = mul(_LeftLegLower, float4(wpos, 1.0));
    leftLegMidPos = mul(_LeftLegMid, float4(wpos, 1.0));
    rightLegUpperPos = mul(_RightLegUpper, float4(wpos, 1.0));
    rightLegLowerPos = mul(_RightLegLower, float4(wpos, 1.0));
    rightLegMidPos = mul(_RightLegMid, float4(wpos, 1.0));

    head = Sphere(headPos, 0.1F);
    torsoUpper = Capsule(torsoUpperPos, float3(0, 0, 0), float3(0, .15, 0), 0.125F);
    torsoMid = Sphere(torsoMidPos, 0.125F);
    torsoLower = Sphere(torsoLowerPos, 0.16F);
    torsoMidExtra =  Sphere(torsoMidExtraPos, 0.16F);
    
    leftArmUpper = Capsule(leftArmUpperPos, float3(0, 0, 0), float3(0, .15, 0), 0.075F);
    leftArmMid =  Sphere(leftArmMidPos, 0.04F);
    leftArmLower = Capsule(leftArmLowerPos, float3(0, 0, 0), float3(0, .15, 0), 0.05F);
    
    rightArmUpper = Capsule(rightArmUpperPos, float3(0, 0, 0), float3(0, .15, 0), 0.075F);
    rightArmMid =  Sphere(rightArmMidPos, 0.045F);
    rightArmLower = Capsule(rightArmLowerPos, float3(0, 0, 0), float3(0, .15, 0), 0.05F);
    
    leftLegUpper = Capsule(leftLegUpperPos, float3(0, 0, 0), float3(0, .125, 0), 0.07F);
    leftLegLower = Capsule(leftLegLowerPos, float3(0, 0, 0), float3(0, .125, 0), 0.07F);
    leftLegMid =  Sphere(leftLegMidPos, 0.075F);
    
    rightLegUpper = Capsule(rightLegUpperPos, float3(0, 0, 0), float3(0, .125, 0), 0.07F);
    rightLegLower = Capsule(rightLegLowerPos, float3(0, 0, 0), float3(0, .125, 0), 0.07F);
    rightLegMid =  Sphere(rightLegMidPos, 0.06F);

    float result1 = SmoothMin(torsoUpper, torsoLower, _Smooth);
    float result2 = SmoothMin(leftArmUpper, leftArmLower, _Smooth);
    float result3 = SmoothMin(rightArmUpper, rightArmLower, _Smooth);
    float result4 = SmoothMin(leftLegUpper, leftLegLower, _Smooth);
    float result5 = SmoothMin(rightLegUpper, rightLegLower, _Smooth);
    float result6 = SmoothMin(head, torsoMid, _Smooth);
    float result7 = SmoothMin(leftArmMid, rightArmMid, _Smooth);
    float result8 = SmoothMin(leftLegMid, rightLegMid, _Smooth);
    
    float result9 = SmoothMin(result1, torsoMidExtra, _Smooth);
    float result10 = SmoothMin(result2, result3, _Smooth);
    float result11 = SmoothMin(result4, result5, _Smooth);
    float result12 = SmoothMin(result6, result7, _Smooth);
    
    float result13 = SmoothMin(result8, result9, _Smooth);
    float result14 = SmoothMin(result10, result11, _Smooth);
    
    float result15 = SmoothMin(result12, result13, _Smooth);
    
    return SmoothMin(result14, result15, _Smooth);
}
// @endblock

// @block PostEffect
float4 _HeadColor;
float4 _TorsoUpperColor;
float4 _TorsoMidColor;
float4 _TorsoLowerColor;
float4 _TorsoMidExtraColor;
float4 _LeftArmUpperColor;
float4 _LeftArmMidColor;
float4 _LeftArmLowerColor;
float4 _RightArmUpperColor;
float4 _RightArmMidColor;
float4 _RightArmLowerColor;
float4 _LeftLegUpperColor;
float4 _LeftLegLowerColor;
float4 _LeftLegMidColor;
float4 _RightLegUpperColor;
float4 _RightLegLowerColor;
float4 _RightLegMidColor;

inline void PostEffect(RaymarchInfo ray, inout PostEffectOutput o)
{
    float4 result1 = float4(4.0 / head, 4.0 / torsoUpper, 4.0 / torsoMid, 4.0 / torsoLower);
    float4 result2 = float4(4.0 / torsoMidExtra, 4.0 / leftArmUpper, 4.0 / leftArmMid, 4.0 / leftArmLower);
    float4 result3 = float4(4.0 / rightArmUpper, 4.0 / rightArmMid, 4.0 / rightArmLower, 4.0 / leftLegUpper);
    float4 result4 = float4(4.0 / leftLegLower, 4.0 / leftLegMid, 4.0 / rightLegUpper, 4.0 / rightLegLower);
    float4 result5 = float4(4.0 / rightLegMid, 0, 0, 0);

    fixed3 computeAlbedoPart1 =
        result1.x * _HeadColor +
        result1.y * _TorsoUpperColor +
        result1.z * _TorsoMidColor +
        result1.w * _TorsoLowerColor;

    fixed3 computeAlbedoPart2 =
        result2.x * _TorsoMidExtraColor +
        result2.y * _LeftArmUpperColor +
        result2.z * _LeftArmMidColor +
        result2.w * _LeftArmLowerColor;

    fixed3 computeAlbedoPart3 =
        result3.x * _RightArmUpperColor +
        result3.y * _RightArmMidColor +
        result3.z * _RightArmLowerColor +
        result3.w * _LeftLegUpperColor;

    fixed3 computeAlbedoPart4 =
        result4.x * _LeftLegLowerColor +
        result4.y * _LeftLegMidColor +
        result4.z * _RightLegUpperColor +
        result4.w * _RightLegLowerColor;

    fixed3 computeAlbedoPart5 =
        result5.x * _RightLegMidColor;

    fixed3 final = normalize(fixed3(
        computeAlbedoPart1 +
        computeAlbedoPart2 +
        computeAlbedoPart3 +
        computeAlbedoPart4 +
        computeAlbedoPart5));

    o.Albedo = final;
}
// @endblock

ENDCG

Pass
{
    Tags { "LightMode" = "ForwardBase" }

    ZWrite [_ZWrite]

    CGPROGRAM
    #include "Assets\uRaymarching\Shaders\Include\Legacy/ForwardBaseStandard.cginc"
    #pragma target 3.0
    #pragma vertex Vert
    #pragma fragment Frag
    #pragma multi_compile_instancing
    #pragma multi_compile_fog
    #pragma multi_compile_fwdbase
    ENDCG
}

Pass
{
    Tags { "LightMode" = "ForwardAdd" }
    ZWrite Off 
    Blend One One

    CGPROGRAM
    #include "Assets\uRaymarching\Shaders\Include\Legacy/ForwardAddStandard.cginc"
    #pragma target 3.0
    #pragma vertex Vert
    #pragma fragment Frag
    #pragma multi_compile_instancing
    #pragma multi_compile_fog
    #pragma skip_variants INSTANCING_ON
    #pragma multi_compile_fwdadd_fullshadows
    ENDCG
}

Pass
{
    Tags { "LightMode" = "ShadowCaster" }

    CGPROGRAM
    #include "Assets\uRaymarching\Shaders\Include\Legacy/ShadowCaster.cginc"
    #pragma target 3.0
    #pragma vertex Vert
    #pragma fragment Frag
    #pragma fragmentoption ARB_precision_hint_fastest
    #pragma multi_compile_shadowcaster
    ENDCG
}

}

Fallback Off

CustomEditor "uShaderTemplate.MaterialEditor"

}