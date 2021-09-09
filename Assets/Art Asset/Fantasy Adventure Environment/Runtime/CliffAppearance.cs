// Fantasy Adventure Environment
// Copyright Staggart Creations
// staggart.xyz

using UnityEngine;
using System.Collections;

namespace FAE
{

    [ExecuteInEditMode]
    public class CliffAppearance : MonoBehaviour
    {
        public Shader cliffShader;
        public Shader cliffCoverageShader;

        public Material[] targetMaterials = new Material[0];

        //Objects
        public Color objectColor = Color.white;
        [Range(0f, 1f)]
        public float roughness = 0.15f;

        //Detail norma
        public Texture detailNormalMap;
        [Range(0f, 1f)]
        public float detailNormalStrength = 0.5f;

        //Global
        public Texture globalColorMap;
        public Color globalColor = Color.white;
        [Range(0f, 5f)]
        public float globalTiling = 0.01f;

        //Coverage
        public bool useCoverageShader;
        public Texture coverageColorMap;
        public Texture coverageNormalMap;
        [Range(0f, 1f)]
        public float coverageAmount = 0.01f;
        [Range(0f, 20f)]
        public float coverageTiling = 1f;
        public Texture coverageMap;

        public void OnEnable()
        {
            if (targetMaterials.Length == 0)
            {
                this.enabled = false;
            }

            if (UnityEngine.Rendering.GraphicsSettings.renderPipelineAsset == null)
            {
                cliffShader = Shader.Find("FAE/Cliff");
                cliffCoverageShader = Shader.Find("FAE/Cliff coverage");
            }
            else
            {
                cliffShader = Shader.Find("Universal Render Pipeline/FAE/FAE_Cliff");
                cliffCoverageShader = Shader.Find("Universal Render Pipeline/FAE/FAE_Cliff_Coverage");
            }

            Apply();
        }


        private void GetSettings()
        {
            if (!targetMaterials[0])
            {
                return;
            }
            Material mat = targetMaterials[0];

            globalColorMap = mat.GetTexture("_Globalalbedo");
            detailNormalMap = mat.GetTexture("_Detailnormal");

            objectColor = mat.GetColor("_ObjectColor");
            globalColor = mat.GetColor("_GlobalColor");

            detailNormalStrength = mat.GetFloat("_Detailstrength");
            globalTiling = mat.GetFloat("_Globaltiling");
            roughness = mat.GetFloat("_Roughness");

            if (mat.shader == cliffCoverageShader)
            {
                useCoverageShader = true;

                coverageNormalMap = mat.GetTexture("_CoverageNormals");
                coverageColorMap = mat.GetTexture("_CoverageAlbedo");
                coverageMap = mat.GetTexture("_CoverageMap");

                coverageAmount = mat.GetFloat("_CoverageAmount");
                coverageTiling = mat.GetFloat("_CoverageTiling");
            }
            else
            {
                useCoverageShader = false;
            }
        }

        public void Apply()
        {
            if (targetMaterials.Length != 0)

                foreach (Material mat in targetMaterials)
                {
                    if (!mat) continue;

                    if (useCoverageShader)
                    {
                        mat.shader = cliffCoverageShader;

                        mat.SetTexture("_CoverageNormals", coverageNormalMap);
                        mat.SetTexture("_CoverageAlbedo", coverageColorMap);
                        mat.SetTexture("_CoverageMap", coverageMap);

                        mat.SetFloat("_CoverageAmount", coverageAmount);
                        mat.SetFloat("_CoverageTiling", coverageTiling);
                    }
                    else
                    {
                        mat.shader = cliffShader;
                    }

                    //Textures
                    mat.SetTexture("_Globalalbedo", globalColorMap);
                    mat.SetTexture("_Detailnormal", detailNormalMap);

                    //Colors
                    mat.SetColor("_ObjectColor", objectColor);
                    mat.SetColor("_GlobalColor", globalColor);

                    //Floats
                    mat.SetFloat("_Detailstrength", detailNormalStrength);
                    mat.SetFloat("_Globaltiling", globalTiling);
                    mat.SetFloat("_Roughness", roughness);

                }
        }


    }
}
