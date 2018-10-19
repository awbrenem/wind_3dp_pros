;+
;*****************************************************************************************
;
;  PROCEDURE:   density_contour_plot.pro
;  PURPOSE  :   This routine creates a 2D contour plot from X vs. Y inputs by first
;                 creating a 2D histogram of number densities.  The contours outline
;                 regions of increasing number density with higher contour levels.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               is_a_number.pro
;               density_hist_2d_wrapper.pro
;               format_limits_struc.pro
;               struct_value.pro
;               str_element.pro
;               my_min_curve_surf.pro
;
;  REQUIRES:    
;               1)  THEMIS TDAS IDL libraries or UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               XDATA       :  [N]-Element array [float/double] of independent data points
;               YDATA       :  [N]-Element array [float/double] of   dependent data points
;
;  EXAMPLES:    
;               [calling sequence]
;               density_contour_plot, xdata, ydata,                                      $
;                                 [,XTTL=xttl] [,YTTL=yttl] [,XMIN=xmin] [,XMAX=xmax]    $
;                                 [,YMIN=ymin] [,YMAX=ymax] [,NX=nx] [,NY=ny]            $
;                                 [,X_LOG=x_log] [,Y_LOG=y_log] [,/OVERPLOT]             $
;                                 [,LIMITS=limits] [,CLABS=clabs] [,/SMCONT]             $
;                                 [,/USE_SMOOTH] [,SMWDTH=smwdth] [,LEVEL_PER=level_per] $
;                                 [,CPATH_OUT=cpath_out] [,HIST2D_OUT=hist2d_out]        $
;                                 [,CLIM_OUT=clim_out] [,RAN_H2DN=ran_h2dn]        $
;                                 [,_EXTRA=ex_str]
;
;               ;;------------------------------------------------------------------------
;               ;;  Define # of bins and data range
;               ;;------------------------------------------------------------------------
;               nx             = 100L
;               ny             = 100L
;               xyran          = [MIN([xdata,ydata],/NAN),MAX([xdata,ydata],/NAN)]
;               ;;------------------------------------------------------------------------
;               ;;  Define CONTOUR LIMITS structure
;               ;;------------------------------------------------------------------------
;               nlev           = 5L
;               ccols          = LINDGEN(nlev)*(250L - 30L)/(nlev - 1L) + 30L
;               con_lim        = {NLEVELS:nlev,C_COLORS:ccols}
;               ;;------------------------------------------------------------------------
;               ;;  Overplot CONTOUR on a pre-existing Y vs. X scatter plot
;               ;;------------------------------------------------------------------------
;               density_contour_plot,xdata,ydata,XMIN=xyran[0],XMAX=xyran[1],NX=nx[0],$
;                                                YMIN=xyran[0],YMAX=xyran[1],NY=ny[0],$
;                                                /OVERPLOT,LIMITS=con_lim,/X_LOG,/Y_LOG
;
;  KEYWORDS:    
;               **********************************
;               ***       DIRECT  INPUTS       ***
;               **********************************
;               [X,Y]TTL    :  Scalar [string] defining the [X,Y]-Axis title to use
;                                {ignored if OVERPLOT is set}
;               [X,Y]MIN    :  Scalar [float/double] defining the Min. [X,Y]-Axis plot
;                                value and the corresponding Min. value to consider when
;                                constructing the 2D histogram.
;                                { Default = MIN([X,Y]DATA) }
;               [X,Y]MAX    :  Scalar [float/double] defining the Max. [X,Y]-Axis plot
;                                value and the corresponding Max. value to consider when
;                                constructing the 2D histogram.
;                                { Default = MAX([X,Y]DATA) }
;               N[X,Y]      :  Scalar [long] defining the # of [X,Y]-Axis bins to use
;                                [Default = 100L]
;               [X,Y]_LOG   :  Scalar [long] defining whether the [X,Y]-Axis should be
;                                put on a log-scale
;                                [Default = FALSE]
;               OVERPLOT    :  If set, routine will plot the contours on top of the
;                                currently active plot.  When this is set, the routine
;                                ignores [X,Y]-Axis related graphics keywords set by the
;                                user or imbedded within LIMITS.
;               LIMITS      :  Scalar [structure] defining the plot limits structure
;                                with tag names matching acceptable keywords in
;                                CONTOUR.PRO to be passed using _EXTRA
;               CLABS       :  If set, routine will plot the contours with labels
;                                indicating the percentage of data points within each
;                                contour
;                                [Default = FALSE]
;               SMCONT      :  If set, routine will smooth the contours prior to plotting
;                                [Default = FALSE]
;               USE_SMOOTH  :  If set, routine will use SMOOTH.PRO instead of
;                                MIN_CURVE_SURF.PRO to smooth the contours.  Setting
;                                this keyword makes the routine run much much faster.
;                                [Default = FALSE]
;               LEVEL_PER   :  [L]-Element array [float/double] defining the relative
;                                percent of the maximum density from the 2D histogram
;                                to use for each level in the contour plot output
;               SMWDTH      :  Scalar [integer/long] defining the number of elements over
;                                 which to smooth the 2D histogram (only applies when the
;                                 USE_SMOOTH keyword is set)
;                                [Default = 4]
;               **********************************
;               ***      INDIRECT OUTPUTS      ***
;               **********************************
;               CPATH_OUT   :  Set to a named variable to return the contour path
;                                information in data coordinates
;               HIST2D_OUT  :  Set to a named variable to return the 2D histogram used
;                                to create the contours for CONTOUR.PRO
;               CLIM_OUT    :  Set to a named variable to return the plot limits
;                                structure for CONTOUR.PRO that includes level values
;               RAN_H2DN    :  Set to a named variable to return the range of histogram
;                                values prior to smoothing
;
;   CHANGED:  1)  Added keywords:  CLABS and SMCONT
;                                                                   [06/20/2013   v1.1.0]
;             2)  Added keyword:  USE_SMOOTH and now calls my_min_curve_surf.pro
;                                                                   [08/29/2013   v1.2.0]
;             3)  Added keywords:  CPATH_OUT and HIST2D_OUT
;                                                                   [04/14/2014   v1.3.0]
;             4)  Added keywords:  LEVEL_PER
;                                                                   [11/26/2014   v1.4.0]
;             5)  Added error handling for issue when CONTOUR does not output anything
;                   for the contour paths and now calls is_a_number.pro and
;                   added keywords:  SMWDTH, CLIMOUT, RAN_H2DN
;                                                                   [09/20/2018   v1.4.1]
;
;   NOTES:      
;               1)  This routine works well for overplotting contours onto
;                     Y vs. X scatter plots that have already been plotted.  To use
;                     it alone, make sure the LIMITS structure is sufficiently defined
;                     to create a useful contour plot.
;               2)  There are times when MIN_CURVE_SURF.PRO will take far too long to
;                     produce results (gets stuck in LUDC.PRO), so I copied it, renamed
;                     it to my_min_curve_surf.pro, and tried using LA_SVD and SVSOL
;                     instead.  It still failed in some cases, so I added the keyword
;                     USE_SMOOTH to allow the user to use a different method.
;               3)  If the LEVEL_PER keyword is set, it will trump the use of the LEVELS
;                     in the input LIMITS structure
;
;   CREATED:  05/01/2013
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/20/2018   v1.4.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO density_contour_plot,xdata,ydata,XTTL=xttl,XMIN=xmin,XMAX=xmax,NX=nx,X_LOG=x_log,$  ;; inputs
                                     YTTL=yttl,YMIN=ymin,YMAX=ymax,NY=ny,Y_LOG=y_log,$
                                     OVERPLOT=overplot,LIMITS=limits,CLABS=clabs,    $
                                     SMCONT=smcont,USE_SMOOTH=use_smooth,            $
                                     LEVEL_PER=level_per,SMWDTH=smwdth,              $
                                     CPATH_OUT=cpath_out,HIST2D_OUT=hist2d_out,      $  ;; outputs
                                     CLIM_OUT=clim_out,RAN_H2DN=ran_h2dn,            $
                                     _EXTRA=ex_str

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;; => Dummy error messages
noinpt_msg     = 'No input supplied...'
nofint_msg     = 'No finite data...'
badinp_msg     = 'XDATA and YDATA must have the same number of elements...'
;; => Dummy tick mark arrays
exp_val        = LINDGEN(501) - 250L                  ;;  Array of exponent values
exp_str        = STRTRIM(STRING(exp_val,FORMAT='(I)'),2L)
log10_tickn    = '10!U'+exp_str+'!N'                  ;;  Powers of 10 tick names
log10_tickv    = 1d1^DOUBLE(exp_val[*])               ;;  " " values
xyz_str        = ['x','y','z']
;;  All [XYZ]{Suffix} graphics tags
xyz_tags       = [xyz_str+'charsize',xyz_str+'gridstyle',xyz_str+'margin',            $
                  xyz_str+'minor',xyz_str+'range',xyz_str+'style',xyz_str+'thick',    $
                  xyz_str+'tickformat',xyz_str+'tickinterval',xyz_str+'ticklayout',   $
                  xyz_str+'ticklen',xyz_str+'tickname',xyz_str+'ticks',               $
                  xyz_str+'tickunits',xyz_str+'tickv',xyz_str+'tick_get',             $
                  xyz_str+'title']
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() NE 2) THEN BEGIN
  MESSAGE,noinpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
