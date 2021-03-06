
;PROCEDURE:	time_fit
;PURPOSE:
;
;  Creates "TPLOT" variable by summing 3D data over selected angle bins.
;
;INPUT:		data_str, a string(either 'eh','el','ph','pl','sf',or 'so' at
;		this point) telling which data to get.
;
;KEYWORDS:	bins: a keyword telling which bins to sum over
;		units:	convert to these units if included
;               NAME:  New name of the Data Quantity
;               BKG:  A 3d data structure containing the background counts.
;               FLOOR:  Sets the minimum value of any data point to sqrt(bkg).
;               ETHRESH:
;               MISSING: value for bad data.
;
;CREATED BY:  Davin Larson
;FILE:  mk_elpd_cdf.pro
;VERSION:  1.3
;LAST MODIFICATION:  97/02/26
;
;NOTES:	  "LOAD_3DP_DATA" must be called first to load up WIND data.
pro time_fit ,date  ,data_str,  $
;  	bins=bins, $       
	units = units,  $
        name  = name, $
	bkg = bkg, $
        missing = missing, $
        bsource=bsource, $
        vsource=vsource, $
        ethresh=ethresh,  $
        elbins = elbins,  $
        noload = noload, $
        lim = lim, $
        trange=trange, $
        data=d, $
	no3s_mag = no3s_mag, $
        num_pa=num_pa

ex_start = systime(1)

do_fit=1
version = '_v01'
if keyword_set(do_fit) then version = '_v03'
fileformat = 'wi_elft_3dp_'
if not keyword_set(units) then units = 'flux'
bsource = 'wi_B3'
vsource = 'Vp'
npsource ='wi_swe_Np'
data_str = 'el'
routine = 'get_'+data_str

if not keyword_set(noload) then begin
nodat = 0
if keyword_set(no3s_mag) then begin
   load_wi_mfi
   bsource = 'wi_B'
   nodat = 0
endif else load_wi_sp_mfi,name=bsource,nodat=nodat
load_wi_swe,/pol
if nodat then return
endif

elbins = bytarr(88) eq 0
elbins([5,7,9,10,16,18,20,21])=0

get_pmom2

times = call_function(routine,/times)
if ndimen(times) le 0 then begin
   message,/info,'No electron data to produce cdf file'
   return
endif
max = n_elements(times)
message,/info,string(max) +' Time samples'
istart = 0
if keyword_set(trange) then begin
   irange = fix(interp(findgen(max),times,time_double(trange)))
   print,irange
   irange = (irange < (max-1)) > 0
   irange = minmax_range(irange)
   istart = irange(0)
   times = times(istart:irange(1))
   print,'Index range: ',irange
   max = n_elements(times)
endif

dat = call_function(routine, t, index=0)

nenergy =15
nenergy = dat.nenergy
nredf = 32

if keyword_set(num_pa) eq 0 then num_pa = 8


dat0={time:0.d,flux:fltarr(nenergy,num_pa) $
  ,energy:fltarr(nenergy),pangle:fltarr(num_pa) $
  ,integ_t:0.  $
  ,redf:fltarr(nredf) $
  ,vsw:fltarr(3),magf:fltarr(3),np:0.}


if keyword_set(do_fit) then begin
   foo = elfit4(par=par)
   xfer_parameters,par,'',a,fulln=pnames
   d = strpos(pnames,'.')
   for i=0,n_elements(pnames)-1 do begin
     foo = pnames(i)
     if d(i) ge 0 then strput,foo,'_',d(i)
     pnames(i) = foo
   endfor
   params = 'core halo.n:vth:v'
   params = 'sc_pot core halo.n:vth:v'

   par.e_shift = 0.
   p0=par
   for i=0,n_elements(pnames)-1 do add_str_element,dat0,pnames(i),0.
;   add_str_element,dat0,'fitpar',par
   add_str_element,dat0,'chisq',0.
   par0=par
   badpar =par
   xfer_parameters,badpar,'',a,/struct_to_arr
   a(*) = !values.f_nan
   xfer_parameters,badpar,'',a,/array_to_str
   
endif

dat_bad=dat0
for i=0,n_tags(dat_bad)-1 do  dat_bad.(i) = !values.f_nan

d = replicate(dat_bad,max)

max = n_elements(times)
if max lt 2 then return

magf = data_cut(bsource,times,count=count)
if count ne max  then   message,bsource+' does not work!',/info

if keyword_set(vsource) then begin
  vsw = data_cut(vsource,times,count=count)
  if count ne max  then   message,vsource+' does not work!',/info
endif

