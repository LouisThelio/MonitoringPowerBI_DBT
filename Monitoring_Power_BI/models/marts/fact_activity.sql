SELECT DISTINCT
    a.Operation AS operation,
    a.UserId AS user_id,
    a.UserAgent AS user_agent,
    a.ItemName AS item_name,
    a.WorkspaceId AS workspace_id,
    a.ReportId AS report_id,
    a.DashboardId AS dashboard_id,
    CAST(a.CreationTime AS DATE) AS [date],
    a.DatasetId as dataset_id,

    CASE
        WHEN a.UserAgent IS NULL THEN 'Unknown'
        WHEN LOWER(a.UserAgent) LIKE '%iphone%' THEN 'iPhone'
        WHEN LOWER(a.UserAgent) LIKE '%android%' THEN 'Android'
        WHEN LOWER(a.UserAgent) LIKE '%os x%' THEN 'OS X'
        WHEN LOWER(a.UserAgent) LIKE '%windows%' THEN 'Windows'
        ELSE 'Other'
    END AS operative_system,

    -- Conversion de l'heure HHMM en entier (sans FORMAT)
    CAST(
        RIGHT('00' + CAST(DATEPART(HOUR, a.CreationTime) AS VARCHAR(2)), 2) +
        RIGHT('00' + CAST(DATEPART(MINUTE, a.CreationTime) AS VARCHAR(2)), 2)
        AS INT
    ) AS time_id,

    a.WorkSpaceName AS workspace,
    a.DatasetName AS dataset,
    a.ReportName AS report,
    a.DashboardName AS dashboard,
    a.DistributionMethod AS distribution_method,
    a.AppName AS app,
    a.ClientIP AS client_ip,
    a.CapacityId AS capacity_id,
    a.CapacityName AS capacity,
    a.ReportType AS report_type,
    a.DataflowName AS dataflow,

    -- Heure au format HH:mm:ss sans FORMAT()
    RIGHT('00' + CAST(DATEPART(HOUR, a.CreationTime) AS VARCHAR(2)), 2) + ':' +
    RIGHT('00' + CAST(DATEPART(MINUTE, a.CreationTime) AS VARCHAR(2)), 2) + ':' +
    RIGHT('00' + CAST(DATEPART(SECOND, a.CreationTime) AS VARCHAR(2)), 2)
    AS [time],

    CASE
        WHEN LOWER(a.WorkSpaceName) LIKE '%personalworkspace%' THEN 'Personal'
        WHEN a.WorkSpaceName IS NOT NULL THEN 'Workspace'
        ELSE NULL
    END AS workspace_type,

    COALESCE(
        SUBSTRING(u.emailAddress, CHARINDEX('@', u.emailAddress) + 1, LEN(u.emailAddress)),
        'Unknown'
    ) AS user_tenant,

    a.SharingAction AS sharing_action,
    COALESCE(a.ConsumptionMethod, 'Unknown') AS consumption_method_original,
    a.ingestion_date AS file_date
FROM {{ ref('lh_monitoring_powerBI', 'stg_pbi1_activity') }} AS a
LEFT JOIN {{ ref('lh_monitoring_powerBI', 'stg_pbi1_users') }} AS u
    ON a.UserId = u.identifier;
