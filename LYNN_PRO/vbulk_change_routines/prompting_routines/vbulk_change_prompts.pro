;*****************************************************************************************
;
;  FUNCTION :   vbulk_change_check_result_prompt.pro
;  PURPOSE  :   This is a subroutine meant to clean up vbulk_change_prompts.pro by
;                 avoiding repetitive patterns for checking whether the user likes
;                 a new parameter result.
;
;  CALLED BY:   
;               vbulk_change_prompts.pro
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;               general_prompt_routine.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  Vbulk Change IDL Libraries
;
;  INPUT:
;               OLD_STR    :  Scalar [string] defining the old/current value of the
;                               relevant parameter being altered by
;                               vbulk_change_prompts.pro
;               NEW_STR    :  Scalar [string] defining the new value of the relevant
;                               parameter being altered by vbulk_change_prompts.pro
;               OLD_VAL    :  Scalar or [N]-element [numeric] array defining the
;                               old/current value of the relevant parameter being
;                               altered by vbulk_change_prompts.pro
;               NEW_VAL    :  Scalar or [N]-element [numeric] array defining the new
;                               value of the relevant parameter being altered
;                               by vbulk_change_prompts.pro
;
;  EXAMPLES:    
;               [calling sequence]
;               test = vbulk_change_check_result_prompt(old_str,new_str,old_val,new_val,$
;                                                      [,VAL_NAME=val_name]             $
;                                                      [,READ_OUT=read_out]             $
;                                                      [,VALUE_OUT=value_out]           $
;                                                      [,CHANGE=change]                 )
;
;  KEYWORDS:    
;               VAL_NAME   :  Scalar [string] defining the name of the associated scalar
;                               [Default = 'VAL']
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               ***  [all the following changed on output]  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               READ_OUT   :  Set to a named variable to return a string containing the
;                               last command line input.  This is used by the overhead
;                               routine to determine whether user left the program by
;                               quitting or if the program finished
;               VALUE_OUT  :  Set to a named variable to return the new value for the
;                               changed variable associated with the INPUT keyword.
;               CHANGE     :  Set to a named variable to return the logic setting that
;                               informs the calling routine whether to the user wishes
;                               to try to alter the parameter again
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [05/22/2017   v1.0.0]
;             2)  Continued to write routine
;                                                                   [05/23/2017   v1.0.0]
;             3)  Continued to write routine
;                                                                   [05/24/2017   v1.0.0]
;             4)  Continued to write routine
;                                                                   [07/21/2017   v1.0.0]
;             5)  Continued to write routine
;                                                                   [07/25/2017   v1.0.0]
;             6)  Continued to write routine
;                                                                   [07/27/2017   v1.0.0]
;             7)  Continued to write routine
;                                                                   [07/28/2017   v1.0.0]
;             8)  Fixed bug where routine would not prompt user for new input in
;                   main routine
;                                                                   [08/10/2017   v1.0.0]
;
;   NOTES:      
;               1)  See also:  general_prompt_routine.pro, beam_fit_prompts.pro
;
;  REFERENCES:  
;               NA
;
;   CREATED:  05/19/2017
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/10/2017   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************

FUNCTION vbulk_change_check_result_prompt,old_str,new_str,old_val,new_val,         $
                                          VAL_NAME=val_name,                       $
                                          READ_OUT=read_out,VALUE_OUT=value_out,   $
                                          CHANGE=change

;;----------------------------------------------------------------------------------------
;;  Constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Initialize outputs
read_out       = ''
value_out      = 0.
change         = 0b
;;  Dummy error messages
notstr_msg     = 'User must supply 4 inputs: 2 scalar strings and 2 associated numerical values...'
badfor1msg     = 'The [OLD,NEW]_VAL must be numeric and [OLD,NEW]_STR must be strings!'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
;;  Check for an input
test           = (N_ELEMENTS(old_str) EQ 0) OR (N_ELEMENTS(old_val) EQ 0) OR      $
                 (N_ELEMENTS(new_str) EQ 0) OR (N_ELEMENTS(new_val) EQ 0) OR      $
                 (N_PARAMS() NE 4)
IF (test[0]) THEN BEGIN
  MESSAGE,notstr_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check input types
testv          = (is_a_number(old_val,/NOMSSG) EQ 0) OR (is_a_number(new_val,/NOMSSG) EQ 0)
tests          = (SIZE(old_str,/TYPE) NE 7) OR (SIZE(new_str,/TYPE) NE 7)
test           = testv[0] OR tests[0]
IF (test[0]) THEN BEGIN
  MESSAGE,badfor1msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check VAL_NAME
test           = (N_ELEMENTS(val_name) EQ 0) OR (SIZE(val_name,/TYPE) NE 7)
IF (test[0]) THEN in_str = 'VAL' ELSE in_str = val_name[0]
;;----------------------------------------------------------------------------------------
;;  Define relevant parameters
;;----------------------------------------------------------------------------------------
old_val_str    = old_str[0]
new_val_str    = new_str[0]
pro_out        = ["The old/current "+in_str[0]+" is "+old_val_str[0]+".",$
                  "","The new "+in_str[0]+" is "+new_val_str[0]+".",     $
                  "","[Type 'q' to quit at any time]"]
str_out        = "Do you wish to use this new value of "+in_str[0]+" (y/n):  "
;;  Prompt user
WHILE (read_out[0] NE 'n' AND read_out[0] NE 'y' AND read_out[0] NE 'q') DO BEGIN
  read_out       = general_prompt_routine(STR_OUT=str_out,PRO_OUT=pro_out,FORM_OUT=7)
  IF (read_out[0] EQ 'debug') THEN STOP
ENDWHILE
;;----------------------------------------------------------------------------------------
;;  Check User response
;;----------------------------------------------------------------------------------------
;;  Check if user wishes to quit
IF (read_out[0] EQ 'q') THEN RETURN,1b
IF (read_out EQ 'y') THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Yes --> User wants to use new value
  ;;--------------------------------------------------------------------------------------
  value_out = new_val
ENDIF ELSE BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  No  --> User wants to use old/current setting
  ;;--------------------------------------------------------------------------------------
  ;;  Check if user wants to try again
  str_out        = "Do you wish to try to estimate or change "+in_str[0]+" again (y/n)?  "
  ;;  Set/Reset outputs
  read_out       = ''    ;;  output value of decision
  WHILE (read_out[0] NE 'n' AND read_out[0] NE 'y' AND read_out[0] NE 'q') DO BEGIN
    read_out       = general_prompt_routine(STR_OUT=str_out,FORM_OUT=7)
    IF (read_out[0] EQ 'debug') THEN STOP
  ENDWHILE
  ;;  Check if user wishes to quit
  IF (read_out[0] EQ 'q') THEN RETURN,1b
  IF (read_out[0] EQ 'y') THEN BEGIN
    ;;  Yes --> User does want to try again
    change         = 1b
    value_out      = old_val
  ENDIF ELSE BEGIN
    ;;  No  --> User does not want to try again
    value_out      = old_val
  ENDELSE
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,1b
END

;*****************************************************************************************
;
;  FUNCTION :   vbulk_change_scalar_prompt.pro
;  PURPOSE  :   This is a subroutine meant to clean up vbulk_change_prompts.pro by
;                 avoiding repetitive patterns for changing scalar values though a
;                 command line prompt.
;
;  CALLED BY:   
;               vbulk_change_prompts.pro
;               vbulk_change_3vec_prompt.pro
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               get_zeros_mins_maxs_type.pro
;               is_a_number.pro
;               convert_num_type.pro
;               general_prompt_routine.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  Vbulk Change IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               [calling sequence]
;               new_val = vbulk_change_3vec_prompt([,SCL_NAME=scl_name]        $
;                                [,SCL_UNITS=scl_units] [,UPPER_LIM=upper_lim] $
;                                [,LOWER_LIM=lower_lim] [,ABSOLUTE=absolute]   $
;                                [,STR_OUT=str_out] [,PRO_OUT=pro_out]         $
;                                [,ERRMSG=errmsg] [,FORM_OUT=form_out]         $
;                                [,READ_OUT=read_out] [,VALUE_OUT=value_out]   )
;
;  KEYWORDS:    
;               SCL_NAME   :  Scalar [string] defining the name of the associated scalar
;                               [Default = 'VAL']
;               SCL_UNITS  :  Scalar [string] defining the name/label for the units
;                               associated with SCL_NAME
;                               [Default = 'units']
;               UPPER_LIM  :  Scalar [numeric] defining the upper limit above which
;                               output values from the prompt will be treated as
;                               bad/invalid values, thus prompting a new request for a
;                               value
;                               [Default = Max value of type (FORM_OUT)]
;               LOWER_LIM  :  Scalar [numeric] defining the lower limit below which
;                               output values from the prompt will be treated as
;                               bad/invalid values, thus prompting a new request for a
;                               value
;                               [Default = 0d0 or Min value of type (FORM_OUT), depending on ABSOLUTE]
;               ABSOLUTE   :  If set, routine assumes that the upper and lower bounds
;                               should be tested with the absolute value operator
;                               applied to the output value from the prompting routine
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               ***   general_prompt_routine.pro keywords   ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               STR_OUT    :  Scalar [string] that tells the user what to enter at
;                               prompt
;                               [Default = "Enter a new value for VEC_NAME_j [VEC_UNITS] (format = XXXX.xxx):  "]
;               PRO_OUT    :  Scalar(or array) [string] containing instructions for
;                               input
;                               [Default = FALSE]
;               ERRMSG     :  Scalar(or array) [string] containing error messages the
;                               user wishes to print to screen
;                               [Default = FALSE]
;               FORM_OUT   :  Scalar [integer/long] defining the type code of the prompt
;                               input and output.  Let us define the following:
;                                    FPN = floating-point #
;                                    SP  = single-precision
;                                    DP  = double-precision
;                                    UI  = unsigned integer
;                                    SI  = signed integer
;                               Possible values include:
;                                  1  :  BYTE     [8-bit UI]
;                                  2  :  INT      [16-bit SI]
;                                  3  :  LONG     [32-bit SI]
;                                  4  :  FLOAT    [32-bit, SP, FPN]
;                                  5  :  DOUBLE   [64-bit, DP, FPN]
;                                  6  :  COMPLEX  [32-bit, SP, FPN for Real and Imaginary]
;                                  7  :  STRING   [0 to 2147483647 characters]
;                                  9  :  DCOMPLEX [64-bit, DP, FPN for Real and Imaginary]
;                                 12  :  UINT     [16-bit UI]
;                                 13  :  ULONG    [32-bit UI]
;                                 14  :  LONG64   [64-bit SI]
;                                 15  :  ULONG64  [64-bit UI]
;                               [Default = 5]
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               ***  [all the following changed on output]  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               READ_OUT   :  Set to a named variable to return a string containing the
;                               last command line input.  This is used by the overhead
;                               routine to determine whether user left the program by
;                               quitting or if the program finished
;               VALUE_OUT  :  Set to a named variable to return the new value for the
;                               changed variable associated with the INPUT keyword.
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [05/18/2017   v1.0.0]
;             2)  Continued to write routine
;                                                                   [05/19/2017   v1.0.0]
;             3)  Continued to write routine
;                                                                   [05/22/2017   v1.0.0]
;             4)  Continued to write routine
;                                                                   [05/23/2017   v1.0.0]
;             5)  Continued to write routine
;                                                                   [05/24/2017   v1.0.0]
;             6)  Continued to write routine
;                                                                   [07/21/2017   v1.0.0]
;             7)  Continued to write routine
;                                                                   [07/25/2017   v1.0.0]
;             8)  Continued to write routine
;                                                                   [07/27/2017   v1.0.0]
;             9)  Continued to write routine
;                                                                   [07/28/2017   v1.0.0]
;            10)  Fixed bug where routine would not prompt user for new input in
;                   main routine
;                                                                   [08/10/2017   v1.0.0]
;
;   NOTES:      
;               1)  See also:  general_prompt_routine.pro, beam_fit_prompts.pro
;
;  REFERENCES:  
;               NA
;
;   CREATED:  05/18/2017
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/10/2017   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************

FUNCTION vbulk_change_scalar_prompt,SCL_NAME=scl_name,SCL_UNITS=scl_units,         $
                                    UPPER_LIM=upper_lim,LOWER_LIM=lower_lim,       $
                                    ABSOLUTE=absolute,                             $  ;;  *** INPUT --> general usage keywords ***
                                    STR_OUT=str_out,PRO_OUT=pro_out,ERRMSG=errmsg, $
                                    FORM_OUT=form_out,                             $  ;;  *** INPUT --> general_prompt_routine.pro keywords ***
                                    READ_OUT=read_out,VALUE_OUT=value_out             ;;  ***  OUTPUT  ***

;;----------------------------------------------------------------------------------------
;;  Constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Initialize outputs
value_out      = 0.
;;  Define allowed types
all_type_str   = get_zeros_mins_maxs_type()     ;;  Get all type info for system
all_ok_type    = all_type_str.TYPES
all_ok_mins    = all_type_str.MINS
all_ok_maxs    = all_type_str.MAXS
;;  Define defaults
def_str_form   = "(format = "+["XXXX.xxx","XX","'aaaa'"]+")"
flt_like_typ   = [4L,5L,6L,9L]
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check SCL_NAME
test           = (N_ELEMENTS(scl_name) EQ 0) OR (SIZE(scl_name,/TYPE) NE 7)
IF (test[0]) THEN valname = 'VAL' ELSE valname = scl_name[0]
;;  Check SCL_UNITS
test           = (N_ELEMENTS(scl_units) EQ 0) OR (SIZE(scl_units,/TYPE) NE 7)
IF (test[0]) THEN units = 'units' ELSE units = scl_units[0]
;;  Check FORM_OUT
test           = (N_ELEMENTS(form_out) EQ 0) OR (is_a_number(form_out,/NOMSSG) EQ 0)
IF (test[0]) THEN fout = 5L ELSE fout = LONG(form_out[0])
;;  Check against okay formats
good           = WHERE(all_ok_type EQ fout[0],gd)
IF (gd[0] GT 0) THEN BEGIN
  ;;  okay input --> define defaults
  def_low        = all_ok_mins.(good[0])
  def_upp        = all_ok_maxs.(good[0])
ENDIF ELSE BEGIN
  fout           = 5L
  good           = WHERE(all_ok_type EQ fout[0],gd)
  def_low        = all_ok_mins.(good[0])
  def_upp        = all_ok_maxs.(good[0])
ENDELSE
;;  Logic:  TRUE = STRING type set
IF (fout[0] EQ 7) THEN str_on = 1b ELSE str_on = 0b
IF (str_on[0]) THEN BEGIN
  ;;  String format requested --> other keywords are not really relevant
  abs_on   = 0b
  lower    = ''
  upper    = ''
  str_form = def_str_form[2L]
ENDIF ELSE BEGIN
  ;;  Check ABSOLUTE
  test           = (N_ELEMENTS(absolute) GT 0) AND KEYWORD_SET(absolute)
  IF (test[0]) THEN abs_on = 1b ELSE abs_on = 0b
  ;;  Check UPPER_LIM
  test           = (N_ELEMENTS(upper_lim) EQ 0) OR (is_a_number(upper_lim,/NOMSSG) EQ 0)
  IF (test[0]) THEN BEGIN
    ;;  Use default bound for specific type
    upper = def_upp[0]
  ENDIF ELSE BEGIN
    ;;  Make sure user-defined upper limit has the correct type code
    temp  = convert_num_type(upper_lim[0],fout[0],/NO_ARRAY)
    test  = (SIZE(temp[0],/TYPE) NE fout[0])
    IF (test[0]) THEN upper = def_upp[0] ELSE upper = temp[0]
  ENDELSE
  ;;  Check LOWER_LIM
  test           = (N_ELEMENTS(lower_lim) EQ 0) OR (is_a_number(lower_lim,/NOMSSG) EQ 0)
  IF (test[0]) THEN BEGIN
    ;;  Use default bound for specific type
    IF (abs_on[0]) THEN BEGIN
      temp  = convert_num_type((0 > def_low[0]),fout[0],/NO_ARRAY)
      test  = (SIZE(temp[0],/TYPE) NE fout[0])
      IF (test[0]) THEN lower = def_low[0] ELSE lower = temp[0]
    ENDIF ELSE BEGIN
      lower = def_low[0]
    ENDELSE
  ENDIF ELSE BEGIN
    ;;  Make sure user-defined upper limit has the correct type code
    temp  = convert_num_type(lower_lim[0],fout[0],/NO_ARRAY)
    test  = (SIZE(temp[0],/TYPE) NE fout[0])
    IF (test[0]) THEN lower = def_low[0] ELSE lower = temp[0]
  ENDELSE
  ;;  Define format instructions in string form
  test  = (TOTAL(flt_like_typ EQ fout[0]) GT 0)
  IF (test[0]) THEN str_form = def_str_form[0L] ELSE str_form = def_str_form[1L]
