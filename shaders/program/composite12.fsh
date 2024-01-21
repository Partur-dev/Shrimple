#define RENDER_OPAQUE_FINAL
#define RENDER_COMPOSITE
#define RENDER_FRAG

#include "/lib/constants.glsl"
#include "/lib/common.glsl"

in vec2 texcoord;

uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D depthtex2;
uniform sampler2D noisetex;
uniform sampler2D BUFFER_FINAL;
uniform sampler2D BUFFER_DEFERRED_COLOR;
uniform sampler2D BUFFER_DEFERRED_SHADOW;
uniform usampler2D BUFFER_DEFERRED_DATA;
uniform sampler2D BUFFER_DEFERRED_NORMAL_TEX;
uniform sampler2D BUFFER_BLOCK_DIFFUSE;
uniform sampler2D TEX_LIGHTMAP;

#if defined WATER_CAUSTICS && defined WORLD_WATER_ENABLED && defined WORLD_SKY_ENABLED && defined IS_IRIS
    uniform sampler3D texCaustics;
#endif

#if MATERIAL_SPECULAR != SPECULAR_NONE
    uniform sampler2D BUFFER_BLOCK_SPECULAR;
#endif

#if defined IRIS_FEATURE_SSBO && LPV_SIZE > 0 && (LIGHTING_MODE != DYN_LIGHT_NONE || LPV_SUN_SAMPLES > 0)
    uniform sampler3D texLPV_1;
    uniform sampler3D texLPV_2;
#endif

#if defined WORLD_SKY_ENABLED && ((MATERIAL_REFLECTIONS != REFLECT_NONE && defined MATERIAL_REFLECT_CLOUDS) || defined SHADOW_CLOUD_ENABLED)
    #if SKY_CLOUD_TYPE > CLOUDS_VANILLA
        uniform sampler3D TEX_CLOUDS;
    #elif SKY_CLOUD_TYPE == CLOUDS_VANILLA
        uniform sampler2D TEX_CLOUDS_VANILLA;
    #endif
#endif

#ifdef DISTANT_HORIZONS
    uniform sampler2D dhDepthTex;
    uniform sampler2D dhDepthTex1;
#endif

uniform int frameCounter;
uniform float frameTime;
//uniform float frameTimeCounter;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;
uniform vec3 upPosition;
uniform float viewWidth;
uniform float viewHeight;
uniform vec2 viewSize;
uniform vec2 pixelSize;
uniform float near;
uniform float far;
uniform float farPlane;

uniform vec3 skyColor;
uniform vec3 fogColor;
uniform float fogDensity;
uniform float fogStart;
uniform float fogEnd;
uniform int fogShape;
uniform int fogMode;

uniform int worldTime;
uniform ivec2 eyeBrightnessSmooth;
uniform float blindnessSmooth;

uniform int heldItemId;
uniform int heldItemId2;
uniform int heldBlockLightValue;
uniform int heldBlockLightValue2;

#ifdef ANIM_WORLD_TIME
    //uniform int worldTime;
#else
    uniform float frameTimeCounter;
#endif

#ifndef IRIS_FEATURE_SSBO
    uniform mat4 gbufferPreviousModelView;
    uniform mat4 gbufferPreviousProjection;
#endif

#if MATERIAL_REFLECTIONS == REFLECT_SCREEN
    uniform mat4 gbufferProjection;
#endif

#ifdef WORLD_SKY_ENABLED
    uniform vec3 sunPosition;
    uniform vec3 shadowLightPosition;
    uniform float rainStrength;
    uniform float skyRainStrength;
    uniform float skyWetnessSmooth;
    uniform float wetness;
    
    uniform float cloudHeight = WORLD_CLOUD_HEIGHT;

    #if (MATERIAL_REFLECTIONS != REFLECT_NONE && defined MATERIAL_REFLECT_CLOUDS) || defined SHADOW_CLOUD_ENABLED
        uniform float cloudTime;
    #endif

    #ifdef IS_IRIS
        uniform float lightningStrength;
    #endif
#endif

#if LPV_SIZE > 0
    uniform mat4 gbufferPreviousModelView;
#endif

#if defined WORLD_SHADOW_ENABLED && SHADOW_TYPE != SHADOW_TYPE_NONE
    #ifndef IRIS_FEATURE_SSBO
        uniform mat4 shadowModelView;
    #endif
#else
    //uniform int worldTime;
#endif

#ifdef WORLD_WATER_ENABLED
    uniform int isEyeInWater;
    uniform vec3 WaterAbsorbColor;
    uniform vec3 WaterScatterColor;
    uniform float waterDensitySmooth;
#endif

#ifdef IS_IRIS
    uniform bool isSpectator;
    uniform bool firstPersonCamera;
    uniform vec3 eyePosition;
    //uniform float cloudHeight = WORLD_CLOUD_HEIGHT;
#endif

#ifdef DISTANT_HORIZONS
    uniform mat4 dhModelViewInverse;
    uniform mat4 dhProjectionInverse;
    uniform float dhNearPlane;
    uniform float dhFarPlane;
#endif

#if MC_VERSION >= 11700 && defined ALPHATESTREF_ENABLED
    uniform float alphaTestRef;
#endif

#ifdef IRIS_FEATURE_SSBO
    #include "/lib/buffers/scene.glsl"
    #include "/lib/buffers/block_static.glsl"
    #include "/lib/buffers/light_static.glsl"

    #if defined IS_TRACING_ENABLED || defined IS_LPV_ENABLED
        #include "/lib/buffers/block_voxel.glsl"
    #endif
    
    #if defined WORLD_WATER_ENABLED && WATER_DEPTH_LAYERS > 1
        #include "/lib/buffers/water_depths.glsl"
    #endif
#endif

#include "/lib/blocks.glsl"
#include "/lib/items.glsl"

#if LIGHTING_MODE_HAND != HAND_LIGHT_NONE
    #include "/lib/lights.glsl"
#endif

#include "/lib/sampling/depth.glsl"
#include "/lib/sampling/noise.glsl"
#include "/lib/sampling/bayer.glsl"
#include "/lib/sampling/ign.glsl"
#include "/lib/sampling/gaussian.glsl"
#include "/lib/sampling/bilateral_gaussian.glsl"

#include "/lib/utility/anim.glsl"
#include "/lib/utility/lightmap.glsl"
#include "/lib/utility/temporal_offset.glsl"

#include "/lib/world/atmosphere.glsl"
#include "/lib/world/common.glsl"
#include "/lib/fog/fog_common.glsl"

#if LIGHTING_MODE_HAND != HAND_LIGHT_NONE
    #include "/lib/lighting/blackbody.glsl"

    #ifdef LIGHTING_FLICKER
        #include "/lib/lighting/flicker.glsl"
    #endif
#endif

#ifdef WORLD_SKY_ENABLED
    #include "/lib/world/sky.glsl"
    #include "/lib/world/wetness.glsl"
#endif

#ifdef WORLD_WATER_ENABLED
    #include "/lib/world/water.glsl"

    #if defined WATER_CAUSTICS && defined WORLD_SKY_ENABLED
        #include "/lib/lighting/caustics.glsl"
    #endif
#endif

#if SKY_TYPE == SKY_TYPE_CUSTOM
    #include "/lib/fog/fog_custom.glsl"
#elif SKY_TYPE == SKY_TYPE_VANILLA
    #include "/lib/fog/fog_vanilla.glsl"
#endif

#if MATERIAL_SPECULAR != SPECULAR_NONE
    #include "/lib/material/hcm.glsl"
    #include "/lib/material/fresnel.glsl"
#endif

#if defined IS_TRACING_ENABLED || defined IS_LPV_ENABLED
    #include "/lib/lighting/voxel/mask.glsl"
    #include "/lib/lighting/voxel/block_mask.glsl"
    #include "/lib/lighting/voxel/blocks.glsl"
#endif

#if LIGHTING_MODE_HAND == HAND_LIGHT_TRACED
    #include "/lib/lighting/voxel/tinting.glsl"
    #include "/lib/lighting/voxel/tracing.glsl"
#endif

#include "/lib/lighting/hg.glsl"
#include "/lib/lighting/fresnel.glsl"
#include "/lib/lighting/sampling.glsl"

#if LIGHTING_MODE_HAND != HAND_LIGHT_NONE
    #include "/lib/lighting/voxel/lights.glsl"
    #include "/lib/lighting/voxel/lights_render.glsl"