test_xy        = ((N_ELEMENTS(xdata) EQ 0) OR (N_ELEMENTS(ydata) EQ 0)) OR $
                  (N_ELEMENTS(xdata) NE N_ELEMENTS(ydata)) OR              $
                  (is_a_number(xdata,/NOMSSG) EQ 0) OR (is_a_number(ydata,/NOMSSG) EQ 0)
IF (test_xy[0]) THEN BEGIN
  MESSAGE,badinp_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;  Define parameters
xx             = REFORM(xdata)
yy             = REFORM(ydata)
;;----------------------------------------------------------------------------------------
;;  Get 2D Histogram
;;----------------------------------------------------------------------------------------
struc          = density_hist_2d_wrapper(xx,yy,XMIN=xmin,XMAX=xmax,NX=nx,X_LOG=x_log,$
                                               YMIN=ymin,YMAX=ymax,NY=ny,Y_LOG=y_log)
IF (SIZE(struc,/TYPE) NE 8) THEN RETURN
;;  Define 2D Histogram
hist2d         = struc.HIST2D
;;  Define Max. number density
maxdens        = MAX(hist2d,/NAN)*1d0
;maxdens        = CEIL(MAX(hist2d,/NAN)/1d2) * 1d2
;;  Define corresponding [X,Y]-grid
x_locs         = struc.X_LOCS
y_locs         = struc.Y_LOCS
;;  Define keywords used in HIST_2D.PRO
key_str        = struc.HIST_2D_STR
;;  X-Axis Keywords
xran_def       = [key_str.MINX[0],key_str.MAXX[0]]
widthx         = key_str.BINX[0]
nnx            = key_str.NX[0]
xlog           = key_str.XLOG[0]
;;  Y-Axis Keywords
yran_def       = [key_str.MINY[0],key_str.MAXY[0]]
widthy         = key_str.BINY[0]
nny            = key_str.NY[0]
ylog           = key_str.YLOG[0]
;;  Check [X,Y]LOG
IF KEYWORD_SET(xlog) THEN xxl = 1d1^(x_locs) ELSE xxl = x_locs
IF KEYWORD_SET(ylog) THEN yyl = 1d1^(y_locs) ELSE yyl = y_locs
;;----------------------------------------------------------------------------------------
;;  Check input for LIMITS
;;----------------------------------------------------------------------------------------
test_lim       = format_limits_struc(LIMITS=limits,PTYPE=2)
IF (SIZE(test_lim,/TYPE) NE 8) THEN lim0 = 0 ELSE lim0 = test_lim
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check USE_SMOOTH
test           = (N_ELEMENTS(use_smooth) NE 0) AND KEYWORD_SET(use_smooth)
IF (test[0]) THEN use_sm = 1 ELSE use_sm = 0
;;  Check SMCONT
test           = (N_ELEMENTS(smcont) NE 0) AND KEYWORD_SET(smcont)
IF (test[0]) THEN sm_cont = 1 ELSE sm_cont = 0
;;  Check SMWDTH
test           = (is_a_number(smwdth,/NOMSSG) EQ 0)
IF (test[0]) THEN wdth = 4L ELSE wdth = (LONG(smwdth[0]) > 3L) < (MIN([nnx[0],nny[0]])/2)
;;  Check CLABS
test           = (N_ELEMENTS(clabs) NE 0) AND KEYWORD_SET(clabs)
IF (test[0]) THEN plotlabs = 1 ELSE plotlabs = 0
;;  Check limits structure
over           = struct_value(lim0,'OVERPLOT',INDEX=ind)
test0          = (ind[0] GE 0) AND (over[0] EQ 1)
test1          = (N_ELEMENTS(overplot) NE 0) AND KEYWORD_SET(overplot)
test           = test0 OR test1
IF (test[0]) THEN over = 1 ELSE over = 0
;;  Add to LIMITS
str_element,lim0,'OVERPLOT',over[0],/ADD_REPLACE
;;  Check for XRANGE
xran           = struct_value(lim0,'XRANGE',INDEX=ind)
test0          = (ind[0] LT 0) OR (N_ELEMENTS(xran) NE 2)
IF (test0[0])     THEN xran = xran_def
IF (over[0] EQ 0) THEN str_element,lim0,'XRANGE',xran,/ADD_REPLACE
;;  Check for YRANGE
yran           = struct_value(lim0,'YRANGE',INDEX=ind)
test0          = (ind[0] LT 0) OR (N_ELEMENTS(yran) NE 2)
IF (test0[0])     THEN yran = yran_def
IF (over[0] EQ 0) THEN str_element,lim0,'YRANGE',yran,/ADD_REPLACE
;;-----------------------------------------
;;  [X,Y]-Axis Keywords
;;-----------------------------------------
test           = (over EQ 0)
IF (test) THEN BEGIN
  ;;------------------------------------
  ;;  Make new plot
  ;;------------------------------------
  ;;  X-Axis Title
  test0 = (SIZE(xttl,/TYPE) EQ 7)
  IF (test0) THEN str_element,lim0,'XTITLE',xttl[0],/ADD_REPLACE
  ;;  Y-Axis Title
  test0 = (SIZE(yttl,/TYPE) EQ 7)
  IF (test0) THEN str_element,lim0,'YTITLE',yttl[0],/ADD_REPLACE
