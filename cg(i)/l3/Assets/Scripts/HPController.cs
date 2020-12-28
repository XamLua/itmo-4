using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class HPController : MonoBehaviour
{
	public Slider HPbar;

	private float hp;

    // Start is called before the first frame update
    void Start()
    {
        hp = 100f;
    }

    // Update is called once per frame
    void Update()
    {
    	hp -= 0.002f;
        HPbar.value = hp;
    }

    public void changeHP(int diff)
    {
    	hp += diff;
    }
}
