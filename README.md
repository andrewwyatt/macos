macos
====

This is just a simple script to configure parameters and install apps on my Macbooks.

License
----
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Usage
----

This script is parameterized, and takes exactly one parameter as input.  The default parameter is 'personal' if none is supplied.

The parameter is used to determine the path to check for files necessary to execute the script and make the desired changes to the system.

There are two installation types, 'personal' and 'work'.  The 'common' directory contains configurations that would be executed on all systems.

The script will check each of these subdirectories looking for the following files.  They should be updated to deploy the software you would like to install.

```
include
applists/casks
        /brew
        /mas
scripts/*
```

include
----
This is a plain text file containing other collections that should be included as part of the installation selected.

applists/casks
----
This is a collection of homebrew casks to install on the system, one line per cask.  Comments will be ignored automatically.

applists/brew
----
This is a collection of homebrew to install on the system, one line per cask.  Comments will be ignored automatically.

applists/mas
----
This is a collection of applications to install from the Apple App Store.  The application IDs can be discovered by installing mas and running 'mas list' on a configured system.

scripts/*
----
Each script in this directory will be executed using bash.  This directory should contain snippets of code defining any properties that should be configured.

**Before using this script, evaluate the files in all of the subdirectories and update them to suit your needs**

Execution
----

**Warning:** This script doesn't ask for permission, or for forgiveness.  It will blindly install and change your system without prompting.  Review the script and everything that it does before using.

To use, download or clone this repository and execute install.sh.

```
$ git clone https://github.com/andrewwyatt/osx
$ cd osx
$ ./install.sh {type of installation}
```

Screenshot
----
![Screenshot](./common/data/Screenshot.png)

To Do
----
* Dock defaults
* Finder favorites
