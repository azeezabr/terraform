cat << EOF >> /c/Users/Precision/.ssh/config

Host ${hostname}
    Hostname ${hostname}
    User ${user}
    IdentityFile ${identityfile}
EOF