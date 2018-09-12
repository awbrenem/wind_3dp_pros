;+
;*****************************************************************************************
;
;  BATCH    :   load_thm_FS_eVDFs_calc_sh_parms_batch.pro
;  PURPOSE  :   This is a batch file to be called from the command line using the
;                 standard method of calling
;                 (i.e., @load_thm_FS_eVDFs_calc_sh_parms_batch.pro).
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               
;
;  REQUIRES:    
;               1)  THEMIS TDAS IDL libraries and UMN Modified Wind/3DP IDL Libraries
;               2)  MUST run comp_lynn_pros.pro prior to calling this routine
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               ;;  Load all ESA, State, and FGM data for 2008-07-26 for Probe B
;               ;;  **********************************************
;               ;;  **  variable names MUST exactly match these **
;               ;;  **********************************************
;               probe          = 'b'
;               tdate          = '2008-07-26'
;               date           = '072608'
;               @load_thm_FS_eVDFs_calc_sh_parms_batch.pro
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Updated data-specific parameters for THC on 2008-09-16
;                                                                   [01/28/2016   v1.0.1]
;             2)  Changed where STOP statement occurs
;                                                                   [02/02/2016   v1.1.0]
;
;   NOTES:      
;               1)  This batch routine expects a date (in two formats) and a probe,
;                     all input on the command line prior to calling (see EXAMPLES)
;               2)  If your paths are not set correctly, you may need to provide a full
;                     path to this routine, e.g., on my machine this is:
;               @$HOME/Desktop/swidl-0.1/IDL_Stuff/cribs/THEMIS_cribs/foreshock_eVDFs_fits/load_thm_FS_eVDFs_calc_sh_parms_batch.pro
;
;  REFERENCES:  
;               1)  McFadden, J.P., C.W. Carlson, D. Larson, M. Ludlam, R. Abiad,
;                      B. Elliot, P. Turin, M. Marckwordt, and V. Angelopoulos
;                      "The THEMIS ESA Plasma Instrument and In-flight Calibration,"
;                      Space Sci. Rev. 141, pp. 277-302, (2008).
;               2)  McFadden, J.P., C.W. Carlson, D. Larson, J.W. Bonnell,
;                      F.S. Mozer, V. Angelopoulos, K.-H. Glassmeier, U. Auster
;                      "THEMIS ESA First Science Results and Performance Issues,"
;                      Space Sci. Rev. 141, pp. 477-508, (2008).
;               3)  Auster, H.U., K.-H. Glassmeier, W. Magnes, O. Aydogar, W. Baumjohann,
;                      D. Constantinescu, D. Fischer, K.H. Fornacon, E. Georgescu,
;                      P. Harvey, O. Hillenmaier, R. Kroth, M. Ludlam, Y. Narita,
;                      R. Nakamura, K. Okrafka, F. Plaschke, I. Richter, H. Schwarzl,
;                      B. Stoll, A. Valavanoglou, and M. Wiedemann "The THEMIS Fluxgate
;                      Magnetometer," Space Sci. Rev. 141, pp. 235-264, (2008).
;               6)  Angelopoulos, V. "The THEMIS Mission," Space Sci. Rev. 141,
;                      pp. 5-34, (2008).
;
;   CREATED:  01/15/2016
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/02/2016   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-



;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
c              = 2.9979245800d+08         ;;  Speed of light in vacuum [m s^(-1), 2014 CODATA/NIST]
GG             = 6.6740800000d-11         ;;  Newtonian Constant [m^(3) kg^(-1) s^(-1), 2014 CODATA/NIST]
kB             = 1.3806485200d-23         ;;  Boltzmann Constant [J K^(-1), 2014 CODATA/NIST]
SB             = 5.6703670000d-08         ;;  Stefan-Boltzmann Constant [W m^(-2) K^(-4), 2014 CODATA/NIST]
hh             = 6.6260700400d-34         ;;  Planck Constant [J s, 2014 CODATA/NIST]
qq             = 1.6021766208d-19         ;;  Fundamental charge [C, 2014 CODATA/NIST]
epo            = 8.8541878170d-12         ;;  Permittivity of free space [F m^(-1), 2014 CODATA/NIST]
muo            = !DPI*4.00000d-07         ;;  Permeability of free space [N A^(-2) or H m^(-1), 2014 CODATA/NIST]
ma             = 6.6446572300d-27         ;;  Alpha particle mass [kg, 2014 CODATA/NIST]
me             = 9.1093835600d-31         ;;  Electron mass [kg, 2014 CODATA/NIST]
mn             = 1.6749274710d-27         ;;  Neutron mass [kg, 2014 CODATA/NIST]
mp             = 1.6726218980d-27         ;;  Proton mass [kg, 2014 CODATA/NIST]
;;  --> Define mass of particles in units of energy [eV]
ma_eV          = ma[0]*c[0]^2/qq[0]       ;;  ~3727.379378(23) [MeV, 2014 CODATA/NIST]
me_eV          = me[0]*c[0]^2/qq[0]       ;;  ~0.5109989461(31) [MeV, 2014 CODATA/NIST]
mn_eV          = mn[0]*c[0]^2/qq[0]       ;;  ~939.5654133(58) [MeV, 2014 CODATA/NIST]
mp_eV          = mp[0]*c[0]^2/qq[0]       ;;  ~938.2720813(58) [MeV, 2014 CODATA/NIST]
;;  Astronomical
R_Ea__m        = 6.3781366d06             ;;  Earth's Mean Equatorial Radius [m, 2016 AA values]
M_E            = 5.9722000d24             ;;  Earth's mass [kg, 2015 AA values]
au             = 1.49597870700d+11        ;;  1 astronomical unit or AU [m, from Mathematica 10.1 on 2015-04-21]
R_E            = R_Ea__m[0]*1d-3          ;;  m --> km
;;  Conversion Factors
f_1eV          = qq[0]/hh[0]              ;;  Freq. associated with 1 eV of energy [ Hz --> f_1eV*energy{eV} = freq{Hz} ]
J_1eV          = hh[0]*f_1eV[0]           ;;  Energy associated with 1 eV of energy [ J --> J_1eV*energy{eV} = energy{J} ]
K_eV           = qq[0]/kB[0]              ;;  Temp. associated with 1 eV of energy [11,604.5221 K/eV, 2014 CODATA/NIST --> K_eV*energy{eV} = Temp{K}]
eV_K           = kB[0]/qq[0]              ;;  Energy associated with 1 K Temp. [8.6173303 x 10^(-5) eV/K, 2014 CODATA/NIST --> eV_K*Temp{K} = energy{eV}]
valfen__fac    = 1d-9/SQRT(muo[0]*mp[0]*1d6)       ;;  factor for (proton-only) Alfvén speed [m s^(-1) nT^(-1) cm^(-3/2)]
gam            = 5d0/3d0                  ;;  Use gamma = 5/3
rho_fac        = (me[0] + mp[0])*1d6      ;;  kg, cm^(-3) --> m^(-3)
cs_fac         = SQRT(gam[0]/rho_fac[0])
;;  Useful variables
slash          = get_os_slash()       ;;  '/' for Unix, '\' for Windows
all_scs        = ['a','b','c','d','e']
coord_ssl      = 'ssl'
coord_dsl      = 'dsl'
coord_gse      = 'gse'
coord_gsm      = 'gsm'
coord_mag      = 'mag'
fb_string      = ['f','b']
vec_str        = ['x','y','z']
fac_vec_str    = ['perp1','perp2','para']
fac_dir_str    = ['para','perp','anti']
vec_col        = [250,150,50]

start_of_day_t = '00:00:00.000000000'
end___of_day_t = '23:59:59.999999999'
def__lim       = {YSTYLE:1,PANEL_SIZE:2.,XMINOR:5,XTICKLEN:0.04,YTICKLEN:0.01}
;;  Define dummy time range arrays for later use
dt_70          = [-1,1]*7d1
dt_140         = [-1,1]*14d1
dt_200         = [-1,1]*20d1
dt_250         = [-1,1]*25d1
dt_400         = [-1,1]*40d1
;;  Define dummy error messages
dummy_errmsg   = ['You have not defined the proper input!',          $
                  'This batch routine expects three inputs',         $
                  'with following EXACT variable names:',            $
                  "date   ;; e.g., '072608' for July 26, 2008",      $
                  "tdate  ;; e.g., '2008-07-26' for July 26, 2008",  $
                  "probe  ;; e.g., 'b' for Probe B"                  ]
nderrmsg       = N_ELEMENTS(dummy_errmsg) - 1L
;;----------------------------------------------------------------------------------------
;;  Define and times/dates Probe from input
;;----------------------------------------------------------------------------------------
test           = (N_ELEMENTS(date) EQ 0) OR (N_ELEMENTS(tdate) EQ 0) OR $
                 (N_ELEMENTS(probe) EQ 0)
IF (test[0]) THEN FOR pj=0L, nderrmsg[0] DO PRINT,dummy_errmsg[pj]
IF (test[0]) THEN PRINT,'%%  Stopping before starting...'
IF (test[0]) THEN STOP             ;;  Stop before user runs into issues
;;  Check TDATE format
test           = test_tdate_format(tdate)
IF (test[0] EQ 0) THEN STOP        ;;  Stop before user runs into issues
;;----------------------------------------------------------------------------------------
;;  Load all relevant data
;;----------------------------------------------------------------------------------------
@/Users/lbwilson/Desktop/swidl-0.1/IDL_stuff/cribs/THEMIS_cribs/foreshock_eVDFs_fits/load_themis_foreshock_eVDFs_batch.pro
;;  Create a new TPLOT handle containing the spacecraft position information in DSL coordinates
;;    -->  Needed for the SST data, which have not been rotated into GSE
coords         = [coord_dsl[0],coord_gse[0]]
in__name       = scpref[0]+'state_pos_'+coord_gse[0]
out_name       = scpref[0]+'state_pos_'+coord_dsl[0]
thm_cotrans,in__name[0],out_name[0],IN_COORD=coords[1],OUT_COORD=coords[0],VERBOSE=0
;;  Set timespan to keep TPLOT happy...
timespan,tdate[0]+'/'+start_of_day_t[0],1d0,/DAYS
;;  Load AE Indices
thm_make_AE
;;  Remove unwanted/unnecessary TPLOT handles
thm_gr_tpn     = tnames('thg_mag_*')
store_data,DELETE=thm_gr_tpn
;;  Rename the default AE Index outputs
store_data,'thmAL',NEWNAME=scpref[0]+'AL_Index'
store_data,'thmAU',NEWNAME=scpref[0]+'AU_Index'
store_data,'thmAE',NEWNAME=scpref[0]+'AE_Index'
aeindex_tpn    = tnames(scpref[0]+'AE_Index')
IF (tdate[0] EQ '2008-07-14') THEN ae_ran  = [3e1,50e1]
IF (tdate[0] EQ '2008-08-19') THEN ae_ran  = [3e1,30e1]
IF (tdate[0] EQ '2008-09-08') THEN ae_ran  = [6e1,23e1]
options,aeindex_tpn[0],YRANGE=ae_ran,YLOG=0,COLORS=30,/DEF
options,aeindex_tpn[0],YGRIDSTYLE=2,YTICKLEN=1e0
options,aeindex_tpn[0],'YRANGE'
options,aeindex_tpn[0],'YLOG'
options,aeindex_tpn[0],'YMINOR'
;;----------------------------------------------------------------------------------------
;;  Sort and modify relevant data
;;----------------------------------------------------------------------------------------
n_e            = N_ELEMENTS(dat_egse)
n_i            = N_ELEMENTS(dat_igse)
tra_sst        = time_double(tr_00)
;;  Sort by time (since it was not done, apparently)
sp             = SORT(dat_egse.TIME)
dat_egse       = TEMPORARY(dat_egse[sp])
sp             = SORT(dat_igse.TIME)
dat_igse       = TEMPORARY(dat_igse[sp])
;;  Insert NaNs at intervals for FGM data
fgs_tpns       = tnames(scpref[0]+'fgl_*')
fgl_tpns       = tnames(scpref[0]+'fgl_*')
fgh_tpns       = tnames(scpref[0]+'fgh_*')
t_insert_nan_at_interval_se,fgs_tpns,GAP_THRESH=4d0
t_insert_nan_at_interval_se,fgl_tpns,GAP_THRESH=1d0/3d0
t_insert_nan_at_interval_se,fgh_tpns,GAP_THRESH=1d0/100d0
;;  Insert NaNs at intervals for ESA Burst data
esasuffx       = ['density','avgtemp','velocity_*','magt3','ptens']
t_insert_nan_at_interval_se,tnames(scpref[0]+'pe*b_'+esasuffx),GAP_THRESH=3.5d0
;;  Set defaults
lbw_tplot_set_defaults
tplot_options, 'XMARGIN',[20,15]      ;;  Change X-Margins slightly

