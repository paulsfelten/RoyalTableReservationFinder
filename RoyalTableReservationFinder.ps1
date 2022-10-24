# Description: Those that are slightly more familiar with Disney World know that  getting a reservation for Cinderella's Royal Table can be very hard if not impossible. This PowerShell script will call the Reservation API every so often and send an email whenever a reservation is found that matches the date and # of people for the reservation. 

# How to use: Change the variables directly below then run! Note: the $appPass must be a generated gmail app password to access your email. Your personal email password will not work!

# Tips: Disney world has a 24hr cancellation policy, so you will be refunded for cancelling unless it is less than 24hrs until your reservation. Most people grab these up and the ones who cancell, will typically do so 1-4 days prior to the actual reservation. I would recommend setting $howOftenToCheck to 30 (minutes) for more than one week out from your park reservation. If less than 7 days, I would set it to 15 (minutes). 

# Note: The API address can be changed to be any restaurant/dinning experience!

$path = 'C:\...'
$email = "...@gmail.com"
$username = "" #Your username - do NOT include "@gmail.com"
$appPass = "..." #You must create an 'app password' in gmail and use it here. Your regular password won't work!
$howOftenToCheck = 15 #how many minutes to wait before checking again.
$month = "10"
$day = "21"
$year = "2022"
$howManyPeople = "3"

while ((Get-Date -Format "dd") -ne 21) {
	"" > $path
	$times = @('08', '10', '12', '14', '16')
	$availability = 0
	for($t=0; $t -lt $times.Count; $t++) {
		$url = "https://disneyworld.disney.go.com/finder/api/v1/explorer-service/dining-availability/%7B6182D449-6F14-4501-B5C2-06C1BF011A6F%7D/wdw/90002464;entityType=restaurant/table-service/$howManyPeople/$year-$month-$day/?searchTime=$($times[$t]):00:00"
		$response = Invoke-RestMethod -Method 'Get' -Uri $url
		if ($response.offers.time -eq $null) {
			Write-Host "No availability for $($times[$t])."
		}
		else {
			Write-Host "$($times[$t]) AVAILABILITY!"
			"$($times[$t]) @Royal Table!" >> $path
			$availability = 1
		}

	}
	if ($availability -eq 1) {
		#Start-Process $path
		$content = Get-Content -Path $path
		
		$EmailFrom = $email
		$EmailTo = $email
		$Subject = "Royal Table Reservation" 
		$Body = "Royal Table reservation found: $content" 
		$SMTPServer = "smtp.gmail.com" 
		$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587) 
		$SMTPClient.EnableSsl = $true 
		$SMTPClient.Credentials = New-Object System.Net.NetworkCredential($username, $appPass); 
		$SMTPClient.Send($EmailFrom, $EmailTo, $Subject, $Body)
	}
	
	Write-Host "Waiting $howOftenToCheck m"
	Start-Sleep -Seconds ($howOftenToCheck*60)
}