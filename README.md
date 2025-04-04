# Azure PowerShell Scripts

This repository contains two PowerShell scripts designed to interact with Azure resources. These scripts allow users to:

1. **Create an Azure Virtual Machine (VM)** or **Deploy Gateway Packet Capture**.
2. **Search for a Private IP Address** to find its associated **Subnet** and **Network Interface Card (NIC)**.

## Prerequisites

Before running these scripts, ensure you have the following:

- **Azure CLI** installed on your machine.
- **PowerShell** version 5.0 or higher.
- **Permissions** to create VMs and access network resources in the Azure subscription you are working with.
- Logged into **Azure** via the Azure CLI with the following command:

  ```bash
  az login

## Azure Resouce Deloyment Input

Enter the Subscription ID: 12345-abcd-67890  
Enter the Resource Group Name: MyResourceGroup  
Enter the name of the Azure service: vm  
Enter the VM name: MyVM  
Enter the location (e.g., eastus): eastus  
Enter the VM size (e.g., Standard_B2s): Standard_B2s  
Enter the VM image (e.g., UbuntuLTS): UbuntuLTS  
Enter the admin username: adminuser  
Enter the admin password: ********  

## Packet Capture Input

Enter the Subscription ID: 12345-abcd-67890  
Enter the Resource Group Name: MyResourceGroup  
Enter the name of the Azure service: packetCapture  
Enter the location (e.g., eastus): eastus  
Enter the capture name: MyPacketCapture  
Enter the Gateway ID: Gateway123  
Enter the storage account directory: MyStorageAccount  
