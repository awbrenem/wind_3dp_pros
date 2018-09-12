;;  @/Users/lbwilson/Desktop/low_beta_Ma_whistlers/crib_sheets/print_latex_table_stats_new_crib.pro

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
vec_str        = ['x','y','z']
vec_col        = [250,150,50]
def__lim       = {YSTYLE:1,PANEL_SIZE:2.,XMINOR:5,XTICKLEN:0.04,YTICKLEN:0.01}
def_dlim       = {SPEC:0,COLORS:50L,LABELS:'1',LABFLAG:2}
;;  Define save/setup stuff for TPLOT
popen_str      = {PORT:1,LANDSCAPE:0,UNITS:'inches',YSIZE:11,XSIZE:8.5}
;;  Define save directory
sav_dir        = slash[0]+'Users'+slash[0]+'lbwilson'+slash[0]+'Desktop'+slash[0]+$
                 'low_beta_Ma_whistlers'+slash[0]+'idl_save_files'+slash[0]
inst_pref      = 'mfi_'
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
delt           = [-1,1]*1d0*36d2        ;;  load ±1 hour about ramp
@/Users/lbwilson/Desktop/low_beta_Ma_whistlers/crib_sheets/get_ip_shocks_whistler_ramp_times_batch.pro

all_stunix     = tura_mid + delt[0]
all_enunix     = tura_mid + delt[1]
all__trans     = [[all_stunix],[all_enunix]]
;;  Look at only events with definite whistlers
good           = good_y_all0
gd             = gd_y_all[0]
ind1           = good_A
ind2           = good_A[good_y_all0]      ;;  All "good" shocks with whistlers [indices for CfA arrays]
ny             = N_ELEMENTS(ind1)
nz             = N_ELEMENTS(ind2)
;;  Define relevant uncertainties
d_ni_avg_up    = ABS(asy_info_str.DENS_ION.DY[*,0])
d_bo_gse_up    = ABS(asy_info_str.MAGF_GSE.DY[*,*,0])
d_vshn___up    = ABS(key_info_str.VSHN_UP.DY)
;;  Need to estimate ∂|Bo|...
d_bo_mag_up    = SQRT((bo_gse_up[*,0]*d_bo_gse_up[*,0])^2 + (bo_gse_up[*,1]*d_bo_gse_up[*,1])^2 + (bo_gse_up[*,2]*d_bo_gse_up[*,2])^2)/bo_mag_up
;;----------------------------------------------------------------------------------------
;;  Define requirements/tests for all quasi-perp. shocks
;;----------------------------------------------------------------------------------------
test_0a        = (ABS(Mfast__up) GE 1e0) AND (ABS(M_VA___up) GE 1e0) AND (ABS(N2_N1__up) GE 1e0)
test_1a        = (ABS(thetbn_up) GE 45e0)
test_1b        = (ABS(thetbn_up) LT 45e0)
good_qperp     = WHERE(test_0a AND test_1a,gd_qperp)
good_qpara     = WHERE(test_0a AND test_1b,gd_qpara)
n_all_cfa      = N_ELEMENTS(Mfast__up)
PRINT,';;  ',n_all_cfa[0],gd_qperp[0],gd_qpara[0]
;;           430         250          83

;;  Since the CfA database uses the following:
;;    Wi^2  = kB Ti/Mi
;;    Cs^2  = (5/3)*Wi^2
;;    ß     = (3/5)*Cs^2/V_A^2
;;  let use try a more stringent criteria for "low beta" of (2ß ≤ 1)
test_0         = (ABS(Mfast__up) GE 1e0) AND (ABS(M_VA___up) GE 1e0) AND (ABS(N2_N1__up) GE 1e0)
test_1         = (ABS(N2_N1__up) LE 3e0) AND (ABS(thetbn_up) GE 45e0)
test2A         = (ABS(2d0*beta_t_up) LE 1e0) AND (ABS(M_VA___up) LE 3e0) AND test_1
good2A         = WHERE(test2A AND test_0,gd2A)
PRINT,';;  ',gd_A[0],gd2A[0],ABS(gd_A[0] - gd2A[0])
;;           145         107          38

;;  Define indices relative to CfA database arrays
ind0           = good_qperp               ;;  All quasi-perpendicular shocks
ind1           = good_A                   ;;  All "good" shocks
ind2           = good_A[good_y_all0]      ;;  All "good" shocks with whistlers
ind3           = good2A                   ;;  All "good" shocks (2ß)
;;  Check for overlaps
test_2b        = array_where(ind3,ind2,/N_UNIQ)
ind4           = ind3[test_2b[*,0]]
PRINT,';;  ',N_ELEMENTS(ind1),N_ELEMENTS(ind3),ABS(N_ELEMENTS(ind1) - N_ELEMENTS(ind3)) & $
PRINT,';;  ',N_ELEMENTS(ind2),N_ELEMENTS(ind4),ABS(N_ELEMENTS(ind2) - N_ELEMENTS(ind4))
;;           145         107          38
;;           113          88          25

;;----------------------------------------------------------------------------------------
;;  Define events where precursor extends into ramp
;;----------------------------------------------------------------------------------------
diff           = (whis_en - tura_st)
good_pinr      = WHERE(diff GT 0,gd_pinr)
PRINT,';;  ',N_ELEMENTS(ind2),gd_pinr[0],(1d2*gd_pinr[0]/N_ELEMENTS(ind2))
;;           113          35       30.973451

ind5           = ind2[good_pinr]

xx             = beta_t_up[ind5]
nx             = N_ELEMENTS(xx)
beta_up_stats  = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]
xx             = thetbn_up[ind5]
nx             = N_ELEMENTS(xx)
thbn_up_stats  = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]
xx             = Mfast__up[ind5]
nx             = N_ELEMENTS(xx)
Mf___up_stats  = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]
xx             = M_VA___up[ind5]
nx             = N_ELEMENTS(xx)
MA___up_stats  = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]
xx             = vshn___up[ind5]
nx             = N_ELEMENTS(xx)
vshn_up_stats  = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]
xx             = ushn___up[ind5]
nx             = N_ELEMENTS(xx)
ushn_up_stats  = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]
xx             = bo_mag_up[ind5]
nx             = N_ELEMENTS(xx)
bmag_up_stats  = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]
xx             = ni_avg_up[ind5]
nx             = N_ELEMENTS(xx)
dens_up_stats  = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]
xx             = SQRT(ni_avg_up[ind5])/bo_mag_up[ind5]
nx             = N_ELEMENTS(xx)
nsqb_up_stats  = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]

stat_labs      = ['Beta_up','thet_Bn','Mf___up','M_A__up','Vshn_up','Ushn_up','Bmag_up','Ni___up','NsqBo_up']
strc_stats     = CREATE_STRUCT(stat_labs,beta_up_stats,thbn_up_stats,Mf___up_stats,MA___up_stats,vshn_up_stats,ushn_up_stats,bmag_up_stats,dens_up_stats,nsqb_up_stats)
mform          = '(";;  ",a7,":  ",6e15.4)'
np             = N_ELEMENTS(stat_labs)
PRINT,';;  N = ',nx[0]
FOR kk=0L, np[0] - 1L DO BEGIN                                                                              $
  stats = strc_stats.(kk[0])                                                                              & $
  PRINT,stat_labs[kk],stats,FORMAT=mform[0]
;;------------------------------------------------------------------------------------------------------
;;  Only Shocks with Whistler Precursors extending into ramp
;;  N =           35
;;------------------------------------------------------------------------------------------------------
;;  Name              Min            Max            Avg            Med            Std            SoM
;;======================================================================================================
;;  Beta_up:       3.4000e-02     6.9200e-01     3.3231e-01     3.1900e-01     1.8474e-01     3.1227e-02
;;  thet_Bn:       4.5500e+01     8.8100e+01     6.2786e+01     6.1100e+01     1.1851e+01     2.0031e+00
;;  Mf___up:       1.0800e+00     2.5100e+00     1.6546e+00     1.6100e+00     3.9263e-01     6.6366e-02
;;  M_A__up:       1.2239e+00     2.8386e+00     2.0034e+00     2.0063e+00     5.4717e-01     9.2488e-02
;;  Vshn_up:       2.5730e+02     6.6900e+02     4.3631e+02     4.1110e+02     1.0620e+02     1.7951e+01
;;  Ushn_up:       5.2900e+01     2.7510e+02     1.0507e+02     8.3100e+01     5.0419e+01     8.5224e+00
;;  Bmag_up:       2.5140e+00     1.7345e+01     6.1867e+00     5.5045e+00     3.1627e+00     5.3460e-01
;;  Ni___up:       1.0000e+00     2.9500e+01     8.0829e+00     6.3000e+00     6.3503e+00     1.0734e+00
;;  NsqBo_u:       1.2093e-01     9.2484e-01     4.8308e-01     4.4881e-01     1.8733e-01     3.1664e-02
;;------------------------------------------------------------------------------------------------------

;;----------------------------------------------------------------------------------------
;;  Look at stats for undersampled shocks with whistlers [YU or YM]
;;----------------------------------------------------------------------------------------
ind6           = good_A[good_y_aum0]      ;;  All "good" shocks with whistlers and undersampled

xx             = beta_t_up[ind6]
nx             = N_ELEMENTS(xx)
beta_up_stats  = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]
xx             = thetbn_up[ind6]
nx             = N_ELEMENTS(xx)
thbn_up_stats  = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]
xx             = Mfast__up[ind6]
nx             = N_ELEMENTS(xx)
Mf___up_stats  = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]
xx             = M_VA___up[ind6]
nx             = N_ELEMENTS(xx)
MA___up_stats  = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]
xx             = vshn___up[ind6]
nx             = N_ELEMENTS(xx)
vshn_up_stats  = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]
xx             = ushn___up[ind6]
nx             = N_ELEMENTS(xx)
ushn_up_stats  = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]
xx             = bo_mag_up[ind6]
nx             = N_ELEMENTS(xx)
bmag_up_stats  = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]
xx             = ni_avg_up[ind6]
nx             = N_ELEMENTS(xx)
dens_up_stats  = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]
xx             = SQRT(ni_avg_up[ind6])/bo_mag_up[ind6]
nx             = N_ELEMENTS(xx)
nsqb_up_stats  = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]

stat_labs      = ['Beta_up','thet_Bn','Mf___up','M_A__up','Vshn_up','Ushn_up','Bmag_up','Ni___up','NsqBo_up']
strc_stats     = CREATE_STRUCT(stat_labs,beta_up_stats,thbn_up_stats,Mf___up_stats,MA___up_stats,vshn_up_stats,ushn_up_stats,bmag_up_stats,dens_up_stats,nsqb_up_stats)
mform          = '(";;  ",a7,":  ",6e15.4)'
np             = N_ELEMENTS(stat_labs)
PRINT,';;  N = ',nx[0]
FOR kk=0L, np[0] - 1L DO BEGIN                                                                              $
  stats = strc_stats.(kk[0])                                                                              & $
  PRINT,stat_labs[kk],stats,FORMAT=mform[0]
;;------------------------------------------------------------------------------------------------------
;;  Only Shocks with Whistler Precursors that are undersampled [YU or YM]
;;  N =           67
;;------------------------------------------------------------------------------------------------------
;;  Name              Min            Max            Avg            Med            Std            SoM
;;======================================================================================================
;;  Beta_up:       1.8000e-02     8.2000e-01     3.2107e-01     3.0100e-01     2.1839e-01     2.6680e-02
;;  thet_Bn:       4.5500e+01     8.7500e+01     6.9315e+01     6.9400e+01     1.0874e+01     1.3284e+00
;;  Mf___up:       1.0400e+00     2.5200e+00     1.7215e+00     1.7600e+00     3.8676e-01     4.7250e-02
;;  M_A__up:       1.1485e+00     2.9497e+00     2.0772e+00     2.1357e+00     5.2668e-01     6.4344e-02
;;  Vshn_up:       8.5600e+01     9.0780e+02     4.6478e+02     4.5450e+02     1.1882e+02     1.4517e+01
;;  Ushn_up:       3.8600e+01     2.7510e+02     1.2080e+02     1.0940e+02     5.4510e+01     6.6595e+00
;;  Bmag_up:       2.4104e+00     1.7345e+01     7.4348e+00     6.7149e+00     3.0234e+00     3.6936e-01
;;  Ni___up:       1.6000e+00     2.7800e+01     9.2985e+00     7.6000e+00     5.7797e+00     7.0610e-01
;;  NsqBo_u:       1.2093e-01     1.2024e+00     4.4671e-01     3.9246e-01     2.0415e-01     2.4941e-02
;;------------------------------------------------------------------------------------------------------

mform          = '(";;  ",a7,":  ",6f15.4)'
np             = N_ELEMENTS(stat_labs)
PRINT,';;  N = ',nx[0]
FOR kk=0L, np[0] - 1L DO BEGIN                                                                              $
  stats = strc_stats.(kk[0])                                                                              & $
  PRINT,stat_labs[kk],stats,FORMAT=mform[0]
;;------------------------------------------------------------------------------------------------------
;;  Only Shocks with Whistler Precursors that are undersampled [YU or YM]
;;  N =           67
;;------------------------------------------------------------------------------------------------------
;;  Name                Min            Max            Avg            Med            Std            SoM
;;======================================================================================================
;;  Beta_up:           0.0180         0.8200         0.3211         0.3010         0.2184         0.0267
;;  thet_Bn:          45.5000        87.5000        69.3149        69.4000        10.8736         1.3284
;;  Mf___up:           1.0400         2.5200         1.7215         1.7600         0.3868         0.0473
;;  M_A__up:           1.1485         2.9497         2.0772         2.1357         0.5267         0.0643
;;  Vshn_up:          85.6000       907.8000       464.7791       454.5000       118.8240        14.5167
;;  Ushn_up:          38.6000       275.1000       120.8030       109.4000        54.5104         6.6595
;;  Bmag_up:           2.4104        17.3453         7.4348         6.7149         3.0234         0.3694
;;  Ni___up:           1.6000        27.8000         9.2985         7.6000         5.7797         0.7061
;;  NsqBo_u:           0.1209         1.2024         0.4467         0.3925         0.2041         0.0249
;;------------------------------------------------------------------------------------------------------

;;----------------------------------------------------------------------------------------
;;  Look at stats for resolved shocks with whistlers [YS or YG]
;;----------------------------------------------------------------------------------------
ind7           = good_A[good_y_asg0]      ;;  All "good" shocks with whistlers and resolved

xx             = beta_t_up[ind7]
nx             = N_ELEMENTS(xx)
beta_up_stats  = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]
xx             = thetbn_up[ind7]
nx             = N_ELEMENTS(xx)
thbn_up_stats  = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]
xx             = Mfast__up[ind7]
nx             = N_ELEMENTS(xx)
Mf___up_stats  = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]
xx             = M_VA___up[ind7]
nx             = N_ELEMENTS(xx)
MA___up_stats  = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]
xx             = vshn___up[ind7]
nx             = N_ELEMENTS(xx)
vshn_up_stats  = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]
xx             = ushn___up[ind7]
nx             = N_ELEMENTS(xx)
ushn_up_stats  = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]
xx             = bo_mag_up[ind7]
nx             = N_ELEMENTS(xx)
bmag_up_stats  = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]
xx             = ni_avg_up[ind7]
nx             = N_ELEMENTS(xx)
dens_up_stats  = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]
xx             = SQRT(ni_avg_up[ind7])/bo_mag_up[ind7]
nx             = N_ELEMENTS(xx)
nsqb_up_stats  = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]

stat_labs      = ['Beta_up','thet_Bn','Mf___up','M_A__up','Vshn_up','Ushn_up','Bmag_up','Ni___up','NsqBo_up']
strc_stats     = CREATE_STRUCT(stat_labs,beta_up_stats,thbn_up_stats,Mf___up_stats,MA___up_stats,vshn_up_stats,ushn_up_stats,bmag_up_stats,dens_up_stats,nsqb_up_stats)
mform          = '(";;  ",a7,":  ",6e15.4)'
np             = N_ELEMENTS(stat_labs)
PRINT,';;  N = ',nx[0]
FOR kk=0L, np[0] - 1L DO BEGIN                                                                              $
  stats = strc_stats.(kk[0])                                                                              & $
  PRINT,stat_labs[kk],stats,FORMAT=mform[0]
;;------------------------------------------------------------------------------------------------------
;;  Only Shocks with Whistler Precursors that are resolved [YS or YG]
;;  N =           13
;;------------------------------------------------------------------------------------------------------
;;  Name              Min            Max            Avg            Med            Std            SoM
;;======================================================================================================
;;  Beta_up:       5.8000e-02     6.5500e-01     3.0962e-01     2.8900e-01     1.9088e-01     5.2939e-02
;;  thet_Bn:       4.5500e+01     8.5500e+01     5.8931e+01     6.0100e+01     1.2474e+01     3.4596e+00
;;  Mf___up:       1.0200e+00     2.0000e+00     1.4738e+00     1.5400e+00     3.7992e-01     1.0537e-01
;;  M_A__up:       1.1509e+00     2.5740e+00     1.7516e+00     1.5851e+00     5.2034e-01     1.4432e-01
;;  Vshn_up:       2.8510e+02     5.9170e+02     4.2044e+02     3.8610e+02     8.8505e+01     2.4547e+01
;;  Ushn_up:       5.2300e+01     2.5880e+02     9.0977e+01     7.3500e+01     5.4860e+01     1.5215e+01
;;  Bmag_up:       2.1119e+00     1.5560e+01     5.3430e+00     4.7339e+00     3.4058e+00     9.4459e-01
;;  Ni___up:       1.0000e+00     1.7200e+01     6.0615e+00     4.4000e+00     4.9765e+00     1.3802e+00
;;  NsqBo_u:       1.8170e-01     8.7312e-01     4.8472e-01     4.6954e-01     1.7599e-01     4.8812e-02
;;------------------------------------------------------------------------------------------------------

mform          = '(";;  ",a7,":  ",6f15.4)'
np             = N_ELEMENTS(stat_labs)
PRINT,';;  N = ',nx[0]
FOR kk=0L, np[0] - 1L DO BEGIN                                                                              $
  stats = strc_stats.(kk[0])                                                                              & $
  PRINT,stat_labs[kk],stats,FORMAT=mform[0]
;;------------------------------------------------------------------------------------------------------
;;  Only Shocks with Whistler Precursors that are resolved [YS or YG]
;;  N =           13
;;------------------------------------------------------------------------------------------------------
;;  Name                Min            Max            Avg            Med            Std            SoM
;;======================================================================================================
;;  Beta_up:           0.0580         0.6550         0.3096         0.2890         0.1909         0.0529
;;  thet_Bn:          45.5000        85.5000        58.9308        60.1000        12.4739         3.4596
;;  Mf___up:           1.0200         2.0000         1.4738         1.5400         0.3799         0.1054
;;  M_A__up:           1.1509         2.5740         1.7516         1.5851         0.5203         0.1443
;;  Vshn_up:         285.1000       591.7000       420.4385       386.1000        88.5050        24.5469
;;  Ushn_up:          52.3000       258.8000        90.9769        73.5000        54.8600        15.2154
;;  Bmag_up:           2.1119        15.5599         5.3430         4.7339         3.4058         0.9446
;;  Ni___up:           1.0000        17.2000         6.0615         4.4000         4.9765         1.3802
;;  NsqBo_u:           0.1817         0.8731         0.4847         0.4695         0.1760         0.0488
;;------------------------------------------------------------------------------------------------------

;;----------------------------------------------------------------------------------------
;;  Look at stats for at least partially resolved shocks with whistlers [YS or YG or YP]
;;----------------------------------------------------------------------------------------
test_2_asgp    = (whpre_2l EQ 'S') OR (whpre_2l EQ 'G') OR (whpre_2l EQ 'P')
test_y_asgp    = test_2_asgp AND test_y_all0
good_y_asgp    = WHERE(test_y_asgp,gd_y_asgp)         ;;   All whistlers and at least partially resolved

ind8           = good_A[good_y_asgp]      ;;  All "good" shocks with whistlers and at least partially resolved

xx             = beta_t_up[ind8]
nx             = N_ELEMENTS(xx)
beta_up_stats  = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]
xx             = thetbn_up[ind8]
nx             = N_ELEMENTS(xx)
thbn_up_stats  = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]
xx             = Mfast__up[ind8]
nx             = N_ELEMENTS(xx)
Mf___up_stats  = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]
xx             = M_VA___up[ind8]
nx             = N_ELEMENTS(xx)
MA___up_stats  = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]
xx             = vshn___up[ind8]
nx             = N_ELEMENTS(xx)
vshn_up_stats  = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]
xx             = ushn___up[ind8]
nx             = N_ELEMENTS(xx)
ushn_up_stats  = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]
xx             = bo_mag_up[ind8]
nx             = N_ELEMENTS(xx)
bmag_up_stats  = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]
xx             = ni_avg_up[ind8]
nx             = N_ELEMENTS(xx)
dens_up_stats  = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]
xx             = SQRT(ni_avg_up[ind8])/bo_mag_up[ind8]
nx             = N_ELEMENTS(xx)
nsqb_up_stats  = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]

stat_labs      = ['Beta_up','thet_Bn','Mf___up','M_A__up','Vshn_up','Ushn_up','Bmag_up','Ni___up','NsqBo_up']
strc_stats     = CREATE_STRUCT(stat_labs,beta_up_stats,thbn_up_stats,Mf___up_stats,MA___up_stats,vshn_up_stats,ushn_up_stats,bmag_up_stats,dens_up_stats,nsqb_up_stats)
mform          = '(";;  ",a7,":  ",6e15.4)'
np             = N_ELEMENTS(stat_labs)
PRINT,';;  N = ',nx[0]
FOR kk=0L, np[0] - 1L DO BEGIN                                                                              $
  stats = strc_stats.(kk[0])                                                                              & $
  PRINT,stat_labs[kk],stats,FORMAT=mform[0]
;;------------------------------------------------------------------------------------------------------
;;  Only Shocks with Whistler Precursors that are at least partially resolved [YS or YG or YP]
;;  N =           46
;;------------------------------------------------------------------------------------------------------
;;  Name              Min            Max            Avg            Med            Std            SoM
;;======================================================================================================
;;  Beta_up:       4.2000e-02     6.5500e-01     3.1659e-01     3.6100e-01     1.6502e-01     2.4330e-02
;;  thet_Bn:       4.5500e+01     8.8100e+01     6.2196e+01     6.0700e+01     1.1401e+01     1.6809e+00
;;  Mf___up:       1.0200e+00     2.2200e+00     1.5748e+00     1.5900e+00     3.3331e-01     4.9144e-02
;;  M_A__up:       1.1509e+00     2.8042e+00     1.8883e+00     1.9289e+00     4.6645e-01     6.8774e-02
;;  Vshn_up:       9.3000e+00     7.0070e+02     4.2999e+02     4.1790e+02     1.2694e+02     1.8716e+01
;;  Ushn_up:       4.3400e+01     2.5880e+02     9.8157e+01     8.6600e+01     4.5312e+01     6.6809e+00
;;  Bmag_up:       2.1119e+00     1.5560e+01     5.6801e+00     5.0498e+00     2.5269e+00     3.7257e-01
;;  Ni___up:       1.0000e+00     2.9500e+01     7.0217e+00     6.1000e+00     5.1656e+00     7.6163e-01
;;  NsqBo_u:       1.8170e-01     9.2484e-01     4.8872e-01     4.5598e-01     1.9642e-01     2.8960e-02
;;------------------------------------------------------------------------------------------------------

mform          = '(";;  ",a7,":  ",6f15.4)'
np             = N_ELEMENTS(stat_labs)
PRINT,';;  N = ',nx[0]
FOR kk=0L, np[0] - 1L DO BEGIN                                                                              $
  stats = strc_stats.(kk[0])                                                                              & $
  PRINT,stat_labs[kk],stats,FORMAT=mform[0]
;;------------------------------------------------------------------------------------------------------
;;  Only Shocks with Whistler Precursors that are at least partially resolved [YS or YG or YP]
;;  N =           46
;;------------------------------------------------------------------------------------------------------
;;  Name                Min            Max            Avg            Med            Std            SoM
;;======================================================================================================
;;  Beta_up:           0.0420         0.6550         0.3166         0.3610         0.1650         0.0243
;;  thet_Bn:          45.5000        88.1000        62.1956        60.7000        11.4006         1.6809
;;  Mf___up:           1.0200         2.2200         1.5748         1.5900         0.3333         0.0491
;;  M_A__up:           1.1509         2.8042         1.8883         1.9289         0.4665         0.0688
;;  Vshn_up:           9.3000       700.7000       429.9869       417.9000       126.9382        18.7160
;;  Ushn_up:          43.4000       258.8000        98.1565        86.6000        45.3124         6.6809
;;  Bmag_up:           2.1119        15.5599         5.6801         5.0498         2.5269         0.3726
;;  Ni___up:           1.0000        29.5000         7.0217         6.1000         5.1656         0.7616
;;  NsqBo_u:           0.1817         0.9248         0.4887         0.4560         0.1964         0.0290
;;------------------------------------------------------------------------------------------------------

;;----------------------------------------------------------------------------------------
;;  Find IDL save files
;;----------------------------------------------------------------------------------------
fname_amps     = 'Wind_'+inst_pref[0]+'_all_precursor_shocks_Det-Filt-Bo_Val_Norm2Bup_Norm2DB.sav'
fname_mach     = 'Wind_'+inst_pref[0]+'_all_Qperp_shocks_betaup_theBn_MAup_Mfup_Mcr3WMcrs_and_ratios.sav'
gname_amps     = FILE_SEARCH(sav_dir[0],fname_amps[0])
gname_mach     = FILE_SEARCH(sav_dir[0],fname_mach[0])
;;  Restore data
IF (gname_amps[0] NE '') THEN RESTORE,gname_amps
IF (gname_mach[0] NE '') THEN RESTORE,gname_mach
test           = (SIZE(bamp_struc,/TYPE) NE 8) OR (SIZE(mach_rat_stru,/TYPE) NE 8)
IF (test[0]) THEN STOP

;;----------------------------------------------------------------------------------------
;;  Print stats
;;----------------------------------------------------------------------------------------

;;---------------------------------------------
;;  Stats:  ∂B/<B>_up = Ratio
;;---------------------------------------------
all_stats      = bamp_struc.BAVG_RAT
;;  Determine number of events where Ratio ≥ 10%, 25%, 50%, 75%
thrsh          = 1e-1
thrsh_str      = '≥ 10%:  '

thrsh          = 25e-2
thrsh_str      = '≥ 25%:  '

thrsh          = 5e-1
thrsh_str      = '≥ 50%:  '

thrsh          = 75e-2
thrsh_str      = '≥ 75%:  '

