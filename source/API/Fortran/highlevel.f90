module tagarray_highlevel
  !! Free-function spellings of the high-level allocate-and-bind convenience.
  !!
  !! Thin wrappers around the type-bound `container%alloc` / `container%alloc_or_die`
  !! for users who prefer a procedural call style:
  !!
  !!   status = ta_allocate(c, tag, shape, ptr [, description] [, override])
  !!   call   ta_allocate_or_die(c, tag, shape, ptr [, description] [, override])
  !!
  !! Both spellings are fully equivalent; see container.f90 for the semantics.
  !! Supported element types: real64, real32, int32, int64, complex(real64);
  !! pointer ranks 1-3. The TA_TYPE_* id is inferred from the pointer kind.
  use, intrinsic :: iso_c_binding, only: c_int32_t, c_int64_t, c_float, c_double, c_double_complex
  use tagarray_defines,   only: TA_CHAR
  use tagarray_container, only: container_t
  implicit none
  private

  interface ta_allocate
    module procedure ta_allocate_r64_1, ta_allocate_r64_2, ta_allocate_r64_3
    module procedure ta_allocate_r32_1, ta_allocate_r32_2, ta_allocate_r32_3
    module procedure ta_allocate_i32_1, ta_allocate_i32_2, ta_allocate_i32_3
    module procedure ta_allocate_i64_1, ta_allocate_i64_2, ta_allocate_i64_3
    module procedure ta_allocate_c64_1, ta_allocate_c64_2, ta_allocate_c64_3
  end interface ta_allocate

  interface ta_allocate_or_die
    module procedure ta_allocate_die_r64_1, ta_allocate_die_r64_2, ta_allocate_die_r64_3
    module procedure ta_allocate_die_r32_1, ta_allocate_die_r32_2, ta_allocate_die_r32_3
    module procedure ta_allocate_die_i32_1, ta_allocate_die_i32_2, ta_allocate_die_i32_3
    module procedure ta_allocate_die_i64_1, ta_allocate_die_i64_2, ta_allocate_die_i64_3
    module procedure ta_allocate_die_c64_1, ta_allocate_die_c64_2, ta_allocate_die_c64_3
  end interface ta_allocate_or_die

  public :: ta_allocate, ta_allocate_or_die

