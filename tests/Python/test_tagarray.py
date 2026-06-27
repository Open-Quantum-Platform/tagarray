"""pytest suite for the tagarray Python bindings."""
import numpy as np
import pytest
import tagarray


def test_roundtrip_1d():
    c = tagarray.Container("t")
    c["v"] = np.asfortranarray(np.arange(5, dtype=np.float64))
    out = np.asarray(c["v"].data)
    assert out.shape == (5,)
    assert np.allclose(out, np.arange(5))


def test_roundtrip_2d_fortran_order():
    c = tagarray.Container("t")
    a = np.asfortranarray(np.arange(6, dtype=np.float64).reshape(2, 3))
    c["m"] = a
    out = np.asarray(c["m"].data)
    assert out.shape == (2, 3)
    assert np.allclose(out, a)


def test_contains_and_len():
    c = tagarray.Container("t")
    c["a"] = np.asfortranarray([1.0, 2.0])
    assert "a" in c
    assert "b" not in c
    assert len(c) == 1


def test_overwrite():
    c = tagarray.Container("t")
    c["x"] = np.asfortranarray([1.0])
    c["x"] = np.asfortranarray([2.0, 3.0])
    assert np.allclose(np.asarray(c["x"].data), [2.0, 3.0])


def test_integer_dtype():
    c = tagarray.Container("t")
    c["i"] = np.asfortranarray(np.array([1, 2, 3], dtype=np.int64))
    assert np.array_equal(np.asarray(c["i"].data), [1, 2, 3])


def test_version():
    assert tagarray.__version__ == "1.0.0"
