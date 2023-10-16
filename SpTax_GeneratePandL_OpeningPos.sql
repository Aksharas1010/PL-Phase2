alter Procedure [dbo].[SpTax_GeneratePandL_OpeningPos]                
    (                                  
        @cid int,                                                                      
        @ToDate VarChar(12)                                                           
    )                                              
As                                              
Begin        
    
 set nocount on                                                                                                                    
 CREATE TABLE #TempOpeningPos (
    INSTRUMENT varchar(max),     
    FOCLIENTID int,    
    CONTRACT varchar(max),     
    SYMBOL varchar(max),         
    OptionType varchar(max),     
    BuySellQty int,    
    BUYSELL varchar(max),
	TRANDATE Date,
	StrikePrice Decimal(18,3),
	Rate Decimal(18,3)

);                       
    CREATE TABLE #TempOpeningPosCDS (
    INSTRUMENT varchar(max),     
    CLIENTID int,    
    CONTRACT varchar(max),     
    SYMBOL varchar(max),         
    OptionType varchar(max),     
    BuySellQty int,    
    BUYSELL varchar(max),
	TRANDATE Date,
	StrikePrice Decimal(18,3),
	Rate Decimal(18,3)

); 

    CREATE TABLE #OpeningPos (
    INSTRUMENT varchar(max),     
    CLIENTID int,    
    CONTRACT varchar(max),     
    SYMBOL varchar(max),         
    OptionType varchar(max),     
    Qty int,    
	TRANDATE Date,
	StrikePrice Decimal(18,3),
	AvgRate Decimal(18,3),
	Type varchar(50)

); 
                                  
 Declare @oldcln integer                                                  
 Declare @oldcln1 integer                                                  
 Declare @cln integer
 set @oldcln=@cid                                            
                                        
 Create Table #oldclnsdetFO ( clientid integer,Foclientid  integer)                                  
                                        
                                        
 Insert  into #oldclnsdetFO  ( clientid )  Values  ( @oldcln )                                                  
                                        
 While @oldcln > 0                                               
 Begin                                                  
  set @oldcln1 = 0                                   
                                        
  select  @oldcln1 = isnull(Clientid, 0)                                     
  from inacln (Nolock)                                              
  Where                                           
   Toclientid = @oldcln   and isnull(clientid,'') <> isnull(Toclientid,'')                                                 
                                        
  Set @oldcln = @oldcln1                                                  
                                        
  if @oldcln > 0                                               
   Insert  into #oldclnsdetFO (clientid ) Values  ( @oldcln )                                                  
 End                                    
                                  
  Update c set c.Foclientid = F.Foclientid                                   
  from #oldclnsdetFO c, Foclient F(nolock)                                  
  where                                   
    c.clientid=f.clientid                                  
--------------------------------------------                                                                 
 insert into #TempOpeningPos
 Select INSTRUMENT,FOCLIENTID,CONTRACT,SYMBOL,OptionType,
 case when BUYSELL='B' then QTY else -(Qty) end as BuySellQty,BUYSELL,TRANDATE,StrikePrice,Rate
 From Fosauda (Nolock)                                              
 Where (foclientid in (select Foclientid from #oldclnsdetFO))  And (TranDate <= @ToDate) ;
 
 insert into #OpeningPos
 select INSTRUMENT,FOCLIENTID,CONTRACT,SYMBOL,OptionType,Sum(BuySellQty)as Qty,TRANDATE,max(StrikePrice) as StrikePrice,Avg(Rate) as AvgRate,'EQ'  
 from #TempOpeningPos  group by INSTRUMENT,FOCLIENTID,CONTRACT,OptionType,SYMBOL,TRANDATE





 insert into #TempOpeningPosCDS
 Select Instrument,ClientID,Contract,Symbol,OptionType,
 case when BUYSELL='B' then QTY else -(Qty) end as BuySellQty,BUYSELL,TRANDATE,StrikePrice,Rate
 From CdsSauda (Nolock)                                              
 Where (ClientID in (1290375246))  And (TranDate <= @ToDate) 

 insert into #OpeningPos
 select Instrument,ClientID,Contract,Symbol,OptionType,Sum(BuySellQty)as Qty,TRANDATE,max(StrikePrice) as StrikePrice,Avg(Rate) as AvgRate,'CUR' 
 from #TempOpeningPosCDS  group by INSTRUMENT,ClientID,CONTRACT,OptionType,SYMBOL,TRANDATE


 select * from #OpeningPos where TRANDATE=@ToDate and Qty != 0

 drop table #oldclnsdetFO
 drop table #TempOpeningPos
 drop table #TempOpeningPosCDS
 drop table #OpeningPos
 end