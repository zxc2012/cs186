-- Before running drop any existing views
DROP VIEW IF EXISTS q0;
DROP VIEW IF EXISTS q1i;
DROP VIEW IF EXISTS q1ii;
DROP VIEW IF EXISTS q1iii;
DROP VIEW IF EXISTS q1iv;
DROP VIEW IF EXISTS q2i;
DROP VIEW IF EXISTS q2ii;
DROP VIEW IF EXISTS q2iii;
DROP VIEW IF EXISTS q3i;
DROP VIEW IF EXISTS q3ii;
DROP VIEW IF EXISTS q3iii;
DROP VIEW IF EXISTS q4i;
DROP VIEW IF EXISTS q4ii;
DROP VIEW IF EXISTS q4iii;
DROP VIEW IF EXISTS q4iv;
DROP VIEW IF EXISTS q4v;

-- Question 0
CREATE VIEW q0(era)
AS
  select max(ERA) from pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT namefirst,namelast,birthyear from people
  where weight>300
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT namefirst,namelast,birthyear from people
  where namefirst like '% %' 
  order by namefirst,namelast
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthyear,avg(height),count(*) from people
  group by birthyear
  order by birthyear
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT birthyear,avg(height),count(*) from people
  group by birthyear
  having avg(height)>70
  order by birthyear
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT namefirst,namelast,people.playerid,yearid
  from people,halloffame
  where people.playerid=halloffame.playerid and halloffame.inducted='Y'
  order by yearid desc,people.playerid
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  SELECT namefirst, namelast, people.playerid, schools.schoolID,yearid
  from (collegeplaying natural join schools natural join people), halloffame
  where collegeplaying.playerid=halloffame.playerid and halloffame.inducted='Y' and schoolState='CA'
  order by yearid desc,schools.schoolID,people.playerid
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT halloffame.playerid,namefirst, namelast,schoolID
  from (halloffame natural join people)left outer join collegeplaying on halloffame.playerid=collegeplaying.playerid
  where halloffame.inducted='Y'
  order by halloffame.playerid desc,schoolID
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  SELECT batting.playerid, namefirst, namelast, yearid, (H+H2B+2*H3B+3*HR)*1.0/AB as slg
  from batting natural join people 
  where AB>50
  order by slg desc,yearid,batting.playerid
  limit 10
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  SELECT batting.playerid, namefirst, namelast, sum(H+H2B+2*H3B+3*HR)*1.0/sum(AB) as lslg
  from batting natural join people 
  group by batting.playerid
  having sum(AB)>50
  order by lslg desc,batting.playerid
  limit 10
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  SELECT namefirst, namelast, sum(H+H2B+2*H3B+3*HR)*1.0/sum(AB) as lslg
  from batting natural join people 
  group by batting.playerid
  having sum(AB)>50 and lslg>(
    select sum(H+H2B+2*H3B+3*HR)*1.0/sum(AB) from batting natural join people 
    where batting.playerid='mayswi01'
  )
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
  SELECT yearID, min(salary), max(salary),avg(salary)
  from salaries
  group by yearID
  order by yearID
;


-- Helper table for 4ii
DROP TABLE IF EXISTS binids;
CREATE TABLE binids(binid);
INSERT INTO binids VALUES (0), (1), (2), (3), (4), (5), (6), (7), (8), (9);

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS
  SELECT binid, 507500.0+binid*3249250,3756750.0+binid*3249250, count(*)
  from binids,salaries
  where (salary between 507500.0+binid*3249250 and 3756750.0+binid*3249250 )and yearID='2016'
  group by binid
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  SELECT t.yearid,t.min-r.min,t.max-r.max,t.avg-r.avg
  from q4i as t join q4i as r
  on t.yearid=r.yearid+1
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  SELECT t.playerID, namefirst, namelast, salary ,t.yearID
  from (salaries natural join people)as t join (
      select max(salary) as m,yearID from salaries
      group by yearID
      having yearID between '2000' and '2001' 
  )r
  on t.yearID=r.yearID and t.salary=r.m
;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
  SELECT t.teamID,max(salary)-min(salary)
  from allstarfull as t join(
      select salary,teamID,yearID,playerID
      from salaries
      where yearID='2016'
  )r 
  on t.teamID=r.teamID and t.yearID=r.yearID and t.playerID=r.playerID
  group by t.teamID
;

