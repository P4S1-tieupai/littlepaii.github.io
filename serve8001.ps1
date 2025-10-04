$prefix = "http://localhost:8001/"
$root = (Get-Location).Path
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($prefix)
$listener.Start()
Write-Output "Serving $root on $prefix. Press Ctrl+C in the terminal to stop."
while ($listener.IsListening) {
    try {
        $context = $listener.GetContext()
    } catch {
        break
    }
    $request = $context.Request
    $localpath = $request.Url.LocalPath.TrimStart('/')
    if ($localpath -eq '') { $localpath = 'index.html' }
    $file = Join-Path $root $localpath
    if (Test-Path $file) {
        $ext = [IO.Path]::GetExtension($file).ToLower()
        switch ($ext) {
            '.html' { $ctype = 'text/html' }
            '.htm' { $ctype = 'text/html' }
            '.css' { $ctype = 'text/css' }
            '.js' { $ctype = 'application/javascript' }
            '.json' { $ctype = 'application/json' }
            '.png' { $ctype = 'image/png' }
            '.jpg' { $ctype = 'image/jpeg' }
            '.jpeg' { $ctype = 'image/jpeg' }
            '.gif' { $ctype = 'image/gif' }
            '.svg' { $ctype = 'image/svg+xml' }
            default { $ctype = 'application/octet-stream' }
        }
        $bytes = [IO.File]::ReadAllBytes($file)
        $context.Response.ContentType = $ctype
        $context.Response.ContentLength64 = $bytes.Length
        $context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
        $context.Response.OutputStream.Close()
    } else {
        $context.Response.StatusCode = 404
        $context.Response.Close()
    }
}
$listener.Stop()
$listener.Close()
Write-Output "Server stopped."
