# Load required framework classes


Add-Type -assembly System.Windows.Forms

# Help to load the img background (relativ path)
if(-not (Get-Variable -Name 'PSScriptRoot' -Scope 'Script')) {$Script:PSScriptRoot = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent}

#Create the screen form (window) to contain elements:
$main_form = New-Object System.Windows.Forms.Form

# Set the title, style and size of the window:
$main_form.Text = 'My Music Finder'
$main_form.Width = 650
$main_form.Height = 600
$main_form.ForeColor = "purple"
$main_form.Font = [System.Drawing.Font]::new("Microsoft Sans Serif", 12, [System.Drawing.FontStyle]::Bold)

#Create a background image with (relative path)
$Image = [system.drawing.image]::FromFile("$PSScriptRoot\script_img.jpg") 
$main_form.BackgroundImage = $Image
$main_form.BackgroundImageLayout = "Center"

#Create a label element on the form:
$Label = New-Object System.Windows.Forms.Label
$Label.Text = "Select a Game folder to find the useless sounds"
$Label.Location  = New-Object System.Drawing.Point(145,60)
$Label.AutoSize = $true
$main_form.Controls.Add($Label)

# Button to select the folder
$Button = New-Object System.Windows.Forms.Button
$Button.Location = New-Object System.Drawing.Size(220,190)
$Button.Size = New-Object System.Drawing.Size(200,40)
$Button.Text = "Select Game"
$main_form.Controls.Add($Button)
$Button.Add_Click(
{
    $browser = New-Object System.Windows.Forms.FolderBrowserDialog
    $null = $browser.ShowDialog()
    $global:path = $browser.SelectedPath
})

# Button to find the music file not present in folder
$Button3 = New-Object System.Windows.Forms.Button
$Button3.Location = New-Object System.Drawing.Size(205,370)
$Button3.Size = New-Object System.Drawing.Size(230,50)
$button3.ForeColor = 'LightBlue'
$button3.BackColor = 'Black'
 $Button3.Text = "Find Useless Sound"
$main_form.Controls.Add($Button3)

# Script is running once this button is clicked
$Button3.Add_Click(
{
  # Path of Game Folder
    $path_of_dir = $path #'src\'

  # Finding game TYPE from main.js file
    $gamenamepath = $path_of_dir+"\views\main.js"
    $gameType = gc $gamenamepath | % { if($_ -cmatch "gameType:") {$_}}
    $gameType = $gameType.Split(":")[1].Substring(1,$gameType.Split(":")[1].length-2)
    $gameType -replace ‘[""]’
    $gameType = $gameType -replace ‘[""]’
  

    # Finding game NAME from main.js file and printing it
    $gamename = gc $gamenamepath | % { if($_ -cmatch "gameName:") {$_}}
    $gamename = $gamename.Split(":")[1].Substring(1,$gamename.Split(":")[1].length-2)
    $gamename -replace ‘[""]’
    $gamename = $gamename -replace ‘[""]’

    # Path of the XML File
    $path_of_xml = $path + "\resources\games\" + $gameType + "\" + $gamename + "\sounds\sounds.xml" #"sounds.xml"

      Test-Path  $path_of_xml
   
  If (Test-Path -Path $path_of_xml ) {
       
    # Print searching message on the console
    Write-Host "****************************"
    Write-Host "----------------------------"
    Write-Host "SEARCHING FOR USELESS SOUNDS"
    Write-Host "----------------------------"
    Write-Host  "game: "$gamename
    Write-Host "----------------------------"
    Write-Host "****************************"

    # Array of all sound title present in the XML file
    $musicArray = Select-Xml -Path $path_of_xml -XPath '/MergeAudiodata/Sounds/Sound' | ForEach-Object { $_.Node.Name }
    $path_of_dir = $path_of_dir + "\src"
    # Getting all code file from game folder src
    $gamemusic = Get-ChildItem -Path $path_of_dir -Filter '*.ts' -Recurse -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName }
  
    $wordfound=0

    # Getting content of all code file into a single file called content.txt
    if(Test-Path 'content.txt') {Clear-Content content.txt}
    if(Test-path 'output.txt'){Clear-Content output.txt}

    $gamemusic | Foreach-Object { $content = Get-Content $_; $content | Out-File -Append content.txt}

      $gamemusic |  Foreach-Object { 
        $word3 = $_
        $word4 = $word3.Substring(0,$word.length)
        Write-Host "searching in folder $word3"}

    # Reading from the above created content.txt file and searching for words
    $musicArray |  Foreach-Object { 
        $word = $_
        $word2 = $word.Substring(0,$word.length-1)
        Write-Host "The script is searching: $word"
        if ((Select-String -Path content.txt -Pattern $word -SimpleMatch -Quiet))
        {
            $wordfound+=1
        }
        else
        {
            echo "$word - Not In The Folder" | Out-File -Append output.txt
        }
    }
    if($wordfound -ne $musicarray.count)
    {
        Get-Content output.txt | Out-GridView
    }
    else
    {
        Write-Host "CONGRATULATIONS: 0 useless music was found!"-ForegroundColor Green
    }
    Remove-Item content.txt
    
    Write-Host "END of task" -ForegroundColor Yellow -BackgroundColor DarkGreen

    } else {

    # Print error message on the console
    Write-Host "****************************"
    Write-Host "----------------------------"
    Write-Warning "ARE YOU SURE YOUR SELECTED THE GAME FOLDER PROPERLY ?"
    Write-Host "----------------------------"
    Write-Host "****************************"
}
}
)


# Display the form on the screen.
$main_form.ShowDialog()