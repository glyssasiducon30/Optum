USE [MIS_SPOTLIGHT]
GO

/****** Object:  StoredProcedure [dbo].[Spotlight_OT_VTO_MemberServices]    Script Date: 8/5/2025 11:54:10 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Glyssa Siducon>
-- Create date: <May 23 2023>
-- Description:	<Optum Rx MS OT_VTO Report>
-- USED in OT_VTO Report Member Services
--=============================================
ALTER PROCEDURE [dbo].[Spotlight_OT_VTO_MemberServices_v2]
	
		@StartDate date = NULL,
		@EndDate date = NULL,
		@Line_Of_Business varchar(max) = NULL,
		@FN_LOB varchar(max) = NULL,
		@Supervisor varchar(max) = NULL,
		@Deputy_Manager varchar(max) = NULL,
		@Location varchar(max) = NULL,
		@Group_L1 varchar(max) = NULL,
		@ReportView varchar(max) = NULL


AS
BEGIN
	
/*
	Declare 
		
			@StartDate date = '2025-07-01',
			@EndDate date = '2025-08-02', --DATEADD(d, -1, GETUTCDATE()),
			@Line_Of_Business varchar(max) = 'OPTUM RX',
			@FN_LOB varchar(max) = 'OPTUM.V.OPTUMRX',
			@Supervisor varchar(max) = NULL,
			@Deputy_Manager varchar(max) = NULL,
			@Location varchar(max) = NULL,
			@Group_L1 varchar(max) = NULL,
			@ReportView varchar(max) = 'OT_Overall' -- NULL --'OT_Overall' --NULL --'VTO_Overall' --'RawData'

*/
	--IF @ReportView = 'Overall'
	--BEGIN
	--	SELECT NULL AS [Date], NULL AS Align, NULL AS [Type], NULL AS Agent_Id, NULL AS Agent_Name, NULL AS Schedule_Activity, NULL AS Activity_StartTime
	--			, NULL AS Activity_EndTime, NULL AS OT_Status, NULL AS OT_Compliance
	--			, NULL AS Length_Mins, NULL AS [Hours], NULL AS Pre_Post_RDOT
	--			, NULL AS Main_LOB, NULL AS [Sub LOB], NULL AS TotalHours
	--			, NULL AS [MS_ID], NULL AS [AgentName], NULL AS SUPERVISOR, NULL AS DEPUTY_MANAGER, NULL AS [LOCATION]
	--END END

	--IF @ReportView = 'OT_Overall'
	--BEGIN
	--	SELECT NULL AS [Date], NULL AS [Type], NULL AS Align, NULL AS MU_ID, NULL AS Agent_Id, NULL AS Activity_StartTime, NULL AS Activity_EndTime, NULL AS Schedule_Activity,
	--	NULL AS FN_LOB, NULL AS FULL_NAME, NULL AS EMP_ID, NULL AS MS_ID, NULL AS SUPERVISOR, NULL AS DEPUTY_MANAGER, NULL AS LINE_OF_BUSINESS, NULL AS [LOCATION], NULL AS GROUP_L1, 
	--			NULL AS [SUB LOB], NULL AS [MAIN_LOB],
	--			NULL AS [Start CST],
	--			NULL AS [End CST], NULL AS OT_Status, NULL AS OT_Compliance, NULL AS Category, NULL AS SCHEDULE,NULL AS [Length_mins], NULL AS [Length_Hours], NULL AS [PRE/POST/RDOT]
				
	--END
	--END

	--IF @ReportView = 'VTO_Overall'
	--BEGIN
	--	SELECT NULL AS Date, NULL AS Align, NULL AS Type, NULL AS Agent_Id, NULL AS Agent_Name, NULL AS Schedule_Activity, NULL AS Activity_StartTime
	--			, NULL AS Activity_EndTime, NULL AS OT_Status, NULL AS OT_Compliance, NULL AS Sub_Category,
	--			, NULL AS TimeLengthinMins, NULL AS TimeLengthinHours, NULL AS RenderedTimeLengthinMins, NULL AS RenderedTimeLengthinHours, NULL AS Pre_Post_RDOT
	--			, NULL AS Main_LOB, NULL AS Sub_LOB, NULL AS TotalHours
	--			, NULL AS [MS_ID], NULL AS [AgentName], NULL AS SUPERVISOR, NULL AS DEPUTY_MANAGER, NULL AS [LOCATION]
	--END 
	--END

	--IF @ReportView = 'RawData'
	--BEGIN
	--	SELECT NULL AS Date, NULL AS Agent_Id, NULL AS Agent_Name, NULL AS Schedule_Activity, NULL AS Activity_StartTime
	--			, NULL AS Activity_EndTime, NULL AS OT_Status, NULL AS OT_Compliance
	--			, NULL AS Length_Mins, NULL AS [Hours], NULL AS Pre_Post_RDOT
	--			, NULL AS Main_LOB, NULL AS Sub_LOB
	--			, NULL AS [MS_ID], NULL AS [AgentName], NULL AS SUPERVISOR, NULL AS DEPUTY_MANAGER, NULL AS [LOCATION]
	--END 
	--END

			
			IF @StartDate IS NULL
				BEGIN
					SET @StartDate = DATEADD(d, -1, GETUTCDATE())
				END

			IF @EndDate IS NULL
				BEGIN
					SET @EndDate = DATEADD(d, -1, GETUTCDATE())
				END

			IF @Line_Of_Business IS NULL
				BEGIN
					SET @Line_Of_Business = 'OPTUM RX'
				END
			IF @FN_LOB IS NULL
				BEGIN
					SET @FN_LOB = 'OPTUM.V.OPTUMRX'
				END


	-------------------------------------------------------------------------------------------------------------------------Param Line_Of_Business
	IF OBJECT_ID ('tempdb..#ParamLine_Of_Business') IS NOT NULL Drop table #ParamLine_Of_Business

	CREATE TABLE #ParamLine_Of_Business (val VARCHAR(MAX)) 
		IF @Line_Of_Business IS NULL
			BEGIN
				INSERT INTO #ParamLine_Of_Business (val)
				SELECT
					DISTINCT LTRIM(RTRIM(LINE_OF_BUSINESS))
			FROM Spotlight_EmployeeInformationDeriveFromLH
			WHERE LINE_OF_BUSINESS = 'OPTUM RX'
			AND GROUP_L4 = 'PHL PHARMACY MEMBER SRVCES OPT'
					AND ROSTER_EFFECTIVE_DATE between @StartDate and @EndDate

			END
		ELSE
			BEGIN
				INSERT INTO #ParamLine_Of_Business(val)
				SELECT
					LTRIM(RTRIM(VALUE))
					FROM dbo.FnSplit(@Line_Of_Business,'!')
			END	
			
