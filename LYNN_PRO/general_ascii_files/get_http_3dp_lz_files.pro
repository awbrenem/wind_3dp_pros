;*****************************************************************************************
;
;  FUNCTION :   get_ymdhms_2_time.pro
;  PURPOSE  :   Return the Unix time from an input string time
;
;*****************************************************************************************

FUNCTION get_ymdhms_2_time,s,INFORMAT=format,TFORMAT=tformat

;;----------------------------------------------------------------------------------------
;;  Defaults
;;----------------------------------------------------------------------------------------
order          = [2,1,0,3,4,5]
tformat        = ''
months         = ['JAN','FEB','MAR','APR', 'MAY', 'JUN', 'JUL', 'AUG','SEP','OCT','NOV','DEC']
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check INFORMAT
test           = ~KEYWORD_SET(format) OR (SIZE(format,/TYPE) NE 7)
IF (test[0]) THEN format = 'YMDhms' ELSE format = format[0]
;;----------------------------------------------------------------------------------------
;;  Define relevant variables
;;----------------------------------------------------------------------------------------
;;  Remove all "white space" and separate into segments.
ss             = STRSPLIT(STRUPCASE(s),' _-:/',/EXTRACT,COUNT=nss)
FOR i=0L, nss[0] - 1L DO BEGIN
   w = WHERE(ss[i] EQ months,nw)
   IF (nw[0] GT 0) THEN ss[i] = STRTRIM(w[0] + 1L,2L)  ;;  replace months with a number.
ENDFOR
;;  Find segments that only contains numbers. Ignore everything else
w              = WHERE(ss EQ STRLOWCASE(ss),nw)
IF (nw[0] EQ 0) THEN RETURN,0d0
ss             = TEMPORARY(ss[w])
;;  Sort by bytes
;;    PRINT,SORT(BYTE('YMDhms'))
;;           2           1           0           3           4           5
srt            = SORT(BYTE(format))
srto           = srt[order]
;;  Redefine string again
ss             = TEMPORARY(ss[srto[0L:(nw[0] - 1L)]])
;;  Add trailing white space
str            = STRJOIN(ss,' ')
;;  Convert to Unix
unix           = time_double(str)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,unix
END

;*****************************************************************************************
;
;  FUNCTION :   get_http_3dp_lz_header_element.pro
;  PURPOSE  :   Return the header element specified on input
;
;*****************************************************************************************

FUNCTION get_http_3dp_lz_header_element,header,name

;;  Compare two strings
res            = STRCMP(header,name,STRLEN(name),/FOLD_CASE)
g              =  WHERE(res,ng)
IF (ng[0] GT 0) THEN BEGIN
  ;;  NAME found in header
  RETURN,STRMID(header[g[0]],STRLEN(name) + 1L)
ENDIF ELSE BEGIN
  ;;  NAME not found in header
  RETURN,''
ENDELSE

END

;*****************************************************************************************
;
;  PROCEDURE:   get_http_3dp_lz_header_info.pro
;  PURPOSE  :   Return the header info
;
;*****************************************************************************************

PRO get_http_3dp_lz_header_info,header,hi,VERBOSE=verbose

IF (N_PARAMS() LT 2) THEN RETURN
;; MIME type recognition
IF (STRMID(hi.URL,0,1,/REVERSE_OFFSET) EQ '/') THEN hi.DIRECTORY = 1b     ;;  Make sure directory-type URL setting is on
hi.LTIME           = SYSTIME(1)
hi.STATUS_STR      = header[0]
header0            = STRSPLIT(/EXTRACT,header[0],' ')
hi.STATUS_CODE     = FIX(header0[1])
;;  Get server time (date)
date               = get_http_3dp_lz_header_element(header,'Date:')
IF KEYWORD_SET(date) THEN hi.ATIME = get_ymdhms_2_time(date,INFORMAT='DMYhms') ELSE hi.ATIME = hi.LTIME
hi.CLOCK_OFFSET    = hi.ATIME - hi.LTIME
;;  Look for successful return
hi.EXISTS          = (hi.STATUS_CODE EQ 200) || (hi.STATUS_CODE EQ 304)
hi.CLASS           = 'text'
hi.TYPE            = 'simple'                ;;  in case no information found...
;;  Get the content type from header
hi.CONTENT_TYPE    = get_http_3dp_lz_header_element(header,'Content-Type:')
IF KEYWORD_SET(hi.CONTENT_TYPE) THEN BEGIN
  hi.CLASS = (STRSPLIT(hi.CONTENT_TYPE, '/', /EXTRACT))[0]
  hi.TYPE  = (STRSPLIT(hi.CONTENT_TYPE, '/', /EXTRACT))[1]
