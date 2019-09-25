﻿@{
# Script module or binary module file associated with this manifest
ModuleToProcess = 'PMPro.psm1'

# Version number of this module.
ModuleVersion = '2.0000'

# ID used to uniquely identify this module
GUID = 'b888e75a-2284-474b-9b34-3ecaed5d9821'

# Author of this module
Author = 'Matt Egan (Version 1), Armand Hatting (Current version)'

HelpInfoUri  = 'https://github.com/ahatting/PMPro-PSModule'

# Company or vendor of this module
CompanyName = ''

# Copyright statement for this module
Copyright = '(c) 2019 Armand Hatting. All rights reserved.'

# Description of the functionality provided by this module
Description = 'This module contains powershell wrappers to leverage the Okta API functions described here https://www.manageengine.com/products/passwordmanagerpro/help/restapi.html'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '4.0'

# Name of the Windows PowerShell host required by this module
PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
PowerShellHostVersion = '4.0'

# Minimum version of the .NET Framework required by this module
DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module
CLRVersion = ''

# Processor architecture (None, X86, Amd64, IA64) required by this module
ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
#RequiredAssemblies = @('')

# Script files (.ps1) that are run in the caller's environment prior to importing this module
ScriptsToProcess = @('myPMPro.ps1')

# Type files (.ps1xml) to be loaded when importing this module
#TypesToProcess = @('')

# Format files (.ps1xml) to be loaded when importing this module
#FormatsToProcess = @('')

# Modules to import as nested modules of the module specified in ModuleToProcess
NestedModules = @()

# Functions to export from this module
FunctionsToExport = 'PMPro*'

# Cmdlets to export from this module
CmdletsToExport = ''

# Variables to export from this module
VariablesToExport = ''

# Aliases to export from this module
AliasesToExport = ''

# List of all modules packaged with this module
ModuleList = @()

# List of all files packaged with this module
FileList = @('PMPro.psm1','PMPro.psd1','myPMPro.ps1')

# Private data to pass to the module specified in ModuleToProcess
PrivateData = ''
}