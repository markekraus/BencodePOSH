<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2016 v5.2.129
	 Created on:   	11/17/2016 5:03 AM
	 Created by:   	Mark Kraus
	 Organization: 	
	 Filename:     	bencodestring.ps1
	===========================================================================
	.DESCRIPTION
		bencodestring class definition
#>
class bencodestring {
    [string]$String
    
    hidden $_Length = $(
        $This | Add-Member -MemberType ScriptProperty -Name 'Length' {
            $This.String.Length
        } {
            throw "Length cannot be set"
        }
    )
    
    bencodestring ([string]$String) {
        $This.String = $String
    }
    
    bencodestring ([byte[]]$ByteArray) {
        $This.FromBencodeByteArray($ByteArray)
    }
    
    [void] FromBencodeByteArray([byte[]]$ByteArray) {
        $UTF8 = [system.text.encoding]::UTF8
        $Bencodestring = $UTF8.GetString($ByteArray)
        $Length, $StringPart = $Bencodestring -split ':'
        if (-not $StringPart) {
            throw "Invalid Byte Array for Bencode String. Expcted string format: <length>:<string>"
        }
        $This.String = $StringPart
    }
    
    [void] FromByteArray([byte[]]$ByteArray) {
        $UTF8 = [system.text.encoding]::UTF8
        $This.String = $UTF8.GetString($ByteArray)
    }
    
    [string] ToString() {
        return $This.String
    }
    
    [string] ToBencodeString() {
        $Output = "{0}:{1}" -f $this.String.Length, $This.String
        return $Output
    }
    
    [byte[]] ToBencodeByteArray() {
        $UTF8 = [system.text.encoding]::UTF8
        $ByteArray = $UTF8.GetBytes($This.ToBencodeString())
        return $ByteArray
    }
    
    [byte[]] ToByteArray() {
        $UTF8 = [system.text.encoding]::UTF8
        $ByteArray = $UTF8.GetBytes($This.String)
        return $ByteArray
    }
}