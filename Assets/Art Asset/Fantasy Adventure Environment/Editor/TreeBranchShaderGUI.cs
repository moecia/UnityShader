// Fantasy Adventure Environment
// Copyright Staggart Creations
// staggart.xyz

using UnityEngine;
using UnityEditor;
using System.Collections;

namespace FAE
{
    public class TreeBranchShaderGUI : ShaderGUI
    {

        MaterialProperty _MaskClipValue;

        MaterialProperty _UseSpeedTreeWind;

        //Main maps
        MaterialProperty _MainTex;
        MaterialProperty _BumpMap;

        //Color
        MaterialProperty _Color;
        MaterialProperty _HueVariation;
        MaterialProperty _AmbientOcclusion;
        MaterialProperty _TransmissionColor;
        MaterialProperty _GradientBrightness;
        MaterialProperty _Smoothness;
        MaterialProperty _FlatLighting;

        //Animation
        MaterialProperty _MaxWindStrength;
        MaterialProperty _WindAmplitudeMultiplier;

        MaterialEditor m_MaterialEditor;

        //Meta
        bool showHelp;
        bool showHelpColor;
        bool showHelpAnimation;

        bool hasWindController;
        WindController windController;

        GUIContent mainTexName = new GUIContent("Diffuse", "Diffuse (RGB) and Transparency (A)");
        GUIContent normalMapName = new GUIContent("Normal Map");
        private Material targetMat;
        
        private bool visualizeVectors;

        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
        {
            if (windController == null) LocateWindController();

            //Receive
            visualizeVectors = WindController._visualizeVectors;

            this.m_MaterialEditor = materialEditor;
            targetMat = (Material)materialEditor.target;
            
            this.FindProperties(props);
            
            //Style similar to Standard shader
            m_MaterialEditor.SetDefaultGUIWidths();
            m_MaterialEditor.UseDefaultMargins();
            EditorGUIUtility.labelWidth = 0f;

#if UNITY_2019_3_OR_NEWER
            if (UnityEngine.Rendering.GraphicsSettings.currentRenderPipeline != null &&
                !targetMat.shader.name.Contains("Universal Render Pipeline"))
            {
                EditorGUILayout.HelpBox("A render pipeline is in use, but this material is using a shader for the Built-in render pipeline.\n\nShaders and materials can be converted through the Help window", MessageType.Error);
                EditorGUILayout.Space();
            }
#endif
            
            EditorGUI.BeginChangeCheck();

            //Draw fields
            DoHeader();

            DoMapsArea();
            DoColorArea();
            DoAnimationArea();

            if (EditorGUI.EndChangeCheck())
            {
                //Send
                WindController.VisualizeVectors(visualizeVectors);
            }

            GUILayout.Label("Advanced Options", EditorStyles.boldLabel);

            GUIHelper.DrawExtraFields(m_MaterialEditor);

            GUIHelper.DrawFooter();

        }

        void DoHeader()
        {
            EditorGUILayout.BeginHorizontal();
            showHelp = GUILayout.Toggle(showHelp, "Toggle help", "Button");
            GUILayout.Label("FAE Tree Branch Shader", GUIHelper.Header);
            EditorGUILayout.EndHorizontal();
            if (showHelp) EditorGUILayout.HelpBox("Please bear in mind, when using custom meshes, that most shader features require the Ambient Occlusion to be baked into the RGB vertex colors.", MessageType.Warning);
        }

        void DoMapsArea()
        {
            GUILayout.Label("Main maps", EditorStyles.boldLabel);
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.PrefixLabel(_MaskClipValue.displayName);
            _MaskClipValue.floatValue = EditorGUILayout.Slider(_MaskClipValue.floatValue, 0f, 1f);
            EditorGUILayout.EndHorizontal();

            this.m_MaterialEditor.TexturePropertySingleLine(mainTexName, this._MainTex, this._Color);
            if(targetMat.HasProperty("_BumpMap")) this.m_MaterialEditor.TexturePropertySingleLine(normalMapName, this._BumpMap);

            EditorGUILayout.Space();
        }

