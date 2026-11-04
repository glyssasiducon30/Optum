USE [MIS_SPOTLIGHT]
GO
/****** Object:  StoredProcedure [dbo].[SpotLight_AttendanceReport_OptumRxMS_PHD_SpecialtyRx_V2]    Script Date: 12/16/2025 11:32:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Glyssa Siducon>
-- Create date: <September 16, 2024>
-- Description:	<Attendance Report MS, PHD and Specialty Pharmacy>
-- =============================================

	ALTER PROCEDURE [dbo].[SpotLight_AttendanceReport_OptumRxMS_PHD_SpecialtyRx_V2] 
		@StartDate date=NULL,
		@Group_L1 varchar(max)=NULL,
		@Location varchar(max)=NULL,
		@Supervisor varchar(max)=NULL,
		@DM varchar(max)=NULL,
		@ReportView varchar(max)=NULL

	AS
	BEGIN

	--DECLARE
	--	@StartDate date= '2025-10-02',
	--	@Group_L1 varchar(max)=NULL,	
	--	@Location varchar(max)=NULL,
	--	@Supervisor varchar(max)=NULL,
	--	@DM varchar(max)=NULL,
	--	@ReportView varchar(max)= 'MS_view'    --''SPRx_SubLOB_view''       --'PHD_view'    --'MS_view' -- NULL



	--IF (@ReportView = 'PHD_MS')
	--BEGIN
	--SELECT null as RPTDATE, null as FULL_NAME, null as MU_ID, null as MU_NAME, null as AGENT_ID, 
	--			null as FN_LOB, null as EMP_ID, null as MS_ID, 
	--			 null as SUPERVISOR, null as DEPUTY_MANAGER, null as LINE_OF_BUSINESS, null as [LOCATION], 
	--			 null as GROUP_L1, null as GROUP_L2, null as Exception_Code, null as EMPLOYEE_ID, 
	--			 null as RESOURCE_NAME, null as START_TIME, 
	--			  null as SCHEDULE, null as Log_in_HH_MM, null as SCHEDULE_MT, null as SCHEDULE_CST, null as CST_NOW, null as SCHED_, null as ABSENT_COUNT,
	--				null as [Attendance], null as PRESENT_COUNT
	--END

	

	--IF (@ReportView = 'SPRx')
	--BEGIN
	--SELECT null as [RPTDATE],null as [MU_ID], null as [Agent_ID], null as [Agent_Name], null as [Start_Time], null as [End_Time], null as [Schedule_Activity],	
	--	null as [FN_LOB], null as [MS_ID], null as [Category], null as [Exception_Code], null as GROUP_L1, null as GROUP_L2, null as [LOCATION], null as [Seconds_UnplannedOOO],
	--	null as [Seconds_PlannedOOO], null as [Hours_UnplannedOOO],null as [Hours_PlannedOOO],null as [UnplannedOOO], null as [PlannedOOO], null as ACOUNT
	--END


	--	IF (@ReportView = 'PHD_view')
	--BEGIN
	--SELECT null as RPTDATE, null as FULL_NAME, null as MU_ID, null as MU_NAME, null as AGENT_ID, 
	--			null as FN_LOB, null as EMP_ID, null as MS_ID, 
	--			 null as SUPERVISOR, null as DEPUTY_MANAGER, null as LINE_OF_BUSINESS, null as [LOCATION], 
	--			 null as GROUP_L1, null as GROUP_L2, null as Exception_Code, null as EMPLOYEE_ID, 
	--			 null as RESOURCE_NAME, null as START_TIME, 
	--			  null as SCHEDULE, null as Log_in_HH_MM, null as SCHEDULE_MT, null as SCHEDULE_CST, null as CST_NOW, null as SCHED_, null as ABSENT_COUNT,
	--				null as [Attendance], null as PRESENT_COUNT, null as Headcount
	--END

	--END

DECLARE @fnLOB VARCHAR (max)=NULL
DECLARE @LineOfBusiness VARCHAR (255)=NULL 

	IF @StartDate IS NULL 
		BEGIN
			SET @StartDate = DATEADD(d,-1,GETUTCDATE())
		END

	--IF @EndDate IS NULL 
	--	BEGIN
	--		SET @EndDate = DATEADD(d,-1,GETUTCDATE())
	--	END


		IF @fnLOB='OPTUM.V.OPTUMRX'
		BEGIN
			SET @LineOfBusiness='OPTUM RX'
		END



-- ParamLOB -------------------------------------------------
	IF OBJECT_ID('tempdb..#ParamGroupL1') IS NOT NULL DROP TABLE #ParamGroupL1     
	CREATE TABLE #ParamGroupL1 (val VARCHAR(MAX)) 
	IF @Group_L1 IS NULL
		BEGIN
			INSERT INTO #ParamGroupL1 (val)
			SELECT 
				DISTINCT LTRIM(RTRIM(LINE_OF_BUSINESS)) 
			FROM Spotlight_EmployeeInformationDeriveFromLH
			WHERE [LINE_OF_BUSINESS] = 'OPTUM RX'
				AND GROUP_L4 IN ('PHL PHARMACY MEMBER SRVCES OPT','PHL PHARMACY HELPDESK OPTUM', 'PHL BRIOVA REFILL OPTUM','PHL RX Specialty PCC', 'PHL OGA RX SPECIALTY')


		END
	ELSE
		BEGIN 
			INSERT INTO #ParamGroupL1 (val)                
			SELECT 
				LTRIM(RTRIM(VALUE)) 
			FROM dbo.FnSplit(@Group_L1,'!')
		END

--ParamSite -------------------------------------------------------------------
	IF OBJECT_ID('tempdb..#ParamSite') IS NOT NULL DROP TABLE #ParamSite
	CREATE TABLE #ParamSite(val VARCHAR(MAX))
	IF @Location IS NULL
		BEGIN
			INSERT INTO #ParamSite(val)
			SELECT 
				DISTINCT LTRIM(RTRIM([LOCATION]))
			FROM Spotlight_EmployeeInformationDeriveFromLH
			WHERE [LINE_OF_BUSINESS] = 'OPTUM RX'
				AND GROUP_L4 IN ('PHL PHARMACY MEMBER SRVCES OPT','PHL PHARMACY HELPDESK OPTUM', 'PHL BRIOVA REFILL OPTUM','PHL RX Specialty PCC', 'PHL OGA RX SPECIALTY')
		END
	ELSE
		BEGIN
			INSERT INTO #ParamSite(val)
			SELECT 
				LTRIM(RTRIM(VALUE)) 
			FROM dbo.FnSplit(@Location,'!')
		END
	
--ParamSupervisor -------------------------------------------------
	IF OBJECT_ID('tempdb..#ParamSupervisor') IS NOT NULL DROP TABLE #ParamSupervisor
	CREATE TABLE #ParamSupervisor(val VARCHAR(MAX))
	IF @Supervisor IS NULL
		BEGIN
			INSERT INTO #ParamSupervisor(val)
			SELECT 
				DISTINCT LTRIM(RTRIM(SUPERVISOR)) 
			FROM Spotlight_EmployeeInformationDeriveFromLH
			WHERE [LINE_OF_BUSINESS] = 'OPTUM RX'
				AND GROUP_L4 IN ('PHL PHARMACY MEMBER SRVCES OPT','PHL PHARMACY HELPDESK OPTUM', 'PHL BRIOVA REFILL OPTUM','PHL RX Specialty PCC', 'PHL OGA RX SPECIALTY')
		END
	ELSE
		BEGIN
			INSERT INTO #ParamSupervisor(val)              
			SELECT 
				LTRIM(RTRIM(VALUE)) 
			FROM dbo.FnSplit(@Supervisor,'!')
		END
--ParamManager ---------------------------------------
IF OBJECT_ID('tempdb..#ParamDM') IS NOT NULL DROP TABLE #ParamDM
	CREATE TABLE #ParamDM(val VARCHAR(MAX))
	IF @DM IS NULL
		BEGIN
			INSERT INTO #ParamDM(val)
			SELECT 
				DISTINCT LTRIM(RTRIM(DEPUTY_MANAGER))
			FROM Spotlight_EmployeeInformationDeriveFromLH
			WHERE [LINE_OF_BUSINESS] = 'OPTUM RX'
				AND GROUP_L4 IN ('PHL PHARMACY MEMBER SRVCES OPT','PHL PHARMACY HELPDESK OPTUM', 'PHL BRIOVA REFILL OPTUM','PHL RX Specialty PCC', 'PHL OGA RX SPECIALTY')
		END
	ELSE
		BEGIN
			INSERT INTO #ParamDM(val)
			SELECT 
				LTRIM(RTRIM(VALUE)) 
			FROM dbo.FnSplit(@DM,'!')
		END

--DEMOGRAPHICS-----------------------------------------------

	IF OBJECT_ID('tempdb..#demographics') IS NOT NULL DROP TABLE #demographics

	Select EMP_ID,	MS_ID,	FULL_NAME,	SUPERVISOR,	DEPUTY_MANAGER,	LINE_OF_BUSINESS,
			CASE WHEN [LOCATION] LIKE '%Alabang%' THEN 'ALABANG'
				WHEN [LOCATION] LIKE '%Cebu%' THEN 'CEBU'
				WHEN [LOCATION] LIKE '%Davao%' THEN 'DAVAO'
				WHEN [LOCATION] LIKE '%Quezon%' THEN 'QUEZON CITY'
				WHEN [LOCATION] LIKE '%Makati%' THEN 'MAKATI'
				ELSE [LOCATION] END AS [LOCATION],	
			GROUP_L4, GROUP_L5, LOB, SUB_LOB, ROSTER_EFFECTIVE_DATE
	into #demographics
	from Spotlight_EmployeeInformationDeriveFromLH
	where 
	ROSTER_EFFECTIVE_DATE = @StartDate
	AND [LINE_OF_BUSINESS] = 'OPTUM RX'
	AND GROUP_L4 IN ('PHL PHARMACY MEMBER SRVCES OPT','PHL PHARMACY HELPDESK OPTUM', 'PHL BRIOVA REFILL OPTUM','PHL RX Specialty PCC', 'PHL OGA RX SPECIALTY')
	--AND EMP_ID IS NOT NULL
	--AND ISNULL([LOCATION],'-') IN (SELECT val FROM #ParamSite)
	AND ISNULL(DEPUTY_MANAGER,'-') IN (SELECT val FROM #ParamDM)
	AND ISNULL(Supervisor,'-') IN (SELECT val FROM #ParamSupervisor)
	ORDER BY EMP_ID,	MS_ID

	
	
	--Select * from #demographics

---------------------------------------------------------



	IF @StartDate IS NULL 
		BEGIN
			SET @StartDate = DATEADD(d,-1,GETUTCDATE())
		END

	--IF @EndDate IS NULL 
	--	BEGIN
	--		SET @EndDate = DATEADD(d,-1,GETUTCDATE())
	--	END

	IF @fnLOB='OPTUM.V.OPTUMRX'
		BEGIN
			SET @LineOfBusiness='OPTUM RX'
		END


	--SELECT * from #SubLOB_Grouping

--PHD BASE TABLE --------------------------------------------------------
	IF OBJECT_ID('tempdb..#ScheduleCalendar') IS NOT NULL DROP TABLE #ScheduleCalendar
	IF OBJECT_ID('tempdb..#LILO') IS NOT NULL DROP TABLE #LILO
	IF OBJECT_ID('tempdb..#Temp_Sched') IS NOT NULL DROP TABLE #Temp_Sched
	IF OBJECT_ID('tempdb..#Temp_A_Sched') IS NOT NULL DROP TABLE #Temp_A_Sched


	SELECT RPTDATE, TIME_INTERVAL_60_MINUTES, MU_ID, MU_NAME, AGENT_ID, AGENT_NAME, SCHEDULE, FN_LOB, demo.EMP_ID, demo.MS_ID
			,demo.FULL_NAME,	demo.SUPERVISOR,	demo.DEPUTY_MANAGER,	demo.LINE_OF_BUSINESS,
			demo.[LOCATION],	demo.LOB as GROUP_L1, demo.SUB_LOB as GROUP_L2

		INTO #Temp_Sched
		FROM LH_VOICE_WFM_RPT_NICE_IEX_AGENT_SCHEDULE_CALENDAR_DATA_ForOptumRx_HOURLY base
		INNER JOIN #demographics demo on demo.ROSTER_EFFECTIVE_DATE = base.RPTDATE
				AND demo.EMP_ID = base.EMP_ID
		WHERE MU_ID IN ('9001', '9204', '9214')
			--AND TIME_INTERVAL_60_MINUTES = '2:30'
			--AND demo.EMP_ID IS NOT NULL
			--AND ISNULL(demo.[LOCATION],'-') IN (SELECT val FROM #ParamSite)
			AND ISNULL(demo.DEPUTY_MANAGER,'-') IN (SELECT val FROM #ParamDM)
			AND ISNULL(demo.SUPERVISOR,'-') IN (SELECT val FROM #ParamSupervisor)

			
	ORDER BY RPTDATE, TIME_INTERVAL_60_MINUTES

--Select * from #Temp_Sched

	SELECT RPTDATE, MIN(TIME_INTERVAL_60_MINUTES) TIME_INTERVAL_60_MINUTES, AGENT_ID 
		INTO #Temp_A_Sched
	FROM #Temp_Sched
	GROUP BY RPTDATE,AGENT_ID 
	ORDER BY RPTDATE,TIME_INTERVAL_60_MINUTES, AGENT_ID 

	--Select * from #Temp_A_Sched

	SELECT Sched_Calendar.RPTDATE, Sched_Calendar.TIME_INTERVAL_60_MINUTES, MU_ID, MU_NAME, Sched_Calendar.AGENT_ID, AGENT_NAME, SCHEDULE, FN_LOB, demo.EMP_ID, demo.MS_ID
			,demo.FULL_NAME,	demo.SUPERVISOR,	demo.DEPUTY_MANAGER,	demo.LINE_OF_BUSINESS,
			demo.[LOCATION],	demo.LOB as GROUP_L1, demo.SUB_LOB as GROUP_L2

		INTO #ScheduleCalendar

		FROM #Temp_Sched Sched_Calendar   --LH_VOICE_WFM_RPT_NICE_IEX_AGENT_SCHEDULE_CALENDAR_DATA
			inner join #Demographics demo ON demo.ROSTER_EFFECTIVE_DATE = Sched_Calendar.RPTDATE
		and demo.EMP_ID = Sched_Calendar.EMP_ID
		INNER JOIN #Temp_A_Sched A_Sched ON A_Sched.RPTDATE = Sched_Calendar.RPTDATE
				AND A_Sched.TIME_INTERVAL_60_MINUTES = Sched_Calendar.TIME_INTERVAL_60_MINUTES
				AND A_Sched.AGENT_ID = Sched_Calendar.AGENT_ID
		WHERE Sched_Calendar.RPTDATE = @StartDate
			AND  MU_ID IN ('9001', '9204', '9214')
			--AND demo.EMP_ID IS NOT NULL
			--AND ISNULL(demo.[LOCATION],'-') IN (SELECT val FROM #ParamSite)
			AND ISNULL(demo.DEPUTY_MANAGER,'-') IN (SELECT val FROM #ParamDM)
			AND ISNULL(demo.SUPERVISOR,'-') IN (SELECT val FROM #ParamSupervisor)
		Order by Sched_Calendar.RPTDATE, Sched_Calendar.TIME_INTERVAL_60_MINUTES, MU_ID, MU_NAME

		

	--Select * from #ScheduleCalendar
-----------------------------------------------------------------------------------

	SELECT   RPTDATE, AGENT_NAME, EMPLOYEE_ID, RESOURCE_NAME,  MIN(START_TIME) as START_TIME  -- the code MIN(START_TIME) will only get the earlist start_time in a day
			,demo.FULL_NAME,	demo.SUPERVISOR,	demo.DEPUTY_MANAGER,	demo.LINE_OF_BUSINESS,
			demo.[LOCATION],	demo.LOB as GROUP_L1, demo.SUB_LOB as GROUP_L2, GROUP_NAME


		INTO #LILO

		FROM GenesysAgentLoginLogoutDetailsReportMultipleBusiness LILO
		inner join #Demographics demo ON demo.ROSTER_EFFECTIVE_DATE = LILO.RPTDATE
		and demo.MS_ID = LILO.RESOURCE_NAME
		WHERE RPTDATE = @StartDate
				AND GROUP_NAME IN ('VAG_OPT_OptumRx_PharmHelpDesk_Offshore',
				'AG_OPT_OptumRx_PharmHelpDesk_Offshore',
							'AG_OPT_OptumRx_PharmHelpDesk_OGS',
							'AG_OPT_OptumRx_PharmHelpDesk_OGS_Assist',
							'AG_OPT_OptumRx_PharmHelpDesk_OGS_Lead',
							'AG_OPT_OptumRx_PharmHelpDesk_OGS_NH',
							'VAG_OPT_OptumRx_PharmHelpDesk_Assist_OGA',
							'VAG_OPT_OptumRx_CustSrvc_Advanced',
							'VAG_OPT_OptumRx_CustSrvc_Core',
							'AG_OPT_OptumRx_PharmHelpDesk_OGS',
							'AG_OPT_OptumRX_PharmHelpDesk_OGS_Assist',
							'VAG_OPT_OptumRx_PharmHelpDesk_Offshore',
							'AG_OPT_OptumRX_PharmHelpDesk_OGS_Lead',
							'VAG_OPT_OptumRx_CustSrvc_Core_OGS',
							'VAG_OPT_OptumRx_CustSrvc_Advanced_OGS',
							'AG_OPT_OptumRx_CORE_Offshore',
							'AG_OPT_OptumRx_CustSrvc_WWE_AgentLogoff',
							'AG_OPT_OptumRx_CustSrvc_WWE_OGSCORE',
							'AG_OPT_OptumRx_CustSrvc_Member_Chat',
							'AG_OPT_OptumRx_CustSrvc_Members_Leads',
							'AG_OPT_OptumRx_CustSrvc_Member_Supervisors_OGS',
							'VAG_OPT_OptumRx_CustSrvc_PCS_UHC_EI_Global',
							'VAG_OPT_OptumRx_CustSrvc_PBM_UMR_Global',
							'VAG_OPT_OptumRx_CustSrvc_PCS_UMR_Global')
			AND demo.EMP_ID IS NOT NULL
			--AND ISNULL(demo.[LOCATION],'-') IN (SELECT val FROM #ParamSite)
			AND ISNULL(demo.DEPUTY_MANAGER,'-') IN (SELECT val FROM #ParamDM)
			AND ISNULL(demo.SUPERVISOR,'-') IN (SELECT val FROM #ParamSupervisor)
		GROUP BY AGENT_NAME, RPTDATE,  EMPLOYEE_ID, RESOURCE_NAME
				,demo.FULL_NAME,	demo.SUPERVISOR,	
				demo.DEPUTY_MANAGER,	demo.LINE_OF_BUSINESS,demo.[LOCATION], demo.LOB, demo.SUB_LOB, GROUP_NAME


		ORDER BY RPTDATE, START_TIME, AGENT_NAME, EMPLOYEE_ID, RESOURCE_NAME



			
	
	--Select * from #LILO


-----------------------------------------------------------------------------------
	IF OBJECT_ID('tempdb..#IEX_Mapping') IS NOT NULL DROP TABLE #IEX_Mapping
	IF OBJECT_ID('tempdb..#IEX_Code_Mapping') IS NOT NULL DROP TABLE #IEX_Code_Mapping
	IF OBJECT_ID('tempdb..#IEX_Code_Mapping_SPRx') IS NOT NULL DROP TABLE #IEX_Code_Mapping_SPRx

	SELECT Exception_Code,FN_LOB,  Onshore_Bucket,
		CASE WHEN Onshore_Bucket = 'Absent' THEN Exception_Code ELSE NULL END AS Legend_Absent,
		  CASE WHEN Onshore_Bucket = 'Outage' THEN Exception_Code ELSE NULL END AS Legend_Outage,
		  CASE WHEN Onshore_Bucket = 'Off/PTO' THEN Exception_Code ELSE NULL END AS Legend_Off_PTO
	INTO #IEX_Mapping
	FROM dbo.Spotlight_IEX_ExceptionCodeMapping
	WHERE Onshore_Bucket IN ('Outage','Off/PTO', 'Absent')
	AND FN_LOB IN ('OPTUM.V.OPTUMRX')

	--Select * from #IEX_Mapping

	---------------------------------------------

	SELECT FN_LOB, Exception_Code, In_Office_Or_Out_Of_Office,	Planned_Or_Unplanned,	Category
	INTO #IEX_Code_Mapping_SPRx
	FROM dbo.Spotlight_IEX_ExceptionCodeMapping
	WHERE FN_LOB IN ('OPTUM.V.OPTUMRX')


		--Select * from #IEX_Mapping
---------------------------------------------------------------------------------

IF OBJECT_ID('tempdb..#Base1') IS NOT NULL DROP TABLE #Base1
IF OBJECT_ID('tempdb..#Base2') IS NOT NULL DROP TABLE #Base2
IF OBJECT_ID('tempdb..#Base3') IS NOT NULL DROP TABLE #Base3
IF OBJECT_ID('tempdb..#Base4') IS NOT NULL DROP TABLE #Base4
IF OBJECT_ID('tempdb..#Base5') IS NOT NULL DROP TABLE #Base5
IF OBJECT_ID('tempdb..#Base_PHD_MS') IS NOT NULL DROP TABLE #Base_PHD_MS
IF OBJECT_ID('tempdb..#Base_Table') IS NOT NULL DROP TABLE #Base_Table
IF OBJECT_ID('tempdb..#AC') IS NOT NULL DROP TABLE #AC
 

	SELECT 
		SchedCalendar.RPTDATE, SchedCalendar.FULL_NAME, MU_ID, MU_NAME, AGENT_ID, 
		 IEX_Mapping.FN_LOB, EMP_ID, MS_ID, 
		 SchedCalendar.SUPERVISOR, SchedCalendar.DEPUTY_MANAGER, SchedCalendar.LINE_OF_BUSINESS, SchedCalendar.[LOCATION], 
		 SchedCalendar.GROUP_L1, SchedCalendar.GROUP_L2,
		 Exception_Code, 
		  EMPLOYEE_ID, 
		 RESOURCE_NAME, START_TIME,
		  SCHEDULE,
		  Legend_Absent,Legend_Outage, Legend_Off_PTO,
		 case when START_TIME = NULL then '' else  format(cast(START_TIME as DATETIME), 'h:mm') end AS Log_in_HH_MM,
		 --format(cast(START_TIME as DATETIME), 'h:mm') AS Log_in_HH_MM,
		 case when LEFT(Schedule,5) = 'TAFW-' THEN RIGHT(Schedule,LEN(Schedule)-5) 
			ELSE LEFT(Schedule,4) end as SCHEDULE_MT

	 INTO #Base1
	FROM #ScheduleCalendar SchedCalendar
		--FULL OUTER JOIN #LILO LILO ON 
		LEFT JOIN #LILO LILO ON 
			SchedCalendar.MS_ID =LILO.RESOURCE_NAME 
		   AND SchedCalendar.RPTDATE = LILO.RPTDATE

		  LEFT JOIN #IEX_Mapping IEX_Mapping ON IEX_Mapping.FN_LOB = SchedCalendar.FN_LOB
			AND IEX_Mapping.Exception_Code = SchedCalendar.SCHEDULE
				
	where
			SchedCalendar.RPTDATE = @StartDate
			order by LILO.RPTDATE


			Update #Base1
		SET GROUP_L1 = CASE WHEN GROUP_L1 = 'Web Tech' THEN 'Member Services'
			ELSE GROUP_L1
		END

	--Select * from #Base1




	DECLARE @H2 DATETIME = CAST(CONVERT(VARCHAR, GETDATE(), 108) AS DATETIME); -- Current time in h:mm:ss format  
	DECLARE @H3 DATETIME = '00:00:00'; -- 12:00 AM 
	DECLARE @I3 DATETIME = '12:00:00'; -- 12:00 PM 

	SELECT 
		RPTDATE, FULL_NAME, MU_ID, MU_NAME, AGENT_ID, 
		FN_LOB, EMP_ID, MS_ID, 
		 SUPERVISOR, DEPUTY_MANAGER, LINE_OF_BUSINESS, [LOCATION], 
		 GROUP_L1, 
		 GROUP_L2,
		 Exception_Code, 
		 EMPLOYEE_ID, 
		 RESOURCE_NAME, START_TIME,
		  SCHEDULE, 
		  Legend_Absent,Legend_Outage, Legend_Off_PTO, 
		  Log_in_HH_MM,SCHEDULE_MT,
		 CASE 
			WHEN ISNUMERIC(SCHEDULE_MT) = 1 THEN FORMAT(CAST(CONVERT(CHAR(2),LEFT(SCHEDULE_MT,2)) +':'+ CONVERT(CHAR(2),RIGHT(SCHEDULE_MT,2)) AS DATETIME), 'hh:mm tt' )
			ELSE ''
		END AS SCHEDULE_CST,


		CASE WHEN @H2 >= @H3 AND @H2 < @I3 
		THEN FORMAT(@H2, 'hh:mm tt') 
		 ELSE CONVERT(VARCHAR, @H2, 108) -- return in h:mm:ss format 
		 END AS CST_NOW

	INTO #Base2
	FROM #Base1

	--Select * from #Base2


	SELECT 
		RPTDATE, FULL_NAME, MU_ID, MU_NAME, AGENT_ID, 
		base.FN_LOB, EMP_ID, MS_ID, 
		 SUPERVISOR, DEPUTY_MANAGER, LINE_OF_BUSINESS, [LOCATION], 
		 GROUP_L1, GROUP_L2,
		Exception_Code, 
		EMPLOYEE_ID, 
		 RESOURCE_NAME, START_TIME,
		  SCHEDULE, 
		  Legend_Absent,Legend_Outage, Legend_Off_PTO, 
		  Log_in_HH_MM,SCHEDULE_MT, SCHEDULE_CST, CST_NOW

		--,CASE WHEN CST_NOW > DATEADD(SECOND, 0, SCHEDULE_cST) THEN 1 ELSE 0 END AS SCHED_

	INTO #Base3
	FROM #Base2 base



	--Select * from #Base3


	SELECT 
		RPTDATE, FULL_NAME, MU_ID, MU_NAME, AGENT_ID, 
		FN_LOB, EMP_ID, MS_ID, 
		 SUPERVISOR, DEPUTY_MANAGER, LINE_OF_BUSINESS, [LOCATION], 
		 GROUP_L1, GROUP_L2, Exception_Code,  EMPLOYEE_ID, 
		 RESOURCE_NAME, START_TIME,
		  SCHEDULE, Legend_Absent,Legend_Outage, Legend_Off_PTO, 
		  Log_in_HH_MM,SCHEDULE_MT, SCHEDULE_CST, CST_NOW, 
		  --SCHED_,
		  CASE WHEN Legend_Absent = SCHEDULE THEN 1
				WHEN Legend_Outage = SCHEDULE THEN 0
				WHEN Legend_Off_PTO = SCHEDULE THEN 0
				--WHEN SCHED_ = 0 THEN 0
				WHEN Log_in_HH_MM IS NOT NULL THEN 0 ELSE 1 END AS ABSENT_COUNT

	 INTO #Base4
	FROM #Base3
	GROUP BY RPTDATE, FULL_NAME, MU_ID, MU_NAME, AGENT_ID, 
		FN_LOB, EMP_ID, MS_ID, 
		 SUPERVISOR, DEPUTY_MANAGER, LINE_OF_BUSINESS, [LOCATION], 
		 GROUP_L1, GROUP_L2,Exception_Code, EMPLOYEE_ID, 
		 RESOURCE_NAME, START_TIME,
		  SCHEDULE, Legend_Absent,Log_in_HH_MM,SCHEDULE_MT, SCHEDULE_CST, CST_NOW,
		  --SCHED_, 
		  Legend_Absent,Legend_Outage, Legend_Off_PTO
	
	--Select * from #Base4

	

			SELECT RPTDATE, FULL_NAME, MU_ID, MU_NAME, AGENT_ID, 
				FN_LOB, EMP_ID, MS_ID, 
				 SUPERVISOR, DEPUTY_MANAGER, LINE_OF_BUSINESS, [LOCATION], 
				 GROUP_L1, GROUP_L2, Exception_Code, EMPLOYEE_ID, 
				 RESOURCE_NAME, START_TIME,
				  SCHEDULE, Legend_Absent,Legend_Outage, Legend_Off_PTO, Log_in_HH_MM,SCHEDULE_MT, SCHEDULE_CST, CST_NOW, 
				  --SCHED_, 
				  ABSENT_COUNT,
				   CASE WHEN Legend_Absent = SCHEDULE THEN 'Absent'
					WHEN Legend_Off_PTO = SCHEDULE THEN 'Off'
					WHEN ABSENT_COUNT = 1 THEN 'Absent'
					WHEN Legend_Outage = SCHEDULE THEN 'Shrink'
					--WHEN SCHED_ = 0 THEN 'Not Yet'
					ELSE 'Present' END AS [Attendance]
		
			INTO #Base5
			FROM #Base4


	SELECT RPTDATE, FULL_NAME, MU_ID, MU_NAME, AGENT_ID, 
				FN_LOB, EMP_ID, MS_ID, 
				 SUPERVISOR, DEPUTY_MANAGER, LINE_OF_BUSINESS, [LOCATION], 
				 GROUP_L1, GROUP_L2, Exception_Code,  EMPLOYEE_ID, 
				 RESOURCE_NAME, START_TIME, 
				  SCHEDULE, Legend_Absent,Legend_Outage, Legend_Off_PTO, Log_in_HH_MM,SCHEDULE_MT, SCHEDULE_CST, CST_NOW,
				  --SCHED_, 
				  ABSENT_COUNT,
					[Attendance],
				CASE WHEN [Attendance] = 'Shrink' or [Attendance] = 'Present' THEN 1 ELSE 0 END PRESENT_COUNT
				
	INTO #Base_Table
	FROM #Base5


		SELECT  RPTDATE, FULL_NAME, MU_ID, MU_NAME, AGENT_ID, 
				FN_LOB, EMP_ID, MS_ID, 
				 SUPERVISOR, DEPUTY_MANAGER, LINE_OF_BUSINESS, [LOCATION], 
				 GROUP_L1, GROUP_L2, Exception_Code,  EMPLOYEE_ID, 
				 RESOURCE_NAME, START_TIME, 
				  SCHEDULE, Legend_Absent, Legend_Outage, Legend_Off_PTO, Log_in_HH_MM,SCHEDULE_MT, SCHEDULE_CST, CST_NOW, 
				  --SCHED_, 
				  ABSENT_COUNT,
				[Attendance],PRESENT_COUNT, PRESENT_COUNT+ABSENT_COUNT as Headcount,
				Case when GROUP_L2 LIKE 'PBM %' then 'PBM'
					when GROUP_L2 LIKE 'PCS %' then 'PCS' else NULL end as Sub_LOB,
				case when ABSENT_COUNT = 1 and Legend_Absent IS NULL then 'No Tagging/MIA' else Legend_Absent end as PLOT
		INTO #Base_PHD_MS
		FROM #Base_Table




	--Select * from #Base_PHD_MS

	
--SPRx ------------------------------------------------------------------------------------------------
	IF OBJECT_ID('tempdb..#Agent_Schedule') IS NOT NULL DROP TABLE #Agent_Schedule 
	IF OBJECT_ID('tempdb..#Agent_Schedule_Base') IS NOT NULL DROP TABLE #Agent_Schedule_Base
	IF OBJECT_ID('tempdb..#BaseSPRx') IS NOT NULL DROP TABLE #BaseSPRx
	IF OBJECT_ID('tempdb..#AG') IS NOT NULL DROP TABLE #AG
	IF OBJECT_ID('tempdb..#SubLOB_Site_view') IS NOT NULL DROP TABLE #SubLOB_Site_view



	IF OBJECT_ID('tempdb..#Agent_Count') IS NOT NULL DROP TABLE #Agent_Count
	Select distinct (Agent_ID) AS Agent_id, 1 AS A_count,MAX(Activity_StartTime) AS Start_Time, GROUP_L1 , GROUP_L2 , [LOCATION]
	
	INTO #Agent_Count
	FROM SPOTLIGHT_IEX_Automation_Agent_Schedule_Report_DATA_HOURLY
	where MU_ID IN ('10262','10251','10252','10254')
	AND GROUP_L2 IN ('CSFO-ORX-SP-Loan OGA', 'CSFO-ORX-SP-PCC Offshore Advanced', 'CSFO-ORX-SP-PCC Offshore Core','CSFO-ORX-SP-PCC Offshore Expert')
	AND RPTDATE = @StartDate
	AND GROUP_L1 = 'Specialty Rx'
	AND GROUP_L1 IS NOT NULL
	GROUP BY Agent_ID, GROUP_L1, GROUP_L2 , [LOCATION]



	Update #Agent_Count
		SET GROUP_L2 = CASE WHEN GROUP_L2 = 'CSFO-ORX-SP-Loan OGA' THEN 'Loan'
							WHEN GROUP_L2 = 'CSFO-ORX-SP-PCC Offshore Advanced' THEN 'Advanced'
							WHEN GROUP_L2 = 'CSFO-ORX-SP-PCC Offshore Core' THEN 'Core'
							WHEN GROUP_L2 = 'CSFO-ORX-SP-PCC Offshore Expert' THEN 'Expert'
						ELSE GROUP_L2
		END

	--Select * from #Agent_Count


	SELECT RPTDATE, MU_ID, Agent_ID, Agent_Name, demo.SUPERVISOR , Schedule_Activity,
		Activity_StartTime, Activity_EndTime, Agent_Sched.FN_LOB, demo.MS_ID,
		count(distinct Agent_ID) as Sched_Count,
		Category, Exception_Code, demo.LOB as GROUP_L1, demo.SUB_LOB as GROUP_L2, demo.[LOCATION],

				CASE WHEN Category = 'Unplanned OOO' THEN DATEDIFF(s,Activity_StartTime,Activity_EndTime)/3600 ELSE '' END AS Hours_UnplannedOOO,
		CASE WHEN Category = 'Planned OOO' THEN DATEDIFF(s,Activity_StartTime,Activity_EndTime)/3600 ELSE '' END AS Hours_PlannedOOO
		,CASE WHEN Category = 'Unplanned OOO' THEN DATEDIFF(s,Activity_StartTime,Activity_EndTime) ELSE '' END AS Seconds_UnplannedOOO,
		CASE WHEN Category = 'Planned OOO' THEN DATEDIFF(s,Activity_StartTime,Activity_EndTime) ELSE '' END AS Seconds_PlannedOOO
		 
	INTO #Agent_Schedule 
	FROM SPOTLIGHT_IEX_Automation_Agent_Schedule_Report_DATA_HOURLY Agent_Sched
		LEFT JOIN #demographics demo on demo.EMP_ID = Agent_Sched.EMP_ID
				AND demo.ROSTER_EFFECTIVE_DATE = Agent_Sched.RPTDATE

		LEFT JOIN #IEX_Code_Mapping_SPRx IEX_MAPPING ON Agent_Sched.FN_LOB = IEX_MAPPING.FN_LOB
				AND Agent_Sched.Schedule_Activity = IEX_MAPPING.Exception_Code

	WHERE Category IN ('UnPlanned OOO','Planned OOO')
		AND MU_ID IN ('10262','10251','10252','10254')     -- Note: 10254 adv, 10252 exp, 10251 core, 10262 loan/chat
		--AND DEMO.GROUP_L2 IN ('CSFO-ORX-SP-Loan OGA', 'CSFO-ORX-SP-PCC Offshore Advanced', 'CSFO-ORX-SP-PCC Offshore Core','CSFO-ORX-SP-PCC Offshore Expert')
		--AND DEMO.GROUP_L1 = 'Specialty Rx'
		AND demo.LOB = 'Specialty Rx'
		AND IEX_Mapping.FN_LOB = 'OPTUM.V.OPTUMRX'
		--AND demo.EMP_ID IS NOT NULL
		AND RPTDATE = @StartDate
	GROUP BY RPTDATE, MU_ID, Agent_ID, Agent_Name, demo.SUPERVISOR, Schedule_Activity,
		Activity_StartTime, Activity_EndTime, Agent_Sched.FN_LOB, demo.MS_ID,Category, Exception_Code,
		--DEMO.GROUP_L1, demo.GROUP_L2, 
		demo.LOB, demo.SUB_LOB,
		demo.[LOCATION]


		Update #Agent_Schedule 
		SET GROUP_L2 = CASE WHEN GROUP_L2 = 'CSFO-ORX-SP-Loan OGA' THEN 'Loan'
							WHEN GROUP_L2 = 'CSFO-ORX-SP-PCC Offshore Advanced' THEN 'Advanced'
							WHEN GROUP_L2 = 'CSFO-ORX-SP-PCC Offshore Core' THEN 'Core'
							WHEN GROUP_L2 = 'CSFO-ORX-SP-PCC Offshore Expert' THEN 'Expert'
						ELSE GROUP_L2
		END

	--Select * from #Agent_Schedule

	Select RPTDATE, MU_ID, Agent_ID, Agent_Name, SUPERVISOR,  Schedule_Activity,
		FN_LOB, MS_ID,
		Category, Exception_Code,GROUP_L1, GROUP_L2, [LOCATION],

		SUM(Seconds_UnplannedOOO) as Seconds_UnplannedOOO ,sum(Seconds_PlannedOOO) as Seconds_PlannedOOO, 
		sum(Hours_UnplannedOOO) as Hours_UnplannedOOO, sum(Hours_PlannedOOO) as Hours_PlannedOOO,
		sum(Hours_UnplannedOOO) as UnplannedOOO, sum(Hours_PlannedOOO) as PlannedOOO
		
	INTO #AG
	FROM #Agent_Schedule

	GROUP BY RPTDATE, MU_ID, Agent_ID, Agent_Name, SUPERVISOR,  Schedule_Activity,
		 FN_LOB, MS_ID,
		Category, Exception_Code,GROUP_L1, GROUP_L2, [LOCATION]

	--Select * from #AG


		
	SELECT RPTDATE, MU_ID, Agent_ID, Agent_Name, SUPERVISOR,  Schedule_Activity,
			 FN_LOB, MS_ID,
		Category, Exception_Code,GROUP_L1, GROUP_L2, [LOCATION],

		Seconds_UnplannedOOO,Seconds_PlannedOOO, Hours_UnplannedOOO,Hours_PlannedOOO,
		UnplannedOOO, PlannedOOO,
		CASE WHEN UnplannedOOO > 4 THEN 1 ELSE 0 END AS [UnPlannedOOO_COUNT],
		CASE WHEN PlannedOOO > 4 THEN 1 ELSE 0 END AS [PlannedOOO_COUNT]

	INTO #Agent_Schedule_Base
	FROM #AG
	GROUP BY RPTDATE, MU_ID, Agent_ID, Agent_Name, SUPERVISOR,  Schedule_Activity,
		FN_LOB, MS_ID,
		Category, Exception_Code,GROUP_L1, GROUP_L2, [LOCATION],Seconds_UnplannedOOO,Seconds_PlannedOOO, Hours_UnplannedOOO,Hours_PlannedOOO, UnplannedOOO, PlannedOOO
	
	
	

	select [RPTDATE],[MU_ID],[Agent_ID],[Agent_Name],SUPERVISOR,[Schedule_Activity],	
		[FN_LOB],[MS_ID],[Category],[Exception_Code],GROUP_L1, GROUP_L2, [LOCATION], [Seconds_UnplannedOOO],[Seconds_PlannedOOO],	
		[Hours_UnplannedOOO],[Hours_PlannedOOO],[UnplannedOOO],	[PlannedOOO], [UnPlannedOOO_COUNT], [PlannedOOO_COUNT],
		CASE WHEN [UnPlannedOOO_COUNT] = 1 THEN [Exception_Code] ELSE NULL END AS PLOT

	
	INTO #BaseSPRx

	FROM #Agent_Schedule_Base
	ORDER BY [RPTDATE],[MU_ID],[Agent_ID],[Agent_Name],SUPERVISOR,[Schedule_Activity]


	--Select * from #Agent_Schedule_Base

--	select [RPTDATE],[MU_ID],[Agent_ID],[Agent_Name],SUPERVISOR,[Start_Time],[End_Time],[Schedule_Activity],	
--		[FN_LOB],[MS_ID],[Category],[Exception_Code],GROUP_L1, GROUP_L2, [LOCATION], [Seconds_UnplannedOOO],[Seconds_PlannedOOO],	
--		[Hours_UnplannedOOO],[Hours_PlannedOOO],[UnplannedOOO],	[PlannedOOO], [UnPlannedOOO_COUNT], [PlannedOOO_COUNT], PLOT, ACOUNT

	
--	INTO #BaseSPRx



--FROM (
--Select [RPTDATE],[MU_ID],[Agent_ID],[Agent_Name],SUPERVISOR, [Start_Time],[End_Time],[Schedule_Activity],	
--[FN_LOB],[MS_ID],[Category],[Exception_Code],GROUP_L1, GROUP_L2, [LOCATION],[Seconds_UnplannedOOO],[Seconds_PlannedOOO],	
--[Hours_UnplannedOOO],[Hours_PlannedOOO],[UnplannedOOO],	[PlannedOOO], [UnPlannedOOO_COUNT], [PlannedOOO_COUNT], 
--CASE WHEN [UnPlannedOOO_COUNT] = 1 THEN [Exception_Code] ELSE NULL END AS PLOT,
--NULL AS ACOUNT
--from #Agent_Schedule_Base
--UNION
--SELECT NULL [RPTDATE],NULL [MU_ID],[Agent_ID],NULL [Agent_Name], NULL SUPERVISOR, NULL [Start_Time],NULL [End_Time],NULL[Schedule_Activity],	
--NULL[FN_LOB],NULL[MS_ID],NULL[Category],NULL[Exception_Code], GROUP_L1,  GROUP_L2,  [LOCATION],NULL[Seconds_UnplannedOOO],NULL[Seconds_PlannedOOO],	
--NULL [Hours_UnplannedOOO],NULL [Hours_PlannedOOO],NULL [UnplannedOOO],	NULL [PlannedOOO], NULL [UnPlannedOOO_COUNT], NULL [PlannedOOO_COUNT], NULL PLOT, A_count AS ACOUNT
--FROM #Agent_Count
--) AS New_Tab



--- Sub LOB wise
IF OBJECT_ID('tempdb..#SubLOB_view') IS NOT NULL DROP TABLE #SubLOB_view
IF OBJECT_ID('tempdb..#AS_SubLOB') IS NOT NULL DROP TABLE #AS_SubLOB
IF OBJECT_ID('tempdb..#AC_SubLOB') IS NOT NULL DROP TABLE #AC_SubLOB
IF OBJECT_ID('tempdb..#Location_view') IS NOT NULL DROP TABLE #Location_view
IF OBJECT_ID('tempdb..#AS_Location') IS NOT NULL DROP TABLE #AS_Location
IF OBJECT_ID('tempdb..#AC_Location') IS NOT NULL DROP TABLE #AC_Location
IF OBJECT_ID('tempdb..#Location') IS NOT NULL DROP TABLE #Location
IF OBJECT_ID('tempdb..#SubLOB') IS NOT NULL DROP TABLE #SubLOB

	Select sum(A_count) as Acount, GROUP_L1 , GROUP_L2
	INTO #AC_SubLOB
	from #Agent_Count
	group by GROUP_L1 , GROUP_L2

	--Select * from #AC_SubLOB


	Select GROUP_L1, GROUP_L2, SUM([UnPlannedOOO_COUNT]) as [UnPlannedOOO_COUNT], 
			SUM([PlannedOOO_COUNT]) as [PlannedOOO_COUNT]
		INTO #AS_SubLOB
	FROM #Agent_Schedule_Base
		GROUP BY GROUP_L1, GROUP_L2

	--Select * from #AS_SubLOB
	
	Select AC.GROUP_L1, Ac.GROUP_L2, [UnPlannedOOO_COUNT], [PlannedOOO_COUNT],
			Acount, 
			Acount - ([UnPlannedOOO_COUNT] + [PlannedOOO_COUNT]) as [Count]

	INTO #SubLOB
	FROM #AS_SubLOB ASB
	FULL OUTER JOIN  #AC_SubLOB AC ON ASB.GROUP_L1 = AC.GROUP_L1
		AND ASB.GROUP_L2 = AC.GROUP_L2


	Select GROUP_L1, GROUP_L2, [UnPlannedOOO_COUNT], [PlannedOOO_COUNT],
			Acount, [Count],
			Case when [Count] Is NULL then Acount ELSE [Count] END AS Present_Count
	INTO #SubLOB_view
	from #SubLOB

	--Select * from #SubLOB
	--Select * from #SubLOB_view


------------------------------------------------------------
--- Location wise


		Select sum(A_count) as Acount, GROUP_L1 , [LOCATION]
	INTO #AC_Location
	from #Agent_Count
	group by GROUP_L1 , [LOCATION]

	--Select * from #AC_Location


	Select GROUP_L1, [LOCATION], SUM([UnPlannedOOO_COUNT]) as [UnPlannedOOO_COUNT], 
			SUM([PlannedOOO_COUNT]) as [PlannedOOO_COUNT]
		INTO #AS_Location
	FROM #Agent_Schedule_Base
		GROUP BY GROUP_L1, [LOCATION]

	--Select * from #AS_Location
	
	Select AC.GROUP_L1, Ac.[LOCATION], [UnPlannedOOO_COUNT], [PlannedOOO_COUNT],
			Acount,
			Acount - ([UnPlannedOOO_COUNT] + [PlannedOOO_COUNT]) as [Count]

	INTO #Location
	FROM #AS_Location ASB
	FULL OUTER JOIN  #AC_Location AC ON ASB.GROUP_L1 = AC.GROUP_L1
		AND ASB.[LOCATION] = AC.[LOCATION]


	Select GROUP_L1, [LOCATION], [UnPlannedOOO_COUNT], [PlannedOOO_COUNT],
			Acount, [Count],
			Case when [Count] Is NULL then Acount ELSE [Count] END AS Present_Count
	INTO #Location_view 
	from #Location
	

	--Select * from #Location_view
	--Select * from #Location

-----------------------------------------------------------------------
-----------------------------------------------------------------------

	
	if @ReportView = 'PHD_view'
begin
Select * from #Base_PHD_MS
where Group_L1 = 'PHD'
end

	if @ReportView = 'PHD_Plot_view'
begin
Select * from #Base_PHD_MS
where Group_L1 = 'PHD'
AND ABSENT_COUNT = 1
AND PLOT IS NOT NULL
end

------------------------------------------------------------------------
------------------------------------------------------------------------

	if @ReportView = 'MS_view'
begin
Select * from #Base_PHD_MS
where GROUP_L1 IN ('Member Services','Web Tech')
--AND GROUP_L2 IN ('PBM Global Lead/Assist', 'PBM Global Preferred', 
--					'PCS Global Lead/Assist', 'PCS Global MnR',
--					'PCS Global Preferred', 'PCS Global Web','PBM D-CARD')
end

	if @ReportView = 'MS_Plot_view'
begin
Select * from #Base_PHD_MS
where Group_L1 IN ('Member Services','Web tech')
--AND GROUP_L2 IN ('PBM Global Lead/Assist', 'PBM Global Preferred', 
--					'PCS Global Lead/Assist', 'PCS Global MnR',
--					'PCS Global Preferred', 'PCS Global Web','PBM Global Dcard')
AND ABSENT_COUNT = 1
AND PLOT IS NOT NULL
end

------------------------------------------------------------------------
------------------------------------------------------------------------

--		if @ReportView = 'SPRx_view'
--begin
--Select * from #BaseSPRx
--where Group_L1 = 'Specialty Rx'
--end

	if @ReportView = 'SPRx_Plot_view'
begin
Select * from #BaseSPRx
where Group_L1 = 'Specialty Rx'
AND [UnPlannedOOO_COUNT] = 1
end


		if @ReportView = 'SPRx_SubLOB_view'
begin
Select * from #SubLOB_view
end

	
		if @ReportView = 'SPRx_Location_view'
begin
Select * from #Location_view 
end



END