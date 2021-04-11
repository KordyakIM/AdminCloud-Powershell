#--------------------------------------------------#
$SMBFolderAC_DFS = "\\SMBPath\Productive_AC"
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
#получаем запущенны процесс AdminCloud
$FolderBrowsers = Get-Process -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Path | Where-Object -FilterScript {$_ -like "*AdminCloud.exe*"}
while(Get-Process -Name "AdminCloud"){
	Stop-Process -Name "AdminCloud" -Force -ErrorAction SilentlyContinue
	sleep 1
}
#SQL input data
$SQLServer = "SQLServer"
$SQLDBName = "AdminCloud"
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$SqlConnection.ConnectionString = "Server = $SQLServer; Database = $SQLDBName; Integrated Security=True"
#$sqlConnection.Open()
#if($?){
#	$sqlConnection.Close()
#}else{
#	[System.Windows.Forms.MessageBox]::Show("Не удалось подключиться к SQL-базе AdminCloud.`nОбратитесь к Администратору.","AdminCloud")
#	$sqlConnection.Close()
#	break
#}
#проверка версии приложения
$SqlQuery = "Select * FROM dbo.Config"
$SqlCmd = New-Object System.Data.SqlClient.SqlCommand($SqlQuery,$SqlConnection)
$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
$SqlAdapter.SelectCommand = $SqlCmd
$DataSet = New-Object System.Data.DataSet
$SqlAdapter.Fill($DataSet)
if($?){
	$version = $DataSet.Tables[0].Parameter[0]
	if(Get-ChildItem -Path $SMBFolderAC_DFS -ErrorAction SilentlyContinue){
		$FolderBrowser = $FolderBrowsers -replace "AdminCloud.exe",""
		if(![string]::IsNullOrEmpty($FolderBrowser)) {
			Copy-Item "$SMBFolderAC_DFS\AdminCloud.exe" -Destination $FolderBrowser
			Copy-Item "$SMBFolderAC_DFS\AdminCloud.exe.config" -Destination $FolderBrowser
		    [System.Windows.Forms.MessageBox]::Show("Приложение AdminCloud успешно обновилось до версии $version","AdminCloud")
			Start-Process -filepath $folderbrowser"AdminCloud.exe" -ErrorAction SilentlyContinue
			Stop-Process -Name AdminCloud_Update -Force -ErrorAction SilentlyContinue
		}
	}else{
		[System.Windows.Forms.MessageBox]::Show("Приложение не удалось обновить до версии $version, нет доступа к ресурсу - $SMBFolderAC_DFS`nОбратитесь к Администратору.","AdminCloud")
		break
	}
}else{
	[System.Windows.Forms.MessageBox]::Show("Приложение не обновилось, не удалось подключиться к SQL-базе AdminCloud.`nОбратитесь к Администратору.","AdminCloud")
	break
}