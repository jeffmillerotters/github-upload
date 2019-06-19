Function get_raid_adjust, file, ch, hemi, satf2=satf2, localdir = localdir, noadjust = noadjust

;** file is e.g '1992183' for 1. July, 1992
;** ch is e.g. '19v' etc.
;** hemi is either 'N' or 'S'
;
;		modified to use the path on J. Miller's g5 mac to /pmw
;		modified to return 18 GHz values when 19 GHz is requested for SMMR data
;		modified 11/6/2006 to apply corrections to take all tbs back to f8 per Stroeve 1998 and Abdalati's PHD Dissertation
;		modified 7/16/2009 to update directories on new
;** computer
;               modified 2/19/2010 to update directories on newer
;                  computer, fix endian on new computer and to
;                  allow for F17 data
;
;               modified 1/30/2012 to try adjustment to take f17 to
;** f13, tho it is incomplete (only 19v/h and 37v are adjusted, at the
;** moment).  also added ability to retrieve ice concentration data
;
;                modified 1/03/2012 to produce non-adjusted values (to
;** keep the execution the same between get_raid and get_raid_adjust)
;
;                modified 1/9/2014 to do test adjustment of F17 to F13
;** values.
;
;                modified 10/1/2015 because the directory structure on
;** pmw changed
;                modified 4/18/2018 for directory structure (local
;** versions now)
;
  if n_elements(localdir) eq 0 then localdir = ''
  if n_elements(satf2) eq 0 then satf2 = ''
  if n_elements(noadjust) eq 0 then noadjust = 0
  hemi = strupcase(hemi)


;*** Routine now includes SMMR data ***, Jan.7,2003

  yy=strmid(file,0,4)
  day=strmid(file,4,3)

                                ; need to pull month and day for the new filetypes
  if (yy mod 4) eq 0 then leap = 1 else leap = 0
  result = day2date(fix(day), leap)

;*** F8 : 87190--91365
;*** F11: 91337--95273
;*** F13: 95123--08366
;*** F17: 09001--16092
;*** F18: 16091 on
;***before F8 -> SMMR

  case 1 of 
     (long(file) lt 1987190): sat='Smmr'
     ((long(file) ge 1987190)and(long(file) le 1991365)): sat='SsmiF8' ; f11 starts 1203 in 1991
     ((long(file) ge 1991337)and(long(file) le 1995273)): sat='SsmiF11'
     ((long(file) ge 1995123)and(long(file) le 2006366)) : sat='SsmiF13' ;temporary to 2006, should be 2008
     ((long(file) ge 2007001)and(long(file) le 2016091)) : sat='SsmiF17' ;starts 20061214 and v4
     ((long(file) ge 2016092)) : sat='SsmiF18'
     else: print, 'Date is not valid'
  endcase

  if long(file) ge 2007001 then vstr = '4' else vstr = '2'

  if satf2 eq '' then begin
     if (sat eq 'SsmiF8') then satf='08' 
     if (sat eq 'SsmiF11') then satf='11' 
     if (sat eq 'SsmiF13') then satf='13' 
     if (sat eq 'SsmiF17') then satf='17'
     if (sat eq 'SsmiF18') then satf='18'
  endif else begin
     satf = satf2
     if satf2 eq 'smmr' then sat = 'Smmr'
  endelse


  if ((ch eq '85v')or(ch eq '85h')) then hol='high' else hol='low'

  if ((ch eq '19v') AND (sat eq 'Smmr')) then ch = '18v'
  if ((ch eq '19h') AND (sat eq 'Smmr')) then ch = '18h'

  if (hemi eq 'N') then shemi='North' else shemi='South'

  if ((hemi eq 'N')and(hol eq 'high')) then data=intarr(608,896)
  if ((hemi eq 'N')and(hol eq 'low'))  then data=intarr(304,448)
  if ((hemi eq 'S')and(hol eq 'high')) then data=intarr(632,664)
  if ((hemi eq 'S')and(hol eq 'low'))  then data=intarr(316,332)

  head=bytarr(300)

  if (sat eq 'Smmr') then begin
     if localdir eq '' then begin
;/Users/jamiller/Desktop/pmw/
        if strlowcase(ch) ne 'icecon' then begin
           if (hemi eq 'N') then $
              path='/Volumes/azure/NSSSS1DTB01/'+strtrim(yy,2)+'/nsmss1dadtb'+ch+file $
           else path='/Volumes/pmw/SSMSS1DTBORIG01/ssmss1dadtb'+ch+file ; this needs to be fixed, no SH data atm
; /Volumes/azure/NSMSS1DTB01/1979/nsmss1dadtb06h1979002
                                ; file is date
                                ; ch is channel
           
; used to be               path='/Volumes/pmw/NSMSS1DTBORIG01/nsmss1dadtb'+ch+file $

        endif else begin
           if (hemi eq 'N') then   $
              path='/Volumes/azure/NSSSS1DTB01/'+strtrim(yy,2)+'/tb_f'+satf+'_'+ch+file $
