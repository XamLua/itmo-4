using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CmController : MonoBehaviour
{

	//public
	public float minX = -60f;
	public float maxX = 60f;
	public float minY = -360f;
	public float maxY = 360f;

	public float sensX = 15f;
	public float sensY = 15f;

	public Camera cm;

	//private
	float rotationY = 0f;
	float rotationX = 0f;


    // Start is called before the first frame update
    void Start()
    {
        Cursor.lockState = CursorLockMode.Locked;
    }

    // Update is called once per frame
    void Update()
    {
        rotationY += Input.GetAxis("Mouse X") * sensY;
        rotationX += Input.GetAxis("Mouse Y") * sensX;

        rotationX = Mathf.Clamp(rotationX, minX, maxX);

        transform.localEulerAngles = new Vector3(0, rotationY, 0);
        cm.transform.localEulerAngles = new Vector3(-rotationX, rotationY, 0);

        if(Input.GetKey(KeyCode.Escape))
        {
        	Cursor.lockState = CursorLockMode.None;
        	Cursor.visible = true;
        }
    }
}
