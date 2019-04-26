--# SQL to identify database objects that haven't been explicitly named
--# author: spokey
--# date: 2019-04-22

select tabid, idxtype, idxname from sysindexes where idxname matches " *"
order by 1, 2, 3;
select tabid, constrtype, constrname from sysconstraints where constrname matches "*[0-9]_[0-9]*"
order by 1, 2, 3;
