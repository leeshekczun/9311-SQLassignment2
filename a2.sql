create view Q1_1(id)  --all id
as
select  distinct person.PersonId from Person  join RelationPersonInProceeding
on Person.personId = RelationPersonInProceeding.personId;
create view Q1(authors) 
as
select person.name 
from person 
where person.PersonId in (select id from Q1_1);
create or replace view NEditor(Id) 
as
select distinct PersonId from RelationPersonInProceeding except select EditorId from Proceeding; --storge for further usage

create view Q2(Name)
as
select name from person where personId in
((select distinct p1.PersonId from Person p1  right join RelationPersonInProceeding r
on (p1.personId = r.personId))       --authors
except
(select distinct p2.PersonId from Person p2 right join Proceeding pr  --editors
on (p2.personId = pr.EditorId)));
create  view Q3(Name)
as
((select distinct p1.name from Person p1 join Proceeding pr1  --editors
on (p1.personId = pr1.EditorId))
except
(select distinct p2.name  --those have edited
from Person p2, Person p3, RelationPersonInProceeding r1, 
Proceeding pr1, Inproceeding i1
where 
      r1.PersonId = p2.PersonId             and 
      r1.InproceedingId = i1.InproceedingId and 
      i1.ProceedingId = pr1.ProceedingId    and 
      p3.PersonId = pr1.EditorId            and
      p2.PersonId = p3.PersonId ));
create view Q4(Name, Total)
as
select distinct p2.name, count(i1.ProceedingId) as total
from Person p2, Person p3, RelationPersonInProceeding r1, 
Proceeding pr1, Inproceeding i1
where 
      r1.PersonId = p2.PersonId             and 
      r1.InproceedingId = i1.InproceedingId and 
      i1.ProceedingId = pr1.ProceedingId    and 
      p3.PersonId = pr1.EditorId            and  --relationships
      p2.PersonId = p3.PersonId
group by      --list all of them
      p2.name
order by
      total desc,p2.name;



--Q5
create or replace view PAAC(InId,ToTal) --（inproceeding里作者多于1人的）
      as select InProceedingId,count(PersonId) from RelationPersonInProceeding group by InProceedingId having count(PersonId)>1;


create or replace view AAEAY(Id,Year) --（编辑和其编辑作品的年份）
      as select Person.PersonId,Proceeding.Year 
from Person,Proceeding 
where Person.PersonId=Proceeding.EditorId;

create or replace view AAEALY(Id,LYear) --（每个编辑的最早编辑年份）
      as select Id,min(Year) from AAEAY group by Id;


create or replace view PAY(InId,Year)  --（每个inproceeding的年份）
      as select InProceeding.InProceedingId,Proceeding.Year 
from InProceeding,Proceeding 
Where InProceeding.ProceedingId=Proceeding.ProceedingId;

create or replace view PALY(InId,LYear) (在inproceeding和editor里都出现的人的proceedingid和其最早编辑年)
      as select RelationPersonInProceeding.InProceedingId,AAEALY.LYear 
from RelationPersonInProceeding,AAEALY 
where RelationPersonInProceeding.PersonId=AAEALY.Id;


create or replace view PAEP(InId) 
      as select PAY.InId from PAY,PALY where PAY.InId=PALY.InId and PALY.LYear<PAY.Year;


create or replace view PWUY(InId)  --（没有年份的inproceedingid）
      as select InProceeding.InProceedingId 
from InProceeding,Proceeding 
where InProceeding.ProceedingId=Proceeding.ProceedingId and 
      Proceeding.Year is null;


create or replace view PWNP(InId)   --（没有proceedingid的inproceedingid）
      as select InProceedingId from InProceeding where ProceedingId is null;


create or replace view FQ5(InId) 
      as 
      select InId from PAEP 
      union
      select InId from PWUY   --（没有年份的inproceedingid）
      union 
      select InId from PWNP;   --（没有proceedingid的inproceedingid）


create or replace view Q5Id(InId) 
      as select InProceedingId from InProceeding except select InId from FQ5;


create or replace view Q5(Title) 
      as select InProceeding.Title from InProceeding, Q5Id where InProceeding.InProceedingId=Q5Id.InId;

create view Q6(Year, Total)
as
select pr1.year, count(i1.InproceedingId)
from Proceeding pr1, Inproceeding i1
where
	   pr1.ProceedingId = i1.ProceedingId        
