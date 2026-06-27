#include "tagarray_assert.fh"

! Tests for the v1.0.0 high-level allocate-and-bind convenience:
!   container%alloc / container%alloc_or_die  and  ta_allocate / ta_allocate_or_die
program test
  use tagarray
  use, intrinsic :: iso_c_binding, only: c_int32_t, c_int64_t, c_double, c_f_pointer
  implicit none
  TEST(check_alloc_ranks)
  TEST(check_alloc_zero_copy)
  TEST(check_alloc_free_form)
  TEST(check_alloc_override)
  TEST(check_alloc_or_die)
  TEST(check_alloc_types)
contains

  ! the generic resolves and binds for every supported element type
  integer(c_int32_t) function check_alloc_types() result(status)
    use, intrinsic :: iso_c_binding, only: c_float, c_double_complex
    type(container_t) :: c
    real(c_double),            pointer :: d(:)
    real(c_float),             pointer :: f(:,:)
    integer(c_int32_t),        pointer :: i4(:)
    integer(c_int64_t),        pointer :: i8(:,:)
    complex(c_double_complex), pointer :: z(:)
    call c%new()
    status = c%alloc("d",  (/ 3 /),    d);  if (status /= TA_OK .or. .not.associated(d))  then; status = 1; return; end if
    status = c%alloc("f",  (/ 2, 2 /), f);  if (status /= TA_OK .or. .not.associated(f))  then; status = 2; return; end if
    status = c%alloc("i4", (/ 4 /),    i4); if (status /= TA_OK .or. .not.associated(i4)) then; status = 3; return; end if
    status = c%alloc("i8", (/ 2, 3 /), i8); if (status /= TA_OK .or. .not.associated(i8)) then; status = 4; return; end if
    status = c%alloc("z",  (/ 5 /),    z);  if (status /= TA_OK .or. .not.associated(z))  then; status = 5; return; end if
    ! exercise the bound storage of each
    d = 1._c_double; f = 2._c_float; i4 = 3_c_int32_t; i8 = 4_c_int64_t
    z = (1._c_double_complex, -1._c_double_complex)
    if (abs(d(3) - 1) > 0 .or. abs(f(2,2) - 2) > 0) then; status = 6; return; end if
    if (i4(1) /= 3 .or. i8(2,3) /= 4) then; status = 7; return; end if
    if (abs(real(z(5)) - 1) > 0 .or. abs(aimag(z(5)) + 1) > 0) then; status = 8; return; end if
    call c%delete()
    status = 0
  end function check_alloc_types

  ! alloc binds a usable, correctly-shaped pointer for ranks 1-3
  integer(c_int32_t) function check_alloc_ranks() result(status)
    type(container_t) :: c
    real(c_double), pointer :: v1(:), v2(:,:), v3(:,:,:)
    call c%new()
    status = c%alloc("v1", (/ 4 /), v1)
    if (status /= TA_OK) then; status = 1; return; end if
    if (.not.associated(v1) .or. size(v1) /= 4) then; status = 2; return; end if

    status = c%alloc("v2", (/ 2, 3 /), v2)
    if (status /= TA_OK) then; status = 3; return; end if
    if (.not.associated(v2)) then; status = 4; return; end if
    if (size(v2,1) /= 2 .or. size(v2,2) /= 3) then; status = 5; return; end if

    status = c%alloc("v3", (/ 2, 3, 4 /), v3, description="a 3-D block")
    if (status /= TA_OK) then; status = 6; return; end if
    if (.not.associated(v3)) then; status = 7; return; end if
    if (size(v3,1) /= 2 .or. size(v3,2) /= 3 .or. size(v3,3) /= 4) then; status = 8; return; end if

    call c%delete()
    status = 0
  end function check_alloc_ranks

  ! data written through the bound pointer lives in the container (zero-copy)
  integer(c_int32_t) function check_alloc_zero_copy() result(status)
    type(container_t) :: c
    type(recordinfo_t) :: rec
    real(c_double), pointer :: p(:,:), q(:,:)
    call c%new()
    status = c%alloc("mat", (/ 2, 2 /), p)
    if (status /= TA_OK) then; status = 1; return; end if
    p = reshape((/ 10._c_double, 20._c_double, 30._c_double, 40._c_double /), (/ 2, 2 /))
    ! re-fetch the record independently and confirm the bytes are there
    rec = c%get("mat")
    call c_f_pointer(rec%data, q, rec%dims)
    if (any(abs(q - p) > 0)) then; status = 2; return; end if
    if (abs(q(2,2) - 40._c_double) > 0) then; status = 3; return; end if
    call c%delete()
    status = 0
  end function check_alloc_zero_copy

  ! the free-function spelling ta_allocate is equivalent
  integer(c_int32_t) function check_alloc_free_form() result(status)
    type(container_t) :: c
    real(c_double), pointer :: v(:)
    call c%new()
    status = ta_allocate(c, "free", (/ 5 /), v)
    if (status /= TA_OK) then; status = 1; return; end if
    if (.not.associated(v) .or. size(v) /= 5) then; status = 2; return; end if
    v = 7._c_double
    if (abs(v(3) - 7._c_double) > 0) then; status = 3; return; end if
    call c%delete()
    status = 0
  end function check_alloc_free_form

  ! override defaults to .true. (replace); override=.false. rejects duplicates
  integer(c_int32_t) function check_alloc_override() result(status)
    type(container_t) :: c
    real(c_double), pointer :: p(:)
    call c%new()
    status = c%alloc("x", (/ 3 /), p)
    if (status /= TA_OK) then; status = 1; return; end if
    ! default override replaces an existing record
    status = c%alloc("x", (/ 6 /), p)
    if (status /= TA_OK) then; status = 2; return; end if
    if (size(p) /= 6) then; status = 3; return; end if
    ! create-only semantics: duplicate must be rejected
    status = c%alloc("x", (/ 3 /), p, override=.false.)
    if (status /= TA_CONTAINER_RECORD_EXISTS) then; status = 4; return; end if
    if (associated(p)) then; status = 5; return; end if
    call c%delete()
    status = 0
  end function check_alloc_override

  ! alloc_or_die succeeds silently on the happy path and binds the pointer
  integer(c_int32_t) function check_alloc_or_die() result(status)
    type(container_t) :: c
    real(c_double), pointer :: p(:,:)
    call c%new()
    call c%alloc_or_die("ok", (/ 3, 3 /), p)
    if (.not.associated(p) .or. size(p) /= 9) then; status = 1; return; end if
    call ta_allocate_or_die(c, "ok2", (/ 2, 2 /), p)
    if (.not.associated(p) .or. size(p) /= 4) then; status = 2; return; end if
    call c%delete()
    status = 0
  end function check_alloc_or_die

end program test