#endif

#if defined IRIS_FEATURE_SSBO && LPV_SIZE > 0 && (LIGHTING_MODE != DYN_LIGHT_NONE || LPV_SUN_SAMPLES > 0)
    #include "/lib/buffers/volume.glsl"
    
    #include "/lib/lighting/voxel/lpv.glsl"
    #include "/lib/lighting/voxel/lpv_render.glsl"
#endif

#if LIGHTING_MODE_HAND != HAND_LIGHT_NONE
    #include "/lib/lighting/voxel/item_light_map.glsl"
    #include "/lib/lighting/voxel/items.glsl"
#endif

#include "/lib/lighting/scatter_transmit.glsl"

#if defined WORLD_SKY_ENABLED && defined IS_IRIS
    #include "/lib/clouds/cloud_vars.glsl"
    #include "/lib/world/lightning.glsl"

    #if (defined MATERIAL_REFLECT_CLOUDS && MATERIAL_REFLECTIONS != REFLECT_NONE) || defined RENDER_CLOUD_SHADOWS_ENABLED
        #if SKY_CLOUD_TYPE > CLOUDS_VANILLA
            #include "/lib/clouds/cloud_custom.glsl"
        #elif SKY_CLOUD_TYPE == CLOUDS_VANILLA
            #include "/lib/clouds/cloud_vanilla.glsl"
        #endif
    #endif
#endif

#if MATERIAL_REFLECTIONS != REFLECT_NONE
    //#include "/lib/utility/depth_tiles.glsl"
    #include "/lib/lighting/reflections.glsl"
#endif

#ifdef WORLD_SKY_ENABLED
    #include "/lib/lighting/sky_lighting.glsl"
#endif

#if LIGHTING_MODE == DYN_LIGHT_NONE
    #include "/lib/lighting/vanilla.glsl"
#elif LIGHTING_MODE == DYN_LIGHT_LPV
    #include "/lib/lighting/floodfill.glsl"
#else
    #include "/lib/lighting/basic.glsl"
    #include "/lib/sampling/light_filter.glsl"
#endif

#if LIGHTING_MODE_HAND != HAND_LIGHT_NONE
    #include "/lib/lighting/basic_hand.glsl"
#endif


