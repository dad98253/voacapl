! dst2ascii. Convert a .DST binary record file into an ASCII table.
!
! Copyright (C) 2018 J.Watson
!
! This program is free software: you can redistribute it and/or modify
! it under the terms of the GNU General Public License as published by
! the Free Software Foundation, either version 3 of the License, or
! (at your option) any later version.
!
! This program is distributed in the hope that it will be useful,
! but WITHOUT ANY WARRANTY; without even the implied warranty of
! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
! GNU General Public License for more details.

! You should have received a copy of the GNU General Public License
! along with this program.  If not, see <https://www.gnu.org/licenses/>.

program dst2ascii
    logical*1 file_exists
    real :: gcdkm, xlat, xlon, MUF, FOT, ANGLE, DELAY, VHITE, MUFday, LOSS
    real :: DBU, SDBW, NDBW, SNR, RPWRG, REL, MPROB, SPRB, SIGLW, SIGUP, SNRLW, SNRUP
    real :: TGAIN, RGAIN, SNRxx, DBM
    integer :: num_args
    character(len=128) :: data_dir_path = ""
    integer :: ios
    integer :: NUMDIST, NUMFREQ, NUMHOUR
    real, dimension(1 : 25) :: FREQS
    integer, dimension(1 : 25) :: hours
    integer, parameter :: IDX_FILE = 70
    integer, parameter :: DST_FILE = 80
    integer, parameter :: ASC_FILE = 90
    integer :: HOURBLK
    integer :: ptr, utcPtr, freqPtr, offset, id = 0
    character(200) :: index_buffer
    character(4) :: xmode
    character(120) :: RUN_DIR
    character(len=1), parameter :: PATH_SEPARATOR ='/'
    character(len=128) :: idx_path, dst_path, asc_path

    num_args = command_argument_count()

    if (num_args == 1) then
        call get_command_argument(1, data_dir_path)
        idx_path = trim(data_dir_path)//PATH_SEPARATOR//'voacapd.idx'
        dst_path = trim(data_dir_path)//PATH_SEPARATOR//'voacapd.dst'
        asc_path = trim(data_dir_path)//PATH_SEPARATOR//'voacapd.asc'
    else
        idx_path = 'voacapd.idx'
        dst_path = 'voacapd.dst'
        asc_path = 'voacapd.asc'
    end if

    inquire(file=idx_path, exist=file_exists)
    if (.not.file_exists) then
        write(*,'(''Unable to open IDX file : '',a)') idx_path
        stop
    end if

    inquire(file=dst_path, exist=file_exists)
    if (.not.file_exists) then
        write(*,'(''Unable to open DST file : '',a)') dst_path
        stop
    end if

    open(IDX_FILE, file=idx_path, status='old')
    ! Read the number of distances
    read(IDX_FILE, '(I5A)') NUMDIST, index_buffer

    ! Read the frequencies
    read(IDX_FILE, '(I2A)') NUMFREQ, index_buffer
    do freqPtr = 1, NUMFREQ
        offset = 1 + (7*(freqPtr-1))
        read(index_buffer((offset): (offset+7)), '(F7.3)') FREQS(freqPtr)
    end do

    ! Read the hours
    read(IDX_FILE, '(I3A)') NUMHOUR, index_buffer
    do ptr = 1, NUMHOUR
        offset = 1 + (3*(ptr-1))
        read(index_buffer((offset): (offset+3)), '(I3)') hours(ptr)
    end do

    close(IDX_FILE)

    HOURBLK = NUMDIST * NUMFREQ

    open(DST_FILE,file=dst_path,status='old', form='unformatted',access='direct',recl=108)
    open(ASC_FILE,file=asc_path)
    rewind(ASC_FILE)

    do utcPtr = 1, NUMHOUR
        write(ASC_FILE, '(AI2A)') "UTC:", utcPtr, ":00"
        do freqPtr = 1, 8
            write(ASC_FILE, '(AF6.3A)') "Freq:", freqs(freqPtr), "MHz"
            write(ASC_FILE, '(A3, A8, 2A10, A5, 23A8)') "id", "gcdkm", "Latitude", "Longitude", "Mode", &
                    "MUF", "FOT", "ANGLE", "DELAY", "VHITE", "MUFday", "LOSS", "DBU", "SDBW", "NDBW", "SNR", &
                    "RPWRG", "REL", "MPROB", "SPRB", "SIGLW", "SIGUP", "SNRLW", "SNRUP", "TGAIN", "RGAIN",  &
                    "SNRxx", "DBM"
            do ptr = NUMDIST-1, 0, -1
                read(DST_FILE, rec=((utcPtr-1)*HOURBLK)+(ptr*8)+freqPtr ) gcdkm,xlat,xlon,xmode, MUF, &
                    FOT, ANGLE, DELAY, VHITE, MUFday, LOSS, DBU, SDBW, &
                    NDBW, SNR, RPWRG, REL, MPROB, SPRB, SIGLW, SIGUP, &
                    SNRLW, SNRUP, TGAIN, RGAIN, SNRxx, DBM
                write(ASC_FILE, '(I3, F8.1, 2F10.4, A5, 23F8.3)') NUMDIST-ptr, gcdkm, xlat, xlon, xmode, MUF, FOT, ANGLE, &
                    DELAY, VHITE, MUFday, LOSS, DBU, SDBW, NDBW, SNR, RPWRG, REL, MPROB, SPRB, SIGLW, SIGUP, &
                    SNRLW, SNRUP, TGAIN, RGAIN, SNRxx, DBM
            end do
        end do
    end do
    close(DST_FILE)
    close(ASC_FILE)
end program dst2ascii