ENDIF
;;  Get file modification time
last_modified      = get_http_3dp_lz_header_element(header,'Last-Modified:')
hi.MTIME           = KEYWORD_SET(last_modified) ? get_ymdhms_2_time(last_modified,INFORMAT='DMYhms') : SYSTIME(1)
;;  Try to determine length
len                = get_http_3dp_lz_header_element(header,'Content-Length:')
IF KEYWORD_SET(len) THEN BEGIN
  hi.SIZE = LONG64(len)
ENDIF ELSE BEGIN
  IF (hi.SIZE LE 0) THEN hi.SIZE = -1LL
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END


;+
;*****************************************************************************************
;
;  PROCEDURE:   get_http_3dp_lz_files.pro
;  PURPOSE  :   Uses Unix to check whether files exist at the 3DP LZ HTTP site and if so,
;                 return the full url path to those files.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               get_ymdhms_2_time.pro
;               get_http_3dp_lz_header_element.pro
;               get_http_3dp_lz_header_info.pro
;
;  CALLS:
;               get_os_slash.pro
;               test_file_path_format.pro
;               time_string.pro
;               time_double.pro
;               test_tdate_format.pro
;               get_valid_trange.pro
;               fill_tdates_btwn_start_end.pro
;               convert_html_url_2_string.pro
;               get_http_3dp_lz_header_info.pro
;               get_http_3dp_lz_header_element.pro
;               find_local_3dp_lz_files.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  Internet connection
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               [calling sequence]
;               get_http_3dp_lz_files [,TDATE=tdate] [,TRANGE=trange] [,/NO_CLOBBER] $
;                                     [,OUT_FILES=out_files]
;
;               ;;  Example usage
;               start_of_day   = '00:00:00.000'
;               tdate0         = '2015-01-02'
;               tdate1         = '2015-04-01'
;               t_tra          = [tdate0[0],tdate1[0]]+'/'+start_of_day[0]
;               tran           = time_double(t_tra)
;               get_http_3dp_lz_files,TRANGE=tran,OUT_FILES=out_files
;
;  KEYWORDS:    
;               TDATE       :  Scalar [string] defining the date of interest of the form:
;                                'YYYY-MM-DD' [MM=month, DD=day, YYYY=year]
;                                [Default = prompted by get_valid_trange.pro]
;               TRANGE      :  [2]-Element [double] array specifying the Unix time
;                                range for which to limit the data in DATA
;                                [Default = prompted by get_valid_trange.pro]
;               NO_CLOBBER  :  If set, routine will not remove old versions of file
;                                [Default = FALSE]
;               ***  OUTPUT  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               ***  [all the following changed on output]  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               OUT_FILES   :  Set to a named variable to return the full file path
;                                and file names for the desired files
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [05/16/2018   v1.0.0]
;             2)  Added some examples to Man. page for usage
;                                                                   [05/01/2019   v1.0.1]
;
;   NOTES:      
;               1)  This will overwrite files and there is very little error handling
;                     beyond the bare minimum necessary to prevent major system failures
;               2)  See also:  file_http_copy.pro, file_retrieve.pro, spd_download.pro
;
;  REFERENCES:  
;               NA
;
;   CREATED:  05/15/2018
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/01/2019   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO get_http_3dp_lz_files,TDATE=tdate,TRANGE=trange,NO_CLOBBER=no_clobber,OUT_FILES=out_files