fgs_tpns       = scpref[0]+'fgs_'+[coord_mag[0],coord_gse[0]]
fgl_tpns       = scpref[0]+'fgl_'+[coord_mag[0],coord_gse[0]]
fgh_tpns       = scpref[0]+'fgh_'+[coord_mag[0],coord_gse[0]]

tplot,fgs_tpns,TRANGE=tra_sst
;;  Determine fgh time intervals
fghnm          = scpref[0]+'fgh_'+[coord_mag[0],coord_gse[0]]
get_data,fghnm[0],DATA=temp,DLIM=dlim,LIM=lim
gap_thsh       = 1d-2
srate          = sample_rate(temp.X,GAP_THRESH=gap_thsh[0],/AVE,OUT_MED_AVG=sr_medavg)
med_sr         = sr_medavg[0]                     ;;  Median sample rate [sps]
med_dt         = 1d0/med_sr[0]                    ;;  Median sample period [s]
se_int         = t_interval_find(temp.X,GAP_THRESH=2d0*med_dt[0],/NAN)
sint_fgh       = temp.X[REFORM(se_int[*,0])]
eint_fgh       = temp.X[REFORM(se_int[*,1])]
;;  Some gaps on 2008-08-19 --> Merge intervals
IF (tdate[0] EQ '2008-08-19') THEN sint_fgh = TEMPORARY([sint_fgh[0],sint_fgh[3:6],sint_fgh[10]])
IF (tdate[0] EQ '2008-08-19') THEN eint_fgh = TEMPORARY([eint_fgh[2],eint_fgh[3:5],eint_fgh[9],eint_fgh[13]])
;;----------------------------------------------------------------------------------------
;;  Define relevant time ranges
;;----------------------------------------------------------------------------------------
;;  Initialize defaults
t_tr_0         = tdate[0]+'/'+[start_of_day_t[0],end___of_day_t[0]]
t_tr_1         = t_tr_0
t_tr_2         = t_tr_0
t_tr_3         = t_tr_0
t_tr_4         = t_tr_0
t_tr_5         = t_tr_0
t_slam_cent    = tdate[0]+'/12:00:00.000000000'
t_hfa__cent    = t_slam_cent[0]
t_fb___cent    = t_slam_cent[0]
;;  Define date-specific time ranges
IF (tdate[0] EQ '2008-07-14') THEN t_tr_0 = tdate[0]+'/'+['12:19:46.000000','12:31:13.000000']
IF (tdate[0] EQ '2008-07-14') THEN t_tr_1 = tdate[0]+'/'+['13:10:43.900000','13:20:50.200000']
IF (tdate[0] EQ '2008-07-14') THEN t_tr_2 = tdate[0]+'/'+['15:17:03.300000','15:27:08.000000']
IF (tdate[0] EQ '2008-07-14') THEN t_tr_3 = tdate[0]+'/'+['19:57:59.400000','20:08:04.700000']
IF (tdate[0] EQ '2008-07-14') THEN t_tr_4 = tdate[0]+'/'+['21:53:44.000000','22:14:03.000000']
IF (tdate[0] EQ '2008-07-14') THEN t_tr_5 = tdate[0]+'/'+['22:33:28.800000','22:43:39.400000']
;;  Define center-times for specific TIFP
IF (tdate[0] EQ '2008-07-14') THEN t_slam_cent = tdate[0]+'/'+['13:16:26','13:19:30']
IF (tdate[0] EQ '2008-07-14') THEN t_hfa__cent = tdate[0]+'/'+['15:21:00','22:37:22']
IF (tdate[0] EQ '2008-07-14') THEN t_fb___cent = tdate[0]+'/'+['20:03:21','21:55:45','21:58:10']

IF (tdate[0] EQ '2008-08-19') THEN t_slam_cent = tdate[0]+'/'+['21:48:55','21:53:45','22:17:35','22:18:30','22:22:30','22:37:45','22:42:48']
IF (tdate[0] EQ '2008-08-19') THEN t_hfa__cent = tdate[0]+'/'+['12:50:57','21:46:17','22:41:00']
IF (tdate[0] EQ '2008-08-19') THEN t_fb___cent = tdate[0]+'/'+['20:43:35','21:51:45']

IF (tdate[0] EQ '2008-09-08') THEN t_slam_cent = tdate[0]+'/'+['17:28:23','20:24:50','20:36:11','21:12:24','21:15:33']
IF (tdate[0] EQ '2008-09-08') THEN t_hfa__cent = tdate[0]+'/'+['17:01:41','19:13:57','20:26:44']
IF (tdate[0] EQ '2008-09-08') THEN t_fb___cent = tdate[0]+'/20:25:22'

IF (tdate[0] EQ '2008-09-16') THEN t_slam_cent = tdate[0]+'/'+['00:00:00']
IF (tdate[0] EQ '2008-09-16') THEN t_hfa__cent = tdate[0]+'/'+['17:26:45']
IF (tdate[0] EQ '2008-09-16') THEN t_fb___cent = tdate[0]+'/'+['17:46:13']
;;  Define Unix version of time ranges
temp_tr0       = time_double(t_tr_0)
temp_tr1       = time_double(t_tr_1)
temp_tr2       = time_double(t_tr_2)
temp_tr3       = time_double(t_tr_3)
temp_tr4       = time_double(t_tr_4)
temp_tr5       = time_double(t_tr_5)
;;  Define several time windows
FOR j=0L, N_ELEMENTS(t_slam_cent) - 1L DO BEGIN                                                $
  unix_0   = time_double(t_slam_cent[j])                                                     & $
  unix_ras = unix_0[0] + [dt_70[0],dt_140[0],dt_200[0],dt_250[0],dt_400[0]]                  & $
  unix_rae = unix_0[0] + [dt_70[1],dt_140[1],dt_200[1],dt_250[1],dt_400[1]]                  & $
  unix_ra  = [[unix_ras],[unix_rae]]                                                         & $
  IF (j EQ 0) THEN tr_slam_70  = unix_ra[0,*] ELSE tr_slam_70  = [tr_slam_70, unix_ra[0,*]]  & $
  IF (j EQ 0) THEN tr_slam_140 = unix_ra[1,*] ELSE tr_slam_140 = [tr_slam_140,unix_ra[1,*]]  & $
  IF (j EQ 0) THEN tr_slam_200 = unix_ra[2,*] ELSE tr_slam_200 = [tr_slam_200,unix_ra[2,*]]  & $
  IF (j EQ 0) THEN tr_slam_250 = unix_ra[3,*] ELSE tr_slam_250 = [tr_slam_250,unix_ra[3,*]]  & $
  IF (j EQ 0) THEN tr_slam_400 = unix_ra[4,*] ELSE tr_slam_400 = [tr_slam_400,unix_ra[4,*]]

FOR j=0L, N_ELEMENTS(t_hfa__cent) - 1L DO BEGIN                                                $
  unix_0   = time_double(t_hfa__cent[j])                                                     & $
  unix_ras = unix_0[0] + [dt_70[0],dt_140[0],dt_200[0],dt_250[0],dt_400[0]]                  & $
  unix_rae = unix_0[0] + [dt_70[1],dt_140[1],dt_200[1],dt_250[1],dt_400[1]]                  & $
  unix_ra  = [[unix_ras],[unix_rae]]                                                         & $
  IF (j EQ 0) THEN tr_hfa__70  = unix_ra[0,*] ELSE tr_hfa__70  = [tr_hfa__70, unix_ra[0,*]]  & $
  IF (j EQ 0) THEN tr_hfa__140 = unix_ra[1,*] ELSE tr_hfa__140 = [tr_hfa__140,unix_ra[1,*]]  & $
  IF (j EQ 0) THEN tr_hfa__200 = unix_ra[2,*] ELSE tr_hfa__200 = [tr_hfa__200,unix_ra[2,*]]  & $
  IF (j EQ 0) THEN tr_hfa__250 = unix_ra[3,*] ELSE tr_hfa__250 = [tr_hfa__250,unix_ra[3,*]]  & $
  IF (j EQ 0) THEN tr_hfa__400 = unix_ra[4,*] ELSE tr_hfa__400 = [tr_hfa__400,unix_ra[4,*]]

FOR j=0L, N_ELEMENTS(t_fb___cent) - 1L DO BEGIN                                                $
  unix_0   = time_double(t_fb___cent[j])                                                     & $
  unix_ras = unix_0[0] + [dt_70[0],dt_140[0],dt_200[0],dt_250[0],dt_400[0]]                  & $
  unix_rae = unix_0[0] + [dt_70[1],dt_140[1],dt_200[1],dt_250[1],dt_400[1]]                  & $
  unix_ra  = [[unix_ras],[unix_rae]]                                                         & $
  IF (j EQ 0) THEN tr_fb___70  = unix_ra[0,*] ELSE tr_fb___70  = [tr_fb___70, unix_ra[0,*]]  & $
  IF (j EQ 0) THEN tr_fb___140 = unix_ra[1,*] ELSE tr_fb___140 = [tr_fb___140,unix_ra[1,*]]  & $
  IF (j EQ 0) THEN tr_fb___200 = unix_ra[2,*] ELSE tr_fb___200 = [tr_fb___200,unix_ra[2,*]]  & $
  IF (j EQ 0) THEN tr_fb___250 = unix_ra[3,*] ELSE tr_fb___250 = [tr_fb___250,unix_ra[3,*]]  & $
  IF (j EQ 0) THEN tr_fb___400 = unix_ra[4,*] ELSE tr_fb___400 = [tr_fb___400,unix_ra[4,*]]

