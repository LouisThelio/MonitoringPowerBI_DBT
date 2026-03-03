WITH ranked AS (
    SELECT 
        state,
        id as workspace_id,
        isOnDedicatedCapacity as is_dedicated_capacity,
        type,
        name as workspace,
        description,
        capacityId as capacity_id,
        ROW_NUMBER() OVER (
            PARTITION BY id
            ORDER BY 
                artifact_createdDate DESC  
        ) AS rn
    FROM {{ ref('lh_monitoring_powerBI', 'ref_pbi1_catalog_scan_workspaces') }}
)

SELECT 
    state,
    workspace_id,
    is_dedicated_capacity,
    type,
    workspace,
    description,
    capacity_id
FROM ranked
WHERE rn = 1;