contains

  integer(c_int32_t) function ta_allocate_r64_1(c, tag, dshape, ptr, description, override) result(status)
    type(container_t),                        intent(inout) :: c
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    real(c_double),                  pointer, intent(out)   :: ptr(:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    status = c%alloc(tag, dshape, ptr, description=description, override=override)
  end function ta_allocate_r64_1

  integer(c_int32_t) function ta_allocate_r64_2(c, tag, dshape, ptr, description, override) result(status)
    type(container_t),                        intent(inout) :: c
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    real(c_double),                  pointer, intent(out)   :: ptr(:,:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    status = c%alloc(tag, dshape, ptr, description=description, override=override)
  end function ta_allocate_r64_2

  integer(c_int32_t) function ta_allocate_r64_3(c, tag, dshape, ptr, description, override) result(status)
    type(container_t),                        intent(inout) :: c
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    real(c_double),                  pointer, intent(out)   :: ptr(:,:,:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    status = c%alloc(tag, dshape, ptr, description=description, override=override)
  end function ta_allocate_r64_3

  integer(c_int32_t) function ta_allocate_r32_1(c, tag, dshape, ptr, description, override) result(status)
    type(container_t),                        intent(inout) :: c
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    real(c_float),                  pointer, intent(out)   :: ptr(:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    status = c%alloc(tag, dshape, ptr, description=description, override=override)
  end function ta_allocate_r32_1

  integer(c_int32_t) function ta_allocate_r32_2(c, tag, dshape, ptr, description, override) result(status)
    type(container_t),                        intent(inout) :: c
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    real(c_float),                  pointer, intent(out)   :: ptr(:,:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    status = c%alloc(tag, dshape, ptr, description=description, override=override)
  end function ta_allocate_r32_2

  integer(c_int32_t) function ta_allocate_r32_3(c, tag, dshape, ptr, description, override) result(status)
    type(container_t),                        intent(inout) :: c
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    real(c_float),                  pointer, intent(out)   :: ptr(:,:,:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    status = c%alloc(tag, dshape, ptr, description=description, override=override)
  end function ta_allocate_r32_3

  integer(c_int32_t) function ta_allocate_i32_1(c, tag, dshape, ptr, description, override) result(status)
    type(container_t),                        intent(inout) :: c
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    integer(c_int32_t),                  pointer, intent(out)   :: ptr(:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    status = c%alloc(tag, dshape, ptr, description=description, override=override)
  end function ta_allocate_i32_1

  integer(c_int32_t) function ta_allocate_i32_2(c, tag, dshape, ptr, description, override) result(status)
    type(container_t),                        intent(inout) :: c
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    integer(c_int32_t),                  pointer, intent(out)   :: ptr(:,:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    status = c%alloc(tag, dshape, ptr, description=description, override=override)
  end function ta_allocate_i32_2

  integer(c_int32_t) function ta_allocate_i32_3(c, tag, dshape, ptr, description, override) result(status)
    type(container_t),                        intent(inout) :: c
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    integer(c_int32_t),                  pointer, intent(out)   :: ptr(:,:,:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    status = c%alloc(tag, dshape, ptr, description=description, override=override)
  end function ta_allocate_i32_3

  integer(c_int32_t) function ta_allocate_i64_1(c, tag, dshape, ptr, description, override) result(status)
    type(container_t),                        intent(inout) :: c
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    integer(c_int64_t),                  pointer, intent(out)   :: ptr(:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    status = c%alloc(tag, dshape, ptr, description=description, override=override)
  end function ta_allocate_i64_1

  integer(c_int32_t) function ta_allocate_i64_2(c, tag, dshape, ptr, description, override) result(status)
    type(container_t),                        intent(inout) :: c
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    integer(c_int64_t),                  pointer, intent(out)   :: ptr(:,:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    status = c%alloc(tag, dshape, ptr, description=description, override=override)
  end function ta_allocate_i64_2

  integer(c_int32_t) function ta_allocate_i64_3(c, tag, dshape, ptr, description, override) result(status)
    type(container_t),                        intent(inout) :: c
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    integer(c_int64_t),                  pointer, intent(out)   :: ptr(:,:,:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    status = c%alloc(tag, dshape, ptr, description=description, override=override)
  end function ta_allocate_i64_3

  integer(c_int32_t) function ta_allocate_c64_1(c, tag, dshape, ptr, description, override) result(status)
    type(container_t),                        intent(inout) :: c
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    complex(c_double_complex),                  pointer, intent(out)   :: ptr(:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    status = c%alloc(tag, dshape, ptr, description=description, override=override)
  end function ta_allocate_c64_1

  integer(c_int32_t) function ta_allocate_c64_2(c, tag, dshape, ptr, description, override) result(status)
    type(container_t),                        intent(inout) :: c
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    complex(c_double_complex),                  pointer, intent(out)   :: ptr(:,:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    status = c%alloc(tag, dshape, ptr, description=description, override=override)
  end function ta_allocate_c64_2

  integer(c_int32_t) function ta_allocate_c64_3(c, tag, dshape, ptr, description, override) result(status)
    type(container_t),                        intent(inout) :: c
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    complex(c_double_complex),                  pointer, intent(out)   :: ptr(:,:,:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    status = c%alloc(tag, dshape, ptr, description=description, override=override)
  end function ta_allocate_c64_3

  subroutine ta_allocate_die_r64_1(c, tag, dshape, ptr, description, override)
    type(container_t),                        intent(inout) :: c
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    real(c_double),                  pointer, intent(out)   :: ptr(:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    call c%alloc_or_die(tag, dshape, ptr, description=description, override=override)
  end subroutine ta_allocate_die_r64_1

  subroutine ta_allocate_die_r64_2(c, tag, dshape, ptr, description, override)
    type(container_t),                        intent(inout) :: c
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    real(c_double),                  pointer, intent(out)   :: ptr(:,:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    call c%alloc_or_die(tag, dshape, ptr, description=description, override=override)
  end subroutine ta_allocate_die_r64_2

  subroutine ta_allocate_die_r64_3(c, tag, dshape, ptr, description, override)
    type(container_t),                        intent(inout) :: c
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    real(c_double),                  pointer, intent(out)   :: ptr(:,:,:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    call c%alloc_or_die(tag, dshape, ptr, description=description, override=override)
  end subroutine ta_allocate_die_r64_3

  subroutine ta_allocate_die_r32_1(c, tag, dshape, ptr, description, override)
    type(container_t),                        intent(inout) :: c
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    real(c_float),                  pointer, intent(out)   :: ptr(:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    call c%alloc_or_die(tag, dshape, ptr, description=description, override=override)
  end subroutine ta_allocate_die_r32_1

  subroutine ta_allocate_die_r32_2(c, tag, dshape, ptr, description, override)
    type(container_t),                        intent(inout) :: c
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    real(c_float),                  pointer, intent(out)   :: ptr(:,:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    call c%alloc_or_die(tag, dshape, ptr, description=description, override=override)
  end subroutine ta_allocate_die_r32_2

  subroutine ta_allocate_die_r32_3(c, tag, dshape, ptr, description, override)
    type(container_t),                        intent(inout) :: c
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    real(c_float),                  pointer, intent(out)   :: ptr(:,:,:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    call c%alloc_or_die(tag, dshape, ptr, description=description, override=override)
  end subroutine ta_allocate_die_r32_3

  subroutine ta_allocate_die_i32_1(c, tag, dshape, ptr, description, override)
    type(container_t),                        intent(inout) :: c
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    integer(c_int32_t),                  pointer, intent(out)   :: ptr(:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    call c%alloc_or_die(tag, dshape, ptr, description=description, override=override)
  end subroutine ta_allocate_die_i32_1

  subroutine ta_allocate_die_i32_2(c, tag, dshape, ptr, description, override)
    type(container_t),                        intent(inout) :: c
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    integer(c_int32_t),                  pointer, intent(out)   :: ptr(:,:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    call c%alloc_or_die(tag, dshape, ptr, description=description, override=override)
  end subroutine ta_allocate_die_i32_2

  subroutine ta_allocate_die_i32_3(c, tag, dshape, ptr, description, override)
    type(container_t),                        intent(inout) :: c
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    integer(c_int32_t),                  pointer, intent(out)   :: ptr(:,:,:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    call c%alloc_or_die(tag, dshape, ptr, description=description, override=override)
  end subroutine ta_allocate_die_i32_3

  subroutine ta_allocate_die_i64_1(c, tag, dshape, ptr, description, override)
    type(container_t),                        intent(inout) :: c
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    integer(c_int64_t),                  pointer, intent(out)   :: ptr(:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    call c%alloc_or_die(tag, dshape, ptr, description=description, override=override)
  end subroutine ta_allocate_die_i64_1

  subroutine ta_allocate_die_i64_2(c, tag, dshape, ptr, description, override)
    type(container_t),                        intent(inout) :: c
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    integer(c_int64_t),                  pointer, intent(out)   :: ptr(:,:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    call c%alloc_or_die(tag, dshape, ptr, description=description, override=override)
  end subroutine ta_allocate_die_i64_2

  subroutine ta_allocate_die_i64_3(c, tag, dshape, ptr, description, override)
    type(container_t),                        intent(inout) :: c
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    integer(c_int64_t),                  pointer, intent(out)   :: ptr(:,:,:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    call c%alloc_or_die(tag, dshape, ptr, description=description, override=override)
  end subroutine ta_allocate_die_i64_3

  subroutine ta_allocate_die_c64_1(c, tag, dshape, ptr, description, override)
    type(container_t),                        intent(inout) :: c
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    complex(c_double_complex),                  pointer, intent(out)   :: ptr(:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    call c%alloc_or_die(tag, dshape, ptr, description=description, override=override)
  end subroutine ta_allocate_die_c64_1

  subroutine ta_allocate_die_c64_2(c, tag, dshape, ptr, description, override)
    type(container_t),                        intent(inout) :: c
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    complex(c_double_complex),                  pointer, intent(out)   :: ptr(:,:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    call c%alloc_or_die(tag, dshape, ptr, description=description, override=override)
  end subroutine ta_allocate_die_c64_2

  subroutine ta_allocate_die_c64_3(c, tag, dshape, ptr, description, override)
    type(container_t),                        intent(inout) :: c
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    complex(c_double_complex),                  pointer, intent(out)   :: ptr(:,:,:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    call c%alloc_or_die(tag, dshape, ptr, description=description, override=override)
  end subroutine ta_allocate_die_c64_3

end module tagarray_highlevel
