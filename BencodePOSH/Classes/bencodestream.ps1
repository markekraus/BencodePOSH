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
enum BencodeStreamType {
    File = 1
    String = 2
    ExistingStream = 3
}

class BencodeStream {
    hidden [System.IO.Stream]$Stream
    [System.Text.encoding]$Encoding = [System.Text.encoding]::UTf8
    hidden [System.IO.BinaryReader]$StreamReader
    hidden [bool]$_HasPeeked = $false
    hidden [int]$_PeekByte
    [BencodeStreamType]$StreamType
    
    hidden $_ScriptProperties = $(
        # Add Length ScriptProperty to return the lenght of the stream.
        $This | Add-Member -MemberType ScriptProperty -Name 'Length' {
            # Get{}
            $This.Stream.Length
        } {
            # Set{}
            throw [NotSupportedException]::new()
        }
        
        
        # Add Position ScriptProperty to handle changing the position of the stream
        # Implments -1 style positions to go to the end of the stream
        $This | Add-Member -MemberType ScriptProperty -Name 'Position' {
            # Get{}
            $This.Stream.Position
        } {
            # Set{}
            param (
                [long]$Position
            )
            if (-not ($Position -le $This.Length -and $Position -ge - $This.Length)) {
                $Message = "Invalid range. Value must be between '-{0}' and '{0}'" -f $This.Length
                Throw [ArgumentOutOfRangeException]::new('Position', $Message)
            }
            $This._HasPeeked = $false
            if ($Position -lt 0) {
                $This.Stream.Position = $This.Length + $Position
            }
            else {
                $This.Stream.Position = $Position
            }
        }
        
        # Add Name ScriptProperty to return the filepath of the stream if present.
        $This | Add-Member -MemberType ScriptProperty -Name 'Name' {
            # Get{}
            $This.Stream.Name
        } {
            # Set{}
            throw [NotSupportedException]::new()
        }
    )
    
    [int] PeekByte () {
        if ($This._HasPeeked) {
            return $This._PeekByte
        }
        $This._HasPeeked = $true
        $previousposition = $This.Stream.Position
        try {
            $This._PeekByte = [int]$This.StreamReader.ReadByte()
        }
        catch [System.IO.EndOfStreamException] {
            $This._PeekByte = -1
        }
        $This.Stream.Position = $previousposition
        return $This._PeekByte
    }
    
    [int] PeekChar () {
        return $This.StreamReader.PeekChar()
    }
    
    [int] ReadByte () {
        if (-not $This._HasPeeked) {
            try {
                $Return = [int]$This.StreamReader.ReadByte()
            }
            catch [System.IO.EndOfStreamException] {
                $Return = -1
            }
            return $Return
        }
        if ($This._PeekByte -eq -1) {
            return $This._PeekByte
        }
        $This._HasPeeked = $false
        $This.Stream.Position += 1
        return $This._PeekByte
    }
    
    [byte[]] ReadBytes ([int]$Count) {
        return $This.StreamReader.ReadBytes($Count)
    }
    
    [int] ReadChar () {
        try {
            $Return = $This.StreamReader.ReadChar()
        }
        catch [System.IO.EndOfStreamException] {
            $Return = -1
        }
        return $Return
    }
    
    [char[]] ReadChars ([int32]$Count) {
        return $this.StreamReader.ReadChars($Count)
    }

    # This is where all the new object logic is done.
    [void] Init ([object]$Object, [BencodeStreamType]$StreamType, [system.Text.encoding]$Encoding) {
        $This.Encoding = $Encoding
        $This.StreamType = $StreamType
        switch ($StreamType) {
            'File' {
                $This.Stream = [System.IO.FileStream]::new([string]$Object, 'Open')
            }
            'String'{
                $This.Stream = [system.io.memorystream]::new()
                $StreamWriter = [System.IO.StreamWriter]::new($This.Stream)
                $bytes = $Encoding.GetBytes([string]$Object)
                $StreamWriter.Write($bytes, 0, $bytes.Length)
                $StreamWriter.Flush()
                $This.Stream.Position = 0
            }
            'ExistingStream' {
                $This.Stream = $Object
            }
        }
        $This.StreamReader = [System.IO.BinaryReader]::new($This.Stream, $This.Encoding)
    }
    
    BencodeStream ([object]$Object, [BencodeStreamType]$StreamType, [system.Text.encoding]$Encoding) {
        $This.Init($Object, $StreamType, $Encoding)
    }
    
    BencodeStream ([system.IO.stream]$Stream) {
        $This.Init($Stream, [BencodeStreamType]::ExistingStream, [system.Text.encoding]::UTF8)
    }
    
    BencodeStream ([system.IO.stream]$Stream, [system.Text.encoding]$Encoding) {
        $This.Init($Stream, [BencodeStreamType]::ExistingStream, $Encoding)
    }
    
    # Default string behavior is a file path
    BencodeStream ([string]$FilePath) {
        $This.Init($FilePath, [BencodeStreamType]::File, [system.Text.encoding]::UTF8)
    }
    
    BencodeStream ([string]$FilePath, [system.Text.encoding]$Encoding) {
        $This.Init($FilePath, [BencodeStreamType]::File, $Encoding)
    }
    
    [void] Dispose () {
        $This.Stream.Dispose()
    }
}