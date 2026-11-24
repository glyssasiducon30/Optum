USE [MIS_SPOTLIGHT]
GO
/****** Object:  StoredProcedure [dbo].[Spotlight_PriorDaysReport_MemberServices_PBM]    Script Date: 7/2/2025 10:43:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/**/
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

--ALTER PROC [dbo].[Spotlight_PriorDaysReport_MemberServices_PBM]
	
--	@StartDate AS DATE,
--	@EndDate AS DATE

--AS
--BEGIN

--DECLARE 
		--@StartDate AS DATE = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1), --'2025-01-01', --CAST(DATEADD(d, -7, GETUTCDATE()) as date),
		--@EndDate AS DATE = CAST(DATEADD(d, -1, GETUTCDATE()) as date),  --'2025-05-06', --CAST(DATEADD(d, -1, GETUTCDATE()) as date),


	DECLARE @StartDate AS DATE, @EndDate AS DATE

	--SET @StartDate = CAST(DATEADD(dd, DATEDIFF(dd, 7, GETDATE()), 0) AS DATE)
	--SET @EndDate = CAST(DATEADD(dd, DATEDIFF(dd, 1, GETDATE()), 0) AS DATE)	

	SET @StartDate = '2025.09.01'
	SET @EndDate = '2025.09.30'

DECLARE @LineOfBusiness VARCHAR (255)=NULL , @fnLOB VARCHAR (255)=NULL
SET @LineOfBusiness = 'Member Services'
SET @fnLOB = 'OPTUM.V.OPTUMRX'


IF OBJECT_ID('tempdb..' + '#tmp_Spotlight_SublobgroupingforExecutive_Dashboard') IS NOT NULL 
BEGIN EXEC('DROP TABLE ' + '#tmp_Spotlight_SublobgroupingforExecutive_Dashboard') END

IF OBJECT_ID('tempdb..' + '#TempDemographics') IS NOT NULL 
BEGIN EXEC('DROP TABLE ' + '#TempDemographics') END

IF OBJECT_ID('tempdb..' + '#DemoForAHT') IS NOT NULL 
BEGIN EXEC('DROP TABLE ' + '#DemoForAHT') END

IF OBJECT_ID('tempdb..' + '#DemoForOccu') IS NOT NULL 
BEGIN EXEC('DROP TABLE ' + '#DemoForOccu') END 

IF OBJECT_ID('tempdb..' + '#OCCUPANCY_PBI') IS NOT NULL 
BEGIN EXEC('DROP TABLE ' + '#OCCUPANCY_PBI') END  

IF OBJECT_ID('tempdb..' + '#TempDemographicsOccu') IS NOT NULL 
BEGIN EXEC('DROP TABLE ' + '#TempDemographicsOccu') END

IF OBJECT_ID('tempdb..' + '#GenesysAgentAHTQueueForOccupancy') IS NOT NULL 
BEGIN EXEC('DROP TABLE ' + '#GenesysAgentAHTQueueForOccupancy') END

IF OBJECT_ID('tempdb..' + '#GenesysAgentNotReadyReasonCode_ForOccupancy') IS NOT NULL 
BEGIN EXEC('DROP TABLE ' + '#GenesysAgentNotReadyReasonCode_ForOccupancy') END 

IF OBJECT_ID('tempdb..' + '#Genesys_AHT_Occupancy') IS NOT NULL 
BEGIN EXEC('DROP TABLE ' + '#Genesys_AHT_Occupancy') END 

IF OBJECT_ID('tempdb..' + '#Genesys_Ready_Occupancy') IS NOT NULL 
BEGIN EXEC('DROP TABLE ' + '#Genesys_Ready_Occupancy') END 

IF OBJECT_ID('tempdb..' + '#OCCU_PBI') IS NOT NULL 
BEGIN EXEC('DROP TABLE ' + '#OCCU_PBI') END  
	
IF OBJECT_ID('tempdb..' + '#TMP_MAPPING_DETAILS') IS NOT NULL 
BEGIN EXEC('DROP TABLE ' + '#TMP_MAPPING_DETAILS') END

IF OBJECT_ID('tempdb..' + '#TempSpotlight_IEX_ExceptionCodeMapping') IS NOT NULL 
BEGIN EXEC('DROP TABLE ' + '#TempSpotlight_IEX_ExceptionCodeMapping') END

IF OBJECT_ID('tempdb..' + '#tmp_Spotlight_SublobgroupingforExecutive_Dashboard_Occu') IS NOT NULL 
BEGIN EXEC('DROP TABLE ' + '#tmp_Spotlight_SublobgroupingforExecutive_Dashboard_Occu') END

IF OBJECT_ID('tempdb..' + '#tmp_LH_VOICE_WFM_RPT_GENESYS_QUEUE_REFERENCE_OPTUMRX') IS NOT NULL
BEGIN EXEC('DROP TABLE ' + '#tmp_LH_VOICE_WFM_RPT_GENESYS_QUEUE_REFERENCE_OPTUMRX') END	

IF OBJECT_ID('tempdb..' + '#TMP_LH_VOICE_WFM_RPT_NICE_IEX_INTRADAY_DATA_ForOptumRx') IS NOT NULL 
BEGIN EXEC('DROP TABLE ' + '#TMP_LH_VOICE_WFM_RPT_NICE_IEX_INTRADAY_DATA_ForOptumRx') END

IF OBJECT_ID('tempdb..' + '#GenesysAgentAHTQueueDaywiseReportMultipleBusiness_View_OptumRx_TMP') IS NOT NULL 
BEGIN EXEC('DROP TABLE ' + '#GenesysAgentAHTQueueDaywiseReportMultipleBusiness_View_OptumRx_TMP') END

IF OBJECT_ID('tempdb..' + '#GenesysAgentNotReadyReasonCodeReportAgentActivityIntervalwiseforMultipleBusiness_TMP') IS NOT NULL 
BEGIN EXEC('DROP TABLE ' + '#GenesysAgentNotReadyReasonCodeReportAgentActivityIntervalwiseforMultipleBusiness_TMP') END

IF OBJECT_ID('tempdb..' + '#LH_VOICE_WFM_RPT_NICE_IEX_UTILIZATION_DATA_TMP') IS NOT NULL 
BEGIN EXEC('DROP TABLE ' + '#LH_VOICE_WFM_RPT_NICE_IEX_UTILIZATION_DATA_TMP') END

IF OBJECT_ID('tempdb..' + '#LH_VOICE_WFM_RPT_NICE_IEX_ADHERENCE_DATA_TMP') IS NOT NULL 
BEGIN EXEC('DROP TABLE ' + '#LH_VOICE_WFM_RPT_NICE_IEX_ADHERENCE_DATA_TMP') END

IF OBJECT_ID('tempdb..' + '#TempShrinkageBaseRaw') IS NOT NULL 
BEGIN EXEC('DROP TABLE ' + '#TempShrinkageBaseRaw') END

IF OBJECT_ID('tempdb..' + '#SHRINKAGEDATA_MS_PBM') IS NOT NULL
BEGIN EXEC('DROP TABLE ' + '#SHRINKAGEDATA_MS_PBM') END

IF OBJECT_ID('tempdb..' + '#Spotlight_OptumRx_AggTbl_PriorDaysReport_MS_PBM') IS NOT NULL 
BEGIN EXEC('DROP TABLE ' + '#Spotlight_OptumRx_AggTbl_PriorDaysReport_MS_PBM') END

IF OBJECT_ID('tempdb..' + '#Spotlight_OptumRx_PriorDays_Forecast') IS NOT NULL 
BEGIN EXEC('DROP TABLE ' + '#Spotlight_OptumRx_PriorDays_Forecast') END

IF OBJECT_ID('tempdb..' + '#SUB_LOB_ref') IS NOT NULL 
BEGIN EXEC('DROP TABLE ' + '#SUB_LOB_ref') END

IF OBJECT_ID('tempdb..' + '#TempPriorDaysreport') IS NOT NULL 
BEGIN EXEC('DROP TABLE ' + '#TempPriorDaysreport') END 

--------------SUB LOB GROUPING------------------

select distinct [FN_LOB],[Business],[LOB],
				CASE WHEN [Lighthouse Process Name] LIKE '%PBE Overnight%' THEN 'PBM OVN' ELSE [SUB LOB] END AS [SUB LOB],
				[LH Department Name],[Lighthouse Process Name], [Intraday - IEX MU], [Intraday_IEX_CT]
	into #tmp_Spotlight_SublobgroupingforExecutive_Dashboard
		from Spotlight_SublobgroupingforExecutive_Dashboard 
		where LOB = @LineOfBusiness
		AND [LH Department Name] = 'PHL PHARMACY MEMBER SRVCES OPT'
		--AND [Sub LOB] LIKE 'PBM%'
		--AND [Lighthouse Process Name] NOT LIKE '%PCS%'

		INSERT INTO #tmp_Spotlight_SublobgroupingforExecutive_Dashboard
		VALUES ('OPTUM.V.OPTUMRX', 'Optum Rx', 'Member Services', 'PBM Preferred','PHL PHARMACY MEMBER SRVCES OPT','Optum Rx Member Services - PBE Global Preferred - TBB',NULL, '9301') --TRAINING

		
		--AND [Is_Executive_Dashboard] = 1
		--AND [Intraday - IEX MU] IS NOT NULL

		---values not in Spotlight_SublobgroupingforExecutive_Dashboard tbl
	--INSERT INTO #tmp_Spotlight_SublobgroupingforExecutive_Dashboard
	--	VALUES ('OPTUM.V.OPTUMRX', 'TBB', 'Optum Rx', 'PHD', 'PHD', '846767', 'PHL PHARMACY HELPDESK OPTUM', 'OptumRx Pharmacy Helpdesk - TBB', 'OGA', '9003', '9003', NULL, NULL, 1) --TRAINING

	--		select * from #tmp_Spotlight_SublobgroupingforExecutive_Dashboard
	--Select * from Spotlight_SublobgroupingforExecutive_Dashboard

------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------



-------------IEX MAPPING FOR SHRINK DATA------------------

	SELECT 
		ID, 'OPTUM.V.OPTUMRX' AS FN_LOB, Exception_Code, [Definition], In_Office_Or_Out_Of_Office, Planned_Or_Unplanned, Consider_For_Total_Hours, 
		
		CASE 
			WHEN Category = 'Holiday' AND Planned_Or_Unplanned = 'Planned' AND In_Office_Or_Out_Of_Office = 'Out of Office' THEN 'Planned OOO'
			WHEN Category = 'Holiday' AND Planned_Or_Unplanned = 'Unplanned' AND In_Office_Or_Out_Of_Office = 'Out of Office' THEN 'Unplanned OOO'
			ELSE Category
		END AS Category, 
		
		Sub_Category,OT_Status, Avail_Code, Onshore_Bucket, Offshore_Bucket, Is_Excluded_From_Shrinkage, Is_Included_For_Present_Consideration, 
		Is_Included_For_Present_For_TU_Schedule_Activity, Remarks, In_Office_Shrink_WithBreakAndLunch, In_Office_Shrink_WithoutBreakAndLunch,
		In_Office_Shrink_WithoutLunch, Out_Of_Office_Shrink, [Status], TIME_STAMP
		INTO #TempSpotlight_IEX_ExceptionCodeMapping
		FROM dbo.Spotlight_IEX_ExceptionCodeMapping
	WHERE FN_LOB = @fnLOB
	AND [Status] = 1


	--select * from #TempSpotlight_IEX_ExceptionCodeMapping
