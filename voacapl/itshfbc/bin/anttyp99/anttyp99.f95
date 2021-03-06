!--------------------------------------------------------------
!# anttyp99.for
!***********************************************************************
PROGRAM anttyp99
!***********************************************************************
! Calculate an exteranl antenna file.
! Assumes data is in the format of:
!       ..\antennas\samples\sample.90
! Execute with:
!    anttyp99 directory mode
! where:
!    directory = full pathname to the RUN directory (e.g. c:\ITSHFBC\RUN)
!    mode      = (blank) = Point-to-Point
!              = a = Area Coverage
!***********************************************************************

    use Cant99
    
    implicit none

    real                :: elev, azimuth, freq, g 
    real                :: xfqs,xfqe,designfreq, aeff
    real                :: beammain,offazim,cond,diel
    real, dimension(91) :: gain
    character(len=24)   :: antfile
    character(len=80)   :: filename, gainfilename
    character(len=120)  :: run_directory, root_directory, arg
    character(len=1)    :: mode
    integer             :: idx, iel, iazim, ifreq
    integer, parameter  :: dat_file_un = 21
    integer, parameter  :: gain_file_un = 22
    integer, parameter  :: lua = 42

    !HARRIS_INTERP controls compatibility compatibility with the 
    !Harris version with produces gain tables with the azimuth 
    !rounded to the nearest degree.
    !HARRIS_INTERP = .false. should produce more accurate
    !gain tables, interpolated to the exact azimuth.
    !
    logical, parameter  :: HARRIS_INTERP = .true.

    !HARRIS_LOWER_LIMIT Controls the format of the lower limit.  The
    !Harris version prints the value -99.990 as -99.999 (although the 
    !value -99.990 appears to be used in the interpolation).

    logical, parameter  :: HARRIS_LOWER_LIMIT = .true.
      
!...START OF PROGRAM
    mode = " "
! We need to consider two forms of command args;
! anttype99 rundir [mode]
! anttype99 rundir rootdir [mode]
    call GET_COMMAND_ARGUMENT(1, run_directory)
    if (COMMAND_ARGUMENT_COUNT().eq.1) then
        root_directory = run_directory(1:len(trim(run_directory))-3)
    else if (COMMAND_ARGUMENT_COUNT().eq.2) then
        call GET_COMMAND_ARGUMENT(2, arg)
        if (len(trim(arg)).eq.1) then
            call GET_COMMAND_ARGUMENT(2, mode)
        else
            call GET_COMMAND_ARGUMENT(2, root_directory)
        end if
    else if (COMMAND_ARGUMENT_COUNT().eq.3) then
            call GET_COMMAND_ARGUMENT(2, root_directory)
            call GET_COMMAND_ARGUMENT(3, mode)
    end if
    open(dat_file_un,file=trim(run_directory)//'/anttyp99.dat', position='rewind', status='old',err=900)
    read(dat_file_un,*,err=920) idx          !  antenna index #, GAINxx.dat
    read(dat_file_un,'(a)',err=920) antfile  !  antenna file name
    read(dat_file_un,*,err=920) xfqs         !  starting frequency
    read(dat_file_un,*,err=920) xfqe         !  ending frequency
    read(dat_file_un,*,err=920) beammain     !  main beam (deg from North)
    read(dat_file_un,*,err=920) offazim      !  off azimuth (deg from North)
    close(dat_file_un)

    filename=trim(root_directory)//'/antennas/'//trim(antfile)
    call ant99_read(filename,21,lua,*910)
    diel=parms(3)         !  dielectric constant
    cond=parms(4)         !  conductivity
    write(gainfilename,1) trim(run_directory),idx
1   format(a,5h/gain,i2.2,4h.dat)

    open(gain_file_un,file=gainfilename, position='rewind')
    write(gain_file_un,'(a)') 'HARRIS99  '//title

    if(len(trim(mode)).eq.0) then
!****************************************************************
!                  Point-to-Point mode
!****************************************************************
        write(gain_file_un,2) xfqs,xfqe,beammain,offazim,cond,diel
2       format(2f5.0,2f7.2,2f10.5)
        azimuth=offazim
        if (HARRIS_INTERP) azimuth = real(nint(azimuth))
        do ifreq=1,30
            freq=ifreq
            if(freq.ge.xfqs .and. freq.le.xfqe) then !  in frequency range
                do iel=0,90
                    elev=iel
                    call ant99_calc(freq,azimuth,elev,gain(iel+1),aeff,*940)
                end do
            else                                     !  outside freq range
                aeff=0.
                do iel=0,90
                    gain(iel+1)=0.
                end do
            end if
            if (HARRIS_LOWER_LIMIT) then
                where (gain.lt.-99.9) gain=-99.999
            end if
            write(gain_file_un,3) ifreq,aeff,gain
3           format(i2,f6.2,(T10,10F7.3))
        end do
    else

!****************************************************************
!                    Area Coverage mode
!****************************************************************
        write(gain_file_un,2) 2.0,xfqe,beammain,-999.,cond,diel
        freq=xfqs
        call ant99_calc(freq,0.,8.,g,aeff,*940)
        write(gain_file_un,201) freq,aeff
201     format(10x,f7.3,'MHz eff=',f10.3)
        do iazim=0,359
            azimuth=iazim
            do iel=0,90
                elev=iel
                !write(*, '(A F12.6)') 'call az = ', azimuth
                call ant99_calc(freq,azimuth,elev,gain(iel+1),aeff,*940)
            end do
            write(gain_file_un,251) iazim, gain
251         format(i5,(T10,10F7.3))
        end do
    end if 
!****************************************************************
    call ant99_close      !Close the scratch file
    close(gain_file_un)
!****************************************************************
    go to 999
!****************************************************************
900 write(*,901) trim(run_directory)//'/anttyp99.dat'
901 format(' In anttyp99, could not OPEN file=',a)
    stop 'OPEN error in anttyp99 at 900'
910 write(*,911) filename
911 format(' In anttyp99, error READing file=',a)
    stop 'READ error in anttyp99 at 910'
920 write(*,921) trim(run_directory)//'/anttyp99.dat'
921 format(' In anttyp99, error READing file=',a)
    stop 'READ error in anttyp99 at 920'
!***********************************************************************
930 write(*,931)
931 format('anttyp99 must be executed:',&
        '1. Point-to-Point:',&
        '   anttyp99.exe run_directory',&
        '4. Area Coverage:',&
        '   icepacw.exe run_directory a')
    write(*,932)
932 format(&
        'Where:',&
        '      run_directory = full pathname to RUN directory',&
        '                      (e.g. /home/usr_name/itshfbc/run)')
    stop 'anttyp99 not executed properly.'
940 write(*,941) filename
941 format(' In anttyp99, error Calculating from file=',a)
    stop 'READ error in ANTTYP99 at 940'
!***********************************************************************
999 continue
end
