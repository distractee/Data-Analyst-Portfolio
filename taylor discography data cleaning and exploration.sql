# Data Cleaning
alter table personal_projects.taylor_discography
rename column ï»¿track_name to track_name;

select*
from taylor_discography;

Update taylor_discography
set track_name = 'Who\'s afraid of little old me?'
where track_name = 'Who\â€™s Afraid of Little Old Me?';

select*
from taylor_discography
where track_name Like '%â€%';

Update taylor_discography
set track_name = replace(track_name, 'â€', '\'')
where track_name Like '%â€%';

select*
from taylor_discography;

# EDA
select count(*) as total_remakes
from taylor_discography
where track_name Like '%(Taylor''s Version)%';

select  distinct(album_total_tracks), count(album_total_tracks)
from taylor_discography
group by album_total_tracks;

SELECT album_total_tracks, COUNT(distinct album_name) AS album_count
FROM taylor_discography
GROUP BY album_total_tracks;

Select explicit, count(*) as no_of_songs
From taylor_discography
group by explicit;

Select album_name, explicit, YEAR(album_release_date)
from taylor_discography
where explicit = 'TRUE'
group by album_name, YEAR(album_release_date)












