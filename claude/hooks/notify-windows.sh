#!/bin/bash
# Windows balloon notification from WSL
# Receives notification from Claude Code hook (via stdin as JSON)

INPUT=$(cat)
MESSAGE=$(echo "$INPUT" | python3 -c "import sys,json; data=json.load(sys.stdin); print(data.get('message','Claude CLI 작업 완료'))" 2>/dev/null)

if [ -z "$MESSAGE" ]; then
  MESSAGE="Claude CLI 작업 완료"
fi

# Escape single quotes for PowerShell
MESSAGE=$(echo "$MESSAGE" | sed "s/'/''/g")

powershell.exe -Command "
Add-Type -AssemblyName System.Windows.Forms
\$balloon = New-Object System.Windows.Forms.NotifyIcon
\$balloon.Icon = [System.Drawing.SystemIcons]::Information
\$balloon.BalloonTipIcon = 'Info'
\$balloon.BalloonTipTitle = 'Claude CLI'
\$balloon.BalloonTipText = '$MESSAGE'
\$balloon.Visible = \$true
\$balloon.ShowBalloonTip(5000)
Start-Sleep -Seconds 3
\$balloon.Dispose()
" 2>/dev/null &

exit 0
