program heresy_reliability_runtime
  implicit none

  character(len=32) :: web_arg, raw_arg
  character(len=40) :: observed_class
  character(len=80) :: diagnostic
  integer :: web_error, raw_error, ios

  call get_command_argument(1, web_arg)
  call get_command_argument(2, raw_arg)

  read(web_arg, *, iostat=ios) web_error
  if (ios /= 0) then
     write(*,'(A)') 'RELIABILITY_INPUT_INVALID'
     error stop 64
  end if

  read(raw_arg, *, iostat=ios) raw_error
  if (ios /= 0) then
     write(*,'(A)') 'RELIABILITY_INPUT_INVALID'
     error stop 64
  end if

  if (web_error < 0 .or. web_error > 100 .or. raw_error < 0 .or. raw_error > 100) then
     write(*,'(A)') 'RELIABILITY_PERCENT_OUT_OF_RANGE'
     error stop 64
  end if

  if (web_error >= 20 .or. raw_error >= 50) then
     observed_class = 'INCIDENT'
  else if (web_error > 0 .or. raw_error > 0) then
     observed_class = 'DEGRADED'
  else
     observed_class = 'NOMINAL'
  end if

  if (raw_error >= 50) then
     diagnostic = 'STATISTICALLY_SPEAKING_THIS_IS_A_COIN'
  else if (raw_error >= 20) then
     diagnostic = 'DOWNLOAD_PATH_IS_NOT_HEALTHY'
  else
     diagnostic = 'DOWNLOAD_PATH_WITHIN_THIS_SPECIMEN_IS_NOT_THE_JOKE'
  end if

  write(*,'(A)') 'RUNTIME=HERESY/360-FORTRAN-RELIABILITY'
  write(*,'(A,A)') 'OBSERVED_CLASS=', trim(observed_class)
  write(*,'(A,A)') 'RAW_DIAGNOSTIC=', trim(diagnostic)
  write(*,'(A)') 'STATUS_PAGE_EUPHEMISM_IS_OBSERVED_FAILURE_RATE=0'
  write(*,'(A)') 'ROOT_CAUSE_INFERRED=0'
end program heresy_reliability_runtime
