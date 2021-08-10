using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DrawTracks : MonoBehaviour
{
    public Shader DrawShader;
    [Range(1, 500)]
    public float BrushSize;
    [Range(0, 1)]
    public float BrushStrength;
    public GameObject Terrain;

    private Camera drawCamera;
    private RenderTexture splatMap;
    private Material snowMaterial;
    private Material drawMateral;
    private RaycastHit hit;

    // Start is called before the first frame update
    void Start()
    {
        drawCamera = Camera.main;
        drawMateral = new Material(DrawShader);
        drawMateral.SetVector("_Color", Color.red);
        drawMateral.SetFloat("_Size", BrushSize);
        drawMateral.SetFloat("_Strength", BrushStrength);

        snowMaterial = GetComponent<MeshRenderer>().material;
        splatMap = new RenderTexture(1024, 1024, 0, RenderTextureFormat.ARGBFloat);
        snowMaterial.SetTexture("_Splat", splatMap);
    }

    // Update is called once per frame
    void Update()
    {
        if(Input.GetMouseButton(0))
        {
            if(Physics.Raycast(drawCamera.ScreenPointToRay(Input.mousePosition), out hit))
            {
                drawMateral.SetVector("_Coordinate", new Vector4(hit.textureCoord.x, hit.textureCoord.y, 0, 0));
                var tempTex = RenderTexture.GetTemporary(splatMap.width, splatMap.height, 0, RenderTextureFormat.ARGBFloat);
                Graphics.Blit(splatMap, tempTex);
                Graphics.Blit(tempTex, splatMap, drawMateral);
                RenderTexture.ReleaseTemporary(tempTex);

            }
        }
    }

    private void OnGUI()
    {
        GUI.DrawTexture(new Rect(0, 0, 32, 32), splatMap, ScaleMode.ScaleToFit, false, 1);
    }
}
