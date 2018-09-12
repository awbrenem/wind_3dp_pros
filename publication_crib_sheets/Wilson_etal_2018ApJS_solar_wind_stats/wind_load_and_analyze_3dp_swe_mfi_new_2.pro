;;  $HOME/Desktop/temp_idl/solar_wind_stats/wind_load_and_analyze_3dp_swe_mfi_new_2.pro

;;----------------------------------------------------------------------------------------
;;  Load batch file
;;----------------------------------------------------------------------------------------
ex_start       = SYSTIME(1)            ;;  Time the execution of all events within
@/Users/lbwilson/Desktop/temp_idl/solar_wind_stats/wind_load_and_analyze_3dp_swe_mfi_new_batch.pro
MESSAGE,STRING(SYSTIME(1) - ex_start[0])+' seconds execution time.',/INFORMATIONAL,/CONTINUE

HELP, in__ip_shock, out_ip_shock, in__mo_all, out_mo_all
;;  IN__IP_SHOCK    LONG      = Array[194651]
;;  OUT_IP_SHOCK    LONG      = Array[2435510]
;;  IN__MO_ALL      LONG      = Array[128109]
;;  OUT_MO_ALL      LONG      = Array[2502052]

HELP,mo_tran,bad_tra
;;  MO_TRAN         DOUBLE    = Array[170, 2]
;;  BAD_TRA         DOUBLE    = Array[239, 2]

;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Plot histograms
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------

;;----------------------------------------------------------------------------------------
;;  Plot beta_s_j ratios
;;----------------------------------------------------------------------------------------
xran           = [1d-3,1d2]
yran           = [1d0,1d5]
deltax         = 1.1d0
yttl0          = 'Number of Events'

ttle0          = 'beta_s_avg Ratios'
xttls          = ['beta_e_avg [3DP, ALL]','beta_p_avg [SWE, ALL]','beta_a_avg [SWE, ALL]','beta_e_avg [3DP, No Shocks]','beta_p_avg [SWE, No Shocks]','beta_a_avg [SWE, No Shocks]','beta_e_avg [3DP, Inside  MOs]','beta_p_avg [SWE, Inside  MOs]','beta_a_avg [SWE, Inside  MOs]','beta_e_avg [3DP, Outside MOs]','beta_p_avg [SWE, Outside MOs]','beta_a_avg [SWE, Outside MOs]']
fnames         = ['beta_e_avg_3DP_ALL','beta_p_avg_SWE_ALL','beta_a_avg_SWE_ALL','beta_e_avg_3DP_No_Shocks','beta_p_avg_SWE_No_Shocks','beta_a_avg_SWE_No_Shocks','beta_e_avg_3DP_Inside__MOs','beta_p_avg_SWE_Inside__MOs','beta_a_avg_SWE_Inside__MOs','beta_e_avg_3DP_Outside_MOs','beta_p_avg_SWE_3DP_Outside_MOs','beta_a_avg_SWE_Outside_MOs']
xdat           = CREATE_STRUCT(fnames,beta_avg_epa[*,0,1],beta_avg_epa[*,1,1],beta_avg_epa[*,2,1],beta_avg_epa[out_ip_shock,0,1],beta_avg_epa[out_ip_shock,1,1],beta_avg_epa[out_ip_shock,2,1],beta_avg_epa[in__mo_all,0,1],beta_avg_epa[in__mo_all,1,1],beta_avg_epa[in__mo_all,2,1],beta_avg_epa[out_mo_all,0,1],beta_avg_epa[out_mo_all,1,1],beta_avg_epa[out_mo_all,2,1])