ENDIF
;;----------------------------------------------------------------------------------------
;;  Set up CONTOUR LIMITS structure
;;----------------------------------------------------------------------------------------
;;  Check for LEVELS tag
test_lper      = (N_ELEMENTS(level_per) GT 2)
IF (test_lper) THEN levper0 = REFORM(level_per)
levels         = struct_value(lim0,'LEVELS',INDEX=ind)
test0          = (ind[0] LT 0) OR (N_ELEMENTS(levels) LE 2)
IF (test0) THEN BEGIN
  ;;  Check for NLEVELS tag
  nlevs          = struct_value(lim0,'NLEVELS',INDEX=ind)
  test0          = (ind[0] LT 0) OR (nlevs LE 2)
  IF (test0) THEN BEGIN
    ;;  Use default levels
    IF (test_lper) THEN levper = levper0 ELSE levper = [25d-2,50d-2,75d-2]
    levels = maxdens[0]*levper
    nlevs  = N_ELEMENTS(levels)
  ENDIF ELSE BEGIN
    IF (test_lper) THEN BEGIN
      levper = levper0
      nlevs  = N_ELEMENTS(levper)
      minper = MIN(levper,/NAN)
      maxper = MAX(levper,/NAN)
    ENDIF ELSE BEGIN
      minper = 2d-1
      maxper = 8d-1
      ;;  Define levels [from 20% to 80% of Max.]
      levper = DINDGEN(nlevs)*(maxper[0] - minper[0])/(nlevs - 1L) + minper[0]
    ENDELSE
    minlev = minper[0]*maxdens[0]
    maxlev = maxper[0]*maxdens[0]
    levels = DINDGEN(nlevs)*(maxlev[0] - minlev[0])/(nlevs - 1L) + minlev[0]
  ENDELSE
  str_element,lim0,'LEVELS',levels,/ADD_REPLACE
