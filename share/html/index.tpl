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

<h2>Current jobs list</h2>
<table width="100%">
<tr>
<th>id</th>
<th>target</th>
<th>task</th>
<th>period (seconds)</th>
<th>next execution date</th>
</tr>
{
    my $i = 0;
    foreach my $job (@jobs) {
	my $class = $i++ % 2 ? 'odd' : 'even';
	$OUT .= "<tr class=\"$class\">";
	$OUT .= "<td>$job->{id}</td>";
	$OUT .= "<td>$job->{target}</td>";
	$OUT .= "<td>$job->{task}</td>";
	$OUT .= "<td>$job->{period}</td>";
	$OUT .= "<td>" . localtime($job->{nextRunDate}) . "</td>";
	$OUT .= "</tr>";
    }
}
</table>

</body>
</html>