-------------Genesys QUEUE Ref------------------

	select [FN_LOB],[QUEUE_NAME],[SUB_LOB],[SUB_LOB_FOR_DISPLAY],[IS_EXECUTIVE_DASBOARD]
		into #tmp_LH_VOICE_WFM_RPT_GENESYS_QUEUE_REFERENCE_OPTUMRX
	 from LH_VOICE_WFM_RPT_GENESYS_QUEUE_REFERENCE_OPTUMRX 
	 where SUB_LOB =  @LineOfBusiness
	 AND [SUB_LOB_FOR_DISPLAY] LIKE 'PBM %'
	 AND [IS_EXECUTIVE_DASBOARD] = 1

	 --Select * from #tmp_LH_VOICE_WFM_RPT_GENESYS_QUEUE_REFERENCE_OPTUMRX

-------------DEMOGRAPHICS------------------      

	SELECT  ROSTER_EFFECTIVE_DATE, EMP_ID, IEX_AGENT_ID, MS_ID ,FULL_NAME AS AGENT_NAME, LINE_OF_BUSINESS,
	ISNULL(GROUP_L5,'-') AS [Lighthouse Process Name], 
	ISNULL(SUPERVISOR,'-') AS SUPERVISOR, 
	ISNULL(DEPUTY_MANAGER, '-') AS DEPUTY_MANAGER, 
	SERVICE_DELIVERY_LEADER, BATCH, SEGMENT
	,CASE 
				WHEN [LOCATION] LIKE ('%Alabang%') THEN 'ALABANG'
				WHEN [LOCATION] LIKE ('%Cebu%') THEN 'CEBU'
				WHEN [LOCATION] LIKE ('%Makati%') THEN 'MAKATI'
				WHEN [LOCATION] LIKE ('%Quezon%') THEN 'QUEZON'
				WHEN [LOCATION] LIKE ('%McKinley%') THEN 'TAGUIG'
				WHEN [LOCATION] LIKE ('%Davao%') THEN 'DAVAO'
				ELSE [LOCATION]
			END AS [LOCATION],
	JOB_DESC
	INTO #TempDemographics 
	FROM Spotlight_EmployeeInformationDeriveFromLH
	WHERE ROSTER_EFFECTIVE_DATE between @STARTDATE AND  @ENDDATE
	AND GROUP_L4 = 'PHL PHARMACY MEMBER SRVCES OPT'
	AND LINE_OF_BUSINESS ='Optum Rx'
	AND GROUP_L5 IN (select distinct [Lighthouse Process Name] from #tmp_Spotlight_SublobgroupingforExecutive_Dashboard)

	Option(recompile)


--Select * from #TempDemographics

-------------------------------------------------------------------------------------------------------------------------



SELECT 
		DISTINCT 
				BN.BUSINESS_NAME_FOR_DISPLAY, 
				BN_SUB.FN_LOB, 
				BN_REF.LOB, 
				BN_SUB.SUB_LOB AS MAIN_LOB,
				BN_SUB.SUB_LOB_VAL_AS_PER_OPS, 
				SKILLORVQ.[SOURCE],
				BN_SUB.[SPAN LEADER],
				BN_SUB.[BL LEADER]
INTO #TMP_MAPPING_DETAILS
FROM Spotlight_BusinessName BN
INNER JOIN Spotlight_Business_SubLobRel BN_SUB ON BN.BUSINESS_NAME_ID = BN_SUB.BUSINESS_NAME_ID
INNER JOIN LH_VOICE_WFM_PMS_BusinessRef BN_REF ON BN_SUB.BUSINESS_ID = BN_REF.BUSINESS_ID
LEFT JOIN (
			SELECT 
				DISTINCT 
				SUB_LOB_ID, 
				[SOURCE] 
			FROM Spotlight_BusinessSubLobCMSSkillRel
		   ) SKILLORVQ 
		   ON BN_SUB.SUB_LOB_ID = SKILLORVQ.SUB_LOB_ID
WHERE BN.[STATUS] = 1 and BN_SUB.[STATUS] = 1
AND BN_SUB.SUB_LOB = @LineOfBusiness
and BN_SUB.FN_LOB = 'OPTUM.V.OPTUMRX'



SELECT [FN_LOB],[Billing Model],[Business],[LOB],[Sub LOB],[LH Department ID],[LH Department Name],[Lighthouse Process Name],[OGA or Enterprise],[Intraday - IEX MU],[Intraday_IEX_CT],[SUB_LOB_FOR_UNKNOWN],[DEFAULT_SUB_LOB],[Is_Executive_Dashboard],[Intraday_IEX_CT_NAME],  [Intraday_IEX_CT_NAME_EFFECTIVE_START_DATE], [Intraday_IEX_CT_NAME_EFFECTIVE_END_DATE]  ---------ADDED AS IEX_GROUP FROM INTRADAY BASE TABLE HAS 2 VERSIONS
		
		INTO #tmp_Spotlight_SublobgroupingforExecutive_Dashboard_Occu
		from Spotlight_SublobgroupingforMSPCSPriorDaysReport with(nolock) --new table, update as needed. 
		where FN_LOB = 'OPTUM.V.OPTUMRX' 
		AND [LOB] IN (select distinct MAIN_LOB from #TMP_MAPPING_DETAILS)
		AND [Sub LOB] LIKE ('%PBM%')
		AND [Intraday - IEX MU] IS NOT NULL
		--AND [Intraday_IEX_CT_NAME_EFFECTIVE_START_DATE] <= @dtToDate 
		--AND ([Intraday_IEX_CT_NAME_EFFECTIVE_END_DATE] >= @dtFromDate or [Intraday_IEX_CT_NAME_EFFECTIVE_END_DATE] IS NULL)

	--INSERT INTO #tmp_Spotlight_SublobgroupingforExecutive_Dashboard
	--		VALUES ('OPTUM.V.OPTUMRX',	'FTE',	'Optum Rx',	'Member Services',	'PBM OVN',	'846768', 'PHL PHARMACY MEMBER SRVCES OPT',	'Optum Rx Member Services - PCS Overnight - FTE', 'OGA',	'-', '-',	NULL, NULL, NULL, NULL, NULL, NULL) --PBM OVN



-------------------------------------------------------------------------------------------------------------------------




/**/
/*****TARGET TEMP TABLE TO STORE FINAL OUTPUT*************/

DECLARE @sqlString AS VARCHAR(MAX) = ''

Create TABLE #Spotlight_OptumRx_AggTbl_PriorDaysReport_MS_PBM
	(	
	--[ID] [bigint] IDENTITY(1,1) NOT NULL,
		 [MONTH]  NVARCHAR (50) NULL
		,[RPTDATE] NVARCHAR (50) NULL
		,[METRIC] VARCHAR(50) NULL
		,[CT] NVARCHAR (50) NULL
		,[IEX_GROUP] NVARCHAR (50) NULL
		,[LOB] varchar (50) NULL
		,[Sub LOB] varchar (50) NULL
		,CONTACTS_RECVD_REVISED NUMERIC(32,6) NULL  
		 ,CONTACTS_RECVD_ACT NUMERIC(32,6) NULL 
		 ,CONTACTS_ABNDN_ACT NUMERIC(32,6) NULL 
		 ,AHT_ACT NUMERIC(32,6) NULL 
		 ,SERVICE_LEVEL_ACT NUMERIC(32,6) NULL 
		 ,OCCUPANCY_ACT NUMERIC(32,6) NULL 
		 ,ASA_ACT NUMERIC(32,6) NULL  
		 ,Handled_Actual_Contacts NUMERIC(32,6) NULL  
		 ,[Avail] NUMERIC(32,6) NULL
		 ,AHT_Calc NUMERIC(32,6) NULL 
		 ,SL_Calc NUMERIC(32,6) NULL  
		 ,ASA_Calc NUMERIC(32,6) NULL
		,[Queue] nvarchar (50) NULL
		,[Calls_Handled] NUMERIC(32,6) NULL
		,[n_average_handle_time] NUMERIC(32,6) NULL
		,[d_average_handle_time] NUMERIC(32,6) NULL
		,[Engage Time] NUMERIC(32,6) NULL
		,[Wrap Time] NUMERIC(32,6) NULL
		,[Hold Time] NUMERIC(32,6) NULL
		,[Busy Time] NUMERIC(32,6) NULL
		,[Calls_Handled_Occupancy] NUMERIC(32,6) NULL
		,[n_average_handle_time_Occupancy] NUMERIC(32,6) NULL
		,[d_average_handle_time_Occupancy] NUMERIC(32,6) NULL 
		,[Engage_Time_Occupancy] NUMERIC(32,6) NULL
		,[Wrap_Time_Occupancy] NUMERIC(32,6) NULL
		,[Hold_Time_Occupancy] NUMERIC(32,6) NULL		
		,[Ready_Time_Occupancy] NUMERIC(32,6) NULL
		,[MU_ID] NVARCHAR (50) NULL
        ,N_OOO NUMERIC(32,6) NULL
		,N_IO NUMERIC(32,6) NULL
		,N_SHRINKAGE NUMERIC(32,6) NULL
        ,N_VTO NUMERIC(32,6) NULL
		,N_LOST_HRS NUMERIC(32,6) NULL
		,N_OT NUMERIC(32,6) NULL
        ,D_SHRINKAGE NUMERIC(32,6) NULL
		,[Call Forecast Original] NUMERIC(32,6) NULL
		,[Call Forecast Revised] NUMERIC(32,6) NULL
		,[AHT Original (Goal)] NUMERIC(32,6) NULL
		,[AHT Revised (Goal)] NUMERIC(32,6) NULL
		,Shrinkage_Target NUMERIC(32,6) NULL

	)

	--DECLARE 
	--		@Date as date = ''
	--	SET @Date = @StartDate

	CREATE NONCLUSTERED INDEX ixSpotlight_OptumRx_AggTbl_PriorDaysReport_MS_PBM ON #Spotlight_OptumRx_AggTbl_PriorDaysReport_MS_PBM ([RPTDATE]) INCLUDE([Sub LOB], [MU_ID], [CT], [Queue])
--CREATE TABLE #BASE_Spotlight_OptumRx_AggTbl_PriorDaysReport_MS_PBM



Create TABLE #OCCUPANCY_PBI
	(	
		--[ID] [bigint] IDENTITY(1,1) NOT NULL,
		 [RPTDATE] NVARCHAR (50) NULL,
		 --[RESOURCE_NAME] NVARCHAR (50) NULL,
		 [LOB] varchar (50) NULL,
		 [Sub LOB] varchar (50) NULL, 
		 [Calls_Handled_Occupancy]  NUMERIC(32,6) NULL, 
		 [n_average_handle_time_Occupancy]  NUMERIC(32,6) NULL, 
		 [d_average_handle_time_Occupancy]  NUMERIC(32,6) NULL, 
		 [Engage_Time_Occupancy]  NUMERIC(32,6) NULL, 
		 [Wrap_Time_Occupancy]  NUMERIC(32,6) NULL, 
		 [Hold_Time_Occupancy]  NUMERIC(32,6) NULL,
		[Ready_Time_Occupancy]  NUMERIC(32,6) NULL


	)
		

	CREATE NONCLUSTERED INDEX ixOCCUPANCY_PBI ON #OCCUPANCY_PBI ([RPTDATE]) INCLUDE([Sub LOB],LOB)

--CREATE 


CREATE TABLE #SHRINKAGEDATA_MS_PBM
([RPTDATE] DATE, [METRIC] VARCHAR (50), [LOB] VARCHAR (50),[Sub LOB] VARCHAR (50), [MU_ID] NVARCHAR (50), [SchedTime] NUMERIC (32,6), [ActualTime] NUMERIC (32,6), [Duration_in_hours] NUMERIC (32,6), [Is_Excluded_From_Shrinkage] INT, [Consider_For_Total_Hours] INT, [ExShrink] NUMERIC (32,6), [CFTH] NUMERIC (32,6), [In_Office_Total] NUMERIC (32,6), [Out_Of_Office_Total] NUMERIC (32,6), [LostTime_Total] NUMERIC (32,6), [_OpenTime] NUMERIC (32,6), [_LT_OpenTime]NUMERIC (32,6), [_OT] NUMERIC (32,6), [_VTO] NUMERIC (32,6)
)
---PREPARATION IEX INTRADAY DATA (FOR OPTUM RX - MS PBM)

	SELECT 
			RPTDATE,
				[CT],
				[IEX_GROUP],
				[LOB],
				[Sub LOB],
				CONTACTS_RECVD_REVISED,
				CONTACTS_RECVD_ACT,
				CONTACTS_ABNDN_ACT,
				AHT_ACT,
				SERVICE_LEVEL_ACT,
				OCCUPANCY_ACT,
				ASA_ACT,
				Handled_Actual_Contacts,
				CASE WHEN OCCUPANCY_ACT = 0 THEN 0
					ELSE (Handled_Actual_Contacts * AHT_ACT / (OCCUPANCY_ACT/100.0) - (Handled_Actual_Contacts) * AHT_ACT)
					END AS [Avail],
				Handled_Actual_Contacts * AHT_ACT as AHT_Calc,
				SERVICE_LEVEL_ACT * CONTACTS_RECVD_ACT as SL_Calc,
				ASA_ACT * Handled_Actual_Contacts as ASA_Calc

		INTO #TMP_LH_VOICE_WFM_RPT_NICE_IEX_INTRADAY_DATA_ForOptumRx 
	FROM (
			SELECT 
				INTRADAY_DATA.RPTDATE,
				[CT],
				[IEX_GROUP],
				[LOB],
				[Sub LOB],
				SUM(TRY_CAST(REPLACE(CONTACTS_RECVD_REVISED, ',','') AS DECIMAL(10,2))) as CONTACTS_RECVD_REVISED,
				CONTACTS_RECVD_ACT,
				CONTACTS_ABNDN_ACT,
				AHT_ACT,
				SERVICE_LEVEL_ACT,
				OCCUPANCY_ACT,
				ASA_ACT,
				CONTACTS_RECVD_ACT - CONTACTS_ABNDN_ACT AS Handled_Actual_Contacts			
				FROM LH_VOICE_WFM_RPT_NICE_IEX_INTRADAY_DATA_ForOptumRx INTRADAY_DATA
					INNER JOIN #tmp_Spotlight_SublobgroupingforExecutive_Dashboard mapping ON INTRADAY_DATA.[CT] = mapping.[Intraday_IEX_CT]
					where CT IN (select distinct Intraday_IEX_CT from  #tmp_Spotlight_SublobgroupingforExecutive_Dashboard) 
					AND RPTDATE BETWEEN @StartDate AND @EndDate
					AND TIME_INTERVAL_60_MINUTES = '02:30'
				GROUP BY RPTDATE, [CT],[IEX_GROUP],[LOB], [Sub LOB], CONTACTS_RECVD_ACT,
				CONTACTS_ABNDN_ACT,
				AHT_ACT,
				SERVICE_LEVEL_ACT,
				OCCUPANCY_ACT,
				ASA_ACT
					)tmpINTRADAYDATA
				GROUP BY RPTDATE,
				[CT],
				[IEX_GROUP],
				[LOB],
				[Sub LOB], CONTACTS_RECVD_REVISED,
				CONTACTS_RECVD_ACT,
				CONTACTS_ABNDN_ACT,
				AHT_ACT,
				SERVICE_LEVEL_ACT,
				OCCUPANCY_ACT,
				ASA_ACT,
				Handled_Actual_Contacts

				option(recompile);


		SELECT [RPTDATE], [MEDIA_NAME], /* [AGENT_NAME], [RESOURCE_NAME],*/ 
	--[Active Time], 
	[RESOURCE_NAME],

	[Busy Time], 
	--[Not Ready Time], [Wrap Time], 
	[LOB], 
	[Sub LOB], [Lighthouse Process Name]
		 INTO #GenesysAgentNotReadyReasonCodeReportAgentActivityIntervalwiseforMultipleBusiness_TMP
	FROM
		(	SELECT 
			[SHIFT_DATE] as [RPTDATE],[MEDIA_NAME], demogs.[Lighthouse Process Name]
			,[RESOURCE_NAME]
			--,SUM([Ready Time]) as [Ready Time]     --formula for occupancy
			,SUM([Busy Time]) as [Busy Time]
			,subLOB.[LOB]
			,CASE WHEN demogs.[Lighthouse Process Name] LIKE '%PBE Overnight%' THEN 'PBM OVN'
				ELSE subLOB.[SUB LOB] 
				END AS [Sub LOB]
			
		 from GenesysAgentNotReadyReasonCodeReportAgentActivityIntervalwiseforMultipleBusiness nr
		inner join #TempDemographics demogs ON nr.[RESOURCE_NAME] = demogs.[MS_ID]
			AND nr.SHIFT_DATE = demogs.[ROSTER_EFFECTIVE_DATE]
		INNER JOIN #tmp_Spotlight_SublobgroupingforExecutive_Dashboard subLOB ON demogs.[Lighthouse Process Name] = subLOB.[Lighthouse Process Name]

		--INNER JOIN #SUB_LOB_ref subLOB ON nr.RESOURCE_NAME = subLOB.[Resource Name]

		where SHIFT_DATE  between @StartDate and @EndDate --'2025-02-01' and CAST(dateadd(d,-1, GETUTCDATE()) as date)
		 AND demogs.[Lighthouse Process Name] IN (select distinct [Lighthouse Process Name] from #tmp_Spotlight_SublobgroupingforExecutive_Dashboard 
		 WHERE LOB = @LineOfBusiness 
		 )
		 GROUP BY [SHIFT_DATE],[MEDIA_NAME], subLOB.[LOB], subLOB.[Sub LOB], demogs.[Lighthouse Process Name], [RESOURCE_NAME]
		 )tmpNOTREADYDATA
		 ORDER BY [RPTDATE]

		 option(recompile);


			--Select * from #TMP_LH_VOICE_WFM_RPT_NICE_IEX_INTRADAY_DATA_ForOptumRx 
---PREPARATION IEX VOL and AHT DATA (FOR OPTUM RX - MS PBM) -- Agent Queue Report Adjusted
--------------DEMOGRAPHICS FOR AHT----------------------------------------------------------------------------

	SELECT  ROSTER_EFFECTIVE_DATE, MS_ID,
	ISNULL(GROUP_L5,'-') AS [Lighthouse Process Name]
	,[Location]

	INTO #DemoForAHT
	FROM Spotlight_EmployeeInformationDeriveFromLH
	WHERE ROSTER_EFFECTIVE_DATE between @STARTDATE AND  @ENDDATE
	AND LINE_OF_BUSINESS ='Optum Rx'

	Option(recompile)

	--Select * from #DemoForAHT




	select [RPTDATE], [Resource Name], [Queue], [Interaction Type], [FN_LOB], [LOB], [Sub LOB], [Calls_Handled], [n_average_handle_time], [d_average_handle_time], [Engage Time], [Wrap Time], [Hold Time], [Handle_Time_Occu]
			,[Lighthouse Process Name]
		into #GenesysAgentAHTQueueDaywiseReportMultipleBusiness_View_OptumRx_TMP
	FROM ( 
	
	
	SELECT
			CAST([day] as date) as [RPTDATE]
			,[Resource Name]
			,CASE 
				WHEN [Queue] LIKE ('VQ_OPT_OptumRx_%') THEN
				SUBSTRING([Queue], LEN ('VQ_OPT_OptumRx_') + 1, LEN([Queue]))
				ELSE NULL 
				END AS [Queue]
			,[Interaction Type]
			,[FN_LOB]
			,gen.[SUB_LOB] AS [LOB]
			--,[SUB_LOB_FOR_DISPLAY] as [Sub LOB]
			,CASE WHEN [Lighthouse Process Name] LIKE '%PBE Overnight%' THEN 'PBM OVN'
				ELSE [SUB_LOB_FOR_DISPLAY] 
				END AS [Sub LOB]
			--,[SUB_LOB_FOR_DISPLAY] as [Sub LOB]
			,SUM([Calls_Handled]) as [Calls_Handled]
			,SUM([n_average_handle_time]) as [n_average_handle_time]
			,SUM([d_average_handle_time]) as [d_average_handle_time]
			,SUM([Engage Time]) as [Engage Time]
			,SUM([Wrap Time]) as [Wrap Time]
			,SUM([Hold Time]) as [Hold Time]
			,(SUM([Calls_Handled]) * SUM([n_average_handle_time])) as [Handle_Time_Occu]
			,[Lighthouse Process Name]
			

				from GenesysAgentAHTQueueDaywiseReportMultipleBusiness_View_OptumRx gen
				INNER JOIN #DemoForAHT demogs ON demogs.MS_ID = gen.[Resource Name] AND demogs.ROSTER_EFFECTIVE_DATE = cast(gen.[day] as date) -- added to filter MS agents only
				where
					 [Queue] in (select distinct QUEUE_NAME from #tmp_LH_VOICE_WFM_RPT_GENESYS_QUEUE_REFERENCE_OPTUMRX)
					 AND  CAST([day] as date) between @StartDate and @EndDate
					 GROUP BY CAST([day] as date), [Resource Name], [Queue], [Interaction Type], [FN_LOB], gen.[SUB_LOB], [SUB_LOB_FOR_DISPLAY]
					 ,[Lighthouse Process Name],[Location]
						)tmpGENESYSDATA
					ORDER BY [RPTDATE]

			option(recompile);

			CREATE NONCLUSTERED INDEX [TMP_AHTQueue_Resource Name]
				ON [dbo].[#GenesysAgentAHTQueueDaywiseReportMultipleBusiness_View_OptumRx_TMP]([Resource Name])
				INCLUDE ([RPTDATE],[Queue])

--Select * from #GenesysAgentAHTQueueDaywiseReportMultipleBusiness_View_OptumRx_TMP


-------------------------------------------------------------------------------------------------------------------------------

---PREPARATION Agent Activity (Occupancy) (FOR OPTUM RX - MS PBM) -- Agent Not Ready Reason
--For OCCUPANCY and AVAIL-----------------------------------------------------------------------------------------------------------------------------
--------------DEMOGRAPHICS FOR OCCUPANCY----------------------------------------------------------------------------

	SELECT  ROSTER_EFFECTIVE_DATE, MS_ID,
	ISNULL(GROUP_L5,'-') AS [Lighthouse Process Name],
	GROUP_L3

	INTO #DemoForOccu
	FROM Spotlight_EmployeeInformationDeriveFromLH
	WHERE ROSTER_EFFECTIVE_DATE between @STARTDATE AND  @ENDDATE
	AND LINE_OF_BUSINESS ='Optum Rx'
	AND GROUP_L4 = 'PHL PHARMACY MEMBER SRVCES OPT'
	AND GROUP_L5 NOT LIKE '%PCS%'
	AND GROUP_L3 NOT LIKE '%Support%'

	Option(recompile)

	--Select * from #DemoForAHT


	select [RPTDATE], [Resource Name] as [RESOURCE_NAME],
	[Queue], [Interaction Type], [FN_LOB], [LOB], [Sub LOB], [Calls_Handled_Occupancy], [n_average_handle_time_Occupancy], [d_average_handle_time_Occupancy], [Engage_Time_Occupancy], [Wrap_Time_Occupancy], [Hold_Time_Occupancy]
			,[Lighthouse Process Name]
		into #GenesysAgentAHTQueueForOccupancy
	FROM ( 
	
	
	SELECT
			CAST([day] as date) as [RPTDATE]
			,[Resource Name]
			,CASE 
				WHEN [Queue] LIKE ('VQ_OPT_OptumRx_%') THEN
				SUBSTRING([Queue], LEN ('VQ_OPT_OptumRx_') + 1, LEN([Queue]))
				ELSE NULL 
				END AS [Queue]
			,[Interaction Type]
			,[FN_LOB]
			,gen.[SUB_LOB] AS [LOB]
			,CASE WHEN [Lighthouse Process Name] LIKE '%PBE Overnight%' THEN 'PBM OVN'
				ELSE [SUB_LOB_FOR_DISPLAY] 
				END AS [Sub LOB]
			,SUM([Calls_Handled]) as [Calls_Handled_Occupancy]
			,SUM([n_average_handle_time]) as [n_average_handle_time_Occupancy]
			,SUM([d_average_handle_time]) as [d_average_handle_time_Occupancy]
			,SUM([Engage Time]) as [Engage_Time_Occupancy]
			,SUM([Wrap Time]) as [Wrap_Time_Occupancy]
			,SUM([Hold Time]) as [Hold_Time_Occupancy]
			,[Lighthouse Process Name]
			

		from GenesysAgentAHTQueueDaywiseReportMultipleBusiness_View_OptumRx gen
				INNER JOIN #DemoForOccu demogs ON demogs.MS_ID = gen.[Resource Name] AND demogs.ROSTER_EFFECTIVE_DATE = cast(gen.[day] as date) -- added to filter MS agents only
				where
					 [Queue] in (select distinct QUEUE_NAME from #tmp_LH_VOICE_WFM_RPT_GENESYS_QUEUE_REFERENCE_OPTUMRX)
					 AND  CAST([day] as date) between @StartDate and @EndDate
					 GROUP BY CAST([day] as date), [Resource Name], [Queue], [Interaction Type], [FN_LOB], gen.[SUB_LOB], [SUB_LOB_FOR_DISPLAY]
					 ,[Lighthouse Process Name]
						)tmpGENESYSDATA
					ORDER BY [RPTDATE]

			option(recompile);

			CREATE NONCLUSTERED INDEX [TMP_AHTQueue_Resource Name_Occu]
				ON [dbo].[#GenesysAgentAHTQueueDaywiseReportMultipleBusiness_View_OptumRx_TMP]([Resource Name])
				INCLUDE ([RPTDATE],[Queue])


		--Select * from #GenesysAgentAHTQueueForOccupancy


	Select distinct [RESOURCE_NAME], [Sub LOB], [Lighthouse Process Name], LOB
		INTO #SUB_LOB_ref
		FROM #GenesysAgentAHTQueueForOccupancy

  option(recompile)


	select [RPTDATE], [RESOURCE_NAME],[LOB], [Sub LOB],
	  SUM([Calls_Handled_Occupancy]) AS [Calls_Handled_Occupancy], SUm([n_average_handle_time_Occupancy]) AS [n_average_handle_time_Occupancy], SUM([d_average_handle_time_Occupancy]) AS [d_average_handle_time_Occupancy], SUM([Engage_Time_Occupancy]) AS [Engage_Time_Occupancy], SUM([Wrap_Time_Occupancy]) AS [Wrap_Time_Occupancy], SUM([Hold_Time_Occupancy]) AS [Hold_Time_Occupancy]

		into #Genesys_AHT_Occupancy
		FROM #GenesysAgentAHTQueueForOccupancy
		GROUP BY [RPTDATE], [RESOURCE_NAME],[LOB], [Sub LOB]

	--Select * from #Genesys_AHT_Occupancy


	SELECT [RPTDATE], [MEDIA_NAME],
	[RESOURCE_NAME],
	[Ready_Time_Occupancy],
	[LOB], 
	[Sub LOB], [Lighthouse Process Name]
		 INTO #GenesysAgentNotReadyReasonCode_ForOccupancy
	FROM
		(	SELECT 
			[SHIFT_DATE] as [RPTDATE],[MEDIA_NAME], demogs.[Lighthouse Process Name]
			,nr.[RESOURCE_NAME]
			,SUM([Ready Time]) as [Ready_Time_Occupancy]     --formula for occupancy
			,subLOB.[LOB]
			,CASE WHEN demogs.[Lighthouse Process Name] LIKE '%PBE Overnight%' THEN 'PBM OVN'
				ELSE subLOB.[SUB LOB] 
				END AS [Sub LOB]
			
		 from GenesysAgentNotReadyReasonCodeReportAgentActivityIntervalwiseforMultipleBusiness nr
		inner join #DemoForOccu  demogs ON nr.[RESOURCE_NAME] = demogs.[MS_ID]
			AND nr.SHIFT_DATE = demogs.[ROSTER_EFFECTIVE_DATE]
		--INNER JOIN #tmp_Spotlight_SublobgroupingforExecutive_Dashboard subLOB ON demogs.[Lighthouse Process Name] = subLOB.[Lighthouse Process Name]

		INNER JOIN #SUB_LOB_ref subLOB ON nr.RESOURCE_NAME = subLOB.[RESOURCE_NAME]

		where SHIFT_DATE  between @StartDate and @EndDate --'2025-02-01' and CAST(dateadd(d,-1, GETUTCDATE()) as date)
		 AND demogs.[Lighthouse Process Name] IN (select distinct [Lighthouse Process Name] from #tmp_Spotlight_SublobgroupingforExecutive_Dashboard 
		 WHERE LOB = @LineOfBusiness 
		 --GROUP BY [SHIFT_DATE],[MEDIA_NAME], demogs.[Lighthouse Process Name],nr.[RESOURCE_NAME]
		 )
		 GROUP BY [SHIFT_DATE]
		 ,[MEDIA_NAME],  demogs.[Lighthouse Process Name], nr.[RESOURCE_NAME], subLOB.[LOB], subLOB.[Sub LOB]
		
		 )tmpNOTREADYDATA
		 ORDER BY [RPTDATE]

		 option(recompile);

	--Select * from #GenesysAgentNotReadyReasonCode_ForOccupancy


		SELECT [RPTDATE],
	[RESOURCE_NAME],
	SUM([Ready_Time_Occupancy]) AS [Ready_Time_Occupancy],
	[LOB], 
	[Sub LOB]
		 INTO #Genesys_Ready_Occupancy
		 FROM #GenesysAgentNotReadyReasonCode_ForOccupancy
		 GROUP BY [RPTDATE],[RESOURCE_NAME],[LOB], [Sub LOB]

	--Select * from #Genesys_Ready_Occupancy
	


	INSERT INTO #OCCUPANCY_PBI

	( [RPTDATE],
		--[RESOURCE_NAME], 
		[LOB], [Sub LOB], [Calls_Handled_Occupancy], [n_average_handle_time_Occupancy], [d_average_handle_time_Occupancy], [Engage_Time_Occupancy], [Wrap_Time_Occupancy], [Hold_Time_Occupancy],
		[Ready_Time_Occupancy])
			
	SELECT AHT.[RPTDATE], 
		--AHT.[RESOURCE_NAME], 
		AHT.[LOB], AHT.[Sub LOB], SUM(AHT.[Calls_Handled_Occupancy]) AS [Calls_Handled_Occupancy] , SUM(AHT.[n_average_handle_time_Occupancy]) AS [n_average_handle_time_Occupancy], SUM(AHT.[d_average_handle_time_Occupancy]) AS [d_average_handle_time_Occupancy], SUM(AHT.[Engage_Time_Occupancy]) AS [Engage_Time_Occupancy], SUM(AHT.[Wrap_Time_Occupancy]) AS [Wrap_Time_Occupancy], SUM(AHT.[Hold_Time_Occupancy]) AS [Hold_Time_Occupancy]
			, 0 [Ready_Time_Occupancy]
		FROM #Genesys_AHT_Occupancy AHT
		GROUP BY [RPTDATE], [RESOURCE_NAME], [LOB], [Sub LOB], [Calls_Handled_Occupancy], [n_average_handle_time_Occupancy], [d_average_handle_time_Occupancy], [Engage_Time_Occupancy], [Wrap_Time_Occupancy], [Hold_Time_Occupancy]

	UNION ALL

		SELECT [RPTDATE], 
			--Ready.[RESOURCE_NAME], 
			[LOB], [Sub LOB], 0 [Calls_Handled_Occupancy], 0 [n_average_handle_time_Occupancy], 0 [d_average_handle_time_Occupancy], 0 [Engage_Time_Occupancy], 0 [Wrap_Time_Occupancy], 0 [Hold_Time_Occupancy]
			, SUM(Ready.[Ready_Time_Occupancy]) AS [Ready_Time_Occupancy]
		FROM #Genesys_Ready_Occupancy Ready
		GROUP BY [RPTDATE], [RESOURCE_NAME], [LOB], [Sub LOB],[Ready_Time_Occupancy]

		option(recompile);


		--Select * from  #OCCUPANCY_PBI

	SELECT [RPTDATE],
		[LOB], [Sub LOB], SUM([Calls_Handled_Occupancy]) AS [Calls_Handled_Occupancy], 
		SUM([n_average_handle_time_Occupancy]) AS [n_average_handle_time_Occupancy], SUM([d_average_handle_time_Occupancy]) AS [d_average_handle_time_Occupancy], SUM([Engage_Time_Occupancy]) AS [Engage_Time_Occupancy], SUM([Wrap_Time_Occupancy]) AS [Wrap_Time_Occupancy], SUM([Hold_Time_Occupancy]) AS [Hold_Time_Occupancy],
		SUM([Ready_Time_Occupancy]) AS [Ready_Time_Occupancy]
	INTO #OCCU_PBI
	FROM #OCCUPANCY_PBI
	GROUP BY [RPTDATE],[LOB], [Sub LOB]

	--SELECT * FROM #OCCU_PBI
		



----------------------------------------------------------------------------------------------------------------------------------------
-- SHRINKAGE
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
IF OBJECT_ID('tempdb..' + '#ShrinkageMetrics') IS NOT NULL 
BEGIN EXEC('DROP TABLE ' + '#ShrinkageMetrics') END
IF OBJECT_ID('tempdb..' + '#ShrinkageMetricsRaw') IS NOT NULL 
BEGIN EXEC('DROP TABLE ' + '#ShrinkageMetricsRaw') END
IF OBJECT_ID('tempdb..' + '#ShrinkageMetricsTbl') IS NOT NULL 
BEGIN EXEC('DROP TABLE ' + '#ShrinkageMetricsTbl') END

        CREATE TABLE #ShrinkageMetrics
		(Type VARCHAR(50),	Align VARCHAR(50),	RptDate VARCHAR(50),	[Date] VARCHAR(50),	MU_ID VARCHAR(50),	SUB_LOB VARCHAR(50),	[Agent Name] VARCHAR(50),	[Agent ID] VARCHAR(50),	MS_ID VARCHAR(50),	
		[Location] VARCHAR(50),	Supervisor VARCHAR(50),	Manager VARCHAR(50),	SDL VARCHAR(50),	Exception VARCHAR(50),	SchedTime NUMERIC (18,4),	ActualTime NUMERIC (18,4),	Duration_in_hours NUMERIC (18,4),
		UniqueCateg VARCHAR(50),	UniqueSubCateg VARCHAR(50),	OT_Status VARCHAR(50),	SUB_CATEGORY VARCHAR(50),	CATEGORY VARCHAR(50),	Is_Excluded_From_Shrinkage NUMERIC (18,4),	Consider_For_Total_Hours NUMERIC (18,4),	
		ExShrink NUMERIC (18,4),	CFTH NUMERIC (18,4),	In_Office_Total NUMERIC (18,4),	Out_Of_Office_Total NUMERIC (18,4),	Productive_Total NUMERIC (18,4),	LostTime_Total NUMERIC (18,4),	_VTO NUMERIC (18,4),	
		_Holiday NUMERIC (18,4),	_NonPhone NUMERIC (18,4),	_OT_Productive NUMERIC (18,4),	_OT_InOffice NUMERIC (18,4),	_OT_Absent NUMERIC (18,4),	_OT_Cancelled NUMERIC (18,4),	_OT NUMERIC (18,4),	_Unplanned_Absent_Count NUMERIC (18,4),	
		_Planned_Absent_Count NUMERIC (18,4),	_OpenTime NUMERIC (18,4),	_LT_OpenTime NUMERIC (18,4),	_Sched_Count NUMERIC (18,4),	_SignedOn NUMERIC (18,4),	_Lunch_Actual_Auxes NUMERIC (18,4),	_Lunch_Sched_Auxes NUMERIC (18,4))



	INSERT INTO #ShrinkageMetrics
        EXEC   [dbo].[Spotlight_MemberServices_PBM_Shrinkage_Report]
        @StartDate = @StartDate,
        @EndDate= @EndDate,
        @Manager =NULL,
        @Supervisor=NULL,
        @Location =NULL,
        @SubLOB =NULL,
        @Mode= 'Dashboard'



		SELECT RptDate AS [DATE],MU_ID,SUB_LOB as [SUB LOB],[Agent Name] AS Agent_Name,[Agent ID] AS Agent_ID,MS_ID,[Location],Supervisor,Manager
		,SUM(CFTH) AS D_SHRINKAGE,
		SUM(In_Office_Total) AS N_IO,
		SUM(Out_Of_Office_Total) AS N_OOO,
		(SUM(Out_Of_Office_Total)+SUM(In_Office_Total)) AS N_SHRINKAGE
		,SUM(_VTO) AS N_VTO,
		SUM(_OT_Productive) AS N_OT,
		SUM(_LT_OpenTime) AS N_LOST_HRS
		--SUM(LostTime_Total) AS N_LOST_HRS
		INTO #ShrinkageMetricsRaw
		FROM #ShrinkageMetrics
		WHERE Align = 4
		GROUP BY RptDate,MU_ID,SUB_LOB,[Agent Name],[Agent ID],MS_ID,[Location],Supervisor,Manager

		Option(recompile)


		 SELECT 
        [Date] as [RPTDATE],[SUB LOB], MU_ID
        ,SUM(N_OOO) AS N_OOO,
		SUM(N_IO) AS N_IO,
		SUM (N_SHRINKAGE) AS  N_SHRINKAGE
        ,SUM(N_VTO) AS N_VTO, 
		SUM(N_LOST_HRS) AS N_LOST_HRS,
		SUM(N_OT) AS N_OT
        ,SUM(D_SHRINKAGE) AS D_SHRINKAGE
        INTO #ShrinkageMetricsTbl
        FROM #ShrinkageMetricsRaw
		GROUP BY   [Date],[SUB LOB],  MU_ID


		Option(recompile)


		--Select * from #ShrinkageMetricsTbl
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Forecast Original and Revised

	SELECT [Date], LOB, [Sub LOB], [Rev/Orig], [Forecast], [AHT Goal],
			CASE WHEN [Rev/Orig] = 'Revised' THEN [Forecast]
				ELSE 0
				END AS [Call Forecast Revised],
			CASE WHEN [Rev/Orig] = 'Original' THEN [Forecast]
				ELSE 0
				END AS [Call Forecast Original],
			CASE WHEN [Rev/Orig] = 'Revised' THEN [AHT Goal]
				ELSE 0
				END AS [AHT Revised (Goal)],
			CASE WHEN [Rev/Orig] = 'Original' THEN [AHT Goal]
				ELSE 0
				END AS [AHT Original (Goal)]	

	INTO #Spotlight_OptumRx_PriorDays_Forecast
	FROM Spotlight_OptumRx_PriorDays_Forecast
	WHERE [SUB LOB] LIKE '%PBM%'
	AND [DATE] between @STARTDATE AND  @ENDDATE

	OPTION(Recompile)


	Update #Spotlight_OptumRx_PriorDays_Forecast
	SET [Sub LOB] = 'PBM Preferred'
	WHERE [SUB LOB] = 'PBM Pref'
	AND LOB = 'Member Services'

		--Select * from #Spotlight_OptumRx_PriorDays_Forecast

-----PREPARATION SHRINKAGE DATA (FOR OPTUM RX - MS PBM) 
	
--	---- LH_VOICE_WFM_RPT_NICE_IEX_UTILIZATION_DATA

----BASE_TABLE_AGGREGATE

	INSERT INTO #Spotlight_OptumRx_AggTbl_PriorDaysReport_MS_PBM
	(	[MONTH],
		[RPTDATE],[METRIC], [CT],[IEX_GROUP],[LOB],[Sub LOB], CONTACTS_RECVD_REVISED,  CONTACTS_RECVD_ACT,  CONTACTS_ABNDN_ACT,  AHT_ACT,  SERVICE_LEVEL_ACT,  OCCUPANCY_ACT,  ASA_ACT,  Handled_Actual_Contacts,  [Avail],  AHT_Calc,  SL_Calc,  ASA_Calc,
		[Queue], [Calls_Handled],[n_average_handle_time],[d_average_handle_time],[Engage Time],[Wrap Time],[Hold Time],
		[Busy Time],
		[Calls_Handled_Occupancy], [n_average_handle_time_Occupancy], [d_average_handle_time_Occupancy], [Engage_Time_Occupancy], [Wrap_Time_Occupancy], [Hold_Time_Occupancy],		[Ready_Time_Occupancy],
		[MU_ID], N_OOO , N_IO,  N_SHRINKAGE , N_VTO , N_LOST_HRS,  N_OT,  D_SHRINKAGE
		,[Call Forecast Original],[Call Forecast Revised],[AHT Original (Goal)],[AHT Revised (Goal)], Shrinkage_Target
	)
			SELECT
			CONVERT(VARCHAR(10),DATEPART(MM,(cast(RPTDATE as date)))) + '-' + DATENAME(MONTH,(cast(RPTDATE as date))) as [MONTH],
			[RPTDATE], 'INTRADAY' AS [METRIC], intra.[CT], intra.[IEX_GROUP], intra.[LOB], intra.[Sub LOB], intra.CONTACTS_RECVD_REVISED, CONTACTS_RECVD_ACT, CONTACTS_ABNDN_ACT, AHT_ACT, SERVICE_LEVEL_ACT, OCCUPANCY_ACT, ASA_ACT, Handled_Actual_Contacts, [Avail], AHT_Calc, SL_Calc, ASA_Calc,
			'-' [Queue], 0 [Calls_Handled], 0 [n_average_handle_time], 0 [d_average_handle_time], 0 [Engage Time], 0 [Wrap Time], 0 [Hold Time],
			0 [Busy Time],
			0 [Calls_Handled_Occupancy], 0 [n_average_handle_time_Occupancy], 0 [d_average_handle_time_Occupancy], 0 [Engage_Time_Occupancy], 0 [Wrap_Time_Occupancy], 0 [Hold_Time_Occupancy],	0 [Ready_Time_Occupancy],
			0 [MU_ID], 0 N_OOO ,0 N_IO, 0 N_SHRINKAGE ,0 N_VTO ,0 N_LOST_HRS, 0 N_OT, 0 D_SHRINKAGE,
			0 [Call Forecast Original], 0 [Call Forecast Revised], 0 [AHT Original (Goal)], 0 [AHT Revised (Goal)], 
			CASE WHEN intra.[Sub LOB] = 'PBM Preferred' THEN 0.30 
				WHEN intra.[Sub LOB] = 'PBM Dcard' THEN 0.3447
				WHEN intra.[Sub LOB] = 'PBM Lead' THEN 0.3850
				WHEN intra.[Sub LOB] = 'PBM OVN' THEN 0.3447
				END AS Shrinkage_Target
			FROM #TMP_LH_VOICE_WFM_RPT_NICE_IEX_INTRADAY_DATA_ForOptumRx intra
			GROUP BY [RPTDATE], [CT], [IEX_GROUP], [LOB], [Sub LOB], CONTACTS_RECVD_REVISED,  CONTACTS_RECVD_ACT,  CONTACTS_ABNDN_ACT,  AHT_ACT,  SERVICE_LEVEL_ACT,  OCCUPANCY_ACT,  ASA_ACT,  Handled_Actual_Contacts,  [Avail],  AHT_Calc,  SL_Calc,  ASA_Calc

			UNION ALL

			SELECT
			CONVERT(VARCHAR(10),DATEPART(MM,(cast(RPTDATE as date)))) + '-' + DATENAME(MONTH,(cast(RPTDATE as date))) as [MONTH],
			[RPTDATE], 'AHT_VOL' [METRIC], 0 [CT], NULL [IEX_GROUP],[LOB],[Sub LOB], 0 CONTACTS_RECVD_REVISED, 0 CONTACTS_RECVD_ACT, 0 CONTACTS_ABNDN_ACT, 0 AHT_ACT, 0 SERVICE_LEVEL_ACT, 0 OCCUPANCY_ACT, 0 ASA_ACT, 0 Handled_Actual_Contacts, 0 [Avail], 0 AHT_Calc, 0 SL_Calc, 0 ASA_Calc,
			aht.[Queue], aht.[Calls_Handled], aht.[n_average_handle_time], aht.[d_average_handle_time], aht.[Engage Time],  aht.[Wrap Time], aht.[Hold Time], 
			0 [Busy Time],
			0 [Calls_Handled_Occupancy], 0 [n_average_handle_time_Occupancy], 0 [d_average_handle_time_Occupancy], 0 [Engage_Time_Occupancy], 0 [Wrap_Time_Occupancy], 0 [Hold_Time_Occupancy],	0 [Ready_Time_Occupancy],
			0 [MU_ID], 0 N_OOO ,0 N_IO, 0 N_SHRINKAGE ,0 N_VTO ,0 N_LOST_HRS, 0 N_OT, 0 D_SHRINKAGE,
			0 [Call Forecast Original], 0 [Call Forecast Revised], 0 [AHT Original (Goal)], 0 [AHT Revised (Goal)],
			CASE WHEN [Sub LOB] = 'PBM Preferred' THEN 0.30 
				WHEN [Sub LOB] = 'PBM Dcard' THEN 0.3447
				WHEN [Sub LOB] = 'PBM Lead' THEN 0.3850
				WHEN [Sub LOB] = 'PBM OVN' THEN 0.3447
				END AS Shrinkage_Target
			FROM #GenesysAgentAHTQueueDaywiseReportMultipleBusiness_View_OptumRx_TMP aht
			GROUP BY [RPTDATE], [LOB],[Sub LOB], [Queue], [Calls_Handled],[n_average_handle_time],[d_average_handle_time],[Engage Time], [Wrap Time], [Hold Time]

			UNION ALL
			
			SELECT 
			CONVERT(VARCHAR(10),DATEPART(MM,(cast(RPTDATE as date)))) + '-' + DATENAME(MONTH,(cast(RPTDATE as date))) as [MONTH],
			[RPTDATE], 'OCCUPANCY_IEX' [METRIC], 0 [CT], NULL [IEX_GROUP],[LOB],[Sub LOB], 0 CONTACTS_RECVD_REVISED, 0 CONTACTS_RECVD_ACT, 0 CONTACTS_ABNDN_ACT, 0 AHT_ACT, 0 SERVICE_LEVEL_ACT, 0 OCCUPANCY_ACT, 0 ASA_ACT, 0 Handled_Actual_Contacts, 0 [Avail], 0 AHT_Calc, 0 SL_Calc, 0 ASA_Calc,
			'-' [Queue], 0 [Calls_Handled], 0 [n_average_handle_time], 0 [d_average_handle_time], 0 [Engage Time], 0 [Wrap Time], 0 [Hold Time], 
			 occ.[Busy Time],
			0 [Calls_Handled_Occupancy], 0 [n_average_handle_time_Occupancy], 0 [d_average_handle_time_Occupancy], 0 [Engage_Time_Occupancy], 0 [Wrap_Time_Occupancy], 0 [Hold_Time_Occupancy],	0 [Ready_Time_Occupancy],
			0 [MU_ID], 0 N_OOO ,0 N_IO, 0 N_SHRINKAGE ,0 N_VTO ,0 N_LOST_HRS, 0 N_OT, 0 D_SHRINKAGE,
		0 [Call Forecast Original], 0 [Call Forecast Revised], 0 [AHT Original (Goal)], 0 [AHT Revised (Goal)],
			CASE WHEN [Sub LOB] = 'PBM Preferred' THEN 0.30 
				WHEN [Sub LOB] = 'PBM Dcard' THEN 0.3447
				WHEN [Sub LOB] = 'PBM Lead' THEN 0.3850
				WHEN [Sub LOB] = 'PBM OVN' THEN 0.3447
				END AS Shrinkage_Target
			FROM #GenesysAgentNotReadyReasonCodeReportAgentActivityIntervalwiseforMultipleBusiness_TMP occ
			GROUP BY [RPTDATE], [LOB],[Sub LOB], [Busy Time]


			UNION ALL

			SELECT 
			CONVERT(VARCHAR(10),DATEPART(MM,(cast(RPTDATE as date)))) + '-' + DATENAME(MONTH,(cast(RPTDATE as date))) as [MONTH],
			[RPTDATE], 'OCCUPANCY_PBI' [METRIC], 0 [CT], NULL [IEX_GROUP],[LOB],[Sub LOB], 0 CONTACTS_RECVD_REVISED, 0 CONTACTS_RECVD_ACT, 0 CONTACTS_ABNDN_ACT, 0 AHT_ACT, 0 SERVICE_LEVEL_ACT, 0 OCCUPANCY_ACT, 0 ASA_ACT, 0 Handled_Actual_Contacts, 0 [Avail], 0 AHT_Calc, 0 SL_Calc, 0 ASA_Calc,
			'-' [Queue], 0 [Calls_Handled], 0 [n_average_handle_time], 0 [d_average_handle_time], 0 [Engage Time], 0 [Wrap Time], 0 [Hold Time], 
			0 [Busy Time],
			pbi.[Calls_Handled_Occupancy], pbi.[n_average_handle_time_Occupancy], pbi.[d_average_handle_time_Occupancy], pbi.[Engage_Time_Occupancy], pbi.[Wrap_Time_Occupancy], pbi.[Hold_Time_Occupancy],	pbi.[Ready_Time_Occupancy],
			0 [MU_ID], 0 N_OOO ,0 N_IO, 0 N_SHRINKAGE ,0 N_VTO ,0 N_LOST_HRS, 0 N_OT, 0 D_SHRINKAGE,
			0 [Call Forecast Original], 0 [Call Forecast Revised], 0 [AHT Original (Goal)], 0 [AHT Revised (Goal)],
			CASE WHEN [Sub LOB] = 'PBM Preferred' THEN 0.30 
				WHEN [Sub LOB] = 'PBM Dcard' THEN 0.3447
				WHEN [Sub LOB] = 'PBM Lead' THEN 0.3850
				WHEN [Sub LOB] = 'PBM OVN' THEN 0.3447
				END AS Shrinkage_Target
			FROM #OCCU_PBI pbi
			GROUP BY [RPTDATE], [LOB],[Sub LOB], [Calls_Handled_Occupancy], [n_average_handle_time_Occupancy], [d_average_handle_time_Occupancy], [Engage_Time_Occupancy], [Wrap_Time_Occupancy], [Hold_Time_Occupancy], [Ready_Time_Occupancy]

		UNION ALL

			SELECT 
			CONVERT(VARCHAR(10),DATEPART(MM,(cast(RPTDATE as date)))) + '-' + DATENAME(MONTH,(cast(RPTDATE as date))) as [MONTH],
			[RPTDATE], 'SHRINKAGE' [METRIC], 0 [CT], NULL [IEX_GROUP],NULL [LOB],shrink.[SUB LOB], 0 CONTACTS_RECVD_REVISED, 0 CONTACTS_RECVD_ACT, 0 CONTACTS_ABNDN_ACT, 0 AHT_ACT, 0 SERVICE_LEVEL_ACT, 0 OCCUPANCY_ACT, 0 ASA_ACT, 0 Handled_Actual_Contacts, 0 [Avail], 0 AHT_Calc, 0 SL_Calc, 0 ASA_Calc,
			'-' [Queue], 0 [Calls_Handled], 0 [n_average_handle_time], 0 [d_average_handle_time], 0 [Engage Time], 0 [Wrap Time], 0 [Hold Time],
			 0 [Busy Time],
			0 [Calls_Handled_Occupancy], 0 [n_average_handle_time_Occupancy], 0 [d_average_handle_time_Occupancy], 0 [Engage_Time_Occupancy], 0 [Wrap_Time_Occupancy], 0 [Hold_Time_Occupancy],	0 [Ready_Time_Occupancy],
			shrink.[MU_ID], shrink.N_OOO ,shrink.N_IO, shrink.N_SHRINKAGE ,shrink.N_VTO ,shrink.N_LOST_HRS, shrink.N_OT, shrink.D_SHRINKAGE,
			0 [Call Forecast Original], 0 [Call Forecast Revised], 0 [AHT Original (Goal)], 0 [AHT Revised (Goal)],
			CASE WHEN [Sub LOB] = 'PBM Preferred' THEN 0.30 
				WHEN [Sub LOB] = 'PBM Dcard' THEN 0.3447
				WHEN [Sub LOB] = 'PBM Lead' THEN 0.3850
				WHEN [Sub LOB] = 'PBM OVN' THEN 0.3447
				END AS Shrinkage_Target
			FROM #ShrinkageMetricsTbl shrink
			GROUP BY [RPTDATE],[Sub LOB], [MU_ID], shrink.N_OOO
		,shrink.N_IO
		,shrink.N_SHRINKAGE
        ,shrink.N_VTO
		,shrink.N_LOST_HRS
		,shrink.N_OT
        ,shrink.D_SHRINKAGE

			UNION ALL

			SELECT 
			CONVERT(VARCHAR(10),DATEPART(MM,(cast([Date] as date)))) + '-' + DATENAME(MONTH,(cast([Date] as date))) as [MONTH],
			[Date] as [RPTDATE], 'Rev_Orig' [METRIC], 0 [CT], NULL [IEX_GROUP],Rev_Orig.[LOB],Rev_Orig.[Sub LOB], 0 CONTACTS_RECVD_REVISED, 0 CONTACTS_RECVD_ACT, 0 CONTACTS_ABNDN_ACT, 0 AHT_ACT, 0 SERVICE_LEVEL_ACT, 0 OCCUPANCY_ACT, 0 ASA_ACT, 0 Handled_Actual_Contacts, 0 [Avail], 0 AHT_Calc, 0 SL_Calc, 0 ASA_Calc,
			'-' [Queue], 0 [Calls_Handled], 0 [n_average_handle_time], 0 [d_average_handle_time], 0 [Engage Time], 0 [Wrap Time], 0 [Hold Time],
			  0 [Busy Time],
			0 [Calls_Handled_Occupancy], 0 [n_average_handle_time_Occupancy], 0 [d_average_handle_time_Occupancy], 0 [Engage_Time_Occupancy], 0 [Wrap_Time_Occupancy], 0 [Hold_Time_Occupancy],	0 [Ready_Time_Occupancy],
			0 [MU_ID], 0 N_OOO ,0 N_IO, 0 N_SHRINKAGE ,0 N_VTO ,0 N_LOST_HRS, 0 N_OT, 0 D_SHRINKAGE,
		Rev_Orig.[Call Forecast Original], Rev_Orig.[Call Forecast Revised], Rev_Orig.[AHT Original (Goal)], Rev_Orig.[AHT Revised (Goal)],
			CASE WHEN [Sub LOB] = 'PBM Preferred' THEN 0.30 
				WHEN [Sub LOB] = 'PBM Dcard' THEN 0.3447
				WHEN [Sub LOB] = 'PBM Lead' THEN 0.3850
				WHEN [Sub LOB] = 'PBM OVN' THEN 0.3447
				END AS Shrinkage_Target
			FROM #Spotlight_OptumRx_PriorDays_Forecast Rev_Orig
			GROUP BY [Date], [LOB],[Sub LOB], [Call Forecast Original], [Call Forecast Revised], [AHT Original (Goal)], [AHT Revised (Goal)]


			
			option(recompile);

--Select * from #Spotlight_OptumRx_AggTbl_PriorDaysReport_MS_PBM







-----------REPORT VIEWS-----------

	--IF @Mode = 'Raw'
	--	BEGIN
	--		SELECT 
	--			CONVERT(VARCHAR(10),DATEPART(MM,(cast(RPTDATE as date)))) + '-' + DATENAME(MONTH,(cast(RPTDATE as date))) as [MONTH]
	--			,[RPTDATE]
	--			,[METRIC], [CT],[IEX_GROUP], [MU_ID], [Queue], [LOB],[Sub LOB]
	--			,CAST(SUM(CONTACTS_RECVD_REVISED) AS NUMERIC(10,2)) AS CONTACTS_RECVD_REVISED
	--			,CAST(SUM(CONTACTS_RECVD_ACT) AS NUMERIC(10,2)) AS CONTACTS_RECVD_ACT
	--			,CAST(SUM(CONTACTS_ABNDN_ACT) AS NUMERIC(10,2)) AS CONTACTS_ABNDN_ACT
	--			,CAST(SUM(AHT_ACT) AS NUMERIC(10,2)) AS AHT_ACT
	--			,CAST(SUM(SERVICE_LEVEL_ACT) AS NUMERIC(10,2)) AS SERVICE_LEVEL_ACT
	--			,CAST(SUM(OCCUPANCY_ACT) AS NUMERIC(10,2)) AS OCCUPANCY_ACT
	--			,CAST(SUM(ASA_ACT) AS NUMERIC(10,2)) AS ASA_ACT
	--			,CAST(SUM(Handled_Actual_Contacts) AS NUMERIC(10,2)) AS Handled_Actual_Contacts
	--			,CAST(SUM([Avail]) AS NUMERIC(10,2)) AS [Avail]
	--			,CAST(SUM(AHT_Calc) AS NUMERIC(10,2)) AS AHT_Calc
	--			,CAST(SUM(SL_Calc) AS NUMERIC(10,2)) AS SL_Calc
	--			,CAST(SUM(ASA_Calc) AS NUMERIC(10,2)) AS ASA_Calc
	--			,CAST(SUM([Calls_Handled]) AS NUMERIC(10,2)) AS [Calls_Handled]
	--			,CAST(SUM([n_average_handle_time]) AS NUMERIC(10,2)) AS [n_average_handle_time]
	--			,CAST(SUM([d_average_handle_time]) AS NUMERIC(10,2)) AS [d_average_handle_time]
	--			,CAST(SUM([Engage Time]) AS NUMERIC(10,2)) AS [Engage Time]
	--			,CAST(SUM([Wrap Time]) AS NUMERIC(10,2)) AS [Wrap Time]
	--			,CAST(SUM([Hold Time]) AS NUMERIC(10,2)) AS [Hold Time]
	--			,CAST(SUM([Handle_Time_Occu]) AS NUMERIC(10,2)) AS [Handle_Time_Occu]
	--			,CAST(SUM([Ready Time]) AS NUMERIC(10,2)) AS [Ready Time]
	--			,CAST(SUM([Busy Time]) AS NUMERIC(10,2)) AS [Busy Time]
	--			,CAST(SUM([SchedTime]) AS NUMERIC(10,2)) AS [SchedTime]
	--			,CAST(SUM([ActualTime]) AS NUMERIC(10,2)) AS [ActualTime]
	--			,CAST(SUM([Duration_in_hours]) AS NUMERIC(10,2)) AS [Duration_in_hours]
	--			,CAST(SUM([Is_Excluded_From_Shrinkage]) AS NUMERIC(10,2)) AS [Is_Excluded_From_Shrinkage]
	--			,CAST(SUM([Consider_For_Total_Hours]) AS NUMERIC(10,2)) AS [Consider_For_Total_Hours]
	--			,CAST(SUM([ExShrink])  AS NUMERIC(10,2))AS [ExShrink]
	--			,CAST(SUM([CFTH]) AS NUMERIC(10,2))AS [CFTH]
	--			,CAST(SUM([In_Office_Total]) AS NUMERIC(10,2)) AS [In_Office_Total]
	--			,CAST(SUM([Out_Of_Office_Total]) AS NUMERIC(10,2)) AS [Out_Of_Office_Total]
	--			,CAST(SUM([LostTime_Total]) AS NUMERIC(10,2)) AS [LostTime_Total]
	--			,CAST(SUM([_OpenTime]) AS NUMERIC(10,2)) AS [_OpenTime]
	--			,CAST(SUM([_LT_OpenTime]) AS NUMERIC(10,2)) AS [_LT_OpenTime]
	--			,CAST(SUM([_VTO]) AS NUMERIC(10,2)) AS [_VTO]
	--			,CAST(SUM([_OT]) AS NUMERIC(10,2)) AS [_OT]
	--			,CAST(SUM([Call Forecast Original]) AS NUMERIC(10,2)) AS [Call Forecast Original]
	--			,CAST(SUM([Call Forecast Revised]) AS NUMERIC(10,2)) AS [Call Forecast Revised]
	--			,CAST(SUM([AHT Original (Goal)]) AS NUMERIC(10,2)) AS [AHT Original (Goal)]
	--			,CAST(SUM([AHT Revised (Goal)]) AS NUMERIC(10,2)) AS [AHT Revised (Goal)] 	
	--			,Shrinkage_Target
	--		FROM #Spotlight_OptumRx_AggTbl_PriorDaysReport_MS_PBM
	--		WHERE RPTDATE BETWEEN @StartDate AND @EndDate
	--		GROUP BY CONVERT(VARCHAR(10),DATEPART(MM,(cast(RPTDATE as date)))) + '-' + DATENAME(MONTH,(cast(RPTDATE as date))), 
	--		[RPTDATE], [METRIC], [CT],[IEX_GROUP], [MU_ID], [Queue], [LOB],[Sub LOB], Shrinkage_Target
	--		ORDER BY CONVERT(VARCHAR(10),DATEPART(MM,(cast(RPTDATE as date)))) + '-' + DATENAME(MONTH,(cast(RPTDATE as date))), 
	--		[RPTDATE], [LOB],[Sub LOB] 
	--	END 


	--IF @Mode = 'Yearly'
	--	BEGIN
	--		SELECT CONVERT(VARCHAR(10),DATEPART(MM,(cast(RPTDATE as date)))) + '-' + DATENAME(MONTH,(cast(RPTDATE as date))) as [MONTH]
	--			,[METRIC], [CT],[IEX_GROUP], [MU_ID], [Queue], [LOB],[Sub LOB]
	--			,CAST(SUM(CONTACTS_RECVD_REVISED) AS NUMERIC(10,2)) AS CONTACTS_RECVD_REVISED
	--			,CAST(SUM(CONTACTS_RECVD_ACT) AS NUMERIC(10,2)) AS CONTACTS_RECVD_ACT
	--			,CAST(SUM(CONTACTS_ABNDN_ACT) AS NUMERIC(10,2)) AS CONTACTS_ABNDN_ACT
	--			,CAST(SUM(AHT_ACT) AS NUMERIC(10,2)) AS AHT_ACT
	--			,CAST(SUM(SERVICE_LEVEL_ACT) AS NUMERIC(10,2)) AS SERVICE_LEVEL_ACT
	--			,CAST(SUM(OCCUPANCY_ACT) AS NUMERIC(10,2)) AS OCCUPANCY_ACT
	--			,CAST(SUM(ASA_ACT) AS NUMERIC(10,2)) AS ASA_ACT
	--			,CAST(SUM(Handled_Actual_Contacts) AS NUMERIC(10,2)) AS Handled_Actual_Contacts
	--			,CAST(SUM([Avail]) AS NUMERIC(10,2)) AS [Avail]
	--			,CAST(SUM(AHT_Calc) AS NUMERIC(10,2)) AS AHT_Calc
	--			,CAST(SUM(SL_Calc) AS NUMERIC(10,2)) AS SL_Calc
	--			,CAST(SUM(ASA_Calc) AS NUMERIC(10,2)) AS ASA_Calc
	--			,CAST(SUM([Calls_Handled]) AS NUMERIC(10,2)) AS [Calls_Handled]
	--			,CAST(SUM([n_average_handle_time]) AS NUMERIC(10,2)) AS [n_average_handle_time]
	--			,CAST(SUM([d_average_handle_time]) AS NUMERIC(10,2)) AS [d_average_handle_time]
	--			,CAST(SUM([Engage Time]) AS NUMERIC(10,2)) AS [Engage Time]
	--			,CAST(SUM([Wrap Time]) AS NUMERIC(10,2)) AS [Wrap Time]
	--			,CAST(SUM([Hold Time]) AS NUMERIC(10,2)) AS [Hold Time]
	--			,CAST(SUM([Handle_Time_Occu]) AS NUMERIC(10,2)) AS [Handle_Time_Occu]
	--			,CAST(SUM([Ready Time]) AS NUMERIC(10,2)) AS [Ready Time]
	--			,CAST(SUM([Busy Time]) AS NUMERIC(10,2)) AS [Busy Time]
	--			,CAST(SUM([SchedTime]) AS NUMERIC(10,2)) AS [SchedTime]
	--			,CAST(SUM([ActualTime]) AS NUMERIC(10,2)) AS [ActualTime]
	--			,CAST(SUM([Duration_in_hours]) AS NUMERIC(10,2)) AS [Duration_in_hours]
	--			,CAST(SUM([Is_Excluded_From_Shrinkage]) AS NUMERIC(10,2)) AS [Is_Excluded_From_Shrinkage]
	--			,CAST(SUM([Consider_For_Total_Hours]) AS NUMERIC(10,2)) AS [Consider_For_Total_Hours]
	--			,CAST(SUM([ExShrink])  AS NUMERIC(10,2))AS [ExShrink]
	--			,CAST(SUM([CFTH]) AS NUMERIC(10,2))AS [CFTH]
	--			,CAST(SUM([In_Office_Total]) AS NUMERIC(10,2)) AS [In_Office_Total]
	--			,CAST(SUM([Out_Of_Office_Total]) AS NUMERIC(10,2)) AS [Out_Of_Office_Total]
	--			,CAST(SUM([LostTime_Total]) AS NUMERIC(10,2)) AS [LostTime_Total]
	--			,CAST(SUM([_OpenTime]) AS NUMERIC(10,2)) AS [_OpenTime]
	--			,CAST(SUM([_LT_OpenTime]) AS NUMERIC(10,2)) AS [_LT_OpenTime]
	--			,CAST(SUM([_VTO]) AS NUMERIC(10,2)) AS [_VTO]
	--			,CAST(SUM([_OT]) AS NUMERIC(10,2)) AS [_OT]
	--			,CAST(SUM([Call Forecast Original]) AS NUMERIC(10,2)) AS [Call Forecast Original]
	--			,CAST(SUM([Call Forecast Revised]) AS NUMERIC(10,2)) AS [Call Forecast Revised]
	--			,CAST(SUM([AHT Original (Goal)]) AS NUMERIC(10,2)) AS [AHT Original (Goal)]
	--			,CAST(SUM([AHT Revised (Goal)]) AS NUMERIC(10,2)) AS [AHT Revised (Goal)] 
	--			,Shrinkage_Target
	--			FROM #Spotlight_OptumRx_AggTbl_PriorDaysReport_MS_PBM
	--		WHERE RPTDATE BETWEEN CAST(DATEFROMPARTS(YEAR(GETDATE()),1,1) as DATE) AND @EndDate
	--		GROUP BY CONVERT(VARCHAR(10),DATEPART(MM,(cast(RPTDATE as date)))) + '-' + DATENAME(MONTH,(cast(RPTDATE as date))), [METRIC], [CT],[IEX_GROUP], [MU_ID], [Queue], [LOB],[Sub LOB], Shrinkage_Target
	--		ORDER BY CONVERT(VARCHAR(10),DATEPART(MM,(cast(RPTDATE as date)))) + '-' + DATENAME(MONTH,(cast(RPTDATE as date))), [LOB],[Sub LOB]
	--	END
	

----------------------------------------------------------------------------------------
	SELECT 
				CONVERT(VARCHAR(10),DATEPART(MM,(cast(RPTDATE as date)))) + '-' + DATENAME(MONTH,(cast(RPTDATE as date))) as [MONTH]
				,[RPTDATE]
				,[METRIC], [CT],[IEX_GROUP], [MU_ID], [Queue], [LOB],[Sub LOB]
				,CAST(SUM(CONTACTS_RECVD_REVISED) AS NUMERIC(10,2)) AS CONTACTS_RECVD_REVISED
				,CAST(SUM(CONTACTS_RECVD_ACT) AS NUMERIC(10,2)) AS CONTACTS_RECVD_ACT
				,CAST(SUM(CONTACTS_ABNDN_ACT) AS NUMERIC(10,2)) AS CONTACTS_ABNDN_ACT
				,CAST(SUM(AHT_ACT) AS NUMERIC(10,2)) AS AHT_ACT
				,CAST(SUM(SERVICE_LEVEL_ACT) AS NUMERIC(10,2)) AS SERVICE_LEVEL_ACT
				,CAST(SUM(OCCUPANCY_ACT) AS NUMERIC(10,2)) AS OCCUPANCY_ACT
				,CAST(SUM(ASA_ACT) AS NUMERIC(10,2)) AS ASA_ACT
				,CAST(SUM(Handled_Actual_Contacts) AS NUMERIC(10,2)) AS Handled_Actual_Contacts
				,CAST(SUM([Avail]) AS NUMERIC(10,2)) AS [Avail]
				,CAST(SUM(AHT_Calc) AS NUMERIC(10,2)) AS AHT_Calc
				,CAST(SUM(SL_Calc) AS NUMERIC(10,2)) AS SL_Calc
				,CAST(SUM(ASA_Calc) AS NUMERIC(10,2)) AS ASA_Calc
				,CAST(SUM([Calls_Handled]) AS NUMERIC(10,2)) AS [Calls_Handled]
				,CAST(SUM([n_average_handle_time]) AS NUMERIC(10,2)) AS [n_average_handle_time]
				,CAST(SUM([d_average_handle_time]) AS NUMERIC(10,2)) AS [d_average_handle_time]
				,CAST(SUM([Engage Time]) AS NUMERIC(10,2)) AS [Engage Time]
				,CAST(SUM([Wrap Time]) AS NUMERIC(10,2)) AS [Wrap Time]
				,CAST(SUM([Hold Time]) AS NUMERIC(10,2)) AS [Hold Time]
				,CAST(SUM([Busy Time]) AS NUMERIC(10,2)) AS [Busy Time]
				,CAST(SUM([Calls_Handled_Occupancy]) AS NUMERIC(10,2)) AS [Calls_Handled_Occupancy]
				,CAST(SUM([n_average_handle_time_Occupancy]) AS NUMERIC(10,2)) AS [n_average_handle_time_Occupancy]
		        ,CAST(SUM([d_average_handle_time_Occupancy]) AS NUMERIC(10,2)) AS  [d_average_handle_time_Occupancy]
		        ,CAST(SUM([Engage_Time_Occupancy]) AS NUMERIC(10,2)) AS [Engage_Time_Occupancy]
		        ,CAST(SUM([Wrap_Time_Occupancy]) AS NUMERIC(10,2)) AS [Wrap_Time_Occupancy]
		        ,CAST(SUM([Hold_Time_Occupancy]) AS NUMERIC(10,2)) AS [Hold_Time_Occupancy]	
		        ,CAST(SUM([Ready_Time_Occupancy]) AS NUMERIC(10,2)) AS [Ready_Time_Occupancy]
				,CAST(SUM(N_OOO) as NUMERIC(10,2)) as N_OOO  
				,CAST(SUM(N_IO) as NUMERIC(10,2)) as N_IO 
				,CAST(SUM(N_SHRINKAGE) as NUMERIC(10,2)) as N_SHRINKAGE
				,CAST(SUM(N_VTO) as NUMERIC(10,2)) as N_VTO
				,CAST(SUM(N_LOST_HRS) as NUMERIC(10,2)) as N_LOST_HRS
				,CAST(SUM(N_OT) AS NUMERIC(10,2)) AS N_OT
				,CAST(SUM(D_SHRINKAGE) as NUMERIC(10,2)) as D_SHRINKAGE
				,CAST(SUM([Call Forecast Original]) AS NUMERIC(10,2)) AS [Call Forecast Original]
				,CAST(SUM([Call Forecast Revised]) AS NUMERIC(10,2)) AS [Call Forecast Revised]
				,CAST(SUM([AHT Original (Goal)]) AS NUMERIC(10,2)) AS [AHT Original (Goal)]
				,CAST(SUM([AHT Revised (Goal)]) AS NUMERIC(10,2)) AS [AHT Revised (Goal)] 	
				,Shrinkage_Target
			INTO #TempPriorDaysreport
			FROM #Spotlight_OptumRx_AggTbl_PriorDaysReport_MS_PBM
			WHERE RPTDATE BETWEEN @StartDate AND @EndDate
			GROUP BY CONVERT(VARCHAR(10),DATEPART(MM,(cast(RPTDATE as date)))) + '-' + DATENAME(MONTH,(cast(RPTDATE as date))), 
			[RPTDATE], [METRIC], [CT],[IEX_GROUP], [MU_ID], [Queue], [LOB],[Sub LOB], Shrinkage_Target
			ORDER BY CONVERT(VARCHAR(10),DATEPART(MM,(cast(RPTDATE as date)))) + '-' + DATENAME(MONTH,(cast(RPTDATE as date))), 
			[RPTDATE], [LOB],[Sub LOB] 

			--Select * from #TempPriorDaysreport
			
/**/
			DECLARE @ERRORSUM AS INT

			DELETE FROM [dbo].[Spotlight_OptumRx_AggTbl_PriorDaysReport_MS_PBM]
			WHERE RPTDATE BETWEEN @StartDate AND @EndDate

			INSERT INTO [Spotlight_OptumRx_AggTbl_PriorDaysReport_MS_PBM]
			SELECT *, GETUTCDATE() FROM #TempPriorDaysreport

			SET @ERRORSUM = @@ERROR

			IF @ERRORSUM > 0 
				BEGIN
					INSERT INTO Spotlight_Automation_Ingestion_ExceptionAndError_Log VALUES 
					('Prior Days Member Services PBM',
					'Ingestion Failed date range between ' + CONVERT(varchar(50), @StartDate, 102) + ' and ' + CONVERT(varchar(50), @EndDate, 102),
					'1',
					'Failed',
					HOST_NAME(),
					GETUTCDATE())
				END
			ELSE 
				BEGIN
					INSERT INTO Spotlight_Automation_Ingestion_ExceptionAndError_Log VALUES 
					('Prior Days Member Services PBM',
					'Ingestion Completed date range between ' + CONVERT(varchar(50), @StartDate, 102) + ' and ' + CONVERT(varchar(50), @EndDate, 102),
					'1',
					'Success',
					HOST_NAME(),
					GETUTCDATE())
				END
			

			--select 'Prior Days Member Services PBM',
			--		'Ingestion Failed date range between ' + CONVERT(varchar(50), getdate(), 102) + ' and ' + CONVERT(varchar(50), getdate(), 102),
			--		'1',
			--		'Failed',
			--		HOST_NAME(),
			--		GETUTCDATE()


IF OBJECT_ID('tempdb..' + '#TempPriorDaysreport') IS NOT NULL 
BEGIN EXEC('DROP TABLE ' + '#TempPriorDaysreport') END


IF OBJECT_ID('tempdb..' + '#tmp_Spotlight_SublobgroupingforExecutive_Dashboard') IS NOT NULL 
BEGIN EXEC('DROP TABLE ' + '#tmp_Spotlight_SublobgroupingforExecutive_Dashboard') END

IF OBJECT_ID('tempdb..' + '#TempDemographics') IS NOT NULL 
BEGIN EXEC('DROP TABLE ' + '#TempDemographics') END
 
IF OBJECT_ID('tempdb..' + '#TempSpotlight_IEX_ExceptionCodeMapping') IS NOT NULL 
BEGIN EXEC('DROP TABLE ' + '#TempSpotlight_IEX_ExceptionCodeMapping') END

IF OBJECT_ID('tempdb..' + '#tmp_LH_VOICE_WFM_RPT_GENESYS_QUEUE_REFERENCE_OPTUMRX') IS NOT NULL
BEGIN EXEC('DROP TABLE ' + '#tmp_LH_VOICE_WFM_RPT_GENESYS_QUEUE_REFERENCE_OPTUMRX') END	

IF OBJECT_ID('tempdb..' + '#TMP_LH_VOICE_WFM_RPT_NICE_IEX_INTRADAY_DATA_ForOptumRx') IS NOT NULL 
BEGIN EXEC('DROP TABLE ' + '#TMP_LH_VOICE_WFM_RPT_NICE_IEX_INTRADAY_DATA_ForOptumRx') END

IF OBJECT_ID('tempdb..' + '#GenesysAgentAHTQueueDaywiseReportMultipleBusiness_View_OptumRx_TMP') IS NOT NULL 
BEGIN EXEC('DROP TABLE ' + '#GenesysAgentAHTQueueDaywiseReportMultipleBusiness_View_OptumRx_TMP') END

IF OBJECT_ID('tempdb..' + '#GenesysAgentNotReadyReasonCodeReportAgentActivityIntervalwiseforMultipleBusiness_TMP') IS NOT NULL 
BEGIN EXEC('DROP TABLE ' + '#GenesysAgentNotReadyReasonCodeReportAgentActivityIntervalwiseforMultipleBusiness_TMP') END

IF OBJECT_ID('tempdb..' + '#LH_VOICE_WFM_RPT_NICE_IEX_UTILIZATION_DATA_TMP') IS NOT NULL 
BEGIN EXEC('DROP TABLE ' + '#LH_VOICE_WFM_RPT_NICE_IEX_UTILIZATION_DATA_TMP') END

IF OBJECT_ID('tempdb..' + '#LH_VOICE_WFM_RPT_NICE_IEX_ADHERENCE_DATA_TMP') IS NOT NULL 
BEGIN EXEC('DROP TABLE ' + '#LH_VOICE_WFM_RPT_NICE_IEX_ADHERENCE_DATA_TMP') END

IF OBJECT_ID('tempdb..' + '#TempShrinkageBaseRaw') IS NOT NULL 
BEGIN EXEC('DROP TABLE ' + '#TempShrinkageBaseRaw') END

IF OBJECT_ID('tempdb..' + '#Spotlight_OptumRx_AggTbl_PriorDaysReport_MS') IS NOT NULL 
BEGIN EXEC('DROP TABLE ' + '#Spotlight_OptumRx_AggTbl_PriorDaysReport_MS') END

IF OBJECT_ID('tempdb..' + '#Spotlight_OptumRx_PriorDays_Forecast') IS NOT NULL 
BEGIN EXEC('DROP TABLE ' + '#Spotlight_OptumRx_PriorDays_Forecast') END


--END

/*base tables

INTRADAY = #TMP_LH_VOICE_WFM_RPT_NICE_IEX_INTRADAY_DATA_ForOptumRx
AHT_CALL_VOL = #GenesysAgentAHTQueueDaywiseReportMultipleBusiness_View_OptumRx_TMP
OCCUPANCY = #GenesysAgentNotReadyReasonCodeReportAgentActivityIntervalwiseforMultipleBusiness_TMP
SHRINKAGE = #TempShrinkageBaseRaw

select top 1 * from #TMP_LH_VOICE_WFM_RPT_NICE_IEX_INTRADAY_DATA_ForOptumRx
select top 1 * from #GenesysAgentAHTQueueDaywiseReportMultipleBusiness_View_OptumRx_TMP
select top 1 * from #GenesysAgentNotReadyReasonCodeReportAgentActivityIntervalwiseforMultipleBusiness_TMP
select top 1 * from #TempShrinkageBaseRaw

--select * from Spotlight_OptumRx_AggTbl_PriorDaysReport where DATE BETWEEN '2025-04-01' AND '2025-04-30'

AVAIL
    (SUM(Overall_CALLS_HANDLED * Overall_AHT) / AVG(OCCUPANCY)) - SUM(Overall_CALLS_HANDLED * Overall_AHT) 
*/
--GO


