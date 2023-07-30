-- Sessions, Orders, Conversion Rate on Holiday Season
SELECT 
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(COUNT(DISTINCT o.order_id) / COUNT(DISTINCT ws.website_session_id) * 100,
            1) AS conv_rate
FROM
    website_sessions ws
        LEFT JOIN
    orders o ON o.website_session_id = ws.website_session_id
WHERE
    YEAR(ws.created_at) = 2014
        AND (MONTH(ws.created_at) = 11
        OR MONTH(ws.created_at) = 12);

-- Sessions, Orders, Conversion Rate by Month
SELECT 
    YEAR(ws.created_at) AS 'year',
    MONTH(ws.created_at) AS 'month',
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(COUNT(DISTINCT o.order_id) / COUNT(DISTINCT ws.website_session_id) * 100,
            1) AS conv_rate
FROM
    website_sessions ws
        LEFT JOIN
    orders o ON o.website_session_id = ws.website_session_id
WHERE
    YEAR(ws.created_at) <= 2014
GROUP BY 1 , 2;

-- Sessions, Orders, Conversion Rate by UTM Source
SELECT 
    CASE
        WHEN
            utm_source IS NULL
                AND http_referer IN ('https://www.gsearch.com' , 'https://www.bsearch.com')
        THEN
            'organic_search'
        WHEN utm_campaign = 'nonbrand' THEN 'search_engine_nonbrand_ads'
        WHEN utm_campaign = 'brand' THEN 'search_engine_brand_ads'
        WHEN
            utm_source IS NULL
                AND http_referer IS NULL
        THEN
            'direct_type_in'
        WHEN utm_source = 'socialbook' THEN 'social_media_ads'
    END AS channel_group,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(COUNT(DISTINCT o.order_id) / COUNT(DISTINCT ws.website_session_id) * 100,
            1) AS conv_rate
FROM
    website_sessions ws
        LEFT JOIN
    orders o ON o.website_session_id = ws.website_session_id
WHERE
    YEAR(ws.created_at) = 2014
        AND (MONTH(ws.created_at) = 11
        OR MONTH(ws.created_at) = 12)
GROUP BY 1
ORDER BY 4 DESC;

-- Social Media Ads Profit by Month
create temporary table social_users
select 
user_id
from website_sessions
where utm_source = 'socialbook' AND MONTH(created_at) >= 8;

SELECT 
    MONTH(ws.created_at) AS mo,
    COUNT(ws.website_session_id) AS total_sessions,
    COUNT(CASE
        WHEN ws.is_repeat_session = 0 THEN ws.website_session_id
        ELSE NULL
    END) AS non_repeat,
    COUNT(CASE
        WHEN ws.is_repeat_session = 1 THEN ws.website_session_id
        ELSE NULL
    END) AS is_repeat,
    COUNT(order_id) AS total_orders,
    ROUND(SUM(o.price_usd) - SUM(o.cogs_usd)) - COUNT(DISTINCT ws.website_session_id) * 2 AS margin_from_ads
FROM
    website_sessions ws
        INNER JOIN
    social_users su ON ws.user_id = su.user_id
        LEFT JOIN
    orders o ON ws.website_session_id = o.website_session_id
WHERE
    YEAR(ws.created_at) = 2014
        AND MONTH(ws.created_at) >= 8
GROUP BY 1;

-- Sessions, Orders, Conversion Rate by Search Engine
SELECT 
    utm_source,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(COUNT(DISTINCT o.order_id) / COUNT(DISTINCT ws.website_session_id) * 100,
            1) AS conv_rate
FROM
    website_sessions ws
        LEFT JOIN
    orders o ON o.website_session_id = ws.website_session_id
WHERE
    utm_campaign = 'nonbrand'
        AND YEAR(ws.created_at) = 2014
        AND (MONTH(ws.created_at) = 11
        OR MONTH(ws.created_at) = 12)
GROUP BY 1;

-- Desktop Search Engine Ads Comparison: Sessions, Orders and Conversion Rate
SELECT 
    utm_content,
    utm_campaign,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(COUNT(DISTINCT o.order_id) / COUNT(DISTINCT ws.website_session_id) * 100,
            1) AS conv_rate
FROM
    website_sessions ws
        LEFT JOIN
    orders o ON o.website_session_id = ws.website_session_id