test_min       = (all_stats[*,0] GE thrsh[0]) & test_max = (all_stats[*,1] GE thrsh[0]) & test_avg = (all_stats[*,2] GE thrsh[0]) & test_med = (all_stats[*,3] GE thrsh[0])
good_min       = WHERE(test_min,gd_min) & good_max = WHERE(test_max,gd_max) & good_avg = WHERE(test_avg,gd_avg) & good_med = WHERE(test_med,gd_med)
PRINT,';;' & $
PRINT,';;  '+thrsh_str[0],gd_min[0],gd_max[0],gd_avg[0],gd_med[0] & $
PRINT,';;  '+thrsh_str[0],ROUND(gd_min[0]/(1d-2*gd[0])),ROUND(gd_max[0]/(1d-2*gd[0])),ROUND(gd_avg[0]/(1d-2*gd[0])),ROUND(gd_med[0]/(1d-2*gd[0]))

;;
;;  ≥ 10%:             0         104          29           7
;;  ≥ 10%:             0          92          26           6
;;
;;  ≥ 25%:             0          77           3           1
;;  ≥ 25%:             0          68           3           1
;;
;;  ≥ 50%:             0          41           0           0
;;  ≥ 50%:             0          36           0           0
;;
;;  ≥ 75%:             0          20           0           0
;;  ≥ 75%:             0          18           0           0

;;  Print Stats for each stat
stat_labs      = ['Min','Max','Avg','Med','Std','SoM']
mform          = '(";;  ",a3,":  ",6e15.4)'
FOR kk=0L, 5L DO BEGIN                                                                                      $
  xx    = all_stats[*,kk]                                                                                 & $
  nx    = N_ELEMENTS(xx)                                                                                  & $
  stats = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]  & $
  PRINT,stat_labs[kk],stats,FORMAT=mform[0]
;;  Stats:  ∂B/<B>_up
;;------------------------------------------------------------------------------------------------------
;;  Stat          Min            Max            Avg            Med            Std            SoM
;;======================================================================================================
;;  Min:       3.2825e-03     3.9385e-02     1.1663e-02     9.5515e-03     7.5392e-03     7.0923e-04
;;  Max:       2.7563e-02     1.5923e+00     4.6389e-01     3.8376e-01     3.3907e-01     3.1897e-02
;;  Avg:       1.1208e-02     3.8332e-01     8.1866e-02     6.6058e-02     6.1677e-02     5.8021e-03
;;  Med:       9.7792e-03     3.3704e-01     5.0281e-02     4.2087e-02     3.9223e-02     3.6898e-03
;;  Std:       4.4510e-03     4.7077e-01     8.6307e-02     6.4338e-02     7.5203e-02     7.0745e-03
;;  SoM:       3.8860e-04     1.0527e-01     1.0479e-02     5.9200e-03     1.4251e-02     1.3406e-03
;;------------------------------------------------------------------------------------------------------

stat_labs      = ['Min','Max','Avg','Med','Std','SoM']
mform          = '(";;  ",a3,":  ",6f13.4)'
yy             = all_stats
FOR kk=0L, 5L DO BEGIN                                                                                      $
  xx    = yy[*,kk]                                                                                        & $
  nx    = N_ELEMENTS(xx)                                                                                  & $
  stats = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]  & $
  hig2  = WHERE(stats GE 10,gd_h2)                                                                        & $
  high  = WHERE(stats GE 1 AND stats LT 10,gd_hg)                                                         & $
  mid   = WHERE(stats GE 1e-1 AND stats LT 1,gd_md)                                                       & $
  low   = WHERE(stats LT 1e-1,gd_lw)                                                                      & $
  IF (gd_h2[0] GT 0) THEN stats[hig2] = roundsig(stats[hig2],SIGFIG=3)                                    & $
  IF (gd_hg[0] GT 0) THEN stats[high] = roundsig(stats[high],SIGFIG=2)                                    & $
  IF (gd_md[0] GT 0) THEN stats[mid]  = roundsig(stats[mid],SIGFIG=1)                                     & $
  IF (gd_lw[0] GT 0) THEN stats[low]  = roundsig(stats[low],SIGFIG=0)                                     & $
  PRINT,stat_labs[kk],stats,FORMAT=mform[0]
;;  Stats:  ∂B/<B>_up
;;------------------------------------------------------------------------------------------------------
;;  Stat          Min          Max          Avg          Med          Std          SoM
;;======================================================================================================
;;  Min:         0.0030       0.0400       0.0100       0.0100       0.0080       0.0007
;;  Max:         0.0300       1.5900       0.4600       0.3800       0.3400       0.0300
;;  Avg:         0.0100       0.3800       0.0800       0.0700       0.0600       0.0060
;;  Med:         0.0100       0.3400       0.0500       0.0400       0.0400       0.0040
;;  Std:         0.0040       0.4700       0.0900       0.0600       0.0800       0.0070
;;  SoM:         0.0004       0.1100       0.0100       0.0060       0.0100       0.0010
;;------------------------------------------------------------------------------------------------------


;;---------------------------------------------
;;  Stats:  ∂B/∆B
;;---------------------------------------------
all_stats      = bamp_struc.RAMP_RAT
;;  Determine number of events where Ratio ≥ 10%, 25%, 50%, 75%
thrsh          = 1e-1
thrsh_str      = '≥ 10%:  '

thrsh          = 25e-2
thrsh_str      = '≥ 25%:  '

thrsh          = 5e-1
thrsh_str      = '≥ 50%:  '

thrsh          = 75e-2
thrsh_str      = '≥ 75%:  '

test_min       = (all_stats[*,0] GE thrsh[0]) & test_max = (all_stats[*,1] GE thrsh[0]) & test_avg = (all_stats[*,2] GE thrsh[0]) & test_med = (all_stats[*,3] GE thrsh[0])
good_min       = WHERE(test_min,gd_min) & good_max = WHERE(test_max,gd_max) & good_avg = WHERE(test_avg,gd_avg) & good_med = WHERE(test_med,gd_med)
PRINT,';;' & $
PRINT,';;  '+thrsh_str[0],gd_min[0],gd_max[0],gd_avg[0],gd_med[0] & $
PRINT,';;  '+thrsh_str[0],ROUND(gd_min[0]/(1d-2*gd[0])),ROUND(gd_max[0]/(1d-2*gd[0])),ROUND(gd_avg[0]/(1d-2*gd[0])),ROUND(gd_med[0]/(1d-2*gd[0]))

;;
;;  ≥ 10%:             2         112          47          23
;;  ≥ 10%:             2          99          42          20
;;
;;  ≥ 25%:             0          94          10           4
;;  ≥ 25%:             0          83           9           4
;;
;;  ≥ 50%:             0          57           4           2
;;  ≥ 50%:             0          50           4           2
;;
;;  ≥ 75%:             0          36           1           1
;;  ≥ 75%:             0          32           1           1

;;  Print Stats for each stat
stat_labs      = ['Min','Max','Avg','Med','Std','SoM']
mform          = '(";;  ",a3,":  ",6e15.4)'
FOR kk=0L, 5L DO BEGIN                                                                                      $
  xx    = all_stats[*,kk]                                                                                 & $
  nx    = N_ELEMENTS(xx)                                                                                  & $
  stats = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]  & $
  PRINT,stat_labs[kk],stats,FORMAT=mform[0]
;;  Stats:  ∂B/∆B
;;------------------------------------------------------------------------------------------------------
;;  Stat          Min            Max            Avg            Med            Std            SoM
;;======================================================================================================
;;  Min:       3.8600e-03     1.5333e-01     1.8814e-02     1.3999e-02     1.9413e-02     1.8262e-03
;;  Max:       3.5972e-02     1.5320e+01     7.9284e-01     5.0590e-01     1.4936e+00     1.4050e-01
;;  Avg:       1.4627e-02     2.1478e+00     1.3751e-01     8.9535e-02     2.2038e-01     2.0732e-02
;;  Med:       1.1652e-02     1.0851e+00     8.2924e-02     5.5080e-02     1.1598e-01     1.0910e-02
;;  Std:       5.8090e-03     2.6657e+00     1.4775e-01     8.3999e-02     2.7911e-01     2.6256e-02
;;  SoM:       7.2612e-04     2.3290e-01     1.7442e-02     7.9141e-03     3.4301e-02     3.2268e-03
;;------------------------------------------------------------------------------------------------------

stat_labs      = ['Min','Max','Avg','Med','Std','SoM']
mform          = '(";;  ",a3,":  ",6f13.4)'
yy             = all_stats
FOR kk=0L, 5L DO BEGIN                                                                                      $
  xx    = yy[*,kk]                                                                                        & $
  nx    = N_ELEMENTS(xx)                                                                                  & $
  stats = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]  & $
  hig2  = WHERE(stats GE 10,gd_h2)                                                                        & $
  high  = WHERE(stats GE 1 AND stats LT 10,gd_hg)                                                         & $
  mid   = WHERE(stats GE 1e-1 AND stats LT 1,gd_md)                                                       & $
  low   = WHERE(stats LT 1e-1,gd_lw)                                                                      & $
  IF (gd_h2[0] GT 0) THEN stats[hig2] = roundsig(stats[hig2],SIGFIG=3)                                    & $
  IF (gd_hg[0] GT 0) THEN stats[high] = roundsig(stats[high],SIGFIG=2)                                    & $
  IF (gd_md[0] GT 0) THEN stats[mid]  = roundsig(stats[mid],SIGFIG=1)                                     & $
  IF (gd_lw[0] GT 0) THEN stats[low]  = roundsig(stats[low],SIGFIG=0)                                     & $
  PRINT,stat_labs[kk],stats,FORMAT=mform[0]
;;  Stats:  ∂B/∆B
;;------------------------------------------------------------------------------------------------------
;;  Stat          Min          Max          Avg          Med          Std          SoM
;;======================================================================================================
;;  Min:         0.0040       0.1500       0.0200       0.0100       0.0200       0.0020
;;  Max:         0.0400      15.3200       0.7900       0.5100       1.4900       0.1400
;;  Avg:         0.0100       2.1500       0.1400       0.0900       0.2200       0.0200
;;  Med:         0.0100       1.0900       0.0800       0.0600       0.1200       0.0100
;;  Std:         0.0060       2.6700       0.1500       0.0800       0.2800       0.0300
;;  SoM:         0.0007       0.2300       0.0200       0.0080       0.0300       0.0030
;;------------------------------------------------------------------------------------------------------


;;---------------------------------------------
;;  Stats:  ∂B
;;---------------------------------------------
all_stats      = bamp_struc.BAMP_VAL
;;  Determine number of events where ∂B ≥ 0.10, 0.25, 0.50, 0.75
thrsh          = 1e-1
thrsh_str      = '≥ 0.10:  '

thrsh          = 25e-2
thrsh_str      = '≥ 0.25:  '

thrsh          = 5e-1
thrsh_str      = '≥ 0.50:  '

thrsh          = 75e-2
thrsh_str      = '≥ 0.75:  '

thrsh          = 1e0
thrsh_str      = '≥ 1.00:  '

thrsh          = 2e0
thrsh_str      = '≥ 2.00:  '

test_min       = (all_stats[*,0] GE thrsh[0]) & test_max = (all_stats[*,1] GE thrsh[0]) & test_avg = (all_stats[*,2] GE thrsh[0]) & test_med = (all_stats[*,3] GE thrsh[0])
good_min       = WHERE(test_min,gd_min) & good_max = WHERE(test_max,gd_max) & good_avg = WHERE(test_avg,gd_avg) & good_med = WHERE(test_med,gd_med)
PRINT,';;' & $
PRINT,';;  '+thrsh_str[0],gd_min[0],gd_max[0],gd_avg[0],gd_med[0] & $
PRINT,';;  '+thrsh_str[0],ROUND(gd_min[0]/(1d-2*gd[0])),ROUND(gd_max[0]/(1d-2*gd[0])),ROUND(gd_avg[0]/(1d-2*gd[0])),ROUND(gd_med[0]/(1d-2*gd[0]))
;;
;;  ≥ 0.10:            20         113         107          98
;;  ≥ 0.10:            18         100          95          87
;;
;;  ≥ 0.25:             5         110          80          57
;;  ≥ 0.25:             4          97          71          50
;;
;;  ≥ 0.50:             0         106          44          22
;;  ≥ 0.50:             0          94          39          19
;;
;;  ≥ 0.75:             0         100          26           9
;;  ≥ 0.75:             0          88          23           8
;;
;;  ≥ 1.00:             0          91          17           6
;;  ≥ 1.00:             0          81          15           5
;;
;;  ≥ 2.00:             0          64           0           0
;;  ≥ 2.00:             0          57           0           0

;;  Print Stats for each stat
stat_labs      = ['Min','Max','Avg','Med','Std','SoM']
mform          = '(";;  ",a3,":  ",6e15.4)'
FOR kk=0L, 5L DO BEGIN                                                                                      $
  xx    = all_stats[*,kk]                                                                                 & $
  nx    = N_ELEMENTS(xx)                                                                                  & $
  stats = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]  & $
  PRINT,stat_labs[kk],stats,FORMAT=mform[0]
;;  Stats:  ∂B
;;------------------------------------------------------------------------------------------------------
;;  Stat          Min            Max            Avg            Med            Std            SoM
;;======================================================================================================
;;  Min:       1.4066e-02     4.3988e-01     7.7312e-02     5.4346e-02     7.2018e-02     6.7749e-03
;;  Max:       2.0965e-01     1.2996e+01     2.9915e+00     2.3437e+00     2.5210e+00     2.3716e-01
;;  Avg:       7.2162e-02     1.9399e+00     5.3144e-01     4.2411e-01     3.9721e-01     3.7367e-02
;;  Med:       6.5264e-02     1.3442e+00     3.3533e-01     2.5615e-01     2.7448e-01     2.5821e-02
;;  Std:       2.9849e-02     2.4464e+00     5.4759e-01     4.2511e-01     4.6327e-01     4.3581e-02
;;  SoM:       1.3269e-03     5.3272e-01     6.5558e-02     3.8358e-02     8.0278e-02     7.5519e-03
;;------------------------------------------------------------------------------------------------------

stat_labs      = ['Min','Max','Avg','Med','Std','SoM']
mform          = '(";;  ",a3,":  ",6f13.4)'
yy             = all_stats
FOR kk=0L, 5L DO BEGIN                                                                                      $
  xx    = yy[*,kk]                                                                                        & $
  nx    = N_ELEMENTS(xx)                                                                                  & $
  stats = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]  & $
  hig2  = WHERE(stats GE 10,gd_h2)                                                                        & $
  high  = WHERE(stats GE 1 AND stats LT 10,gd_hg)                                                         & $
  mid   = WHERE(stats GE 1e-1 AND stats LT 1,gd_md)                                                       & $
  low   = WHERE(stats LT 1e-1,gd_lw)                                                                      & $
  IF (gd_h2[0] GT 0) THEN stats[hig2] = roundsig(stats[hig2],SIGFIG=3)                                    & $
  IF (gd_hg[0] GT 0) THEN stats[high] = roundsig(stats[high],SIGFIG=2)                                    & $
  IF (gd_md[0] GT 0) THEN stats[mid]  = roundsig(stats[mid],SIGFIG=1)                                     & $
  IF (gd_lw[0] GT 0) THEN stats[low]  = roundsig(stats[low],SIGFIG=0)                                     & $
  PRINT,stat_labs[kk],stats,FORMAT=mform[0]
;;  Stats:  ∂B
;;------------------------------------------------------------------------------------------------------
;;  Stat          Min          Max          Avg          Med          Std          SoM
;;======================================================================================================
;;  Min:         0.0100       0.4400       0.0800       0.0500       0.0700       0.0070
;;  Max:         0.2100      13.0000       2.9900       2.3400       2.5200       0.2400
;;  Avg:         0.0700       1.9400       0.5300       0.4200       0.4000       0.0400
;;  Med:         0.0700       1.3400       0.3400       0.2600       0.2700       0.0300
;;  Std:         0.0300       2.4500       0.5500       0.4300       0.4600       0.0400
;;  SoM:         0.0010       0.5300       0.0700       0.0400       0.0800       0.0080
;;------------------------------------------------------------------------------------------------------


;;----------------------------------------------------------------------------------------
;;  Define all relevant variable and uncertainties
;;----------------------------------------------------------------------------------------
;;  Values
prec_utc_st    = STRMID(prec_st,11L)              ;;  e.g., '23:32:57.740'
prec_utc_en    = STRMID(prec_en,11L)
prec_tdates    = bamp_struc.TDATE
dB_DBrampstats = bamp_struc.RAMP_RAT              ;;  ∂B/∆B [min,max,avg,med,std,som]
dB_Bavgupstats = bamp_struc.BAVG_RAT              ;;  ∂B/<B>_up " "
dB_val___stats = bamp_struc.BAMP_VAL              ;;  ∂B [nT] " "

nform          = 'f8.3'
texform        = '(";;  ",a10," & ",a12," & ",a12," & ",'+nform[0]+'," & ",'+nform[0]+'," & ",'+nform[0]+'," & ",'+nform[0]+'," & ",'+nform[0]+'," & ",'+nform[0]+',"  \\")'
np             = N_ELEMENTS(prec_tdates)
FOR kk=0L, np[0] - 1L DO BEGIN                                                                              $
  nums0 = REFORM(dB_DBrampstats[kk,*])                                                                    & $
  PRINT,';;  \hline'                                                                                      & $
  PRINT,prec_tdates[kk],prec_utc_st[kk],prec_utc_en[kk],nums0,FORMAT=texform[0]

