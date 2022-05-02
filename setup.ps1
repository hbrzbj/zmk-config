# Copyright (c) 2020 The ZMK Contributors
# SPDX-License-Identifier: MIT

$ErrorActionPreference = "Stop"

function Get-Choice-From-Options {
    param(
        [String[]] $Options,
        [String] $Prompt
    )

    while ($true) {
        for ($i = 0; $i -lt $Options.length; $i++) {
            Write-Host "$($i + 1)) $($Options[$i])"
        }

        Write-Host "$($Options.length + 1)) Quit"
        $selection = (Read-Host $Prompt) -as [int]

        if ($selection -eq $Options.length + 1) {
            Write-Host "Goodbye!"
            exit 1
        }
        elseif ($selection -le $Options.length -and $selection -gt 0) {
            $choice = $($selection - 1)
            break
        }
        else {
            Write-Host "Invalid Option. Try another one."
        }
    }

    return $choice
}

function Test-Git-Config {
    param(
        [String] $Option,
        [String] $ErrMsg
    )

    git config $Option | Out-Null

    if ($lastExitCode -ne 0) {
        Write-Host $ErrMsg
        exit 1
    }
}

try {
    git | Out-Null
}
catch [System.Management.Automation.CommandNotFoundException] {
    Write-Host "Git is not installed, and is required for this script!"
    exit 1
}

Test-Git-Config -Option "user.name" -ErrMsg "Git username not set!`nRun: git config --global user.name 'My Name'"
Test-Git-Config -Option "user.email" -ErrMsg "Git email not set!`nRun: git config --global user.email 'example@myemail.com'"

function Test-CommandExists {
    param ($command)

    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = "stop"

    try {
        if(Get-Command $command){ return $true }
    } Catch { return $false }
    Finally { $ErrorActionPreference=$oldPreference }
}

if (Test-CommandExists Get-Acl) {
    $permission = (Get-Acl $pwd).Access |
    ?{$_.IdentityReference -match $env:UserName `
        -and $_.FileSystemRights -match "FullControl" `
        -or $_.FileSystemRights -match "Write" } | 
             Select IdentityReference,FileSystemRights

    If (-Not $permission){
        Write-Host "Sorry, you do not have write permissions in this directory."
        Write-Host "Please try running this script again from a directory that you do have write permissions for."
        exit 1
    }
}

$repo_path = "https://github.com/zmkfirmware/unified-zmk-config-template.git"

$title = "ZMK Config Setup:"
Write-Host ""
Write-Host "Keyboard Shield Selection:"
$prompt = "Pick a keyboard"

