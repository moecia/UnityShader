// Fantasy Adventure Environment
// Copyright Staggart Creations
// staggart.xyz

using System;
using UnityEngine;
using System.Collections;
using UnityEditor;

namespace FAE
{
    [CustomEditor(typeof(CliffAppearance))]
    public class CliffAppearanceInspector : Editor
    {
        CliffAppearance ca;
        private bool showHelp = false;

        public SerializedProperty targetMaterials;
        public SerializedProperty objectColor;
        public SerializedProperty roughness;

        public SerializedProperty detailNormalMap;
        public SerializedProperty detailNormalStrength;

        public SerializedProperty globalColorMap;
        public SerializedProperty globalColor;
        public SerializedProperty globalTiling;

        public SerializedProperty useCoverageShader;
        public SerializedProperty coverageColorMap;
        public SerializedProperty coverageNormalMap;
        public SerializedProperty coverageAmount;
        public SerializedProperty coverageTiling;
        public SerializedProperty coverageMap;

#if UNITY_EDITOR
        void OnEnable()
        {
            ca = (CliffAppearance)target;
            
            targetMaterials = serializedObject.FindProperty("targetMaterials");

            objectColor = serializedObject.FindProperty("objectColor");
            roughness = serializedObject.FindProperty("roughness");

            detailNormalMap = serializedObject.FindProperty("detailNormalMap");
            detailNormalStrength = serializedObject.FindProperty("detailNormalStrength");

            globalColorMap = serializedObject.FindProperty("globalColorMap");
            globalColor = serializedObject.FindProperty("globalColor");
            globalTiling = serializedObject.FindProperty("globalTiling");

            useCoverageShader = serializedObject.FindProperty("useCoverageShader");
            coverageColorMap = serializedObject.FindProperty("coverageColorMap");
            coverageNormalMap = serializedObject.FindProperty("coverageNormalMap");
            coverageAmount = serializedObject.FindProperty("coverageAmount");
            coverageTiling = serializedObject.FindProperty("coverageTiling");
            coverageMap = serializedObject.FindProperty("coverageMap");

            Undo.undoRedoPerformed += OnUndoRedo;
        }

        private void OnDisable()
        {
            Undo.undoRedoPerformed -= OnUndoRedo;
        }

        private void OnUndoRedo()
        {
            ca.Apply();
        }

        public override void OnInspectorGUI()
        {
            serializedObject.Update();
            EditorGUI.BeginChangeCheck();

            if (ca.cliffShader == null) EditorGUILayout.HelpBox("Cliff shader could not be found!", MessageType.Error);
            if (ca.cliffCoverageShader == null) EditorGUILayout.HelpBox("Cliff Coverage shader could not be found!", MessageType.Error);

            DrawFields();

            if (EditorGUI.EndChangeCheck())
            {
                serializedObject.ApplyModifiedProperties();
                ca.Apply();
            }
        }

        private void DrawFields()
        {
            DoHeader();

            EditorGUILayout.PropertyField(targetMaterials, true);
            EditorGUILayout.Space();

            EditorGUILayout.BeginVertical(EditorStyles.helpBox);

            EditorGUILayout.LabelField("Coverage", EditorStyles.boldLabel);
            EditorGUILayout.Space();

            EditorGUILayout.PropertyField(useCoverageShader, new GUIContent("Enable"));

            if (showHelp) EditorGUILayout.HelpBox("Covers the objects from the Y-axis", MessageType.Info);

            if (ca.useCoverageShader)
            {
                EditorGUILayout.HelpBox("Currently this feature requires you to have the PigmentMapGenerator script on your terrain", MessageType.Info);

                EditorGUILayout.PropertyField(coverageMap, new GUIContent("Coverage map"));

                if (showHelp) EditorGUILayout.HelpBox("This grayscale map represents the coverage amount on the terrain \n\nThe bottom left of the texture equals the pivot point of the terrain", MessageType.Info);

                EditorGUILayout.PropertyField(coverageColorMap, new GUIContent("Albedo"));
                EditorGUILayout.PropertyField(coverageNormalMap, new GUIContent("Normals"));

                EditorGUILayout.PropertyField(coverageAmount, new GUIContent("Amount"));
                EditorGUILayout.PropertyField(coverageTiling, new GUIContent("Tiling"));
            }

            EditorGUILayout.Space();
            EditorGUILayout.EndVertical();

            EditorGUILayout.Space();

            EditorGUILayout.BeginVertical(EditorStyles.helpBox);

            EditorGUILayout.LabelField("Object", EditorStyles.boldLabel);
            EditorGUILayout.Space();

            EditorGUILayout.PropertyField(objectColor);
            EditorGUILayout.PropertyField(roughness);

            EditorGUILayout.Space();
            EditorGUILayout.EndVertical();

            EditorGUILayout.Space();

            EditorGUILayout.BeginVertical(EditorStyles.helpBox);

            EditorGUILayout.LabelField("Detail", EditorStyles.boldLabel);
            EditorGUILayout.Space();

            if (showHelp) EditorGUILayout.HelpBox("Normal details visible up close", MessageType.Info);


            EditorGUILayout.PropertyField(detailNormalMap, new GUIContent("Detail normal map"));

            EditorGUILayout.PropertyField(detailNormalStrength, new GUIContent("Normal strength"));

            EditorGUILayout.Space();
            EditorGUILayout.EndVertical();

            EditorGUILayout.Space();

            EditorGUILayout.BeginVertical(EditorStyles.helpBox);

            EditorGUILayout.LabelField("Global", EditorStyles.boldLabel);
            EditorGUILayout.Space();

            if (showHelp) EditorGUILayout.HelpBox("A tri-planar projected color map which tiles across all the objects seamlessly", MessageType.Info);

            EditorGUILayout.PropertyField(globalColorMap, new GUIContent("Global color map"));

            EditorGUILayout.PropertyField(globalColor, new GUIContent("Color"));
            EditorGUILayout.PropertyField(globalTiling, new GUIContent("Tiling"));
            
            EditorGUILayout.Space();
            EditorGUILayout.EndVertical();

            GUIHelper.DrawFooter();
        }

        private void DoHeader()
        {
            EditorGUILayout.BeginHorizontal();
            showHelp = GUILayout.Toggle(showHelp, "Toggle help", "Button");
            GUILayout.Label("FAE Cliff Appearance", GUIHelper.Header);
            EditorGUILayout.EndHorizontal();
            if (showHelp) EditorGUILayout.HelpBox("This script allows you to edit multiple materials that use the FAE/Cliff shader. When it's loaded, the settings will be applied to them, so it acts as a sort of preset loader", MessageType.Info);
        }
#endif
    }
}
