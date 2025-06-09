Add-Type -AssemblyName System.Windows.Forms

function Set-CPUTweaks {
    # Enable Minimum/Maximum Processor State 100%
    $subKeys = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00"

    foreach ($key in $subKeys) {
        New-ItemProperty -Path $key.PSPath -Name "Attributes" -Value 2 -PropertyType DWORD -Force | Out-Null
    }

    # Set processor min/max to 100% in all active schemes
    $schemes = powercfg -list | Select-String -Pattern "Power Scheme GUID" | ForEach-Object {
        ($_ -split ":")[1].Trim().Split()[0]
    }

    foreach ($guid in $schemes) {
        powercfg -setacvalueindex $guid sub_processor PROCTHROTTLEMIN 100
        powercfg -setacvalueindex $guid sub_processor PROCTHROTTLEMAX 100
    }

    powercfg -setactive SCHEME_MIN
}

# Create Form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Power Plan Optimizer + CPU Tweaks"
$form.Size = New-Object System.Drawing.Size(420,360)
$form.StartPosition = "CenterScreen"

# Label
$label = New-Object System.Windows.Forms.Label
$label.Text = "Select a Power Plan:"
$label.Location = New-Object System.Drawing.Point(20,20)
$label.AutoSize = $true
$form.Controls.Add($label)

# Power Plan Buttons
$btnHigh = New-Object System.Windows.Forms.Button
$btnHigh.Text = "High Performance"
$btnHigh.Location = New-Object System.Drawing.Point(20,60)
$btnHigh.Add_Click({
    Start-Process "powercfg" "-setactive SCHEME_MIN" -WindowStyle Hidden
    [System.Windows.Forms.MessageBox]::Show("Switched to High Performance.")
})
$form.Controls.Add($btnHigh)

$btnBalanced = New-Object System.Windows.Forms.Button
$btnBalanced.Text = "Balanced"
$btnBalanced.Location = New-Object System.Drawing.Point(20,100)
$btnBalanced.Add_Click({
    Start-Process "powercfg" "-setactive SCHEME_BALANCED" -WindowStyle Hidden
    [System.Windows.Forms.MessageBox]::Show("Switched to Balanced.")
})
$form.Controls.Add($btnBalanced)

$btnSaver = New-Object System.Windows.Forms.Button
$btnSaver.Text = "Power Saver"
$btnSaver.Location = New-Object System.Drawing.Point(20,140)
$btnSaver.Add_Click({
    Start-Process "powercfg" "-setactive SCHEME_MAX" -WindowStyle Hidden
    [System.Windows.Forms.MessageBox]::Show("Switched to Power Saver.")
})
$form.Controls.Add($btnSaver)

# Sleep/Hibernate Checkbox
$chkSleep = New-Object System.Windows.Forms.CheckBox
$chkSleep.Text = "Disable Sleep & Hibernation"
$chkSleep.Location = New-Object System.Drawing.Point(20,180)
$form.Controls.Add($chkSleep)

# CPU Tweaks Checkbox
$chkCPU = New-Object System.Windows.Forms.CheckBox
$chkCPU.Text = "Apply CPU Performance Tweaks (100% min/max, no throttling)"
$chkCPU.Size = New-Object System.Drawing.Size(380,40)
$chkCPU.Location = New-Object System.Drawing.Point(20,210)
$form.Controls.Add($chkCPU)

# Apply Button
$btnApply = New-Object System.Windows.Forms.Button
$btnApply.Text = "Apply Settings"
$btnApply.Location = New-Object System.Drawing.Point(20,260)
$btnApply.Add_Click({
    if ($chkSleep.Checked) {
        powercfg -change -standby-timeout-ac 0
        powercfg -change -hibernate-timeout-ac 0
        powercfg -hibernate off
        [System.Windows.Forms.MessageBox]::Show("Sleep and Hibernation disabled.")
    }

    if ($chkCPU.Checked) {
        Set-CPUTweaks
        [System.Windows.Forms.MessageBox]::Show("CPU performance tweaks applied (100% min/max).")
    }
})
$form.Controls.Add($btnApply)

# Run Form
[void]$form.ShowDialog()
