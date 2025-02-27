using System;
using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using DarkBlade;

internal class DarkBladeParticleGUI: ShaderGUI
{

	public static Dictionary<Material, Toggles> foldouts = new Dictionary<Material, Toggles>();
	Toggles toggles = new Toggles(new string[] {
		"Primary Textures"
	}, 1);

	string versionLabel = "v1.0";

	MaterialProperty dst = null;
	MaterialProperty src = null;
	MaterialProperty mainTex = null;
	MaterialProperty mainTexTile = null;
	MaterialProperty mainTexOffset = null;
	MaterialProperty scrollingBase = null;
	MaterialProperty distortion = null;
	MaterialProperty distortionStrength = null;
	MaterialProperty distortionSecondary = null;
	MaterialProperty distortionTiling = null;
	MaterialProperty distortionOffset = null;
	MaterialProperty distortionScrolling = null;
    MaterialProperty multiplyStrengthbyAlpha = null;
	MaterialProperty multiplyAddSecondary = null;
	MaterialProperty mainTex1 = null;
	MaterialProperty mainTex1Tile = null;
	MaterialProperty mainTex1Offset = null;
	MaterialProperty scrollingSecondary = null;
	MaterialProperty tileOffsetSecondary = null;
	MaterialProperty secondaryStrength = null;
	MaterialProperty secondaryTint = null;
	MaterialProperty color = null;
	MaterialProperty softParticle = null;
	MaterialProperty fresnel = null;
	MaterialProperty fadefromCenter = null;
	MaterialProperty culling = null;
	MaterialProperty glowStrength = null;
	MaterialProperty glowRadius = null;
    MaterialProperty vertexdistortion = null;
    MaterialProperty vertexdistortionspeed = null;
    MaterialProperty vertexdistortionscale = null;

    MaterialEditor me;

	bool m_FirstTimeApply = true;

	public void FindProperties(MaterialProperty[] props, Material mat)
	{
		dst = FindProperty("_Dst", props);
		src = FindProperty("_Src", props);
		mainTex = FindProperty("_MainTex", props);
		mainTexTile = FindProperty("_MainTexTiling", props);
		mainTexOffset = FindProperty("_MainTexOffset", props);
		scrollingBase = FindProperty("_ScrollingBase", props);
		distortion = FindProperty("_Distortion", props);
		distortionStrength = FindProperty("_DistortionStrength", props);
		distortionTiling = FindProperty("_DistortionTiling", props);
        distortionOffset = FindProperty("_DistortionOffset", props);
        distortionScrolling = FindProperty("_DistortionScrolling", props);
        multiplyStrengthbyAlpha = FindProperty("_MultiplyStrengthbyAlpha", props);
		multiplyAddSecondary = FindProperty("_MultiplyAddSecondary", props);
		mainTex1 = FindProperty("_MainTex1", props);
		mainTex1Tile = FindProperty("_MainTex1Tiling", props);
		mainTex1Offset = FindProperty("_MainTex1Offset", props);
		scrollingSecondary = FindProperty("_ScrollingSecondary", props);
		secondaryStrength = FindProperty("_SecondaryStrength", props);
		secondaryTint = FindProperty("_SecondaryTint", props);
		distortionSecondary = FindProperty("_DistortSecondaryColor", props);
		color = FindProperty("_Color", props);
		softParticle = FindProperty("_SoftParticle", props);
		fresnel = FindProperty("_Fresnel", props, false);
		fadefromCenter = FindProperty("_FadefromCenter", props);
		culling = FindProperty("_Culling", props);
		glowStrength = FindProperty("_GlowStrength", props);
		glowRadius = FindProperty("_GlowRadius", props);
        vertexdistortion = FindProperty("_VertexDistortion", props);
        vertexdistortionscale = FindProperty("_VertexDistortionScale", props);
        vertexdistortionspeed = FindProperty("_VertexDistortionSpeed", props);
    }

