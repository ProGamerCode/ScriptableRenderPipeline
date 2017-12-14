﻿using System;
using System.Linq;
using UnityEngine;

namespace UnityEditor.Experimental.Rendering.HDPipeline
{
    // TODO: Missing UI tooltips
    partial class HDLightEditor
    {
        sealed class Styles
        {
            // Base
            public readonly GUIContent cookieSizeX = new GUIContent("Size X", "Controls the size of the cookie mask currently assigned to the light.");
            public readonly GUIContent cookieSizeY = new GUIContent("Size Y", "Controls the size of the cookie mask currently assigned to the light.");
            public readonly GUIContent shadowBias = new GUIContent("Bias", "Controls the distance at which the shadows will be pushed away from the light. Useful for avoiding false self-shadowing artifacts.");
            public readonly GUIContent shadowNormalBias = new GUIContent("Normal Bias", "Controls distance at which the shadow casting surfaces will be shrunk along the surface normal. Useful for avoiding false self-shadowing artifacts.");
            public readonly GUIContent shadowNearPlane = new GUIContent("Near Plane", "Controls the value for the near clip plane when rendering shadows. Currently clamped to 0.1 units or 1% of the lights range property, whichever is lower.");
            public readonly GUIContent bakedShadowRadius = new GUIContent("Baked Shadow Radius", "Controls the amount of artificial softening applied to the edges of shadows cast by the Point or Spot light.");
            public readonly GUIContent bakedShadowAngle = new GUIContent("Baked Shadow Angle", "Controls the amount of artificial softening applied to the edges of shadows cast by directional lights.");

            // Additional light data
            public readonly GUIContent maxSmoothness = new GUIContent("Max Smoothness", "Very low cost way of faking spherical area lighting. This will modify the roughness of the material lit. This is useful when the specular highlight is too small or too sharp.");
            public readonly GUIContent affectDiffuse = new GUIContent("Affect Diffuse", "This will disable diffuse lighting for this light. Doesn't save performance, diffuse lighting is still computed.");
            public readonly GUIContent affectSpecular = new GUIContent("Affect Specular", "This will disable specular lighting for this light. Doesn't save performance, specular lighting is still computed.");
            public readonly GUIContent lightDimmer = new GUIContent("Dimmer", "Aim to be used with script, timeline or animation. It allows dimming one or multiple lights of heterogeneous intensity easily (without needing to know the intensity of each light).");
            public readonly GUIContent fadeDistance = new GUIContent("Fade Distance", "The distance at which the light will smoothly fade before being culled to minimize popping.");
            public readonly GUIContent spotInnerPercent = new GUIContent("Inner Percent", "Controls size of the angular attenuation in percent of the base angle of the Spot light's cone.");
            public readonly GUIContent spotLightShape = new GUIContent("Shape", "The shape use for the spotlight. Has an impact on the cookie transformation and light angular attenuation.");
            public readonly GUIContent shapeLengthLine = new GUIContent("Length", "Length of the line light");
            public readonly GUIContent shapeLengthRect = new GUIContent("Size X", "SizeX of the rectangle light");
            public readonly GUIContent shapeWidthRect = new GUIContent("Size Y", "SizeY of the rectangle light");
            public readonly GUIContent aspectRatioPyramid = new GUIContent("Aspect ratio", "");
            public readonly GUIContent shapeLengthBox = new GUIContent("Size X", "");
            public readonly GUIContent shapeWidthBox = new GUIContent("Size Y", "");
            public readonly GUIContent applyRangeAttenuation = new GUIContent("Apply Range Attenuation", "Allows disabling range attenuation. This is useful indoor (like a room) to avoid having to setup a large range for a light to get correct inverse square attenuation that may leak out of the indoor");

            public readonly GUIContent shape = new GUIContent("Type", "Specifies the current type of light. Possible types are Directional, Spot, Point, Rectangle and Line lights.");
            public readonly GUIContent[] shapeNames;

            // Additional shadow data
            public readonly GUIContent shadowCascadeCount = new GUIContent("Cascade Count", "");
            public readonly GUIContent[] shadowCascadeRatios = { new GUIContent("Cascade 1"), new GUIContent("Cascade 2"), new GUIContent("Cascade 3") };
            public readonly GUIContent shadowResolution = new GUIContent("Resolution", "Controls the rendered resolution of the shadow maps. A higher resolution will increase the fidelity of shadows at the cost of GPU performance and memory usage.");
            public readonly GUIContent shadowFadeDistance = new GUIContent("Fade Distance", "The shadow will fade at distance ShadowFadeDistance before being culled to minimize popping.");
            public readonly GUIContent shadowDimmer = new GUIContent("Dimmer", "Aim to be use with script, timeline or animation. It allows dimming one or multiple shadows. This can also be used as an optimization to fit in shadow budget manually and minimize popping.");

            public Styles()
            {
                shapeNames = Enum.GetNames(typeof(LightShape))
                    .Select(x => new GUIContent(x))
                    .ToArray();
            }
        }

        static Styles s_Styles;

        // Can't use a static initializer in case we need to create GUIStyle in the Styles class as
        // these can only be created with an active GUI rendering context
        void CheckStyles()
        {
            if (s_Styles == null)
                s_Styles = new Styles();
        }
    }
}