group by
       pr1.year
having
       pr1.year is not null           and   --properties
       count(i1.InproceedingId) > 0
order by
       pr1.year;   --list
create view Q7_1(publisher_count)  --list numbers of count
as
select pu1.name, count(i1.inProceedingId) as b
from Proceeding pr1, Publisher pu1, Inproceeding i1
where
      pu1.PublisherId = pr1.PublisherId     and
      pr1.ProceedingId = i1.ProceedingId
group by
      pu1.name;

create view Q7(Name)  
as
select publisher_count 
from Q7_1 
where b in 
(select max(b) from Q7_1);
create view Q8_1(authorId,count)  --different authors
as
select p1.PersonId as authorId, count(distinct r1.inProceedingId)
from Person p1, Person p2,
 RelationPersonInProceeding r1,
RelationPersonInProceeding r2
where 
(      p1.personId != p2.personId            and
       r1.inProceedingId = r2.inProceedingId and
       r1.PersonId = p1.personId             and
       r2.PersonId = p2.personId
)
group by
      authorId;
create view Q8_2(co_author_most)---find the most
as
select authorid
from   Q8_1
where count in
(select max(count) from Q8_1);
create or replace view CA(Id,Total) as select RelationPersonInProceeding.PersonId,count(RelationPersonInProceeding.InProceedingId)from PAAC,RelationPersonInProceeding where RelationPersonInProceeding.InProceedingId=PAAC.InId group by RelationPersonInProceeding.PersonId;

create view Q8(Name)  --list
as
select name from person
where personid in (select co_author_most from Q8_2);
create view Q9_1(author)--as above ,all of them
as
select p1.PersonId as author
from Person p1, Person p2,
 RelationPersonInProceeding r1,
RelationPersonInProceeding r2
where  
(      p1.personId != p2.personId            and
       r1.inProceedingId = r2.inProceedingId and
       r1.PersonId = p1.personId             and
       r2.PersonId = p2.personId
)
group by
      author;
create view Q9_2(id) --all authors
as
select  distinct person.PersonId from Person  join RelationPersonInProceeding
on Person.personId = RelationPersonInProceeding.personId;
create view Q9_3(never_co_author_id)  --all - not needed
as
(select id from Q9_2)
except
(select author from Q9_1);
create or replace view Q9Id(Id) as select PersonId from RelationPersonInProceeding except select Id from CA;
create view Q9(Name)  --list
as
select name from person
where personid in (select never_co_author_id from Q9_3);

create or replace view RPP2(Id,InId)  --step by step
      as select PersonId,InProceedingId from RelationPersonInProceeding;
create or replace view CACA(Id,Id2) 
      as select a.PersonId,b.Id from RelationPersonInProceeding a,RPP2 b where a.InProceedingId=b.InId and a.PersonId<>b.Id;
create or replace view Q10Id(Id,Total) 
      as select Id,count(distinct Id2) from CACA group by Id union select Id,0 from Q9Id;
create or replace view Q10(Name, Total) 
      as select Person.Name,Q10Id.Total from Person,Q10Id where Person.PersonId=Q10Id.Id order by 2 DESC,1;

create or replace view RichardId(Id) as select PersonId from Person where Name like 'Richard%';
create view Q11_1(co_author_with_richard)  --co_author_with_richard
as
select distinct p1.PersonId from Person p1, Person p2,
RelationPersonInProceeding r1, InProceeding i1, 
RelationPersonInProceeding r2
where
       p1.PersonId = r1.PersonId                  and
       p2.PersonId = r2.PersonId                  and
       p2.name like 'Richard%'                    and
       r1.inProceedingId = i1.inProceedingId      and
       r2.inProceedingId = i1.inProceedingId      and
       p1.PersonId != p2.PersonId;

create view Q11_2(co_author_with_richards_coauthor)   --co_author_with_richards_coauthor
as
select distinct p3.PersonId from Person p3, Person p4,
RelationPersonInProceeding r3, InProceeding i3, 
RelationPersonInProceeding r4,Q11_1
where
       p3.PersonId = r3.PersonId                  and
       p4.PersonId = r4.PersonId                  and
       r3.inProceedingId = i3.inProceedingId      and
       r4.inProceedingId = i3.inProceedingId      and
       p3.PersonId != p4.PersonId                and
       p4.PersonId in (select co_author_with_richard 
            from Q11_1)
