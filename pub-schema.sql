CREATE TABLE Person (
  PersonId integer primary key,
  Name text not null,
  Email text default null,
  Url text default null
);

CREATE TABLE Publisher (
  PublisherId integer primary key,
  Name text not null,
  Address text default null
);

CREATE TABLE Series (
  SeriesId integer primary key,
  Title text not null,
  Url text default null
);

CREATE TABLE Proceeding (
  ProceedingId integer primary key,
  Title text not null,
  EditorId integer references Person(PersonId),
  PublisherId integer references Publisher(PublisherId),
  SeriesId integer references Series(SeriesId),
  Year char(4) default null check (Year ~ '[1-2][0-9]{3}'),
  ISBN text default null,
  Url text default null
);

-- InProceeding contains the research paper title, and the proceeding (if known) 
-- in which the paper appears.
--
CREATE TABLE InProceeding (
  InProceedingId integer primary key,
  Title text default null,
  Pages text default null,
  Url text default null,
  ProceedingId integer references Proceeding(ProceedingId)
);

CREATE TABLE RelationPersonInProceeding (
  PersonId integer references Person(PersonId),
  InProceedingId integer references InProceeding(InProceedingId),
  primary key (PersonId,InProceedingId)
);

CREATE VIEW check_tongming(name,count_inproceedingid) as
select p1.name, count(r1.inproceedingid) 
from person p1,relationpersoninproceeding r1 
where r1.personid = p1.personid group by p1.name;

a2=# CREATE VIEW check_tongming(name,count_inproceedingid) as
a2-# select p1.name, count(r1.inproceedingid) 
a2-# from person p1,relationpersoninproceeding r1 
a2-# where r1.personid = p1.personid group by p1.name;


select RelationPersonInProceeding.* from RelationPersonInProceeding,person 
where person.personid=RelationPersonInProceeding.personid and 
(person.personid=80 or 
person.personid=2972 or 
person.personid=2997 or 
person.personid=3199);


Csar Fernndez
create view Q5_1(id)
as
select distinct i1.inProceedingId
from InProceeding i1 ,         Proceeding pr1,Proceeding pr2,person p1,
            person p2, RelationPersonInProceeding r1,
            RelationPersonInProceeding r2,InProceeding i2
      where
     (p1.PersonId = r1.PersonId                and
      r1.InProceedingId = i1.inProceedingId    and  
      p2.PersonId = r2.PersonId                and
      r2.InProceedingId = i2.inProceedingId    and 
      i1.inProceedingId = i2.inProceedingId    and                
      i1.ProceedingId = pr1.ProceedingId       and
      p2.PersonId = pr2.EditorId               and
      p1.PersonId != p2.PersonId               and
      pr2.year < pr1.year                )     
order by
      i1.inProceedingId;
create view Q5_2(id_year_null)
as
select inProceedingId
from proceeding pr1, inProceeding i1
where
      pr1.ProceedingId = i1.ProceedingId     and
      pr1.year is null




create view Q13_1(PersonId, year, total) 
as
select p1.PersonId, pr1.year, count(i1.inProceedingId)
from person p1, RelationPersonInProceeding r1, inProceeding i1,
Proceeding pr1
where
       p1.PersonId = r1.PersonId               and
       r1.inProceedingId = i1.inProceedingId   and
       i1.ProceedingId = pr1.ProceedingId
group by
       p1.PersonId, pr1.year
order by
       p1.PersonId, pr1.year;

create view Q13_2(AuthorId, Total, FirstYear, LastYear)
as
select PersonId, sum(total), min(year), 
max(year)
from Q13_1
group by
       PersonId
order by
       PersonId;



create view Q13(Author, Total, FirstYear, LastYear)
as
select p1.name,total, FirstYear, LastYear
from Q13_2,person p1
where
       p1.PersonId = AuthorId
order by
       total desc,p1.name;









create view Q16_1(id_never_co_author) 
as
select distinct p1.PersonId 
from Person p1 
where  not exists
(select p2.PersonId 
from   Person p2,
RelationPersonInProceeding r1, InProceeding i1, 
RelationPersonInProceeding r2
where
       p1.PersonId = r1.PersonId                  and
       p2.PersonId = r2.PersonId                  and
       r1.inProceedingId = i1.inProceedingId      and
       r2.inProceedingId = i1.inProceedingId      and
       p1.PersonId != p2.PersonId);
create view Q16_2(all_authors_id) 
as
select  distinct person.PersonId from Person  join RelationPersonInProceeding
on Person.personId = RelationPersonInProceeding.personId;
create view Q16(name) 
as
select name from person
where PersonId in 
((select all_authors_id from Q16_2)
except
(select id_never_co_author from Q16_1))
order by name;


create view person_all_id(id,name,email) as
select p1.personid,p1.name,email 
from person p1 
group by p1.personid;


create view person_all_idandname(id,name,email) as
select p1.personid,p1.name,email 
from person p1 
group by p1.personid,p1.name;


create view person_all_name(id,name,email) as
select p1.personid,p1.name,email 
from person p1 
group by p1.name;










