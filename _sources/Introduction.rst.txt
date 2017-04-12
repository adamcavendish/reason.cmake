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
5. Free programmers from remembering the ``include-directories`` and ``extra link`` dependencies
6. Automatically build package for package-manager

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


Convensions
~~~~~~~~~~~

1. reason_install

   - reason uses ``Unix Directory Tree Convension``

     - ``bin      # for executables``
     - ``include  # for header files``
     - ``lib      # for static and shared libraries``
     - ``share    # CMake package info for find_package``

2. reason_add_library

   1. Specify ``STATIC`` to build ``${TARGET}_s`` as static library
   2. Specify ``SHARED`` to build ``${TARGET}_d`` as dynamic library
   3. Both for building both

3. Parameter ``INC_DIRS`` in ``reason_add_executable``, ``reason_add_library`` and ``reaso
n_install``

   1. reason will use ``target_include_directories`` to include these dirs for the target to build only. No other targets will be polluted.
   2. ``reason_install`` will copy all files and directories in these directories


Typical reason.cmake C++ project
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1. A C++ project with internal dependencies

  .. code-block:: text

     Foo
     ├── CMakeLists.txt
     ├── deps
     │   ├── module1
     │   │   ├── CMakeLists.txt
     │   │   ├── include
     │   │   │   └── module1
     │   │   │       └── ... // ... headers for module 1 ...
     │   │   ├── src
     │   │   │   └── ...     // ... module 1 source files ...
     │   │   └── test
     │   │       └── ...     // ... module 1 test files ...
     │   ├── module2
     │   │   ├── CMakeLists.txt
     │   │   ├── include
     │   │   ├── src
     │   │   └── test
     │   └── ...             // ... many other modules ...
     ├── include
     │   └── foo
     │       └── ...         // ... the projects's headers ...
     ├── src                 // ... project's source ...
     └── test                // ... project's test ...


  - Declare ``Foo`` project to depend on ``module1`` with one command:

    .. code-block:: cmake

       add_subdirectory(module1)

  - You can automatically include dependencies' ``include-directories``, and link to ``link-libraries`` via simply ``LINKS``:

    .. code-block:: cmake

       # Just 'LINKS' module1_s, and reason will help you find out
       # what directories 'module1_s' includes and what libraries
       # it links
       reason_add_library(STATIC foo SRC "src/foo_src.cpp" LINKS module1_s)


.. _add_subdirectory(module1): https://github.com/adamcavendish/ReasonableCMakeForCXX/blob/142d595d9864acf477f43281af9c7f9461907768/project3-rewrite_project1_with_reason/CMakeLists.txt#L16
.. _ : https://github.com/adamcavendish/ReasonableCMakeForCXX/blob/142d595d9864acf477f43281af9c7f9461907768/project3-rewrite_project1_with_reason/CMakeLists.txt#L22

2. A C++ project with cross dependencies

  .. code-block:: text

     Foo-project
     ├── CMakeLists.txt   // just use 'add_subdirectory' to specify the build sequence
     │   common
     │   ├── CMakeLists.txt
     │   ├── include
     │   │   └── common
     │   │       └── ...  // ... headers for module common ...
     │   ├── src
     │   │   └── ...      // ... module common source files ...
     │   └── test
     │       └── ...      // ... module common test files ...
     ├── Bar-project      // ... some projects like Foo project specified in 1
     │   ├── CMakeLists.txt
     │   ├── deps         // ... other internal deps ...
     │   ├── include
     │   ├── src
     │   └── test
     ├── Baz-project
     │   ├── CMakeLists.txt
     │   └── ...          // ... other directories ...
     └── ...              // ... other projects ...

  - Use ``add_subdirectory`` in the top ``CMakeLists.txt`` to specify the dependency sequence

    - for example, add ``common`` first

  - For ``Bar-project``, you may just ``LINKS``  ``common_s``, or ``common_d``:

    .. code-block:: cmake

       reason_add_executable(TARGET "bar" SRC "src/main.cpp" LINKS common_s)