order by
       p3.PersonId;





create view Q11_3(id)    -- all authors
as
select  distinct person.PersonId from Person  join RelationPersonInProceeding
on Person.personId = RelationPersonInProceeding.personId;

create view Q11(Name)
as
select name from person 
where personId in
((select id from Q11_3) --all authors
except
(select PersonId from Person
where person.PersonId in 
((select * from q11_1) 
union
(select * from q11_2))));




create or replace view Q12Id(Id) as  ---recursive process
      with recursive Link(Id) as (
            select * from RichardId
            union
            select CACA.Id2 from Link,CACA where CACA.Id=Link.Id
)
select * from link except select * from RichardId;
create or replace view Q12(Name) as select Person.Name from Person,Q12Id where Q12Id.Id=Person.PersonId;



create or replace view PAT(Id,Total)  --step by step
      as select PersonId,count(InProceedingId) from RelationPersonInProceeding group by PersonId;
create or replace view PeAY(Id,Year) 
      as select RelationPersonInProceeding.PersonId,PAY.Year from RelationPersonInProceeding,PAY where RelationPersonInProceeding.InProceedingId=PAY.InId;
create or replace view PeALMY(Id,FYear,LYear) 
      as select Id,min(Year),max(Year) from PeAY group by Id;
create or replace view PWoP(InId)
      as select InProceedingId from InProceeding where ProceedingId is null;
create or replace view PeWUY(Id) 
      as select Id from PeALMY where FYear is null union select a.PersonId from RelationPersonInProceeding a,PWoP b where a.InProceedingId=b.InId;
create or replace view PeAUY(Id,Total,FYear,LYear) 
      as select PeWUY.Id,PAT.Total,'unknown','unknown' from PeWUY,PAT where PeWUY.Id=PAT.Id;
create or replace view PeALMYUN(Id,FYear,LYear)  -- add unknows
      as select Id,FYear,LYear from PeALMY where FYear is not null;
create or replace view PeALMYUN2(Id,Total,FYear,LYear) as select PeALMYUN.Id,PAT.Total,PeALMYUN.FYear,PeALMYUN.LYear from PeALMYUN,PAT where PeALMYUN.Id=PAT.Id;
create or replace view Q13Id(Id,Total,FYear,LYear) 
      as select Id,Total,FYear,LYear from PeALMYUN2 union select Id,Total,FYear,LYear from PeAUY where Id not in(select Id from PeALMYUN2);
create or replace view Q13(Author,Total,FirstYear,LastYear)as select Person.Name,Q13Id.Total,Q13Id.FYear,Q13Id.LYear from Person,Q13Id where Q13Id.Id=Person.PersonId order by 2desc,1;


create or replace view Prdata(PrId) as select ProceedingId from Proceeding where lower(Title) like '%data%';
create or replace view Indata(InId) as select InProceeding.InProceedingId from InProceeding,Prdata where InProceeding.ProceedingId=Prdata.PrId union select InProceedingId from InProceeding where lower(Title) like '%data%';
create or replace view Q14(Total) as select count(distinct RelationPersonInProceeding.PersonId) from RelationPersonInProceeding,Indata where Indata.InId=RelationPersonInProceeding.InProceedingId;
--Q15


create view Q15(EditorName, Title, PublisherName, Year, Total)  --all requirements
as
select p1.name, pr1.title, pu1.name, pr1.year, count(i1.inProceedingId) as total
from inProceeding i1 right join (publisher pu1 right join 
(Person p1 right join proceeding pr1           --keep right joining to make sure every null in proceeding has its position
on 
       p1.PersonId = pr1.EditorId )
on    
       pu1.PublisherId = pr1.PublisherId)
on
      i1.ProceedingId = pr1.ProceedingId
group by 
       p1.name, pr1.title, pu1.name, pr1.year
order by
       total desc, pr1.year, pr1.title;


create or replace view SAIn(InId) ---steps
      as select InProceedingId from RelationPersonInProceeding group by InProceedingId having count(PersonId)=1;
create or replace view everSA(Id)
      as select a.PersonId from RelationPersonInProceeding a,SAIn where a.InProceedingId=SAIn.InId;
