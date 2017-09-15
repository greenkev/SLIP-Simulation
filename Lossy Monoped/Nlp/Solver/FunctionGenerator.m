%FUNCTIONGENERATOR Function generation object.
%
% Copyright 2013-2015 Mikhail S. Jones

classdef (Abstract = true) FunctionGenerator < handle

  % PROTECTED PROPERTIES ==================================================
  properties (SetAccess = protected)
    argsIn@cell vector = {}
    argsOut@cell vector = {}
    path@char vector = ''
    name@char vector = ''
    fid@double scalar = 1
  end % properties

  % ABSTRACT METHODS ======================================================
  methods (Abstract = true)
    writeHeader
    writeIndex
    writeExpression
    writeFooter
  end % methods

  % PUBLIC METHODS ========================================================
  methods
    function obj = FunctionGenerator(argsIn, argsOut, path, name)
    %FUNCTIONGENERATOR Function generation object constructor.

      % TODO: Input argument checks

      % Set object properties
      obj.argsIn = argsIn;
      obj.argsOut = argsOut;
      obj.path = path;
      obj.name = name;
    end % FunctionGenerator
  end % methods
end % classdef
