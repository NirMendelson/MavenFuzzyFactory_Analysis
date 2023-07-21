# MavenFuzzyFactory Analysis
## Business problem
The CEO has requested a thorough analysis of the sales data from the holiday season last year (November-December of 2014) to provide recommendations on how to boost sales in the upcoming holiday season. The focus is primarily on increasing the conversion rate while also uncovering additional valuable insights that can contribute to increased sales.

## The Database
The database contains Maven Fuzzy Factory's sales data for their stuffed animal toys from March 2012 to March 2015. The company offers four products, namely:
1.	The Original Mr. Fuzzy (launched on the 19.03.2012)
2.	The Forever Love Bear (launched on the 06.01.2013)
3.	The Birthday Sugar Panda (launched on the 12.12.2013)
4.	The Hudson River Mini Bear (launched on the 05.02.2014)
The company exclusively sells these products through their website. The database comprises six tables: order_item_refund, order_item, orders, products, website_pageviews, and website_sessions.

![Maven Fuzzy Factory Entity Relationship Diagram](Pictures/Entity_Relationship_Diagram.jpg)

## Data Analysis
Let's begin by examining the key metrics from last November-December, including the number of website sessions, number of orders, and conversion rate, while comparing them with previous months.

![Sessions, Orders and Conversion Rate](/Pictures/Sessions_Orders_Conv_Rate.png)

Next, we'll delve deeper into factors affecting the conversion rate and identify insights that can help increase it.

### UTM Source
Maven Fuzzy Factory uses five different UTM sources to track their website traffic:
1.	Organic search
2.	Brand ads on search engines
3.	Nonbrand ads on search engines
4.	Direct type-in
5.	Social media ads

We'll analyze the conversion rate for each UTM source and determine which ones perform the best.

![Sessions, Orders and Conversion Rate](/Pictures/C.png)