create or replace view Q16Id(Id)
      as select Id from NEditor except select Id from everSA;
create or replace view Q16(Name) 
      as select Person.Name from Person,Q16Id where Q16Id.Id=Person.PersonId;


create view Q17_1(id,Total)   --list id
as
select p1.PersonId, count(distinct pr1.ProceedingId) as total
from person p1, Proceeding pr1,Inproceeding i1, 
RelationPersonInProceeding r1
where
       p1.PersonId = r1.PersonId    and
       r1.InproceedingId = i1.InProceedingId  and
       i1.ProceedingId = pr1.ProceedingId  
group by
       p1.PersonId
order by
       total desc,p1.PersonId;
create view Q17(Name,Total)  --list name
as
select p2.name, Q17_1.Total
from Person p2,Q17_1
where
       p2.PersonId = Q17_1.id

order by
       Q17_1.Total desc,p2.name;


create or replace view AAInNN(Id,InId)as select a.PersonId,b.InProceedingId from RelationPersonInProceeding a,InProceeding b where a.InProceedingId is not null and a.InProceedingId=b.InProceedingId and b.ProceedingId is not null;
create view Q18_1(person, num_publications)   --basic view
as
select p1.name, count(i1.inProceedingId) as total
from person p1, Proceeding pr1,Inproceeding i1, 
RelationPersonInProceeding r1
where
       p1.PersonId = r1.PersonId    and
       r1.InproceedingId = i1.InProceedingId  and
       i1.ProceedingId = pr1.ProceedingId  
group by
       p1.name
order by
       total desc,p1.name;
create view Q18(MinPub, AvgPub, MaxPub) --results
as
select min(num_publications),Round(avg(num_publications),0) , 
max(num_publications) 
from Q18_1;
create view Q19_1(EditorId, num_year, year, num_publications)   --list id
as
select p1.PersonId, count(distinct pr1.year) as num_year,pr1.year, 
count(i1.inProceedingId) as num_publications
from person p1, proceeding pr1, inProceeding i1 
where
       p1.PersonId = pr1.EditorId  and
       pr1.ProceedingId = i1.ProceedingId and
       pr1.EditorId is not null
group by 
       p1.PersonId, pr1.year
order by
       p1.PersonId, pr1.year;
create view Q19(Name, Years, MinPub, MaxPub, AvgPub) 
as
select person.name, count(num_year),min(num_publications), 
max(num_publications) ,Round(avg(num_publications),0)
from Q19_1,person
where
            person.PersonId = Q19_1.EditorId
group by 
       person.name
order by
       person.name;







create function Q20() RETURNS trigger AS $$
begin
if new.PersonId <>( select EditorId from Proceeding where ProceedingId=
      (select ProceedingId from InProceeding where InProceedingId=new.InProceedingId))
      then
      return new;
end if;
end;
$$ LANGUAGE plpgsql;
CREATE TRIGGER Q20 BEFORE INSERT OR UPDATE ON RelationPersonInProceeding
    FOR EACH ROW EXECUTE PROCEDURE Q20();
--Q21
create function Q21() RETURNS trigger AS $$
begin
    --create or replace view EAuIn(InId) as select InId from AAInNN where Id=new.EditorId;
      --create or replace view YAIn(InId)as select InId from EAIn where InId=(select InId from AAInNN where Id=new.EditorId) and Year<=new.Year;
      if new.Year is null then
            return new;
      elsif (select count(InId) from PAY where InId in(select InId from AAInNN where Id=new.EditorId)and Year<=new.Year)>=3then
            return new;
      end if;
end;
$$ LANGUAGE plpgsql;
Create trigger Q21 before insert or update on Proceeding 
FOR EACH ROW EXECUTE PROCEDURE Q21();
--Q22
create function Q22() RETURNS trigger AS $$
begin
      if (select count(InProceedingId) from RelationPersonInProceeding where InProceedingId in(select InProceedingId from InProceeding where ProceedingId=new.ProceedingId) and PersonId=(select EditorId from Proceeding where ProceedingId=new.ProceedingId))<2then
            return new;
      end if;
end;
$$ LANGUAGE plpgsql;
Create trigger Q22 before insert or update on InProceeding 
FOR EACH ROW EXECUTE PROCEDURE Q22();