	public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
	{
		me = materialEditor;
		Material material = materialEditor.target as Material;

		FindProperties(props, material);

		// Make sure that needed setup (ie keywords/renderqueue) are set up if we're switching some existing
		// material to a standard shader.
		// Do this before any GUI code has been issued to prevent layout issues in subsequent GUILayout statements (case 780071)

		// Add mat to foldout dictionary if it isn't in there yet
		if (!foldouts.ContainsKey(material))
			foldouts.Add(material, toggles);

		// Use default labelWidth
		EditorGUIUtility.labelWidth = 0f;

		// Detect any changes to the material
		EditorGUI.BeginChangeCheck();
		{

			// Primary properties
			DGUI.CenteredText("DarkBlade Particle Shader", 18, 2,2);
			DGUI.VersionLabel("v1.0",12,0,0);
			DGUI.Space4();
			DGUI.BoldLabel("Primary Texture");
			DGUI.PropertyGroup(() => {
				DoPrimaryArea(material);
			});
			DGUI.Space2();
			DGUI.BoldLabel("Secondary Texture");
			DGUI.PropertyGroup(() => {
				DoSecondaryArea(material);
			});
			DGUI.Space2();
			DGUI.BoldLabel("Distortion");
			DGUI.PropertyGroup(() => {
				DoDistortionArea(material);
			});
			DGUI.Space2();

			DGUI.BoldLabel("Render Settings");
			DGUI.PropertyGroup(() => {
				DoRenderingArea(material);
			});
		}

		DGUI.Space8();
	}

	void DoPrimaryArea(Material material)
	{
		DGUI.PropertyGroup(() => {
			me.TexturePropertySingleLine(DarkBladeTips.albedoText, mainTex, color);
			me.ShaderProperty(glowStrength, "Glow Strength");
			me.ShaderProperty(glowRadius, "Glow Radius");
		});
		EditorGUI.BeginChangeCheck();
		DGUI.PropertyGroup(() => {
			DGUI.TextureSOScrollCustom(me, mainTexTile,mainTexOffset, scrollingBase);
		});
	}
	void DoSecondaryArea(Material material)
	{
		DGUI.PropertyGroup(() => {
			me.TexturePropertySingleLine(DarkBladeTips.albedoText, mainTex1, secondaryTint);
		});
		EditorGUI.BeginChangeCheck();
		DGUI.PropertyGroup(() => {
			DGUI.TextureSOScrollCustom(me, mainTex1Tile, mainTex1Offset, scrollingSecondary);
		});
		DGUI.PropertyGroup(() => {
			me.ShaderProperty(secondaryStrength, "Secondary Strength");
			me.ShaderProperty(multiplyAddSecondary, "Multiply/Add Secondary");
			me.ShaderProperty(distortionSecondary, "Distort Secondary");
		});
	}
	void DoDistortionArea(Material material)
	{
		DGUI.PropertyGroup(() => {
			me.TexturePropertySingleLine(DarkBladeTips.normalMapText, distortion, distortion.textureValue ? distortionStrength : null);
		});
		EditorGUI.BeginChangeCheck();
		DGUI.PropertyGroup(() => {
			DGUI.TextureSOScrollCustom(me, distortionTiling, distortionOffset, distortionScrolling);
		});
		DGUI.PropertyGroup(() => {
			me.ShaderProperty(multiplyStrengthbyAlpha, "Multiply Strength by Alpha");
		});
	}

	void DoRenderingArea(Material material)
	{
		me.ShaderProperty(fadefromCenter, "Fade From Center");
		me.ShaderProperty(fresnel, "Fresnel Culling");
		me.ShaderProperty(softParticle, "Soft Particle");
		me.ShaderProperty(dst, "Blend Mode");
		me.ShaderProperty(culling, "Culling Mode");
		me.ShaderProperty(vertexdistortion, "Vertex Distortion");
        me.ShaderProperty(vertexdistortionscale, "Vertex Distortion Scale");
        me.ShaderProperty(vertexdistortionspeed, "Vertex Distortion Speed");
    }

}