ENDIF ELSE BEGIN
  IF (test_lper) THEN BEGIN
    levper = levper0
    nlevs  = N_ELEMENTS(levper)
    minper = MIN(levper,/NAN)
    maxper = MAX(levper,/NAN)
    ;;  Redefine levels
    minlev = minper[0]*maxdens[0]
    maxlev = maxper[0]*maxdens[0]
    levels = DINDGEN(nlevs)*(maxlev[0] - minlev[0])/(nlevs - 1L) + minlev[0]
  ENDIF ELSE BEGIN
    minper = MIN(levels,/NAN)/maxdens[0]
    maxper = MAX(levels,/NAN)/maxdens[0]
    levper = DINDGEN(N_ELEMENTS(levels))*(maxper[0] - minper[0])/(N_ELEMENTS(levels) - 1L) + minper[0]
  ENDELSE
ENDELSE
nlevs  = N_ELEMENTS(levels)
str_element,lim0,'NLEVELS',nlevs[0],/ADD_REPLACE
;;  If NLEVELS < 10 -> label contours [as % contained within]
IF (nlevs LT 10 AND plotlabs) THEN BEGIN
  lev_str  = STRTRIM(STRING(REVERSE(levper)*1d2,FORMAT='(f10.0)'),2)+'%'
  str_element,lim0,'C_LABELS',REPLICATE(1,nlevs[0]),/ADD_REPLACE
  str_element,lim0,'C_ANNOTATION',lev_str,/ADD_REPLACE