;;  Show location of SLAMS, HFAs, and FBs
time_bar,t_slam_cent,COLOR=250
time_bar,t_hfa__cent,COLOR=200
time_bar,t_fb___cent,COLOR= 30
;;----------------------------------------------------------------------------------------
;;  Calculate bow shock parameters
;;----------------------------------------------------------------------------------------
;;    bow shock model [Slavin and Holzer, [1981]]
ecc            = (1.10 + 1.20)/2d0                       ; => eccentricity      [Table 4 estimates]
Lsemi          = (22.9 + 23.5)/2d0                       ; => semi-latus rectum [Re, Table 4 estimates]
;xo             = 1.2d0
xo             = 3.0d0                                   ;;  position of focus along X-axis
IF (tdate[0] EQ '2008-07-14') THEN xo = 2.40
IF (tdate[0] EQ '2008-08-19') THEN xo = 5.20
IF (tdate[0] EQ '2008-09-08') THEN xo = 2.70
IF (tdate[0] EQ '2008-09-16') THEN xo = 4.00
bow            = {STANDOFF:Lsemi[0],ECCENTRICITY:ecc[0],X_OFFSET:xo[0]}
;;  Define time range to use for BS parameter calcs
IF (tdate[0] EQ '2008-07-14') THEN tr_bs_cal = time_double(tdate[0]+'/'+['11:52:00',end___of_day_t[0]])
IF (tdate[0] EQ '2008-08-19') THEN tr_bs_cal = time_double(tdate[0]+'/'+['12:00:00',end___of_day_t[0]])
IF (tdate[0] EQ '2008-09-08') THEN tr_bs_cal = time_double(tdate[0]+'/'+['16:30:00','21:32:00'])
IF (tdate[0] EQ '2008-09-16') THEN tr_bs_cal = time_double(tdate[0]+'/'+['12:20:00',end___of_day_t[0]])
;;  Get Bo and R_sc data
thm_pos_tpn    = scpref[0]+'state_pos_'+coord_gse[0]
thm_vsw_tpn    = scpref[0]+'peir_velocity_'+coord_gse[0]
get_data,   fgs_tpns[1],DATA=thm_bo,DLIM=dlim_bo,LIM=lim_bo
get_data,thm_pos_tpn[0],DATA=thm_ro,DLIM=dlim_ro,LIM=lim_ro
get_data,thm_vsw_tpn[0],DATA=thm_Vi,DLIM=dlim_Vi,LIM=lim_Vi
;;  Check structures
test_mag       = tplot_struct_format_test(thm_bo,/YVECT,/NOMSSG)
test_pos       = tplot_struct_format_test(thm_ro,/YVECT,/NOMSSG)
test_vsw       = tplot_struct_format_test(thm_Vi,/YVECT,/NOMSSG)
;;  Convert to Re
IF (test_pos[0]) THEN thm_ro1 = {X:thm_ro.X,Y:thm_ro.Y/R_E[0]}
;;  Clip the data to the specified time range
IF (test_pos[0]) THEN thm_ro2 = trange_clip_data(thm_ro1,TRANGE=tr_bs_cal,PREC=3)
IF (test_mag[0]) THEN thm_bo2 = trange_clip_data( thm_bo,TRANGE=tr_bs_cal,PREC=3)
IF (test_vsw[0]) THEN thm_Vi2 = trange_clip_data( thm_Vi,TRANGE=tr_bs_cal,PREC=3)
;;  Re-sample the data to Bo time stamps [if present]
IF (test_mag[0]) THEN thm_bo3 = thm_bo2
IF (test_mag[0] AND test_pos[0]) THEN thm_ro3 = t_resample_tplot_struc(thm_ro2,thm_bo3.X,/NO_EXTRAPOLATE)
IF (test_mag[0] AND test_vsw[0]) THEN thm_Vi3 = t_resample_tplot_struc(thm_Vi2,thm_bo3.X,/NO_EXTRAPOLATE)
;;  Calculate model BS params
.compile $HOME/Desktop/swidl-0.1/wind_3dp_pros/DAVIN_PRO/cal_bs_param.pro
test_all       = (test_mag[0] AND test_pos[0] AND test_vsw[0])
IF (test_all[0]) THEN pos = thm_ro3.Y
IF (test_all[0]) THEN magf           = thm_bo3.Y
IF (test_all[0]) THEN vsw            = thm_Vi3.Y
IF (test_all[0]) THEN cal_bs_param,pos,magf,BOW=bow,VSW=vsw,STRUCT=bs_par_str
;;  Define parameters to send to TPLOT [if present]
test_all       = test_all[0] AND (SIZE(bs_par_str,/TYPE) EQ 8)
smwd           = 25L                              ;;  Width of smoothing points
IF (test_all[0]) THEN n_sh           = bs_par_str.SHNORM
IF (test_all[0]) THEN shpos          = bs_par_str.SHPOS
IF (test_all[0]) THEN thetabn        = bs_par_str.BSN
IF (test_all[0]) THEN lsh_n          = bs_par_str.LSN
IF (test_all[0]) THEN diff           = mag__vec(pos,/NAN) - mag__vec(shpos,/NAN)
IF (test_all[0]) THEN bad            = WHERE(diff LE 0,bd)
IF (test_all[0]) THEN IF (bd[0] GT 0) THEN thetabn[bad] = f
IF (test_all[0]) THEN IF (bd[0] GT 0) THEN lsh_n[bad]   = f
IF (test_all[0]) THEN IF (bd[0] GT 0) THEN n_sh[bad,*]  = f
IF (test_all[0]) THEN thetabnc       = thetabn < (18e1 - thetabn)       ;;  Complementary angle only [deg]
;;  Calculate smoothed versions of parameters
IF (test_all[0]) THEN thetabn_sm     = SMOOTH(thetabn,smwd[0],/NAN,/EDGE_TRUNCATE)
IF (test_all[0]) THEN lsh_n_sm       = SMOOTH(lsh_n,smwd[0],/NAN,/EDGE_TRUNCATE)
IF (test_all[0]) THEN thetabnc_sm    = SMOOTH(thetabnc,smwd[0],/NAN,/EDGE_TRUNCATE)
IF (test_all[0]) THEN n_sh_x_sm      = SMOOTH(n_sh[*,0],smwd[0],/NAN,/EDGE_TRUNCATE)
IF (test_all[0]) THEN n_sh_y_sm      = SMOOTH(n_sh[*,1],smwd[0],/NAN,/EDGE_TRUNCATE)
IF (test_all[0]) THEN n_sh_z_sm      = SMOOTH(n_sh[*,2],smwd[0],/NAN,/EDGE_TRUNCATE)
IF (test_all[0]) THEN n_sh_sm        = [[n_sh_x_sm],[n_sh_y_sm],[n_sh_z_sm]]
IF (test_all[0]) THEN lshn_struc     = {X:thm_bo3.X,Y:[[lsh_n],[lsh_n_sm]]}
IF (test_all[0]) THEN thbn_struc     = {X:thm_bo3.X,Y:[[thetabn],[thetabn_sm]]}
IF (test_all[0]) THEN tbnc_struc     = {X:thm_bo3.X,Y:[[thetabnc],[thetabnc_sm]]}

thm_lsn_tpn    = scpref[0]+'lshn_re'
thm_bsn_tpn    = scpref[0]+'BS_thbn_deg'
thm_bsntpn2    = scpref[0]+'BS_thbn_c_deg'
tlabs          = ['Value','Smoothed']
tcols          = vec_col[[2,0]]
IF (test_all[0]) THEN store_data,thm_lsn_tpn[0],DATA=lshn_struc,LIM=lim_ro
IF (test_all[0]) THEN store_data,thm_bsn_tpn[0],DATA=thbn_struc,LIM=lim_ro
IF (test_all[0]) THEN store_data,thm_bsntpn2[0],DATA=tbnc_struc,LIM=lim_ro
IF (test_all[0]) THEN options,thm_lsn_tpn[0],YTITLE='(Lsh . n)',YSUBTITLE='[Re]',COLORS=tcols,LABELS=tlabs,/DEF
IF (test_all[0]) THEN options,thm_bsn_tpn[0],YTITLE='(Bo . n)',YSUBTITLE='[deg]',COLORS=tcols,LABELS=tlabs,/DEF
IF (test_all[0]) THEN options,thm_bsntpn2[0],YTITLE='|(Bo . n)|',YSUBTITLE='[deg]',COLORS=tcols,LABELS=tlabs,/DEF
IF (test_all[0]) THEN options,thm_bsntpn2[0],YRANGE=[0e0,9e1],YTICKV=LINDGEN(7)*15e0,YTICKS=6,YMINOR=4,/DEF
IF (test_all[0]) THEN options,thm_bsntpn2[0],YGRIDSTYLE=2,YTICKLEN=1e0
;;----------------------------------------------------------------------------------------
;;  Calculate bow shock Mach numbers (assuming shock is stationary in Earth frame)
;;----------------------------------------------------------------------------------------
thm_vbulk_tpn  = scpref[0]+'peir_velocity_'+coord_gse[0]
thm_ipten_tpn  = scpref[0]+'peir_ptens'
thm_idens_tpn  = scpref[0]+'peir_density'
thm_itemp_tpn  = scpref[0]+'peir_avgtemp'
thm_etemp_tpn  = scpref[0]+'peer_avgtemp'
thm_epten_tpn  = scpref[0]+'peer_ptens'
thm_thebn_tpn  = scpref[0]+'BS_sm_thbn_c_deg'
thm_ushn__tpn  = scpref[0]+'BS_sm_Ushn'
;;  Define TPLOT handles for speed and Mach number outputs
tpn_midfn      = 'fgs_peir_'
thm_V_A___tpn  = scpref[0]+tpn_midfn[0]+'V_A'
thm_C_s___tpn  = scpref[0]+tpn_midfn[0]+'C_s'
thm_V_f___tpn  = scpref[0]+tpn_midfn[0]+'V_f'
thm_Vms___tpn  = scpref[0]+tpn_midfn[0]+'Vms'
thm_Mms___tpn  = scpref[0]+tpn_midfn[0]+'Mms'
thm_Machs_tpn  = scpref[0]+tpn_midfn[0]+'BS_Ma_Ms_Mf'

;;  Create Ushn tplot variable
IF (test_all[0]) THEN n_sh_str = {X:thm_bo3.X,Y:n_sh_sm}
IF (test_all[0]) THEN thbn_str = {X:thm_bo3.X,Y:thetabnc_sm}
IF (test_all[0]) THEN vi_d_nsh = ABS(my_dot_prod(thm_Vi3.Y,n_sh_sm,/NOM))
IF (test_all[0]) THEN vn_str   = {X:thm_bo3.X,Y:vi_d_nsh}
IF (test_all[0]) THEN store_data,thm_thebn_tpn[0],DATA=thbn_str,LIMIT=def__lim
IF (test_all[0]) THEN store_data,thm_ushn__tpn[0],DATA=vn_str,LIMIT=def__lim
;;  Calculate relevant speeds and associated Mach numbers
IF (test_all[0]) THEN $
t_calc_and_send_machs_2_tplot,thm_ushn__tpn[0],thm_idens_tpn[0],fgs_tpns[0],3b,         $
                              TPN__TE=thm_etemp_tpn[0],TPN__TI=thm_itemp_tpn[0],        $
                              TPN_THE=thm_thebn_tpn[0],GAMM_E=gam[0],                   $
                              GAMM_I=gam[0],Z_I=1d0,M_I=mp[0],                          $
                              TPN_VA_OUT=thm_V_A___tpn[0],TPN_CS_OUT=thm_C_s___tpn[0],  $
                              TPN_VM_OUT=thm_Vms___tpn[0],TPN_VF_OUT=thm_V_f___tpn[0],  $
                              TPN_MM_OUT=thm_Mms___tpn[0],TPNACS_OUT=thm_Machs_tpn[0]
;IF (no_load_spec) THEN STOP
;;----------------------------------------------------------------------------------------
;;  Load SST data
;;----------------------------------------------------------------------------------------
vern           = !VERSION.RELEASE     ;;  e.g., '7.1.1'
test           = (vern[0] GE '6.0')
IF (test[0]) THEN cwd_char = FILE_DIRNAME('',/MARK_DIRECTORY) ELSE cwd_char = '.'+slash[0]
cur_wdir       = FILE_EXPAND_PATH(cwd_char[0])
new_ts_dir     = add_os_slash(cur_wdir[0]);+'themis_data_dir'+slash[0]
new_sst_dir    = new_ts_dir[0]+'themis_sst_save'+slash[0]+tdate[0]+slash[0]
esname         = 'SSTE_*_THEMIS_'+sc[0]+'_Structures_'+tdate[0]+'_lz_counts.sav'
isname         = 'SSTI_*_THEMIS_'+sc[0]+'_Structures_'+tdate[0]+'_lz_counts.sav'
sste_file      = FILE_SEARCH(new_sst_dir[0],esname[0])
ssti_file      = FILE_SEARCH(new_sst_dir[0],isname[0])
test_sste      = (sste_file[0] NE '')
test_ssti      = (ssti_file[0] NE '')
IF (test_sste[0]) THEN RESTORE,sste_file[0]  ;;  Restore SST Electron structures
IF (test_ssti[0]) THEN RESTORE,ssti_file[0]  ;;  Restore SST Ion structures

