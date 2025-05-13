DBCC SHOW_STATISTICS(Orders, OrderDate) easiest to use for manual inspection.
--but if you want to filter out and do some processing...

--should use the DMV sys.dm_db_stats_histogram

SELECT sh.* 
FROM sys.stats s
CROSS APPLY sys.dm_db_stats_histogram(s.object_id, s.stats_id) sh
WHERE s.object_id = object_id('dbo.Orders')
AND s.name = 'OrderDate'
ORDER BY sh.range_high_key
