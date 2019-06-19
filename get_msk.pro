Function get_msk, res, nos, ease = ease
	;** Returns Landmask 
	;** res = Resolution (6.25,12.5 or 25 km) (6,12,25)
	;** nos = Hemisphere ('N' or 'S')
	;** ease = 1 if requesting easegrid landmask

if n_elements(ease) eq 0 then ease = 0
nos = strupcase(nos)
if ease eq 1 then begin
	if (nos eq 'N') then begin
		;
		;		landmask
		;
		msk = intarr(721,721)
		openr,1,'/Users/jamiller/Documents/disk6items/nleasemask.int.721.721', /swap_endian
		readu,1,msk
		close,1
	endif else begin
		;
		;		landmask
		;
		msk = intarr(721,721)
		openr,1,'/Users/jamiller/Documents/data/EASEtbs/sleasemask.int.721.721', /swap_endian
		readu,1,msk
		close,1
	endelse
	return, msk
endif else begin
	file='xxx'
	
	if (fix(res) eq 6) then begin
		if (nos eq 'N') then begin
		msk=intarr(1216,1792) 
		file='north_land_6_25'
		endif else begin
		msk=intarr(1264,1328)
		file='south_land_6_25'
		endelse
	endif
	
	if (fix(res) eq 12) then begin
		if (nos eq 'N') then begin
		msk=intarr(608,896)
		file='landmask_north_125'
		endif else begin
		msk=intarr(632,664)
		file='landmask_south_125'
		endelse
	endif
	
	if (fix(res) eq 25) then begin
		if (nos eq 'N') then begin
		msk=intarr(304,448)
		file='landmask_north_25'
		endif else begin
		msk=intarr(316,332)
		file='landmask_south_25'
		endelse
	endif
	
	if (file eq 'xxx') then begin 
		print, '***Wrong Parameters***'
		return, -1
	endif else begin
		head=bytarr(300)
		openr, 99, '/Users/jamiller/Documents/disk6items/'+file, /swap_if_little_endian
		readu, 99, head
		readu, 99, msk
		close, 99
		return, msk
	endelse
endelse

end
