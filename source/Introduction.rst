Introduction
------------

CMake is flexible
~~~~~~~~~~~~~~~~~

CMake is a highly flexible build system, but hard to use.

You might:

1. Manually write many ``custom targets`` to help cmake build up its dependency graph to build anything you like.
2. Use `ExternalProject`_ to pull projects from github, build and install to any directory you like

But ...

- Being flexible means being frustrated to get it configured right
  - You don't know the best practice while having no the time to skim through all approaches
- Being flexible preserves way too much functionalities, and you're simply writing code to choose what you want indeed

.. _ExternalProject: https://cmake.org/cmake/help/latest/module/ExternalProject.html

What ``reason.cmake`` can and cannot solve
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Solve it:

1. Simplify the whole CMake process
2. Smooth ``CMakeLists.txt`` writing
3. Unify C++ project structures
4. Enable modular CMake ``find_pacage`` experience
5. Build package for package-manager

   1. deb
   2. rpm (TODO)

Not solved:

1. C++ language level modules

   1. Modules is already proposed for C++ (`Modules`_), but not yet adopted
   2. Clang has already implemented it (`Modules in Clang`_)
   3. CMake's ``find_package`` and ``add_subdirectory`` is not the final solution

2. ABI incompatibility

.. _Modules: http://open-std.org/JTC1/SC22/WG21/docs/papers/2016/p0143r1.pdf
.. _Modules in Clang: https://clang.llvm.org/docs/Modules.html
