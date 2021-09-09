// Fantasy Adventure Environment
// Copyright Staggart Creations
// staggart.xyz

using UnityEngine;
using UnityEditor;
using System.Collections;

namespace FAE
{
    public class TreeTrunkShaderGUI : ShaderGUI
    {

        //Main maps
        MaterialProperty _MainTex;
        MaterialProperty _BumpMap;

        MaterialProperty _UseSpeedTreeWind;

        //Color
        MaterialProperty _AmbientOcclusion;
        MaterialProperty _GradientBrightness;
        MaterialProperty _Smoothness;

        MaterialEditor m_MaterialEditor;
#if UNITY_2019_3_OR_NEWER
        private Material targetMat;
#endif

        //Meta
        bool showHelp;

        GUIContent mainTexName = new GUIContent("Diffuse", "Diffuse (RGB) and Transparency (A)");
        GUIContent normalMapName = new GUIContent("Normal Map");

        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
        {
            this.m_MaterialEditor = materialEditor;
#if UNITY_2019_3_OR_NEWER
            targetMat = materialEditor.target as Material;
#endif
            
            this.FindProperties(props);
            
            //Style similar to Standard shader
            m_MaterialEditor.SetDefaultGUIWidths();
            m_MaterialEditor.UseDefaultMargins();
            EditorGUIUtility.labelWidth = 0f;

#if UNITY_2019_3_OR_NEWER
            if (UnityEngine.Rendering.GraphicsSettings.currentRenderPipeline != null &&
                !targetMat.shader.name.Contains("Universal Render Pipeline"))
            {
                EditorGUILayout.HelpBox("Universal Render Pipeline is in use, but this material is using a shader for the Built-in render pipeline.\n\nShaders and materials can be converted through the Help window", MessageType.Error);
                EditorGUILayout.Space();
            }
#endif
            
            EditorGUI.BeginChangeCheck();

            //Draw fields
            DoHeader();

            DoMapsArea();
            DoColorArea();

            if (EditorGUI.EndChangeCheck())
            {
                //Apply changes
            }

            GUILayout.Label("Advanced Options", EditorStyles.boldLabel);

            GUIHelper.DrawExtraFields(m_MaterialEditor);

            m_MaterialEditor.ShaderProperty(_UseSpeedTreeWind, new GUIContent("Sample SpeedTree wind"));
            if (showHelp) EditorGUILayout.HelpBox("If this is a tree created using the SpeedTree Unity Modeler, this toggle will make the shader read the wind information as stored by SpeedTree.", MessageType.None);

            if(showHelp) GUIHelper.DrawWindInfo();

            GUIHelper.DrawFooter();

        }

        void DoHeader()
        {
            EditorGUILayout.BeginHorizontal();
            showHelp = GUILayout.Toggle(showHelp, "Toggle help", "Button");
            GUILayout.Label("FAE Tree Trunk Shader", GUIHelper.Header);
            EditorGUILayout.EndHorizontal();
            if (showHelp) EditorGUILayout.HelpBox("Tree trunk shader, featuring global wind motion", MessageType.Info);
        }

        void DoMapsArea()
        {
            GUILayout.Label("Main maps", EditorStyles.boldLabel);
            this.m_MaterialEditor.TexturePropertySingleLine(mainTexName, this._MainTex);
            this.m_MaterialEditor.TexturePropertySingleLine(normalMapName, this._BumpMap);

            EditorGUILayout.Space();
        }

        void DoColorArea()
        {
            m_MaterialEditor.ShaderProperty(_AmbientOcclusion, _AmbientOcclusion.displayName);
            if (showHelp) EditorGUILayout.HelpBox("Darkens the areas of the mesh where red vertex colors are applied", MessageType.None);
            m_MaterialEditor.ShaderProperty(_GradientBrightness, _GradientBrightness.displayName);
            if (showHelp) EditorGUILayout.HelpBox("Adds a gradient to the branch mesh from bottom to top. This information is stored in the alpha vertex color channel.\n\nWithout this information, the parameter will have no effect.", MessageType.None);
            m_MaterialEditor.ShaderProperty(_Smoothness, _Smoothness.displayName);
            if (showHelp) EditorGUILayout.HelpBox("Multiplies the value of the texture's alpha channel to decrease the roughness amount", MessageType.None);

            EditorGUILayout.Space();
        }


        public void FindProperties(MaterialProperty[] props)
        {
            _UseSpeedTreeWind = FindProperty("_UseSpeedTreeWind", props);

            //Main maps
            _MainTex = FindProperty("_MainTex", props);
            _BumpMap = FindProperty("_BumpMap", props);

            //Color
            _AmbientOcclusion = FindProperty("_AmbientOcclusion", props);
            _GradientBrightness = FindProperty("_GradientBrightness", props);
            _Smoothness = FindProperty("_Smoothness", props);

        }

    }
}
