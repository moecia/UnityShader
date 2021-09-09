// Fantasy Adventure Environment
// Copyright Staggart Creations
// staggart.xyz

using UnityEngine;
using UnityEditor;
using System.Collections;

namespace FAE
{
    [ExecuteInEditMode]
    public class GrassShaderGUI : ShaderGUI
    {

        MaterialProperty _MaskClipValue;

        //Main maps
        MaterialProperty _MainTex;
        MaterialProperty _BumpMap;

        //Color
        MaterialProperty _ColorTop;
        MaterialProperty _ColorBottom;
        MaterialProperty _ColorVariation;
        MaterialProperty _AmbientOcclusion;
        MaterialProperty _TransmissionSize;
        MaterialProperty _TransmissionAmount;

        //Animation
        MaterialProperty _MaxWindStrength;
        MaterialProperty _WindSwinging;
        MaterialProperty _WindAmplitudeMultiplier;
        MaterialProperty _BendingInfluence;

        //VS Touch Bend
#if TOUCH_REACT
        MaterialProperty _VS_TOUCHBEND;
        MaterialProperty _BendingTint;
#endif

        //Heightmap
        MaterialProperty _HeightmapInfluence;
        MaterialProperty _MinHeight;
        MaterialProperty _MaxHeight;

        //Pigment map
        MaterialProperty _PigmentMapInfluence;
        MaterialProperty _PigmentMapHeight;

        MaterialEditor m_MaterialEditor;

        //Meta
        bool showHelp;
        bool showHelpColor;
        bool showHelpAnimation;
        bool showHelpBending;
        bool showHelpHeightmap;
        bool showHelpPigmentmap;
#if UNITY_5_5_OR_NEWER
        bool hasPigmentMap = true;
#endif
        bool hasWindController;
        WindController windController;

        GUIContent mainTexName = new GUIContent("Diffuse", "Diffuse (RGB) and Transparency (A)");
        GUIContent normalMapName = new GUIContent("Normal Map");
        private bool visualizeVectors;

        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
        {
            if (windController == null) LocateWindController();
            this.FindProperties(props);

            //Receive
            visualizeVectors = WindController._visualizeVectors;

            this.m_MaterialEditor = materialEditor;

            //Style similar to Standard shader
            m_MaterialEditor.SetDefaultGUIWidths();
            m_MaterialEditor.UseDefaultMargins();
            EditorGUIUtility.labelWidth = 0f;

            //GetGlobalTexture is only available since Unity 5.5
#if UNITY_5_5_OR_NEWER

            hasPigmentMap = (Shader.GetGlobalTexture("_PigmentMap")) ? true : false;
#endif

            EditorGUI.BeginChangeCheck();

            //Draw fields
            DoHeader();

            DoMapsArea();
            DoColorArea();
            DoAnimationArea();
            DoBendingArea();
            DoHeightmapArea();
            DoPigmentMapArea();

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
            GUILayout.Label("FAE Grass Shader", GUIHelper.Header);
            EditorGUILayout.EndHorizontal();
            if (showHelp) EditorGUILayout.HelpBox("Please bear in mind, when using custom meshes, that most shader feature require the top of the mesh to be vertex colored.", MessageType.Warning);
        }

        void DoMapsArea()
        {
            GUILayout.Label("Main maps", EditorStyles.boldLabel);
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.PrefixLabel(_MaskClipValue.displayName);
            _MaskClipValue.floatValue = EditorGUILayout.Slider(_MaskClipValue.floatValue, 0f, 1f);
            EditorGUILayout.EndHorizontal();
            this.m_MaterialEditor.TexturePropertySingleLine(mainTexName, this._MainTex);
            this.m_MaterialEditor.TexturePropertySingleLine(normalMapName, this._BumpMap);

            EditorGUILayout.Space();
        }

