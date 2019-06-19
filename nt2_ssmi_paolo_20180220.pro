pro nt2_ssmi_paolo

for pv = 2018075, 2018075 do begin

   p = strtrim(pv,2)
   ;icpn = get_amsr(p, 'ICECON', 25, 'n', localdir = '/Volumes/data/amsrv12/')
   v19 = get_raid_adjust(p, '19v', 'N', localdir = '/Volumes/Seagate8TB/verdant/pmnew/', /noadjust)/10.0
   h19 = get_raid_adjust(p, '19h', 'N', localdir = '/Volumes/Seagate8TB/verdant/pmnew/', /noadjust)/10.0
   v22 = get_raid_adjust(p, '22v', 'N', localdir = '/Volumes/Seagate8TB/verdant/pmnew/', /noadjust)/10.0
   v37 = get_raid_adjust(p, '37v', 'N', localdir = '/Volumes/Seagate8TB/verdant/pmnew/', /noadjust)/10.0
   h37 = get_raid_adjust(p, '37h', 'N', localdir = '/Volumes/Seagate8TB/verdant/pmnew/', /noadjust)/10.0
   v85 = get_raid_adjust(p, '85v', 'N', localdir = '/Volumes/Seagate8TB/verdant/pmnew/', /noadjust)/10.0
   h85 = get_raid_adjust(p, '85h', 'N', localdir = '/Volumes/Seagate8TB/verdant/pmnew/', /noadjust)/10.0
   v85r = rebin(v85, 304,448,/sample)
   h85r = rebin(h85, 304, 448, /sample)
   msk = get_msk(25, 'N')
   
      
   icn = nt2_working( v19, h19, v22, v37, h37, v85r, h85r, msk,'n', 'ssmi')
                                ;nt2_secondprinciples, v19x, h19x, v22x, v37x, h37x, v85x, h85x, mskx,'n', 'amsr', icn2
   
   openw, un1, '/Volumes/Seagate8TB/verdant/nt2nrt/nt2_'+strtrim(pv,2)+'_f18_nrt.int.304.448.be', /get_lun, /swap_endian ;make GE like the other files
   writeu, un1, icn
   close, un1
   free_lun, un1
   
endfor

end
