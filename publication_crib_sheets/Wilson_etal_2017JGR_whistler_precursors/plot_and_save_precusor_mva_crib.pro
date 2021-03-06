;;  plot_and_save_precusor_mva_crib.pro

;;  ***  Need to start in SPEDAS mode, not UIDL64  ***
;;  Compile relevant routines
@comp_lynn_pros
thm_init

;;----------------------------------------------------------------------------------------
;;  Coordinates and vectors
;;----------------------------------------------------------------------------------------
;;  Define some coordinate strings
coord_dsl      = 'dsl'
coord_gse      = 'gse'
coord_gsm      = 'gsm'
coord_fac      = 'fac'
coord_mag      = 'mag'
coord_gseu     = STRUPCASE(coord_gse[0])
vec_str        = ['x','y','z']
tensor_str     = ['x'+vec_str,'y'+vec_str[1:2],'zz']
fac_vec_str    = ['perp1','perp2','para']
fac_dir_str    = ['para','perp','anti']
vec_col        = [250,150, 50]
;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
start_of_day   = '00:00:00.000000'
end___of_day   = '23:59:59.999999'
def__lim       = {YSTYLE:1,PANEL_SIZE:2.,XMINOR:5,XTICKLEN:0.04,YTICKLEN:0.01}
def_dlim       = {SPEC:0,COLORS:50L,LABELS:'1',LABFLAG:2}
;;  Define save/setup stuff for TPLOT
popen_str      = {PORT:1,LANDSCAPE:0,UNITS:'inches',YSIZE:11,XSIZE:8.5}
;;  Define spacecraft-specific variables
sc             = 'Wind'
scpref         = sc[0]+'_'
;;  Define save directory
slash          = get_os_slash()           ;;  '/' for Unix, '\' for Windows
mva_dir        = slash[0]+'Users'+slash[0]+'lbwilson'+slash[0]+'Desktop'+slash[0]+$
                 'low_beta_Ma_whistlers'+slash[0]+'mva_plots'+slash[0]
FILE_MKDIR,mva_dir[0]
inst_pref      = 'mfi_'
;;  Define relevant TPLOT handles
mfi_gse_tpn    = 'Wind_B_htr_gse'
mfi_mag_tpn    = 'Wind_B_htr_mag'
mfi_filt_lp    = 'lowpass_Bo'
mfi_filt_hp    = 'highpass_Bo'
mfi_filt_dettp = 'highpass_Bo_detrended'
;;----------------------------------------------------------------------------------------
;;  Initialize and setup
;;----------------------------------------------------------------------------------------
@/Users/lbwilson/Desktop/low_beta_Ma_whistlers/crib_sheets/print_ip_shocks_whistler_stats_batch.pro
;;  Convert zoom times to Unix
start_unix     = time_double(start_times)
end___unix     = time_double(end___times)
midt__unix     = (start_unix + end___unix)/2d0
;;----------------------------------------------------------------------------------------
;;  Define time ranges to load into TPLOT
;;----------------------------------------------------------------------------------------
delt           = [-1,1]*6d0*36d2        ;;  load ±6 hours about ramp
@/Users/lbwilson/Desktop/low_beta_Ma_whistlers/crib_sheets/get_ip_shocks_whistler_ramp_times_batch.pro

all_stunix     = tura_mid + delt[0]
all_enunix     = tura_mid + delt[1]
all__trans     = [[all_stunix],[all_enunix]]
nprec          = N_ELEMENTS(tura_mid)
;;----------------------------------------------------------------------------------------
;;  Define burst and precursor intervals
;;----------------------------------------------------------------------------------------
tran_brsts     = time_string(all__trans,PREC=3)
tran__subs     = [[prec_st],[prec_en]]
;;----------------------------------------------------------------------------------------
;;  Define frequency filter range
;;----------------------------------------------------------------------------------------
fran_mods      = REPLICATE(0d0,nprec[0],2L)
fran_mods[*,0] = 1d-1         ;;  Put lower bound at 100 mHz
fran_mods[*,1] = 30d0         ;;  Put upper bound well above Nyquist frequency
special_dates  = ['1998-02-18','1999-08-23','1999-11-05','2000-02-05','2001-03-03','2006-08-19','2008-06-24','2011-02-04','2012-01-21','2013-07-12','2013-10-26','2014-04-19','2014-05-07','2014-05-29']
special_flow   = [2e-1,1e-1,1e-1,4e-1,2e-1,1e-1,2e-1,2e-1,5e-1,3e-1,3e-1,2e-1,2e-1,2e-1]
sind           = array_where(tdate_ramps,special_dates,/N_UNIQ)
sind_f         = REFORM(sind[*,0])
fran_mods[sind_f] = special_flow
;;----------------------------------------------------------------------------------------
;;  Define file name and plot stuff
;;----------------------------------------------------------------------------------------
date_in_pre0   = 'EventDate_'+tdate_ramps
date_in_pre    = 'EventDate_'+tdate_ramps+'_'
date_mid_0     = 'Event Date: '+tdate_ramps
scpref0        = sc[0]
num_ip_str     = num2int_str(nprec[0],NUM_CHAR=3,/ZERO_PAD)

