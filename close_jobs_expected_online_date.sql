SELECT 
    job_openid,
    topup_type,
    expected_online_date,
    process_type,
    return_count,
    follow_date,
    distribute_date,
    topup
FROM
    (SELECT 
        jopopen.id AS job_openid,
            product.brand,
            CASE
                WHEN service.parentjob_id != 0 THEN parent_service.date_pay1
                ELSE service.date_pay1
            END AS pay1_date,
            jopopen.TOPUP_TYPE,
            jopopen.expect_online_date AS expected_online_date,
            jopopen.PROCESS_TYPE,
            CASE
                WHEN google_return_newjobs_history.return_count IS NULL THEN 0
                ELSE google_return_newjobs_history.return_count
            END AS return_count,
            customerpending.follow_date,
            customeradwords.CreateDate AS distribute_date,
            case
				when service2.prepaid_first is null then 0
                else service2.prepaid_first
			end as topup
    FROM
        theiconwebcrm.jopopen
    JOIN theiconwebcrm.productlist ON jopopen.id = productlist.id
    JOIN theiconwebcrm.product ON productlist.id_product = product.id_product
    LEFT JOIN (SELECT 
        id_jobopen AS job_openid, COUNT(*) AS return_count
    FROM
        itopplus_erp.google_return_newjobs_history
    GROUP BY id_jobopen) AS google_return_newjobs_history ON jopopen.id = google_return_newjobs_history.job_openid
    LEFT JOIN (SELECT 
        *
    FROM
        adwords.customerpending
    WHERE
        customerpending.id IN (SELECT 
                MAX(id)
            FROM
                adwords.customerpending
            GROUP BY JobOpen_ID)
            AND YEAR(follow_date) >= YEAR(CURDATE()) - 2) customerpending ON customerpending.jobopen_id = jopopen.id
    LEFT JOIN adwords.customerhistory ON jopopen.id = customerhistory.JobOpen_ID
    LEFT JOIN adwords.customeradwords ON customeradwords.id = customerhistory.CustomerAW_ID
    JOIN theiconwebcrm.service ON service.id = jopopen.id
    LEFT JOIN theiconwebcrm.service parent_service ON service.parentjob_id = parent_service.id
    left join theiconwebcrm.service2 on service2.id = service.id
    WHERE
        product.team_owner = 'GOOGLE' AND service.status1 = 1) a
WHERE
    pay1_date >= '2019-01-01'