ttle0          = 'beta_s_per Ratios'
xttls          = ['beta_e_per [3DP, ALL]','beta_p_per [SWE, ALL]','beta_a_per [SWE, ALL]','beta_e_per [3DP, No Shocks]','beta_p_per [SWE, No Shocks]','beta_a_per [SWE, No Shocks]','beta_e_per [3DP, Inside  MOs]','beta_p_per [SWE, Inside  MOs]','beta_a_per [SWE, Inside  MOs]','beta_e_per [3DP, Outside MOs]','beta_p_per [SWE, Outside MOs]','beta_a_per [SWE, Outside MOs]']
fnames         = ['beta_e_per_3DP_ALL','beta_p_per_SWE_ALL','beta_a_per_SWE_ALL','beta_e_per_3DP_No_Shocks','beta_p_per_SWE_No_Shocks','beta_a_per_SWE_No_Shocks','beta_e_per_3DP_Inside__MOs','beta_p_per_SWE_Inside__MOs','beta_a_per_SWE_Inside__MOs','beta_e_per_3DP_Outside_MOs','beta_p_per_SWE_3DP_Outside_MOs','beta_a_per_SWE_Outside_MOs']
xdat           = CREATE_STRUCT(fnames,beta_per_epa[*,0,1],beta_per_epa[*,1,1],beta_per_epa[*,2,1],beta_per_epa[out_ip_shock,0,1],beta_per_epa[out_ip_shock,1,1],beta_per_epa[out_ip_shock,2,1],beta_per_epa[in__mo_all,0,1],beta_per_epa[in__mo_all,1,1],beta_per_epa[in__mo_all,2,1],beta_per_epa[out_mo_all,0,1],beta_per_epa[out_mo_all,1,1],beta_per_epa[out_mo_all,2,1])

ttle0          = 'beta_s_par Ratios'
xttls          = ['beta_e_par [3DP, ALL]','beta_p_par [SWE, ALL]','beta_a_par [SWE, ALL]','beta_e_par [3DP, No Shocks]','beta_p_par [SWE, No Shocks]','beta_a_par [SWE, No Shocks]','beta_e_par [3DP, Inside  MOs]','beta_p_par [SWE, Inside  MOs]','beta_a_par [SWE, Inside  MOs]','beta_e_par [3DP, Outside MOs]','beta_p_par [SWE, Outside MOs]','beta_a_par [SWE, Outside MOs]']
fnames         = ['beta_e_par_3DP_ALL','beta_p_par_SWE_ALL','beta_a_par_SWE_ALL','beta_e_par_3DP_No_Shocks','beta_p_par_SWE_No_Shocks','beta_a_par_SWE_No_Shocks','beta_e_par_3DP_Inside__MOs','beta_p_par_SWE_Inside__MOs','beta_a_par_SWE_Inside__MOs','beta_e_par_3DP_Outside_MOs','beta_p_par_SWE_3DP_Outside_MOs','beta_a_par_SWE_Outside_MOs']
xdat           = CREATE_STRUCT(fnames,beta_par_epa[*,0,1],beta_par_epa[*,1,1],beta_par_epa[*,2,1],beta_par_epa[out_ip_shock,0,1],beta_par_epa[out_ip_shock,1,1],beta_par_epa[out_ip_shock,2,1],beta_par_epa[in__mo_all,0,1],beta_par_epa[in__mo_all,1,1],beta_par_epa[in__mo_all,2,1],beta_par_epa[out_mo_all,0,1],beta_par_epa[out_mo_all,1,1],beta_par_epa[out_mo_all,2,1])

ndat           = N_TAGS(xdat)
.compile /Users/lbwilson/Desktop/temp_idl/solar_wind_stats/temp_hist_quick_plot.pro
FOR j=0L, ndat[0] - 1L DO BEGIN                                                                          $
  xdata = xdat.(j)                                                                                     & $
  fname = 'Wind_'+fnames[j]+'_grid_times_2'                                                            & $
  xttle = xttls[j]                                                                                     & $
  temp_hist_quick_plot,xdata,XTITLE=xttle[0],YTITLE=yttl0[0],XRANGE=xran,YRANGE=yran,                    $
                             TITLE=ttle0[0],DELTAX=deltax[0],FILE_NAME=fname[0],                         $
                             WIND_N=1