fname_suff     = 'Filtered_MFI_MVA_Results.sav'
fname_prefs    = STRUPCASE(scpref[0])+date_in_pre+'_*'+fname_suff[0]             ;;  e.g., 'WIND_2015-10-16_*Filtered_MFI_MVA_Results.sav'
;;  Define tag prefixes
date_tpre      = 'DATE_'        ;;  Dates
iint_tpre      = 'INT_'         ;;  precursor time intervals for each date
fint_tpre      = 'FR_'          ;;  frequency range tags
;;  Define date and precursor interval tags
date_tags      = date_tpre[0]+tdate_ramps
prec_tags      = iint_tpre[0]+'000'
;;  Define indices relative to CfA database
good           = good_y_all0
gd             = gd_y_all[0]
ind1           = good_A
ind2           = good_A[good_y_all0]      ;;  All "good" shocks with whistlers [indices for CfA arrays]
;;  Define upstream average vectors
bvecup         = bo_gse_up[ind2,*]
d_bvecup       = ABS(asy_info_str.MAGF_GSE.DY[ind2,*,0])
nvecup         = n_gse__up[ind2,*]
d_nvecup       = ABS(bvn_info_str.SH_N_GSE.DY[ind2,*])
;;  Compile necessary routines
.compile $HOME/Desktop/low_beta_Ma_whistlers/crib_sheets/load_ip_shocks_mfi_split_magvec.pro
.compile $HOME/Desktop/low_beta_Ma_whistlers/crib_sheets/load_ip_shocks_mfi_filter.pro
.compile adaptive_mva_interval_wrapper.pro
.compile extract_good_mva_from_adapint.pro
.compile calc_and_save_mva_res_by_int.pro
.compile keep_best_mva_from_adapint.pro
.compile $HOME/Desktop/low_beta_Ma_whistlers/crib_sheets/temp_plot_and_save_autoadapt_mva_results.pro
;;  Define frequency range way outside useful range to prevent adaptive MVA routines from
;;    filtering the filtered data
def_fran__low  = 0d0
def_fran_high  = 1d2
;;  Reset variables
all___mva__res = 0             ;;  MVA_RESULTS output keyword
best_subin_res = 0             ;;  BEST_SUBINT " "
best__mva__res = 0             ;;  BEST_RESULTS " "
all_polwav_res = 0             ;;  POLARIZE_WAV " "
;FOR kk=9L, nprec[0] - 1L DO BEGIN                                                                 $
;FOR kk=11L, 20L DO BEGIN                                                                 $
;FOR kk=5L, 10L DO BEGIN                                                                 $
;FOR kk=0L, 5L DO BEGIN                                                                 $
ex_start       = SYSTIME(1)
FOR kk=0L, nprec[0] - 1L DO BEGIN                                                                 $
  flow_ww_str    = 0                                                                            & $   ;;  Reset variables
  fhig_ww_str    = 0                                                                            & $
  best_results   = 0                                                                            & $
  polarize_wav   = 0                                                                            & $
  best_subint    = 0                                                                            & $
  mva_results    = 0                                                                            & $
  tr_load        = time_double(REFORM(tran_brsts[kk,*]))                                        & $   ;;  Define time range [Unix] to load into TPLOT
  tr_ww_pred     = time_double(REFORM(tran__subs[kk,*],1,2))                                    & $   ;;  Define precursor interval time ranges [string]
  fran_int       = REFORM(fran_mods[kk,*])                                                      & $
  load_ip_shocks_mfi_filter,TRANGE=tr_load,PRECISION=prec,FREQ_RANGE=fran_int,/NO_INS_NAN       & $   ;;  Load data into TPLOT
  dc_bfield_tpn  = tnames(mfi_filt_lp[0])                                                       & $   ;;  Define DC- and AC-Coupled field TPLOT handles
  ac_bfield_tpn  = tnames(mfi_filt_dettp[0])                                                    & $   ;;  Define DC- and AC-Coupled field TPLOT handles
  test           = (dc_bfield_tpn[0] EQ '') OR (ac_bfield_tpn[0] EQ '')                         & $
  IF (test[0]) THEN str_element,all___mva__res,date_tags[kk[0]],0,/ADD_REPLACE                  & $
  IF (test[0]) THEN str_element,best_subin_res,date_tags[kk[0]],0,/ADD_REPLACE                  & $
  IF (test[0]) THEN str_element,best__mva__res,date_tags[kk[0]],0,/ADD_REPLACE                  & $
  IF (test[0]) THEN str_element,all_polwav_res,date_tags[kk[0]],0,/ADD_REPLACE                  & $
  IF (test[0]) THEN PRINT,''                                                                    & $
  IF (test[0]) THEN PRINT,date_mid_0[kk]+' --> No MVA results returned...'                      & $
  IF (test[0]) THEN PRINT,''                                                                    & $
  IF (test[0]) THEN CONTINUE                                                                    & $   ;;  Add to structures for later to save
  bavg_up        = TRANSPOSE([bvecup[kk,*],d_bvecup[kk,*]])                                     & $
  sh_norm        = TRANSPOSE([nvecup[kk,*],d_nvecup[kk,*]])                                     & $
  str_element,flow_ww_str,prec_tags[0],def_fran__low[0],/ADD_REPLACE                            & $
  str_element,fhig_ww_str,prec_tags[0],def_fran_high[0],/ADD_REPLACE                            & $
  temp_plot_and_save_autoadapt_mva_results,ac_bfield_tpn[0],dc_bfield_tpn[0],BRST_TRAN=tr_load,   $   ;;  Perform adaptive interval (AI) MVA, save results, plot results
                                   INTS_TRANGE=tr_ww_pred,FLOW_SUBINT=flow_ww_str,                $
                                   FHIGHSUBINT=fhig_ww_str,SCPREF=scpref0[0],                     $
                                   FPREF_MID=date_in_pre0[kk[0]],BEST_RESULTS=best_results,       $   ;;  Return "best" results to user
                                   BAVG_UP=bavg_up,SH_NORM=sh_norm,                               $
                                   POLARIZE_WAV=polarize_wav,BEST_SUBINT=best_subint,             $
                                   MVA_RESULTS=mva_results                                      & $
  test           = (SIZE(best_subint,/TYPE) NE 8) OR (SIZE(mva_results,/TYPE) NE 8) OR            $
                   (SIZE(best_results,/TYPE) NE 8) OR (SIZE(polarize_wav,/TYPE) NE 8)           & $   ;;  Make sure output is valid, if not --> save dummy values
  IF (test[0]) THEN str_element,all___mva__res,date_tags[kk[0]],0,/ADD_REPLACE                  & $
  IF (test[0]) THEN str_element,best_subin_res,date_tags[kk[0]],0,/ADD_REPLACE                  & $
  IF (test[0]) THEN str_element,best__mva__res,date_tags[kk[0]],0,/ADD_REPLACE                  & $
  IF (test[0]) THEN str_element,all_polwav_res,date_tags[kk[0]],0,/ADD_REPLACE                  & $
  IF (test[0]) THEN PRINT,''                                                                    & $
  IF (test[0]) THEN PRINT,date_mid_0[kk]+' --> No MVA results returned...'                      & $
  IF (test[0]) THEN PRINT,''                                                                    & $
  IF (test[0]) THEN CONTINUE                                                                    & $   ;;  Add to structures for later to save
  str_element,all___mva__res,date_tags[kk[0]], mva_results,/ADD_REPLACE                         & $
  str_element,best_subin_res,date_tags[kk[0]], best_subint,/ADD_REPLACE                         & $
  str_element,best__mva__res,date_tags[kk[0]],best_results,/ADD_REPLACE                         & $
  str_element,all_polwav_res,date_tags[kk[0]],polarize_wav,/ADD_REPLACE                         & $
  PRINT,''                                                                                      & $
  PRINT,date_mid_0[kk]+' --> finished MVA and plotting...'                                      & $
  PRINT,''
