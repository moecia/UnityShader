#if VEGETATION_STUDIO_PRO
using AwesomeTechnologies.VegetationSystem;
using UnityEngine;

namespace AwesomeTechnologies.Shaders
{
    // ReSharper disable once InconsistentNaming
    public class FAETreeShaderController : IShaderController
    {
        private static readonly string[] BranchShaderNames =
        {
            "FAE/Tree Branch",
            "Universal Render Pipeline/FAE/FAE_TreeBranch"
        };

        private static readonly string[] TrunkShaderNames =
        {
            "FAE/Tree Trunk",
            "Universal Render Pipeline/FAE/FAE_TreeTrunk"
        };

        public bool MatchShader(string shaderName)
        {
            if (string.IsNullOrEmpty(shaderName)) return false;

            for (int i = 0; i <= BranchShaderNames.Length - 1; i++)
            {
                if (BranchShaderNames[i].Contains(shaderName)) return true;
            }

            for (int i = 0; i <= TrunkShaderNames.Length - 1; i++)
            {
                if (TrunkShaderNames[i].Contains(shaderName)) return true;
            }
            return false;
        }

        public bool MatchBillboardShader(Material[] materials)
        {
            //VSP will skip any LODs matching this shader, bypass when URP is in use so billboards are still rendered
            if (UnityEngine.Rendering.GraphicsSettings.renderPipelineAsset != null) return false;

            for (int i = 0; i <= materials.Length - 1; i++)
            {
                if (materials[i].shader.name == "FAE/Tree Billboard" || materials[i].shader.name == "Universal Render Pipeline/FAE/FAE_TreeBillboard") return true;
            }
            return false;
        }

        bool IsTrunkShader(string shaderName)
        {
            for (int i = 0; i <= TrunkShaderNames.Length - 1; i++)
            {
                if (TrunkShaderNames[i].Contains(shaderName)) return true;
            }

            return false;
        }

        public ShaderControllerSettings Settings { get; set; }
        public void CreateDefaultSettings(Material[] materials)
        {
            Settings = new ShaderControllerSettings
            {
                Heading = "Fantasy Adventure Environment Tree",
                Description = "",
                LODFadePercentage = true,
                LODFadeCrossfade = true,
                SampleWind = true,
                SupportsInstantIndirect = true
            };

            Settings.AddLabelProperty("Branch");
            Settings.AddColorProperty("Color", "Main color", "", ShaderControllerSettings.GetColorFromMaterials(materials, "_Color"));
            Settings.AddColorProperty("HueVariation", "Hue Variation", "",
                ShaderControllerSettings.GetColorFromMaterials(materials, "_HueVariation"));
            Settings.AddColorProperty("TransmissionColor", "Transmission Color", "",
                ShaderControllerSettings.GetColorFromMaterials(materials, "_TransmissionColor"));
            Settings.AddFloatProperty("AmbientOcclusionBranch", "Ambient Occlusion", "",
             ShaderControllerSettings.GetFloatFromMaterials(materials, "_AmbientOcclusion"), 0, 1);
            Settings.AddFloatProperty("GradientBrightnessBranch", "Gradient Brightness", "",
                ShaderControllerSettings.GetFloatFromMaterials(materials, "_GradientBrightness"), 0, 2);

            Settings.AddLabelProperty("Trunk");
            Settings.AddFloatProperty("GradientBrightnessTrunk", "Gradient Brightness", "",
                ShaderControllerSettings.GetFloatFromMaterials(materials, "_GradientBrightness"), 0, 2);
            Settings.AddFloatProperty("AmbientOcclusionTrunk", "Ambient Occlusion", "",
                ShaderControllerSettings.GetFloatFromMaterials(materials, "_AmbientOcclusion"), 0, 1);

            Settings.AddLabelProperty("Branch Wind");
            Settings.AddFloatProperty("WindInfluence", "Max Strength", "", ShaderControllerSettings.GetFloatFromMaterials(materials, "_MaxWindStrength"), 0, 1);
            Settings.AddFloatProperty("WindAmplitude", "Amplitude Multiplier", "", ShaderControllerSettings.GetFloatFromMaterials(materials, "_WindAmplitudeMultiplier"), 0, 10);

        }

        public void UpdateMaterial(Material material, EnvironmentSettings environmentSettings)
        {
            if (Settings == null) return;

            bool isTrunk = IsTrunkShader(material.shader.name);

            if (isTrunk)
            {
                material.SetFloat("_AmbientOcclusion", Settings.GetFloatPropertyValue("AmbientOcclusionTrunk"));
                material.SetFloat("_GradientBrightness", Settings.GetFloatPropertyValue("GradientBrightnessTrunk"));
            }
            else
            {
                material.SetColor("_Color", Settings.GetColorPropertyValue("Color"));
                material.SetColor("_HueVariation", Settings.GetColorPropertyValue("HueVariation"));
                material.SetColor("_TransmissionColor", Settings.GetColorPropertyValue("TransmissionColor"));
                material.SetFloat("_AmbientOcclusion", Settings.GetFloatPropertyValue("AmbientOcclusionBranch"));
                material.SetFloat("_GradientBrightness", Settings.GetFloatPropertyValue("GradientBrightnessBranch"));

                material.SetFloat("_MaxWindStrength", Settings.GetFloatPropertyValue("WindInfluence"));
                material.SetFloat("_WindAmplitudeMultiplier", Settings.GetFloatPropertyValue("WindAmplitude"));
            }
        }

        public void UpdateWind(Material material, WindSettings windSettings)
        {
            
        }
    }
}
#endif
