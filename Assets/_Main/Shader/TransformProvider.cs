using UnityEngine;

[ExecuteInEditMode]
public class TransformProvider : MonoBehaviour
{
    [System.Serializable]
    public class NameTransformPair
    {
        public string name;
        public Transform transform;
    }
    
    [SerializeField] private Renderer targetRenderer = null;

    [SerializeField] private NameTransformPair[] pairs;

    private void Update()
    {
        Validate();
    }

    private void Validate()
    {
        if (!targetRenderer) return;

        var material = targetRenderer.sharedMaterial;
        if (!material) return;
        
        foreach (var pair in pairs)
        {
            var pos = pair.transform.position;
            var rot = pair.transform.rotation;
            var scale = pair.transform.localScale;
            var mat = Matrix4x4.TRS(pos, rot, scale);
            var invMat = Matrix4x4.Inverse(mat);
            material.SetMatrix(pair.name, invMat);
        }
    }
}