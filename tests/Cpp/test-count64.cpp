// Record element counts must be computed in int64_t.  With an int
// accumulator, a 234^4 real64 record (2,998,219,536 elements, 24 GB) wrapped
// to a negative count: no memory was allocated, create() returned OK, and the
// first write through the record's data pointer crashed.
#include <cstdint>
#include <iostream>

#include <tagarray.hpp>

using namespace tagarray;

static int failures = 0;

#define CHECK(cond)                                                            \
  do {                                                                         \
    if (!(cond)) {                                                             \
      std::cerr << __FILE__ << ":" << __LINE__ << ": CHECK failed: " #cond     \
                << std::endl;                                                  \
      failures++;                                                              \
    }                                                                          \
  } while (0)

int main() {
  const int64_t big = (int64_t{1} << 32) + 3; // 3 in a 32-bit int
  const int64_t huge = (int64_t{1} << 61) + 1;

  // begin checked_count
  using hidden::Record;
  // Counts beyond 2^31 and 2^32, and an asymmetric shape.
  CHECK(Record::checked_count({234, 234, 234, 234}, 8) == 2998219536LL);
  CHECK(Record::checked_count({big, 5}, 1) == 5 * big);
  CHECK(Record::checked_count({3, 5, 7}, 8) == 105);
  CHECK(Record::checked_count({0, big, big}, 8) == 0);
  // Invalid extents and int64 overflow of the element or byte count.
  CHECK(Record::checked_count({-1}, 8) == -1);
  CHECK(Record::checked_count({big, huge}, 1) == -1);
  CHECK(Record::checked_count({65536, 65536, 65536, 65536}, 1) == -1);
  CHECK(Record::checked_count({int64_t{1} << 61}, 8) == -1);
  // end checked_count

  // (2^32 + 3) * (2^61 + 1) elements overflow int64_t, so the shape must be
  // refused before any allocation.  A 32-bit accumulator wraps it to 3
  // elements, allocates 24 bytes and stores a record whose count does not
  // match its shape.
  Container c("count64");
  const int32_t status = c.create("wrapped", defines::TYPE_REAL64, {big, huge});
  CHECK(status == defines::DATA_INCORRECT_DIMENSIONS);
  CHECK(!c.contains("wrapped"));
  if (c.contains("wrapped"))
    std::cerr << "stored count " << c["wrapped"]->count() << std::endl;

  // An ordinary asymmetric record is unchanged.
  CHECK(c.create("small", defines::TYPE_REAL64, {3, 5, 7}) == defines::OK);
  CHECK(c["small"]->count() == 105);
  CHECK(c["small"]->byte_count() == 840);
  CHECK(c["small"]->shape() == std::vector<int64_t>({3, 5, 7}));

  if (failures != 0)
    std::cerr << failures << " check(s) failed" << std::endl;
  return failures == 0 ? 0 : 1;
}
