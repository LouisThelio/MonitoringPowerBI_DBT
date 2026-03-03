WITH changed_type AS 
(
    SELECT 
        c.id AS workspace_id,
        c.artifact_users_AccessRight AS access_right,
        u.displayName AS [identity],

        CASE
            WHEN u.identifier IS NOT NULL THEN u.identifier 
            WHEN u.emailAddress IS NOT NULL THEN u.emailAddress
            ELSE c.artifact_users_graphId
        END AS identity_id,
        
        CASE WHEN c.artifact_users_graphId IS NOT NULL THEN c.artifact_users_graphId 
            ELSE u.identifier 
        END AS identity_graph_id,
        
        CASE WHEN u.principalType IS NOT NULL THEN u.principalType
            ELSE 'None'
        END AS identity_type,
        
        c.artifact_id AS object_id,
        c.artifact_type AS object_type
        
    FROM {{ ref('lh_monitoring_powerBI', 'ref_pbi1_catalog_scan_workspaces') }} c
    JOIN {{ ref('lh_monitoring_powerBI', 'stg_pbi1_users') }} u
    ON c.artifact_users_graphId = u.graphId
    WHERE c.artifact_type IN ('reports','dashboards','dataflows','datamarts','datasets')
    AND c.artifact_users_AccessRight IS NOT NULL
), 

workspace_user AS
(
    SELECT DISTINCT
        u.id AS workspace_id,
        CAST(JSON_VALUE(e.value, '$.groupUserAccessRight') AS VARCHAR(200)) AS access_right,
        CAST(JSON_VALUE(e.value, '$.displayName') AS VARCHAR(200)) AS [identity],

        CASE
            WHEN CAST(JSON_VALUE(e.value, '$.emailAddress') AS VARCHAR(200)) IS NOT NULL THEN CAST(JSON_VALUE(e.value, '$.emailAddress') AS VARCHAR(200))
            ELSE CAST(JSON_VALUE(e.value, '$.graphId') AS VARCHAR(200))
        END AS identity_id,

        CAST(JSON_VALUE(e.value, '$.graphId') AS VARCHAR(200)) AS identity_graph_id,
        CAST(JSON_VALUE(e.value, '$.principalType') AS VARCHAR(200)) AS identity_type,
        u.id AS object_id,
        'Workspace' AS object_type

    FROM {{ ref('lh_monitoring_powerBI', 'ref_pbi1_catalog_scan_workspaces') }} u
    CROSS APPLY OPENJSON(u.users) AS e
), 

all_users AS 
(
    SELECT *
    FROM changed_type
    UNION ALL
    SELECT *
    FROM workspace_user
), 

group_expend AS
(
    SELECT 
        c.workspace_id AS workspace_id,
        c.access_right AS access_right,
        g.members_displayName AS [identity],
        g.id AS group_id,
        g.displayName AS group_name,

        CASE 
            WHEN g.members_userPrincipalName IS NOT NULL THEN g.members_userPrincipalName
                ELSE g.members_id
        END as identity_id,

        CASE 
            WHEN g.members_userPrincipalName IS NOT NULL THEN g.members_id
            WHEN g.members_appId IS NOT NULL THEN g.members_appId
                ELSE g.members_id
        END as identity_graph_id,

        CASE 
            WHEN g.members_userPrincipalName IS NOT NULL THEN 'User'
            ELSE 'App'
        END AS identity_type,
        
        c.object_id AS object_id,
        c.object_type

    FROM all_users c
    JOIN {{ ref('lh_monitoring_powerBI', 'stg_pbi1_graph_groups') }} g
    ON c.identity_graph_id = g.id

    WHERE identity_type = 'Group'
),

catalog_permission AS 
(
    SELECT workspace_id, access_right, [identity], identity_id, identity_graph_id, identity_type, object_id, object_type, 'indirect' AS link, group_id, group_name 
    FROM group_expend

    UNION ALL

    SELECT *, 'direct' AS link, NULL AS group_id, NULL AS group_name
    FROM all_users
)

SELECT *
FROM catalog_permission;