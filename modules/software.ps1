<#
.SYNOPSIS
    Module for installing essential software.
.DESCRIPTION
    This script installs a list of software using winget or chocolatey (fallback).
.NOTES
    File Name      : ./install/software.ps1
    Author         : Rodrigo Gargani Oliveira
    Prerequisite   : >= PowerShell 5.1.19041.5607 (Desktop)
#>

# List of software to install
$softwareList = @(
  @{ Name = "7-Zip";                           Id = "7zip.7zip";                       ChocoId = "7zip";                       Description = "File Archiver" },
  @{ Name = "Node.js LTS";                     Id = "OpenJS.NodeJS.LTS";               ChocoId = "nodejs-lts";                 Description = "Development Platform" },
  @{ Name = "Java JDK";                        Id = "Oracle.JDK.17";                   ChocoId = "jdk8";                       Description = "Java Development Kit" },
  @{ Name = "Python";                          Id = "Python.Python.3";                 ChocoId = "python";                     Description = "Programming Language" },
  @{ Name = "Visual Studio Code";              Id = "Microsoft.VisualStudioCode";      ChocoId = "vscode";                     Description = "Code Editor" },
  @{ Name = "Google Chrome";                   Id = "Google.Chrome";                   ChocoId = "googlechrome";               Description = "Web Browser" },
  @{ Name = "IntelliJ IDEA Community Edition"; Id = "JetBrains.IntelliJIDEA.Community";ChocoId = "intellijidea-community";     Description = "Java/Kotlin IDE" },
  @{ Name = "Apache NetBeans";                 Id = "Apache.NetBeans";                 ChocoId = "netbeans";                   Description = "Java IDE" },
  @{ Name = "Arduino IDE";                     Id = "Arduino.ArduinoIDE";              ChocoId = "arduino";                    Description = "Arduino Programming Environment" },
  @{ Name = "Android Studio";                  Id = "Google.AndroidStudio";            ChocoId = "androidstudio";              Description = "Android Development IDE" },
  @{ Name = "MySQL";                           Id = "Oracle.MySQL";                    ChocoId = "mysql";                      Description = "Relational Database" },
  @{ Name = "MySQL Workbench";                 Id = "Oracle.MySQLWorkbench";           ChocoId = "mysql.workbench";            Description = "MySQL Administration Tool" },
  @{ Name = "Docker Desktop";                  Id = "Docker.DockerDesktop";            ChocoId = "docker-desktop";             Description = "Container Platform" },
  @{ Name = "Eclipse IDE";                     Id = "EclipseFoundation.Eclipse";       ChocoId = "eclipse";                    Description = "Java IDE" }
)

# Iterate over the list and install each software
foreach ($software in $softwareList) {
  Install-Resource -ResourceName $software.Name -PackageId $software.Id -ChocoPackageId $software.ChocoId
}

Write-Log "Software installation process completed." "SUCCESS"