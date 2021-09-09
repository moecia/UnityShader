// Fantasy Adventure Environment
// Staggart Creations
// http://staggart.xyz

using UnityEngine;
using System.IO;

using UnityEditor;
using System.Collections.Generic;
using System.Linq;

namespace FAE
{
    public class FAE_Core : Editor
    {
        public const string ASSET_NAME = "Fantasy Adventure Environment";
        public const string ASSET_ABRV = "FAE";
        public const string ASSET_ID = "70354";

        public const string PACKAGE_VERSION = "20174";
        public static string INSTALLED_VERSION = "1.5.5";
        public const string MIN_UNITY_VERSION = "2019.3";

        public static string DOC_URL = "http://staggart.xyz/unity/fantasy-adventure-environment/fae-documentation/";
        public static string FORUM_URL = "https://forum.unity3d.com/threads/486102";

#if UNITY_2019_3_OR_NEWER
        private const string UniversalShaderPackageGUID = "7c884420a5dfbaa4db9afe42d366b843";
#endif

        public static void OpenStorePage()
        {
            Application.OpenURL("com.unity3d.kharma:content/" + ASSET_ID);
        }

        public static string PACKAGE_ROOT_FOLDER
        {
            get { return SessionState.GetString(ASSET_ABRV + "_BASE_FOLDER", string.Empty); }
            set { SessionState.SetString(ASSET_ABRV + "_BASE_FOLDER", value); }
        }

        public static string GetRootFolder()
        {
            //Get script path
            string[] scriptGUID = AssetDatabase.FindAssets("FAE_Core t:script");
            string scriptFilePath = AssetDatabase.GUIDToAssetPath(scriptGUID[0]);

            //Truncate to get relative path
            PACKAGE_ROOT_FOLDER = scriptFilePath.Replace("/Editor/FAE_Core.cs", string.Empty);

#if FAE_DEV
            Debug.Log("<b>Package root</b> " + PACKAGE_ROOT_FOLDER);
#endif

            return PACKAGE_ROOT_FOLDER;
        }

#if UNITY_2019_3_OR_NEWER
        public enum ShaderInstallation
        {
            BuiltIn,
            UniversalRP
        }

        public class RunOnImport : AssetPostprocessor
        {
            static void OnPostprocessAllAssets(string[] importedAssets, string[] deletedAssets, string[] movedAssets, string[] movedFromAssetPaths)
            {
                foreach (string str in importedAssets)
                {
                    if (str.Contains("FAE_Core.cs"))
                    {
                        GetRootFolder();

                        string urpFolder = FAE_Core.PACKAGE_ROOT_FOLDER + "/Shaders/URP/";

                        var info = new DirectoryInfo(urpFolder);
                        FileInfo[] fileInfo = info.GetFiles();

                        //Only one file in the folder, shaders not yet unpacked
                        if (fileInfo.Length <= 2 && UnityEngine.Rendering.GraphicsSettings.renderPipelineAsset != null)
                        {
                            if (EditorUtility.DisplayDialog("Fantasy Adventure Environment", "The Universal Render Pipeline is in use.\n\nURP compatible shaders can be unpacked and materials upgraded through the \"Help\" window after importing has finished\n\nErrors about _GrabTexture can safely be ignored.", "OK"))
                            {

                            }
                        }
                    }
                }
            }
        }

        private const string urpName = "Universal Render Pipeline";

        //Look up table to finding pipeline shader variants
        private static Dictionary<string, string> ShaderRelations = new Dictionary<string, string>
        {
            //Peartickles
            //Since 7.4.1, the legacy particle shaders will work
            //{ "Legacy Shaders/Particles/Alpha Blended", urpName + "/Particles/Simple Lit" },

			//No longer needed to convert particle materials. Barely works, so particle materials are now packaged for URP
            //{ "Particles/Alpha Blended", urpName + "/Particles/Simple Lit" },
            //{ "Mobile/Particles/Alpha Blended", urpName + "/Particles/Simple Lit" },
            //{ "Particles/Standard Surface", urpName + "/Particles/Simple Lit" },
            //{ "Particles/Standard Unlit", urpName + "/Particles/Unlit" },

            { "Standard", urpName + "/Lit" },
            { "Skybox/Cubemap","Skybox/Cubemap" },
            { "Nature/Terrain/Standard", urpName + "/Terrain/Lit" },

            { "FAE/Fog sheet", urpName + "/FAE/FAE_FogSheet" },
            { "FAE/Sunshaft", urpName + "/FAE/FAE_Sunshaft" },
            //{ "FAE/Sunshaft particle", urpName + "/FAE/FAE_SunshaftParticle" },

            { "FAE/Cliff", urpName + "/FAE/FAE_Cliff" },
            { "FAE/Cliff coverage", urpName + "/FAE/FAE_Cliff_Coverage" },

            { "FAE/Water", urpName + "/FAE/FAE_Water" },
            { "FAE/Waterfall", urpName + "/FAE/FAE_Waterfall" },
            { "FAE/Waterfall foam", urpName + "/FAE/FAE_WaterfallFoam" },

            { "FAE/Foliage", urpName+ "/FAE/FAE_Foliage" },
            { "FAE/Tree Branch", urpName+ "/FAE/FAE_TreeBranch" },
            { "FAE/Tree Trunk", urpName+ "/FAE/FAE_TreeTrunk" },
            { "FAE/Tree Billboard", urpName+ "/FAE/FAE_TreeBillboard" }
        };

