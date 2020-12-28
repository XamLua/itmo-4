using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DoorController : MonoBehaviour
{
	public GameObject leftSide;
	public GameObject rightSide;

	//private
	Vector3 lOpen;
	Vector3 lClose;
	Vector3 rOpen;
	Vector3 rClose;

	float oDistance = 5;

	bool isOpen = false;
	int moving = 0;

	public float speed = 0.02f;

	float newX;

    // Start is called before the first frame update
    void Start()
    {
        lClose = leftSide.transform.localPosition;
        rClose = rightSide.transform.localPosition;

        lOpen = leftSide.transform.localPosition + new Vector3(-oDistance, 0, 0);
        rOpen = rightSide.transform.localPosition + new Vector3(oDistance, 0, 0);

        //Open();
    }

    // Update is called once per frame
    void Update()
    {
        if (moving == 0)
        	return;

        newX = rightSide.transform.localPosition.x - (speed * moving);
        if (moving == 1 && newX < rClose.x)
        {
        	newX = rClose.x;
        	moving = 0;
        }
        else if (newX > rOpen.x)
        {
        	newX = rOpen.x;
        	moving = 0;
        }
        rightSide.transform.localPosition = new Vector3(newX, rightSide.transform.localPosition.y, rightSide.transform.localPosition.z);
        leftSide.transform.localPosition = new Vector3(-newX, leftSide.transform.localPosition.y, leftSide.transform.localPosition.z);
    }

    public void Open()
    {
    	if (isOpen)
    		return;

    	isOpen = true;
    	moving = -1;
    }

    public void Close()
    {
    	if (!isOpen)
    		return;

    	isOpen = false;
    	moving = 1;
    }

    void OnTriggerEnter(Collider collider)
    {
    	if (collider.transform.tag == "Player")
    		Open();
    }

    void OnTriggerExit(Collider collider)
    {
    	if (collider.transform.tag == "Player")
    		Close();
    }
}
