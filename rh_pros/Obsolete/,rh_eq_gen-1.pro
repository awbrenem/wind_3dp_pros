;+
;*****************************************************************************************
;
;  FUNCTION :   rh_eq_gen.pro
;  PURPOSE  :   Computes the conservation relations and the gradients with respect to
;                 the shock normal angles [azimuthal,poloidal] and the shock speed
;                 for an input set of data points.  The shock normal angles and shock
;                 normal speed in the spacecraft frame are free variables in the
;                 minimization of the merit function defined by the Rankine-Hugoniot
;                 equations from Koval and Szabo, [2008].
;
;  CALLED BY:   
;               
;
;  CALLS:
;               del_vsn.pro
;               vec_norm.pro
;               vec_trans.pro
;
;  REQUIRES:    
;               
;
;  INPUT:
;               RHO    :  [N,2]-Element [up,down] array corresponding to the number
;                           density [cm^(-3)]
;               VSW    :  [N,3,2]-Element [up,down] array corresponding to the solar wind
;                           velocity vectors [SC-frame, km/s]
;               MAG    :  [N,3,2]-Element [up,down] array corresponding to the ambient
;                           magnetic field vectors [nT]
;               TOT    :  [N,2]-Element [up,down] array corresponding to the total plasma
;                           temperature [eV]
;               NOR    :  [3]-Element unit shock normal vectors
;               VSHN   :  [N]-Element array defining the shock normal
;                           velocities [km/s] in SC-frame
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               EQNUM  :  The equation number to generate
;                           1 = mass flux
;                           2 = normal B-field
;                           3 = transverse momentum flux
;                           4 = transverse E-field
;                           5 = normal momentum flux
;                           6 = energy flux
;                           [Default = 1]
;               POLYT  :  Scalar value defining the polytrope index
;                           [Default = 5/3]
;
;   CHANGED:  1)  Changed input and output format so that N RH Eqs
;                   are calculated for each shock normal vector     [09/07/2011   v1.1.0]
;
;   NOTES:      
;               1)  User should not call this routine
;
;  REFERENCES:  
;               1)  Vinas, A.F. and J.D. Scudder (1986), "Fast and Optimal Solution to
;                      the 'Rankine-Hugoniot Problem'," J. Geophys. Res. 91, pp. 39-58.
;               2)  A. Szabo (1994), "An improved solution to the 'Rankine-Hugoniot'
;                      problem," J. Geophys. Res. 99, pp. 14,737-14,746.
;               3)  Koval, A. and A. Szabo (2008), "Modified 'Rankine-Hugoniot' shock
;                      fitting technique:  Simultaneous solution for shock normal and
;                      speed," J. Geophys. Res. 113, pp. A10110.
;
;   CREATED:  06/21/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/07/2011   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION rh_eq_gen,rho,vsw,mag,tot,nor,vshn,EQNUM=eqnum,POLYT=polyt

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f          = !VALUES.F_NAN
d          = !VALUES.D_NAN
K_eV       = 1.160474d4        ; => Conversion = degree Kelvin/eV
kB         = 1.3806504d-23     ; => Boltzmann Constant (J/K)
qq         = 1.60217733d-19    ; => Fundamental charge (C) [or = J/eV]
me         = 9.1093897d-31     ; => Electron mass [kg]
mp         = 1.6726231d-27     ; => Proton mass [kg]
mi         = (me + mp)         ; => Total mass [kg]
muo        = 4d0*!DPI*1d-7     ; => Permeability of free space (N/A^2 or H/m)
IF ~KEYWORD_SET(polyt) THEN polyti = 5d0/3d0 ELSE polyti = polyt[0]
IF ~KEYWORD_SET(eqnum) THEN eqn    = 1       ELSE eqn    = LONG(eqnum[0])
; => Make sure polytrope index is between 1-3
IF (polyti[0] LT 1d0 OR polyti[0] GT 3d0) THEN polyti = 5d0/3d0
gfactor    = polyti[0]/(polyti[0] - 1d0)
;-----------------------------------------------------------------------------------------
; => Convert input to SI units
;-----------------------------------------------------------------------------------------
rhoud      = REFORM(rho)*1d6*mp   ; => convert to [kg m^(-3)]  [N,2]-Element
bo         = REFORM(mag)*1d-9     ; => convert to [Tesla]      [N,3,2]-Element
vo         = REFORM(vsw)*1d3      ; => convert to [m/s]        [N,3,2]-Element
te         = REFORM(tot)*qq       ; => convert to [Joules]     [N,2]-Element
;bo         = TRANSPOSE(bo)        ; => change to [2,3]-Element array
;vo         = TRANSPOSE(vo)        ; => change to [2,3]-Element array
; => Define thermal pressure [Pa]
pt         = rhoud/mp[0]*te          ; => Pa = N m^(-2) = J m^(-3) [N,2]-Element