p_test         = WHERE(all_scs EQ sc[0],pt)
p_t_arr        = [(p_test[0] EQ 0),(p_test[0] EQ 1),(p_test[0] EQ 2),(p_test[0] EQ 3),(p_test[0] EQ 4)]
IF (test_ssti[0] AND p_t_arr[0]) THEN nsif = N_ELEMENTS(psif_df_arr_a)
IF (test_ssti[0] AND p_t_arr[1]) THEN nsif = N_ELEMENTS(psif_df_arr_b)
IF (test_ssti[0] AND p_t_arr[2]) THEN nsif = N_ELEMENTS(psif_df_arr_c)
IF (test_ssti[0] AND p_t_arr[3]) THEN nsif = N_ELEMENTS(psif_df_arr_d)
IF (test_ssti[0] AND p_t_arr[4]) THEN nsif = N_ELEMENTS(psif_df_arr_e)
IF (test_ssti[0] AND p_t_arr[0]) THEN nsib = N_ELEMENTS(psib_df_arr_a)
IF (test_ssti[0] AND p_t_arr[1]) THEN nsib = N_ELEMENTS(psib_df_arr_b)
IF (test_ssti[0] AND p_t_arr[2]) THEN nsib = N_ELEMENTS(psib_df_arr_c)
IF (test_ssti[0] AND p_t_arr[3]) THEN nsib = N_ELEMENTS(psib_df_arr_d)
IF (test_ssti[0] AND p_t_arr[4]) THEN nsib = N_ELEMENTS(psib_df_arr_e)
IF (test_sste[0] AND p_t_arr[0]) THEN nsef = N_ELEMENTS(psef_df_arr_a)
IF (test_sste[0] AND p_t_arr[1]) THEN nsef = N_ELEMENTS(psef_df_arr_b)
IF (test_sste[0] AND p_t_arr[2]) THEN nsef = N_ELEMENTS(psef_df_arr_c)
IF (test_sste[0] AND p_t_arr[3]) THEN nsef = N_ELEMENTS(psef_df_arr_d)
IF (test_sste[0] AND p_t_arr[4]) THEN nsef = N_ELEMENTS(psef_df_arr_e)
IF (test_sste[0] AND p_t_arr[0]) THEN nseb = N_ELEMENTS(pseb_df_arr_a)
IF (test_sste[0] AND p_t_arr[1]) THEN nseb = N_ELEMENTS(pseb_df_arr_b)
IF (test_sste[0] AND p_t_arr[2]) THEN nseb = N_ELEMENTS(pseb_df_arr_c)
IF (test_sste[0] AND p_t_arr[3]) THEN nseb = N_ELEMENTS(pseb_df_arr_d)
IF (test_sste[0] AND p_t_arr[4]) THEN nseb = N_ELEMENTS(pseb_df_arr_e)

IF (nsib[0] GT 0) THEN IF (p_t_arr[0]) THEN dat_sib = psib_df_arr_a ELSE $
                       IF (p_t_arr[1]) THEN dat_sib = psib_df_arr_b ELSE $
                       IF (p_t_arr[2]) THEN dat_sib = psib_df_arr_c ELSE $
                       IF (p_t_arr[3]) THEN dat_sib = psib_df_arr_d ELSE $
                       IF (p_t_arr[4]) THEN dat_sib = psib_df_arr_e

IF (nsif[0] GT 0) THEN IF (p_t_arr[0]) THEN dat_sif = psif_df_arr_a ELSE $
                       IF (p_t_arr[1]) THEN dat_sif = psif_df_arr_b ELSE $
                       IF (p_t_arr[2]) THEN dat_sif = psif_df_arr_c ELSE $
                       IF (p_t_arr[3]) THEN dat_sif = psif_df_arr_d ELSE $
                       IF (p_t_arr[4]) THEN dat_sif = psif_df_arr_e

IF (nseb[0] GT 0) THEN IF (p_t_arr[0]) THEN dat_seb = pseb_df_arr_a ELSE $
                       IF (p_t_arr[1]) THEN dat_seb = pseb_df_arr_b ELSE $
                       IF (p_t_arr[2]) THEN dat_seb = pseb_df_arr_c ELSE $
                       IF (p_t_arr[3]) THEN dat_seb = pseb_df_arr_d ELSE $
                       IF (p_t_arr[4]) THEN dat_seb = pseb_df_arr_e

IF (nsef[0] GT 0) THEN IF (p_t_arr[0]) THEN dat_sef = psef_df_arr_a ELSE $
                       IF (p_t_arr[1]) THEN dat_sef = psef_df_arr_b ELSE $
                       IF (p_t_arr[2]) THEN dat_sef = psef_df_arr_c ELSE $
                       IF (p_t_arr[3]) THEN dat_sef = psef_df_arr_d ELSE $
                       IF (p_t_arr[4]) THEN dat_sef = psef_df_arr_e

PRINT,';; ',nseb[0],nsef[0],nsib[0],nsif[0],'  For Probe:  TH'+STRUPCASE(sc[0])+' on '+tdate[0]
;;         1347         658           0       14009  For Probe:  THC on 2008-07-14
;;         1338         655           0       14019  For Probe:  THC on 2008-08-19
;;         1188         662           0       14092  For Probe:  THC on 2008-09-08
;;----------------------------------------------------------------------------------------
;;  Modify SST structures [just in case]
;;----------------------------------------------------------------------------------------
;;  Modify unit conversion procedure
IF (nsef[0] GT 0) THEN dat_sef.UNITS_PROCEDURE = 'thm_convert_sst_units_lbwiii'
IF (nseb[0] GT 0) THEN dat_seb.UNITS_PROCEDURE = 'thm_convert_sst_units_lbwiii'
IF (nsif[0] GT 0) THEN dat_sif.UNITS_PROCEDURE = 'thm_convert_sst_units_lbwiii'
IF (nsib[0] GT 0) THEN dat_sib.UNITS_PROCEDURE = 'thm_convert_sst_units_lbwiii'

;;  Modify particle charge
IF (nsef[0] GT 0) THEN dat_sef.CHARGE = -1e0
IF (nseb[0] GT 0) THEN dat_seb.CHARGE = -1e0
IF (nsif[0] GT 0) THEN dat_sif.CHARGE = 1e0
IF (nsib[0] GT 0) THEN dat_sib.CHARGE = 1e0
;;----------------------------------------------------------------------------------------
;;  Sort structures
;;----------------------------------------------------------------------------------------
IF (nsef[0] GT 0) THEN sp             =      SORT(dat_sef.TIME)
IF (nsef[0] GT 0) THEN dat_sef        = TEMPORARY(dat_sef[sp])
IF (nseb[0] GT 0) THEN sp             =      SORT(dat_seb.TIME)
IF (nseb[0] GT 0) THEN dat_seb        = TEMPORARY(dat_seb[sp])
IF (nsif[0] GT 0) THEN sp             =      SORT(dat_sif.TIME)
IF (nsif[0] GT 0) THEN dat_sif        = TEMPORARY(dat_sif[sp])
IF (nsib[0] GT 0) THEN sp             =      SORT(dat_sib.TIME)
IF (nsib[0] GT 0) THEN dat_sib        = TEMPORARY(dat_sib[sp])
;;----------------------------------------------------------------------------------------
;;  Determine Earth direction at times of each distribution
;;----------------------------------------------------------------------------------------
fglnm          = scpref[0]+'fgl_'+[coord_mag[0],coord_gse[0]]
fghnm          = scpref[0]+'fgh_'+[coord_mag[0],coord_gse[0]]
;;  Define tests for position vectors
thm_gse_pos_tp = scpref[0]+'state_pos_'+coord_gse[0]
thm_dsl_pos_tp = scpref[0]+'state_pos_'+coord_dsl[0]
test_gse_pos   = test_tplot_handle(thm_gse_pos_tp,TPNMS=tpn_gse_pos)
test_dsl_pos   = test_tplot_handle(thm_dsl_pos_tp,TPNMS=tpn_dsl_pos)
IF (test_gse_pos[0]) THEN get_data,tpn_gse_pos[0],DATA=thm_gse_pos,DLIM=dlim_gse_pos,LIM=lim_gse_pos
IF (test_dsl_pos[0]) THEN get_data,tpn_dsl_pos[0],DATA=thm_dsl_pos,DLIM=dlim_dsl_pos,LIM=lim_dsl_pos
test_gse_pos   = tplot_struct_format_test(thm_gse_pos,/YVECT,/NOMSSG)
test_dsl_pos   = tplot_struct_format_test(thm_dsl_pos,/YVECT,/NOMSSG)
IF (test_gse_pos[0]) THEN gse_pos_t = thm_gse_pos.X
IF (test_gse_pos[0]) THEN gse_pos_v = thm_gse_pos.Y
IF (test_dsl_pos[0]) THEN dsl_pos_t = thm_dsl_pos.X
IF (test_dsl_pos[0]) THEN dsl_pos_v = thm_dsl_pos.Y
;;  Define start/end times for each type of particle structure
tr_eesa        = [[dat_egse.TIME],[dat_egse.END_TIME]]
tr_iesa        = [[dat_igse.TIME],[dat_igse.END_TIME]]
tr_isst        = [[dat_sif.TIME],[dat_sif.END_TIME]]
tr_essb        = [[dat_seb.TIME],[dat_seb.END_TIME]]
tr_essf        = [[dat_sef.TIME],[dat_sef.END_TIME]]

n_eesa         = N_ELEMENTS(dat_egse)
n_iesa         = N_ELEMENTS(dat_igse)
n_essb         = N_ELEMENTS(dat_seb)
n_essf         = N_ELEMENTS(dat_sef)
n_isst         = N_ELEMENTS(dat_sif)
;;  Define SC position in relevant coordinate bases
se_eesa_posi   = REPLICATE(d,n_eesa[0],2L,3L)         ;;  [N,{S,E},{X,Y,Z}]-Element array
se_iesa_posi   = REPLICATE(d,n_iesa[0],2L,3L)         ;;  [N,{S,E},{X,Y,Z}]-Element array
se_essb_posi   = REPLICATE(d,n_essb[0],2L,3L)         ;;  [N,{S,E},{X,Y,Z}]-Element array
se_essf_posi   = REPLICATE(d,n_essf[0],2L,3L)         ;;  [N,{S,E},{X,Y,Z}]-Element array
se_isst_posi   = REPLICATE(d,n_isst[0],2L,3L)         ;;  [N,{S,E},{X,Y,Z}]-Element array
FOR k=0L, 1L DO BEGIN                                                                          $
  IF (test_gse_pos[0]) THEN tempx = INTERPOL(gse_pos_v[*,0],gse_pos_t,tr_eesa[*,k],/SPLINE)  & $
  IF (test_gse_pos[0]) THEN tempy = INTERPOL(gse_pos_v[*,1],gse_pos_t,tr_eesa[*,k],/SPLINE)  & $
  IF (test_gse_pos[0]) THEN tempz = INTERPOL(gse_pos_v[*,2],gse_pos_t,tr_eesa[*,k],/SPLINE)  & $
  IF (test_gse_pos[0]) THEN se_eesa_posi[*,k,*] = [[tempx],[tempy],[tempz]]                  & $
  IF (test_gse_pos[0]) THEN tempx = INTERPOL(gse_pos_v[*,0],gse_pos_t,tr_iesa[*,k],/SPLINE)  & $
  IF (test_gse_pos[0]) THEN tempy = INTERPOL(gse_pos_v[*,1],gse_pos_t,tr_iesa[*,k],/SPLINE)  & $
  IF (test_gse_pos[0]) THEN tempz = INTERPOL(gse_pos_v[*,2],gse_pos_t,tr_iesa[*,k],/SPLINE)  & $
  IF (test_gse_pos[0]) THEN se_iesa_posi[*,k,*] = [[tempx],[tempy],[tempz]]                  & $
  IF (test_dsl_pos[0]) THEN tempx = INTERPOL(dsl_pos_v[*,0],dsl_pos_t,tr_essb[*,k],/SPLINE)  & $
  IF (test_dsl_pos[0]) THEN tempy = INTERPOL(dsl_pos_v[*,1],dsl_pos_t,tr_essb[*,k],/SPLINE)  & $
  IF (test_dsl_pos[0]) THEN tempz = INTERPOL(dsl_pos_v[*,2],dsl_pos_t,tr_essb[*,k],/SPLINE)  & $
  IF (test_dsl_pos[0]) THEN se_essb_posi[*,k,*] = [[tempx],[tempy],[tempz]]                  & $
  IF (test_dsl_pos[0]) THEN tempx = INTERPOL(dsl_pos_v[*,0],dsl_pos_t,tr_essf[*,k],/SPLINE)  & $
  IF (test_dsl_pos[0]) THEN tempy = INTERPOL(dsl_pos_v[*,1],dsl_pos_t,tr_essf[*,k],/SPLINE)  & $
  IF (test_dsl_pos[0]) THEN tempz = INTERPOL(dsl_pos_v[*,2],dsl_pos_t,tr_essf[*,k],/SPLINE)  & $
  IF (test_dsl_pos[0]) THEN se_essf_posi[*,k,*] = [[tempx],[tempy],[tempz]]                  & $
  IF (test_dsl_pos[0]) THEN tempx = INTERPOL(dsl_pos_v[*,0],dsl_pos_t,tr_isst[*,k],/SPLINE)  & $
  IF (test_dsl_pos[0]) THEN tempy = INTERPOL(dsl_pos_v[*,1],dsl_pos_t,tr_isst[*,k],/SPLINE)  & $
  IF (test_dsl_pos[0]) THEN tempz = INTERPOL(dsl_pos_v[*,2],dsl_pos_t,tr_isst[*,k],/SPLINE)  & $
  IF (test_dsl_pos[0]) THEN se_isst_posi[*,k,*] = [[tempx],[tempy],[tempz]]