        void DoColorArea()
        {
            EditorGUILayout.BeginHorizontal();
            showHelpColor = GUILayout.Toggle(showHelpColor, "?", "Button", GUILayout.Width(25f)); GUILayout.Label("Color", EditorStyles.boldLabel);
            EditorGUILayout.EndHorizontal();

            EditorGUI.BeginDisabledGroup(_PigmentMapInfluence.floatValue == 1);
            m_MaterialEditor.ShaderProperty(_ColorTop, "Top");
            m_MaterialEditor.ShaderProperty(_ColorBottom, "Bottom");
            EditorGUI.EndDisabledGroup();

            if (_PigmentMapInfluence.floatValue == 1)
            {
            EditorGUILayout.HelpBox("These colors are disabled because the pigment map influence value is set to 1, so they would have no effect", MessageType.None);
            }


            m_MaterialEditor.ShaderProperty(_ColorVariation, _ColorVariation.displayName);
            if (showHelpColor) EditorGUILayout.HelpBox("Vizualises the wind by adding a slight white tint. When the wind strength is set 0, this effect doesn't appear", MessageType.None);
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

            visualizeVectors = EditorGUILayout.Toggle("Visualize wind", visualizeVectors);

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
            m_MaterialEditor.ShaderProperty(_WindSwinging, _WindSwinging.displayName);
            if (showHelpAnimation) EditorGUILayout.HelpBox("Higher values mean the object always sways back against the wind direction", MessageType.None);

            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.LabelField(_WindAmplitudeMultiplier.displayName);
            _WindAmplitudeMultiplier.floatValue = EditorGUILayout.FloatField(_WindAmplitudeMultiplier.floatValue, GUILayout.Width(65f));
            EditorGUILayout.EndHorizontal();

            if (showHelpAnimation) EditorGUILayout.HelpBox("Multiply the wind amplitude for this material. Essentally this is the size of the wind waves.", MessageType.None);
            if (!hasWindController)
            {
                EditorGUI.EndDisabledGroup();
            }

            if (hasWindController && showHelpAnimation)
            {
                GUIHelper.DrawWindInfo();
            }

            EditorGUILayout.Space();

        }

        void DoBendingArea()
        {
            EditorGUILayout.BeginHorizontal();
            showHelpBending = GUILayout.Toggle(showHelpBending, "?", "Button", GUILayout.Width(25f)); GUILayout.Label("Bending", EditorStyles.boldLabel);
            EditorGUILayout.EndHorizontal();

#if TOUCH_REACT
            m_MaterialEditor.ShaderProperty(_VS_TOUCHBEND, new GUIContent("Use Vegetation Studio TouchBend"));
            if (showHelpBending) EditorGUILayout.HelpBox("Utilize Vegetation Studio's TouchBendSystem", MessageType.None);

            if (_VS_TOUCHBEND.floatValue == 1)
            {
                m_MaterialEditor.ShaderProperty(_BendingTint, _BendingTint.displayName);
                if (showHelpBending) EditorGUILayout.HelpBox("Darken the grass where it is bending", MessageType.None);

            }
            else
#endif
            {
                m_MaterialEditor.ShaderProperty(_BendingInfluence, _BendingInfluence.displayName);
                if (showHelpBending) EditorGUILayout.HelpBox("Determines how much influence the FoliageBender script has on the object", MessageType.None);

            }

            EditorGUILayout.Space();
        }

        void LocateWindController()
        {
            //Debug.Log("Searching scene for WindController script");
            windController = GameObject.FindObjectOfType<WindController>();
            hasWindController = (windController) ? true : false;
        }

        void DoHeightmapArea()
        {
            EditorGUILayout.BeginHorizontal();
            showHelpHeightmap = GUILayout.Toggle(showHelpHeightmap, "?", "Button", GUILayout.Width(25f)); GUILayout.Label("Heightmap", EditorStyles.boldLabel);
            EditorGUILayout.EndHorizontal();
#if UNITY_5_5_OR_NEWER
            if(!hasPigmentMap)
            {
            EditorGUILayout.HelpBox("No height map was found, please add the PigmentMapGenerator script to your terrain to enable these features", MessageType.Warning);
                _HeightmapInfluence.floatValue = 0;
                EditorGUI.BeginDisabledGroup(true);
            }
#endif
            if (showHelpHeightmap) EditorGUILayout.HelpBox("The heightmap is generated through the PigmentMapGenerator script on your terrain", MessageType.None);
            m_MaterialEditor.ShaderProperty(_HeightmapInfluence, "Influence");
            if (showHelpHeightmap) EditorGUILayout.HelpBox("Determines the influence the heightmap has on the object", MessageType.None);
            m_MaterialEditor.ShaderProperty(_MinHeight, _MinHeight.displayName);
            if (showHelpHeightmap) EditorGUILayout.HelpBox("Minimum grass height", MessageType.None);
            m_MaterialEditor.ShaderProperty(_MaxHeight, _MaxHeight.displayName);
            if (showHelpHeightmap) EditorGUILayout.HelpBox("Maximum grass height", MessageType.None);

            EditorGUILayout.Space();
#if UNITY_5_5_OR_NEWER
            if (!hasPigmentMap)
            {
                EditorGUI.EndDisabledGroup();
            }
#endif
        }