$keyboards = [ordered]@{
    "two_percent_milk" = @{
        name = "2% Milk";
        type = "shield";
        basedir = "two_percent_milk";
        split = "false";
        arch = "";
        siblings = ( "two_percent_milk" );
    }
    "a_dux" = @{
        name = "A. Dux";
        type = "shield";
        basedir = "a_dux";
        split = "true";
        arch = "";
        siblings = @(
            "a_dux_left"
            "a_dux_right"
            );
    }
    "bat43" = @{
        name = "BAT43";
        type = "shield";
        basedir = "bat43";
        split = "false";
        arch = "";
        siblings = ( "bat43" );
    }
    "bdn9_rev2" = @{
        name = "BDN9 Rev2";
        type = "board";
        basedir = "bdn9";
        split = "";
        arch = "arm";
        siblings = ( "bdn9_rev2" );
    }
    "bfo9000" = @{
        name = "BFO-9000";
        type = "shield";
        basedir = "bfo9000";
        split = "true";
        arch = "";
        siblings = @(
            "bfo9000_left"
            "bfo9000_right"
            );
    }
    "boardsource3x4" = @{
        name = "Boardsource 3x4 Macropad";
        type = "shield";
        basedir = "boardsource3x4";
        split = "false";
        arch = "";
        siblings = ( "boardsource3x4" );
    }
    "boardsource5x12" = @{
        name = "Boardsource 5x12";
        type = "shield";
        basedir = "boardsource5x12";
        split = "false";
        arch = "";
        siblings = ( "boardsource5x12" );
    }
    "bt60_v1_hs" = @{
        name = "BT60 V1 Hotswap";
        type = "board";
        basedir = "bt60";
        split = "";
        arch = "arm";
        siblings = ( "bt60_v1_hs" );
    }
    "bt60_v1" = @{
        name = "BT60 V1 Soldered";
        type = "board";
        basedir = "bt60";
        split = "";
        arch = "arm";
        siblings = ( "bt60_v1" );
    }
    "chalice" = @{
        name = "Chalice";
        type = "shield";
        basedir = "chalice";
        split = "false";
        arch = "";
        siblings = ( "chalice" );
    }
    "clog" = @{
        name = "Clog";
        type = "shield";
        basedir = "clog";
        split = "true";
        arch = "";
        siblings = @(
            "clog_left"
            "clog_right"
            );
    }
    "contra" = @{
        name = "Contra";
        type = "shield";
        basedir = "contra";
        split = "false";
        arch = "";
        siblings = ( "contra" );
    }
    "corne" = @{
        name = "Corne";
        type = "shield";
        basedir = "corne";
        split = "true";
        arch = "";
        siblings = @(
            "corne_left"
            "corne_right"
            );
    }
    "cradio" = @{
        name = "Cradio/Sweep";
        type = "shield";
        basedir = "cradio";
        split = "true";
        arch = "";
        siblings = @(
            "cradio_left"
            "cradio_right"
            );
    }
    "crbn" = @{
        name = "CRBN Featherlight";
        type = "shield";
        basedir = "crbn";
        split = "false";
        arch = "";
        siblings = ( "crbn" );
    }
    "eek" = @{
        name = "eek!";
        type = "shield";
        basedir = "eek";
        split = "false";
        arch = "";
        siblings = ( "eek" );
    }
    "elephant42" = @{
        name = "Elephant42";
        type = "shield";
        basedir = "elephant42";
        split = "true";
        arch = "";
        siblings = @(
            "elephant42_left"
            "elephant42_right"
            );
    }
    "ergodash" = @{
        name = "Ergodash";
        type = "shield";
        basedir = "ergodash";
        split = "true";
        arch = "";
        siblings = @(
            "ergodash_left"
            "ergodash_right"
            );
    }
    "ferris_rev02" = @{
        name = "Ferris 0.2";
        type = "board";
        basedir = "ferris";
        split = "";
        arch = "arm";
        siblings = ( "ferris_rev02" );
    }
    "fourier" = @{
        name = "Fourier Rev. 1";
        type = "shield";
        basedir = "fourier";
        split = "true";
        arch = "";
        siblings = @(
            "fourier_left"
            "fourier_right"
            );
    }
    "helix" = @{
        name = "Helix";
        type = "shield";
        basedir = "helix";
        split = "true";
        arch = "";
        siblings = @(
            "helix_left"
            "helix_right"
            );
    }
    "hummingbird" = @{
        name = "Hummingbird";
        type = "shield";
        basedir = "hummingbird";
        split = "false";
        arch = "";
        siblings = ( "hummingbird" );
    }
    "iris" = @{
        name = "Iris";
        type = "shield";
        basedir = "iris";
        split = "true";
        arch = "";
        siblings = @(
            "iris_left"
            "iris_right"
            );
    }
    "jian" = @{
        name = "Jian";
        type = "shield";
        basedir = "jian";
        split = "true";
        arch = "";
        siblings = @(
            "jian_left"
            "jian_right"
            );
    }
    "jiran" = @{
        name = "Jiran";
        type = "shield";
        basedir = "jiran";
        split = "true";
        arch = "";
        siblings = @(
            "jiran_left"
            "jiran_right"
            );
    }
    "jorne" = @{
        name = "Jorne";
        type = "shield";
        basedir = "jorne";
        split = "true";
        arch = "";
        siblings = @(
            "jorne_left"
            "jorne_right"
            );
    }
    "knob_goblin" = @{
        name = "Knob Goblin";
        type = "shield";
        basedir = "knob_goblin";
        split = "false";
        arch = "";
        siblings = ( "knob_goblin" );
    }
    "kyria" = @{
        name = "Kyria";
        type = "shield";
        basedir = "kyria";
        split = "true";
        arch = "";
        siblings = @(
            "kyria_left"
            "kyria_right"
            );
    }
    "kyria_rev2" = @{
        name = "Kyria Rev2";
        type = "shield";
        basedir = "kyria";
        split = "true";
        arch = "";
        siblings = @(
            "kyria_rev2_left"
            "kyria_rev2_right"
            );
    }
    "leeloo" = @{
        name = "Leeloo";
        type = "shield";
        basedir = "leeloo";
        split = "true";
        arch = "";
        siblings = @(
            "leeloo_left"
            "leeloo_right"
            );
    }
    "lily58" = @{
        name = "Lily58";
        type = "shield";
        basedir = "lily58";
        split = "true";
        arch = "";
        siblings = @(
            "lily58_left"
            "lily58_right"
            );
    }
    "lotus58" = @{
        name = "Lotus58";
        type = "shield";
        basedir = "lotus58";
        split = "true";
        arch = "";
        siblings = @(
            "lotus58_left"
            "lotus58_right"
            );
    }
    "m60" = @{
        name = "MakerDiary m60";
        type = "shield";
        basedir = "m60";
        split = "false";
        arch = "";
        siblings = ( "m60" );
    }
    "microdox" = @{
        name = "Microdox";
        type = "shield";
        basedir = "microdox";
        split = "true";
        arch = "";
        siblings = @(
            "microdox_left"
            "microdox_right"
            );
    }
    "murphpad" = @{
        name = "MurphPad";
        type = "shield";
        basedir = "murphpad";
        split = "false";
        arch = "";
        siblings = ( "murphpad" );
    }
    "naked60" = @{
        name = "Naked60";
        type = "shield";
        basedir = "naked60";
        split = "false";
        arch = "";
        siblings = ( "naked60" );
    }
    "nibble" = @{
        name = "Nibble";
        type = "shield";
        basedir = "nibble";
        split = "false";
        arch = "";
        siblings = ( "nibble" );
    }
    "nice60" = @{
        name = "nice!60";
        type = "board";
        basedir = "nice60";
        split = "";
        arch = "arm";
        siblings = ( "nice60" );
    }
    "osprette" = @{
        name = "Osprette";
        type = "shield";
        basedir = "osprette";
        split = "false";
        arch = "";
        siblings = ( "osprette" );
    }
    "planck_rev6" = @{
        name = "Planck Rev6";
        type = "board";
        basedir = "planck";
        split = "";
        arch = "arm";
        siblings = ( "planck_rev6" );
    }
    "qaz" = @{
        name = "QAZ";
        type = "shield";
        basedir = "qaz";
        split = "false";
        arch = "";
        siblings = ( "qaz" );
    }
    "quefrency" = @{
        name = "Quefrency Rev. 1";
        type = "shield";
        basedir = "quefrency";
        split = "true";
        arch = "";
        siblings = @(
            "quefrency_left"
            "quefrency_right"
            );
    }
    "redox" = @{
        name = "Redox";
        type = "shield";
        basedir = "redox";
        split = "true";
        arch = "";
        siblings = @(
            "redox_left"
            "redox_right"
            );
    }
    "reviung41" = @{
        name = "REVIUNG41";
        type = "shield";
        basedir = "reviung41";
        split = "false";
        arch = "";
        siblings = ( "reviung41" );
    }
    "romac" = @{
        name = "Romac Macropad";
        type = "shield";
        basedir = "romac";
        split = "false";
        arch = "";
        siblings = ( "romac" );
    }
    "romac_plus" = @{
        name = "Romac+ Macropad";
        type = "shield";
        basedir = "romac_plus";
        split = "false";
        arch = "";
        siblings = ( "romac_plus" );
    }
    "s40nc" = @{
        name = "S40NC";
        type = "board";
        basedir = "s40nc";
        split = "";
        arch = "arm";
        siblings = ( "s40nc" );
    }
    "sofle" = @{
        name = "Sofle";
        type = "shield";
        basedir = "sofle";
        split = "true";
        arch = "";
        siblings = @(
            "sofle_left"
            "sofle_right"
            );
    }
    "splitreus62" = @{
        name = "Splitreus62";
        type = "shield";
        basedir = "splitreus62";
        split = "true";
        arch = "";
        siblings = @(
            "splitreus62_left"
            "splitreus62_right"
            );
    }
    "tg4x" = @{
        name = "TG4x";
        type = "shield";
        basedir = "tg4x";
        split = "false";
        arch = "";
        siblings = ( "tg4x" );
    }
    "tidbit" = @{
        name = "Tidbit Numpad";
        type = "shield";
        basedir = "tidbit";
        split = "false";
        arch = "";
        siblings = ( "tidbit" );
    }
    "zodiark" = @{
        name = "Zodiark";
        type = "shield";
        basedir = "zodiark";
        split = "true";
        arch = "";
        siblings = @(
            "zodiark_left"
            "zodiark_right"
            );
    }
}
# TODO: Add support for "Other" and linking to docs on adding custom shields in user config repos.