;;  Define averages for each component
avg_posx       = (se_eesa_posi[*,0,0] + se_eesa_posi[*,1,0])/2d0
avg_posy       = (se_eesa_posi[*,0,1] + se_eesa_posi[*,1,1])/2d0
avg_posz       = (se_eesa_posi[*,0,2] + se_eesa_posi[*,1,2])/2d0
avg_eesa_pos   = [[avg_posx],[avg_posy],[avg_posz]]
avg_posx       = (se_iesa_posi[*,0,0] + se_iesa_posi[*,1,0])/2d0
avg_posy       = (se_iesa_posi[*,0,1] + se_iesa_posi[*,1,1])/2d0
avg_posz       = (se_iesa_posi[*,0,2] + se_iesa_posi[*,1,2])/2d0
avg_iesa_pos   = [[avg_posx],[avg_posy],[avg_posz]]
avg_posx       = (se_essb_posi[*,0,0] + se_essb_posi[*,1,0])/2d0
avg_posy       = (se_essb_posi[*,0,1] + se_essb_posi[*,1,1])/2d0
avg_posz       = (se_essb_posi[*,0,2] + se_essb_posi[*,1,2])/2d0
avg_essb_pos   = [[avg_posx],[avg_posy],[avg_posz]]
avg_posx       = (se_essf_posi[*,0,0] + se_essf_posi[*,1,0])/2d0
avg_posy       = (se_essf_posi[*,0,1] + se_essf_posi[*,1,1])/2d0
avg_posz       = (se_essf_posi[*,0,2] + se_essf_posi[*,1,2])/2d0
avg_essf_pos   = [[avg_posx],[avg_posy],[avg_posz]]
avg_posx       = (se_isst_posi[*,0,0] + se_isst_posi[*,1,0])/2d0
avg_posy       = (se_isst_posi[*,0,1] + se_isst_posi[*,1,1])/2d0
avg_posz       = (se_isst_posi[*,0,2] + se_isst_posi[*,1,2])/2d0
avg_isst_pos   = [[avg_posx],[avg_posy],[avg_posz]]
;;  Convert to unit vectors
avg_eesa_posu  = unit_vec(avg_eesa_pos,/NAN)
avg_iesa_posu  = unit_vec(avg_iesa_pos,/NAN)
avg_essb_posu  = unit_vec(avg_essb_pos,/NAN)
avg_essf_posu  = unit_vec(avg_essf_pos,/NAN)
avg_isst_posu  = unit_vec(avg_isst_pos,/NAN)
;;  Define Earth direction for each distribution
avg_eesa_earth = -1d0*avg_eesa_posu
avg_iesa_earth = -1d0*avg_iesa_posu
avg_essb_earth = -1d0*avg_essb_posu
avg_essf_earth = -1d0*avg_essf_posu
avg_isst_earth = -1d0*avg_isst_posu
IF (no_load_spec) THEN STOP
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Calculate stacked spectra and send to TPLOT  [using FACs]
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
tr_all_day     = time_double(tdate[0]+'/'+[start_of_day_t[0],end___of_day_t[0]])
tpn_prefs      = scpref[0]+'magf_'
.compile $HOME/Desktop/swidl-0.1/wind_3dp_pros/LYNN_PRO/tplot_routines/t_stacked_energy_spec_2_tplot.pro
.compile $HOME/Desktop/swidl-0.1/wind_3dp_pros/LYNN_PRO/tplot_routines/t_stacked_pad_spec_2_tplot.pro
.compile $HOME/Desktop/swidl-0.1/wind_3dp_pros/LYNN_PRO/tplot_routines/t_stacked_ener_pad_spec_2_tplot.pro
;;--------------------------------------------
;;  EESA
;;--------------------------------------------
units          = 'flux'
bins           = REPLICATE(1b,dat_egse[0].NBINS)
num_pa         = 8L
erange         = [0e0,1e9]       ;;  Default energy bin range to include all energies [eV]
IF (tdate[0] EQ '2008-07-14') THEN erange         = [40e0,15e3]
IF (tdate[0] EQ '2008-08-19') THEN erange         = [50e0,10e3]
IF (tdate[0] EQ '2008-09-08') THEN erange         = [30e0,20e3]
IF (tdate[0] EQ '2008-09-16') THEN erange         = [40e0,20e3]
name           = tpn_prefs[0]+'eesa_spec'
no_trans       = 0b
dat            = dat_egse
t_stacked_ener_pad_spec_2_tplot,dat,UNITS=units,BINS=bins,NUM_PA=num_pa,  $
                                    ERANGE=erange,NAME=name,NO_TRANS=no_trans,$
                                    TRANGE=tr_all_day,TPN_STRUC=fac_struc_eesa
;;  Define TPLOT handles specific to EESA
eeomni_fac     = tnames(fac_struc_eesa.OMNI.SPEC_TPLOT_NAME)
eepad_omni_fac = tnames(fac_struc_eesa.PAD.SPEC_TPLOT_NAME)
eepad_spec_fac = tnames(fac_struc_eesa.PAD.PAD_TPLOT_NAMES)
eeanisotro_fac = tnames([fac_struc_eesa.ANIS.(0),fac_struc_eesa.ANIS.(1)])
;;  Insert NaNs at intervals
t_insert_nan_at_interval_se,tnames(name[0]+'*'),GAP_THRESH=5d0
;;--------------------------------------------
;;  IESA [Multiple formats --> same EBIN has different energy --> Fix!]
;;--------------------------------------------
units          = 'flux'
bins           = REPLICATE(1b,dat_igse[0].NBINS)
num_pa         = 8L
erange         = [0e0,1e9]       ;;  Default energy bin range to include all energies [eV]
IF (tdate[0] EQ '2008-07-14') THEN erange         = [45e0,25e3]
zrange         = [1e-1,1e4]
name           = tpn_prefs[0]+'iesa_spec'
no_trans       = 0b
dat            = dat_igse
t_stacked_ener_pad_spec_2_tplot,dat,UNITS=units,BINS=bins,NUM_PA=num_pa,  $
                                    ERANGE=erange,NAME=name,NO_TRANS=no_trans,$
                                    TRANGE=tr_all_day,TPN_STRUC=fac_struc_iesa
;;  compile the SPEDAS version of specplot.pro
ieomni_fac     = tnames( fac_struc_iesa.OMNI.SPEC_TPLOT_NAME)
iepad_omni_fac = tnames( fac_struc_iesa.PAD.SPEC_TPLOT_NAME)
iepad_spec_fac = tnames( fac_struc_iesa.PAD.PAD_TPLOT_NAMES)
ieanisotro_fac = tnames([fac_struc_iesa.ANIS.(0),fac_struc_iesa.ANIS.(1)])
;;  Insert NaNs at intervals
t_insert_nan_at_interval_se,tnames(name[0]+'*'),GAP_THRESH=5d0
;;  Change to dynamic spectra because of the wildly changing energy bin values
ispec_facs     = [ieomni_fac,iepad_spec_fac]
get_data,ispec_facs[0],DATA=temp,DLIM=dlim,LIM=lim
zsub_ttle      = dlim.YSUBTITLE
ysub_ttle      = '[Energy (eV)]'
IF (tdate[0] EQ '2008-07-14') THEN yran_spec      = [10e1,25e3]
IF (tdate[0] EQ '2008-08-19') THEN yran_spec      = [40e0,25e3]
IF (tdate[0] EQ '2008-09-08') THEN yran_spec      = [50e0,20e3]
IF (tdate[0] EQ '2008-09-16') THEN yran_spec      = [10e0,25e3]
options,ispec_facs,SPEC=1,ZLOG=1,ZTICKS=3,YRANGE=yran_spec,ZRANGE=zrange,$
                   YSUBTITLE=ysub_ttle[0],ZTITLE=zsub_ttle[0],/DEF
options,[iepad_omni_fac[0],ieanisotro_fac],SPEC=0,YRANGE=erange,/DEF
options,[iepad_omni_fac[0],ieanisotro_fac],  'ZLOG',/DEF
options,[iepad_omni_fac[0],ieanisotro_fac],'ZTICKS',/DEF
options,[iepad_omni_fac[0],ieanisotro_fac],'ZRANGE',/DEF
options,[iepad_omni_fac[0],ieanisotro_fac],'YRANGE',/DEF
;;--------------------------------------------
;;  E-SST Burst and Full
;;--------------------------------------------
units          = 'flux'
bins           = REPLICATE(1b,dat_seb[0].NBINS)
num_pa         = 8L
erange         = [0e0,1e9]       ;;  Default energy bin range to include all energies [eV]
IF (tdate[0] EQ '2008-07-14') THEN erange         = [1e4,150e3]
IF (tdate[0] EQ '2008-08-19') THEN erange         = [1e4,300e3]
IF (tdate[0] EQ '2008-09-08') THEN erange         = [1e4,250e3]
IF (tdate[0] EQ '2008-09-16') THEN erange         = [1e4,100e3]
name           = tpn_prefs[0]+'pseb_psef_spec'
no_trans       = 0b
dat            = dat_seb
dat2           = dat_sef
t_stacked_ener_pad_spec_2_tplot,dat,UNITS=units,BINS=bins,NUM_PA=num_pa,  $
                                    ERANGE=erange,NAME=name,NO_TRANS=no_trans,$
                                    TRANGE=tr_all_day,TPN_STRUC=fac_struc_psebf,DAT_STR2=dat2
