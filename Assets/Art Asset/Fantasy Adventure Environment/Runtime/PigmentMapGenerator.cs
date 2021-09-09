// Fantasy Adventure Environment
// Copyright Staggart Creations
// staggart.xyz

using UnityEngine;
using System.Collections;
using System.IO;
using System;
using Workflow = FAE.TerrainUVUtil.Workflow;

namespace FAE
{
    using System.Collections.Generic;
#if UNITY_EDITOR
    using UnityEditor;
    using UnityEditor.SceneManagement;
    [ExecuteInEditMode]
#endif

    public class PigmentMapGenerator : MonoBehaviour
    {
        //Dev
        public bool debug = false;
        public bool performCleanup = true;
        public bool manualInput = false;

        //Terrain objects
        public GameObject[] terrainObjects;

        //Terrain utils
        public TerrainUVUtil util;
        public Workflow workflow;

        public int resIdx = 4;
        private int resolution = 1024;
        public Vector3 targetSize;
        public Vector3 targetOriginPosition;
        public Vector3 targetCenterPosition;

        //Runtime
        [SerializeField]
        public Vector4 terrainScaleOffset;

        //Terrain terrain
        public Terrain[] terrains;

        //Mesh terrain
        private MeshRenderer[] meshes;
        private Material material;

        #region Rendering
        //Constants
        const int HEIGHTOFFSET = 1000;
        const int CLIP_PADDING = 100;

        //Render options
        public LayerMask layerMask = 1;
        public float renderLightBrightness = 0.25f;
        public bool useAlternativeRenderer = false;

        //Rendering
        private Camera renderCam;
        private Light renderLight;
        private Light[] lights;
        #endregion

        #region Inputs
        //Inputs 
        public Texture2D inputHeightmap;
        public Texture2D customPigmentMap;
        public bool useCustomPigmentMap;

        //Texture options
        public bool flipVertically;
        public bool flipHortizontally;

        public enum TextureRotation
        {
            None,
            Quarter,
            Half,
            ThreeQuarters
        }
        public TextureRotation textureRotation;
        #endregion

        //Textures
        public Texture2D pigmentMap;

        //Meta
        public bool isMultiTerrain;
        public string savePath;
        private float originalTargetYPos;
        [NonSerialized]
        public bool showArea;

        //MegaSplat
        public bool hasTerrainData = true;
        public bool isMegaSplat = false;

        //Reset lighting settings
        UnityEngine.Rendering.AmbientMode ambientMode;
        Color ambientColor;
        bool enableFog;
        Material skyboxMat;

        public enum HeightmapChannel
        {
            None,
            Texture1,
            Texture2,
            Texture3,
            Texture4,
            Texture5,
            Texture6,
            Texture7,
            Texture8
        }
        public HeightmapChannel heightmapChannel = HeightmapChannel.None;
        public string HeightmapChannelName;
        public string[] terrainTextureNames;

        //Used at runtime
        private void OnEnable()
        {
            Init();
        }

        private void OnDisable()
        {
            //This is to avoid the pigment map remaining in the shader
            Shader.SetGlobalTexture("_PigmentMap", null);
        }

        private void OnDrawGizmosSelected()
        {
            if (showArea)
            {
                Color32 color = new Color(0f, 0.66f, 1f, 0.1f);
                Gizmos.color = color;
                Gizmos.DrawCube(targetCenterPosition, targetSize);
                color = new Color(0f, 0.66f, 1f, 0.66f);
                Gizmos.color = color;
                Gizmos.DrawWireCube(targetCenterPosition, targetSize);
            }

        }

        public void Init()
        {
#if UNITY_EDITOR

            CheckMegaSplat();

            if (GetComponent<Terrain>() || GetComponent<MeshRenderer>())
            {
                isMultiTerrain = false;
                //Single terrain, use first element
                terrainObjects = new GameObject[1];
                terrainObjects[0] = this.gameObject;
            }
            else
            {
                isMultiTerrain = true;
                //Init array
                if (terrainObjects == null) terrainObjects = new GameObject[0];
            }

            //Create initial pigment map
            if (pigmentMap == null)
            {
                Generate();
            }

#endif
            SetPigmentMap();

        }

        private void CheckMegaSplat()
        {
#if __MEGASPLAT__
            if(workflow == TerrainUVUtil.Workflow.Terrain)
            {
                if (terrains[0].materialType == Terrain.MaterialType.Custom)
                {
                    if (terrains[0].materialTemplate.shader.name.Contains("MegaSplat"))
                    {
                        isMegaSplat = true;
                        useAlternativeRenderer = true;
                    }
                    else
                    {
                        isMegaSplat = false;
                    }
                }
            }
#else
            isMegaSplat = false;
#endif
        }

