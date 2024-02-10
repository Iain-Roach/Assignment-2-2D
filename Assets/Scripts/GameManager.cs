using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;


public class GameManager : MonoBehaviour
{
    public static GameManager Instance { get; private set; }

    private List<Scene> sceneList = new List<Scene>();
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

    public void Update()
    {
        if (System.Diagnostics.Debugger.IsAttached)
        {
            Application.Quit();
        }
    }
    public void LoadScene(int index)
    {
        if (System.Diagnostics.Debugger.IsAttached)
        {
            Application.Quit();
        }
        currentSceneIndex = index;
        SceneManager.LoadScene(index);
        
    }

    public void PlayAgain()
    {
        currentSceneIndex = 0;
        SceneManager.LoadScene(0);
    }

    public void QuitGame()
    {
        Application.Quit();
    }

}
