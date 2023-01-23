# Import the Active Directory module for Windows PowerShell
Import-Module ActiveDirectory

# Prompt user for first name and last name
$FirstName = Read-Host "Please enter the first name"
$LastName = Read-Host "Please enter the last name"

# Create username by concatenating the first letter of first name and last name
$username = $FirstName.Substring(0, 1) + $LastName

# Generate random password
[STRING]$Zollikerberg = "Zollikerberg"
[STRING] $Password = Get-Random -Maximum 40
$PlainPW = "$Zollikerberg$Password"
$DefPW = ConvertTo-SecureString $PlainPW -AsPlainText -Force 

# Create new Active Directory user with the given username and password
New-ADUser -Name "$FirstName $LastName" -SamAccountName $username -UserPrincipalName "$username@example.com" -AccountPassword (ConvertTo-SecureString $DefPW -AsPlainText -Force) -Enabled $true -ChangePasswordAtLogon $True

# Prompt user if they want to copy group membership from an existing user
$copyGroups = Read-Host "Do you want to copy group membership from an existing user? (yes or no)"

# Check if user wants to copy group membership
if ($copyGroups -eq "yes") {
    # Prompt user for existing user to copy group membership from
    $existingUser = Read-Host "Please enter the username of the existing user"
    # Check if existing user exists in Active Directory
    $existingUserExists = Get-ADUser -Identity $existingUser -ErrorAction SilentlyContinue
    if ($existingUserExists) {
        # Get group membership of existing user
        $existingUserGroups = Get-ADPrincipalGroupMembership $existingUser
        # Add group membership of existing user to new user
        foreach ($group in $existingUserGroups) {
            try {

                Add-ADPrincipalGroupMembership -Identity $username -MemberOf $group
} catch {
Write-Host "Error: Unable to add $username to $group, continuing with other group memberships." -ForegroundColor Red
}
}
Write-Host "Group membership successfully copied from $existingUser to $username."
} else {
Write-Host "Error: $existingUser does not exist in Active Directory."
}

}