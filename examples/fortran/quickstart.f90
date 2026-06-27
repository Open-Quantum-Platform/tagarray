! tagarray Fortran quickstart.
!
! The high-level c%alloc convenience (added in v1.0.0) creates a
! container-owned array AND binds a typed Fortran pointer to it in ONE call,
! replacing the create -> get -> get_status -> c_f_pointer ritual.
program quickstart
  use tagarray
  use, intrinsic :: iso_c_binding, only: c_double, c_int32_t
  implicit none
  type(container_t)       :: c
  real(c_double), pointer :: vec(:), mat(:,:)
  integer(c_int32_t)      :: status

  call c%new("fortran-quickstart")

  ! one line: allocate "vec" and bind `vec` to its storage
  status = c%alloc("vec", (/ 3 /), vec)
  if (status /= TA_OK) error stop get_status_message(status, "vec")
  vec = (/ 1.0d0, 2.0d0, 3.0d0 /)
  print "(A,3F5.1)", "F90 : vec =", vec

  ! fail-fast variant: aborts with a message on error, no status to check
  call c%alloc_or_die("mat", (/ 2, 2 /), mat)
  mat = reshape((/ 1.0d0, 2.0d0, 3.0d0, 4.0d0 /), (/ 2, 2 /))
  print "(A,F5.1)", "F90 : mat(2,2) =", mat(2,2)

  call c%delete()
end program quickstart