;;  ****************************************************************************************************
;;  ***  Need to add [-11.5pt] immediately after last \\ in table to avoid extra stupid-looking row  ***
;;  ****************************************************************************************************
;;
;;  \caption{Whistler Precursor Amplitude Statistics for $\delta B{\scriptstyle_{pk-pk}} / \Delta \lvert \mathbf{B}{\scriptstyle_{o}} \rvert$} \\  %%  show caption
;;  test & the width & of this & table & by & killing & a & row & here \kill
;;  \hline
;;  \textbf{Date} & \textbf{Start Time} & \textbf{End Time} & $\mathbf{X{\scriptstyle_{\mathbf{min}}}}$ & $\mathbf{X{\scriptstyle_{\mathbf{max}}}}$ & $\bar{\mathbf{X}}$ & $\tilde{\mathbf{X}}$ & $\boldsymbol{\sigma}{\scriptstyle_{\mathbf{x}}}$ & $\boldsymbol{\sigma}{\scriptstyle_{\mathbf{x}}}/\sqrt{\textbf{N}}$  \\
;;  & \textbf{[UTC]} & \textbf{[UTC]} & & & & & &  \\
;;  \hline
;;  \multicolumn{9}{ |c| }{\textbf{Statistics of} $\boldsymbol{\delta}\mathbf{B}{\scriptstyle_{\mathbf{pk-pk}}} \mathbf{/} \boldsymbol{\Delta \lvert} \mathbf{B}{\scriptstyle_{\mathbf{o}}} \boldsymbol{\rvert}$ \textbf{for each of the 113 shocks with precursors satisfying:}} \\
;;  \multicolumn{9}{ |c| }{$\langle M{\scriptstyle_{f}} \rangle{\scriptstyle_{up}}$ $\geq$ 1;  1 $\leq$ $\langle M{\scriptstyle_{A}} \rangle{\scriptstyle_{up}}$ $\leq$ 3; 1 $\leq$ $\mathcal{R}$ $\leq$ 3; $\langle \theta{\scriptstyle_{Bn}} \rangle{\scriptstyle_{up}}$ $\geq$ 45$^{\circ}$} \\
;;  \endhead  %%  Specifies rows to appear at the top of every page
;;  \textbf{Date} & \textbf{Start Time} & \textbf{End Time} & $\mathbf{X{\scriptstyle_{\mathbf{min}}}}$ & $\mathbf{X{\scriptstyle_{\mathbf{max}}}}$ & $\bar{\mathbf{X}}$ & $\tilde{\mathbf{X}}$ & $\boldsymbol{\sigma}{\scriptstyle_{\mathbf{x}}}$ & $\boldsymbol{\sigma}{\scriptstyle_{\mathbf{x}}}/\sqrt{\textbf{N}}$  \\
;;  & \textbf{[UTC]} & \textbf{[UTC]} & & & & & &  \\
;;  \hline
;;  \endfoot  %%  Specifies rows to appear at the bottom of every page
;;  \hline
;;  \textbf{Date} & \textbf{Start Time} & \textbf{End Time} & $\mathbf{X{\scriptstyle_{\mathbf{min}}}}$ & $\mathbf{X{\scriptstyle_{\mathbf{max}}}}$ & $\bar{\mathbf{X}}$ & $\tilde{\mathbf{X}}$ & $\boldsymbol{\sigma}{\scriptstyle_{\mathbf{x}}}$ & $\boldsymbol{\sigma}{\scriptstyle_{\mathbf{x}}}/\sqrt{\textbf{N}}$  \\
;;  & \textbf{[UTC]} & \textbf{[UTC]} & & & & & &  \\
;;  \hline
;;  \endlastfoot  %%  Specifies rows to appear at the bottom of every page
;;  \hline
;;  1995-04-17 & 23:32:57.740 & 23:33:07.610 &    0.122 &    0.712 &    0.299 &    0.267 &    0.163 &    0.032  \\
;;  \hline
;;  1995-07-22 & 05:34:15.740 & 05:35:45.049 &    0.017 &    0.939 &    0.113 &    0.059 &    0.160 &    0.010  \\
;;  \hline
;;  1995-08-22 & 12:56:39.240 & 12:56:48.970 &    0.038 &    1.536 &    0.305 &    0.127 &    0.387 &    0.054  \\
;;  \hline
;;  1995-08-24 & 22:10:53.360 & 22:11:04.379 &    0.026 &    0.391 &    0.109 &    0.086 &    0.074 &    0.010  \\
;;  \hline
;;  1995-10-22 & 21:20:09.761 & 21:20:15.694 &    0.020 &    0.832 &    0.163 &    0.073 &    0.167 &    0.027  \\
;;  \hline
;;  1995-12-24 & 05:57:33.368 & 05:57:35.006 &    0.012 &    0.495 &    0.097 &    0.070 &    0.102 &    0.014  \\
;;  \hline
;;  1996-02-06 & 19:14:13.830 & 19:14:25.350 &    0.026 &    0.397 &    0.119 &    0.055 &    0.123 &    0.022  \\
;;  \hline
;;  1996-04-03 & 09:46:57.259 & 09:47:17.037 &    0.021 &    1.015 &    0.086 &    0.054 &    0.124 &    0.012  \\
;;  \hline
;;  1996-04-08 & 02:41:03.620 & 02:41:09.639 &    0.028 &    0.705 &    0.217 &    0.089 &    0.225 &    0.040  \\
;;  \hline
;;  1997-03-15 & 22:29:44.490 & 22:30:32.279 &    0.032 &    1.105 &    0.258 &    0.176 &    0.234 &    0.021  \\
;;  \hline
;;  1997-04-10 & 12:57:53.649 & 12:58:34.480 &    0.025 &    0.289 &    0.110 &    0.091 &    0.070 &    0.007  \\
;;  \hline
;;  1997-10-24 & 11:17:03.750 & 11:18:09.830 &    0.009 &    1.394 &    0.074 &    0.035 &    0.136 &    0.007  \\
;;  \hline
;;  1997-11-01 & 06:14:27.659 & 06:14:45.110 &    0.024 &    0.270 &    0.095 &    0.092 &    0.053 &    0.005  \\
;;  \hline
;;  1997-12-10 & 04:33:03.539 & 04:33:14.666 &    0.008 &    0.574 &    0.127 &    0.051 &    0.164 &    0.031  \\
;;  \hline
;;  1997-12-30 & 01:13:20.450 & 01:13:43.639 &    0.014 &    0.383 &    0.077 &    0.038 &    0.087 &    0.011  \\
;;  \hline
;;  1998-01-06 & 13:28:11.509 & 13:29:00.182 &    0.153 &   15.320 &    2.148 &    1.085 &    2.666 &    0.233  \\
;;  \hline
;;  1998-02-18 & 07:46:50.370 & 07:48:43.870 &    0.010 &    1.950 &    0.235 &    0.139 &    0.262 &    0.015  \\
;;  \hline
;;  1998-05-29 & 15:11:58.159 & 15:12:04.299 &    0.039 &    0.229 &    0.105 &    0.082 &    0.055 &    0.014  \\
;;  \hline
;;  1998-08-06 & 07:14:35.190 & 07:16:07.495 &    0.007 &    0.393 &    0.079 &    0.053 &    0.068 &    0.004  \\
;;  \hline
;;  1998-08-19 & 18:40:34.169 & 18:40:41.519 &    0.030 &    0.963 &    0.319 &    0.305 &    0.269 &    0.062  \\
;;  \hline
;;  1998-11-08 & 04:40:53.240 & 04:41:17.230 &    0.028 &    0.261 &    0.082 &    0.067 &    0.050 &    0.006  \\
;;  \hline
;;  1998-12-28 & 18:19:57.519 & 18:20:16.065 &    0.009 &    0.155 &    0.024 &    0.015 &    0.027 &    0.004  \\
;;  \hline
;;  1999-01-13 & 10:47:36.970 & 10:47:44.669 &    0.044 &    2.580 &    0.621 &    0.123 &    0.763 &    0.171  \\
;;  \hline
;;  1999-02-17 & 07:11:31.720 & 07:12:13.843 &    0.015 &    0.602 &    0.098 &    0.068 &    0.091 &    0.009  \\
;;  \hline
;;  1999-04-16 & 11:13:23.500 & 11:14:12.000 &    0.024 &    1.296 &    0.248 &    0.193 &    0.207 &    0.018  \\
;;  \hline
;;  1999-06-26 & 19:30:24.860 & 19:30:55.759 &    0.013 &    0.913 &    0.130 &    0.088 &    0.143 &    0.016  \\
;;  \hline
;;  1999-08-04 & 01:44:01.429 & 01:44:38.368 &    0.019 &    0.810 &    0.200 &    0.131 &    0.175 &    0.018  \\
;;  \hline
;;  1999-08-23 & 12:09:18.200 & 12:11:14.590 &    0.016 &    1.175 &    0.164 &    0.095 &    0.203 &    0.011  \\
;;  \hline
;;  1999-09-22 & 12:09:24.743 & 12:09:25.473 &    0.065 &    2.699 &    0.683 &    0.553 &    0.746 &    0.156  \\
;;  \hline
;;  1999-10-21 & 02:19:01.000 & 02:20:51.235 &    0.004 &    0.523 &    0.057 &    0.042 &    0.058 &    0.003  \\
;;  \hline
;;  1999-11-05 & 20:01:36.899 & 20:03:09.659 &    0.017 &    1.024 &    0.193 &    0.132 &    0.189 &    0.012  \\
;;  \hline
;;  1999-11-13 & 12:47:31.509 & 12:48:57.250 &    0.014 &    0.436 &    0.075 &    0.055 &    0.062 &    0.004  \\
;;  \hline
;;  2000-02-05 & 15:25:06.629 & 15:26:29.031 &    0.013 &    0.925 &    0.161 &    0.100 &    0.176 &    0.012  \\
;;  \hline
;;  2000-02-14 & 07:12:32.429 & 07:12:59.740 &    0.037 &    1.734 &    0.307 &    0.137 &    0.384 &    0.045  \\
;;  \hline
;;  2000-06-23 & 12:57:16.379 & 12:57:59.327 &    0.008 &    0.387 &    0.098 &    0.068 &    0.086 &    0.008  \\
;;  \hline
;;  2000-07-13 & 09:43:38.389 & 09:43:51.580 &    0.037 &    0.683 &    0.216 &    0.143 &    0.177 &    0.030  \\
;;  \hline
;;  2000-07-26 & 18:59:52.940 & 19:00:14.860 &    0.012 &    0.214 &    0.068 &    0.046 &    0.053 &    0.007  \\
;;  \hline
;;  2000-07-28 & 06:38:15.860 & 06:38:45.817 &    0.008 &    0.855 &    0.109 &    0.060 &    0.134 &    0.015  \\
;;  \hline
;;  2000-08-10 & 05:12:21.080 & 05:13:21.370 &    0.009 &    0.236 &    0.061 &    0.042 &    0.050 &    0.004  \\
;;  \hline
;;  2000-08-11 & 18:49:30.659 & 18:49:34.379 &    0.023 &    0.257 &    0.120 &    0.124 &    0.071 &    0.013  \\
;;  \hline
;;  2000-10-28 & 09:30:28.309 & 09:30:41.879 &    0.027 &    3.621 &    0.657 &    0.183 &    1.072 &    0.179  \\
;;  \hline
;;  2000-10-31 & 17:08:33.149 & 17:09:59.284 &    0.011 &    0.751 &    0.092 &    0.045 &    0.121 &    0.008  \\
;;  \hline
;;  2000-11-06 & 09:29:09.789 & 09:30:20.669 &    0.016 &    0.992 &    0.224 &    0.150 &    0.205 &    0.015  \\
;;  \hline
;;  2000-11-26 & 11:43:20.870 & 11:43:26.710 &    0.022 &    0.742 &    0.130 &    0.084 &    0.154 &    0.030  \\
;;  \hline
;;  2000-11-28 & 05:25:33.700 & 05:27:41.985 &    0.010 &    0.262 &    0.044 &    0.033 &    0.034 &    0.002  \\
;;  \hline
;;  2001-01-17 & 04:07:10.799 & 04:07:53.059 &    0.014 &    0.138 &    0.047 &    0.040 &    0.022 &    0.002  \\
;;  \hline
;;  2001-03-03 & 11:28:22.080 & 11:29:20.899 &    0.019 &    0.902 &    0.134 &    0.079 &    0.154 &    0.012  \\
;;  \hline
;;  2001-03-22 & 13:58:30.230 & 13:59:06.240 &    0.005 &    0.219 &    0.039 &    0.018 &    0.046 &    0.005  \\
;;  \hline
;;  2001-03-27 & 18:07:15.600 & 18:07:48.210 &    0.007 &    0.129 &    0.033 &    0.025 &    0.027 &    0.003  \\
;;  \hline
;;  2001-04-21 & 15:29:02.879 & 15:29:14.123 &    0.023 &    0.119 &    0.044 &    0.036 &    0.024 &    0.004  \\
;;  \hline
;;  2001-05-06 & 09:05:27.789 & 09:06:08.332 &    0.017 &    0.507 &    0.111 &    0.073 &    0.100 &    0.010  \\
;;  \hline
;;  2001-05-12 & 10:01:41.690 & 10:03:14.317 &    0.010 &    0.138 &    0.042 &    0.038 &    0.020 &    0.001  \\
;;  \hline
;;  2001-09-13 & 02:30:10.129 & 02:31:26.029 &    0.014 &    0.329 &    0.068 &    0.054 &    0.051 &    0.004  \\
;;  \hline
;;  2001-10-28 & 03:13:23.950 & 03:13:48.500 &    0.005 &    0.276 &    0.055 &    0.020 &    0.071 &    0.009  \\
;;  \hline
;;  2001-11-30 & 18:15:10.889 & 18:15:45.440 &    0.017 &    0.326 &    0.075 &    0.050 &    0.065 &    0.007  \\
;;  \hline
;;  2001-12-21 & 14:09:42.850 & 14:10:17.090 &    0.014 &    0.263 &    0.093 &    0.073 &    0.059 &    0.006  \\
;;  \hline
;;  2001-12-30 & 20:04:29.870 & 20:05:05.830 &    0.019 &    0.338 &    0.075 &    0.051 &    0.061 &    0.006  \\
;;  \hline
;;  2002-01-17 & 05:26:51.590 & 05:26:56.879 &    0.010 &    0.279 &    0.073 &    0.027 &    0.082 &    0.014  \\
;;  \hline
;;  2002-01-31 & 21:37:31.419 & 21:38:10.404 &    0.010 &    0.138 &    0.056 &    0.045 &    0.031 &    0.004  \\
;;  \hline
;;  2002-03-23 & 11:23:24.620 & 11:24:09.210 &    0.007 &    0.222 &    0.050 &    0.036 &    0.044 &    0.004  \\
;;  \hline
;;  2002-03-29 & 22:15:09.809 & 22:15:13.250 &    0.011 &    0.343 &    0.074 &    0.041 &    0.076 &    0.014  \\
;;  \hline
;;  2002-05-21 & 21:13:11.610 & 21:14:15.840 &    0.016 &    0.739 &    0.147 &    0.074 &    0.167 &    0.013  \\
;;  \hline
;;  2002-06-29 & 21:09:57.429 & 21:10:26.399 &    0.024 &    0.465 &    0.115 &    0.076 &    0.089 &    0.010  \\
;;  \hline
;;  2002-08-01 & 23:08:31.379 & 23:09:07.282 &    0.009 &    0.417 &    0.067 &    0.040 &    0.066 &    0.007  \\
;;  \hline
;;  2002-09-30 & 07:53:38.919 & 07:54:24.149 &    0.020 &    0.661 &    0.112 &    0.089 &    0.082 &    0.007  \\
;;  \hline
;;  2002-11-09 & 18:27:30.419 & 18:27:49.240 &    0.008 &    0.162 &    0.041 &    0.032 &    0.031 &    0.004  \\
;;  \hline
;;  2003-05-29 & 18:30:49.730 & 18:31:07.827 &    0.020 &    0.257 &    0.077 &    0.063 &    0.048 &    0.007  \\
;;  \hline
;;  2003-06-18 & 04:40:53.679 & 04:42:06.159 &    0.030 &    0.866 &    0.165 &    0.120 &    0.132 &    0.009  \\
;;  \hline
;;  2004-04-12 & 18:28:23.210 & 18:29:46.279 &    0.015 &    0.584 &    0.090 &    0.065 &    0.081 &    0.005  \\
;;  \hline
;;  2005-05-06 & 12:03:02.500 & 12:08:38.930 &    0.011 &    1.252 &    0.079 &    0.049 &    0.118 &    0.004  \\
;;  \hline
;;  2005-05-07 & 18:26:09.069 & 18:26:16.081 &    0.020 &    0.120 &    0.043 &    0.030 &    0.031 &    0.007  \\
;;  \hline
;;  2005-06-16 & 08:07:07.720 & 08:09:10.069 &    0.005 &    0.749 &    0.077 &    0.040 &    0.103 &    0.006  \\
;;  \hline
;;  2005-07-10 & 02:41:17.430 & 02:42:30.726 &    0.006 &    0.229 &    0.046 &    0.025 &    0.042 &    0.003  \\
;;  \hline
;;  2005-08-24 & 05:34:39.140 & 05:35:24.414 &    0.004 &    0.320 &    0.049 &    0.020 &    0.060 &    0.005  \\
;;  \hline
;;  2005-09-02 & 13:48:38.779 & 13:50:16.069 &    0.011 &    0.611 &    0.066 &    0.040 &    0.083 &    0.005  \\
;;  \hline
;;  2006-08-19 & 09:33:17.500 & 09:38:48.400 &    0.022 &    1.818 &    0.260 &    0.161 &    0.285 &    0.009  \\
;;  \hline
;;  2007-08-22 & 04:31:24.700 & 04:34:03.000 &    0.049 &    0.783 &    0.135 &    0.118 &    0.078 &    0.004  \\
;;  \hline
;;  2007-12-17 & 01:52:53.579 & 01:53:18.549 &    0.010 &    0.606 &    0.056 &    0.021 &    0.110 &    0.013  \\
;;  \hline
;;  2008-05-28 & 01:14:59.750 & 01:17:38.161 &    0.010 &    0.433 &    0.050 &    0.032 &    0.049 &    0.002  \\
;;  \hline
;;  2008-06-24 & 18:52:21.700 & 19:10:41.963 &    0.007 &    2.073 &    0.041 &    0.031 &    0.084 &    0.002  \\
;;  \hline
;;  2009-02-03 & 19:21:01.865 & 19:21:03.157 &    0.012 &    0.851 &    0.129 &    0.055 &    0.195 &    0.040  \\
;;  \hline
;;  2009-06-24 & 09:52:07.650 & 09:52:20.400 &    0.018 &    0.261 &    0.094 &    0.065 &    0.071 &    0.012  \\
;;  \hline
;;  2009-06-27 & 11:03:13.559 & 11:04:18.898 &    0.015 &    0.414 &    0.082 &    0.072 &    0.059 &    0.004  \\
;;  \hline
;;  2009-10-21 & 23:13:55.190 & 23:15:09.880 &    0.014 &    0.722 &    0.066 &    0.036 &    0.086 &    0.006  \\
;;  \hline
;;  2010-04-11 & 12:19:16.900 & 12:20:56.220 &    0.006 &    0.816 &    0.086 &    0.054 &    0.102 &    0.006  \\
;;  \hline
;;  2011-02-04 & 01:50:37.319 & 01:50:55.670 &    0.037 &    0.783 &    0.203 &    0.115 &    0.201 &    0.029  \\
;;  \hline
;;  2011-07-11 & 08:26:30.220 & 08:27:25.471 &    0.013 &    0.633 &    0.100 &    0.069 &    0.099 &    0.008  \\
;;  \hline
;;  2011-09-16 & 18:54:08.200 & 18:57:15.299 &    0.038 &    0.342 &    0.118 &    0.107 &    0.049 &    0.002  \\
;;  \hline
;;  2011-09-25 & 10:43:56.410 & 10:46:32.085 &    0.006 &    0.742 &    0.054 &    0.030 &    0.073 &    0.004  \\
;;  \hline
;;  2012-01-21 & 04:00:32.019 & 04:02:01.809 &    0.017 &    0.589 &    0.090 &    0.060 &    0.096 &    0.006  \\
;;  \hline
;;  2012-01-30 & 15:43:03.640 & 15:43:13.309 &    0.008 &    0.116 &    0.029 &    0.019 &    0.023 &    0.005  \\
;;  \hline
;;  2012-06-16 & 19:34:25.569 & 19:34:39.369 &    0.040 &    0.378 &    0.125 &    0.105 &    0.080 &    0.013  \\
;;  \hline
;;  2012-10-08 & 04:11:45.970 & 04:12:14.022 &    0.006 &    0.276 &    0.060 &    0.038 &    0.060 &    0.007  \\
;;  \hline
;;  2012-11-12 & 22:12:34.461 & 22:12:41.579 &    0.008 &    0.345 &    0.096 &    0.064 &    0.104 &    0.024  \\
;;  \hline
;;  2012-11-26 & 04:32:36.150 & 04:32:50.960 &    0.026 &    0.286 &    0.086 &    0.050 &    0.072 &    0.012  \\
;;  \hline
;;  2013-02-13 & 00:46:46.049 & 00:47:45.742 &    0.022 &    0.766 &    0.112 &    0.065 &    0.126 &    0.010  \\
;;  \hline
;;  2013-04-30 & 08:52:30.789 & 08:52:46.417 &    0.020 &    0.170 &    0.064 &    0.054 &    0.033 &    0.005  \\
;;  \hline
;;  2013-06-10 & 02:51:45.099 & 02:52:01.335 &    0.018 &    0.506 &    0.064 &    0.038 &    0.094 &    0.014  \\
;;  \hline
;;  2013-07-12 & 16:42:29.809 & 16:43:28.516 &    0.009 &    1.292 &    0.146 &    0.060 &    0.216 &    0.017  \\
;;  \hline
;;  2013-09-02 & 01:55:13.480 & 01:56:49.119 &    0.020 &    0.562 &    0.108 &    0.077 &    0.089 &    0.006  \\
;;  \hline
;;  2013-10-26 & 21:18:46.200 & 21:26:02.099 &    0.011 &    1.024 &    0.068 &    0.043 &    0.100 &    0.003  \\
;;  \hline
;;  2014-02-13 & 08:53:39.980 & 08:55:28.934 &    0.008 &    0.458 &    0.047 &    0.023 &    0.062 &    0.004  \\
;;  \hline
;;  2014-02-15 & 12:46:04.039 & 12:46:36.901 &    0.008 &    0.316 &    0.056 &    0.047 &    0.052 &    0.006  \\
;;  \hline
;;  2014-02-19 & 03:09:14.809 & 03:09:38.861 &    0.006 &    0.036 &    0.015 &    0.013 &    0.006 &    0.001  \\
;;  \hline
;;  2014-04-19 & 17:46:30.859 & 17:48:25.604 &    0.010 &    1.832 &    0.186 &    0.078 &    0.302 &    0.017  \\
;;  \hline
;;  2014-05-07 & 21:17:03.170 & 21:19:38.779 &    0.015 &    0.433 &    0.075 &    0.050 &    0.071 &    0.003  \\
;;  \hline
;;  2014-05-29 & 08:25:13.950 & 08:26:40.940 &    0.012 &    0.457 &    0.067 &    0.049 &    0.066 &    0.004  \\
;;  \hline
;;  2014-07-14 & 13:37:34.940 & 13:38:08.971 &    0.007 &    0.296 &    0.055 &    0.037 &    0.057 &    0.006  \\
;;  \hline
;;  2015-05-06 & 00:55:30.509 & 00:55:49.854 &    0.004 &    0.509 &    0.053 &    0.012 &    0.110 &    0.015  \\
;;  \hline
;;  2015-06-24 & 13:06:37.990 & 13:07:14.601 &    0.008 &    0.220 &    0.034 &    0.025 &    0.033 &    0.003  \\
;;  \hline
;;  2015-08-15 & 07:43:17.430 & 07:43:40.250 &    0.009 &    0.874 &    0.104 &    0.055 &    0.148 &    0.019  \\
;;  \hline
;;  2016-03-11 & 04:24:15.900 & 04:29:29.400 &    0.007 &    0.350 &    0.043 &    0.028 &    0.043 &    0.001  \\
;;  \hline
;;  2016-03-14 & 16:16:06.680 & 16:16:31.880 &    0.011 &    0.106 &    0.042 &    0.037 &    0.024 &    0.003  \\[-11.5pt]
;;  \hline


nform          = 'f8.3'
texform        = '(";;  ",a10," & ",a12," & ",a12," & ",'+nform[0]+'," & ",'+nform[0]+'," & ",'+nform[0]+'," & ",'+nform[0]+'," & ",'+nform[0]+'," & ",'+nform[0]+',"  \\")'
np             = N_ELEMENTS(prec_tdates)
FOR kk=0L, np[0] - 1L DO BEGIN                                                                              $
  nums0 = REFORM(dB_Bavgupstats[kk,*])                                                                    & $
  PRINT,';;  \hline'                                                                                      & $
  PRINT,prec_tdates[kk],prec_utc_st[kk],prec_utc_en[kk],nums0,FORMAT=texform[0]

