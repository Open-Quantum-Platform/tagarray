module tagarray_container
  use, intrinsic :: iso_c_binding, only: c_int32_t, c_int64_t, c_float, c_double, c_double_complex, c_ptr, c_f_pointer, c_null_ptr, c_associated
  use tagarray_defines
  use tagarray_CAPI
  use tagarray_utils
  use tagarray_recordinfo, only: recordinfo_t
  implicit none
  private
  type, public :: container_t
    type(c_ptr) :: container_ptr = c_null_ptr
  contains
    procedure, public  :: new => container_t_new
    procedure, public  :: delete => container_t_delete
    procedure, public  :: is_allocated => container_t_is_allocated
    procedure, public  :: create => container_t_create
    procedure, public  :: get => container_t_get
    procedure, public  :: append => container_t_append
    procedure, private :: container_t_contains_s
    procedure, private :: container_t_contains_m
    procedure, private :: container_t_erase_s
    procedure, private :: container_t_erase_m
    generic,   public  :: contains => container_t_contains_s, container_t_contains_m
    generic,   public  :: erase => container_t_erase_s, container_t_erase_m
    procedure, public  :: clear => container_t_clear
    procedure, public  :: load => container_t_load
    procedure, public  :: save => container_t_save
    ! High-level "allocate a container-owned array and bind a typed pointer to
    ! it" convenience (added in v1.0.0). One call replaces create + get +
    ! get_status + c_f_pointer; the TA_TYPE_* id is inferred from the pointer.
    procedure, private :: alloc_r64_1, alloc_r64_2, alloc_r64_3
    procedure, private :: alloc_r32_1, alloc_r32_2, alloc_r32_3
    procedure, private :: alloc_i32_1, alloc_i32_2, alloc_i32_3
    procedure, private :: alloc_i64_1, alloc_i64_2, alloc_i64_3
    procedure, private :: alloc_c64_1, alloc_c64_2, alloc_c64_3
    generic,   public  :: alloc => &
        alloc_r64_1, alloc_r64_2, alloc_r64_3, &
        alloc_r32_1, alloc_r32_2, alloc_r32_3, &
        alloc_i32_1, alloc_i32_2, alloc_i32_3, &
        alloc_i64_1, alloc_i64_2, alloc_i64_3, &
        alloc_c64_1, alloc_c64_2, alloc_c64_3
    procedure, private :: alloc_die_r64_1, alloc_die_r64_2, alloc_die_r64_3
    procedure, private :: alloc_die_r32_1, alloc_die_r32_2, alloc_die_r32_3
    procedure, private :: alloc_die_i32_1, alloc_die_i32_2, alloc_die_i32_3
    procedure, private :: alloc_die_i64_1, alloc_die_i64_2, alloc_die_i64_3
    procedure, private :: alloc_die_c64_1, alloc_die_c64_2, alloc_die_c64_3
    generic,   public  :: alloc_or_die => &
        alloc_die_r64_1, alloc_die_r64_2, alloc_die_r64_3, &
        alloc_die_r32_1, alloc_die_r32_2, alloc_die_r32_3, &
        alloc_die_i32_1, alloc_die_i32_2, alloc_die_i32_3, &
        alloc_die_i64_1, alloc_die_i64_2, alloc_die_i64_3, &
        alloc_die_c64_1, alloc_die_c64_2, alloc_die_c64_3
  end type
