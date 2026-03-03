SELECT DISTINCT
    category,
    description,
    object_name,
    object_type,
    rule_name,
    severity,
    CASE 
        WHEN severity = 'ℹ️' THEN 'Info'
        WHEN severity = '⚠️' THEN 'Warning'
        WHEN severity = '❌' THEN 'Error'
        ELSE 'Unknown'
    END AS severity_text,
    url,
    dataset_id,
    workspace_id,
    ingestion_date
FROM {{ ref('lh_monitoring_powerBI', 'stg_best_practice_analyzer') }}