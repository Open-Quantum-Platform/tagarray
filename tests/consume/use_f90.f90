program use_f90
  use tagarray
  use, intrinsic :: iso_c_binding, only: c_double, c_int32_t
  implicit none
  type(container_t)       :: c
  real(c_double), pointer :: m(:,:)
  integer(c_int32_t)      :: status
  call c%new()
  status = c%alloc("m", (/ 2, 3 /), m)        ! the v1.0.0 one-line API
  if (status /= TA_OK) error stop "alloc failed"
  m = 0.0d0; m(2,3) = 42.0d0
  print "(A,F5.1)", "consumer F90 ok: ", m(2,3)
  call c%delete()
end program use_f90