;;  ****************************************************************************************************
;;  ***  Need to add [-11.5pt] immediately after last \\ in table to avoid extra stupid-looking row  ***
;;  ****************************************************************************************************
;;
;;  \caption{Whistler Precursor Amplitude Statistics for $\delta B{\scriptstyle_{pk-pk}} / \langle \lvert \mathbf{B}{\scriptstyle_{o}} \rvert \rangle{\scriptstyle_{up}}$} \\  %%  show caption
;;  test & the width & of this & table & by & killing & a & row & here \kill
;;  \hline
;;  \textbf{Date} & \textbf{Start Time} & \textbf{End Time} & $\mathbf{X{\scriptstyle_{\mathbf{min}}}}$ & $\mathbf{X{\scriptstyle_{\mathbf{max}}}}$ & $\bar{\mathbf{X}}$ & $\tilde{\mathbf{X}}$ & $\boldsymbol{\sigma}{\scriptstyle_{\mathbf{x}}}$ & $\boldsymbol{\sigma}{\scriptstyle_{\mathbf{x}}}/\sqrt{\textbf{N}}$  \\
;;  & \textbf{[UTC]} & \textbf{[UTC]} & & & & & &  \\
;;  \hline
;;  \multicolumn{9}{ |c| }{\textbf{Statistics of} $\boldsymbol{\delta}\mathbf{B}{\scriptstyle_{\mathbf{pk-pk}}} \mathbf{/} \boldsymbol{\langle \lvert} \mathbf{B}{\scriptstyle_{\mathbf{o}}} \boldsymbol{\rvert \rangle}{\scriptstyle_{\mathbf{up}}}$ \textbf{for each of the 113 shocks with precursors satisfying:}} \\
;;  \multicolumn{9}{ |c| }{$\langle M{\scriptstyle_{f}} \rangle{\scriptstyle_{up}}$ $\geq$ 1;  1 $\leq$ $\langle M{\scriptstyle_{A}} \rangle{\scriptstyle_{up}}$ $\leq$ 3; 1 $\leq$ $\mathcal{R}$ $\leq$ 3; $\langle \theta{\scriptstyle_{Bn}} \rangle{\scriptstyle_{up}}$ $\geq$ 45$^{\circ}$} \\
;;  \endhead  %%  Specifies rows to appear at the top of every page
;;  \textbf{Date} & \textbf{Start Time} & \textbf{End Time} & $\mathbf{X{\scriptstyle_{\mathbf{min}}}}$ & $\mathbf{X{\scriptstyle_{\mathbf{max}}}}$ & $\bar{\mathbf{X}}$ & $\tilde{\mathbf{X}}$ & $\boldsymbol{\sigma}{\scriptstyle_{\mathbf{x}}}$ & $\boldsymbol{\sigma}{\scriptstyle_{\mathbf{x}}}/\sqrt{\textbf{N}}$  \\
;;  & \textbf{[UTC]} & \textbf{[UTC]} & & & & & &  \\
;;  \hline
;;  \endfoot  %%  Specifies rows to appear at the bottom of every page
;;  \hline
;;  \textbf{Date} & \textbf{Start Time} & \textbf{End Time} & $\mathbf{X{\scriptstyle_{\mathbf{min}}}}$ & $\mathbf{X{\scriptstyle_{\mathbf{max}}}}$ & $\bar{\mathbf{X}}$ & $\tilde{\mathbf{X}}$ & $\boldsymbol{\sigma}{\scriptstyle_{\mathbf{x}}}$ & $\boldsymbol{\sigma}{\scriptstyle_{\mathbf{x}}}/\sqrt{\textbf{N}}$  \\
;;  & \textbf{[UTC]} & \textbf{[UTC]} & & & & & &  \\
;;  \hline
;;  \endlastfoot  %%  Specifies rows to appear at the bottom of every page
;;  \hline
;;  1995-04-17 & 23:32:57.740 & 23:33:07.610 &    0.036 &    0.209 &    0.088 &    0.078 &    0.048 &    0.009  \\
;;  \hline
;;  1995-07-22 & 05:34:15.740 & 05:35:45.049 &    0.014 &    0.771 &    0.093 &    0.048 &    0.131 &    0.008  \\
;;  \hline
;;  1995-08-22 & 12:56:39.240 & 12:56:48.970 &    0.036 &    1.468 &    0.291 &    0.121 &    0.370 &    0.052  \\
;;  \hline
;;  1995-08-24 & 22:10:53.360 & 22:11:04.379 &    0.017 &    0.267 &    0.074 &    0.059 &    0.050 &    0.007  \\
;;  \hline
;;  1995-10-22 & 21:20:09.761 & 21:20:15.694 &    0.012 &    0.485 &    0.095 &    0.043 &    0.097 &    0.016  \\
;;  \hline
;;  1995-12-24 & 05:57:33.368 & 05:57:35.006 &    0.015 &    0.608 &    0.120 &    0.086 &    0.125 &    0.018  \\
;;  \hline
;;  1996-02-06 & 19:14:13.830 & 19:14:25.350 &    0.012 &    0.192 &    0.057 &    0.026 &    0.059 &    0.011  \\
;;  \hline
;;  1996-04-03 & 09:46:57.259 & 09:47:17.037 &    0.012 &    0.591 &    0.050 &    0.032 &    0.072 &    0.007  \\
;;  \hline
;;  1996-04-08 & 02:41:03.620 & 02:41:09.639 &    0.016 &    0.412 &    0.127 &    0.052 &    0.132 &    0.023  \\
;;  \hline
;;  1997-03-15 & 22:29:44.490 & 22:30:32.279 &    0.009 &    0.298 &    0.070 &    0.047 &    0.063 &    0.006  \\
;;  \hline
;;  1997-04-10 & 12:57:53.649 & 12:58:34.480 &    0.009 &    0.102 &    0.039 &    0.032 &    0.025 &    0.002  \\
;;  \hline
;;  1997-10-24 & 11:17:03.750 & 11:18:09.830 &    0.010 &    1.422 &    0.076 &    0.036 &    0.139 &    0.007  \\
;;  \hline
;;  1997-11-01 & 06:14:27.659 & 06:14:45.110 &    0.015 &    0.166 &    0.059 &    0.057 &    0.032 &    0.003  \\
;;  \hline
;;  1997-12-10 & 04:33:03.539 & 04:33:14.666 &    0.010 &    0.700 &    0.155 &    0.062 &    0.201 &    0.037  \\
;;  \hline
;;  1997-12-30 & 01:13:20.450 & 01:13:43.639 &    0.013 &    0.353 &    0.071 &    0.035 &    0.080 &    0.010  \\
;;  \hline
;;  1998-01-06 & 13:28:11.509 & 13:29:00.182 &    0.010 &    0.957 &    0.134 &    0.068 &    0.167 &    0.015  \\
;;  \hline
;;  1998-02-18 & 07:46:50.370 & 07:48:43.870 &    0.004 &    0.764 &    0.092 &    0.054 &    0.103 &    0.006  \\
;;  \hline
;;  1998-05-29 & 15:11:58.159 & 15:12:04.299 &    0.027 &    0.157 &    0.071 &    0.056 &    0.038 &    0.010  \\
;;  \hline
;;  1998-08-06 & 07:14:35.190 & 07:16:07.495 &    0.005 &    0.287 &    0.058 &    0.039 &    0.049 &    0.003  \\
;;  \hline
;;  1998-08-19 & 18:40:34.169 & 18:40:41.519 &    0.033 &    1.063 &    0.353 &    0.337 &    0.297 &    0.068  \\
;;  \hline
;;  1998-11-08 & 04:40:53.240 & 04:41:17.230 &    0.025 &    0.238 &    0.074 &    0.061 &    0.046 &    0.006  \\
;;  \hline
;;  1998-12-28 & 18:19:57.519 & 18:20:16.065 &    0.007 &    0.119 &    0.018 &    0.012 &    0.021 &    0.003  \\
;;  \hline
;;  1999-01-13 & 10:47:36.970 & 10:47:44.669 &    0.027 &    1.592 &    0.383 &    0.076 &    0.471 &    0.105  \\
;;  \hline
;;  1999-02-17 & 07:11:31.720 & 07:12:13.843 &    0.010 &    0.384 &    0.063 &    0.043 &    0.058 &    0.005  \\
;;  \hline
;;  1999-04-16 & 11:13:23.500 & 11:14:12.000 &    0.013 &    0.711 &    0.136 &    0.106 &    0.114 &    0.010  \\
;;  \hline
;;  1999-06-26 & 19:30:24.860 & 19:30:55.759 &    0.012 &    0.893 &    0.128 &    0.086 &    0.140 &    0.015  \\
;;  \hline
;;  1999-08-04 & 01:44:01.429 & 01:44:38.368 &    0.019 &    0.822 &    0.204 &    0.133 &    0.178 &    0.018  \\
;;  \hline
;;  1999-08-23 & 12:09:18.200 & 12:11:14.590 &    0.006 &    0.467 &    0.065 &    0.038 &    0.081 &    0.005  \\
;;  \hline
;;  1999-09-22 & 12:09:24.743 & 12:09:25.473 &    0.011 &    0.475 &    0.120 &    0.097 &    0.131 &    0.027  \\
;;  \hline
;;  1999-10-21 & 02:19:01.000 & 02:20:51.235 &    0.007 &    0.896 &    0.098 &    0.072 &    0.099 &    0.006  \\
;;  \hline
;;  1999-11-05 & 20:01:36.899 & 20:03:09.659 &    0.008 &    0.462 &    0.087 &    0.059 &    0.085 &    0.005  \\
;;  \hline
;;  1999-11-13 & 12:47:31.509 & 12:48:57.250 &    0.009 &    0.274 &    0.047 &    0.035 &    0.039 &    0.003  \\
;;  \hline
;;  2000-02-05 & 15:25:06.629 & 15:26:29.031 &    0.007 &    0.471 &    0.082 &    0.051 &    0.090 &    0.006  \\
;;  \hline
;;  2000-02-14 & 07:12:32.429 & 07:12:59.740 &    0.022 &    1.007 &    0.178 &    0.080 &    0.223 &    0.026  \\
;;  \hline
;;  2000-06-23 & 12:57:16.379 & 12:57:59.327 &    0.012 &    0.539 &    0.137 &    0.095 &    0.120 &    0.011  \\
;;  \hline
;;  2000-07-13 & 09:43:38.389 & 09:43:51.580 &    0.026 &    0.472 &    0.149 &    0.099 &    0.122 &    0.021  \\
;;  \hline
;;  2000-07-26 & 18:59:52.940 & 19:00:14.860 &    0.007 &    0.128 &    0.041 &    0.028 &    0.032 &    0.004  \\
;;  \hline
;;  2000-07-28 & 06:38:15.860 & 06:38:45.817 &    0.009 &    1.014 &    0.129 &    0.071 &    0.159 &    0.018  \\
;;  \hline
;;  2000-08-10 & 05:12:21.080 & 05:13:21.370 &    0.006 &    0.155 &    0.040 &    0.027 &    0.033 &    0.003  \\
;;  \hline
;;  2000-08-11 & 18:49:30.659 & 18:49:34.379 &    0.024 &    0.267 &    0.124 &    0.129 &    0.074 &    0.013  \\
;;  \hline
;;  2000-10-28 & 09:30:28.309 & 09:30:41.879 &    0.009 &    1.228 &    0.223 &    0.062 &    0.364 &    0.061  \\
;;  \hline
;;  2000-10-31 & 17:08:33.149 & 17:09:59.284 &    0.007 &    0.509 &    0.062 &    0.031 &    0.082 &    0.005  \\
;;  \hline
;;  2000-11-06 & 09:29:09.789 & 09:30:20.669 &    0.015 &    0.935 &    0.211 &    0.141 &    0.193 &    0.014  \\
;;  \hline
;;  2000-11-26 & 11:43:20.870 & 11:43:26.710 &    0.013 &    0.435 &    0.076 &    0.049 &    0.090 &    0.018  \\
;;  \hline
;;  2000-11-28 & 05:25:33.700 & 05:27:41.985 &    0.007 &    0.184 &    0.031 &    0.023 &    0.024 &    0.001  \\
;;  \hline
;;  2001-01-17 & 04:07:10.799 & 04:07:53.059 &    0.006 &    0.055 &    0.019 &    0.016 &    0.009 &    0.001  \\
;;  \hline
;;  2001-03-03 & 11:28:22.080 & 11:29:20.899 &    0.018 &    0.843 &    0.125 &    0.074 &    0.144 &    0.011  \\
;;  \hline
;;  2001-03-22 & 13:58:30.230 & 13:59:06.240 &    0.004 &    0.201 &    0.036 &    0.016 &    0.043 &    0.004  \\
;;  \hline
;;  2001-03-27 & 18:07:15.600 & 18:07:48.210 &    0.007 &    0.137 &    0.035 &    0.026 &    0.029 &    0.003  \\
;;  \hline
;;  2001-04-21 & 15:29:02.879 & 15:29:14.123 &    0.012 &    0.065 &    0.024 &    0.019 &    0.013 &    0.002  \\
;;  \hline
;;  2001-05-06 & 09:05:27.789 & 09:06:08.332 &    0.010 &    0.300 &    0.066 &    0.043 &    0.059 &    0.006  \\
;;  \hline
;;  2001-05-12 & 10:01:41.690 & 10:03:14.317 &    0.004 &    0.052 &    0.016 &    0.014 &    0.008 &    0.000  \\
;;  \hline
;;  2001-09-13 & 02:30:10.129 & 02:31:26.029 &    0.006 &    0.144 &    0.030 &    0.023 &    0.022 &    0.002  \\
;;  \hline
;;  2001-10-28 & 03:13:23.950 & 03:13:48.500 &    0.007 &    0.390 &    0.078 &    0.028 &    0.100 &    0.012  \\
;;  \hline
;;  2001-11-30 & 18:15:10.889 & 18:15:45.440 &    0.008 &    0.157 &    0.036 &    0.024 &    0.031 &    0.003  \\
;;  \hline
;;  2001-12-21 & 14:09:42.850 & 14:10:17.090 &    0.005 &    0.088 &    0.031 &    0.024 &    0.020 &    0.002  \\
;;  \hline
;;  2001-12-30 & 20:04:29.870 & 20:05:05.830 &    0.015 &    0.269 &    0.060 &    0.041 &    0.048 &    0.005  \\
;;  \hline
;;  2002-01-17 & 05:26:51.590 & 05:26:56.879 &    0.008 &    0.228 &    0.060 &    0.023 &    0.067 &    0.011  \\
;;  \hline
;;  2002-01-31 & 21:37:31.419 & 21:38:10.404 &    0.013 &    0.179 &    0.072 &    0.058 &    0.040 &    0.006  \\
;;  \hline
;;  2002-03-23 & 11:23:24.620 & 11:24:09.210 &    0.014 &    0.466 &    0.106 &    0.076 &    0.091 &    0.008  \\
;;  \hline
;;  2002-03-29 & 22:15:09.809 & 22:15:13.250 &    0.014 &    0.446 &    0.096 &    0.054 &    0.098 &    0.018  \\
;;  \hline
;;  2002-05-21 & 21:13:11.610 & 21:14:15.840 &    0.014 &    0.625 &    0.124 &    0.063 &    0.141 &    0.011  \\
;;  \hline
;;  2002-06-29 & 21:09:57.429 & 21:10:26.399 &    0.009 &    0.180 &    0.044 &    0.029 &    0.035 &    0.004  \\
;;  \hline
;;  2002-08-01 & 23:08:31.379 & 23:09:07.282 &    0.008 &    0.367 &    0.060 &    0.035 &    0.058 &    0.006  \\
;;  \hline
;;  2002-09-30 & 07:53:38.919 & 07:54:24.149 &    0.012 &    0.391 &    0.066 &    0.052 &    0.049 &    0.004  \\
;;  \hline
;;  2002-11-09 & 18:27:30.419 & 18:27:49.240 &    0.007 &    0.137 &    0.034 &    0.027 &    0.026 &    0.004  \\
;;  \hline
;;  2003-05-29 & 18:30:49.730 & 18:31:07.827 &    0.031 &    0.389 &    0.116 &    0.095 &    0.072 &    0.010  \\
;;  \hline
;;  2003-06-18 & 04:40:53.679 & 04:42:06.159 &    0.018 &    0.501 &    0.096 &    0.069 &    0.076 &    0.005  \\
;;  \hline
;;  2004-04-12 & 18:28:23.210 & 18:29:46.279 &    0.018 &    0.724 &    0.111 &    0.080 &    0.101 &    0.007  \\
;;  \hline
;;  2005-05-06 & 12:03:02.500 & 12:08:38.930 &    0.006 &    0.680 &    0.043 &    0.027 &    0.064 &    0.002  \\
;;  \hline
;;  2005-05-07 & 18:26:09.069 & 18:26:16.081 &    0.007 &    0.040 &    0.014 &    0.010 &    0.010 &    0.002  \\
;;  \hline
;;  2005-06-16 & 08:07:07.720 & 08:09:10.069 &    0.003 &    0.546 &    0.056 &    0.029 &    0.075 &    0.004  \\
;;  \hline
;;  2005-07-10 & 02:41:17.430 & 02:42:30.726 &    0.005 &    0.177 &    0.035 &    0.019 &    0.032 &    0.002  \\
;;  \hline
;;  2005-08-24 & 05:34:39.140 & 05:35:24.414 &    0.004 &    0.362 &    0.056 &    0.023 &    0.067 &    0.006  \\
;;  \hline
;;  2005-09-02 & 13:48:38.779 & 13:50:16.069 &    0.013 &    0.681 &    0.073 &    0.044 &    0.092 &    0.006  \\
;;  \hline
;;  2006-08-19 & 09:33:17.500 & 09:38:48.400 &    0.007 &    0.573 &    0.082 &    0.051 &    0.090 &    0.003  \\
;;  \hline
;;  2007-08-22 & 04:31:24.700 & 04:34:03.000 &    0.011 &    0.183 &    0.032 &    0.028 &    0.018 &    0.001  \\
;;  \hline
;;  2007-12-17 & 01:52:53.579 & 01:53:18.549 &    0.011 &    0.654 &    0.060 &    0.023 &    0.118 &    0.014  \\
;;  \hline
;;  2008-05-28 & 01:14:59.750 & 01:17:38.161 &    0.010 &    0.409 &    0.047 &    0.030 &    0.046 &    0.002  \\
;;  \hline
;;  2008-06-24 & 18:52:21.700 & 19:10:41.963 &    0.004 &    1.254 &    0.025 &    0.019 &    0.051 &    0.001  \\
;;  \hline
;;  2009-02-03 & 19:21:01.865 & 19:21:03.157 &    0.008 &    0.614 &    0.093 &    0.040 &    0.141 &    0.029  \\
;;  \hline
;;  2009-06-24 & 09:52:07.650 & 09:52:20.400 &    0.012 &    0.178 &    0.064 &    0.044 &    0.049 &    0.008  \\
;;  \hline
;;  2009-06-27 & 11:03:13.559 & 11:04:18.898 &    0.008 &    0.209 &    0.041 &    0.036 &    0.030 &    0.002  \\
;;  \hline
;;  2009-10-21 & 23:13:55.190 & 23:15:09.880 &    0.007 &    0.385 &    0.035 &    0.019 &    0.046 &    0.003  \\
;;  \hline
;;  2010-04-11 & 12:19:16.900 & 12:20:56.220 &    0.007 &    0.874 &    0.093 &    0.057 &    0.109 &    0.007  \\
;;  \hline
;;  2011-02-04 & 01:50:37.319 & 01:50:55.670 &    0.031 &    0.657 &    0.170 &    0.097 &    0.169 &    0.024  \\
;;  \hline
;;  2011-07-11 & 08:26:30.220 & 08:27:25.471 &    0.012 &    0.588 &    0.093 &    0.064 &    0.092 &    0.008  \\
;;  \hline
;;  2011-09-16 & 18:54:08.200 & 18:57:15.299 &    0.007 &    0.061 &    0.021 &    0.019 &    0.009 &    0.000  \\
;;  \hline
;;  2011-09-25 & 10:43:56.410 & 10:46:32.085 &    0.005 &    0.610 &    0.045 &    0.025 &    0.060 &    0.003  \\
;;  \hline
;;  2012-01-21 & 04:00:32.019 & 04:02:01.809 &    0.010 &    0.336 &    0.052 &    0.034 &    0.055 &    0.004  \\
;;  \hline
;;  2012-01-30 & 15:43:03.640 & 15:43:13.309 &    0.013 &    0.186 &    0.047 &    0.031 &    0.038 &    0.008  \\
;;  \hline
;;  2012-06-16 & 19:34:25.569 & 19:34:39.369 &    0.039 &    0.369 &    0.122 &    0.103 &    0.078 &    0.013  \\
;;  \hline
;;  2012-10-08 & 04:11:45.970 & 04:12:14.022 &    0.005 &    0.257 &    0.056 &    0.036 &    0.056 &    0.006  \\
;;  \hline
;;  2012-11-12 & 22:12:34.461 & 22:12:41.579 &    0.008 &    0.360 &    0.100 &    0.067 &    0.108 &    0.025  \\
;;  \hline
;;  2012-11-26 & 04:32:36.150 & 04:32:50.960 &    0.024 &    0.273 &    0.082 &    0.048 &    0.069 &    0.011  \\
;;  \hline
;;  2013-02-13 & 00:46:46.049 & 00:47:45.742 &    0.017 &    0.593 &    0.087 &    0.050 &    0.098 &    0.008  \\
;;  \hline
;;  2013-04-30 & 08:52:30.789 & 08:52:46.417 &    0.011 &    0.093 &    0.035 &    0.030 &    0.018 &    0.003  \\
;;  \hline
;;  2013-06-10 & 02:51:45.099 & 02:52:01.335 &    0.010 &    0.279 &    0.035 &    0.021 &    0.052 &    0.008  \\
;;  \hline
;;  2013-07-12 & 16:42:29.809 & 16:43:28.516 &    0.008 &    1.153 &    0.131 &    0.054 &    0.193 &    0.015  \\
;;  \hline
;;  2013-09-02 & 01:55:13.480 & 01:56:49.119 &    0.011 &    0.308 &    0.059 &    0.042 &    0.049 &    0.003  \\
;;  \hline
;;  2013-10-26 & 21:18:46.200 & 21:26:02.099 &    0.006 &    0.520 &    0.034 &    0.022 &    0.051 &    0.001  \\
;;  \hline
;;  2014-02-13 & 08:53:39.980 & 08:55:28.934 &    0.005 &    0.296 &    0.030 &    0.015 &    0.040 &    0.002  \\
;;  \hline
;;  2014-02-15 & 12:46:04.039 & 12:46:36.901 &    0.009 &    0.348 &    0.061 &    0.052 &    0.057 &    0.006  \\
;;  \hline
;;  2014-02-19 & 03:09:14.809 & 03:09:38.861 &    0.005 &    0.028 &    0.011 &    0.010 &    0.004 &    0.001  \\
;;  \hline
;;  2014-04-19 & 17:46:30.859 & 17:48:25.604 &    0.006 &    1.130 &    0.115 &    0.048 &    0.187 &    0.011  \\
;;  \hline
;;  2014-05-07 & 21:17:03.170 & 21:19:38.779 &    0.006 &    0.192 &    0.033 &    0.022 &    0.031 &    0.002  \\
;;  \hline
;;  2014-05-29 & 08:25:13.950 & 08:26:40.940 &    0.006 &    0.246 &    0.036 &    0.026 &    0.036 &    0.002  \\
;;  \hline
;;  2014-07-14 & 13:37:34.940 & 13:38:08.971 &    0.005 &    0.218 &    0.041 &    0.028 &    0.042 &    0.004  \\
;;  \hline
;;  2015-05-06 & 00:55:30.509 & 00:55:49.854 &    0.006 &    0.642 &    0.066 &    0.015 &    0.139 &    0.019  \\
;;  \hline
;;  2015-06-24 & 13:06:37.990 & 13:07:14.601 &    0.007 &    0.194 &    0.030 &    0.022 &    0.029 &    0.003  \\
;;  \hline
;;  2015-08-15 & 07:43:17.430 & 07:43:40.250 &    0.010 &    1.031 &    0.123 &    0.065 &    0.175 &    0.022  \\
;;  \hline
;;  2016-03-11 & 04:24:15.900 & 04:29:29.400 &    0.005 &    0.266 &    0.032 &    0.021 &    0.032 &    0.001  \\
;;  \hline
;;  2016-03-14 & 16:16:06.680 & 16:16:31.880 &    0.009 &    0.084 &    0.033 &    0.030 &    0.019 &    0.002  \\[-11.5pt]
;;  \hline



nform          = 'f8.3'
texform        = '(";;  ",a10," & ",a12," & ",a12," & ",'+nform[0]+'," & ",'+nform[0]+'," & ",'+nform[0]+'," & ",'+nform[0]+'," & ",'+nform[0]+'," & ",'+nform[0]+',"  \\")'
np             = N_ELEMENTS(prec_tdates)
FOR kk=0L, np[0] - 1L DO BEGIN                                                                              $
  nums0 = REFORM(dB_val___stats[kk,*])                                                                    & $
  PRINT,';;  \hline'                                                                                      & $
  PRINT,prec_tdates[kk],prec_utc_st[kk],prec_utc_en[kk],nums0,FORMAT=texform[0]


;;  ****************************************************************************************************
;;  ***  Need to add [-11.5pt] immediately after last \\ in table to avoid extra stupid-looking row  ***
;;  ****************************************************************************************************
;;
;;  \caption{Whistler Precursor Amplitude Statistics for $\delta B{\scriptstyle_{pk-pk}}$} \\  %%  show caption
;;  test & the width & of this & table & by & killing & a & row & here \kill
;;  \hline
;;  \textbf{Date} & \textbf{Start Time} & \textbf{End Time} & $\mathbf{X{\scriptstyle_{\mathbf{min}}}}$ & $\mathbf{X{\scriptstyle_{\mathbf{max}}}}$ & $\bar{\mathbf{X}}$ & $\tilde{\mathbf{X}}$ & $\boldsymbol{\sigma}{\scriptstyle_{\mathbf{x}}}$ & $\boldsymbol{\sigma}{\scriptstyle_{\mathbf{x}}}/\sqrt{\textbf{N}}$  \\
;;  & \textbf{[UTC]} & \textbf{[UTC]} & & & & & &  \\
;;  \hline
;;  \multicolumn{9}{ |c| }{\textbf{Statistics of} $\boldsymbol{\delta}\mathbf{B}{\scriptstyle_{\mathbf{pk-pk}}}$ \textbf{[nT] for each of the 113 shocks with precursors satisfying:}} \\
;;  \multicolumn{9}{ |c| }{$\langle M{\scriptstyle_{f}} \rangle{\scriptstyle_{up}}$ $\geq$ 1;  1 $\leq$ $\langle M{\scriptstyle_{A}} \rangle{\scriptstyle_{up}}$ $\leq$ 3; 1 $\leq$ $\mathcal{R}$ $\leq$ 3; $\langle \theta{\scriptstyle_{Bn}} \rangle{\scriptstyle_{up}}$ $\geq$ 45$^{\circ}$} \\
;;  \endhead  %%  Specifies rows to appear at the top of every page
;;  \textbf{Date} & \textbf{Start Time} & \textbf{End Time} & $\mathbf{X{\scriptstyle_{\mathbf{min}}}}$ & $\mathbf{X{\scriptstyle_{\mathbf{max}}}}$ & $\bar{\mathbf{X}}$ & $\tilde{\mathbf{X}}$ & $\boldsymbol{\sigma}{\scriptstyle_{\mathbf{x}}}$ & $\boldsymbol{\sigma}{\scriptstyle_{\mathbf{x}}}/\sqrt{\textbf{N}}$  \\
;;  & \textbf{[UTC]} & \textbf{[UTC]} & & & & & &  \\
;;  \hline
;;  \endfoot  %%  Specifies rows to appear at the bottom of every page
;;  \hline
;;  \textbf{Date} & \textbf{Start Time} & \textbf{End Time} & $\mathbf{X{\scriptstyle_{\mathbf{min}}}}$ & $\mathbf{X{\scriptstyle_{\mathbf{max}}}}$ & $\bar{\mathbf{X}}$ & $\tilde{\mathbf{X}}$ & $\boldsymbol{\sigma}{\scriptstyle_{\mathbf{x}}}$ & $\boldsymbol{\sigma}{\scriptstyle_{\mathbf{x}}}/\sqrt{\textbf{N}}$  \\
;;  & \textbf{[UTC]} & \textbf{[UTC]} & & & & & &  \\
;;  \hline
;;  \endlastfoot  %%  Specifies rows to appear at the bottom of every page
;;  \hline
;;  1995-04-17 & 23:32:57.740 & 23:33:07.610 &    0.280 &    1.629 &    0.685 &    0.610 &    0.373 &    0.073  \\
;;  \hline
;;  1995-07-22 & 05:34:15.740 & 05:35:45.049 &    0.046 &    2.603 &    0.314 &    0.163 &    0.443 &    0.029  \\
;;  \hline
;;  1995-08-22 & 12:56:39.240 & 12:56:48.970 &    0.076 &    3.099 &    0.615 &    0.256 &    0.781 &    0.109  \\
;;  \hline
;;  1995-08-24 & 22:10:53.360 & 22:11:04.379 &    0.115 &    1.766 &    0.492 &    0.391 &    0.333 &    0.043  \\
;;  \hline
;;  1995-10-22 & 21:20:09.761 & 21:20:15.694 &    0.051 &    2.143 &    0.419 &    0.188 &    0.430 &    0.071  \\
;;  \hline
;;  1995-12-24 & 05:57:33.368 & 05:57:35.006 &    0.094 &    3.848 &    0.758 &    0.543 &    0.794 &    0.111  \\
;;  \hline
;;  1996-02-06 & 19:14:13.830 & 19:14:25.350 &    0.048 &    0.742 &    0.222 &    0.102 &    0.229 &    0.042  \\
;;  \hline
;;  1996-04-03 & 09:46:57.259 & 09:47:17.037 &    0.051 &    2.505 &    0.213 &    0.134 &    0.305 &    0.030  \\
;;  \hline
;;  1996-04-08 & 02:41:03.620 & 02:41:09.639 &    0.093 &    2.344 &    0.722 &    0.297 &    0.750 &    0.133  \\
;;  \hline
;;  1997-03-15 & 22:29:44.490 & 22:30:32.279 &    0.043 &    1.496 &    0.350 &    0.238 &    0.317 &    0.028  \\
;;  \hline
;;  1997-04-10 & 12:57:53.649 & 12:58:34.480 &    0.076 &    0.870 &    0.329 &    0.275 &    0.211 &    0.020  \\
;;  \hline
;;  1997-10-24 & 11:17:03.750 & 11:18:09.830 &    0.087 &   12.996 &    0.690 &    0.326 &    1.267 &    0.067  \\
;;  \hline
;;  1997-11-01 & 06:14:27.659 & 06:14:45.110 &    0.086 &    0.977 &    0.345 &    0.334 &    0.190 &    0.020  \\
;;  \hline
;;  1997-12-10 & 04:33:03.539 & 04:33:14.666 &    0.069 &    4.975 &    1.101 &    0.441 &    1.425 &    0.265  \\
;;  \hline
;;  1997-12-30 & 01:13:20.450 & 01:13:43.639 &    0.068 &    1.897 &    0.380 &    0.188 &    0.431 &    0.055  \\
;;  \hline
;;  1998-01-06 & 13:28:11.509 & 13:29:00.182 &    0.063 &    6.256 &    0.877 &    0.443 &    1.089 &    0.095  \\
;;  \hline
;;  1998-02-18 & 07:46:50.370 & 07:48:43.870 &    0.059 &   11.886 &    1.433 &    0.845 &    1.597 &    0.091  \\
;;  \hline
;;  1998-05-29 & 15:11:58.159 & 15:12:04.299 &    0.309 &    1.818 &    0.829 &    0.649 &    0.437 &    0.113  \\
;;  \hline
;;  1998-08-06 & 07:14:35.190 & 07:16:07.495 &    0.055 &    2.958 &    0.595 &    0.400 &    0.509 &    0.032  \\
;;  \hline
;;  1998-08-19 & 18:40:34.169 & 18:40:41.519 &    0.117 &    3.760 &    1.247 &    1.192 &    1.051 &    0.241  \\
;;  \hline
;;  1998-11-08 & 04:40:53.240 & 04:41:17.230 &    0.440 &    4.137 &    1.290 &    1.066 &    0.796 &    0.100  \\
;;  \hline
;;  1998-12-28 & 18:19:57.519 & 18:20:16.065 &    0.045 &    0.818 &    0.125 &    0.081 &    0.144 &    0.021  \\
;;  \hline
;;  1999-01-13 & 10:47:36.970 & 10:47:44.669 &    0.136 &    8.058 &    1.940 &    0.385 &    2.382 &    0.533  \\
;;  \hline
;;  1999-02-17 & 07:11:31.720 & 07:12:13.843 &    0.067 &    2.687 &    0.438 &    0.302 &    0.405 &    0.038  \\
;;  \hline
;;  1999-04-16 & 11:13:23.500 & 11:14:12.000 &    0.089 &    4.689 &    0.898 &    0.699 &    0.749 &    0.065  \\
;;  \hline
;;  1999-06-26 & 19:30:24.860 & 19:30:55.759 &    0.145 &   10.584 &    1.512 &    1.015 &    1.661 &    0.182  \\
;;  \hline
;;  1999-08-04 & 01:44:01.429 & 01:44:38.368 &    0.118 &    5.121 &    1.268 &    0.831 &    1.109 &    0.111  \\
;;  \hline
;;  1999-08-23 & 12:09:18.200 & 12:11:14.590 &    0.051 &    3.817 &    0.534 &    0.308 &    0.658 &    0.037  \\
;;  \hline
;;  1999-09-22 & 12:09:24.743 & 12:09:25.473 &    0.129 &    5.357 &    1.356 &    1.098 &    1.481 &    0.309  \\
;;  \hline
;;  1999-10-21 & 02:19:01.000 & 02:20:51.235 &    0.061 &    8.216 &    0.899 &    0.662 &    0.912 &    0.053  \\
;;  \hline
;;  1999-11-05 & 20:01:36.899 & 20:03:09.659 &    0.053 &    3.110 &    0.586 &    0.401 &    0.574 &    0.036  \\
;;  \hline
;;  1999-11-13 & 12:47:31.509 & 12:48:57.250 &    0.058 &    1.778 &    0.304 &    0.226 &    0.252 &    0.017  \\
;;  \hline
;;  2000-02-05 & 15:25:06.629 & 15:26:29.031 &    0.039 &    2.765 &    0.482 &    0.299 &    0.528 &    0.035  \\
;;  \hline
;;  2000-02-14 & 07:12:32.429 & 07:12:59.740 &    0.127 &    5.888 &    1.044 &    0.466 &    1.305 &    0.153  \\
;;  \hline
;;  2000-06-23 & 12:57:16.379 & 12:57:59.327 &    0.087 &    4.056 &    1.033 &    0.716 &    0.905 &    0.084  \\
;;  \hline
;;  2000-07-13 & 09:43:38.389 & 09:43:51.580 &    0.153 &    2.804 &    0.888 &    0.587 &    0.728 &    0.123  \\
;;  \hline
;;  2000-07-26 & 18:59:52.940 & 19:00:14.860 &    0.043 &    0.742 &    0.235 &    0.161 &    0.184 &    0.024  \\
;;  \hline
;;  2000-07-28 & 06:38:15.860 & 06:38:45.817 &    0.080 &    8.692 &    1.106 &    0.612 &    1.363 &    0.152  \\
;;  \hline
;;  2000-08-10 & 05:12:21.080 & 05:13:21.370 &    0.041 &    1.026 &    0.263 &    0.181 &    0.218 &    0.017  \\
;;  \hline
;;  2000-08-11 & 18:49:30.659 & 18:49:34.379 &    0.228 &    2.507 &    1.168 &    1.207 &    0.692 &    0.126  \\
;;  \hline
;;  2000-10-28 & 09:30:28.309 & 09:30:41.879 &    0.062 &    8.263 &    1.499 &    0.418 &    2.446 &    0.408  \\
;;  \hline
;;  2000-10-31 & 17:08:33.149 & 17:09:59.284 &    0.053 &    3.767 &    0.460 &    0.227 &    0.606 &    0.040  \\
;;  \hline
;;  2000-11-06 & 09:29:09.789 & 09:30:20.669 &    0.072 &    4.585 &    1.036 &    0.694 &    0.945 &    0.068  \\
;;  \hline
;;  2000-11-26 & 11:43:20.870 & 11:43:26.710 &    0.116 &    3.998 &    0.701 &    0.453 &    0.832 &    0.163  \\
;;  \hline
;;  2000-11-28 & 05:25:33.700 & 05:27:41.985 &    0.044 &    1.214 &    0.205 &    0.155 &    0.156 &    0.008  \\
;;  \hline
;;  2001-01-17 & 04:07:10.799 & 04:07:53.059 &    0.029 &    0.279 &    0.095 &    0.081 &    0.044 &    0.004  \\
;;  \hline
;;  2001-03-03 & 11:28:22.080 & 11:29:20.899 &    0.071 &    3.307 &    0.492 &    0.291 &    0.565 &    0.045  \\
;;  \hline
;;  2001-03-22 & 13:58:30.230 & 13:59:06.240 &    0.045 &    2.000 &    0.354 &    0.162 &    0.425 &    0.043  \\
;;  \hline
;;  2001-03-27 & 18:07:15.600 & 18:07:48.210 &    0.076 &    1.438 &    0.369 &    0.275 &    0.305 &    0.033  \\
;;  \hline
;;  2001-04-21 & 15:29:02.879 & 15:29:14.123 &    0.043 &    0.226 &    0.084 &    0.068 &    0.046 &    0.009  \\
;;  \hline
;;  2001-05-06 & 09:05:27.789 & 09:06:08.332 &    0.049 &    1.478 &    0.325 &    0.212 &    0.292 &    0.028  \\
;;  \hline
;;  2001-05-12 & 10:01:41.690 & 10:03:14.317 &    0.046 &    0.648 &    0.197 &    0.178 &    0.096 &    0.006  \\
;;  \hline
;;  2001-09-13 & 02:30:10.129 & 02:31:26.029 &    0.051 &    1.206 &    0.250 &    0.196 &    0.187 &    0.013  \\
;;  \hline
;;  2001-10-28 & 03:13:23.950 & 03:13:48.500 &    0.055 &    2.958 &    0.593 &    0.211 &    0.760 &    0.094  \\
;;  \hline
;;  2001-11-30 & 18:15:10.889 & 18:15:45.440 &    0.031 &    0.572 &    0.131 &    0.088 &    0.113 &    0.012  \\
;;  \hline
;;  2001-12-21 & 14:09:42.850 & 14:10:17.090 &    0.042 &    0.786 &    0.280 &    0.218 &    0.178 &    0.019  \\
;;  \hline
;;  2001-12-30 & 20:04:29.870 & 20:05:05.830 &    0.170 &    3.072 &    0.682 &    0.467 &    0.551 &    0.056  \\
;;  \hline
;;  2002-01-17 & 05:26:51.590 & 05:26:56.879 &    0.052 &    1.451 &    0.380 &    0.143 &    0.429 &    0.072  \\
;;  \hline
;;  2002-01-31 & 21:37:31.419 & 21:38:10.404 &    0.075 &    1.050 &    0.425 &    0.341 &    0.234 &    0.032  \\
;;  \hline
;;  2002-03-23 & 11:23:24.620 & 11:24:09.210 &    0.047 &    1.590 &    0.361 &    0.259 &    0.312 &    0.028  \\
;;  \hline
;;  2002-03-29 & 22:15:09.809 & 22:15:13.250 &    0.076 &    2.430 &    0.521 &    0.293 &    0.537 &    0.098  \\
;;  \hline
;;  2002-05-21 & 21:13:11.610 & 21:14:15.840 &    0.059 &    2.683 &    0.533 &    0.269 &    0.605 &    0.046  \\
;;  \hline
;;  2002-06-29 & 21:09:57.429 & 21:10:26.399 &    0.056 &    1.083 &    0.267 &    0.177 &    0.208 &    0.024  \\
;;  \hline
;;  2002-08-01 & 23:08:31.379 & 23:09:07.282 &    0.061 &    2.984 &    0.483 &    0.285 &    0.471 &    0.048  \\
;;  \hline
;;  2002-09-30 & 07:53:38.919 & 07:54:24.149 &    0.161 &    5.239 &    0.889 &    0.702 &    0.653 &    0.059  \\
;;  \hline
;;  2002-11-09 & 18:27:30.419 & 18:27:49.240 &    0.047 &    0.919 &    0.231 &    0.185 &    0.176 &    0.025  \\
;;  \hline
;;  2003-05-29 & 18:30:49.730 & 18:31:07.827 &    0.438 &    5.502 &    1.647 &    1.344 &    1.022 &    0.147  \\
;;  \hline
;;  2003-06-18 & 04:40:53.679 & 04:42:06.159 &    0.186 &    5.275 &    1.008 &    0.731 &    0.805 &    0.057  \\
;;  \hline
;;  2004-04-12 & 18:28:23.210 & 18:29:46.279 &    0.077 &    3.030 &    0.464 &    0.337 &    0.421 &    0.028  \\
;;  \hline
;;  2005-05-06 & 12:03:02.500 & 12:08:38.930 &    0.026 &    3.025 &    0.191 &    0.120 &    0.286 &    0.009  \\
;;  \hline
;;  2005-05-07 & 18:26:09.069 & 18:26:16.081 &    0.086 &    0.528 &    0.189 &    0.130 &    0.135 &    0.032  \\
;;  \hline
;;  2005-06-16 & 08:07:07.720 & 08:09:10.069 &    0.039 &    6.456 &    0.660 &    0.341 &    0.889 &    0.049  \\
;;  \hline
;;  2005-07-10 & 02:41:17.430 & 02:42:30.726 &    0.051 &    1.909 &    0.381 &    0.208 &    0.350 &    0.025  \\
;;  \hline
;;  2005-08-24 & 05:34:39.140 & 05:35:24.414 &    0.046 &    3.754 &    0.575 &    0.234 &    0.699 &    0.063  \\
;;  \hline
;;  2005-09-02 & 13:48:38.779 & 13:50:16.069 &    0.077 &    4.123 &    0.444 &    0.268 &    0.559 &    0.034  \\
;;  \hline
;;  2006-08-19 & 09:33:17.500 & 09:38:48.400 &    0.054 &    4.395 &    0.628 &    0.389 &    0.688 &    0.023  \\
;;  \hline
;;  2007-08-22 & 04:31:24.700 & 04:34:03.000 &    0.028 &    0.441 &    0.076 &    0.067 &    0.044 &    0.002  \\
;;  \hline
;;  2007-12-17 & 01:52:53.579 & 01:53:18.549 &    0.039 &    2.329 &    0.214 &    0.080 &    0.422 &    0.052  \\
;;  \hline
;;  2008-05-28 & 01:14:59.750 & 01:17:38.161 &    0.037 &    1.591 &    0.183 &    0.119 &    0.179 &    0.009  \\
;;  \hline
;;  2008-06-24 & 18:52:21.700 & 19:10:41.963 &    0.014 &    4.473 &    0.089 &    0.067 &    0.181 &    0.003  \\
;;  \hline
;;  2009-02-03 & 19:21:01.865 & 19:21:03.157 &    0.039 &    2.844 &    0.430 &    0.184 &    0.651 &    0.133  \\
;;  \hline
;;  2009-06-24 & 09:52:07.650 & 09:52:20.400 &    0.057 &    0.819 &    0.296 &    0.204 &    0.224 &    0.038  \\
;;  \hline
;;  2009-06-27 & 11:03:13.559 & 11:04:18.898 &    0.029 &    0.790 &    0.156 &    0.137 &    0.113 &    0.009  \\
;;  \hline
;;  2009-10-21 & 23:13:55.190 & 23:15:09.880 &    0.025 &    1.335 &    0.122 &    0.066 &    0.160 &    0.011  \\
;;  \hline
;;  2010-04-11 & 12:19:16.900 & 12:20:56.220 &    0.032 &    4.005 &    0.424 &    0.263 &    0.499 &    0.030  \\
;;  \hline
;;  2011-02-04 & 01:50:37.319 & 01:50:55.670 &    0.079 &    1.651 &    0.427 &    0.243 &    0.425 &    0.061  \\
;;  \hline
;;  2011-07-11 & 08:26:30.220 & 08:27:25.471 &    0.066 &    3.179 &    0.504 &    0.347 &    0.499 &    0.041  \\
;;  \hline
;;  2011-09-16 & 18:54:08.200 & 18:57:15.299 &    0.023 &    0.210 &    0.072 &    0.065 &    0.030 &    0.001  \\
;;  \hline
;;  2011-09-25 & 10:43:56.410 & 10:46:32.085 &    0.031 &    3.731 &    0.273 &    0.153 &    0.368 &    0.018  \\
;;  \hline
;;  2012-01-21 & 04:00:32.019 & 04:02:01.809 &    0.045 &    1.526 &    0.234 &    0.156 &    0.250 &    0.016  \\
;;  \hline
;;  2012-01-30 & 15:43:03.640 & 15:43:13.309 &    0.039 &    0.563 &    0.142 &    0.093 &    0.114 &    0.023  \\
;;  \hline
;;  2012-06-16 & 19:34:25.569 & 19:34:39.369 &    0.313 &    2.931 &    0.967 &    0.817 &    0.620 &    0.103  \\
;;  \hline
;;  2012-10-08 & 04:11:45.970 & 04:12:14.022 &    0.043 &    2.092 &    0.456 &    0.291 &    0.454 &    0.052  \\
;;  \hline
;;  2012-11-12 & 22:12:34.461 & 22:12:41.579 &    0.061 &    2.726 &    0.758 &    0.506 &    0.818 &    0.193  \\
;;  \hline
;;  2012-11-26 & 04:32:36.150 & 04:32:50.960 &    0.117 &    1.313 &    0.393 &    0.231 &    0.333 &    0.053  \\
;;  \hline
;;  2013-02-13 & 00:46:46.049 & 00:47:45.742 &    0.059 &    2.099 &    0.306 &    0.178 &    0.346 &    0.027  \\
;;  \hline
;;  2013-04-30 & 08:52:30.789 & 08:52:46.417 &    0.053 &    0.457 &    0.172 &    0.146 &    0.090 &    0.014  \\
;;  \hline
;;  2013-06-10 & 02:51:45.099 & 02:52:01.335 &    0.041 &    1.131 &    0.144 &    0.086 &    0.210 &    0.032  \\
;;  \hline
;;  2013-07-12 & 16:42:29.809 & 16:43:28.516 &    0.040 &    5.928 &    0.672 &    0.276 &    0.991 &    0.079  \\
;;  \hline
;;  2013-09-02 & 01:55:13.480 & 01:56:49.119 &    0.032 &    0.921 &    0.177 &    0.126 &    0.146 &    0.009  \\
;;  \hline
;;  2013-10-26 & 21:18:46.200 & 21:26:02.099 &    0.023 &    2.187 &    0.144 &    0.092 &    0.213 &    0.006  \\
;;  \hline
;;  2014-02-13 & 08:53:39.980 & 08:55:28.934 &    0.028 &    1.699 &    0.174 &    0.085 &    0.229 &    0.013  \\
;;  \hline
;;  2014-02-15 & 12:46:04.039 & 12:46:36.901 &    0.058 &    2.329 &    0.411 &    0.349 &    0.385 &    0.041  \\
;;  \hline
;;  2014-02-19 & 03:09:14.809 & 03:09:38.861 &    0.042 &    0.234 &    0.095 &    0.087 &    0.038 &    0.005  \\
;;  \hline
;;  2014-04-19 & 17:46:30.859 & 17:48:25.604 &    0.034 &    6.223 &    0.632 &    0.265 &    1.027 &    0.058  \\
;;  \hline
;;  2014-05-07 & 21:17:03.170 & 21:19:38.779 &    0.031 &    0.914 &    0.159 &    0.106 &    0.149 &    0.007  \\
;;  \hline
;;  2014-05-29 & 08:25:13.950 & 08:26:40.940 &    0.030 &    1.165 &    0.172 &    0.124 &    0.168 &    0.011  \\
;;  \hline
;;  2014-07-14 & 13:37:34.940 & 13:38:08.971 &    0.044 &    1.740 &    0.324 &    0.220 &    0.336 &    0.035  \\
;;  \hline
;;  2015-05-06 & 00:55:30.509 & 00:55:49.854 &    0.032 &    3.674 &    0.380 &    0.084 &    0.796 &    0.110  \\
;;  \hline
;;  2015-06-24 & 13:06:37.990 & 13:07:14.601 &    0.039 &    1.066 &    0.165 &    0.121 &    0.161 &    0.016  \\
;;  \hline
;;  2015-08-15 & 07:43:17.430 & 07:43:40.250 &    0.113 &   11.120 &    1.325 &    0.700 &    1.887 &    0.242  \\
;;  \hline
;;  2016-03-11 & 04:24:15.900 & 04:29:29.400 &    0.028 &    1.476 &    0.179 &    0.119 &    0.180 &    0.006  \\
;;  \hline
;;  2016-03-14 & 16:16:06.680 & 16:16:31.880 &    0.050 &    0.481 &    0.191 &    0.170 &    0.108 &    0.013  \\[-11.5pt]
;;  \hline