sebfomnifac    = tnames( fac_struc_psebf.OMNI.SPEC_TPLOT_NAME)
sebfpd_omnifac = tnames( fac_struc_psebf.PAD.SPEC_TPLOT_NAME)
sebfpd_specfac = tnames( fac_struc_psebf.PAD.PAD_TPLOT_NAMES)
sebfanisotrfac = tnames([fac_struc_psebf.ANIS.(0),fac_struc_psebf.ANIS.(1)])
;;  Insert NaNs at intervals
IF (tdate[0] NE '2008-09-08') THEN t_insert_nan_at_interval_se,tnames(name[0]+'*'),GAP_THRESH=100d0
;;--------------------------------------------
;;  I-SST Full
;;--------------------------------------------
units          = 'flux'
bins           = REPLICATE(1b,dat_sif[0].NBINS)
num_pa         = 8L
erange         = [0e0,1e9]       ;;  Default energy bin range to include all energies [eV]
IF (tdate[0] EQ '2008-07-14') THEN erange         = [1e4,500e3]
IF (tdate[0] EQ '2008-08-19') THEN erange         = [1e4,700e3]
IF (tdate[0] EQ '2008-09-08') THEN erange         = [1e4,500e3]
IF (tdate[0] EQ '2008-09-16') THEN erange         = [1e4,250e3]
name           = tpn_prefs[0]+'psif_spec'
no_trans       = 0b
dat            = dat_sif
t_stacked_ener_pad_spec_2_tplot,dat,UNITS=units,BINS=bins,NUM_PA=num_pa,  $
                                    ERANGE=erange,NAME=name,NO_TRANS=no_trans,$
                                    TRANGE=tr_all_day,TPN_STRUC=fac_struc_psif
sifomnifac     = tnames( fac_struc_psif.OMNI.SPEC_TPLOT_NAME)
sifpad_omnifac = tnames( fac_struc_psif.PAD.SPEC_TPLOT_NAME)
sifpad_specfac = tnames( fac_struc_psif.PAD.PAD_TPLOT_NAMES)
sifanisotrofac = tnames([fac_struc_psif.ANIS.(0),fac_struc_psif.ANIS.(1)])
;;  Insert NaNs at intervals
t_insert_nan_at_interval_se,tnames(name[0]+'*'),GAP_THRESH=10d0
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Calculate stacked spectra and send to TPLOT  [using Earth Vector]
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
tpn_prefs      = scpref[0]+'earthvec_'
.compile $HOME/Desktop/swidl-0.1/wind_3dp_pros/LYNN_PRO/tplot_routines/t_stacked_energy_spec_2_tplot.pro
.compile $HOME/Desktop/swidl-0.1/wind_3dp_pros/LYNN_PRO/tplot_routines/t_stacked_pad_spec_2_tplot.pro
.compile $HOME/Desktop/swidl-0.1/wind_3dp_pros/LYNN_PRO/tplot_routines/t_stacked_ener_pad_spec_2_tplot.pro
;;--------------------------------------------
;;  EESA
;;--------------------------------------------
units          = 'flux'
bins           = REPLICATE(1b,dat_egse[0].NBINS)
num_pa         = 8L
erange         = [0e0,1e9]       ;;  Default energy bin range to include all energies [eV]
IF (tdate[0] EQ '2008-07-14') THEN erange         = [40e0,15e3]
IF (tdate[0] EQ '2008-08-19') THEN erange         = [50e0,10e3]
IF (tdate[0] EQ '2008-09-08') THEN erange         = [30e0,20e3]
IF (tdate[0] EQ '2008-09-16') THEN erange         = [40e0,20e3]
name           = tpn_prefs[0]+'eesa_spec'
no_trans       = 0b
IF (test_gse_pos[0]) THEN dat            = dat_egse
IF (test_gse_pos[0]) THEN dat.MAGF       = TRANSPOSE(avg_eesa_earth)
IF (test_gse_pos[0]) THEN t_stacked_ener_pad_spec_2_tplot,dat,UNITS=units,BINS=bins,NUM_PA=num_pa,  $
                                                              ERANGE=erange,NAME=name,NO_TRANS=no_trans,$
                                                              TRANGE=tr_all_day,TPN_STRUC=tpn_struc_eesa
;;  Define TPLOT handles specific to EESA
IF (test_gse_pos[0]) THEN eeomni_tpn     = tnames(tpn_struc_eesa.OMNI.SPEC_TPLOT_NAME)
IF (test_gse_pos[0]) THEN eepad_omni_tpn = tnames(tpn_struc_eesa.PAD.SPEC_TPLOT_NAME)
IF (test_gse_pos[0]) THEN eepad_spec_tpn = tnames(tpn_struc_eesa.PAD.PAD_TPLOT_NAMES)
IF (test_gse_pos[0]) THEN eeanisotro_tpn = tnames([tpn_struc_eesa.ANIS.(0),tpn_struc_eesa.ANIS.(1)])
;;  Insert NaNs at intervals
IF (test_gse_pos[0]) THEN t_insert_nan_at_interval_se,tnames(name[0]+'*'),GAP_THRESH=5d0
;;--------------------------------------------
;;  IESA [Multiple formats --> same EBIN has different energy --> Fix!]
;;--------------------------------------------
units          = 'flux'
bins           = REPLICATE(1b,dat_igse[0].NBINS)
num_pa         = 8L
erange         = [0e0,1e9]       ;;  Default energy bin range to include all energies [eV]
IF (tdate[0] EQ '2008-07-14') THEN erange         = [45e0,25e3]
zrange         = [1e-1,1e4]
name           = tpn_prefs[0]+'iesa_spec'
no_trans       = 0b
IF (test_gse_pos[0]) THEN dat            = dat_igse
IF (test_gse_pos[0]) THEN dat.MAGF       = TRANSPOSE(avg_iesa_earth)
IF (test_gse_pos[0]) THEN t_stacked_ener_pad_spec_2_tplot,dat,UNITS=units,BINS=bins,NUM_PA=num_pa,  $
                                                              ERANGE=erange,NAME=name,NO_TRANS=no_trans,$
                                                              TRANGE=tr_all_day,TPN_STRUC=tpn_struc_iesa
;;  compile the SPEDAS version of specplot.pro
IF (test_gse_pos[0]) THEN ieomni_tpn     = tnames( tpn_struc_iesa.OMNI.SPEC_TPLOT_NAME)
IF (test_gse_pos[0]) THEN iepad_omni_tpn = tnames( tpn_struc_iesa.PAD.SPEC_TPLOT_NAME)
IF (test_gse_pos[0]) THEN iepad_spec_tpn = tnames( tpn_struc_iesa.PAD.PAD_TPLOT_NAMES)
IF (test_gse_pos[0]) THEN ieanisotro_tpn = tnames([tpn_struc_iesa.ANIS.(0),tpn_struc_iesa.ANIS.(1)])
;;  Insert NaNs at intervals
IF (test_gse_pos[0]) THEN t_insert_nan_at_interval_se,tnames(name[0]+'*'),GAP_THRESH=5d0
;;  Change to dynamic spectra because of the wildly changing energy bin values
IF (test_gse_pos[0]) THEN ispec_tpns     = [ieomni_tpn,iepad_spec_tpn]
IF (test_gse_pos[0]) THEN get_data,ispec_tpns[0],DATA=temp,DLIM=dlim,LIM=lim
IF (test_gse_pos[0]) THEN zsub_ttle      = dlim.YSUBTITLE
IF (test_gse_pos[0]) THEN ysub_ttle      = '[Energy (eV)]'
IF (test_gse_pos[0]) THEN IF (tdate[0] EQ '2008-07-14') THEN yran_spec      = [10e1,25e3]
IF (test_gse_pos[0]) THEN IF (tdate[0] EQ '2008-08-19') THEN yran_spec      = [40e0,25e3]
IF (test_gse_pos[0]) THEN IF (tdate[0] EQ '2008-09-08') THEN yran_spec      = [50e0,20e3]
IF (test_gse_pos[0]) THEN IF (tdate[0] EQ '2008-09-16') THEN yran_spec      = [10e0,25e3]
IF (test_gse_pos[0]) THEN options,ispec_tpns,SPEC=1,ZLOG=1,ZTICKS=3,YRANGE=yran_spec,ZRANGE=zrange,$
                                             YSUBTITLE=ysub_ttle[0],ZTITLE=zsub_ttle[0],/DEF
IF (test_gse_pos[0]) THEN options,[iepad_omni_tpn[0],ieanisotro_tpn],SPEC=0,YRANGE=erange,/DEF
IF (test_gse_pos[0]) THEN options,[iepad_omni_tpn[0],ieanisotro_tpn],  'ZLOG',/DEF
IF (test_gse_pos[0]) THEN options,[iepad_omni_tpn[0],ieanisotro_tpn],'ZTICKS',/DEF
IF (test_gse_pos[0]) THEN options,[iepad_omni_tpn[0],ieanisotro_tpn],'ZRANGE',/DEF
IF (test_gse_pos[0]) THEN options,[iepad_omni_tpn[0],ieanisotro_tpn],'YRANGE',/DEF
dprint,SETVERBOSE=1
;;--------------------------------------------
;;  E-SST Burst and Full
;;--------------------------------------------
units          = 'flux'
bins           = REPLICATE(1b,dat_seb[0].NBINS)
num_pa         = 8L
erange         = [0e0,1e9]       ;;  Default energy bin range to include all energies [eV]
IF (tdate[0] EQ '2008-07-14') THEN erange         = [1e4,150e3]
IF (tdate[0] EQ '2008-08-19') THEN erange         = [1e4,300e3]
IF (tdate[0] EQ '2008-09-08') THEN erange         = [1e4,250e3]
IF (tdate[0] EQ '2008-09-16') THEN erange         = [1e4,100e3]
name           = tpn_prefs[0]+'pseb_psef_spec'
no_trans       = 0b
IF (test_dsl_pos[0]) THEN dat            = dat_seb
IF (test_dsl_pos[0]) THEN dat2           = dat_sef
IF (test_dsl_pos[0]) THEN dat.MAGF       = TRANSPOSE(avg_essb_earth)
IF (test_dsl_pos[0]) THEN dat2.MAGF      = TRANSPOSE(avg_essf_earth)
IF (test_dsl_pos[0]) THEN t_stacked_ener_pad_spec_2_tplot,dat,UNITS=units,BINS=bins,NUM_PA=num_pa,  $
                                                              ERANGE=erange,NAME=name,NO_TRANS=no_trans,$
                                                              TRANGE=tr_all_day,TPN_STRUC=tpn_struc_psebf,DAT_STR2=dat2
IF (test_dsl_pos[0]) THEN sebfomni_tp    = tnames( tpn_struc_psebf.OMNI.SPEC_TPLOT_NAME)
IF (test_dsl_pos[0]) THEN sebfpd_omni_tp = tnames( tpn_struc_psebf.PAD.SPEC_TPLOT_NAME)
IF (test_dsl_pos[0]) THEN sebfpd_spec_tp = tnames( tpn_struc_psebf.PAD.PAD_TPLOT_NAMES)
IF (test_dsl_pos[0]) THEN sebfanisotr_tp = tnames([tpn_struc_psebf.ANIS.(0),tpn_struc_psebf.ANIS.(1)])
;;  Insert NaNs at intervals
IF (test_dsl_pos[0]) THEN IF (tdate[0] NE '2008-09-08') THEN t_insert_nan_at_interval_se,tnames(name[0]+'*'),GAP_THRESH=100d0
;;--------------------------------------------
;;  I-SST Full
;;--------------------------------------------
units          = 'flux'
bins           = REPLICATE(1b,dat_sif[0].NBINS)
num_pa         = 8L
erange         = [0e0,1e9]       ;;  Default energy bin range to include all energies [eV]
IF (tdate[0] EQ '2008-07-14') THEN erange         = [1e4,500e3]
IF (tdate[0] EQ '2008-08-19') THEN erange         = [1e4,700e3]
IF (tdate[0] EQ '2008-09-08') THEN erange         = [1e4,500e3]
IF (tdate[0] EQ '2008-09-16') THEN erange         = [1e4,250e3]
name           = tpn_prefs[0]+'psif_spec'
no_trans       = 0b
IF (test_dsl_pos[0]) THEN dat            = dat_sif
IF (test_dsl_pos[0]) THEN dat.MAGF       = TRANSPOSE(avg_isst_earth)
IF (test_dsl_pos[0]) THEN t_stacked_ener_pad_spec_2_tplot,dat,UNITS=units,BINS=bins,NUM_PA=num_pa,  $
                                                              ERANGE=erange,NAME=name,NO_TRANS=no_trans,$
                                                              TRANGE=tr_all_day,TPN_STRUC=tpn_struc_psif
