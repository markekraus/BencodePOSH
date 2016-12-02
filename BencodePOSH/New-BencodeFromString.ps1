<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2016 v5.3.130
	 Created on:   	11/29/2016 4:53 AM
	 Created by:   	Mark Kraus
	 Organization: 	
	 Filename:     	New-BencodeFromString.ps1
	===========================================================================
	.DESCRIPTION
		Contains the 	New-BencodeFromString Function
#>
<#
    .SYNOPSIS
        Returns a BencodeStream created from a string
    
    .DESCRIPTION
        Takes a String and creates a BencodeStream object that can be used by the other functions in this module. No validation is done to ensure the string is a valid Bencode. An optional endocing can be set to identify the encoding that should be used for any write operations.
    
    .PARAMETER String
        The string to be used for creating the BencodeStream
    
    .PARAMETER Encoding
        Sets the encoding for the BencodeStream that will be used for write operations. The Default is UTF8
    
    .EXAMPLE
        PS C:\> $BencodeStream = New-BencodeFromString -String 'i1000e'

    .EXAMPLE
        PS C:\> $BencodeStream = New-BencodeFromString -String 'i1000e' -Encoding [System.Text.Encoding]::UTF8
    
    .NOTES
        https://wiki.theory.org/BitTorrentSpecification#Bencoding
#>
function New-BencodeFromString {
    [CmdletBinding(ConfirmImpact = 'None')]
    [OutputType([BencodeStream])]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [String[]]$String,
        
        [Parameter(Mandatory = $false,
                   ValueFromPipelineByPropertyName = $true)]
        [System.Text.Encoding]$Encoding = [System.Text.Encoding]::UTF8
    )
    
    Process {
        foreach ($CurString in $String) {
            [BencodeStream]::New($CurString,'String',$Encoding)
        }
    }
}