;;----------------------------------------------------------------------------------------
;;  Plot (Ts1/Ts2)_j ratios
;;----------------------------------------------------------------------------------------
xran           = [1d-3,1d2]
yran           = [1d0,1d5]
deltax         = 1.1d0
yttl0          = 'Number of Events'

ttle0          = '(Ts1/Ts2)_avg Ratios'
xttls          = ['(Te/Tp)_avg [SWE, 3DP, ALL]','(Te/Ta)_avg [SWE, 3DP, ALL]','(Ta/Tp)_avg [SWE, ALL]','(Te/Tp)_avg [SWE, 3DP, No Shocks]','(Te/Ta)_avg [SWE, 3DP, No Shocks]','(Ta/Tp)_avg [SWE, No Shocks]','(Te/Tp)_avg [SWE, 3DP, Inside  MOs]','(Te/Ta)_avg [SWE, 3DP, Inside  MOs]','(Ta/Tp)_avg [SWE, Inside  MOs]','(Te/Tp)_avg [SWE, 3DP, Outside MOs]','(Te/Ta)_avg [SWE, 3DP, Outside MOs]','(Ta/Tp)_avg [SWE, Outside MOs]']
fnames         = ['Te_Tp_avg_SWE_3DP_ALL','Te_Ta_avg_SWE_3DP_ALL','Ta_Tp_avg_SWE_ALL','Te_Tp_avg_SWE_3DP_No_Shocks','Te_Ta_avg_SWE_3DP_No_Shocks','Ta_Tp_avg_SWE_No_Shocks','Te_Tp_avg_SWE_3DP_Inside__MOs','Te_Ta_avg_SWE_3DP_Inside__MOs','Ta_Tp_avg_SWE_Inside__MOs','Te_Tp_avg_SWE_3DP_Outside_MOs','Te_Ta_avg_SWE_3DP_Outside_MOs','Ta_Tp_avg_SWE_Outside_MOs']
xdat           = CREATE_STRUCT(fnames,Tr_avg_epeaap[*,0,1,1],Tr_avg_epeaap[*,1,1,1],Tr_avg_epeaap[*,2,1,1],Tr_avg_epeaap[out_ip_shock,0,1,1],Tr_avg_epeaap[out_ip_shock,1,1,1],Tr_avg_epeaap[out_ip_shock,2,1,1],Tr_avg_epeaap[in__mo_all,0,1,1],Tr_avg_epeaap[in__mo_all,1,1,1],Tr_avg_epeaap[in__mo_all,2,1,1],Tr_avg_epeaap[out_mo_all,0,1,1],Tr_avg_epeaap[out_mo_all,1,1,1],Tr_avg_epeaap[out_mo_all,2,1,1])

