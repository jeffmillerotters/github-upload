Function i2koord, in, xsize

  koor=intarr(2,n_elements(in))	;*** 0=x, 1=y

  koor(1,*)=in/fix(xsize)
  koor(0,*)=in-(koor(1,*)*xsize)

  return, koor

end

Function nt2_working, v19, h19, v22, v37, h37, v85, h85, msk, hemi, sens
;
;		updated 6/3/09 to use new user directory (prev edit
;		was october 19, 2006)
;               updated 1/27/2010 to use new directories, and fix
;               endian byteswapping on the intel mac
;		updated 2/3/2010 to add gr2219 weather filter
;
;***** v19, h19, etc. are brightness temperatures
;***** They can be single numbers, vectors or 2D arrays
;*****
;***** msk is a variable that contains land info
;***** and must have the same dimensions as the TBs
;***** 0 is for ocean
;***** 
;***** hemi must either be 'S' or 'N' 
;*****
;***** The function returns the ice concentration in %
;***** land is 117, missing is 255
;
;***** sens is either 'amsr' or 'ssmi'

  if n_elements(sens) eq 0 then sens = 'amsr'; else sens = 'ssmi'
  ;if sens eq 'amsr' then sens = 'amsr_reg'
  hemi = strupcase(hemi)

  v19=v19
  h19=h19
  v22=v22
  v37=v37
  h37=h37
  v85=v85
  h85=h85




;*** Number of atmospheres
  n_atm=12
;n_atm=1

  ss=size(msk)
  if (ss(0) eq 0) then begin    ;*** TBs are scalars
     xs=1
     ys=1
  endif
  if (ss(0) eq 1) then begin	;*** TBs are vectors
     xs=ss(1)
     ys=1
  endif
  if (ss(0) eq 2) then begin	;*** TBs are 2-D arrays
     xs=ss(1)
     ys=ss(2)
  endif


  pr19=(1.*v19-h19)/(1.*v19+h19)
  pr37=(1.*v37-h37)/(1.*v37+h37)
  pr85=(1.*v85-h85)/(1.*v85+h85)
  gr=(1.*v37-v19)/(1.*v37+v19)
  gr22v=(1.*v22-v19)/(1.*v22+v19)
  gr8519v=(1.*v85-v19)/(1.*v85+v19)
  gr8519h=(1.*h85-h19)/(1.*h85+h19)


  if (hemi eq 'S') then begin
     phi19=-0.59D
     phi85=-0.40D
  endif else begin
     phi19=-0.18D
     phi85=-0.06D
  endelse

  pr19R=-gr*sin(phi19)+pr19*cos(phi19)
  pr85R=-gr*sin(phi85)+pr85*cos(phi85)
  dgr=gr8519h-gr8519v


;*** Read model data
  tbow=fltarr(7,n_atm)
  tbfy=fltarr(7,n_atm)
  tbcc=fltarr(7,n_atm)
  tbthin=fltarr(7,n_atm)

  if (hemi eq 'S') then hemis='ant' else hemis='ark'
  tpath = '/Users/jamiller/Documents/disk6items/RTM/4icneu/'
  openr, 9, tpath+'TBow'+hemis+'.tab.'+sens, /swap_if_little_endian
  readf, 9, tbow
  close, 9
  openr, 9, tpath+'TBfy'+hemis+'.tab.'+sens, /swap_if_little_endian
  readf, 9, tbfy
  close, 9
  openr, 9, tpath+'TBcc'+hemis+'.tab.'+sens, /swap_if_little_endian
  readf, 9, tbcc
  close, 9


  if (hemi eq 'N') then begin
     openr, 9, tpath+'TBthark.tab.'+sens, /swap_if_little_endian
     readf, 9, tbthin
     close, 9
  endif
;**********