-------------------------------------------------------------------------------------------------------------------------Param Group_L1
	IF OBJECT_ID ('tempdb..#ParamGroup_L1') IS NOT NULL Drop table #ParamGroup_L1

	CREATE TABLE #ParamGroup_L1 (val VARCHAR(MAX)) 
		IF @Group_L1 IS NULL
			BEGIN
				INSERT INTO #ParamGroup_L1 (val)
				SELECT
					DISTINCT LTRIM(RTRIM(GROUP_L4)) as GROUP_L1
			FROM Spotlight_EmployeeInformationDeriveFromLH
			WHERE LINE_OF_BUSINESS = 'OPTUM RX'
			AND GROUP_L4 = 'PHL PHARMACY MEMBER SRVCES OPT'
					AND ROSTER_EFFECTIVE_DATE between @StartDate and @EndDate

			END
		ELSE
			BEGIN
				INSERT INTO #ParamLine_Of_Business(val)
				SELECT
					LTRIM(RTRIM(VALUE))
					FROM dbo.FnSplit(@Line_Of_Business,'!')
			END	


	--------------------------------------------------------------------------------------------------------------------------Param Supervisor
	IF OBJECT_ID ('tempdb..#ParamSupervisor') IS NOT NULL Drop Table #ParamSupervisor

	CREATE TABLE #ParamSupervisor (val VARCHAR(Max))
		IF @Supervisor IS NULL
			BEGIN
				INSERT INTO #ParamSupervisor (val)
				SELECT
					DISTINCT LTRIM(RTRIM(SUPERVISOR))
			FROM Spotlight_EmployeeInformationDeriveFromLH
			WHERE LINE_OF_BUSINESS = 'OPTUM RX'
			AND GROUP_L4 = 'PHL PHARMACY MEMBER SRVCES OPT'
					AND ROSTER_EFFECTIVE_DATE between @StartDate and @EndDate
			END
		ELSE
			BEGIN
				INSERT INTO #ParamSupervisor(val)
				SELECT
					LTRIM(RTRIM(VALUE))
					FROM dbo.FnSplit(@Supervisor,'!')
			END

		--select * from #ParamSupervisor
	------------------------------------------------------------------------------------------------------------------------------#Param Deputy_Manager
	IF OBJECT_ID ('tempdb..#ParamDeputy_Manager') IS NOT NULL DROP Table #ParamDeputy_Manager

	CREATE TABLE #ParamDeputy_Manager (val VARCHAR(Max))
		IF @Deputy_Manager IS NULL
			BEGIN
				INSERT INTO #ParamDeputy_Manager (Val)
				SELECT
					DISTINCT LTRIM(RTRIM(DEPUTY_MANAGER))
			FROM Spotlight_EmployeeInformationDeriveFromLH
			WHERE LINE_OF_BUSINESS = 'OPTUM RX'
			AND GROUP_L4 = 'PHL PHARMACY MEMBER SRVCES OPT'
					AND ROSTER_EFFECTIVE_DATE between @StartDate and @EndDate
			END
		ELSE
			BEGIN
				INSERT INTO #ParamDeputy_Manager (val)
				SELECT
					LTRIM(RTRIM(VALUE))
					FROM dbo.FnSplit(@Deputy_Manager,'!')
			END

		--select * from #ParamDeputy_Manager

	--------------------------------------------------------------------------------------------------------------------------------#ParamLocation
	IF OBJECT_ID ('tempdb..#ParamLocation') IS NOT NULL DROP TABLE #ParamLocation

	CREATE TABLE #ParamLocation (val VARCHAR(max))
		if @Location IS NULL
			BEGIN
				INSERT INTO #ParamLocation (val)
				SELECT
					DISTINCT LTRIm(RTRIM(Location))
			FROM Spotlight_EmployeeInformationDeriveFromLH
			WHERE LINE_OF_BUSINESS = 'OPTUM RX'
			AND GROUP_L4 = 'PHL PHARMACY MEMBER SRVCES OPT'
					AND ROSTER_EFFECTIVE_DATE between @StartDate and @EndDate
			END
		ELSE
			BEGIN
				INSERT INTO #ParamLocation (val)
				SELECT
					LTRIM(RTRIM(VALUE))
					FROM dbo.FnSplit(@Location,'!')
		END
		
		--select * from #ParamLocation
