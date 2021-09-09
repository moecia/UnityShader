using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rotator : MonoBehaviour
{
    public float RotateSpeed = 1.0f;

    void Update()
    {
        
        var rot = transform.rotation.eulerAngles;
        rot.y += Time.deltaTime * RotateSpeed;
        transform.eulerAngles = rot;
    }
}