;;----------------------------------------------------------------------------------------
;;  Defaults
;;----------------------------------------------------------------------------------------
tstart             = SYSTIME(1)
slash              = get_os_slash()                              ;;  '/' for Unix, '\' for Windows
http_slash         = '/'                                         ;;  separator for URLs
read_tout          = 30
connect_tout       = 5
port               = 80
date_form          = 'YYYYMMDD'
print_pref         = '% FIND_HTTP_3DP_LZ_FILES: '
fname_pref         = 'wi_lz_3dp_'
;;  Default 3DP LZ file location
def_datloc         = '.'+slash[0]+'wind_3dp_pros'+slash[0]+'wind_data_dir'+slash[0]+$
                     'data1'+slash[0]+'wind'+slash[0]+'3dp'+slash[0]+'lz'+slash[0]
;;  Define location where files will be written
test_umn           = test_file_path_format(def_datloc[0],EXISTS=umn_exists,DIR_OUT=localdir)
IF (~test_umn[0] OR ~umn_exists[0]) THEN RETURN
;;----------------------------------------------------------------------------------------
;;  Define dummy time variables
;;----------------------------------------------------------------------------------------
tdate_launch       = '1994-11-01'                                ;;  launch date of Wind
tdate0             = '1995-01-01'                                ;;  start of 3DP LZ files
t_current          = time_string(tstart[0],PREC=3)
tdate1             = STRMID(t_current[0],0L,10L)                 ;;  Current date
yr_st_en           = STRMID([tdate0[0],tdate1[0]],0L,4L)
start_of_day       = '00:00:00.000'
end___of_day       = '23:59:59.999'
;;  Define the maximum possible time range
tr_tmax            = [tdate0[0]+'/'+start_of_day[0],tdate1[0]+'/'+end___of_day[0]]
tr_dmax            = time_double(tr_tmax)
;;----------------------------------------------------------------------------------------
;;  Define other dummy variables
;;----------------------------------------------------------------------------------------
;;  Define 3DP LZ file name formats
fname_format       = 'wi_lz_3dp_'+date_form[0]+'_v??.dat'
;;  Define SPDF base data directory
wi3dp_base_dir     = 'http://sprg.ssl.berkeley.edu/wind3dp/data/wi/3dp/lz/'
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check TDATE and TRANGE
test0          = test_tdate_format(tdate,/NOMSSG)
test1          = ((N_ELEMENTS(trange) EQ 2) AND is_a_number(trange,/NOMSSG))
test           = test0[0] OR test1[0]
IF (test[0]) THEN BEGIN
  ;;  At least one is set --> use that one
  IF (test0[0]) THEN time_ra = get_valid_trange(TDATE=tdate) ELSE time_ra = get_valid_trange(TRANGE=trange)
ENDIF ELSE BEGIN
  ;;  Prompt user and ask user for date/times
  time_ra        = get_valid_trange(TDATE=tdate,TRANGE=trange)
ENDELSE
;;  Define dates and time ranges
tra                = time_ra.UNIX_TRANGE
tdates             = time_ra.DATE_TRANGE        ;;  'YYYY-MM-DD'  e.g., '2009-07-13'
tdate              = tdates[0]                  ;;  Redefine TDATE on output
;;  Define all dates between start and end date
all_tdates         = fill_tdates_btwn_start_end(tdates[0],tdates[1])
;;  Define years
fyears             = STRMID(all_tdates,0L,4L)       ;;  'YYYY'
unqy               = UNIQ(LONG(fyears),SORT(LONG(fyears)))
;IF (fyears[0] NE fyears[1]) THEN multiyear = 1b ELSE multiyear = 0b
multiyear          = 0b                         ;;  For now, shut off option for multiple years
;;  Convert TDATEs to format used by 3DP LZ files [e.g., 'YYYYMMDD']
fdates             = STRMID(all_tdates,0L,4L)+STRMID(all_tdates,5L,2L)+STRMID(all_tdates,8L,2L)
;;----------------------------------------------------------------------------------------
;;  Define HTTP/URL address
;;----------------------------------------------------------------------------------------
s_start            = 7L                         ;;  characters to skip for 'http://'
nyear              = N_ELEMENTS(unqy)           ;;  # of years
ndate              = N_ELEMENTS(fdates)         ;;  # of unique dates

