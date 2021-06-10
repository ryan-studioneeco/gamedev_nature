using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FishCollider : MonoBehaviour
{
    public Transform restartPoint;
    public Collider restartCollider;
    public GameObject fish;
    private  void OnTriggerEnter(Collider other) {
        // Debug.Log("A Collision");
        // Debug.Log(other.gameObject);
        if (other.gameObject == this.restartCollider.gameObject) {
            // Debug.Log("Restart Collision!");
            this.fish.transform.position = this.restartPoint.position;
        }
    }
}