;;----------------------------------------------------------------------------------------
;;  Define all relevant variable and uncertainties
;;----------------------------------------------------------------------------------------
;;  Values
betaupvd       = mach_rat_stru.GOOD_QP.BETAUP     ;;  upstream beta [value,uncertainty]
thetbnvd       = mach_rat_stru.GOOD_QP.THEBN      ;;  shock normal angle [rad]
MachAuvd       = mach_rat_stru.GOOD_QP.MAUP       ;;  upstream Alfvenic Mach number
Machfuvd       = mach_rat_stru.GOOD_QP.MFUP       ;;  upstream fast mode Mach number
MfMcruvd       = mach_rat_stru.GOOD_QP.MF_MCEK84  ;;  Mf/Mcr
MfMwwuvd       = mach_rat_stru.GOOD_QP.MF_MWWK02  ;;  Mf/Mww
MfMgruvd       = mach_rat_stru.GOOD_QP.MF_MGRK02  ;;  Mf/Mgr
MfMnwuvd       = mach_rat_stru.GOOD_QP.MF_MNWK02  ;;  Mf/Mnw
;;
;;  Parameters for Table 1:
;;    Ramp Time  Method  Vshn  <ni>_up  <Bo>_up  MA_up  Mf_up  Whistler
;;      [UTC]           [km/s]  [/cc]     [nT]                 [2 letter]
tramp_str      = time_string(midt__unix,PREC=3)   ;;  UTC time at center of ramp
tramp_str[good] = time_string(tura_mid,PREC=3)    ;;  Fix for ramps we know
ww_meth        = rhmeth_bst[ind1]
Vshn           = vshn___up[ind1]
d_Vshn         = d_vshn___up[ind1]
Niup           = ni_avg_up[ind1]
d_niup         = d_ni_avg_up[ind1]
Boup           = bo_mag_up[ind1]
d_boup         = d_bo_mag_up[ind1]
MAup           = MachAuvd[*,0]
d_MAup         = MachAuvd[*,1]
Mfup           = Machfuvd[*,0]
d_Mfup         = Machfuvd[*,1]
whistler       = whpre_yn

nform          = 'f9.2,"$\pm$",f6.2'
texform        = '(";;  ",a23," & ",a7," & ",'+nform[0]+'," & ",'+nform[0]+'," & ",'+nform[0]+'," & ",'+nform[0]+'," & ",'+nform[0]+'," & ",a4,"  \\")'
np             = N_ELEMENTS(tramp_str)
FOR kk=0L, np[0] - 1L DO BEGIN                                                                              $
  nums0 = [Vshn[kk],d_Vshn[kk],Niup[kk],d_Niup[kk],Boup[kk],d_Boup[kk]]                                   & $
  nums1 = [MAup[kk],d_MAup[kk],Mfup[kk],d_Mfup[kk]]                                                       & $
  PRINT,';;  \hline'                                                                                      & $
  PRINT,tramp_str[kk],ww_meth[kk],nums0,nums1,whistler[kk],FORMAT=texform[0]


