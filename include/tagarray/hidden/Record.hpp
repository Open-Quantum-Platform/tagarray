#pragma once

#include <algorithm>
#include <cassert>
#include <cstdint>
#include <limits>
#include <memory>
#include <numeric>
#include <string>
#include <vector>

#include "tagarray/RecordInfo.h"
#include "tagarray/Utils.hpp"

namespace tagarray {
namespace hidden {

class Record {
private:
  const int32_t type_id_;
  const int32_t itemsize_; // size of one element in bytes
  int64_t count_;          // number of elements
  int64_t ndims_;
  std::vector<int64_t> dims_;
  std::shared_ptr<uint8_t[]> data_;
  std::string description_;

public:
  // Element count of a record with extents `dims`, evaluated in int64_t.
  // Returns -1 for a negative extent, or when the element count or the byte
  // count (count * itemsize) does not fit in int64_t.
  inline static int64_t checked_count(const std::vector<int64_t> &dims,
                                      const int32_t itemsize) noexcept {
    int64_t count = 1;
    for (const auto extent : dims) {
      if (extent < 0)
        return -1;
      if (extent != 0 && count > std::numeric_limits<int64_t>::max() / extent)
        return -1;
      count *= extent;
    }
    if (itemsize > 0 && count > std::numeric_limits<int64_t>::max() / itemsize)
      return -1;
    return count;
  }

  Record(const int32_t type_id, std::vector<int64_t> dimensions,
         const uint8_t *const data = nullptr,
         const std::string &description = std::string(""))
      : type_id_(type_id), itemsize_(utils::get_storage_size(type_id)),
        ndims_(dimensions.size()), dims_(dimensions),
        description_(description) {
    this->count_ = checked_count(this->dims_, this->itemsize_);
    assert(this->byte_count() != 0);
    if (this->byte_count() <= 0)
      return;
    auto deleter = [](uint8_t *ptr) {
      operator delete[](ptr, std::align_val_t(32));
    };
    std::shared_ptr<uint8_t[]> tmp(new (std::align_val_t(64), std::nothrow)
                                       uint8_t[this->byte_count()],
                                   deleter);
    this->data_ = tmp;
    if (this->data_.get() == nullptr) {
      return;
    }
    if (data == nullptr) {
      std::fill(this->data_.get(), this->data_.get() + this->byte_count(), 0);
    } else {
      std::copy(data, data + this->byte_count(), this->data_.get());
    }
  }

  Record(const Record &rec)
      : type_id_(rec.type_id()), itemsize_(rec.itemsize()), count_(rec.count()),
        ndims_(rec.ndims()), dims_(rec.shape()), data_(rec.data_),
        description_(rec.description()) {}

  ~Record() {}

  inline const std::string &description() const noexcept {
    return this->description_;
  }

  inline std::string &description() noexcept { return this->description_; }

  inline void description(const std::string &str) noexcept {
    this->description_ = str;
  }

  inline int32_t type_id() const noexcept { return this->type_id_; }

  inline int32_t itemsize() const noexcept { return this->itemsize_; }

  inline int64_t count() const noexcept { return this->count_; }

  inline int64_t byte_count() const noexcept {
    return this->count_ * this->itemsize_;
  }

  inline int64_t ndims() const noexcept { return this->ndims_; }

  inline const std::vector<int64_t> &shape() const noexcept {
    return this->dims_;
  }

  inline void shape(const std::vector<int64_t> &shape) noexcept {
    assert(this->count_ == checked_count(shape, this->itemsize_));
    this->ndims_ = shape.size();
    this->dims_ = shape;
  }

  template <typename T> inline auto raw_data() const noexcept {
    return reinterpret_cast<T>(this->data_.get());
  }

  inline int32_t append(const std::vector<int64_t> &shape,
                        const uint8_t *const data = nullptr) noexcept {
    assert(this->ndims_ == 1);
    assert(shape.size() == 1);
    int64_t shift = checked_count(shape, this->itemsize_);
    if (shift < 0 ||
        shift > std::numeric_limits<int64_t>::max() / this->itemsize_ -
                    this->count_)
      return defines::DATA_INCORRECT_DIMENSIONS;
    int64_t new_count = shift + this->count_;
    if (new_count == this->count_)
      return defines::NOT_IMPLEMENTED;
    assert(new_count > this->count_);
    auto deleter = [](uint8_t *ptr) {
      operator delete[](ptr, std::align_val_t(64));
    };
    std::shared_ptr<uint8_t[]> tmp(new (std::align_val_t(64), std::nothrow)
                                       uint8_t[this->itemsize() * new_count],
                                   deleter);
    if (tmp.get() == nullptr) {
      return defines::NOT_IMPLEMENTED;
    }
    std::copy(this->data_.get(), this->data_.get() + this->byte_count(),
              tmp.get());
    if (data == nullptr) {
      std::fill(tmp.get() + this->byte_count(),
                tmp.get() + new_count * this->itemsize(), 0);
    } else {
      std::copy(data, data + shift * this->itemsize(),
                tmp.get() + this->byte_count());
    }
    this->count_ = new_count;
    this->ndims_ = shape.size();
    for (size_t i = 0; i < this->dims_.size(); i++) {
      this->dims_[i] += shape[i];
    }
    std::swap(this->data_, tmp);
    return defines::OK;
  }

  inline std::shared_ptr<Record> copy() const noexcept {
    return std::make_shared<Record>(Record(*this));
  }

  inline std::shared_ptr<Record> deepcopy() const noexcept {
    return std::make_shared<Record>(Record(this->type_id(), this->shape(),
                                           this->data_.get(),
                                           this->description()));
  }

  inline RecordInfo info() const noexcept {
    RecordInfo recordInfo = {this->type_id_,
                             this->itemsize_,
                             this->count_,
                             this->ndims_,
                             const_cast<int64_t *>(this->dims_.data()),
                             this->data_.get(),
                             const_cast<char *>(this->description_.data())};
    return recordInfo;
  }

  inline static const Record invalid() noexcept {
    Record invalid(defines::TYPE_UNKNOWN, {-1}, nullptr, "invalid");
    return invalid;
  }
};
} // namespace hidden
} // namespace tagarray