use ipl;

#1.	Show the percentage of wins of each bidder in the order of highest to lowest percentage. 
 select bdr.bidder_id 'Bidder ID', bdr.bidder_name 'Bidder Name', 
(select count(*) from ipl_bidding_details ibd
where ibd.bid_status = 'won' and ibd.bidder_id = bdr.bidder_id) / 
(select no_of_bids from ipl_bidder_points ibp
where bdr.bidder_id = ibp.bidder_id)*100 as Percentage
from ipl_bidder_details bdr order by Percentage desc;
 
 
#2.	Display the number of matches conducted at each stadium with stadium name, city from the database.
select iss.stadium_id,iss.stadium_name,iss.city,count(ims.match_id) as no_of_matches from ipl_stadium iss join ipl_match_schedule ims 
on iss.stadium_id = ims.stadium_id group by iss.stadium_id;
#3.	In a given stadium, what is the percentage of wins by a team which has won the toss?
select stadium_id 'Stadium ID', stadium_name 'Stadium Name',
(select count(*) from ipl_match m join ipl_match_schedule ms on m.match_id = ms.match_id
where ms.stadium_id = s.stadium_id and (toss_winner = match_winner)) /
(select count(*) from ipl_match_schedule ms where ms.stadium_id = s.stadium_id) * 100 
as 'Percentage of Wins by teams who won the toss (%)'
from ipl_stadium s;



#4.	Show the total bids along with bid team and team name.
select ibd.bidder_id,ibd.bid_team,it.team_name,count(ibd.bidder_id) from ipl_bidding_details ibd 
join ipl_team it on ibd.bid_team = it.team_id group by bid_team;
#5.	Show the team id who won the match as per the win details.
select match_winner,win_details from ipl_match where win_details like '%won%';

#6.	Display total matches played, total matches won and total matches lost by team along with its team name.
select ips.team_id,it.team_name,sum(ips.matches_won) as matches_won,sum(ips.matches_lost) as matches_lost,
sum(ips.matches_played) as matches_played from ipl_team_standings ips join ipl_team it
on ips.team_id = it.team_id group by ips.team_id;
#7.	Display the bowlers for Mumbai Indians team.
select player_name,player_id from ipl_player  where player_id in 
(select player_id from ipl_team_players where player_role = 'Bowler' and team_id = 5);
#8.	How many all-rounders are there in each team, Display the teams with more than 4 all-rounder in descending order

select itp.remarks,count(itp.player_id) as no_of_players from ipl_team_players itp where player_role = 'all-rounder'   group by remarks having  no_of_players > 4 ;