ex_time        = SYSTIME(1) - ex_start[0]
PRINT,''  & $
MESSAGE,'Execution Time: '+STRING(ex_time)+' seconds',/INFORMATIONAL,/CONTINUE  & $
PRINT,''

;;----------------------------------------------------------------------------------------
;;  Create IDL save file containing all "best" MVA results for all burst intervals
;;----------------------------------------------------------------------------------------
mva_dir        = slash[0]+'Users'+slash[0]+'lbwilson'+slash[0]+'Desktop'+slash[0]+$
                 'low_beta_Ma_whistlers'+slash[0]+'mva_sav'+slash[0]
FILE_MKDIR,mva_dir[0]
fname_suff     = 'Filtered_MFI_OnlyBest_MVA_Results.sav'
fname_out      = STRUPCASE(scpref[0])+'All_'+num_ip_str[0]+'_Precursor_Ints_'+fname_suff[0]             ;;  e.g., 'WIND_All_113_Precursor_Ints_Filtered_MFI_OnlyBest_MVA_Results.sav'
test           = (SIZE(all___mva__res,/TYPE) EQ 8) AND (SIZE(all_polwav_res,/TYPE) EQ 8)
IF (test[0]) THEN SAVE,all___mva__res,best_subin_res,best__mva__res,all_polwav_res,FILENAME=mva_dir[0]+fname_out[0]































































































