#!/bin/bash

mkdir blog

builddate=$( date +%a,\ %d\ %b\ %Y )

head=$( cat head.htm )
foot=$( cat foot.htm )
deck=$( cat deck.htm )
url=$( head -1 siteinfo.txt )
sitename=$( head -2 siteinfo.txt | tail -1 )
sitedesc=$( tail -1 siteinfo.txt )

echo "sorting index..."
index=()
for i in $( ls src )
do
	date=$( head -2 src/$i | tail -1 )
	index+=("$date $i")
done
echo ". unsorted	${index[@]}"

IFS=$'\n' index=($(sort <<<"${index[*]}")) && unset IFS
echo ". sorted	${index[@]}"

echo "building..."
cards=""
rssstack=""
for i in "${index[@]}"
do
	items=($i)
	date=${items[0]}
	file=${items[1]}
	echo ". processing $file..."
	filename=$( echo "$file" | sed 's/$/l/' )
	desc=$( head -1 src/$file )
	date=$( head -2 src/$file | tail -1 )
	title=$( head -3 src/$file | tail -1 )
	spechead=$( echo "$head" | sed "s/<!--TITLE-->/$title/" )
	main=$( cat src/$file | tail -n +4 )
	img=$( echo "$main" | grep "class=\"titular\"" | sed 's/<img/<img style="width:200px;" width="200"/' )
	page="$spechead<h1>$title</h1><p><code>$date</code></p>$main$foot"
	echo "$page" > blog/$filename
	rssstack="<item>
  <title>$title</title>
  <link>$url/blog/$filename</link>
  <pubDate>$date</pubDate>
  <description>
<![CDATA[$main]]>
  </description>
</item>
$rssstack"

	cards="<div class='minipost'>
	<h2><a href='$filename'>$title</a></h2>
	<code>$date</code>
	<table><tr>
		<td valign='top'><a href='$filename'>$img</a></td>
		<td valign='top'><p>$desc</p></td>
	</tr></table>
</div>
<br>
$cards"
done

echo "writing rss.xml..."
rss="<?xml version='1.0' encoding='UTF-8' ?>
<rss version='2.0'>
<channel>
<title>$sitename</title>
<link>$url</link>
<description>$sitedesc</description>
<lastBuildDate>$builddate</lastBuildDate>
$rssstack
</channel>
</rss>"
echo "$rss" > blog/rss.xml

echo "creating deck page..."
title=$( echo "$deck" | head -1 )
opening=$( echo "$deck" | tail -n +2 )
spechead=$( echo "$head" | sed "s/<!--TITLE-->/$title/" )
echo "$spechead<h1>$title</h1>$opening$cards$foot" > blog/index.html
