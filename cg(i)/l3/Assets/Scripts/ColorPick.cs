using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ColorPick : MonoBehaviour
{
	public Light bulb;

    private int action;

    // Start is called before the first frame update
    void Start()
    {
        action = 1;

        bulb.color = new Color(
        	Random.Range(0.0f, 10.0f),
        	Random.Range(0.0f, 5f),
        	Random.Range(0.0f, 5f),
        	1f
        );
    }

    // Update is called once per frame
    void Update()
    {
        float curR = bulb.color.r;

        curR += Random.Range(0.0f, 0.01f) * action;

        if (curR < 0.0f)
        {
            curR = 0.0f;
            action = 1;
        }
        else if (curR > 10.0f)
        {
            curR = 10.0f;
            action = -1;
        }


        bulb.color = new Color(
            curR,
            bulb.color.g,
            bulb.color.b,
            bulb.color.a
        );
    }
}