if keyword_set(npsource) then begin
  nproton=data_cut(npsource,times,count=count)
  if count ne max then message,npsource+' does not work!',/info
endif

if not keyword_set(bsource) then message,'Please supply Magnetic field variable'

dat=conv_units(dat,units)

count = dat.nbins
ytitle = data_str+'pd'
if not keyword_set(elbins) then ind=indgen(dat.nbins) else ind=where(elbins,count)
if count ne dat.nbins then ytitle = ytitle+'_'+strtrim(count,2)
if keyword_set(name) eq 0 then name=ytitle else ytitle = name
ytitle = ytitle+' ('+units+')'

if not keyword_set(units) then units = 'counts'
if units eq 'Counts' then norm = 1 else norm = count

if not keyword_set(missing) then missing = !values.f_nan


magf = data_cut(bsource,times,count=count)
if count ne max  then   message,bsource+' does not work!'

if keyword_set(vsource) then begin
  vsw = data_cut(vsource,times,count=count)
  if count ne max  then   message,vsource+' does not work!'
endif

chi_lim = 20.  & chisq = 0.
erange = [7.,1e6]

lim = {psym:0}
debug1=1
debug2=1


for i=0l,max-1 do begin
   el = call_function(routine,index=i+istart)
;   print,i,' ',time_string(el.time)
   if el.valid ne 0 then begin
     if times(i) ne el.time then print,time_string(el.time),el.time-times(i)
     if keyword_set(bkg) then   el = sub3d(el,bkg)
     v = reform(vsw(i,*))
     m = reform(magf(i,*))
     np = nproton(i)
     df = convert_vframe(el,v,/int,ethresh=ethresh)
     df = conv_units(df,units)
     pd = pad(df,magf=m,NUM_PA=num_pa,BINS=elbins)
     d(i).time = df.time
     d(i).flux = pd.data
     d(i).energy = pd.energy(*,0)
     d(i).pangle = pd.angles(0,*)
     d(i).vsw = v
     d(i).magf = m
     d(i).np = np
     if keyword_set(do_fit) then begin
        add_str_element,el,'magf',m
        add_str_element,el,'vsw',v
;        add_str_element,el,'Np',np
        add_str_element,el,'bins',bytarr(15,88)
        sc_pot0 = sc_pot(np,par=scpar)
par.sc_pot = sc_pot0
par.core.n = np/1.5
        erange(0) = par.sc_pot - par.e_shift + 2.
        par=par0
        repeat begin
print,i,' ',time_string(el.time)
           if (erange(0) + par.e_shift) lt par.sc_pot then begin
              message,/info,'Invalid energy range'+string(7b)
              if keyword_set(debug1) then stop
           endif
                      
           el.bins = el.energy lt erange[1] and el.energy gt erange[0]
           if keyword_set(elbins) then $
             el.bins = el.bins and replicate(1b,15)#elbins
           dt = el.data(where(el.bins))
           ddt = sqrt((.03*dt)^2+ (dt+2.))
           foo = fitfunc(el,dt,dy=ddt,func='elfit4',nam=params,/nod,par=par, silent=silent,chi2 = chisq,maxp=12)
           if chisq ge chi_lim then foo = 0
           
           if keyword_set(lim) then begin
              elt = el
              fit = elfit4(elt,par=par,/set)
              over=0
              spec3d,el,lim=lim,bins=elbins,over=over
              lim2=lim
              str_element,/add,lim2,'psym',-4
              spec3d,elt,lim=lim2,bins=elbins,over=over
           endif
if debug() then stop
           if not keyword_set(foo) then begin
              printdat,par
              message,/info,'Invalid Parameters' +string(7b)
              par = badpar
              if keyword_set(debug2) then stop
           endif else begin
              par0=par
           endelse
        endrep until keyword_set(foo)
        xfer_parameters,par,'',parray,/struct_to_array
        temp_d = d(i)
        xfer_parameters,temp_d,pnames,parray,/array_to_struct
        d(i) = temp_d
        d(i).chisq = chisq
     endif
   endif
   
endfor

save,d,file='fitpar2.sav'


if not keyword_set(date) then date=d(0).time +3600. 
t = time_double(date)
t = t - t mod 86400.d
dates = strmid(time_string(t,f=2),0,8)
filename = fileformat+dates+version
w = where(d.time ge t and d.time lt (t+86400.),c)
if c ne 0 then begin
;  d = d(w)
  makecdf,d(w),file=filename,/overwrite
  print,'file ',filename,'.cdf created'
endif else print,'No data to produce file: ',filename+'.cdf' 



ex_time = systime(1) - ex_start
message,string(ex_time)+' seconds execution time.',/cont,/info

return

end
