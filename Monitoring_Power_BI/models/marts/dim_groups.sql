SELECT DISTINCT
    members_displayName AS member_name,
    members_id AS member_id,
    members_userPrincipalName AS member_principal_name,
    CASE 
        WHEN members_userPrincipalName IS NOT NULL THEN 'User'
        ELSE 'App'
    END AS member_type,
    id AS group_id,
    displayName AS group_name

FROM {{ ref('lh_monitoring_powerBI', 'stg_pbi1_graph_groups') }}