;**** Create LUT ****
;	LUT19=fltarr(101,101,n_atm)
;	LUT85=fltarr(101,101,n_atm)
;	LUTGR=fltarr(101,101,n_atm)
;	LUT19thin=fltarr(101,101,n_atm)
;	LUT85thin=fltarr(101,101,n_atm)
;	LUTGR37=fltarr(101,101,n_atm)

  LUT19=dblarr(101,101,n_atm)
  LUT85=dblarr(101,101,n_atm)
  LUTGR=dblarr(101,101,n_atm)
  LUT19thin=dblarr(101,101,n_atm)
  LUT85thin=dblarr(101,101,n_atm)
  LUTGR37=dblarr(101,101,n_atm)

  LUT19(*,*,*)=10000.
  LUT85(*,*,*)=10000.
  LUTGR(*,*,*)=10000.
  LUT19thin(*,*,*)=10000.
  LUT85thin(*,*,*)=10000.
  LUTGR37(*,*,*)=10000.
  for ca=0,100 do begin
     for cb=0,100-ca do begin
        caf=ca/100.
        cbf=cb/100.
        tb19h=(1.-caf-cbf)*tbow(0,*)+caf*tbfy(0,*)+cbf*tbcc(0,*)
        tb19v=(1.-caf-cbf)*tbow(1,*)+caf*tbfy(1,*)+cbf*tbcc(1,*)
        tb37v=(1.-caf-cbf)*tbow(4,*)+caf*tbfy(4,*)+cbf*tbcc(4,*)
        tb85h=(1.-caf-cbf)*tbow(5,*)+caf*tbfy(5,*)+cbf*tbcc(5,*)
        tb85v=(1.-caf-cbf)*tbow(6,*)+caf*tbfy(6,*)+cbf*tbcc(6,*)

        tb19ht=(1.-caf-cbf)*tbow(0,*)+caf*tbfy(0,*)+cbf*tbthin(0,*)
        tb19vt=(1.-caf-cbf)*tbow(1,*)+caf*tbfy(1,*)+cbf*tbthin(1,*)
        tb37vt=(1.-caf-cbf)*tbow(4,*)+caf*tbfy(4,*)+cbf*tbthin(4,*)
        tb85ht=(1.-caf-cbf)*tbow(5,*)+caf*tbfy(5,*)+cbf*tbthin(5,*)
        tb85vt=(1.-caf-cbf)*tbow(6,*)+caf*tbfy(6,*)+cbf*tbthin(6,*)

        LUT19(ca,cb,*)=-((tb37v-tb19v)/(tb37v+tb19v))*sin(phi19)+    $
                       ((tb19v-tb19h)/(tb19v+tb19h))*cos(phi19)
        LUT85(ca,cb,*)=-((tb37v-tb19v)/(tb37v+tb19v))*sin(phi85)+    $
                       ((tb85v-tb85h)/(tb85v+tb85h))*cos(phi85)

        LUT19thin(ca,cb,*)=-((tb37vt-tb19vt)/(tb37vt+tb19vt))*sin(phi19)+    $
                           ((tb19vt-tb19ht)/(tb19vt+tb19ht))*cos(phi19)
        LUT85thin(ca,cb,*)=-((tb37vt-tb19vt)/(tb37vt+tb19vt))*sin(phi85)+    $
                           ((tb85vt-tb85ht)/(tb85vt+tb85ht))*cos(phi85)

        LUTGR(ca,cb,*)=(tb85h-tb19h)/(tb85h+tb19h) - (tb85v-tb19v)/(tb85v+tb19v)
        LUTGR37(ca,cb,*)=(tb37vt-tb19vt)/(tb37vt+tb19vt)

     endfor
  endfor
;**********************
  
  c=bytarr(xs,ys)

  w85=1.0
  w19=1.0
  wgr=1.0


  for x=0L,xs-1 do begin
;		print, x
     for y=0L,ys-1 do begin
;			print, x,y


        if ((msk(x,y) eq 0)and(v19(x,y) gt 50)and(v85(x,y) gt 50)and(gr(x,y) lt 0.05) and (gr22v(x,y) lt 0.045)) then begin
                                ;		if ((msk(x,y) eq 0)and(v19(x,y) gt 50)and(v85(x,y) gt 50)) then begin

                                ;------------------------------------------

           pr19ri=pr19r(x,y)
           pr85ri=pr85r(x,y)
           dgri=dgr(x,y)
           gri=gr(x,y)

           camina=intarr(n_atm)
           ccmina=intarr(n_atm)
           dmina=dblarr(n_atm)
           dmina(*)=1000.D

           for k=0,n_atm-1 do begin
              if ((hemi eq 'N')and(gri gt -0.01)) then begin
                 dpr19=pr19ri-reform(LUT19thin(*,*,k))
                 dpr85=pr85ri-reform(LUT85thin(*,*,k))
                 ddgr=gri-reform(LUTGR37(*,*,k))
              endif else begin
                 dpr19=pr19ri-reform(LUT19(*,*,k))
                 dpr85=pr85ri-reform(LUT85(*,*,k))
                 ddgr=dgri-reform(LUTGR(*,*,k))
              endelse

              d=min(w19*dpr19*dpr19+w85*dpr85*dpr85+wgr*ddgr*ddgr, minloc)
              
              result = i2koord(minloc, 101)
              res2 = array_indices(reform(LUT19thin(*,*,k)), minloc)

;              camina(k)=result(0)
 ;             ccmina(k)=result(1)
              camina(k)=res2(0)
              ccmina(k)=res2(1)
              dmina(k)=d
           endfor

           dsort = sort(dmina)
           bestk = dsort(0)

           c(x,y)=camina(bestk)+ccmina(bestk)
                                ;------------------------------------------

        endif else begin
           if (gr(x,y) ge 0.05) then c(x,y)=0						;*** Wx filter
           if ((v19(x,y) lt 50)or(v85(x,y) lt 50)) then c(x,y)=255                      ;*** missing data
           if (msk(x,y) ne 0) then c(x,y)=117						;*** land
        endelse
     endfor
  endfor

  
  return ,c

end

