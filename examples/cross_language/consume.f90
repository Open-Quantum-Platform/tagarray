! Cross-language demo, step 2: a Fortran program reads the file the C++ program
! wrote -- the SAME bytes, no conversion. This is what tagarray is for.
program consume
  use tagarray
  use, intrinsic :: iso_c_binding, only: c_double, c_f_pointer
  implicit none
  type(container_t)       :: c
  type(recordinfo_t)      :: rec
  real(c_double), pointer :: mat(:,:)
  character(len=256)      :: path
  integer                 :: n
  call get_command_argument(1, path, n)
  if (n == 0) path = "shared.ta"
  call c%load(trim(path))
  rec = c%get("mat")
  if (.not. rec%is_associated()) error stop "mat not found in file"
  call c_f_pointer(rec%data, mat, rec%dims)
  print "(A,2I2,A,A)", "F90  : read mat shape (", int(rec%dims), " ) desc='", &
                       trim(rec%description)//"'"
  print "(A,6F4.0)", "F90  : mat = ", mat
  call c%delete()
end program consume