WHERE
    (YEAR(ws.created_at) = 2014
        AND (MONTH(ws.created_at) = 11
        OR MONTH(ws.created_at) = 12))
        AND utm_content IS NOT NULL
        AND utm_content <> 'social_ad_2'
        AND device_type = 'desktop'
GROUP BY utm_content , utm_campaign
ORDER BY conv_rate DESC;

-- Mobile Search Engine Ads Comparison: Sessions, Orders and Conversion Rate
SELECT 
    utm_content,
    utm_campaign,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(COUNT(DISTINCT o.order_id) / COUNT(DISTINCT ws.website_session_id) * 100,
            1) AS conv_rate
FROM
    website_sessions ws
        LEFT JOIN
    orders o ON o.website_session_id = ws.website_session_id
WHERE
    (YEAR(ws.created_at) = 2014
        AND (MONTH(ws.created_at) = 11
        OR MONTH(ws.created_at) = 12))
        AND utm_content IS NOT NULL
        AND utm_content <> 'social_ad_2'
        AND device_type = 'mobile'
GROUP BY utm_content , utm_campaign
ORDER BY conv_rate DESC;

-- Website Pages by Pageviews
SELECT 
    pageview_url, COUNT(DISTINCT website_pageview_id) AS pvs
FROM
    website_pageviews
WHERE
    YEAR(created_at) = 2014
        AND (MONTH(created_at) = 11
        OR MONTH(created_at) = 12)
GROUP BY 1
ORDER BY 2 DESC;

-- Bounced Sessions Percentage by Landing Page
CREATE TEMPORARY TABLE first_test_pageviews
SELECT
ws.website_session_id,
MIN(wp.website_pageview_id) AS min_pageview_id
FROM website_pageviews wp
INNER JOIN website_sessions ws ON ws.website_session_id = wp.website_session_id
AND YEAR(ws.created_at) = 2014 
AND (MONTH(ws.created_at) = 11 OR MONTH(ws.created_at) = 12)
GROUP BY 1;

CREATE TEMPORARY TABLE nonbrand_test_sessions_w_landing_page
SELECT
f.website_session_id,
wp.pageview_url AS landing_page
FROM first_test_pageviews f
LEFT JOIN website_pageviews wp ON wp.website_pageview_id = f.min_pageview_id
WHERE wp.pageview_url IN ('/home', '/lander-2', '/lander-3', '/lander-5');

CREATE TEMPORARY TABLE nonbrand_test_bounced_sessions
SELECT
ns.website_session_id,
ns.landing_page,
COUNT(wp.website_pageview_id) AS count_of_pages_viewed
FROM nonbrand_test_sessions_w_landing_page ns
LEFT JOIN website_pageviews wp ON wp.website_session_id = ns.website_session_id
GROUP BY 1,2
HAVING COUNT(wp.website_pageview_id) = 1;

SELECT 
    ns.landing_page,
    COUNT(DISTINCT ns.website_session_id) AS sessions,
    COUNT(DISTINCT nb.website_session_id) AS bounced_sessions,
    ROUND(COUNT(DISTINCT nb.website_session_id) / COUNT(DISTINCT ns.website_session_id) * 100,
            1) AS bounced_session_to_sessions_pct
FROM
    nonbrand_test_sessions_w_landing_page ns
        LEFT JOIN
    nonbrand_test_bounced_sessions nb ON nb.website_session_id = ns.website_session_id
GROUP BY 1
ORDER BY 4 DESC;

-- Website Conversion Funnel from Products Catalog Page
CREATE TEMPORARY TABLE session_level_made_it_flags
SELECT
website_session_id,
MAX(productCatalog_page) AS productCatalog_made_it,
MAX(specificProduct_page) AS specificProduct_made_it,
MAX(cart_page) AS cart_made_it,
MAX(shipping_page) AS shipping_made_it,
MAX(billing_page) AS billing_made_it,
MAX(thankyou_page) AS thankyou_made_it
FROM (
SELECT
ws.website_session_id,
CASE WHEN pageview_url IN ('/home', '/lander-2', '/lander-3', '/lander-5') THEN 1 ELSE 0 END AS landing_page,
CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS productCatalog_page,
CASE WHEN pageview_url IN ('/the-original-mr-fuzzy', '/the-birthday-sugar-panda', '/the-forever-love-bear', '/the-hudson-river-mini-bear') THEN 1 ELSE 0 END AS specificProduct_page,
CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
CASE WHEN pageview_url = '/billing-2' THEN 1 ELSE 0 END AS billing_page,
CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM website_sessions ws
LEFT JOIN website_pageviews wp ON wp.website_session_id = ws.website_session_id
AND YEAR(ws.created_at) = 2014
AND (MONTH(ws.created_at) = 11 OR MONTH(ws.created_at) = 12)
ORDER BY
ws.website_session_id,
wp.created_at
) AS pageview_level
GROUP BY website_session_id;