------------------------------------------------------------------------------------------------------DEMOGRAPHICS
	IF OBJECT_ID ('tempdb..#Demographics') IS NOT NULL DROP TABLE #Demographics

	SELECT EMP_ID, MS_ID, FULL_NAME, SUPERVISOR, DEPUTY_MANAGER, [LOCATION], LINE_OF_BUSINESS, GROUP_L4 as GROUP_L1, ROSTER_EFFECTIVE_DATE
		INTO #Demographics
			FROM Spotlight_EmployeeInformationDeriveFromLH
				WHERE ROSTER_EFFECTIVE_DATE between @StartDate and @EndDate
				AND LINE_OF_BUSINESS IN (SELECT LTRIM(RTRIM(VALUE)) FROM dbo.FnSplit(@Line_of_Business,'!'))
				AND EMP_ID IS NOT NULL
				AND ISNULL([LOCATION],'-') IN (SELECT val FROM #ParamLocation)
				AND ISNULL(DEPUTY_MANAGER,'-') IN (SELECT val FROM #ParamDeputy_Manager)
				AND ISNULL(Supervisor,'-') IN (SELECT val FROM #ParamSupervisor)


	OPTION(RECOMPILE)
			--select * from #Demographics
	---------------------------------------------------------------------------------------------------- IEXCode Mapping

	IF OBJECT_ID('tempdb..#IEXCodeMapping') IS NOT NULL DROP TABLE #IEXCodeMapping

		Select *
	INTO #IEXCodeMapping
	FROM
	(
		Select DISTINCT Exception_Code, FN_LOB,OT_Compliance, OT_Status, Category, Sub_Category
		FROM dbo.Spotlight_IEX_ExceptionCodeMapping
		WHERE FN_LOB IN ('OPTUM.V.OPTUMRX')
		) a
	--WHERE Exception_Code LIKE '%OT%' OR Exception_Code LIKE '%VTO%'
	WHERE Category IN ('OT', 'Planned OOO', 'Unplanned OOO')
	AND Sub_Category IN ('OT Taken', 'OT Removal', 'VTO') --VTO tagging changed columns from iex mapping

	OPTION(RECOMPILE)
	--select * from #IEXCodeMapping
-------------------------------------------------------------------------------------------------------- Sub_LOB
	IF OBJECT_ID('tempdb..#Temp_SubLOBGrouping') IS NOT NULL DROP TABLE #Temp_SubLOBGrouping

	--Select DISTINCT FN_LOB, MAIN_LOB, [SUB LOB], MU
	--INTO #Temp_SubLOBGrouping
	--FROM Spotlight_SublobgroupingforOptumRx
	--WHERE MU IN (9220, 9208, 9205, 9206, 9219, 9249, 9515, 9514)  -- added 9249 for MS M&R 12/6/2023 -- 9515, 9514 added effective 06/01/2024
	--AND FN_LOB IN (SELECT LTRIM(RTRIM(VALUE)) FROM dbo.FnSplit(@FN_LOB,'!'))

		Select DISTINCT FN_LOB, MAIN_LOB, [SUB LOB], MU, EFFECTIVE_START_DATE, EFFECTIVE_END_DATE
		INTO #Temp_SubLOBGrouping
			FROM Spotlight_SublobgroupingforOptumRx
			WHERE MAIN_LOB = 'Member Services'
				--(9220, 9208, 9205, 9206, 9219, 9249)  -- added 9249 for MS M&R 12/6/2023 -- 9515, 9514 added effective 06/01/2024
			AND FN_LOB IN (SELECT LTRIM(RTRIM(VALUE)) FROM dbo.FnSplit(@FN_LOB,'!'))
	OPTION(RECOMPILE)	
	--Select * from #Temp_SubLOBGrouping

	If @StartDate < '2024-06-01'
	begin
		UPDATE #Temp_SubLOBGrouping
		SET [SUB LOB] = 'MS CORE'
		WHERE MU IN ('9208','1827')   -- CORE and ADV are now combined. Joe Ortega requested to make ADV as CORE
	end

--Select * from #Temp_SubLOBGrouping

------------------------------------------------------------------------------------------------------OFF_AgentScheduleCalendar
	IF OBJECT_ID('tempdb..#OFF_AgentScheduleCalendar') IS NOT NULL DROP TABLE #OFF_AgentScheduleCalendar

	Select RPTDATE, MU_ID, AGENT_ID, AGENT_NAME, SCHEDULE, FN_LOB, EMP_ID, MS_ID, FULL_NAME, SUPERVISOR, DEPUTY_MANAGER, LINE_OF_BUSINESS,
		[LOCATION], GROUP_L1,
		case when SCHEDULE = 'Off' THEN DATENAME(WEEKDAY, RPTDATE) ELSE SCHEDULE END AS OffDay
	INTO #OFF_AgentScheduleCalendar
		FROM LH_VOICE_WFM_RPT_NICE_IEX_AGENT_SCHEDULE_CALENDAR_DATA 
			WHERE MU_ID IN (select distinct MU from #Temp_SubLOBGrouping)  --(9220, 9208, 9205, 9206, 9219, 9249, 9515, 9514)
			AND FN_LOB IN (SELECT LTRIM(RTRIM(VALUE)) FROM dbo.FnSplit(@FN_LOB,'!'))
			--AND LINE_OF_BUSINESS IN (SELECT LTRIM(RTRIM(VALUE)) FROM dbo.FnSplit(@Line_of_Business,'!'))
			AND RPTDATE Between @StartDate and @EndDate
			--AND Group_L1 IN ('Member Services','Web Tech')
			--AND ISNULL([LOCATION],'-') IN (SELECT val FROM #ParamLocation)
			--AND ISNULL(DEPUTY_MANAGER,'-') IN (SELECT val FROM #ParamDeputy_Manager)
			--AND ISNULL(SUPERVISOR,'-') IN (SELECT val FROM #ParamSupervisor)
			ORDER BY [RPTDATE]
OPTION(RECOMPILE)
	--select * from #OFF_AgentScheduleCalendar

--param is removed as demogs part of the table is empty
			
----------------------------------------------------------------------------------------------------------------------------------AgentSched_Base
	IF OBJECT_ID('tempdb..#AgentSched_Base') IS NOT NULL DROP TABLE #AgentSched_Base

	Select YEAR(AS_Base.[RPTDATE]) AS [Year],
			'Q' + CAST(DATEPART(quarter, AS_Base.RPTDATE) AS VARCHAR(2)) AS [Quarter],
			CONVERT(VARCHAR(10),DATEPART(MM,AS_Base.RPTDATE)) + '-' + DATENAME(MONTH,AS_Base.RPTDATE) AS [MonthNum],
			CONVERT(VARCHAR(10),DATEADD(dd, 7-(DATEPART(dw, AS_Base.RPTDATE)), AS_Base.RPTDATE)) AS [WeekEnding],
			CONVERT(VARCHAR(10),AS_Base.RPTDATE) AS [Date],
			Start_Time
			,End_Time
			,AS_Base.MU_ID
			,AS_Base.Agent_Id
			,AS_Base.Agent_Name
			,AS_Base.Activity_StartTime
			,AS_Base.Activity_EndTime
			,AS_Base.Schedule_Activity
			,AS_Base.FN_LOB
			,AS_Base.EMP_ID
			,AS_Base.MS_ID
			,AS_Base.SUPERVISOR
			,AS_Base.DEPUTY_MANAGER
			,AS_Base.LINE_OF_BUSINESS
			,AS_Base.[LOCATION]
			,AS_Base.GROUP_L1
			,CAST(CONCAT(Schedule_Date, ' ', Activity_StartTime) AS DATETIME) AS [Start CST],
			CASE 
				WHEN CAST(Activity_EndTime AS TIME) >  CAST(Activity_StartTime AS TIME) 
				THEN CAST(CONCAT(Schedule_Date, ' ', Activity_EndTime) AS DATETIME) 
				ELSE DATEADD(DAY,1,CAST(CONCAT(Schedule_Date, ' ', Activity_EndTime) AS DATETIME))
				END AS [End CST]
			,IEXCodeMapping.OT_Status
			,IEXCodeMapping.OT_Compliance
			,IEXCodeMapping.Category
			,IEXCodeMapping.Sub_Category
			,SubLOBGrouping.[SUB LOB]
			,SubLOBGrouping.[MAIN_LOB]
			,SubLOBGrouping.MU
	Into #AgentSched_Base
		FROM SPOTLIGHT_IEX_Automation_Agent_Schedule_Report_DATA_HOURLY AS_Base
		INNER JOIN #IEXCodeMapping IEXCodeMapping ON IEXCodeMapping.Exception_Code = AS_Base.Schedule_Activity
		LEFT JOIN #Temp_SubLOBGrouping SubLOBGrouping ON AS_Base.FN_LOB = SubLOBGrouping.FN_LOB
				 AND AS_Base.MU_ID = SubLOBGrouping.MU
		WHERE AS_Base.RPTDATE between @StartDate and @EndDate
			AND AS_Base.MU_ID IN (select distinct MU from #Temp_SubLOBGrouping) --(9220, 9208, 9205, 9206, 9219, 9249)  -- added 9249 for MS M&R 12/6/2023
			AND SubLOBGrouping.EFFECTIVE_START_DATE <= @EndDate 
			AND (SubLOBGrouping.EFFECTIVE_END_DATE >= @StartDate or SubLOBGrouping.EFFECTIVE_END_DATE IS NULL) --added effective date to reflect new MS Name convention based on effective dates
			AND AS_Base.TIME_INTERVAL_60_MINUTES = '02:30'
			AND AS_Base.AGENT_ID IS NOT NULL
			--AND AS_Base.FN_LOB IN (SELECT LTRIM(RTRIM(VALUE)) FROM dbo.FnSplit(@FN_LOB,'!'))
			--AND AS_Base.LINE_OF_BUSINESS IN (SELECT LTRIM(RTRIM(VALUE)) FROM dbo.FnSplit(@Line_of_Business,'!'))
			--AND AS_Base.RPTDATE Between @StartDate and @EndDate
			--AND ISNULL(AS_Base.[LOCATION],'-') IN (SELECT val FROM #ParamLocation)
			--AND ISNULL(AS_Base.DEPUTY_MANAGER,'-') IN (SELECT val FROM #ParamDeputy_Manager)
			--AND ISNULL(AS_Base.SUPERVISOR,'-') IN (SELECT val FROM #ParamSupervisor)
			--ORDER BY AS_Base.[RPTDATE]
OPTION(RECOMPILE)
--Select * from #AgentSched_Base
----------------------------------------------------------------------------------------------------------------------------------------------- Base_OTVTO
	IF OBJECT_ID('tempdb..#baseOTVTO') IS NOT NULL DROP TABLE #baseOTVTO

	Select  [Year]
			,[Quarter]
			,[MonthNum]
			,[WeekEnding]
			,[Date]
			,Start_Time
			,End_Time
			,AS_Base.MU_ID
			,AS_Base.Agent_Id
			,AS_Base.Activity_StartTime
			,AS_Base.Activity_EndTime
			,AS_Base.Schedule_Activity
			,AS_Base.FN_LOB
			,demo.FULL_NAME
			,demo.EMP_ID
			,demo.MS_ID
			,demo.SUPERVISOR
			,demo.DEPUTY_MANAGER
			,demo.LINE_OF_BUSINESS
			,demo.[LOCATION]
			,demo.GROUP_L1
			,AS_Base.[Start CST]
			,AS_Base.[End CST]
			,AS_Base.OT_Status
			,AS_Base.OT_Compliance
			,AS_Base.Category
			,AS_Base.Sub_Category
			,OFF_Sched.SCHEDULE
			,AS_Base.[SUB LOB]
			,AS_Base.MAIN_LOB
			,DATEDIFF(MINUTE,[Start CST],[END CST]) AS [Length_mins]
			,CAST(DATEDIFF(SECOND,[Start CST],[END CST])/ 3600.00 AS NUMERIC(10,2)) AS [Length_Hours]
			,CASE 
				WHEN OffDay = DATENAME(WEEKDAY, AS_Base.[Date]) THEN 'RDOT' 
				WHEN AS_Base.[Activity_StartTime] <= '1:55 PM' THEN 'PRE' 
					ELSE 'POST' 
				END AS [PRE/POST/RDOT]
	INTO #baseOTVTO
		FROM #AgentSched_Base AS_Base	
			INNER JOIN #Demographics demo ON AS_Base.[Date] = demo.[ROSTER_EFFECTIVE_DATE]
					AND AS_Base.[Agent_Id] = REPLACE(LTRIM(REPLACE(demo.[EMP_ID], '0',' ')),' ', '0')
			INNER JOIN #IEXCodeMapping IEXCodeMapping ON AS_Base.[Schedule_Activity] = IEXCodeMapping.[Exception_Code]
			INNER JOIN #OFF_AgentScheduleCalendar OFF_Sched 
				ON  AS_Base.[Agent_Id] = OFF_Sched.AGENT_ID --REPLACE(LTRIM(REPLACE(OFF_Sched.[EMP_ID], '0',' ')),' ', '0')
					AND AS_Base.[Date] = OFF_Sched.RPTDATE
		GROUP BY [Year], [Quarter], [MonthNum], [WeekEnding],[Date] ,Start_Time,End_Time, AS_Base.MU_ID, AS_Base.Agent_Id, AS_Base.Activity_StartTime, AS_Base.Activity_EndTime, AS_Base.Schedule_Activity, AS_Base.FN_LOB, demo.FULL_NAME, demo.EMP_ID,demo.MS_ID, demo.SUPERVISOR, demo.DEPUTY_MANAGER, demo.LINE_OF_BUSINESS, demo.[LOCATION], demo.GROUP_L1,AS_Base.[Start CST], AS_Base.[End CST], AS_Base.OT_Status, AS_Base.OT_Compliance,AS_Base.Category, AS_Base.Sub_Category, OFF_Sched.SCHEDULE,AS_Base.[SUB LOB], AS_Base.MAIN_LOB, OffDay
		ORDER BY [Date]
OPTION(RECOMPILE)
	--Select * from #baseOTVTO
	
--------- Overall view
	
	IF @ReportView = 'Overall'
		BEGIN

			SELECT
				[Date], SUM([Length_Hours]) AS TotalHours
			INTO #tmpTotalHoursDaily
			FROM #baseOTVTO
			GROUP BY [Date]
			

			SELECT
				[WeekEnding], SUM([Length_Hours]) AS TotalHours
			INTO #tmpTotalHoursWeekly
			FROM #baseOTVTO
			GROUP BY [WeekEnding]
			

			SELECT
				[MonthNum], SUM([Length_Hours]) AS TotalHours
			INTO #tmpTotalHoursMonthly
			FROM #baseOTVTO
			GROUP BY [MonthNum]
			

	SELECT 
				Date, Align, Type, Agent_Id, Schedule_Activity, Activity_StartTime
				, Activity_EndTime, OT_Status, OT_Compliance, SCHEDULE
				, Length_mins, [Length_Hours], [PRE/POST/RDOT]
				, Main_LOB, [SUB LOB], TotalHours
				, [MS_ID], [FULL_NAME], SUPERVISOR, DEPUTY_MANAGER, [LOCATION]
			FROM (
				SELECT tmpoverall.MonthNum AS 'Date', '1' AS Align, 'Monthly' AS Type, Agent_Id
					, Start_Time
					, End_Time
					, Schedule_Activity
					, Activity_StartTime
					, Activity_EndTime
					, OT_Status
					, OT_Compliance
					, SCHEDULE
					, EMP_ID
					, Length_mins
					, [Length_Hours]
					, [PRE/POST/RDOT]
					, Main_LOB
					, [Sub LOB]
					, TotalHours
					, [MS_ID], [FULL_NAME], SUPERVISOR, DEPUTY_MANAGER, [LOCATION]
				FROM #baseOTVTO tmpoverall
				INNER JOIN #tmpTotalHoursMonthly tmpTotalHoursMonthly
					ON tmpoverall.MonthNum = tmpTotalHoursMonthly.MonthNum
				UNION ALL
				SELECT tmpoverall.WeekEnding AS 'Date', '2' AS Align, 'Weekly' AS Type, Agent_Id
					, Start_Time
					, End_Time
					, Schedule_Activity
					, Activity_StartTime
					, Activity_EndTime
					, OT_Status
					, OT_Compliance
					, SCHEDULE
					, EMP_ID
					, Length_mins
					, [Length_Hours]
					, [PRE/POST/RDOT]
					, Main_LOB
					, [Sub LOB]
					, TotalHours
					, [MS_ID], [FULL_NAME], SUPERVISOR, DEPUTY_MANAGER, [LOCATION]
				FROM #baseOTVTO tmpoverall
				INNER JOIN #tmpTotalHoursWeekly tmpTotalHoursWeekly
					ON tmpoverall.WeekEnding = tmpTotalHoursWeekly.WeekEnding
				UNION ALL
				SELECT CONVERT(VARCHAR(10),tmpoverall.[Date]) AS 'Date', '3' AS Align, 'Daily' AS Type, Agent_Id
					, Start_Time
					, End_Time
					, Schedule_Activity
					, Activity_StartTime
					, Activity_EndTime
					, OT_Status
					, OT_Compliance
					, SCHEDULE
					, EMP_ID
					, Length_mins
					, [Length_Hours]
					, [PRE/POST/RDOT]
					, Main_LOB
					, [Sub LOB]
					, TotalHours
					, [MS_ID], [FULL_NAME], SUPERVISOR, DEPUTY_MANAGER, [LOCATION]
				FROM #baseOTVTO tmpoverall
				INNER JOIN #tmpTotalHoursDaily tmpTotalHoursDaily
					ON tmpoverall.[Date] = tmpTotalHoursDaily.[Date]
			) Overall
		END


	IF OBJECT_ID('tempdb..#tmpTotalHoursDaily_OT') IS NOT NULL DROP TABLE #tmpTotalHoursDaily_OT
	IF OBJECT_ID('tempdb..#tmpTotalHoursWeekly_OT') IS NOT NULL DROP TABLE #tmpTotalHoursWeekly_OT
	IF OBJECT_ID('tempdb..#tmpTotalHoursMonthly_OT') IS NOT NULL DROP TABLE #tmpTotalHoursMonthly_OT

	IF OBJECT_ID('tempdb..#tmpTotalHoursDaily_Loc_OT') IS NOT NULL DROP TABLE #tmpTotalHoursDaily_Loc_OT
	IF OBJECT_ID('tempdb..#tmpTotalHoursWeekly_Loc_OT') IS NOT NULL DROP TABLE #tmpTotalHoursWeekly_Loc_OT
	IF OBJECT_ID('tempdb..#tmpTotalHoursMonthly_Loc_OT') IS NOT NULL DROP TABLE #tmpTotalHoursMonthly_Loc_OT

	IF OBJECT_ID('tempdb..#tmpTotalHoursDaily_DM_OT') IS NOT NULL DROP TABLE #tmpTotalHoursDaily_DM_OT
	IF OBJECT_ID('tempdb..#tmpTotalHoursWeekly_DM_OT') IS NOT NULL DROP TABLE #tmpTotalHoursWeekly_DM_OT
	IF OBJECT_ID('tempdb..#tmpTotalHoursMonthly_DM_OT') IS NOT NULL DROP TABLE #tmpTotalHoursMonthly_DM_OT

	IF OBJECT_ID('tempdb..#tmpTotalHoursDaily_Sup_OT') IS NOT NULL DROP TABLE #tmpTotalHoursDaily_Sup_OT
	IF OBJECT_ID('tempdb..#tmpTotalHoursWeekly_Sup_OT') IS NOT NULL DROP TABLE #tmpTotalHoursWeekly_Sup_OT
	IF OBJECT_ID('tempdb..#tmpTotalHoursMonthly_Sup_OT') IS NOT NULL DROP TABLE #tmpTotalHoursMonthly_Sup_OT

	IF OBJECT_ID('tempdb..#tmpTotalHoursDaily_Agent_OT') IS NOT NULL DROP TABLE #tmpTotalHoursDaily_Agent_OT
	IF OBJECT_ID('tempdb..#tmpTotalHoursWeekly_Agent_OT') IS NOT NULL DROP TABLE #tmpTotalHoursWeekly_Agent_OT
	IF OBJECT_ID('tempdb..#tmpTotalHoursMonthly_Agent_OT') IS NOT NULL DROP TABLE #tmpTotalHoursMonthly_Agent_OT


		IF @ReportView = 'OT_Overall'
		BEGIN

			SELECT
				[Date], SUM([Length_Hours]) AS TotalHours
			INTO #tmpTotalHoursDaily_OT
			FROM #baseOTVTO
			--WHERE OT_Compliance IN ('Rendered','Not Rendered')
			WHERE Category = 'OT'
			GROUP BY [Date]

			SELECT
				[WeekEnding], SUM([Length_Hours]) AS TotalHours
			INTO #tmpTotalHoursWeekly_OT
			FROM #baseOTVTO
			--WHERE OT_Compliance IN ('Rendered','Not Rendered')
			WHERE Category = 'OT'
			GROUP BY [WeekEnding]

			SELECT
				[MonthNum], SUM([Length_Hours]) AS TotalHours
			INTO #tmpTotalHoursMonthly_OT
			FROM #baseOTVTO
			--WHERE OT_Compliance IN ('Rendered','Not Rendered')
			WHERE Category = 'OT'
			GROUP BY [MonthNum]

			SELECT
				[Date], LOCATION,SUM([Length_Hours]) AS LocTotalHours
			INTO #tmpTotalHoursDaily_Loc_OT
			FROM #baseOTVTO
			--WHERE OT_Compliance IN ('Rendered','Not Rendered')
				WHERE Category = 'OT'
			GROUP BY [Date],LOCATION

			SELECT
				[WeekEnding], LOCATION, SUM([Length_Hours]) AS LocTotalHours
			INTO #tmpTotalHoursWeekly_Loc_OT
			FROM #baseOTVTO
			--WHERE OT_Compliance IN ('Rendered','Not Rendered')
				WHERE Category = 'OT'
			GROUP BY [WeekEnding], LOCATION

			SELECT
				[MonthNum], LOCATION, SUM([Length_Hours]) AS LocTotalHours
			INTO #tmpTotalHoursMonthly_Loc_OT
			FROM #baseOTVTO
			--WHERE OT_Compliance IN ('Rendered','Not Rendered')
				WHERE Category = 'OT'
			GROUP BY [MonthNum], LOCATION

			SELECT
				[Date], DEPUTY_MANAGER,SUM([Length_Hours]) AS DMTotalHours
			INTO #tmpTotalHoursDaily_DM_OT
			FROM #baseOTVTO
			--WHERE OT_Compliance IN ('Rendered','Not Rendered')
				WHERE Category = 'OT'
			GROUP BY [Date],DEPUTY_MANAGER

			SELECT
				[WeekEnding], DEPUTY_MANAGER, SUM([Length_Hours]) AS DMTotalHours
			INTO #tmpTotalHoursWeekly_DM_OT
			FROM #baseOTVTO
			--WHERE OT_Compliance IN ('Rendered','Not Rendered')
				WHERE Category = 'OT'
			GROUP BY [WeekEnding], DEPUTY_MANAGER

			SELECT
				[MonthNum], DEPUTY_MANAGER, SUM([Length_Hours]) AS DMTotalHours
			INTO #tmpTotalHoursMonthly_DM_OT
			FROM #baseOTVTO
			--WHERE OT_Compliance IN ('Rendered','Not Rendered')
				WHERE Category = 'OT'
			GROUP BY [MonthNum], DEPUTY_MANAGER

			SELECT
				[Date], SUPERVISOR,SUM([Length_Hours]) AS SupTotalHours
			INTO #tmpTotalHoursDaily_Sup_OT
			FROM #baseOTVTO
			--WHERE OT_Compliance IN ('Rendered','Not Rendered')
			WHERE Category = 'OT'
			GROUP BY [Date],SUPERVISOR

			SELECT
				[WeekEnding], SUPERVISOR, SUM([Length_Hours]) AS SupTotalHours
			INTO #tmpTotalHoursWeekly_Sup_OT
			FROM #baseOTVTO
			--WHERE OT_Compliance IN ('Rendered','Not Rendered')
			WHERE Category = 'OT'
			GROUP BY [WeekEnding], SUPERVISOR

			SELECT
				[MonthNum], SUPERVISOR, SUM([Length_Hours]) AS SupTotalHours
			INTO #tmpTotalHoursMonthly_Sup_OT
			FROM #baseOTVTO
			--WHERE OT_Compliance IN ('Rendered','Not Rendered')
			WHERE Category = 'OT'
			GROUP BY [MonthNum], SUPERVISOR

			SELECT
				[Date], Agent_Id,SUM([Length_Hours]) AS AgentTotalHours
			INTO #tmpTotalHoursDaily_Agent_OT
			FROM #baseOTVTO
			--WHERE OT_Compliance IN ('Rendered','Not Rendered')
				WHERE Category = 'OT'
			GROUP BY [Date],Agent_Id

			SELECT
				[WeekEnding], Agent_Id, SUM([Length_Hours]) AS AgentTotalHours
			INTO #tmpTotalHoursWeekly_Agent_OT
			FROM #baseOTVTO
			--WHERE OT_Compliance IN ('Rendered','Not Rendered')
				WHERE Category = 'OT'
			GROUP BY [WeekEnding], Agent_Id

			SELECT
				[MonthNum], Agent_Id, SUM([Length_Hours]) AS AgentTotalHours
			INTO #tmpTotalHoursMonthly_Agent_OT
			FROM #baseOTVTO
			--WHERE OT_Compliance IN ('Rendered','Not Rendered')
				WHERE Category = 'OT'
			GROUP BY [MonthNum], Agent_Id

			--select * from #tmpTotalHoursMonthly_Agent_OT


			SELECT 
				Date, Align, Type, Agent_Id, Schedule_Activity, Activity_StartTime
				, Activity_EndTime, OT_Status, OT_Compliance, Category, SCHEDULE
				, Length_mins, [Length_Hours], RenderedTimeLengthinMins, RenderedTimeLengthinHours, [PRE/POST/RDOT]
				, Main_LOB, [SUB LOB], TotalHours
				, [MS_ID], [FULL_NAME], SUPERVISOR, DEPUTY_MANAGER, [LOCATION]
				, DMTotalHours, SupTotalHours, AgentTotalHours,LocTotalHours
			FROM (
				SELECT tmpoverall.MonthNum AS 'Date', '1' AS Align, 'Monthly' AS Type, tmpoverall.Agent_Id
					, Start_Time
					, End_Time
					, Schedule_Activity
					, Activity_StartTime
					, Activity_EndTime
					, OT_Status
					, OT_Compliance
					, Category
					, SCHEDULE
					, EMP_ID
					, Length_mins
					, [Length_Hours]
					, CASE WHEN OT_Compliance = 'Rendered' THEN Length_mins ELSE 0 END AS RenderedTimeLengthinMins
					, CASE WHEN OT_Compliance = 'Rendered' THEN [Length_Hours] ELSE 0 END AS RenderedTimeLengthinHours
					,[PRE/POST/RDOT]
					, Main_LOB
					, [SUB LOB]
					, TotalHours
					, DMTotalHours, SupTotalHours, AgentTotalHours, LocTotalHours
					, [MS_ID], [FULL_NAME], tmpoverall.SUPERVISOR, tmpoverall.DEPUTY_MANAGER, tmpoverall.[LOCATION]
				FROM #baseOTVTO tmpoverall
				INNER JOIN #tmpTotalHoursMonthly_OT tmpTotalHoursMonthly
					ON tmpoverall.MonthNum = tmpTotalHoursMonthly.MonthNum
				INNER JOIN #tmpTotalHoursMonthly_Loc_OT tmpTotalHoursMonthlyLoc
					ON tmpoverall.MonthNum = tmpTotalHoursMonthlyLoc.MonthNum
					AND tmpoverall.LOCATION = tmpTotalHoursMonthlyLoc.LOCATION
				INNER JOIN #tmpTotalHoursMonthly_DM_OT tmpTotalHoursMonthlyDM
					ON tmpoverall.MonthNum = tmpTotalHoursMonthlyDM.MonthNum
					AND tmpoverall.DEPUTY_MANAGER = tmpTotalHoursMonthlyDM.DEPUTY_MANAGER
				INNER JOIN #tmpTotalHoursMonthly_Sup_OT tmpTotalHoursMonthlySup
					ON tmpoverall.MonthNum = tmpTotalHoursMonthlySup.MonthNum
					AND tmpoverall.SUPERVISOR = tmpTotalHoursMonthlySup.SUPERVISOR
				INNER JOIN #tmpTotalHoursMonthly_Agent_OT tmpTotalHoursMonthlyAgent
					ON tmpoverall.MonthNum = tmpTotalHoursMonthlyAgent.MonthNum
					AND tmpoverall.Agent_Id = tmpTotalHoursMonthlyAgent.Agent_Id
				UNION ALL
				SELECT tmpoverall.WeekEnding AS 'Date', '2' AS Align, 'Weekly' AS Type, tmpoverall.Agent_Id
					, Start_Time
					, End_Time
					, Schedule_Activity
					, Activity_StartTime
					, Activity_EndTime
					, OT_Status
					, OT_Compliance
					, Category
					, SCHEDULE
					, EMP_ID
					, Length_Mins
					, [Length_Hours]
					, CASE WHEN OT_Compliance = 'Rendered' THEN Length_Mins ELSE 0 END AS RenderedTimeLengthinMins
					, CASE WHEN OT_Compliance = 'Rendered' THEN [Length_Hours] ELSE 0 END AS RenderedTimeLengthinHours
					, [PRE/POST/RDOT]
					, Main_LOB
					, [SUB LOB]
					, TotalHours
					, DMTotalHours, SupTotalHours, AgentTotalHours, LocTotalHours
					, [MS_ID], [FULL_NAME], tmpoverall.SUPERVISOR, tmpoverall.DEPUTY_MANAGER, tmpoverall.[LOCATION]
				FROM #baseOTVTO tmpoverall
				INNER JOIN #tmpTotalHoursWeekly_OT tmpTotalHoursWeekly
					ON tmpoverall.WeekEnding = tmpTotalHoursWeekly.WeekEnding
				INNER JOIN #tmpTotalHoursWeekly_Loc_OT tmpTotalHoursWeeklyLoc
					ON tmpoverall.WeekEnding = tmpTotalHoursWeeklyLoc.WeekEnding
					AND tmpoverall.LOCATION = tmpTotalHoursWeeklyLoc.LOCATION
				INNER JOIN #tmpTotalHoursWeekly_DM_OT tmpTotalHoursWeeklyDM
					ON tmpoverall.WeekEnding = tmpTotalHoursWeeklyDM.WeekEnding
					AND tmpoverall.DEPUTY_MANAGER = tmpTotalHoursWeeklyDM.DEPUTY_MANAGER
				INNER JOIN #tmpTotalHoursWeekly_Sup_OT tmpTotalHoursWeeklySup
					ON tmpoverall.WeekEnding = tmpTotalHoursWeeklySup.WeekEnding
					AND tmpoverall.SUPERVISOR = tmpTotalHoursWeeklySup.SUPERVISOR
				INNER JOIN #tmpTotalHoursWeekly_Agent_OT tmpTotalHoursWeeklyAgent
					ON tmpoverall.WeekEnding = tmpTotalHoursWeeklyAgent.WeekEnding
					AND tmpoverall.Agent_Id = tmpTotalHoursWeeklyAgent.Agent_Id
				UNION ALL
				SELECT CONVERT(VARCHAR(10),tmpoverall.[Date]) AS 'Date', '3' AS Align, 'Daily' AS Type, tmpoverall.Agent_Id
					,Start_Time
					, End_Time
					, Schedule_Activity
					, Activity_StartTime
					, Activity_EndTime
					, OT_Status
					, OT_Compliance
					, Category
					, SCHEDULE
					, EMP_ID
					, Length_mins
					, [Length_Hours]
					, CASE WHEN OT_Compliance = 'Rendered' THEN Length_mins ELSE 0 END AS RenderedTimeLengthinMins
					, CASE WHEN OT_Compliance = 'Rendered' THEN [Length_Hours] ELSE 0 END AS RenderedTimeLengthinHours
					, [PRE/POST/RDOT]
					, Main_LOB
					, [SUB LOB]
					, TotalHours
					, DMTotalHours, SupTotalHours, AgentTotalHours, LocTotalHours
					, [MS_ID], [FULL_NAME], tmpoverall.SUPERVISOR, tmpoverall.DEPUTY_MANAGER, tmpoverall.[LOCATION]
				FROM #baseOTVTO tmpoverall
				INNER JOIN #tmpTotalHoursDaily_OT tmpTotalHoursDaily
					ON tmpoverall.[Date] = tmpTotalHoursDaily.[Date]
				INNER JOIN #tmpTotalHoursDaily_Loc_OT tmpTotalHoursDailyLoc
					ON tmpoverall.[Date] = tmpTotalHoursDailyLoc.[Date]
					AND tmpoverall.LOCATION = tmpTotalHoursDailyLoc.LOCATION
				INNER JOIN #tmpTotalHoursDaily_DM_OT tmpTotalHoursDailyDM
					ON tmpoverall.[Date] = tmpTotalHoursDailyDM.[Date]
					AND tmpoverall.DEPUTY_MANAGER = tmpTotalHoursDailyDM.DEPUTY_MANAGER
				INNER JOIN #tmpTotalHoursDaily_Sup_OT tmpTotalHoursDailySup
					ON tmpoverall.[Date] = tmpTotalHoursDailySup.[Date]
					AND tmpoverall.SUPERVISOR = tmpTotalHoursDailySup.SUPERVISOR
				INNER JOIN #tmpTotalHoursDaily_Agent_OT tmpTotalHoursDailyAgent
					ON tmpoverall.[Date] = tmpTotalHoursDailyAgent.[Date]
					AND tmpoverall.Agent_Id = tmpTotalHoursDailyAgent.Agent_Id
			) OverallOT
			WHERE Category = 'OT'

		END

		IF OBJECT_ID('tempdb..#tmpTotalHoursDaily_VTO') IS NOT NULL DROP TABLE #tmpTotalHoursDaily_VTO
	IF OBJECT_ID('tempdb..#tmpTotalHoursWeekly_VTO') IS NOT NULL DROP TABLE #tmpTotalHoursWeekly_VTO
	IF OBJECT_ID('tempdb..#tmpTotalHoursMonthly_VTO') IS NOT NULL DROP TABLE #tmpTotalHoursMonthly_VTO

	IF @ReportView = 'VTO_Overall'
		BEGIN
			SELECT
				[Date], SUM([Length_Hours]) AS TotalHours
			INTO #tmpTotalHoursDaily_VTO
			FROM #baseOTVTO
			WHERE Sub_Category = ('VTO')
			GROUP BY [Date]

			SELECT
				[WeekEnding], SUM([Length_Hours]) AS TotalHours
			INTO #tmpTotalHoursWeekly_VTO
			FROM #baseOTVTO
			WHERE Sub_Category = ('VTO')
			GROUP BY [WeekEnding]

			SELECT
				[MonthNum], SUM([Length_Hours]) AS TotalHours
			INTO #tmpTotalHoursMonthly_VTO
			FROM #baseOTVTO
			WHERE Sub_Category = ('VTO')
			GROUP BY [MonthNum]


			SELECT 
				Date, Align, Type, Agent_Id, Schedule_Activity, Activity_StartTime
				, Activity_EndTime, OT_Status, OT_Compliance, Sub_Category, SCHEDULE
				, Length_Mins, [Length_Hours], RenderedTimeLengthinMins, RenderedTimeLengthinHours, [PRE/POST/RDOT]
				, Main_LOB, [SUB LOB], TotalHours
				, [MS_ID], [FULL_NAME], SUPERVISOR, DEPUTY_MANAGER, [LOCATION]
			FROM (
					SELECT tmpoverall.MonthNum AS 'Date', '1' AS Align, 'Monthly' AS Type, Agent_Id
					, Start_Time
					, End_Time
					, Schedule_Activity
					, Activity_StartTime
					, Activity_EndTime
					, OT_Status
					, OT_Compliance
					, Sub_Category
					, SCHEDULE
					, EMP_ID
					, Length_Mins
					, [Length_Hours]
					, 0 AS RenderedTimeLengthinMins
					, 0 AS RenderedTimeLengthinHours
					, [PRE/POST/RDOT]
					, Main_LOB
					, [SUB LOB]
					, TotalHours
					, [MS_ID], [FULL_NAME], SUPERVISOR, DEPUTY_MANAGER, [LOCATION]
				FROM #baseOTVTO tmpoverall
				INNER JOIN #tmpTotalHoursMonthly_VTO tmpTotalHoursMonthly
					ON tmpoverall.MonthNum = tmpTotalHoursMonthly.MonthNum
				UNION ALL
				SELECT tmpoverall.WeekEnding AS 'Date', '2' AS Align, 'Weekly' AS Type, Agent_Id
					, Start_Time
					, End_Time
					, Schedule_Activity
					, Activity_StartTime
					, Activity_EndTime
					, OT_Status
					, OT_Compliance
					, Sub_Category
					, SCHEDULE
					, EMP_ID
					, Length_Mins
					, [Length_Hours]
					, 0 AS RenderedTimeLengthinMins
					, 0 AS RenderedTimeLengthinHours
					, [PRE/POST/RDOT]
					, Main_LOB
					, [SUB LOB]
					, TotalHours
					, [MS_ID], [FULL_NAME], SUPERVISOR, DEPUTY_MANAGER, [LOCATION]
				FROM #baseOTVTO tmpoverall
				INNER JOIN #tmpTotalHoursWeekly_VTO tmpTotalHoursWeekly
					ON tmpoverall.WeekEnding = tmpTotalHoursWeekly.WeekEnding
				UNION ALL
				SELECT CONVERT(VARCHAR(10),tmpoverall.[Date]) AS 'Date', '3' AS Align, 'Daily' AS Type, Agent_Id
					, Start_Time
					, End_Time
					, Schedule_Activity
					, Activity_StartTime
					, Activity_EndTime
					, OT_Status
					, OT_Compliance
					, Sub_Category
					, SCHEDULE
					, EMP_ID
					, Length_Mins
					, [Length_Hours]
					, 0 AS RenderedTimeLengthinMins
					, 0 AS RenderedTimeLengthinHours
					, [PRE/POST/RDOT]
					, Main_LOB
					, [Sub LOB]
					, TotalHours
					, [MS_ID], [FULL_NAME], SUPERVISOR, DEPUTY_MANAGER, [LOCATION]
				FROM #baseOTVTO tmpoverall
				INNER JOIN #tmpTotalHoursDaily_VTO tmpTotalHoursDaily
					ON tmpoverall.[Date] = tmpTotalHoursDaily.[Date]
			) OverallVTO
			WHERE Sub_Category = ('VTO')

		END

		IF @ReportView = 'RawData'
		BEGIN
			SELECT 
				[Date]
				,Agent_Id
				,Schedule_Activity
				,Activity_StartTime
				,Activity_EndTime
				,OT_Status
				,OT_Compliance
				,Length_mins
				,[Length_Hours]
				,[PRE/POST/RDOT]
				,Main_LOB
				,[SUB LOB]
				,[MS_ID]
				,[FULL_NAME]
				,SUPERVISOR
				,DEPUTY_MANAGER
				,[LOCATION]
			FROM #baseOTVTO tmpoverall
			GROUP BY  Date, Agent_Id, Schedule_Activity, Activity_StartTime, Activity_EndTime, OT_Status, OT_Compliance, Length_mins,[Length_Hours],[PRE/POST/RDOT],Main_LOB, [SUB LOB],[MS_ID],[FULL_NAME],SUPERVISOR,DEPUTY_MANAGER,[LOCATION]
			ORDER BY [Date],FULL_NAME,Activity_StartTime
		END	

		
	IF OBJECT_ID('tempdb..#tmpTotalHoursDaily') IS NOT NULL DROP TABLE #tmpTotalHoursDaily
	IF OBJECT_ID('tempdb..#tmpTotalHoursWeekly') IS NOT NULL DROP TABLE #tmpTotalHoursWeekly
	IF OBJECT_ID('tempdb..#tmpTotalHoursMonthly') IS NOT NULL DROP TABLE #tmpTotalHoursMonthly

	IF OBJECT_ID('tempdb..#tmpTotalHoursDaily_OT') IS NOT NULL DROP TABLE #tmpTotalHoursDaily_OT

	IF OBJECT_ID('tempdb..#tmpTotalHoursDaily_OT') IS NOT NULL DROP TABLE #tmpTotalHoursDaily_OT
	IF OBJECT_ID('tempdb..#tmpTotalHoursWeekly_OT') IS NOT NULL DROP TABLE #tmpTotalHoursWeekly_OT
	IF OBJECT_ID('tempdb..#tmpTotalHoursMonthly_OT') IS NOT NULL DROP TABLE #tmpTotalHoursMonthly_OT

	IF OBJECT_ID('tempdb..#tmpTotalHoursDaily_Loc_OT') IS NOT NULL DROP TABLE #tmpTotalHoursDaily_Loc_OT
	IF OBJECT_ID('tempdb..#tmpTotalHoursWeekly_Loc_OT') IS NOT NULL DROP TABLE #tmpTotalHoursWeekly_Loc_OT
	IF OBJECT_ID('tempdb..#tmpTotalHoursMonthly_Loc_OT') IS NOT NULL DROP TABLE #tmpTotalHoursMonthly_Loc_OT

	IF OBJECT_ID('tempdb..#tmpTotalHoursDaily_DM_OT') IS NOT NULL DROP TABLE #tmpTotalHoursDaily_DM_OT
	IF OBJECT_ID('tempdb..#tmpTotalHoursWeekly_DM_OT') IS NOT NULL DROP TABLE #tmpTotalHoursWeekly_DM_OT
	IF OBJECT_ID('tempdb..#tmpTotalHoursMonthly_DM_OT') IS NOT NULL DROP TABLE #tmpTotalHoursMonthly_DM_OT

	IF OBJECT_ID('tempdb..#tmpTotalHoursDaily_Sup_OT') IS NOT NULL DROP TABLE #tmpTotalHoursDaily_Sup_OT
	IF OBJECT_ID('tempdb..#tmpTotalHoursWeekly_Sup_OT') IS NOT NULL DROP TABLE #tmpTotalHoursWeekly_Sup_OT
	IF OBJECT_ID('tempdb..#tmpTotalHoursMonthly_Sup_OT') IS NOT NULL DROP TABLE #tmpTotalHoursMonthly_Sup_OT

	IF OBJECT_ID('tempdb..#tmpTotalHoursDaily_Agent_OT') IS NOT NULL DROP TABLE #tmpTotalHoursDaily_Agent_OT
	IF OBJECT_ID('tempdb..#tmpTotalHoursWeekly_Agent_OT') IS NOT NULL DROP TABLE #tmpTotalHoursWeekly_Agent_OT
	IF OBJECT_ID('tempdb..#tmpTotalHoursMonthly_Agent_OT') IS NOT NULL DROP TABLE #tmpTotalHoursMonthly_Agent_OT

	IF OBJECT_ID('tempdb..#tmpTotalHoursDaily_VTO') IS NOT NULL DROP TABLE #tmpTotalHoursDaily_VTO
	IF OBJECT_ID('tempdb..#tmpTotalHoursWeekly_VTO') IS NOT NULL DROP TABLE #tmpTotalHoursWeekly_VTO
	IF OBJECT_ID('tempdb..#tmpTotalHoursMonthly_VTO') IS NOT NULL DROP TABLE #tmpTotalHoursMonthly_VTO

	IF OBJECT_ID('tempdb..#tmpOverall') IS NOT NULL DROP TABLE #tmpOverall

END


