Param(
    [string] [Parameter(Mandatory=$true)] $ResourceGroupName,
    [string] [Parameter(Mandatory=$true)] $ServiceBusName,
    [string] [Parameter(Mandatory=$true)] $DataFilePath,
    [string] $TenantId,
	[string] $SubscriptionId,
	[string] $ServicePrincipalId,
	[string] $ServicePrincipalKey,
	[string] $SkipConnection = 'N'
)


# Login to Azure
if ($SkipConnection -eq 'N'){
	$securePassword = ConvertTo-SecureString $ServicePrincipalKey -AsPlainText -Force
	$psCredential = New-Object System.Management.Automation.PSCredential ($ServicePrincipalId, $securePassword)
	Connect-AzureRmAccount -ServicePrincipal -Credential $psCredential -Tenant $TenantId
	Set-AzureRmContext -Subscription $SubscriptionId
}

# Load the test parameters file into the "Expected" object:
$Expected = Import-PowerShellDataFile -Path $DataFilePath


# Get the resources we want to test (deployed to Azure):
$rg = Get-AzResourceGroup -ResourceGroupName $ResourceGroupName
$sbNamespace = Get-AzServiceBusNamespace -ResourceGroupName $ResourceGroupName -Name $ServiceBusName
$sbQueues = Get-AzServiceBusQueue -ResourceGroupName $ResourceGroupName -Namespace $ServiceBusName


# Defining Tests

###############  Testing the Resource Group ###############
Describe 'Validating the resource group' {
    It "Resource group name is correct" {
      $rg.ResourceGroupName | Should -Be $Expected.ResourceGroup.Name
    }
    It "The location (region) of the resource group is correct" {
      $rg.Location | Should -Be $Expected.ResourceGroup.Location
    }
}

###############  Testing the Service Bus namespace ###############
Describe 'Validating the Service Bus namespace' {
    It "The Service Bus is in the right resource group" {
        $sbNamespace.ResourceGroupName | Should -Be $Expected.ServiceBusNamespace.ResourceGroupName
    }
    It "The Service Bus has the right name" {
        $sbNamespace.Name | Should -Be $Expected.ServiceBusNamespace.Name
    }
    It "The Service Bus is in the right region (Location)" {
        $sbNamespace.Location | Should -Be $Expected.ServiceBusNamespace.Location
    }
    # It "The Service Bus has the correct SKU" {        
    #     $sbNamespace.Sku.Name.ToString() | Should -Be $Expected.ServiceBusNamespace.Sku.Name
    #     $sbNamespace.Sku.Tier.ToString() | Should -Be $Expected.ServiceBusNamespace.Sku.Tier
    # }
    It "All the tags are present and have the right values" {
      foreach ($tagExpected in $Expected.ServiceBusNamespace.Tags.Keys){
          # tag is present
          $tagExpected | Should -BeIn $sbNamespace.Tags.Keys 
          # the value is correct
          $sbNamespace.Tags.Item($tagExpected) | Should -Be $Expected.ServiceBusNamespace.Tags.Item($tagExpected)
      }
    }
    It "The Service Bus has the expected number of queues" {
        $sbQueues.Count | Should -Be $Expected.ServiceBusQueues.Count
    }
}



###############  Testing the Service Bus queues ###############
Describe 'Validating the queues of the Service Bus' {
    foreach ($sbQueue in $sbQueues){
        $ExpectedObject = $Expected.ServiceBusQueues | Where-Object {$_.QueueName -eq $sbQueue.Name}
        It "Queue name is correct" {
            $sbQueue.Name | Should -Be $ExpectedObject.QueueName
        }
        # It "The status of the queue is correct" {
        #     $sbQueue.Status.ToString() | Should -Be $ExpectedObject.Status
        # }
        It "LockDuration of the queue is correct" {
            $sbQueue.LockDuration | Should -Be $ExpectedObject.LockDuration
        }
        It "DefaultMessageTimeToLive of the queue is correct" {
            $sbQueue.DefaultMessageTimeToLive | Should -Be $ExpectedObject.DefaultMessageTimeToLive
        }
        It "MaxDeliveryCount of the queue is correct" {
            $sbQueue.MaxDeliveryCount | Should -Be $ExpectedObject.MaxDeliveryCount
        }
        It "MaxSizeInMegabytes of the queue is correct" {
            $sbQueue.MaxSizeInMegabytes | Should -Be $ExpectedObject.MaxSizeInMegabytes
        }
        It "RequiresDuplicateDetection of the queue is correct" {
            $sbQueue.RequiresDuplicateDetection | Should -Be $ExpectedObject.RequiresDuplicateDetection
        }
    }
}