        [MenuItem("Edit/Render Pipeline/Fantasy Adventure Environment/Revert to Built-in")]
        public static void InstallBuiltIn()
        {
            InstallShaders(ShaderInstallation.BuiltIn);
        }

        [MenuItem("Edit/Render Pipeline/Fantasy Adventure Environment/Convert to URP")]
        public static void InstallURP()
        {

#if UNITY_2019_3_OR_NEWER && FAE_DEV
            SwitchRenderPipeline.SetPipeline(ShaderInstallation.UniversalRP);
#endif

            if (UnityEngine.Rendering.GraphicsSettings.renderPipelineAsset == null)
            {
                if (EditorUtility.DisplayDialog("Fantasy Adventure Environment", "No URP asset has been assigned in the Graphics settings. URP should be set up, before converting the package.", "Show me", "Cancel"))
                {
                    SettingsService.OpenProjectSettings("Project/Graphics");
                    return;
                }
            }

            InstallShaders(ShaderInstallation.UniversalRP);
        }

        public static void InstallShaders(ShaderInstallation config)
        {
            string guid = UniversalShaderPackageGUID;
            string packagePath = AssetDatabase.GUIDToAssetPath(guid);

            GetRootFolder();

            //TODO: Package up current shaders
            if (config == ShaderInstallation.BuiltIn)
            {
                //AssetDatabase.ExportPackage(PACKAGE_ROOT_FOLDER + "/Shaders/URP", packagePath, ExportPackageOptions.Default | ExportPackageOptions.Recurse);

                UpgradeMaterials(config);
            }
            else
            {
                if (packagePath == string.Empty)
                {
                    Debug.LogError("URP Shader/material package with the GUID: " + guid + ". Could not be found in the project, was it changed or not imported? It should be located in <i>" + PACKAGE_ROOT_FOLDER + "/Shaders/URP</i>");
                    return;
                }
                AssetDatabase.ImportPackage(packagePath, false);
                AssetDatabase.importPackageCompleted += new AssetDatabase.ImportPackageCallback(ImportURPCallback);
            }

#if UNITY_2019_3_OR_NEWER && FAE_DEV
            SwitchRenderPipeline.SetPipeline(config);
#endif

        }

        static void ImportURPCallback(string packageName)
        {
            AssetDatabase.Refresh();

            UpgradeMaterials(ShaderInstallation.UniversalRP);

            AssetDatabase.importPackageCompleted -= ImportURPCallback;
        }

