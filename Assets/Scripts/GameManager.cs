using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;


public class GameManager : MonoBehaviour
{
    public static GameManager Instance { get; private set; }

    private List<Scene> sceneList;
    public List<Scene> SceneList { get; }

    public int currentSceneIndex = 0;

    private void Awake()
    {
        if (Instance != null && Instance != this)
        {
            Destroy(this);
        }
        else
        {
            Instance = this;
            DontDestroyOnLoad(this.gameObject);
        }
    }

    public void Start()
    {
        for(int i = 0; i < SceneManager.sceneCount; i++)
        {
            sceneList.Add(SceneManager.GetSceneAt(i));
        }
    }

    public void LoadScene(int index)
    {
        currentSceneIndex = index;
        SceneManager.LoadScene(index);
        
    }


}
