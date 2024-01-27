using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UIManager : MonoBehaviour
{
    public void PlayAgain()
    {
        GameManager.Instance.PlayAgain();
    }

    public void QuitGame()
    {
        GameManager.Instance.QuitGame();
    }

    public void PauseGame()
    {
        Time.timeScale = 0;
    }

    public void UnPauseGame()
    {
        Time.timeScale = 1;
    }
}