layout(location = 0) out vec4 outFinal;
#ifdef DEFERRED_BUFFER_ENABLED
    /* RENDERTARGETS: 0 */

    void main() {
        ivec2 iTex = ivec2(gl_FragCoord.xy);
        vec2 viewSize = vec2(viewWidth, viewHeight);

        //float depth = texelFetch(depthtex1, iTex, 0).r;
        //float handClipDepth = texelFetch(depthtex2, iTex, 0).r;
        float depthTrans = textureLod(depthtex0, texcoord, 0).r;
        float depthOpaque = textureLod(depthtex1, texcoord, 0).r;
        float handClipDepth = textureLod(depthtex2, texcoord, 0).r;
        bool isHand = handClipDepth > depthOpaque;

        // if (isHand) {
        //     depth = depth * 2.0 - 1.0;
        //     depth /= MC_HAND_DEPTH;
        //     depth = depth * 0.5 + 0.5;
        // }

        float depthOpaqueL = linearizeDepthFast(depthOpaque, near, farPlane);
        float depthTransL = linearizeDepthFast(depthTrans, near, farPlane);
        mat4 projectionInvOpaque = gbufferProjectionInverse;

        #ifdef DISTANT_HORIZONS
            float dhDepthTrans = textureLod(dhDepthTex, texcoord, 0).r;
            float dhDepthTransL = linearizeDepthFast(dhDepthTrans, dhNearPlane, dhFarPlane);

            if (dhDepthTransL < depthTransL || depthTrans >= 1.0) {
                //depthTrans = dhDepthTrans;
                depthTransL = dhDepthTransL;
            }

            float dhDepthOpaque = textureLod(dhDepthTex1, texcoord, 0).r;
            float dhDepthOpaqueL = linearizeDepthFast(dhDepthOpaque, dhNearPlane, dhFarPlane);

            if (dhDepthOpaqueL < depthOpaqueL || depthOpaque >= 1.0) {
                depthOpaque = dhDepthOpaque;
                depthOpaqueL = dhDepthOpaqueL;
                projectionInvOpaque = dhProjectionInverse;
            }
        #endif

        vec3 final;

        #ifdef DH_COMPAT_ENABLED
            #ifdef WORLD_SKY_ENABLED
                vec3 skyFinal = texelFetch(BUFFER_FINAL, iTex, 0).rgb;
                skyFinal = RGBToLinear(skyFinal) * WorldSkyBrightnessF;
            #else
                vec3 skyFinal = RGBToLinear(fogColor);
            #endif

            // vec3 deferredColor = texelFetch(BUFFER_DEFERRED_COLOR, iTex, 0).rgb;

            // if (all(greaterThan(deferredColor, EPSILON3)))
            //     skyFinal = RGBToLinear(deferredColor) * 2.0;
        #endif

        if (depthOpaque < 1.0) {
            vec3 clipPos = vec3(texcoord, depthOpaque) * 2.0 - 1.0;

            #ifdef DISTANT_HORIZONS
                vec3 viewPos = unproject(projectionInvOpaque * vec4(clipPos, 1.0));
                vec3 localPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
            #else
                #ifndef IRIS_FEATURE_SSBO
                    vec3 viewPos = unproject(gbufferProjectionInverse * vec4(clipPos, 1.0));
                    vec3 localPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
                #else
                    vec3 localPos = unproject(gbufferModelViewProjectionInverse * vec4(clipPos, 1.0));
                #endif
            #endif

            vec3 localViewDir = normalize(localPos);

            vec3 deferredColor = texelFetch(BUFFER_DEFERRED_COLOR, iTex, 0).rgb;

            uvec4 deferredData = texelFetch(BUFFER_DEFERRED_DATA, iTex, 0);
            vec4 deferredLighting = unpackUnorm4x8(deferredData.g);

            vec4 deferredNormal = unpackUnorm4x8(deferredData.r);
            vec3 localNormal = deferredNormal.rgb;

            if (any(greaterThan(localNormal, EPSILON3)))
                localNormal = normalize(localNormal * 2.0 - 1.0);

            vec3 texNormal = texelFetch(BUFFER_DEFERRED_NORMAL_TEX, iTex, 0).rgb;

            if (any(greaterThan(texNormal, EPSILON3)))
                texNormal = normalize(texNormal * 2.0 - 1.0);

            float viewDist = length(localPos);

            #if MATERIAL_SPECULAR != SPECULAR_NONE
                vec3 deferredRoughMetalF0Porosity = unpackUnorm4x8(deferredData.a).rgb;
                float roughL = _pow2(deferredRoughMetalF0Porosity.r);
                float metal_f0 = deferredRoughMetalF0Porosity.g;
                float porosity = deferredRoughMetalF0Porosity.b;
            #else
                const float roughL = 1.0;
                const float metal_f0 = 0.04;
                const float porosity = 0.0;
            #endif

            #if defined SHADOW_BLUR && !defined EFFECT_TAA_ENABLED
                #ifdef SHADOW_COLORED
                    const vec3 shadowSigma = vec3(3.0, 3.0, 0.25);
                    vec3 deferredShadow = BilateralGaussianDepthBlurRGB_5x(texcoord, BUFFER_DEFERRED_SHADOW, viewSize, depthtex1, viewSize, depthOpaqueL, shadowSigma);
                #else
                    float shadowSigma = 3.0 / depthOpaqueL;
                    vec3 deferredShadow = vec3(BilateralGaussianDepthBlur_5x(texcoord, BUFFER_DEFERRED_SHADOW, viewSize, depthtex1, viewSize, depthOpaqueL, shadowSigma));
                #endif
            #else
                //vec3 deferredShadow = unpackUnorm4x8(deferredData.b).rgb;
                vec3 deferredShadow = textureLod(BUFFER_DEFERRED_SHADOW, texcoord, 0).rgb;
            #endif

            #if defined WORLD_SKY_ENABLED && defined RENDER_CLOUD_SHADOWS_ENABLED && SKY_CLOUD_TYPE > CLOUDS_VANILLA
                float cloudShadow = TraceCloudShadow(cameraPosition + localPos, localSkyLightDirection, CLOUD_SHADOW_STEPS);
                deferredShadow.rgb *= 1.0 - (1.0 - cloudShadow) * (1.0 - ShadowCloudBrightnessF);
                // deferredShadow.rgb *= cloudShadow;
            #endif

            vec3 albedo = RGBToLinear(deferredColor);
            float occlusion = deferredLighting.z;
            float emission = deferredLighting.a;
            float sss = deferredNormal.a;

            //float skyLightF = saturate(luminance(deferredShadow) * 10.0);
            //skyLightF = max(skyLightF, _pow3(deferredLighting.y)*0.7);
            //occlusion = max(occlusion, skyLightF);

            float skyWetness = 0.0, puddleF = 0.0;
            #if defined WORLD_SKY_ENABLED && defined WORLD_WETNESS_ENABLED
                skyWetness = GetSkyWetness(localPos + cameraPosition, localNormal, deferredLighting.xy);

                #if WORLD_WETNESS_PUDDLES != PUDDLES_NONE
                    puddleF = GetWetnessPuddleF(skyWetness, porosity);
                #endif
            #endif

            #ifdef WORLD_WATER_ENABLED
                #if WATER_DEPTH_LAYERS > 1
                    uvec2 waterScreenUV = uvec2(gl_FragCoord.xy);
                    uint waterPixelIndex = uint(waterScreenUV.y * viewWidth + waterScreenUV.x);
                    bool hasWaterDepth = false;

                    vec3 clipPosTrans = vec3(texcoord, depthTrans) * 2.0 - 1.0;
                    vec3 localPosTrans = unproject(gbufferModelViewProjectionInverse * vec4(clipPosTrans, 1.0));
                    float distTrans = length(localPosTrans);

                    float waterDepth[WATER_DEPTH_LAYERS+1];
                    GetAllWaterDepths(waterPixelIndex, waterDepth);

                    hasWaterDepth = viewDist > waterDepth[0] && viewDist < waterDepth[1];

                    #if WATER_DEPTH_LAYERS >= 3
                        hasWaterDepth = hasWaterDepth || (viewDist > waterDepth[2] && viewDist < waterDepth[3]);
                    #endif

                    #if WATER_DEPTH_LAYERS >= 5
                        hasWaterDepth = hasWaterDepth || (viewDist > waterDepth[4] && viewDist < waterDepth[5]);
                    #endif
                #else
                    bool hasWaterDepth = isEyeInWater == 1
                        ? depthOpaqueL <= depthTransL
                        : depthTransL < depthOpaqueL;
                #endif

                if (hasWaterDepth) {
                    #if defined WORLD_SKY_ENABLED
                        puddleF = 1.0;
                    #endif

                    #if defined WATER_CAUSTICS && defined WORLD_SKY_ENABLED
                        const float shadowDepth = 8.0; // TODO
                        float causticLight = SampleWaterCaustics(localPos, shadowDepth, deferredLighting.y);

                        deferredShadow *= 0.3 + 0.7*causticLight;
                    #endif
                }
            #endif

            //#if (defined WORLD_SKY_ENABLED && defined WORLD_WETNESS_ENABLED) || defined WORLD_WATER_ENABLED
            #if defined WORLD_SKY_ENABLED && (defined WORLD_WETNESS_ENABLED || defined WORLD_WATER_ENABLED)
                //albedo = pow(albedo, vec3(1.0 + MaterialPorosityDarkenF * sqrt(porosity)));

                ApplySkyWetness(albedo, porosity, skyWetness, puddleF);
            #endif

            #if LIGHTING_MODE == DYN_LIGHT_NONE
                vec3 diffuse, specular = vec3(0.0);
                GetVanillaLighting(diffuse, deferredLighting.xy, localPos, localNormal, texNormal, deferredShadow, sss);

                // #if MATERIAL_SPECULAR != SPECULAR_NONE && defined WORLD_SHADOW_ENABLED && SHADOW_TYPE != SHADOW_TYPE_NONE
                //     #ifndef IRIS_FEATURE_SSBO
                //         vec3 localSkyLightDirection = mat3(gbufferModelViewInverse) * normalize(shadowLightPosition);
                //     #endif

                //     float geoNoL = dot(localNormal, localSkyLightDirection);
                //     specular += GetSkySpecular(localPos, geoNoL, texNormal, albedo, deferredShadow, deferredLighting.xy, metal_f0, roughL);
                // #endif

                #ifdef WORLD_SKY_ENABLED
                    const bool tir = false; // TODO: ?
                    GetSkyLightingFinal(diffuse, specular, deferredShadow, localPos, localNormal, texNormal, albedo, deferredLighting.xy, roughL, metal_f0, occlusion, sss, tir);
                #endif

                #if LIGHTING_MODE_HAND != HAND_LIGHT_NONE
                    SampleHandLight(diffuse, specular, localPos, localNormal, texNormal, albedo, roughL, metal_f0, occlusion, sss);
                #endif

                final = GetFinalLighting(albedo, diffuse, specular, metal_f0, roughL, emission, occlusion);
            #else
                vec3 blockDiffuse = vec3(0.0);
                vec3 blockSpecular = vec3(0.0);

                #if defined IRIS_FEATURE_SSBO && LIGHTING_MODE == DYN_LIGHT_TRACED
                    #if LIGHTING_MODE_HAND != HAND_LIGHT_NONE
                        SampleHandLight(blockDiffuse, blockSpecular, localPos, localNormal, texNormal, albedo, roughL, metal_f0, occlusion, sss);
                    #endif

                    #if LPV_SIZE > 0
                        blockDiffuse += GetLpvAmbientLighting(localPos, localNormal) * occlusion;
                    #endif

                    #if MATERIAL_SPECULAR != SPECULAR_NONE
                        if (metal_f0 >= 0.5) {
                            blockDiffuse *= mix(MaterialMetalBrightnessF, 1.0, roughL);
                            blockSpecular *= albedo;
                        }
                    #endif

                    vec3 sampleDiffuse = vec3(0.0);
                    vec3 sampleSpecular = vec3(0.0);

                    #ifdef LIGHTING_TRACE_FILTER
                        light_GaussianFilter(sampleDiffuse, sampleSpecular, texcoord, depthOpaqueL, texNormal, roughL);
                    #elif LIGHTING_TRACE_RES == 0
                        sampleDiffuse = texelFetch(BUFFER_BLOCK_DIFFUSE, iTex, 0).rgb;

                        #if MATERIAL_SPECULAR != SPECULAR_NONE
                            sampleSpecular = texelFetch(BUFFER_BLOCK_SPECULAR, iTex, 0).rgb;
                        #endif
                    #else
                        sampleDiffuse = textureLod(BUFFER_BLOCK_DIFFUSE, texcoord, 0).rgb;

                        #if MATERIAL_SPECULAR != SPECULAR_NONE
                            sampleSpecular = textureLod(BUFFER_BLOCK_SPECULAR, texcoord, 0).rgb;
                        #endif
                    #endif

                    blockDiffuse += sampleDiffuse;
                    blockSpecular += sampleSpecular;

                    // TODO: convert diffuse/specular to final

                    //blockDiffuse += emission * MaterialEmissionF;
                    vec3 skyDiffuse = vec3(0.0);
                    vec3 skySpecular = vec3(0.0);

                    #ifdef WORLD_SKY_ENABLED
                        GetSkyLightingFinal(skyDiffuse, skySpecular, deferredShadow, localPos, localNormal, texNormal, albedo, deferredLighting.xy, roughL, metal_f0, occlusion, sss, false);

                        #if MATERIAL_SPECULAR != SPECULAR_NONE
                            if (metal_f0 >= 0.5) {
                                skyDiffuse *= mix(MaterialMetalBrightnessF, 1.0, roughL);
                                skySpecular *= albedo;
                            }
                        #endif
                    #else
                        blockDiffuse += WorldAmbientF;
                    #endif

                    //float shadowF = min(luminance(deferredShadow), 1.0);
                    //occlusion = max(occlusion, shadowF);

                    blockDiffuse += skyDiffuse;
                    blockSpecular += skySpecular;
                #elif LIGHTING_MODE == DYN_LIGHT_LPV
                    GetFloodfillLighting(blockDiffuse, blockSpecular, localPos, localNormal, texNormal, deferredLighting.xy, deferredShadow, albedo, metal_f0, roughL, occlusion, sss, false);
                    
                    #ifdef WORLD_SKY_ENABLED
                        const bool tir = false; // TODO: ?
                        GetSkyLightingFinal(blockDiffuse, blockSpecular, deferredShadow, localPos, localNormal, texNormal, albedo, deferredLighting.xy, roughL, metal_f0, occlusion, sss, tir);
                    #else
                        blockDiffuse += WorldAmbientF;
                    #endif

                    #if LIGHTING_MODE_HAND != HAND_LIGHT_NONE
                        SampleHandLight(blockDiffuse, blockSpecular, localPos, localNormal, texNormal, albedo, roughL, metal_f0, occlusion, sss);
                    #endif

                    #if MATERIAL_SPECULAR != SPECULAR_NONE
                        if (metal_f0 >= 0.5) {
                            blockDiffuse *= mix(MaterialMetalBrightnessF, 1.0, roughL);
                            blockSpecular *= albedo;
                        }
                    #endif
                #endif

                blockDiffuse += emission * MaterialEmissionF;

                final = GetFinalLighting(albedo, blockDiffuse, blockSpecular, occlusion);
            #endif

            #ifdef DH_COMPAT_ENABLED
                float fogDist = GetShapedFogDistance(localPos);
                float fogF = GetFogFactor(fogDist, 0.6 * far, far, 1.0);
                final = mix(final, skyFinal, fogF);
            #elif defined SKY_BORDER_FOG_ENABLED
                #if SKY_TYPE == SKY_TYPE_CUSTOM
                    vec3 fogColorFinal = GetCustomSkyColor(localSunDirection.y, localViewDir.y);
                    fogColorFinal *= WorldSkyBrightnessF;

                    float fogDist = GetShapedFogDistance(localPos);
                    float fogF = GetCustomFogFactor(fogDist);

                    #if defined WORLD_SKY_ENABLED && SKY_VOL_FOG_TYPE != VOL_TYPE_NONE && SKY_CLOUD_TYPE > CLOUDS_VANILLA
                        #ifdef DISTANT_HORIZONS
                            float fogFarDist = max(SkyFar, dhFarPlane) - (0.5*dhFarPlane);
                        #else
                            float fogFarDist = SkyFar - far;
                        #endif

                        if (fogFarDist > 0.0) {
                            float weatherF = 1.0 - 0.5 * _pow2(skyRainStrength);
                            vec3 skyLightColor = WorldSkyLightColor * weatherF * VolumetricBrightnessSky;

                            #if SKY_VOL_FOG_TYPE == VOL_TYPE_FANCY
                                float VoL = dot(localSkyLightDirection, localViewDir);
                                float phaseSky = DHG(VoL, -0.12, 0.78, 0.42);
                            #else
                                const float phaseSky = phaseIso;
                            #endif

                            vec3 vlLight = (phaseSky + AirAmbientF) * skyLightColor;
                            float airDensity = GetSkyDensity(cameraPosition.y + localPos.y);
                            vec4 scatterTransmit = ApplyScatteringTransmission(fogFarDist, vlLight, airDensity, vec3(AirScatterF), AirExtinctF, CLOUD_STEPS);
                            fogColorFinal = fogColorFinal * scatterTransmit.a + scatterTransmit.rgb;
                        }
                    #endif
                #elif SKY_TYPE == SKY_TYPE_VANILLA
                    vec4 deferredFog = unpackUnorm4x8(deferredData.b);
                    vec3 fogColorFinal = GetVanillaFogColor(deferredFog.rgb, localViewDir.y);
                    fogColorFinal = RGBToLinear(fogColorFinal) * WorldSkyBrightnessF;
                    float fogF = deferredFog.a;
                #endif

                final = mix(final, fogColorFinal, fogF);
            #endif
        }
        else {
            #ifdef DH_COMPAT_ENABLED
                final = skyFinal;
            #else
                #ifdef WORLD_NETHER
                    final.rgb = RGBToLinear(fogColor) * WorldSkyBrightnessF;
                #else
                    final = texelFetch(BUFFER_FINAL, iTex, 0).rgb;
                #endif
            #endif
        }

        outFinal = vec4(final, 1.0);
    }
#else
    // Pass-through for world-specific flags not working in shader.properties
    
    uniform sampler2D colortex0;


    void main() {
        outFinal = texture(colortex0, texcoord);
    }
#endif