        public void GetChildTerrainObjects(Transform parent)
        {
            //All childs, recursive
            Transform[] children = parent.GetComponentsInChildren<Transform>();

            int childCount = 0;

            //Count first level transforms
            for (int i = 0; i < children.Length; i++)
            {
                if (children[i].parent == parent) childCount++;
            }

            //Temp list
            List<GameObject> terrainList = new List<GameObject>();

            //Init array with childcount length
            this.terrainObjects = new GameObject[childCount];

            //Fill array with first level transforms
            for (int i = 0; i < children.Length; i++)
            {
                if (children[i].parent == parent)
                {
                    terrainList.Add(children[i].gameObject);
                }
            }

            terrainObjects = terrainList.ToArray();
        }

        //Grab the terrain position and size and pass it to the shaders
        public void GetTargetInfo()
        {
            if (debug) Debug.Log("Getting target info for " + terrainObjects.Length + " object(s)");

            if (!util) util = ScriptableObject.CreateInstance<TerrainUVUtil>();

            util.GetObjectPlanarUV(terrainObjects);

            //Determine if the object is a terrain or mesh
            workflow = util.workflow;

            //If using Unity Terrains
            terrains = util.terrains;

            //Avoid unused variable warning
            material = null;

            //Summed size
            targetSize = util.size;

            //First terrain makes up the corner
            targetOriginPosition = util.originPosition;

            //Center of terrain(s)
            targetCenterPosition = util.centerPostion;

            //Terrain UV
            terrainScaleOffset = util.terrainScaleOffset;


            SetPigmentMap();
        }

        //Set the pigmentmap texture on all shaders that utilize it
        public void SetPigmentMap()
        {
            if (pigmentMap)
            {
                Shader.SetGlobalVector("_TerrainUV", new Vector4(targetSize.x, targetSize.z, Mathf.Abs(targetOriginPosition.x - 1), Mathf.Abs(targetOriginPosition.z - 1)));

                //Set this at runtime to account for different instances having different pigment maps
                Shader.SetGlobalTexture("_PigmentMap", pigmentMap);
            }
        }

        public static int IndexToResolution(int i)
        {
            int res = 0;

            switch (i)
            {
                case 0:
                    res = 64; break;
                case 1:
                    res = 128; break;
                case 2:
                    res = 256; break;
                case 3:
                    res = 512; break;
                case 4:
                    res = 1024; break;
                case 5:
                    res = 2048; break;
                case 6:
                    res = 4096; break;
            }

            return res;
        }

        //Editor functions
#if UNITY_EDITOR
        //Primary function
        public void Generate()
        {
            if (terrainObjects.Length == 0) return;

            if (!manualInput)
            {
                GetTargetInfo();
            }
            else
            {
                workflow = (terrainObjects[0].GetComponent<Terrain>()) ? Workflow.Terrain : Workflow.Mesh;
            }

            //If a custom map is assigned, don't generate one, only assign
            if (useCustomPigmentMap)
            {
                pigmentMap = customPigmentMap;
                SetPigmentMap();
                return;
            }

            LightSetup();

            CameraSetup();

            MoveTerrains();

            RenderToTexture();

            SetPigmentMap();

            if (performCleanup) Cleanup();

            ResetLights();

        }

        //Position a camera above the terrain(s) so that the world positions line up perfectly with the texture UV
        public void CameraSetup()
        {
            //Create camera
            if (!renderCam)
            {
                GameObject cameraObj = new GameObject();
                cameraObj.name = this.name + " renderCam";
                renderCam = cameraObj.AddComponent<Camera>();
            }

            //Set up a square camera rect
            float rectWidth = resolution;
            rectWidth /= Screen.width;
            renderCam.rect = new Rect(0, 0, 1, 1);

            //Camera set up
            renderCam.orthographic = true;
            renderCam.orthographicSize = (targetSize.x / 2);
            renderCam.clearFlags = CameraClearFlags.Skybox;
            renderCam.allowHDR = true;

            renderCam.farClipPlane = 5000f;
            renderCam.useOcclusionCulling = false;

            renderCam.cullingMask = layerMask;

            //Rendering in Forward mode is a tad darker, so a Directional Light is used to make up for the difference
            renderCam.renderingPath = (useAlternativeRenderer || workflow == TerrainUVUtil.Workflow.Mesh) ? RenderingPath.Forward : RenderingPath.VertexLit;

            if (workflow == Workflow.Terrain)
            {
                //Hide tree objects
                foreach (Terrain terrain in terrains)
                {
                    terrain.drawTreesAndFoliage = false;
                }
            }

            //Position cam in given center of terrain(s)
            renderCam.transform.position = new Vector3(
                targetCenterPosition.x,
                targetOriginPosition.y + targetSize.y + HEIGHTOFFSET + CLIP_PADDING,
                targetCenterPosition.z
                );

            renderCam.transform.localEulerAngles = new Vector3(90, 0, 0);
        }