FOR dd=0L, ndate[0] - 1L DO BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Define url for this date
  ;;--------------------------------------------------------------------------------------
  url                = wi3dp_base_dir[0]+fyears[dd[0]]+http_slash[0]
  ;;  Get the page source HTML
  convert_html_url_2_string,url,PAGE_SOURCE=page_source
  ;;  Get file version
  psource            = REFORM(page_source)
  all_posi           = STRPOS(psource,fname_pref[0]+fdates[dd[0]])
  gposi              = WHERE(all_posi GE 0,gp)
  IF (gp[0] EQ 0) THEN CONTINUE
  gline              = psource[gposi[0]]
  vposi              = STREGEX(gline[0],'v0',/FOLD_CASE)
  fvers              = STRMID(gline[0],vposi[0],3L)
  ;;--------------------------------------------------------------------------------------
  ;;  Define file name
  ;;--------------------------------------------------------------------------------------
  fname              = fname_pref[0]+fdates[dd[0]]+'_'+fvers[0]+'.dat'
  ;;--------------------------------------------------------------------------------------
  ;;  Get file size
  ;;--------------------------------------------------------------------------------------
  sposis             = STREGEX(gline[0],' </td><td align="right">',/FOLD_CASE)
  sposie             = STREGEX(gline[0],'</td><td>&nbsp;</td></tr>',/FOLD_CASE)
  sposis_off         = STRLEN(' </td><td align="right">')
  low                = sposis[0] + sposis_off[0]
  del                = sposie[0] - low[0]
  fsizes             = STRTRIM(STRMID(gline[0],low[0],del[0]),2L)
  fsizeu             = STRMID(fsizes,0,1,/REVERSE_OFF)      ;;  e.g., 'M'  for Megabyte
  uposi              = STRPOS(fsizes,fsizeu[0])
  fsizen             = FLOAT(STRMID(fsizes,0,uposi[0]))
  onemeg             = 2e0^20e0                             ;;  1 Mebibyte
  onekil             = 2e0^10e0                             ;;  1 kibibyte
  IF (fsizeu[0] EQ 'M') THEN BEGIN
    file_size        = LONG64(onemeg[0]*fsizen[0]) > 0LL
  ENDIF ELSE BEGIN
    ;;  Smaller???  -->  Check if in the kilobyte area
    IF (fsizeu[0] EQ 'k' OR fsizeu[0] EQ 'K') THEN BEGIN
      file_size        = LONG64(onekil[0]*fsizen[0]) > 0LL
    ENDIF ELSE BEGIN
      ;;  What file size is this???  -->  Debug
      STOP
    ENDELSE
  ENDELSE
  ;;--------------------------------------------------------------------------------------
  ;;  Redefine url
  ;;--------------------------------------------------------------------------------------
  url               += fname[0]
  slen               = STRLEN(url[0])
  end_slash          = STRPOS(STRMID(url[0],s_start[0],slen[0]),http_slash[0])
  wi3dp_server       = STRMID(url[0],s_start[0],end_slash[0])
  purl               = STRMID(url[0],end_slash[0]+s_start[0],slen[0])
  
  newpathname        = fyears[dd[0]]+slash[0]+fname[0]
  ;;--------------------------------------------------------------------------------------
  ;;  Initialize variables
  ;;--------------------------------------------------------------------------------------
  localname          = ''
  download_file      = 1
  ;;  Initialize URL structure
  url_info           = {http_info,        $
                        URL:'',           $   ;;  Full url of file
                        IO_ERROR: 0,      $
                        LOCALNAME:'',     $   ;;  local file name
                        STATUS_STR:'',    $
                        STATUS_CODE:0,    $
                        CONTENT_TYPE:'',  $
                        TYPE:'',          $   ;;  type of file
                        CLASS:'',         $   ;;  Class
                        EXISTS: 0B,       $
                        DIRECTORY: 0B,    $
                        CLOCK_OFFSET: 0L, $   ;;  difference between server time and local time
                        LTIME: 0LL,       $   ;;  Time when procedure was run
                        ATIME: 0LL,       $   ;;  server time at time of last access
                        MTIME: 0LL,       $   ;;  last mod time of file
                        SIZE:  0LL        $
                        }
  ;;  Define URL structure tags
  url_info.URL       = url
  url_info.LTIME     = SYSTIME(1)
  url_info.SIZE      = file_size[0]
  indexfilename      = '.remote-index.html'
  ;;  Define local file name
  localname          = localdir[0]+newpathname[0]
  IF (STRMID(url[0],0,1,/REVERSE_OFFSET) EQ '/') THEN BEGIN    ;;  Directories
    url_info.DIRECTORY = 1b
    localname          = localname[0]+indexfilename[0]
  ENDIF
  lcl                = FILE_INFO(localname[0])
  url_info.LOCALNAME = localname[0]
  url_info.EXISTS    = -1                                      ;;  remote existence is not known!  (yet)
  lcl_part           = FILE_INFO(localname[0]+'.part')
  ;;--------------------------------------------------------------------------------------
  ;;--------------------------------------------------------------------------------------
  ;;--------------------------------------------------------------------------------------
  ;;  Check on server and open socket
  ;;--------------------------------------------------------------------------------------
  ;;--------------------------------------------------------------------------------------
  ;;--------------------------------------------------------------------------------------
  t_connect          = SYSTIME(1)
  SOCKET,gunit,wi3dp_server[0],port[0],/GET_LUN,/SWAP_IF_LITTLE_ENDIAN,ERROR=error,$
         READ_TIMEOUT=read_tout,CONNECT_TIMEOUT=connect_tout
  IF (error[0] NE 0) THEN BEGIN
    ;;  Something failed --> debug
    FREE_LUN,gunit
    ;;  Issue error message
    MESSAGE,!ERROR_STATE.MSG,/CONTINUE,/INFORMATION
    STOP
    ;;  Jump to end of loop
    GOTO,CLOSE_SERVER
  ENDIF
  ;;  Show status of connection
  PRINTF,gunit, 'GET '+purl[0]+' HTTP/1.0'
  IF ~KEYWORD_SET(host) THEN host = wi3dp_server[0]
  PRINTF,gunit, 'Host: '+host[0]
  PRINTF,gunit, ''
  
  IF (N_ELEMENTS(if_modified_since) EQ 0) THEN if_modified_since = 1
  IF KEYWORD_SET(if_modified_since) THEN BEGIN
    input       = (if_modified_since LT 2) ? (lcl.MTIME + 1) : if_modified_since
    filemodtime = time_string(input,TFORMAT='DOW, DD MTH YYYY hh:mm:ss GMT' )
    PRINTF,gunit,'If-Modified-Since: '+filemodtime[0]
    MESSAGE,'If-Modified-Since: '+filemodtime[0],/CONTINUE,/INFORMATION
  ENDIF
  ;;  Read in header
  linesread          = 0L
  text               = 'XXX'
  ON_IOERROR, DONE            ;;  Jump to DONE on error
  header             = STRARR(256)
  WHILE (text[0] NE '') DO BEGIN
    READF,gunit,text
    header[linesread[0]] = text
    linesread           += 1
    IF (linesread[0] MOD 256 EQ 0) THEN header = [header,STRARR(256)]
  ENDWHILE
  ;;======================================================================================
  DONE: ON_IOERROR, NULL
  ;;======================================================================================
  IF (linesread[0] EQ 0) THEN BEGIN
    ;;  Close socket
    FREE_LUN,gunit
    ;;  Issue error message
    MESSAGE,!ERROR_STATE.MSG,/CONTINUE,/INFORMATION
    url_info.IO_ERROR = 1
    GOTO, FINAL
  ENDIF
  ;;--------------------------------------------------------------------------------------
  ;;  Check on header info
  ;;--------------------------------------------------------------------------------------
  header             = header[0L:(linesread[0] - 1L)]
  url_info.LOCALNAME = localname     ;;  line is redundant - already performed
  get_http_3dp_lz_header_info,header,url_info,VERBOSE=verbose
  ;;--------------------------------------------------------------------------------------
  ;;  Check on status of server connection
  ;;--------------------------------------------------------------------------------------
  ;;  Check authorization status
  IF (url_info.STATUS_CODE[0] EQ 401) THEN BEGIN
    ;;  Unauthorized server access requested
    realm    = get_http_3dp_lz_header_element(header,'WWW-Authenticate:')
    prefix   = KEYWORD_SET(user_pass) ? 'Invalid USER_PASS: "'+user_pass+'" for: '+realm  : 'keyword USER_PASS required for: '+realm
    MESSAGE,prefix[0]+' Authentication Error: "'+url[0]+'"',/CONTINUE,/INFORMATION
    GOTO,CLOSE_SERVER
  ENDIF
  ;;  Check temporary redirect status
  IF (url_info.STATUS_CODE[0] EQ 302) THEN BEGIN
    ;;  Temporary redirect  (typically caused by user not logged into wi-fi)
    MESSAGE,'Temporary redirect. Have you logged into WiFi yet?  "'+url+'"',/CONTINUE,/INFORMATION
    GOTO,CLOSE_SERVER
  ENDIF 
  ;;  Check permanent redirect status
  IF (url_info.STATUS_CODE[0] EQ 301) THEN BEGIN
    ;;  Permanent redirect  (typically caused by server no longer supplying the files)
    location = get_http_3dp_lz_header_element(header,'Location:')
    MESSAGE,'Permanent redirect to: '+location[0],/CONTINUE,/INFORMATION
    MESSAGE,'Request Aborted',/CONTINUE,/INFORMATION
    GOTO,CLOSE_SERVER
  ENDIF
  ;;  Check clocks
  IF (ABS(url_info.CLOCK_OFFSET[0]) GT 30) THEN BEGIN
    PRINT,print_pref[0],'Warning! Remote and local clocks differ by:',url_info.CLOCK_OFFSET[0],' Seconds'
  ENDIF
  ;;  Check modification status
  IF (url_info.STATUS_CODE[0] EQ 304) THEN BEGIN
    ;;  Not modified since.   Connection will be closed by the server.
    MESSAGE,'Remote file: '+newpathname[0]+' not modified since '+filemodtime[0],/CONTINUE,/INFORMATION
    GOTO,CLOSE_SERVER
  ENDIF
  ;;  Check good/bad status
  IF (url_info.STATUS_CODE[0] EQ 400) THEN BEGIN
    ;;  Bad Request
    url_info.EXISTS = 1b
    localname      += '.400'
  ENDIF
  ;;--------------------------------------------------------------------------------------
  ;;  Check if we should retrieve file
  ;;--------------------------------------------------------------------------------------
  IF (url_info.EXISTS[0]) THEN BEGIN
    tdiff    = (url_info.MTIME - lcl.MTIME)  ;;  seconds old
    MB       = 2e0^20e0
    IF (lcl.exists[0]) THEN BEGIN
      download_file = 0
      PRINT,print_pref[0],'tdiff=',tdiff,' sec'
      IF (tdiff[0] GT 0) THEN BEGIN
        IF KEYWORD_SET(no_clobber) THEN PRINT,print_pref[0],tdiff[0]/24d0/36d2,localname[0],FORMAT="(a28,'Warning!  ',f0.1,' day old local file: ',a  )"
        download_file = 1
      ENDIF
      IF (lcl.SIZE NE url_info.SIZE) && (~KEYWORD_SET(ascii_mode)) THEN BEGIN
        ;;  not working with if-modified-since keyword in use
        IF KEYWORD_SET(no_clobber) THEN BEGIN
          mform = '(a28,"Warning! Different file sizes: Remote=",f0.3," MB, Local=",f0.3," MB file: ",a)'
          PRINT,print_pref[0],url_info.SIZE[0]/mb[0],lcl.SIZE[0]/mb[0],FILE_BASENAME(localname),FORMAT=mform
        ENDIF
        IF NOT KEYWORD_SET(ignore_filesize) THEN download_file = 1
      ENDIF
      IF KEYWORD_SET(no_clobber) then download_file=0
    ENDIF ELSE BEGIN     ;;  endof lcl.exists
      download_file  = 1b
      mform          = "(a28,'Found remote (',f0.3,' MB) file: ""',a,'""')"
      PRINT,print_pref[0],url_info.SIZE[0]/mb[0],url[0],FORMAT=mform
    ENDELSE
    ;;  Check download status from keywords
    IF KEYWORD_SET(no_download)    THEN download_file = 0
    IF KEYWORD_SET(force_download) THEN download_file = 1
    IF (url_info.STATUS_CODE[0] NE 200) THEN BEGIN
      MESSAGE,'Unknown status code: '+STRING(url_info.STATUS_CODE[0]),/CONTINUE,/INFORMATION
    ENDIF
    IF (download_file[0]) THEN BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  Download file
      ;;----------------------------------------------------------------------------------
      dirname   = FILE_DIRNAME(localname)
      ON_IOERROR,FILE_ERROR2            ;;  Jump to FILE_ERROR2 on error
      ;;----------------------------------------------------------------------------------
      ;;  Open link to file
      ;;----------------------------------------------------------------------------------
      OPENW,wunit,localname[0]+'.part',/GET_LUN
      ;;  Track system time
      ts      = SYSTIME(1)
      t0      = ts
      ;;  Assume non-text download
      maxb    = 2L^20    ;;  1 Megabyte default buffer size
      nb      = 0L
      b       = 0L
      messstr = ''
      WHILE (nb[0] LT url_info.SIZE[0]) DO BEGIN
        buffsize = maxb[0] <  (url_info.SIZE[0] - nb[0])
        aaa      = BYTARR(buffsize[0],/NOZERO)
        ;;  Start reading file
        READU,gunit,aaa
        WRITEU,wunit,aaa
        ;;  Increment buffer size value
        nb      += buffsize[0]
        t1       = SYSTIME(1)
        dt       = t1[0] - t0[0]
        b       += buffsize[0]
        percent  = 1e2*FLOAT(nb[0])/url_info.SIZE[0]             ;;  Percent complete
        IF ((dt[0] GT 1e0) AND (nb[0] LT url_info.SIZE[0])) THEN BEGIN
          ;;  Wait 10 seconds between updates.
          rate    = b[0]/mb[0]/dt[0]                                     ;;  Average download/transfer rate [MiB/s]
          del     = t1[0] - ts[0]                                        ;;  Currently elapsed time [s] of download/transfer
          eta     = (url_info.SIZE[0] - nb[0])/mb[0]/rate[0] + del[0]    ;;  Estimated remaining time [s] left for download/transfer
          mform   = '("  ",f5.1," %  (",f0.1,"/",f0.1," secs)  @ ",f0.2," MB/s  File: ",a)'
          messstr = STRING(percent[0],del[0],eta[0],rate[0],FILE_BASENAME(localname),/PRINT,FORMAT=mform)
          MESSAGE,messstr[0],/CONTINUE,/INFORMATION
          ;;  Update/Reset values
          t0      = t1[0]
          b       = 0L
        ENDIF
      ENDWHILE
      ;;  Update values
      t1       = SYSTIME(1)
      dt       = t1[0] - tstart[0]                                       ;;  Total ellapsed time [s] since start of routine
      dt1      = t1[0] - ts[0]                                           ;;  Total ellapsed time [s] since start of download/transfer
      wiposi   = STRPOS(localname[0],'/wind_3dp_pros') > 0L
      pfile    = STRMID(localname[0],wiposi[0])
      IF (wiposi[0] GT 0) THEN pfile = '~'+pfile[0]
      totdown  = DOUBLE(nb[0])/DOUBLE(mb[0])                             ;;  Total data downloaded/transfered [MiB]
      avgrate  = totdown[0]/dt1[0]                                       ;;  Average download/transfer rate [MiB/s]
      mform    = "('Downloaded ',f0.3,' MBytes at ',f0.1,' secs of run time @ ',f0.2,' MB/s  File: ""', a,'""' )"
      messstr  = STRING(totdown[0],dt[0],avgrate[0],pfile[0],/PRINT,FORMAT=mform)
