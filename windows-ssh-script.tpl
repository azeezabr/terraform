add-content -path C:\Users\Precision\.ssh\config -value @'


Host ${hostname}
    Hostname ${hostname}
    User ${user}
    IdentityFile ${identityfile}
'@