ttle0          = '(Ts1/Ts2)_per Ratios'
xttls          = ['(Te/Tp)_per [SWE, 3DP, ALL]','(Te/Ta)_per [SWE, 3DP, ALL]','(Ta/Tp)_per [SWE, ALL]','(Te/Tp)_per [SWE, 3DP, No Shocks]','(Te/Ta)_per [SWE, 3DP, No Shocks]','(Ta/Tp)_per [SWE, No Shocks]','(Te/Tp)_per [SWE, 3DP, Inside  MOs]','(Te/Ta)_per [SWE, 3DP, Inside  MOs]','(Ta/Tp)_per [SWE, Inside  MOs]','(Te/Tp)_per [SWE, 3DP, Outside MOs]','(Te/Ta)_per [SWE, 3DP, Outside MOs]','(Ta/Tp)_per [SWE, Outside MOs]']
fnames         = ['Te_Tp_per_SWE_3DP_ALL','Te_Ta_per_SWE_3DP_ALL','Ta_Tp_per_SWE_ALL','Te_Tp_per_SWE_3DP_No_Shocks','Te_Ta_per_SWE_3DP_No_Shocks','Ta_Tp_per_SWE_No_Shocks','Te_Tp_per_SWE_3DP_Inside__MOs','Te_Ta_per_SWE_3DP_Inside__MOs','Ta_Tp_per_SWE_Inside__MOs','Te_Tp_per_SWE_3DP_Outside_MOs','Te_Ta_per_SWE_3DP_Outside_MOs','Ta_Tp_per_SWE_Outside_MOs']
xdat           = CREATE_STRUCT(fnames,Tr_per_epeaap[*,0,1,1],Tr_per_epeaap[*,1,1,1],Tr_per_epeaap[*,2,1,1],Tr_per_epeaap[out_ip_shock,0,1,1],Tr_per_epeaap[out_ip_shock,1,1,1],Tr_per_epeaap[out_ip_shock,2,1,1],Tr_per_epeaap[in__mo_all,0,1,1],Tr_per_epeaap[in__mo_all,1,1,1],Tr_per_epeaap[in__mo_all,2,1,1],Tr_per_epeaap[out_mo_all,0,1,1],Tr_per_epeaap[out_mo_all,1,1,1],Tr_per_epeaap[out_mo_all,2,1,1])

ttle0          = '(Ts1/Ts2)_par Ratios'
xttls          = ['(Te/Tp)_par [SWE, 3DP, ALL]','(Te/Ta)_par [SWE, 3DP, ALL]','(Ta/Tp)_par [SWE, ALL]','(Te/Tp)_par [SWE, 3DP, No Shocks]','(Te/Ta)_par [SWE, 3DP, No Shocks]','(Ta/Tp)_par [SWE, No Shocks]','(Te/Tp)_par [SWE, 3DP, Inside  MOs]','(Te/Ta)_par [SWE, 3DP, Inside  MOs]','(Ta/Tp)_par [SWE, Inside  MOs]','(Te/Tp)_par [SWE, 3DP, Outside MOs]','(Te/Ta)_par [SWE, 3DP, Outside MOs]','(Ta/Tp)_par [SWE, Outside MOs]']
fnames         = ['Te_Tp_par_SWE_3DP_ALL','Te_Ta_par_SWE_3DP_ALL','Ta_Tp_par_SWE_ALL','Te_Tp_par_SWE_3DP_No_Shocks','Te_Ta_par_SWE_3DP_No_Shocks','Ta_Tp_par_SWE_No_Shocks','Te_Tp_par_SWE_3DP_Inside__MOs','Te_Ta_par_SWE_3DP_Inside__MOs','Ta_Tp_par_SWE_Inside__MOs','Te_Tp_par_SWE_3DP_Outside_MOs','Te_Ta_par_SWE_3DP_Outside_MOs','Ta_Tp_par_SWE_Outside_MOs']
xdat           = CREATE_STRUCT(fnames,Tr_par_epeaap[*,0,1,1],Tr_par_epeaap[*,1,1,1],Tr_par_epeaap[*,2,1,1],Tr_par_epeaap[out_ip_shock,0,1,1],Tr_par_epeaap[out_ip_shock,1,1,1],Tr_par_epeaap[out_ip_shock,2,1,1],Tr_par_epeaap[in__mo_all,0,1,1],Tr_par_epeaap[in__mo_all,1,1,1],Tr_par_epeaap[in__mo_all,2,1,1],Tr_par_epeaap[out_mo_all,0,1,1],Tr_par_epeaap[out_mo_all,1,1,1],Tr_par_epeaap[out_mo_all,2,1,1])

ndat           = N_TAGS(xdat)
.compile /Users/lbwilson/Desktop/temp_idl/solar_wind_stats/temp_hist_quick_plot.pro
FOR j=0L, ndat[0] - 1L DO BEGIN                                                                          $
  xdata = xdat.(j)                                                                                     & $
  fname = 'Wind_'+fnames[j]+'_grid_times_2'                                                            & $
  xttle = xttls[j]                                                                                     & $
  temp_hist_quick_plot,xdata,XTITLE=xttle[0],YTITLE=yttl0[0],XRANGE=xran,YRANGE=yran,                    $
                             TITLE=ttle0[0],DELTAX=deltax[0],FILE_NAME=fname[0],                         $
                             WIND_N=1


