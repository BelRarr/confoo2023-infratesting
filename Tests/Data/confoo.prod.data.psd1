@{
    
    ResourceGroup = @{
		Name = 'confoo-rg'
		Location = 'canada central'
	}


    ServiceBusNamespace = @{
        Name = 'confoosb'
        Location = 'canada central'
        ResourceGroupName = 'confoo-rg'
        Sku = @{
            Name = 'Basic'
            Tier = 'Basic'
        }
        Tags = @{
            Projet = 'confoo'
            Environnement = 'prod'
        }
    }


    ServiceBusQueues = @(
        @{
            QueueName = 'prioritary'
            LockDuration = 'PT30S'
            DefaultMessageTimeToLive = 'P14D'
            MaxDeliveryCount = 10
            MaxSizeInMegabytes = 1024
            Status = 'Active'
            RequiresDuplicateDetection = $false            
        }
        @{
            QueueName = 'medium'
            LockDuration = 'PT30S'
            DefaultMessageTimeToLive = 'P7D'
            MaxDeliveryCount = 10
            MaxSizeInMegabytes = 1024
            Status = 'Active'
            RequiresDuplicateDetection = $false            
        }
        @{
            QueueName = 'low'
            LockDuration = 'PT30S'
            DefaultMessageTimeToLive = 'P2D'
            MaxDeliveryCount = 2
            MaxSizeInMegabytes = 1024
            Status = 'Active'
            RequiresDuplicateDetection = $false            
        }
    )
}