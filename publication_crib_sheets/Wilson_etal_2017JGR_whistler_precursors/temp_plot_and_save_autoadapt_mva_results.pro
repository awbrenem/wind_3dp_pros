;+
;*****************************************************************************************
;
;  PROCEDURE:   temp_plot_and_save_autoadapt_mva_results.pro
;  PURPOSE  :   This routine takes the output results from the routine
;                 extract_good_mva_from_adapint.pro and plots the time series as an
;                 interval with the best subintervals (SIs) and time windows (TWs) within
;                 each SI defined by those with the best minimum variance analysis (MVA)
;                 results.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               test_tplot_handle.pro
;               get_data.pro
;               sample_rate.pro
;               is_a_number.pro
;               get_valid_trange.pro
;               trange_clip_data.pro
;               calc_and_save_mva_res_by_int.pro
;               num2int_str.pro
;               t_get_struc_unix.pro
;               keep_best_mva_from_adapint.pro
;               lbw_window.pro
;               unit_vec.pro
;               my_dot_prod.pro
;               poly_winding_number2d.pro
;               str_element.pro
;               time_string.pro
;               minmax.pro
;               file_name_times.pro
;               extract_tags.pro
;               popen.pro
;               pclose.pro
;               plotxy.pro
;               plotxyvec.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               AC_FIELD_TPN  :  Scalar [string] defining the TPLOT handle for the
;                                  AC-coupled field data upon which to perform
;                                  MVA
;                                  [***  Routine assumes already filtered  ***]
;               DC_FIELD_TPN  :  Scalar [string] defining the TPLOT handle for the
;                                  DC-coupled field data for which to compare
;                                  and use as a reference for the MVA results
;
;  EXAMPLES:    
;               [calling sequence]
;               temp_plot_and_save_autoadapt_mva_results,ac_bfield_tpn,dc_bfield_tpn,    $
;                                  INTS_TRANGE=ints_trange,FLOW_SUBINT=flow_subint,      $
;                                  FHIGHSUBINT=fhighsubint [,BRST_TRAN=brst_tran]        $
;                                  [,BAD_INTS=bad_ints] [,BAD_FLOW=bad_flow]             $
;                                  [,SCPREF=scpref] [,FPREF_MID=fpref_mid0]              $
;                                  [,BAVG_UP=bavg_up] [,SH_NORM=sh_norm]                 $
;                                  [,BEST_SUBINT=best_subint] [,MVA_RESULTS=mva_results] $
;                                  [,BEST_RESULTS=best_res] [,POLARIZE_WAV=polarize_wav]
;
;  KEYWORDS:    
;               **********************************
;               ***      REQUIRED  INPUTS      ***
;               **********************************
;               INTS_TRANGE   :  [I,2]-Element [numeric] array defining the Unix start/end
;                                  times of each interval within STRUC
;               FLOW_SUBINT   :  Scalar [structure] containing I-tags with arrays of the
;                                  lower bound frequencies [Hz] for the bandpass filters,
;                                  where the i-th tag corresponds to i-th interval in
;                                  INTS_TRANGE
;               FHIGHSUBINT   :  Scalar [structure] containing I-tags with arrays of the
;                                  upper bound frequencies [Hz] for the bandpass filters,
;                                  where the i-th tag corresponds to i-th interval in
;                                  INTS_TRANGE
;               **********************************
;               ***      OPTIONAL  INPUTS      ***
;               **********************************
;               BRST_TRAN     :  [2]-Element [numeric] array defining the Unix start/end
;                                  times of the burst interval of interest
;                                  [Default = (user is prompted to enter time range)]
;               BAD_INTS      :  [K]-Element [numeric] array defining the intervals within
;                                  the time range of STRUC to avoid performing MVA.
;                                  [Default = -1]
;               BAD_FLOW      :  [K]-Element [numeric] array defining the low frequency
;                                  bound corresponding to the BAD_INTS in the event that
;                                  the same interval has good frequency ranges on which to
;                                  perform MVA.
;                                  [Default = NaN]
;               SCPREF        :  Scalar [string] defining the name of the spacecraft (or
;                                  whatever name the user wishes to use) to use in the
;                                  output file name
;                                  [Default = 'sc']
;               FPREF_MID     :  Scalar [string] to insert into the output file name
;                                  after the SCPREF[0]+'_' initial prefix.  For instance,
;                                  this is a useful way to label each burst interval or
;                                  some other defining trait of a given input STRUC.
;                                  [Default = '']
;               BEST_SUBINT   :  Scalar [structure] containing multiple tags corresponding
;                                  to analysis on multiple intervals from the output of
;                                  the BEST_NO_OVRLP keyword in the routine
;                                  extract_good_mva_from_adapint.pro
;                                  [Default = (defined on output)]
;               MVA_RESULTS   :  Scalar [structure] containing multiple tags corresponding
;                                  to analysis on multiple intervals from the output of
;                                  the routine extract_good_mva_from_adapint.pro
;                                  [Default = (defined on output)]
;               BAVG_UP       :  [3,2]-Element array defining the average upstream
;                                  magnetic field vector, BAVG_UP[*,0], and associated
;                                  uncertainties BAVG_UP[*,1]
;               SH_NORM       :  [3,2]-Element array defining the average upstream
;                                  shock normal vector, SH_NORM[*,0], and associated
;                                  uncertainties, SH_NORM[*,1]
;               FREQ__LOW     :  [I,2]-Element [string] defining the lower frequency bound,
;                                  with units, to use for labels in plot titles and file
;                                  name outputs.  The numbers go in the first column and
;                                  units in the second, e.g., FREQ__LOW[0,1] = 'mHz'.
;               FREQ_HIGH     :  [I,2]-Element [string] defining the upper frequency bound,
;                                  with units, to use for labels in plot titles and file
;                                  name outputs.  The numbers go in the first column and
;                                  units in the second, e.g., FREQ_HIGH[0,1] = 'Hz'.
;               **********************************
;               ***           OUTPUTS          ***
;               **********************************
;               BEST_SUBINT   :  Set to a named variable to return a scalar [structure]
;                                  containing multiple tags corresponding to analysis on
;                                  multiple intervals from the output of the BEST_NO_OVRLP
;                                  keyword in the routine extract_good_mva_from_adapint.pro
;               MVA_RESULTS   :  Set to a named variable to return a scalar [structure]
;                                  containing multiple tags corresponding to analysis on
;                                  multiple intervals from the output of the routine
;                                  extract_good_mva_from_adapint.pro
;               BEST_RESULTS  :  Set to a named variable to return a scalar [structure]
;                                  containing the "best" MVA results returned by the
;                                  routine keep_best_mva_from_adapint.pro
;               POLARIZE_WAV  :  Set to a named variable to return a scalar [structure]
;                                  containing the polarization with respect to the
;                                  quasi-static magnetic field (i.e., handedness) of each
;                                  subinterval plotted (only results returned by the
;                                  routine keep_best_mva_from_adapint.pro are checked)
;
;   CHANGED:  1)  Adapted from temp_plot_and_save_scm_mva_results.pro
;                                                                   [04/06/2017   v1.0.0]
;             2)  Changed thresholds for keeping interval and cleaned up a little
;                                                                   [04/07/2017   v1.0.1]
;             3)  Now plots "bad" intervals but in orange, not black to distinguish
;                                                                   [04/07/2017   v1.0.2]
;             4)  Added Keywords:  BAVG_UP and SH_NORM
;                                                                   [04/07/2017   v1.1.0]
;             5)  Added Keywords:  FREQ__LOW and FREQ_HIGH
;                                                                   [04/19/2017   v1.2.0]
;
;   NOTES:      
;               1)  See also:
;                     adaptive_mva_interval_wrapper.pro
;                     extract_good_mva_from_adapint.pro
;               2)  Do not add a '_' after SCPREF or FPREF_MID inputs, as the routine
;                     will do that automatically
;               3)  Use FREQ__LOW and FREQ_HIGH keywords in place of the original
;                     FLOW_SUBINT and FHIGHSUBINT only when inputs are pre-filtered
;                     and user does not want subsequent routines to filter further.
;                     In this case, define FLOW_SUBINT and FHIGHSUBINT such that the
;                     frequency ranges are well outside the actual FFT frequencies.
;                     This will prevent vector_bandpass.pro from actually performing
;                     a bandpass filter.
;
;  REFERENCES:  
;               1)  G. Paschmann and P.W. Daly "Analysis Methods for Multi-Spacecraft
;                     Data," ISSI Scientific Report, Noordwijk, The Netherlands.,
;                     Int. Space Sci. Inst., 1998.
;               2)  J.C. Samson and J.V. Olson, "Some Comments on the Descriptions of
;                      the Polarization States of Waves," Geophys. J. Astr. Soc. 61,
;                      pp. 115-129, 1980.
;               3)  J.D. Means, "Use of the Three-Dimensional Covariance Matrix in
;                      Analyzing the Polarization Properties of Plane Waves,"
;                      J. Geophys. Res. 77(28), pg 5551-5559, 1972.
;               4)  H. Kawano and T. Higuchi "The bootstrap method in space physics:
;                     Error estimation for the minimum variance analysis," Geophys.
;                     Res. Lett. 22(3), pp. 307-310, 1995.
;               5)  A.V. Khrabrov and B.U.Ö Sonnerup "Error estimates for minimum
;                     variance analysis," J. Geophys. Res. 103(A4), pp. 6641-6651,
;                     1998.
;
;   CREATED:  07/22/2016
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/19/2017   v1.2.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO temp_plot_and_save_autoadapt_mva_results,ac_bfield_tpn,dc_bfield_tpn,            $
                                   INTS_TRANGE=ints_trange,BRST_TRAN=brst_tran,      $
                                   FLOW_SUBINT=flow_subint,FHIGHSUBINT=fhighsubint,  $
                                   BAD_INTS=bad_ints,BAD_FLOW=bad_flow,              $
                                   SCPREF=scpref,FPREF_MID=fpref_mid0,               $
                                   BAVG_UP=bavg_up0,SH_NORM=sh_norm0,                $
                                   FREQ__LOW=freq__low,FREQ_HIGH=freq_high,          $
                                   BEST_SUBINT=best_subint,MVA_RESULTS=mva_results,  $
                                   BEST_RESULTS=best_res,POLARIZE_WAV=polarize_wav