;;----------------------------------------------------------------------------------------
;;  Plot (Ts1/Ts2)_j ratios [2nd XRANGE]
;;----------------------------------------------------------------------------------------
xran           = [1d-2,1d2]
yran           = [1d0,1d5]
deltax         = 1.1d0
yttl0          = 'Number of Events'

ttle0          = '(Ts1/Ts2)_avg Ratios'
xttls          = ['(Te/Tp)_avg [SWE, 3DP, ALL]','(Te/Ta)_avg [SWE, 3DP, ALL]','(Ta/Tp)_avg [SWE, ALL]','(Te/Tp)_avg [SWE, 3DP, No Shocks]','(Te/Ta)_avg [SWE, 3DP, No Shocks]','(Ta/Tp)_avg [SWE, No Shocks]','(Te/Tp)_avg [SWE, 3DP, Inside  MOs]','(Te/Ta)_avg [SWE, 3DP, Inside  MOs]','(Ta/Tp)_avg [SWE, Inside  MOs]','(Te/Tp)_avg [SWE, 3DP, Outside MOs]','(Te/Ta)_avg [SWE, 3DP, Outside MOs]','(Ta/Tp)_avg [SWE, Outside MOs]']
fnames         = ['Te_Tp_avg_SWE_3DP_ALL','Te_Ta_avg_SWE_3DP_ALL','Ta_Tp_avg_SWE_ALL','Te_Tp_avg_SWE_3DP_No_Shocks','Te_Ta_avg_SWE_3DP_No_Shocks','Ta_Tp_avg_SWE_No_Shocks','Te_Tp_avg_SWE_3DP_Inside__MOs','Te_Ta_avg_SWE_3DP_Inside__MOs','Ta_Tp_avg_SWE_Inside__MOs','Te_Tp_avg_SWE_3DP_Outside_MOs','Te_Ta_avg_SWE_3DP_Outside_MOs','Ta_Tp_avg_SWE_Outside_MOs']
xdat           = CREATE_STRUCT(fnames,Tr_avg_epeaap[*,0,1,1],Tr_avg_epeaap[*,1,1,1],Tr_avg_epeaap[*,2,1,1],Tr_avg_epeaap[out_ip_shock,0,1,1],Tr_avg_epeaap[out_ip_shock,1,1,1],Tr_avg_epeaap[out_ip_shock,2,1,1],Tr_avg_epeaap[in__mo_all,0,1,1],Tr_avg_epeaap[in__mo_all,1,1,1],Tr_avg_epeaap[in__mo_all,2,1,1],Tr_avg_epeaap[out_mo_all,0,1,1],Tr_avg_epeaap[out_mo_all,1,1,1],Tr_avg_epeaap[out_mo_all,2,1,1])

