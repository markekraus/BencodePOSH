<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2016 v5.3.130
	 Created on:   	11/30/2016 4:55 AM
	 Created by:   	Mark Kraus
	 Organization: 	
	 Filename:     	Open-BencodeFile.ps1
	===========================================================================
	.DESCRIPTION
		Open-BencodeFile Function
#>
<#
    .SYNOPSIS
        Opens a file stream for a bencoded file
    
    .DESCRIPTION
        Returns a BencodeStream object from a bencoded file to be used by other functions in this module. An optional text encoding can be sepcified. The opened file will be locked and unavailable to other system processes until the PowerShell session has ended or until Close-BencodeFile is called on the obejct.
    
    .PARAMETER FilePath
        Path of the bencoded file to open.
    
    .PARAMETER Encoding
        Optional character encoding for the file. The default is UTf8.
    
    .EXAMPLE
        		PS C:\> Open-BencodeFile -FilePath $value1 -Encoding $value2
    
    .NOTES
        Additional information about the function.
#>
function Open-BencodeFile {
    [CmdletBinding(ConfirmImpact = 'Low')]
    [OutputType([BencodeStream])]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $_ -PathType Leaf })]
        [string[]]$FilePath,
        
        [Parameter(ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [System.Text.Encoding]$Encoding = [System.Text.Encoding]::UTF8
    )
    
    Process {
        
        foreach ($Path in $FilePath) {
            [BencodeStream]::new($Path, 'File', $Encoding)
        }        
    }
}