vou        = REFORM(vo[*,*,0])      ; => Upstream     [N,3]-Element array
vod        = REFORM(vo[*,*,1])      ; => Downstream   [N,3]-Element array
bou        = REFORM(bo[*,*,0])      ; => Upstream     [N,3]-Element array
bod        = REFORM(bo[*,*,1])      ; => Downstream   [N,3]-Element array
;-----------------------------------------------------------------------------------------
; => Calculate (V . n - Vs)
;-----------------------------------------------------------------------------------------
delvsu     = del_vsn(vou,nor,vshn,VEC=0)      ; => [N]-Element array
delvsd     = del_vsn(vod,nor,vshn,VEC=0)
;-----------------------------------------------------------------------------------------
; => Calculate (V - Vs n)
;-----------------------------------------------------------------------------------------
delvvu     = del_vsn(vou,nor,vshn,VEC=1)      ; => [N,3]-Element array
delvvd     = del_vsn(vod,nor,vshn,VEC=1)
; => Calc. the squares
delvvu2    = TOTAL(delvvu^2,2L,/NAN)/2d0
delvvd2    = TOTAL(delvvd^2,2L,/NAN)/2d0
; => Calculate (V - Vs n) . B
delvvudb   = delvvu[*,0]*bou[*,0] + delvvu[*,1]*bou[*,1] + delvvu[*,2]*bou[*,2]
delvvddb   = delvvd[*,0]*bod[*,0] + delvvd[*,1]*bod[*,1] + delvvd[*,2]*bod[*,2]
;-----------------------------------------------------------------------------------------
; => Pre-define relevant quantities
;-----------------------------------------------------------------------------------------
n          = N_ELEMENTS(vshn)
vn         = REPLICATE(d,n,3L,2L)  ; => Vsw . n
bn         = REPLICATE(d,n,3L,2L)  ; => Bo  . n
vt         = REPLICATE(d,n,3L,2L)  ; => (n x Vsw) x n
bt         = REPLICATE(d,n,3L,2L)  ; => (n x Bo ) x n
ncrossVt   = REPLICATE(d,n,3L,2L)  ; => (n x Vt) = n x [(n x Vsw) x n] = n x Vsw
ncrossBt   = REPLICATE(d,n,3L,2L)  ; => (n x Bt) = n x [(n x Bo ) x n] = n x Bo

; => Define normal terms
nor2       = REPLICATE(d,n,3L)
nor2[*,0]  = nor[0]
nor2[*,1]  = nor[1]
nor2[*,2]  = nor[2]
vn[*,0,0]  = vec_norm(vou,nor2)  & vn[*,1,0] = vn[*,0,0] & vn[*,2,0] = vn[*,0,0]
vn[*,0,1]  = vec_norm(vod,nor2)  & vn[*,1,1] = vn[*,0,1] & vn[*,2,1] = vn[*,0,1]
bn[*,0,0]  = vec_norm(bou,nor2)  & bn[*,1,0] = bn[*,0,0] & bn[*,2,0] = bn[*,0,0]
bn[*,0,1]  = vec_norm(bod,nor2)  & bn[*,1,1] = bn[*,0,1] & bn[*,2,1] = bn[*,0,1]
; => Define transverse terms
vt[*,*,0]  = vec_trans(vou,nor2)
vt[*,*,1]  = vec_trans(vod,nor2)
bt[*,*,0]  = vec_trans(bou,nor2)
bt[*,*,1]  = vec_trans(bod,nor2)
; => Define cross terms
ncrossVt[*,*,0] = my_crossp_2(nor,REFORM(vt[*,*,0]),/NOM)
ncrossVt[*,*,1] = my_crossp_2(nor,REFORM(vt[*,*,1]),/NOM)
ncrossBt[*,*,0] = my_crossp_2(nor,REFORM(bt[*,*,0]),/NOM)
ncrossBt[*,*,1] = my_crossp_2(nor,REFORM(bt[*,*,1]),/NOM)
;-----------------------------------------------------------------------------------------
; => Define relevant equation and partials
;-----------------------------------------------------------------------------------------
CASE eqn[0] OF
  1  :  BEGIN
    ; => mass flux equation [Eq. 1 from Koval and Szabo, 2008]
    eq0      = REPLICATE(d,n,3L)
    eq0[*,0] = rhoud[*,1]*delvsd - rhoud[*,0]*delvsu
    eq0[*,1] = rhoud[*,1]*delvsd - rhoud[*,0]*delvsu
    eq0[*,2] = rhoud[*,1]*delvsd - rhoud[*,0]*delvsu
  END
  2  :  BEGIN
    ; => Bn equation [Eq. 2 from Koval and Szabo, 2008]
    eq0      = bn[*,*,0] - bn[*,*,1]
  END
  3  :  BEGIN
    ; => transverse momentum flux equation [Eq. 3 from Koval and Szabo, 2008]
