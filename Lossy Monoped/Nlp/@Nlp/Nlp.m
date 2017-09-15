%NLP Nonlinear programming optimization problem.
%
% Syntax:
%   obj = Nlp;
%
% Optional Input Arguments:
%   name - (CHAR) Problem name.
%   description - (CHAR) Problem description.
%   verbose - (LOGICAL) Set verbosity of user feedback.
%
% Description:
%   NLP is a MATLAB object-oriented class for formulating, building, and
%   solving nonlinear optimization problems.
%
% Features:
%   * Handles a wide variety of optimization problems including linear,
%     nonlinear, constrained, and unconstrained.
%   * Uses a object-oriented interface to abstract the problem formulation,
%     allowing for a simple, intuitive and robust symbolic problem
%     generation.
%   * Automatically generates analytical gradients and Hessians (optional)
%     to increase solver performance.
%   * Includes wrappers to interface MATLAB solvers as well as a hand full
%     of open-source solvers.

% Copyright 2013-2015 Mikhail S. Jones

classdef Nlp < handle

  % PUBLIC PROPERTIES =====================================================
  properties % TODO: set methods
    % Vector of variable lower bounds
    variableLowerBound@double vector = []
    % Vector of variable upper bounds
    variableUpperBound@double vector = []
    % Vector of variable initial guesses
    initialGuess@double vector = []
    % Vector of variable solutions
    solution@double vector = []
  end % properties

  % PROTECTED PROPERTIES ==================================================
  properties (SetAccess = public)
    % Vector of design variables
    variable@Variable
    % Vector of objectives
    objective@Objective
    % Vector of constraints
    constraint@Constraint
    % Options structure
    options@struct scalar
  end % properties

  % DEPENDENT PROPERTIES ==================================================
  properties (Dependent = true)
    % Number of variables in NLP problem
    numberOfVariables@double scalar
    % Number of constraints in NLP problem
    numberOfConstraints@double scalar
    % Number of objectives in NLP problem
    numberOfObjectives@double scalar
  end % properties

  % PUBLIC METHODS ========================================================
  methods
    function obj = Nlp(varargin)
    %NLP Creates a nonlinear programming optimization problem object.

      % Construct input argument parser
      parser = inputParser;
      parser.addParamValue('name', 'No Name', ...
        @(x) validateattributes(x, {'char'}, {}));
      parser.addParamValue('description', 'No Description', ...
        @(x) validateattributes(x, {'char'}, {}));
      parser.addParamValue('verbose', true, ...
        @(x) validateattributes(x, {'logical'}, {'scalar'}));

      % Parse input arguments
      parser.parse(varargin{:});

      % Store the results
      obj.options = parser.Results;
    end % Nlp

    function n = get.numberOfVariables(obj)
    %GET.NUMBEROFVARIABLES Get method for number of variables.

      % Number of variables
      n = length(obj.initialGuess);
    end % get.numberOfVariables

    function n = get.numberOfObjectives(obj)
    %GET.NUMBEROFOBJECTIVES Get method for number of objectives.

      % Number of objectives
      n = length(obj.objective);
    end % get.numberOfObjectives

    function n = get.numberOfConstraints(obj)
    %GET.NUMBEROFCONSTRAINTS Get method for number of constraints.

      % Check if any constraints have been defined
      if isempty(obj.constraint)
        n = 0;
      else
        % Construct reference to object array
        refCons = [obj.constraint.expression];

        % Compute number of constraints
        n = sum([refCons.length]);
      end % if
    end % get.numberOfConstraints
  end % methods
end % classdef
