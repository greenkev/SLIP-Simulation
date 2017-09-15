Auto: automate method construction for kinematic and dynamic systems
COPYRIGHT 2017 Andy Abate (abatea@oregonstate.edu)

Contains facilities for deriving Jacobians and equations of motion for
arbitrary systems. Requires R2016b.

To use, subclass any single Auto* class.
Implement abstract methods as required.

Add public properties for any constants associated with the system
(e.g. mass, link length).

The child class must be contained in a class folder
(e.g. '@ClassName/ClassName.m').

The Auto* classes will automatically build class methods for the subclass
and place them in the class folder.
You may have to try instantiating a class multiple times on first use.
MATLAB does not see the methods right away, and proceeds to crash when
the methods are called.

Methods will be rebuilt automatically when the main class file changes.
Touch the class file to force updates.






TODO:
- command to build template class (which avoids errors when generating folder class methods)