$choice = Get-Choice-From-Options -Options ($keyboards.values | % { $_['name'] }) -Prompt $prompt
$keyboard = $($($keyboards.keys)[$choice])
$keyboard_title = $keyboards[$keyboard].name
$basedir = $keyboards[$keyboard].basedir
$keyboard_split = $keyboards[$keyboard].split
$keyboard_arch = $keyboards[$keyboard].arch
$keyboard_siblings = $keyboards[$keyboard].siblings
$keyboard_type = $keyboards[$keyboard].type

if ($keyboard_type -eq "shield") {
    $prompt = "Pick an MCU board"
    $boards = [ordered]@{
        bluemicro840_v1 = "BlueMicro840 v1";
        mikoto_520 = "Mikoto 5.20";
        nice_nano = "nice!nano v1";
        nice_nano_v2 = "nice!nano v2";
        nrf52840_m2 = "nRF52840 M.2 Module";
        nrfmicro_11_flipped = "nRFMicro 1.1 (flipped)";
        nrfmicro_11 = "nRFMicro 1.1/1.2";
        nrfmicro_13 = "nRFMicro 1.3/1.4";
        proton_c = "QMK Proton-C";
        seeeduino_xiao = "Seeeduino XIAO";
        seeeduino_xiao_ble = "Seeeduino XIAO BLE";
    }

    Write-Host "$title"
    Write-Host ""
    Write-Host "MCU Board Selection:"

    $choice = Get-Choice-From-Options -Options $boards.values -Prompt $prompt
    $shields = $keyboard_siblings
    $board = $($($boards.keys)[$choice])
    $boards = ( $board )
} else {
    $boards = ( $keyboard_siblings )
    $shields = @( )
}