ENDIF
;;----------------------------------------------------------------------------------------
;;  Smooth contours if desired
;;----------------------------------------------------------------------------------------
IF KEYWORD_SET(sm_cont) THEN BEGIN
  IF KEYWORD_SET(use_sm) THEN BEGIN
    ;;  Use smooth instead of my_min_curve_surf.pro
    hist2dn        = SMOOTH(hist2d,wdth[0],/NAN,/EDGE_TRUNCATE)
    xxln           = xxl
    yyln           = yyl
  ENDIF ELSE BEGIN
    ;;  Trick to smoothing the contours is to artificially increase the resolution of
    ;;    your 2D histogram through interpolation using MIN_CURVE_SURF.PRO
    temp           = hist2d
    szt            = SIZE(temp,/DIMENSIONS)
    newd           = (szt - 1L)*5L
    nxny           = newd + 1L
    ;;  Smooth density function
    temp           = my_min_curve_surf(temp,/DOUBLE,/REGULAR,NX=nxny[0],NY=nxny[1])
;    temp           = MIN_CURVE_SURF(temp,/DOUBLE,/REGULAR,NX=nxny[0],NY=nxny[1])
    ;;  Determine the new dimensions
    sztn           = SIZE(temp,/DIMENSIONS)
    ;;  Define corresponding [X,Y]-grid
    widthxn        = (xran_def[1] - xran_def[0])/(sztn[0] - 1L)
    widthyn        = (yran_def[1] - yran_def[0])/(sztn[1] - 1L)
    xyoff          = [xran_def[0],yran_def[0]]
    x_nlocs        = DINDGEN(sztn[0])*widthxn[0] + xyoff[0]
    y_nlocs        = DINDGEN(sztn[1])*widthyn[0] + xyoff[1]
    ;;  Check for logarithmic scaling and redefine contour inputs
    IF KEYWORD_SET(xlog) THEN xxln = 1d1^(x_nlocs) ELSE xxln = x_nlocs
    IF KEYWORD_SET(ylog) THEN yyln = 1d1^(y_nlocs) ELSE yyln = y_nlocs
    hist2dn        = temp
  ENDELSE
ENDIF ELSE BEGIN
  ;;  Change nothing
  hist2dn        = hist2d
  xxln           = xxl
  yyln           = yyl
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Plot contours
;;----------------------------------------------------------------------------------------
;;  -->  Plot contours
CONTOUR,hist2dn,xxln,yyln,_EXTRA=lim0
;;  -->  Record contours
CONTOUR,hist2dn,xxln,yyln,_EXTRA=lim0,/PATH_DATA_COORDS,/PATH_DOUBLE,$
        PATH_INFO=cpath_info,PATH_XY=cpath_xy
;;  Define path structure for output
tags           = ['INFO','XY']
;;  Make sure the outputs are defined
IF (N_ELEMENTS(cpath_info) EQ 0) THEN cpath_info = 0
IF (N_ELEMENTS(cpath_xy)   EQ 0) THEN cpath_xy = 0
cpath_out      = CREATE_STRUCT(tags,cpath_info,cpath_xy)
;;  Define histogram for output
hist2d_out     = hist2dn
;;  Define CLIM_OUT
clim_out       = lim0
;;  Define RAN_H2DN
good           = WHERE(FINITE(hist2d) AND hist2d GT 0,gd)
IF (gd[0] GT 0) THEN ran_h2dn = [MIN(hist2d[good],/NAN),MAX(hist2d[good],/NAN)] ELSE ran_h2dn = REPLICATE(d,2)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END