;;  ****************************************************************************************************
;;  ***  Need to add [-11.5pt] immediately after last \\ in table to avoid extra stupid-looking row  ***
;;  ****************************************************************************************************
;;
;;  \caption{IP Shock Parameters and Whistler Observation Designation} \\  %%  show caption
;;  test the width & of & this & table & by & killing & a & row \kill
;;  \hline
;;  \textbf{Ramp Time} & \textbf{RH} & $\langle \lvert \mathbf{V}{\scriptstyle_{\mathbf{shn}}} \rvert \rangle{\scriptstyle_{\mathbf{up}}}$ & $\langle \mathbf{n}{\scriptstyle_{\mathbf{i}}} \rangle{\scriptstyle_{\mathbf{up}}}$ & $\langle \lvert \mathbf{B}{\scriptstyle_{\mathbf{o}}} \rvert \rangle{\scriptstyle_{up}}$ & $\langle \mathbf{M}{\scriptstyle_{\mathbf{A}}} \rangle{\scriptstyle_{\mathbf{up}}}$ & $\langle \mathbf{M}{\scriptstyle_{\mathbf{f}}} \rangle{\scriptstyle_{\mathbf{up}}}$ & \textbf{Shock}  \\
;;  \textbf{[UTC]} & \textbf{Meth.} & \textbf{[km/s]} & \textbf{[}$\mathbf{cm}^{\mathbf{-3}}$\textbf{]} & \textbf{[nT]} &  &  & \textbf{Label}  \\
;;  \endhead  %%  Specifies rows to appear at the top of every page
;;  \textbf{Ramp Time} & \textbf{RH} & $\langle \lvert \mathbf{V}{\scriptstyle_{\mathbf{shn}}} \rvert \rangle{\scriptstyle_{\mathbf{up}}}$ & $\langle \mathbf{n}{\scriptstyle_{\mathbf{i}}} \rangle{\scriptstyle_{\mathbf{up}}}$ & $\langle \lvert \mathbf{B}{\scriptstyle_{\mathbf{o}}} \rvert \rangle{\scriptstyle_{up}}$ & $\langle \mathbf{M}{\scriptstyle_{\mathbf{A}}} \rangle{\scriptstyle_{\mathbf{up}}}$ & $\langle \mathbf{M}{\scriptstyle_{\mathbf{f}}} \rangle{\scriptstyle_{\mathbf{up}}}$ & \textbf{Shock}  \\
;;  \textbf{[UTC]} & \textbf{Meth.} & \textbf{[km/s]} & \textbf{[}$\mathbf{cm}^{\mathbf{-3}}$\textbf{]} & \textbf{[nT]} &  &  & \textbf{Label}  \\
;;  \hline
;;  \endfoot  %%  Specifies rows to appear at the bottom of every page
;;  \hline
;;  1995-03-04/00:36:58.500 &    RH08 &    380.20$\pm$  8.40 &      5.20$\pm$  0.30 &      3.91$\pm$  0.15 &      2.60$\pm$  0.17 &      1.96$\pm$  0.09 &   MU  \\
;;  \hline
;;  1995-04-17/23:33:07.755 &    RH08 &    389.20$\pm$  4.40 &     14.40$\pm$  0.20 &      7.79$\pm$  0.24 &      1.29$\pm$  0.02 &      1.14$\pm$  0.01 &   YU  \\
;;  \hline
;;  1995-07-22/05:35:45.354 &    RH08 &      9.30$\pm$  6.10 &      3.80$\pm$  0.20 &      3.38$\pm$  0.16 &      1.38$\pm$  0.09 &      1.22$\pm$  0.04 &   YP  \\
;;  \hline
;;  1995-08-22/12:56:49.213 &    RH08 &    381.00$\pm$  5.30 &      3.40$\pm$  0.20 &      2.11$\pm$  0.13 &      2.57$\pm$  0.13 &      1.82$\pm$  0.04 &   YG  \\
;;  \hline
;;  1995-08-24/22:11:04.526 &    RH08 &    387.70$\pm$ 13.00 &     20.40$\pm$  0.80 &      6.61$\pm$  0.46 &      2.49$\pm$  0.10 &      2.01$\pm$  0.05 &   YU  \\
;;  \hline
;;  1995-09-14/21:24:55.549 &    RH08 &    328.40$\pm$ 17.80 &      3.00$\pm$  0.20 &      2.91$\pm$  0.31 &      1.99$\pm$  0.18 &      1.50$\pm$  0.09 &   NN  \\
;;  \hline
;;  1995-10-22/21:20:15.947 &    RH08 &    333.00$\pm$ 14.10 &      5.40$\pm$  0.30 &      4.42$\pm$  0.12 &      2.72$\pm$  0.15 &      2.06$\pm$  0.10 &   YU  \\
;;  \hline
;;  1995-12-24/05:57:35.591 &    RH08 &    422.80$\pm$ 11.50 &     16.40$\pm$  1.50 &      6.33$\pm$  0.38 &      2.95$\pm$  0.26 &      2.52$\pm$  0.17 &   YU  \\
;;  \hline
;;  1996-02-06/19:14:24.148 &    RH08 &    383.40$\pm$  5.90 &      7.60$\pm$  0.30 &      3.88$\pm$  0.23 &      1.71$\pm$  0.10 &      1.40$\pm$  0.06 &   YU  \\
;;  \hline
;;  1996-04-03/09:47:17.151 &    RH08 &    379.20$\pm$  3.80 &     14.50$\pm$  0.50 &      4.24$\pm$  0.07 &      2.02$\pm$  0.06 &      1.59$\pm$  0.02 &   YP  \\
;;  \hline
;;  1996-04-08/02:41:09.765 &    RH08 &    182.30$\pm$  4.00 &     15.80$\pm$  0.20 &      5.69$\pm$  0.35 &      2.42$\pm$  0.04 &      2.08$\pm$  0.03 &   YP  \\
;;  \hline
;;  1996-06-18/22:35:55.500 &    RH08 &    460.80$\pm$ 16.30 &     10.50$\pm$  0.50 &      7.40$\pm$  0.30 &      1.66$\pm$  0.11 &      1.42$\pm$  0.10 &   NN  \\
;;  \hline
;;  1997-01-05/03:20:46.500 &    RH09 &    384.20$\pm$  8.30 &      7.10$\pm$  0.10 &      5.21$\pm$  0.20 &      1.45$\pm$  0.05 &      1.19$\pm$  0.02 &   MU  \\
;;  \hline
;;  1997-03-15/22:30:33.074 &     MX3 &    386.10$\pm$  7.30 &      7.00$\pm$  0.10 &      5.02$\pm$  0.21 &      1.41$\pm$  0.05 &      1.10$\pm$  0.03 &   YS  \\
;;  \hline
;;  1997-04-10/12:58:34.717 &    RH08 &    371.40$\pm$  5.70 &     15.00$\pm$  0.40 &      8.50$\pm$  0.35 &      1.49$\pm$  0.10 &      1.25$\pm$  0.04 &   YU  \\
;;  \hline
;;  1997-04-16/12:21:25.500 &    RH08 &    401.30$\pm$  4.00 &     19.10$\pm$  1.00 &      5.28$\pm$  0.23 &      2.20$\pm$  0.08 &      1.41$\pm$  0.05 &   MU  \\
;;  \hline
;;  1997-05-20/05:10:48.500 &    RH08 &    349.60$\pm$  2.60 &      8.60$\pm$  0.30 &      3.39$\pm$  0.48 &      1.92$\pm$  0.13 &      1.50$\pm$  0.08 &   NN  \\
;;  \hline
;;  1997-05-25/13:49:55.500 &    RH08 &    374.10$\pm$  8.30 &      9.30$\pm$  0.20 &      4.63$\pm$  0.21 &      2.57$\pm$  0.06 &      1.80$\pm$  0.04 &   MU  \\
;;  \hline
;;  1997-05-26/09:09:07.500 &    RH08 &    335.20$\pm$  2.60 &     13.80$\pm$  0.30 &      3.07$\pm$  0.11 &      2.98$\pm$  0.09 &      2.26$\pm$  0.04 &   NN  \\
;;  \hline
;;  1997-08-05/04:59:04.500 &    RH08 &    392.40$\pm$ 10.10 &     11.00$\pm$  0.20 &      4.53$\pm$  0.36 &      1.52$\pm$  0.10 &      1.03$\pm$  0.06 &   NN  \\
;;  \hline
;;  1997-09-03/08:38:40.500 &     MX3 &    477.30$\pm$ 15.10 &      8.60$\pm$  0.30 &      9.98$\pm$  0.23 &      1.28$\pm$  0.03 &      1.08$\pm$  0.01 &   NN  \\
;;  \hline
;;  1997-10-10/15:57:07.500 &    RH08 &    477.30$\pm$ 10.10 &     12.10$\pm$  0.70 &      8.46$\pm$  0.63 &      1.60$\pm$  0.08 &      1.50$\pm$  0.08 &   MU  \\
;;  \hline
;;  1997-10-24/11:18:09.990 &    RH08 &    490.90$\pm$ 13.00 &     11.00$\pm$  0.70 &      9.14$\pm$  0.45 &      1.92$\pm$  0.07 &      1.73$\pm$  0.06 &   YP  \\
;;  \hline
;;  1997-11-01/06:14:45.660 &    RH08 &    309.20$\pm$  6.00 &     29.50$\pm$  0.30 &      5.87$\pm$  0.15 &      2.35$\pm$  0.03 &      1.81$\pm$  0.02 &   YP  \\
;;  \hline
;;  1997-12-10/04:33:14.806 &    RH08 &    391.20$\pm$ 12.40 &     10.20$\pm$  0.90 &      7.10$\pm$  0.21 &      2.73$\pm$  0.17 &      2.26$\pm$  0.10 &   YU  \\
;;  \hline
;;  1997-12-30/01:13:43.921 &    RH08 &    423.40$\pm$  8.10 &      7.70$\pm$  0.20 &      5.37$\pm$  0.32 &      2.47$\pm$  0.07 &      1.89$\pm$  0.03 &   YU  \\
;;  \hline
;;  1998-01-06/13:29:00.368 &    RH08 &    408.40$\pm$ 10.00 &      9.70$\pm$  0.40 &      6.53$\pm$  0.21 &      2.41$\pm$  0.07 &      1.97$\pm$  0.05 &   YU  \\
;;  \hline
;;  1998-02-18/07:48:44.519 &    RH08 &    463.40$\pm$ 11.00 &     17.20$\pm$  0.40 &     15.56$\pm$  0.37 &      1.15$\pm$  0.03 &      1.08$\pm$  0.02 &   YS  \\
;;  \hline
;;  1998-05-29/15:12:04.523 &    RH08 &    692.50$\pm$ 29.00 &      7.70$\pm$  0.50 &     11.60$\pm$  0.24 &      1.83$\pm$  0.09 &      1.36$\pm$  0.06 &   YU  \\
;;  \hline
;;  1998-08-06/07:16:07.589 &    RH08 &    478.80$\pm$ 36.50 &     10.90$\pm$  1.00 &     10.31$\pm$  0.34 &      1.66$\pm$  0.10 &      1.58$\pm$  0.08 &   YU  \\
;;  \hline
;;  1998-08-19/18:40:41.694 &    RH08 &    334.70$\pm$  6.20 &      7.80$\pm$  0.30 &      3.54$\pm$  0.31 &      2.80$\pm$  0.17 &      2.32$\pm$  0.13 &   YU  \\
;;  \hline
;;  1998-11-08/04:41:17.414 &    RH08 &    644.50$\pm$ 64.30 &      4.40$\pm$  0.70 &     17.35$\pm$  0.36 &      1.51$\pm$  0.14 &      1.49$\pm$  0.14 &   YU  \\
;;  \hline
;;  1998-12-26/09:56:06.449 &    RH09 &    483.70$\pm$ 18.80 &      5.90$\pm$  0.10 &      8.09$\pm$  0.25 &      1.38$\pm$  0.04 &      1.09$\pm$  0.04 &   MU  \\
;;  \hline
;;  1998-12-28/18:20:16.211 &    RH08 &    465.20$\pm$ 30.20 &      6.90$\pm$  0.90 &      6.88$\pm$  1.33 &      1.75$\pm$  0.27 &      1.42$\pm$  0.16 &   YP  \\
;;  \hline
;;  1999-01-13/10:47:45.119 &    RH08 &    433.10$\pm$ 22.40 &      9.70$\pm$  1.10 &      5.06$\pm$  0.90 &      2.48$\pm$  0.27 &      1.85$\pm$  0.20 &   YP  \\
;;  \hline
;;  1999-02-17/07:12:13.985 &    RH08 &    560.20$\pm$ 17.80 &      6.10$\pm$  0.40 &      7.00$\pm$  0.24 &      1.57$\pm$  0.07 &      1.38$\pm$  0.05 &   YU  \\
;;  \hline
;;  1999-03-10/01:33:01.500 &    RH08 &    509.30$\pm$ 15.40 &      7.20$\pm$  0.20 &      4.42$\pm$  0.34 &      2.78$\pm$  0.09 &      1.74$\pm$  0.03 &   NN  \\
;;  \hline
;;  1999-04-16/11:14:11.089 &    RH09 &    479.80$\pm$ 14.50 &      4.00$\pm$  0.50 &      6.60$\pm$  0.23 &      1.60$\pm$  0.11 &      1.49$\pm$  0.08 &   YP  \\
;;  \hline
;;  1999-06-26/19:30:58.154 &    RH08 &    467.20$\pm$  9.70 &     15.60$\pm$  1.00 &     11.85$\pm$  0.92 &      2.22$\pm$  0.07 &      1.83$\pm$  0.03 &   YM  \\
;;  \hline
;;  1999-08-04/01:44:38.601 &    RH08 &    418.10$\pm$  6.90 &      8.70$\pm$  0.20 &      6.23$\pm$  0.41 &      2.07$\pm$  0.08 &      1.95$\pm$  0.04 &   YP  \\
;;  \hline
;;  1999-08-23/12:11:14.769 &    RH08 &    491.20$\pm$ 12.70 &      6.20$\pm$  0.20 &      8.17$\pm$  0.10 &      1.48$\pm$  0.03 &      1.44$\pm$  0.03 &   YP  \\
;;  \hline
;;  1999-09-15/07:43:48.000 &    RH08 &    665.50$\pm$ 16.30 &      2.60$\pm$  0.10 &      5.69$\pm$  0.91 &      2.04$\pm$  0.12 &      1.42$\pm$  0.06 &   NN  \\
;;  \hline
;;  1999-09-22/12:09:25.567 &    RH08 &    510.70$\pm$ 37.20 &     17.00$\pm$  0.70 &     11.29$\pm$  1.66 &      2.44$\pm$  0.10 &      1.88$\pm$  0.08 &   YU  \\
;;  \hline
;;  1999-10-21/02:20:51.968 &    RH08 &    477.30$\pm$ 28.60 &     13.40$\pm$  0.40 &      9.17$\pm$  0.38 &      2.46$\pm$  0.07 &      2.21$\pm$  0.06 &   YM  \\
;;  \hline
;;  1999-11-05/20:03:10.098 &    RH08 &    392.60$\pm$  6.90 &      6.10$\pm$  0.20 &      6.74$\pm$  0.21 &      1.46$\pm$  0.06 &      1.25$\pm$  0.04 &   YP  \\
;;  \hline
;;  1999-11-13/12:48:57.367 &    RH08 &    470.30$\pm$  7.00 &      2.90$\pm$  0.10 &      6.49$\pm$  0.22 &      1.36$\pm$  0.04 &      1.31$\pm$  0.02 &   YU  \\
;;  \hline
;;  2000-02-05/15:26:29.213 &    RH08 &    444.00$\pm$  8.10 &      5.30$\pm$  0.10 &      5.87$\pm$  0.18 &      1.29$\pm$  0.03 &      1.15$\pm$  0.03 &   YU  \\
;;  \hline
;;  2000-02-14/07:12:59.975 &    RH08 &    700.70$\pm$593.50 &      2.90$\pm$  0.40 &      5.85$\pm$  0.31 &      1.83$\pm$  0.18 &      1.46$\pm$  0.09 &   YP  \\
;;  \hline
;;  2000-06-23/12:58:00.164 &    RH08 &    527.60$\pm$ 24.60 &      6.10$\pm$  0.70 &      7.52$\pm$  0.49 &      2.80$\pm$  0.24 &      2.22$\pm$  0.08 &   YP  \\
;;  \hline
;;  2000-07-13/09:43:52.019 &    RH08 &    641.40$\pm$ 13.90 &      4.20$\pm$  0.30 &      5.94$\pm$  0.47 &      2.14$\pm$  0.14 &      1.52$\pm$  0.05 &   YU  \\
;;  \hline
;;  2000-07-26/19:00:15.048 &    RH08 &    425.00$\pm$  5.60 &     13.70$\pm$  0.50 &      5.80$\pm$  0.14 &      1.95$\pm$  0.05 &      1.40$\pm$  0.02 &   YU  \\
;;  \hline
;;  2000-07-28/06:38:46.187 &    RH08 &    491.40$\pm$ 19.20 &      5.60$\pm$  0.90 &      8.57$\pm$  0.35 &      1.88$\pm$  0.18 &      1.84$\pm$  0.14 &   YU  \\
;;  \hline
;;  2000-08-10/05:13:21.711 &    RH08 &    379.90$\pm$  7.00 &      6.10$\pm$  0.40 &      6.61$\pm$  0.39 &      1.33$\pm$  0.08 &      1.14$\pm$  0.06 &   YU  \\
;;  \hline
;;  2000-08-11/18:49:34.684 &    RH08 &    605.10$\pm$163.10 &      1.60$\pm$  0.50 &      9.39$\pm$  0.33 &      1.27$\pm$  0.21 &      1.27$\pm$  0.23 &   YM  \\
;;  \hline
;;  2000-10-03/01:02:20.500 &    RH08 &    457.20$\pm$  7.90 &      7.00$\pm$  0.30 &      5.72$\pm$  0.42 &      2.20$\pm$  0.17 &      1.66$\pm$  0.05 &   NN  \\
;;  \hline
;;  2000-10-28/06:38:31.899 &    RH08 &    413.60$\pm$ 11.70 &      3.80$\pm$  0.40 &      4.40$\pm$  0.27 &      1.99$\pm$  0.17 &      1.71$\pm$  0.09 &   MU  \\
;;  \hline
;;  2000-10-28/09:30:41.475 &    RH08 &    441.10$\pm$  7.00 &      9.70$\pm$  1.00 &      6.73$\pm$  0.43 &      2.12$\pm$  0.18 &      1.53$\pm$  0.06 &   YU  \\
;;  \hline
;;  2000-10-31/17:09:59.376 &    RH08 &    475.30$\pm$ 24.90 &      5.40$\pm$  0.40 &      7.40$\pm$  0.56 &      1.79$\pm$  0.10 &      1.60$\pm$  0.06 &   YU  \\
;;  \hline
;;  2000-11-04/02:25:46.500 &    RH08 &    450.10$\pm$  9.10 &     16.30$\pm$  0.30 &      8.36$\pm$  0.78 &      2.33$\pm$  0.06 &      1.91$\pm$  0.04 &   NN  \\
;;  \hline
;;  2000-11-06/09:30:15.569 &    RH08 &    626.00$\pm$ 21.60 &      2.00$\pm$  0.30 &      4.91$\pm$  0.61 &      1.96$\pm$  0.23 &      1.66$\pm$  0.15 &   YP  \\
;;  \hline
;;  2000-11-11/04:10:49.500 &    RH08 &    975.60$\pm$ 85.00 &      1.10$\pm$  0.10 &      4.39$\pm$  1.17 &      1.78$\pm$  0.28 &      1.50$\pm$  0.20 &   MU  \\
;;  \hline
;;  2000-11-26/11:43:31.355 &    RH08 &    509.70$\pm$ 29.10 &      7.60$\pm$  1.00 &      9.19$\pm$  0.67 &      2.52$\pm$  0.14 &      1.77$\pm$  0.09 &   YM  \\
;;  \hline
;;  2000-11-28/05:27:42.233 &    RH08 &    603.80$\pm$ 21.00 &      5.30$\pm$  0.40 &      6.61$\pm$  0.58 &      1.62$\pm$  0.09 &      1.40$\pm$  0.06 &   YP  \\
;;  \hline
;;  2001-01-17/04:07:53.254 &    RH08 &    379.20$\pm$  5.60 &      9.40$\pm$  0.50 &      5.05$\pm$  0.17 &      1.68$\pm$  0.07 &      1.33$\pm$  0.02 &   YP  \\
;;  \hline
;;  2001-03-03/11:29:19.410 &    RH08 &    553.60$\pm$ 14.40 &      3.10$\pm$  0.30 &      3.92$\pm$  0.46 &      2.37$\pm$  0.13 &      1.92$\pm$  0.09 &   YS  \\
;;  \hline
;;  2001-03-22/13:59:06.530 &    RH08 &    382.00$\pm$  7.10 &     19.80$\pm$  1.60 &      9.95$\pm$  0.88 &      1.44$\pm$  0.08 &      1.28$\pm$  0.06 &   YU  \\
;;  \hline
;;  2001-03-27/18:07:48.865 &    RH08 &    552.10$\pm$ 19.40 &      6.40$\pm$  0.50 &     10.48$\pm$  0.51 &      2.14$\pm$  0.16 &      1.76$\pm$  0.08 &   YU  \\
;;  \hline
;;  2001-04-21/15:29:14.585 &    RH08 &    395.40$\pm$  2.10 &      7.10$\pm$  0.20 &      3.49$\pm$  0.11 &      2.47$\pm$  0.10 &      1.82$\pm$  0.10 &   YU  \\
;;  \hline
;;  2001-05-06/09:06:08.766 &    RH08 &    365.60$\pm$  5.30 &      8.70$\pm$  0.20 &      4.92$\pm$  0.23 &      1.58$\pm$  0.04 &      1.31$\pm$  0.04 &   YP  \\
;;  \hline
;;  2001-05-12/10:03:14.540 &    RH08 &    574.70$\pm$ 16.40 &      5.20$\pm$  0.10 &     12.43$\pm$  0.40 &      1.21$\pm$  0.04 &      1.10$\pm$  0.03 &   YP  \\
;;  \hline
;;  2001-08-12/16:12:46.500 &    RH08 &    340.20$\pm$ 13.20 &     13.60$\pm$  0.60 &      9.65$\pm$  0.18 &      2.19$\pm$  0.11 &      1.88$\pm$  0.10 &   MU  \\
;;  \hline
;;  2001-08-31/01:25:04.500 &    RH08 &    475.30$\pm$ 16.80 &      3.20$\pm$  0.10 &      5.08$\pm$  0.10 &      1.52$\pm$  0.04 &      1.25$\pm$  0.03 &   NN  \\
;;  \hline
;;  2001-09-13/02:31:28.009 &    RH08 &    454.50$\pm$ 33.40 &      6.70$\pm$  0.80 &      8.40$\pm$  0.39 &      1.31$\pm$  0.10 &      1.08$\pm$  0.05 &   YU  \\
;;  \hline
;;  2001-10-28/03:13:48.680 &    RH08 &    591.80$\pm$ 53.00 &      2.60$\pm$  0.70 &      7.58$\pm$  0.66 &      2.34$\pm$  0.39 &      2.32$\pm$  0.29 &   YU  \\
;;  \hline
;;  2001-11-30/18:15:45.600 &    RH08 &    417.90$\pm$ 21.50 &      3.80$\pm$  0.20 &      3.65$\pm$  0.28 &      2.01$\pm$  0.11 &      1.61$\pm$  0.07 &   YP  \\
;;  \hline
;;  2001-12-21/14:10:18.049 &    RH08 &    565.80$\pm$141.90 &      4.20$\pm$  0.70 &      8.96$\pm$  0.74 &      2.15$\pm$  0.29 &      1.99$\pm$  0.17 &   YP  \\
;;  \hline
;;  2001-12-30/20:05:07.154 &    RH08 &    669.00$\pm$ 24.00 &      7.00$\pm$  0.40 &     11.44$\pm$  1.59 &      2.47$\pm$  0.16 &      1.79$\pm$  0.06 &   YM  \\
;;  \hline
;;  2002-01-17/05:26:58.160 &    RH09 &    404.30$\pm$  9.90 &      6.50$\pm$  0.40 &      6.35$\pm$  0.80 &      1.26$\pm$  0.10 &      1.13$\pm$  0.04 &   YP  \\
;;  \hline
;;  2002-01-31/21:38:10.686 &    RH08 &    363.90$\pm$  8.30 &      4.80$\pm$  0.20 &      5.86$\pm$  0.12 &      2.36$\pm$  0.08 &      2.14$\pm$  0.05 &   YU  \\
;;  \hline
;;  2002-03-23/11:24:09.197 &    RH08 &    520.10$\pm$  9.00 &      3.60$\pm$  0.30 &      3.41$\pm$  0.58 &      2.82$\pm$  0.17 &      2.12$\pm$  0.10 &   YU  \\
;;  \hline
;;  2002-03-29/22:15:13.397 &    RH08 &    398.70$\pm$ 14.40 &     23.20$\pm$  2.10 &      5.45$\pm$  1.12 &      2.93$\pm$  0.38 &      2.05$\pm$  0.12 &   YU  \\
;;  \hline
;;  2002-05-21/21:14:16.399 &    RH09 &    257.30$\pm$  4.50 &      8.50$\pm$  0.40 &      4.30$\pm$  0.27 &      1.93$\pm$  0.09 &      1.55$\pm$  0.05 &   YP  \\
;;  \hline
;;  2002-06-29/21:10:26.075 &    RH08 &    385.40$\pm$ 15.10 &      5.50$\pm$  0.20 &      6.02$\pm$  0.50 &      1.38$\pm$  0.06 &      1.17$\pm$  0.05 &   YS  \\
;;  \hline
;;  2002-08-01/23:09:07.514 &    RH08 &    497.40$\pm$  5.30 &     12.10$\pm$  0.10 &      8.12$\pm$  0.30 &      1.51$\pm$  0.03 &      1.42$\pm$  0.03 &   YU  \\
;;  \hline
;;  2002-09-30/07:54:24.470 &    RH08 &    326.50$\pm$  6.80 &     19.30$\pm$  0.90 &     13.41$\pm$  0.63 &      1.40$\pm$  0.04 &      1.24$\pm$  0.04 &   YM  \\
;;  \hline
;;  2002-10-02/22:41:04.500 &    RH08 &    527.20$\pm$ 19.80 &      3.10$\pm$  0.30 &      3.48$\pm$  0.55 &      1.98$\pm$  0.13 &      1.59$\pm$  0.06 &   MU  \\
;;  \hline
;;  2002-11-09/18:27:49.389 &    RH08 &    425.00$\pm$  7.40 &     13.10$\pm$  0.90 &      6.71$\pm$  0.18 &      1.85$\pm$  0.10 &      1.70$\pm$  0.08 &   YU  \\
;;  \hline
;;  2003-05-29/18:31:08.012 &    RH08 &    907.80$\pm$ 51.60 &      7.70$\pm$  1.20 &     14.14$\pm$  1.27 &      1.97$\pm$  0.22 &      1.88$\pm$  0.19 &   YU  \\
;;  \hline
;;  2003-06-18/04:42:06.396 &    RH08 &    618.70$\pm$ 38.40 &      6.60$\pm$  0.30 &     10.53$\pm$  0.27 &      1.76$\pm$  0.06 &      1.53$\pm$  0.03 &   YP  \\
;;  \hline
;;  2004-04-12/18:29:46.590 &    RH08 &    558.60$\pm$ 30.50 &      3.20$\pm$  0.20 &      4.19$\pm$  0.88 &      2.71$\pm$  0.13 &      2.05$\pm$  0.08 &   YU  \\
;;  \hline
;;  2005-05-06/12:08:39.840 &    RH08 &    416.80$\pm$  0.30 &      9.30$\pm$  0.10 &      4.45$\pm$  0.14 &      2.35$\pm$  0.15 &      1.93$\pm$  0.07 &   YS  \\
;;  \hline
;;  2005-05-07/18:26:16.447 &    RH08 &    437.90$\pm$  1.20 &     17.90$\pm$  0.90 &     13.27$\pm$  0.76 &      1.15$\pm$  0.03 &      1.04$\pm$  0.03 &   YU  \\
;;  \hline
;;  2005-06-16/08:09:10.578 &    RH08 &    620.60$\pm$ 10.60 &      4.10$\pm$  0.80 &     11.83$\pm$  0.08 &      1.29$\pm$  0.16 &      1.29$\pm$  0.13 &   YU  \\
;;  \hline
;;  2005-07-10/02:42:30.953 &    RH08 &    540.50$\pm$ 14.70 &      7.30$\pm$  0.80 &     10.79$\pm$  0.38 &      2.25$\pm$  0.19 &      2.06$\pm$  0.16 &   YU  \\
;;  \hline
;;  2005-07-16/01:40:58.500 &    RH08 &    421.80$\pm$  1.70 &      8.60$\pm$  0.50 &      5.30$\pm$  0.43 &      2.03$\pm$  0.19 &      1.47$\pm$  0.07 &   NN  \\
;;  \hline
;;  2005-08-01/06:00:52.500 &    RH08 &    479.60$\pm$  4.50 &      3.30$\pm$  0.20 &      7.64$\pm$  0.21 &      1.79$\pm$  0.09 &      1.61$\pm$  0.09 &   MU  \\
;;  \hline
;;  2005-08-24/05:35:24.651 &    RH08 &    579.10$\pm$  1.30 &     11.60$\pm$  0.80 &     10.36$\pm$  1.38 &      1.97$\pm$  0.25 &      1.65$\pm$  0.11 &   YM  \\
;;  \hline
;;  2005-09-02/13:50:16.303 &    RH08 &    587.00$\pm$  3.80 &      4.90$\pm$  0.60 &      6.05$\pm$  0.77 &      2.63$\pm$  0.19 &      2.04$\pm$  0.06 &   YU  \\
;;  \hline
;;  2005-09-15/08:36:30.500 &    RH08 &    683.70$\pm$  3.00 &      1.50$\pm$  0.10 &      3.33$\pm$  0.69 &      2.54$\pm$  0.47 &      2.13$\pm$  0.28 &   MU  \\
;;  \hline
;;  2005-12-30/23:45:23.000 &    RH08 &    619.00$\pm$  1.00 &      2.00$\pm$  0.00 &      3.10$\pm$  0.10 &      1.59$\pm$  0.09 &      1.19$\pm$  0.05 &   NN  \\
;;  \hline
;;  2006-08-19/09:38:49.144 &    RH08 &    373.30$\pm$  1.50 &     14.90$\pm$  0.60 &      7.67$\pm$  0.51 &      1.21$\pm$  0.08 &      1.02$\pm$  0.07 &   YS  \\
;;  \hline
;;  2006-11-03/09:37:16.500 &    RH08 &    397.50$\pm$  1.80 &     10.80$\pm$  0.50 &      4.98$\pm$  0.12 &      2.05$\pm$  0.05 &      1.58$\pm$  0.02 &   NN  \\
;;  \hline
;;  2007-07-20/03:27:17.000 &    RH08 &    357.20$\pm$  0.60 &      8.60$\pm$  0.20 &      3.56$\pm$  0.10 &      1.99$\pm$  0.05 &      1.41$\pm$  0.03 &   NU  \\
;;  \hline
;;  2007-08-22/04:34:03.509 &    RH08 &    356.90$\pm$  0.70 &      8.40$\pm$  0.40 &      2.41$\pm$  0.18 &      2.13$\pm$  0.14 &      1.54$\pm$  0.06 &   YU  \\
;;  \hline
;;  2007-12-17/01:53:18.835 &    RH08 &    289.30$\pm$  0.70 &      6.60$\pm$  0.10 &      3.56$\pm$  0.09 &      2.33$\pm$  0.09 &      1.70$\pm$  0.06 &   YP  \\
;;  \hline
;;  2008-05-28/01:17:38.485 &    RH08 &    402.40$\pm$  1.00 &     10.90$\pm$  0.70 &      3.89$\pm$  0.53 &      2.88$\pm$  0.18 &      2.05$\pm$  0.07 &   YU  \\
;;  \hline
;;  2008-06-24/19:10:41.966 &    RH08 &    354.80$\pm$  0.80 &      7.10$\pm$  0.20 &      3.57$\pm$  0.10 &      2.01$\pm$  0.06 &      1.68$\pm$  0.03 &   YP  \\
;;  \hline
;;  2009-02-03/19:21:03.298 &    RH08 &    407.70$\pm$ 10.20 &      3.00$\pm$  0.30 &      4.63$\pm$  0.20 &      1.69$\pm$  0.12 &      1.59$\pm$  0.10 &   YU  \\
;;  \hline
;;  2009-06-24/09:52:20.572 &    RH08 &    350.40$\pm$  1.80 &     12.10$\pm$  0.70 &      4.60$\pm$  0.20 &      2.80$\pm$  0.21 &      2.03$\pm$  0.10 &   YP  \\
;;  \hline
;;  2009-06-27/11:04:19.171 &    RH08 &    426.10$\pm$  1.50 &      3.80$\pm$  0.20 &      3.79$\pm$  0.10 &      1.59$\pm$  0.03 &      1.32$\pm$  0.02 &   YU  \\
;;  \hline
;;  2009-10-21/23:15:10.175 &    RH08 &    307.70$\pm$  1.30 &     10.10$\pm$  0.40 &      3.47$\pm$  0.23 &      2.38$\pm$  0.21 &      1.71$\pm$  0.09 &   YU  \\
;;  \hline
;;  2010-04-11/12:20:56.470 &    RH08 &    465.20$\pm$  1.80 &      3.20$\pm$  0.20 &      4.58$\pm$  0.41 &      2.53$\pm$  0.17 &      2.17$\pm$  0.16 &   YP  \\
;;  \hline
;;  2011-02-04/01:50:55.821 &    RH10 &    285.10$\pm$  4.80 &      2.50$\pm$  0.20 &      2.51$\pm$  0.10 &      1.97$\pm$  0.16 &      1.63$\pm$  0.12 &   YS  \\
;;  \hline
;;  2011-07-11/08:27:25.529 &    RH08 &    601.40$\pm$  3.00 &      5.00$\pm$  0.10 &      5.41$\pm$  0.46 &      2.82$\pm$  0.18 &      1.98$\pm$  0.10 &   YU  \\
;;  \hline
;;  2011-09-16/18:56:59.489 &    RH08 &    291.10$\pm$  5.90 &      1.00$\pm$  1.00 &      3.41$\pm$  2.37 &      1.35$\pm$  1.90 &      1.28$\pm$  1.28 &   YP  \\
;;  \hline
;;  2011-09-25/10:46:32.224 &    RH08 &     85.60$\pm$  2.50 &      3.90$\pm$  0.70 &      6.12$\pm$  1.04 &      1.15$\pm$  0.25 &      1.06$\pm$  0.39 &   YU  \\
;;  \hline
;;  2012-01-21/04:02:01.998 &    RH08 &    326.80$\pm$  2.20 &      5.10$\pm$  0.20 &      4.54$\pm$  0.09 &      1.85$\pm$  0.03 &      1.70$\pm$  0.02 &   YU  \\
;;  \hline
;;  2012-01-30/15:43:13.436 &    RH08 &    411.10$\pm$  5.70 &      2.90$\pm$  0.60 &      3.03$\pm$  0.23 &      2.84$\pm$  0.14 &      2.51$\pm$  0.10 &   YU  \\
;;  \hline
;;  2012-03-07/03:28:39.500 &    RH08 &    479.00$\pm$  4.50 &      6.90$\pm$  0.40 &      8.93$\pm$  0.52 &      2.09$\pm$  0.13 &      1.88$\pm$  0.08 &   NN  \\
;;  \hline
;;  2012-04-19/17:13:31.500 &    RH08 &    410.10$\pm$  2.20 &      5.20$\pm$  0.20 &      2.77$\pm$  0.19 &      2.45$\pm$  0.15 &      1.73$\pm$  0.09 &   MU  \\
;;  \hline
;;  2012-06-16/19:34:39.463 &    RH08 &    486.90$\pm$  2.30 &     18.70$\pm$  0.60 &      7.95$\pm$  0.53 &      2.40$\pm$  0.16 &      1.78$\pm$  0.05 &   YU  \\
;;  \hline
;;  2012-10-08/04:12:14.203 &    RH08 &    465.40$\pm$  6.20 &      7.10$\pm$  0.40 &      8.14$\pm$  0.60 &      2.32$\pm$  0.11 &      2.02$\pm$  0.11 &   YU  \\
;;  \hline
;;  2012-11-12/22:12:41.856 &    RH08 &    377.10$\pm$  1.50 &     17.90$\pm$  0.80 &      7.58$\pm$  0.72 &      2.52$\pm$  0.31 &      2.07$\pm$  0.16 &   YU  \\
;;  \hline
;;  2012-11-26/04:32:51.244 &    RH08 &    586.40$\pm$  5.40 &      3.10$\pm$  0.40 &      4.80$\pm$  0.56 &      2.20$\pm$  0.30 &      1.78$\pm$  0.21 &   YP  \\
;;  \hline
;;  2012-12-14/19:06:13.500 &    RH08 &    384.30$\pm$  2.40 &      6.80$\pm$  0.30 &      5.92$\pm$  0.10 &      2.10$\pm$  0.06 &      1.78$\pm$  0.05 &   NN  \\
;;  \hline
;;  2013-01-17/00:23:43.500 &    RH08 &    424.90$\pm$  1.00 &     22.50$\pm$  0.70 &      5.44$\pm$  0.11 &      1.83$\pm$  0.07 &      1.26$\pm$  0.02 &   MU  \\
;;  \hline
;;  2013-02-13/00:47:45.971 &    RH08 &    447.80$\pm$  3.00 &      5.10$\pm$  0.30 &      3.54$\pm$  0.37 &      2.60$\pm$  0.15 &      1.96$\pm$  0.07 &   YP  \\
;;  \hline
;;  2013-04-30/08:52:46.649 &    RH08 &    461.40$\pm$  3.70 &      5.70$\pm$  0.20 &      4.91$\pm$  0.52 &      2.17$\pm$  0.12 &      1.78$\pm$  0.09 &   YU  \\
;;  \hline
;;  2013-06-10/02:52:01.571 &    RH08 &    387.70$\pm$  1.20 &     11.10$\pm$  0.40 &      4.05$\pm$  0.12 &      1.62$\pm$  0.06 &      1.18$\pm$  0.06 &   YP  \\
;;  \hline
;;  2013-07-12/16:43:27.886 &    RH08 &    499.30$\pm$  6.90 &      3.20$\pm$  0.30 &      5.14$\pm$  0.20 &      2.31$\pm$  0.21 &      1.86$\pm$  0.08 &   YP  \\
;;  \hline
;;  2013-09-02/01:56:50.404 &    RH08 &    524.70$\pm$  3.90 &      1.50$\pm$  0.10 &      2.99$\pm$  0.39 &      2.20$\pm$  0.09 &      1.71$\pm$  0.08 &   YG  \\
;;  \hline
;;  2013-10-26/21:26:02.434 &    RH08 &    336.50$\pm$  0.80 &      3.90$\pm$  0.10 &      4.21$\pm$  0.10 &      1.59$\pm$  0.03 &      1.54$\pm$  0.02 &   YS  \\
;;  \hline
;;  2014-02-13/08:55:29.210 &    RH08 &    465.60$\pm$  2.80 &      3.70$\pm$  0.10 &      5.75$\pm$  0.10 &      1.74$\pm$  0.03 &      1.71$\pm$  0.03 &   YU  \\
;;  \hline
;;  2014-02-15/12:46:37.044 &    RH08 &    499.60$\pm$  2.70 &      6.60$\pm$  0.40 &      6.69$\pm$  0.15 &      2.68$\pm$  0.12 &      2.11$\pm$  0.06 &   YU  \\
;;  \hline
;;  2014-02-19/03:09:39.045 &    RH08 &    632.40$\pm$  6.40 &      2.40$\pm$  0.00 &      8.50$\pm$  0.14 &      2.06$\pm$  0.03 &      2.00$\pm$  0.03 &   YU  \\
;;  \hline
;;  2014-04-19/17:48:25.374 &    RH08 &    549.20$\pm$  2.70 &      6.30$\pm$  0.20 &      5.50$\pm$  0.25 &      1.63$\pm$  0.05 &      1.52$\pm$  0.04 &   YP  \\
;;  \hline
;;  2014-05-07/21:19:39.118 &    RH08 &    386.40$\pm$  1.00 &      5.10$\pm$  0.20 &      4.76$\pm$  0.19 &      1.22$\pm$  0.04 &      1.13$\pm$  0.04 &   YS  \\
;;  \hline
;;  2014-05-29/08:26:41.450 &    RH08 &    381.70$\pm$  1.80 &      4.40$\pm$  0.30 &      4.73$\pm$  0.14 &      1.26$\pm$  0.07 &      1.11$\pm$  0.06 &   YS  \\
;;  \hline
;;  2014-07-14/13:38:09.110 &    RH08 &    278.10$\pm$  4.60 &     27.80$\pm$  2.90 &      7.99$\pm$  0.62 &      1.30$\pm$  0.14 &      1.07$\pm$  0.06 &   YU  \\
;;  \hline
;;  2015-05-06/00:55:49.856 &    RH08 &    527.50$\pm$  3.60 &      5.00$\pm$  0.90 &      5.72$\pm$  0.25 &      2.61$\pm$  0.26 &      2.28$\pm$  0.13 &   YU  \\
;;  \hline
;;  2015-06-05/08:30:57.400 &    RH08 &    326.90$\pm$  0.60 &      6.70$\pm$  0.20 &      2.54$\pm$  0.30 &      2.42$\pm$  0.07 &      1.57$\pm$  0.05 &   MU  \\
;;  \hline
;;  2015-06-24/13:07:15.538 &    RH08 &    591.70$\pm$ 15.50 &      1.00$\pm$  0.10 &      5.50$\pm$  0.68 &      2.09$\pm$  0.16 &      2.00$\pm$  0.21 &   YS  \\
;;  \hline
;;  2015-08-15/07:43:42.090 &    RH08 &    477.40$\pm$  3.70 &     11.40$\pm$  1.60 &     10.79$\pm$  0.19 &      2.38$\pm$  0.20 &      2.27$\pm$  0.19 &   YM  \\
;;  \hline
;;  2016-03-11/04:29:17.468 &    RH08 &    363.10$\pm$  1.90 &     15.60$\pm$  1.40 &      5.54$\pm$  0.38 &      2.01$\pm$  0.18 &      1.46$\pm$  0.13 &   YU  \\
;;  \hline
;;  2016-03-14/16:16:32.196 &    RH08 &    412.50$\pm$  1.70 &     13.80$\pm$  0.50 &      5.73$\pm$  0.65 &      2.27$\pm$  0.12 &      1.52$\pm$  0.02 &   YU  \\[-11.5pt]
;;  \hline