$copy_keymap = Read-Host "Copy in the stock keymap for customisation? [Yn]"

if ($copy_keymap -eq "" -or $copy_keymap -eq "Y" -or $copy_keymap -eq "y") {
    $copy_keymap = "yes"
}

$github_user = Read-Host "GitHub Username (leave empty to skip GitHub repo creation)"

if ($github_user -ne "") {
    $repo_name = Read-Host "GitHub Repo Name [zmk-config]"

    if ($repo_name -eq "") {
        $repo_name = "zmk-config"
    }

    $github_repo = Read-Host "GitHub Repo [https://github.com/$github_user/$repo_name.git]"

    if ($github_repo -eq "") {
        $github_repo = "https://github.com/$github_user/$repo_name.git"
    }
}
else {
    $repo_name = "zmk-config"
    $github_repo = ""
}

Write-Host ""
Write-Host "Preparing a user config for:"
if ($keyboard_type -eq "shield") {
    Write-Host "* MCU Board: ${boards}"
    Write-Host "* Shield(s): ${shields}"
} else {
    Write-Host "* Board(s): ${boards}"
}

if ($copy_keymap -eq "yes") {
    Write-Host "* Copy Keymap?: Yes"
}
else {
    Write-Host "* Copy Keymap?: No"
}

if ($github_repo -ne "") {
    Write-Host "* GitHub Repo to Push (please create this in GH first!): $github_repo"
}