SELECT 
    ROUND(COUNT(DISTINCT CASE
                    WHEN specificProduct_made_it = 1 THEN website_session_id
                    ELSE NULL
                END) / COUNT(DISTINCT CASE
                    WHEN productCatalog_made_it = 1 THEN website_session_id
                    ELSE NULL
                END) * 100,
            1) AS productsCatalog_to_specificProduct_pct,
    ROUND(COUNT(DISTINCT CASE
                    WHEN cart_made_it = 1 THEN website_session_id
                    ELSE NULL
                END) / COUNT(DISTINCT CASE
                    WHEN specificProduct_made_it = 1 THEN website_session_id
                    ELSE NULL
                END) * 100,
            1) AS specificProduct_to_cart_pct,
    ROUND(COUNT(DISTINCT CASE
                    WHEN shipping_made_it = 1 THEN website_session_id
                    ELSE NULL
                END) / COUNT(DISTINCT CASE
                    WHEN cart_made_it = 1 THEN website_session_id
                    ELSE NULL
                END) * 100,
            1) AS cart_to_shipping_pct,
    ROUND(COUNT(DISTINCT CASE
                    WHEN billing_made_it = 1 THEN website_session_id
                    ELSE NULL
                END) / COUNT(DISTINCT CASE
                    WHEN shipping_made_it = 1 THEN website_session_id
                    ELSE NULL
                END) * 100,
            1) AS shipping_to_billing_pct,
    ROUND(COUNT(DISTINCT CASE
                    WHEN thankyou_made_it = 1 THEN website_session_id
                    ELSE NULL
                END) / COUNT(DISTINCT CASE
                    WHEN billing_made_it = 1 THEN website_session_id
                    ELSE NULL
                END) * 100,
            1) AS billing_to_thankyou_pct
FROM
    session_level_made_it_flags;

-- Conversion Funnel of Each Product
CREATE TEMPORARY TABLE sessions_seeing_product_pages
SELECT
website_session_id,
website_pageview_id,
pageview_url AS product_page_seen
FROM website_pageviews
WHERE YEAR(created_at) = 2014 AND (MONTH(created_at) = 11 OR MONTH(created_at) = 12)
AND pageview_url IN ('/the-original-mr-fuzzy', '/the-forever-love-bear', '/the-birthday-sugar-panda', '/the-hudson-river-mini-bear');

CREATE TEMPORARY TABLE session_product_level_made_it_flags
SELECT
    website_session_id,
    CASE
        WHEN product_page_seen = '/the-original-mr-fuzzy' THEN 'mr fuzzy'
        WHEN product_page_seen = '/the-forever-love-bear' THEN 'forever love bear'
        WHEN product_page_seen = '/the-birthday-sugar-panda' THEN 'birthday sugar panda'
        WHEN product_page_seen = '/the-hudson-river-mini-bear' THEN 'hudson river mini bear'
    END AS product_seen,
    MAX(cart_page) AS cart_made_it,
    MAX(shipping_page) AS shipping_made_it,
    MAX(billing_page) AS billing_made_it,
    MAX(thankyou_page) AS thankyou_made_it
FROM
    (
        SELECT 
            sp.website_session_id,
            sp.product_page_seen,
            CASE
                WHEN wp.pageview_url = '/cart' THEN 1
                ELSE 0
            END AS cart_page,
            CASE
                WHEN wp.pageview_url = '/shipping' THEN 1
                ELSE 0
            END AS shipping_page,
            CASE
                WHEN wp.pageview_url IN ('/billing', '/billing-2') THEN 1
                ELSE 0
            END AS billing_page,
            CASE
                WHEN wp.pageview_url = '/thank-you-for-your-order' THEN 1
                ELSE 0
            END AS thankyou_page
        FROM
            sessions_seeing_product_pages sp
            LEFT JOIN website_pageviews wp ON wp.website_session_id = sp.website_session_id
            AND wp.website_pageview_id > sp.website_pageview_id
        ORDER BY
            sp.website_session_id,
            wp.created_at
    ) AS pageview_level
