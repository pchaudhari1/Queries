Month-over-month

SELECT DATE_FORMAT(host_since, '%Y-%m') as yearmonth, neighbourhood, 
COUNT(DISTINCT host_id) as countid,
FORMAT(100 * (COUNT(DISTINCT host_id) - LAG(COUNT(id), 1) OVER (PARTITION BY neighbourhood
ORDER BY date_format(host_since, '%Y-%m'))) / LAG(COUNT(DISTINCT host_id), 1) OVER 
(PARTITION BY neighbourhood ORDER BY DATE_FORMAT(host_since, '%Y-%m')), 2)
AS growth
FROM listings
WHERE host_since BETWEEN '2018-06-01' AND '2018-08-31'
AND neighbourhood <> ''
GROUP BY 1,2
ORDER BY 1
;

Except

CREATE TABLE if not exists Listings1 AS
SELECT * from listings
EXCEPT
SELECT l.*
FROM listings l
JOIN reviews r ON l.id = r.listing_id
WHERE r.date BETWEEN '2018-01-01' and '2018-12-31'
;

SELECT COUNT(id), host_response_time
FROM LISTINGS1
GROUP BY 2
ORDER BY 1 DESC
;

SELECT COUNT(id), neighbourhood,
host_identity_verified,room_type
FROM listings 
WHERE neighbourhood <> ''
AND room_type = 'Private room'
GROUP BY 2,3,4
ORDER BY 1 DESC
LIMIT 2;




PART ONE | Analyzing Dates

Accounts
account_id	created_date	campaign_id
		

Campaigns
campaign_id	created_date	revenue	Product
			



1)	[Write a query] For each campaign without an account, what was the number of campaigns created in December 2018?
2)	[Write a query] For each campaign with an account, what is the number of days between a campaign created and an account created?
3)	[Open Answer] Provide at least 3 potential data quality issues from your answer to #2 that would warrant further investigation.



1 
Select count(campaign_id)
From campaigns
Where created_date between ‘12-01-2018’ and ’12-31-2018’
;

2
Select datediff(days, c.created_date , a.created_date) as num_days
From campaigns c 
Join account a
On c.campaign_id = a.campaign_id;

3
a.	If the two date columns do not have same data type.
b.	The date format is different for both columns
c.	Duplicate records may be present.














PART TWO | Analyzing Revenue

Revenue
account_id	revenue_2017	revenue_2018
1111	1000	1300
1112	500	800
1113	750	1200
1114	3200	3500
…	 	 
 
Team							    
account_id	team	region
1111	Tech	NAMER-US
1112	Services	NAMER-CA
1113	Government	LATAM
1114	Education	NAMER-CA
…	 	 

1)	[Write a query] What is the 2017 to 2018 year-over-year growth rate by account? 
2)	[Write a query] We suspect the “team” table may have a data quality issue. Write a query that identifies the top 5 teams by 2018 revenue that are mapped to more than one region and list the # of regions in the same row.
3)	[Write a query] Show two columns in the output where one is the total 2018 revenue from the “Tech” Team “NAMER-US” accounts and another is the total 2018 revenue from “Tech” Team “NAMER-CA” accounts.

1
Select account_id, ((revenue_2018 – revenue_2017)/revenue_2018) * 100 as growth
From revenue;

2
Select t.team, count(t.region), r.revenue_2018
From team t
Join
Revenue r
On t.account_id = r.account_id
Group by t.team
Order by r.revenue_2018
limit 5
;


3
Select sum(r.revenue_2018) as rev_namerus, sum(r.revenue_2018) as rev_namerca
From revenue r
Join team t
On
r.account_id = t.account_id
where t.team = ‘namer_us’ and ‘Namer_ca’
;


select a1.campaign ,a2.name  as username,a1.device_id,a3.total_amt
from ((SELECT campaign,ud.device_id,ud.userid  from attribution a , user_device ud where a.device_id =ud.device_id 
group by a.campaign ,ud.device_id,ud.userid)  a1 
inner join 
(select id,name from [User] u group by id,name) a2 
on a1.userid = a2.id )
inner join (select  s.userid , SUM(s.amount) as total_amt from sale s ,  user_device ud where ud.userid =s.userid 
group by s.userid ) a3
on a2.id = a3.userid
order by 1,2,3
;

1. SQL 
•	On a typical day, what share of registrants are coming from each acquisition 
source? 
select u.reg_device,round(cast(Total as Float)/sum(Frequency),2) as 'Average Share of Registrants' 
from (select reg_device,SUM(1) as 'Total' from Users group by reg_device) u inner join (select reg_device ,convert(varchar(12),reg_ts,101) as 'reg_date' ,1 as 'Frequency' from Users group by reg_device,convert(varchar(12),reg_ts,101)) t on u.reg_device=t.reg_device
group by u.reg_device,u.Total , t.Frequency
; 
•	What is the typical Active Lifetime of a user by device, where Active Lifetime is defined as time from registration to last activity? 
select u.user_id,u.reg_device,DATEDIFF(MINUTE,u.reg_ts,max(a.actvy_ts)) as 'Activity Lifetime (Minutes)' from Users u inner join Activity a
on a.user_id = u.user_id
group by u.user_id ,u.reg_device, u.reg_ts 
order by u.user_id,u.reg_device ; 
•	What is the typical Churned Lifetime overall, where Churned Lifetime is defined as time from registration to last activity for users who have not been active for at least 180 days? 
select u.user_id,DATEDIFF(DAY,u.reg_ts,max(a.actvy_ts)) as 'Churned Lifetime (Days)' from Users u inner join Activity a
on a.user_id = u.user_id
group by u.user_id, u.reg_ts 
having (DATEDIFF(DAY,u.reg_ts,max(a.actvy_ts)))>180 order by u.user_id
; 
2. Considering the data available in these tables, what characteristics of user behavior would you want to examine in this dataset? Propose 3-5 theories you have about user engagement and describe how you would explore them. 
1.	Device type 
i.	Checking the type of device where the maximum traffic comes from. Checking 
which device is being used maximum whether a phone, tablet or a computer. 
ii.	Improving the app/website to be more user friendly depending upon where 
maximum traffic is coming from. 
2.	Session activity 
i.	Checking the user interaction with app/website by tracking the user activity from 
the time they login into the app/website until they quit. 
ii.	Watching the user first session activity and see how the user interacts and why he 
never used the app/website after the first session. 
iii.	Watching the session activity of regular users to see what works the best for them 
and how to improve/add features. 
3.	Conversion funnels
Tracking user behavior across different stages of a funnel such as payment stage, in-app purchases, onboarding, etc. and time taken for each stage. 
i. Measuring time between different stages in the funnel
ii. Understanding if the users are leaving upon increasing the in-app purchases what 
made them to leave without converting.
iii. Session recording for login and creating an account and improving onboardings. 
d. Action Cohorts 
i.	Tracking actions to analyze the relation between different related actions to see 
the trends and engagement of the user over a given period of time. 
ii.	Tracking user behavior from time of onboarding to time of account creation. 
iii.	Tracking relationship between first and successive sessions. 
iv.	Tracking user cohorts who created the account and then left without making any 
in-app purchases or using any other service to increase user retention. 
1
•	What are the 5 most listened to playlists?

SELECT playlist_id, count(playlist_id) as most_listened from plays
GROUP BY playlist_id
ORDER BY most_listened DESC
limit 5
;

•	Given a user X, what are their 3 most listened to playlists? 

SELECT user_id, playlist_id, count(playlist_id)
FROM plays
WHERE user_id = X
GROUP BY playlist_id
ORDER BY playlist_id DESC
limit 3
;

•	Which users have uploaded a majority of tracks belonging to ‘HipHop & R&B’ or ‘Dance & Electronic’ genre categories? (please answer this question with and without the use of a window/analytical function) 

Without window function
SELECT user_id, count(track_id) as max_tracks
FROM tracks
WHERE track_genre_category = 'HipHop & R&B' or track_genre_category = 'Dance & Electronic'
GROUP BY user_id
ORDER BY max_tracks DESC
;

With window function
SELECT user_id, track_id, track_genre_category,
COUNT(track_id) OVER (PARTITION BY track_genre_category) total_count
FROM tracks
;

•	Which uploaders have churned recently?
For this question I used the tracks table and perform self -join on it to see how many users were not active in last 90 days i.e., which users did not upload any tracks.

SELECT t.user_id
FROM tracks t
JOIN tracks tr ON t.user_at = tr.user_ID
GROUP BY t.user_id
HAVING MAX(tr.created_at) < CURDATE() - INTERVAL 90 DAY
OR MAX(tr.created_at) IS NULL
 ;

•	For a user X, recommend 5 playlists they would like that they haven’t heard before. Please attempt this using SQL and (where appropriate) common table expressions. Please explain your logic. 

For this question I first try to find what is the most listened to tracks by user by genre category.
I want to find the most listed tracks belonging to a particular genre. For that I use following query to get ouput for user_id = 1.

SELECT p.user_id, COUNT(p.track_id), t.track_genre_category
FROM plays p
JOIN tracks t
ON p.track_id = t.track_id
WHERE p.user_id = 1
GROUP by 1, 3
ORDER BY 2 DESC
;

If the above output says ‘Classic is the most listened I can get the track_id from ‘Classic’ genre from tracks table that were not listened by the user.

SELECT p.user_id, p.track_id, t.track_id, t.track_genre_category  from plays p
RIGHT JOIN tracks t
ON p.track_id = t.track_id
WHERE t.track_genre_category = ‘Classic’
;


2. There might be several reasons why the numbers might be less today. Some of them are:

a.	Technical difficulties with website: Checking if the website was down or were the pages broken, was there any maintenance scheduled, longer load times, Error 404.

b.	Recent website changes: Checking if any recent changes were made to the website, any features added or deleted. Change in UI which is not very user friendly for some users.

c.	Server Overload: Investigating if the web servers were overloaded which might have crashed the website for a few hours.

d.	Competition from other websites: It might be possible the competitor website might be having a better and a greater number of tracks collection and more user-friendly UI. Monitoring and analyzing the competitors content marketing, social media activity.

e.	Monotonous: Investigating whether any new tracks were uploaded or not. Are the tracks becoming repetitious, are users tired of listening to same old tracks? 

f.	Poor promotion: Poorly promoting a new uploaders track. Users not getting suggestions as per their music choices. 


3. Visualization done in tableau with output in ppt file.



4.  Some of the important KPIs to track and analyze the health of subscription business
a.	Active Subscriber Count (ASC)
b.	Churn
c.	Average Revenue Per User (ARPU)
d.	Monthly Recurring Revenue (MRR)
e.	Customer Acquisition Cost (CAC)
f.	Lifetime Value (LTV)

a. Active Subscriber Count (ASC)
An active subscriber is currently using the service over a given period of time, but customers can always cancel the service whenever they want. Important points to consider:
i.	Most profitable subscriber
ii.	Subscriber most engaged with the service.
iii.	Who are most likely to stay and most likely to churn?

ASC is calculated from Net Subscriber Count (NSC) which is:
(No. of subscribers acquired during a period) – (No. of subscribers churned in same period).
b. Churn
The churn is the rate at which the subscribers leaves in a given month or year. Churn rate must be always less then new subscriber signing in. If we lose 1000 subscribers, we need to get more than 1000 subscribers.
Churn = (No. of subscribers left) / (Total subscribers) x 100

c. Average Revenue Per User (ARPU)
ARPU helps in determining the average revenue earned from each subscriber.
ARPU = (Total revenue) / (Total subscribers)

d. Monthly Recurring Revenue (MRR)
MRR is the total revenue from different subscription plans and is calculated by:
(Monthly revenue) x (No. of active subscribers)

e. Customer Acquisition Cost (CAC)
CAC is the total amount spent in running different marketing campaigns to acquire a single subscriber. CAC helps in understanding how effective our marketing strategies and marketing campaigns is.
CAC = (Amount spent on marketing) / New subscribers acquired)

We can use a more complex model by attributing costs at individual level like which campaign helped in acquiring the subscriber.

f. Lifetime Value (LTV)
It helps in predicting total business that would be received from the subscriber. It helps in determining what subscriber are most valuable based on recent purchases. The more the subscriber spends in a given period of time the higher will be its LTV. Higher LTV can justify spending more Customer Acquisition. Together LTV and CAC can help determine how long it takes to get back the investment required to acquire a customer. 
LTV = (ARPU) x (Retention)


