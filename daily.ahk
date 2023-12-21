#Requires AutoHotkey v2.0

#include <rdee>


; This script holds all hotkeys & hotstrings in daily windows operation, along with their execution functions

; 2023-12-14    mitigated from ahk.rdee, with <rob-system> and <SG-system> already done
; 2023-12-14    <toolPanel#init>, <tp_fastlink#init>



; *******************************************************************
; Hotkeys & Hotstrings
; *******************************************************************


; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> General hotkeys
>+>!S::
{

    reSave()
}

>+>!G::
{
    reGoto()
}

; ---------- toolPanel
>+>!F2::
{
    toolpanel()
}

; ---------- quick open
; ... open windoes-terminal at current path of active explorer
>+>!1::
{
    path := "D:\"
    if (WinActive("ahk_class CabinetWClass")) {
        ; Try to get the path of the active Explorer window
        for window in ComObject("Shell.Application").Windows() {
            try {
                if (window.HWND = WinActive("A")) {
                    path := window.Document.Folder.Self.Path
                    Break
                }
            }
        }
    }
    Run(Format("wt.exe -d {}", path))
}

; ... (Admin) open windoes-terminal at current path of active explorer
>+>!2::
{
    path := "D:\"
    if (WinActive("ahk_class CabinetWClass")) {
        ; Try to get the path of the active Explorer window
        for window in ComObject("Shell.Application").Windows() {
            try {
                if (window.HWND = WinActive("A")) {
                    path := window.Document.Folder.Self.Path
                    Break
                }
            }
        }
    }
    Run(Format("*RunAs cmd.exe /c wt -d {}", path))
}

; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Explorer hotkeys
; ---------- rob-system
#HotIf WinActive("ahk_class CabinetWClass")
>+>!F1::
{
    rob()
}
#HotIf



; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Obsidian hotkeys
#HotIf WinActive("ahk_exe Obsidian.exe")
::@@_now::
{
    SendInput("<sub style=`"color:gray`">@" . FormatTime(,"yyyy-MM-dd HH:mm:ss") . "</sub>")
}
::@@red::
{
    SendInput('<font color="red"></font>')
    SendInput('{Left 7}')
}
::@@green::
{
    SendInput('<font color="green"></font>')
    SendInput('{Left 7}')
}
::@@yellow::
{
    SendInput('<font color="yellow"></font>')
    SendInput('{Left 7}')
}
::@@blue::
{
    SendInput('<font color="blue"></font>')
    SendInput('{Left 7}')
}
#HotIf






; *******************************************************************
; functions
; *******************************************************************

; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> re Save-Goto system
file_sg := "D:\ahk_sg.json"
sgMap := Map()

reSave(){
    global file_sg, sgMap
    if sgMap.Count = 0 and FileExist(file_sg){
        sgContent := FileRead(file_sg)
        sgMap := jxon_load(&sgContent)
    }

    active_info := GetActiveWindowInfo()
    name := InputBox("Set key for this uri: " . active_info, "reSave").Value
    if name != "" {  ;>- valid name 
        sgMap[name] := active_info
        sgContent := jxon_dump(sgMap, indent:=0)

        fo := FileOpen(file_sg, "w")
        fo.Write(sgContent)
        fo.Close()
    }
}

reGoto(){
    global file_sg, sgMap
    if sgMap.Count = 0{
        if ! FileExist(file_sg){
            MsgBox("Please save first, then goto! Cannot find local file now")
            Return
        }
        sgContent := FileRead(file_sg)
        sgMap := jxon_load(&sgContent)
    }

    strT := "go to target key: "
    for k, v in sgMap
        strT := strT . "`n" . k . " : " . v
    ; MsgBox(strT)
    name := InputBox(strT, "reGoto").Value
    if name = ""
        Return
    if sgMap.Has(name){
        Run(sgMap[name])
    }else{
        MsgBox("Cannot find key: " . name)
    }
}


; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> roadelse sync system
rob(){
    static r_prefix := "D:\recRoot\Roadelse", o_prefix := EnvGet("USERPROFILE") . "\OneDrive\Roadelse", b_prefix := "D:\BaiduSyncdisk\Roadelse"
    if (WinActive("ahk_class CabinetWClass")) {
        ; Try to get the path of the active Explorer window
        for window in ComObject("Shell.Application").Windows() {
            if (window.HWND = WinActive("A"))
                path := window.Document.Folder.Self.Path
        }
        rDirC := " ", oDirC := " ", bDirC := " "
        if startswith(path, r_prefix){
            rpath := path
            opath := StrReplace(path, r_prefix, o_prefix)
            bpath := StrReplace(path, r_prefix, b_prefix)
            rDirC := "*"
        } else if startswith(path, o_prefix) {
            rpath := StrReplace(path, o_prefix, r_prefix)
            opath := path
            bpath := StrReplace(path, o_prefix, b_prefix)
            oDirC := "*"
        } else if startswith(path, b_prefix) {
            rpath := StrReplace(path, b_prefix, r_prefix)
            opath := StrReplace(path, b_prefix, o_prefix)
            bpath := path
            bDirC := "*"
        } else {
            MsgBox("Not in rob/Roadelse system path!")
            return
        }
        rDirE := FileExist(rpath) ? "√" : "x"
        oDirE := FileExist(opath) ? "√" : "x"
        bDirE := FileExist(bpath) ? "√" : "x"

        MyGui := Gui()
        RvO := MyGui.Add("Radio", "vclickO", Format("OneDrive ({}){}  : {}", oDirE, oDirC, opath))
        RvB := MyGui.Add("Radio", "vclickB", Format("BaiduSync({}){}  : {}", bDirE, bDirC, bpath))
        RvR := MyGui.Add("Radio", "vclickR", Format("recRoot  ({}){}  : {}", rDirE, rDirC, rpath))
        MyGui.OnEvent("Close", gui_cancel)

        CB_cst := MyGui.Add("CheckBox", "vCreateShortcut", "Create shortcuts among r.o.b.? (auto mkdir)")

        B_ok := MyGui.Add("Button", "Default Section", "OK")  ;>- Section starts a new section, for column layout, i.e., ys below
        B_ok.OnEvent("Click", gui_ok)
        B_cancel := MyGui.Add("Button", "Default ys", "Cancel")
        B_cancel.OnEvent("Click", gui_cancel)

        MyGui.Show()
        return

        gui_cancel(*){
            MyGui.Destroy()
        }

        gui_ok(*){
            MyGui.Submit()
            ; ----- open/activate target path (Run feature: if opened, just activate rather than open a new window)
            if RvO.Value = 1
                mkdir_and_run(opath)
            else if RvB.Value = 1
                mkdir_and_run(bpath)
            else if RvR.Value = 1
                mkdir_and_run(rpath)

            if CB_cst.Value = 1
            {
                DirCreate(rpath)
                DirCreate(opath)
                DirCreate(bpath)

                FileCreateShortcut(opath, rpath . "\→OneDrive.lnk", , , , "C:\Users\roadelse\OneDrive\Pictures\OneDrive-icon.ico")
                FileCreateShortcut(opath, bpath . "\→OneDrive.lnk", , , , "C:\Users\roadelse\OneDrive\Pictures\OneDrive-icon.ico")
                FileCreateShortcut(bpath, rpath . "\→BaiduSync.lnk", , , , "C:\Users\roadelse\OneDrive\Pictures\baiduYun-icon.ico")
                FileCreateShortcut(bpath, opath . "\→BaiduSync.lnk", , , , "C:\Users\roadelse\OneDrive\Pictures\baiduYun-icon.ico")
                FileCreateShortcut(rpath, bpath . "\→StaticRecall.lnk", , , , "C:\Users\roadelse\OneDrive\Pictures\StaticRecall.RGB-FFAA6E.ico")
                FileCreateShortcut(rpath, opath . "\→StaticRecall.lnk", , , , "C:\Users\roadelse\OneDrive\Pictures\StaticRecall.RGB-FFAA6E.ico")
            }

            MyGui.Destroy()
        }
    }
    MsgBox("Not in rob/Roadelse system path!")
    return
}


; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> tools panel
toolpanel(){
    ;;; This function opens a dialog serving as a top-level tool panel, making it quick to open wanted small tools further

    ; ------------- create GUI
    mygui := Gui()
    ; ..... config events
    mygui.OnEvent("Close", guiClose)

    ; ------------------ add tools
    btn_fastlink := MyGui.Add("Button", "Default", "fast link")
    btn_fastlink.OnEvent("Click", tp_fastlink)

    ; ------------- show
    mygui.Show()

    return

    ; ------------- internal event functions
    guiClose(*){
        mygui.Destroy()
    }

}


tp_fastlink(*){
    ;;; This function provides a gui wrapper for mklink in cmd, avoiding open a cmd as admin. manually

    ; ------------- gui definitions
    gui_fl := Gui(, "Fast link")
    gui_fl.OnEvent("Close", fastlink_cancel)
    gui_fl.OnEvent("Escape", fastlink_cancel)

    ; ..... from text & edit
    gui_fl.Add("Text",, "From:")
    edit_from := gui_fl.Add("Edit")
    ; ..... to text & edit
    gui_fl.Add("Text",, "To:")
    ; gui_fl.Add("Text",, "WorkingDir: " A_WorkingDir) ; !! to-be-dev, add support for relative path based on active directory
    edit_to := gui_fl.Add("Edit")

    ; ..... ok & cancel buttons
    btn_ok := gui_fl.Add("Button", "Default Section", "OK")
    btn_ok.OnEvent("Click", fastlink_ok)
    btn_cancel := gui_fl.Add("Button", "Default ys", "Cancel")
    btn_cancel.OnEvent("Click", fastlink_cancel)

    ; ------------- show
    gui_fl.Show()
    return

    ; ------------- internal event functions
    fastlink_ok(*){
        gui_fl.Submit(false)
        ; ..... pre-check
        fe_to := FileExist(edit_to.Text)
        fe_from := FileExist(edit_from.Text)

        if fe_from = ""{
            MsgBox("Target doesn't exist!")
            return
        } else if InStr(fe_from, "D")  ; cannot use "= D" since it may be "AD" such as within OneDrive
            option := "/D"
        else
            option := ""

        if fe_to != ""{
            if InStr(fe_to, "D"){
                path_to := edit_to.Text . "\" . GetBaseName(edit_from.Text)
            } else {
                MsgBox("Link already exists!")
                return
            }
        } else {
                path_to := edit_to.Text
        }

        ; ..... execution
        ; MsgBox(Format("{}  *RunAs cmd.exe /c mklink {} `"{}`" `"{}`"", fe_from, option, path_to, edit_from.Text))
        ret_code := RunWait(Format("*RunAs cmd.exe /c mklink {} `"{}`" `"{}`"", option, path_to, edit_from.Text),,"Hide")
        if ret_code != 0 {
            MsgBox("Error! Fails to create symlink")
            return
        }
        gui_fl.Destroy()
    }
    
    fastlink_cancel(*){
        gui_fl.Destroy()
    }
}

