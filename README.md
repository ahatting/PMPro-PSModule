## ManageEngine Password Manager Pro API PowerShell Wrapper Module

_The ManageEngine Password Manager Pro API PowerShell Wrapper Module allows you to easily retrieve data from Password Manager Pro programmaticaly_

Requirements:
- Windows PowerShell version 4 or higher
- Password Manager Pro (Enterprise license for using the API)
- A settingsfile (myPMPro.ps1) which holds the details for your own PMP environement
- This module loaded in your PS session

Before you begin, make sure you change the values in the settings file - myPMPro.ps1.
If you do not want to expose the API users authorization token from PMP in plain text, you can encrypt the token in the settingsfile (myPMPro.ps1) using DPAPI:
https://docs.microsoft.com/en-us/previous-versions/ms995355(v=msdn.10)?redirectedfrom=MSDN


Examples:


