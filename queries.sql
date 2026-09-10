-- 1. Location of User 
SELECT * FROM post
WHERE location IN ('agra' ,'maharashtra','west bengal');


-- 2. Most Followed Hashtag
SELECT 
	hashtag_name AS 'Hashtags', COUNT(hashtag_follow.hashtag_id) AS 'Total Follows' 
FROM hashtag_follow, hashtags 
WHERE hashtags.hashtag_id = hashtag_follow.hashtag_id
GROUP BY hashtag_follow.hashtag_id
ORDER BY COUNT(hashtag_follow.hashtag_id) DESC LIMIT 5;

-- 3. Most Used Hashtags
SELECT 
	hashtag_name AS 'Trending Hashtags', 
    COUNT(post_tags.hashtag_id) AS 'Times Used'
FROM hashtags,post_tags
WHERE hashtags.hashtag_id = post_tags.hashtag_id
GROUP BY post_tags.hashtag_id
ORDER BY COUNT(post_tags.hashtag_id) DESC LIMIT 10;


-- 4. Most Inactive User
SELECT user_id, username AS 'Most Inactive User'
FROM users
WHERE user_id NOT IN (SELECT user_id FROM post);

 
-- 5. Most Likes Posts
SELECT post_likes.post_id, COUNT(post_likes.post_id) AS TotalLikes
FROM post_likes, post
WHERE post.post_id = post_likes.post_id 
GROUP BY post_likes.post_id
ORDER BY COUNT(post_likes.post_id) DESC ;

-- 6. Average post per user
SELECT ROUND((COUNT(post_id) / COUNT(DISTINCT user_id) ),2) AS 'Average Post per User' 
FROM post;

-- 7. no. of login by per user
SELECT user_id, email, username, login.login_id AS login_number
FROM users 
NATURAL JOIN login;


-- 8. User who liked every single post (CHECK FOR BOT)
SELECT username, Count(*) AS num_likes 
FROM users 
INNER JOIN post_likes ON users.user_id = post_likes.user_id 
GROUP  BY post_likes.user_id 
HAVING num_likes = (SELECT Count(*) FROM   post); 

-- 9. User Never Comment 
SELECT user_id, username AS 'User Never Comment'
FROM users
WHERE user_id NOT IN (SELECT user_id FROM comments);

-- 10. User who commented on every post (CHECK FOR BOT)
SELECT username, Count(*) AS num_comment 
FROM users 
INNER JOIN comments ON users.user_id = comments.user_id 
GROUP  BY comments.user_id 
HAVING num_comment = (SELECT Count(*) FROM comments); 


-- 11. User Not Followed by anyone
SELECT user_id, username AS 'User Not Followed by anyone'
FROM users
WHERE user_id NOT IN (SELECT followee_id FROM follows);

-- 12. User Not Following Anyone
SELECT user_id, username AS 'User Not Following Anyone'
FROM users
WHERE user_id NOT IN (SELECT follower_id FROM follows);

-- 13. Posted more than 5 times
SELECT user_id, COUNT(user_id) AS post_count FROM post
GROUP BY user_id
HAVING post_count > 5
ORDER BY COUNT(user_id) DESC;


-- 14. Followers > 40
SELECT followee_id, COUNT(follower_id) AS follower_count FROM follows
GROUP BY followee_id
HAVING follower_count > 40
ORDER BY COUNT(follower_id) DESC;


-- 15. Any specific word in comment
SELECT * FROM comments
WHERE comment_text REGEXP'good|beautiful';


-- 16. Longest captions in post
SELECT user_id, caption, LENGTH(post.caption) AS caption_length FROM post
ORDER BY caption_length DESC LIMIT 5;


-- ============================================================
-- Custom Analysis Added to the Project
-- ============================================================

-- 11. Users with the most unread notifications
SELECT
    u.user_id,
    u.username,
    COUNT(n.notification_id) AS unread_notifications
FROM users u
JOIN notifications n
    ON u.user_id = n.user_id
WHERE n.is_read = FALSE
GROUP BY u.user_id, u.username
ORDER BY unread_notifications DESC;


-- 12. Notification activity by type
SELECT
    notification_type,
    COUNT(*) AS total_notifications,
    SUM(CASE WHEN is_read = FALSE THEN 1 ELSE 0 END) AS unread_notifications
FROM notifications
GROUP BY notification_type
ORDER BY total_notifications DESC;


-- 13. Posts receiving the most notifications
SELECT
    p.post_id,
    u.username AS post_owner,
    COUNT(n.notification_id) AS notification_count
FROM post p
JOIN users u
    ON p.user_id = u.user_id
JOIN notifications n
    ON p.post_id = n.post_id
GROUP BY p.post_id, u.username
ORDER BY notification_count DESC;


-- 14. Users who both receive and generate notifications
SELECT
    u.user_id,
    u.username,
    COUNT(DISTINCT received.notification_id) AS received_notifications,
    COUNT(DISTINCT sent.notification_id) AS generated_notifications
FROM users u
LEFT JOIN notifications received
    ON u.user_id = received.user_id
LEFT JOIN notifications sent
    ON u.user_id = sent.actor_id
GROUP BY u.user_id, u.username
HAVING received_notifications > 0
   AND generated_notifications > 0
ORDER BY received_notifications DESC;