;;****************************************************************************************
ex_start = SYSTIME(1)
;;****************************************************************************************
;;----------------------------------------------------------------------------------------
;;  Constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Define default minimum # of points to allow for any given interval
def_min_nint   = 10L
;;  Factors and units
mult_facts     = [1d12,1d9,1d6,1d3,1d0,1d-3,1d-6,1d-9,1d-12]
si_prefixes    = ['p','n','mu','m','','k','M','G','T']
mult_units     = si_prefixes+'(nT)'
fran_units     = si_prefixes+'Hz'
;;  Plot specific stuff
xytpre         = ['Int.','Max.']+' Var. '
origin         = [[0d0],[0d0]]
def_pstr_ts    = {XSTYLE:1,YSTYLE:1,NODATA:1,YMINOR:10,XMINOR:10,XTICKS:7,YTICKS:4,CHARSIZE:2.}
popen_str      = {LANDSCAPE:1,UNITS:'inches',XSIZE:10.75,YSIZE:8.25}
popen_hodo     = {PORT:1,UNITS:'inches',XSIZE:8.0,YSIZE:8.0}
pstr_xy        = {XSTYLE:1,YSTYLE:1,YMINOR:10,XMINOR:10,XTICKS:4,YTICKS:4,CHARSIZE:1.,$
                  PSTART:4,PSTOP:5,STARTSYMCOLOR:250,STOPSYMCOLOR:50,SYMSIZE:2}
