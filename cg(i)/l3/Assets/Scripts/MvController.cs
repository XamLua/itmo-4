using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MvController : MonoBehaviour
{

    //Public
	public float speed;
    public float jSpeed;
    public Camera cm;
    public CapsuleCollider cc;
    public Rigidbody rb;

    //Private
	Vector3 mvDirection;
    float distToGround;

    bool needJump;

	void Awake()
	{
	}

    // Start is called before the first frame update
    void Start()
    {
        distToGround = cc.bounds.extents.y;
    }

    // Update is called once per frame
    void Update()
    {
        //set default
        float hMov = 0;
        float vMov = 0;

    	//Get mv from user
        if (CanMove(transform.right * Input.GetAxisRaw("Horizontal")))
    	   hMov = Input.GetAxisRaw("Horizontal");

        if (CanMove(transform.forward * Input.GetAxisRaw("Vertical")))
    	   vMov = Input.GetAxisRaw("Vertical");

    	mvDirection = (hMov * transform.right + vMov * transform.forward).normalized;

        if (Input.GetKeyDown(KeyCode.Space))
            needJump = true;
    }

    // FixedUpdate is called very physic step
    void FixedUpdate()
    {
    	Move();

        if (needJump && isOnGround())
        {
            Jump();
            needJump = false;
        }
    }

    void Move()
    {
        Vector3 yVel = new Vector3(0, rb.velocity.y, 0);

        rb.velocity = mvDirection * speed * Time.deltaTime;
        rb.velocity += yVel;
    }

    //Collision detection in a nutshell 
    bool CanMove(Vector3 direction)
    {
        float pointDistance = cc.height / 2 - cc.radius;

        Vector3 topPoint = transform.position + cc.center + Vector3.up * pointDistance;
        Vector3 bottomPoint = transform.position + cc.center + Vector3.down * pointDistance;

        float rad = cc.radius * 0.95f;
        float cDistance = 3f;

        RaycastHit[] hits = Physics.CapsuleCastAll(topPoint, bottomPoint, rad, direction, cDistance);

        foreach (RaycastHit hit in hits)
        {
            if (hit.transform.tag == "Wall")
            {
                return false;
            }
        }
        return true;
    }

    //Jump
    void Jump()
    {
        rb.velocity += new Vector3(0, jSpeed * Time.deltaTime, 0);
    }

    bool isOnGround()
    {
        return Physics.Raycast(transform.position, -Vector3.up, distToGround + 0.1f);
    }
}