        void DoColorArea()
        {
            EditorGUILayout.BeginHorizontal();
            showHelpColor = GUILayout.Toggle(showHelpColor, "?", "Button", GUILayout.Width(25f)); GUILayout.Label("Color", EditorStyles.boldLabel);
            EditorGUILayout.EndHorizontal();

            m_MaterialEditor.ShaderProperty(_HueVariation, _HueVariation.displayName);
            if (showHelpColor) EditorGUILayout.HelpBox("Uses the object's world-space position to add a color variation. This effect is controlled through the alpha channel.\n\n Note: Does not work with meshes that are batched or combined", MessageType.None);
            m_MaterialEditor.ShaderProperty(_AmbientOcclusion, _AmbientOcclusion.displayName);
            if (showHelpColor) EditorGUILayout.HelpBox("Darkens the areas of the mesh where red vertex colors are applied", MessageType.None);
            m_MaterialEditor.ShaderProperty(_TransmissionColor, new GUIContent("Translucency"));
            if (showHelpColor) EditorGUILayout.HelpBox("Simulates light passing through the material. The alpha channel controls the intensity. This effect is controlled through the blue channel.", MessageType.None);
            m_MaterialEditor.ShaderProperty(_GradientBrightness, _GradientBrightness.displayName);
            if (showHelpColor) EditorGUILayout.HelpBox("Adds a gradient to the branch mesh from bottom to top. This information is stored in the alpha vertex color channel.\n\nWithout this information, the parameter will have no effect.", MessageType.None);
            m_MaterialEditor.ShaderProperty(_Smoothness, _Smoothness.displayName);
            if (showHelpColor) EditorGUILayout.HelpBox("Determines the shininess of the material", MessageType.None);
            m_MaterialEditor.ShaderProperty(_FlatLighting, _FlatLighting.displayName);
            if (showHelpColor) EditorGUILayout.HelpBox("A value of 1 makes the mesh normals point upwards. For some trees this is necessary to achieve the best visual result.", MessageType.None);

            EditorGUILayout.Space();
        }

        void DoAnimationArea()
        {
            EditorGUILayout.BeginHorizontal();
            showHelpAnimation = GUILayout.Toggle(showHelpAnimation, "?", "Button", GUILayout.Width(25f)); GUILayout.Label("Wind animation", EditorStyles.boldLabel);
            EditorGUILayout.EndHorizontal();

#if !VEGETATION_STUDIO_PRO //VS Pro has an FAE wind controller
            if (!hasWindController)
            {
                EditorGUILayout.HelpBox("No \"WindController\" component was found in your scene. Please add this script to an empty GameObject\n\nGo to GameObject->3D Object to create one", MessageType.Warning);
                EditorGUI.BeginDisabledGroup(true);

            }
#else
                EditorGUI.BeginDisabledGroup(false);
#endif

#if UNITY_2019_3_OR_NEWER
            if (UnityEngine.Rendering.GraphicsSettings.currentRenderPipeline == null)
            {
#endif
            visualizeVectors = EditorGUILayout.Toggle("Visualize wind", visualizeVectors);
#if UNITY_2019_3_OR_NEWER
            }
#endif

            if (showHelpAnimation) EditorGUILayout.HelpBox("Toggle a visualisation of the wind vectors on all the objects that use FAE shaders featuring wind.\n\nThis allows you to more clearly see the effects of the settings.", MessageType.None);

            m_MaterialEditor.ShaderProperty(_UseSpeedTreeWind, new GUIContent("Sample SpeedTree wind"));
            if (showHelpAnimation) EditorGUILayout.HelpBox("If this is a tree created using the Unity SpeedTree Modeler, this toggle will make the shader read the wind information as stored by SpeedTree.", MessageType.None);

            m_MaterialEditor.ShaderProperty(_MaxWindStrength, new GUIContent("Max wind strength"));
            if (showHelpAnimation) EditorGUILayout.HelpBox("Determines how much influence the wind has on the branches", MessageType.None);

            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.LabelField(new GUIContent("Wind Amplitude Multiplier"));
            _WindAmplitudeMultiplier.floatValue = EditorGUILayout.FloatField(_WindAmplitudeMultiplier.floatValue, GUILayout.Width(65f));
            EditorGUILayout.EndHorizontal();
            //m_MaterialEditor.ShaderProperty(_WindAmplitudeMultiplier, _WindAmplitudeMultiplier.displayName);
            if (showHelpAnimation) EditorGUILayout.HelpBox("Multiply the wind amplitude for this material. Essentally this is the size of the wind waves.", MessageType.None);

            if (hasWindController && showHelpAnimation)
            {
                GUIHelper.DrawWindInfo();
            }

            EditorGUI.EndDisabledGroup();
            EditorGUILayout.Space();
        }

        void LocateWindController()
        {
            //Debug.Log("Searching scene for WindController script");
            windController = GameObject.FindObjectOfType<WindController>();
            hasWindController = (windController) ? true : false;
        }

        public void FindProperties(MaterialProperty[] props)
        {
            //Rendering
            _MaskClipValue = FindProperty("_Cutoff", props);

            _UseSpeedTreeWind = FindProperty("_UseSpeedTreeWind", props);

            //Main maps
            _Color = FindProperty("_Color", props);
            _MainTex = FindProperty("_MainTex", props);
            if(targetMat.HasProperty("_BumpMap")) _BumpMap = FindProperty("_BumpMap", props);

            //Color
            _HueVariation = FindProperty("_HueVariation", props);
            _AmbientOcclusion = FindProperty("_AmbientOcclusion", props);
            _TransmissionColor = FindProperty("_TransmissionColor", props);
            _GradientBrightness = FindProperty("_GradientBrightness", props);
            _Smoothness = FindProperty("_Smoothness", props);
            _FlatLighting = FindProperty("_FlatLighting", props);

            //Animation
            _MaxWindStrength = FindProperty("_MaxWindStrength", props);
            _WindAmplitudeMultiplier = FindProperty("_WindAmplitudeMultiplier", props);

        }

    }
}