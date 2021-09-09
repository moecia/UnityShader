// Fantasy Adventure Environment
// Copyright Staggart Creations
// staggart.xyz

using UnityEngine;
using UnityEditor;
using System.Collections;

namespace FAE
{
    public class FoliageShaderGUI : ShaderGUI
    {

        MaterialProperty _MaskClipValue;

        //Main maps
        MaterialProperty _MainTex;
        MaterialProperty _BumpMap;
        MaterialProperty _Color;

        //Color
        MaterialProperty _WindTint;
        MaterialProperty _AmbientOcclusion;
        MaterialProperty _TransmissionSize;
        MaterialProperty _TransmissionAmount;

        //Animation
        MaterialProperty _MaxWindStrength;
        MaterialProperty _GlobalWindMotion;
        MaterialProperty _LeafFlutter;
        MaterialProperty _WindAmplitudeMultiplier;
        MaterialProperty _WindSwinging;
        MaterialProperty _BendingInfluence;

        MaterialEditor m_MaterialEditor;
        private Material targetMat;
        
        //Meta
        bool showHelp;
        bool showHelpColor;
        bool showHelpAnimation;

        bool hasWindController;
        WindController windController;

        GUIContent mainTexName = new GUIContent("Diffuse", "Diffuse (RGB) and Transparency (A)");
        GUIContent normalMapName = new GUIContent("Normal Map");
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

            GUIHelper.DrawExtraFields(m_MaterialEditor);
            GUIHelper.DrawFooter();
        }

        void DoHeader()
        {
            EditorGUILayout.BeginHorizontal();
            showHelp = GUILayout.Toggle(showHelp, "Toggle help", "Button");
            GUILayout.Label("FAE Foliage Shader", GUIHelper.Header);
            EditorGUILayout.EndHorizontal();
            if (showHelp) EditorGUILayout.HelpBox("Please bear in mind, when using custom meshes, that most shader feature require the tips of the mesh to be vertex colored.\n\nBaking Ambient Occlusion into the vertex colors will yield correct results.", MessageType.Warning);
        }

        void DoMapsArea()
        {
            GUILayout.Label("Main maps", EditorStyles.boldLabel);
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.PrefixLabel(_MaskClipValue.displayName);
            _MaskClipValue.floatValue = EditorGUILayout.Slider(_MaskClipValue.floatValue, 0f, 1f);
            EditorGUILayout.EndHorizontal();
            this.m_MaterialEditor.TexturePropertySingleLine(mainTexName, this._MainTex);
            if(targetMat.HasProperty("_BumpMap"))this.m_MaterialEditor.TexturePropertySingleLine(normalMapName, this._BumpMap);

            EditorGUILayout.Space();
        }

        void DoColorArea()
        {
            EditorGUILayout.BeginHorizontal();
            showHelpColor = GUILayout.Toggle(showHelpColor, "?", "Button", GUILayout.Width(25f)); GUILayout.Label("Color", EditorStyles.boldLabel);
            EditorGUILayout.EndHorizontal();

            m_MaterialEditor.ShaderProperty(_Color, _Color.displayName);
            m_MaterialEditor.ShaderProperty(_AmbientOcclusion, _AmbientOcclusion.displayName);
            if (showHelpColor) EditorGUILayout.HelpBox("Darkens the areas of the mesh where vertex colors are applied", MessageType.None);
            m_MaterialEditor.ShaderProperty(_TransmissionAmount, _TransmissionAmount.displayName);
            if (showHelpColor) EditorGUILayout.HelpBox("Simulates light passing through the material. This will have no effect on short grass.", MessageType.None);
            m_MaterialEditor.ShaderProperty(_TransmissionSize, _TransmissionSize.displayName);

            EditorGUILayout.Space();
        }

