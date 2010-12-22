<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml"><head>

<meta content="text/html; charset=UTF-8" http-equiv="content-type" />
<title>FusionInventory-Agent</title>
<link rel="stylesheet" href="/files/site.css" type="text/css" />

</head>
<body>

<img src="/files/logo.png" alt="FusionInventory" />
<br />
This is FusionInventory Agent {$version}<br />

{
    if ($trust) {
	$OUT .= '<a href="/now">Force an Inventory</a>';
    }
}

<h2>Current targets list</h2>
<table width="100%">
<tr>
<th>id</th>
<th>type</th>
<th>destination</th>
<th>period (seconds)</th>
<th>next execution date</th>
<th>status</th>
</tr>
{
    foreach my $target (@targets) {
	$OUT .= "<tr>";
	$OUT .= "<td>$target->{id}</td>";
	$OUT .= "<td>$target->{type}</td>";
	$OUT .= "<td>$target->{destination}</td>";
	$OUT .= "<td>$target->{period}</td>";
	$OUT .= "<td>$target->{time}</td>";
	$OUT .= "<td>$target->{status}</td>";
	$OUT .= "</tr>";
    }
}
</table>

</body>
</html>
