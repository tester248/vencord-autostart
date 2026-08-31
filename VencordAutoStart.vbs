' VencordAutoStart.vbs - Launches the Vencord patch script with a fully hidden window
' so nothing appears on screen at logon.
CreateObject("WScript.Shell").Run "powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File ""C:\Users\Ashwin\Documents\Programs\vencordstuff\VencordAutoStart.ps1"" -Quiet", 0, False
