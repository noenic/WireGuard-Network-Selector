'Code from jfrmilner https://stackoverflow.com/questions/64177099/how-to-run-powershell-script-without-terminal-window
'to run powershell script without terminal window while still be triggered by windows task scheduler in battery saver mode
Set objShell = CreateObject("Wscript.Shell")
Set args = Wscript.Arguments
For Each arg In args
    objShell.Run("powershell -windowstyle hidden -executionpolicy bypass -noninteractive ""&"" ""'" & arg & "'"""),0
Next
