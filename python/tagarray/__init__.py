"""tagarray: share the same array data across C, C++, Fortran and Python.

This pure-Python package re-exports the compiled extension ``_tagarray`` so that
``import tagarray`` gives you ``Container``, ``RecordInfo``, ``types`` and the
status ``defines`` directly.
"""
try:
    # Installed/wheel layout: the extension lives inside this package.
    from . import _tagarray as _ext
except ImportError:  # pragma: no cover - dev/build-tree fallback
    # The extension is a top-level module on PYTHONPATH (e.g. the build dir).
    import _tagarray as _ext

__version__ = "1.0.0"

# Re-export the public names of the extension (those not starting with "_").
__all__ = [name for name in dir(_ext) if not name.startswith("_")]
globals().update({name: getattr(_ext, name) for name in __all__})