ENDELSE
;;  Define default output strings for prompt lines
str_out0       = "Enter a new value for "+valname[0]+" ["+units[0]+"] "+str_form[0]+":  "
;;  Check STR_OUT
test           = (N_ELEMENTS(str_out) EQ 0) OR (SIZE(str_out,/TYPE) NE 7)
IF (test[0]) THEN str_outs = str_out0 ELSE str_outs = str_out[0]
;;----------------------------------------------------------------------------------------
;;  Define output
;;----------------------------------------------------------------------------------------
;; Output procedural information
info_out       = general_prompt_routine(PRO_OUT=pro_out,FORM_OUT=7)
;;  Initialize output value
IF (str_on[0]) THEN value_out = '' ELSE value_out = convert_num_type(0,fout[0],/NO_ARRAY)
true           = 1b
strout         = str_outs[0]
WHILE (true[0]) DO BEGIN
  ;;  Loop until conditions are satisfied
  val_out        = general_prompt_routine(STR_OUT=strout,FORM_OUT=fout[0])
  ;;  Need to check for strings so as to avoid impossible tests
  IF (str_on[0]) THEN BEGIN
    ;;  String output
    IF (val_out[0] EQ 'debug') THEN STOP  ;;  User wishes to debug
    true           = (val_out[0] EQ 'n' OR val_out[0] EQ 'y' OR val_out[0] EQ 'q')
  ENDIF ELSE BEGIN
    ;;  Assume numeric output
    IF (abs_on[0]) THEN val = ABS(val_out[0]) ELSE val = val_out[0]
    true           = (val[0] GT upper[0]) OR (val[0] LT lower[0])
  ENDELSE
ENDWHILE
value_out      = val_out[0]
;;  Define return value
new_val        = value_out[0]
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,new_val
END

;*****************************************************************************************
;
;  FUNCTION :   vbulk_change_3vec_prompt.pro
;  PURPOSE  :   This is a subroutine meant to clean up vbulk_change_prompts.pro by
;                 avoiding repetitive patterns for changing 3-vectors though a
;                 command line prompt.
;
;  CALLED BY:   
;               vbulk_change_prompts.pro
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               get_zeros_mins_maxs_type.pro
;               is_a_number.pro
;               convert_num_type.pro
;               vbulk_change_scalar_prompt.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  Vbulk Change IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               [calling sequence]
;               new_val = vbulk_change_3vec_prompt([,VEC_NAME=vec_name]        $
;                                [,VEC_UNITS=vec_units] [,UPPER_LIM=upper_lim] $
;                                [,LOWER_LIM=lower_lim] [,ABSOLUTE=absolute]   $
;                                [,STR_OUT=str_out] [,PRO_OUT=pro_out]         $
;                                [,ERRMSG=errmsg] [,FORM_OUT=form_out]         $
;                                [,READ_OUT=read_out] [,VALUE_OUT=value_out]   )
;
;  KEYWORDS:    
;               VEC_NAME   :  Scalar [string] defining the name of the associated vector
;                               [Default = 'VEC']
;               VEC_UNITS  :  Scalar [string] defining the name/label for the units
;                               associated with VEC_NAME
;                               [Default = 'units']
;               UPPER_LIM  :  Scalar [numeric] defining the upper limit above which
;                               output values from the prompt will be treated as
;                               bad/invalid values, thus prompting a new request for a
;                               value
;                               [Default = Max value of type (FORM_OUT)]
;               LOWER_LIM  :  Scalar [numeric] defining the lower limit below which
;                               output values from the prompt will be treated as
;                               bad/invalid values, thus prompting a new request for a
;                               value
;                               [Default = 0d0 or Min value of type (FORM_OUT), depending on ABSOLUTE]
;               ABSOLUTE   :  If set, routine assumes that the upper and lower bounds
;                               should be tested with the absolute value operator
;                               applied to the output value from the prompting routine
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               ***   general_prompt_routine.pro keywords   ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               STR_OUT    :  Scalar [string] that tells the user what to enter at
;                               prompt
;                               [Default = "Enter a new value for VEC_NAME_j [VEC_UNITS] (format = XXXX.xxx):  "]
;               PRO_OUT    :  Scalar(or array) [string] containing instructions for
;                               input
;                               [Default = FALSE]
;               ERRMSG     :  Scalar(or array) [string] containing error messages the
;                               user wishes to print to screen
;                               [Default = FALSE]
;               FORM_OUT   :  Scalar [integer/long] defining the type code of the prompt
;                               input and output.  Let us define the following:
;                                    FPN = floating-point #
;                                    SP  = single-precision
;                                    DP  = double-precision
;                                    UI  = unsigned integer
;                                    SI  = signed integer
;                               Possible values include:
;                                  1  :  BYTE     [8-bit UI]
;                                  2  :  INT      [16-bit SI]
;                                  3  :  LONG     [32-bit SI]
;                                  4  :  FLOAT    [32-bit, SP, FPN]
;                                  5  :  DOUBLE   [64-bit, DP, FPN]
;                                  6  :  COMPLEX  [32-bit, SP, FPN for Real and Imaginary]
;                                  7  :  STRING   [0 to 2147483647 characters]
;                                  9  :  DCOMPLEX [64-bit, DP, FPN for Real and Imaginary]
;                                 12  :  UINT     [16-bit UI]
;                                 13  :  ULONG    [32-bit UI]
;                                 14  :  LONG64   [64-bit SI]
;                                 15  :  ULONG64  [64-bit UI]
;                               [Default = 5]
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               ***  [all the following changed on output]  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               READ_OUT   :  Set to a named variable to return a string containing the
;                               last command line input.  This is used by the overhead
;                               routine to determine whether user left the program by
;                               quitting or if the program finished
;               VALUE_OUT  :  Set to a named variable to return the new value for the
;                               changed variable associated with the INPUT keyword.
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [05/18/2017   v1.0.0]
;             2)  Continued to write routine
;                                                                   [05/18/2017   v1.0.0]
;             3)  Continued to write routine
;                                                                   [05/19/2017   v1.0.0]
;             4)  Continued to write routine
;                                                                   [05/22/2017   v1.0.0]
;             5)  Continued to write routine
;                                                                   [05/23/2017   v1.0.0]
;             6)  Continued to write routine
;                                                                   [05/24/2017   v1.0.0]
;             7)  Continued to write routine
;                                                                   [07/21/2017   v1.0.0]
;             8)  Continued to write routine
;                                                                   [07/25/2017   v1.0.0]
;             9)  Continued to write routine
;                                                                   [07/27/2017   v1.0.0]
;            10)  Continued to write routine
;                                                                   [07/28/2017   v1.0.0]
;            11)  Fixed bug where routine would not prompt user for new input in
;                   main routine
;                                                                   [08/10/2017   v1.0.0]
;
;   NOTES:      
;               1)  See also:  general_prompt_routine.pro, beam_fit_prompts.pro
;
;  REFERENCES:  
;               NA
;
;   CREATED:  05/18/2017
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/10/2017   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************

FUNCTION vbulk_change_3vec_prompt,VEC_NAME=vec_name,VEC_UNITS=vec_units,         $
                                  UPPER_LIM=upper_lim,LOWER_LIM=lower_lim,       $
                                  ABSOLUTE=absolute,                             $  ;;  *** INPUT --> general usage keywords ***
                                  STR_OUT=str_out,PRO_OUT=pro_out,ERRMSG=errmsg, $
                                  FORM_OUT=form_out,                             $  ;;  *** INPUT --> general_prompt_routine.pro keywords ***
                                  READ_OUT=read_out,VALUE_OUT=value_out             ;;  ***  OUTPUT  ***

;;----------------------------------------------------------------------------------------
;;  Constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Initialize outputs
value_out      = 0.
;;  Define allowed types
all_type_str   = get_zeros_mins_maxs_type()     ;;  Get all type info for system
;all_ok_type    = [1L,2L,3L,4L,5L,6L,7L,9L,12L,13L,14L,15L]
all_ok_type    = all_type_str.TYPES
all_ok_mins    = all_type_str.MINS
all_ok_maxs    = all_type_str.MAXS
;;  Define defaults
def_str_form   = "(format = "+["XXXX.xxx","XX","'aaaa'"]+")"
flt_like_typ   = [4L,5L,6L,9L]
;;  Define dummy values
vec_str        = ['x','y','z']
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check VEC_NAME
test           = (N_ELEMENTS(vec_name) EQ 0) OR (SIZE(vec_name,/TYPE) NE 7)
IF (test[0]) THEN valname = "VEC"+"_"+vec_str ELSE valname = vec_name[0]+"_"+vec_str
;;  Check VEC_UNITS
test           = (N_ELEMENTS(vec_units) EQ 0) OR (SIZE(vec_units,/TYPE) NE 7)
IF (test[0]) THEN units = 'units' ELSE units = vec_units[0]
;;  Check FORM_OUT
test           = (N_ELEMENTS(form_out) EQ 0) OR (is_a_number(form_out,/NOMSSG) EQ 0)
IF (test[0]) THEN fout = 5L ELSE fout = LONG(form_out[0])
;;  Check against okay formats
good           = WHERE(all_ok_type EQ fout[0],gd)
IF (gd[0] EQ 0) THEN fout = 5L
;;----------------------------------------------------------------------------------------
;;  Define output
;;----------------------------------------------------------------------------------------
;; Output procedural information (avoid repitition for each component)
info_out       = general_prompt_routine(PRO_OUT=pro_out,FORM_OUT=7)
;;  Loop through vector components
value_out      = MAKE_ARRAY(DIMENSION=3L,TYPE=fout[0])
FOR j=0L, 2L DO BEGIN
  sclname        = valname[j]
  temp           = vbulk_change_scalar_prompt(SCL_NAME=sclname[0],SCL_UNITS=units[0],  $
                                              UPPER_LIM=upper_lim,LOWER_LIM=lower_lim, $
                                              ABSOLUTE=absolute,STR_OUT=str_out,       $
                                              ERRMSG=errmsg,FORM_OUT=fout[0],          $
                                              READ_OUT=read_out,VALUE_OUT=val_out      )
  ;;  Check output format
  val            = convert_num_type(temp[0],fout[0],/NO_ARRAY)
  value_out[j]   = val[0]
ENDFOR
;;  Define return value
new_val        = REFORM(value_out,3L)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,new_val
END

;+
;*****************************************************************************************
;
;  PROCEDURE:   vbulk_change_prompts.pro
;  PURPOSE  :   This routine produces several prompts and return parameters for
;                 higher level calling routines that interactively ask for user input.
;
;  CALLED BY:   
;               vbulk_change_options.pro
;
;  INCLUDES:
;               vbulk_change_check_result_prompt.pro
;               vbulk_change_scalar_prompt.pro
;               vbulk_change_3vec_prompt.pro
;
;  CALLS:
;               get_os_slash.pro
;               vbulk_change_test_vdf_str_form.pro
;               vbulk_change_test_cont_str_form.pro
;               vbulk_change_get_default_struc.pro
;               vbulk_change_test_windn.pro
;               vbulk_change_test_plot_str_form.pro
;               struct_value.pro
;               mag__vec.pro
;               format_vector_string.pro
;               general_prompt_routine.pro
;               str_element.pro
;               general_cursor_select.pro
;               rot_matrix_array_dfs.pro
;               vbulk_change_3vec_prompt.pro
;               vbulk_change_check_result_prompt.pro
;               vbulk_change_scalar_prompt.pro
;               num2int_str.pro
;               test_file_path_format.pro
;               get_os_slash.pro
;               get_os_slash.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  Vbulk Change IDL Libraries
;
;  INPUT:
;               DAT        :  Scalar data structure containing a particle velocity
;                               distribution function (VDF) with the following
;                               structure tags:
;                                 VDF     :  [N]-Element [float/double] array defining
;                                              the VDF in units of phase space density
;                                              [i.e., # s^(+3) km^(-3) cm^(-3)]
;                                 VELXYZ  :  [N,3]-Element [float/double] array defining
;                                              the particle velocity 3-vectors for each
;                                              element of VDF
;                                              [km/s]
;
;  EXAMPLES:    
;               [calling sequence]
;               vbulk_change_prompts, dat [,/VFRAME] [,/VEC1] [,/VEC2] [,/VLIM]           $
;                                    [,/NLEV] [,/XNAME] [,/YNAME] [,/SM_CUTS] [,/SM_CONT] $
;                                    [,/NSMCUT] [,/NSMCON] [,/PLANE] [,/DFMIN] [,/DFMAX]  $
;                                    [,/DFRA] [,/V_0X] [,/V_0Y] [,/SAVE_DIR]              $
;                                    [,/FILE_PREF] [,/FILE_MIDF]                          $
;                                    [,CONT_STR=cont_str] [,WINDN=windn]                  $
;                                    [,PLOT_STR=plot_str] [,READ_OUT=read_out]            $
;                                    [,VALUE_OUT=value_out]
;
;  KEYWORDS:    
;               ***  INPUT --> Command to Change  ***
;               VFRAME     :  If set, routine prompts user to define a new value for
;                               the bulk flow velocity [km/s] reference frame, i.e.,
;                               this determines the location of the origin in the
;                               contour plots
;               VEC1       :  If set, routine prompts user to define a new value for
;                               the 3-vector used for "parallel" or "X" direction in
;                               the orthonormal basis used to plot the data
;                               [e.g. see rotate_and_triangulate_dfs.pro]
;               VEC2       :  If set, routine prompts user to define a new value for
;                               the 3-vector used as the second vector to construct
;                               the orthonormal basis used to plot the data.  The new
;                               The orthonormal basis is defined as the following:
;                                 X'  :  VEC1
;                                 Z'  :  (VEC1 x VEC2)
;                                 Y'  :  (VEC1 x VEC2) x VEC1
;               VLIM       :  If set, routine prompts user to define a new value for
;                               the maximum speed [km/s] to be shown in each plot
;               NLEV       :  If set, routine prompts user to define a new value for
;                               the number of contour levels to use
;               XNAME      :  If set, routine prompts user to define a new value for
;                               the string associated with VEC1
;               YNAME      :  If set, routine prompts user to define a new value for
;                               the string associated with VEC2
;               SM_CUTS    :  If set, routine prompts user to determine whether to
;                               smooth the 1D cuts before plotting
;               SM_CONT    :  If set, routine prompts user to determine whether to
;                               smooth the 2D contours before plotting
;               NSMCUT     :  If set, routine prompts user to define a new value for
;                               the number of points to use when smoothing the 1D cuts
;               NSMCON     :  If set, routine prompts user to define a new value for
;                               the number of points to use when smoothing the 2D
;                               contours
;               PLANE      :  If set, routine prompts user to define a new value for
;                               the plane of projection to plot with corresponding
;                               cuts [Let V1 = VEC1, V2 = VEC2]
;                                 'xy'  :  horizontal axis parallel to V1 and normal
;                                            vector to plane defined by (V1 x V2)
;                                 'xz'  :  horizontal axis parallel to (V1 x V2) and
;                                            vertical axis parallel to V1
;                                 'yz'  :  horizontal axis defined by (V1 x V2) x V1
;                                            and vertical axis (V1 x V2)
;               DFMIN      :  If set, routine prompts user to define a new value for
;                               the minimum allowable phase space density to show in
;                               any plot
;                               [# s^(+3) km^(-3) cm^(-3)]
;               DFMAX      :  If set, routine prompts user to define a new value for
;                               the maximum allowable phase space density to show in
;                               any plot
;                               [# s^(+3) km^(-3) cm^(-3)]
;               DFRA       :  If set, routine prompts user to define a new range for
;                                 the VDF plot range for both the 2D contour levels and
;                                 1D cut plots Y-Axis range
;                               [Default = [DFMIN,DFMAX]]
;               V_0X       :  If set, routine prompts user to define a new value for
;                               the velocity [km/s] along the X-Axis (horizontal) to
;                               shift the location where the perpendicular (vertical)
;                               cut of the VDF will be performed (i.e., origin of
;                               vertical line)
;               V_0Y       :  If set, routine prompts user to define a new value for
;                               the velocity [km/s] along the Y-Axis (vertical) to shift
;                               the location where the parallel (horizontal) cut of the
;                               VDF will be performed (i.e., origin of horizontal line)
;               SAVE_DIR   :  If set, routine prompts user to define a new value for
;                               the directory where the plots will be stored
;               FILE_PREF  :  If set, routine prompts user to define a new value for
;                               the file prefix associated with the PostScript plot
;                               on output
;               FILE_MIDF  :  If set, routine prompts user to define a new value for
;                               the middle part of the file name associated with the
;                               plane of projection and number of contour levels
;               CHECK_OFF  :  If set, routine will not call the checking routine
;                               vbulk_change_check_result_prompt.pro
;                               [Default = FALSE]
;               ***  INPUT --> Contour Plot  ***
;               CONT_STR   :  Scalar [structure] containing tags defining all of the
;                               current plot settings associated with all of the above
;                               "INPUT --> Command to Change" keywords
;               ***  INPUT --> System  ***
;               WINDN      :  Scalar [long] defining the index of the window to use when
;                               selecting the region of interest
;                               [Default = !D.WINDOW]
;               PLOT_STR   :  Scalar [structure] that defines the scaling factors for the
;                               contour plot shown in window WINDN to be used by
;                               general_cursor_select.pro
;               ***  OUTPUT  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               ***  [all the following changed on output]  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               READ_OUT   :  Set to a named variable to return a string containing the
;                               last command line input.  This is used by the overhead
;                               routine to determine whether user left the program by
;                               quitting or if the program finished
;               VALUE_OUT  :  Set to a named variable to return the new value for the
;                               changed variable associated with the INPUT keyword.
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [05/17/2017   v1.0.0]
;             2)  Continued to write routine
;                                                                   [05/18/2017   v1.0.0]
;             3)  Continued to write routine
;                                                                   [05/18/2017   v1.0.0]
;             4)  Continued to write routine
;                                                                   [05/18/2017   v1.0.0]
;             5)  Continued to write routine
;                                                                   [05/19/2017   v1.0.0]
;             6)  Continued to write routine
;                                                                   [05/22/2017   v1.0.0]
;             7)  Continued to write routine
;                                                                   [05/23/2017   v1.0.0]
;             8)  Continued to write routine
;                                                                   [05/24/2017   v1.0.0]
;             9)  Continued to write routine
;                                                                   [07/21/2017   v1.0.0]
;            10)  Continued to write routine
;                                                                   [07/25/2017   v1.0.0]
;            11)  Continued to write routine
;                                                                   [07/27/2017   v1.0.0]
;            12)  Continued to write routine
;                                                                   [07/28/2017   v1.0.0]
;            11)  Fixed bug where routine would not prompt user for new input for
;                   SM_CONT and SM_CUTS
;                                                                   [08/10/2017   v1.0.1]
;            12)  Added keyword:  CHECK_OFF
;                   and updated Man page
;                                                                   [04/10/2019   v1.0.2]
;
;   NOTES:      
;               1)  For more information about many of the keywords, see
;                     general_vdf_contour_plot.pro or contour_3d_1plane.pro, etc.
;               2)  User should NOT call this routine
;               3)  VDF = particle velocity distribution function
;               4)  phase space density = [# cm^(-3) km^(-3) s^(3)]
;               5)  *** Routine can only handle ONE INPUT keyword set at a time ***
;               6)  Routine will NOT alter DAT
;
;  REFERENCES:  
;               1)  Carlson et al., "An instrument for rapidly measuring plasma
;                      distribution functions with high resolution," Adv. Space Res. 2,
;                      pp. 67-70, 1983.
;               2)  Curtis et al., "On-board data analysis techniques for space plasma
;                      particle instruments," Rev. Sci. Inst. 60, pp. 372, 1989.
;               3)  Lin et al., "A three-dimensional plasma and energetic particle
;                      investigation for the Wind spacecraft," Space Sci. Rev. 71,
;                      pp. 125, 1995.
;               4)  Paschmann, G. and P.W. Daly "Analysis Methods for Multi-Spacecraft
;                      Data," ISSI Scientific Report, Noordwijk, The Netherlands.,
;                      Int. Space Sci. Inst., 1998.
;               5)  McFadden, J.P., C.W. Carlson, D. Larson, M. Ludlam, R. Abiad,
;                      B. Elliot, P. Turin, M. Marckwordt, and V. Angelopoulos
;                      "The THEMIS ESA Plasma Instrument and In-flight Calibration,"
;                      Space Sci. Rev. 141, pp. 277-302, 2008.
;               6)  McFadden, J.P., C.W. Carlson, D. Larson, J.W. Bonnell,
;                      F.S. Mozer, V. Angelopoulos, K.-H. Glassmeier, U. Auster
;                      "THEMIS ESA First Science Results and Performance Issues,"
;                      Space Sci. Rev. 141, pp. 477-508, 2008.
;               7)  Auster, H.U., K.-H. Glassmeier, W. Magnes, O. Aydogar, W. Baumjohann,
;                      D. Constantinescu, D. Fischer, K.H. Fornacon, E. Georgescu,
;                      P. Harvey, O. Hillenmaier, R. Kroth, M. Ludlam, Y. Narita,
;                      R. Nakamura, K. Okrafka, F. Plaschke, I. Richter, H. Schwarzl,
;                      B. Stoll, A. Valavanoglou, and M. Wiedemann "The THEMIS Fluxgate
;                      Magnetometer," Space Sci. Rev. 141, pp. 235-264, 2008.
;               8)  Angelopoulos, V. "The THEMIS Mission," Space Sci. Rev. 141,
;                      pp. 5-34, (2008).
;               9)  Wilson III, L.B., et al., "Quantified energy dissipation rates in the
;                      terrestrial bow shock: 1. Analysis techniques and methodology,"
;                      J. Geophys. Res. 119, pp. 6455--6474, doi:10.1002/2014JA019929,
;                      2014a.
;              10)  Wilson III, L.B., et al., "Quantified energy dissipation rates in the
;                      terrestrial bow shock: 2. Waves and dissipation,"
;                      J. Geophys. Res. 119, pp. 6475--6495, doi:10.1002/2014JA019930,
;                      2014b.
;              11)  Pollock, C., et al., "Fast Plasma Investigation for Magnetospheric
;                      Multiscale," Space Sci. Rev. 199, pp. 331--406,
;                      doi:10.1007/s11214-016-0245-4, 2016.
;              12)  Gershman, D.J., et al., "The calculation of moment uncertainties
;                      from velocity distribution functions with random errors,"
;                      J. Geophys. Res. 120, pp. 6633--6645, doi:10.1002/2014JA020775,
;                      2015.
;              13)  Bordini, F. "Channel electron multiplier efficiency for 10-1000 eV
;                      electrons," Nucl. Inst. & Meth. 97, pp. 405--408,
;                      doi:10.1016/0029-554X(71)90300-4, 1971.
;              14)  Meeks, C. and P.B. Siegel "Dead time correction via the time series,"
;                      Amer. J. Phys. 76, pp. 589--590, doi:10.1119/1.2870432, 2008.
;              15)  Furuya, K. and Y. Hatano "Pulse-height distribution of output signals
;                      in positive ion detection by a microchannel plate,"
;                      Int. J. Mass Spectrom. 218, pp. 237--243,
;                      doi:10.1016/S1387-3806(02)00725-X, 2002.
;              16)  Funsten, H.O., et al., "Absolute detection efficiency of space-based
;                      ion mass spectrometers and neutral atom imagers,"
;                      Rev. Sci. Inst. 76, pp. 053301, doi:10.1063/1.1889465, 2005.
;              17)  Oberheide, J., et al., "New results on the absolute ion detection
;                      efficiencies of a microchannel plate," Meas. Sci. Technol. 8,
;                      pp. 351--354, doi:10.1088/0957-0233/8/4/001, 1997.
;
;   ADAPTED FROM:  beam_fit_prompts.pro [UMN 3DP library, beam fitting routines]
;   CREATED:  05/16/2017
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/10/2019   v1.0.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO vbulk_change_prompts,dat,_EXTRA=ex_str,                             $  ;;  ***  INPUT --> Command to Change  ***
                         CHECK_OFF=check_off,                           $
                         CONT_STR=cont_str0,                            $  ;;  ***  INPUT --> Contour Plot  ***
                         WINDN=windn,PLOT_STR=plot_str0,                $  ;;  ***  INPUT --> System  ***
                         READ_OUT=read_out,VALUE_OUT=value_out             ;;  ***  OUTPUT  ***