        void DoAnimationArea()
        {
            EditorGUILayout.BeginHorizontal();
            showHelpAnimation = GUILayout.Toggle(showHelpAnimation, "?", "Button", GUILayout.Width(25f)); GUILayout.Label("Wind animation", EditorStyles.boldLabel);
            EditorGUILayout.EndHorizontal();

#if UNITY_2019_3_OR_NEWER
            if (UnityEngine.Rendering.GraphicsSettings.currentRenderPipeline == null)
            {
#endif
            visualizeVectors = EditorGUILayout.Toggle("Visualize wind", visualizeVectors);
#if UNITY_2019_3_OR_NEWER
            }
#endif

#if !VEGETATION_STUDIO_PRO //VS Pro has an FAE wind controller
            if (!hasWindController)
            {
                EditorGUILayout.HelpBox("No \"WindController\" component was found in your scene. Please add this script to an empty GameObject\n\nA prefab can be found in the Prefabs/Effects folder.", MessageType.Warning);
                EditorGUI.BeginDisabledGroup(true);
            }
#else
            EditorGUI.BeginDisabledGroup(false);
#endif
            if (showHelpAnimation) EditorGUILayout.HelpBox("Toggle a visualisation of the wind vectors on all the objects that use FAE shaders featuring wind.\n\nThis allows you to more clearly see the effects of the settings.", MessageType.None);

            m_MaterialEditor.ShaderProperty(_MaxWindStrength, _MaxWindStrength.displayName);
            if (showHelpAnimation) EditorGUILayout.HelpBox("Determines how much influence the wind has on the object", MessageType.None);
            m_MaterialEditor.ShaderProperty(_GlobalWindMotion, _GlobalWindMotion.displayName);
            if (showHelpAnimation) EditorGUILayout.HelpBox("Back and forth motion", MessageType.None);
            m_MaterialEditor.ShaderProperty(_LeafFlutter, _LeafFlutter.displayName);
            if (showHelpAnimation) EditorGUILayout.HelpBox("Local wind turbulence", MessageType.None);
            m_MaterialEditor.ShaderProperty(_WindAmplitudeMultiplier, _WindAmplitudeMultiplier.displayName);
            if (showHelpAnimation) EditorGUILayout.HelpBox("Multiply the wind amplitude for this material.Essentally this is the size of the wind waves.", MessageType.None);     
            m_MaterialEditor.ShaderProperty(_WindSwinging, _WindSwinging.displayName);
            if (showHelpAnimation) EditorGUILayout.HelpBox("Higher values mean the object always sways back against the wind direction", MessageType.None);

            if (targetMat.HasProperty("_WindTint"))
            {
                m_MaterialEditor.ShaderProperty(_WindTint, _WindTint.displayName);
                if (showHelpAnimation)
                    EditorGUILayout.HelpBox("Vizualises the wind by adding a slight tint, either dark (<0) or light (>0)", MessageType.None);
            }

            if (showHelpAnimation) EditorGUILayout.HelpBox("Multiply the wind amplitude for this material. Essentally this is the size of the wind waves.", MessageType.None);
            if (!hasWindController)
            {
                EditorGUI.EndDisabledGroup();
            }
            m_MaterialEditor.ShaderProperty(_BendingInfluence, _BendingInfluence.displayName);
            if (showHelpAnimation) EditorGUILayout.HelpBox("Determines how much influence the FoliageBender script has on the object", MessageType.None);

            if (hasWindController && showHelpAnimation)
            {
                GUIHelper.DrawWindInfo();
            }

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
#if UNITY_2017_1_OR_NEWER
            _MaskClipValue = FindProperty("_Cutoff", props);
#else
            _MaskClipValue = FindProperty("_Cutoff", props);
#endif

            //Main maps
            _MainTex = FindProperty("_MainTex", props);
            if(targetMat.HasProperty("_BumpMap")) _BumpMap = FindProperty("_BumpMap", props);

            //Color
            if(targetMat.HasProperty("_WindTint")) _WindTint = FindProperty("_WindTint", props);
            _Color = FindProperty("_Color", props);
            _AmbientOcclusion = FindProperty("_AmbientOcclusion", props);
            _TransmissionSize = FindProperty("_TransmissionSize", props);
            _TransmissionAmount = FindProperty("_TransmissionAmount", props);

            //Animation
            _MaxWindStrength = FindProperty("_MaxWindStrength", props);
            _GlobalWindMotion = FindProperty("_GlobalWindMotion", props);
            _LeafFlutter = FindProperty("_LeafFlutter", props);
            _WindAmplitudeMultiplier = FindProperty("_WindAmplitudeMultiplier", props);
            _WindSwinging = FindProperty("_WindSwinging", props);
            _BendingInfluence = FindProperty("_BendingInfluence", props);

        }

    }
}