        void DoPigmentMapArea()
        {

            EditorGUILayout.BeginHorizontal();
            showHelpPigmentmap = GUILayout.Toggle(showHelpPigmentmap, "?", "Button", GUILayout.Width(25f)); GUILayout.Label("Pigment map", EditorStyles.boldLabel);
            EditorGUILayout.EndHorizontal();

#if UNITY_5_5_OR_NEWER
            if(!hasPigmentMap)
            {
                EditorGUILayout.HelpBox("No pigment map was found, please add the PigmentMapGenerator script to your terrain to enable these features", MessageType.Warning);
                _PigmentMapInfluence.floatValue = 0;
                EditorGUI.BeginDisabledGroup(true);
            }
            
#endif
            if (showHelpPigmentmap) EditorGUILayout.HelpBox("The pigment map is generated through the PigmentMapGenerator script on your terrain. It colors the grass by the terrain's color.", MessageType.None);
            m_MaterialEditor.ShaderProperty(_PigmentMapInfluence, "Influence");
            if (showHelpPigmentmap) EditorGUILayout.HelpBox("Determines how much the object should be colored through the pigment map", MessageType.None);
            m_MaterialEditor.ShaderProperty(_PigmentMapHeight, "Height");
            if (showHelpPigmentmap) EditorGUILayout.HelpBox("With this parameter you can choose to only color the base of the grass", MessageType.None);

            EditorGUILayout.Space();
            if (showHelpPigmentmap) EditorGUILayout.HelpBox("If your grass is completely white, bring the Influence parameter to 0. Or add the PigmentmapGenerator script to your terrain.", MessageType.Info);

#if UNITY_5_4 && !UNITY_5_5_OR_NEWER
            if (showHelpPigmentmap) EditorGUILayout.HelpBox("In versions older than Unity 5.5, it is possible for your grass to still be colored by the last pigment map generated", MessageType.Info);
#endif


            EditorGUILayout.Space();
#if UNITY_5_5_OR_NEWER
            if (!hasPigmentMap)
            {
                EditorGUI.EndDisabledGroup();
            }
#endif
        }

        public void FindProperties(MaterialProperty[] props)
        {
            //Rendering
            _MaskClipValue = FindProperty("_Cutoff", props);

            //Main maps
            _MainTex = FindProperty("_MainTex", props);
            _BumpMap = FindProperty("_BumpMap", props);

            //Color
            _ColorTop = FindProperty("_ColorTop", props);
            _ColorBottom = FindProperty("_ColorBottom", props);
            _ColorVariation = FindProperty("_ColorVariation", props);
            _AmbientOcclusion = FindProperty("_AmbientOcclusion", props);
            _TransmissionSize = FindProperty("_TransmissionSize", props);
            _TransmissionAmount = FindProperty("_TransmissionAmount", props);

            //Animation
            _MaxWindStrength = FindProperty("_MaxWindStrength", props);
            _WindSwinging = FindProperty("_WindSwinging", props);
            _WindAmplitudeMultiplier = FindProperty("_WindAmplitudeMultiplier", props);
            _BendingInfluence = FindProperty("_BendingInfluence", props);

#if TOUCH_REACT
            //TouchBend
            _VS_TOUCHBEND = FindProperty("_VS_TOUCHBEND", props);
            _BendingTint = FindProperty("_BendingTint", props);
#endif

            //Heightmap
            _HeightmapInfluence = FindProperty("_HeightmapInfluence", props);
            _MinHeight = FindProperty("_MinHeight", props);
            _MaxHeight = FindProperty("_MaxHeight", props);

            //Pigment map
            _PigmentMapInfluence = FindProperty("_PigmentMapInfluence", props);
            _PigmentMapHeight = FindProperty("_PigmentMapHeight", props);


        }

    }
}