IF (test_dsl_pos[0]) THEN sifomni_tp     = tnames( tpn_struc_psif.OMNI.SPEC_TPLOT_NAME)
IF (test_dsl_pos[0]) THEN sifpad_omni_tp = tnames( tpn_struc_psif.PAD.SPEC_TPLOT_NAME)
IF (test_dsl_pos[0]) THEN sifpad_spec_tp = tnames( tpn_struc_psif.PAD.PAD_TPLOT_NAMES)
IF (test_dsl_pos[0]) THEN sifanisotro_tp = tnames([tpn_struc_psif.ANIS.(0),tpn_struc_psif.ANIS.(1)])
;;  Insert NaNs at intervals
IF (test_dsl_pos[0]) THEN t_insert_nan_at_interval_se,tnames(name[0]+'*'),GAP_THRESH=10d0
;;----------------------------------------------------------------------------------------
;;  Set defaults
;;----------------------------------------------------------------------------------------
lbw_tplot_set_defaults
tplot_options,  'XMARGIN',[20,20]
;;----------------------------------------------------------------------------------------
;;  Fix Y-Ranges and tick marks
;;----------------------------------------------------------------------------------------
eesa_sp_tpns   = tnames(scpref[0]+'*_eesa_spec*')
iesa_sp_tpns   = tnames(scpref[0]+'*_iesa_spec*')
sste_sp_tpns   = tnames(scpref[0]+'*_pseb_psef_spec*')
ssti_sp_tpns   = tnames(scpref[0]+'*_psif_spec*')

test_eesa      = (STRPOS(eesa_sp_tpns,'_para_to_perp') GE 0) OR (STRPOS(eesa_sp_tpns,'_para_to_anti') GE 0)
bad_eesa       = WHERE(test_eesa,bd_eesa,COMPLEMENT=good_eesa,NCOMPLEMENT=gd_eesa)
test_iesa      = (STRPOS(iesa_sp_tpns,'_para_to_perp') GE 0) OR (STRPOS(iesa_sp_tpns,'_para_to_anti') GE 0)
bad_iesa       = WHERE(test_iesa,bd_iesa,COMPLEMENT=good_iesa,NCOMPLEMENT=gd_iesa)
test_sste      = (STRPOS(sste_sp_tpns,'_para_to_perp') GE 0) OR (STRPOS(sste_sp_tpns,'_para_to_anti') GE 0)
bad_sste       = WHERE(test_sste,bd_sste,COMPLEMENT=good_sste,NCOMPLEMENT=gd_sste)
test_ssti      = (STRPOS(ssti_sp_tpns,'_para_to_perp') GE 0) OR (STRPOS(ssti_sp_tpns,'_para_to_anti') GE 0)
bad_ssti       = WHERE(test_ssti,bd_ssti,COMPLEMENT=good_ssti,NCOMPLEMENT=gd_ssti)

all_tpns       = {T0:eesa_sp_tpns[good_eesa],T2:sste_sp_tpns[good_sste],T3:ssti_sp_tpns[good_ssti]}
;;  Default flux(intensity) Y-Axis range to include all spectra [i.e., change after plotting]
all_ymnmx      = {T0:[1e-5,1e10],T2:[1e-8,1e3],T3:[1e-9,1e8]}
IF (tdate[0] EQ '2008-07-14') THEN all_ymnmx = {T0:[1e-1,1e7],T2:[2e-5,1e-1],T3:[4e-6,1e1]}
IF (tdate[0] EQ '2008-08-19') THEN all_ymnmx = {T0:[1e-1,1e7],T2:[1e-5,1e0],T3:[1e-6,1e1]}
IF (tdate[0] EQ '2008-09-08') THEN all_ymnmx = {T0:[1e-1,1e7],T2:[1e-5,1e0],T3:[5e-6,1e1]}
IF (tdate[0] EQ '2008-09-16') THEN all_ymnmx = {T0:[1e-2,1e6],T2:[1e-5,2e-1],T3:[1e-6,1e0]}

n_tp           = N_TAGS(all_tpns)
def_yra        = [1d30,1d-30]
FOR jj=0L, n_tp[0] - 1L DO BEGIN                              $
  tpns0 = all_tpns.(jj)                                     & $
  IF (tpns0[0] EQ '') THEN CONTINUE                         & $
  nn      = N_ELEMENTS(tpns0)                               & $
  ymnmx   = all_ymnmx.(jj)                                  & $
  yra1    = def_yra                                         & $
  FOR kk=0L, nn[0] - 1L DO BEGIN                              $
    get_data,tpns0[kk],DATA=temp,DLIM=dlim,LIM=lim          & $
    test = FINITE(temp.Y) AND (temp.Y GT 0)                 & $
    good = WHERE(test,gd)                                   & $
    IF (gd EQ 0) THEN CONTINUE                              & $
    yra0 = [MIN(temp.Y[good],/NAN),MAX(temp.Y[good],/NAN)]  & $
    test = test_plot_axis_range(yra0,/NOMSSG)               & $
    IF (test[0] EQ 0) THEN CONTINUE                         & $
    IF (kk EQ 0) THEN yra1 = yra0 ELSE yra1 = [yra1,yra0]   & $
  ENDFOR                                                    & $
  yra1    = yra1[SORT(yra1)]                                & $
  test    = log10_tickmarks(yra1,RANGE=ymnmx,/FORCE_RA)     & $
  IF (SIZE(test,/TYPE) NE 8) THEN CONTINUE                  & $
  options,REFORM(tpns0),'YRANGE'                            & $
  options,REFORM(tpns0),YRANGE=ymnmx,YTICKNAME=test.TICKNAME,YTICKV=test.TICKV,YTICKS=test.TICKS

;;  Alter ratio TPLOT handles separately
all_tpns       = {T0:eesa_sp_tpns[bad_eesa],T1:iesa_sp_tpns[bad_iesa],T2:sste_sp_tpns[bad_sste],T3:ssti_sp_tpns[bad_ssti]}
n_tp           = N_TAGS(all_tpns)
def_yra        = [1d30,1d-30]
FOR jj=0L, n_tp[0] - 1L DO BEGIN                              $
  tpns0 = all_tpns.(jj)                                     & $
  IF (tpns0[0] EQ '') THEN CONTINUE                         & $
  nn      = N_ELEMENTS(tpns0)                               & $
  yra1    = def_yra                                         & $
  FOR kk=0L, nn[0] - 1L DO BEGIN                              $
    get_data,tpns0[kk],DATA=temp,DLIM=dlim,LIM=lim          & $
    test = FINITE(temp.Y) AND (temp.Y GT 0)                 & $
    good = WHERE(test,gd)                                   & $
    IF (gd EQ 0) THEN CONTINUE                              & $
    yra0 = [MIN(temp.Y[good],/NAN),MAX(temp.Y[good],/NAN)]  & $
    test = test_plot_axis_range(yra0,/NOMSSG)               & $
    IF (test[0] EQ 0) THEN CONTINUE                         & $
    IF (kk EQ 0) THEN yra1 = yra0 ELSE yra1 = [yra1,yra0]   & $
  ENDFOR                                                    & $
  yra1    = yra1[SORT(yra1)]                                & $
  yran    = calc_log_scale_yrange(yra1)                     & $
  IF (N_ELEMENTS(yran) NE 2) THEN CONTINUE                  & $
  test    = get_power_of_ten_ticks(yran)                    & $
  IF (SIZE(test,/TYPE) NE 8) THEN CONTINUE                  & $
  options,REFORM(tpns0),'YRANGE'                            & $
  options,REFORM(tpns0),YRANGE=yran,YTICKNAME=test.YTICKNAME,YTICKV=test.YTICKV,YTICKS=test.YTICKS
;;----------------------------------------------------------------------------------------
;;  Fix anisotropy ratios by smoothing prior to calculation
;;----------------------------------------------------------------------------------------
eesa_sp_tpns   = tnames(scpref[0]+'*_eesa_spec*')
iesa_sp_tpns   = tnames(scpref[0]+'*_iesa_spec*')
sste_sp_tpns   = tnames(scpref[0]+'*_pseb_psef_spec*')
ssti_sp_tpns   = tnames(scpref[0]+'*_psif_spec*')

;;  EESA
test_eesa_para = (STRPOS(eesa_sp_tpns,'-2-0:1') GE 0)
good_eesa_para = WHERE(test_eesa_para,gd_eesa_para)
test_eesa_perp = (STRPOS(eesa_sp_tpns,'-2-3:4') GE 0)
good_eesa_perp = WHERE(test_eesa_perp,gd_eesa_perp)
test_eesa_anti = (STRPOS(eesa_sp_tpns,'-2-6:7') GE 0)
good_eesa_anti = WHERE(test_eesa_anti,gd_eesa_anti)
test_eer_pa2pe = (STRPOS(eesa_sp_tpns,'_para_to_perp') GE 0)
test_eer_pa2an = (STRPOS(eesa_sp_tpns,'_para_to_anti') GE 0)
good_eer_pa2pe = WHERE(test_eer_pa2pe,gd_eer_pa2pe)
good_eer_pa2an = WHERE(test_eer_pa2an,gd_eer_pa2an)

;;  IESA
test_iesa_para = (STRPOS(iesa_sp_tpns,'-2-0:1') GE 0)
good_iesa_para = WHERE(test_iesa_para,gd_iesa_para)
test_iesa_perp = (STRPOS(iesa_sp_tpns,'-2-3:4') GE 0)
good_iesa_perp = WHERE(test_iesa_perp,gd_iesa_perp)
test_iesa_anti = (STRPOS(iesa_sp_tpns,'-2-6:7') GE 0)
good_iesa_anti = WHERE(test_iesa_anti,gd_iesa_anti)
test_ier_pa2pe = (STRPOS(iesa_sp_tpns,'_para_to_perp') GE 0)
test_ier_pa2an = (STRPOS(iesa_sp_tpns,'_para_to_anti') GE 0)
good_ier_pa2pe = WHERE(test_ier_pa2pe,gd_ier_pa2pe)
good_ier_pa2an = WHERE(test_ier_pa2an,gd_ier_pa2an)

;;  SSTe
test_sste_para = (STRPOS(sste_sp_tpns,'-2-0:1') GE 0)
good_sste_para = WHERE(test_sste_para,gd_sste_para)
test_sste_perp = (STRPOS(sste_sp_tpns,'-2-3:4') GE 0)
good_sste_perp = WHERE(test_sste_perp,gd_sste_perp)
test_sste_anti = (STRPOS(sste_sp_tpns,'-2-6:7') GE 0)
good_sste_anti = WHERE(test_sste_anti,gd_sste_anti)
test_ser_pa2pe = (STRPOS(sste_sp_tpns,'_para_to_perp') GE 0)
test_ser_pa2an = (STRPOS(sste_sp_tpns,'_para_to_anti') GE 0)
good_ser_pa2pe = WHERE(test_ser_pa2pe,gd_ser_pa2pe)
good_ser_pa2an = WHERE(test_ser_pa2an,gd_ser_pa2an)