ttle0          = '(Ts1/Ts2)_per Ratios'
xttls          = ['(Te/Tp)_per [SWE, 3DP, ALL]','(Te/Ta)_per [SWE, 3DP, ALL]','(Ta/Tp)_per [SWE, ALL]','(Te/Tp)_per [SWE, 3DP, No Shocks]','(Te/Ta)_per [SWE, 3DP, No Shocks]','(Ta/Tp)_per [SWE, No Shocks]','(Te/Tp)_per [SWE, 3DP, Inside  MOs]','(Te/Ta)_per [SWE, 3DP, Inside  MOs]','(Ta/Tp)_per [SWE, Inside  MOs]','(Te/Tp)_per [SWE, 3DP, Outside MOs]','(Te/Ta)_per [SWE, 3DP, Outside MOs]','(Ta/Tp)_per [SWE, Outside MOs]']
fnames         = ['Te_Tp_per_SWE_3DP_ALL','Te_Ta_per_SWE_3DP_ALL','Ta_Tp_per_SWE_ALL','Te_Tp_per_SWE_3DP_No_Shocks','Te_Ta_per_SWE_3DP_No_Shocks','Ta_Tp_per_SWE_No_Shocks','Te_Tp_per_SWE_3DP_Inside__MOs','Te_Ta_per_SWE_3DP_Inside__MOs','Ta_Tp_per_SWE_Inside__MOs','Te_Tp_per_SWE_3DP_Outside_MOs','Te_Ta_per_SWE_3DP_Outside_MOs','Ta_Tp_per_SWE_Outside_MOs']
xdat           = CREATE_STRUCT(fnames,Tr_per_epeaap[*,0,1,1],Tr_per_epeaap[*,1,1,1],Tr_per_epeaap[*,2,1,1],Tr_per_epeaap[out_ip_shock,0,1,1],Tr_per_epeaap[out_ip_shock,1,1,1],Tr_per_epeaap[out_ip_shock,2,1,1],Tr_per_epeaap[in__mo_all,0,1,1],Tr_per_epeaap[in__mo_all,1,1,1],Tr_per_epeaap[in__mo_all,2,1,1],Tr_per_epeaap[out_mo_all,0,1,1],Tr_per_epeaap[out_mo_all,1,1,1],Tr_per_epeaap[out_mo_all,2,1,1])

ttle0          = '(Ts1/Ts2)_par Ratios'
xttls          = ['(Te/Tp)_par [SWE, 3DP, ALL]','(Te/Ta)_par [SWE, 3DP, ALL]','(Ta/Tp)_par [SWE, ALL]','(Te/Tp)_par [SWE, 3DP, No Shocks]','(Te/Ta)_par [SWE, 3DP, No Shocks]','(Ta/Tp)_par [SWE, No Shocks]','(Te/Tp)_par [SWE, 3DP, Inside  MOs]','(Te/Ta)_par [SWE, 3DP, Inside  MOs]','(Ta/Tp)_par [SWE, Inside  MOs]','(Te/Tp)_par [SWE, 3DP, Outside MOs]','(Te/Ta)_par [SWE, 3DP, Outside MOs]','(Ta/Tp)_par [SWE, Outside MOs]']
fnames         = ['Te_Tp_par_SWE_3DP_ALL','Te_Ta_par_SWE_3DP_ALL','Ta_Tp_par_SWE_ALL','Te_Tp_par_SWE_3DP_No_Shocks','Te_Ta_par_SWE_3DP_No_Shocks','Ta_Tp_par_SWE_No_Shocks','Te_Tp_par_SWE_3DP_Inside__MOs','Te_Ta_par_SWE_3DP_Inside__MOs','Ta_Tp_par_SWE_Inside__MOs','Te_Tp_par_SWE_3DP_Outside_MOs','Te_Ta_par_SWE_3DP_Outside_MOs','Ta_Tp_par_SWE_Outside_MOs']
xdat           = CREATE_STRUCT(fnames,Tr_par_epeaap[*,0,1,1],Tr_par_epeaap[*,1,1,1],Tr_par_epeaap[*,2,1,1],Tr_par_epeaap[out_ip_shock,0,1,1],Tr_par_epeaap[out_ip_shock,1,1,1],Tr_par_epeaap[out_ip_shock,2,1,1],Tr_par_epeaap[in__mo_all,0,1,1],Tr_par_epeaap[in__mo_all,1,1,1],Tr_par_epeaap[in__mo_all,2,1,1],Tr_par_epeaap[out_mo_all,0,1,1],Tr_par_epeaap[out_mo_all,1,1,1],Tr_par_epeaap[out_mo_all,2,1,1])

