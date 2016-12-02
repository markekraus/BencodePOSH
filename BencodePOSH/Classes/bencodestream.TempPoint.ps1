<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2016 v5.2.129
	 Created on:   	11/18/2016 9:35 AM
	 Created by:   	Mark Kraus
	 Organization: 	
	 Filename:     	bencodestream.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>
class bencodestream {
    [byte[]]$Data
    [int64]$Position = 0
    [System.Text.encoding]$Encoding = [System.Text.encoding]::UTf8
    hidden $_Count = $(
        $This | Add-Member -MemberType ScriptProperty -Name 'Count' {
            $This.Data.Count
        } {
            throw "Count cannot be set"
        }
    )
    
    #New from path to file
    bencodestream  ([string]$Path) {
        if (-not (Test-Path $Path)) {
            throw "File '$Path' does not exist"
        }
        $This.Data = Get-Content -Encoding Byte -ReadCount 0 -Path $Path -ErrorAction Stop
    }
    
    #New from path to file and encoding
    bencodestream  ([string]$Path, [System.Text.encoding]$Encoding) {
        if (-not (Test-Path $Path)) {
            throw "File '$Path' does not exist"
        }
        $This.Encoding = $Encoding
        $This.Data = Get-Content -Encoding Byte -ReadCount 0 -Path $Path -ErrorAction Stop
    }
    
    #New from Byte Array
    bencodestream ([byte[]]$ByteArray) {
        $This.Data = $ByteArray
    }
    
    #New from Byte Array with Encoding
    bencodestream ([byte[]]$ByteArray, [System.Text.encoding]$Encoding) {
        $This.Encoding = $Encoding
        $This.Data = $ByteArray
    }
    
    static [bencodestream] NewFromBencodeString ([string]$Bencodestring) {
        return [bencodestream]::new($([System.Text.UTF8Encoding]::new()).getbytes($Bencodestring))
    }
    
    static [bencodestream] NewFromBencodeString ([string]$Bencodestring, [System.Text.encoding]$Encoding) {
        return [bencodestream]::new($Encoding.getbytes($Bencodestring), $Encoding)
    }
    
    static [bencodestream] NewFromFile ([string]$Path) {
        return [bencodestream]::new($Path)
    }
    
    static [bencodestream] NewFromFile ([string]$Path, [System.Text.encoding]$Encoding) {
        return [bencodestream]::new($Path, $Encoding)
    }
    
    #Grab a byte
    [object] ReadByte() {
        if ($This.Position -eq $This.Count) {
            return -1
        }
        $This.Position++
        return $This.Data[($This.Position - 1)]
    }
    
    #Grab a char
    [object] ReadChar() {
        if ($This.Position -eq $This.Count) {
            return -1
        }
        $This.Position++
        return $This.Encoding.GetChars($This.Data[($This.Position - 1)])
    }
    
    #Peek a byte
    [object] PeekByte() {
        if (($This.Position + 1) -eq $This.Count -or $This.Position -eq $This.Count ) {
            return -1
        }
        return $This.Data[($This.Position + 1)]
    }
    
    #Peek a char
    [object] PeekChar() {
        if (($This.Position + 1) -eq $This.Count -or $This.Position -eq $This.Count) {
            return -1
        }
        return $This.Encoding.GetChars($This.Data[($This.Position + 1)])
    }
    
    [byte[]] ReadAllBytes () {
        $This.Position = 0
        return $This.Data
    }
    
    [string] ReadAllString () {
        $This.Position = 0
        return $This.Encoding.GetString($This.Data)
    }
    
    [void] Rewind() {
        $This.Position = 0
    }
    
    [void] SetPosition([int64]$Position) {
        $this.Position = $Position
    }
}