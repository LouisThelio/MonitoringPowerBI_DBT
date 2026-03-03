WITH ranked AS (
    SELECT
        id AS workspace_id,
        artifact_id AS report_id,
        artifact_name AS report,
        artifact_datasetId AS dataset_id,
        artifact_createdDate AS created_on,
        artifact_modifiedDateTime AS modified_on,
        artifact_modifiedBy AS modified_by,
        name AS report_workspace,
        artifact_appId AS app_id,
        artifact_type AS type,
        artifact_endorsementDetails_endorsement AS endorsement,
        artifact_endorsementDetails_certifiedBy AS certified_by,
        artifact_sensitivitylabel as sensitivity_label,

        ROW_NUMBER() OVER (
            PARTITION BY artifact_id
            ORDER BY 
                CASE 
                    WHEN artifact_modifiedDateTime IS NULL THEN 1 
                    ELSE 0 
                END,               -- place les NULLS en bas
                artifact_modifiedDateTime DESC
        ) AS rn
    FROM {{ ref('lh_monitoring_powerBI', 'ref_pbi1_catalog_scan_workspaces') }}
    WHERE artifactType = 'reports'
)

SELECT
    workspace_id,
    report_id,
    report,
    dataset_id,
    created_on,
    modified_on,
    modified_by,
    report_workspace,
    app_id,
    type,
    endorsement,
    certified_by,
    sensitivity_label
FROM ranked
WHERE rn = 1;