contains
  subroutine container_t_new(this, description)
    class(container_t), intent(inout) :: this
    character(kind=TA_CHAR, len=*), optional :: description
    character(kind=TA_CHAR, len=:), allocatable :: C_desc
    if (c_associated(this%container_ptr)) call this%delete()
    C_desc = to_Cstring(description)
    this%container_ptr = TA_Container_new(C_desc)
  end subroutine container_t_new
  subroutine container_t_load(this, path)
    class(container_t), intent(inout) :: this
    character(kind=TA_CHAR, len=*), intent(in) :: path
    character(kind=TA_CHAR, len=:), allocatable :: C_path
    if (c_associated(this%container_ptr)) call this%delete()
    C_path = to_Cstring(path)
    this%container_ptr = TA_Container_load(C_path)
  end subroutine container_t_load
  integer(c_int32_t) function container_t_save(this, path) result(status)
    class(container_t), intent(inout) :: this
    character(kind=TA_CHAR, len=*), intent(in) :: path
    character(kind=TA_CHAR, len=:), allocatable :: C_path
    C_path = to_Cstring(path)
    status = TA_Container_save(this%container_ptr, C_path)
  end function container_t_save
  subroutine container_t_delete(this)
    class(container_t), intent(inout) :: this
    call TA_Container_delete(this%container_ptr)
    this%container_ptr = c_null_ptr
  end subroutine container_t_delete
  logical(c_bool) function container_t_is_allocated(this) result(status)
    class(container_t), intent(inout) :: this
    status = c_associated(this%container_ptr)
  end function container_t_is_allocated
  integer(c_int32_t) function container_t_create(this, tag, type_id, shape, data_ptr, description, override) result(status)
    class(container_t),                       intent(inout) :: this
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer(c_int32_t),                       intent(in)    :: type_id
    integer(c_int64_t),                       intent(in)    :: shape(:)
    type(c_ptr),                    optional, intent(in)    :: data_ptr
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    !
    character(kind=TA_CHAR, len=:), allocatable :: Ctag, Cdesc
    Ctag = to_Cstring(tag)
    Cdesc = to_Cstring(description)
    if (present(override)) then
      if (override) then
        call this%erase(Ctag)
      end if
    end if
    if (present(data_ptr)) then
      status = TA_Container_create(this%container_ptr, Ctag, type_id, size(shape, kind=4), shape, data_ptr, Cdesc)
    else
      status = TA_Container_create(this%container_ptr, Ctag, type_id, size(shape, kind=4), shape, c_null_ptr, Cdesc)
    end if
  end function container_t_create
  integer(c_int32_t) function container_t_append(this, tag, shape, data_ptr) result(status)
    class(container_t),                       intent(inout) :: this
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer(c_int64_t),                       intent(in)    :: shape(:)
    type(c_ptr),                    optional, intent(in)    :: data_ptr
    character(kind=TA_CHAR, len=:), allocatable :: Ctag
    Ctag = to_Cstring(tag)
    if (present(data_ptr)) then
      status = TA_Container_append(this%container_ptr, Ctag, size(shape, kind=4), shape, data_ptr)
    else
      status = TA_Container_append(this%container_ptr, Ctag, size(shape, kind=4), shape, c_null_ptr)
    end if
  end function container_t_append
  type(RecordInfo_t) function container_t_get(this, tag) result(ri)
    class(container_t),                       intent(inout) :: this
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    character(kind=TA_CHAR, len=:), allocatable :: Ctag
    Ctag = to_Cstring(tag)
    ri = TA_Container_get(this%container_ptr, Ctag)
  end function container_t_get
  logical(c_bool) function container_t_contains_s(this, tag) result(status)
    class(container_t),                   intent(inout) :: this
    character(kind=TA_CHAR, len=*), intent(in)    :: tag
    character(kind=TA_CHAR, len=:), allocatable   :: Ctag
    Ctag = to_Cstring(tag)
    status = TA_Container_contains(this%container_ptr, Ctag)
  end function container_t_contains_s
  logical(c_bool) function container_t_contains_m(this, tags, id) result(status)
    class(container_t),                   intent(inout) :: this
    character(kind=TA_CHAR, len=*), intent(in)    :: tags(:)
    character(kind=TA_CHAR, len=:), allocatable   :: Ctag
    integer(c_int32_t), optional, intent(out) :: id
    integer :: i
    status = .true.
    if (present(id)) id = 0
    do i = 1, size(tags)
      if (present(id)) id = i
      Ctag = to_Cstring(tags(i))
      status = TA_Container_contains(this%container_ptr, Ctag)
      if (.not.status) return
    end do
  end function container_t_contains_m
  subroutine container_t_erase_s(this, tag)
    class(container_t),             intent(inout) :: this
    character(kind=TA_CHAR, len=*), intent(in)    :: tag
    character(kind=TA_CHAR, len=:), allocatable   :: Ctag
    Ctag = to_Cstring(tag)
    call TA_container_erase(this%container_ptr, Ctag)
  end subroutine container_t_erase_s
  subroutine container_t_erase_m(this, tags)
    class(container_t),             intent(inout) :: this
    character(kind=TA_CHAR, len=*), intent(in)    :: tags(:)
    character(kind=TA_CHAR, len=:), allocatable   :: Ctag
    integer :: i
    do i = 1, size(tags)
      Ctag = to_Cstring(tags(i))
      call TA_container_erase(this%container_ptr, Ctag)
    end do
  end subroutine container_t_erase_m
  subroutine container_t_clear(this)
    class(container_t),             intent(inout) :: this
    call TA_container_clear(this%container_ptr)
  end subroutine container_t_clear

  ! ===================================================================
  ! High-level allocate-and-bind convenience (v1.0.0)
  !
  ! `status = c%alloc(tag, shape, ptr [, description] [, override])`
  ! creates a container-owned record AND binds the caller's typed Fortran
  ! pointer to its (zero-copy) storage in a single call. The TA_TYPE_* id is
  ! taken from the pointer's kind, and `shape` is given as plain default
  ! integers. By default an existing record under `tag` is replaced
  ! (override defaults to .true.); pass override=.false. for create-only
  ! semantics (then a duplicate tag returns TA_CONTAINER_RECORD_EXISTS).
  ! On any failure the pointer is returned null() and the TA_* status is
  ! returned. `c%alloc_or_die(...)` is the fail-fast variant that aborts
  ! with a formatted message instead of returning a status.
  ! ===================================================================
  subroutine container_t_alloc_record(this, tag, type_id, dshape, description, override, rec, status)
    class(container_t),                       intent(inout) :: this
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer(c_int32_t),                       intent(in)    :: type_id
    integer(c_int64_t),                       intent(in)    :: dshape(:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    type(recordinfo_t),                       intent(out)   :: rec
    integer(c_int32_t),                       intent(out)   :: status
    logical :: ov
    ov = .true.
    if (present(override)) ov = override
    status = this%create(tag, type_id, dshape, description=description, override=ov)
    if (status /= TA_OK) return
    rec = this%get(tag)
    status = rec%get_status(type_id, int(size(dshape), c_int64_t))
  end subroutine container_t_alloc_record

  subroutine container_t_alloc_abort(status, tag)
    use, intrinsic :: iso_fortran_env, only: error_unit
    integer(c_int32_t),             intent(in) :: status
    character(kind=TA_CHAR, len=*), intent(in) :: tag
    write(error_unit, '(A)') "tagarray: alloc('"//trim(tag)//"') failed -- "// &
                             get_status_message(status, tag)
    error stop
  end subroutine container_t_alloc_abort

  integer(c_int32_t) function alloc_r64_1(this, tag, dshape, ptr, description, override) result(status)
    class(container_t),                       intent(inout) :: this
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    real(c_double),                  pointer, intent(out)   :: ptr(:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    type(recordinfo_t) :: rec
    ptr => null()
    call container_t_alloc_record(this, tag, TA_TYPE_REAL64, int(dshape, c_int64_t), description, override, rec, status)
    if (status == TA_OK) call c_f_pointer(rec%data, ptr, rec%dims)
  end function alloc_r64_1

  integer(c_int32_t) function alloc_r64_2(this, tag, dshape, ptr, description, override) result(status)
    class(container_t),                       intent(inout) :: this
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    real(c_double),                  pointer, intent(out)   :: ptr(:,:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    type(recordinfo_t) :: rec
    ptr => null()
    call container_t_alloc_record(this, tag, TA_TYPE_REAL64, int(dshape, c_int64_t), description, override, rec, status)
    if (status == TA_OK) call c_f_pointer(rec%data, ptr, rec%dims)
  end function alloc_r64_2

  integer(c_int32_t) function alloc_r64_3(this, tag, dshape, ptr, description, override) result(status)
    class(container_t),                       intent(inout) :: this
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    real(c_double),                  pointer, intent(out)   :: ptr(:,:,:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    type(recordinfo_t) :: rec
    ptr => null()
    call container_t_alloc_record(this, tag, TA_TYPE_REAL64, int(dshape, c_int64_t), description, override, rec, status)
    if (status == TA_OK) call c_f_pointer(rec%data, ptr, rec%dims)
  end function alloc_r64_3

  integer(c_int32_t) function alloc_r32_1(this, tag, dshape, ptr, description, override) result(status)
    class(container_t),                       intent(inout) :: this
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    real(c_float),                  pointer, intent(out)   :: ptr(:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    type(recordinfo_t) :: rec
    ptr => null()
    call container_t_alloc_record(this, tag, TA_TYPE_REAL32, int(dshape, c_int64_t), description, override, rec, status)
    if (status == TA_OK) call c_f_pointer(rec%data, ptr, rec%dims)
  end function alloc_r32_1

  integer(c_int32_t) function alloc_r32_2(this, tag, dshape, ptr, description, override) result(status)
    class(container_t),                       intent(inout) :: this
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    real(c_float),                  pointer, intent(out)   :: ptr(:,:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    type(recordinfo_t) :: rec
    ptr => null()
    call container_t_alloc_record(this, tag, TA_TYPE_REAL32, int(dshape, c_int64_t), description, override, rec, status)
    if (status == TA_OK) call c_f_pointer(rec%data, ptr, rec%dims)
  end function alloc_r32_2

  integer(c_int32_t) function alloc_r32_3(this, tag, dshape, ptr, description, override) result(status)
    class(container_t),                       intent(inout) :: this
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    real(c_float),                  pointer, intent(out)   :: ptr(:,:,:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    type(recordinfo_t) :: rec
    ptr => null()
    call container_t_alloc_record(this, tag, TA_TYPE_REAL32, int(dshape, c_int64_t), description, override, rec, status)
    if (status == TA_OK) call c_f_pointer(rec%data, ptr, rec%dims)
  end function alloc_r32_3

  integer(c_int32_t) function alloc_i32_1(this, tag, dshape, ptr, description, override) result(status)
    class(container_t),                       intent(inout) :: this
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    integer(c_int32_t),                  pointer, intent(out)   :: ptr(:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    type(recordinfo_t) :: rec
    ptr => null()
    call container_t_alloc_record(this, tag, TA_TYPE_INT32, int(dshape, c_int64_t), description, override, rec, status)
    if (status == TA_OK) call c_f_pointer(rec%data, ptr, rec%dims)
  end function alloc_i32_1

  integer(c_int32_t) function alloc_i32_2(this, tag, dshape, ptr, description, override) result(status)
    class(container_t),                       intent(inout) :: this
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    integer(c_int32_t),                  pointer, intent(out)   :: ptr(:,:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    type(recordinfo_t) :: rec
    ptr => null()
    call container_t_alloc_record(this, tag, TA_TYPE_INT32, int(dshape, c_int64_t), description, override, rec, status)
    if (status == TA_OK) call c_f_pointer(rec%data, ptr, rec%dims)
  end function alloc_i32_2

  integer(c_int32_t) function alloc_i32_3(this, tag, dshape, ptr, description, override) result(status)
    class(container_t),                       intent(inout) :: this
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    integer(c_int32_t),                  pointer, intent(out)   :: ptr(:,:,:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    type(recordinfo_t) :: rec
    ptr => null()
    call container_t_alloc_record(this, tag, TA_TYPE_INT32, int(dshape, c_int64_t), description, override, rec, status)
    if (status == TA_OK) call c_f_pointer(rec%data, ptr, rec%dims)
  end function alloc_i32_3

  integer(c_int32_t) function alloc_i64_1(this, tag, dshape, ptr, description, override) result(status)
    class(container_t),                       intent(inout) :: this
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    integer(c_int64_t),                  pointer, intent(out)   :: ptr(:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    type(recordinfo_t) :: rec
    ptr => null()
    call container_t_alloc_record(this, tag, TA_TYPE_INT64, int(dshape, c_int64_t), description, override, rec, status)
    if (status == TA_OK) call c_f_pointer(rec%data, ptr, rec%dims)
  end function alloc_i64_1

  integer(c_int32_t) function alloc_i64_2(this, tag, dshape, ptr, description, override) result(status)
    class(container_t),                       intent(inout) :: this
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    integer(c_int64_t),                  pointer, intent(out)   :: ptr(:,:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    type(recordinfo_t) :: rec
    ptr => null()
    call container_t_alloc_record(this, tag, TA_TYPE_INT64, int(dshape, c_int64_t), description, override, rec, status)
    if (status == TA_OK) call c_f_pointer(rec%data, ptr, rec%dims)
  end function alloc_i64_2

  integer(c_int32_t) function alloc_i64_3(this, tag, dshape, ptr, description, override) result(status)
    class(container_t),                       intent(inout) :: this
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    integer(c_int64_t),                  pointer, intent(out)   :: ptr(:,:,:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    type(recordinfo_t) :: rec
    ptr => null()
    call container_t_alloc_record(this, tag, TA_TYPE_INT64, int(dshape, c_int64_t), description, override, rec, status)
    if (status == TA_OK) call c_f_pointer(rec%data, ptr, rec%dims)
  end function alloc_i64_3

  integer(c_int32_t) function alloc_c64_1(this, tag, dshape, ptr, description, override) result(status)
    class(container_t),                       intent(inout) :: this
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    complex(c_double_complex),                  pointer, intent(out)   :: ptr(:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    type(recordinfo_t) :: rec
    ptr => null()
    call container_t_alloc_record(this, tag, TA_TYPE_CMPLX64, int(dshape, c_int64_t), description, override, rec, status)
    if (status == TA_OK) call c_f_pointer(rec%data, ptr, rec%dims)
  end function alloc_c64_1

  integer(c_int32_t) function alloc_c64_2(this, tag, dshape, ptr, description, override) result(status)
    class(container_t),                       intent(inout) :: this
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    complex(c_double_complex),                  pointer, intent(out)   :: ptr(:,:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    type(recordinfo_t) :: rec
    ptr => null()
    call container_t_alloc_record(this, tag, TA_TYPE_CMPLX64, int(dshape, c_int64_t), description, override, rec, status)
    if (status == TA_OK) call c_f_pointer(rec%data, ptr, rec%dims)
  end function alloc_c64_2

  integer(c_int32_t) function alloc_c64_3(this, tag, dshape, ptr, description, override) result(status)
    class(container_t),                       intent(inout) :: this
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    complex(c_double_complex),                  pointer, intent(out)   :: ptr(:,:,:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    type(recordinfo_t) :: rec
    ptr => null()
    call container_t_alloc_record(this, tag, TA_TYPE_CMPLX64, int(dshape, c_int64_t), description, override, rec, status)
    if (status == TA_OK) call c_f_pointer(rec%data, ptr, rec%dims)
  end function alloc_c64_3

  subroutine alloc_die_r64_1(this, tag, dshape, ptr, description, override)
    class(container_t),                       intent(inout) :: this
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    real(c_double),                  pointer, intent(out)   :: ptr(:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    integer(c_int32_t) :: status
    status = this%alloc(tag, dshape, ptr, description=description, override=override)
    if (status /= TA_OK) call container_t_alloc_abort(status, tag)
  end subroutine alloc_die_r64_1

  subroutine alloc_die_r64_2(this, tag, dshape, ptr, description, override)
    class(container_t),                       intent(inout) :: this
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    real(c_double),                  pointer, intent(out)   :: ptr(:,:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    integer(c_int32_t) :: status
    status = this%alloc(tag, dshape, ptr, description=description, override=override)
    if (status /= TA_OK) call container_t_alloc_abort(status, tag)
  end subroutine alloc_die_r64_2

  subroutine alloc_die_r64_3(this, tag, dshape, ptr, description, override)
    class(container_t),                       intent(inout) :: this
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    real(c_double),                  pointer, intent(out)   :: ptr(:,:,:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    integer(c_int32_t) :: status
    status = this%alloc(tag, dshape, ptr, description=description, override=override)
    if (status /= TA_OK) call container_t_alloc_abort(status, tag)
  end subroutine alloc_die_r64_3

  subroutine alloc_die_r32_1(this, tag, dshape, ptr, description, override)
    class(container_t),                       intent(inout) :: this
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    real(c_float),                  pointer, intent(out)   :: ptr(:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    integer(c_int32_t) :: status
    status = this%alloc(tag, dshape, ptr, description=description, override=override)
    if (status /= TA_OK) call container_t_alloc_abort(status, tag)
  end subroutine alloc_die_r32_1

  subroutine alloc_die_r32_2(this, tag, dshape, ptr, description, override)
    class(container_t),                       intent(inout) :: this
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    real(c_float),                  pointer, intent(out)   :: ptr(:,:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    integer(c_int32_t) :: status
    status = this%alloc(tag, dshape, ptr, description=description, override=override)
    if (status /= TA_OK) call container_t_alloc_abort(status, tag)
  end subroutine alloc_die_r32_2

  subroutine alloc_die_r32_3(this, tag, dshape, ptr, description, override)
    class(container_t),                       intent(inout) :: this
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    real(c_float),                  pointer, intent(out)   :: ptr(:,:,:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    integer(c_int32_t) :: status
    status = this%alloc(tag, dshape, ptr, description=description, override=override)
    if (status /= TA_OK) call container_t_alloc_abort(status, tag)
  end subroutine alloc_die_r32_3

  subroutine alloc_die_i32_1(this, tag, dshape, ptr, description, override)
    class(container_t),                       intent(inout) :: this
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    integer(c_int32_t),                  pointer, intent(out)   :: ptr(:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    integer(c_int32_t) :: status
    status = this%alloc(tag, dshape, ptr, description=description, override=override)
    if (status /= TA_OK) call container_t_alloc_abort(status, tag)
  end subroutine alloc_die_i32_1

  subroutine alloc_die_i32_2(this, tag, dshape, ptr, description, override)
    class(container_t),                       intent(inout) :: this
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    integer(c_int32_t),                  pointer, intent(out)   :: ptr(:,:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    integer(c_int32_t) :: status
    status = this%alloc(tag, dshape, ptr, description=description, override=override)
    if (status /= TA_OK) call container_t_alloc_abort(status, tag)
  end subroutine alloc_die_i32_2

  subroutine alloc_die_i32_3(this, tag, dshape, ptr, description, override)
    class(container_t),                       intent(inout) :: this
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    integer(c_int32_t),                  pointer, intent(out)   :: ptr(:,:,:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    integer(c_int32_t) :: status
    status = this%alloc(tag, dshape, ptr, description=description, override=override)
    if (status /= TA_OK) call container_t_alloc_abort(status, tag)
  end subroutine alloc_die_i32_3

  subroutine alloc_die_i64_1(this, tag, dshape, ptr, description, override)
    class(container_t),                       intent(inout) :: this
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    integer(c_int64_t),                  pointer, intent(out)   :: ptr(:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    integer(c_int32_t) :: status
    status = this%alloc(tag, dshape, ptr, description=description, override=override)
    if (status /= TA_OK) call container_t_alloc_abort(status, tag)
  end subroutine alloc_die_i64_1

  subroutine alloc_die_i64_2(this, tag, dshape, ptr, description, override)
    class(container_t),                       intent(inout) :: this
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    integer(c_int64_t),                  pointer, intent(out)   :: ptr(:,:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    integer(c_int32_t) :: status
    status = this%alloc(tag, dshape, ptr, description=description, override=override)
    if (status /= TA_OK) call container_t_alloc_abort(status, tag)
  end subroutine alloc_die_i64_2

  subroutine alloc_die_i64_3(this, tag, dshape, ptr, description, override)
    class(container_t),                       intent(inout) :: this
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    integer(c_int64_t),                  pointer, intent(out)   :: ptr(:,:,:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    integer(c_int32_t) :: status
    status = this%alloc(tag, dshape, ptr, description=description, override=override)
    if (status /= TA_OK) call container_t_alloc_abort(status, tag)
  end subroutine alloc_die_i64_3

  subroutine alloc_die_c64_1(this, tag, dshape, ptr, description, override)
    class(container_t),                       intent(inout) :: this
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    complex(c_double_complex),                  pointer, intent(out)   :: ptr(:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    integer(c_int32_t) :: status
    status = this%alloc(tag, dshape, ptr, description=description, override=override)
    if (status /= TA_OK) call container_t_alloc_abort(status, tag)
  end subroutine alloc_die_c64_1

  subroutine alloc_die_c64_2(this, tag, dshape, ptr, description, override)
    class(container_t),                       intent(inout) :: this
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    complex(c_double_complex),                  pointer, intent(out)   :: ptr(:,:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    integer(c_int32_t) :: status
    status = this%alloc(tag, dshape, ptr, description=description, override=override)
    if (status /= TA_OK) call container_t_alloc_abort(status, tag)
  end subroutine alloc_die_c64_2

  subroutine alloc_die_c64_3(this, tag, dshape, ptr, description, override)
    class(container_t),                       intent(inout) :: this
    character(kind=TA_CHAR, len=*),           intent(in)    :: tag
    integer,                                  intent(in)    :: dshape(:)
    complex(c_double_complex),                  pointer, intent(out)   :: ptr(:,:,:)
    character(kind=TA_CHAR, len=*), optional, intent(in)    :: description
    logical,                        optional, intent(in)    :: override
    integer(c_int32_t) :: status
    status = this%alloc(tag, dshape, ptr, description=description, override=override)
    if (status /= TA_OK) call container_t_alloc_abort(status, tag)
  end subroutine alloc_die_c64_3
end module tagarray_container
