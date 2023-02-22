
# Install-Module -Name Pester -Force -SkipPublisherCheck
# import-module Pester -Passthru
# Connect-AzAccount
# Set-AzContext -Subscription 'Microsoft Azure Sponsorship'


Clear-Host

$container = New-PesterContainer `
-Path '.\Tests\confoo.tests.ps1' `
-Data @{ `
	ResourceGroupName = 'confoo-rg'; `
	ServiceBusName = 'confoosb'; `
	DataFilePath = '.\Tests\Data\confoo.prod.data.psd1'; `
	SkipConnection = 'Y'; `
}

$config = New-PesterConfiguration
$config.Output.Verbosity = "Detailed"
$config.Run.Container = $container
###################################################
$config.TestResult.Enabled = $true
$config.TestResult.OutputFormat = "NUnitXml"
$config.TestResult.OutputPath = "results.xml"
###################################################

Invoke-Pester -Configuration $config