ndat           = N_TAGS(xdat)
.compile /Users/lbwilson/Desktop/temp_idl/solar_wind_stats/temp_hist_quick_plot.pro
FOR j=0L, ndat[0] - 1L DO BEGIN                                                                          $
  xdata = xdat.(j)                                                                                     & $
  fname = 'Wind_'+fnames[j]+'_grid_times_2_2nd-xrange'                                                 & $
  xttle = xttls[j]                                                                                     & $
  temp_hist_quick_plot,xdata,XTITLE=xttle[0],YTITLE=yttl0[0],XRANGE=xran,YRANGE=yran,                    $
                             TITLE=ttle0[0],DELTAX=deltax[0],FILE_NAME=fname[0],                         $
                             WIND_N=1



;;----------------------------------------------------------------------------------------
;;  Plot (Ts)_j [eV]
;;----------------------------------------------------------------------------------------
xran           = [1d-1,5d2]
yran           = [1d0,2d5]
deltax         = 1.1d0
yttl0          = 'Number of Events'

ttle0          = 'T_s,avg Histograms'
xttls          = ['Te_avg [SWE, 3DP, ALL, eV]','Tp_avg [SWE, 3DP, ALL, eV]','Ta_avg [SWE, 3DP, ALL, eV]','Te_avg [SWE, 3DP, No Shocks, eV]','Tp_avg [SWE, 3DP, No Shocks, eV]','Ta_avg [SWE, 3DP, No Shocks, eV]','Te_avg [SWE, 3DP, Inside  MOs, eV]','Tp_avg [SWE, 3DP, Inside  MOs, eV]','Ta_avg [SWE, 3DP, Inside  MOs, eV]','Te_avg [SWE, 3DP, Outside MOs, eV]','Tp_avg [SWE, 3DP, Outside MOs, eV]','Ta_avg [SWE, 3DP, Outside MOs, eV]']
fnames         = ['Te_avg_SWE_3DP_ALL','Tp_avg_SWE_3DP_ALL','Ta_avg_SWE_3DP_ALL','Te_avg_SWE_3DP_No_Shocks','Tp_avg_SWE_3DP_No_Shocks','Ta_avg_SWE_3DP_No_Shocks','Te_avg_SWE_3DP_Inside__MOs','Tp_avg_SWE_3DP_Inside__MOs','Ta_avg_SWE_3DP_Inside__MOs','Te_avg_SWE_3DP_Outside_MOs','Tp_avg_SWE_3DP_Outside_MOs','Ta_avg_SWE_3DP_Outside_MOs']
xdat           = CREATE_STRUCT(fnames,gtavg_epa[*,0,1],gtavg_epa[*,1,1],gtavg_epa[*,2,1],gtavg_epa[out_ip_shock,0,1],gtavg_epa[out_ip_shock,1,1],gtavg_epa[out_ip_shock,2,1],gtavg_epa[in__mo_all,0,1],gtavg_epa[in__mo_all,1,1],gtavg_epa[in__mo_all,2,1],gtavg_epa[out_mo_all,0,1],gtavg_epa[out_mo_all,1,1],gtavg_epa[out_mo_all,2,1])

