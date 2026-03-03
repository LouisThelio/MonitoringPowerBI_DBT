WITH ranked AS (
    SELECT
        artifact_name AS dataset,
        artifact_createdBy AS configured_by,
        id AS workspace_id,
        artifact_id AS dataset_id,
        artifact_targetStorageMode AS target_storage,
        artifact_createdDate AS created_on,
        artifact_contentProviderType AS content_provider_type,
        NULLIF(TRIM(artifact_description), '') AS description,
        artifact_endorsementDetails_endorsement AS endorsement,
        artifact_endorsementDetails_certifiedBy AS certified_by,
        artifact_schemaissues AS schema_issues,
        artifact_sensitivitylabel AS sensitivity_label,
        artifact_isEffectiveIdentityRequired AS is_effectiveidentity_required,
        artifact_isEffectiveIdentityRolesRequired AS is_effectiveidentity_roles_required,
        ROW_NUMBER() OVER (
            PARTITION BY artifact_id
            ORDER BY 
                CASE WHEN artifact_createdBy IS NULL THEN 1 ELSE 0 END,
                artifact_createdDate DESC  -- optionnel : garde la plus récente si plusieurs non-null
        ) AS rn
    FROM {{ ref('lh_monitoring_powerBI', 'ref_pbi1_catalog_scan_workspaces') }}
    WHERE artifactType = 'datasets'
)

SELECT
    dataset,
    configured_by,
    workspace_id,
    dataset_id,
    target_storage,
    created_on,
    content_provider_type,
    description,
    endorsement,
    certified_by,
    schema_issues,
    sensitivity_label,
    is_effectiveidentity_required,
    is_effectiveidentity_roles_required
FROM ranked
WHERE rn = 1;