pstr_v         = {OVERPLOT:1,COLOR:250,UARROWSIDE:'none'}
ncirc          = 50L
cfact          = 2d0*!DPI/(ncirc[0] - 1L)
c_a0           = DINDGEN(ncirc[0])*cfact[0]
c_x0           = COS(c_a0)
c_y0           = SIN(c_a0)
circ           = [[c_x0],[c_y0]]
;;  Define some coordinate strings
coord_dsl      = 'dsl'
coord_gse      = 'gse'
coord_gsm      = 'gsm'
coord_fac      = 'fac'
coord_mag      = 'mag'
coord_gseu     = STRUPCASE(coord_gse[0])
yttle_ts_icb   = 'B [GSE, nT]'
yttle_ts_mva   = 'B [MVA, nT]'
;;  Dummy error messages
no_inpt_msg    = 'User must supply at least two TPLOT handles...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 2) OR                                     $
                 (test_tplot_handle(dc_bfield_tpn,TPNMS=dcf_tpn) EQ 0) OR $
                 (test_tplot_handle(ac_bfield_tpn,TPNMS=acf_tpn) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,no_inpt_msg,/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;----------------------------------------------------------------------------------------
;;  Get data
;;----------------------------------------------------------------------------------------
;;  stuff related to AC_FIELD_TPN and DC_FIELD_TPN inputs
;;    Bo [nT, ICB]
get_data,dcf_tpn[0],DATA=t_dcf_str,DLIMIT=dlim_dcf,LIMIT=lim_dcf
;;    ∂B [nT, ICB]
get_data,acf_tpn[0],DATA=t_acf_str,DLIMIT=dlim_acf,LIMIT=lim_acf
;;  Calculate sample rates [sps] and periods [s]
unix_bo        = t_get_struc_unix(t_dcf_str,TSHFT_ON=tshft_on)
unix_db        = t_get_struc_unix(t_acf_str,TSHFT_ON=tshft_on)
srate_bo0      = sample_rate(unix_bo,/AVERAGE)
IF (srate_bo0[0] GT 1) THEN sr = ROUND(srate_bo0[0]) ELSE sr = srate_bo0[0]
srate_bo       = DOUBLE(sr[0])                     ;;  Sample rate [sps]
speri_bo       = 1d0/srate_bo[0]                   ;;  Sample period [s]
srate_db0      = sample_rate(unix_db,/AVERAGE)
IF (srate_db0[0] GT 1) THEN BEGIN
  IF (srate_db0[0] GT 10) THEN BEGIN
    sr = FLOOR(srate_bo0[0])
  ENDIF ELSE BEGIN
    sr = ROUND(srate_bo0[0])
  ENDELSE
ENDIF ELSE BEGIN
  sr = srate_bo0[0]
ENDELSE
srate_db       = DOUBLE(ROUND(srate_db0[0]))       ;;  Sample rate [sps]
speri_db       = 1d0/srate_db[0]                   ;;  Sample period [s]
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check BAD_INTS and BAD_FLOW
test           = (N_ELEMENTS(bad_ints) EQ 0) OR (N_ELEMENTS(bad_flow) EQ 0)
IF (test[0]) THEN bad_ints = [-1L]
IF (test[0]) THEN bad_flow = [f]
;;  Check INTS_TRANGE
test           = (N_ELEMENTS(ints_trange) LT 2) OR (is_a_number(ints_trange,/NOMSSG) EQ 0)
IF (test[0]) THEN RETURN     ;;  Required input keyword missing --> exit
nt             = N_ELEMENTS(ints_trange)/2L         ;;  # of intervals within burst time range
ints_trange    = REFORM(ints_trange,nt[0],2L)
st_td          = REFORM(ints_trange[*,0])
en_td          = REFORM(ints_trange[*,1])
nt             = N_ELEMENTS(st_td)                ;;  # of intervals within burst time range
;;  Define interval durations
int_durat      = ABS(en_td - st_td)
int_npts       = int_durat*srate_db[0]
min_int_npts   = FLOOR(MIN(int_npts,/NAN))        ;;  Minimum # of 3-vectors in any given interval
;;  Define # of time windows within each subinterval
CASE 1 OF
  (min_int_npts[0] LT 10L)  :  BEGIN
    outmssg = 'Not enough points on which to perform MVA... exiting prematurely'
    PRINT,''
    MESSAGE,outmssg[0],/INFORMATIONAL,/CONTINUE
    PRINT,''
    RETURN
  END
  (min_int_npts[0] GE 10L AND min_int_npts[0] LE 20L)  :  BEGIN
    n_win = 2L
;    n_win = 1L                 ;;  # of time windows within each subinterval
  END
;  (min_int_npts[0] GT 20L AND min_int_npts[0] LE 200L)  :  BEGIN
  (min_int_npts[0] GT 20L AND min_int_npts[0] LE 100L)    :  BEGIN
    n_win = 20L < (min_int_npts[0]/5L)
  END
  (min_int_npts[0] GT 100L AND min_int_npts[0] LE 200L)   :  BEGIN
    n_win = 40L < (min_int_npts[0]/5L)
  END
;  (min_int_npts[0] GT 200L AND min_int_npts[0] LE 500L)   :  BEGIN
  (min_int_npts[0] GT 200L AND min_int_npts[0] LE 300L)   :  BEGIN
    n_win = 60L < (min_int_npts[0]/5L)
;    n_win = 20L < (min_int_npts[0]/10L)                 ;;  # of time windows within each subinterval
  END
  (min_int_npts[0] GT 300L AND min_int_npts[0] LE 400L)   :  BEGIN
    n_win = 80L < (min_int_npts[0]/5L)
  END
  (min_int_npts[0] GT 400L AND min_int_npts[0] LE 500L)   :  BEGIN
    n_win = 100L < (min_int_npts[0]/5L)
  END
  (min_int_npts[0] GT 500L AND min_int_npts[0] LE 1000L)  :  BEGIN
    n_win = 200L < (min_int_npts[0]/5L)
;    n_win = 50L < (min_int_npts[0]/10L)                 ;;  # of time windows within each subinterval
  END
  (min_int_npts[0] GT 1000L)  :  BEGIN
    n_win = 200L                 ;;  # of time windows within each subinterval
;    n_win = 100L                 ;;  # of time windows within each subinterval
  END
  ELSE  :  STOP      ;;  Should not happen --> Debug!
ENDCASE
;;  Check BRST_TRAN
tra_struc      = get_valid_trange(TRANGE=brst_tran,PRECISION=prec)
tr_brst_int    = tra_struc.UNIX_TRANGE
test           = (TOTAL(FINITE(tr_brst_int)) LT 2)
IF (test[0]) THEN RETURN     ;;  Required input keyword missing --> exit
;;  Check FLOW_SUBINT and FHIGHSUBINT
test           = (SIZE(flow_subint,/TYPE) NE 8) OR (SIZE(fhighsubint,/TYPE) NE 8)
IF (test[0]) THEN RETURN     ;;  Required input keyword missing --> exit
test           = (N_TAGS(flow_subint) NE nt[0]) OR (N_TAGS(fhighsubint) NE nt[0])
IF (test[0]) THEN RETURN     ;;  Required input keyword missing --> exit
flow_ww_str    = flow_subint
fhig_ww_str    = fhighsubint
;;  Check SCPREF
test           = (SIZE(scpref,/TYPE) NE 7)
IF (test[0]) THEN scpref = 'sc' ELSE scpref = scpref[0]
;IF (test[0]) THEN scpref = 'sc_' ELSE scpref = scpref[0]
;;  Check FPREF_MID
test           = (SIZE(fpref_mid0,/TYPE) NE 7)
IF (test[0]) THEN fpref_mid = '' ELSE fpref_mid = fpref_mid0[0]+'_'
;;  Check BAVG_UP
test           = (N_ELEMENTS(bavg_up0) EQ 6) AND is_a_number(bavg_up0,/NOMSSG)
IF (test[0]) THEN BEGIN
  bavg_up = REFORM(bavg_up0,3,2)
ENDIF
;;  Check SH_NORM
test           = (N_ELEMENTS(sh_norm0) EQ 6) AND is_a_number(sh_norm0,/NOMSSG)
IF (test[0]) THEN BEGIN
  sh_norm = REFORM(sh_norm0,3,2)
ENDIF
;;  Check FREQ__LOW and FREQ_HIGH
test           = (SIZE(freq__low,/TYPE) NE 7) OR (SIZE(freq_high,/TYPE) NE 7)
IF (test[0]) THEN use_orig_fkeys = 1b ELSE use_orig_fkeys = 0b
test           = (N_ELEMENTS(freq__low) NE N_ELEMENTS(freq_high)) AND (use_orig_fkeys[0] EQ 0)
IF (test[0]) THEN use_orig_fkeys = 1b ELSE use_orig_fkeys = 0b
test           = ((SIZE(freq__low,/N_DIMENSIONS) NE 2) OR (SIZE(freq_high,/N_DIMENSIONS) NE 2)) AND $
                 (use_orig_fkeys[0] EQ 0)
IF (test[0]) THEN use_orig_fkeys = 1b ELSE use_orig_fkeys = 0b
;;----------------------------------------------------------------------------------------
;;  Clip data to BRST_TRAN range
;;----------------------------------------------------------------------------------------
clip_acf       = trange_clip_data(t_acf_str,TRANGE=tr_brst_int,PREC=6)
;;----------------------------------------------------------------------------------------
;;  Get MVA results
;;----------------------------------------------------------------------------------------
min_thrsh      = 5d-2                ;;  use 50 pT as the minimum threshold allowed for MVA
d__nw          = 2L                  ;;  # of points btwn size of each time window within in subinterval
d__ns          = 4L                  ;;  # of points to shift btwn each subinterval
;n_win          = 50L                 ;;  # of time windows within each subinterval
mxovr          = 55d-2               ;;  require 55% overlap for two subintervals to be considered the "same"
saved          = calc_and_save_mva_res_by_int(clip_acf,INTS_TRANGE=ints_trange,                   $
                                              FLOW_SUBINT=flow_subint,FHIGHSUBINT=fhighsubint,    $
                                              BAD_INTS=bad_ints,BAD_FLOW=bad_flow,                $
                                              SCPREF=scpref[0],D__NW=d__nw[0],D__NS=d__ns[0],     $
                                              N_WIN=n_win[0],MIN_THRSH=min_thrsh[0],              $
                                              MAX_OVERL=mxovr[0],FPREF_MID=fpref_mid0,            $
                                              MIN_NUM_INT=def_min_nint[0],                        $
                                              N_INT_ARR=n_int_all,FRAN_FNM_STR=freq_str_str,      $
                                              FRAN_YSB_STR=freq_ysub_str,N_MIN_STR=nmin_filt_str, $
                                              BEST_SUBINT=best_subint,MVA_RESULTS=mva_results     )
;;----------------------------------------------------------------------------------------
;;  Define interval stuff
;;----------------------------------------------------------------------------------------
;;  stuff related to INTS_TRANGE keyword
int_strs       = num2int_str(LINDGEN(nt[0]),NUM_CHAR=3,/ZERO_PAD)
tags           = 'INT_'+int_strs
unix           = t_get_struc_unix(clip_acf)
;;----------------------------------------------------------------------------------------
;;  To get the subinterval indices, use the following:
;;    j    :  interval index associated with TRANGE
;;    k    :  frequency filter index
;;    sis  :  Start indices w/rt to beginning of j-th subinterval
;;    sie  :  End indices w/rt to beginning of j-th subinterval
;;    mvs  :  array of good MVA subinterval indices corrsponding to sis and sie
;;    mvw  :  array of good MVA time window indices within each subinterval " "
;;    
;;  Then one can define the following:
;;    sis = best_subint.(j).(k).SE_IND[*,0]
;;    sie = best_subint.(j).(k).SE_IND[*,1]
;;    mvs = best_subint.(j).(k).MVA_SIND
;;    mvw = best_subint.(j).(k).MVA_WIND
;;
;;
;;  To get the indices w/rt to the entire input array (i.e., STRUC), do the following:
;;    j    :  interval index associated with TRANGE
;;    k    :  frequency filter index
;;    st   :  index at start of interval defined by TRANGE w/rt zeroth index in STRUC.X
;;    en   :  index at end " "
;;    
;;  Then one can define the following:
;;    st  = mva_results.(j).(k).ALL_MVA_RESULTS.MVA_INT_STR.TW_IND_SE[0]
;;    en  = mva_results.(j).(k).ALL_MVA_RESULTS.MVA_INT_STR.TW_IND_SE[1]
;;----------------------------------------------------------------------------------------
test_struc     = (SIZE(best_subint,/TYPE) NE 8) OR (SIZE(mva_results,/TYPE) NE 8)
IF (test_struc[0]) THEN STOP     ;;  Something is wrong --> debug
;;----------------------------------------------------------------------------------------
;;  Get best results from adaptive interval (AI) MVA
;;----------------------------------------------------------------------------------------
best_res       = keep_best_mva_from_adapint(best_subint,mva_results)
test           = (SIZE(best_res,/TYPE) NE 8)
IF (test[0]) THEN STOP     ;;  Something is wrong --> debug
indices_struc  = best_res.INDICES_STRUC        ;;  Indices structures
sis_tws_struc  = best_res.SI_TW_STRUC          ;;  SI and TW #'s structures
eigvals_struc  = best_res.EIGVALS_STRUC        ;;  eigenvalue structures
eigvecs_struc  = best_res.EIGVECS_STRUC        ;;  eigenvector structures
test           = (SIZE(indices_struc,/TYPE) NE 8) OR (SIZE(sis_tws_struc,/TYPE) NE 8) OR $
                 (SIZE(eigvals_struc,/TYPE) NE 8) OR (SIZE(eigvecs_struc,/TYPE) NE 8)
IF (test[0]) THEN STOP     ;;  Something is wrong --> debug
nt             = MIN([N_TAGS(indices_struc),N_TAGS(sis_tws_struc),N_TAGS(eigvals_struc),N_TAGS(eigvecs_struc)])
;;----------------------------------------------------------------------------------------
;;  Open windows for plotting
;;----------------------------------------------------------------------------------------
DEVICE,GET_SCREEN_SIZE=s_size
xywsz          = ROUND([78.125d-2,95.925d-2]*s_size)
lbw_window,WIND_N=1,_EXTRA={XSIZE:xywsz[0],YSIZE:xywsz[0],TITLE:'Time Series'}
xywsz          = ROUND([55d0/96d0,93.379d-2]*s_size)
xywsz[0]       = xywsz[0] < xywsz[1]
xywsz[1]       = xywsz[0]
lbw_window,WIND_N=2,_EXTRA={XSIZE:xywsz[0],YSIZE:xywsz[0],TITLE:'Max vs. Mid'}
;;----------------------------------------------------------------------------------------
;;  Plot and save
;;----------------------------------------------------------------------------------------
npl_max        = 15L                          ;;  Max. # of time series plots per file
nhd_max        = 8L                           ;;  Max. # of hodogram plots per file
xttle_ts       = 'Time [s from start]'
;xttle_ts       = 'Time [ms from start]'
ps_midfs_0     = 'Filt_Int_'+int_strs+'_'
xxo            = FINDGEN(17)*(!PI*2./16.)     ;;  Dummy array used for USERSYM later
polarize_wav   = 0                            ;;  Variable to be defined later for output

FOR int=0L, nt[0] - 1L DO BEGIN   ;;  Iterate over intervals
  ;;  Reset variables
  wavpol_struc   = 0
  right_handed   = 0
  wavpol_str     = ''
  ;;--------------------------------------------------------------------------------------
  ;;  Define interval-specific parameters
  ;;--------------------------------------------------------------------------------------
  ff_ind_struc   = indices_struc.(int[0])     ;;  I-th interval indices structure(s)
  ff_sitw_strc   = sis_tws_struc.(int[0])     ;;  " " SI and TW #'s structure(s)
  ff_eval_strc   = eigvals_struc.(int[0])     ;;  " " eigenvalue structure(s)
  ff_evec_strc   = eigvecs_struc.(int[0])     ;;  " " eigenvector structure(s)
  test           = (SIZE(ff_ind_struc,/TYPE) NE 8) OR (SIZE(ff_sitw_strc,/TYPE) NE 8) OR $
                   (SIZE(ff_eval_strc,/TYPE) NE 8) OR (SIZE(ff_evec_strc,/TYPE) NE 8)
  IF (test[0]) THEN BEGIN
    ;;  No MVA was performed on this interval --> skip iteration
;    str_element,polarize_wav,tags[int[0]],wavpol_struc,/ADD_REPLACE
    str_element,wavpol_struc,'FR_00',{LOGIC:right_handed,STRINGS:wavpol_str,THETA_KB:d,THETA_KN:d,WAV_AMP:d,GIND:{G_MVA_000:0b}},/ADD_REPLACE
    str_element,polarize_wav,tags[int[0]],wavpol_struc,/ADD_REPLACE
    CONTINUE
  ENDIF
  nfrq           = MIN([N_TAGS(ff_ind_struc),N_TAGS(ff_sitw_strc),N_TAGS(ff_eval_strc),N_TAGS(ff_evec_strc)])
  IF (use_orig_fkeys[0]) THEN BEGIN
    low_freqs      = flow_ww_str.(int[0])
    hig_freqs      = fhig_ww_str.(int[0])
    frq_stris      = freq_str_str.(int[0])
    frq_ysubs      = freq_ysub_str.(int[0])
  ENDIF ELSE BEGIN
    low_freqs      = FLOAT(freq__low[int[0],0])
    hig_freqs      = FLOAT(freq_high[int[0],0])
    frq_stris      = 'Filt_'+freq__low[int[0],0]+freq__low[int[0],1]+'-'+freq_high[int[0],0]+freq_high[int[0],1]
    frq_ysubs      = '[Filt: '+freq__low[int[0],0]+' '+freq__low[int[0],1]+' - '+$
                      freq_high[int[0],0]+' '+freq_high[int[0],1]+']'
  ENDELSE
  n_int          = n_int_all[int[0]]
  ftags          = 'FR_'+num2int_str(LINDGEN(nfrq[0]),NUM_CHAR=2,/ZERO_PAD)
  FOR ff=0L, nfrq[0] - 1L DO BEGIN  ;;  Iterate over frequency ranges
    ;;  Reset variables
    right_handed   = 0
    wavpol_str     = ''
    ;;------------------------------------------------------------------------------------
    ;;  Define frequency range-specific parameters
    ;;------------------------------------------------------------------------------------
    low_f          = low_freqs[ff[0]]
    highf          = hig_freqs[ff[0]]
    testf          = (FINITE(low_f[0]) EQ 0) OR (FINITE(highf[0]) EQ 0) OR $
                     (low_f[0] LT 0) OR (highf[0] LT 0)
    tests          = (SIZE(ff_ind_struc.(ff[0]),/TYPE) NE 8) OR $
                     (SIZE(ff_sitw_strc.(ff[0]),/TYPE) NE 8) OR $
                     (SIZE(ff_eval_strc.(ff[0]),/TYPE) NE 8) OR $
                     (SIZE(ff_evec_strc.(ff[0]),/TYPE) NE 8)
    IF (testf[0] OR tests[0]) THEN BEGIN
      ;;  No finite frequencies --> skip frequency range and interval
      str_element,wavpol_struc,ftags[ff[0]],{LOGIC:right_handed,STRINGS:wavpol_str,THETA_KB:d,THETA_KN:d,WAV_AMP:d,GIND:{G_MVA_000:0b}},/ADD_REPLACE
      CONTINUE
    ENDIF
    frq_strs       = frq_stris[ff[0]]
    frq_ysub       = frq_ysubs[ff[0]]
    ;;------------------------------------------------------------------------------------
    ;;  Define indices for best, non-overlapping results
    ;;------------------------------------------------------------------------------------
    ;;  Define indices relative to subinterval (SI)
    gi_sis         = ff_ind_struc.(ff[0]).ST_R2INT                   ;;  Good start array indices relative to SI
    gi_eis         = ff_ind_struc.(ff[0]).EN_R2INT                   ;;  Good end " "
    ;;  Define indices relative burst interval of input array
    tt_sti         = ff_ind_struc.(ff[0]).ST_R2ALL                   ;;  Good start array indices relative to start of burst interval
    tt_eni         = ff_ind_struc.(ff[0]).EN_R2ALL                   ;;  Good end " "
    nv_int         = tt_eni - tt_sti + 1L                            ;;  Total # of 3-vectors in given interval
    tind_mnmx      = [MIN(tt_sti),MAX(tt_eni)]         ;;  Index range relative entire input array
    ;;  Define good SI and time window (TW) numbers
    gi_sub         = ff_sitw_strc.(ff[0]).SUB_I_NUM                  ;;  Best SI indices
    gi_win         = ff_sitw_strc.(ff[0]).T_WIN_NUM                  ;;  Best TW indices
    ;;------------------------------------------------------------------------------------
    ;;  Define MVA results
    ;;------------------------------------------------------------------------------------
    ;;  Define eigenvalues
    gi_min_eval    = ff_eval_strc.(ff[0]).MIN_EIGVALS
    gi_mid_eval    = ff_eval_strc.(ff[0]).MID_EIGVALS
    gi_max_eval    = ff_eval_strc.(ff[0]).MAX_EIGVALS
    n_gi           = N_ELEMENTS(gi_min_eval)                         ;;  # of good MVA results
    gi_tags        = 'G_MVA_'+num2int_str(LINDGEN(n_gi[0]),NUM_CHAR=3,/ZERO_PAD)
    ;;  Define eigenvalue ratios
    gi_d2n_eval    = gi_mid_eval/gi_min_eval
    gi_x2d_eval    = gi_max_eval/gi_mid_eval
    ;;  Define eigenvectors
    gi_min_evec    = ff_evec_strc.(ff[0]).MIN_EIGVECS    ;;  Good minimum variance eigenvector [ICB]
    gi_mid_evec    = ff_evec_strc.(ff[0]).MID_EIGVECS    ;;  Good intermediate " "
    gi_max_evec    = ff_evec_strc.(ff[0]).MAX_EIGVECS    ;;  Good maximum " "
    ;;  Define good rotation matrices
    gi_rot_scm2mva = [[[gi_min_evec]],[[gi_mid_evec]],[[gi_max_evec]]]
    ;;------------------------------------------------------------------------------------
    ;;  Define time-specific paramters
    ;;------------------------------------------------------------------------------------
    xa_0           = unix[tind_mnmx[0]:tind_mnmx[1]]
    xmin           = MIN(xa_0,/NAN)
    xmin_str       = time_string(xmin[0],PREC=3)
    xall           = 1d0*(xa_0 - xmin[0])
;    xall           = 1d3*(xa_0 - xmin[0])
    tra00          = minmax(xa_0)
    ;;------------------------------------------------------------------------------------
    ;;  Calculate Avg., Min., and Max. Bo [nT] during interval
    ;;------------------------------------------------------------------------------------
    ;;  Clip FGM data to current snapshot time
    bo_clip        = trange_clip_data(t_dcf_str,TRANGE=tra00,PREC=6)
    ;;  Calculate stats within
    avgb           = REPLICATE(d,n_gi[0],3L)
    minb           = avgb
    maxb           = avgb
    FOR j=0L, n_gi[0] - 1L DO BEGIN  ;;  Iterate over good MVA results
      tr00 = unix[[tt_sti[j],tt_eni[j]]]
      temp = trange_clip_data(bo_clip,TRANGE=tr00,PREC=6)
      test = (SIZE(temp,/TYPE) NE 8)
      IF (test[0]) THEN BEGIN
        tr01 = tr00 + [-1,1]*speri_bo[0]
        temp = trange_clip_data(bo_clip,TRANGE=tr01,PREC=6)
        test = (SIZE(temp,/TYPE) NE 8)
        IF (test[0]) THEN CONTINUE  ;;  No FGM data within extended SI
      ENDIF
      ;;  Calculate <Bo> [nT, ICB]
      avgx = MEAN(temp.Y[*,0],/NAN)
      avgy = MEAN(temp.Y[*,1],/NAN)
      avgz = MEAN(temp.Y[*,2],/NAN)
      avgb[j,*] = [avgx[0],avgy[0],avgz[0]]
      ;;  Caclulate Min/Max of Bo [nT, ICB]
      minb[j,*] = MIN(temp.Y,/NAN,DIMENSION=1)
      maxb[j,*] = MAX(temp.Y,/NAN,DIMENSION=1)
    ENDFOR
    ;;------------------------------------------------------------------------------------
    ;;  Calculate angle between Bo and minimum variance eigenvector (or theta_kB)
    ;;------------------------------------------------------------------------------------
    k_uvec         = unit_vec(gi_min_evec)
    test           = (N_ELEMENTS(bavg_up) EQ 6) AND is_a_number(bavg_up,/NOMSSG)
    IF (test[0]) THEN BEGIN
      ones           = [-1,0,1]
      bu_avg         = REPLICATE(d,3L,3L)
      k_d_bu         = REPLICATE(d,n_gi[0],3L)
      FOR jj=0L, 2L DO BEGIN
        tempb  = unit_vec(REFORM(bavg_up[*,0] + ones[jj]*ABS(bavg_up[*,1])))
        bu_avg[*,jj] = tempb
        k_d_bu[*,jj] = my_dot_prod(k_uvec,tempb,/NOM)
      ENDFOR
      the_kB_avg0    = MEAN(ACOS(k_d_bu)*18d1/!DPI,/NAN,DIMENSION=2)
      b_avgu         = REPLICATE(1d0,n_gi[0]) # REFORM(unit_vec(bavg_up[*,0]))
    ENDIF ELSE BEGIN
      b_avgu         = unit_vec(avgb)
      k_d_Bavg       = my_dot_prod(k_uvec,b_avgu,/NOM)
      the_kB_avg0    = ACOS(k_d_Bavg)*18d1/!DPI
    ENDELSE
    ;;------------------------------------------------------------------------------------
    ;;  Calculate angle between Nsh and minimum variance eigenvector (or theta_kn)
    ;;------------------------------------------------------------------------------------
    test           = (N_ELEMENTS(sh_norm) EQ 6) AND is_a_number(sh_norm,/NOMSSG)
    IF (test[0]) THEN BEGIN
      ones           = [-1,0,1]
      nu_avg         = REPLICATE(d,3L,3L)
      k_d_nu         = REPLICATE(d,n_gi[0],3L)
      FOR jj=0L, 2L DO BEGIN
        tempn  = unit_vec(REFORM(sh_norm[*,0] + ones[jj]*ABS(sh_norm[*,1])))
        nu_avg[*,jj] = tempn
        k_d_nu[*,jj] = my_dot_prod(k_uvec,tempn,/NOM)
      ENDFOR
      the_kn_avg0    = MEAN(ACOS(k_d_nu)*18d1/!DPI,/NAN,DIMENSION=2)
    ENDIF ELSE BEGIN
      the_kn_avg0    = REPLICATE(d,n_gi[0])
    ENDELSE
    ;;------------------------------------------------------------------------------------
    ;;  Bandpass filter data
    ;;    Order (i.e., filter first or rotate first) doesn't seem to matter much...
    ;;      --> only filter once [faster]
    ;;------------------------------------------------------------------------------------
    filt_v0        = clip_acf.Y
    px             = 0d0
    py             = 0d0
    right_handed   = REPLICATE(0b,n_gi[0])      ;;  Check handedness of each interval
    filt_amp       = REPLICATE(0d0,n_gi[0],5)   ;;  Amplitude [pk-pk, nT] {Min., Mid., Max., |∂B|, All}
    FOR jj=0L, n_gi[0] - 1L DO BEGIN  ;;  Iterate over good MVA results
      ;;  Rotate entire array of 3-vectors from ICB to MVA
      filt_vr   = REFORM(REFORM(gi_rot_scm2mva[jj,*,*]) ## filt_v0)
      ;;  Limit range of 3-vectors to specific SI and TW
      vrt       = filt_vr[tt_sti[jj]:tt_eni[jj],*]
      ;;  Remove offsets
      avgx = MEAN(vrt[*,0],/NAN)
      avgy = MEAN(vrt[*,1],/NAN)
      avgz = MEAN(vrt[*,2],/NAN)
      IF (FINITE(avgx[0])) THEN vrt[*,0] -= avgx[0]
      IF (FINITE(avgy[0])) THEN vrt[*,1] -= avgy[0]
      IF (FINITE(avgz[0])) THEN vrt[*,2] -= avgz[0]
      ;;  Determine wave amplitudes [nT]
      FOR cc=0L, 2L DO BEGIN
        ;;  Get component pk-pk amplitudes
        good_neg      = WHERE(vrt[*,cc] LT 0,gd_neg,COMPLEMENT=bad_neg,NCOMPLEMENT=bd_neg)
        IF (gd_neg[0] GT 0) THEN abs_neg = ABS(vrt[good_neg,cc]) ELSE abs_neg = [0d0]
        IF (bd_neg[0] GT 0) THEN abs_pos = ABS(vrt[bad_neg,cc])  ELSE abs_pos = [0d0]
        filt_amp[jj,cc] = MAX(abs_neg,/NAN) + MAX(abs_pos,/NAN)
      ENDFOR
      mgvrt     = mag__vec(vrt,/NAN)
      filt_amp[jj,3L] = MAX(ABS(mgvrt),/NAN)
      filt_amp[jj,4L] = MAX(ABS(filt_amp[jj,0L:2L]),/NAN)
      ;;----------------------------------------------------------------------------------
      ;;  Determine wave polarization
      ;;----------------------------------------------------------------------------------
      ;;  Define vertices of curve
      vt        = vrt[*,1:2]
      ;;  Define "origin" about which to calculate the winding number
      ;;    *** addresses issues if offsets are present ***
      px        = MEDIAN(vt[*,0])
      py        = MEDIAN(vt[*,1])
      phi_0     = (ATAN(vt[*,1],vt[*,0])*18d1/!DPI + 36d1) MOD 36d1
      ;;  Define Zi = (V_i x V_i+1)
      ;;    <Z>  >  0  :  average counterclockwise rotation
      ;;    <Z>  <  0  :  average clockwise rotation
      ;;    <Z>  ~  0  :  no average rotation  -->  bad(?)/scatter
      nn        = N_ELEMENTS(phi_0)
      upp       = nn[0] - 1L
      x         = LINDGEN(upp[0])
      y         = x + 1L
      z         = REPLICATE(0d0,nn[0])
      ut        = vt/(SQRT(vt[*,0]^2 + vt[*,1]^2) # REPLICATE(1d0,2L))
      z[1:upp[0]] = ut[x,0]*ut[y,1] - ut[x,1]*ut[y,0]
;      z[1:upp[0]] = vt[x,0]*vt[y,1] - vt[x,1]*vt[y,0]
      avgz      = MEAN(z,/NAN)
;      test_z    = (ABS(avgz[0]) GT 1d-2)
;      test_z    = (ABS(avgz[0]) GT 5d-2)
      test_z    = (ABS(avgz[0]) GT 1d-1)
;      test_z    = (ABS(avgz[0]) GT 2d-1)
      ;;  Define wave normal angle [deg]
      theta     = the_kB_avg0[jj]
      ;;  Calculate the winding number of the vectors about the origin
      test      = poly_winding_number2d(px,py,vt)
      rhand0    = ((test[0] GT 0) AND (theta LT 9d1))
      rhand1    = ((test[0] LT 0) AND (theta GT 9d1))
      rhand     = rhand0 OR rhand1
      right_handed[jj] = rhand[0]
      ;;  Save rotated data to prevent redundant calls later
      str_element,flit_vr_vt_str,gi_tags[jj],vrt,/ADD_REPLACE
      str_element,average_z,gi_tags[jj],avgz[0],/ADD_REPLACE
      IF (test_z[0]) THEN BEGIN
        str_element,good_int,gi_tags[jj],1b,/ADD_REPLACE
      ENDIF ELSE BEGIN
        ;;  Not a plane polarized wave --> just scattered points so do not keep
;        str_element,flit_vr_vt_str,gi_tags[jj],0,/ADD_REPLACE
        str_element,good_int,gi_tags[jj],0b,/ADD_REPLACE
;        right_handed[jj] = 0
;        the_kB_avg0[jj]  = d
;        filt_amp[jj,*]   = d
;      ENDIF
      ENDELSE
    ENDFOR
    ;;------------------------------------------------------------------------------------
    ;;  Plot time series snapshots
    ;;------------------------------------------------------------------------------------
    ;;  Define plot-specific variables
    nplots         = CEIL(1d0*n_gi[0]/npl_max[0]) > 1              ;;  # of plots to output of time series
    ncols          = 2L                                            ;;  # of columns per plot output of time series
    nrows          = CEIL((1d0*n_gi[0] + nplots[0])/2L/nplots[0])  ;;  # of rows " "
    upmax          = (n_gi[0] - 1L)                                ;;  total # of good MVA results to show
    IF (ncols[0]*nrows[0] LT (n_gi[0] + 1L)/nplots[0]) THEN nrows += 1L
    ;;------------------------------------------------------------------------------------
    ;;  Define outputs for plot titles and file names
    ;;------------------------------------------------------------------------------------
    ;;  Plot title stuff
    ttle0          = 'Time Start: '+xmin_str[0]+' UT, N_INT: '+num2int_str(n_int[0])
    sub_tpre       = 'Sub. #: '+num2int_str(gi_sub)
    win_tpre       = ', Win. #: '+num2int_str(gi_win)
    nvi_tpre       = ', # Vec.: '+num2int_str(nv_int)
    gi_d2n_evst    = 'R_d2n = '+STRTRIM(STRING(gi_d2n_eval,FORMAT='(f15.2)'),2L)
    gi_x2d_evst    = 'R_x2d = '+STRTRIM(STRING(gi_x2d_eval,FORMAT='(f15.2)'),2L)
    eirat_suff     = gi_d2n_evst+', '+gi_x2d_evst
    theta_string   = ', Theta: '+STRTRIM(STRING(the_kB_avg0,FORMAT='(f15.1)'),2L)+' deg'
    ;;  File name stuff
    fnm            = file_name_times(tra00,PREC=3L)
    pspref         = STRUPCASE(scpref[0])+'_'+fpref_mid[0]
    pspref         = pspref[0]+'_'+fnm.F_TIME[0]+'-'+STRMID(fnm.F_TIME[1],11L)+'_'
    psmidf         = ps_midfs_0[int[0]]+frq_strs[0]+'_'
    ;;------------------------------------------------------------------------------------
    ;;  Add to polarization output (inner) structure
    ;;------------------------------------------------------------------------------------
    yall           = filt_v0[tind_mnmx[0]:tind_mnmx[1],*]
    yran           = [-1,1]*MAX(ABS(yall),/NAN)*1.1
    ;;  Add to polarization output (inner) structure
    wavpol_str     = (['LH','RH'])[right_handed]
    struc0         = {LOGIC:right_handed,STRINGS:wavpol_str,THETA_KB:the_kB_avg0,THETA_KN:the_kn_avg0,WAV_AMP:filt_amp,GIND:good_int}
    str_element,wavpol_struc,ftags[ff[0]],struc0,/ADD_REPLACE
    ;;------------------------------------------------------------------------------------
    ;;  Define data-specific paramters
    ;;------------------------------------------------------------------------------------
    pstr_ts        = def_pstr_ts
    pstr_ex0       = {YRANGE:yran,TITLE:ttle0[0],XTITLE:xttle_ts[0]}
    extract_tags,pstr_ts,pstr_ex0
    pstr_mva_ts    = def_pstr_ts
    FOR pp=0L, nplots[0] - 1L DO BEGIN  ;;  Iterate over each time series snapshot
      !P.MULTI       = [0,ncols[0],nrows[0]]
      WSET,1
      WSHOW,1
      ;;  Plot entire subinterval
      PLOT,xall,yall[*,0],_EXTRA=pstr_ts,YTITLE=yttle_ts_icb[0]+'!C'+frq_ysub[0]
        FOR k=0L, 2L DO OPLOT,xall,yall[*,k],COLOR=([250,150,50])[k]
      lower          = pp[0]*ncols[0]*nrows[0]
      upper          = (ncols[0]*nrows[0]*(pp[0] + 1L) - 2L) < upmax[0]
      IF (lower[0] GT upmax[0]) THEN CONTINUE      ;;  Make sure indices are in order
      FOR jj=lower[0], upper[0] DO BEGIN
        ;;  Loop through time windows within subinterval and plot each
        x0        = unix[tt_sti[jj]:tt_eni[jj]]
        xx        = 1d0*(x0 - xmin[0])
;        xx        = 1d3*(x0 - xmin[0])
        yr        = flit_vr_vt_str.(jj)
        IF (N_ELEMENTS(xx) NE N_ELEMENTS(yr[*,0])) THEN CONTINUE
        ttle      = sub_tpre[jj]+win_tpre[jj]+nvi_tpre[jj]+', '+eirat_suff[jj]
        yran      = [-1,1]*MAX(ABS(yr),/NAN)*1.1
        PLOT,xx,yr[*,0],_EXTRA=pstr_mva_ts,YRANGE=yran,TITLE=ttle[0],XTITLE=xttle_ts[0],YTITLE=yttle_ts_mva[0]
          FOR k=0L, 2L DO OPLOT,xx,yr[*,k],COLOR=([250,150,50])[k]
      ENDFOR
      !P.MULTI       = 0
    ENDFOR
    ;;------------------------------------------------------------------------------------
    ;;  Save time series snapshots
    ;;------------------------------------------------------------------------------------
    str_element,pstr_ts,    'CHARSIZE',1.,/ADD_REPLACE
    str_element,pstr_mva_ts,'CHARSIZE',1.,/ADD_REPLACE
    FOR pp=0L, nplots[0] - 1L DO BEGIN  ;;  Iterate over each time series snapshot
      !P.MULTI       = [0,ncols[0],nrows[0]]
      lower          = pp[0]*ncols[0]*nrows[0]
      upper          = (ncols[0]*nrows[0]*(pp[0] + 1L) - 2L) < upmax[0]
      IF (lower[0] GT upmax[0]) THEN CONTINUE      ;;  Make sure indices are in order
      sub_strs0      = STRJOIN(num2int_str(gi_sub[lower[0]:upper[0]]),'-')
      win_strs0      = STRJOIN(num2int_str(gi_win[lower[0]:upper[0]]),'-')
      pssuff         = 'Subs_'+sub_strs0[0]+'_Wins_'+win_strs0[0]
      psnames        = pspref[0]+psmidf[0]+pssuff[0]+'_TimeSeries'
      popen,psnames[0],_EXTRA=popen_str
        !P.MULTI       = [0,ncols[0],nrows[0]]
        ;;  Plot entire subinterval
        PLOT,xall,yall[*,0],_EXTRA=pstr_ts,YTITLE=yttle_ts_icb[0]+'!C'+frq_ysub[0]
          FOR k=0L, 2L DO OPLOT,xall,yall[*,k],COLOR=([250,150,50])[k]
        FOR jj=lower[0], upper[0] DO BEGIN
          ;;  Loop through time windows within subinterval and plot each
          x0        = unix[tt_sti[jj]:tt_eni[jj]]
          xx        = 1d0*(x0 - xmin[0])
;          xx        = 1d3*(x0 - xmin[0])
          yr        = flit_vr_vt_str.(jj)
          ttle      = sub_tpre[jj]+win_tpre[jj]+nvi_tpre[jj]+', '+eirat_suff[jj]
          yran      = [-1,1]*MAX(ABS(yr),/NAN)*1.1
          IF (good_int.(jj)) THEN BEGIN
            PLOT,xx,yr[*,0],_EXTRA=pstr_mva_ts,YRANGE=yran,TITLE=ttle[0],XTITLE=xttle_ts[0],YTITLE=yttle_ts_mva[0]
              FOR k=0L, 2L DO OPLOT,xx,yr[*,k],COLOR=([250,150,50])[k]
          ENDIF ELSE BEGIN
            PLOT,xx,yr[*,0],_EXTRA=pstr_mva_ts,YRANGE=yran,TITLE=ttle[0],XTITLE=xttle_ts[0],YTITLE=yttle_ts_mva[0]
              FOR k=0L, 2L DO OPLOT,xx,yr[*,k],COLOR=([200,100,25])[k]
          ENDELSE
        ENDFOR
      pclose
      !P.MULTI       = 0
    ENDFOR
    ;;------------------------------------------------------------------------------------
    ;;  Plot hodograms of snapshots
    ;;------------------------------------------------------------------------------------
    ;;  Define total # of plots
    nplots         = CEIL(1d0*n_gi[0]/(nhd_max[0] - 1L)) > 1                  ;;  # of hodogram plots
    IF (n_gi[0] LE 3) THEN ncols = 2L ELSE ncols = 3L                         ;;  # of columns per hodogram plot
    nrows          = CEIL((1d0*n_gi[0] + nplots[0])/ncols[0]/nplots[0]) < 3L  ;;  # of rows " "
    test           = ((n_gi[0] + 1L)/nplots[0] - (ncols[0]*nrows[0])) GT 0
    IF (test[0]) THEN nplots += 1L
    IF (test[0]) THEN nrows   = 3L
    ;;  Define user symbol for dot to indicate out-of-page Bo
    rfac           = 0.27*n_gi[0]/(ncols[0]*nrows[0])
    USERSYM,rfac[0]*COS(xxo),rfac[0]*SIN(xxo),/FILL
    ;;  Define !P.MULTI string used by plotxy.pro
    multi_str      = num2int_str([ncols[0],nrows[0]])
    m_str          = multi_str[0]+' '+multi_str[1]
    ;;  Define plot margins (for hodograms)
    test           = ((n_gi[0] + 1L)/nplots[0] - (ncols[0]*nrows[0])) LT 0
    bt_mm          = 5d-1/nrows[0]/nrows[0]
    lr_mm          = 5d-1/ncols[0]/[1d1,2d1]
    IF (test[0]) THEN lr_mm *= 2L
    xmargin        = [lr_mm[0],lr_mm[1]]            ;;  [ l, r ]
    ymargin        = ([bt_mm[0],bt_mm[0]]*4) < 0.1  ;;  [ b, t ]
    mmargin        = REPLICATE(4d-2,4)              ;;  order = [ b, l, t, r ]
    mmargin[1]    += 3d-2
    mmargin[3]    -= 3d-2
    mmargin[[0,2]] -= 2d-2
    ;;  Define plot limits structures (for hodograms)
    pstr_mva_hd    = pstr_xy
    pstr1_ex       = {XMARGIN:xmargin,YMARGIN:ymargin}
    extract_tags,pstr_mva_hd,pstr1_ex
    pstr_icb_hd    = pstr_mva_hd
    ;;------------------------------------------------------------------------------------
    ;;  Clip FGM data to current snapshot time
    ;;------------------------------------------------------------------------------------
    bo_avra        = MEAN(bo_clip.Y,/NAN,DIMENSION=1)
    vt0            = REFORM(yall[*,1:2])
    yran0          = [-1,1]*MAX(ABS(vt0),/NAN)*1.1
    test_upper     = (ALOG10(yran0[1]) LT ALOG10(1d0/mult_facts))
    bad_fr         = WHERE(test_upper,bd_fr,COMPLEMENT=good_fr,NCOMPLEMENT=gd_fr)
    IF (gd_fr[0] GT 0) THEN mfact = mult_facts[MAX(good_fr)] ELSE mfact = 1d0
    IF (gd_fr[0] GT 0) THEN munit = mult_units[MAX(good_fr)] ELSE munit = mult_units[4]
    vt0           *= mfact[0]
    yran0         *= mfact[0]
    boscl0         = (0.85*yran0[1]/MAX(ABS(bo_avra[1:2]),/NAN))
    xytsuf         = ' ['+munit[0]+']'
    xyttls         = ['Ygsm','Zgsm']+xytsuf[0]
    pstr1_ex       = {XTITLE:xyttls[0],YTITLE:xyttls[1],MULTI:m_str[0],MMARGIN:mmargin}
    extract_tags,pstr_icb_hd,pstr1_ex
    chsz           = (9./(ncols[0]*nrows[0])*3./4.) < 1.
    str_element,pstr_icb_hd,'CHARSIZE',chsz[0],/ADD_REPLACE
    str_element,pstr_mva_hd,'CHARSIZE',chsz[0],/ADD_REPLACE
    ttle0          = 'Time Start: '+xmin_str[0]+' UT'
    ;;------------------------------------------------------------------------------------
    ;;  Plot hodograms
    ;;------------------------------------------------------------------------------------
    FOR pp=0L, nplots[0] - 1L DO BEGIN  ;;  Iterate over hodogram plots
      lower          = pp[0]*ncols[0]*nrows[0]
      upper          = (ncols[0]*nrows[0]*(pp[0] + 1L) - 2L) < upmax[0]
      IF (lower[0] GT upmax[0]) THEN CONTINUE
      WSET,2
      WSHOW,2
      ;;  Initialize entire window and plot entire subinterval hodogram
      plotxy,vt0,_EXTRA=pstr_icb_hd,YRANGE=yran0,XRANGE=yran0,TITLE=ttle0
      ;;  Overplot arrow of FGM data (projected onto plane)
      plotxyvec,origin,TRANSPOSE(bo_avra[1:2]),ARROWSCALE=boscl0[0],_EXTRA=pstr_v
      XYOUTS,0.35,0.97,frq_ysub[0]+', N_INT: '+num2int_str(n_int[0]),CHARSIZE=1.,/NORMAL
      xyttls         = xytpre+xytsuf[0]
      pstr1_ex       = {XTITLE:xyttls[0],YTITLE:xyttls[1]}
      extract_tags,pstr_mva_hd,pstr1_ex
      FOR jj=lower[0], upper[0] DO BEGIN  ;;  Loop through time windows within subinterval and plot each
        ;;  Rotate filtered data
        ;;  Rotate FGM data
        bo_avr    = REFORM(REFORM(gi_rot_scm2mva[jj,*,*]) ## REFORM(b_avgu[jj,*]))
        ;;  Renormalize rotated, filtered data
        vrt       = flit_vr_vt_str.(jj)
        IF (N_ELEMENTS(vrt[*,0]) LT 2) THEN CONTINUE
        vt        = vrt[*,1:2]*mfact[0]
        the       = the_kB_avg0[jj]
        test_the  = (the[0] GT 9d1)
        ;;  Define plot title, YRANGE, and Bo scale factor
        ttle      = sub_tpre[jj]+win_tpre[jj]+theta_string[jj]
        yran      = [-1,1]*MAX(ABS(vt),/NAN)*1.1
        boscl     = (0.85*yran[1]/MAX(ABS(bo_avr[1:2]),/NAN))
        ;;  Plot Max. vs. Mid. hodogram
        plotxy,vt,_EXTRA=pstr_mva_hd,YRANGE=yran,XRANGE=yran,TITLE=ttle,/ADDPANEL
        ;;  Plot unit normal direction for rotated Bo (i.e., dot for into page, cross for out of page)
        plotxy,1d-1*yran[1]*circ,/OVERPLOT,COLOR=250
        IF (~test_the[0]) THEN plotxy,origin,/OVERPLOT,COLOR=250,PSYM=8
        IF (test_the[0]) THEN plotxy,origin,/OVERPLOT,COLOR=250,PSYM=7
        ;;  Output info about handedness of data
        xwin00 = !X.CRANGE
        ywin00 = !Y.CRANGE
        xwin0  = xwin00[1]*105d-2
        ywin0  = ywin00[0] + 15d-2*ywin00[1]
        rhout  = 'Polariz. = '+(['LH','RH'])[right_handed[jj]]
        XYOUTS,xwin0[0],ywin0[0],rhout[0],/DATA,CHARSIZE=75d-2,COLOR=250,ORIENTATION=90.
        ;;  Overplot arrow of rotated FGM data (projected onto plane)
        plotxyvec,origin,TRANSPOSE(bo_avr[1:2]),ARROWSCALE=boscl[0],_EXTRA=pstr_v
      ENDFOR
      !P.MULTI       = 0
    ENDFOR
    ;;------------------------------------------------------------------------------------
    ;;  Save hodogram plots
    ;;------------------------------------------------------------------------------------
    str_element,pstr_icb_hd,'CHARSIZE',2d0*chsz[0]/3d0,/ADD_REPLACE
    str_element,pstr_mva_hd,'CHARSIZE',2d0*chsz[0]/3d0,/ADD_REPLACE
    FOR pp=0L, nplots[0] - 1L DO BEGIN  ;;  Iterate over hodogram plots
      lower          = pp[0]*ncols[0]*nrows[0]
      upper          = (ncols[0]*nrows[0]*(pp[0] + 1L) - 2L) < upmax[0]
      IF (lower[0] GT upmax[0]) THEN CONTINUE  ;;  No more plots --> skip iteration
      sub_strs0      = STRJOIN(num2int_str(gi_sub[lower[0]:upper[0]]),'-')
      win_strs0      = STRJOIN(num2int_str(gi_win[lower[0]:upper[0]]),'-')
      pssuff         = 'Subs_'+sub_strs0[0]+'_Wins_'+win_strs0[0]
      psnames        = pspref[0]+psmidf[0]+pssuff[0]+'_Hodogram_Max_vs_Mid'
      popen,psnames[0],_EXTRA=popen_hodo
        ;;  Initialize entire window and plot entire subinterval hodogram
        plotxy,vt0,_EXTRA=pstr_icb_hd,YRANGE=yran0,XRANGE=yran0,TITLE=ttle0
        ;;  Overplot arrow of FGM data (projected onto plane)
        plotxyvec,origin,TRANSPOSE(bo_avra[1:2]),ARROWSCALE=boscl0[0],_EXTRA=pstr_v
        XYOUTS,0.35,0.97,frq_ysub[0]+', N_INT: '+num2int_str(n_int[0]),CHARSIZE=1.,/NORMAL
        FOR jj=lower[0], upper[0] DO BEGIN  ;;  Loop through time windows within subinterval and plot each
          ;;  Rotate filtered data
          ;;  Rotate FGM data
          bo_avr    = REFORM(REFORM(gi_rot_scm2mva[jj,*,*]) ## REFORM(b_avgu[jj,*]))
          ;;  Renormalize rotated, filtered data
          vrt       = flit_vr_vt_str.(jj)
          the       = the_kB_avg0[jj]
          test_the  = (the[0] GT 9d1)
          ;;  Define k vector output
          kvec_out  = 'k = '+format_vector_string(REFORM(k_uvec[jj,*]),PREC=3)+' [GSE]'
          ;;  Define plot title
          ttle      = sub_tpre[jj]+win_tpre[jj]+theta_string[jj]
          ;;  Define data to plot
          vt        = vrt[*,1:2]*mfact[0]
          ;;  Define YRANGE and Bo scale factor
          yran      = [-1,1]*MAX(ABS(vt),/NAN)*1.1
          boscl     = (0.85*yran[1]/MAX(ABS(bo_avr[1:2]),/NAN))
          ;;------------------------------------------------------------------------------
          ;;  Plot Max. vs. Mid. hodogram
          ;;------------------------------------------------------------------------------
          IF (good_int.(jj)) THEN BEGIN
            ;;  Plot data
            plotxy,vt,_EXTRA=pstr_mva_hd,YRANGE=yran,XRANGE=yran,TITLE=ttle,/ADDPANEL
          ENDIF ELSE BEGIN
            ;;  Indicate "bad" with orange line
            plotxy,vt,_EXTRA=pstr_mva_hd,YRANGE=yran,XRANGE=yran,TITLE=ttle,/ADDPANEL,COLORS=200
          ENDELSE
          ;;  Plot unit normal direction for rotated Bo (i.e., dot for into page, cross for out of page)
          plotxy,1d-1*yran[1]*circ,/OVERPLOT,COLOR=250
          IF (~test_the[0]) THEN plotxy,origin,/OVERPLOT,COLOR=250,PSYM=8
          IF (test_the[0]) THEN plotxy,origin,/OVERPLOT,COLOR=250,PSYM=7
          ;;  Overplot arrow of rotated FGM data (projected onto plane)
          plotxyvec,origin,TRANSPOSE(bo_avr[1:2]),ARROWSCALE=boscl[0],_EXTRA=pstr_v
          ;;  Output the k vector
          xwin00 = !X.CRANGE
          ywin00 = !Y.CRANGE
          xwin0  = xwin00[0] + 15d-2*xwin00[1]
          ywin0  = ywin00[0] + 15d-2*ywin00[1]
          XYOUTS,xwin0[0],ywin0[0],kvec_out[0],/DATA,CHARSIZE=75d-2,COLOR=200,ORIENTATION=90.,CHARTHICK=2e0
;          ;;  Output the <z> value
;          XYOUTS,xwin0[0],ywin0[0],'<z> = '+STRING(average_z.(jj),FORMAT='(e10.2)'),/DATA,CHARSIZE=75d-2,COLOR=200,ORIENTATION=90.,CHARTHICK=2e0
          ;;  Output info about handedness of data
          xwin0  = xwin00[1]*110d-2
          ywin0  = ywin00[0] + 15d-2*ywin00[1]
          rhout  = 'Polariz. = '+(['LH','RH'])[right_handed[jj]]
          IF (jj[0] EQ upper[0]) THEN rhout = rhout[0]+';  Diamond = Start'
          XYOUTS,xwin0[0],ywin0[0],rhout[0],/DATA,CHARSIZE=75d-2,COLOR=250,ORIENTATION=90.
        ENDFOR
      pclose
      !P.MULTI       = 0
    ENDFOR
    test_output    = ((int[0] MOD 5) EQ 0) AND (ff[0] EQ 0)
    update_out     = ';;  Int: '+(num2int_str(int[0],NUM_CHAR=4,/ZERO_PAD))[0]
    update_out    += ', N_gi = '+(num2int_str(n_gi[0],NUM_CHAR=4,/ZERO_PAD))[0]
    IF (test_output[0]) THEN PRINT,update_out[0]
  ENDFOR
  ;;  Add to polarization output structure
  str_element,polarize_wav,tags[int[0]],wavpol_struc,/ADD_REPLACE
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------
;;****************************************************************************************
ex_time        = SYSTIME(1) - ex_start[0]
MESSAGE,'Execution Time: '+STRING(ex_time)+' seconds',/INFORMATIONAL,/CONTINUE
;;****************************************************************************************

RETURN
END

