GROUP BY
    1,
    2;

SELECT 
    product_seen,
    ROUND(COUNT(DISTINCT CASE
                    WHEN cart_made_it = 1 THEN website_session_id
                    ELSE NULL
                END) / COUNT(DISTINCT website_session_id) * 100,
            1) AS product_to_cart_pct,
    ROUND(COUNT(DISTINCT CASE
                    WHEN shipping_made_it = 1 THEN website_session_id
                    ELSE NULL
                END) / COUNT(DISTINCT CASE
                    WHEN cart_made_it = 1 THEN website_session_id
                    ELSE NULL
                END) * 100,
            1) AS cart_to_shipping_pct,
    ROUND(COUNT(DISTINCT CASE
                    WHEN billing_made_it = 1 THEN website_session_id
                    ELSE NULL
                END) / COUNT(DISTINCT CASE
                    WHEN shipping_made_it = 1 THEN website_session_id
                    ELSE NULL
                END) * 100,
            1) AS shipping_to_billing_pct,
    ROUND(COUNT(DISTINCT CASE
                    WHEN thankyou_made_it = 1 THEN website_session_id
                    ELSE NULL
                END) / COUNT(DISTINCT CASE
                    WHEN billing_made_it = 1 THEN website_session_id
                    ELSE NULL
                END) * 100,
            1) AS billing_to_thankyou_pct
FROM
    session_product_level_made_it_flags
GROUP BY 1
ORDER BY 1 DESC;

-- Product Selling Price and Profit Comparison
SELECT DISTINCT
    p.product_name,
    oi.price_usd,
    oi.cogs_usd,
    oi.price_usd - oi.cogs_usd AS margin
FROM
    products p
        LEFT JOIN
    order_items oi ON oi.product_id = p.product_id
ORDER BY 2 DESC;

-- Product Cross-Selling Analysis
SELECT 
    o.primary_product_id,
    COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT CASE
            WHEN oi.product_id = 1 THEN o.order_id
            ELSE NULL
        END) AS x_sell_prod1,
    COUNT(DISTINCT CASE
            WHEN oi.product_id = 2 THEN o.order_id
            ELSE NULL
        END) AS x_sell_prod2,
    COUNT(DISTINCT CASE
            WHEN oi.product_id = 3 THEN o.order_id
            ELSE NULL
        END) AS x_sell_prod3,
    COUNT(DISTINCT CASE
            WHEN oi.product_id = 3 THEN o.order_id
            ELSE NULL
        END) AS x_sell_prod4,
    ROUND(COUNT(DISTINCT CASE
                    WHEN oi.product_id = 1 THEN o.order_id
                    ELSE NULL
                END) / COUNT(DISTINCT o.order_id) * 100,
            2) AS x_sell_prod1_rt,
    ROUND(COUNT(DISTINCT CASE
                    WHEN oi.product_id = 2 THEN o.order_id
                    ELSE NULL
                END) / COUNT(DISTINCT o.order_id) * 100,
            2) AS x_sell_prod2_rt,
    ROUND(COUNT(DISTINCT CASE
                    WHEN oi.product_id = 3 THEN o.order_id
                    ELSE NULL
                END) / COUNT(DISTINCT o.order_id) * 100,
            2) AS x_sell_prod3_rt,
    ROUND(COUNT(DISTINCT CASE
                    WHEN oi.product_id = 4 THEN o.order_id
                    ELSE NULL
                END) / COUNT(DISTINCT o.order_id) * 100,
            2) AS x_sell_prod4_rt
FROM
    orders o
        LEFT JOIN
    order_items oi ON oi.order_id = o.order_id
        AND oi.is_primary_item = 0
WHERE
    YEAR(o.created_at) = '2014'
        AND (MONTH(o.created_at) = 11
        OR MONTH(o.created_at) = 12)
GROUP BY 1;