; /Volumes/azure/NSSSS1DTB01/1987/tb_f08_19870713_v2_n85v.bin
;              path='/Volumes/pmw/NSMSS1DICECON01/nsmss1d07cnnon'+file  $
           else path='/Volumes/pmw/SSMSS1DICECON01/ssmss1d07cnnon'+file ;smss was always f07?
        endelse
     endif else begin
        if strlowcase(ch) ne 'icecon' then begin
           if (hemi eq 'N') then $
              path=localdir + 'nsmss1dadtb'+ch+file $
           else path=localdir + 'ssmss1dadtb'+ch+file 
        endif else begin
           if (hemi eq 'N') then   $
              path=localdir + 'nsmss1d07cnnon'+file  $
           else path=localdir + 'ssmss1d07cnnon'+file ;smss was always f07?
        endelse
     endelse
     
  endif else begin 
     if localdir eq '' then begin

        if strlowcase(ch) ne 'icecon' then begin
           if (hemi eq 'N') then   $
              path='/Volumes/pmw/NSSSS1DTB01/nssss1d'+satf+'tb'+ch+file  $
           else path='/Volumes/pmw/SSSSS1DTB01/sssss1d'+satf+'tb'+ch+file
        endif else begin
           if (hemi eq 'N') then   $
              path='/Volumes/pmw/NSSSS1DICECON01/nssss1d'+satf+'cnnon'+file  $
           else path='/Volumes/pmw/SSSSS1DICECON01/sssss1d'+satf+'cnnon'+file
        endelse

     endif else begin
        if strlowcase(ch) ne 'icecon' then begin
           if (hemi eq 'N') then   $
              path=localdir + 'nssss1d'+satf+'tb'+ch+file  $
           else path=localdir + 'sssss1d'+satf+'tb'+ch+file
        endif else begin
           if (hemi eq 'N') then   $
              path=localdir + 'nssss1d'+satf+'cnnon'+file  $
           else path=localdir + 'sssss1d'+satf+'cnnon'+file
        endelse
     endelse
  endelse
  
  print, path
  openr,un1, path ,error=err, /swap_if_little_endian, /get_lun

  if (err eq 0) then begin
     readu, un1, head
     readu, un1, data
     close, un1
     free_lun, un1
  endif else begin
     data(*,*)=-1
     print, 'No file found: '+path
     print, !ERROR_STATE.MSG
  endelse

  if (noadjust ne 1) then begin
