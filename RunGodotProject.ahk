; Global hotkey: F4 (works anywhere)
$F5::
{
    godotTitle := "Godot Engine"
    gameTitle := "Goblin Escape (DEBUG)"

    ; Don't re-run the game if it's focused
    if WinExist(gameTitle){
        if WinActive(gameTitle){
            Send "{F5}"
            return
        }
    }

    ; If Godot is not running, do nothing (or you can launch it)
    if !WinExist(godotTitle)
        return

    ; Activate Godot window
    WinActivate(godotTitle)
    WinWaitActive(godotTitle, , 1)


    ; Send F5 (Run Project)
    Send "{F5}"
}
$F8::{
    gameTitle := "Goblin Escape (DEBUG)"

    if WinExist(gameTitle)
        WinClose
    else
        send "{F8}"
}
F13::
{
    if WinExist("ahk_exe FMOD Studio.exe")
    {
        WinActivate
        return
    }

    Run "C:\Program Files\FMOD SoundSystem\FMOD Studio 2.03.11\FMOD Studio.exe"
}
