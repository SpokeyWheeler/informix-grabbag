#!/bin/bash

# script to generate SQL to explicitly name database objects that haven't been explicitly named
# parameters: databasename and issuereference
# outputs: one script file per table, named something like 20190422-mytablename-renameindex-202_101.sql
# or 20190422-mytablename-renameconstraint-u502_105.sql

dbname="$1"
ticketno="$2"
dt=$( date +%Y%m%d )
idxno=1

for oname in $( dbaccess $dbname <<! 2> /dev/null | awk '{print $2}'
select idxname from sysindexes where idxname matches " *"
and tabid > 99
order by 1;
!
)
do
	tname=$( dbaccess $dbname <<! 2> /dev/null | grep -v "^$" | awk '{print $2}'
select tabname from systables where tabid in (
select tabid from sysindexes where idxname matches "*${oname}"
);
!
)

echo ">>>>$tname<<<<"
	fn="${dt}-${tname}-renameindex-${oname}.sql"
	> "${fn}"
	echo "--# description: this script renames an index that has a default name to a more useful one
--# table: $tname	index: $oname
--# author: $USER
--# date: $( date +%Y-%m-%d )
--# issue reference # : $ticketno
--# 


RENAME INDEX $oname TO i${tname}${idxno};
" > "${fn}"
	idxno=$(( idxno + 1 ))

done

# select constrname from sysconstraints where constrname matches "*[0-9]_[0-9]*"
# order by 1;
