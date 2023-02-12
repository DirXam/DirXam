#
#  ██████╗░██╗██████╗░██╗░░██╗░█████╗░███╗░░░███╗
#  ██╔══██╗██║██╔══██╗╚██╗██╔╝██╔══██╗████╗░████║
#  ██║░░██║██║██████╔╝░╚███╔╝░███████║██╔████╔██║
#  ██║░░██║██║██╔══██╗░██╔██╗░██╔══██║██║╚██╔╝██║
#  ██████╔╝██║██║░░██║██╔╝╚██╗██║░░██║██║░╚═╝░██║
#  ╚═════╝░╚═╝╚═╝░░╚═╝╚═╝░░╚═╝╚═╝░░╚═╝╚═╝░░░░░╚═╝
#

if (Test-Path "DirXam" -PathType Container)
{
	if (Test-Path (Join-Path "DirXam" "DirXam") -PathType Container)
	{
		Set-Location "DirXam"
	}
	python -m dirxam
	exit
}

Write-Output("Downloading Python...")
Invoke-WebRequest -Uri "https://www.python.org/ftp/python/3.9.6/python-3.9.6.exe" -OutFile (Join-Path $env:TEMP "python-installer.exe")
Write-Output("Installing Python...")
Start-Process (Join-Path $env:TEMP "python-installer.exe") @("/quiet"; "InstallAllUsers=0"; "PrependPath=1"; "Include_test=0"; "InstallLauncherAllUsers=0") -Wait
Write-Output("Locating Git...")
$ret = Invoke-RestMethod -Uri "https://api.github.com/repos/git-for-windows/git/releases" -Headers @{ 'User-Agent' = 'DirXam installer' }
foreach ($release in $ret)
{
	$asset_id = $release.assets | Where { $_.name -Match ("^Git-[0-9]+\.[0-9]+\.[0-9]+-" + (Get-WmiObject -Class Win32_OperatingSystem -ComputerName $env:computername -ea 0).OSArchitecture + ".exe$") } | % { $_.id }
	if (-not [string]::IsNullOrEmpty($asset_id))
	{
		break
	}
}
if ( [string]::IsNullOrEmpty($asset_id))
{
	Write-Error "Unable to locate Git"
	exit
}
$download_url = "https://api.github.com/repos/git-for-windows/git/releases/assets/" + $asset_id
Write-Output("Git yuklab olish...")
Invoke-WebRequest -Uri $download_url -OutFile (Join-Path $env:TEMP "git-scm-installer.exe") -Headers @{ 'User-Agent' = 'DirXam installer'; 'Accept' = 'application/octet-stream' }
Write-Output("Git o'rnatish...")
Start-Process (Join-Path $env:TEMP "git-scm-installer.exe") @("/VERYSILENT"; "/NORESTART"; "/NOCANCEL"; "/SP-"; "/CURRENTUSER"; "/NOCLOSEAPPLICATIONS"; "/NORESTARTAPPLICATIONS"; '/COMPONENTS=""') -Wait
Write-Output("Bajarildi")

# https://stackoverflow.com/a/31845512
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
git clone https://github.com/DirXam/DirXam

Set-Location DirXam
python -m pip install -r requirements.txt
python -m dirxam
python -m dirxam --heroku # Stopgap
