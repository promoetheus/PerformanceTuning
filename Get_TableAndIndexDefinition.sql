USE Northwind
GO

DECLARE @tbl nvarchar(265)
SELECT @tbl = 'Orders'

SELECT o.name, i.index_id, i.name, i.type_desc,
       substring(ikey.cols, 3, len(ikey.cols)) AS key_cols,
       substring(inc.cols, 3, len(inc.cols)) AS included_cols,
       stats_date(o.object_id, i.index_id) AS stats_date,
       i.filter_definition
FROM   sys.objects o
JOIN   sys.indexes i ON i.object_id = o.object_id
OUTER  APPLY (SELECT ', ' + c.name +
                     CASE ic.is_descending_key
                          WHEN 1 THEN ' DESC'
                          ELSE ''
                     END
              FROM   sys.index_columns ic
              JOIN   sys.columns c ON ic.object_id = c.object_id
                                  AND ic.column_id = c.column_id
              WHERE  ic.object_id = i.object_id
                AND  ic.index_id  = i.index_id
                AND  ic.is_included_column = 0
              ORDER  BY ic.key_ordinal
              FOR XML PATH('')) AS ikey(cols)
OUTER  APPLY (SELECT ', ' + c.name
              FROM   sys.index_columns ic
              JOIN   sys.columns c ON ic.object_id = c.object_id
                                  AND ic.column_id = c.column_id
              WHERE  ic.object_id = i.object_id
                AND  ic.index_id  = i.index_id
                AND  ic.is_included_column = 1
              ORDER  BY ic.index_column_id
              FOR XML PATH('')) AS inc(cols)
WHERE  o.name = @tbl
ORDER  BY o.name, i.index_id
