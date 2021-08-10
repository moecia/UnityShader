using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WheelTracks : MonoBehaviour
{
    public Shader DrawShader;
    [Range(0, 2)]
    public float BrushSize;
    [Range(0, 1)]
    public float BrushStrength;
    public GameObject Terrain;
    public Transform[] Wheels;

    private RenderTexture splatMap;
    private Material snowMaterial;
    private Material drawMateral;
    private RaycastHit hit;
    private int layerMask;
    
    // Start is called before the first frame update
    void Start()
    {
        layerMask = LayerMask.GetMask("Ground");
        drawMateral = new Material(DrawShader);
        drawMateral.SetVector("_Color", Color.red);
        drawMateral.SetFloat("_Size", BrushSize);
        drawMateral.SetFloat("_Strength", BrushStrength);

        snowMaterial = Terrain.GetComponent<MeshRenderer>().material;
        splatMap = new RenderTexture(1024, 1024, 0, RenderTextureFormat.ARGBFloat);
        snowMaterial.SetTexture("_Splat", splatMap);
    }

    // Update is called once per frame
    void Update()
    {
        for (int i = 0; i < Wheels.Length; i++)
        {
            if (Physics.Raycast(Wheels[i].position, Vector3.down, out hit, 1f, layerMask))
            {
                drawMateral.SetVector("_Coordinate", new Vector4(hit.textureCoord.x, hit.textureCoord.y, 0, 0));
                var tempTex = RenderTexture.GetTemporary(splatMap.width, splatMap.height, 0, RenderTextureFormat.ARGBFloat);
                Graphics.Blit(splatMap, tempTex);
                Graphics.Blit(tempTex, splatMap, drawMateral);
                RenderTexture.ReleaseTemporary(tempTex);
            }
        }
    }
}