;      messstr  = STRING(nb[0]/mb[0],dt[0],nb[0]/mb[0]/dt1[0],pfile[0],/PRINT,FORMAT=mform)
;      messstr  = STRING(nb[0]/mb[0],dt[0],nb[0]/mb[0]/dt1[0],localname[0],/PRINT,FORMAT=mform)
      MESSAGE,messstr[0],/CONTINUE,/INFORMATION
      ;;----------------------------------------------------------------------------------
      ;;  Close Link
      ;;----------------------------------------------------------------------------------
      FREE_LUN,wunit
      ;;----------------------------------------------------------------------------------
      ;;  Overwrite file, if exists
      ;;----------------------------------------------------------------------------------
      FILE_MOVE,localname[0]+'.part',localname[0],/OVERWRITE
      ;;----------------------------------------------------------------------------------
      ;;  Error loop
      ;;----------------------------------------------------------------------------------
      IF 0 THEN BEGIN
        ;;================================================================================
        FILE_ERROR2:
        ;;================================================================================
        MESSAGE,'Error downloading file: "'+url+'"',/CONTINUE,/INFORMATION
        error = !ERROR_STATE.MSG
        MESSAGE,error,/CONTINUE,/INFORMATION
        IF KEYWORD_SET(wunit) THEN BEGIN
          ;;  Close temporary logical unit
          FREE_LUN, wunit
          max_arcs    = 99
          fi          = FILE_INFO(localname[0]+'.part')
          dir         = FILE_DIRNAME(fi.NAME)
          bname       = FILE_BASENAME(fi.NAME)
          archive_ext = '.error'
          arc_format  = dir[0]+bname[0]+archive_ext[0]
          arc_names   = FILE_SEARCH(arc_format[0]+'*',COUNT=n_arc)
          IF (n_arc[0] NE 0) THEN BEGIN
             arc_nums = FIX(STRMID(arc_names,STRLEN(arc_format[0])))
             n_arc    = MAX(arc_nums) + 1
          ENDIF
          arc_name    = arc_format[0]+STRTRIM(n_arc[0] < max_arcs[0],2L)
          FILE_MOVE,fi.NAME,arc_name[0]
        ENDIF
      ENDIF
    ENDIF ELSE BEGIN     ;;  endof download_file
      wiposi   = STRPOS(localname[0],'/wind_data_dir') > 0L
      pfile    = STRMID(localname[0],wiposi[0])
      IF (wiposi[0] GT 0) THEN pfile = '~'+pfile[0]
      t1       = SYSTIME(1)
      dt       = t1[0] - tstart[0]
      plen     = STRLEN(pfile[0])
      slen     = STRLEN(wi3dp_server[0])
      pl_str   = STRTRIM(STRING(plen,FORMAT='(I)'),2L)
      sl_str   = STRTRIM(STRING(slen,FORMAT='(I)'),2L)
      mform    = "('Local file: ',a"+pl_str[0]+",' (Not downloaded): Server ',a"+sl_str[0]+",' left hanging at ',f0.1,' secs of run time')"
      messstr  = STRING(pfile[0],wi3dp_server[0],dt[0],/PRINT,FORMAT=mform)
      MESSAGE,messstr[0],/CONTINUE,/INFORMATION
;      MESSAGE,'Local file: "'+pfile[0]+'"  (Not downloaded).  Server '+wi3dp_server[0]+' left hanging',/CONTINUE,/INFORMATION
    ENDELSE
  ENDIF ELSE BEGIN
    MESSAGE,'Can not retrieve: "'+ url + '" '+header[0],/CONTINUE,/INFORMATION
    MESSAGE,'If file was expected, you should verify that your anti-virus software did not block the connection and add an exception for IDL, if necessary',/CONTINUE,/INFORMATION
  ENDELSE
  ;;--------------------------------------------------------------------------------------
  ;;  Close socket
  ;;--------------------------------------------------------------------------------------
  ;;======================================================================================
  CLOSE_SERVER:
  ;;======================================================================================
  FREE_LUN,gunit
  MESSAGE,'Closing server: '+wi3dp_server[0],/CONTINUE,/INFORMATION
ENDFOR         ;;  End of Year Loop
;;========================================================================================
FINAL:
;;========================================================================================
;;----------------------------------------------------------------------------------------
;;  Define output
;;----------------------------------------------------------------------------------------
find_local_3dp_lz_files,TDATE=tdate,TRANGE=trange,OUT_FILES=out_files
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END
