# Introduction

Last month I published a article on how to use [ JavascriptCore ](http://www.spazstik-software.com/blog/article/how-to-example-extend-a-ios-using-javascriptcore-as-a-macro-engine) for extending a iOS application with macro support.  While Javascript has many uses, as a way for application customization, it would not be my first choice.

A better choice to me would be a language like Python.  Being curious, I wondered what it would take to to use Python.

This is a demo application that accompanies the blog article [ How To: Support User Editable Python Macros In a iOS Application ](http://www.spazstik-software.com/blog/article/how-to-support-user-editable-python-macros-in-a-ios-application)


## Building Instructions
This demo application relies upon the [Python-Apple-Support.](https://github.com/pybee/Python-Apple-support) provided by [BeeWare Project](http://pybee.org).

[Download the Python Apple support package for iOS](https://github.com/pybee/Python-Apple-support/releases/download/3.5-b1/Python-3.5-iOS-support.b1.tar.gz), and extract it. This will give you four frameworks.

* ``BZip2.framework``

* ``OpenSSL.framework``

* ``XZ.framework``

* ``Python.framework``

Or, you can download the [Python-Apple-Support.](https://github.com/pybee/Python-Apple-support)_ project, and
build the 3.5 version of these frameworks.

Copy the four frameworks into the root directory of this project.  This application will compile with one warning when targeting the simulator.  The warning is not present when targeting a device.