Write-Host ""
$do_it = Read-Host "Continue? [Yn]"

if ($do_it -ne "" -and $do_it -ne "Y" -and $do_it -ne "y") {
    Write-Host "Aborting..."
    exit 1
}

git clone --single-branch "$repo_path" "$repo_name"
Set-Location "$repo_name"

Push-Location config

$config_file = "${keyboard}.conf"
$keymap_file = "${keyboard}.keymap"

if ($keyboard_type -eq "shield") {
    $config_url = "https://raw.githubusercontent.com/zmkfirmware/zmk/main/app/boards/shields/${basedir}/${keyboard}.conf"
    $keymap_url = "https://raw.githubusercontent.com/zmkfirmware/zmk/main/app/boards/shields/${basedir}/${keyboard}.keymap"
} else {
    $config_url = "https://raw.githubusercontent.com/zmkfirmware/zmk/main/app/boards/${keyboard_arch}/${basedir}/${keyboard}.conf"
    $keymap_url = "https://raw.githubusercontent.com/zmkfirmware/zmk/main/app/boards/${keyboard_arch}/${basedir}/${keyboard}.keymap"
}

Write-Host "Downloading config file (${config_url})"
Try {
    Invoke-RestMethod -Uri "${config_url}" -OutFile "${config_file}"
} Catch {
    Set-Content -Path $config_file "# Place configuration items here"
}

if ($copy_keymap -eq "yes") {
    Write-Host "Downloading keymap file (${keymap_url})"
    Invoke-RestMethod -Uri "${keymap_url}" -OutFile "${keymap_file}"
}

Pop-Location

Add-Content -Path "build.yaml" -Value "include:"
foreach ($b in ${boards}) {
    if ($keyboard_type -eq "shield") {
        foreach ($s in ${shields}) {
            Add-Content -Path "build.yaml" -Value "  - board: $b"
            Add-Content -Path "build.yaml" -Value "    shield: $s"
        }
    } else {
        Add-Content -Path "build.yaml" -Value "  - board: $b"
    }
}

Remove-Item -Recurse -Force .git
git init .
git add .
git commit -m "Initial User Config."

if ($github_repo -ne "") {
    git remote add origin "$github_repo"

    git push --set-upstream origin $(git symbolic-ref --short HEAD)

    # If push failed, assume that the origin was incorrect and give instructions on fixing.
    if ($lastExitCode -ne 0) {
        Write-Host "Remote repository $github_repo not found..."
        Write-Host "Check GitHub URL, and try adding again."
        Write-Host "Run the following: "
        Write-Host "    git remote rm origin"
        Write-Host "    git remote add origin FIXED_URL"
        Write-Host "    git push --set-upstream origin $(git symbolic-ref --short HEAD)"
        Write-Host "Once pushed, your firmware should be availalbe from GitHub Actions at: $actions"
        exit 1
    }

    if ($github_repo -imatch "https") {
        $actions = "$($github_repo.substring(0, $github_repo.length - 4))/actions"
        Write-Host "Your firmware should be availalbe from GitHub Actions shortly: $actions"
    }
}