;;  SSTi
test_ssti_para = (STRPOS(ssti_sp_tpns,'-2-0:1') GE 0)
good_ssti_para = WHERE(test_ssti_para,gd_ssti_para)
test_ssti_perp = (STRPOS(ssti_sp_tpns,'-2-3:4') GE 0)
good_ssti_perp = WHERE(test_ssti_perp,gd_ssti_perp)
test_ssti_anti = (STRPOS(ssti_sp_tpns,'-2-6:7') GE 0)
good_ssti_anti = WHERE(test_ssti_anti,gd_ssti_anti)
test_sir_pa2pe = (STRPOS(ssti_sp_tpns,'_para_to_perp') GE 0)
test_sir_pa2an = (STRPOS(ssti_sp_tpns,'_para_to_anti') GE 0)
good_sir_pa2pe = WHERE(test_sir_pa2pe,gd_sir_pa2pe)
good_sir_pa2an = WHERE(test_sir_pa2an,gd_sir_pa2an)


nsmpt          = 6L
nsmpt_suffx    = '_NSm'+STRTRIM(STRING(nsmpt[0],FORMAT='(I3.3)'),2)+'pts'
para_tpns      = {T0:eesa_sp_tpns[good_eesa_para],T1:iesa_sp_tpns[good_iesa_para],T2:sste_sp_tpns[good_sste_para],T3:ssti_sp_tpns[good_ssti_para]}
perp_tpns      = {T0:eesa_sp_tpns[good_eesa_perp],T1:iesa_sp_tpns[good_iesa_perp],T2:sste_sp_tpns[good_sste_perp],T3:ssti_sp_tpns[good_ssti_perp]}
anti_tpns      = {T0:eesa_sp_tpns[good_eesa_anti],T1:iesa_sp_tpns[good_iesa_anti],T2:sste_sp_tpns[good_sste_anti],T3:ssti_sp_tpns[good_ssti_anti]}
old_pa2pe_tpns = {T0:eesa_sp_tpns[good_eer_pa2pe],T1:iesa_sp_tpns[good_ier_pa2pe],T2:sste_sp_tpns[good_ser_pa2pe],T3:ssti_sp_tpns[good_sir_pa2pe]}
old_pa2an_tpns = {T0:eesa_sp_tpns[good_eer_pa2an],T1:iesa_sp_tpns[good_ier_pa2an],T2:sste_sp_tpns[good_ser_pa2an],T3:ssti_sp_tpns[good_sir_pa2an]}

;;  First sort to make sure things are in order
n_tp           = N_TAGS(old_pa2pe_tpns)
ss             = '*_magf_*'      ;;  search string to use later
FOR jj=0L, n_tp[0] - 1L DO BEGIN                                                          $
  jtag          = 'T'+STRTRIM(STRING(jj[0],FORMAT='(I1.1)'),2)                          & $
  tpn_old_pa2pe = old_pa2pe_tpns.(jj)                                                   & $
  tpn_old_pa2an = old_pa2an_tpns.(jj)                                                   & $
  tpns_para     = para_tpns.(jj)                                                        & $
  tpns_perp     = perp_tpns.(jj)                                                        & $
  tpns_anti     = anti_tpns.(jj)                                                        & $
  nn_papean     = [N_ELEMENTS(tpns_para),N_ELEMENTS(tpns_perp),N_ELEMENTS(tpns_anti)]   & $
  test          = (tpns_para[0] EQ '') OR (tpns_perp[0] EQ '') OR (tpns_anti[0] EQ '')  & $
  IF (test[0]) THEN CONTINUE                                                            & $
  test          = (nn_papean[0] NE 2) OR (nn_papean[1] NE 2) OR (nn_papean[2] NE 2)     & $
  nn1           = N_ELEMENTS(tpn_old_pa2pe)                                             & $
  nn2           = N_ELEMENTS(tpn_old_pa2an)                                             & $
  test          = test[0] OR (nn1[0] NE 2) OR (nn2[0] NE 2)                             & $
  IF (test[0]) THEN CONTINUE                                                            & $
  all_tpns      = {T0:tpn_old_pa2pe,T1:tpn_old_pa2an,T2:tpns_para,T3:tpns_perp,T4:tpns_anti}  & $
  tests         = [STRMATCH(tpn_old_pa2pe[0],ss),STRMATCH(tpn_old_pa2an[0],ss),           $
                   STRMATCH(tpns_para[0],ss),STRMATCH(tpns_perp[0],ss),                   $
                   STRMATCH(tpns_anti[0],ss)]                                           & $
  FOR kk=0L, 4L DO IF (tests[kk] EQ 0) THEN all_tpns.(kk) = REVERSE(all_tpns.(kk))      & $
  old_pa2pe_tpns.(jj) = all_tpns.(0)                                                    & $
  old_pa2an_tpns.(jj) = all_tpns.(1)                                                    & $
  para_tpns.(jj)      = all_tpns.(2)                                                    & $
  perp_tpns.(jj)      = all_tpns.(3)                                                    & $
  anti_tpns.(jj)      = all_tpns.(4)                                                    & $
  new_tpns_0          = all_tpns.(0)+nsmpt_suffx[0]                                     & $
  new_tpns_1          = all_tpns.(1)+nsmpt_suffx[0]                                     & $
  str_element,new_pa2pe_tpns,jtag[0],new_tpns_0,/ADD_REPLACE                            & $
  str_element,new_pa2an_tpns,jtag[0],new_tpns_1,/ADD_REPLACE

;;  Now re-calculate anisotropies
all_gap_thsh   = [5d0,5d0,100d0,10d0]
new_pa2pe_ysub = ['[para-to-perp ratio]','[EW-to-SHPlane ratio]']
new_pa2an_ysub = ['[para-to-anti ratio]','[2Earth-to-2Sun ratio]']
n_tp           = N_TAGS(old_pa2pe_tpns)
FOR jj=0L, n_tp[0] - 1L DO BEGIN                                                          $
  tpn_old_pa2pe = old_pa2pe_tpns.(jj)                                                   & $
  tpn_old_pa2an = old_pa2an_tpns.(jj)                                                   & $
  tpns_para     = para_tpns.(jj)                                                        & $
  tpns_perp     = perp_tpns.(jj)                                                        & $
  tpns_anti     = anti_tpns.(jj)                                                        & $
  tpn_new_pa2pe = new_pa2pe_tpns.(jj)                                                   & $
  tpn_new_pa2an = new_pa2an_tpns.(jj)                                                   & $
  nn            = N_ELEMENTS(tpn_old_pa2pe)                                             & $
  FOR kk=0L, nn[0] - 1L DO BEGIN                                                          $
    get_data,tpn_old_pa2pe[kk],DATA=t_pa2pe,DLIM=dlim_pa2pe,LIM=lim_pa2pe               & $
    get_data,tpn_old_pa2an[kk],DATA=t_pa2an,DLIM=dlim_pa2an,LIM=lim_pa2an               & $
    get_data,tpns_para[kk],DATA=t_para,DLIM=dlim_para,LIM=lim_para                      & $
    get_data,tpns_perp[kk],DATA=t_perp,DLIM=dlim_perp,LIM=lim_perp                      & $
    get_data,tpns_anti[kk],DATA=t_anti,DLIM=dlim_anti,LIM=lim_anti                      & $
    test  = (SIZE(t_pa2pe,/TYPE) NE 8) OR (SIZE(t_pa2an,/TYPE) NE 8) OR                   $
            (SIZE(t_para,/TYPE) NE 8) OR (SIZE(t_perp,/TYPE) NE 8) OR                     $
            (SIZE(t_anti,/TYPE) NE 8)                                                   & $
    IF (test[0]) THEN CONTINUE                                                          & $
    n__t  = N_ELEMENTS(t_para.X)                                                        & $
    n_en  = N_ELEMENTS(t_para.Y[0,*])                                                   & $
    new_para = DBLARR(n__t[0],n_en[0])                                                  & $
    new_perp = DBLARR(n__t[0],n_en[0])                                                  & $
    new_anti = DBLARR(n__t[0],n_en[0])                                                  & $
    FOR ii=0L, n_en[0] - 1L DO BEGIN                                                      $
      new_para[*,ii] = SMOOTH(REFORM(t_para.Y[*,ii]),nsmpt[0],/NAN,/EDGE_TRUNCATE)      & $
      new_perp[*,ii] = SMOOTH(REFORM(t_perp.Y[*,ii]),nsmpt[0],/NAN,/EDGE_TRUNCATE)      & $
      new_anti[*,ii] = SMOOTH(REFORM(t_anti.Y[*,ii]),nsmpt[0],/NAN,/EDGE_TRUNCATE)      & $
    ENDFOR                                                                              & $
    new_r_pa2pe = new_para/new_perp                                                     & $
    new_r_pa2an = new_para/new_anti                                                     & $
    new_struc   = {X:t_pa2pe.X,Y:new_r_pa2pe,V:t_pa2pe.V}                               & $
    store_data,tpn_new_pa2pe[kk],DATA=new_struc,DLIM=dlim_pa2pe,LIM=lim_pa2pe           & $
    new_struc   = {X:t_pa2an.X,Y:new_r_pa2an,V:t_pa2an.V}                               & $
    store_data,tpn_new_pa2an[kk],DATA=new_struc,DLIM=dlim_pa2an,LIM=lim_pa2an           & $
    options,tpn_new_pa2pe[kk],YSUBTITLE=new_pa2pe_ysub[kk],/DEF                         & $
    options,tpn_new_pa2an[kk],YSUBTITLE=new_pa2an_ysub[kk],/DEF                         & $
  ENDFOR                                                                                & $
  dumb  = TEMPORARY(t_pa2pe)                                                            & $
  dumb  = TEMPORARY(t_pa2an)                                                            & $
  dumb  = TEMPORARY(t_para)                                                             & $
  dumb  = TEMPORARY(t_perp)                                                             & $
  dumb  = TEMPORARY(t_anti)                                                             & $
  dumb  = TEMPORARY(new_struc)

;;  Remove default Y-Ranges, tick marks, and log-scales
options,tnames(scpref[0]+'*'+nsmpt_suffx[0]),   'YRANGE'
options,tnames(scpref[0]+'*'+nsmpt_suffx[0]),   'YRANGE',/DEF
options,tnames(scpref[0]+'*'+nsmpt_suffx[0]),'YTICKNAME'
options,tnames(scpref[0]+'*'+nsmpt_suffx[0]),'YTICKNAME',/DEF
options,tnames(scpref[0]+'*'+nsmpt_suffx[0]),   'YTICKV'
options,tnames(scpref[0]+'*'+nsmpt_suffx[0]),   'YTICKV',/DEF
options,tnames(scpref[0]+'*'+nsmpt_suffx[0]),   'YTICKS'
options,tnames(scpref[0]+'*'+nsmpt_suffx[0]),   'YTICKS',/DEF
options,tnames(scpref[0]+'*'+nsmpt_suffx[0]),     'YLOG'
options,tnames(scpref[0]+'*'+nsmpt_suffx[0]),     'YLOG',/DEF

;;  Reset log-scales [for SSTe only] after defining MIN_VALUE and MAX_VALUE
min_val        = 1e-1
max_val        = 1e1
IF (tdate[0] EQ '2008-07-14') THEN max_val = 5e0
IF (tdate[0] EQ '2008-08-19') THEN max_val = 2.5e0
IF (tdate[0] EQ '2008-09-08') THEN max_val = 5e0
options,tnames(scpref[0]+'*_pseb_psef_spec_*'+nsmpt_suffx[0]),'MIN_VALUE'
options,tnames(scpref[0]+'*_pseb_psef_spec_*'+nsmpt_suffx[0]),'MAX_VALUE'
options,tnames(scpref[0]+'*_pseb_psef_spec_*'+nsmpt_suffx[0]),YLOG=0,$
        MIN_VALUE=min_val[0],MAX_VALUE=max_val[0],/DEF
options,tnames(scpref[0]+'*_pseb_psef_spec_*'+nsmpt_suffx[0]),YGRIDSTYLE=2,YTICKLEN=1e0

