;;
;;  Parameters for Table 2:
;;    Ramp Time  <beta>_up  theta_Bn  Mf/Mcr  Mf/Mww  Mf/Mgr  Mf/Mnw
tramp_str      = time_string(midt__unix,PREC=3)   ;;  UTC time at center of ramp
tramp_str[good] = time_string(tura_mid,PREC=3)    ;;  Fix for ramps we know
betaup         = betaupvd[*,0]
d_betaup       = betaupvd[*,1]
thetaBn        = thetbnvd[*,0]*18d1/!DPI
d_thetaBn      = thetbnvd[*,1]*18d1/!DPI
MfMcr          = MfMcruvd[*,0]
d_MfMcr        = MfMcruvd[*,1]
MfMww          = MfMwwuvd[*,0]
d_MfMww        = MfMwwuvd[*,1]
MfMgr          = MfMgruvd[*,0]
d_MfMgr        = MfMgruvd[*,1]
MfMnw          = MfMnwuvd[*,0]
d_MfMnw        = MfMnwuvd[*,1]
whistler       = whpre_yn

nform          = 'f9.2,"$\pm$",f6.2'
texform        = '(";;  ",a23," & ",'+nform[0]+'," & ",'+nform[0]+'," & ",'+nform[0]+'," & ",'+nform[0]+'," & ",'+nform[0]+'," & ",'+nform[0]+'," & ",a4,"  \\")'
np             = N_ELEMENTS(tramp_str)
FOR kk=0L, np[0] - 1L DO BEGIN                                                                              $
  nums0 = [betaup[kk],d_betaup[kk],thetaBn[kk],d_thetaBn[kk],MfMcr[kk],d_MfMcr[kk]]                       & $
  nums1 = [MfMww[kk],d_MfMww[kk],MfMgr[kk],d_MfMgr[kk],MfMnw[kk],d_MfMnw[kk]]                             & $
  PRINT,';;  \hline'                                                                                      & $
  PRINT,tramp_str[kk],nums0,nums1,whistler[kk],FORMAT=texform[0]