;;----------------------------------------------------------------------------------------
;;  Constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
c              = 2.9979245800d+08     ;;  Speed of light in vacuum [m/s]
ckm            = c[0]                 ;;  Speed of light in vacuum [km/s]
ckm           *= 1d-3                 ;;  m --> km
;;  String constants
xyzvecf        = ['V1','V1xV2xV1','V1xV2']
def_xysuff     = xyzvecf[1]+'_vs_'+xyzvecf[0]+'_'  ;;  e.g., 'V1xV2xV1_vs_V1_'
def_xzsuff     = xyzvecf[0]+'_vs_'+xyzvecf[2]+'_'  ;;  e.g., 'V1_vs_V1xV2_'
def_yzsuff     = xyzvecf[2]+'_vs_'+xyzvecf[1]+'_'  ;;  e.g., 'V1xV2_vs_V1xV2xV1_'
def_suffix     = [def_xysuff[0],def_xzsuff[0],def_yzsuff[0]]
;;  Define required tags
def_dat_tags   = ['vdf','velxyz']
def_con_tags   = ['vframe','vec1','vec2','vlim','nlev','xname','yname','sm_cuts','sm_cont',$
                  'nsmcut','nsmcon','plane','dfmin','dfmax','dfra','v_0x','v_0y',          $
                  'save_dir','file_pref','file_midf']
;;  Define the current working directory character
;;    e.g., './' [for unix and linux] otherwise guess './' or '.\'
slash          = get_os_slash()                    ;;  '/' for Unix-like, '\' for Windows
vers           = !VERSION.OS_FAMILY                ;;  e.g., 'unix'
vern           = !VERSION.RELEASE                  ;;  e.g., '7.1.1'
test           = (vern[0] GE '6.0')
IF (test[0]) THEN cwd_char = FILE_DIRNAME('',/MARK_DIRECTORY) ELSE cwd_char = '.'+slash[0]
;;  Initialize outputs
value_out      = 0
read_out       = ''
def_win        = !D.WINDOW                        ;; default window #
;;  ***************************************************
;;  The following are from general_vdf_contour_plot.pro
;;  ***************************************************
;;  Position of contour plot [square]
;;                   Xo    Yo    X1    Y1
pos_0con       = [0.22941,0.515,0.77059,0.915]
;;  Position of 1st DF cuts [square]
pos_0cut       = [0.22941,0.050,0.77059,0.450]
;;  Dummy prompt messages
str_pre_c      = "Do you wish to keep the current value of "
str_pre_d      = "Do you wish to use the default value of "
;;  Dummy error messages
notstr_msg     = 'User must input DAT as a scalar IDL structure...'
notvdf_msg     = 'DAT must be a velocity distribution as an IDL structure...'
badstr_msg     = 'DAT must have the following structure tags:  VDF and VELXYZ'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = vbulk_change_test_vdf_str_form(dat)
IF (test[0] EQ 0) THEN RETURN
test           = vbulk_change_test_cont_str_form(cont_str0,DAT_OUT=cont_str)
IF (test[0] EQ 0 OR SIZE(cont_str,/TYPE) NE 8) THEN cont_str = vbulk_change_get_default_struc()
;;  Check CHECK_OFF
IF KEYWORD_SET(check_off) THEN checkon = 0b ELSE checkon = 1b
IF (checkon[0]) THEN checkoff = 0b ELSE checkoff = 1b
;;----------------------------------------------------------------------------------------
;;  Check ***  INPUT --> System  *** keywords
;;----------------------------------------------------------------------------------------
;;  Check WINDN
test           = vbulk_change_test_windn(windn,DAT_OUT=win)
IF (test[0] EQ 0) THEN RETURN
;;  Check PLOT_STR
;;    TRUE   -->  Allow use of general_cursor_select.pro routine
;;    FALSE  -->  Command-line input only
test_plt       = vbulk_change_test_plot_str_form(plot_str0,DAT_OUT=plot_str)
;;----------------------------------------------------------------------------------------
;;  DeFine some limits
;;----------------------------------------------------------------------------------------
str            = dat[0]
velxyz         = struct_value(str,'VELXYZ',INDEX=i_vel)         ;;  [N,3]-Element [numeric] array of 3-vector velocities [km/s]
velmag         = mag__vec(velxyz,/NAN)                          ;;  [N]-Element [numeric] array of speeds [km/s]
vmag_max       = MAX(velmag,/NAN)                               ;;  Scalar [numeric] maximum speed of VDF [km/s]
min_vfac       = 10d-2                                          ;;  Limit VLIM estimates to ≥ 10% of MAX(ABS(DAT.VELXYZ))
max_vfac       = 85d-2                                          ;;  Limit VFRAME estimates to ≤ 85% of MAX(ABS(DAT.VELXYZ))
vmag_85_max    = max_vfac[0]*vmag_max[0]                        ;;  85% of |V|_max
vmag_10_min    = min_vfac[0]*vmag_max[0]
;;  Convert results to strings
vmax_85_str    = STRTRIM(STRING(vmag_85_max[0],FORMAT='(f25.2)'),2L)
vmax_10_str    = STRTRIM(STRING(vmag_10_min[0],FORMAT='(f25.2)'),2L)
;;----------------------------------------------------------------------------------------
;;  Determine what, if anything, user wants to change
;;----------------------------------------------------------------------------------------
test_ex        = (SIZE(ex_str,/TYPE) NE 8)
IF (test_ex[0]) THEN BEGIN
  ;;  User does not wish to change anything
