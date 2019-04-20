#!/bin/bash
#
# script to generate primary key constraints from unique indexes
# parameters: databasename and issuereference
# outputs: one script file per table, named something like 20190420-mytablename-createpkconstraint.sql

dbname="$1"
ticketno="$2"
dt=$( date +%Y%m%d )

for i in $( dbaccess "$dbname" <<! 2> /dev/null | awk '{print $2}'
	select tabname from systables
	where tabid > 99 -- exclude system catalogs
	and tabtype = "T" -- exclude views (and synonyms?)
	and tabid not in ( -- exclude tables that already have a primary key
		select tabid from sysconstraints
		where constrtype = "P"
	)
	and tabid in ( -- exclude tables that have no unique index
		select tabid from sysindexes
	where idxtype = "U"
	)
	order by tabname;
!
)
do
	fn="$dt-$i-createpkconstraint.sql"
	echo "--# description: this script creates a primary key constraint from a unique index
--# table: $i
--# author: $USER
--# date: $( date +%Y-%m-%d )
--# issue reference # : $ticketno
--# 

" > "${fn}"

	echo "ALTER TABLE $i ADD CONSTRAINT PRIMARY KEY (" >> "${fn}"

	pcol="X"

	for j in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16
	do

		col=$( dbaccess "$dbname" <<! 2> /dev/null | grep -v "^$" | awk '{print $2}'
		select colname
		from syscolumns
		where tabid in (
			select tabid from systables where tabname = "${i}"
			)
		and colno in (
			select part${j}
			from sysindexes
			where idxtype = "U"
			and tabid = syscolumns.tabid
			)
		;
!
)
		if [ "x$col" != "x" ] && [ "x$pcol" != "xX" ]
		then
			echo "$pcol," >> "${fn}"
		else
			if [ "x$pcol" != "x" ] && [ "x$pcol" != "xX" ]
			then
				echo "$pcol" >> "${fn}"
			fi
		fi
		pcol=$col
	done

	echo ") CONSTRAINT pk_$i;" >> "${fn}"

done
