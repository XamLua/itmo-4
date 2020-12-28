using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Controller : MonoBehaviour
{

	public float speed;

	Rigidbody rb;
	Vector3 mvDirection;

	void Awake()
	{
		rb = GetComponent<Rigidbody>();
	}

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
    	//Get mv from user
    	float hMov = Input.GetAxisRaw("Horizontal");
    	float vMov = Input.GetAxisRaw("Vertical");

    	mvDirection = (hMov * transform.right + vMov * transform.forward).normalized;
        
    }

    // FixedUpdate is called very physic step
    void FixedUpdate()
    {
    	Move();
    }

    void Move()
    {
    	rb.velocity = mvDirection * speed * Time.deltaTime;
    }
}