        public static void UpgradeMaterials(ShaderInstallation config)
        {
            string[] GUIDs = AssetDatabase.FindAssets("t: material", new string[] { PACKAGE_ROOT_FOLDER });

            int count = 0;
            if (GUIDs.Length > 0)
            {
                Material[] mats = new Material[GUIDs.Length];

                for (int i = 0; i < mats.Length; i++)
                {
                    EditorUtility.DisplayProgressBar("Material configuration", "Converting FAE materials for " + config, (float)i / mats.Length);
                    string path = AssetDatabase.GUIDToAssetPath(GUIDs[i]);

                    mats[i] = (Material)AssetDatabase.LoadAssetAtPath(path, typeof(Material));

                    string dest = string.Empty;
                    string source = mats[i].shader.name;
                    bool matched = ShaderRelations.TryGetValue(source, out dest);

                    if (config == ShaderInstallation.BuiltIn)
                    {
                        //Get key by value (inverse lookup)
                        dest = ShaderRelations.FirstOrDefault(x => x.Value == source).Key;

                        matched = dest != null;
                    }

                    if (config == ShaderInstallation.UniversalRP)
                    {
                        //Set grass to foliage shader
                        if (source == "FAE/Grass")
                        {
                            dest = urpName + "/FAE/FAE_Foliage";
                            matched = true;
                        }
                    }
                    if (config == ShaderInstallation.BuiltIn)
                    {
                        //Set foliage to grass shader
                        if (mats[i].name.Contains("Grass"))
                        {
                            dest = "FAE/Grass";
                            matched = true;
                        }
                    }

                    if (source == null && dest == null) continue;
                    if (string.Equals(dest, source)) continue;

                    if (matched)
                    {

                        if (config == ShaderInstallation.UniversalRP)
                        {
                            Texture mainTex = null;
                            if (mats[i].HasProperty("_MainTex")) mainTex = mats[i].GetTexture("_MainTex");
                            
                            if (mats[i].HasProperty("_Color")) mats[i].SetColor("_BaseColor", mats[i].GetColor("_Color"));
                            if (mats[i].HasProperty("_TintColor")) mats[i].SetColor("_BaseColor", mats[i].GetColor("_TintColor"));

                            //Grass to foliage switch
                            if (mats[i].HasProperty("_ColorTop")) mats[i].SetColor("_Color", mats[i].GetColor("_ColorTop"));

                            if (mats[i].HasProperty("_MainTex"))
                            {
                                mats[i].SetTexture("_BaseMap", mainTex);
                            }

                            if (mats[i].name.Contains("Grass"))
                            {
                                mats[i].SetFloat("_MaxWindStrength", 0.2f);
                                mats[i].SetFloat("_AmbientOcclusion", 0.15f);
                            }

                            mats[i].shader = Shader.Find(dest);
                            
                            if (mainTex) mats[i].SetTexture("_BaseMap", mainTex);
                            
                        }

                        if (mats[i].HasProperty("_TransmissionAmount"))
                        {
                            mats[i].SetFloat("_TransmissionAmount", Mathf.Clamp(mats[i].GetFloat("_TransmissionAmount"), 0, 10));
                        }

                        //Debug.Log("src: " + source + " dst:" + dest);
                        mats[i].shader = Shader.Find(dest);

                        EditorUtility.SetDirty(mats[i]);
                        count++;
                    }
                    else
                    {
#if FAE_DEV
                        Debug.LogError("No matching " + config + " shader could be found for " + mats[i].shader.name);
#endif
                    }
                }
                EditorUtility.ClearProgressBar();
                
                Debug.Log(count + " materials were configured for the " + config + " render pipeline");

                AssetDatabase.Refresh();
                AssetDatabase.SaveAssets();

                if (config == ShaderInstallation.UniversalRP)
                {
                    delayTime = (float)EditorApplication.timeSinceStartup + renameDelaySec;
                    EditorApplication.update += PostURPConversion;
                }
            }
        }

        private static float delayTime;
        private const float renameDelaySec = 1f;
        
        private static void PostURPConversion()
        {
            //Wait 1s
            if (EditorApplication.timeSinceStartup >= delayTime)
            {
                EditorApplication.update -= PostURPConversion;
      
                //If any controllers are present in the open scene, these need to be nudged to apply the correct shaders
                CliffAppearance[] cliffControllers = GameObject.FindObjectsOfType<CliffAppearance>();
                for (int i = 0; i < cliffControllers.Length; i++)
                {
                    cliffControllers[i].OnEnable();
                }

                string[] shaderFileGUIDS = AssetDatabase.FindAssets("t: Shader", new[] {PACKAGE_ROOT_FOLDER + "/Shaders/URP"});

                //Force a re-import of the Shader Graphs, depending on the angle of the sun, and the orbit of Jupiter, they fail to reference the FAE.hlsl file if imported last
                for (int i = 0; i < shaderFileGUIDS.Length; i++)
                {
                    AssetDatabase.ImportAsset(AssetDatabase.GUIDToAssetPath(shaderFileGUIDS[i]));
                }
                
                if (EditorUtility.DisplayDialog("Fantasy Adventure Environment", "Ensure the Depth/Opaque Texture options are enabled in your pipeline settings, otherwise the water isn't visible in the game view", "Show me", "OK"))
                {
                    Selection.activeObject = UnityEngine.Rendering.GraphicsSettings.renderPipelineAsset;
                }
                
                AssetDatabase.SaveAssets();
                
            }
            
        }
#endif
    }
}//namespace