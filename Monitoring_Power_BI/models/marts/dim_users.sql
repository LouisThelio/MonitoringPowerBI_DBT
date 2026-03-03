SELECT DISTINCT
    u.emailAddress as user_id,
    u.displayName as [user],
    COALESCE(
        SUBSTRING(u.emailAddress, CHARINDEX('@', u.emailAddress) + 1, LEN(u.emailAddress)), 
        'Unknown'
    ) AS tenant,
    CAST(JSON_VALUE(l.value, '$.skuId') AS VARCHAR(200)) as sku_id,
    s.skuPartNumber as licence

FROM {{ ref('lh_monitoring_powerBI', 'stg_pbi1_users') }} AS u

CROSS APPLY OPENJSON(u.AssignedLicenses) as l
LEFT JOIN {{ source('lh_monitoring_powerBI', 'stg_pbi1_graph_subscribedskus') }} as s ON 
    CAST(JSON_VALUE(l.value, '$.skuId') AS VARCHAR(200)) = s.skuId
WHERE u.emailAddress LIKE '%@%'
AND CAST(JSON_VALUE(l.value, '$.skuId') AS VARCHAR(200)) is not null;