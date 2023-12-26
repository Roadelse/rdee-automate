#Requires AutoHotkey v2.0

#include <rdee>


F2::
{
    MsgBox("H=" . A_ScreenHeight . ", W=" . A_ScreenWidth)
    MsgBox("vW=" . SysGet(78) . ", vH=" . SysGet(79))
    MonitorGet(1, &L, &T, &R, &B)
    MsgBox("for monitor 1, L=" . L . ", R=" . R . ", T=" . T . ", B=" . B)
    MonitorGet(2, &L2, &T2, &R2, &B2)
    MsgBox("for monitor 2, L=" . L2 . ", R=" . R2 . ", T=" . T2 . ", B=" . B2)

}

F1::
{
    paths := []
    feids := []
    for window in ComObject("Shell.Application").Windows() {
        path := window.Document.Folder.Self.Path
        ; MsgBox(window.HWND)
        paths.Push(path)
        feids.Push(window.HWND)
    }
    ; WinMove(0, 0, A_ScreenWidth/2, A_ScreenHeight/2, feids[1])
    ; WinActivate(feids[1])

    ; ... ...
    gui_fm := Gui()
    cbs := []
    Loop feids.Length {
        cbs.Push(gui_fm.Add("CheckBox", "", paths[A_Index]))
    }

    btn_ok := gui_fm.Add("Button", "Default Section", "OK")
    btn_ok.OnEvent("Click", fastmove_ok)
    btn_cancel := gui_fm.Add("Button", "Default ys", "Cancel")
    btn_cancel.OnEvent("Click", fastmove_cancel)

    gui_fm.Show()
    return

    fastmove_ok(*){
        gui_fm.Submit(false)

        ; xC := 0
        ; yC := 0
        ; xW := 0
        ; yW := 0
        ; wW := 0
        ; hW := 0
        WinMaximize(feids[1])
        WinGetPos(&xW, &yW, &wW, &hW, feids[1])
        WinGetClientPos(&xC, &yC, &wC, &hC, feids[1])
        ; MsgBox("x=" . xW . ", y=" . yW . ", wW=" . wW . ", hW=" . hW)
        ; MsgBox("x=" . xC . ", y=" . yC . ", CC=" . wC . ", hC=" . hC)
        WinRestore(feids[1])
        xoffset := -xW
        yoffset := -yW

        target_ids := []
        for cb in cbs{
            if cb.Value = 1
                target_ids.Push(A_Index)
        }
        if target_ids.Length = 2{
            WinMove(-xoffset, -yoffset, wC/2+2*xoffset, hC+yoffset, feids[target_ids[1]])
            WinMove(wC/2-xoffset, -yoffset, wC/2+2*xoffset, hC+yoffset, feids[target_ids[2]])
            ; WinMove(xW, yW, wW/2, hW, feids[target_ids[1]])
            ; WinMove(wW/2, yW, wW/2, hW, feids[target_ids[2]])
            ; MsgBox("" . A_ScreenWidth/2 . target_ids[2])



            WinActivate(feids[target_ids[1]])
            WinActivate(feids[target_ids[2]])
            ; WinGetClientPos(&xC, &yC,,, feids[target_ids[1]])
            MsgBox("x=" . -xoffset . ", y=" . -yoffset . ", w=" . wC/2+2*xoffset . ", h=" . hC+yoffset)
        
        }
        gui_fm.Destroy()
    }

    fastmove_cancel(*){
        gui_fm.Destroy()
    }
}