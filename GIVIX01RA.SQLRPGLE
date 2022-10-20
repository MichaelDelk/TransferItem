000100211212**FREE
000200000000//    *------------------------------------------------------------------------
000300000000//    * CM|IT #     Programmer  Change Flag     Description
000400000000//    * ----------- ----------- --------------- -------------------------------
000500220622//    * @IT-023009@ Michael D   MD01            Modify to allow ADJ for locations
000501220627//    *                                         with zero quantities. Also add
000600220627//    *                                         support for new transaction code
000601220627//    *                                         PROD, to function exactly as existing
000602220627//    *                                         ADJ transaction code.
000603220724//    * @CM-000387@ Michael D   MD02            Increase size of response text from 80 to
000604220724//    *                                         256 and default blank numeric parms to zeros
000605220724//    *                                         in order to reduce confusion in user under-
000606220724//    *                                         standing of response message information.
000607220724//    *------------------------------------------------------------------------
000700000000//    * NOTES:
000800000000//    *
000900000000//    *-----------------------------------------------------------------
001000000000// ======================================================================================
001100000000//
001200000000//  PROGRAM NAME: IV Item - Transfer
001300000000//  PROGRAM ID  : GIVIX01RA
001400000000//
001500000000//  WRITTEN BY  : Michael Delk
001600000000//  DATE        : 2021-10-15
001700000000//
001800000000//  PROGRAM DESC: Process requested item transfer transactions.
001900000000//
002000211224//                Original intent is to receive Transfer Out (TROUT), Transfer In
002001211224//                (TRIN), Adjustment (ADJ), and Issue (ISSU) transactions scanned
002002211224//                from web interfaces on tablets out in the plants.
002003211224//
002400000000//                This program is responsible for validating all input before
002500000000//                processing it. Do not assume any parameter values are valid.
002600220208//
002601220208//                Note: Library list set by php's call to GConB.php
002602220208//                which reads request parm $_GET['DB'] sent by the
002603220208//                HTML form's hidden input field 'DB'.
002604220208//
002700211224//  COMPILE INST: CRTSQLRPGI OBJ(GMIVOBJ/GIVIX01RA) SRCFILE(GMIVOBJ/QRPGLESRC)
002701211224//                  SRCMBR(GIVIX01RA) OBJTYPE(*MODULE) REPLACE(*YES) DBGVIEW(*SOURCE)
002702211224//
002703211224//                CRTPGM PGM(GMIVOBJ/GIVIX01RA)
002704211224//                  BNDDIR(HIVITE) ACTGRP(*NEW) DETAIL(*FULL)
002705211224//
002706211224//
003100000000//                Name               Defn In/Out Description
003200000000//                ----------------- ----- ------ ---------------------------------------
003300000000//  PARMS       : ##XtnDb            2A   In     Xtn database (GI, IV, TS, etc.)
003400000000//                ##XtnType          4A   In     Xtn type (TROUT, TRIN, ADJ, etc)
003500000000//                ##ItemNumber      15A   In     Item number
003600000000//                ##ItemQuantity    20A   In     Item quantity Packed(13:4)
003700211128//                ##ItemWhsFrom      3A   In     Item warehouse - From Zoned(3:0)
003800220114//                ##StockroomFrom    3A   In     Stockroom - From
003801220114//                ##AisleFrom        4A   In     Aisle - From
003802220114//                ##StockLocFrom     8A   In     Stock location - From
003900211128//                ##ItemWhsTo        3A   In     Item warehouse - To Zoned(3:0)
003901220114//                ##StockroomTo      3A   In     Stockroom - To
003902220114//                ##AisleTo          4A   In     Aisle - To
003903220114//                ##StockLocTo       8A   In     Stock location - To
003904211212//                ##AdjReason       25A   In     Adjustment reason
004000000000//                ##Success          1A      Out Success (Y/N)
004100220724// DMD02          ##RspText         80A      Out Response text
004200220724// AMD02          ##RspText        256A      Out Response text
004201220724//
004300000000// =====================================================================================
004400000000
004500000000ctl-opt
004600211224  Option(*SrcStmt:*NoDebugIO:*NoUnref)
004800211213  DatFmt(*ISO) TimFmt(*ISO) DecEdit('0.')
004900211213  AlwNull(*InputOnly)
005000211213  Copyright('GIVIX01RA.SQLRPGLE | V1.0.0 2021-10-15 | IV Item - Transfer') ;
005100000000
005200000000// ==============================================================
005300000000// TABLE DESCRIPTION SECTION
005400000000// ==============================================================
005500000000//
005600000000//    NAME                 DESCRIPTION
005700000000// ----------   -------------------------------------------
005800000000// HDIMST       Item Master (Item)
005900211215// HDITSL       Item Stock Locaiton Master (SId#/Item/Whs/Lot)
005901211215// HDIWHS       Item/Warehouse Master (Item/Whs)
006000220210// HDSTLC       CTL - Stock Location Master (Whs/Stkr/Aile/SLoc)
006001220210// HDTTYP       Transaction Type Master (Type)
006002211213// HDWHSM       Warehouse Master (Whs)
006100211215//
006200000000// ==============================================================
006300000000
006400000000// ==============================================================
006500000000// PROTOTYPE - MAIN
006600000000// ==============================================================
006700000000
006800000000dcl-pr GIVIX01RA ExtPgm('GIVIX01RA') ;
006900000000  ##XtnDb Char(2) ;
007000000000  ##XtnType Char(4) ;
007100000000  ##ItemNumber Char(15) ;
007200000000  ##ItemQuantity Char(20) ;
007300211128  ##ItemWhsFrom Char(3) ;
007400220114  ##StockroomFrom Char(3) ;
007500220114  ##AisleFrom Char(4) ;
007501220114  ##StockLocFrom Char(8) ;
007502220114  ##ItemWhsTo Char(3) ;
007503220114  ##StockroomTo Char(3) ;
007504220114  ##AisleTo Char(4) ;
007505220114  ##StockLocTo Char(8) ;
007506211212  ##AdjReason Char(25) ;
007600000000  ##Success Char(1) ;
007601220724// MD02: Begin
007700220724//   ##RspText Char(80) ;
007800220724  ##RspText Char(256) ;
007801220724// MD02: End
007802220724end-pr ;
007900000000
008000000000// ==============================================================
008100000000// PROTOTYPE - OTHER
008200000000// ==============================================================
008300000000
008400000000dcl-pr Init ;
008500000000end-pr ;
008600000000dcl-pr ValidateRequest ;
008700000000end-pr ;
008800000000dcl-pr ProcessRequest ;
008900000000end-pr ;
009000211224dcl-pr RtvQtyAvail ;
009001211224end-pr ;
009002211224dcl-pr CallHHDDTU ;
009003211212end-pr ;
009004211212dcl-pr RtvSysStamp LikeDS(sysStampDS_t) ;
009100000000end-pr ;
009200211212dcl-pr CvtDateToCyymmdd Zoned(7:0) ;
009201211212  *n Date ;
009202211212end-pr ;
009203211212dcl-pr ShtDwn ;
009300000000end-pr ;
009301211215
009302211215// ==============================================================
009600000000// PROCEDURE INTERFACE
009700000000// ==============================================================
009800000000
009900000000dcl-pi GIVIX01RA ;
010000000000  ##XtnDb Char(2) ;
010100000000  ##XtnType Char(4) ;
010200000000  ##ItemNumber Char(15) ;
010300000000  ##ItemQuantity Char(20) ;
010400211128  ##ItemWhsFrom Char(3) ;
010500220114  ##StockroomFrom Char(3) ;
010501220114  ##AisleFrom Char(4) ;
010502220114  ##StockLocFrom Char(8) ;
010600211128  ##ItemWhsTo Char(3) ;
010601220114  ##StockroomTo Char(3) ;
010602220114  ##AisleTo Char(4) ;
010603220114  ##StockLocTo Char(8) ;
010604211212  ##AdjReason Char(25) ;
010700000000  ##Success Char(1) ;
010701220724// MD02: Begin
010800220724//  ##RspText Char(80) ;
010801220724  ##RspText Char(256) ;
010802220724// MD02: End
010900000000end-pi ;
011000000000
011100000000// ==============================================================
011200000000// FILE DECLARATIONS (Global)
011300000000// ==============================================================
011400000000
011500000000// ==============================================================
011600000000// STANDALONE VARIABLES (Global)
011700000000// ==============================================================
011800000000
011900000000//
012000000000// Define program status data structure.
012100000000//
012200000000dcl-ds psdsDS PSDS Qualified ;
012300000000  Proc Char(10) ;             // Module or main procedure name
012400000000  StsCde Zoned(5) ;           // Status code
012500000000  PrvStsCde Zoned(5) ;        // Previous status
012600000000  SrcLineNbr Char(8) ;        // Source line number
012700000000  Routine Char(8) ;           // Name of the RPG routine
012800000000  Parms Zoned(3) ;            // Number of parms passed to program
012900000000  ExceptionType Char(3) ;     // Exception type
013000000000  ExceptionNbr Char(4) ;      // Exception number
013100000000  Exception Char(7) SamePos(ExceptionType) ;
013200000000  Reserved1 Char(4) ;         // Reserved
013300000000  MsgWrkArea Char(30) ;       // Message work area
013400000000  PgmLib Char(10) ;           // Program library
013500000000  ExceptionData Char(80) ;    // Retrieved exception data
013600000000  Rnx9001Exception Char(4) ;  // Id of exception that caused RNX9001
013700000000  LastFile1 Char(10) ;        // Last file operation occurred on
013800000000  Unused1 Char(6) ;           // Unused
013900000000  DteEntered Char(8) ;        // Date entered system
014000000000  StrDteCentury Zoned(2) ;    // Century of job started date
014100000000  LastFile2 Char(8) ;         // Last file operation occurred on
014200000000  LastFileSts Char(35) ;      // Last file used status information
014300000000  JobName Char(10) ;          // Job name
014400000000  JobUser Char(10) ;          // Job user
014500000000  JobNbr Zoned(6) ;           // Job number
014600000000  StrDte Zoned(6) ;           // Job started date
014700000000  PgmDte Zoned(6) ;           // Date of program running
014800000000  PgmTime Zoned(6) ;          // Time of program running
014900000000  CompileDte Char(6) ;        // Date program was compiled
015000000000  CompileTime Char(6) ;       // Time program was compiled
015100000000  CompilerLevel Char(4) ;     // Level of compiler
015200000000  SrcFile Char(10) ;          // Source file name
015300000000  SrcLib Char(10) ;           // Source file library
015400000000  SrcMbr Char(10) ;           // Source member name
015500000000  ProcPgm Char(10) ;          // Program containing procedure
015600000000  ProcMod Char(10) ;          // Module containing procedure
015700000000  SrcLineNbrBin BinDec(2) ;   // Source line number as binary
015800000000  LastFileStsBin BinDec(2) ;  // Source id matching positions 228-235
015900000000  User Char(10) ;             // Current user
016000000000  ExtErrCode Int(10) ;        // External error code
016100000000  IntoElements Int(20) ;      // Elements set by XML-INTO or DATA-INTO (7.3)
016200000000  InternalJobId Char(16) ;    // Internal job id (7.3 TR6)
016300000000  SysName Char(8) ;           // System name (7.3 TR6)
016400000000end-ds ;
016500000000
016600000000//
016700000000// Define data structures for program work fields based on
016800000000// DB2 versions of external files. (Global)
016900000000//
017000000000dcl-ds hdimstDS_t
017100000000  ExtName('HDIMST') Qualified Template
017200000000end-ds ;
017300000000dcl-ds hdimstDS LikeDS(hdimstDS_t) Inz ;
017400000000
017500211215dcl-ds hditslDS_t
017501211215  ExtName('HDITSL') Qualified Template
017502211215end-ds ;
017503211215dcl-ds hditslDS_From LikeDS(hditslDS_t) Inz ;
017504211215dcl-ds hditslDS_To LikeDS(hditslDS_t) Inz ;
017505211215
017506211215dcl-ds hdiwhsDS_t
017600000000  ExtName('HDIWHS') Qualified Template
017700000000end-ds ;
017800211213dcl-ds hdiwhsDS_From LikeDS(hdiwhsDS_t) Inz ;
017900211213dcl-ds hdiwhsDS_To LikeDS(hdiwhsDS_t) Inz ;
017901211213
018000220210dcl-ds hdstlcDS_t
018001220210  ExtName('HDSTLC') Qualified Template
018002220210end-ds ;
018003220210dcl-ds hdstlcDS LikeDS(hdstlcDS_t) Inz ;
018004220210
018005220210dcl-ds hdttypDS_t
018006211213  ExtName('HDTTYP') Qualified Template
018007211213end-ds ;
018008211213dcl-ds hdttypDS LikeDS(hdttypDS_t) Inz ;
018009211213
018010211213dcl-ds hdwhsmDS_t
018100000000  ExtName('HDWHSM') Qualified Template
018200000000end-ds ;
018300211213dcl-ds hdwhsmDS_From LikeDS(hdwhsmDS_t) Inz ;
018400211213dcl-ds hdwhsmDS_To LikeDS(hdwhsmDS_t) Inz ;
018401211213
018500211213//
018501211215// Define data structure for transaction update program parms.
018502211213//
018503211215dcl-ds hhddtuDS
018504211213  ExtName('HHDDTUPL') Qualified Inz
018505211213end-ds ;
018506211213
018507211213//
018600000000// Define data structure for system timestamp.
018700000000//
018800000000dcl-ds sysStampDS_t Qualified Template ;
018900000000  stamp Timestamp ;
019000000000  date Date(*ISO) ;
019100000000  time Time ;
019200000000end-ds ;
019300000000dcl-ds sysStampDS LikeDS(sysStampDS_t) ;
019400000000
019500000000//
019600000000// Define work fields for requested parameters (global).
019700000000//
019800220114dcl-s $XtnDb         Like(##XtnDb)         Inz(*Blanks) ;
019900220114dcl-s $XtnType       Like(##XtnType)       Inz(*Blanks) ;
020000220114dcl-s $ItemNumber    Like(##ItemNumber)    Inz(*Blanks) ;
020100220114dcl-s $ItemQuantity  Packed(13:4)          Inz(*Zeros) ;
020200220114dcl-s $ItemWhsFrom   Zoned(3:0)            Inz(*Zeros) ;
020300220114dcl-s $StockroomFrom Like(##StockroomFrom) Inz(*Blanks) ;
020400220114dcl-s $AisleFrom     Like(##AisleFrom)     Inz(*Blanks) ;
020401220114dcl-s $StockLocFrom  Like(##StockLocFrom)  Inz(*Blanks) ;
020402220114dcl-s $ItemWhsTo     Zoned(3:0)            Inz(*Zeros) ;
020403220114dcl-s $StockroomTo   Like(##StockroomTo)  Inz(*Blanks) ;
020404220114dcl-s $AisleTo       Like(##AisleTo)      Inz(*Blanks) ;
020405220114dcl-s $StockLocTo    Like(##StockLocTo)    Inz(*Blanks) ;
020406220114dcl-s $AdjReason     Like(##AdjReason)     Inz(*Blanks) ;
020500000000
020600000000//
020700000000// Define misc work fields (global).
020800000000//
020900211224dcl-s $Debug   Ind                   Inz(*Off) ; // Debug mode *ON?
021000211224dcl-s $EndPg   Ind                   Inz(*Off) ;
021100211224dcl-s $ErrFd   Ind                   Inz(*Off) ;
021200211224dcl-s $QtyAvail  Like($ItemQuantity) Inz(*Zeros) ; // from Harris HHDRAV
021201211224dcl-s $QtyOnHand Like($ItemQuantity) Inz(*Zeros) ; // from Harris HHDRAV
021202211224dcl-s $RspText Like(##RspText)       Inz(*Blanks) ;
021300000000
021400211213//
021401211213// Define work fields for call to transaction update program..
021402211213//
021403211215dcl-s $Type Like(hhddtuDS.plType) ;
021404211215dcl-s $Whs  Like(hhddtuDS.plWhs)  ;
021405211215dcl-s $SCC1 Like(hhddtuDS.plSCC1) ;
021406211215dcl-s $SWhs Like(hhddtuDS.plSWhs) ;
021407220114dcl-s $Stkr Like(hhddtuDS.plStkr) ;
021408220114dcl-s $Aile Like(hhddtuDS.plAile) ;
021409220114dcl-s $SLoc Like(hhddtuDS.plSLoc) ;
021410211215dcl-s $OSeq Like(hhddtuDS.plOSeq) ;
021411211213
021412211213//
021500000000// Define program constants.
021600000000//
021700000000dcl-c #DIGITS      Const('0123456789') ; // Numeric digits 0-9
021800000000dcl-c #NO          Const('N') ;
021900000000dcl-c #YES         Const('Y') ;
022000000000
022100000000// ==============================================================
022200000000//
022300000000// SECTION NAME    -  Mainline
022400000000//
022500000000// DESCRIPTION     -  This section loops through maintenance
022600000000//                    function until user chooses to exit.
022700000000//
022800000000// ==============================================================
022900000000
023000000000Init() ;
023100000000If Not $EndPg ;
023200000000  ValidateRequest() ;
023300000000EndIf ;
023400000000If Not $EndPg ;
023500000000  ProcessRequest() ;
023600000000EndIf ;
023700000000ShtDwn() ;
023800000000
023900000000// ==============================================================
024000000000// Procedure name: Init
024100000000// Purpose: Set SQL opts, receive program parms, and set initial
024200000000//          program options/values.
024300000000// Returns:
024400000000// ==============================================================
024500000000
024600000000dcl-proc Init ;
024700000000
024800000000  //
024900000000  // Initialize SQL options.
025000000000  //
025100000000  Exec Sql
025200000000    SET OPTION NAMING = *SYS, COMMIT = *NONE, USRPRF = *USER,
025300000000               DYNUSRPRF = *USER, DATFMT = *ISO, CLOSQLCSR = *ENDMOD ;
025400000000
025500000000  //
025600000000  // Load current system timestamp for any logging
025700000000  // requirements.
025800000000  //
025900000000  Clear sysStampDS ;
026000000000  sysStampDS = RtvSysStamp() ;
026100000000
026200000000  //
026300000000  // Initialize return parameters.
026400000000  //
026500000000  ##Success = #NO ;
026600000000  ##RspText = *Blanks ;
026700000000
026800220131  //
028601211213  // Load requested input parameter values to program
028602211213  // work fields, validating data types if needed.
028603211213  //
028604211213  $XtnDb = ##XtnDb ;
028605211213  $XtnType = ##XtnType;
028606211213  $ItemNumber = ##ItemNumber ;
028607220114  $StockroomFrom = ##StockroomFrom ;
028608220114  $AisleFrom = ##AisleFrom ;
028609220114  $StockLocFrom = ##StockLocFrom ;
028610220114  $StockroomTo = ##StockroomTo ;
028611220114  $AisleTo = ##AisleTo ;
028612220114  $StockLocTo = ##StockLocTo ;
028613211213  $AdjReason = ##AdjReason ;
028614211213
028615220724  // MD02: Begin
028616220724  If (##ItemQuantity = *Blanks) ;
028617220724    ##ItemQuantity = '0';
028618220724  EndIf;
028619220724  If (##ItemWhsFrom = *Blanks) ;
028620220724    ##ItemWhsFrom = '0';
028621220724  EndIf;
028622220724  If (##ItemWhsTo = *Blanks) ;
028623220724    ##ItemWhsTo = '0';
028624220724  EndIf;
028625220724  // MD02: End
028626220724
028627211213  If Not $ErrFd ;
028628211213    Monitor ;
028629211213      $ItemQuantity = %Dec(##ItemQuantity:13:4) ;
028630211213    On-Error ;
028631211213      $RspText = 'E001: Could not convert requested Item Quantity '
028632211213                   + %Trim(##ItemQuantity) + ' to 13,4 decimal number.' ;
028633211213      $ErrFd = *On ;
028634211213    EndMon ;
028635211213  EndIf ;
028636211213
028637211213  If Not $ErrFd ;
028638211216    Monitor ;
028639211213      $ItemWhsFrom = %Dec(##ItemWhsFrom:3:0) ;
028640211213    On-Error ;
028641211213      $RspText = 'E002: Could not convert requested Item From Whs '
028642211213                   + %Trim(##ItemWhsFrom) + ' to 3,0 decimal number.' ;
028643211213      $ErrFd = *On ;
028644211213    EndMon ;
028645211213  EndIf ;
028646211213
028647211213  If Not $ErrFd ;
028648211216    If ($XtnType = 'TROU') ;
028649211216      Monitor ;
028650211216        $ItemWhsTo = %Dec(##ItemWhsTo:3:0) ;
028651211216      On-Error ;
028652211216        $RspText = 'E009: Could not convert requested Item To Whs '
028653211216                     + %Trim(##ItemWhsTo) + ' to 3,0 decimal number.' ;
028654211216        $ErrFd = *On ;
028655211216      EndMon ;
028656211216    Else ;
028657211216      $ItemWhsTo = *Zeros ;
028658211216    EndIf;
028659211216  EndIf ;
028660211213
028661211213  //
028662211213  // Set flag to exit program if any errors found.
028663211213  //
028664211213  If $ErrFd ;
028665211213    $EndPg = *On ;
028666211213  EndIf ;
028667211213
028668211213  Return ;
028700000000
028800000000end-proc ;
028900000000
029000000000// ==============================================================
029100000000// Procedure name: ValidateRequest
029200000000// Purpose: Validate request.
029300000000// Returns:
029400000000// ==============================================================
029500000000
029600000000dcl-proc ValidateRequest ;
029700000000
029800000000  //
029900000000  // Initialize work areas.
030000000000  //
030100000000  Clear hdimstDS ;
030200211215  Clear hditslDS_From ;
030201211215  Clear hditslDS_To ;
030202211215  Clear hdiwhsDS_From ;
030300211213  Clear hdiwhsDS_To ;
030301211213  Clear hdwhsmDS_From ;
030400211213  Clear hdwhsmDS_To ;
030401211213
030500211213  //
033600000000  // Requested transaction type must be valid.
033700000000  //
033800000000  If Not $ErrFd ;
033900000000    Select ;
034000000000      When ($XtnType = 'TROU') ;
034100211128      When ($XtnType = 'ISSU') ;
034200000000      When ($XtnType = 'ADJ') ;
034201220627  // Begin: MD01 - Add PROD transaction code.
034300220627      When ($XtnType = 'PROD') ; // AMD01
034301220627  // End: MD01
034302220627      Other ;
034400220627  // Begin: MD01 - Add PROD transaction code.
034401220627  //      $RspText = 'E008: Requested transaction type ' + %Trim($XtnType)
034500220627  //                   + ' must be TROU, ISSU, or ADJ.' ;
034600220627        $RspText = 'E008: Requested transaction type ' + %Trim($XtnType)
034601220627                     + ' must be TROU, ISSU, ADJ, or PROD.' ;
034602220627  // End: MD01
034603220627        $ErrFd = *On ;
034700000000    EndSl ;
034800000000  EndIf ;
034900000000
035000211213  //
035001211213  // Requested transaction type exist in transaction type master.
035002211213  //
035003211213  If Not $ErrFd ;
035004211213    Exec Sql
035006211213      SELECT a.* INTO :hdttypDS FROM hdttyp a WHERE a.tttype = :$XtnType ;
035007211213    Select ;
035008211213      When Not (SQLCODE = *Zeros) ;
035009211213        $RspText = 'E011: Requested Transaction Type '
035010211213                     + %Trim(%Char($XtnType))
035011211213                     + ' not found in transaction type master.' ;
035012211213        $ErrFd = *On ;
035013211213      Other ;
035014211213    EndSl ;
035015211213  EndIf ;
035017211213
035018211213  //
035100000000  // Requested item must exist in item master and must be active.
035200000000  //
035300000000  If Not $ErrFd ;
035400000000    Exec Sql
035500000000      SELECT a.* INTO :hdimstDS FROM hdimst a WHERE a.imitem = :$ItemNumber ;
035600000000    Select ;
035700000000      When Not (SQLCODE = *Zeros) ;
035800000000        $RspText = 'E003: Requested Item Number ' + %Trim($ItemNumber)
035900000000                     + ' not found in item master.' ;
036000000000        $ErrFd = *On ;
036100000000      When Not (hdimstDS.imimac = *Blanks) ;
036200000000        $RspText = 'E004: Requested Item Number ' + %Trim($ItemNumber)
036300000000                     + ' not active in item master.' ;
036400000000        $ErrFd = *On ;
036500000000      Other ;
036600000000    EndSl ;
036700000000  EndIf ;
036800000000
036900000000  //
037000211128  // Requested from warehouse must exist in warehouse master.
037100000000  //
037200000000  If Not $ErrFd ;
037300000000    Exec Sql
037400211213      SELECT a.* INTO :hdwhsmDS_From FROM hdwhsm a WHERE a.whwhs = :$ItemWhsFrom ;
037500000000    Select ;
037600000000      When Not (SQLCODE = *Zeros) ;
037700211128        $RspText = 'E005: Requested Item From Warehouse '
037800211128                     + %Trim(%Char($ItemWhsFrom))
037900000000                     + ' not found in warehouse master.' ;
038000000000        $ErrFd = *On ;
038100000000      Other ;
038200000000    EndSl ;
038300000000  EndIf ;
038400000000
038500211128  //
038501211128  // Requested to warehouse must exist in warehouse master
038502211128  // for TROU/TRIN transactions.
038503211128  //
038504211128  If Not $ErrFd ;
038505211128    If ($XtnType = 'TROU') ;
038506211128      Exec Sql
038507211213        SELECT a.* INTO :hdwhsmDS_To FROM hdwhsm a WHERE a.whwhs = :$ItemWhsTo ;
038508211128      Select ;
038509211128        When Not (SQLCODE = *Zeros) ;
038510211128          $RspText = 'E010: Requested Item To Warehouse '
038511211128                       + %Trim(%Char($ItemWhsTo))
038512211128                       + ' not found in warehouse master.' ;
038513211128          $ErrFd = *On ;
038514211128        Other ;
038515211128      EndSl ;
038516211128    EndIf ;
038517211128  EndIf ;
038518211128
038519211128  //
038600211128  // Requested item/from-warehouse must exist in item/warehouse master
038700000000  // and must be active.
038800000000  //
038900000000  If Not $ErrFd ;
039000000000    Exec Sql
039100211213      SELECT a.* INTO :hdiwhsDS_From
039200000000        FROM hdiwhs a
039300000000        WHERE a.iwitem = :$ItemNumber
039400211128          AND a.iwwhs  = :$ItemWhsFrom ;
039500000000    Select ;
039600000000      When Not (SQLCODE = *Zeros) ;
039700211128        $RspText = 'E006: Reqd Item/From-Whs '
039800211128                     + %Trim($ItemNumber) + '/' + %Trim(%Char($ItemWhsFrom))
039900211128                     + ' not found in item/whs master.' ;
040000000000        $ErrFd = *On ;
040100211213      When Not (hdiwhsDS_From.iwiwac = *Blanks) ;
040200211128        $RspText = 'E007: Reqd Item/From-Whs '
040300211128                     + %Trim($ItemNumber) + '/' + %Trim(%Char($ItemWhsFrom))
040400211128                     + ' not active in item/whs master.' ;
040500000000        $ErrFd = *On ;
040600000000      Other ;
040700000000    EndSl ;
040800000000  EndIf ;
040900000000
041000211128  //
041001211128  // Requested item/to-warehouse must exist in item/warehouse master
041002211128  // and must be active for TROU/TRIN transactions.
041003211128  //
041004211128  If Not $ErrFd ;
041005211128    If ($XtnType = 'TROU') ;
041006211128      Exec Sql
041007211213        SELECT a.* INTO :hdiwhsDS_To
041008211128          FROM hdiwhs a
041009211128          WHERE a.iwitem = :$ItemNumber
041010211128            AND a.iwwhs  = :$ItemWhsTo ;
041011211128      Select ;
041012211128        When Not (SQLCODE = *Zeros) ;
041013211216          $RspText = 'E014: Reqd Item/To-Whs '
041014211128                       + %Trim($ItemNumber) + '/' + %Trim(%Char($ItemWhsTo))
041015211128                       + ' not found in item/whs master.' ;
041016211128          $ErrFd = *On ;
041017211213        When Not (hdiwhsDS_To.iwiwac = *Blanks) ;
041018211216          $RspText = 'E015: Reqd Item/To-Whs '
041019211128                       + %Trim($ItemNumber) + '/' + %Trim(%Char($ItemWhsTo))
041020211128                       + ' not active in item/whs master.' ;
041021211128          $ErrFd = *On ;
041022211128        Other ;
041023211128      EndSl ;
041024211128    EndIf ;
041025211128  EndIf ;
041026211128
041027220622  // Begin: MD01
041028220622  //
041029220622  // Requested from stock location must exist in stock
041030220627  // location master for ADJ and PROD transactions if stock
041031220622  // locator flag is <Y>es for source item-warehouse.
041032220622  //
041033220622  If Not $ErrFd ;
041034220627    If (($XtnType = 'ADJ ') Or ($XtnType = 'PROD'));
041035220622      If (hdiwhsDS_From.iwStkL = #YES) ;
041036220622        Exec Sql
041037220622          SELECT a.* INTO :hdstlcDS
041038220622            FROM hdstlc a
041039220622            WHERE a.slWhs  = :$ItemWhsFrom
041040220622              AND a.slStkR = :$StockroomFrom
041041220622              AND a.slAile = :$AisleFrom
041042220622              AND a.slSLoc = :$StockLocFrom
041043220622              LIMIT 1 ;
041044220622        Select ;
041045220622          When Not (SQLCODE = *Zeros) ;
041046220622            $RspText = 'E019: Reqd From-Whs/From-Loc '
041047220624                        + %Trim(%Char($ItemWhsFrom))
041048220624                        + '/' + %Trim($StockroomFrom)
041049220624                        + '/' + %Trim($AisleFrom)
041050220624                        + '/' + %Trim($StockLocFrom)
041051220622                        + ' not found in stock location master.' ;
041052220622            $ErrFd = *On ;
041053220622          Other ;
041054220622        EndSl ;
041055220622      EndIf ;
041056220622    EndIf ;
041057220622  EndIf ;
041058220622  // End: MD01
041059220622
041060220627  //
041094211215  // Requested from item stock location must exist in item stock
041095220126  // location master and be active.
041096211215  //
041097220622  // MD01: Do not require item stock location record for
041098220627  //       ADJ and PROD transactions.
041099220622  //
041100220622  If Not $ErrFd ;
041101220622  // Begin: MD01
041102220628    If (Not ($XtnType = 'ADJ ') And Not ($XtnType = 'PROD')) ;
041103220622  // End: MD01
041104220622    Exec Sql
041105220118      SELECT a.* INTO :hditslDS_From
041106220118        FROM hditsl a
041107220118        WHERE a.isitem = :$ItemNumber
041108220118          AND a.iswhs  = :$ItemWhsFrom
041109220118          AND a.isStkR = :$StockroomFrom
041110220118          AND a.isAile = :$AisleFrom
041111220118          AND a.isSLoc = :$StockLocFrom
041112220118          AND a.islot  = ''
041113220118          LIMIT 1 ;
041114220118    Select ;
041115220118      When Not (SQLCODE = *Zeros) ;
041116220118        $RspText = 'E012: Reqd Item/From-Whs/From-Loc '
041117220118                     + %Trim($ItemNumber)
041118220118                     + '/' + %Trim(%Char($ItemWhsFrom))
041119220118                     + '/' + %Trim($StockroomFrom)
041120220118                     + '/' + %Trim($AisleFrom)
041121220118                     + '/' + %Trim($StockLocFrom)
041122220622                     + ' not found in item stock location master.' ;
041123220118        $ErrFd = *On ;
041124220126      Other ;
041125220118    EndSl ;
041126220622  // Begin: MD01
041127220622    EndIf ;
041128220622  // End: MD01
041129220622  EndIf ;
041130211215
041131220210  //
041132220622  // Requested to stock location must exist in stock
041133220210  // location master for TROU/TRIN transactions if stock
041134220210  // locator flag is <Y>es for destination item-warehouse.
041135220210  //
041136220210  If Not $ErrFd ;
041137220210    If ($XtnType = 'TROU') ;
041138220210      If (hdiwhsDS_To.iwStkL = #YES) ;
041139220210        Exec Sql
041140220210          SELECT a.* INTO :hdstlcDS
041141220210            FROM hdstlc a
041142220210            WHERE a.slWhs  = :$ItemWhsTo
041143220210              AND a.slStkR = :$StockroomTo
041144220210              AND a.slAile = :$AisleTo
041145220210              AND a.slSLoc = :$StockLocTo
041146220210              LIMIT 1 ;
041147220210        Select ;
041148220210          When Not (SQLCODE = *Zeros) ;
041149220210            $RspText = 'E013: Reqd To-Whs/To-Loc '
041150220210                        + %Trim(%Char($ItemWhsTo))
041151220210                        + '/' + %Trim($StockroomTo)
041152220210                        + '/' + %Trim($AisleTo)
041153220210                        + '/' + %Trim($StockLocTo)
041154220622                        + ' locked or not found in stock location master.' ;
041155220210            $ErrFd = *On ;
041156220210          Other ;
041157220210        EndSl ;
041158220210      EndIf ;
041159220210    EndIf ;
041160220210  EndIf ;
041161220210
041162220624  // Begin: MD01
041163220624  //
041164220624  // Stock locater must be active for item/from-whs
041165220627  // for ADJ, ISSU, PROD, and TROU transactions.
041166220624  //
041167220624  If Not $ErrFd ;
041168220624    If (($XtnType = 'ADJ ')
041169220624      Or ($XtnType = 'ISSU')
041170220627      Or ($XtnType = 'PROD')
041171220627      Or ($XtnType = 'TROU'));
041172220624      If Not (hdiwhsDS_From.iwStkL = #YES) ;
041173220624        $RspText = 'E020: Stock locator not active for Item/From-Whs '
041174220624                    + %Trim($ItemNumber)
041175220624                    + '/' + %Trim(%Char($ItemWhsFrom))
041176220624                    + '.' ;
041177220624        $ErrFd = *On ;
041178220624      EndIf ;
041179220624    EndIf ;
041180220624  EndIf ;
041181220624  // End: MD01
041182220624
041183220624  //
041186211224  // Requested quantity cannot be zero.
041187211224  //
041188211224  If Not $ErrFd ;
041189211224    If ($ItemQuantity = *Zeros) ;
041190211224        $RspText = 'E016: Reqd Qty cannot be zero.' ;
041191211224        $ErrFd = *On ;
041192211224    EndIf ;
041193211224  EndIf ;
041194211224
041195220627  // Begin: MD01
041196220627  //
041197211224  // Requested quantity must be positive unless
041198211224  // user requested ADJ transaction.
041199211224  //
041200220627  // If Not $ErrFd ;
041201220627  //   If ($ItemQuantity < *Zeros) ;
041202220627  //     If Not ($XtnType = 'ADJ ') ;
041203220627  //       $RspText = 'E017: Reqd Qty must be positive for Trans Type '
041204220627  //                    + %Trim(%Char($ItemQuantity)) + '/'
041205220627  //                    + %Trim($XtnType)
041206220627  //                    + '.' ;
041207220627  //       $ErrFd = *On ;
041208220627  //     EndIf ;
041209220627  //   EndIf ;
041210220627  // EndIf ;
041211220627  //
041212220627  // Requested quantity must be positive unless
041213220627  // user requested ADJ or PROD transaction.
041214220627  //
041215220627  If Not $ErrFd ;
041216220627    If ($ItemQuantity < *Zeros) ;
041217220627      If (Not ($XtnType = 'ADJ ') And Not ($XtnType = 'PROD')) ;
041218220627        $RspText = 'E017: Reqd Qty must be positive for Trans Type '
041219220627                     + %Trim(%Char($ItemQuantity)) + '/'
041220220627                     + %Trim($XtnType)
041221220627                     + '.' ;
041222220627        $ErrFd = *On ;
041223220627      EndIf ;
041224220627    EndIf ;
041225220627  EndIf ;
041226220627  // End: MD01
041227220627
041228220627  // Begin: MD01
041229220627  //
041230211224  // If requested quantity is positive, it cannot be
041231211224  // greater than available quantity.
041232211224  //
041233220627  // If Not $ErrFd ;
041234220627  //   If ($ItemQuantity > *Zeros) ; // User requested positive qty.
041235220627  //     If Not ($XtnType = 'ADJ ') ;
041236220627  //       RtvQtyAvail() ;
041237220627  //       If ($QtyAvail < $ItemQuantity) ;
041238220627  //         $RspText = 'E018: Qty requested '
041239220627  //                      + %Trim(%Char($ItemQuantity))
041240220627  //                      + ' cannot be greater than qty avail: '
041241220627  //                      + %Trim(%Char($QtyAvail)) + '.' ;
041242220627  //         $ErrFd = *On ;
041243220627  //       EndIf ;
041244220627  //     EndIf ;
041245220627  //   EndIf ;
041246220627  //   If ($ItemQuantity > *Zeros) ;
041247220627  //   EndIf ;
041248220627  // EndIf ;
041249220627  If Not $ErrFd ;
041250220627    If ($ItemQuantity > *Zeros) ; // User requested positive qty.
041251220627      If (Not ($XtnType = 'ADJ ') And Not ($XtnType = 'PROD')) ;
041252220627        RtvQtyAvail() ;
041253220627        If ($QtyAvail < $ItemQuantity) ;
041254220627          $RspText = 'E018: Qty requested '
041255220627                       + %Trim(%Char($ItemQuantity))
041256220627                       + ' cannot be greater than qty avail: '
041257220627                       + %Trim(%Char($QtyAvail)) + '.' ;
041258220627          $ErrFd = *On ;
041259220627        EndIf ;
041260220627      EndIf ;
041261220627    EndIf ;
041262220627  EndIf ;
041265220627  // End: MD01
041266220627
041267211224  //
041268000000  // Set flag to exit program if any errors found.
041269000000  //
041300000000  If $ErrFd ;
041400000000    $EndPg = *On ;
041500000000  EndIf ;
041600000000
041700000000  //
041800000000  // Return to calling procedure.
041900000000  //
042000000000  Return ;
042100000000
042200000000end-proc ;
042300000000
042400000000// ==============================================================
042500000000// Procedure name: ProcessRequest
042600000000// Purpose: Process request.
042700000000// Returns:
042800000000// ==============================================================
042900000000
043000000000dcl-proc ProcessRequest ;
043100000000
043200211227  dcl-pr HHDDIS ExtProc ; // Delete Item Stock Loc Records With 0 Qty.
043207211224    *n Like(hditslDS_t.isSId#) ; // Stock loc id
043208211224    *n Like(hditslDS_t.isItem) ; // Item number
043209211224    *n Packed(3:0)             ; // Warehouse (HHDDIS requires packed, not zoned.)
043210211224    *n Like(hditslDS_t.isLot)  ; // Lot number
043211211224  end-pr ;
043212211224
043220211227  dcl-s $WhsFrom Packed(3:0) Inz ;
043228211224  dcl-s $WhsTo   Packed(3:0) Inz ;
043229211224
043230211224  // Call transaction program for primary transaction.
043231211213  //
043232211213  $Type = $XtnType ;
043233211213  $Whs  = $ItemWhsFrom ;
043234211213  $SCC1 = hdiwhsDS_From.iwStCs ;
043235211213  $SWhs = $ItemWhsTo ;
043236220114  $Stkr = $StockroomFrom ;
043237220114  $Aile = $AisleFrom ;
043238220114  $SLoc = $StockLocFrom ;
043239211213  $OSeq = *Zeros ;
043240211213  CallHHDDTU() ;
043241211215
043242211213  //
043243211213  // Call transaction update program for secondary transaction (TRIN),
043244211213  // if required (Primary = TROU).
043245211213  //
043246211213  If ($XtnType = 'TROU') ;
043247211213    $Type = 'TRIN' ;
043248211213    $Whs  = $ItemWhsTo ;
043249211213    $SCC1 = hdiwhsDS_To.iwStCs ;
043250211213    $SWhs = $ItemWhsFrom ;
043251220114    $Stkr = $StockroomTo ;
043252220114    $Aile = $AisleTo ;
043253220114    $SLoc = $StockLocTo ;
043254211213    CallHHDDTU() ;
043255211213  EndIf ;
043256211213
043257211224  //
043258211224  // Clean up empty item stock location records.
043259211224  //
043260211224  // Note: HHDDIS requires packed warehouse value, not zoned.
043261211224  //
043262211224  $WhsFrom = hditslDS_From.isWhs ;
043263211224  $WhsTo   = hditslDS_To.isWhs   ;
043264211224  HHDDIS(hditslDS_From.isSId#:hditslDS_From.isItem:$WhsFrom:hditslDS_From.isLot) ;
043265211224  If ($xtnType = 'TROU') ;
043266211224    HHDDIS(hditslDS_To.isSId#:hditslDS_To.isItem:$WhsTo:hditslDS_To.isLot) ;
043267211224  EndIf ;
043268211224
043269211215  //
043300000000  // Return to calling procedure.
043400000000  //
043500000000  Return ;
043600000000
043700000000end-proc ;
043800000000
043900211224// ==============================================================
043901211224// Procedure name: RtvQtyAvail
043902211224// Purpose: Call HHDRAV to retrieve quantity available for
043903211224//          requested item/whs/lot/stockroom/aisle/location.
043904211224// Returns:
043905211224// ==============================================================
043906211224
043907211224dcl-proc RtvQtyAvail ;
043908211224
043909211224  dcl-pr HHDRAV ExtProc ; // Retrieve quantity available.
043910211224    *n Char(15) ; // Item nbr
043911211224    *n Packed(3:0) ; // Warehouse nbr (HHDRAV requires packed, not zoned.)
043912211224    *n Char(15) ; // Lot nbr
043913211224    *n Char(3) ; // Stock room
043914211224    *n Char(4) ; // Aisle
043915211224    *n Char(8) ; // Location
043916211224    *n Packed(13:4) ; // Qty available
043917211224    *n Packed(13:4) ; // Qty on-hand
043918211224  end-pr ;
043919211224
043920211224  dcl-ds hhdravDS Qualified ;
043921211224    Item   Char(15) ;
043922211224    Whs    Packed(3:0) ;
043923211224    Lot    Char(15) ;
043924211224    StkRm  Char(3) ;
043925211224    Aisle  Char(4) ;
043926211224    SLoc   Char(8) ;
043927211224    Avail  Packed(13:4) ;
043928211224    OnHand Packed(13:4) ;
043929211224  end-ds ;
043930211224
043931211224  //
043932211224  // Initialize quantities.
043933211224  //
043934211224  $QtyAvail  = *Zeros ;
043935211224  $QtyOnHand = *Zeros ;
043936211224
043937211224  //
043938211224  // Load parameter HHDRAV parameter list.
043939211224  //
043940211224  Clear hhdravDS ;
043941220114  hhdravDS.Item  = $ItemNumber ;
043942220114  hhdravDS.Whs   = $ItemWhsFrom ;
043943220114  hhdravDS.StkRm = $StockroomFrom ;
043944220114  hhdravDS.Aisle = $AisleFrom ;
043945220114  hhdravDS.SLoc  = $StockLocFrom ;
043946211224
043947211224  //
043948211224  // Call update transaction program.
043949211224  //
043950211224  HHDRAV(hhdravDS.Item:hhdravDS.Whs:hhdravDS.Lot:hhdravDS.StkRm
043951211224          :hhdravDS.Aisle:hhdravDS.SLoc:hhdravDS.Avail:hhdravDS.OnHand) ;
043952211224
043953211224  //
043954211224  // Load quantities returned from Harris.
043955211224  //
043956211224  $QtyAvail  = hhdravDS.Avail ;
043957211224  $QtyOnHand = hhdravDS.OnHand ;
043958211224
043959211224  //
043960211224  // Return to calling procedure.
043961211224  //
043962211224  Return ;
043963211224
043964211224end-proc ;
043965211224
043966211224// ==============================================================
043967211212// Procedure name: CallHHDDTU
043968211212// Purpose: Call HHDDTU to update transaction tables.
043969211212// Returns:
043970211212// ==============================================================
043971211212
043972211212dcl-proc CallHHDDTU ;
043973211212
043974211227  dcl-pr HHDDTU ExtProc ; // Update files for transactions.
043975211227    *n LikeDS(hhddtuDS) ;
043976211227  end-pr ;
043978211227
043979211227  dcl-ds xtnStampDS LikeDS(sysStampDS_t) ;
043980211212
043981211212  // Retrieve current system timestamp.
043982211212  xtnStampDs = RtvSysStamp() ;
043983211212
043984211212  //
043985211212  // Load parameter HHDDTU parameter list.
043986211212  //
043987211215  Clear hhddtuDS ;
043988211215  hhddtuDS.plType = $Type ;
043989211215  hhddtuDS.plItem = $ItemNumber ;
043990211215  hhddtuDS.plWhs  = $Whs ;
043991211215  hhddtuDS.plPlt  = *Zeros ;
043992211215  hhddtuDS.plTrDt = CvtDateToCyymmdd(xtnStampDs.date) ;
043993211215  hhddtuDS.plDoc# = 1 ;
043994211215  hhddtuDS.plDcL# = *Zeros ;
043995211215  hhddtuDS.plBtCs = *Zeros ;
043996211215  hhddtuDS.plStCs = *Zeros ;
043997211215  hhddtuDS.plDShp = *Zeros ;
043998211215  hhddtuDS.plRInv = *Zeros ;
043999211215  hhddtuDS.plQty  = $ItemQuantity ;
044000211215  hhddtuDS.plPPUM = *Zeros ;
044001211215  hhddtuDS.plExPa = *Zeros ;
044002211215  hhddtuDS.plSCC1 = $SCC1 ;
044003211215  hhddtuDS.plSCC2 = *Zeros ;
044004211215  hhddtuDS.plSCC3 = *Zeros ;
044005211215  hhddtuDS.plSCC4 = *Zeros ;
044006211215  hhddtuDS.plSCC5 = *Zeros ;
044007211215  hhddtuDS.plECC1 = %DecH(hhddtuDS.plSCC1 * hhddtuDS.plQty: 11 : 2) ;
044008211215  hhddtuDS.plECC2 = *Zeros ;
044009211215  hhddtuDS.plECC3 = *Zeros ;
044010211215  hhddtuDS.plECC4 = *Zeros ;
044011211215  hhddtuDS.plECC5 = *Zeros ;
044012211215  hhddtuDS.plTrfV = *Zeros ;
044013211215  hhddtuDS.plKitC = *Zeros ;
044014211215  hhddtuDS.plLPPU = *Zeros ;
044015211215  hhddtuDS.plSWhs = $SWhs ;
044016211215  hhddtuDS.plSPlt = *Zeros ;
044017211215  hhddtuDS.plSPCs = *Blanks ;
044018211215  hhddtuDS.plRecv = *Blanks ;
044019211215  hhddtuDS.plRmVd = *Zeros ;
044020211215  hhddtuDS.plVend = *Zeros ;
044021211215  hhddtuDS.plOrDt = *Zeros ;
044022220114  hhddtuDS.plStkR = $Stkr ;
044023220114  hhddtuDS.plAile = $Aile ;
044024211215  hhddtuDS.plSLoc = $SLoc ;
044025211215  hhddtuDS.plLot# = *Blanks ;
044026211215  hhddtuDS.plCmnt = *Blanks ;
044027211215  hhddtuDS.plAcct = hdttypDS.ttMOfM ;
044028211215  hhddtuDS.plSub  = hdttypDS.ttMOfS ;
044029211215  hhddtuDS.plOvrd = *Blanks ;
044030211215  hhddtuDS.plRsnC = *Blanks ;
044031211215  hhddtuDS.plRsnD = %Subst($AdjReason:1:25) ;
044032211215  hhddtuDS.plVLot = *Blanks ;
044033211215  hhddtuDS.plLCPU = *Zeros ;
044034211215  hhddtuDS.plLCEx  = *Zeros ;
044035211215  hhddtuDS.plPgm  = psdsDS.ProcPgm ;
044036211215  hhddtuDS.plWsId = 'WEB' ;
044037211215  hhddtuDS.plUser = psdsDS.User ;
044038211215  hhddtuDS.plDtRc = *Zeros ;
044039211215  hhddtuDS.plDtEx = *Zeros ;
044040211215  hhddtuDS.plUDF1 = *Blanks ;
044041211215  hhddtuDS.plUDF2 = *Blanks ;
044042211215  hhddtuDS.plUDF3 = *Blanks ;
044043211215  hhddtuDS.plSeqN = *Zeros ;
044044211215  hhddtuDS.plMOrd = *Blanks ;
044045211215  hhddtuDS.plAvgC = *Blanks ;
044046211215  hhddtuDS.plOSeq = $OSeq ;
044047211213
044048211213  //
044049211213  // Call update transaction program.
044050211213  //
044051211227  HHDDTU(hhddtuDS) ;
044052211227
044053211213  //
044054211213  // Save resulting sequence number.
044055211213  //
044056211215  $OSeq = hhddtuDS.plOSeq ;
044057211213
044058211213  //
044059211212  // Return to calling procedure.
044060211212  //
044061211212  Return ;
044062211212
044063211212end-proc ;
044064211212
044065211212// ==============================================================
044066000000// Procedure name: RtvSysStamp
044100000000// Purpose: Retrieve current system timestamp.
044200000000// Returns: DS of timestamp, date, and time.
044300000000// ==============================================================
044400000000
044500000000dcl-proc RtvSysStamp ;
044600000000  dcl-pi *n LikeDS(sysStampDS_t) ;
044700000000  end-pi ;
044800000000
044900000000  dcl-ds $NowDS LikeDS(sysStampDS_t) ;
045000000000
045100000000  $NowDS.Stamp = %Timestamp() ;
045200000000  $NowDS.Date  = %Date($NowDS.Stamp) ;
045300000000  $NowDS.Time  = %Time($NowDS.Stamp) ;
045400000000
045500000000  Return $NowDS ;
045600000000
045700000000end-proc ;
045800000000
045900211212// ==============================================================
045901211212// Procedure name: CvtDateToCyymmdd
045902211212// Purpose: Convert DATE object to zoned decimal 7,0 cyymmdd.
045903211212// Returns: zoned decimal 7,0 cyymmdd
045904211212// ==============================================================
045905211212
045906211212dcl-proc CvtDateToCyymmdd ;
045907211212  dcl-pi *n Zoned(7:0) ;
045908211214    Date_IN Date ; // DATE object to be converted.
045909211212  end-pi ;
045910211212
045911211212  dcl-s Date_OUT Zoned(7:0) Inz(*Zeros) ;
045912211212  dcl-s $Wk80    Zoned(8:0) Inz(*Zeros) ;
045913211212
045914211212  Exec Sql
045915211214    SELECT DEC(VARCHAR_FORMAT(:Date_IN, 'YYYYMMDD'), 8) - 19000000
045916211212      INTO :$Wk80
045917211212      FROM sysibm.sysdummy1 ;
045918211212
045919211212  Date_OUT = $Wk80 ;
045920211214
045921211214  Return Date_OUT ;
045922211212
045923211212end-proc;
045924211212
045925211212// ==============================================================
046000000000// Procedure name: ShtDwn
046100000000// Purpose: Perform clean-up and return to calling program.
046200000000// Returns:
046300000000// ==============================================================
046400000000
046500000000dcl-proc ShtDwn ;
046600000000
046700000000  //
046800000000  // Load return parameters.
046900000000  //
047000000000  If Not $ErrFd ;
047100000000    ##Success = #YES ;
047200000000  EndIf ;
047300000000  ##RspText = $RspText ;
047400000000
047500220131  //
049400000000  // Close implicitly-opened files and return to calling program.
049500000000  //
049600000000  *InLR = *On ;
049700000000  Return ;
049800000000
049900000000end-proc ;