;
;		apply corrections to take values back to f8
;
     if (where(data ne -1))(0) ne -1 then begin
        case 1 of 
           ((long(file) ge 1991337)and(long(file) le 1995273)): begin ; f11 to f8 per abdalati, greenland values
              print, 'heeeere'
              if ch eq '19h' then begin
                 h19a0 = -1.89
                 h19a1 = 1.013
                 data2 = (data/10.0)*h19a1 + h19a0
                 data = fix(data2*10)
              endif
              if ch eq '19v' then begin
                 v19a0 = -2.51
                 v19a1 = 1.013
                 data2 = (data/10.0)*v19a1 + v19a0
                 data = fix(data2*10)
              endif
              if ch eq '22v' then begin
                 v22a0 = -2.73
                 v22a1 = 1.014
                 data2 = (data/10.0)*v22a1 + v22a0
                 data = fix(data2*10)
              endif
              if ch eq '37h' then begin
                 h37a0 = -4.22
                 h37a1 = 1.024
                 data2 = (data/10.0)*h37a1 + h37a0
                 data = fix(data2*10)
              endif
              if ch eq '37v' then begin
                 v37a0 = 0.052
                 v37a1 = 1.000
                 data2 = (data/10.0)*v37a1 + v37a0
                 data = fix(data2*10)
              endif
           end

           (long(file) gt 1995123 and long(file) le 2007366 and satf ne '17'): begin ; stroeve first to f11 and then abdalati to f8, sb 2006366
              print, 'not heeeeere'
              if ch eq '19h' then begin
                 h19a0 = 2.705
                 h19a1 = 0.985
                 data2 = (data/10.0)*h19a1 + h19a0
                 h19a0 = -1.89
                 h19a1 = 1.013
                 data2 = (data2)*h19a1 + h19a0
                 data = fix(data2*10)
              endif
              if ch eq '19v' then begin
                 v19a0 = 4.875
                 v19a1 = 0.977
                 data2 = (data/10.0)*v19a1 + v19a0
                 v19a0 = -2.51
                 v19a1 = 1.013
                 data2 = (data2)*v19a1 + v19a0
                 data = fix(data2*10)
              endif
              if ch eq '22v' then begin
                 v22a0 = 7.52
                 v22a1 = 0.964
                 data2 = (data/10.0)*v22a1 + v22a0
                 v22a0 = -2.73
                 v22a1 = 1.014
                 data2 = (data2)*v22a1 + v22a0
                 data = fix(data2*10)
              endif
              if ch eq '37h' then begin
                 h37a0 = 6.139
                 h37a1 = 0.967
                 data2 = (data/10.0)*h37a1 + h37a0
                 h37a0 = -4.22
                 h37a1 = 1.024
                 data2 = (data2)*h37a1 + h37a0
                 data = fix(data2*10)
              endif
              if ch eq '37v' then begin
                 v37a0 = -3.28
                 v37a1 = 1.015
                 data2 = (data/10.0)*v37a1 + v37a0
                 v37a0 = 0.052
                 v37a1 = 1.000
                 data2 = (data2)*v37a1 + v37a0
                 data = fix(data2*10)
              endif
           end

           (long(file) ge 2007001  and (satf eq '17' or satf eq '18')): begin ; my own f17 to f13, then stroeve first to f11 and then abdalati to f8, sb 2009001
              if ch eq '19h' then begin
                 ;h19a0 = 7.526449
                 ;h19a1 = 0.95325166
                 ;data2 = (data/10.0)*h19a1 + h19a0
                 h19a0 = 1.324
                 h19a1 = 0.98000 ;nick's numbers
                 data2 = (data/10.0)*h19a1 + h19a0
                 h19a0 = 2.705
                 h19a1 = 0.985
                 data2 = (data2)*h19a1 + h19a0
                 h19a0 = -1.89
                 h19a1 = 1.013
                 data2 = (data2)*h19a1 + h19a0
                 data = fix(data2*10)
              endif
              if ch eq '19v' then begin
                 ;v19a0 = -4.832989
                 ;v19a1 = 1.0268478
                 ;data2 = (data/10.0)*v19a1 + v19a0
                 v19a0 = 6.704
                 v19a1 = 0.962  ;nick's numbers
                 data2 = (data/10.0)*v19a1 + v19a0
                 v19a0 = 4.875
                 v19a1 = 0.977
                 data2 = (data2)*v19a1 + v19a0
                 v19a0 = -2.51
                 v19a1 = 1.013
                 data2 = (data2)*v19a1 + v19a0
                 data = fix(data2*10)
              endif
              if ch eq '22v' then begin
                 v22a0 = 7.52
                 v22a1 = 0.964
                 data2 = (data/10.0)*v22a1 + v22a0
                 v22a0 = -2.73
                 v22a1 = 1.014
                 data2 = (data2)*v22a1 + v22a0
                 data = fix(data2*10)
              endif
              if ch eq '37h' then begin
                 h37a0 = 6.139
                 h37a1 = 0.967
                 data2 = (data/10.0)*h37a1 + h37a0
                 h37a0 = -4.22
                 h37a1 = 1.024
                 data2 = (data2)*h37a1 + h37a0
                 data = fix(data2*10)
              endif
              if ch eq '37v' then begin
                 ;v37a0 = -1.457553
                 ;v37a1 = 0.999914
                 ;data2 = (data/10.0)*v37a1 + v37a0
                 v37a0 = 5.98
                 v37a1 = 0.9800 ;nicks numbers
                 data2 = (data/10.0)*v37a1 + v37a0
                 v37a0 = -3.28
                 v37a1 = 1.015
                 data2 = (data2)*v37a1 + v37a0
                 v37a0 = 0.052
                 v37a1 = 1.000
                 data2 = (data2)*v37a1 + v37a0
                 data = fix(data2*10)
              endif
                                ;end
;     endif                      ;	1 eq 2

              ;else: foo = 1
           end
else: foo = 1
        endcase

        

     endif


  endif                         ;noadjust

  return, data

end





;           if 1 eq 2 then begin                            ;this is the F17 to AMSR adjustment.
;           case (long(file) ge 2007001 and satf eq '17'): begin ; my own f17 to f13, then stroeve first to f11 and then abdalati to f8, sb 2009001
;              if ch eq '19h' then begin
;                 h19a0 = 6.876359395
;                 h19a1 = 0.978964194
;                 data2 = (data/10.0)*h19a1 + h19a0
;                 data2 = (0.92903290D*data2 + 18.577403)
;                 data = fix(data2*10)
;              endif
;              if ch eq '19v' then begin
;                 v19a0 = -0.43144
;                 v19a1 = 1.011053244
;                 data2 = (data/10.0)*v19a1 + v19a0
;                 data2 = (1.006601D*data2 - 0.1955896)
;                 data = fix(data2*10)
;              endif
;              if ch eq '22v' then begin
;                 v22a0 = 7.52
;                 v22a1 = 0.964
;                 data2 = (data/10.0)*v22a1 + v22a0
;                 v22a0 = -2.73
;                 v22a1 = 1.014
;                 data2 = (data2)*v22a1 + v22a0
;                 data = fix(data2*10)
;              endif
;              if ch eq '37h' then begin
;                 h37a0 = 6.139
;                 h37a1 = 0.967
;                 data2 = (data/10.0)*h37a1 + h37a0
;                 h37a0 = -4.22
;                 h37a1 = 1.024
;                 data2 = (data2)*h37a1 + h37a0
;                 data = fix(data2*10)
;              endif
;              if ch eq '37v' then begin
;                 v37a0 = 4.454251148
;                 v37a1 = 0.975551173
;                 data2 = (data/10.0)*v37a1 + v37a0
;                 data2 = (1.032074D*data2 - 8.5317351)
;                 data = fix(data2*10)
;              endif
;           end;;;;;;


;        endif        ;;                                    ; 1 eq 2 amsr adjustment