;;  ****************************************************************************************************
;;  ***  Need to add [-11.5pt] immediately after last \\ in table to avoid extra stupid-looking row  ***
;;  ****************************************************************************************************
;;
;;  \caption{IP Shock Critical Mach Number Ratios} \\  %%  show caption
;;  test the width & of & this & table & by & killing & a & row \kill
;;  \hline
;;  \textbf{Ramp Time} & $\langle \boldsymbol{\beta}{\scriptstyle_{\mathbf{Tot}}} \rangle{\scriptstyle_{\mathbf{up}}}$ & $\langle \boldsymbol{\theta}{\scriptstyle_{\mathbf{Bn}}} \rangle{\scriptstyle_{\mathbf{up}}}$ & $\langle \mathbf{M}{\scriptstyle_{\mathbf{f}}} / \mathbf{M}{\scriptstyle_{\mathbf{cr}}} \rangle{\scriptstyle_{\mathbf{up}}}$ & $\langle \mathbf{M}{\scriptstyle_{\mathbf{f}}} / \mathbf{M}{\scriptstyle_{\mathbf{ww}}} \rangle{\scriptstyle_{\mathbf{up}}}$ & $\langle \mathbf{M}{\scriptstyle_{\mathbf{f}}} / \mathbf{M}{\scriptstyle_{\mathbf{gr}}} \rangle{\scriptstyle_{\mathbf{up}}}$ & $\langle \mathbf{M}{\scriptstyle_{\mathbf{f}}} / \mathbf{M}{\scriptstyle_{\mathbf{nw}}} \rangle{\scriptstyle_{\mathbf{up}}}$ & \textbf{Shock}  \\
;;  \textbf{[UTC]} &  & \textbf{[}$^{\circ}$\textbf{]} &  &  &  &  & \textbf{Label}  \\
;;  \endhead  %%  Specifies rows to appear at the top of every page
;;  \textbf{Ramp Time} & $\langle \boldsymbol{\beta}{\scriptstyle_{\mathbf{Tot}}} \rangle{\scriptstyle_{\mathbf{up}}}$ & $\langle \boldsymbol{\theta}{\scriptstyle_{\mathbf{Bn}}} \rangle{\scriptstyle_{\mathbf{up}}}$ & $\langle \mathbf{M}{\scriptstyle_{\mathbf{f}}} / \mathbf{M}{\scriptstyle_{\mathbf{cr}}} \rangle{\scriptstyle_{\mathbf{up}}}$ & $\langle \mathbf{M}{\scriptstyle_{\mathbf{f}}} / \mathbf{M}{\scriptstyle_{\mathbf{ww}}} \rangle{\scriptstyle_{\mathbf{up}}}$ & $\langle \mathbf{M}{\scriptstyle_{\mathbf{f}}} / \mathbf{M}{\scriptstyle_{\mathbf{gr}}} \rangle{\scriptstyle_{\mathbf{up}}}$ & $\langle \mathbf{M}{\scriptstyle_{\mathbf{f}}} / \mathbf{M}{\scriptstyle_{\mathbf{nw}}} \rangle{\scriptstyle_{\mathbf{up}}}$ & \textbf{Shock}  \\
;;  \textbf{[UTC]} &  & \textbf{[}$^{\circ}$\textbf{]} &  &  &  &  & \textbf{Label}  \\
;;  \hline
;;  \endfoot  %%  Specifies rows to appear at the bottom of every page
;;  \hline
;;  \textbf{Ramp Time} & $\langle \boldsymbol{\beta}{\scriptstyle_{\mathbf{Tot}}} \rangle{\scriptstyle_{\mathbf{up}}}$ & $\langle \boldsymbol{\theta}{\scriptstyle_{\mathbf{Bn}}} \rangle{\scriptstyle_{\mathbf{up}}}$ & $\langle \mathbf{M}{\scriptstyle_{\mathbf{f}}} / \mathbf{M}{\scriptstyle_{\mathbf{cr}}} \rangle{\scriptstyle_{\mathbf{up}}}$ & $\langle \mathbf{M}{\scriptstyle_{\mathbf{f}}} / \mathbf{M}{\scriptstyle_{\mathbf{ww}}} \rangle{\scriptstyle_{\mathbf{up}}}$ & $\langle \mathbf{M}{\scriptstyle_{\mathbf{f}}} / \mathbf{M}{\scriptstyle_{\mathbf{gr}}} \rangle{\scriptstyle_{\mathbf{up}}}$ & $\langle \mathbf{M}{\scriptstyle_{\mathbf{f}}} / \mathbf{M}{\scriptstyle_{\mathbf{nw}}} \rangle{\scriptstyle_{\mathbf{up}}}$ & \textbf{Shock}  \\
;;  \textbf{[UTC]} &  & \textbf{[}$^{\circ}$\textbf{]} &  &  &  &  & \textbf{Label}  \\
;;  \hline
;;  \endlastfoot  %%  Specifies rows to appear at the bottom of every page
;;  \hline
;;  1995-03-04/00:36:58.500 &      0.47$\pm$  0.47 &     86.10$\pm$  4.80 &      0.89$\pm$  0.19 &      1.17$\pm$  1.02 &      0.90$\pm$  0.79 &      0.83$\pm$  0.72 &   MU  \\
;;  \hline
;;  1995-04-17/23:33:07.755 &      0.16$\pm$  0.16 &     80.00$\pm$  0.70 &      0.46$\pm$  0.04 &      0.31$\pm$  0.02 &      0.24$\pm$  0.02 &      0.22$\pm$  0.02 &   YU  \\
;;  \hline
;;  1995-07-22/05:35:45.354 &      0.23$\pm$  0.23 &     52.10$\pm$  2.80 &      0.55$\pm$  0.06 &      0.09$\pm$  0.01 &      0.07$\pm$  0.01 &      0.07$\pm$  0.00 &   YP  \\
;;  \hline
;;  1995-08-22/12:56:49.213 &      0.65$\pm$  0.67 &     66.10$\pm$  7.40 &      0.91$\pm$  0.24 &      0.21$\pm$  0.06 &      0.16$\pm$  0.05 &      0.15$\pm$  0.04 &   YG  \\
;;  \hline
;;  1995-08-24/22:11:04.526 &      0.34$\pm$  0.34 &     73.70$\pm$  1.80 &      0.88$\pm$  0.14 &      0.33$\pm$  0.04 &      0.26$\pm$  0.03 &      0.24$\pm$  0.03 &   YU  \\
;;  \hline
;;  1995-09-14/21:24:55.549 &      0.48$\pm$  0.49 &     81.30$\pm$  8.90 &      0.69$\pm$  0.15 &      0.46$\pm$  0.45 &      0.35$\pm$  0.35 &      0.32$\pm$  0.32 &   NN  \\
;;  \hline
;;  1995-10-22/21:20:15.947 &      0.50$\pm$  0.50 &     65.70$\pm$  5.80 &      0.99$\pm$  0.22 &      0.23$\pm$  0.05 &      0.18$\pm$  0.04 &      0.17$\pm$  0.04 &   YU  \\
;;  \hline
;;  1995-12-24/05:57:35.591 &      0.29$\pm$  0.26 &     58.40$\pm$  3.30 &      1.14$\pm$  0.16 &      0.22$\pm$  0.03 &      0.17$\pm$  0.02 &      0.16$\pm$  0.02 &   YU  \\
;;  \hline
;;  1996-02-06/19:14:24.148 &      0.42$\pm$  0.43 &     48.40$\pm$  4.60 &      0.70$\pm$  0.13 &      0.10$\pm$  0.01 &      0.08$\pm$  0.01 &      0.07$\pm$  0.01 &   YU  \\
;;  \hline
;;  1996-04-03/09:47:17.151 &      0.39$\pm$  0.38 &     75.70$\pm$  1.40 &      0.71$\pm$  0.12 &      0.30$\pm$  0.03 &      0.23$\pm$  0.02 &      0.21$\pm$  0.02 &   YP  \\
;;  \hline
;;  1996-04-08/02:41:09.765 &      0.23$\pm$  0.23 &     73.30$\pm$  1.10 &      0.87$\pm$  0.10 &      0.34$\pm$  0.02 &      0.26$\pm$  0.02 &      0.24$\pm$  0.02 &   YP  \\
;;  \hline
;;  1996-06-18/22:35:55.500 &      0.32$\pm$  0.32 &     49.90$\pm$  3.00 &      0.68$\pm$  0.11 &      0.10$\pm$  0.01 &      0.08$\pm$  0.01 &      0.07$\pm$  0.01 &   NN  \\
;;  \hline
;;  1997-01-05/03:20:46.500 &      0.34$\pm$  0.36 &     64.30$\pm$  2.40 &      0.54$\pm$  0.09 &      0.13$\pm$  0.01 &      0.10$\pm$  0.01 &      0.09$\pm$  0.01 &   MU  \\
;;  \hline
;;  1997-03-15/22:30:33.074 &      0.51$\pm$  0.51 &     49.90$\pm$  3.00 &      0.57$\pm$  0.12 &      0.08$\pm$  0.01 &      0.06$\pm$  0.00 &      0.06$\pm$  0.00 &   YS  \\
;;  \hline
;;  1997-04-10/12:58:34.717 &      0.32$\pm$  0.33 &     58.50$\pm$  1.50 &      0.57$\pm$  0.09 &      0.11$\pm$  0.01 &      0.09$\pm$  0.00 &      0.08$\pm$  0.00 &   YU  \\
;;  \hline
;;  1997-04-16/12:21:25.500 &      0.93$\pm$  0.95 &     67.70$\pm$  4.00 &      0.75$\pm$  0.24 &      0.17$\pm$  0.03 &      0.13$\pm$  0.02 &      0.12$\pm$  0.02 &   MU  \\
;;  \hline
;;  1997-05-20/05:10:48.500 &      0.54$\pm$  0.54 &     46.00$\pm$ 11.30 &      0.80$\pm$  0.18 &      0.10$\pm$  0.02 &      0.08$\pm$  0.02 &      0.07$\pm$  0.02 &   NN  \\
;;  \hline
;;  1997-05-25/13:49:55.500 &      0.63$\pm$  0.62 &     85.50$\pm$  4.00 &      0.86$\pm$  0.22 &      1.07$\pm$  0.95 &      0.83$\pm$  0.73 &      0.76$\pm$  0.67 &   MU  \\
;;  \hline
;;  1997-05-26/09:09:07.500 &      0.58$\pm$  0.58 &     50.30$\pm$  1.30 &      1.19$\pm$  0.27 &      0.17$\pm$  0.01 &      0.13$\pm$  0.00 &      0.12$\pm$  0.00 &   NN  \\
;;  \hline
;;  1997-08-05/04:59:04.500 &      0.82$\pm$  0.83 &     56.50$\pm$  7.40 &      0.56$\pm$  0.17 &      0.09$\pm$  0.02 &      0.07$\pm$  0.01 &      0.06$\pm$  0.01 &   NN  \\
;;  \hline
;;  1997-09-03/08:38:40.500 &      0.26$\pm$  0.26 &     78.20$\pm$  2.20 &      0.46$\pm$  0.06 &      0.25$\pm$  0.05 &      0.19$\pm$  0.03 &      0.17$\pm$  0.03 &   NN  \\
;;  \hline
;;  1997-10-10/15:57:07.500 &      0.09$\pm$  0.09 &     87.70$\pm$  6.60 &      0.57$\pm$  0.04 &      0.78$\pm$  0.51 &      0.60$\pm$  0.39 &      0.55$\pm$  0.36 &   MU  \\
;;  \hline
;;  1997-10-24/11:18:09.990 &      0.16$\pm$  0.16 &     68.30$\pm$  4.50 &      0.71$\pm$  0.06 &      0.22$\pm$  0.04 &      0.17$\pm$  0.03 &      0.15$\pm$  0.03 &   YP  \\
;;  \hline
;;  1997-11-01/06:14:45.660 &      0.42$\pm$  0.42 &     77.30$\pm$  1.80 &      0.82$\pm$  0.16 &      0.38$\pm$  0.05 &      0.30$\pm$  0.04 &      0.27$\pm$  0.04 &   YP  \\
;;  \hline
;;  1997-12-10/04:33:14.806 &      0.30$\pm$  0.28 &     70.90$\pm$  1.60 &      0.99$\pm$  0.14 &      0.32$\pm$  0.03 &      0.25$\pm$  0.02 &      0.23$\pm$  0.02 &   YU  \\
;;  \hline
;;  1997-12-30/01:13:43.921 &      0.42$\pm$  0.41 &     87.40$\pm$  8.10 &      0.85$\pm$  0.16 &      0.81$\pm$  0.53 &      0.62$\pm$  0.41 &      0.57$\pm$  0.37 &   YU  \\
;;  \hline
;;  1998-01-06/13:29:00.368 &      0.30$\pm$  0.30 &     82.30$\pm$  6.20 &      0.84$\pm$  0.12 &      0.69$\pm$  0.55 &      0.53$\pm$  0.43 &      0.49$\pm$  0.39 &   YU  \\
;;  \hline
;;  1998-02-18/07:48:44.519 &      0.13$\pm$  0.13 &     48.70$\pm$  2.00 &      0.48$\pm$  0.03 &      0.08$\pm$  0.00 &      0.06$\pm$  0.00 &      0.05$\pm$  0.00 &   YS  \\
;;  \hline
;;  1998-05-29/15:12:04.523 &      0.55$\pm$  0.55 &     64.50$\pm$  2.40 &      0.66$\pm$  0.15 &      0.15$\pm$  0.01 &      0.11$\pm$  0.01 &      0.10$\pm$  0.01 &   YU  \\
;;  \hline
;;  1998-08-06/07:16:07.589 &      0.06$\pm$  0.07 &     80.80$\pm$  3.90 &      0.60$\pm$  0.04 &      0.46$\pm$  0.20 &      0.36$\pm$  0.15 &      0.33$\pm$  0.14 &   YU  \\
;;  \hline
;;  1998-08-19/18:40:41.694 &      0.42$\pm$  0.41 &     45.50$\pm$  8.10 &      1.19$\pm$  0.22 &      0.16$\pm$  0.02 &      0.12$\pm$  0.02 &      0.11$\pm$  0.02 &   YU  \\
;;  \hline
;;  1998-11-08/04:41:17.414 &      0.03$\pm$  0.03 &     54.60$\pm$  1.40 &      0.61$\pm$  0.06 &      0.12$\pm$  0.01 &      0.09$\pm$  0.01 &      0.08$\pm$  0.01 &   YU  \\
;;  \hline
;;  1998-12-26/09:56:06.449 &      0.37$\pm$  0.38 &     78.60$\pm$  2.70 &      0.48$\pm$  0.08 &      0.26$\pm$  0.06 &      0.20$\pm$  0.05 &      0.18$\pm$  0.04 &   MU  \\
;;  \hline
;;  1998-12-28/18:20:16.211 &      0.41$\pm$  0.43 &     60.70$\pm$ 12.90 &      0.68$\pm$  0.15 &      0.14$\pm$  0.06 &      0.11$\pm$  0.04 &      0.10$\pm$  0.04 &   YP  \\
;;  \hline
;;  1999-01-13/10:47:45.119 &      0.52$\pm$  0.49 &     70.90$\pm$ 12.70 &      0.89$\pm$  0.21 &      0.27$\pm$  0.18 &      0.21$\pm$  0.14 &      0.19$\pm$  0.12 &   YP  \\
;;  \hline
;;  1999-02-17/07:12:13.985 &      0.19$\pm$  0.18 &     86.60$\pm$  2.90 &      0.56$\pm$  0.05 &      1.09$\pm$  0.93 &      0.84$\pm$  0.71 &      0.77$\pm$  0.66 &   YU  \\
;;  \hline
;;  1999-03-10/01:33:01.500 &      0.94$\pm$  0.94 &     84.70$\pm$  5.90 &      0.90$\pm$  0.29 &      0.82$\pm$  0.76 &      0.63$\pm$  0.59 &      0.58$\pm$  0.54 &   NN  \\
;;  \hline
;;  1999-04-16/11:14:11.089 &      0.12$\pm$  0.11 &     62.30$\pm$  3.40 &      0.61$\pm$  0.05 &      0.15$\pm$  0.02 &      0.12$\pm$  0.01 &      0.11$\pm$  0.01 &   YP  \\
;;  \hline
;;  1999-06-26/19:30:58.154 &      0.34$\pm$  0.36 &     59.40$\pm$  3.70 &      0.85$\pm$  0.13 &      0.17$\pm$  0.02 &      0.13$\pm$  0.01 &      0.12$\pm$  0.01 &   YM  \\
;;  \hline
;;  1999-08-04/01:44:38.601 &      0.11$\pm$  0.11 &     54.10$\pm$  4.80 &      0.83$\pm$  0.05 &      0.16$\pm$  0.02 &      0.12$\pm$  0.01 &      0.11$\pm$  0.01 &   YP  \\
;;  \hline
;;  1999-08-23/12:11:14.769 &      0.04$\pm$  0.04 &     60.70$\pm$  0.90 &      0.57$\pm$  0.02 &      0.14$\pm$  0.00 &      0.11$\pm$  0.00 &      0.10$\pm$  0.00 &   YP  \\
;;  \hline
;;  1999-09-15/07:43:48.000 &      0.68$\pm$  0.73 &     73.60$\pm$  4.30 &      0.70$\pm$  0.19 &      0.24$\pm$  0.06 &      0.18$\pm$  0.05 &      0.17$\pm$  0.04 &   NN  \\
;;  \hline
;;  1999-09-22/12:09:25.567 &      0.44$\pm$  0.46 &     70.80$\pm$  3.40 &      0.87$\pm$  0.18 &      0.27$\pm$  0.05 &      0.21$\pm$  0.04 &      0.19$\pm$  0.03 &   YU  \\
;;  \hline
;;  1999-10-21/02:20:51.968 &      0.17$\pm$  0.16 &     69.40$\pm$  3.30 &      0.91$\pm$  0.08 &      0.29$\pm$  0.05 &      0.23$\pm$  0.04 &      0.21$\pm$  0.03 &   YM  \\
;;  \hline
;;  1999-11-05/20:03:10.098 &      0.29$\pm$  0.29 &     52.70$\pm$  2.40 &      0.58$\pm$  0.08 &      0.10$\pm$  0.01 &      0.07$\pm$  0.00 &      0.07$\pm$  0.00 &   YP  \\
;;  \hline
;;  1999-11-13/12:48:57.367 &      0.05$\pm$  0.05 &     69.10$\pm$  1.80 &      0.50$\pm$  0.01 &      0.17$\pm$  0.01 &      0.13$\pm$  0.01 &      0.12$\pm$  0.01 &   YU  \\
;;  \hline
;;  2000-02-05/15:26:29.213 &      0.16$\pm$  0.16 &     68.10$\pm$  2.10 &      0.47$\pm$  0.04 &      0.14$\pm$  0.01 &      0.11$\pm$  0.01 &      0.10$\pm$  0.01 &   YU  \\
;;  \hline
;;  2000-02-14/07:12:59.975 &      0.44$\pm$  0.41 &     56.30$\pm$  3.30 &      0.71$\pm$  0.13 &      0.12$\pm$  0.01 &      0.09$\pm$  0.01 &      0.09$\pm$  0.01 &   YP  \\
;;  \hline
;;  2000-06-23/12:58:00.164 &      0.45$\pm$  0.40 &     56.10$\pm$  7.00 &      1.09$\pm$  0.19 &      0.19$\pm$  0.03 &      0.14$\pm$  0.03 &      0.13$\pm$  0.02 &   YP  \\
;;  \hline
;;  2000-07-13/09:43:52.019 &      0.75$\pm$  0.71 &     51.90$\pm$  2.60 &      0.83$\pm$  0.22 &      0.12$\pm$  0.01 &      0.09$\pm$  0.01 &      0.08$\pm$  0.01 &   YU  \\
;;  \hline
;;  2000-07-26/19:00:15.048 &      0.57$\pm$  0.58 &     86.00$\pm$  3.00 &      0.66$\pm$  0.16 &      0.94$\pm$  0.70 &      0.72$\pm$  0.54 &      0.66$\pm$  0.50 &   YU  \\
;;  \hline
;;  2000-07-28/06:38:46.187 &      0.05$\pm$  0.05 &     56.20$\pm$  1.10 &      0.75$\pm$  0.06 &      0.15$\pm$  0.01 &      0.12$\pm$  0.01 &      0.11$\pm$  0.01 &   YU  \\
;;  \hline
;;  2000-08-10/05:13:21.711 &      0.24$\pm$  0.25 &     67.00$\pm$  2.70 &      0.49$\pm$  0.06 &      0.14$\pm$  0.02 &      0.10$\pm$  0.01 &      0.10$\pm$  0.01 &   YU  \\
;;  \hline
;;  2000-08-11/18:49:34.684 &      0.03$\pm$  0.03 &     78.20$\pm$  3.70 &      0.47$\pm$  0.09 &      0.29$\pm$  0.10 &      0.22$\pm$  0.08 &      0.21$\pm$  0.07 &   YM  \\
;;  \hline
;;  2000-10-03/01:02:20.500 &      0.59$\pm$  0.58 &     51.50$\pm$  3.60 &      0.87$\pm$  0.20 &      0.12$\pm$  0.01 &      0.10$\pm$  0.01 &      0.09$\pm$  0.01 &   NN  \\
;;  \hline
;;  2000-10-28/06:38:31.899 &      0.27$\pm$  0.25 &     59.10$\pm$  5.60 &      0.77$\pm$  0.10 &      0.16$\pm$  0.03 &      0.12$\pm$  0.02 &      0.11$\pm$  0.02 &   MU  \\
;;  \hline
;;  2000-10-28/09:30:41.475 &      0.69$\pm$  0.70 &     51.60$\pm$  6.50 &      0.82$\pm$  0.22 &      0.12$\pm$  0.02 &      0.09$\pm$  0.01 &      0.08$\pm$  0.01 &   YU  \\
;;  \hline
;;  2000-10-31/17:09:59.376 &      0.17$\pm$  0.17 &     71.10$\pm$  1.50 &      0.65$\pm$  0.06 &      0.23$\pm$  0.02 &      0.18$\pm$  0.02 &      0.16$\pm$  0.01 &   YU  \\
;;  \hline
;;  2000-11-04/02:25:46.500 &      0.32$\pm$  0.32 &     66.40$\pm$  4.00 &      0.85$\pm$  0.13 &      0.22$\pm$  0.04 &      0.17$\pm$  0.03 &      0.16$\pm$  0.03 &   NN  \\
;;  \hline
;;  2000-11-06/09:30:15.569 &      0.26$\pm$  0.27 &     70.40$\pm$ 13.10 &      0.72$\pm$  0.11 &      0.24$\pm$  0.15 &      0.18$\pm$  0.12 &      0.17$\pm$  0.11 &   YP  \\
;;  \hline
;;  2000-11-11/04:10:49.500 &      0.32$\pm$  0.27 &     56.70$\pm$ 15.90 &      0.70$\pm$  0.13 &      0.13$\pm$  0.06 &      0.10$\pm$  0.05 &      0.09$\pm$  0.04 &   MU  \\
;;  \hline
;;  2000-11-26/11:43:31.355 &      0.68$\pm$  0.70 &     64.90$\pm$  4.60 &      0.90$\pm$  0.24 &      0.20$\pm$  0.03 &      0.15$\pm$  0.03 &      0.14$\pm$  0.02 &   YM  \\
;;  \hline
;;  2000-11-28/05:27:42.233 &      0.26$\pm$  0.25 &     58.30$\pm$  3.00 &      0.63$\pm$  0.08 &      0.12$\pm$  0.01 &      0.10$\pm$  0.01 &      0.09$\pm$  0.01 &   YP  \\
;;  \hline
;;  2001-01-17/04:07:53.254 &      0.39$\pm$  0.38 &     69.70$\pm$  2.20 &      0.60$\pm$  0.10 &      0.18$\pm$  0.02 &      0.14$\pm$  0.01 &      0.13$\pm$  0.01 &   YP  \\
;;  \hline
;;  2001-03-03/11:29:19.410 &      0.48$\pm$  0.50 &     45.50$\pm$  4.60 &      1.01$\pm$  0.21 &      0.13$\pm$  0.01 &      0.10$\pm$  0.01 &      0.09$\pm$  0.01 &   YS  \\
;;  \hline
;;  2001-03-22/13:59:06.530 &      0.18$\pm$  0.17 &     73.50$\pm$  4.50 &      0.52$\pm$  0.05 &      0.21$\pm$  0.06 &      0.16$\pm$  0.04 &      0.15$\pm$  0.04 &   YU  \\
;;  \hline
;;  2001-03-27/18:07:48.865 &      0.36$\pm$  0.34 &     57.20$\pm$  2.10 &      0.83$\pm$  0.13 &      0.15$\pm$  0.01 &      0.12$\pm$  0.01 &      0.11$\pm$  0.01 &   YU  \\
;;  \hline
;;  2001-04-21/15:29:14.585 &      0.52$\pm$  0.51 &     81.00$\pm$  1.50 &      0.85$\pm$  0.19 &      0.54$\pm$  0.09 &      0.42$\pm$  0.07 &      0.38$\pm$  0.07 &   YU  \\
;;  \hline
;;  2001-05-06/09:06:08.766 &      0.41$\pm$  0.42 &     45.80$\pm$  5.20 &      0.67$\pm$  0.12 &      0.09$\pm$  0.01 &      0.07$\pm$  0.01 &      0.06$\pm$  0.01 &   YP  \\
;;  \hline
;;  2001-05-12/10:03:14.540 &      0.15$\pm$  0.15 &     68.20$\pm$  1.40 &      0.45$\pm$  0.04 &      0.14$\pm$  0.01 &      0.11$\pm$  0.01 &      0.10$\pm$  0.01 &   YP  \\
;;  \hline
;;  2001-08-12/16:12:46.500 &      0.23$\pm$  0.22 &     72.40$\pm$  1.40 &      0.79$\pm$  0.09 &      0.29$\pm$  0.03 &      0.22$\pm$  0.02 &      0.21$\pm$  0.02 &   MU  \\
;;  \hline
;;  2001-08-31/01:25:04.500 &      0.28$\pm$  0.28 &     82.50$\pm$  1.30 &      0.53$\pm$  0.07 &      0.45$\pm$  0.08 &      0.34$\pm$  0.06 &      0.32$\pm$  0.06 &   NN  \\
;;  \hline
;;  2001-09-13/02:31:28.009 &      0.31$\pm$  0.33 &     72.10$\pm$  9.00 &      0.47$\pm$  0.07 &      0.17$\pm$  0.08 &      0.13$\pm$  0.06 &      0.12$\pm$  0.06 &   YU  \\
;;  \hline
;;  2001-10-28/03:13:48.680 &      0.04$\pm$  0.03 &     60.30$\pm$  6.80 &      0.92$\pm$  0.12 &      0.22$\pm$  0.05 &      0.17$\pm$  0.04 &      0.16$\pm$  0.04 &   YU  \\
;;  \hline
;;  2001-11-30/18:15:45.600 &      0.40$\pm$  0.38 &     59.70$\pm$  3.90 &      0.76$\pm$  0.13 &      0.15$\pm$  0.02 &      0.11$\pm$  0.01 &      0.11$\pm$  0.01 &   YP  \\
;;  \hline
;;  2001-12-21/14:10:18.049 &      0.13$\pm$  0.15 &     65.10$\pm$  3.00 &      0.82$\pm$  0.09 &      0.22$\pm$  0.03 &      0.17$\pm$  0.02 &      0.16$\pm$  0.02 &   YP  \\
;;  \hline
;;  2001-12-30/20:05:07.154 &      0.61$\pm$  0.64 &     63.00$\pm$  3.90 &      0.90$\pm$  0.22 &      0.18$\pm$  0.03 &      0.14$\pm$  0.02 &      0.13$\pm$  0.02 &   YM  \\
;;  \hline
;;  2002-01-17/05:26:58.160 &      0.22$\pm$  0.20 &     51.20$\pm$  4.50 &      0.51$\pm$  0.05 &      0.08$\pm$  0.01 &      0.06$\pm$  0.01 &      0.06$\pm$  0.01 &   YP  \\
;;  \hline
;;  2002-01-31/21:38:10.686 &      0.15$\pm$  0.14 &     67.90$\pm$  2.70 &      0.87$\pm$  0.06 &      0.27$\pm$  0.03 &      0.20$\pm$  0.02 &      0.19$\pm$  0.02 &   YU  \\
;;  \hline
;;  2002-03-23/11:24:09.197 &      0.51$\pm$  0.50 &     68.00$\pm$  4.20 &      1.01$\pm$  0.22 &      0.26$\pm$  0.05 &      0.20$\pm$  0.04 &      0.19$\pm$  0.04 &   YU  \\
;;  \hline
;;  2002-03-29/22:15:13.397 &      0.67$\pm$  0.59 &     82.90$\pm$ 10.50 &      1.02$\pm$  0.24 &      0.59$\pm$  0.46 &      0.46$\pm$  0.36 &      0.42$\pm$  0.33 &   YU  \\
;;  \hline
;;  2002-05-21/21:14:16.399 &      0.46$\pm$  0.46 &     49.50$\pm$  3.60 &      0.79$\pm$  0.15 &      0.11$\pm$  0.01 &      0.09$\pm$  0.01 &      0.08$\pm$  0.01 &   YP  \\
;;  \hline
;;  2002-06-29/21:10:26.075 &      0.29$\pm$  0.28 &     61.10$\pm$  2.80 &      0.52$\pm$  0.07 &      0.11$\pm$  0.01 &      0.09$\pm$  0.01 &      0.08$\pm$  0.01 &   YS  \\
;;  \hline
;;  2002-08-01/23:09:07.514 &      0.09$\pm$  0.09 &     70.10$\pm$  2.80 &      0.56$\pm$  0.03 &      0.19$\pm$  0.03 &      0.15$\pm$  0.02 &      0.14$\pm$  0.02 &   YU  \\
;;  \hline
;;  2002-09-30/07:54:24.470 &      0.16$\pm$  0.17 &     78.80$\pm$  2.10 &      0.50$\pm$  0.04 &      0.30$\pm$  0.06 &      0.23$\pm$  0.04 &      0.21$\pm$  0.04 &   YM  \\
;;  \hline
;;  2002-10-02/22:41:04.500 &      0.35$\pm$  0.34 &     78.40$\pm$  7.90 &      0.70$\pm$  0.11 &      0.37$\pm$  0.25 &      0.29$\pm$  0.19 &      0.26$\pm$  0.18 &   MU  \\
;;  \hline
;;  2002-11-09/18:27:49.389 &      0.12$\pm$  0.13 &     70.00$\pm$  1.40 &      0.68$\pm$  0.05 &      0.23$\pm$  0.02 &      0.18$\pm$  0.01 &      0.16$\pm$  0.01 &   YU  \\
;;  \hline
;;  2003-05-29/18:31:08.012 &      0.08$\pm$  0.08 &     73.00$\pm$ 10.60 &      0.73$\pm$  0.08 &      0.30$\pm$  0.19 &      0.23$\pm$  0.14 &      0.21$\pm$  0.13 &   YU  \\
;;  \hline
;;  2003-06-18/04:42:06.396 &      0.19$\pm$  0.20 &     86.80$\pm$  2.00 &      0.62$\pm$  0.06 &      1.28$\pm$  0.80 &      0.99$\pm$  0.62 &      0.90$\pm$  0.57 &   YP  \\
;;  \hline
;;  2004-04-12/18:29:46.590 &      0.52$\pm$  0.54 &     60.20$\pm$  9.70 &      1.01$\pm$  0.23 &      0.19$\pm$  0.06 &      0.15$\pm$  0.04 &      0.14$\pm$  0.04 &   YU  \\
;;  \hline
;;  2005-05-06/12:08:39.840 &      0.41$\pm$  0.39 &     48.60$\pm$  2.30 &      0.97$\pm$  0.17 &      0.14$\pm$  0.01 &      0.10$\pm$  0.01 &      0.10$\pm$  0.01 &   YS  \\
;;  \hline
;;  2005-05-07/18:26:16.447 &      0.16$\pm$  0.16 &     61.60$\pm$  4.00 &      0.44$\pm$  0.04 &      0.10$\pm$  0.01 &      0.08$\pm$  0.01 &      0.07$\pm$  0.01 &   YU  \\
;;  \hline
;;  2005-06-16/08:09:10.578 &      0.02$\pm$  0.02 &     66.00$\pm$  0.60 &      0.49$\pm$  0.05 &      0.15$\pm$  0.02 &      0.11$\pm$  0.01 &      0.10$\pm$  0.01 &   YU  \\
;;  \hline
;;  2005-07-10/02:42:30.953 &      0.12$\pm$  0.12 &     80.70$\pm$  3.20 &      0.81$\pm$  0.08 &      0.60$\pm$  0.21 &      0.46$\pm$  0.16 &      0.42$\pm$  0.15 &   YU  \\
;;  \hline
;;  2005-07-16/01:40:58.500 &      0.57$\pm$  0.56 &     84.00$\pm$  5.20 &      0.69$\pm$  0.17 &      0.66$\pm$  0.57 &      0.51$\pm$  0.44 &      0.47$\pm$  0.40 &   NN  \\
;;  \hline
;;  2005-08-01/06:00:52.500 &      0.15$\pm$  0.17 &     84.20$\pm$  2.60 &      0.64$\pm$  0.06 &      0.74$\pm$  0.34 &      0.57$\pm$  0.26 &      0.53$\pm$  0.24 &   MU  \\
;;  \hline
;;  2005-08-24/05:35:24.651 &      0.27$\pm$  0.26 &     86.90$\pm$  7.00 &      0.69$\pm$  0.10 &      0.78$\pm$  0.52 &      0.60$\pm$  0.40 &      0.55$\pm$  0.37 &   YM  \\
;;  \hline
;;  2005-09-02/13:50:16.303 &      0.52$\pm$  0.52 &     53.00$\pm$  3.60 &      1.04$\pm$  0.22 &      0.16$\pm$  0.01 &      0.12$\pm$  0.01 &      0.11$\pm$  0.01 &   YU  \\
;;  \hline
;;  2005-09-15/08:36:30.500 &      0.37$\pm$  0.34 &     54.80$\pm$ 11.90 &      1.03$\pm$  0.21 &      0.17$\pm$  0.06 &      0.13$\pm$  0.04 &      0.12$\pm$  0.04 &   MU  \\
;;  \hline
;;  2005-12-30/23:45:23.000 &      0.50$\pm$  0.47 &     71.70$\pm$  2.00 &      0.56$\pm$  0.12 &      0.18$\pm$  0.02 &      0.14$\pm$  0.02 &      0.13$\pm$  0.01 &   NN  \\
;;  \hline
;;  2006-08-19/09:38:49.144 &      0.37$\pm$  0.36 &     46.90$\pm$  2.90 &      0.51$\pm$  0.09 &      0.07$\pm$  0.01 &      0.05$\pm$  0.00 &      0.05$\pm$  0.00 &   YS  \\
;;  \hline
;;  2006-11-03/09:37:16.500 &      0.41$\pm$  0.40 &     87.80$\pm$  1.00 &      0.70$\pm$  0.13 &      1.92$\pm$  0.87 &      1.48$\pm$  0.67 &      1.36$\pm$  0.62 &   NN  \\
;;  \hline
;;  2007-07-20/03:27:17.000 &      0.64$\pm$  0.66 &     66.30$\pm$  1.90 &      0.70$\pm$  0.18 &      0.16$\pm$  0.01 &      0.13$\pm$  0.01 &      0.12$\pm$  0.01 &   NU  \\
;;  \hline
;;  2007-08-22/04:34:03.509 &      0.63$\pm$  0.60 &     62.00$\pm$  2.40 &      0.78$\pm$  0.19 &      0.15$\pm$  0.01 &      0.12$\pm$  0.01 &      0.11$\pm$  0.01 &   YU  \\
;;  \hline
;;  2007-12-17/01:53:18.835 &      0.65$\pm$  0.64 &     53.80$\pm$  1.90 &      0.90$\pm$  0.22 &      0.13$\pm$  0.01 &      0.10$\pm$  0.01 &      0.10$\pm$  0.01 &   YP  \\
;;  \hline
;;  2008-05-28/01:17:38.485 &      0.61$\pm$  0.58 &     75.10$\pm$ 12.00 &      1.00$\pm$  0.24 &      0.38$\pm$  0.30 &      0.29$\pm$  0.23 &      0.27$\pm$  0.21 &   YU  \\
;;  \hline
;;  2008-06-24/19:10:41.966 &      0.37$\pm$  0.37 &     49.70$\pm$  2.40 &      0.82$\pm$  0.13 &      0.12$\pm$  0.01 &      0.09$\pm$  0.00 &      0.09$\pm$  0.00 &   YP  \\
;;  \hline
;;  2009-02-03/19:21:03.298 &      0.08$\pm$  0.09 &     85.20$\pm$  1.90 &      0.61$\pm$  0.05 &      0.89$\pm$  0.35 &      0.68$\pm$  0.27 &      0.63$\pm$  0.25 &   YU  \\
;;  \hline
;;  2009-06-24/09:52:20.572 &      0.55$\pm$  0.55 &     88.10$\pm$  1.30 &      0.95$\pm$  0.23 &      2.86$\pm$  1.96 &      2.20$\pm$  1.51 &      2.02$\pm$  1.39 &   YP  \\
;;  \hline
;;  2009-06-27/11:04:19.171 &      0.28$\pm$  0.27 &     87.50$\pm$  1.20 &      0.56$\pm$  0.07 &      1.41$\pm$  0.68 &      1.09$\pm$  0.52 &      1.00$\pm$  0.48 &   YU  \\
;;  \hline
;;  2009-10-21/23:15:10.175 &      0.64$\pm$  0.53 &     66.00$\pm$  2.50 &      0.87$\pm$  0.19 &      0.20$\pm$  0.02 &      0.15$\pm$  0.02 &      0.14$\pm$  0.02 &   YU  \\
;;  \hline
;;  2010-04-11/12:20:56.470 &      0.27$\pm$  0.26 &     60.30$\pm$  4.10 &      0.97$\pm$  0.14 &      0.20$\pm$  0.03 &      0.16$\pm$  0.02 &      0.14$\pm$  0.02 &   YP  \\
;;  \hline
;;  2011-02-04/01:50:55.821 &      0.29$\pm$  0.30 &     73.20$\pm$  3.70 &      0.70$\pm$  0.11 &      0.26$\pm$  0.06 &      0.20$\pm$  0.05 &      0.19$\pm$  0.04 &   YS  \\
;;  \hline
;;  2011-07-11/08:27:25.529 &      0.64$\pm$  0.66 &     78.40$\pm$  9.40 &      0.96$\pm$  0.25 &      0.46$\pm$  0.37 &      0.36$\pm$  0.29 &      0.33$\pm$  0.26 &   YU  \\
;;  \hline
;;  2011-09-16/18:56:59.489 &      0.07$\pm$  0.07 &     71.20$\pm$  0.00 &      0.50$\pm$  0.50 &      0.19$\pm$  0.19 &      0.14$\pm$  0.14 &      0.13$\pm$  0.13 &   YP  \\
;;  \hline
;;  2011-09-25/10:46:32.224 &      0.26$\pm$  0.09 &     83.80$\pm$  4.40 &      0.45$\pm$  0.17 &      0.46$\pm$  0.37 &      0.35$\pm$  0.28 &      0.32$\pm$  0.26 &   YU  \\
;;  \hline
;;  2012-01-21/04:02:01.998 &      0.11$\pm$  0.10 &     83.20$\pm$  1.20 &      0.66$\pm$  0.04 &      0.67$\pm$  0.12 &      0.52$\pm$  0.09 &      0.47$\pm$  0.08 &   YU  \\
;;  \hline
;;  2012-01-30/15:43:13.436 &      0.23$\pm$  0.19 &     53.20$\pm$  4.40 &      1.14$\pm$  0.11 &      0.20$\pm$  0.02 &      0.15$\pm$  0.02 &      0.14$\pm$  0.02 &   YU  \\
;;  \hline
;;  2012-03-07/03:28:39.500 &      0.15$\pm$  0.16 &     82.40$\pm$  1.90 &      0.75$\pm$  0.07 &      0.66$\pm$  0.17 &      0.51$\pm$  0.13 &      0.47$\pm$  0.12 &   NN  \\
;;  \hline
;;  2012-04-19/17:13:31.500 &      0.61$\pm$  0.63 &     84.20$\pm$  0.70 &      0.83$\pm$  0.21 &      0.80$\pm$  0.10 &      0.62$\pm$  0.08 &      0.57$\pm$  0.07 &   MU  \\
;;  \hline
;;  2012-06-16/19:34:39.463 &      0.53$\pm$  0.47 &     70.20$\pm$  2.70 &      0.86$\pm$  0.17 &      0.25$\pm$  0.03 &      0.19$\pm$  0.03 &      0.17$\pm$  0.02 &   YU  \\
;;  \hline
;;  2012-10-08/04:12:14.203 &      0.21$\pm$  0.20 &     74.40$\pm$  4.40 &      0.84$\pm$  0.09 &      0.35$\pm$  0.10 &      0.27$\pm$  0.08 &      0.25$\pm$  0.07 &   YU  \\
;;  \hline
;;  2012-11-12/22:12:41.856 &      0.35$\pm$  0.38 &     65.40$\pm$  4.60 &      0.94$\pm$  0.17 &      0.23$\pm$  0.04 &      0.18$\pm$  0.03 &      0.16$\pm$  0.03 &   YU  \\
;;  \hline
;;  2012-11-26/04:32:51.244 &      0.36$\pm$  0.41 &     71.00$\pm$  7.10 &      0.80$\pm$  0.17 &      0.26$\pm$  0.10 &      0.20$\pm$  0.07 &      0.18$\pm$  0.07 &   YP  \\
;;  \hline
;;  2012-12-14/19:06:13.500 &      0.28$\pm$  0.28 &     61.60$\pm$  1.50 &      0.79$\pm$  0.10 &      0.17$\pm$  0.01 &      0.13$\pm$  0.01 &      0.12$\pm$  0.01 &   NN  \\
;;  \hline
;;  2013-01-17/00:23:43.500 &      0.68$\pm$  0.67 &     78.70$\pm$  2.70 &      0.62$\pm$  0.16 &      0.30$\pm$  0.07 &      0.23$\pm$  0.05 &      0.21$\pm$  0.05 &   MU  \\
;;  \hline
;;  2013-02-13/00:47:45.971 &      0.47$\pm$  0.45 &     75.70$\pm$  2.20 &      0.91$\pm$  0.18 &      0.37$\pm$  0.06 &      0.29$\pm$  0.04 &      0.26$\pm$  0.04 &   YP  \\
;;  \hline
;;  2013-04-30/08:52:46.649 &      0.34$\pm$  0.35 &     64.90$\pm$  2.50 &      0.80$\pm$  0.13 &      0.20$\pm$  0.02 &      0.15$\pm$  0.02 &      0.14$\pm$  0.01 &   YU  \\
;;  \hline
;;  2013-06-10/02:52:01.571 &      0.56$\pm$  0.55 &     72.60$\pm$  2.60 &      0.56$\pm$  0.13 &      0.18$\pm$  0.03 &      0.14$\pm$  0.02 &      0.13$\pm$  0.02 &   YP  \\
;;  \hline
;;  2013-07-12/16:43:27.886 &      0.41$\pm$  0.45 &     56.80$\pm$  1.50 &      0.90$\pm$  0.17 &      0.16$\pm$  0.01 &      0.12$\pm$  0.01 &      0.11$\pm$  0.01 &   YP  \\
;;  \hline
;;  2013-09-02/01:56:50.404 &      0.47$\pm$  0.48 &     60.10$\pm$  4.20 &      0.83$\pm$  0.17 &      0.16$\pm$  0.02 &      0.12$\pm$  0.02 &      0.11$\pm$  0.02 &   YG  \\
;;  \hline
;;  2013-10-26/21:26:02.434 &      0.07$\pm$  0.06 &     46.90$\pm$  1.00 &      0.67$\pm$  0.02 &      0.11$\pm$  0.00 &      0.08$\pm$  0.00 &      0.07$\pm$  0.00 &   YS  \\
;;  \hline
;;  2014-02-13/08:55:29.210 &      0.03$\pm$  0.03 &     68.30$\pm$  0.90 &      0.65$\pm$  0.01 &      0.22$\pm$  0.01 &      0.17$\pm$  0.01 &      0.15$\pm$  0.01 &   YU  \\
;;  \hline
;;  2014-02-15/12:46:37.044 &      0.38$\pm$  0.42 &     78.30$\pm$  3.60 &      0.94$\pm$  0.17 &      0.49$\pm$  0.15 &      0.37$\pm$  0.11 &      0.34$\pm$  0.10 &   YU  \\
;;  \hline
;;  2014-02-19/03:09:39.045 &      0.04$\pm$  0.04 &     72.00$\pm$  0.70 &      0.76$\pm$  0.02 &      0.30$\pm$  0.01 &      0.23$\pm$  0.01 &      0.21$\pm$  0.01 &   YU  \\
;;  \hline
;;  2014-04-19/17:48:25.374 &      0.14$\pm$  0.14 &     50.50$\pm$  1.60 &      0.67$\pm$  0.05 &      0.11$\pm$  0.00 &      0.09$\pm$  0.00 &      0.08$\pm$  0.00 &   YP  \\
;;  \hline
;;  2014-05-07/21:19:39.118 &      0.11$\pm$  0.12 &     69.40$\pm$  0.70 &      0.45$\pm$  0.03 &      0.15$\pm$  0.01 &      0.12$\pm$  0.01 &      0.11$\pm$  0.01 &   YS  \\
;;  \hline
;;  2014-05-29/08:26:41.450 &      0.19$\pm$  0.20 &     64.20$\pm$  4.30 &      0.47$\pm$  0.05 &      0.12$\pm$  0.02 &      0.09$\pm$  0.02 &      0.08$\pm$  0.01 &   YS  \\
;;  \hline
;;  2014-07-14/13:38:09.110 &      0.33$\pm$  0.37 &     70.20$\pm$  5.00 &      0.48$\pm$  0.08 &      0.15$\pm$  0.04 &      0.11$\pm$  0.03 &      0.10$\pm$  0.03 &   YU  \\
;;  \hline
;;  2015-05-06/00:55:49.856 &      0.20$\pm$  0.20 &     87.50$\pm$  9.50 &      0.93$\pm$  0.11 &      0.85$\pm$  0.57 &      0.66$\pm$  0.44 &      0.60$\pm$  0.40 &   YU  \\
;;  \hline
;;  2015-06-05/08:30:57.400 &      0.83$\pm$  0.86 &     84.50$\pm$  7.70 &      0.79$\pm$  0.24 &      0.61$\pm$  0.49 &      0.47$\pm$  0.38 &      0.43$\pm$  0.35 &   MU  \\
;;  \hline
;;  2015-06-24/13:07:15.538 &      0.06$\pm$  0.06 &     85.50$\pm$  3.30 &      0.75$\pm$  0.08 &      1.19$\pm$  0.88 &      0.92$\pm$  0.68 &      0.84$\pm$  0.62 &   YS  \\
;;  \hline
;;  2015-08-15/07:43:42.090 &      0.09$\pm$  0.09 &     56.80$\pm$  0.80 &      0.94$\pm$  0.09 &      0.19$\pm$  0.02 &      0.15$\pm$  0.01 &      0.14$\pm$  0.01 &   YM  \\
;;  \hline
;;  2016-03-11/04:29:17.468 &      0.68$\pm$  0.67 &     53.10$\pm$  4.20 &      0.78$\pm$  0.21 &      0.11$\pm$  0.02 &      0.09$\pm$  0.01 &      0.08$\pm$  0.01 &   YU  \\
;;  \hline
;;  2016-03-14/16:16:32.196 &      0.82$\pm$  0.75 &     61.40$\pm$  8.10 &      0.82$\pm$  0.22 &      0.15$\pm$  0.04 &      0.11$\pm$  0.03 &      0.11$\pm$  0.03 &   YU  \\[-11.5pt]
;;  \hline