        private void MoveTerrains()
        {
            //Store terrain position value, to revert to
            //Safe to assume all terrains have the same Y-position, should be the case for multi-terrains
            originalTargetYPos = targetOriginPosition.y;

            //Move terrain objects way up so they are rendered on top of all other objects
            foreach (GameObject terrain in terrainObjects)
            {
                terrain.transform.position = new Vector3(terrain.transform.position.x, HEIGHTOFFSET, terrain.transform.position.z);
            }
        }

        private void RenderToTexture()
        {
            if (!renderCam) return;

            pigmentMap = null;

            //If this is a terrain with no textures, abort (except in the case of MegaSplat)
            if (workflow == Workflow.Terrain)
            {
#if UNITY_2018_3_OR_NEWER
            if (terrains[0].terrainData.terrainLayers.Length == 0 && !isMegaSplat) return;
#else
                if (terrains[0].terrainData.splatPrototypes.Length == 0 && !isMegaSplat) return;
#endif
            }

            resolution = IndexToResolution(resIdx);
            //Set up render texture
            RenderTexture rt = new RenderTexture(resolution, resolution, 0);
            renderCam.targetTexture = rt;

            savePath = GetTargetFolder();

            EditorUtility.DisplayProgressBar("PigmentMapGenerator", "Rendering texture", 1);

            //Render camera into a texture
            Texture2D render = new Texture2D(rt.width, rt.height, TextureFormat.ARGB32, false);
            RenderTexture.active = rt;
            renderCam.Render();

            //Compose texture on GPU
            rt = CompositePigmentMap(rt, inputHeightmap);

            render.ReadPixels(new Rect(0, 0, resolution, resolution), 0, 0);

            //Cleanup
            renderCam.targetTexture = null;
            RenderTexture.active = null;
            DestroyImmediate(rt);

            //Encode
            byte[] bytes = render.EncodeToPNG();

            //Create file
            EditorUtility.DisplayProgressBar("PigmentMapGenerator", "Saving texture...", 1);
            File.WriteAllBytes(savePath, bytes);

            //Import file
            AssetDatabase.Refresh();

            //Load the file
            pigmentMap = new Texture2D(resolution, resolution, TextureFormat.ARGB32, true);
            pigmentMap = AssetDatabase.LoadAssetAtPath(savePath, typeof(Texture2D)) as Texture2D;

            EditorUtility.ClearProgressBar();

        }

        //Add the heightmap and do texture transformations
        private RenderTexture CompositePigmentMap(RenderTexture inputMap, Texture2D heightmap = null)
        {
            Material compositeMat = new Material(Shader.Find("Hidden/PigmentMapComposite"));
            compositeMat.hideFlags = HideFlags.DontSave;

            compositeMat.SetTexture("_MainTex", inputMap);

            //No given heightmap, get from terrain splatmap
            //If a channel is chosen, add heightmap to the pigment map's alpha channel
            if (heightmap == null && workflow == Workflow.Terrain && (int)heightmapChannel > 0)
            {
                //Sample one of the two splatmaps (supporting 8 textures as input)
                int spatmapIndex = ((int)heightmapChannel >= 5) ? 1 : 0;
                int channelIndex = (spatmapIndex > 0) ? (int)heightmapChannel - 4 : (int)heightmapChannel;

                Texture2D splatmap = terrains[0].terrainData.alphamapTextures[spatmapIndex];

                compositeMat.SetTexture("_SplatMap", splatmap);
                compositeMat.SetVector("_SplatMask", new Vector4(
                    channelIndex == 1 ? 1 : 0,
                    channelIndex == 2 ? 1 : 0,
                    channelIndex == 3 ? 1 : 0,
                    channelIndex == 4 ? 1 : 0)
                    );
            }

            if (workflow == Workflow.Mesh)
            {
                //Transforms
                Vector4 transform = new Vector4(0, 0, 0, 0);
                if (flipHortizontally) transform.x = 1;
                if (flipVertically) transform.y = 1;
                transform.z = -(int)textureRotation * (Mathf.PI / 2f);

                compositeMat.SetVector("_Transform", transform);
            }

            if (heightmap != null && isMultiTerrain) //Custom heightmap only for multi-terrains
            {
                compositeMat.SetTexture("_SplatMap", heightmap);

                //Given heightmap is already a grayscale map, unmask all color channels
                compositeMat.SetVector("_SplatMask", new Vector4(1, 0, 0, 0));
            }

            //Render shader output
            RenderTexture rt = new RenderTexture(inputMap.width, inputMap.height, 0);
            RenderTexture.active = rt;

            Graphics.Blit(inputMap, rt, compositeMat);
            DestroyImmediate(compositeMat);

            //inputMap.ReadPixels(new Rect(0, 0, inputMap.width, inputMap.height), 0, 0);
            //inputMap.Apply();

            //RenderTexture.active = null;

            return rt;
        }

