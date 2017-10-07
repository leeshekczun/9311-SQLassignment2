--Q1
create or replace view Q1Id(Id) as select distinct PersonId from RelationPersonInProceeding;
create or replace view Q1(Name) as select Person.Name from Person,Q1Id where Person.PersonId=Q1Id.Id;
--Q2
create or replace view NEditor(Id) as select distinct PersonId from RelationPersonInProceeding except select EditorId from Proceeding;
create or replace view Q2(Name) as select Person.Name from Person,NEditor where Person.PersonId=NEditor.Id;
--Q3
create or replace view InandRE(PeId,PrId) as select RelationPersonInProceeding.PersonId,InProceeding.ProceedingId from InProceeding,RelationPersonInProceeding where RelationPersonInProceeding.InProceedingID=InProceeding.InProceedingID;
create or replace view AAE(Id)as select InandRE.PeId from InandRE,Proceeding where Proceeding.ProceedingId=InandRE.PrId and InandRE.PeId=Proceeding.EditorId;
create or replace view NAAE(Id) as select EditorId from Proceeding except select Id from AAE;
create or replace view Q3(Name) as select Person.Name from Person,NAAE where Person.PersonId=NAAE.Id;
--Q4
create or replace view EAI(Id,InId) as select a.EditorId,b.InProceedingId From Proceeding a,InProceeding b where a.ProceedingId=b.ProceedingId;
create or replace view IAA(InId,Id)as select a.InId,b.PersonId from EAI a,RelationPersonInProceeding b where a.InId=b.InProceedingId;
create or replace view EAI2(Id,InId)as select a.Id,a.InId from EAI a,IAA b where a.InId=b.InId and a.Id=b.Id;
create or replace view Q4Id(Id,Total)as select Id,count(InId) from EAI2 group by Id;
create or replace view Q4(Name, Total) as select Person.Name,Q4Id.Total from Person,Q4Id where Person.PersonId=Q4Id.Id order by 2 DESC,1;
--Q5
create or replace view AAEAY(Id,Year) as select Person.PersonId,Proceeding.Year from Person,Proceeding where Person.PersonId=Proceeding.EditorId;
create or replace view AAEALY(Id,LYear) as select Id,min(Year) from AAEAY group by Id;
create or replace view PAY(InId,Year) as select InProceeding.InProceedingId,Proceeding.Year from InProceeding,Proceeding Where InProceeding.ProceedingId=Proceeding.ProceedingId;
create or replace view PALY(InId,LYear) as select RelationPersonInProceeding.InProceedingId,AAEALY.LYear from RelationPersonInProceeding,AAEALY where RelationPersonInProceeding.PersonId=AAEALY.Id;
create or replace view PAEP(InId) as select PAY.InId from PAY,PALY where PAY.InId=PALY.InId and PALY.LYear<PAY.Year;
create or replace view PWUY(InId) as select InProceeding.InProceedingId from InProceeding,Proceeding where InProceeding.ProceedingId=Proceeding.ProceedingId and Proceeding.Year is null;
create or replace view PWNP(InId)as select InProceedingId from InProceeding where ProceedingId is null;
create or replace view FQ5(InId) as select InId from PAEP union select InId from PWUY union select InId from PWNP;
create or replace view Q5Id(InId) as select InProceedingId from InProceeding except select InId from FQ5;
create or replace view Q5(Title) as select InProceeding.Title from InProceeding, Q5Id where InProceeding.InProceedingId=Q5Id.InId;
--create or replace view Q5 as select * from AAEAY where Id=1872;
--Q6
create or replace view Q6(Year, Total) as select Year,count(InId) from PAY group by Year order by Year;
--Q7
create or replace view PuAI(PuId,InId) as select Proceeding.PublisherId,InProceeding.InProceedingId from Proceeding,InProceeding where Proceeding.ProceedingId=InProceeding.ProceedingId;
create or replace view PuAT(PuId,Total) as select PuId,count(InId) from PuAI group by PuId;
create or replace view PuAMT(MT)as select max(Total)from PuAT;
create or replace view MCP(PuId) as select PuAT.PuId from PuAT,PuAMT where PuAT.Total=PuAMT.MT;
create or replace view Q7(Name) as select Publisher.Name from Publisher,MCP where Publisher.PublisherId=MCP.PuId;
--Q8
create or replace view PAAC(InId,ToTal) as select InProceedingId,count(PersonId) from RelationPersonInProceeding group by InProceedingId having count(PersonId)>1;
create or replace view CA(Id,Total) as select RelationPersonInProceeding.PersonId,count(RelationPersonInProceeding.InProceedingId)from PAAC,RelationPersonInProceeding where RelationPersonInProceeding.InProceedingId=PAAC.InId group by RelationPersonInProceeding.PersonId;
create or replace view CAMT(MT)as select max(Total)from CA;
create or replace view Q8Id(Id) as select CA.Id from CA,CAMT where CA.Total=CAMT.MT;
create or replace view Q8(Name) as select Person.Name from Person,Q8Id where Q8Id.Id=Person.PersonId;
--Q9
create or replace view Q9Id(Id) as select PersonId from RelationPersonInProceeding except select Id from CA;
create or replace view Q9(Name) as select Person.Name from Person,Q9Id where Person.PersonId=Q9Id.Id;
--Q10
create or replace view RPP2(Id,InId) as select PersonId,InProceedingId from RelationPersonInProceeding;
create or replace view CACA(Id,Id2) as select a.PersonId,b.Id from RelationPersonInProceeding a,RPP2 b where a.InProceedingId=b.InId and a.PersonId<>b.Id;
create or replace view Q10Id(Id,Total) as select Id,count(distinct Id2) from CACA group by Id union select Id,0 from Q9Id;
create or replace view Q10(Name, Total) as select Person.Name,Q10Id.Total from Person,Q10Id where Person.PersonId=Q10Id.Id order by 2 DESC,1;
--Q11
create or replace view RichardId(Id) as select PersonId from Person where Name like 'Richard%';
create or replace view CAWR(Id) as select CACA.Id2 from CACA,RichardId where RichardId.Id=CACA.Id;
create or replace view CAWCAWRACAWR(Id) as select CACA.Id2 from CACA,CAWR where CACA.Id=CAWR.Id union select Id from CAWR;
create or replace view Q11Id(Id) as select PersonId from RelationPersonInProceeding except select Id from CAWCAWRACAWR;
create or replace view Q11(Name) as select Person.Name from Person,Q11Id where Q11Id.Id=Person.PersonId;
--Q12
create or replace view Q12Id(Id) as 
	with recursive Link(Id) as (
		select * from RichardId
		union
		select CACA.Id2 from Link,CACA where CACA.Id=Link.Id
)
select * from link except select * from RichardId;
create or replace view Q12(Name) as select Person.Name from Person,Q12Id where Q12Id.Id=Person.PersonId;
--Q13
create or replace view PAT(Id,Total) as select PersonId,count(InProceedingId) from RelationPersonInProceeding group by PersonId;
create or replace view PeAY(Id,Year) as select RelationPersonInProceeding.PersonId,PAY.Year from RelationPersonInProceeding,PAY where RelationPersonInProceeding.InProceedingId=PAY.InId;
create or replace view PeALMY(Id,FYear,LYear) as select Id,min(Year),max(Year) from PeAY group by Id;
create or replace view PWoP(InId)as select InProceedingId from InProceeding where ProceedingId is null;
create or replace view PeWUY(Id) as select Id from PeALMY where FYear is null union select a.PersonId from RelationPersonInProceeding a,PWoP b where a.InProceedingId=b.InId;
create or replace view PeAUY(Id,Total,FYear,LYear) as select PeWUY.Id,PAT.Total,'unknown','unknown' from PeWUY,PAT where PeWUY.Id=PAT.Id;
create or replace view PeALMYUN(Id,FYear,LYear) as select Id,FYear,LYear from PeALMY where FYear is not null;
create or replace view PeALMYUN2(Id,Total,FYear,LYear) as select PeALMYUN.Id,PAT.Total,PeALMYUN.FYear,PeALMYUN.LYear from PeALMYUN,PAT where PeALMYUN.Id=PAT.Id;
create or replace view Q13Id(Id,Total,FYear,LYear) as select Id,Total,FYear,LYear from PeALMYUN2 union select Id,Total,FYear,LYear from PeAUY where Id not in(select Id from PeALMYUN2);
create or replace view Q13(Author,Total,FirstYear,LastYear)as select Person.Name,Q13Id.Total,Q13Id.FYear,Q13Id.LYear from Person,Q13Id where Q13Id.Id=Person.PersonId order by 2desc,1;
--create or replace view Q13 as select * from PeWUY;
--Q14
create or replace view Prdata(PrId) as select ProceedingId from Proceeding where lower(Title) like '%data%';
create or replace view Indata(InId) as select InProceeding.InProceedingId from InProceeding,Prdata where InProceeding.ProceedingId=Prdata.PrId union select InProceedingId from InProceeding where lower(Title) like '%data%';
create or replace view Q14(Total) as select count(distinct RelationPersonInProceeding.PersonId) from RelationPersonInProceeding,Indata where Indata.InId=RelationPersonInProceeding.InProceedingId;
--Q15
create or replace view PrWNIn(PrId)as select ProceedingId from Proceeding except select ProceedingId from InProceeding;
create or replace view PrAT(PrId,Total)as select ProceedingId,count(InProceedingId)from InProceeding group by ProceedingId union select PrId,0 from PrWNIn;
create or replace view Q15Id(EId,Title,PuId,Year,Total)as select a.EditorId,a.Title,a.PublisherId,a.Year,PrAT.Total from Proceeding a,PrAT where a.ProceedingId=PrAT.PrId;
create or replace view Q15IdE(Name,Title,PuId,Year,Total)as select Person.Name,Q15Id.Title,Q15Id.PuId,Q15Id.Year,Q15Id.Total from Q15Id left join Person on Q15Id.EId=Person.PersonId;
create or replace view Q15(EditorName, Title, PublisherName, Year, Total)as select Q15IdE.Name,Q15IdE.Title,Publisher.Name,Q15IdE.Year,Q15IdE.Total from Q15IdE left join Publisher on Q15IdE.PuId=Publisher.PublisherId order by 5desc,4,2;
--Q16
create or replace view SAIn(InId)as select InProceedingId from RelationPersonInProceeding group by InProceedingId having count(PersonId)=1;
create or replace view everSA(Id)as select a.PersonId from RelationPersonInProceeding a,SAIn where a.InProceedingId=SAIn.InId;
create or replace view Q16Id(Id)as select Id from NEditor except select Id from everSA;
create or replace view Q16(Name) as select Person.Name from Person,Q16Id where Q16Id.Id=Person.PersonId;
--Q17
create or replace view AAPr1(Id,PrId)as select a.PersonId,b.ProceedingId from RelationPersonInProceeding a,InProceeding b where a.InProceedingId=b.InProceedingId and b.ProceedingId is not null;
create or replace view AAPr(Id,PrId)as select distinct * from AAPr1;
create or replace view Q17Id(Id,Total)as select Id,count(PrId)from AAPr group by Id;
create or replace view Q17(Name,Total)as select Person.Name,Q17Id.Total from Person,Q17Id where Person.PersonId=Q17Id.Id order by 2desc,1;
--Q18
create or replace view AAInNN(Id,InId)as select a.PersonId,b.InProceedingId from RelationPersonInProceeding a,InProceeding b where a.InProceedingId is not null and a.InProceedingId=b.InProceedingId and b.ProceedingId is not null;
create or replace view AACPr(Id,Total)as select Id,count(distinct InId)from AAInNN group by Id;
create or replace view Q18(MinPub, AvgPub, MaxPub) as select min(Total),round(avg(Total)),Max(Total)from AACPr;
--Q19
create or replace view EAIn(Id,Year,InId)as select a.EditorId,a.Year,b.InProceedingId from Proceeding a,InProceeding b where a.ProceedingId=b.ProceedingId;
create or replace view EAIn2(Id,Years)as select Id,count(distinct Year)from EAIn group by Id;
create or replace view EAIn3(Id,Year,Total)as select Id,Year,count(InId)from EAIn group by Id,Year;
create or replace view EAIn4(Id,MinPub, MaxPub, AvgPub)as select Id,min(Total),max(Total),avg(Total)from EAIn3 group by Id;
create or replace view Q19Id(Id,Years,MinPub, MaxPub, AvgPub)as select a.Id,b.Years,a.MinPub,a.MaxPub,a.AvgPub from EAIn4 a,EAIn2 b where a.Id=b.Id;
create or replace view Q19(Name,Years,MinPub, MaxPub, AvgPub)as select Person.Name,a.Years,a.MinPub,a.MaxPub,round(a.AvgPub) from Q19Id a,Person where Person.PersonId=a.Id order by 1;
--create or replace view Q19 as select ProceedingId,EditorId from Proceeding where EditorId is null;
--Q20
create function Q20() RETURNS trigger AS $$
begin
if new.PersonId <>
( select EditorId 
	from Proceeding 
	where ProceedingId=(select ProceedingId from InProceeding where InProceedingId=new.InProceedingId))then
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