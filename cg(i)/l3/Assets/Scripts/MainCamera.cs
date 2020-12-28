using UnityEngine;
using System.Collections;
 
public class MainCamera : MonoBehaviour {
    
    public Rigidbody player;

    void Update () {

        transform.position = player.position;
       
    }
}