        //Store pigment map next to TerrainData asset, or mesh's material
        private string GetTargetFolder()
        {
            string m_targetPath = null;

            //Compose target file path

            //For single terrain
            if (terrainObjects.Length == 1)
            {
                if (workflow == TerrainUVUtil.Workflow.Terrain)
                {
                    //If there is a TerraData asset, use its file location
                    if (terrains[0].terrainData.name != string.Empty)
                    {
                        hasTerrainData = true;
                        m_targetPath = AssetDatabase.GetAssetPath(terrains[0].terrainData) + string.Format("{0}_pigmentmap.png", terrains[0].terrainData.name);
                        m_targetPath = m_targetPath.Replace(terrains[0].terrainData.name + ".asset", string.Empty);
                    }
                    //If there is no TerrainData, store it next to the scene. Some terrain systems don't use TerrainData
                    else
                    {
                        hasTerrainData = false;
                        string scenePath = EditorSceneManager.GetActiveScene().path.Replace(".unity", string.Empty);
                        m_targetPath = scenePath + "_pigmentmap.png";
                    }
                }
                //If the target is a mesh, use the location of its material
                else if (workflow == TerrainUVUtil.Workflow.Mesh)
                {
                    material = terrainObjects[0].GetComponent<MeshRenderer>().sharedMaterial;
                    m_targetPath = AssetDatabase.GetAssetPath(material) + string.Format("{0}_pigmentmap.png", string.Empty);
                    m_targetPath = m_targetPath.Replace(".mat", string.Empty);
                }
            }
            //For multi-terrain, use scene folder or material
            else
            {
                if (workflow == TerrainUVUtil.Workflow.Mesh)
                {
                    material = terrainObjects[0].GetComponent<MeshRenderer>().sharedMaterial;
                    m_targetPath = AssetDatabase.GetAssetPath(material) + string.Format("{0}_pigmentmap.png", string.Empty);
                    m_targetPath = m_targetPath.Replace(".mat", string.Empty);
                }
                else
                {
                    string scenePath = EditorSceneManager.GetActiveScene().path.Replace(".unity", string.Empty);
                    m_targetPath = scenePath + "_pigmentmap.png";

                }
            }

            return m_targetPath;
        }

        void Cleanup()
        {
            DestroyImmediate(renderCam.gameObject);

            if (renderLight) DestroyImmediate(renderLight.gameObject);

            //Reset terrains
            foreach (GameObject terrain in terrainObjects)
            {
                //Reset terrain position(s)
                terrain.transform.position = new Vector3(terrain.transform.position.x, originalTargetYPos, terrain.transform.position.z);
            }

            //Reset draw foliage
            if (workflow == TerrainUVUtil.Workflow.Terrain)
            {
                foreach (Terrain terrain in terrains)
                {
                    terrain.drawTreesAndFoliage = true;
                }
            }

            renderCam = null;
            renderLight = null;

        }

        //Disable directional light and set ambient color to white for an albedo result
        void LightSetup()
        {
            //Set up lighting for a proper albedo color
            lights = FindObjectsOfType<Light>();
            foreach (Light light in lights)
            {
                if (light.type == LightType.Directional)
                    light.gameObject.SetActive(false);
            }

            //Store current settings to revert to
            ambientMode = RenderSettings.ambientMode;
            ambientColor = RenderSettings.ambientLight;
            enableFog = RenderSettings.fog;
            skyboxMat = RenderSettings.skybox;

            //Flat lighting 
            RenderSettings.ambientMode = UnityEngine.Rendering.AmbientMode.Flat;
            RenderSettings.ambientLight = Color.white;
            RenderSettings.fog = false;
            RenderSettings.skybox = null;

            //To account for Forward rendering being slightly darker, add a light
            if (useAlternativeRenderer)
            {
                if (!renderLight) renderLight = new GameObject().AddComponent<Light>();
                renderLight.name = "renderLight";
                renderLight.type = LightType.Directional;
                renderLight.transform.localEulerAngles = new Vector3(90, 0, 0);
                renderLight.intensity = renderLightBrightness;
            }

        }

        //Re-enable directional light and reset ambient mode
        void ResetLights()
        {
            foreach (Light light in lights)
            {
                if (light.type == LightType.Directional)
                    light.gameObject.SetActive(true);
            }

            RenderSettings.ambientMode = ambientMode;
            RenderSettings.ambientLight = ambientColor;
            RenderSettings.fog = enableFog;
            RenderSettings.skybox = skyboxMat;
        }
#endif
    }
}