ENDIF ELSE BEGIN
  tags           = STRLOWCASE(TAG_NAMES(ex_str[0]))
  nt             = N_ELEMENTS(tags)
  IF (nt[0] GT 1) THEN BEGIN
    true           = 1b
    tt             = 0L
    goodt          = REPLICATE(0b,nt[0])
    FOR tt=0L, nt[0] - 1L DO BEGIN
      temp0          = struct_value(ex_str,tags[tt[0]],INDEX=tind0)
      temp1          = struct_value(cont_str,tags[tt[0]],INDEX=tind1)
      true           = (tind0[0] GE 0) AND (tind1[0] GE 0) AND KEYWORD_SET(temp0[0])
      goodt[tt]      = true[0]
    ENDFOR
    good           = WHERE(goodt,gd)
    IF (gd EQ 0) THEN gtags = '' ELSE gtags = tags[good[0]]
  ENDIF ELSE BEGIN
    gtags = tags[0]
  ENDELSE
  in_str         = STRLOWCASE(gtags[0])
  ;;  Define value of current setting
  old_val        = struct_value(cont_str,gtags[0],INDEX=ind)
  ;;  Set/Reset outputs
  read_out       = ''    ;; output value of decision
  value_out      = 0     ;; output value for prompt
  CASE gtags[0] OF
    'vframe'    : BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  VFRAME
      ;;----------------------------------------------------------------------------------
      units          = 'km/s'
      test           = (TOTAL(ABS(old_val),/NAN) NE 0)
      IF (test[0]) THEN str_pre = str_pre_c[0]+in_str[0] ELSE str_pre = str_pre_d[0]+in_str[0]
      ;;  Convert old value to string
      def_val_str    = (format_vector_string(old_val,PRECISION=3))[0];+" "+units[0]
      str_out        = str_pre[0]+" = "+def_val_str[0]+" ["+units[0]+"]? (y/n):  "
      pro_out        = ["     You can estimate a new "+in_str[0]+" using the command line, or",$
                        "use the cursor.  The end result will be used as the new bulk",        $
                        "flow velocity that defines the Lorentz transformation from",          $
                        "the K-frame (e.g., spacecraft frame) to the K'-frame (e.g.,",         $
                        "plasma rest frame).  The VDF will be re-plotted after user",          $
                        "is satisfied with the new "+in_str[0]+" estimate.","",                $
                        "[Type 'q' to quit at any time]"]
      ;;  Set/Reset outputs
      read_out       = ''    ;;  output value of decision
      WHILE (read_out[0] NE 'n' AND read_out[0] NE 'y' AND read_out[0] NE 'q') DO BEGIN
        read_out       = general_prompt_routine(STR_OUT=str_out,PRO_OUT=pro_out,FORM_OUT=7)
        IF (read_out[0] EQ 'debug') THEN STOP
      ENDWHILE
      ;;  Check if user wishes to quit
      IF (read_out[0] EQ 'q') THEN GOTO,JUMP_RETURN
      ;;  Set/Reset outputs
      value_out      = 0.    ;; output value for prompt
      IF (read_out[0] EQ 'n') THEN BEGIN
        ;;********************************************************************************
        ;;  User wishes to change bulk flow velocity estimate
        ;;********************************************************************************
        ;;    --> Set/Reset outputs
        read_out       = ''    ;; output value of decision
        str_out        = "Do you want to enter a new estimate for "+in_str[0]+" by command line (y/n)?  "
        WHILE (read_out[0] NE 'n' AND read_out[0] NE 'y' AND read_out[0] NE 'q') DO BEGIN
          read_out       = general_prompt_routine(STR_OUT=str_out,FORM_OUT=7)
          IF (read_out[0] EQ 'debug') THEN STOP
        ENDWHILE
        ;;  Check if user wishes to quit
        IF (read_out[0] EQ 'q') THEN GOTO,JUMP_RETURN
        ;;  Determine response
        use_command    = 1b
        IF (read_out[0] EQ 'n') THEN BEGIN
          ;;##############################################################################
          ;;  User wants to use cursor
          ;;##############################################################################
          read_out       = ''    ;; output value of decision
          ;;  Check if user can use cursor
          IF (test_plt[0]) THEN use_cursor = 1b ELSE use_cursor = 0b
          ;; Define string outputs for cursor usage
          cur_out        = ["     Select a point on the contour plot at the center of the",    $
                            "'core' peak region of the VDF.  The routine will ask you if",     $
                            "you like your estimate and, if not, allow you to try again.",     $
                            "The routine will then convert the two coordinate values into",    $
                            "GSE velocity components for the Lorentz transformation.  The",    $
                            "new VFRAME 3-vector will be used as the new rest frame velocity", $
                            "in which to plot the VDF.","","*** Note that you should try to",  $
                            "get as close as possible to the center of the peak for the best", $
                            "results. ***"]
          IF (use_cursor[0]) THEN BEGIN
            ;;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            ;;  Use the cursor
            ;;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            use_command    = 0b  ;;  shut off command line test
            ;;  Inform user of cursor procedure
            info_out       = general_prompt_routine(PRO_OUT=cur_out,FORM_OUT=7)
            ;;  Define dummy versions of !X and !Y for general_cursor_select.pro
            xysys_tags     = ['RANGE','CRANGE','S','WINDOW','REGION']
            dumb2f         = REPLICATE(0e0,2L)
            dumb2d         = REPLICATE(0d0,2L)
            dumb_x         = CREATE_STRUCT(xysys_tags,dumb2d,dumb2d,dumb2d,dumb2f,dumb2f)
            dumb_y         = dumb_x
            d_vxvy         = [!D.X_VSIZE[0],!D.Y_VSIZE[0]]
            ch_xyd         = [!D.X_CH_SIZE[0],!D.Y_CH_SIZE[0]]
            xmarg          = !X.MARGIN
            ymarg          = !Y.MARGIN
            xwinn          = pos_0con[[0,2]]
            ywinn          = pos_0con[[1,3]]
            xregn          = FLOAT(xwinn - [1,-1]*(xmarg*ch_xyd[0]/d_vxvy[0]))
            yregn          = FLOAT(ywinn - [1,-1]*(ymarg*ch_xyd[1]/d_vxvy[1]))
            vlim           = struct_value(cont_str,'vlim',INDEX=dind)
            IF (dind[0] LT 0) THEN STOP  ;;  Should not happen --> Debug!
            xyran          = [-1d0,1d0]*vlim[0]*1d-3     ;;  km  -->  Mm  [just looks better when plotted]
            ;;  Define plot scaling information
            xscale         = 1d0*plot_str.XSCALE
            yscale         = 1d0*plot_str.YSCALE
            xfact          = 1d0*plot_str.XFACT
            yfact          = 1d0*plot_str.YFACT
            ;;  Define tags for dummy versions of !X and !Y
            str_element,dumb_x,'CRANGE', xyran,/ADD_REPLACE
            str_element,dumb_x,     'S',xscale,/ADD_REPLACE
            str_element,dumb_x,'WINDOW', xwinn,/ADD_REPLACE
            str_element,dumb_x,'REGION', xregn,/ADD_REPLACE
            str_element,dumb_y,'CRANGE', xyran,/ADD_REPLACE
            str_element,dumb_y,     'S',yscale,/ADD_REPLACE
            str_element,dumb_y,'WINDOW', ywinn,/ADD_REPLACE
            str_element,dumb_y,'REGION', yregn,/ADD_REPLACE
            ;;  Define new VFRAME
            pk_struc       = general_cursor_select(XSCALE=xscale,YSCALE=yscale,WINDN=win[0],$
                                                   XFACT=xfact[0],YFACT=yfact[0],           $
                                                   XSYS=dumb_x,YSYS=dumb_y)
            IF (SIZE(pk_struc,/TYPE) NE 8) THEN BEGIN
              ;;--------------------------------------------------------------------------
              ;;  bad return --> Use command line input
              ;;--------------------------------------------------------------------------
              use_cursor     = 0b
              use_command    = 1b
            ENDIF ELSE BEGIN
              ;;--------------------------------------------------------------------------
              ;;  good return --> use cursor output
              ;;--------------------------------------------------------------------------
              ;;    --> Define an estimate for VFRAME
              vswx           = pk_struc.XY_DATA[0]
              vswy           = pk_struc.XY_DATA[1]
              plane          = struct_value(cont_str,'PLANE',INDEX=ind)
              ;;  Define center of core in plane of projection
              IF (plane[0] EQ 'xz') THEN gels = [2L,0L] ELSE gels = [0L,1L]
              v_oc           = DBLARR(3)
              v_oc[gels[0]]  = vswx[0]
              v_oc[gels[1]]  = vswy[0]
              ;;--------------------------------------------------------------------------
              ;;  Convert new Vbulk back into GSE and SCF
              ;;--------------------------------------------------------------------------
              vec1           = struct_value(cont_str,'VEC1',INDEX=ind1)
              vec2           = struct_value(cont_str,'VEC2',INDEX=ind2)
              v1             = REFORM(vec1,1,3)
              v2             = REFORM(vec2,1,3)
              IF (plane[0] EQ 'yz') THEN calrot = 0b ELSE calrot = 1b
              rmat           = rot_matrix_array_dfs(v1,v2,CAL_ROT=calrot[0])
              ;;  Define inverse
              inv_rmat       = LA_INVERT(REFORM(rmat,3,3),/DOUBLE,STATUS=status)
              IF (status NE 0) THEN BEGIN
                ;;  No inverse could be found --> BAD input
                bad_mssg = 'User must have finite non-zero vectors defined for tags VEC1 and VEC2!'
                MESSAGE,bad_mssg[0],/INFORMATIONAL,/CONTINUE
                RETURN
              ENDIF
              ;;  Rotate back into GSE coordinates in current bulk flow frame
              v_orc          = REFORM(inv_rmat ## v_oc)
              ;;  Translate back into SCF
              ;;    Define new Vbulk
              new_val        = v_orc + old_val
            ENDELSE
          ENDIF ELSE BEGIN
            ;;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            ;;  Error with windows --> use command line if user so desires
            ;;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            pro_out        = ["     You have not properly defined or opened a device window.",$
                              "Thus, you cannot use the cursor to select your new "+in_str[0]]
            str_out        = "Do you want to enter a new estimate for "+in_str[0]+" by command line (y/n)?  "
            WHILE (read_out[0] NE 'n' AND read_out[0] NE 'y' AND read_out[0] NE 'q') DO BEGIN
              read_out       = general_prompt_routine(STR_OUT=str_out,PRO_OUT=pro_out,FORM_OUT=7)
              IF (read_out[0] EQ 'debug') THEN STOP
            ENDWHILE
            ;;  Check if user wishes to quit
            IF (read_out[0] EQ 'q') THEN GOTO,JUMP_RETURN
            IF (read_out[0] EQ 'n') THEN BEGIN
              use_command = 0b
              ;;  Use old/current value
              new_val = old_val
            ENDIF
          ENDELSE
        ENDIF
        ;;  Check if user wants to use the command line
        IF (use_command[0]) THEN BEGIN
          ;;##############################################################################
          ;;  User wants to use command line
          ;;##############################################################################
          pro_out        = ["     You have chosen to enter a new estimate for "+in_str[0],   $
                            "on the command line.  You will be prompted to enter each",      $
                            "component separately.",                                         $
                            "Make sure to keep the values within the velocity limits",       $
                            "[i.e. ≤ "+vmax_85_str[0]+" "+units[0]+"] of the input data.",   $
                            "Then you will be prompted to check whether you agree",          $
                            "with this result.","",                                          $
                            "*** Remember to include the sign if the component is < 0. ***", $
                            "","[Type 'q' to quit at any time]"]
          ;;  Define new Vbulk
          new_val        = vbulk_change_3vec_prompt(VEC_NAME=in_str[0],VEC_UNITS=units[0],   $
                                                    UPPER_LIM=vmag_85_max[0],/ABSOLUTE,      $
                                                    PRO_OUT=pro_out,FORM_OUT=5L,             $
                                                    READ_OUT=read_out,VALUE_OUT=value_out)
        ENDIF
        ;;********************************************************************************
        ;;  Check if user likes the new result
        ;;********************************************************************************
        new_val_str    = (format_vector_string(new_val,PRECISION=3))[0]+" "+units[0]
        IF (checkon[0]) THEN BEGIN
          test           = vbulk_change_check_result_prompt(def_val_str[0],new_val_str[0],$
                                                            old_val,new_val,              $
                                                            VAL_NAME=in_str[0],           $
                                                            READ_OUT=read_out,            $
                                                            VALUE_OUT=value_out,          $
                                                            CHANGE=change                 )
        ENDIF ELSE BEGIN
          test      = 1b
          change    = 0b
          read_out  = ''
          value_out = new_val
        ENDELSE
        IF (~test[0]) THEN STOP   ;;  Something is wrong --> debug
        ;;  Check if user wishes to quit
        IF (read_out[0] EQ 'q') THEN GOTO,JUMP_RETURN
        ;;********************************************************************************
        ;;  Check if user wants to try and change the parameter again
        ;;********************************************************************************
        IF (read_out[0] EQ 'y' AND change[0]) THEN BEGIN
          ;;  Try again
          vbulk_change_prompts,dat,/VFRAME,CONT_STR=cont_str,WINDN=win,PLOT_STR=plot_str,$
                               READ_OUT=read_out,VALUE_OUT=value_out
          ;;  Exit
          RETURN
        ENDIF
      ENDIF ELSE BEGIN
        ;;********************************************************************************
        ;;  Keep current value
        ;;********************************************************************************
        new_val = old_val
      ENDELSE
      ;;-------------------------------------------
      ;;  Define output
      ;;-------------------------------------------
      value_out      = new_val
    END
    'vec1'      : BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  VEC1
      ;;----------------------------------------------------------------------------------
      units          = 'units'
      test           = (TOTAL(ABS(old_val),/NAN) NE 0)
      IF (test[0]) THEN str_pre = str_pre_c[0]+in_str[0] ELSE str_pre = str_pre_d[0]+in_str[0]
      ;;  Convert old value to string
      def_val_str    = (format_vector_string(old_val,PRECISION=3))[0];+" "+units[0]
      str_out        = str_pre[0]+" = "+def_val_str[0]+" ["+units[0]+"]? (y/n):  "
      ;;  Define informational instructions
      pro_out        = ["     You can estimate a new "+in_str[0]+" using the command line.",   $
                        "The end result will be used as the new 'parallel' direction in",      $
                        "the orthonormal coordinate basis constructed for plotting the",       $
                        "VDFs.  The VDF will be re-plotted after user is satisfied with",      $
                        "the new "+in_str[0]+" estimate.","",                                  $
                        "[Type 'q' to quit at any time]"]
      ;;  Set/Reset outputs
      read_out       = ''    ;;  output value of decision
      WHILE (read_out[0] NE 'n' AND read_out[0] NE 'y' AND read_out[0] NE 'q') DO BEGIN
        read_out       = general_prompt_routine(STR_OUT=str_out,PRO_OUT=pro_out,FORM_OUT=7)
        IF (read_out[0] EQ 'debug') THEN STOP
      ENDWHILE
      ;;  Check if user wishes to quit
      IF (read_out[0] EQ 'q') THEN GOTO,JUMP_RETURN
      ;;  Set/Reset outputs
      value_out      = 0.    ;; output value for prompt
      use_command    = 1b
      IF (read_out[0] EQ 'n') THEN BEGIN
        ;;********************************************************************************
        ;;  User wishes to change value
        ;;********************************************************************************
        IF (use_command[0]) THEN BEGIN
          ;;##############################################################################
          ;;  User wants to use command line
          ;;##############################################################################
          pro_out        = ["     You have chosen to enter a new estimate for "+in_str[0],   $
                            "on the command line.  You will be prompted to enter each",      $
                            "component separately.",                                         $
                            "Then you will be prompted to check whether you agree",          $
                            "with this result.","",                                          $
                            "*** Remember to include the sign if the component is < 0. ***", $
                            "","[Type 'q' to quit at any time]"]
          ;;  Define new Vbulk
          new_val        = vbulk_change_3vec_prompt(VEC_NAME=in_str[0],VEC_UNITS=units[0],   $
                                                    PRO_OUT=pro_out,FORM_OUT=5L,             $
                                                    READ_OUT=read_out,VALUE_OUT=value_out)
        ENDIF
        ;;********************************************************************************
        ;;  Check if user likes the new result
        ;;********************************************************************************
        new_val_str    = (format_vector_string(new_val,PRECISION=3))[0]+" "+units[0]
        IF (checkon[0]) THEN BEGIN
          test           = vbulk_change_check_result_prompt(def_val_str[0],new_val_str[0],$
                                                            old_val,new_val,              $
                                                            VAL_NAME=in_str[0],           $
                                                            READ_OUT=read_out,            $
                                                            VALUE_OUT=value_out,          $
                                                            CHANGE=change                 )
        ENDIF ELSE BEGIN
          test      = 1b
          change    = 0b
          read_out  = ''
          value_out = new_val
        ENDELSE
        IF (~test[0]) THEN STOP   ;;  Something is wrong --> debug
        ;;  Check if user wishes to quit
        IF (read_out[0] EQ 'q') THEN GOTO,JUMP_RETURN
        ;;********************************************************************************
        ;;  Check if user wants to try and change the parameter again
        ;;********************************************************************************
        IF (read_out[0] EQ 'y' AND change[0]) THEN BEGIN
          ;;  Try again
          vbulk_change_prompts,dat,/VEC1,CONT_STR=cont_str,WINDN=win,PLOT_STR=plot_str,$
                               READ_OUT=read_out,VALUE_OUT=value_out
          ;;  Exit
          RETURN
        ENDIF
      ENDIF ELSE BEGIN
        ;;********************************************************************************
        ;;  Keep current value
        ;;********************************************************************************
        use_command    = 0b
        new_val        = old_val
      ENDELSE
      ;;-------------------------------------------
      ;;  Define output
      ;;-------------------------------------------
      value_out      = new_val
    END
    'vec2'      : BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  VEC2
      ;;----------------------------------------------------------------------------------
      units          = 'units'
      test           = (TOTAL(ABS(old_val),/NAN) NE 0)
      IF (test[0]) THEN str_pre = str_pre_c[0]+in_str[0] ELSE str_pre = str_pre_d[0]+in_str[0]
      ;;  Convert old value to string
      def_val_str    = (format_vector_string(old_val,PRECISION=3))[0];+" "+units[0]
      str_out        = str_pre[0]+" = "+def_val_str[0]+" ["+units[0]+"]? (y/n):  "
      ;;  Define informational instructions
      pro_out        = ["     You can estimate a new "+in_str[0]+" using the command line.",   $
                        "The end result will be used as the 2nd vector direction used to",     $
                        "construct the orthonormal coordinate basis for plotting the",         $
                        "VDFs.  The VDF will be re-plotted after user is satisfied with",      $
                        "the new "+in_str[0]+" estimate.","",                                  $
                        "[Type 'q' to quit at any time]"]
      ;;  Set/Reset outputs
      read_out       = ''    ;;  output value of decision
      WHILE (read_out[0] NE 'n' AND read_out[0] NE 'y' AND read_out[0] NE 'q') DO BEGIN
        read_out       = general_prompt_routine(STR_OUT=str_out,PRO_OUT=pro_out,FORM_OUT=7)
        IF (read_out[0] EQ 'debug') THEN STOP
      ENDWHILE
      ;;  Check if user wishes to quit
      IF (read_out[0] EQ 'q') THEN GOTO,JUMP_RETURN
      ;;  Set/Reset outputs
      value_out      = 0.    ;; output value for prompt
      use_command    = 1b
      IF (read_out[0] EQ 'n') THEN BEGIN
        ;;********************************************************************************
        ;;  User wishes to change value
        ;;********************************************************************************
        IF (use_command[0]) THEN BEGIN
          ;;##############################################################################
          ;;  User wants to use command line
          ;;##############################################################################
          pro_out        = ["     You have chosen to enter a new estimate for "+in_str[0],   $
                            "on the command line.  You will be prompted to enter each",      $
                            "component separately.",                                         $
                            "Then you will be prompted to check whether you agree",          $
                            "with this result.","",                                          $
                            "*** Remember to include the sign if the component is < 0. ***", $
                            "","[Type 'q' to quit at any time]"]
          ;;  Define new Vbulk
          new_val        = vbulk_change_3vec_prompt(VEC_NAME=in_str[0],VEC_UNITS=units[0],   $
                                                    PRO_OUT=pro_out,FORM_OUT=5L,             $
                                                    READ_OUT=read_out,VALUE_OUT=value_out)
        ENDIF
        ;;********************************************************************************
        ;;  Check if user likes the new result
        ;;********************************************************************************
        new_val_str    = (format_vector_string(new_val,PRECISION=3))[0]+" "+units[0]
        IF (checkon[0]) THEN BEGIN
          test           = vbulk_change_check_result_prompt(def_val_str[0],new_val_str[0],$
                                                            old_val,new_val,              $
                                                            VAL_NAME=in_str[0],           $
                                                            READ_OUT=read_out,            $
                                                            VALUE_OUT=value_out,          $
                                                            CHANGE=change                 )
        ENDIF ELSE BEGIN
          test      = 1b
          change    = 0b
          read_out  = ''
          value_out = new_val
        ENDELSE
        IF (~test[0]) THEN STOP   ;;  Something is wrong --> debug
        ;;  Check if user wishes to quit
        IF (read_out[0] EQ 'q') THEN GOTO,JUMP_RETURN
        ;;********************************************************************************
        ;;  Check if user wants to try and change the parameter again
        ;;********************************************************************************
        IF (read_out[0] EQ 'y' AND change[0]) THEN BEGIN
          ;;  Try again
          vbulk_change_prompts,dat,/VEC2,CONT_STR=cont_str,WINDN=win,PLOT_STR=plot_str,$
                               READ_OUT=read_out,VALUE_OUT=value_out
          ;;  Exit
          RETURN
        ENDIF
      ENDIF ELSE BEGIN
        ;;********************************************************************************
        ;;  Keep current value
        ;;********************************************************************************
        new_val = old_val
      ENDELSE
      ;;-------------------------------------------
      ;;  Define output
      ;;-------------------------------------------
      value_out      = new_val
    END
    'vlim'      : BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  VLIM
      ;;----------------------------------------------------------------------------------
      ;;  Use vbulk_change_scalar_prompt.pro
      units          = 'km/s'
      test           = (TOTAL(ABS(old_val),/NAN) NE 0)
      IF (test[0]) THEN str_pre = str_pre_c[0]+in_str[0] ELSE str_pre = str_pre_d[0]+in_str[0]
      ;;  Convert old value to string
      def_val_str    = STRTRIM(STRING(old_val[0],FORMAT='(g15.3)'),2);+" "+units[0]
      str_out        = str_pre[0]+" = "+def_val_str[0]+" ["+units[0]+"]? (y/n):  "
      ;;  Define procedural information
      pro_out        = ["You can enter a new value for "+in_str[0]+" (format = XXXX.xxx).",$
                        "[Type 'q' to quit at any time]"]
      ;;  Set/Reset outputs
      read_out       = ''    ;;  output value of decision
      WHILE (read_out[0] NE 'n' AND read_out[0] NE 'y' AND read_out[0] NE 'q') DO BEGIN
        read_out       = general_prompt_routine(STR_OUT=str_out,PRO_OUT=pro_out,FORM_OUT=7)
        IF (read_out[0] EQ 'debug') THEN STOP
      ENDWHILE
      ;;  Check if user wishes to quit
      IF (read_out[0] EQ 'q') THEN GOTO,JUMP_RETURN
      ;;-------------------------------------------
      ;;  Prompt for new VLIM
      ;;-------------------------------------------
      value_out      = 0.    ;;  output value for prompt
      IF (read_out[0] EQ 'n') THEN BEGIN
        ;;********************************************************************************
        ;;  Select new value
        ;;********************************************************************************
        str_out        = "Enter a value > "+vmax_10_str[0]+" ["+units[0]+"] and < c [~300,000 km/s]:  "
        new_val        = vbulk_change_scalar_prompt(SCL_NAME=in_str[0],SCL_UNITS=units[0],    $
                                                    UPPER_LIM=ckm[0],LOWER_LIM=vmag_10_min[0],$
                                                    STR_OUT=str_out,FORM_OUT=5L,              $
                                                    READ_OUT=read_out,VALUE_OUT=value_out)
        ;;********************************************************************************
        ;;  Check if user likes the new result
        ;;********************************************************************************
        new_val_str    = STRTRIM(STRING(new_val[0],FORMAT='(g15.3)'),2)+" "+units[0]
        IF (checkon[0]) THEN BEGIN
          test           = vbulk_change_check_result_prompt(def_val_str[0],new_val_str[0],$
                                                            old_val,new_val,              $
                                                            VAL_NAME=in_str[0],           $
                                                            READ_OUT=read_out,            $
                                                            VALUE_OUT=value_out,          $
                                                            CHANGE=change                 )
        ENDIF ELSE BEGIN
          test      = 1b
          change    = 0b
          read_out  = ''
          value_out = new_val
        ENDELSE
        IF (~test[0]) THEN STOP   ;;  Something is wrong --> debug
        ;;  Check if user wishes to quit
        IF (read_out[0] EQ 'q') THEN GOTO,JUMP_RETURN
        ;;********************************************************************************
        ;;  Check if user wants to try and change the parameter again
        ;;********************************************************************************
        IF (read_out[0] EQ 'y' AND change[0]) THEN BEGIN
          ;;  Try again
          vbulk_change_prompts,dat,/VLIM,CONT_STR=cont_str,WINDN=win,PLOT_STR=plot_str,$
                               READ_OUT=read_out,VALUE_OUT=value_out
          ;;  Exit
          RETURN
        ENDIF
      ENDIF ELSE BEGIN
        ;;********************************************************************************
        ;;  Use current/default
        ;;********************************************************************************
        new_val = old_val[0]
      ENDELSE
      ;;-------------------------------------------
      ;;  Define output
      ;;-------------------------------------------
      value_out      = new_val
    END
    'nlev'      : BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  NLEV
      ;;----------------------------------------------------------------------------------
      units          = ' '
      test           = (TOTAL(ABS(old_val),/NAN) NE 0)
      IF (test[0]) THEN str_pre = str_pre_c[0]+in_str[0] ELSE str_pre = str_pre_d[0]+in_str[0]
      ;;  Convert old value to string
      def_val_str    = num2int_str(old_val[0]);+" "+units[0]
      str_out        = str_pre[0]+" = "+def_val_str[0]+" ["+units[0]+"]? (y/n):  "
      ;;  Set/Reset outputs
      read_out       = ''    ;;  output value of decision
      WHILE (read_out[0] NE 'n' AND read_out[0] NE 'y' AND read_out[0] NE 'q') DO BEGIN
        read_out       = general_prompt_routine(STR_OUT=str_out,FORM_OUT=7)
        IF (read_out[0] EQ 'debug') THEN STOP
      ENDWHILE
      ;;  Check if user wishes to quit
      IF (read_out[0] EQ 'q') THEN GOTO,JUMP_RETURN
      ;;-------------------------------------------
      ;;  Prompt for new NLEV
      ;;-------------------------------------------
      value_out      = 0L    ;;  output value for prompt
      IF (read_out[0] EQ 'n') THEN BEGIN
        ;;********************************************************************************
        ;;  Select new value
        ;;********************************************************************************
        str_out        = "Enter a new value for "+in_str[0]+" [satisfying: 15 < n < 80]:  "
        new_val        = vbulk_change_scalar_prompt(SCL_NAME=in_str[0],SCL_UNITS=units[0],  $
                                                    UPPER_LIM=80L,LOWER_LIM=15L,            $
                                                    STR_OUT=str_out,FORM_OUT=3L,            $
                                                    READ_OUT=read_out,VALUE_OUT=value_out)
        ;;********************************************************************************
        ;;  Check if user likes the new result
        ;;********************************************************************************
        new_val_str    = num2int_str(new_val[0])+" "+units[0]
        IF (checkon[0]) THEN BEGIN
          test           = vbulk_change_check_result_prompt(def_val_str[0],new_val_str[0],$
                                                            old_val,new_val,              $
                                                            VAL_NAME=in_str[0],           $
                                                            READ_OUT=read_out,            $
                                                            VALUE_OUT=value_out,          $
                                                            CHANGE=change                 )
        ENDIF ELSE BEGIN
          test      = 1b
          change    = 0b
          read_out  = ''
          value_out = new_val
        ENDELSE
        IF (~test[0]) THEN STOP   ;;  Something is wrong --> debug
        ;;  Check if user wishes to quit
        IF (read_out[0] EQ 'q') THEN GOTO,JUMP_RETURN
        ;;********************************************************************************
        ;;  Check if user wants to try and change the parameter again
        ;;********************************************************************************
        IF (read_out[0] EQ 'y' AND change[0]) THEN BEGIN
          ;;  Try again
          vbulk_change_prompts,dat,/NLEV,CONT_STR=cont_str,WINDN=win,PLOT_STR=plot_str,$
                               READ_OUT=read_out,VALUE_OUT=value_out
          ;;  Exit
          RETURN
        ENDIF
      ENDIF ELSE BEGIN
        ;;********************************************************************************
        ;;  Use current/default
        ;;********************************************************************************
        new_val = old_val[0]
      ENDELSE
      ;;-------------------------------------------
      ;;  Define output
      ;;-------------------------------------------
      value_out      = new_val
    END
    'xname'     : BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  XNAME
      ;;----------------------------------------------------------------------------------
      units          = ' '
      test           = (TOTAL(old_val EQ '') EQ 0)
      IF (test[0]) THEN str_pre = str_pre_c[0]+in_str[0] ELSE str_pre = str_pre_d[0]+in_str[0]
      ;;  Convert old value to string
      def_val_str    = old_val[0];+" "+units[0]
      str_out        = str_pre[0]+" = "+def_val_str[0]+" ["+units[0]+"]? (y/n):  "
      ;;  Set/Reset outputs
      read_out       = ''    ;;  output value of decision
      WHILE (read_out[0] NE 'n' AND read_out[0] NE 'y' AND read_out[0] NE 'q') DO BEGIN
        read_out       = general_prompt_routine(STR_OUT=str_out,FORM_OUT=7)
        IF (read_out[0] EQ 'debug') THEN STOP
      ENDWHILE
      ;;  Check if user wishes to quit
      IF (read_out[0] EQ 'q') THEN GOTO,JUMP_RETURN
      ;;-------------------------------------------
      ;;  Prompt for new NLEV
      ;;-------------------------------------------
      value_out      = ''    ;;  output value for prompt
      IF (read_out[0] EQ 'n') THEN BEGIN
        ;;********************************************************************************
        ;;  Select new value
        ;;********************************************************************************
        str_out        = "Enter a new string for "+in_str[0]+" (do not need ' ' on input):  "
        new_val        = vbulk_change_scalar_prompt(SCL_NAME=in_str[0],SCL_UNITS=units[0],  $
                                                    STR_OUT=str_out,FORM_OUT=7L,            $
                                                    READ_OUT=read_out,VALUE_OUT=value_out)
        ;;********************************************************************************
        ;;  Check if user likes the new result
        ;;********************************************************************************
        new_val_str    = new_val[0]+" "+units[0]
        IF (checkon[0]) THEN BEGIN
          test           = vbulk_change_check_result_prompt(def_val_str[0],new_val_str[0],$
                                                            1,2,                          $
                                                            VAL_NAME=in_str[0],           $
                                                            READ_OUT=read_out,            $
                                                            VALUE_OUT=value_out,          $
                                                            CHANGE=change                 )
        ENDIF ELSE BEGIN
          test      = 1b
          change    = 0b
          read_out  = ''
          value_out = 2
        ENDELSE
        IF (~test[0]) THEN STOP   ;;  Something is wrong --> debug
        ;;  Check if user wishes to quit
        IF (read_out[0] EQ 'q') THEN GOTO,JUMP_RETURN
        ;;********************************************************************************
        ;;  Check if user wants to try and change the parameter again
        ;;********************************************************************************
        IF (read_out[0] EQ 'y' AND change[0]) THEN BEGIN
          ;;  Try again
          vbulk_change_prompts,dat,/XNAME,CONT_STR=cont_str,WINDN=win,PLOT_STR=plot_str,$
                               READ_OUT=read_out,VALUE_OUT=value_out
          ;;  Exit
          RETURN
        ENDIF
      ENDIF ELSE BEGIN
        ;;********************************************************************************
        ;;  Use current/default
        ;;********************************************************************************
        new_val = old_val[0]
      ENDELSE
      ;;-------------------------------------------
      ;;  Define output
      ;;-------------------------------------------
      value_out      = new_val
    END
    'yname'     : BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  YNAME
      ;;----------------------------------------------------------------------------------
      units          = ' '
      test           = (TOTAL(old_val EQ '') EQ 0)
      IF (test[0]) THEN str_pre = str_pre_c[0]+in_str[0] ELSE str_pre = str_pre_d[0]+in_str[0]
      ;;  Convert old value to string
      def_val_str    = old_val[0];+" "+units[0]
      str_out        = str_pre[0]+" = "+def_val_str[0]+" ["+units[0]+"]? (y/n):  "
      ;;  Set/Reset outputs
      read_out       = ''    ;;  output value of decision
      WHILE (read_out[0] NE 'n' AND read_out[0] NE 'y' AND read_out[0] NE 'q') DO BEGIN
        read_out       = general_prompt_routine(STR_OUT=str_out,FORM_OUT=7)
        IF (read_out[0] EQ 'debug') THEN STOP
      ENDWHILE
      ;;  Check if user wishes to quit
      IF (read_out[0] EQ 'q') THEN GOTO,JUMP_RETURN
      ;;-------------------------------------------
      ;;  Prompt for new NLEV
      ;;-------------------------------------------
      value_out      = ''    ;;  output value for prompt
      IF (read_out[0] EQ 'n') THEN BEGIN
        ;;********************************************************************************
        ;;  Select new value
        ;;********************************************************************************
        str_out        = "Enter a new string for "+in_str[0]+" (do not need ' ' on input):  "
        new_val        = vbulk_change_scalar_prompt(SCL_NAME=in_str[0],SCL_UNITS=units[0],  $
                                                    STR_OUT=str_out,FORM_OUT=7L,            $
                                                    READ_OUT=read_out,VALUE_OUT=value_out)
        ;;********************************************************************************
        ;;  Check if user likes the new result
        ;;********************************************************************************
        new_val_str    = new_val[0]+" "+units[0]
        IF (checkon[0]) THEN BEGIN
          test           = vbulk_change_check_result_prompt(def_val_str[0],new_val_str[0],$
                                                            1,2,                          $
                                                            VAL_NAME=in_str[0],           $
                                                            READ_OUT=read_out,            $
                                                            VALUE_OUT=value_out,          $
                                                            CHANGE=change                 )
        ENDIF ELSE BEGIN
          test      = 1b
          change    = 0b
          read_out  = ''
          value_out = 2
        ENDELSE
        IF (~test[0]) THEN STOP   ;;  Something is wrong --> debug
        ;;  Check if user wishes to quit
        IF (read_out[0] EQ 'q') THEN GOTO,JUMP_RETURN
        ;;********************************************************************************
        ;;  Check if user wants to try and change the parameter again
        ;;********************************************************************************
        IF (read_out[0] EQ 'y' AND change[0]) THEN BEGIN
          ;;  Try again
          vbulk_change_prompts,dat,/YNAME,CONT_STR=cont_str,WINDN=win,PLOT_STR=plot_str,$
                               READ_OUT=read_out,VALUE_OUT=value_out
          ;;  Exit
          RETURN
        ENDIF
      ENDIF ELSE BEGIN
        ;;********************************************************************************
        ;;  Use current/default
        ;;********************************************************************************
        new_val = old_val[0]
      ENDELSE
      ;;-------------------------------------------
      ;;  Define output
      ;;-------------------------------------------
      value_out      = new_val
    END
    'sm_cuts'   : BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  SM_CUTS
      ;;----------------------------------------------------------------------------------
      units          = ' '
      test           = (TOTAL(ABS(old_val),/NAN) NE 0)
      IF (test[0]) THEN str_pre = str_pre_c[0]+in_str[0] ELSE str_pre = str_pre_d[0]+in_str[0]
      ;;  Convert old value to string
      def_val_str    = (['FALSE','TRUE'])[KEYWORD_SET(old_val[0])];+" "+units[0]
      str_out        = str_pre[0]+" = "+def_val_str[0]+" ["+units[0]+"]? (y/n):  "
      ;; Define string outputs for procedural information
      pro_out        = ["     You will now be asked if you wish to smooth the contour and",    $
                        "cuts of the particle velocity distribution functions (DFs).  I",      $
                        "recommend smoothing the cuts but not the contours any more than the", $
                        "minimum amount designated by SMOOTH.  The SM_CUTS keyword determines",$
                        "if the routines smooth the cuts and the SM_CONT keyword determines",  $
                        "if the routines smooth the contours.  The NSMOOTH defines the number",$
                        "of points to use in SMOOTH [Width parameter in routine] for each."    ]
      ;;  Set/Reset outputs
      read_out       = ''    ;;  output value of decision
      WHILE (read_out[0] NE 'n' AND read_out[0] NE 'y' AND read_out[0] NE 'q') DO BEGIN
        read_out       = general_prompt_routine(STR_OUT=str_out,PRO_OUT=pro_out,FORM_OUT=7)
        IF (read_out[0] EQ 'debug') THEN STOP
      ENDWHILE
      ;;  Check if user wishes to quit
      IF (read_out[0] EQ 'q') THEN GOTO,JUMP_RETURN
      ;;-------------------------------------------
      ;;  Prompt for new SM_CUTS
      ;;-------------------------------------------
      value_out      = 0B    ;;  output value for prompt
      IF (read_out[0] EQ 'n') THEN BEGIN
        ;;  Set/Reset outputs
        read_out       = ''    ;;  output value of decision
        ;;********************************************************************************
        ;;  Select new value
        ;;********************************************************************************
        str_out        = "Do you wish to smooth the cuts of the VDFs (y/n):  "
        WHILE (read_out[0] NE 'n' AND read_out[0] NE 'y' AND read_out[0] NE 'q') DO BEGIN
          read_out       = general_prompt_routine(STR_OUT=str_out,PRO_OUT=pro_out,FORM_OUT=7)
          IF (read_out[0] EQ 'debug') THEN STOP
        ENDWHILE
        ;;  Check if user wishes to quit
        IF (read_out[0] EQ 'q') THEN GOTO,JUMP_RETURN
        IF (read_out[0] EQ 'n') THEN new_val = 0b ELSE new_val = 1b
        ;;********************************************************************************
        ;;  Check if user likes the new result
        ;;********************************************************************************
        new_val_str    = (['FALSE','TRUE'])[KEYWORD_SET(new_val[0])]+" "+units[0]
        IF (checkon[0]) THEN BEGIN
          test           = vbulk_change_check_result_prompt(def_val_str[0],new_val_str[0],$
                                                            old_val,new_val,              $
                                                            VAL_NAME=in_str[0],           $
                                                            READ_OUT=read_out,            $
                                                            VALUE_OUT=value_out,          $
                                                            CHANGE=change                 )
        ENDIF ELSE BEGIN
          test      = 1b
          change    = 0b
          read_out  = ''
          value_out = new_val
        ENDELSE
        IF (~test[0]) THEN STOP   ;;  Something is wrong --> debug
        ;;  Check if user wishes to quit
        IF (read_out[0] EQ 'q') THEN GOTO,JUMP_RETURN
        ;;********************************************************************************
        ;;  Check if user wants to try and change the parameter again
        ;;********************************************************************************
        IF (read_out[0] EQ 'y' AND change[0]) THEN BEGIN
          ;;  Try again
          vbulk_change_prompts,dat,/SM_CUTS,CONT_STR=cont_str,WINDN=win,PLOT_STR=plot_str,$
                               READ_OUT=read_out,VALUE_OUT=value_out
          ;;  Exit
          RETURN
        ENDIF
      ENDIF ELSE BEGIN
        ;;********************************************************************************
        ;;  Use current/default
        ;;********************************************************************************
        new_val = old_val[0]
      ENDELSE
      ;;-------------------------------------------
      ;;  Define output
      ;;-------------------------------------------
      value_out      = new_val
    END
    'sm_cont'   : BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  SM_CONT
      ;;----------------------------------------------------------------------------------
      units          = ' '
      test           = (TOTAL(ABS(old_val),/NAN) NE 0)
      IF (test[0]) THEN str_pre = str_pre_c[0]+in_str[0] ELSE str_pre = str_pre_d[0]+in_str[0]
      ;;  Convert old value to string
      def_val_str    = (['FALSE','TRUE'])[KEYWORD_SET(old_val[0])];+" "+units[0]
      str_out        = str_pre[0]+" = "+def_val_str[0]+" ["+units[0]+"]? (y/n):  "
      ;; Define string outputs for procedural information
      pro_out        = ["     You will now be asked if you wish to smooth the contour and",    $
                        "cuts of the particle velocity distribution functions (DFs).  I",      $
                        "recommend smoothing the cuts but not the contours any more than the", $
                        "minimum amount designated by SMOOTH.  The SM_CUTS keyword determines",$
                        "if the routines smooth the cuts and the SM_CONT keyword determines",  $
                        "if the routines smooth the contours.  The NSMOOTH defines the number",$
                        "of points to use in SMOOTH [Width parameter in routine] for each."    ]
      ;;  Set/Reset outputs
      read_out       = ''    ;;  output value of decision
      WHILE (read_out[0] NE 'n' AND read_out[0] NE 'y' AND read_out[0] NE 'q') DO BEGIN
        read_out       = general_prompt_routine(STR_OUT=str_out,PRO_OUT=pro_out,FORM_OUT=7)
        IF (read_out[0] EQ 'debug') THEN STOP
      ENDWHILE
      ;;  Check if user wishes to quit
      IF (read_out[0] EQ 'q') THEN GOTO,JUMP_RETURN
      ;;-------------------------------------------
      ;;  Prompt for new SM_CONT
      ;;-------------------------------------------
      value_out      = 0B    ;;  output value for prompt
      IF (read_out[0] EQ 'n') THEN BEGIN
        ;;  Set/Reset outputs
        read_out       = ''    ;;  output value of decision
        ;;********************************************************************************
        ;;  Select new value
        ;;********************************************************************************
        str_out        = "Do you wish to smooth the contours of the VDFs (y/n):  "
        WHILE (read_out[0] NE 'n' AND read_out[0] NE 'y' AND read_out[0] NE 'q') DO BEGIN
          read_out       = general_prompt_routine(STR_OUT=str_out,PRO_OUT=pro_out,FORM_OUT=7)
          IF (read_out[0] EQ 'debug') THEN STOP
        ENDWHILE
        ;;  Check if user wishes to quit
        IF (read_out[0] EQ 'q') THEN GOTO,JUMP_RETURN
        IF (read_out[0] EQ 'n') THEN new_val = 0b ELSE new_val = 1b
        ;;********************************************************************************
        ;;  Check if user likes the new result
        ;;********************************************************************************
        new_val_str    = (['FALSE','TRUE'])[KEYWORD_SET(new_val[0])]+" "+units[0]
        IF (checkon[0]) THEN BEGIN
          test           = vbulk_change_check_result_prompt(def_val_str[0],new_val_str[0],$
                                                            old_val,new_val,              $
                                                            VAL_NAME=in_str[0],           $
                                                            READ_OUT=read_out,            $
                                                            VALUE_OUT=value_out,          $
                                                            CHANGE=change                 )
        ENDIF ELSE BEGIN
          test      = 1b
          change    = 0b
          read_out  = ''
          value_out = new_val
        ENDELSE
        IF (~test[0]) THEN STOP   ;;  Something is wrong --> debug
        ;;  Check if user wishes to quit
        IF (read_out[0] EQ 'q') THEN GOTO,JUMP_RETURN
        ;;********************************************************************************
        ;;  Check if user wants to try and change the parameter again
        ;;********************************************************************************
        IF (read_out[0] EQ 'y' AND change[0]) THEN BEGIN
          ;;  Try again
          vbulk_change_prompts,dat,/SM_CONT,CONT_STR=cont_str,WINDN=win,PLOT_STR=plot_str,$
                               READ_OUT=read_out,VALUE_OUT=value_out
          ;;  Exit
          RETURN
        ENDIF
      ENDIF ELSE BEGIN
        ;;********************************************************************************
        ;;  Use current/default
        ;;********************************************************************************
        new_val = old_val[0]
      ENDELSE
      ;;-------------------------------------------
      ;;  Define output
      ;;-------------------------------------------
      value_out      = new_val
    END
    'nsmcut'    : BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  NSMCUT
      ;;----------------------------------------------------------------------------------
      units          = ' '
      test           = (TOTAL(ABS(old_val),/NAN) NE 0)
      IF (test[0]) THEN str_pre = str_pre_c[0]+in_str[0] ELSE str_pre = str_pre_d[0]+in_str[0]
      ;;  Convert old value to string
      def_val_str    = num2int_str(old_val[0]);+" "+units[0]
      str_out        = str_pre[0]+" = "+def_val_str[0]+" ["+units[0]+"]? (y/n):  "
      ;; Define string outputs for procedural information
      pro_out        = ["     You will now be asked if you wish to smooth the contour and",    $
                        "cuts of the particle velocity distribution functions (DFs).  I",      $
                        "recommend smoothing the cuts but not the contours any more than the", $
                        "minimum amount designated by SMOOTH.  The SM_CUTS keyword determines",$
                        "if the routines smooth the cuts and the SM_CONT keyword determines",  $
                        "if the routines smooth the contours.  The NSMOOTH defines the number",$
                        "of points to use in SMOOTH [Width parameter in routine] for each."    ]
      ;;  Set/Reset outputs
      read_out       = ''    ;;  output value of decision
      WHILE (read_out[0] NE 'n' AND read_out[0] NE 'y' AND read_out[0] NE 'q') DO BEGIN
        read_out       = general_prompt_routine(STR_OUT=str_out,PRO_OUT=pro_out,FORM_OUT=7)
        IF (read_out[0] EQ 'debug') THEN STOP
      ENDWHILE
      ;;  Check if user wishes to quit
      IF (read_out[0] EQ 'q') THEN GOTO,JUMP_RETURN
      ;;-------------------------------------------
      ;;  Prompt for new NSMCUT
      ;;-------------------------------------------
      value_out      = 0L    ;;  output value for prompt
      IF (read_out[0] EQ 'n') THEN BEGIN
        ;;  Set/Reset outputs
        read_out       = ''    ;;  output value of decision
        ;;********************************************************************************
        ;;  Select new value
        ;;********************************************************************************
        str_out        = "Enter a new value for "+in_str[0]+" [satisfying: 2 < n < 10]:  "
        new_val        = vbulk_change_scalar_prompt(SCL_NAME=in_str[0],SCL_UNITS=units[0],  $
                                                    UPPER_LIM=10L,LOWER_LIM=2L,             $
                                                    STR_OUT=str_out,FORM_OUT=3L,            $
                                                    READ_OUT=read_out,VALUE_OUT=value_out)
        ;;********************************************************************************
        ;;  Check if user likes the new result
        ;;********************************************************************************
        new_val_str    = num2int_str(new_val[0])+" "+units[0]
        IF (checkon[0]) THEN BEGIN
          test           = vbulk_change_check_result_prompt(def_val_str[0],new_val_str[0],$
                                                            old_val,new_val,              $
                                                            VAL_NAME=in_str[0],           $
                                                            READ_OUT=read_out,            $
                                                            VALUE_OUT=value_out,          $
                                                            CHANGE=change                 )
        ENDIF ELSE BEGIN
          test      = 1b
          change    = 0b
          read_out  = ''
          value_out = new_val
        ENDELSE
        IF (~test[0]) THEN STOP   ;;  Something is wrong --> debug
        ;;  Check if user wishes to quit
        IF (read_out[0] EQ 'q') THEN GOTO,JUMP_RETURN
        ;;********************************************************************************
        ;;  Check if user wants to try and change the parameter again
        ;;********************************************************************************
        IF (read_out[0] EQ 'y' AND change[0]) THEN BEGIN
          ;;  Try again
          vbulk_change_prompts,dat,/NSMCUT,CONT_STR=cont_str,WINDN=win,PLOT_STR=plot_str,$
                               READ_OUT=read_out,VALUE_OUT=value_out
          ;;  Exit
          RETURN
        ENDIF
      ENDIF ELSE BEGIN
        ;;********************************************************************************
        ;;  Use current/default
        ;;********************************************************************************
        new_val = old_val[0]
      ENDELSE
      ;;-------------------------------------------
      ;;  Define output
      ;;-------------------------------------------
      value_out      = new_val
    END
    'nsmcon'    : BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  NSMCON
      ;;----------------------------------------------------------------------------------
      units          = ' '
      test           = (TOTAL(ABS(old_val),/NAN) NE 0)
      IF (test[0]) THEN str_pre = str_pre_c[0]+in_str[0] ELSE str_pre = str_pre_d[0]+in_str[0]
      ;;  Convert old value to string
      def_val_str    = num2int_str(old_val[0]);+" "+units[0]
      str_out        = str_pre[0]+" = "+def_val_str[0]+" ["+units[0]+"]? (y/n):  "
      ;; Define string outputs for procedural information
      pro_out        = ["     You will now be asked if you wish to smooth the contour and",    $
                        "cuts of the particle velocity distribution functions (DFs).  I",      $
                        "recommend smoothing the cuts but not the contours any more than the", $
                        "minimum amount designated by SMOOTH.  The SM_CUTS keyword determines",$
                        "if the routines smooth the cuts and the SM_CONT keyword determines",  $
                        "if the routines smooth the contours.  The NSMOOTH defines the number",$
                        "of points to use in SMOOTH [Width parameter in routine] for each."    ]
      ;;  Set/Reset outputs
      read_out       = ''    ;;  output value of decision
      WHILE (read_out[0] NE 'n' AND read_out[0] NE 'y' AND read_out[0] NE 'q') DO BEGIN
        read_out       = general_prompt_routine(STR_OUT=str_out,PRO_OUT=pro_out,FORM_OUT=7)
        IF (read_out[0] EQ 'debug') THEN STOP
      ENDWHILE
      ;;  Check if user wishes to quit
      IF (read_out[0] EQ 'q') THEN GOTO,JUMP_RETURN
      ;;-------------------------------------------
      ;;  Prompt for new NSMCON
      ;;-------------------------------------------
      value_out      = 0L    ;;  output value for prompt
      IF (read_out[0] EQ 'n') THEN BEGIN
        ;;  Set/Reset outputs
        read_out       = ''    ;;  output value of decision
        ;;********************************************************************************
        ;;  Select new value
        ;;********************************************************************************
        str_out        = "Enter a new value for "+in_str[0]+" [satisfying: 2 < n < 10]:  "
        new_val        = vbulk_change_scalar_prompt(SCL_NAME=in_str[0],SCL_UNITS=units[0],  $
                                                    UPPER_LIM=10L,LOWER_LIM=2L,             $
                                                    STR_OUT=str_out,FORM_OUT=3L,            $
                                                    READ_OUT=read_out,VALUE_OUT=value_out)
        ;;********************************************************************************
        ;;  Check if user likes the new result
        ;;********************************************************************************
        new_val_str    = num2int_str(new_val[0])+" "+units[0]
        IF (checkon[0]) THEN BEGIN
          test           = vbulk_change_check_result_prompt(def_val_str[0],new_val_str[0],$
                                                            old_val,new_val,              $
                                                            VAL_NAME=in_str[0],           $
                                                            READ_OUT=read_out,            $
                                                            VALUE_OUT=value_out,          $
                                                            CHANGE=change                 )
        ENDIF ELSE BEGIN
          test      = 1b
          change    = 0b
          read_out  = ''
          value_out = new_val
        ENDELSE
        IF (~test[0]) THEN STOP   ;;  Something is wrong --> debug
        ;;  Check if user wishes to quit
        IF (read_out[0] EQ 'q') THEN GOTO,JUMP_RETURN
        ;;********************************************************************************
        ;;  Check if user wants to try and change the parameter again
        ;;********************************************************************************
        IF (read_out[0] EQ 'y' AND change[0]) THEN BEGIN
          ;;  Try again
          vbulk_change_prompts,dat,/NSMCON,CONT_STR=cont_str,WINDN=win,PLOT_STR=plot_str,$
                               READ_OUT=read_out,VALUE_OUT=value_out
          ;;  Exit
          RETURN
        ENDIF
      ENDIF ELSE BEGIN
        ;;********************************************************************************
        ;;  Use current/default
        ;;********************************************************************************
        new_val = old_val[0]
      ENDELSE
      ;;-------------------------------------------
      ;;  Define output
      ;;-------------------------------------------
      value_out      = new_val
    END
    'plane'     : BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  PLANE
      ;;----------------------------------------------------------------------------------
      units          = ' '
      test           = (TOTAL(old_val EQ '') EQ 0)
      IF (test[0]) THEN str_pre = str_pre_c[0]+in_str[0] ELSE str_pre = str_pre_d[0]+in_str[0]
      ;;  Convert old value to string
      def_val_str    = old_val[0]
      ;; Define string outputs for procedural information
      pro_out        = ["     You will now be asked which plane you wish to enter project",    $
                        "the particle velocity distribution functions (VDFs) onto.  If we",    $
                        "assume we have two input vectors, V1 and V2, then the options are:",  $
                        "  'xy'  :  horizontal axis parallel to V1 and plane normal to vector",$
                        "             defined by (V1 x V2) [DEFAULT]",                         $
                        "  'xz'  :  horizontal axis parallel to (V1 x V2) and vertical axis",  $
                        "             parallel to V1",                                         $
                        "  'yz'  :  horizontal axis defined by (V1 x V2) x V1 and vertical",   $
                        "             axis parallel to (V1 x V2)"                              ]
      str_out        = "Enter 'xy', 'xz', or 'yz' for the desired plane of projection:  "
      ;;  Set/Reset outputs
      read_out       = ''    ;;  output value of decision
      WHILE (read_out[0] NE 'xy' AND read_out[0] NE 'xz' AND read_out[0] NE 'yz' AND read_out[0] NE 'q') DO BEGIN
        read_out       = general_prompt_routine(STR_OUT=str_out,PRO_OUT=pro_out,FORM_OUT=7)
        CASE read_out[0] OF
          'debug'  :  STOP                    ;;  User wishes to debug routine
          'q'      :  GOTO,JUMP_RETURN        ;;  User wishes to quit
          ELSE     :                          ;;  Nope --> ask user again
        ENDCASE
      ENDWHILE
      new_val   = read_out[0]
      new_fmidf = def_suffix[WHERE(['xy','xz','yz'] EQ new_val[0])]
      ;;  Check if user likes the new result
      new_val_str    = new_val[0]
      IF (checkon[0]) THEN BEGIN
        test           = vbulk_change_check_result_prompt(def_val_str[0],new_val_str[0],$
                                                          1,2,                          $
                                                          VAL_NAME=in_str[0],           $
                                                          READ_OUT=read_out,            $
                                                          VALUE_OUT=value_out,          $
                                                          CHANGE=change                 )
      ENDIF ELSE BEGIN
        test      = 1b
        change    = 0b
        read_out  = ''
        value_out = 2
      ENDELSE
      IF (~test[0]) THEN STOP   ;;  Something is wrong --> debug
      ;;  Check if user wishes to quit
      IF (read_out[0] EQ 'q') THEN GOTO,JUMP_RETURN
      ;;  Check if user wants to try and change the parameter again
      IF (read_out[0] EQ 'y' AND change[0]) THEN BEGIN
        ;;  Try again
        vbulk_change_prompts,dat,/PLANE,CONT_STR=cont_str,WINDN=win,PLOT_STR=plot_str,$
                             READ_OUT=read_out,VALUE_OUT=value_out
        ;;  Exit
        RETURN
      ENDIF
      ;;-------------------------------------------
      ;;  Define output
      ;;-------------------------------------------
      value_out      = new_val
    END
    'dfmin'     : BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  DFMIN
      ;;----------------------------------------------------------------------------------
      units          = 's^(+3) cm^(-3) km^(-3)'
      test           = (TOTAL(ABS(old_val),/NAN) NE 0)
      IF (test[0]) THEN str_pre = str_pre_c[0]+in_str[0] ELSE str_pre = str_pre_d[0]+in_str[0]
      ;;  Convert old value to string
      def_val_str    = STRTRIM(STRING(old_val[0],FORMAT='(e15.3)'),2);+" "+units[0]
      str_out        = str_pre[0]+" = "+def_val_str[0]+" ["+units[0]+"]? (y/n):  "
      ;; Define string outputs for procedural information
      pro_out        = ["     You will now be asked whether you wish to enter a default",    $
                        "value for the lower and upper bound to be used in the phase",       $
                        "(velocity) space density plots.  The input format should be",       $
                        "(format = x.xxxESee), where x is any integer 0-9, E = e in IDL",    $
                        "[= x 10^(See)], S = sign of exponent, and ee = exponent values.",   $
                        "",                                                                  $
                        "An example input would be:  1.05e-12"                               ]
      ;;  Set/Reset outputs
      read_out       = ''    ;;  output value of decision
      WHILE (read_out[0] NE 'n' AND read_out[0] NE 'y' AND read_out[0] NE 'q') DO BEGIN
        read_out       = general_prompt_routine(STR_OUT=str_out,PRO_OUT=pro_out,FORM_OUT=7)
        IF (read_out[0] EQ 'debug') THEN STOP
      ENDWHILE
      ;;  Check if user wishes to quit
      IF (read_out[0] EQ 'q') THEN GOTO,JUMP_RETURN
      ;;-------------------------------------------
      ;;  Prompt for new DFMIN
      ;;-------------------------------------------
      value_out      = 0.    ;;  output value for prompt
      IF (read_out[0] EQ 'n') THEN BEGIN
        ;;********************************************************************************
        ;;  Select new value
        ;;********************************************************************************
        str_out        = "Enter a new value for "+in_str[0]+" (format = x.xxxESee):  "
        new_val        = vbulk_change_scalar_prompt(SCL_NAME=in_str[0],SCL_UNITS=units[0],    $
                                                    STR_OUT=str_out,FORM_OUT=5L,              $
                                                    READ_OUT=read_out,VALUE_OUT=value_out)
        ;;********************************************************************************
        ;;  Check if user likes the new result
        ;;********************************************************************************
        new_val_str    = STRTRIM(STRING(new_val[0],FORMAT='(e15.3)'),2)+" "+units[0]
        IF (checkon[0]) THEN BEGIN
          test           = vbulk_change_check_result_prompt(def_val_str[0],new_val_str[0],$
                                                            old_val,new_val,              $
                                                            VAL_NAME=in_str[0],           $
                                                            READ_OUT=read_out,            $
                                                            VALUE_OUT=value_out,          $
                                                            CHANGE=change                 )
        ENDIF ELSE BEGIN
          test      = 1b
          change    = 0b
          read_out  = ''
          value_out = new_val
        ENDELSE
        IF (~test[0]) THEN STOP   ;;  Something is wrong --> debug
        ;;  Check if user wishes to quit
        IF (read_out[0] EQ 'q') THEN GOTO,JUMP_RETURN
        ;;********************************************************************************
        ;;  Check if user wants to try and change the parameter again
        ;;********************************************************************************
        IF (read_out[0] EQ 'y' AND change[0]) THEN BEGIN
          ;;  Try again
          vbulk_change_prompts,dat,/DFMIN,CONT_STR=cont_str,WINDN=win,PLOT_STR=plot_str,$
                               READ_OUT=read_out,VALUE_OUT=value_out
          ;;  Exit
          RETURN
        ENDIF
      ENDIF ELSE BEGIN
        ;;********************************************************************************
        ;;  Use current/default
        ;;********************************************************************************
        new_val = old_val[0]
      ENDELSE
      ;;-------------------------------------------
      ;;  Define output
      ;;-------------------------------------------
      value_out      = new_val
    END
    'dfmax'     : BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  DFMAX
      ;;----------------------------------------------------------------------------------
      units          = 's^(+3) cm^(-3) km^(-3)'
      test           = (TOTAL(ABS(old_val),/NAN) NE 0)
      IF (test[0]) THEN str_pre = str_pre_c[0]+in_str[0] ELSE str_pre = str_pre_d[0]+in_str[0]
      ;;  Convert old value to string
      def_val_str    = STRTRIM(STRING(old_val[0],FORMAT='(e15.3)'),2);+" "+units[0]
      str_out        = str_pre[0]+" = "+def_val_str[0]+" ["+units[0]+"]? (y/n):  "
      ;; Define string outputs for procedural information
      pro_out        = ["     You will now be asked whether you wish to enter a default",    $
                        "value for the lower and upper bound to be used in the phase",       $
                        "(velocity) space density plots.  The input format should be",       $
                        "(format = x.xxxESee), where x is any integer 0-9, E = e in IDL",    $
                        "[= x 10^(See)], S = sign of exponent, and ee = exponent values.",   $
                        "",                                                                  $
                        "An example input would be:  1.05e-12"                               ]
      ;;  Set/Reset outputs
      read_out       = ''    ;;  output value of decision
      WHILE (read_out[0] NE 'n' AND read_out[0] NE 'y' AND read_out[0] NE 'q') DO BEGIN
        read_out       = general_prompt_routine(STR_OUT=str_out,PRO_OUT=pro_out,FORM_OUT=7)
        IF (read_out[0] EQ 'debug') THEN STOP
      ENDWHILE
      ;;  Check if user wishes to quit
      IF (read_out[0] EQ 'q') THEN GOTO,JUMP_RETURN
      ;;-------------------------------------------
      ;;  Prompt for new DFMAX
      ;;-------------------------------------------
      value_out      = 0.    ;;  output value for prompt
      IF (read_out[0] EQ 'n') THEN BEGIN
        ;;********************************************************************************
        ;;  Select new value
        ;;********************************************************************************
        str_out        = "Enter a new value for "+in_str[0]+" (format = x.xxxESee):  "
        new_val        = vbulk_change_scalar_prompt(SCL_NAME=in_str[0],SCL_UNITS=units[0],    $
                                                    STR_OUT=str_out,FORM_OUT=5L,              $
                                                    READ_OUT=read_out,VALUE_OUT=value_out)
        ;;********************************************************************************
        ;;  Check if user likes the new result
        ;;********************************************************************************
        new_val_str    = STRTRIM(STRING(new_val[0],FORMAT='(e15.3)'),2)+" "+units[0]
        IF (checkon[0]) THEN BEGIN
          test           = vbulk_change_check_result_prompt(def_val_str[0],new_val_str[0],$
                                                            old_val,new_val,              $
                                                            VAL_NAME=in_str[0],           $
                                                            READ_OUT=read_out,            $
                                                            VALUE_OUT=value_out,          $
                                                            CHANGE=change                 )
        ENDIF ELSE BEGIN
          test      = 1b
          change    = 0b
          read_out  = ''
          value_out = new_val
        ENDELSE
        IF (~test[0]) THEN STOP   ;;  Something is wrong --> debug
        ;;  Check if user wishes to quit
        IF (read_out[0] EQ 'q') THEN GOTO,JUMP_RETURN
        ;;********************************************************************************
        ;;  Check if user wants to try and change the parameter again
        ;;********************************************************************************
        IF (read_out[0] EQ 'y' AND change[0]) THEN BEGIN
          ;;  Try again
          vbulk_change_prompts,dat,/DFMAX,CONT_STR=cont_str,WINDN=win,PLOT_STR=plot_str,$
                               READ_OUT=read_out,VALUE_OUT=value_out
          ;;  Exit
          RETURN
        ENDIF
      ENDIF ELSE BEGIN
        ;;********************************************************************************
        ;;  Use current/default
        ;;********************************************************************************
        new_val = old_val[0]
      ENDELSE
      ;;-------------------------------------------
      ;;  Define output
      ;;-------------------------------------------
      value_out      = new_val
    END
    'dfra'      : BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  DFRA
      ;;----------------------------------------------------------------------------------
      units          = 's^(+3) cm^(-3) km^(-3)'
      test           = (TOTAL(ABS(old_val),/NAN) EQ 2)
      IF (test[0]) THEN str_pre = str_pre_c[0]+in_str[0] ELSE str_pre = str_pre_d[0]+in_str[0]
      ;;  Convert old value to string
      temp           = STRTRIM(STRING(old_val,FORMAT='(e15.3)'),2)
      def_val_str    = temp[0]+" -- "+temp[1];+" "+units[0]
      str_out        = str_pre[0]+" = "+def_val_str[0]+" ["+units[0]+"]? (y/n):  "
      ;; Define string outputs for procedural information
      pro_out        = ["     You will now be asked whether you wish to enter a plotting",   $
                        "range for the phase (velocity) space density plots.  The input",    $
                        "format should be (format = x.xxxESee), where x is any integer",     $
                        '0-9, E = e in IDL [= x 10^(See)], S = sign of exponent, and',       $
                        "ee = exponent values.  This is different from the inputs for",      $
                        "DFMIN and DFMAX, which correspond to the keywords MIN_VALUE and",   $
                        "MAX_VALUE, respectively, used by PLOT.PRO.","",                     $
                        "An example input would be:  1.05e-12"                               ]
      ;;  Set/Reset outputs
      read_out       = ''    ;;  output value of decision
      WHILE (read_out[0] NE 'n' AND read_out[0] NE 'y' AND read_out[0] NE 'q') DO BEGIN
        read_out       = general_prompt_routine(STR_OUT=str_out,PRO_OUT=pro_out,FORM_OUT=7)
        IF (read_out[0] EQ 'debug') THEN STOP
      ENDWHILE
      ;;  Check if user wishes to quit
      IF (read_out[0] EQ 'q') THEN GOTO,JUMP_RETURN
      ;;-------------------------------------------
      ;;  Prompt for new DFRA
      ;;-------------------------------------------
      value_out      = REPLICATE(0d0,2L)    ;;  output value for prompt
      IF (read_out[0] EQ 'n') THEN BEGIN
        ;;********************************************************************************
        ;;  Select new value
        ;;********************************************************************************
        str_out        = "Enter a new lower bound for "+in_str[0]+" (format = x.xxxESee):  "
        new_val0       = vbulk_change_scalar_prompt(SCL_NAME=in_str[0],SCL_UNITS=units[0],    $
                                                    STR_OUT=str_out,FORM_OUT=5L,              $
                                                    READ_OUT=read_out,VALUE_OUT=value_out)
        str_out        = "Enter a new upper bound for "+in_str[0]+" (format = x.xxxESee):  "
        pro_out        = ["     Note that the new upper bound must exceed 10x's your lower bound estimate!"]
        new_val1       = vbulk_change_scalar_prompt(SCL_NAME=in_str[0],SCL_UNITS=units[0],    $
                                                    LOWER_LIM=1d1*new_val0[0],                $
                                                    STR_OUT=str_out,FORM_OUT=5L,              $
                                                    READ_OUT=read_out,VALUE_OUT=value_out)
        ;;********************************************************************************
        ;;  Check if user likes the new result
        ;;********************************************************************************
        new_val        = [new_val0[0],new_val1[0]]
        temp           = STRTRIM(STRING(new_val,FORMAT='(e15.3)'),2)
        new_val_str    = temp[0]+" -- "+temp[1]+" "+units[0]
        IF (checkon[0]) THEN BEGIN
          test           = vbulk_change_check_result_prompt(def_val_str[0],new_val_str[0],$
                                                            old_val,new_val,              $
                                                            VAL_NAME=in_str[0],           $
                                                            READ_OUT=read_out,            $
                                                            VALUE_OUT=value_out,          $
                                                            CHANGE=change                 )
        ENDIF ELSE BEGIN
          test      = 1b
          change    = 0b
          read_out  = ''
          value_out = new_val
        ENDELSE
        IF (~test[0]) THEN STOP   ;;  Something is wrong --> debug
        ;;  Check if user wishes to quit
        IF (read_out[0] EQ 'q') THEN GOTO,JUMP_RETURN
        ;;********************************************************************************
        ;;  Check if user wants to try and change the parameter again
        ;;********************************************************************************
        IF (read_out[0] EQ 'y' AND change[0]) THEN BEGIN
          ;;  Try again
          vbulk_change_prompts,dat,/DFRA,CONT_STR=cont_str,WINDN=win,PLOT_STR=plot_str,$
                               READ_OUT=read_out,VALUE_OUT=value_out
          ;;  Exit
          RETURN
        ENDIF
      ENDIF ELSE BEGIN
        ;;********************************************************************************
        ;;  Use current/default
        ;;********************************************************************************
        new_val = old_val
      ENDELSE
      ;;-------------------------------------------
      ;;  Define output
      ;;-------------------------------------------
      value_out      = new_val
    END
    'v_0x'      : BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  V_0X
      ;;----------------------------------------------------------------------------------
      units          = 'km/s'
      test           = (TOTAL(ABS(old_val),/NAN) NE 0)
      IF (test[0]) THEN str_pre = str_pre_c[0]+in_str[0] ELSE str_pre = str_pre_d[0]+in_str[0]
      ;;  Convert old value to string
      def_val_str    = STRTRIM(STRING(old_val[0],FORMAT='(g15.3)'),2);+" "+units[0]
      str_out        = str_pre[0]+" = "+def_val_str[0]+" ["+units[0]+"]? (y/n):  "
      ;;  Define procedural information
      pro_out        = ["You can enter a new value for "+in_str[0]+" (format = XXXX.xxx).",$
                        "This will change the location for the perpendicular cut.","",     $
                        "[Type 'q' to quit at any time]"]
      ;;  Set/Reset outputs
      read_out       = ''    ;;  output value of decision
      WHILE (read_out[0] NE 'n' AND read_out[0] NE 'y' AND read_out[0] NE 'q') DO BEGIN
        read_out       = general_prompt_routine(STR_OUT=str_out,PRO_OUT=pro_out,FORM_OUT=7)
        IF (read_out[0] EQ 'debug') THEN STOP
      ENDWHILE
      ;;  Check if user wishes to quit
      IF (read_out[0] EQ 'q') THEN GOTO,JUMP_RETURN
      ;;-------------------------------------------
      ;;  Prompt for new V_0X
      ;;-------------------------------------------
      value_out      = 0.    ;;  output value for prompt
      IF (read_out[0] EQ 'n') THEN BEGIN
        ;;********************************************************************************
        ;;  Select new value
        ;;********************************************************************************
        str_out        = "Enter a new value for "+in_str[0]+" ["+units[0]+"] (format = XXXX.xxx):  "
        new_val        = vbulk_change_scalar_prompt(SCL_NAME=in_str[0],SCL_UNITS=units[0],    $
                                                    UPPER_LIM=vmag_85_max[0],                 $
                                                    LOWER_LIM=-1d0*vmag_85_max[0],            $
                                                    STR_OUT=str_out,FORM_OUT=5L,              $
                                                    READ_OUT=read_out,VALUE_OUT=value_out)
        ;;********************************************************************************
        ;;  Check if user likes the new result
        ;;********************************************************************************
        new_val_str    = STRTRIM(STRING(new_val[0],FORMAT='(g15.3)'),2)+" "+units[0]
        IF (checkon[0]) THEN BEGIN
          test           = vbulk_change_check_result_prompt(def_val_str[0],new_val_str[0],$
                                                            old_val,new_val,              $
                                                            VAL_NAME=in_str[0],           $
                                                            READ_OUT=read_out,            $
                                                            VALUE_OUT=value_out,          $
                                                            CHANGE=change                 )
        ENDIF ELSE BEGIN
          test      = 1b
          change    = 0b
          read_out  = ''
          value_out = new_val
        ENDELSE
        IF (~test[0]) THEN STOP   ;;  Something is wrong --> debug
        ;;  Check if user wishes to quit
        IF (read_out[0] EQ 'q') THEN GOTO,JUMP_RETURN
        ;;********************************************************************************
        ;;  Check if user wants to try and change the parameter again
        ;;********************************************************************************
        IF (read_out[0] EQ 'y' AND change[0]) THEN BEGIN
          ;;  Try again
          vbulk_change_prompts,dat,/V_0X,CONT_STR=cont_str,WINDN=win,PLOT_STR=plot_str,$
                               READ_OUT=read_out,VALUE_OUT=value_out
          ;;  Exit
          RETURN
        ENDIF
      ENDIF ELSE BEGIN
        ;;********************************************************************************
        ;;  Use current/default
        ;;********************************************************************************
        new_val = old_val[0]
      ENDELSE
      ;;-------------------------------------------
      ;;  Define output
      ;;-------------------------------------------
      value_out      = new_val
    END
    'v_0y'      : BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  V_0Y
      ;;----------------------------------------------------------------------------------
      units          = 'km/s'
      test           = (TOTAL(ABS(old_val),/NAN) NE 0)
      IF (test[0]) THEN str_pre = str_pre_c[0]+in_str[0] ELSE str_pre = str_pre_d[0]+in_str[0]
      ;;  Convert old value to string
      def_val_str    = STRTRIM(STRING(old_val[0],FORMAT='(g15.3)'),2);+" "+units[0]
      str_out        = str_pre[0]+" = "+def_val_str[0]+" ["+units[0]+"]? (y/n):  "
      ;;  Define procedural information
      pro_out        = ["You can enter a new value for "+in_str[0]+" (format = XXXX.xxx).",$
                        "This will change the location for the parallel cut.","",          $
                        "[Type 'q' to quit at any time]"]
      ;;  Set/Reset outputs
      read_out       = ''    ;;  output value of decision
      WHILE (read_out[0] NE 'n' AND read_out[0] NE 'y' AND read_out[0] NE 'q') DO BEGIN
        read_out       = general_prompt_routine(STR_OUT=str_out,PRO_OUT=pro_out,FORM_OUT=7)
        IF (read_out[0] EQ 'debug') THEN STOP
      ENDWHILE
      ;;  Check if user wishes to quit
      IF (read_out[0] EQ 'q') THEN GOTO,JUMP_RETURN
      ;;-------------------------------------------
      ;;  Prompt for new V_0Y
      ;;-------------------------------------------
      value_out      = 0.    ;;  output value for prompt
      IF (read_out[0] EQ 'n') THEN BEGIN
        ;;********************************************************************************
        ;;  Select new value
        ;;********************************************************************************
        str_out        = "Enter a new value for "+in_str[0]+" ["+units[0]+"] (format = XXXX.xxx):  "
        new_val        = vbulk_change_scalar_prompt(SCL_NAME=in_str[0],SCL_UNITS=units[0],    $
                                                    UPPER_LIM=vmag_85_max[0],                 $
                                                    LOWER_LIM=-1d0*vmag_85_max[0],            $
                                                    STR_OUT=str_out,FORM_OUT=5L,              $
                                                    READ_OUT=read_out,VALUE_OUT=value_out)
        ;;********************************************************************************
        ;;  Check if user likes the new result
        ;;********************************************************************************
        new_val_str    = STRTRIM(STRING(new_val[0],FORMAT='(g15.3)'),2)+" "+units[0]
        IF (checkon[0]) THEN BEGIN
          test           = vbulk_change_check_result_prompt(def_val_str[0],new_val_str[0],$
                                                            old_val,new_val,              $
                                                            VAL_NAME=in_str[0],           $
                                                            READ_OUT=read_out,            $
                                                            VALUE_OUT=value_out,          $
                                                            CHANGE=change                 )
        ENDIF ELSE BEGIN
          test      = 1b
          change    = 0b
          read_out  = ''
          value_out = new_val
        ENDELSE
        IF (~test[0]) THEN STOP   ;;  Something is wrong --> debug
        ;;  Check if user wishes to quit
        IF (read_out[0] EQ 'q') THEN GOTO,JUMP_RETURN
        ;;********************************************************************************
        ;;  Check if user wants to try and change the parameter again
        ;;********************************************************************************
        IF (read_out[0] EQ 'y' AND change[0]) THEN BEGIN
          ;;  Try again
          vbulk_change_prompts,dat,/V_0Y,CONT_STR=cont_str,WINDN=win,PLOT_STR=plot_str,$
                               READ_OUT=read_out,VALUE_OUT=value_out
          ;;  Exit
          RETURN
        ENDIF
      ENDIF ELSE BEGIN
        ;;********************************************************************************
        ;;  Use current/default
        ;;********************************************************************************
        new_val = old_val[0]
      ENDELSE
      ;;-------------------------------------------
      ;;  Define output
      ;;-------------------------------------------
      value_out      = new_val
    END
    'save_dir'  : BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  SAVE_DIR
      ;;----------------------------------------------------------------------------------
      units          = ' '
      test           = (TOTAL(old_val EQ '') EQ 0)
      IF (test[0]) THEN str_pre = str_pre_c[0]+in_str[0] ELSE str_pre = str_pre_d[0]+in_str[0]
      ;;  Convert old value to string
      def_val_str    = old_val[0];+" "+units[0]
      str_out        = str_pre[0]+" = "+def_val_str[0]+" ["+units[0]+"]? (y/n):  "
      ;;  Define procedural information
      temp_path      = "'"+slash[0]+"full"+slash[0]+"path"+slash[0]+"to"+slash[0]+"directory"+slash[0]+"of"+slash[0]+"interest"+slash[0]+"'"
      pro_out        = ["You can enter a new value for "+in_str[0],                      $
                        " (format = "+temp_path[0]+"):  ",                               $
                        "","You can also enter the new directory as a subdirectory",     $
                        "instead of the full path, where the subdirectory will be",      $
                        "created in the current working directory.  To use this",        $
                        "option, simply enter the directory with the following",         $
                        "format:  '."+slash[0]+"subdirectory_name"+slash[0]+"'",         $
                        "where the trailing file path separator (slash) is not",         $
                        "required but is helpful/useful.","",                            $
                        "This will define/change the location of the output PS plots.",  $
                        "","[Type 'q' to quit at any time]"]
      ;;  Set/Reset outputs
      read_out       = ''    ;;  output value of decision
      WHILE (read_out[0] NE 'n' AND read_out[0] NE 'y' AND read_out[0] NE 'q') DO BEGIN
        read_out       = general_prompt_routine(STR_OUT=str_out,PRO_OUT=pro_out,FORM_OUT=7)
        IF (read_out[0] EQ 'debug') THEN STOP
      ENDWHILE
      ;;  Check if user wishes to quit
      IF (read_out[0] EQ 'q') THEN GOTO,JUMP_RETURN
      ;;-------------------------------------------
      ;;  Prompt for new SAVE_DIR
      ;;-------------------------------------------
      value_out      = ''    ;;  output value for prompt
      IF (read_out[0] EQ 'n') THEN BEGIN
        ;;********************************************************************************
        ;;  Select new value
        ;;********************************************************************************
        str_out        = "Enter a new string for "+in_str[0]+":  "
        read_out       = ''    ;;  output value of decision
        WHILE (read_out[0] NE 'n' AND read_out[0] NE 'y' AND read_out[0] NE 'q') DO BEGIN
          new_val        = vbulk_change_scalar_prompt(SCL_NAME=in_str[0],SCL_UNITS=units[0],  $
                                                      STR_OUT=str_out,FORM_OUT=7L,            $
                                                      READ_OUT=read_out,VALUE_OUT=value_out)
          ;;##############################################################################
          ;;  First check if user provided a valid directory path
          ;;##############################################################################
          IF (read_out[0] EQ 'debug') THEN STOP
          ;;  Check if user entered a subdirectory or full path
          test_base      = (STRMID(new_val[0],0L,2L) EQ '.'+slash[0])
          base_dir       = ''
          sub_dir        = new_val[0]
          IF (test_base[0]) THEN BEGIN
            base_dir = (FILE_SEARCH(STRMID(new_val[0],0L,2L),/FULLY_QUALIFY_PATH,/MARK_DIRECTORY))[0]
            sub_dir  = STRMID(new_val[0],2L)
          ENDIF
          test           = test_file_path_format(sub_dir,BASE_DIR=base_dir,EXISTS=exists,DIR_OUT=dir_out)
          test_exist     = exists[0]
          IF (~test[0]) THEN BEGIN
            ;;  User supplied bad path format --> try again
            pro_out        = ["Bad file path input format, try again."]
            info_out       = general_prompt_routine(PRO_OUT=pro_out,FORM_OUT=7)
            read_out       = ''
            value_out      = ''
            test_exist     = 0b
            new_val        = ''
          ENDIF ELSE BEGIN
            ;;  Directory was good --> re-define NEW_VAL
            new_val        = dir_out[0]
          ENDELSE
        ENDWHILE
        ;;********************************************************************************
        ;;  Check if user likes the new result
        ;;********************************************************************************
        new_val_str    = new_val[0]+" "+units[0]
        IF (checkon[0]) THEN BEGIN
          test           = vbulk_change_check_result_prompt(def_val_str[0],new_val_str[0],$
                                                            1,2,                          $
                                                            VAL_NAME=in_str[0],           $
                                                            READ_OUT=read_out,            $
                                                            VALUE_OUT=value_out,          $
                                                            CHANGE=change                 )
        ENDIF ELSE BEGIN
          test      = 1b
          change    = 0b
          read_out  = ''
          value_out = 2
        ENDELSE
        IF (~test[0]) THEN STOP   ;;  Something is wrong --> debug
        ;;  Check if user wishes to quit
        IF (read_out[0] EQ 'q') THEN GOTO,JUMP_RETURN
        ;;********************************************************************************
        ;;  Check if user wants to try and change the parameter again
        ;;********************************************************************************
        IF (read_out[0] EQ 'y' AND change[0]) THEN BEGIN
          ;;  Try again
          vbulk_change_prompts,dat,/SAVE_DIR,CONT_STR=cont_str,WINDN=win,PLOT_STR=plot_str,$
                               READ_OUT=read_out,VALUE_OUT=value_out
          ;;  Exit
          RETURN
        ENDIF ELSE IF (~test_exist[0]) THEN FILE_MKDIR,new_val[0]    ;;  Create directory if not present
      ENDIF ELSE BEGIN
        ;;********************************************************************************
        ;;  Use current/default
        ;;********************************************************************************
        new_val = old_val[0]
      ENDELSE
      ;;-------------------------------------------
      ;;  Define output
      ;;-------------------------------------------
      value_out      = new_val
    END
    'file_pref' : BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  FILE_PREF
      ;;----------------------------------------------------------------------------------
      units          = ' '
      test           = (TOTAL(old_val EQ '') EQ 0)
      IF (test[0]) THEN str_pre = str_pre_c[0]+in_str[0] ELSE str_pre = str_pre_d[0]+in_str[0]
      ;;  Convert old value to string
      def_val_str    = old_val[0];+" "+units[0]
      str_out        = str_pre[0]+" = "+def_val_str[0]+" ["+units[0]+"]? (y/n):  "
      ;;  Define procedural information
      pro_out        = ["You can enter a new value for "+in_str[0],                       $
                        " (format = 'new_file_prefix_string').",                          $
                        "This will change part of the file name of the output PS plots.", $
                        "","[Type 'q' to quit at any time]"]
      ;;  Set/Reset outputs
      read_out       = ''    ;;  output value of decision
      WHILE (read_out[0] NE 'n' AND read_out[0] NE 'y' AND read_out[0] NE 'q') DO BEGIN
        read_out       = general_prompt_routine(STR_OUT=str_out,PRO_OUT=pro_out,FORM_OUT=7)
        IF (read_out[0] EQ 'debug') THEN STOP
      ENDWHILE
      ;;  Check if user wishes to quit
      IF (read_out[0] EQ 'q') THEN GOTO,JUMP_RETURN
      ;;-------------------------------------------
      ;;  Prompt for new FILE_PREF
      ;;-------------------------------------------
      value_out      = ''    ;;  output value for prompt
      IF (read_out[0] EQ 'n') THEN BEGIN
        ;;********************************************************************************
        ;;  Select new value
        ;;********************************************************************************
        str_out        = "Enter a new string for "+in_str[0]+":  "
        read_out       = ''    ;;  output value of decision
        WHILE (read_out[0] NE 'n' AND read_out[0] NE 'y' AND read_out[0] NE 'q') DO BEGIN
          new_val        = vbulk_change_scalar_prompt(SCL_NAME=in_str[0],SCL_UNITS=units[0],  $
                                                      STR_OUT=str_out,FORM_OUT=7L,            $
                                                      READ_OUT=read_out,VALUE_OUT=value_out)
          ;;##############################################################################
          ;;  First check if user provided a valid IDL string
          ;;##############################################################################
          IF (read_out[0] EQ 'debug') THEN STOP
          test           = (IDL_VALIDNAME(new_val[0]) NE '')
          IF (~test[0]) THEN BEGIN
            ;;  User supplied bad path format --> try again
            pro_out        = ["Bad file name prefix input format, try again."]
            info_out       = general_prompt_routine(PRO_OUT=pro_out,FORM_OUT=7)
            read_out       = ''
          ENDIF
        ENDWHILE
        ;;********************************************************************************
        ;;  Check if user likes the new result
        ;;********************************************************************************
        new_val_str    = new_val[0]+" "+units[0]
        IF (checkon[0]) THEN BEGIN
          test           = vbulk_change_check_result_prompt(def_val_str[0],new_val_str[0],$
                                                            1,2,                          $
                                                            VAL_NAME=in_str[0],           $
                                                            READ_OUT=read_out,            $
                                                            VALUE_OUT=value_out,          $
                                                            CHANGE=change                 )
        ENDIF ELSE BEGIN
          test      = 1b
          change    = 0b
          read_out  = ''
          value_out = 2
        ENDELSE
        IF (~test[0]) THEN STOP   ;;  Something is wrong --> debug
        ;;  Check if user wishes to quit
        IF (read_out[0] EQ 'q') THEN GOTO,JUMP_RETURN
        ;;********************************************************************************
        ;;  Check if user wants to try and change the parameter again
        ;;********************************************************************************
        IF (read_out[0] EQ 'y' AND change[0]) THEN BEGIN
          ;;  Try again
          vbulk_change_prompts,dat,/FILE_PREF,CONT_STR=cont_str,WINDN=win,PLOT_STR=plot_str,$
                               READ_OUT=read_out,VALUE_OUT=value_out
          ;;  Exit
          RETURN
        ENDIF
      ENDIF ELSE BEGIN
        ;;********************************************************************************
        ;;  Use current/default
        ;;********************************************************************************
        new_val = old_val[0]
      ENDELSE
      ;;-------------------------------------------
      ;;  Define output
      ;;-------------------------------------------
      value_out      = new_val
    END
    'file_midf' : BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  FILE_MIDF
      ;;----------------------------------------------------------------------------------
      units          = ' '
      test           = (TOTAL(old_val EQ '') EQ 0)
      IF (test[0]) THEN str_pre = str_pre_c[0]+in_str[0] ELSE str_pre = str_pre_d[0]+in_str[0]
      ;;  Convert old value to string
      def_val_str    = old_val[0];+" "+units[0]
      str_out        = str_pre[0]+" = "+def_val_str[0]+" ["+units[0]+"]? (y/n):  "
      ;;  Define procedural information
      pro_out        = ["You can enter a new value for "+in_str[0],                       $
                        " (format = 'new_file_middle_string_').",                         $
                        "This will change part of the file name of the output PS plots.", $
                        "","[Type 'q' to quit at any time]"]
      ;;  Set/Reset outputs
      read_out       = ''    ;;  output value of decision
      WHILE (read_out[0] NE 'n' AND read_out[0] NE 'y' AND read_out[0] NE 'q') DO BEGIN
        read_out       = general_prompt_routine(STR_OUT=str_out,PRO_OUT=pro_out,FORM_OUT=7)
        IF (read_out[0] EQ 'debug') THEN STOP
      ENDWHILE
      ;;  Check if user wishes to quit
      IF (read_out[0] EQ 'q') THEN GOTO,JUMP_RETURN
      ;;-------------------------------------------
      ;;  Prompt for new FILE_MIDF
      ;;-------------------------------------------
      value_out      = ''    ;;  output value for prompt
      IF (read_out[0] EQ 'n') THEN BEGIN
        ;;********************************************************************************
        ;;  Select new value
        ;;********************************************************************************
        str_out        = "Enter a new string for "+in_str[0]+":  "
        read_out       = ''    ;;  output value of decision
        WHILE (read_out[0] NE 'n' AND read_out[0] NE 'y' AND read_out[0] NE 'q') DO BEGIN
          new_val        = vbulk_change_scalar_prompt(SCL_NAME=in_str[0],SCL_UNITS=units[0],  $
                                                      STR_OUT=str_out,FORM_OUT=7L,            $
                                                      READ_OUT=read_out,VALUE_OUT=value_out)
          ;;##############################################################################
          ;;  First check if user provided a valid IDL string
          ;;##############################################################################
          IF (read_out[0] EQ 'debug') THEN STOP
          test           = (IDL_VALIDNAME(new_val[0]) NE '')
          IF (~test[0]) THEN BEGIN
            ;;  User supplied bad path format --> try again
            pro_out        = ["Bad file name middle input format, try again."]
            info_out       = general_prompt_routine(PRO_OUT=pro_out,FORM_OUT=7)
            read_out       = ''
          ENDIF
        ENDWHILE
        ;;********************************************************************************
        ;;  Check if user likes the new result
        ;;********************************************************************************
        new_val_str    = new_val[0]+" "+units[0]
        IF (checkon[0]) THEN BEGIN
          test           = vbulk_change_check_result_prompt(def_val_str[0],new_val_str[0],$
                                                            1,2,                          $
                                                            VAL_NAME=in_str[0],           $
                                                            READ_OUT=read_out,            $
                                                            VALUE_OUT=value_out,          $
                                                            CHANGE=change                 )
        ENDIF ELSE BEGIN
          test      = 1b
          change    = 0b
          read_out  = ''
          value_out = 2
        ENDELSE
        IF (~test[0]) THEN STOP   ;;  Something is wrong --> debug
        ;;  Check if user wishes to quit
        IF (read_out[0] EQ 'q') THEN GOTO,JUMP_RETURN
        ;;********************************************************************************
        ;;  Check if user wants to try and change the parameter again
        ;;********************************************************************************
        IF (read_out[0] EQ 'y' AND change[0]) THEN BEGIN
          ;;  Try again
          vbulk_change_prompts,dat,/FILE_MIDF,CONT_STR=cont_str,WINDN=win,PLOT_STR=plot_str,$
                               READ_OUT=read_out,VALUE_OUT=value_out
          ;;  Exit
          RETURN
        ENDIF
      ENDIF ELSE BEGIN
        ;;********************************************************************************
        ;;  Use current/default
        ;;********************************************************************************
        new_val = old_val[0]
      ENDELSE
      ;;-------------------------------------------
      ;;  Define output
      ;;-------------------------------------------
      value_out      = new_val
    END
    ELSE        : BEGIN
      ;;  Obsolete Keyword or incorrect input
      ;;    --> Set/Reset outputs
      read_out       = ''    ;; output value of decision
      value_out      = 0.    ;; output value for prompt
    END
  ENDCASE
ENDELSE
;;========================================================================================
JUMP_RETURN:
;;========================================================================================

;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END




