// Fantasy Adventure Environment
// Copyright Staggart Creations
// staggart.xyz

using UnityEngine;
using System.Collections;

namespace FAE
{

#if UNITY_EDITOR
    [ExecuteInEditMode]
#endif

    public class TerrainUVUtil : ScriptableObject
    {

        //Dev
        public static readonly bool debug = false;

        //Public
        public enum Workflow
        {
            None,
            Terrain,
            Mesh
        }
        public Workflow workflow = Workflow.None;

        public Bounds meshBounds;
        public Vector3 pivotPos;

        public float height;
        public float bottom;
        public Vector3 size;
        public Vector3 centerPostion;
        public Vector3 originPosition;

        public Terrain[] terrains;
        public MeshRenderer[] meshes;

        public Vector4 terrainScaleOffset;

        public void GetObjectPlanarUV(GameObject[] gameObjects)
        {
            //No objects given
            if (gameObjects.Length == 0)
            {
                Debug.LogError("No objects given to render!");
                return;
            }

            //Determine workflow
            if (gameObjects[0].GetComponent<Terrain>())
            {
                workflow = Workflow.Terrain;
                GetTerrainInfo(gameObjects);
            }
            else if (gameObjects[0].GetComponent<MeshRenderer>())
            {
                workflow = Workflow.Mesh;
                GetMeshInfo(gameObjects);
            }
            //Safeguard
            else
            {
                workflow = Workflow.None;
                Debug.LogError("Terrain UV Utility: Current object is neither a terrain nor a mesh!");
                return;
            }

#if UNITY_EDITOR
            if (debug)
            {
                Debug.Log("Summed size: " + size);
                Debug.Log("Center position: " + centerPostion);
                Debug.Log("Origin position:" + originPosition);
            }
#endif
        }

        private void GetMeshInfo(GameObject[] meshObjects)
        {
            height = 0;
            size = Vector3.zero;
            MeshRenderer mesh;

            //Init mesh terrain array
            meshes = new MeshRenderer[meshObjects.Length];

            Bounds cornerMeshBounds = new Bounds();

            for (int i = 0; i < meshObjects.Length; i++)
            {
                mesh = meshObjects[i].GetComponent<MeshRenderer>();
                meshBounds = mesh.bounds;

                //Store the bounds of the first, corner, mesh
                if (i == 0) cornerMeshBounds = meshBounds;

                //Mesh size has to be uniform
                if (!IsApproximatelyEqual(meshBounds.extents.x, meshBounds.extents.z))
                {
                    Debug.LogWarningFormat("[PigmentMapGenerator] size of \"{0}\" is not uniform at {1}! This is required for correct results.", mesh.name, meshBounds.extents.x + "x" + meshBounds.extents.z);
                }

                //Set height to highest terrain
                if (meshBounds.size.y > height)
                {
                    height = meshBounds.size.y;
                }

                //With every terrain, size is increased
                size.x += meshBounds.size.x;
                size.z += meshBounds.size.z;
            }

            size.y = height;

            //Multi-terrain
            if (meshObjects.Length > 1)
            {
                size.x /= Mathf.Sqrt(meshObjects.Length);
                size.z /= Mathf.Sqrt(meshObjects.Length);
                originPosition = cornerMeshBounds.min;
                originPosition.y = meshObjects[0].transform.position.y;
                centerPostion = new Vector3(cornerMeshBounds.min.x + (size.x / 2), height / 2f, cornerMeshBounds.min.z + (size.z / 2));
            }
            //Single terrain
            else
            {
                originPosition = cornerMeshBounds.min;
                originPosition.y = meshObjects[0].transform.position.y;
                centerPostion = cornerMeshBounds.center;
            }

            terrainScaleOffset = new Vector4(size.x, size.z, originPosition.x, originPosition.z);

            Shader.SetGlobalVector("_TerrainUV", terrainScaleOffset);
        }

        private void GetTerrainInfo(GameObject[] terrainObjects)
        {
            height = 0;
            size = Vector3.zero;
            Terrain terrain;

            //Init terrain array
            terrains = new Terrain[terrainObjects.Length];

            for (int i = 0; i < terrainObjects.Length; i++)
            {

                terrain = terrainObjects[i].GetComponent<Terrain>();
                terrains[i] = terrain;

                //Terrain size has to be uniform
                if (!IsApproximatelyEqual(terrain.terrainData.size.x, terrain.terrainData.size.z))
                {
                    Debug.LogErrorFormat(this.name + ": size of \"{0}\" is not uniform at {1}!", terrain.name, terrain.terrainData.size.x + "x" + terrain.terrainData.size.z);
                    return;
                }

                //Set height to highest terrain
                if (terrain.terrainData.size.y > height)
                {
                    height = terrain.terrainData.size.y;
                }
                if (terrains[i].transform.position.y < bottom)
                {
                    bottom = terrain.transform.position.y;
                }

                //With every terrain, size is increased
                size += terrain.terrainData.size;
            }

            //For multi terrains, divide by square root of num tiles to get total size
            if (terrainObjects.Length > 1)
            {
                size /= Mathf.Sqrt(terrainObjects.Length);
            }

            //First terrain is considered the corner and origin
            originPosition = terrains[0].transform.position;

            //Offset origin point by half the size to get center
            centerPostion = new Vector3(originPosition.x + (size.x / 2f), originPosition.y + (height / 2f), originPosition.z + (size.z / 2f));
        }

        //Check if values are equal, has error margin for floating point precision
        private bool IsApproximatelyEqual(float a, float b)
        {
            return Mathf.Abs(a - b) < 0.02f;
        }

    }
}