;    eup = rhoud[0]*[[delvsu*vt[*,0,0]],[delvsu*vt[*,1,0]],[delvsu*vt[*,2,0]]]
;    edn = rhoud[1]*[[delvsd*vt[*,0,1]],[delvsd*vt[*,1,1]],[delvsd*vt[*,2,1]]]
    eup      = REPLICATE(d,n,3L)
    edn      = REPLICATE(d,n,3L)
    eup[*,0] = rhoud[*,0]*delvsu*vt[*,0,0]
    eup[*,1] = rhoud[*,0]*delvsu*vt[*,1,0]
    eup[*,2] = rhoud[*,0]*delvsu*vt[*,2,0]
    edn[*,0] = rhoud[*,1]*delvsd*vt[*,0,1]
    edn[*,1] = rhoud[*,1]*delvsd*vt[*,1,1]
    edn[*,2] = rhoud[*,1]*delvsd*vt[*,2,1]
    bte      = bn*bt/muo[0]
    eq0      = (edn - bte[*,*,1]) - (eup - bte[*,*,0])
  END
  4  :  BEGIN
    ; => transverse electric field equation [Eq. 4 from Koval and Szabo, 2008]
;    evu = [[delvsu*ncrossBt[*,0,0]],[delvsu*ncrossBt[*,1,0]],[delvsu*ncrossBt[*,2,0]]]
;    evd = [[delvsd*ncrossBt[*,0,1]],[delvsd*ncrossBt[*,1,1]],[delvsd*ncrossBt[*,2,1]]]
    ett      = ncrossVt*bn
    evu      = REPLICATE(d,n,3L)
    evd      = REPLICATE(d,n,3L)
    evu[*,0] = delvsu*ncrossBt[*,0,0]
    evu[*,1] = delvsu*ncrossBt[*,1,0]
    evu[*,2] = delvsu*ncrossBt[*,2,0]
    evd[*,0] = delvsd*ncrossBt[*,0,1]
    evd[*,1] = delvsd*ncrossBt[*,1,1]
    evd[*,2] = delvsd*ncrossBt[*,2,1]
    eq0      = (ett[*,*,1] - evd) - (ett[*,*,0] - evu)
  END
  5  :  BEGIN
    ; => normal momentum flux equation [Eq. 5 from Koval and Szabo, 2008]
;    btm = SQRT(TOTAL(bt^2,2L,/NAN))/(2d0*muo)        ; => [N,2]-Element array
;    dyn = [[rhoud[0]*delvsu^2],[rhoud[1]*delvsd^2]]  ; => [N,2]-Element array
;    eup = pt[0] + btm[*,0] + dyn[*,0]
;    edn = pt[1] + btm[*,1] + dyn[*,1]
    btm      = SQRT(TOTAL(bt^2,2L,/NAN))/(2d0*muo[0])         ; => [N,2]-Element array
    dynu     = rhoud[*,0]*delvsu^2                            ; => [N]-Element array
    dynd     = rhoud[*,1]*delvsd^2                            ; => [N]-Element array
    eup      = pt[*,0] + btm[*,0] + dynu
    edn      = pt[*,1] + btm[*,1] + dynd
    eq0      = REPLICATE(d,n,3L)
    eq0[*,0] = (edn - eup)
    eq0[*,1] = (edn - eup)
    eq0[*,2] = (edn - eup)
  END
  6  :  BEGIN
    ; => energy flux equation [Eq. 6 from Koval and Szabo, 2008]
;    bmg = [NORM(bou)^2/rhoud[0],NORM(bod)^2/rhoud[1]]/muo       ; => 2-Element array
;    ent = gfactor[0]*pt/rhoud                                   ; => 2-Element array
;    eup = rhoud[0]*delvsu*(delvvu2 + ent[0] + bmg[0])           ; => N-Element array
;    edn = rhoud[1]*delvsd*(delvvd2 + ent[1] + bmg[1])           ; => N-Element array
;    bbu = bn[*,0,0]*delvvudb/muo                                ; => N-Element array
;    bbd = bn[*,0,1]*delvvddb/muo                                ; => N-Element array
;    eq0 = ((edn - bbd) - (eup - bbu)) # REPLICATE(1,3)
    bmgu     = TOTAL(bou^2,2L,/NAN)/(rhoud[*,0]*muo[0])
    bmgd     = TOTAL(bod^2,2L,/NAN)/(rhoud[*,1]*muo[0])
    entu     = gfactor[0]*pt[*,0]/rhoud[*,0]
    entd     = gfactor[0]*pt[*,1]/rhoud[*,1]
    eup      = rhoud[*,0]*delvsu*(delvvu2 + entu + bmgu)
    edn      = rhoud[*,1]*delvsd*(delvvd2 + entd + bmgd)
    bbu      = bn[*,0,0]*delvvudb/muo[0]
    bbd      = bn[*,0,1]*delvvddb/muo[0]
    eq0      = REPLICATE(d,n,3L)
    eq0[*,0] = ((edn - bbd) - (eup - bbu))
    eq0[*,1] = ((edn - bbd) - (eup - bbu))
    eq0[*,2] = ((edn - bbd) - (eup - bbu))
  END
ENDCASE
;-----------------------------------------------------------------------------------------
; => Return value to user
;-----------------------------------------------------------------------------------------

RETURN, eq0
END