ttle0          = 'T_s,per Histograms'
xttls          = ['Te_per [SWE, 3DP, ALL, eV]','Tp_per [SWE, 3DP, ALL, eV]','Ta_per [SWE, 3DP, ALL, eV]','Te_per [SWE, 3DP, No Shocks, eV]','Tp_per [SWE, 3DP, No Shocks, eV]','Ta_per [SWE, 3DP, No Shocks, eV]','Te_per [SWE, 3DP, Inside  MOs, eV]','Tp_per [SWE, 3DP, Inside  MOs, eV]','Ta_per [SWE, 3DP, Inside  MOs, eV]','Te_per [SWE, 3DP, Outside MOs, eV]','Tp_per [SWE, 3DP, Outside MOs, eV]','Ta_per [SWE, 3DP, Outside MOs, eV]']
fnames         = ['Te_per_SWE_3DP_ALL','Tp_per_SWE_3DP_ALL','Ta_per_SWE_3DP_ALL','Te_per_SWE_3DP_No_Shocks','Tp_per_SWE_3DP_No_Shocks','Ta_per_SWE_3DP_No_Shocks','Te_per_SWE_3DP_Inside__MOs','Tp_per_SWE_3DP_Inside__MOs','Ta_per_SWE_3DP_Inside__MOs','Te_per_SWE_3DP_Outside_MOs','Tp_per_SWE_3DP_Outside_MOs','Ta_per_SWE_3DP_Outside_MOs']
xdat           = CREATE_STRUCT(fnames,gtper_epa[*,0,1],gtper_epa[*,1,1],gtper_epa[*,2,1],gtper_epa[out_ip_shock,0,1],gtper_epa[out_ip_shock,1,1],gtper_epa[out_ip_shock,2,1],gtper_epa[in__mo_all,0,1],gtper_epa[in__mo_all,1,1],gtper_epa[in__mo_all,2,1],gtper_epa[out_mo_all,0,1],gtper_epa[out_mo_all,1,1],gtper_epa[out_mo_all,2,1])

ttle0          = 'T_s,par Histograms'
xttls          = ['Te_par [SWE, 3DP, ALL, eV]','Tp_par [SWE, 3DP, ALL, eV]','Ta_par [SWE, 3DP, ALL, eV]','Te_par [SWE, 3DP, No Shocks, eV]','Tp_par [SWE, 3DP, No Shocks, eV]','Ta_par [SWE, 3DP, No Shocks, eV]','Te_par [SWE, 3DP, Inside  MOs, eV]','Tp_par [SWE, 3DP, Inside  MOs, eV]','Ta_par [SWE, 3DP, Inside  MOs, eV]','Te_par [SWE, 3DP, Outside MOs, eV]','Tp_par [SWE, 3DP, Outside MOs, eV]','Ta_par [SWE, 3DP, Outside MOs, eV]']
fnames         = ['Te_par_SWE_3DP_ALL','Tp_par_SWE_3DP_ALL','Ta_par_SWE_3DP_ALL','Te_par_SWE_3DP_No_Shocks','Tp_par_SWE_3DP_No_Shocks','Ta_par_SWE_3DP_No_Shocks','Te_par_SWE_3DP_Inside__MOs','Tp_par_SWE_3DP_Inside__MOs','Ta_par_SWE_3DP_Inside__MOs','Te_par_SWE_3DP_Outside_MOs','Tp_par_SWE_3DP_Outside_MOs','Ta_par_SWE_3DP_Outside_MOs']
xdat           = CREATE_STRUCT(fnames,gtpar_epa[*,0,1],gtpar_epa[*,1,1],gtpar_epa[*,2,1],gtpar_epa[out_ip_shock,0,1],gtpar_epa[out_ip_shock,1,1],gtpar_epa[out_ip_shock,2,1],gtpar_epa[in__mo_all,0,1],gtpar_epa[in__mo_all,1,1],gtpar_epa[in__mo_all,2,1],gtpar_epa[out_mo_all,0,1],gtpar_epa[out_mo_all,1,1],gtpar_epa[out_mo_all,2,1])

ndat           = N_TAGS(xdat)
.compile /Users/lbwilson/Desktop/temp_idl/solar_wind_stats/temp_hist_quick_plot.pro
FOR j=0L, ndat[0] - 1L DO BEGIN                                                                          $
  xdata = xdat.(j)                                                                                     & $
  fname = 'Wind_'+fnames[j]+'_grid_times_2'                                                            & $
  xttle = xttls[j]                                                                                     & $
  temp_hist_quick_plot,xdata,XTITLE=xttle[0],YTITLE=yttl0[0],XRANGE=xran,YRANGE=yran,                    $
                             TITLE=ttle0[0],DELTAX=deltax[0],FILE_NAME=fname[0],                         $
                             WIND_N=1








